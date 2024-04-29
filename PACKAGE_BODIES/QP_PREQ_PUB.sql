--------------------------------------------------------
--  DDL for Package Body QP_PREQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PREQ_PUB" AS
  /* $Header: QPXPPREB.pls 120.27.12010000.16 2010/03/03 12:55:40 kdurgasi ship $ */

  l_debug VARCHAR2(3);
  G_VERSION VARCHAR2(240) := '/* $Header: QPXPPREB.pls 120.27.12010000.16 2010/03/03 12:55:40 kdurgasi ship $ */';
  G_ATTR_MGR_INSTALLED CONSTANT VARCHAR2(1) := QP_UTIL.Attrmgr_Installed;

  G_ROUNDING_OPTIONS VARCHAR2(30);
  G_USE_MULTI_CURRENCY_PUB VARCHAR2(1); -- bug 2943033
  G_ROUND_INDIVIDUAL_ADJ VARCHAR2(30);
  G_CALCULATE_FLAG VARCHAR2(30); --3401941

  G_NO_ROUND CONSTANT VARCHAR2(30) := 'NO_ROUND';
  G_ROUND_ADJ CONSTANT VARCHAR2(30) := 'ROUND_ADJ';
  G_NO_ROUND_ADJ CONSTANT VARCHAR2(30) := 'NO_ROUND_ADJ';
  G_ROUNDING_PROFILE CONSTANT VARCHAR2(1) := 'Q';

  G_POST_ROUND CONSTANT VARCHAR2(30) := 'POST'; --[prarasto:Post Round] constant for post rounding

  G_LIMITS_INSTALLED CONSTANT VARCHAR2(1) := FND_PROFILE.VALUE('QP_LIMITS_INSTALLED');

  --prg processing pl/sql tbl
  G_PRG_UNCH_CALC_PRICE_TBL QP_PREQ_GRP.NUMBER_TYPE;
  G_PRG_UNCH_LINE_ID_TBL QP_PREQ_GRP.NUMBER_TYPE;
  G_PRG_UNCH_LINE_IND_TBL QP_PREQ_GRP.NUMBER_TYPE;
  G_prg_unch_new_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  G_prg_unch_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  G_prg_unch_process_sts_tbl QP_PREQ_GRP.VARCHAR_TYPE;

  G_ldet_plsql_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  G_BACK_CALCULATION_CODE VARCHAR2(30);

  G_NO_ADJ_PROCESSING VARCHAR2(1); --3169430
  G_QP_INSTALL_STATUS VARCHAR2(1) := QP_UTIL.get_qp_status; --3169430


  TYPE BACK_CALC_REC_TYPE IS RECORD
  (LINE_INDEX NUMBER
   , LINE_DETAIL_INDEX NUMBER
   , LIST_LINE_ID NUMBER
   , LIST_LINE_TYPE_CODE VARCHAR2(30)
   , ADJUSTMENT_AMOUNT NUMBER
   , MODIFIER_LEVEL_CODE VARCHAR2(30)
   , OPERAND_VALUE NUMBER
   , APPLIED_FLAG VARCHAR2(1)
   , UPDATED_FLAG VARCHAR2(1)
   , PROCESS_CODE VARCHAR2(30)
   , PRICING_STATUS_CODE VARCHAR2(30)
   , PRICING_STATUS_TEXT VARCHAR2(240)
   , ROUNDING_FACTOR NUMBER
   , CALCULATION_CODE VARCHAR2(30)
   , LINE_QUANTITY NUMBER
   , LIST_HEADER_ID NUMBER
   , LIST_TYPE_CODE VARCHAR2(30)
   , PRICE_BREAK_TYPE_CODE VARCHAR2(30)
   , CHARGE_TYPE_CODE VARCHAR2(30)
   , CHARGE_SUBTYPE_CODE VARCHAR2(30)
   , AUTOMATIC_FLAG VARCHAR2(1)
   , PRICING_PHASE_ID NUMBER
   , LIMIT_CODE VARCHAR2(30)
   , LIMIT_TEXT VARCHAR2(2000)
   , OPERAND_CALCULATION_CODE VARCHAR2(30)
   , PRICING_GROUP_SEQUENCE NUMBER
   , LIST_LINE_NO VARCHAR2(240));


  G_NOT_MAX_FRT_CHARGE CONSTANT VARCHAR2(100) := 'QP_PREQ_PUB:DELETED TO RETURN MAX/OVERRID FREIGHT CHARGE';
  G_FREEZE_OVERRIDE_FLAG VARCHAR2(1) := '';
  G_GSA_ENABLED_FLAG VARCHAR2(1) := NULL; --FND_API.G_MISS_CHAR;

  FUNCTION Get_Version RETURN VARCHAR2 IS
  BEGIN
    RETURN G_Version;
  END Get_Version;

  PROCEDURE INITIALIZE_CONSTANTS(p_control_rec IN QP_PREQ_GRP.CONTROL_RECORD_TYPE
                                 , x_return_status_text OUT NOCOPY VARCHAR2
                                 , x_return_status OUT NOCOPY VARCHAR2) IS
  /*
indxno index used
*/
  CURSOR l_init_pricelist_phase_cur IS
    SELECT PHASE_SEQUENCE, PRICING_PHASE_ID
    FROM QP_PRICING_PHASES
    WHERE  LIST_TYPE_CODE = 'PRL'
    AND    ROWNUM < 2;

  /*
INDX,QP_PREQ_PUB.initialize_constants.l_check_pricing_phase_exists,QP_PRICING_PHASES_U1,PRICING_PHASE_ID,1
INDX,QP_PREQ_PUB.initialize_constants.l_check_pricing_phase_exists,QP_EVENT_PHASES_U1,PRICING_EVENT_CODE,1
INDX,QP_PREQ_PUB.initialize_constants.l_check_pricing_phase_exists,QP_EVENT_PHASES_U1,PRICING_PHASE_ID,1
*/
  CURSOR l_check_pricing_phase_exists(p_event VARCHAR2) IS
    SELECT   b.pricing_phase_id
            , nvl(b.user_freeze_override_flag, b.freeze_override_flag)
    FROM   qp_event_phases a, qp_pricing_phases b
    WHERE  instr(p_event, a.pricing_event_code || ',') > 0
    AND ((G_GET_FREIGHT_FLAG = G_YES AND b.freight_exists = G_YES)
         OR (G_GET_FREIGHT_FLAG = G_NO))
    AND    a.pricing_phase_id = G_PRICE_LIST_PHASE_ID
    AND    b.pricing_phase_id = G_PRICE_LIST_PHASE_ID;

  /*
indxno index used
*/
  CURSOR l_currency_code_cur IS
    SELECT    currency_code
    FROM qp_npreq_lines_tmp;

  /*
indxno index used
*/
  CURSOR l_min_max_eff_date_cur IS
    SELECT MIN(pricing_effective_date)
            , MAX(pricing_effective_date)
    FROM qp_npreq_lines_tmp;

  /*
indxno index used
*/
  CURSOR l_attr_sourcing_cur IS
    SELECT line_index
            , line_quantity
            , priced_quantity
            , unit_price
    FROM qp_npreq_lines_tmp;

  l_attr_sourcing_rec l_attr_sourcing_cur%ROWTYPE;

  l_bypass_pricing VARCHAR2(30);
  l_FIXED_PRICE CONSTANT NUMBER := 11.99;
  l_pricing_phase NUMBER;
  l_price_phase_flag VARCHAR2(1) := G_NO;
  l_freeze_override_flag VARCHAR2(3);
  l_null_eff_date_line NUMBER;
  l_currency_code VARCHAR2(30);
  l_status_text VARCHAR2(30);
  l_routine VARCHAR2(50) := 'QP_PREQ_PUB.Initialize_Constants';
  --sourcing volume attributes performance changes
  l_source_qty_flag VARCHAR2(1);
  l_source_amt_flag VARCHAR2(1);
  l_null_price_req_code VARCHAR2(1) := G_NO;
  l_missing_header VARCHAR2(30) := 'MISSING HEADER';
  l_order_header_id NUMBER := 0;


  E_CURRENCY_CODE_IS_NULL EXCEPTION;
  E_INVALID_PHASE EXCEPTION;
  E_INVALID_CONTROL_RECORD EXCEPTION;
  E_BYPASS_PRICING EXCEPTION;
  E_OTHER_ERRORS EXCEPTION;

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('begin initialize_constants');

    END IF;


    l_bypass_pricing := FND_PROFILE.VALUE(G_BYPASS_PRICING);

    --pricing event can be null when applying manual adjustments
    --IF(p_control_rec.PRICING_EVENT IS NULL
    IF (p_control_rec.calculate_flag = NULL
        OR UPPER(p_control_rec.SIMULATION_FLAG) NOT IN (G_YES, G_NO)
        ) THEN
      RAISE E_INVALID_CONTROL_RECORD;
    END IF;


    --update request_type_code to lines_tmp

    UPDATE qp_npreq_lines_tmp
    SET request_type_code = p_control_rec.request_type_code
    WHERE request_type_code IS NULL;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('1 initialize_constants');

    END IF;
    --populate G_PRICE_LIST_SEQUENCE,G_PRICE_LIST_PHASE_ID
    OPEN l_init_pricelist_phase_cur;
    FETCH l_init_pricelist_phase_cur INTO G_PRICE_LIST_SEQUENCE, G_PRICE_LIST_PHASE_ID;
    CLOSE l_init_pricelist_phase_cur;


    IF(G_PRICE_LIST_SEQUENCE = NULL OR G_PRICE_LIST_SEQUENCE = FND_API.G_MISS_NUM
       OR G_PRICE_LIST_PHASE_ID = NULL OR G_PRICE_LIST_PHASE_ID = FND_API.G_MISS_NUM) THEN
      RAISE E_INVALID_PHASE;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('2 initialize_constants');

    END IF;
    IF (l_bypass_pricing = 'Y' ) THEN

      BEGIN
        /*
	indx no index used
	*/
        UPDATE qp_npreq_lines_tmp SET
                unit_price = l_FIXED_PRICE,
                adjusted_unit_price = l_FIXED_PRICE,
                pricing_status_code = G_STATUS_UPDATED
        WHERE unit_price IS NULL
                OR adjusted_unit_price IS NULL
                OR unit_price = FND_API.G_MISS_NUM
                OR adjusted_unit_price = FND_API.G_MISS_NUM;
      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('QP_PREQ_PUB: Init_cons update status '|| SQLERRM);
          END IF;
          x_return_status_text := SQLERRM;
          RAISE E_OTHER_ERRORS;
      END;
      RAISE E_BYPASS_PRICING;

    END IF;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('3 initialize_constants');

    END IF;
    OPEN l_check_pricing_phase_exists(p_control_rec.PRICING_EVENT);
    FETCH l_check_pricing_phase_exists INTO l_pricing_phase, l_freeze_override_flag;
    CLOSE l_check_pricing_phase_exists;

    IF (l_pricing_phase IS NOT NULL) THEN
      l_price_phase_flag := G_YES;
      G_PRICE_PHASE_FLAG := TRUE;
    ELSE
      l_price_phase_flag := G_NO;
      G_PRICE_PHASE_FLAG := FALSE;
    END IF;

    G_FREEZE_OVERRIDE_FLAG := l_freeze_override_flag;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('4 initialize_constants');


    END IF;
    OPEN l_CURRENCY_CODE_CUR;
    FETCH l_CURRENCY_CODE_CUR INTO G_CURRENCY_CODE;
    CLOSE l_CURRENCY_CODE_CUR;
    --We expect that the user will pass currency code
    --if not the engine will not return right price
    IF G_CURRENCY_CODE IS NULL THEN
      RAISE E_CURRENCY_CODE_IS_NULL;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('5 initialize_constants');

    END IF;
    OPEN l_min_max_eff_date_cur;
    FETCH l_min_max_eff_date_cur INTO G_MIN_PRICING_DATE, G_MAX_PRICING_DATE;
    CLOSE l_min_max_eff_date_cur;


    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('5.5 initialize_constants');
    END IF;
    --update the price flag on summary line to 'P' if there is at least
    --one line with price flag 'P'
    --This is to avoid any more order level adjustments applied
    --if any line has price_flag N/P
    -- Not needed as this is being done in OM. Also OC folks got affected by this change wherein order level
    -- adjustments were not getting applied on a service line pricing
    -- Talked to Amy 01/14/03 and she confirmed that we can comment out this update

    /* update qp_npreq_lines_tmp set price_flag = G_PHASE
		where line_type_code = G_ORDER_LEVEL
		and exists(select 'Y' from qp_npreq_lines_tmp
		where price_flag in (G_PHASE,G_NO,G_CALCULATE_ONLY)
		and line_type_code = G_LINE_LEVEL); */

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('5.6 initialize_constants');
    END IF;
    --fix for bug 2374591 ask for promotions not getting applied
    --updating the list_header_id in the attribute where list_line_id is passed
    UPDATE qp_npreq_line_attrs_tmp attr SET attr.list_header_id =
            (SELECT qpl.list_header_id FROM
             qp_list_lines qpl WHERE qpl.list_line_id = to_number(attr.value_from))
            WHERE attr.context = 'MODLIST'
            AND attribute = 'QUALIFIER_ATTRIBUTE2'
            AND pricing_status_code = 'X';

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('6 initialize_constants');
      QP_PREQ_GRP.engine_debug('Before update_rounding_factor:calculate_flag '
                               || p_control_rec.calculate_flag ||' rounding_flag '
                               || p_control_rec.rounding_flag);

    END IF;
    --This is to populate rounding factor based on price list on the line
    --when engine is called with calculate_only as the calling appln does not
    --store rounding_fac hence rounding factor will be null
    IF p_control_rec.calculate_flag = G_CALCULATE_ONLY
      AND nvl(p_control_rec.rounding_flag, G_YES) IN ('Q', 'U', G_YES, 'P') --[prarasto:Post Round] Added check to
                                                                            --update rounding factor for Post Rounding
      THEN
      QP_PREQ_GRP.update_rounding_factor(G_USE_MULTI_CURRENCY_PUB,
                                         x_return_status,
                                         x_return_status_text);
      IF x_return_status = FND_API.G_RET_STS_ERROR
        THEN
        RAISE E_OTHER_ERRORS;
      END IF;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('6.5 initialize_constants');

    END IF;
    BEGIN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_PUB before insert source line quantity ');
      END IF;
      --sourcing volume attributes performance changes
      l_source_qty_flag := QP_BUILD_SOURCING_PVT.Is_Attribute_Used('VOLUME', 'PRICING_ATTRIBUTE10');
      IF l_source_qty_flag = G_YES
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Sourcing Line Quantity');

        END IF;
        /*
indxno index used
*/
        INSERT INTO qp_npreq_line_attrs_tmp
        (LINE_INDEX
         , LINE_DETAIL_INDEX
         , ATTRIBUTE_LEVEL
         , NO_QUALIFIERS_IN_GRP
         , COMPARISON_OPERATOR_TYPE_CODE
         , VALIDATED_FLAG
         , APPLIED_FLAG
         , PRICING_STATUS_CODE
         , PRICING_STATUS_TEXT
         , QUALIFIER_PRECEDENCE
         , PRICING_ATTR_FLAG
         , QUALIFIER_TYPE
         , DATATYPE
         , PRODUCT_UOM_CODE
         , VALUE_TO
         , SETUP_VALUE_TO
         , GROUPING_NUMBER
         , GROUP_AMOUNT
         , DISTINCT_QUALIFIER_FLAG
         , SETUP_VALUE_FROM
         , ATTRIBUTE_TYPE
         , LIST_HEADER_ID
         , LIST_LINE_ID
         , CONTEXT
         , ATTRIBUTE
         , VALUE_FROM
         , PROCESSED_CODE
         , EXCLUDER_FLAG
         , GROUP_QUANTITY
         )
        SELECT
        LINE_INDEX
        , NULL
        , G_LINE_LEVEL
        , NULL
        , NULL
        , G_NO
        , G_LIST_NOT_APPLIED
        , G_STATUS_UNCHANGED
        , NULL
        , NULL
        , G_YES
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , G_PRICING_TYPE
        , NULL
        , NULL
        , G_PRIC_VOLUME_CONTEXT
        , G_QUANTITY_ATTRIBUTE
        , decode(l_price_phase_flag, G_YES, qp_number.number_to_canonical(nvl(LINE_QUANTITY, 0)), G_NO, qp_number.number_to_canonical(NVL(nvl(PRICED_QUANTITY, LINE_QUANTITY), 0)), 0)
        , NULL
        , NULL
        , NULL
        FROM qp_npreq_lines_tmp;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('QP_PREQ_PUB after insert source line quantity ');
        END IF;
      END IF; --sourcing volume attributes performance changes
    EXCEPTION
      WHEN OTHERS THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('QP_PREQ_PUB init_cons sourceqty exp '|| SQLERRM);
        END IF;
        x_return_status_text := SQLERRM;
        RAISE E_OTHER_ERRORS;
    END;



    BEGIN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_PUB before insert source line amt ');
      END IF;
      --sourcing volume attributes performance changes
      l_source_amt_flag := QP_BUILD_SOURCING_PVT.Is_Attribute_Used('VOLUME', 'PRICING_ATTRIBUTE12');
      IF l_source_amt_flag = G_YES
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Sourcing Line Amount');
        END IF;
        /*
indxno index used
*/
        INSERT INTO qp_npreq_line_attrs_tmp
        (LINE_INDEX
         , LINE_DETAIL_INDEX
         , ATTRIBUTE_LEVEL
         , NO_QUALIFIERS_IN_GRP
         , COMPARISON_OPERATOR_TYPE_CODE
         , VALIDATED_FLAG
         , APPLIED_FLAG
         , PRICING_STATUS_CODE
         , PRICING_STATUS_TEXT
         , QUALIFIER_PRECEDENCE
         , PRICING_ATTR_FLAG
         , QUALIFIER_TYPE
         , DATATYPE
         , PRODUCT_UOM_CODE
         , VALUE_TO
         , SETUP_VALUE_TO
         , GROUPING_NUMBER
         , GROUP_AMOUNT
         , DISTINCT_QUALIFIER_FLAG
         , SETUP_VALUE_FROM
         , ATTRIBUTE_TYPE
         , LIST_HEADER_ID
         , LIST_LINE_ID
         , CONTEXT
         , ATTRIBUTE
         , VALUE_FROM
         , PROCESSED_CODE
         , EXCLUDER_FLAG
         , GROUP_QUANTITY
         )
        SELECT
        LINE_INDEX
        , NULL
        , LINE_TYPE_CODE
        , NULL
        , NULL
        , G_NO
        , QP_PREQ_GRP.G_LIST_NOT_APPLIED
        , G_STATUS_UNCHANGED
        , NULL
        , NULL
        , G_YES
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , G_PRICING_TYPE
        , NULL
        , NULL
        , G_PRIC_VOLUME_CONTEXT
        , G_LINE_AMT_ATTRIBUTE
        , decode(l_price_phase_flag, G_YES, qp_number.number_to_canonical(nvl(LINE_QUANTITY * UNIT_PRICE, 0)), G_NO, qp_number.number_to_canonical(NVL(nvl(PRICED_QUANTITY, LINE_QUANTITY), 0) * nvl(UNIT_PRICE, 0)), 0)
        , NULL
        , NULL
        , NULL
        FROM qp_npreq_lines_tmp;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('QP_PREQ_PUB after insert source line amt ');
        END IF;
      END IF; --sourcing volume attributes performance changes
    EXCEPTION
      WHEN OTHERS THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('QP_PREQ_PUB init_cons sourceamt exp '|| SQLERRM);
        END IF;
        x_return_status_text := SQLERRM;
        RAISE E_OTHER_ERRORS;
    END;

    -- limits check commented out per Ravi, part of accum range break changes
    --IF G_LIMITS_INSTALLED = G_YES THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('7.5 initialize_constants');
    END IF;
    BEGIN
      --populate G_ORDER_PRICE_REQUEST_CODE for limits
      SELECT line_id
      INTO l_order_header_id
      FROM qp_npreq_lines_tmp
      WHERE line_type_code = G_ORDER_LEVEL;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('l_order_header_id '|| l_order_header_id);
      END IF;
      QP_PREQ_GRP.G_ORDER_ID := l_order_header_id; -- accum range break
      QP_PREQ_GRP.G_LINE_ID := null; -- 5706129, accum range break
      IF l_order_header_id = 0 THEN
        QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE := G_REQUEST_TYPE_CODE || '-' || l_missing_header;
      ELSE
        QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE := G_REQUEST_TYPE_CODE || '-' || l_order_header_id;
      END IF; --l_order_header_id
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE '|| QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        --this is not an error may be the summary line was not passed
        QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE := G_REQUEST_TYPE_CODE || '-' || l_missing_header;
    END;
    --END IF;--G_LIMITS_INSTALLED

    IF G_LIMITS_INSTALLED = G_YES THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('7.6 initialize_constants');
      END IF;
      BEGIN
        --populate price_request_code if not passed
        SELECT G_YES INTO l_null_price_req_code
        FROM qp_npreq_lines_tmp
        WHERE price_request_code IS NULL
        AND price_flag IN (G_YES, G_PHASE)
        AND ROWNUM = 1;

        IF l_null_price_req_code = G_YES THEN
          UPDATE qp_npreq_lines_tmp SET
          price_request_code = decode(line_type_code,
                                      G_ORDER_LEVEL, QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE
                                      , G_LINE_LEVEL, QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE || '-' || nvl(line_id, qp_limit_price_request_code_s.NEXTVAL))
          WHERE price_request_code IS NULL
          AND price_flag IN (G_YES, G_PHASE);
        END IF; --l_null_price_req_code
      EXCEPTION
        WHEN OTHERS THEN
          --this is not an error
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('populate price_request_code excep '|| SQLERRM);
          END IF;
          NULL;
      END;
    END IF; --G_LIMITS_INSTALLED


    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('8.0 initialize_constants');
    END IF;
    -------------------------------------------------------------------------
  EXCEPTION
    WHEN E_CURRENCY_CODE_IS_NULL THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Currency code can not be null');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' Error : Currency can not be null';
    WHEN E_INVALID_CONTROL_RECORD THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' INVALID CONTROL RECORD';
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(x_return_status_text);
      END IF;
    WHEN E_INVALID_PHASE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' Invalid phase sequence for Price List phase, Check setup data';
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Invalid phase sequence for Price List phase');
      END IF;
    WHEN E_BYPASS_PRICING THEN
      x_return_status := 'BYPASS_PRICING';
      x_return_status_text := l_routine ||' Pricing Bypassed';
    WHEN E_OTHER_ERRORS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| x_return_status_text;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(l_routine || l_status_text ||' '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END INITIALIZE_CONSTANTS;


--4900095 service item lumpsum discount
--procedure to evaluate the quantity to prorate lumpsum
--to include the parent quantity

PROCEDURE Determine_svc_item_quantity IS
  i NUMBER;
  l_line_index NUMBER;
  l_lgrp_vol_attr VARCHAR2(240);
  --need to use index by varchar as the index used is list_line_id
  --which is a number and can go beyond the binary integer bounds
  TYPE num_indxbyvarchar_type IS TABLE OF NUMBER INDEX BY VARCHAR2(2000);
  l_lumpsum_qty num_indxbyvarchar_type;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Begin Determine_svc_item_quantity');
  END IF;
--bug 4900095 get service qty for lumpsum
  i:= QP_PREQ_GRP.G_service_line_ind_tbl.FIRST;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('loop index '||i);
  END IF;
  While i IS NOT NULL and QP_PREQ_GRP.G_service_line_ind_tbl(i) IS NOT NULL
  LOOP
    l_line_index := QP_PREQ_GRP.G_service_line_ind_tbl(i);
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('line_index of svc line: '||l_line_index);
    END IF;--l_debug

    for cl in
      (select line.line_index, ldet.line_detail_index,
              ldet.created_from_list_line_id, ldet.modifier_level_code,
              line.priced_quantity, line.parent_quantity, line.unit_price
           from qp_npreq_lines_tmp line, qp_npreq_ldets_tmp ldet
           where line.line_index = l_line_index
           and line.pricing_status_code in (G_STATUS_NEW, G_STATUS_UPDATED)
           and line.price_flag in (G_YES, G_PHASE)
           and line.line_type_code = G_LINE_LEVEL
           and ldet.line_index = line.line_index
           and ldet.pricing_status_code in
               (QP_PREQ_GRP.G_STATUS_NEW, G_STATUS_UNCHANGED)
           and ldet.applied_flag = G_YES
           and nvl(ldet.operand_calculation_code,
             QP_PREQ_GRP.G_LUMPSUM_DISCOUNT) = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT
           and ldet.created_from_list_line_type in
             ('DIS', 'SUR', 'PBH', 'FREIGHT_CHARGE')
           and ldet.modifier_level_code in
             (QP_PREQ_GRP.G_LINE_LEVEL, QP_PREQ_GRP.G_LINE_GROUP))
    loop
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('line_dtl_index of lumpsum adj '
          ||cl.line_detail_index||' list_line_id '||cl.created_from_list_line_id
          ||' modlevel '||cl.modifier_level_code||' parent_qty '
          ||cl.parent_quantity||' priced_qty '||cl.priced_quantity
          ||' unit_price '||cl.unit_price);
      END IF;--l_debug
        QP_PREQ_GRP.G_service_line_qty_tbl(cl.line_index) :=
                    cl.parent_quantity * cl.priced_quantity;
      IF l_debug = FND_API.G_TRUE THEN
        IF QP_PREQ_GRP.G_service_line_qty_tbl.exists(cl.line_index) THEN
          QP_PREQ_GRP.engine_debug('service_qty of lumpsum adj '
            ||QP_PREQ_GRP.G_service_line_qty_tbl(cl.line_index));
        END IF;--QP_PREQ_GRP.G_service_line_qty_tbl
      END IF;--l_debug

      --for linegroup modifiers, need to evaluate group lumpsum qty
      IF cl.modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP
      THEN
        IF l_lumpsum_qty.exists(cl.created_from_list_line_id) THEN
            QP_PREQ_GRP.G_Service_ldet_qty_tbl(cl.line_detail_index) :=
                  l_lumpsum_qty(cl.created_from_list_line_id);
        ELSE--new list_line_id
          BEGIN
            --determine the volume attribute on the linegrp modifier
            select attribute
            into l_lgrp_vol_attr
            from qp_npreq_line_attrs_tmp
            where line_detail_index = cl.line_detail_index
            and context = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('vol attr for linegrp modifier'
              ||l_lgrp_vol_attr);
            END IF;--l_debug
          EXCEPTION
          When OTHERS then
            l_lgrp_vol_attr := NULL;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('null vol attr for linegrp modifier');
            END IF;--l_debug
          END;
            --initialize lumpsum_qty for list_line_id
            l_lumpsum_qty(cl.created_from_list_line_id) := 0;
            --loop thru all the occurences of the linegrp modifier
            --to total the group quantity as volattrval * parent_qty
            --for svc lines and volattrval for non-svc lines
            --this lumpsum_qty will be used to prorate the lumpsum adj_amt
            for cl1 in (select line.line_index, lattr.value_from,
                             line.parent_quantity, ldet.line_detail_index
                from qp_npreq_ldets_tmp ldet,
                   qp_npreq_lines_tmp line,
                   qp_npreq_line_attrs_tmp lattr
                where ldet.created_from_list_line_id = cl.created_from_list_line_id
                and ldet.pricing_status_code = G_STATUS_NEW
                and ldet.applied_flag = G_YES
                and line.line_index = ldet.line_index
                and lattr.context = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT
                and lattr.attribute = l_lgrp_vol_attr
                and lattr.line_index = line.line_index
                and lattr.line_detail_index is null)
            loop
              IF QP_PREQ_GRP.G_service_line_ind_tbl.exists(cl1.line_index) THEN
              --this is a service line linegroup lumpsum
                l_lumpsum_qty(cl.created_from_list_line_id) :=
                    l_lumpsum_qty(cl.created_from_list_line_id) +
                    cl1.parent_quantity * cl1.value_from;
              ELSE
              --this is a non-service line linegroup lumpsum
                l_lumpsum_qty(cl.created_from_list_line_id) :=
                    l_lumpsum_qty(cl.created_from_list_line_id) +
                    cl1.value_from;
              END IF;--QP_PREQ_GRP.G_service_line_ind_tbl.exists

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('lumpsum dtls for this pass '
                ||'llid '||cl.created_from_list_line_id
                ||' line_index '||cl1.line_index
                ||' dtl_index '||cl1.line_detail_index
                ||' parent_qty '||cl1.parent_quantity
                ||' vol_attr '||cl1.value_from
                ||' qty running total '
                ||l_lumpsum_qty(cl.created_from_list_line_id));
              END IF;
            end loop; --cl1
            IF l_lgrp_vol_attr = G_LINE_AMT_ATTRIBUTE THEN
              G_Service_pbh_lg_amt_qty(cl.line_detail_index) :=
                     l_lumpsum_qty(cl.created_from_list_line_id)/cl.unit_price;
              QP_PREQ_GRP.G_Service_ldet_qty_tbl(cl.line_detail_index) :=
                     l_lumpsum_qty(cl.created_from_list_line_id);
            ELSE
              QP_PREQ_GRP.G_Service_ldet_qty_tbl(cl.line_detail_index) :=
                     l_lumpsum_qty(cl.created_from_list_line_id);
            END IF;
            IF l_debug = FND_API.G_TRUE THEN
              IF QP_PREQ_GRP.G_Service_ldet_qty_tbl.exists(cl.line_detail_index)
              THEN
                QP_PREQ_GRP.engine_debug('linegrp lumpsum qty for list_line_id '
                ||cl.created_from_list_line_id||' dtl_index '
                ||cl.line_detail_index||' qty '
                ||QP_PREQ_GRP.G_Service_ldet_qty_tbl(cl.line_detail_index));
              END IF;--QP_PREQ_GRP.G_Service_ldet_qty_tbl.exists
            END IF;
        END IF;--l_lumpsum_qty.exists
      END IF;--cl.modifier_level_code
    end loop;--cl
  --go to next line
  i := QP_PREQ_GRP.G_service_line_ind_tbl.next(i);
  END LOOP;--while

/*
  for cl3 in (select sum(line.parent_quantity) lumpsum_qty
              from qp_npreq_lines_tmp line
--qp_npreq_line_attrs_tmp ldetattr, qp_npreq_line_attrs_tmp lattr,
              where ldetattr.line_index = cl.line_index
              and line.priced_uom_code <> line.line_uom_code
              and ldetattr.context = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT
              and ldetattr.line_detail_index = cl.line_detail_index
              and lattr.line_index = cl.line_index
              and lattr.context = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT
              and lattr.attribute = ldetattr.attribute
              and exists (select 'Y'
                          from qp_npreq_ldets_tmp ldet
                          where ldet.created_from_list_line_id = cl.created_from_list_line_id
                          and ldet.modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP
                          and ldet.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW))
  loop
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('dtl_index '||cl.line_detail_index||' sum '||cl3.lumpsum_qty);
    END IF;
    QP_PREQ_GRP.G_Service_ldet_qty_tbl(cl.line_detail_index) := cl3.lumpsum_qty;
  end loop; --cl3
*/
EXCEPTION
When OTHERS Then
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('EXCEPTION Determine_svc_item_quantity');
  END IF;
  null;
END Determine_svc_item_quantity;

  PROCEDURE CALCULATE_BUCKET_PRICE(
                                   p_list_line_type_code IN QP_LIST_LINES.LIST_LINE_TYPE_CODE%TYPE
                                   , p_price IN NUMBER
                                   , p_priced_quantity NUMBER := 1
                                   , p_operand_calculation_code IN QP_LIST_LINES.ARITHMETIC_OPERATOR%TYPE
                                   , p_operand_value IN NUMBER
                                   , x_calc_adjustment OUT NOCOPY NUMBER
                                   , x_return_status OUT NOCOPY VARCHAR2 --DEFAULT FND_API.G_RET_STS_SUCCESS
                                   , x_return_status_text OUT NOCOPY VARCHAR2)
  IS

  l_routine VARCHAR2(50) := 'QP_PREQ_PUB.CALCULATE_BUCKET_PRICE';
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('begin calculate bucket price qty'
                               || p_priced_quantity ||' operator '|| p_operand_calculation_code);

    END IF;


    IF p_operand_calculation_code = G_PERCENT_DISCOUNT
      THEN
      --fix for bug 2245528
      --included abs function for -ve price to get right adj amt
      -- Bug#3002549 reverted the fix done for bug 2245528
      x_calc_adjustment := p_price * p_operand_value / 100;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('calculate % price ' || x_calc_adjustment);
      END IF;
    ELSIF p_operand_calculation_code = G_AMOUNT_DISCOUNT
      THEN
      x_calc_adjustment := p_operand_value;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('calculate amt price '|| x_calc_adjustment);
      END IF;
    ELSIF p_operand_calculation_code = G_NEWPRICE_DISCOUNT
      THEN
      --removed absolute value to account for negative newprice
      --bug 2065609
      x_calc_adjustment :=  - 1 * (p_price - (p_operand_value));
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('calculate newp price '|| x_calc_adjustment);
      END IF;
    ELSIF p_operand_calculation_code = G_LUMPSUM_DISCOUNT
      THEN
      --fix for bug 2394680 for zero list price qty can be 0
      --in case of line group lumpsum based on item amount
      -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM qty means infinity; this qty and zero qty yield no adj
      IF (p_priced_quantity = FND_API.G_NULL_NUM or p_priced_quantity = 0) THEN
        x_calc_adjustment := 0;
      ELSE
        x_calc_adjustment := p_operand_value / nvl(p_priced_quantity, 1);
      END IF;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('calculate lump price qty '
                                 || p_priced_quantity || x_calc_adjustment);
      END IF;
    ELSE NULL;
    END IF; --p_operand_calculation_code

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_RETURN_STATUS_TEXT := l_routine ||' SUCCESS';


    x_calc_adjustment := nvl(x_calc_adjustment, 0);


    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('end calculate bucket price: passed price '
                               || p_price ||' passed_operand '|| p_operand_value ||
                               ' calculated rounded adjustment  '|| x_calc_adjustment);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in calculating bucket price '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END CALCULATE_BUCKET_PRICE;


  PROCEDURE BACK_CALCULATE_PRICE(p_operand_calculation_code IN VARCHAR2
                                 , p_operand_value IN NUMBER
                                 , p_applied_flag IN VARCHAR2
                                 , p_amount_changed IN NUMBER
                                 , p_adjustment_amount IN NUMBER
                                 , p_priced_quantity IN NUMBER
                                 , p_list_price IN NUMBER
                                 , p_adjustment_type IN VARCHAR2
                                 , x_adjustment_amount OUT NOCOPY NUMBER
                                 , x_operand_value OUT NOCOPY NUMBER
                                 , x_process_code OUT NOCOPY BOOLEAN
                                 , x_return_status OUT NOCOPY VARCHAR2 --DEFAULT FND_API.G_RET_STS_SUCCESS
                                 , x_return_status_text OUT NOCOPY VARCHAR2) IS --DEFAULT FND_API.G_RET_STS_SUCCESS) IS

  l_routine VARCHAR2(50) := 'QP_PREQ_PUB.BACK_CALCULATE_PRICE';
  ZERO_LIST_PRICE EXCEPTION;

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('start back calculate adjustment:
                               adjustment type '|| p_adjustment_type ||
                               ' amount changed passed '|| p_amount_changed ||
                               ' price passed '|| p_list_price ||
                               ' adjustment_amount_passed '|| p_adjustment_amount ||
                               ' applied flag '|| p_applied_flag);



    END IF;
    --do not check for applied_flag, bcoz we are passing effective
    --amount_changed each time --for bug 2043442
    x_adjustment_amount := p_amount_changed;

    IF p_operand_calculation_code = G_PERCENT_DISCOUNT THEN
      IF p_list_price = 0 THEN
        RAISE ZERO_LIST_PRICE;
      END IF;
      x_operand_value := ABS(x_adjustment_amount * 100 / p_list_price);
    ELSIF p_operand_calculation_code = G_AMOUNT_DISCOUNT THEN
      x_operand_value := ABS(x_adjustment_amount);
    ELSIF p_operand_calculation_code = G_NEWPRICE_DISCOUNT THEN
      x_operand_value := p_list_price + nvl(x_adjustment_amount, 0);
    ELSIF p_operand_calculation_code = G_LUMPSUM_DISCOUNT THEN
      x_operand_value := ABS(x_adjustment_amount) * p_priced_quantity;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('adjustment amt calculated'
                               || x_adjustment_amount);

    END IF;
    IF p_adjustment_type = G_DISCOUNT AND (x_adjustment_amount <= 0
                                           OR p_operand_calculation_code = G_NEWPRICE_DISCOUNT) THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Manual Adjustment is Discount '|| p_adjustment_type);
      END IF;
      x_process_code := TRUE;
    ELSIF p_adjustment_type = G_SURCHARGE AND x_adjustment_amount >= 0 THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Manual Adjustment is Surcharge '|| p_adjustment_type);
      END IF;
      x_process_code := TRUE;
    ELSE
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Manual Adjustment is not DIS/SUR'|| p_adjustment_type);
      END IF;
      x_process_code := FALSE;
    END IF;



    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_RETURN_STATUS_TEXT := l_routine ||' SUCCESS';


    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('end back calculate adjustment:
                               adjustment amoutn calculated '|| x_adjustment_amount ||
                               ' operand calculated '|| x_operand_value);

    END IF;
  EXCEPTION
    WHEN ZERO_LIST_PRICE THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('exception back calculate adj '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '||'CANNOT OVERRIDE ZERO OR NULL LIST PRICE WITH % BASED ADJUSTMENT';
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('exception back calculate adj '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;

  END BACK_CALCULATE_PRICE;

  --this procedure is to calculate the unit_selling_price
  --operand and adjustment_amount in ordered_qty
  --the reason we do this is because when calling applications
  --do this, the rounding is lost
  --catchweight_qty is the quantity in catchweight pricing
  --where user orders 1 Chicken and 1 chicken = 10 lbs
  --the priced_qty is 10lbs and lineqty is 1 chicken
  --the price of the chicken and adjustments are calculated based
  --on priced_qty = 10 lbs
  --at the time of shipping the actual weight of chicken might be
  --12lbs, so they do not want to change the price at that point
  --but display the unit_price in catchweight_qty
  PROCEDURE GET_ORDERQTY_VALUES(p_ordered_qty IN NUMBER,
                                p_priced_qty IN NUMBER,
                                p_catchweight_qty IN NUMBER,
                                p_actual_order_qty IN NUMBER,
                                p_unit_price IN NUMBER DEFAULT NULL,
                                p_adjusted_unit_price IN NUMBER DEFAULT NULL,
                                p_line_unit_price IN NUMBER DEFAULT NULL,
                                p_operand IN NUMBER DEFAULT NULL,
                                p_adjustment_amt IN NUMBER DEFAULT NULL,
                                p_operand_calculation_code IN VARCHAR2 DEFAULT NULL,
                                p_input_type IN VARCHAR2,
                                x_ordqty_output1 OUT NOCOPY NUMBER,
                                x_ordqty_output2 OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS
  BEGIN
    --we need not treat null adj_unit_price or zero adj_unit_price
    --as adj_unit_price cannot be null and if it is zero, x_ordqty_selling_price
    --needs to be zero
    --we will default the null qty to 1 so that we can avoid divide_by_zero

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('BEGIN GET_ORDERQTY_VALUES: line_qty '
                               || p_ordered_qty ||' priced_qty '|| p_priced_qty ||' catchwtqty '
                               || p_catchweight_qty || 'actual order qty ' || p_actual_order_qty || ' unitprice '
                               || p_unit_price ||' sellingprice '
                               || p_adjusted_unit_price ||' lineunitprice '|| p_line_unit_price
                               ||' operand '|| p_operand ||' operator '|| p_operand_calculation_code
                               ||' adjamt '|| p_adjustment_amt ||' inputtype '|| p_input_type);
    END IF;

    --this procedure will be called for every adjustment
    --but we need calculate G_ORDQTY_SELLING_PRICE only once
    --for each order line
    IF p_input_type = 'SELLING_PRICE' THEN

      /* x_ordqty_output2 := ((p_adjusted_unit_price * p_priced_qty / p_ordered_qty) *
  (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty)); */

      IF (p_catchweight_qty IS NOT NULL) THEN
        --line_unit_price
        x_ordqty_output1 := (p_unit_price * (p_priced_qty / p_actual_order_qty) * (p_catchweight_qty / p_ordered_qty));
        --order_uom_selling_price
        x_ordqty_output2 := (p_adjusted_unit_price * (p_priced_qty / p_actual_order_qty) * (p_catchweight_qty / p_ordered_qty));
      ELSIF (p_actual_order_qty IS NOT NULL) THEN
        --line_unit_price
        x_ordqty_output1 := (p_unit_price * (p_priced_qty / p_actual_order_qty));
        --order_uom_selling_price
        x_ordqty_output2 := (p_adjusted_unit_price * (p_priced_qty / p_actual_order_qty));
      ELSE
        --line_unit_price
        --    x_ordqty_output1 := p_line_unit_price;
        --    x_ordqty_output1 := (p_unit_price * (p_priced_qty / p_ordered_qty));
        -- bug 3006661 for OC
        x_ordqty_output1 := (p_unit_price * (nvl(p_priced_qty, p_ordered_qty) / p_ordered_qty));
        --order_uom_selling_price
        --    x_ordqty_output2 := (p_adjusted_unit_price * (p_priced_qty/p_ordered_qty));
        -- bug 3006661 for OC
        x_ordqty_output2 := (p_adjusted_unit_price * (nvl(p_priced_qty, p_ordered_qty) / p_ordered_qty));
      END IF;

      /* IF p_catchweight_qty IS NOT NULL THEN
    x_ordqty_output1 := ((p_unit_price * p_priced_qty / p_ordered_qty) *
      (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty));
  ELSE
    x_ordqty_output1 := p_line_unit_price;
  END IF;--p_catchweight_qty */


    ELSE --input_type is OPERAND
      IF p_operand_calculation_code IN (G_PERCENT_DISCOUNT, G_LUMPSUM_DISCOUNT) THEN
        --x_ordqty_operand same as operand for % and LUMPSUM based modifiers
        x_ordqty_output1 := p_operand;
      ELSE
        -- Ravi
        /*x_ordqty_output1 := ((p_unit_price * p_priced_qty / p_ordered_qty) *
      (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty));*/
        /* x_ordqty_output1 := ((p_operand * p_priced_qty / p_ordered_qty) *
      (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty)); */

        IF (p_catchweight_qty IS NOT NULL) THEN
          x_ordqty_output1 := (p_operand * (p_priced_qty / p_actual_order_qty) * (p_catchweight_qty / p_ordered_qty));
        ELSIF (p_actual_order_qty IS NOT NULL) THEN
          x_ordqty_output1 := (p_operand * (p_priced_qty / p_actual_order_qty));
        ELSE
          -- x_ordqty_output1 := (p_operand * (p_priced_qty/p_ordered_qty));
          -- bug 3006661 for OC
          x_ordqty_output1 := (p_operand * (nvl(p_priced_qty, p_ordered_qty) / p_ordered_qty));
        END IF;

      END IF; --p_operand_calculation_code

      -- Ravi
      /*x_ordqty_output2 := ((p_unit_price * p_priced_qty / p_ordered_qty) *
    (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty));*/
      /* x_ordqty_output2 := ((p_adjustment_amt * p_priced_qty / p_ordered_qty) *
    (nvl(p_catchweight_qty, p_ordered_qty) / p_ordered_qty)); */

      IF (p_catchweight_qty IS NOT NULL) THEN
        x_ordqty_output2 := (p_adjustment_amt * (p_priced_qty / p_actual_order_qty) * (p_catchweight_qty / p_ordered_qty));
      ELSIF (p_actual_order_qty IS NOT NULL) THEN
        x_ordqty_output2 := (p_adjustment_amt * (p_priced_qty / p_actual_order_qty));
      ELSE
        -- x_ordqty_output2 := (p_adjustment_amt * (p_priced_qty/p_ordered_qty));
        -- bug 3006661 for OC
        x_ordqty_output2 := (p_adjustment_amt * (nvl(p_priced_qty, p_ordered_qty) / p_ordered_qty));
      END IF;

    END IF; --p_input_type

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Output GET_ORDERQTY_VALUES '||'output1 '
                               || x_ordqty_output1 ||' output2 '|| x_ordqty_output2);
    END IF; --l_debug

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in GET_ORDERQTY_VALUES '|| SQLERRM);
      END IF; --l_debug
      x_ordqty_output1 := 0;
      x_ordqty_output2 := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END GET_ORDERQTY_VALUES;

  --This procedure is to update the order_qty_adj_amt and order_qty_operand
  --on manual adjustments which do not go through calculation cursor
  --as they are not applied
  --fix for bug 2816262 where order_qty_operand is not populated for
  --manual adjustments are they do not go thru calculation
  PROCEDURE Update_Adj_orderqty_cols(x_return_status OUT NOCOPY VARCHAR2,
                                     x_return_status_text OUT NOCOPY VARCHAR2) IS
  --[julin/pbperf] tuned to use QP_PREQ_LDETS_TMP_N2
  CURSOR l_update_adj_cur IS
    SELECT /*+ ORDERED index(ldet QP_PREQ_LDETS_TMP_N2) */ ldet.line_detail_index,
           ldet.operand_value,
           ldet.operand_calculation_code,
           ldet.modifier_level_code,
           nvl(ldet.line_quantity, line.priced_quantity) priced_qty,
           line.actual_order_quantity actual_order_qty,
           line.catchweight_qty,
           line.line_quantity ordered_qty
    --       line.unit_price,
    --       line.adjusted_unit_price
    FROM qp_npreq_ldets_tmp ldet,
         qp_npreq_lines_tmp line
    WHERE ldet.pricing_phase_id > 1
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.automatic_flag = G_NO
    AND nvl(ldet.applied_flag, G_NO) = G_NO
    AND nvl(ldet.updated_flag, G_NO) = G_NO
    AND line.line_index = ldet.line_index;

  l_ordqty_line_dtl_index QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_operand QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_operator QP_PREQ_GRP.VARCHAR_TYPE;
  l_ordqty_mod_lvl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ordqty_priced_qty QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_actual_order_qty QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_catchweight_qty QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_ordered_qty QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_ord_qty_operand QP_PREQ_GRP.NUMBER_TYPE;

  l_dummy NUMBER;
  BEGIN
    --initialise
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Begin Update_Adj_orderqty_cols');
    END IF; --l_debug

    OPEN l_update_adj_cur;
    l_ordqty_line_dtl_index.DELETE;
    l_ordqty_operand.DELETE;
    l_ordqty_operator.DELETE;
    l_ordqty_mod_lvl.DELETE;
    l_ordqty_priced_qty.DELETE;
    l_ordqty_actual_order_qty.DELETE;
    l_ordqty_catchweight_qty.DELETE;
    l_ordqty_ordered_qty.DELETE;
    l_ordqty_ord_qty_operand.DELETE;
    FETCH l_update_adj_cur BULK COLLECT INTO
    l_ordqty_line_dtl_index,
    l_ordqty_operand,
    l_ordqty_operator,
    l_ordqty_mod_lvl,
    l_ordqty_priced_qty,
    l_ordqty_actual_order_qty,
    l_ordqty_catchweight_qty,
    l_ordqty_ordered_qty;
    CLOSE l_update_adj_cur;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('After cur Update_Adj_orderqty_cols');
    END IF; --l_debug

    IF l_ordqty_line_dtl_index.COUNT > 0 THEN
      FOR i IN l_ordqty_line_dtl_index.FIRST..l_ordqty_line_dtl_index.LAST
        LOOP
        IF (l_ordqty_ordered_qty(i) <> 0 OR l_ordqty_mod_lvl(i) = G_ORDER_LEVEL) THEN
          IF (l_debug = FND_API.G_TRUE) THEN
            QP_PREQ_GRP.engine_debug('Before GET_ORDERQTY_VALUES #5');
          END IF;

          GET_ORDERQTY_VALUES(p_ordered_qty => l_ordqty_ordered_qty(i),
                              p_priced_qty => l_ordqty_priced_qty(i),
                              p_catchweight_qty => l_ordqty_catchweight_qty(i),
                              p_actual_order_qty => l_ordqty_actual_order_qty(i),
                              p_operand => l_ordqty_operand(i),
                              p_adjustment_amt => 0,  --we do not need this
                              --    p_unit_price => l_adj_tbl(j).unit_price,
                              --    p_adjusted_unit_price => l_sub_total_price,
                              p_operand_calculation_code => l_ordqty_operator(i),
                              p_input_type => 'OPERAND',
                              x_ordqty_output1 => l_ordqty_ord_qty_operand(i),
                              x_ordqty_output2 => l_dummy,
                              x_return_status => x_return_status,
                              x_return_status_text => x_return_status_text);
        ELSE --l_ordqty_ordered_qty
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Ordered Qty #5: '|| l_ordqty_ordered_qty(i));
            QP_PREQ_GRP.engine_debug('OPERAND Ordered Qty=0 or modlvlcode <> ORDER');
          END IF; --l_debug
          l_ordqty_ord_qty_operand(i) := 0;
        END IF; --l_ordqty_ordered_qty
      END LOOP; --i
    END IF; --l_ordqty_line_dtl_index

    IF l_ordqty_line_dtl_index.COUNT > 0 THEN
      IF l_debug = FND_API.G_TRUE THEN
        FOR j IN l_ordqty_line_dtl_index.FIRST..l_ordqty_line_dtl_index.LAST
          LOOP
          QP_PREQ_GRP.engine_debug('Ordqty update line_dtl_index '
                                   || l_ordqty_line_dtl_index(j) ||' ordqty_operand '
                                   || l_ordqty_ord_qty_operand(j));
        END LOOP; --j
      END IF; --l_debug

      FORALL i IN l_ordqty_line_dtl_index.FIRST..l_ordqty_line_dtl_index.LAST
      UPDATE qp_npreq_ldets_tmp SET order_qty_operand = l_ordqty_ord_qty_operand(i)
      WHERE line_detail_index = l_ordqty_line_dtl_index(i);
    END IF; --l_ordqty_line_dtl_index.COUNT

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('End Update_Adj_orderqty_cols');
    END IF; --l_debug

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in Update_Adj_orderqty_cols '|| SQLERRM);
      END IF; --l_debug
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in Update_Adj_orderqty_cols '|| SQLERRM;
  END Update_Adj_orderqty_cols;

  --For bug 2447181 for changed lines functionality
  --to indicate to the calling application to make a subsequent pricing
  --call with calculate_only and to pass all lines when they are calling
  --with changed lines in case there are new/changed order level modifiers
  --this will be indicated in processed_flag = 'C' in qp_npreq_lines_tmp
  --on the summary linE
  PROCEDURE CHECK_ORDER_LINE_CHANGES(p_request_type_code IN VARCHAR2,
                                     p_full_pricing_call IN VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_return_status_text OUT NOCOPY VARCHAR2) IS

  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.CHECK_ORDER_LINE_CHANGES';

  l_exist_changed_order_adj VARCHAR2(1) := G_NO;
  l_header_id NUMBER;
  l_ldet_sum_operand NUMBER := 0;
  l_adj_sum_operand NUMBER := 0;
  BEGIN

    --initialise
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    l_header_id := NULL;
    l_exist_changed_order_adj := G_NO;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Check_order_lines_change: chk_cust '
                               || G_CHECK_CUST_VIEW_FLAG ||' full_pricing_call '|| p_full_pricing_call);

    END IF;
    --do this only if caller has passed changed lines
    --IF p_request_type_code = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
      AND p_full_pricing_call = G_NO
      THEN
      --this is for OM/OC direct insert performance code path
      --there cannot be manual adjustments on the order header

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('starting order line check ');
      END IF;
      BEGIN
        SELECT line_id INTO l_header_id
        FROM qp_npreq_lines_tmp
        WHERE line_type_code = G_ORDER_LEVEL
        AND pricing_status_code IN (G_STATUS_UPDATED,
                                    G_STATUS_UNCHANGED, G_STATUS_GSA_VIOLATION);
      EXCEPTION
        WHEN OTHERS THEN
          l_header_id := NULL;
      END;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('checking header id '|| l_header_id);

      END IF;
      IF l_header_id IS NOT NULL THEN
        BEGIN
          SELECT G_YES INTO l_exist_changed_order_adj
          FROM qp_npreq_ldets_tmp ldet
          WHERE ldet.process_code IN (G_STATUS_UPDATED, G_STATUS_NEW)
          AND ldet.pricing_status_code = G_STATUS_NEW
          AND ldet.modifier_level_code = G_ORDER_LEVEL
          AND ldet.applied_flag = G_YES;
        EXCEPTION
          WHEN OTHERS THEN
            l_exist_changed_order_adj := G_NO;
        END;
      ELSE --l_header_id
        l_exist_changed_order_adj := G_NO;
      END IF; --l_header_id

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('there are header adj changes '
                                 || l_exist_changed_order_adj);

      END IF;
      --do this only if the header does not have error status
      --and there are new or updated summary level automatic adjustments
      --	IF l_header_id is not null
      IF l_exist_changed_order_adj = G_YES
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('checking header adj operand changes');
        END IF;
        BEGIN
          SELECT SUM(operand_value) INTO l_ldet_sum_operand
          FROM qp_npreq_ldets_tmp ldet
          WHERE ldet.modifier_level_code = G_ORDER_LEVEL
          AND ldet.pricing_status_code = G_STATUS_NEW
          AND ldet.automatic_flag = G_YES
          AND applied_flag = G_YES;
        EXCEPTION
          WHEN OTHERS THEN
            l_ldet_sum_operand := 0;
        END;

        l_adj_sum_operand :=
        QP_CLEANUP_ADJUSTMENTS_PVT.get_sum_operand(l_header_id);

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('ldet header adj sum operand '
                                   || l_ldet_sum_operand);
          QP_PREQ_GRP.engine_debug('oe_price_adj header adj sum operand '
                                   || l_adj_sum_operand);
        END IF;
        --only if there is a change in the operand from previous
        --call, we need to recalculate
        --it is OK to sumup operand as order level adj is % based
        --so find out the sum from prev call and current call
        IF l_ldet_sum_operand <> l_adj_sum_operand
          THEN
          --order level modifiers are mostly % based
          -- so if the total % of order level modifiers do not match
          --then caller needs to recalculate
          UPDATE qp_npreq_lines_tmp SET
                  processed_flag = G_CALCULATE_ONLY
                  WHERE line_type_code = G_ORDER_LEVEL;
        END IF;
      END IF; --l_exist_changed_order_adj
      --ELSIF p_request_type_code <> 'ONT'
      --bug 3085453 handle pricing availability UI
      -- they pass reqtype ONT and insert adj into ldets
    ELSIF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES
      AND p_full_pricing_call = G_NO THEN
      --this is for non-OM calling applications
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('starting order line check ');
      END IF;
      --check if there is a summary line passed and it has no errors
      BEGIN
        SELECT line_id INTO l_header_id
        FROM qp_npreq_lines_tmp
        WHERE line_type_code = G_ORDER_LEVEL
        AND pricing_status_code IN (G_STATUS_UPDATED,
                                    G_STATUS_UNCHANGED, G_STATUS_GSA_VIOLATION);
      EXCEPTION
        WHEN OTHERS THEN
          l_header_id := NULL;
      END;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('checking header id '|| l_header_id);
      END IF;
      --if there is a summary line, make sure there are applied adj against it
      IF l_header_id IS NOT NULL THEN
        BEGIN
          SELECT G_YES INTO l_exist_changed_order_adj
          FROM qp_npreq_ldets_tmp ldet
          WHERE ldet.pricing_status_code = G_STATUS_NEW
          AND ldet.modifier_level_code = G_ORDER_LEVEL
          AND ldet.applied_flag = G_YES;
        EXCEPTION
          WHEN OTHERS THEN
            l_exist_changed_order_adj := G_NO;
        END;
      ELSE --l_header_id
        l_exist_changed_order_adj := G_NO;
      END IF; --l_header_id

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('there are header adj changes '
                                 || l_exist_changed_order_adj);
      END IF;
      --do this only if the header does not have error status
      --and there are new or updated summary level automatic adjustments
      --	IF l_header_id is not null
      IF l_exist_changed_order_adj = G_YES
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('checking header adj operand changes');
        END IF;
        BEGIN
          SELECT SUM(operand_value) INTO l_ldet_sum_operand
          FROM qp_npreq_ldets_tmp ldet
          WHERE ldet.modifier_level_code = G_ORDER_LEVEL
          AND ldet.pricing_status_code = G_STATUS_NEW
          AND ldet.automatic_flag = G_YES
          AND applied_flag = G_YES;
        EXCEPTION
          WHEN OTHERS THEN
            l_ldet_sum_operand := 0;
        END;

        BEGIN
          SELECT SUM(operand_value) INTO l_adj_sum_operand
          FROM qp_npreq_ldets_tmp ldet
          WHERE ldet.modifier_level_code = G_ORDER_LEVEL
          AND ldet.pricing_status_code = G_STATUS_UNCHANGED
          AND ldet.automatic_flag = G_YES
          AND applied_flag = G_YES;
        EXCEPTION
          WHEN OTHERS THEN
            l_adj_sum_operand := 0;
        END;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('ldet header adj sum operand '
                                   || l_ldet_sum_operand);
          QP_PREQ_GRP.engine_debug('oe_price_adj header adj sum operand '
                                   || l_adj_sum_operand);
        END IF; --l_debug
        --only if there is a change in the operand from previous
        --call, we need to recalculate
        --it is OK to sumup operand as order level adj is % based
        --so find out the sum from prev call and current call
        IF l_ldet_sum_operand <> l_adj_sum_operand
          THEN
          --order level modifiers are mostly % based
          -- so if the total % of order level modifiers do not match
          --then caller needs to recalculate
          UPDATE qp_npreq_lines_tmp SET
                  processed_flag = G_CALCULATE_ONLY
                  WHERE line_type_code = G_ORDER_LEVEL;
        END IF; --l_ldet_sum_operand
      END IF; --l_exist_changed_order_adj
    ELSE
      --the p_full_pricing_call is 'Y'
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('no change header adj');
      END IF;
    END IF; --p_request_type_code
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG(x_return_status_text);
      END IF;
  END CHECK_ORDER_LINE_CHANGES;

  /*
     --Preinsert Logic for OM call
     --to fetch out-of-phases modifiers and in-phase PRG modifiers
     --to fetch rltd information
*/
  PROCEDURE INT_TABLES_PREINSERT(p_calculate_flag IN VARCHAR2,
                                 p_event_code IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_status_text OUT NOCOPY VARCHAR2) IS
  CURSOR l_ldets_cur IS
    SELECT /*+ ORDERED USE_NL(adj qplh) */
              adj.price_adjustment_id line_detail_index
            , adj.list_line_type_code line_detail_type_code
            , adj.price_break_type_code
            , NULL list_price
            , line.line_index
            , adj.list_header_id created_from_list_header_id
            , adj.list_line_id created_from_list_line_id
            , adj.list_line_type_code created_from_list_line_type
            , '' created_from_list_type_code
            , NULL CREATED_FROM_SQL
            , adj.pricing_group_sequence
            , adj.pricing_phase_id
            , adj.arithmetic_operator operand_calculation_code
            , nvl(adj.operand_per_pqty, adj.operand) operand_value
            , NULL SUBSTITUTION_TYPE_CODE
            , NULL SUBSTITUTION_VALUE_FROM
            , NULL SUBSTITUTION_VALUE_TO
            , NULL ASK_FOR_FLAG
            , NULL PRICE_FORMULA_ID
            , 'N' pricing_status_code
            , ' ' pricing_status_text
            , NULL PRODUCT_PRECEDENCE
            , NULL INCOMPATABILITY_GRP_CODE
            , NULL PROCESSED_FLAG
            , adj.applied_flag
            , adj.automatic_flag
            , adj.update_allowed override_flag
            , NULL PRIMARY_UOM_FLAG
            , NULL PRINT_ON_INVOICE_FLAG
            , adj.modifier_level_code
            , adj.BENEFIT_QTY
            , adj.BENEFIT_UOM_CODE
            , adj.LIST_LINE_NO
            , adj.accrual_flag
            , adj.ACCRUAL_CONVERSION_RATE
            , NULL ESTIM_ACCRUAL_RATE
            , NULL RECURRING_FLAG
            , NULL SELECTED_VOLUME_ATTR
            , line.rounding_factor
            , NULL HEADER_LIMIT_EXISTS
            , NULL LINE_LIMIT_EXISTS
            , adj.charge_type_code
            , adj.charge_subtype_code
            , NULL CURRENCY_DETAIL_ID
            , NULL CURRENCY_HEADER_ID
            , NULL SELLING_ROUNDING_FACTOR
            , NULL ORDER_CURRENCY
            , NULL PRICING_EFFECTIVE_DATE
            , NULL BASE_CURRENCY_CODE
            --, line.line_quantity
            , adj.range_break_quantity line_quantity
            , nvl(adj.updated_flag, QP_PREQ_PUB.G_NO) updated_flag
            , NULL calculation_code
            , adj.CHANGE_REASON_CODE
            , adj.CHANGE_REASON_TEXT
            , adj.PRICE_ADJUSTMENT_ID
            , NULL ACCUM_CONTEXT
            , NULL ACCUM_ATTRIBUTE
            , NULL ACCUM_FLAG
            , NULL BREAK_UOM_CODE
            , NULL BREAK_UOM_CONTEXT
            , NULL BREAK_UOM_ATTRIBUTE
            , NULL PROCESS_CODE -- 3215497
    FROM qp_int_lines line, oe_price_adjustments adj,
            qp_list_headers_b qplh
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
            AND line.process_status IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW' || QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'OLD' || QP_PREQ_PUB.G_STATUS_UNCHANGED)
            AND adj.line_id = line.line_id
            AND line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                                             , QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                             , QP_PREQ_PUB.G_STATUS_UNCHANGED)
            AND (line.price_flag IN (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                 OR nvl(line.processed_code, '0') = QP_PREQ_PUB.G_BY_ENGINE)
            AND line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
            AND (adj.updated_flag = QP_PREQ_PUB.G_YES
                 OR line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                 OR (p_event_code IS NULL AND adj.updated_flag IS NULL)
                 OR (adj.list_line_type_code = 'PRG'
                     AND  adj.pricing_phase_id IN (SELECT ph.pricing_phase_id
                                                   FROM qp_event_phases ev, qp_pricing_phases ph
                                                   WHERE ph.pricing_phase_id = ev.pricing_phase_id
                                                   AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                                                         AND ph.freight_exists = QP_PREQ_PUB.G_YES)
                                                        OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                                                   AND instr(p_event_code, ev.pricing_event_code || ',') > 0
                                                   --and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_YES
                                                   --or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                                                   AND (line.price_flag = QP_PREQ_PUB.G_YES
                                                        OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                                                            AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = QP_PREQ_PUB.G_YES))))
                 OR adj.pricing_phase_id NOT IN (SELECT ph.pricing_phase_id
                                                 FROM qp_event_phases ev, qp_pricing_phases ph
                                                 WHERE ph.pricing_phase_id = ev.pricing_phase_id
                                                 AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                                                       AND ph.freight_exists = QP_PREQ_PUB.G_YES)
                                                      OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                                                 AND instr(p_event_code, ev.pricing_event_code || ',') > 0
                                                 --and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index,line.price_flag) = QP_PREQ_PUB.G_YES
                                                 --or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                                                 AND (line.price_flag = QP_PREQ_PUB.G_YES
                                                      OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                                                          AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) =
                                                          QP_PREQ_PUB.G_YES))))
            AND adj.modifier_level_code IN (QP_PREQ_PUB.G_LINE_LEVEL, QP_PREQ_PUB.G_LINE_GROUP)
          AND qplh.list_header_id = adj.list_header_id
          AND qplh.list_type_code NOT IN (QP_PREQ_PUB.G_PRICE_LIST_HEADER,
                                          QP_PREQ_PUB.G_AGR_LIST_HEADER)
          --commented out because we want to fetch PBH childs and PRG freeline adjs
          --and not exists (select 'x'
          --                from  oe_price_adj_assocs a
          --                where a.RLTD_PRICE_ADJ_ID = adj.price_adjustment_id)
    UNION ALL
    SELECT /*+ ORDERED USE_NL(adj qplh) */
              adj.price_adjustment_id line_detail_index
            , adj.list_line_type_code line_detail_type_code
            , adj.price_break_type_code
            , NULL list_price
            , line.line_index
            , adj.list_header_id created_from_list_header_id
            , adj.list_line_id created_from_list_line_id
            , adj.list_line_type_code created_from_list_line_type
            , '' created_from_list_type_code
            , NULL CREATED_FROM_SQL
            , adj.pricing_group_sequence
            , adj.pricing_phase_id
            , adj.arithmetic_operator operand_calculation_code
            , nvl(adj.operand_per_pqty, adj.operand) operand_value
            , NULL SUBSTITUTION_TYPE_CODE
            , NULL SUBSTITUTION_VALUE_FROM
            , NULL SUBSTITUTION_VALUE_TO
            , NULL ASK_FOR_FLAG
            , NULL PRICE_FORMULA_ID
            , 'N' pricing_status_code
            , ' ' pricing_status_text
            , NULL PRODUCT_PRECEDENCE
            , NULL INCOMPATABILITY_GRP_CODE
            , NULL PROCESSED_FLAG
            , adj.applied_flag
            , adj.automatic_flag
            , adj.update_allowed override_flag
            , NULL PRIMARY_UOM_FLAG
            , NULL PRINT_ON_INVOICE_FLAG
            , adj.modifier_level_code
            , adj.BENEFIT_QTY
            , adj.BENEFIT_UOM_CODE
            , adj.LIST_LINE_NO
            , adj.accrual_flag
            , adj.ACCRUAL_CONVERSION_RATE
            , NULL ESTIM_ACCRUAL_RATE
            , NULL RECURRING_FLAG
            , NULL SELECTED_VOLUME_ATTR
            , line.rounding_factor
            , NULL HEADER_LIMIT_EXISTS
            , NULL LINE_LIMIT_EXISTS
            , adj.charge_type_code
            , adj.charge_subtype_code
            , NULL CURRENCY_DETAIL_ID
            , NULL CURRENCY_HEADER_ID
            , NULL SELLING_ROUNDING_FACTOR
            , NULL ORDER_CURRENCY
            , NULL PRICING_EFFECTIVE_DATE
            , NULL BASE_CURRENCY_CODE
            --, line.line_quantity
            , adj.range_break_quantity line_quantity
            , nvl(adj.updated_flag, QP_PREQ_PUB.G_NO) updated_flag
            , NULL calculation_code
            , adj.CHANGE_REASON_CODE
            , adj.CHANGE_REASON_TEXT
            , adj.PRICE_ADJUSTMENT_ID
            , NULL ACCUM_CONTEXT
            , NULL ACCUM_ATTRIBUTE
            , NULL ACCUM_FLAG
            , NULL BREAK_UOM_CODE
            , NULL BREAK_UOM_CONTEXT
            , NULL BREAK_UOM_ATTRIBUTE
            , NULL PROCESS_CODE -- 3215497
    FROM qp_int_lines line, oe_price_adjustments adj,
            qp_list_headers_b qplh
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
            AND line.process_status IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW' || QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'OLD' || QP_PREQ_PUB.G_STATUS_UNCHANGED)
            AND adj.header_id = line.line_id
            AND line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                                             , QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                             , QP_PREQ_PUB.G_STATUS_UNCHANGED)
            AND line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
            AND (line.price_flag IN (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                 OR nvl(line.processed_code, '0') = QP_PREQ_PUB.G_BY_ENGINE)
            AND (adj.updated_flag = QP_PREQ_PUB.G_YES
                 OR line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                 OR (p_event_code IS NULL AND adj.updated_flag IS NULL)
                 OR adj.pricing_phase_id NOT IN
                 (SELECT ph.pricing_phase_id
                  FROM qp_event_phases ev, qp_pricing_phases ph
                  WHERE ph.pricing_phase_id = ev.pricing_phase_id
                  AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                        AND ph.freight_exists = QP_PREQ_PUB.G_YES)
                       OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                  AND instr(p_event_code, ev.pricing_event_code || ',') > 0
                  --and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_YES
                  --or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                  AND (line.price_flag = QP_PREQ_PUB.G_YES
                       OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                           AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = QP_PREQ_PUB.G_YES))))
            AND adj.modifier_level_code = QP_PREQ_PUB.G_ORDER_LEVEL
            AND adj.line_id IS NULL
            AND qplh.list_header_id = adj.list_header_id
            AND qplh.list_type_code NOT IN (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER);

  CURSOR l_rltd_lines_cur(pbh_exist_flag VARCHAR2, prg_exist_flag VARCHAR2) IS
    SELECT /*+ index(ass OE_PRICE_ADJ_ASSOCS_N1)*/ --[julin/4865213] changed from N3 to N1
     line.line_index             line_index,
     ass.price_adjustment_id     line_detail_index,
     QP_PREQ_PUB.G_PBH_LINE      relationship_type_code,
     line.line_index             related_line_index,
     ass.rltd_price_adj_id       related_line_detail_index,
     adj_pbh.list_line_id        list_line_id,
     adj.list_line_id            related_list_line_id,
     'INSERTED FOR CALCULATION'  pricing_status_text
    FROM qp_int_lines line
            , oe_price_adjustments adj_pbh
            , oe_price_adj_assocs ass
            , oe_price_adjustments adj
            , qp_pricing_attributes attr
    WHERE pbh_exist_flag = 'Y'
    AND QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
    AND line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
    AND line.price_flag IN (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
    AND line.line_id = adj_pbh.line_id
    AND adj_pbh.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
    AND (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR adj_pbh.updated_flag = QP_PREQ_PUB.G_YES
         OR p_event_code = ',' --we pad comma when it is null
         OR adj_pbh.pricing_phase_id NOT IN
         (SELECT ph.pricing_phase_id
          FROM qp_event_phases evt, qp_pricing_phases ph
          WHERE ph.pricing_phase_id = evt.pricing_phase_id
          --introduced for freight_rating functionality to return only modifiers in
          --phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
          AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                AND ph.freight_exists = QP_PREQ_PUB.G_YES)
               OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
          AND instr(p_event_code, evt.pricing_event_code || ',') > 0
          --and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_YES
          AND (line.price_flag = QP_PREQ_PUB.G_YES
               --or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.line_detail_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
               OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                   AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) =
                   QP_PREQ_PUB.G_YES))))
    AND adj_pbh.price_adjustment_id = ass.price_adjustment_id
    AND ass.rltd_price_adj_id = adj.price_adjustment_id
    AND attr.list_line_id = adj.list_line_id
    AND attr.pricing_attribute_context = QP_PREQ_PUB.G_PRIC_VOLUME_CONTEXT
UNION ALL
SELECT /*+ ordered index(ass OE_PRICE_ADJ_ASSOCS_N1)*/ --[julin/4865213] changed from N3 to N1, ordered
         line.line_index             line_index,
         adj_prg.price_adjustment_id line_detail_index,
         QP_PREQ_PUB.G_GENERATED_LINE      relationship_type_code,
         getline.line_index related_line_index,
         ass.rltd_price_adj_id related_line_detail_index,
         adj_prg.list_line_id list_line_id,
         adj.list_line_id related_list_line_id,
         'INSERTED FOR CALCULATION'  pricing_status_text
        FROM qp_int_lines line
                , oe_price_adjustments adj_prg
                , oe_price_adj_assocs ass
                , oe_price_adjustments adj
                , qp_int_lines getline
        WHERE prg_exist_flag = 'Y'
        AND QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        AND line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
        --and line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
        AND line.price_flag = G_YES
        AND line.line_id = adj_prg.line_id
        AND adj_prg.list_line_type_code = G_PROMO_GOODS_DISCOUNT
        AND adj_prg.pricing_phase_id  IN
                (SELECT ph.pricing_phase_id
                 FROM qp_event_phases evt, qp_pricing_phases ph
                 WHERE ph.pricing_phase_id = evt.pricing_phase_id
                 AND instr(p_event_code, evt.pricing_event_code || ',') > 0
                 AND (line.price_flag = QP_PREQ_PUB.G_YES
                      OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                          AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = QP_PREQ_PUB.G_YES)))
        AND ass.price_adjustment_id = adj_prg.price_adjustment_id
        AND ass.rltd_price_adj_id = adj.price_adjustment_id
        AND adj.list_line_type_code = 'DIS'
        AND adj.line_id IS NOT NULL
        AND getline.line_id = adj.line_id;
  --and getline.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE);

  CURSOR l_pbh_adj_exists_cur IS
    SELECT /*+ index(adj OE_PRICE_ADJUSTMENTS_N2) */ 'Y'
    FROM
            qp_int_lines line,
            oe_price_adjustments adj
    WHERE adj.line_id = line.line_id
    AND line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
    AND adj.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
    AND (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR adj.updated_flag = QP_PREQ_PUB.G_YES
         OR p_event_code = ',' -- we pad ',' when it is null
         OR adj.pricing_phase_id NOT IN
         (SELECT ph.pricing_phase_id
          FROM qp_event_phases evt, qp_pricing_phases ph
          WHERE ph.pricing_phase_id = evt.pricing_phase_id
          --introduced for freight_rating functionality to return only modifiers in
          --phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
          AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                AND ph.freight_exists = QP_PREQ_PUB.G_YES)
               OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
          AND instr(p_event_code, evt.pricing_event_code || ',') > 0
          AND (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index), line.price_flag) = QP_PREQ_PUB.G_YES
               OR (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index), line.price_flag) = QP_PREQ_PUB.G_PHASE
                   AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) =
                   QP_PREQ_PUB.G_YES))))
    UNION
    SELECT /*+ index(adj OE_PRICE_ADJUSTMENTS_N1) */ 'Y'
    FROM
            qp_int_lines line,
            oe_price_adjustments adj
    WHERE adj.header_id = line.line_id
    AND line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
    AND adj.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
    AND (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
         OR p_event_code = ',' -- we pad ',' when it is null
         OR adj.pricing_phase_id NOT IN
         (SELECT ph.pricing_phase_id
          FROM qp_event_phases evt, qp_pricing_phases ph
          WHERE ph.pricing_phase_id = evt.pricing_phase_id
          --introduced for freight_rating functionality to return only modifiers in
          --phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
          AND ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                AND ph.freight_exists = QP_PREQ_PUB.G_YES)
               OR (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
          AND instr(p_event_code, evt.pricing_event_code || ',') > 0
          AND (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index), line.price_flag) = QP_PREQ_PUB.G_YES
               OR (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index), line.price_flag) = QP_PREQ_PUB.G_PHASE
                   AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) =
                   QP_PREQ_PUB.G_YES))));


  CURSOR l_prg_adj_exists_cur IS
    SELECT /*+ index(adj OE_PRICE_ADJUSTMENTS_N2) */ 'Y'
    FROM qp_int_lines line,
         oe_price_adjustments adj
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        AND adj.line_id = line.line_id
        AND line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
        AND adj.list_line_type_code = 'PRG'
        AND adj.pricing_phase_id IN
                    (SELECT ph.pricing_phase_id
                     FROM qp_event_phases evt, qp_pricing_phases ph
                     WHERE ph.pricing_phase_id = evt.pricing_phase_id
                     AND instr(p_event_code, evt.pricing_event_code || ',') > 0
                     AND (line.price_flag = QP_PREQ_PUB.G_YES
                          OR (line.price_flag = QP_PREQ_PUB.G_PHASE
                              AND nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = QP_PREQ_PUB.G_YES)));

  CURSOR l_getline_dis_cur IS
    SELECT /*+ ORDERED USE_NL(adj qplh) */
              adj.price_adjustment_id line_detail_index
            , adj.list_line_type_code line_detail_type_code
            , adj.price_break_type_code
            , NULL list_price
            , getline.line_index
            , adj.list_header_id created_from_list_header_id
            , adj.list_line_id created_from_list_line_id
            , adj.list_line_type_code created_from_list_line_type
            , '' created_from_list_type_code
            , NULL CREATED_FROM_SQL
            , adj.pricing_group_sequence
            , adj.pricing_phase_id
            , adj.arithmetic_operator operand_calculation_code
            , nvl(adj.operand_per_pqty, adj.operand) operand_value
            , NULL SUBSTITUTION_TYPE_CODE
            , NULL SUBSTITUTION_VALUE_FROM
            , NULL SUBSTITUTION_VALUE_TO
            , NULL ASK_FOR_FLAG
            , NULL PRICE_FORMULA_ID
            , 'N' pricing_status_code
            , ' ' pricing_status_text
            , NULL PRODUCT_PRECEDENCE
            , NULL INCOMPATABILITY_GRP_CODE
            , NULL PROCESSED_FLAG
            , adj.applied_flag
            , adj.automatic_flag
            , adj.update_allowed override_flag
            , NULL PRIMARY_UOM_FLAG
            , NULL PRINT_ON_INVOICE_FLAG
            , adj.modifier_level_code
            , adj.BENEFIT_QTY
            , adj.BENEFIT_UOM_CODE
            , adj.LIST_LINE_NO
            , adj.accrual_flag
            , adj.ACCRUAL_CONVERSION_RATE
            , NULL ESTIM_ACCRUAL_RATE
            , NULL RECURRING_FLAG
            , NULL SELECTED_VOLUME_ATTR
            , getline.rounding_factor
            , NULL HEADER_LIMIT_EXISTS
            , NULL LINE_LIMIT_EXISTS
            , adj.charge_type_code
            , adj.charge_subtype_code
            , NULL CURRENCY_DETAIL_ID
            , NULL CURRENCY_HEADER_ID
            , NULL SELLING_ROUNDING_FACTOR
            , NULL ORDER_CURRENCY
            , NULL PRICING_EFFECTIVE_DATE
            , NULL BASE_CURRENCY_CODE
            --, line.line_quantity
            , adj.range_break_quantity line_quantity
            , nvl(adj.updated_flag, QP_PREQ_PUB.G_NO) updated_flag
            , NULL calculation_code
            , adj.CHANGE_REASON_CODE
            , adj.CHANGE_REASON_TEXT
            , adj.PRICE_ADJUSTMENT_ID
            , NULL ACCUM_CONTEXT
            , NULL ACCUM_ATTRIBUTE
            , NULL ACCUM_FLAG
            , NULL BREAK_UOM_CODE
            , NULL BREAK_UOM_CONTEXT
            , NULL BREAK_UOM_ATTRIBUTE
            , NULL PROCESS_CODE -- 3215497
    FROM   qp_int_lines getline, oe_price_adjustments adj,
           qp_int_ldets ldet, oe_price_adj_assocs ass
    WHERE  QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
    AND    ldet.CREATED_FROM_LIST_LINE_TYPE = 'PRG'
    AND    ass.price_adjustment_id = ldet.price_adjustment_id
    AND    ass.rltd_price_adj_id = adj.price_adjustment_id
    AND    adj.line_id = getline.line_id
    AND    getline.line_index = ldet.line_index -- sql repos
    AND    getline.process_status IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                      QP_PREQ_PUB.G_STATUS_NEW,
                                      QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                      'NEW' || QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                      'OLD' || QP_PREQ_PUB.G_STATUS_UNCHANGED)
    AND    getline.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                                           , QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                           , QP_PREQ_PUB.G_STATUS_UNCHANGED)
    AND    getline.price_flag = QP_PREQ_PUB.G_NO
    AND    adj.price_adjustment_id NOT IN (SELECT price_adjustment_id
                                           FROM qp_int_ldets);
  --(getline.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE,QP_PREQ_PUB.G_CALCULATE_ONLY)
  --OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
  --and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL

  l_LINE_DETAIL_index QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_LINE_DETAIL_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICE_BREAK_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_LIST_PRICE QP_PREQ_GRP.NUMBER_TYPE;
  l_LINE_INDEX QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_CREATED_FROM_LIST_HEADER_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_CREATED_FROM_LIST_LINE_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_CREATED_FROM_LIST_LINE_TYPE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CREATED_FROM_LIST_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CREATED_FROM_SQL QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICING_GROUP_SEQUENCE QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_PRICING_PHASE_ID QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_OPERAND_CALCULATION_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_OPERAND_VALUE QP_PREQ_GRP.VARCHAR_TYPE;
  l_SUBSTITUTION_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_SUBSTITUTION_VALUE_FROM QP_PREQ_GRP.VARCHAR_TYPE;
  l_SUBSTITUTION_VALUE_TO QP_PREQ_GRP.VARCHAR_TYPE;
  l_ASK_FOR_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICE_FORMULA_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_PRICING_STATUS_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICING_STATUS_TEXT QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRODUCT_PRECEDENCE QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_INCOMPATABLILITY_GRP_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_PROCESSED_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_APPLIED_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_AUTOMATIC_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_OVERRIDE_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRIMARY_UOM_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRINT_ON_INVOICE_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_MODIFIER_LEVEL_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_BENEFIT_QTY QP_PREQ_GRP.NUMBER_TYPE;
  l_BENEFIT_UOM_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_LIST_LINE_NO QP_PREQ_GRP.VARCHAR_TYPE;
  l_ACCRUAL_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_ACCRUAL_CONVERSION_RATE QP_PREQ_GRP.NUMBER_TYPE;
  l_ESTIM_ACCRUAL_RATE QP_PREQ_GRP.NUMBER_TYPE;
  l_RECURRING_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_SELECTED_VOLUME_ATTR QP_PREQ_GRP.VARCHAR_TYPE;
  l_ROUNDING_FACTOR QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_HEADER_LIMIT_EXISTS QP_PREQ_GRP.VARCHAR_TYPE;
  l_LINE_LIMIT_EXISTS QP_PREQ_GRP.VARCHAR_TYPE;
  l_CHARGE_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CHARGE_SUBTYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CURRENCY_DETAIL_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_CURRENCY_HEADER_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_SELLING_ROUNDING_FACTOR QP_PREQ_GRP.NUMBER_TYPE;
  l_ORDER_CURRENCY QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICING_EFFECTIVE_DATE QP_PREQ_GRP.DATE_TYPE;
  l_BASE_CURRENCY_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_LINE_QUANTITY QP_PREQ_GRP.NUMBER_TYPE;
  l_UPDATED_FLAG QP_PREQ_GRP.VARCHAR_TYPE;
  l_CALCULATION_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CHANGE_REASON_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_CHANGE_REASON_TEXT QP_PREQ_GRP.VARCHAR_TYPE;
  l_PRICE_ADJUSTMENT_ID QP_PREQ_GRP.NUMBER_TYPE; -- bug 3099847
  l_ACCUM_CONTEXT QP_PREQ_GRP.VARCHAR_TYPE; -- accum range break
  l_ACCUM_ATTRIBUTE QP_PREQ_GRP.VARCHAR_TYPE; -- accum range break
  l_ACCUM_FLAG QP_PREQ_GRP.VARCHAR_TYPE; -- accum range break
  l_BREAK_UOM_CODE QP_PREQ_GRP.VARCHAR_TYPE; /* Proration*/
  l_BREAK_UOM_CONTEXT QP_PREQ_GRP.VARCHAR_TYPE; /* Proration*/
  l_BREAK_UOM_ATTRIBUTE QP_PREQ_GRP.VARCHAR_TYPE; /* Proration*/
  l_PROCESS_CODE QP_PREQ_GRP.VARCHAR_TYPE; -- 3215497

  l_LINE_INDEX1 QP_PREQ_GRP.PLS_INTEGER_TYPE; -- 3215497
  l_LINE_DETAIL_INDEX1 QP_PREQ_GRP.PLS_INTEGER_TYPE; -- 3215497
  l_RELATIONSHIP_TYPE_CODE QP_PREQ_GRP.VARCHAR_TYPE;
  l_RELATED_LINE_INDEX QP_PREQ_GRP.PLS_INTEGER_TYPE; -- 3215497
  l_RELATED_LINE_DETAIL_INDEX QP_PREQ_GRP.PLS_INTEGER_TYPE; -- 3215497
  l_LIST_LINE_ID QP_PREQ_GRP.NUMBER_TYPE;
  l_RLTD_LIST_LINE_ID QP_PREQ_GRP.NUMBER_TYPE;
  --l_pricing_status_code        QP_PREQ_GRP.VARCHAR_TYPE;
  --l_pricing_status_text        QP_PREQ_GRP.VARCHAR_TYPE;

  l_debug VARCHAR2(3);
  l_pbh_adj_exists VARCHAR2(1) := QP_PREQ_PUB.G_NO;
  l_prg_adj_exists VARCHAR2(1) := QP_PREQ_PUB.G_NO;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

    --per bug3238607, no need to check HVOP
    IF(QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES ) THEN
      --QP_UTIL_PUB.HVOP_PRICING_ON = QP_PREQ_PUB.G_NO) THEN
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG=Y and ');
        --'QP_BULK_PREQ_GRP.G_HVOP_Pricing_ON=N');
        QP_PREQ_GRP.ENGINE_DEBUG('QP_PREQ_PUB.G_GET_FREIGHT_FLAG:' || QP_PREQ_PUB.G_GET_FREIGHT_FLAG);
      END IF;

      OPEN l_ldets_cur;
      LOOP
        l_LINE_DETAIL_index.DELETE;
        l_LINE_DETAIL_TYPE_CODE.DELETE;
        l_PRICE_BREAK_TYPE_CODE.DELETE;
        l_LIST_PRICE.DELETE;
        l_LINE_INDEX.DELETE;
        l_CREATED_FROM_LIST_HEADER_ID.DELETE;
        l_CREATED_FROM_LIST_LINE_ID.DELETE;
        l_CREATED_FROM_LIST_LINE_TYPE.DELETE;
        l_CREATED_FROM_LIST_TYPE_CODE.DELETE;
        l_CREATED_FROM_SQL.DELETE;
        l_PRICING_GROUP_SEQUENCE.DELETE;
        l_PRICING_PHASE_ID.DELETE;
        l_OPERAND_CALCULATION_CODE.DELETE;
        l_OPERAND_VALUE.DELETE;
        l_SUBSTITUTION_TYPE_CODE.DELETE;
        l_SUBSTITUTION_VALUE_FROM.DELETE;
        l_SUBSTITUTION_VALUE_TO.DELETE;
        l_ASK_FOR_FLAG.DELETE;
        l_PRICE_FORMULA_ID.DELETE;
        l_PRICING_STATUS_CODE.DELETE;
        l_PRICING_STATUS_TEXT.DELETE;
        l_PRODUCT_PRECEDENCE.DELETE;
        l_INCOMPATABLILITY_GRP_CODE.DELETE;
        l_PROCESSED_FLAG.DELETE;
        l_APPLIED_FLAG.DELETE;
        l_AUTOMATIC_FLAG.DELETE;
        l_OVERRIDE_FLAG.DELETE;
        l_PRIMARY_UOM_FLAG.DELETE;
        l_PRINT_ON_INVOICE_FLAG.DELETE;
        l_MODIFIER_LEVEL_CODE.DELETE;
        l_BENEFIT_QTY.DELETE;
        l_BENEFIT_UOM_CODE.DELETE;
        l_LIST_LINE_NO.DELETE;
        l_ACCRUAL_FLAG.DELETE;
        l_ACCRUAL_CONVERSION_RATE.DELETE;
        l_ESTIM_ACCRUAL_RATE.DELETE;
        l_RECURRING_FLAG.DELETE;
        l_SELECTED_VOLUME_ATTR.DELETE;
        l_ROUNDING_FACTOR.DELETE;
        l_HEADER_LIMIT_EXISTS.DELETE;
        l_LINE_LIMIT_EXISTS.DELETE;
        l_CHARGE_TYPE_CODE.DELETE;
        l_CHARGE_SUBTYPE_CODE.DELETE;
        l_CURRENCY_DETAIL_ID.DELETE;
        l_CURRENCY_HEADER_ID.DELETE;
        l_SELLING_ROUNDING_FACTOR.DELETE;
        l_ORDER_CURRENCY.DELETE;
        l_PRICING_EFFECTIVE_DATE.DELETE;
        l_BASE_CURRENCY_CODE.DELETE;
        l_LINE_QUANTITY.DELETE;
        l_UPDATED_FLAG.DELETE;
        l_CALCULATION_CODE.DELETE;
        l_CHANGE_REASON_CODE.DELETE;
        l_CHANGE_REASON_TEXT.DELETE;
        l_PRICE_ADJUSTMENT_ID.DELETE;
        l_ACCUM_CONTEXT.DELETE;
        l_ACCUM_ATTRIBUTE.DELETE;
        l_ACCUM_FLAG.DELETE;
        l_BREAK_UOM_CODE.DELETE;
        l_BREAK_UOM_CONTEXT.DELETE;
        l_BREAK_UOM_ATTRIBUTE.DELETE;
        l_PROCESS_CODE.DELETE; -- 3215497

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('fetching l_ldets_cur');
        END IF;

        FETCH l_ldets_cur
        BULK COLLECT INTO
        l_LINE_DETAIL_index,
        l_LINE_DETAIL_TYPE_CODE,
        l_PRICE_BREAK_TYPE_CODE,
        l_LIST_PRICE,
        l_LINE_INDEX,
        l_CREATED_FROM_LIST_HEADER_ID,
        l_CREATED_FROM_LIST_LINE_ID,
        l_CREATED_FROM_LIST_LINE_TYPE,
        l_CREATED_FROM_LIST_TYPE_CODE,
        l_CREATED_FROM_SQL,
        l_PRICING_GROUP_SEQUENCE,
        l_PRICING_PHASE_ID,
        l_OPERAND_CALCULATION_CODE,
        l_OPERAND_VALUE,
        l_SUBSTITUTION_TYPE_CODE,
        l_SUBSTITUTION_VALUE_FROM,
        l_SUBSTITUTION_VALUE_TO,
        l_ASK_FOR_FLAG,
        l_PRICE_FORMULA_ID,
        l_PRICING_STATUS_CODE,
        l_PRICING_STATUS_TEXT,
        l_PRODUCT_PRECEDENCE,
        l_INCOMPATABLILITY_GRP_CODE,
        l_PROCESSED_FLAG,
        l_APPLIED_FLAG,
        l_AUTOMATIC_FLAG,
        l_OVERRIDE_FLAG,
        l_PRIMARY_UOM_FLAG,
        l_PRINT_ON_INVOICE_FLAG,
        l_MODIFIER_LEVEL_CODE,
        l_BENEFIT_QTY,
        l_BENEFIT_UOM_CODE,
        l_LIST_LINE_NO,
        l_ACCRUAL_FLAG,
        l_ACCRUAL_CONVERSION_RATE,
        l_ESTIM_ACCRUAL_RATE,
        l_RECURRING_FLAG,
        l_SELECTED_VOLUME_ATTR,
        l_ROUNDING_FACTOR,
        l_HEADER_LIMIT_EXISTS,
        l_LINE_LIMIT_EXISTS,
        l_CHARGE_TYPE_CODE,
        l_CHARGE_SUBTYPE_CODE,
        l_CURRENCY_DETAIL_ID,
        l_CURRENCY_HEADER_ID,
        l_SELLING_ROUNDING_FACTOR,
        l_ORDER_CURRENCY,
        l_PRICING_EFFECTIVE_DATE,
        l_BASE_CURRENCY_CODE,
        l_LINE_QUANTITY,
        l_UPDATED_FLAG,
        l_CALCULATION_CODE,
        l_CHANGE_REASON_CODE,
        l_CHANGE_REASON_TEXT,
        l_PRICE_ADJUSTMENT_ID,
        l_ACCUM_CONTEXT,
        l_ACCUM_ATTRIBUTE,
        l_ACCUM_FLAG,
        l_BREAK_UOM_CODE,
        l_BREAK_UOM_CONTEXT,
        l_BREAK_UOM_ATTRIBUTE,
        l_PROCESS_CODE; -- 3215497
        --      LIMIT nrows;
        EXIT WHEN l_LINE_DETAIL_index.COUNT = 0;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('rows fetched:'|| l_line_detail_index.COUNT);
        END IF;

        IF l_LINE_DETAIL_index.COUNT > 0
          AND l_debug = FND_API.G_TRUE
          THEN
          FOR i IN l_LINE_DETAIL_index.FIRST..l_LINE_DETAIL_index.LAST
            LOOP
            QP_PREQ_GRP.engine_debug('=======line_detail_index: '|| l_LINE_DETAIL_index(i) ||
                                     ' line_detail_type_code: '|| l_LINE_DETAIL_TYPE_CODE(i) ||
                                     ' price_break_type_code: '|| l_PRICE_BREAK_TYPE_CODE(i) ||
                                     ' list_price: ' || l_LIST_PRICE(i) ||
                                     ' line_index: '|| l_LINE_INDEX(i));

            QP_PREQ_GRP.engine_debug('created_from_list_header_id: '|| l_CREATED_FROM_LIST_HEADER_ID(i) ||
                                     ' created_from_list_line_id: '|| l_CREATED_FROM_LIST_LINE_ID(i) ||
                                     ' created_from_list_line_type: '|| l_CREATED_FROM_LIST_LINE_TYPE(i) ||
                                     ' created_from_list_type_code: '|| l_CREATED_FROM_LIST_TYPE_CODE(i) ||
                                     ' created_from_sql: '|| l_CREATED_FROM_SQL(i) ||
                                     ' pricing_group_sequence: ' || l_PRICING_GROUP_SEQUENCE(i) ||
                                     ' pricing_phase_id: '|| l_PRICING_PHASE_ID(i) ||
                                     ' oprand_calculation_code: ' || l_OPERAND_CALCULATION_CODE(i) ||
                                     ' operand_value: ' || l_OPERAND_VALUE(i));
            QP_PREQ_GRP.engine_debug(' substitution_type_code: ' || l_SUBSTITUTION_TYPE_CODE(i) ||
                                     ' substitution_value_from: ' || l_SUBSTITUTION_VALUE_FROM(i) ||
                                     ' substitution_value_to: ' || l_SUBSTITUTION_VALUE_TO(i) ||
                                     ' ask_for_flag: ' || l_ASK_FOR_FLAG(i) ||
                                     ' price_formula_id: '|| l_PRICE_FORMULA_ID(i) ||
                                     ' pricing_status_code: '|| l_PRICING_STATUS_CODE(i) ||
                                     ' pricing_status_text: '|| l_PRICING_STATUS_TEXT(i) ||
                                     ' product_precedence: '|| l_PRODUCT_PRECEDENCE(i) ||
                                     ' incompatability_grp_code: ' || l_INCOMPATABLILITY_GRP_CODE(i));

            QP_PREQ_GRP.engine_debug(' processed_flag: '|| l_PROCESSED_FLAG(i) ||
                                     ' applied_flag: '|| l_APPLIED_FLAG(i) ||
                                     ' automatic_flag: '|| l_AUTOMATIC_FLAG(i) ||
                                     ' override_flag: '|| l_OVERRIDE_FLAG(i) ||
                                     ' primary_uom_flag: '|| l_PRIMARY_UOM_FLAG(i) ||
                                     ' print_on_invoice_flag: '|| l_PRINT_ON_INVOICE_FLAG(i) ||
                                     ' MODIFIER_LEVEL_CODE: '|| l_MODIFIER_LEVEL_CODE(i) ||
                                     ' BENEFIT_QTY: '|| l_BENEFIT_QTY(i) ||
                                     ' BENEFIT_UOM_CODE: '|| l_BENEFIT_UOM_CODE(i));

            QP_PREQ_GRP.engine_debug(' LIST_LINE_NO: '|| l_LIST_LINE_NO(i) ||
                                     ' ACCRUAL_FLAG: '|| l_ACCRUAL_FLAG(i) ||
                                     ' ACCRUAL_CONVERSION_RATE: '|| l_ACCRUAL_CONVERSION_RATE(i) ||
                                     ' ESTIM_ACCRUAL_RATE: '|| l_ESTIM_ACCRUAL_RATE(i) ||
                                     ' RECURRING_FLAG: '|| l_RECURRING_FLAG(i) ||
                                     ' SELECTED_VOLUME_ATTR: '|| l_SELECTED_VOLUME_ATTR(i) ||
                                     ' ROUNDING_FACTOR: '|| l_ROUNDING_FACTOR(i) ||
                                     ' HEADER_LIMIT_EXISTS: '|| l_HEADER_LIMIT_EXISTS(i) ||
                                     ' LINE_LIMIT_EXISTS: '|| l_LINE_LIMIT_EXISTS(i));

            QP_PREQ_GRP.engine_debug(' CHARGE_TYPE_CODE:'|| l_CHARGE_TYPE_CODE(i) ||
                                     ' CHARGE_SUBTYPE_CODE:'|| l_CHARGE_SUBTYPE_CODE(i) ||
                                     ' CURRENCY_DETAIL_ID:'|| l_CURRENCY_DETAIL_ID(i) ||
                                     ' CURRENCY_HEADER_ID:'|| l_CURRENCY_HEADER_ID(i) ||
                                     ' SELLING_ROUNDING_FACTOR:'|| l_SELLING_ROUNDING_FACTOR(i) ||
                                     ' ORDER_CURRENCY:'|| l_ORDER_CURRENCY(i) ||
                                     ' PRICING_EFFECTIVE_DATE:'|| l_PRICING_EFFECTIVE_DATE(i) ||
                                     ' BASE_CURRENCY_CODE:'|| l_BASE_CURRENCY_CODE(i) ||
                                     ' LINE_QUANTITY:'|| l_LINE_QUANTITY(i));

            QP_PREQ_GRP.engine_debug(' UPDATED_FLAG:'|| l_UPDATED_FLAG(i) ||
                                     ' CALCULATION_CODE:'|| l_CALCULATION_CODE(i) ||
                                     ' CHANGE_REASON_CODE:'|| l_CHANGE_REASON_CODE(i) ||
                                     ' CHANGE_REASON_TEXT:'|| l_CHANGE_REASON_TEXT(i) ||
                                     ' PRICE_ADJUSTMENT_ID:'|| l_PRICE_ADJUSTMENT_ID(i) ||
                                     ' ACCUM_CONTEXT:'|| l_ACCUM_CONTEXT(i) ||
                                     ' ACCUM_ATTRIBUTE:'|| l_ACCUM_ATTRIBUTE(i) ||
                                     ' ACCUM_FLAG:'|| l_ACCUM_FLAG(i) ||
                                     ' BREAK_UOM_CODE:'|| l_BREAK_UOM_CODE(i) ||
                                     ' BREAK_UOM_CONTEXT:'|| l_BREAK_UOM_CONTEXT(i) ||
                                     ' BREAK_UOM_ATTRIBUTE:'|| l_BREAK_UOM_ATTRIBUTE(i));

          END LOOP;
        END IF; --l_line_detail_index.COUNT

        IF l_LINE_DETAIL_index.COUNT > 0 THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('calling INSERT_LDETS2');
          END IF;
          QP_PREQ_GRP.INSERT_LDETS2
          (l_LINE_DETAIL_index,
           l_LINE_DETAIL_TYPE_CODE,
           l_PRICE_BREAK_TYPE_CODE,
           l_LIST_PRICE,
           l_LINE_INDEX,
           l_CREATED_FROM_LIST_HEADER_ID,
           l_CREATED_FROM_LIST_LINE_ID,
           l_CREATED_FROM_LIST_LINE_TYPE,
           l_CREATED_FROM_LIST_TYPE_CODE,
           l_CREATED_FROM_SQL,
           l_PRICING_GROUP_SEQUENCE,
           l_PRICING_PHASE_ID,
           l_OPERAND_CALCULATION_CODE,
           l_OPERAND_VALUE,
           l_SUBSTITUTION_TYPE_CODE,
           l_SUBSTITUTION_VALUE_FROM,
           l_SUBSTITUTION_VALUE_TO,
           l_ASK_FOR_FLAG,
           l_PRICE_FORMULA_ID,
           l_PRICING_STATUS_CODE,
           l_PRICING_STATUS_TEXT,
           l_PRODUCT_PRECEDENCE,
           l_INCOMPATABLILITY_GRP_CODE,
           l_PROCESSED_FLAG,
           l_APPLIED_FLAG,
           l_AUTOMATIC_FLAG,
           l_OVERRIDE_FLAG,
           l_PRIMARY_UOM_FLAG,
           l_PRINT_ON_INVOICE_FLAG,
           l_MODIFIER_LEVEL_CODE,
           l_BENEFIT_QTY,
           l_BENEFIT_UOM_CODE,
           l_LIST_LINE_NO,
           l_ACCRUAL_FLAG,
           l_ACCRUAL_CONVERSION_RATE,
           l_ESTIM_ACCRUAL_RATE,
           l_RECURRING_FLAG,
           l_SELECTED_VOLUME_ATTR,
           l_ROUNDING_FACTOR,
           l_HEADER_LIMIT_EXISTS,
           l_LINE_LIMIT_EXISTS,
           l_CHARGE_TYPE_CODE,
           l_CHARGE_SUBTYPE_CODE,
           l_CURRENCY_DETAIL_ID,
           l_CURRENCY_HEADER_ID,
           l_SELLING_ROUNDING_FACTOR,
           l_ORDER_CURRENCY,
           l_PRICING_EFFECTIVE_DATE,
           l_BASE_CURRENCY_CODE,
           l_LINE_QUANTITY,
           l_UPDATED_FLAG,
           l_CALCULATION_CODE,
           l_CHANGE_REASON_CODE,
           l_CHANGE_REASON_TEXT,
           l_PRICE_ADJUSTMENT_ID,
           l_ACCUM_CONTEXT,
           l_ACCUM_ATTRIBUTE,
           l_ACCUM_FLAG,
           l_BREAK_UOM_CODE,
           l_BREAK_UOM_CONTEXT,
           l_BREAK_UOM_ATTRIBUTE,
           l_PROCESS_CODE,  -- 3215497
           x_return_status,
           x_return_status_text);
        END IF;
      END LOOP;
      CLOSE l_ldets_cur;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('close l_ldets_cur');
      END IF;


      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Insert rltd lines');
      END IF;

      OPEN l_pbh_adj_exists_cur;
      FETCH l_pbh_adj_exists_cur INTO l_pbh_adj_exists;
      CLOSE l_pbh_adj_exists_cur;

      OPEN l_prg_adj_exists_cur;
      FETCH l_prg_adj_exists_cur INTO l_prg_adj_exists;
      CLOSE l_prg_adj_exists_cur;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Check l_pbh_adj_exists '|| l_pbh_adj_exists);
        QP_PREQ_GRP.engine_debug('Check l_prg_adj_exists '|| l_prg_adj_exists);
      END IF;

      --IF l_pbh_adj_exists = QP_PREQ_PUB.G_YES
      --THEN
      --  OPEN l_rltd_lines_cur;
      OPEN l_rltd_lines_cur(l_pbh_adj_exists, l_prg_adj_exists);
      LOOP
        l_LINE_index1.DELETE;
        l_LINE_DETAIL_INDEX1.DELETE;
        l_RELATIONSHIP_TYPE_CODE.DELETE;
        l_RELATED_LINE_INDEX.DELETE;
        l_RELATED_LINE_DETAIL_INDEX.DELETE;
        l_LIST_LINE_ID.DELETE;
        l_RLTD_LIST_LINE_ID.DELETE;
        l_pricing_status_text.DELETE;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('fetching l_rltd_lines_cur');
        END IF;

        FETCH l_rltd_lines_cur
        BULK COLLECT INTO
        l_LINE_index1,
        l_LINE_DETAIL_INDEX1,
        l_RELATIONSHIP_TYPE_CODE,
        l_RELATED_LINE_INDEX,
        l_RELATED_LINE_DETAIL_INDEX,
        l_LIST_LINE_ID,
        l_RLTD_LIST_LINE_ID,
        l_pricing_status_text;
        --      LIMIT nrows;
        EXIT WHEN l_LINE_index1.COUNT = 0;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('rows fetched:'|| l_line_index1.COUNT);
        END IF;

        IF l_LINE_index1.COUNT > 0
          AND l_debug = FND_API.G_TRUE
          THEN
          FOR i IN l_LINE_index1.FIRST..l_LINE_index1.LAST
            LOOP
            QP_PREQ_GRP.engine_debug('======line_index: '|| l_LINE_index1(i) ||
                                     ' line_detail_index: '|| l_LINE_DETAIL_index1(i) ||
                                     ' relationship_type_code: '|| l_RELATIONSHIP_TYPE_CODE(i) ||
                                     ' related_line_index: '|| l_RELATED_LINE_INDEX(i) ||
                                     ' related_line_detail_index: ' || l_RELATED_LINE_DETAIL_INDEX(i) ||
                                     ' list_line_id: '|| l_LIST_LINE_ID(i) ||
                                     ' rltd_list_line_id: '|| l_RLTD_LIST_LINE_ID(i) ||
                                     ' pricing_status_text:' || l_pricing_status_text(i));
          END LOOP;
        END IF; --l_LINE_index1.COUNT

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('calling INSERT_RLTD_LDETS2');
        END IF;
        QP_PREQ_GRP.INSERT_RLTD_LINES2
        (l_LINE_INDEX1
         , l_LINE_DETAIL_INDEX1
         , l_RELATIONSHIP_TYPE_CODE
         , l_RELATED_LINE_INDEX
         , l_RELATED_LINE_DETAIL_INDEX
         , x_return_status
         , x_return_status_text
         , l_LIST_LINE_ID
         , l_RLTD_LIST_LINE_ID
         , l_pricing_status_text);
        /* delete from qp_npreq_rltd_lines_tmp
         where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
         and relationship_type_code = QP_PREQ_PUB.G_PBH_LINE
         and pricing_status_text = G_CALC_INSERT;
       */ --need to delete them later
      END LOOP;
      CLOSE l_rltd_lines_cur;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('close l_rltd_lines_cur');
      END IF;

      IF l_prg_adj_exists = 'Y' THEN
        OPEN l_getline_dis_cur;
        LOOP
          l_LINE_DETAIL_index.DELETE;
          l_LINE_DETAIL_TYPE_CODE.DELETE;
          l_PRICE_BREAK_TYPE_CODE.DELETE;
          l_LIST_PRICE.DELETE;
          l_LINE_INDEX.DELETE;
          l_CREATED_FROM_LIST_HEADER_ID.DELETE;
          l_CREATED_FROM_LIST_LINE_ID.DELETE;
          l_CREATED_FROM_LIST_LINE_TYPE.DELETE;
          l_CREATED_FROM_LIST_TYPE_CODE.DELETE;
          l_CREATED_FROM_SQL.DELETE;
          l_PRICING_GROUP_SEQUENCE.DELETE;
          l_PRICING_PHASE_ID.DELETE;
          l_OPERAND_CALCULATION_CODE.DELETE;
          l_OPERAND_VALUE.DELETE;
          l_SUBSTITUTION_TYPE_CODE.DELETE;
          l_SUBSTITUTION_VALUE_FROM.DELETE;
          l_SUBSTITUTION_VALUE_TO.DELETE;
          l_ASK_FOR_FLAG.DELETE;
          l_PRICE_FORMULA_ID.DELETE;
          l_PRICING_STATUS_CODE.DELETE;
          l_PRICING_STATUS_TEXT.DELETE;
          l_PRODUCT_PRECEDENCE.DELETE;
          l_INCOMPATABLILITY_GRP_CODE.DELETE;
          l_PROCESSED_FLAG.DELETE;
          l_APPLIED_FLAG.DELETE;
          l_AUTOMATIC_FLAG.DELETE;
          l_OVERRIDE_FLAG.DELETE;
          l_PRIMARY_UOM_FLAG.DELETE;
          l_PRINT_ON_INVOICE_FLAG.DELETE;
          l_MODIFIER_LEVEL_CODE.DELETE;
          l_BENEFIT_QTY.DELETE;
          l_BENEFIT_UOM_CODE.DELETE;
          l_LIST_LINE_NO.DELETE;
          l_ACCRUAL_FLAG.DELETE;
          l_ACCRUAL_CONVERSION_RATE.DELETE;
          l_ESTIM_ACCRUAL_RATE.DELETE;
          l_RECURRING_FLAG.DELETE;
          l_SELECTED_VOLUME_ATTR.DELETE;
          l_ROUNDING_FACTOR.DELETE;
          l_HEADER_LIMIT_EXISTS.DELETE;
          l_LINE_LIMIT_EXISTS.DELETE;
          l_CHARGE_TYPE_CODE.DELETE;
          l_CHARGE_SUBTYPE_CODE.DELETE;
          l_CURRENCY_DETAIL_ID.DELETE;
          l_CURRENCY_HEADER_ID.DELETE;
          l_SELLING_ROUNDING_FACTOR.DELETE;
          l_ORDER_CURRENCY.DELETE;
          l_PRICING_EFFECTIVE_DATE.DELETE;
          l_BASE_CURRENCY_CODE.DELETE;
          l_LINE_QUANTITY.DELETE;
          l_UPDATED_FLAG.DELETE;
          l_CALCULATION_CODE.DELETE;
          l_CHANGE_REASON_CODE.DELETE;
          l_CHANGE_REASON_TEXT.DELETE;
          l_PRICE_ADJUSTMENT_ID.DELETE;
          l_ACCUM_CONTEXT.DELETE;
          l_ACCUM_ATTRIBUTE.DELETE;
          l_ACCUM_FLAG.DELETE;
          l_BREAK_UOM_CODE.DELETE;
          l_BREAK_UOM_CONTEXT.DELETE;
          l_BREAK_UOM_ATTRIBUTE.DELETE;
          l_PROCESS_CODE.DELETE; -- 3215497

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('fetching l_getline_dis_cur');
          END IF;

          FETCH l_getline_dis_cur
          BULK COLLECT INTO
          l_LINE_DETAIL_index,
          l_LINE_DETAIL_TYPE_CODE,
          l_PRICE_BREAK_TYPE_CODE,
          l_LIST_PRICE,
          l_LINE_INDEX,
          l_CREATED_FROM_LIST_HEADER_ID,
          l_CREATED_FROM_LIST_LINE_ID,
          l_CREATED_FROM_LIST_LINE_TYPE,
          l_CREATED_FROM_LIST_TYPE_CODE,
          l_CREATED_FROM_SQL,
          l_PRICING_GROUP_SEQUENCE,
          l_PRICING_PHASE_ID,
          l_OPERAND_CALCULATION_CODE,
          l_OPERAND_VALUE,
          l_SUBSTITUTION_TYPE_CODE,
          l_SUBSTITUTION_VALUE_FROM,
          l_SUBSTITUTION_VALUE_TO,
          l_ASK_FOR_FLAG,
          l_PRICE_FORMULA_ID,
          l_PRICING_STATUS_CODE,
          l_PRICING_STATUS_TEXT,
          l_PRODUCT_PRECEDENCE,
          l_INCOMPATABLILITY_GRP_CODE,
          l_PROCESSED_FLAG,
          l_APPLIED_FLAG,
          l_AUTOMATIC_FLAG,
          l_OVERRIDE_FLAG,
          l_PRIMARY_UOM_FLAG,
          l_PRINT_ON_INVOICE_FLAG,
          l_MODIFIER_LEVEL_CODE,
          l_BENEFIT_QTY,
          l_BENEFIT_UOM_CODE,
          l_LIST_LINE_NO,
          l_ACCRUAL_FLAG,
          l_ACCRUAL_CONVERSION_RATE,
          l_ESTIM_ACCRUAL_RATE,
          l_RECURRING_FLAG,
          l_SELECTED_VOLUME_ATTR,
          l_ROUNDING_FACTOR,
          l_HEADER_LIMIT_EXISTS,
          l_LINE_LIMIT_EXISTS,
          l_CHARGE_TYPE_CODE,
          l_CHARGE_SUBTYPE_CODE,
          l_CURRENCY_DETAIL_ID,
          l_CURRENCY_HEADER_ID,
          l_SELLING_ROUNDING_FACTOR,
          l_ORDER_CURRENCY,
          l_PRICING_EFFECTIVE_DATE,
          l_BASE_CURRENCY_CODE,
          l_LINE_QUANTITY,
          l_UPDATED_FLAG,
          l_CALCULATION_CODE,
          l_CHANGE_REASON_CODE,
          l_CHANGE_REASON_TEXT,
          l_PRICE_ADJUSTMENT_ID,
          l_ACCUM_CONTEXT,
          l_ACCUM_ATTRIBUTE,
          l_ACCUM_FLAG,
          l_BREAK_UOM_CODE,
          l_BREAK_UOM_CONTEXT,
          l_BREAK_UOM_ATTRIBUTE,
          l_PROCESS_CODE; -- 3215497
          --      LIMIT nrows;
          EXIT WHEN l_LINE_DETAIL_index.COUNT = 0;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('rows fetched:'|| l_line_detail_index.COUNT);
          END IF;

          IF l_LINE_DETAIL_index.COUNT > 0
            AND l_debug = FND_API.G_TRUE
            THEN
            FOR i IN l_LINE_DETAIL_index.FIRST..l_LINE_DETAIL_index.LAST
              LOOP
              QP_PREQ_GRP.engine_debug('=======line_detail_index: '|| l_LINE_DETAIL_index(i) ||
                                       ' line_detail_type_code: '|| l_LINE_DETAIL_TYPE_CODE(i) ||
                                       ' price_break_type_code: '|| l_PRICE_BREAK_TYPE_CODE(i) ||
                                       ' list_price: ' || l_LIST_PRICE(i) ||
                                       ' line_index: '|| l_LINE_INDEX(i));

              QP_PREQ_GRP.engine_debug('created_from_list_header_id: '|| l_CREATED_FROM_LIST_HEADER_ID(i) ||
                                       ' created_from_list_line_id: '|| l_CREATED_FROM_LIST_LINE_ID(i) ||
                                       ' created_from_list_line_type: '|| l_CREATED_FROM_LIST_LINE_TYPE(i) ||
                                       ' created_from_list_type_code: '|| l_CREATED_FROM_LIST_TYPE_CODE(i) ||
                                       ' created_from_sql: '|| l_CREATED_FROM_SQL(i) ||
                                       ' pricing_group_sequence: ' || l_PRICING_GROUP_SEQUENCE(i) ||
                                       ' pricing_phase_id: '|| l_PRICING_PHASE_ID(i) ||
                                       ' oprand_calculation_code: ' || l_OPERAND_CALCULATION_CODE(i) ||
                                       ' operand_value: ' || l_OPERAND_VALUE(i));
              QP_PREQ_GRP.engine_debug(' substitution_type_code: ' || l_SUBSTITUTION_TYPE_CODE(i) ||
                                       ' substitution_value_from: ' || l_SUBSTITUTION_VALUE_FROM(i) ||
                                       ' substitution_value_to: ' || l_SUBSTITUTION_VALUE_TO(i) ||
                                       ' ask_for_flag: ' || l_ASK_FOR_FLAG(i) ||
                                       ' price_formula_id: '|| l_PRICE_FORMULA_ID(i) ||
                                       ' pricing_status_code: '|| l_PRICING_STATUS_CODE(i) ||
                                       ' pricing_status_text: '|| l_PRICING_STATUS_TEXT(i) ||
                                       ' product_precedence: '|| l_PRODUCT_PRECEDENCE(i) ||
                                       ' incompatability_grp_code: ' || l_INCOMPATABLILITY_GRP_CODE(i));

              QP_PREQ_GRP.engine_debug(' processed_flag: '|| l_PROCESSED_FLAG(i) ||
                                       ' applied_flag: '|| l_APPLIED_FLAG(i) ||
                                       ' automatic_flag: '|| l_AUTOMATIC_FLAG(i) ||
                                       ' override_flag: '|| l_OVERRIDE_FLAG(i) ||
                                       ' primary_uom_flag: '|| l_PRIMARY_UOM_FLAG(i) ||
                                       ' print_on_invoice_flag: '|| l_PRINT_ON_INVOICE_FLAG(i) ||
                                       ' MODIFIER_LEVEL_CODE: '|| l_MODIFIER_LEVEL_CODE(i) ||
                                       ' BENEFIT_QTY: '|| l_BENEFIT_QTY(i) ||
                                       ' BENEFIT_UOM_CODE: '|| l_BENEFIT_UOM_CODE(i));

              QP_PREQ_GRP.engine_debug(' LIST_LINE_NO: '|| l_LIST_LINE_NO(i) ||
                                       ' ACCRUAL_FLAG: '|| l_ACCRUAL_FLAG(i) ||
                                       ' ACCRUAL_CONVERSION_RATE: '|| l_ACCRUAL_CONVERSION_RATE(i) ||
                                       ' ESTIM_ACCRUAL_RATE: '|| l_ESTIM_ACCRUAL_RATE(i) ||
                                       ' RECURRING_FLAG: '|| l_RECURRING_FLAG(i) ||
                                       ' SELECTED_VOLUME_ATTR: '|| l_SELECTED_VOLUME_ATTR(i) ||
                                       ' ROUNDING_FACTOR: '|| l_ROUNDING_FACTOR(i) ||
                                       ' HEADER_LIMIT_EXISTS: '|| l_HEADER_LIMIT_EXISTS(i) ||
                                       ' LINE_LIMIT_EXISTS: '|| l_LINE_LIMIT_EXISTS(i));

              QP_PREQ_GRP.engine_debug(' CHARGE_TYPE_CODE:'|| l_CHARGE_TYPE_CODE(i) ||
                                       ' CHARGE_SUBTYPE_CODE:'|| l_CHARGE_SUBTYPE_CODE(i) ||
                                       ' CURRENCY_DETAIL_ID:'|| l_CURRENCY_DETAIL_ID(i) ||
                                       ' CURRENCY_HEADER_ID:'|| l_CURRENCY_HEADER_ID(i) ||
                                       ' SELLING_ROUNDING_FACTOR:'|| l_SELLING_ROUNDING_FACTOR(i) ||
                                       ' ORDER_CURRENCY:'|| l_ORDER_CURRENCY(i) ||
                                       ' PRICING_EFFECTIVE_DATE:'|| l_PRICING_EFFECTIVE_DATE(i) ||
                                       ' BASE_CURRENCY_CODE:'|| l_BASE_CURRENCY_CODE(i) ||
                                       ' LINE_QUANTITY:'|| l_LINE_QUANTITY(i));

              QP_PREQ_GRP.engine_debug(' UPDATED_FLAG:'|| l_UPDATED_FLAG(i) ||
                                       ' CALCULATION_CODE:'|| l_CALCULATION_CODE(i) ||
                                       ' CHANGE_REASON_CODE:'|| l_CHANGE_REASON_CODE(i) ||
                                       ' CHANGE_REASON_TEXT:'|| l_CHANGE_REASON_TEXT(i) ||
                                       ' PRICE_ADJUSTMENT_ID:'|| l_PRICE_ADJUSTMENT_ID(i) ||
                                       ' ACCUM_CONTEXT:'|| l_ACCUM_CONTEXT(i) ||
                                       ' ACCUM_ATTRIBUTE:'|| l_ACCUM_ATTRIBUTE(i) ||
                                       ' ACCUM_FLAG:'|| l_ACCUM_FLAG(i) ||
                                       ' BREAK_UOM_CODE:'|| l_BREAK_UOM_CODE(i) ||
                                       ' BREAK_UOM_CONTEXT:'|| l_BREAK_UOM_CONTEXT(i) ||
                                       ' BREAK_UOM_ATTRIBUTE:'|| l_BREAK_UOM_ATTRIBUTE(i));

            END LOOP;
          END IF; --l_line_detail_index.COUNT

          IF l_LINE_DETAIL_index.COUNT > 0 THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('calling INSERT_LDETS2');
            END IF;
            QP_PREQ_GRP.INSERT_LDETS2
            (l_LINE_DETAIL_index,
             l_LINE_DETAIL_TYPE_CODE,
             l_PRICE_BREAK_TYPE_CODE,
             l_LIST_PRICE,
             l_LINE_INDEX,
             l_CREATED_FROM_LIST_HEADER_ID,
             l_CREATED_FROM_LIST_LINE_ID,
             l_CREATED_FROM_LIST_LINE_TYPE,
             l_CREATED_FROM_LIST_TYPE_CODE,
             l_CREATED_FROM_SQL,
             l_PRICING_GROUP_SEQUENCE,
             l_PRICING_PHASE_ID,
             l_OPERAND_CALCULATION_CODE,
             l_OPERAND_VALUE,
             l_SUBSTITUTION_TYPE_CODE,
             l_SUBSTITUTION_VALUE_FROM,
             l_SUBSTITUTION_VALUE_TO,
             l_ASK_FOR_FLAG,
             l_PRICE_FORMULA_ID,
             l_PRICING_STATUS_CODE,
             l_PRICING_STATUS_TEXT,
             l_PRODUCT_PRECEDENCE,
             l_INCOMPATABLILITY_GRP_CODE,
             l_PROCESSED_FLAG,
             l_APPLIED_FLAG,
             l_AUTOMATIC_FLAG,
             l_OVERRIDE_FLAG,
             l_PRIMARY_UOM_FLAG,
             l_PRINT_ON_INVOICE_FLAG,
             l_MODIFIER_LEVEL_CODE,
             l_BENEFIT_QTY,
             l_BENEFIT_UOM_CODE,
             l_LIST_LINE_NO,
             l_ACCRUAL_FLAG,
             l_ACCRUAL_CONVERSION_RATE,
             l_ESTIM_ACCRUAL_RATE,
             l_RECURRING_FLAG,
             l_SELECTED_VOLUME_ATTR,
             l_ROUNDING_FACTOR,
             l_HEADER_LIMIT_EXISTS,
             l_LINE_LIMIT_EXISTS,
             l_CHARGE_TYPE_CODE,
             l_CHARGE_SUBTYPE_CODE,
             l_CURRENCY_DETAIL_ID,
             l_CURRENCY_HEADER_ID,
             l_SELLING_ROUNDING_FACTOR,
             l_ORDER_CURRENCY,
             l_PRICING_EFFECTIVE_DATE,
             l_BASE_CURRENCY_CODE,
             l_LINE_QUANTITY,
             l_UPDATED_FLAG,
             l_CALCULATION_CODE,
             l_CHANGE_REASON_CODE,
             l_CHANGE_REASON_TEXT,
             l_PRICE_ADJUSTMENT_ID,
             l_ACCUM_CONTEXT,
             l_ACCUM_ATTRIBUTE,
             l_ACCUM_FLAG,
             l_BREAK_UOM_CODE,
             l_BREAK_UOM_CONTEXT,
             l_BREAK_UOM_ATTRIBUTE,
             l_PROCESS_CODE,  -- 3215497
             x_return_status,
             x_return_status_text);
          END IF;
        END LOOP;
        --CLOSE l_ldets_cur;
        CLOSE l_getline_dis_cur;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('close l_getline_dis_cur');
        END IF;

      END IF;

      --END IF;--l_pbh_adj_exists = QP_PREQ_PUB.G_YES
    END IF; --(QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES AND
    --QP_BULK_PREQ_GRP.G_HVOP_Pricing_ON = QP_PREQ_PUB.G_NO)
  END;

  --This procedure is to update the passed in overridden pbh modifiers
  --with the setup_value_from/to, qualifier_value, price_break_type_code
  --etc on the child lines which the price_break_calculation procedure
  --looks at to evaluate the breaks
  --This procedure will be used in the performance code path when
  --the public API is called by non-OM applications
  -- Ravi -- Added code to update the line detail type code which will be used
  -- in l_calculate_cur to not fetch the child lines as they are already in the qp_npreq_rltd_lines_tmp table
  -- Bug was adjustment amt was being calculated for child lines where it is not satisfied also
  PROCEDURE Update_passed_in_pbh(x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_status_text OUT NOCOPY VARCHAR2) IS

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

    --when any changes are made to this, the similar updated stmt
    --in Update_Related_Line_Info procedure in this file also needs to be changed
    UPDATE qp_npreq_rltd_lines_tmp rltd
            SET (setup_value_from,
                 setup_value_to,
                 relationship_type_detail,
                 list_line_id,
                 related_list_line_id,
                 related_list_line_type,
                 operand_calculation_code,
                 operand,
                 pricing_group_sequence,
                 qualifier_value)
                    =
                    (SELECT
                     qpa.pricing_attr_value_from,
                     qpa.pricing_attr_value_to,
                     ldet_pbh.price_break_type_code,
                     ldet_pbh.created_from_list_line_id,
                     ldet.created_from_list_line_id,
                     ldet.created_from_list_line_type,
                     ldet.operand_calculation_code,
                     ldet.operand_value,
                     ldet.pricing_group_sequence,
                     nvl(ldet.line_quantity,
                         nvl(line.priced_quantity, line.line_quantity))
                     FROM
                     qp_npreq_ldets_tmp ldet,
                     qp_npreq_ldets_tmp ldet_pbh,
                     qp_npreq_lines_tmp line,
                     qp_pricing_attributes qpa
                     WHERE
                     ldet.line_detail_index = rltd.related_line_detail_index
                     AND ldet_pbh.line_detail_index = rltd.line_detail_index
                     AND line.line_index = ldet.line_index
                     AND qpa.list_line_id = ldet.created_from_list_line_id
                     AND ldet.pricing_status_code = G_STATUS_UNCHANGED
                     AND ldet.updated_flag = G_YES
                     AND rltd.relationship_type_code = G_PBH_LINE
                     AND rltd.pricing_status_code = G_STATUS_NEW)
    WHERE rltd.line_detail_index IN (SELECT ldet.line_detail_index
                                     FROM qp_npreq_ldets_tmp ldet
                                     WHERE ldet.pricing_status_code = G_STATUS_UNCHANGED
                                     AND ldet.applied_flag = G_YES
                                     AND ldet.updated_flag = G_YES
                                     AND ldet.created_from_list_line_type = G_PRICE_BREAK_TYPE)
    AND rltd.relationship_type_code = G_PBH_LINE
    AND rltd.pricing_status_code = G_STATUS_NEW;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Updating PBH rltd dlts COUNT: '
                               || SQL%ROWCOUNT);
      QP_PREQ_GRP.engine_debug('Updating the child detail type code');
    END IF;

    UPDATE qp_npreq_ldets_tmp
    SET line_detail_type_code = QP_PREQ_PUB.G_CHILD_DETAIL_TYPE
    WHERE  line_detail_index IN (SELECT related_line_detail_index
                                 FROM  qp_npreq_rltd_lines_tmp
                                 WHERE  relationship_type_code = G_PBH_LINE
                                 AND pricing_status_code = G_STATUS_NEW);

    IF (l_debug = FND_API.G_TRUE) THEN
      FOR i IN (SELECT line_detail_index
                FROM qp_npreq_ldets_tmp
                WHERE line_detail_type_code = QP_PREQ_PUB.G_CHILD_DETAIL_TYPE)
        LOOP
        QP_PREQ_GRP.engine_debug(' PBH Child Line Detail Index : ' || i.line_detail_index);
      END LOOP;

    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in updated_passed_pbh '|| SQLERRM;
  END Update_passed_in_pbh;

  FUNCTION CHECK_GSA_INDICATOR RETURN VARCHAR2 IS

  CURSOR l_check_gsa_ind_cur IS
    SELECT 'Y'
     FROM qp_npreq_lines_tmp line,
            qp_npreq_line_attrs_tmp gsa_attr
     WHERE gsa_attr.line_index = line.line_index
             AND gsa_attr.pricing_status_code = G_STATUS_UNCHANGED
            AND gsa_attr.attribute_type = G_QUALIFIER_TYPE
            AND gsa_attr.context = G_CUSTOMER_CONTEXT
            AND gsa_attr.attribute = G_GSA_ATTRIBUTE
            AND gsa_attr.value_from = G_YES;

  l_gsa_indicator VARCHAR2(1) := 'N';
  l_routine VARCHAR2(50) := 'QP_PREQ_PUB.CHECK_GSA_INDICATOR';
  BEGIN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin CHECK_GSA_INDICATOR '|| l_gsa_indicator);

    END IF;
    OPEN l_check_gsa_ind_cur;
    FETCH l_check_gsa_ind_cur INTO l_gsa_indicator;
    CLOSE l_check_gsa_ind_cur;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Cursor fetched '|| l_gsa_indicator);

    END IF;
    RETURN l_gsa_indicator;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('END CHECK_GSA_INDICATOR ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
      RETURN l_gsa_indicator;
  END CHECK_GSA_INDICATOR;

  PROCEDURE CHECK_GSA_VIOLATION(
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

  -- bug 3804392 - removed the hint qp_list_headers_b_n2 and also rearranged the tables in FROM clause
  CURSOR l_gsa_check_cur IS
    SELECT /*+ ORDERED USE_NL(req lhdr lattr qpa ql) index(qpa qp_pricing_attributes_n5) */
             line.line_index,
             line.adjusted_unit_price,
             MIN(ql.operand) operand
     FROM qp_npreq_lines_tmp line,
             qp_price_req_sources req,
             qp_list_headers_b lhdr,
             qp_npreq_line_attrs_tmp lattr,
             qp_pricing_attributes qpa,
             qp_list_lines ql
     WHERE lattr.line_index = line.line_index
             AND lattr.pricing_status_code IN
                             (G_STATUS_NEW, G_STATUS_UNCHANGED)
             AND lattr.attribute_type = G_PRODUCT_TYPE
             AND lattr.context = qpa.product_attribute_context
             AND lattr.attribute = qpa.product_attribute
             AND lattr.value_from = qpa.product_attr_value
             AND qpa.excluder_flag = G_NO
             AND qpa.pricing_phase_id = 2
             AND qpa.qualification_ind = 6
             AND lattr.line_index = line.line_index
             AND req.request_type_code = line.request_type_code
             AND lhdr.list_header_id = qpa.list_header_id
             AND lhdr.active_flag = G_YES
             AND ((lhdr.currency_code IS NOT NULL AND lhdr.currency_code = line.currency_code)
                  OR
                  lhdr.currency_code IS NULL) -- optional currency
             AND lhdr.list_type_code = G_DISCOUNT_LIST_HEADER
             AND lhdr.source_system_code = req.source_system_code
             AND lhdr.gsa_indicator = G_YES
             AND trunc(line.pricing_effective_date) BETWEEN
             trunc(nvl(lhdr.start_date_active
                       , line.pricing_effective_date))
             AND trunc(nvl(lhdr.End_date_active
                           , line.pricing_effective_date))
             AND qpa.list_line_id = ql.list_line_id
             AND trunc(line.pricing_effective_date) BETWEEN
             trunc(nvl(ql.start_date_active
                       , line.pricing_effective_date))
             AND trunc(nvl(ql.End_date_active
                           , line.pricing_effective_date))
     GROUP BY line.line_index, line.adjusted_unit_price;

  -- bug 3804392 - removed the hint qp_list_headers_b_n2 and also rearranged the tables in FROM clause
  CURSOR l_attrmgr_gsa_check_cur IS
    SELECT /*+ ORDERED USE_NL(req lhdr lattr qpa ql) index(qpa qp_pricing_attributes_n5) */
             line.line_index,
             line.adjusted_unit_price,
             MIN(ql.operand) operand
     FROM qp_npreq_lines_tmp line,
             qp_price_req_sources_v req,
             qp_list_headers_b lhdr,
             qp_npreq_line_attrs_tmp lattr,
             qp_pricing_attributes qpa,
             qp_list_lines ql
     WHERE lattr.line_index = line.line_index
             AND lattr.pricing_status_code IN
                             (G_STATUS_NEW, G_STATUS_UNCHANGED)
             AND lattr.attribute_type = G_PRODUCT_TYPE
             AND lattr.context = qpa.product_attribute_context
             AND lattr.attribute = qpa.product_attribute
             AND lattr.value_from = qpa.product_attr_value
             AND qpa.excluder_flag = G_NO
             AND qpa.pricing_phase_id = 2
             AND qpa.qualification_ind = 6
             AND lattr.line_index = line.line_index
             AND req.request_type_code = line.request_type_code
             AND lhdr.list_header_id = qpa.list_header_id
             AND lhdr.active_flag = G_YES
             AND ((lhdr.currency_code IS NOT NULL AND lhdr.currency_code = line.currency_code)
                  OR
                  lhdr.currency_code IS NULL) -- optional currency
             AND lhdr.list_type_code = G_DISCOUNT_LIST_HEADER
             AND lhdr.source_system_code = req.source_system_code
             AND lhdr.gsa_indicator = G_YES
             AND trunc(line.pricing_effective_date) BETWEEN
             trunc(nvl(lhdr.start_date_active
                       , line.pricing_effective_date))
             AND trunc(nvl(lhdr.End_date_active
                           , line.pricing_effective_date))
             AND qpa.list_line_id = ql.list_line_id
             AND trunc(line.pricing_effective_date) BETWEEN
             trunc(nvl(ql.start_date_active
                       , line.pricing_effective_date))
             AND trunc(nvl(ql.End_date_active
                           , line.pricing_effective_date))
     GROUP BY line.line_index, line.adjusted_unit_price;


  l_gsa_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_gsa_sts_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  I PLS_INTEGER := 0;
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    l_gsa_line_index_tbl.DELETE;
    l_gsa_sts_text_tbl.DELETE;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Pub GSA check');

    END IF;
    -- Call GSA Check only for non-gsa customers(GSA_QUALIFIER_FLAG IS NULL)
    IF G_GSA_CHECK_FLAG = G_YES
      AND G_GSA_ENABLED_FLAG = G_YES
      AND G_GSA_INDICATOR = G_NO
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('IN GSA check attrmgr '|| G_ATTR_MGR_INSTALLED);

      END IF;
      IF G_ATTR_MGR_INSTALLED = G_NO
        THEN
        FOR GSA IN l_gsa_check_cur
          LOOP
          -- I := I + 1; bug2426025 placed the counter in the if condition
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('GSA check: line_index '|| GSA.line_index);
            QP_PREQ_GRP.engine_debug('GSA check: gsa_price '|| GSA.operand);
            QP_PREQ_GRP.engine_debug('GSA check: adj_price '|| GSA.adjusted_unit_price);
          END IF;
          IF GSA.adjusted_unit_price <= GSA.operand
            THEN
            I := I + 1;
            l_gsa_line_index_tbl(I) := GSA.line_index;
            l_gsa_sts_text_tbl(I) := GSA.operand;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('GSA violtn:lineindex '
                                       || l_gsa_line_index_tbl(I));
              QP_PREQ_GRP.engine_debug('GSA violtn:gsa price '
                                       || l_gsa_sts_text_tbl(I));
            END IF;
          END IF;
        END LOOP; --l_gsa_check_cur
      ELSE --G_ATTR_MGR_INSTALLED --not installed
        FOR GSA IN l_attrmgr_gsa_check_cur
          LOOP
          -- I := I + 1; bug2426025 placed the counter in the if condition
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('GSA check: line_index '|| GSA.line_index);
            QP_PREQ_GRP.engine_debug('GSA check: gsa_price '|| GSA.operand);
            QP_PREQ_GRP.engine_debug('GSA check: adj_price '|| GSA.adjusted_unit_price);
          END IF;
          IF GSA.adjusted_unit_price <= GSA.operand
            THEN
            I := I + 1;
            l_gsa_line_index_tbl(I) := GSA.line_index;
            l_gsa_sts_text_tbl(I) := GSA.operand;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('GSA violtn:lineindex '
                                       || l_gsa_line_index_tbl(I));
              QP_PREQ_GRP.engine_debug('GSA violtn:gsa price '
                                       || l_gsa_sts_text_tbl(I));
            END IF;
          END IF;
        END LOOP; --l_attrmgr_gsa_check_cur
      END IF; --G_ATTR_MGR_INSTALLED --not installed

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('AFTER GSA check');
      END IF;
    END IF;

    IF l_gsa_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Before GSA update '|| l_gsa_line_index_tbl.COUNT);
      END IF;
      FORALL I IN l_gsa_line_index_tbl.FIRST..l_gsa_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp
      SET pricing_status_code = G_STATUS_GSA_VIOLATION,
          pricing_status_text =
          'GSA VIOLATION - GSA PRICE '|| l_gsa_sts_text_tbl(I)
      WHERE line_index = l_gsa_line_index_tbl(I);
    END IF; --l_gsa_line_index_tbl.COUNT

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Pub GSA check completed');

    END IF;
    --GSA VIOLATION CHECK


  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('exception QP_PREQ_PUB.check gsa_violation: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.check gsa_violation: '|| SQLERRM;
  END CHECK_GSA_VIOLATION;


  PROCEDURE BACK_CALCULATION(p_line_index IN VARCHAR2
                             , p_amount_changed IN NUMBER
                             , x_back_calc_rec OUT NOCOPY BACK_CALC_REC_TYPE
                             , x_return_status OUT NOCOPY VARCHAR2
                             , x_return_status_text OUT NOCOPY VARCHAR2) IS


  CURSOR l_back_calculate_cur IS
    SELECT    ldet.created_from_list_line_id
            , ldet.line_index line_ind
            , ldet.line_detail_index
            , ldet.created_from_list_line_type
            , ldet.applied_flag
            , p_amount_changed  amount_changed
            , line.priced_quantity
            , ldet.operand_calculation_code
            , ldet.operand_value
            , ldet.adjustment_amount
            , ldet.modifier_level_code
            , line.unit_price
            , ldet.pricing_status_code
            , ldet.pricing_status_text
            , line.rounding_factor
            , ldet.calculation_code
            , ldet.line_quantity
            , ldet.created_from_list_header_id
            , ldet.created_from_list_type_code
            , ldet.price_break_type_code
            , ldet.charge_type_code
            , ldet.charge_subtype_code
            , ldet.automatic_flag
            , ldet.pricing_phase_id
            , ldet.limit_code
            , ldet.limit_text
            , ldet.pricing_group_sequence
            , ldet.list_line_no
            , ldet.calculation_code
--fix for bug 2833753
            , decode(G_BACK_CALCULATION_CODE, 'DIS',
                     decode(ldet.calculation_code, 'BACK_CALCULATE', - 10000,
                            decode(ldet.created_from_list_line_type, 'DIS',
                                   decode(ldet.applied_flag, G_YES, - 100, - 1000),
                                   decode(ldet.applied_flag, G_YES, 1000, 100))),
                     decode(ldet.calculation_code, 'BACK_CALCULATE', 10000,
                            decode(ldet.created_from_list_line_type, 'DIS',
                                   decode(ldet.applied_flag, G_YES, - 1000, - 100),
                                   decode(ldet.applied_flag, G_YES, 100, 1000)))) precedence
    FROM    qp_npreq_ldets_tmp ldet, qp_npreq_lines_tmp line
    WHERE   line.line_index = p_line_index
    AND     line.line_type_code = G_LINE_LEVEL -- sql repos
    AND     line.price_flag IN (G_YES, G_PHASE)
    AND     ldet.line_index = line.line_index
    AND     (ldet.pricing_status_code IN (G_STATUS_NEW, G_STATUS_UNCHANGED))
--commented for OC issue of duplicate manual adj in temp table
--as this cursor would pick up the engine returned manual adj
--		or ldet.process_code = G_STATUS_NEW)
    AND     ldet.created_from_list_line_type IN (G_DISCOUNT, G_SURCHARGE)
    AND     ldet.automatic_flag = G_NO
    AND     ldet.override_flag = G_YES
    AND     ldet.pricing_group_sequence IS NULL --only return null bucket manual modifiers
    AND     ldet.line_detail_index NOT IN
                    (SELECT rltd.related_line_detail_index
                     FROM qp_npreq_rltd_lines_tmp rltd
                     WHERE rltd.relationship_type_code = G_PBH_LINE
                     AND rltd.pricing_status_code = G_STATUS_NEW)
    --ORDER BY ldet.calculation_code,ldet.created_from_list_line_type,ldet.applied_flag desc;
    --ORDER BY ldet.created_from_list_line_type, precedence desc , ldet.applied_flag desc;
--fix for bug 2833753
    ORDER BY precedence;

  l_back_calc_rec back_calc_rec_type;

  l_back_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_list_line_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_operand_value_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_priced_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_amount_changed_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_back_operand_calc_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_rounding_fac_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_calc_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_line_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_list_hdr_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_list_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_price_brk_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_chrg_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_chrg_subtype_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_auto_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_back_phase_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_limit_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_limit_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_bucket_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_list_line_no_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_calculation_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_back_calc_precedence_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_back_modifier_level_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;

  BACK_CALCULATE_SUCC BOOLEAN := TRUE;
  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);
  l_adjustment_amount NUMBER := 0;
  l_operand_value NUMBER := 0;

  i NUMBER;

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    --**************************************************************
    --BACK CALCULATION ROUTINE
    --**************************************************************
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE '
                               || G_BACK_CALCULATION_CODE);


    END IF;
    OPEN l_back_calculate_cur;
    --LOOP
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE1');
    END IF;
    l_back_list_line_id_tbl.DELETE;
    l_back_line_index_tbl.DELETE;
    l_back_line_dtl_index_tbl.DELETE;
    l_back_list_line_type_tbl.DELETE;
    l_back_applied_flag_tbl.DELETE;
    l_back_amount_changed_tbl.DELETE;
    l_back_priced_qty_tbl.DELETE;
    l_back_operand_calc_code_tbl.DELETE;
    l_back_operand_value_tbl.DELETE;
    l_back_adj_amt_tbl.DELETE;
    l_back_unit_price_tbl.DELETE;
    l_back_sts_code_tbl.DELETE;
    l_back_sts_txt_tbl.DELETE;
    l_back_rounding_fac_tbl.DELETE;
    l_back_calc_code_tbl.DELETE;
    l_back_line_qty_tbl.DELETE;
    l_back_list_hdr_id_tbl.DELETE;
    l_back_list_type_tbl.DELETE;
    l_back_price_brk_type_tbl.DELETE;
    l_back_chrg_type_tbl.DELETE;
    l_back_chrg_subtype_tbl.DELETE;
    l_back_auto_flag_tbl.DELETE;
    l_back_phase_id_tbl.DELETE;
    l_back_limit_code_tbl.DELETE;
    l_back_limit_text_tbl.DELETE;
    l_back_bucket_tbl.DELETE;
    l_back_list_line_no_tbl.DELETE;
    l_back_calculation_code_tbl.DELETE;
    l_back_calc_precedence_tbl.DELETE;
    l_back_modifier_level_code_tbl.DELETE;

    FETCH l_back_calculate_cur BULK COLLECT INTO
    l_back_list_line_id_tbl,
    l_back_line_index_tbl,
    l_back_line_dtl_index_tbl,
    l_back_list_line_type_tbl,
    l_back_applied_flag_tbl,
    l_back_amount_changed_tbl,
    l_back_priced_qty_tbl,
    l_back_operand_calc_code_tbl,
    l_back_operand_value_tbl,
    l_back_adj_amt_tbl,
    l_back_modifier_level_code_tbl,
    l_back_unit_price_tbl,
    l_back_sts_code_tbl,
    l_back_sts_txt_tbl,
    l_back_rounding_fac_tbl,
    l_back_calc_code_tbl,
    l_back_line_qty_tbl,
    l_back_list_hdr_id_tbl,
    l_back_list_type_tbl,
    l_back_price_brk_type_tbl,
    l_back_chrg_type_tbl,
    l_back_chrg_subtype_tbl,
    l_back_auto_flag_tbl,
    l_back_phase_id_tbl,
    l_back_limit_code_tbl,
    l_back_limit_text_tbl,
    l_back_bucket_tbl,
    l_back_list_line_no_tbl,
    l_back_calculation_code_tbl,
    l_back_calc_precedence_tbl;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE2');
    END IF;
    --EXIT WHEN l_back_list_line_id_tbl.COUNT = 0;
    CLOSE l_back_calculate_cur;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE2.5');
    END IF;
    --DEBUG
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      AND l_back_list_line_id_tbl.COUNT>0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE3'|| l_back_list_line_id_tbl.COUNT);
      END IF;
      FOR I IN 1..l_back_list_line_id_tbl.COUNT
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE4');
          QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ADJ '
                                   || l_back_list_line_id_tbl(i) ||' line index '
                                   || l_back_line_index_tbl(i) ||' detail index '
                                   || l_back_line_dtl_index_tbl(i) ||' adj type '
                                   || l_back_list_line_type_tbl(i) ||' applied flag '
                                   || l_back_applied_flag_tbl(i) ||' adj amt '
                                   || l_back_adj_amt_tbl(i) ||' amt changed '
                                   || l_back_amount_changed_tbl(i) ||' priced qty '
                                   || l_back_priced_qty_tbl(i) ||' operand code '
                                   || l_back_operand_calc_code_tbl(i) ||' operand '
                                   || l_back_operand_value_tbl(i) ||' unit price '
                                   || l_back_unit_price_tbl(i) ||' round fac '
                                   || l_back_rounding_fac_tbl(i) ||' line_qty '
                                   || l_back_line_qty_tbl(i) || ' calculation code '
                                   || l_back_calculation_code_tbl(i) || ' precedence '
                                   || l_back_calc_precedence_tbl(i) || ' modifier level '
                                   || l_back_modifier_level_code_tbl(i));
        END IF;
      END LOOP;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE4.5');
    END IF;
    IF l_back_line_index_tbl.COUNT > 0
      THEN
      IF p_amount_changed <= 0
        THEN
        FOR I IN
          l_back_line_dtl_index_tbl.FIRST..l_back_line_dtl_index_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('forward loop '|| i);
          END IF;

          --fix for bug 2790460 to add the amount_changed to the
          --adjustment_amount if the adj
          --has been applied already and it is not back calculated
          IF (nvl(l_back_calculation_code_tbl(i), 'NULL')
              <> G_BACK_CALCULATE
              AND l_back_applied_flag_tbl(i) = G_YES) THEN
            l_back_amount_changed_tbl(i) :=
            nvl(l_back_adj_amt_tbl(i), 0) +
            l_back_amount_changed_tbl(i);
          END IF; --l_back_calculation_code_tbl(i)

          BACK_CALCULATE_PRICE(
                               l_back_operand_calc_code_tbl(i)
                               , l_back_operand_value_tbl(i)
                               , nvl(l_back_applied_flag_tbl(i), G_NO)
                               , nvl(l_back_amount_changed_tbl(i), 0)
                               , l_back_adj_amt_tbl(i)
                               , nvl(l_back_priced_qty_tbl(i), 0)
                               , nvl(l_back_unit_price_tbl(i), 0)
                               , l_back_list_line_type_tbl(i)
                               , l_adjustment_amount
                               , l_operand_value
                               , BACK_CALCULATE_SUCC
                               , l_return_status
                               , l_return_status_text);

          IF BACK_CALCULATE_SUCC
            AND l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('back cal succ '
                                       || l_adjustment_amount ||' list_line_id '
                                       || l_back_list_line_id_tbl(i) ||' operand val '
                                       || l_operand_value);

            END IF;
            l_back_calc_rec.line_detail_index :=
            l_back_line_dtl_index_tbl(i);
            l_back_calc_rec.line_index :=
            l_back_line_index_tbl(i);
            l_back_calc_rec.list_line_id :=
            l_back_list_line_id_tbl(i);
            l_back_calc_rec.list_line_type_code :=
            l_back_list_line_type_tbl(i);
            l_back_calc_rec.rounding_factor :=
            l_back_rounding_fac_tbl(i);
            l_back_calc_rec.line_quantity :=
            l_back_line_qty_tbl(i);
            l_back_calc_rec.list_header_id :=
            l_back_list_hdr_id_tbl(i);
            l_back_calc_rec.list_type_code :=
            l_back_list_type_tbl(i);
            l_back_calc_rec.price_break_type_code :=
            l_back_price_brk_type_tbl(i);
            l_back_calc_rec.charge_type_code :=
            l_back_chrg_type_tbl(i);
            l_back_calc_rec.charge_subtype_code :=
            l_back_chrg_subtype_tbl(i);
            l_back_calc_rec.automatic_flag :=
            l_back_auto_flag_tbl(i);
            l_back_calc_rec.pricing_phase_id :=
            l_back_phase_id_tbl(i);
            l_back_calc_rec.limit_code :=
            l_back_limit_code_tbl(i);
            l_back_calc_rec.limit_text :=
            l_back_limit_text_tbl(i);
            l_back_calc_rec.operand_calculation_code :=
            l_back_operand_calc_code_tbl(i);
            l_back_calc_rec.pricing_group_sequence :=
            l_back_bucket_tbl(i);
            l_back_calc_rec.list_line_no :=
            l_back_list_line_no_tbl(i);
            l_back_calc_rec.modifier_level_code :=
            l_back_modifier_level_code_tbl(i);
            --Fix for bug 2103325
            --if price is changed back to selling price
            --back calculated manual adj shd not be returned
            IF l_adjustment_amount = 0
              THEN
              l_back_calc_rec.applied_flag := G_NO;
              l_back_calc_rec.updated_flag := G_NO;
            ELSE
              l_back_calc_rec.applied_flag := G_YES;
              l_back_calc_rec.updated_flag := G_YES;
            END IF;
            l_back_calc_rec.updated_flag := G_YES;
            l_back_calc_rec.calculation_code :=
            G_BACK_CALCULATE;
            l_back_calc_rec.adjustment_amount :=
            l_adjustment_amount;
            l_back_calc_rec.operand_value :=
            l_operand_value;
            l_back_calc_rec.process_code :=
            G_STATUS_NEW;
            l_back_calc_rec.pricing_status_code :=
            G_STATUS_NEW;
            --						l_back_sts_code_tbl(i);
            l_back_calc_rec.pricing_status_text :=
            l_back_sts_txt_tbl(i);
            EXIT;
          ELSE
            NULL;
          END IF;
        END LOOP;

      ELSE --p_amount_changed is positive, then its a surcharge
        FOR I IN REVERSE
          l_back_line_dtl_index_tbl.FIRST..l_back_line_dtl_index_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('reverse loop '|| i);
          END IF;
          --fix for bug 2790460 to add the amount_changed to the
          --adjustment_amount if the adj
          --has been applied already and it is not back calculated
          IF (nvl(l_back_calculation_code_tbl(i), 'NULL')
              <> G_BACK_CALCULATE
              AND l_back_applied_flag_tbl(i) = G_YES) THEN
            l_back_amount_changed_tbl(i) :=
            nvl(l_back_adj_amt_tbl(i), 0) +
            l_back_amount_changed_tbl(i);
          END IF; --l_back_calculation_code_tbl(i)

          BACK_CALCULATE_PRICE(
                               l_back_operand_calc_code_tbl(i)
                               , l_back_operand_value_tbl(i)
                               , nvl(l_back_applied_flag_tbl(i), G_NO)
                               , nvl(l_back_amount_changed_tbl(i), 0)
                               , l_back_adj_amt_tbl(i)
                               , nvl(l_back_priced_qty_tbl(i), 0)
                               , nvl(l_back_unit_price_tbl(i), 0)
                               , l_back_list_line_type_tbl(i)
                               , l_adjustment_amount
                               , l_operand_value
                               , BACK_CALCULATE_SUCC
                               , l_return_status
                               , l_return_status_text);

          IF BACK_CALCULATE_SUCC
            AND l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('back cal succ '
                                       || l_adjustment_amount ||' list_line_id '
                                       || l_back_list_line_id_tbl(i) ||' operand val '
                                       || l_operand_value);

            END IF;
            l_back_calc_rec.line_detail_index :=
            l_back_line_dtl_index_tbl(i);
            l_back_calc_rec.line_index :=
            l_back_line_index_tbl(i);
            l_back_calc_rec.list_line_id :=
            l_back_list_line_id_tbl(i);
            l_back_calc_rec.rounding_factor :=
            l_back_rounding_fac_tbl(i);
            l_back_calc_rec.line_quantity :=
            l_back_line_qty_tbl(i);
            l_back_calc_rec.list_header_id :=
            l_back_list_hdr_id_tbl(i);
            l_back_calc_rec.list_type_code :=
            l_back_list_type_tbl(i);
            l_back_calc_rec.price_break_type_code :=
            l_back_price_brk_type_tbl(i);
            l_back_calc_rec.charge_type_code :=
            l_back_chrg_type_tbl(i);
            l_back_calc_rec.charge_subtype_code :=
            l_back_chrg_subtype_tbl(i);
            l_back_calc_rec.automatic_flag :=
            l_back_auto_flag_tbl(i);
            l_back_calc_rec.pricing_phase_id :=
            l_back_phase_id_tbl(i);
            l_back_calc_rec.limit_code :=
            l_back_limit_code_tbl(i);
            l_back_calc_rec.limit_text :=
            l_back_limit_text_tbl(i);
            l_back_calc_rec.operand_calculation_code :=
            l_back_operand_calc_code_tbl(i);
            l_back_calc_rec.pricing_group_sequence :=
            l_back_bucket_tbl(i);
            l_back_calc_rec.list_line_no :=
            l_back_list_line_no_tbl(i);
            l_back_calc_rec.modifier_level_code :=
            l_back_modifier_level_code_tbl(i);
            --Fix for bug 2103325
            --if price is changed back to selling price
            --back calculated manual adj shd not be returned
            IF l_adjustment_amount = 0
              THEN
              l_back_calc_rec.applied_flag := G_NO;
              l_back_calc_rec.updated_flag := G_NO;
            ELSE
              l_back_calc_rec.applied_flag := G_YES;
              l_back_calc_rec.updated_flag := G_YES;
            END IF;
            l_back_calc_rec.adjustment_amount :=
            l_adjustment_amount;
            l_back_calc_rec.operand_value :=
            l_operand_value;
            l_back_calc_rec.process_code :=
            G_STATUS_NEW;
            l_back_calc_rec.pricing_status_code :=
            G_STATUS_NEW;
            --						l_back_sts_code_tbl(i);
            l_back_calc_rec.pricing_status_text :=
            l_back_sts_txt_tbl(i);
            l_back_calc_rec.calculation_code :=
            G_BACK_CALCULATE;
            EXIT;
          ELSE
            NULL;
          END IF;
        END LOOP;

      END IF; --p_amount_changed

      IF BACK_CALCULATE_SUCC
        THEN
        IF l_return_status = FND_API.G_RET_STS_SUCCESS
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('back cal succ set status');
          END IF;
          x_return_status := l_return_status;
          x_return_status_text := l_return_status_text;
          x_back_calc_rec := l_back_calc_rec;
        END IF;
      ELSE
        IF l_return_status = FND_API.G_RET_STS_SUCCESS
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('back cal fail set status');
          END IF;
          x_return_status := G_BACK_CALCULATION_STS;
          x_return_status_text := 'QP_PREQ_PUB: BACK CALCULATION FAILURE ';
          x_back_calc_rec := l_back_calc_rec;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('back cal error set status');
          END IF;
          x_return_status := G_BACK_CALCULATION_STS;
          x_return_status_text := 'QP_PREQ_PUB: BACK CALCULATION ERROR '|| l_return_status_text;
          x_back_calc_rec := l_back_calc_rec;
        END IF;
      END IF;

    ELSE
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE5');
      END IF;
      x_return_status := G_BACK_CALCULATION_STS;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE6');
      END IF;
      x_return_status_text := 'QP_PREQ_PUB.BACK_CAL: NO MANUAL ADJ';
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE6.5');
      END IF;
    END IF;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE7');

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION EXCEPTION '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Error QP_PREQ_PUB.BACK_CALCULATION '|| SQLERRM;
  END BACK_CALCULATION;

  --procedure to update the line's adjusted_unit_price with unit_price
  --if the engine is called with calculate_only and there are no adjustments
  --fix for bug 2242736
  PROCEDURE UPDATE_UNIT_PRICE(x_return_status OUT NOCOPY VARCHAR2,
                              x_return_status_text OUT NOCOPY VARCHAR2) IS

  CURSOR l_check_adjustments_cur IS
    /*
SELECT line.line_index, line.unit_price, line.adjusted_unit_price
,line.line_quantity, line.priced_quantity, line.catchweight_qty,line.actual_order_quantity
, line.rounding_factor
FROM qp_npreq_lines_tmp line
WHERE line.price_flag in (G_YES, G_PHASE,G_CALCULATE_ONLY)
and line.pricing_status_code in (G_STATUS_UPDATED, G_STATUS_UNCHANGED,
				G_STATUS_GSA_VIOLATION)
and line.line_type_code = G_LINE_LEVEL
and nvl(processed_code,'0')<> G_BY_ENGINE
and (line.adjusted_unit_price <> line.unit_price
--changed this for bug 2776800 to populate order_uom_selling_price
--this means there are no adjustments and calculation has not taken place
or line.order_uom_selling_price IS NULL )
and not exists (select ldet.line_index
	from qp_npreq_ldets_tmp ldet
	where (ldet.line_index = line.line_index
	or ldet.modifier_level_code = G_ORDER_LEVEL)
	and nvl(ldet.created_from_list_type_code,'NULL') not in
		(G_PRICE_LIST_HEADER,G_AGR_LIST_HEADER)
--	and ldet.pricing_status_code = G_STATUS_NEW)
      and ldet.pricing_status_code in (G_STATUS_NEW,G_STATUS_UPDATED))  --2729744
--this is for not updating the unit_price on fg lines for prg cleanup
--as they will not have any adjustments
and line.process_status = G_STATUS_UNCHANGED
--fix for bug 2691794
and nvl(line.processed_flag,'N') <> G_FREEGOOD_LINE;
and not exists (select 'Y' from qp_npreq_lines_tmp line2
where line2.line_id = line.line_id
and line2.line_index <> line.line_index);
*/

    --fix for performance issue in bug 2928322
    --the column qualifiers_exists_flag will be populated to
    --G_CALCULATE_ONLY for all lines that went through calculation
    --we want to do this update only for those lines which
    --do not go through calculation
    SELECT line.line_index, line.unit_price, line.adjusted_unit_price
    , line.line_quantity, line.priced_quantity, line.catchweight_qty, line.actual_order_quantity
    , line.rounding_factor
    , line.updated_adjusted_unit_price
    , line.pricing_status_code
    , line.pricing_status_text
    , 0 amount_changed
    , line_unit_price
    FROM qp_npreq_lines_tmp line
    WHERE line.price_flag IN (G_YES, G_PHASE, G_CALCULATE_ONLY)
    AND line.pricing_status_code IN (G_STATUS_UPDATED, G_STATUS_UNCHANGED,
                                     G_STATUS_GSA_VIOLATION)
    AND line.line_type_code = G_LINE_LEVEL
    AND nvl(processed_code, '0') <> G_BY_ENGINE
    AND (line.adjusted_unit_price <> line.unit_price
         --changed this for bug 2776800 to populate order_uom_selling_price
         --this means there are no adjustments and calculation has not taken place
         OR line.updated_adjusted_unit_price IS NOT NULL
         OR line.order_uom_selling_price IS NULL )
    AND nvl(line.QUALIFIERS_EXIST_FLAG, G_NO) <> G_CALCULATE_ONLY
    AND nvl(line.processed_flag, 'N') <> G_FREEGOOD_LINE; -- added for bug 3116349 /*avallark*/

  l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_adj_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_uom_selling_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_priced_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_catchwt_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_actual_order_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_rounding_factor_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_upd_adj_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_amount_changed_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_pricing_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_sts_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.UPDATE_UNIT_PRICE';

  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);
  l_ord_qty_operand NUMBER;
  l_ord_qty_adj_amt NUMBER;
  i NUMBER;

  l_back_calc_ret_rec back_calc_rec_type;

  l_ldet_dtl_index QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_line_index QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_operand_value QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_adjamt QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_applied_flag QP_PREQ_GRP.FLAG_TYPE;
  l_ldet_updated_flag QP_PREQ_GRP.FLAG_TYPE;
  l_ldet_process_code QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_sts_code QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_sts_text QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_calc_code QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_ord_qty_operand QP_PREQ_GRP.NUMBER_TYPE; --3057395
  l_ldet_ord_qty_adj_amt QP_PREQ_GRP.NUMBER_TYPE; --3057395

  --[prarasto:Post Round] Start : new variables
  l_extended_selling_price_ur 	QP_PREQ_GRP.NUMBER_TYPE;
  l_adjusted_unit_price_ur	QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_selling_price_ur	QP_PREQ_GRP.NUMBER_TYPE;
  l_extended_selling_price 	QP_PREQ_GRP.NUMBER_TYPE;
  l_adjusted_unit_price		QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_selling_price		QP_PREQ_GRP.NUMBER_TYPE;
  --[prarasto:Post Round] End : new variables

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin update_unit_price');

    END IF;
    OPEN l_check_adjustments_cur;
    l_line_index_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_adj_unit_price_tbl.DELETE;
    l_ord_uom_selling_price_tbl.DELETE;
    l_line_qty_tbl.DELETE;
    l_priced_qty_tbl.DELETE;
    l_catchwt_qty_tbl.DELETE;
    l_actual_order_qty_tbl.DELETE;
    l_rounding_factor_tbl.DELETE;
    l_upd_adj_unit_price_tbl.DELETE;
    l_pricing_sts_code_tbl.DELETE;
    l_pricing_sts_text_tbl.DELETE;
    l_amount_changed_tbl.DELETE;
    l_line_unit_price_tbl.DELETE;

    l_ldet_dtl_index.DELETE;
    l_ldet_line_index.DELETE;
    l_ldet_operand_value.DELETE;
    l_ldet_adjamt.DELETE;
    l_ldet_applied_flag.DELETE;
    l_ldet_updated_flag.DELETE;
    l_ldet_process_code.DELETE;
    l_ldet_sts_code.DELETE;
    l_ldet_sts_text.DELETE;
    l_ldet_calc_code.DELETE;
    l_ldet_ord_qty_operand.DELETE; --3057395
    l_ldet_ord_qty_adj_amt.DELETE; --3057395

    FETCH l_check_adjustments_cur BULK COLLECT INTO
    l_line_index_tbl, l_unit_price_tbl, l_adj_unit_price_tbl,
    l_line_qty_tbl, l_priced_qty_tbl, l_catchwt_qty_tbl, l_actual_order_qty_tbl, l_rounding_factor_tbl,
    l_upd_adj_unit_price_tbl,
    l_pricing_sts_code_tbl,
    l_pricing_sts_text_tbl,
    l_amount_changed_tbl,
    l_line_unit_price_tbl;
    CLOSE l_check_adjustments_cur;

    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      AND l_line_index_tbl.COUNT > 0
      THEN
      FOR i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line_index '
                                   || l_line_index_tbl(i) ||' unit_price '
                                   || l_unit_price_tbl(i) ||' adj_unit_price '
                                   || l_adj_unit_price_tbl(i) ||' price_qty '
                                   || l_priced_qty_tbl(i) ||' ordqty '|| l_line_qty_tbl(i)
                                   ||' catchwt_qty '|| l_catchwt_qty_tbl(i)
                                   ||' upd_adj_unit_price '|| l_upd_adj_unit_price_tbl(i)
                                   ||' stscode '|| l_pricing_sts_code_tbl(i)
                                   ||' ststext '|| l_pricing_sts_text_tbl(i));
        END IF;
      END LOOP;
    END IF;

    IF l_line_index_tbl.COUNT > 0 THEN
      FOR i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
        LOOP

        --for bug 2926554 back calculation needs to be done here
        --if the caller has overridden the selling price
        --and if the line did not go thru calculation
        IF l_upd_adj_unit_price_tbl(i) IS NOT NULL THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('back calculation for line '
                                     || l_line_index_tbl(i));
          END IF; --l_debug

          IF G_ROUND_INDIVIDUAL_ADJ not in (G_NO_ROUND, G_POST_ROUND)
			  --[prarasto:Post Round] added check to skip rounding for Post Rounding
            AND l_rounding_factor_tbl(i) IS NOT NULL THEN
            l_upd_adj_unit_price_tbl(i) :=
            round(l_upd_adj_unit_price_tbl(i),  - 1 * l_rounding_factor_tbl(i));
          END IF; --G_ROUND_INDIVIDUAL_ADJ


          IF ((l_upd_adj_unit_price_tbl(i) -
               l_adj_unit_price_tbl(i)) <> 0) THEN
            --there are no applied adjustments as this line
            --did not go thru calculation
            l_amount_changed_tbl(i) :=
            (l_upd_adj_unit_price_tbl(i) - l_adj_unit_price_tbl(i));


            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('amt chg '|| l_amount_changed_tbl(i));
            END IF; --l_debug

            IF l_amount_changed_tbl(i) <= 0 THEN
              G_BACK_CALCULATION_CODE := 'DIS';
            ELSE
              G_BACK_CALCULATION_CODE := 'SUR';
            END IF; --l_amount_changed_tbl

            BACK_CALCULATION(l_line_index_tbl(i)
                             , l_amount_changed_tbl(i)
                             , l_back_calc_ret_rec
                             , l_return_status
                             , l_return_status_text);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              --need to do this check for bug 2833753
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('back cal succ insert rec ');
              END IF; --l_debug

              l_adj_unit_price_tbl(i) := l_upd_adj_unit_price_tbl(i);

              -- Ravi
              --this procedure is called to calculate the
              --selling_price,adjustment_amount and operand in ordered_qty
              --which is the line_quantity on lines_tmp
              -- Ravi bug# 2745337-divisor by zero
              IF (l_line_qty_tbl(i) <> 0
                  OR l_back_calc_ret_rec.modifier_level_code = G_ORDER_LEVEL) THEN
                IF (l_debug = FND_API.G_TRUE) THEN
                  QP_PREQ_GRP.engine_debug('Before GET_ORDERQTY_VALUES #6');
                END IF; --l_debug
                GET_ORDERQTY_VALUES(p_ordered_qty => l_line_qty_tbl(i),
                                    p_priced_qty => l_priced_qty_tbl(i),
                                    p_catchweight_qty => l_catchwt_qty_tbl(i),
                                    p_actual_order_qty => l_actual_order_qty_tbl(i),
                                    p_operand => l_back_calc_ret_rec.operand_value,
                                    p_adjustment_amt => l_back_calc_ret_rec.adjustment_amount,
                                    p_unit_price => l_unit_price_tbl(i),
                                    p_adjusted_unit_price => l_adj_unit_price_tbl(i),
                                    p_operand_calculation_code => l_back_calc_ret_rec.operand_calculation_code,
                                    p_input_type => 'OPERAND',
                                    x_ordqty_output1 => l_ord_qty_operand,
                                    x_ordqty_output2 => l_ord_qty_adj_amt,
                                    x_return_status => x_return_status,
                                    x_return_status_text => x_return_status_text);
              ELSE --l_line_qty_tbl(i)
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('Ordered Qty #3 : ' || l_line_qty_tbl(i));
                  QP_PREQ_GRP.engine_debug('OPERAND Ordered Qty is 0 or modifier level code is not ORDER');
                END IF; --l_debug
                l_ord_qty_operand := 0;
                l_ord_qty_adj_amt := 0;
              END IF; --l_line_qty_tbl(i)

              -- End Ravi

              --fix for bug 2146050 to round adjustment amt
              IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
                AND l_rounding_factor_tbl(i) IS NOT NULL THEN
                l_back_calc_ret_rec.adjustment_amount :=
                round(l_back_calc_ret_rec.adjustment_amount,
                      - 1 * l_rounding_factor_tbl(i));
                l_ord_qty_adj_amt := round(l_ord_qty_adj_amt,
                                           - 1 * l_rounding_factor_tbl(i));
              END IF; --G_ROUND_INDIVIDUAL_ADJ

              --load the l_back_calc_ret_rec to plsqltbl to do bulk update
              l_ldet_dtl_index(l_ldet_dtl_index.COUNT + 1) :=
              l_back_calc_ret_rec.line_detail_index;
              l_ldet_line_index(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.line_index;
              l_ldet_operand_value(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.operand_value;
              l_ldet_adjamt(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.adjustment_amount;
              l_ldet_applied_flag(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.applied_flag;
              l_ldet_updated_flag(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.updated_flag;
              l_ldet_process_code(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.process_code;
              l_ldet_sts_code(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.pricing_status_code;
              l_ldet_sts_text(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.pricing_status_text;
              l_ldet_calc_code(l_ldet_dtl_index.COUNT) :=
              l_back_calc_ret_rec.calculation_code;
              l_ldet_ord_qty_operand(l_ldet_dtl_index.COUNT) :=
              l_ord_qty_operand; --3057395
              l_ldet_ord_qty_adj_amt(l_ldet_dtl_index.COUNT) :=
              l_ord_qty_adj_amt; --3057395

            ELSE --l_ret_status
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('back cal fail no insert rec');
              END IF; --l_debug
              l_pricing_sts_code_tbl(i) := l_return_status;
              l_pricing_sts_text_tbl(i) := l_return_status_text;
            END IF; --ret_status
          END IF; --l_upd_adj_unit_price_tbl - l_adj_unit
        ELSE
          --if not then the line has no adjustments and the
          --selling price needs to be replaced as the selling price
          l_adj_unit_price_tbl(i) := l_unit_price_tbl(i);
        END IF; --l_upd_adj_unit_price_tbl IS NOT NULL

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('end back calc for line '
                                   ||' unit price '|| l_unit_price_tbl(i)
                                   ||' adj_unit_price '|| l_adj_unit_price_tbl(i)
                                   ||' upd_adj_unit_price '|| l_upd_adj_unit_price_tbl(i));
        END IF; --l_debug

        --fix for bug 2812738
        --changes to calculate the order_uom_selling_price
        IF (l_line_qty_tbl(i) <> 0
            OR l_back_calc_ret_rec.modifier_level_code =
            G_ORDER_LEVEL) THEN
          IF (l_debug = FND_API.G_TRUE) THEN
            QP_PREQ_GRP.engine_debug('Before GET_ORDERQTY_VALUES #6.5');
          END IF; --l_debug
          GET_ORDERQTY_VALUES(p_ordered_qty => l_line_qty_tbl(i),
                              p_priced_qty => l_priced_qty_tbl(i),
                              p_catchweight_qty => l_catchwt_qty_tbl(i),
                              p_actual_order_qty => l_actual_order_qty_tbl(i),
                              p_unit_price => l_unit_price_tbl(i),
                              p_adjusted_unit_price => l_adj_unit_price_tbl(i),
                              p_line_unit_price => l_line_unit_price_tbl(i),
                              p_input_type => 'SELLING_PRICE',
                              x_ordqty_output1 => l_line_unit_price_tbl(i),
                              x_ordqty_output2 => l_ord_uom_selling_price_tbl(i),
                              x_return_status => x_return_status,
                              x_return_status_text => x_return_status_text);
        ELSE --ordered_qty
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Ordered Qty #2.5 : '
                                     || l_line_qty_tbl(i));
            QP_PREQ_GRP.engine_debug('SELLING PRICE Ordered Qty is '
                                     ||'0 or modifier level code is not ORDER');
          END IF; --l_debug
          l_line_unit_price_tbl(i) := 0;
          l_ord_uom_selling_price_tbl(i) := 0;
        END IF; --ordered_qty

        --round the selling price if ROUND_INDIVIDUAL_ADJ
        --profile is N in this case the adjustment_amt will not be rounded

          --===[prarasto:Post Round] Start : Calculate rounded values ==--
          l_adjusted_unit_price_ur(i) := l_adj_unit_price_tbl(i);
          l_unit_selling_price_ur(i) := l_ord_uom_selling_price_tbl(i);

	IF (G_ROUND_INDIVIDUAL_ADJ not in ( G_NO_ROUND , G_POST_ROUND )) AND (l_rounding_factor_tbl(i) is not null)
	THEN
          IF (l_catchwt_qty_tbl(i) is null) and (l_actual_order_qty_tbl(i) is not null) THEN
            l_extended_selling_price_ur(i) :=  round(l_unit_selling_price_ur(i), - 1 * l_rounding_factor_tbl(i))
	    					* l_actual_order_qty_tbl(i);
          ELSE
            l_extended_selling_price_ur(i) := round(l_unit_selling_price_ur(i), - 1 * l_rounding_factor_tbl(i))
	    					* l_line_qty_tbl(i);
          END IF;
	ELSE
          IF (l_catchwt_qty_tbl(i) is null) and (l_actual_order_qty_tbl(i) is not null) THEN
            l_extended_selling_price_ur(i) := l_unit_selling_price_ur(i) * l_actual_order_qty_tbl(i);
          ELSE
            l_extended_selling_price_ur(i) := l_unit_selling_price_ur(i) * l_line_qty_tbl(i);
          END IF;
	END IF;


          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('roundingfac to round sellingprice: '
                                     || l_rounding_factor_tbl(i));
          END IF; --l_debug

          IF (G_ROUND_INDIVIDUAL_ADJ = G_NO_ROUND) or (l_rounding_factor_tbl(i) is null) THEN
--            l_adj_unit_price_tbl(i) := l_adjusted_unit_price_ur(i);
            l_unit_selling_price(i) := l_unit_selling_price_ur(i);
            l_extended_selling_price(i) := l_extended_selling_price_ur(i);
          ELSE
            l_adj_unit_price_tbl(i) := round(l_adjusted_unit_price_ur(i), - 1 * l_rounding_factor_tbl(i));
            l_line_unit_price_tbl(i) := round(l_line_unit_price_tbl(i),  - 1 * l_rounding_factor_tbl(i));
            l_unit_selling_price(i) := round(l_unit_selling_price_ur(i),  - 1 * l_rounding_factor_tbl(i));
            l_extended_selling_price(i) := round(l_extended_selling_price_ur(i),  - 1 * l_rounding_factor_tbl(i));
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
	   QP_PREQ_GRP.engine_debug('Extended selling price unrounded : '||l_extended_selling_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Extended selling price : '||l_extended_selling_price(i));
	   QP_PREQ_GRP.engine_debug('Unit selling price unrounded : '||l_unit_selling_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Unit selling price : '||l_unit_selling_price(i));
	   QP_PREQ_GRP.engine_debug('Adjusted unit price unrounded : '||l_adjusted_unit_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Adjusted unit price : '||l_adj_unit_price_tbl(i));
          END IF; --l_debug
          --===[prarasto:Post Round] End : Calculate rounded values ==--

        /*
         IF (l_catchwt_qty_tbl(i) IS NOT NULL) THEN
          l_ord_uom_selling_price_tbl(i) := (nvl(l_adj_unit_price_tbl(i),l_unit_price_tbl(i)) *
          (l_priced_qty_tbl(i)/ l_actual_order_qty_tbl(i))* (l_catchwt_qty_tbl(i)/l_line_qty_tbl(i)));
         ELSIF (l_actual_order_qty_tbl(i) IS NOT NULL) THEN
          l_ord_uom_selling_price_tbl(i) := (nvl(l_adj_unit_price_tbl(i),l_unit_price_tbl(i)) *
          (l_priced_qty_tbl(i)/ l_actual_order_qty_tbl(i)));
         ELSE
          l_ord_uom_selling_price_tbl(i) := (nvl(l_adj_unit_price_tbl(i),l_unit_price_tbl(i)) *
          (l_priced_qty_tbl(i)/ l_line_qty_tbl(i)));
         END IF;

         IF l_rounding_factor_tbl(i) IS NOT NULL and G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND THEN
          l_ord_uom_selling_price_tbl(i) := round(l_ord_uom_selling_price_tbl(i), (-1 * l_rounding_factor_tbl(i)));
         END IF;--l_rounding_factor_tbl
*/

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line_index '
                                   || l_line_index_tbl(i) ||' ord_uom_selling_price '
                                   || l_ord_uom_selling_price_tbl(i));
        END IF; --l_debug

      END LOOP; --i
    END IF; --l_line_index_tbl.count

    --added for bug 2926554
    IF l_ldet_dtl_index.COUNT > 0
      THEN
      FORALL i IN l_ldet_dtl_index.first..l_ldet_dtl_index.last
      UPDATE qp_npreq_ldets_tmp ldet
      SET ldet.operand_value = l_ldet_operand_value(i)
          , ldet.adjustment_amount = l_ldet_adjamt(i)
          , ldet.applied_flag = l_ldet_applied_flag(i)
          , ldet.updated_flag = l_ldet_updated_flag(i)
          , ldet.process_code = l_ldet_process_code(i)
          , ldet.pricing_status_code = l_ldet_sts_code(i)
          , ldet.pricing_status_text = l_ldet_sts_text(i)
          , ldet.calculation_code = l_ldet_calc_code(i)
          , ldet.order_qty_operand = l_ldet_ord_qty_operand(i) --3057395
          , ldet.order_qty_adj_amt = l_ldet_ord_qty_adj_amt(i) --3057395
      WHERE ldet.line_detail_index = l_ldet_dtl_index(i)
      AND ldet.line_index = l_ldet_line_index(i);

    END IF; --l_ldet_dtl_index.COUNT


    IF l_line_index_tbl.COUNT > 0
      THEN

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('unit price needs to be updated');
      END IF;

      FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp
      SET    adjusted_unit_price = l_adj_unit_price_tbl(i)
             --, adjusted_unit_price_ur = l_adjusted_unit_price_ur(i)         --[prarasto:Post Round], [julin/postround] redesign
             , line_unit_price = l_line_unit_price_tbl(i)
             , pricing_status_code = nvl(l_pricing_sts_code_tbl(i), G_STATUS_UPDATED) /* bug 3248475 */
             , pricing_status_text = l_pricing_sts_text_tbl(i)  /* bug 3248475 */
             , order_uom_selling_price = l_unit_selling_price(i)       --[prarasto:Post Round]
             --, order_uom_selling_price_ur = l_unit_selling_price_ur(i) --[prarasto:Post Round], [julin/postround] redesign
             , extended_price = l_extended_selling_price(i)            --[prarasto:Post Round]
             --, extended_selling_price_ur = l_extended_selling_price_ur(i) --[prarasto:Post Round], [julin/postround] redesign
      WHERE line_index = l_line_index_tbl(i)
--		and (l_adj_unit_price_tbl(i) <> l_unit_price_tbl(i)     --3524967
      AND (adjusted_unit_price <> unit_price --3524967
           --changes for bug 2776800 to populate order_uom_selling_price
           OR updated_adjusted_unit_price IS NOT NULL
           OR order_uom_selling_price IS NULL);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG(x_return_status_text);
      END IF;
  END UPDATE_UNIT_PRICE;



  --Procedure to update the line status to 'UPDATED' if there are
  --any lines with adjustments with process_code 'UPDATED'/'N'

  PROCEDURE Update_Line_Status(x_return_status OUT NOCOPY VARCHAR2,
                               x_return_status_text OUT NOCOPY VARCHAR2) IS

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Update_Line_Status:calculate_flag '|| G_CALCULATE_FLAG);

    END IF;

    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
      /* Modified where clause as per suggestion of spgopal for bug 3401941 */
      UPDATE qp_npreq_lines_tmp line
              SET pricing_status_code = G_STATUS_UPDATED
              --for bug 2812738 not to update if back_calc_error/gsa_violatn
              WHERE line.pricing_status_code = G_STATUS_UNCHANGED
--fix for bug 3425569 where frozen lines were set to status updated
--and processing constraints cause error in OM when they update frozen lines
              AND (line.price_flag IN (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                   OR nvl(line.processed_code, '0') = QP_PREQ_PUB.G_BY_ENGINE)
              AND (G_CALCULATE_FLAG = G_CALCULATE_ONLY

                   OR  EXISTS (SELECT 'Y' FROM qp_npreq_ldets_tmp ldet
                               WHERE ldet.line_index = line.line_index
                               AND ldet.pricing_status_code = G_STATUS_NEW
                               AND ldet.applied_flag = G_YES -- bug 6111048/6328486
                               AND ldet.process_code IN
                               (G_STATUS_NEW, G_STATUS_UPDATED))
                   --for bug#3224658
                   OR  EXISTS (SELECT 'Y' FROM qp_npreq_ldets_tmp
                               WHERE modifier_level_code = 'ORDER'
                               AND applied_flag = 'YES' -- bug 6628324
                               AND pricing_status_code = G_STATUS_NEW
                               AND process_code IN (G_STATUS_NEW, G_STATUS_UPDATED))
                   OR EXISTS (SELECT 'Y' FROM oe_price_adjustments adj
                              WHERE line.line_type_code = G_LINE_LEVEL
                              AND line.line_id = adj.line_id
                              AND adj.applied_flag = G_YES
                              AND adj.list_line_id NOT IN (SELECT ldet.created_from_list_line_id FROM qp_npreq_ldets_tmp ldet
                                                           WHERE ldet.line_index = line.line_index
                                                           AND ldet.pricing_status_code = G_STATUS_NEW
                                                           AND ldet.process_code IN (G_STATUS_NEW, G_STATUS_UPDATED)
                                                           AND ldet.applied_flag = G_YES))
                   OR EXISTS (SELECT 'Y' FROM oe_price_adjustments adj
                              WHERE line.line_type_code = G_ORDER_LEVEL
                              AND line.line_id = adj.header_id
                              AND adj.applied_flag = G_YES
                              AND adj.list_line_id NOT IN (SELECT ldet.created_from_list_line_id FROM qp_npreq_ldets_tmp ldet
                                                           WHERE ldet.line_index = line.line_index
                                                           AND ldet.pricing_status_code = G_STATUS_NEW
                                                           AND ldet.process_code IN (G_STATUS_NEW, G_STATUS_UPDATED)
                                                           AND ldet.applied_flag = G_YES))
                   );
    ELSE
      UPDATE qp_int_lines line
              SET pricing_status_code = G_STATUS_UPDATED
              --for bug 2812738 not to update if back_calc_error/gsa_violatn
              WHERE line.pricing_status_code = G_STATUS_UNCHANGED
--fix for bug 3425569 where frozen lines were set to status updated
--and processing constraints cause error in OM when they update frozen lines
              AND (line.price_flag IN (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                   OR nvl(line.processed_code, '0') = QP_PREQ_PUB.G_BY_ENGINE)
              AND (G_CALCULATE_FLAG = G_CALCULATE_ONLY

                   OR  EXISTS (SELECT 'Y' FROM qp_int_ldets ldet
                               WHERE ldet.line_index = line.line_index
                               AND ldet.pricing_status_code = G_STATUS_NEW
                               AND ldet.applied_flag = G_YES -- bug 6111048/6328486
                               AND ldet.process_code IN
                               (G_STATUS_NEW, G_STATUS_UPDATED))
                   --for bug#3224658
                   OR  EXISTS (SELECT 'Y' FROM qp_int_ldets
                               WHERE modifier_level_code = 'ORDER'
                               AND applied_flag = 'YES' -- bug 6628324
                               AND pricing_status_code = G_STATUS_NEW
                               AND process_code IN (G_STATUS_NEW, G_STATUS_UPDATED))
                   OR EXISTS (SELECT 'Y' FROM oe_price_adjustments adj
                              WHERE line.line_type_code = G_LINE_LEVEL
                              AND line.line_id = adj.line_id
                              AND adj.applied_flag = G_YES
                              AND adj.list_line_id NOT IN (SELECT ldet.created_from_list_line_id FROM qp_int_ldets ldet
                                                           WHERE ldet.line_index = line.line_index
                                                           AND ldet.pricing_status_code = G_STATUS_NEW
                                                           AND ldet.process_code IN (G_STATUS_NEW, G_STATUS_UPDATED)
                                                           AND ldet.applied_flag = G_YES))
                   OR EXISTS (SELECT 'Y' FROM oe_price_adjustments adj
                              WHERE line.line_type_code = G_ORDER_LEVEL
                              AND line.line_id = adj.header_id
                              AND adj.applied_flag = G_YES
                              AND adj.list_line_id NOT IN (SELECT ldet.created_from_list_line_id FROM qp_int_ldets ldet
                                                           WHERE ldet.line_index = line.line_index
                                                           AND ldet.pricing_status_code = G_STATUS_NEW
                                                           AND ldet.process_code IN (G_STATUS_NEW, G_STATUS_UPDATED)
                                                           AND ldet.applied_flag = G_YES))
                   );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in QP_PREQ_PUB.Update_Line_Status: '|| SQLERRM;
  END Update_Line_Status;

  --overloaded for QP.G reqts
  --this is used in performance code path called from QPXVCLNB.fetch_adjustments

  PROCEDURE CALCULATE_PRICE(p_request_type_code IN VARCHAR2,
                            p_rounding_flag IN VARCHAR2,
                            p_view_name IN VARCHAR2,
                            p_event_code IN VARCHAR2,
                            p_adj_tbl IN QP_PREQ_PUB.ADJ_TBL_TYPE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_text OUT NOCOPY VARCHAR2) IS

  --fix for bug 2515762 to print in debug the rltd info
  CURSOR l_rltd_lines_cur IS
    SELECT line_index,
            related_line_index,
            line_detail_index,
            related_line_detail_index,
            relationship_type_code,
            list_line_id,
            related_list_line_id,
            related_list_line_type,
            operand_calculation_code,
            operand,
            pricing_group_sequence,
            setup_value_from,
            setup_value_to,
            qualifier_value
    FROM qp_npreq_rltd_lines_tmp
    WHERE pricing_status_code = G_STATUS_NEW;

  CURSOR l_net_amount_flag_cur (p_list_line_id NUMBER) IS
    SELECT net_amount_flag
    FROM qp_list_lines
    WHERE list_line_id = p_list_line_id;


  Calculate_Exc EXCEPTION;


  --back_calculate BOOLEAN := FALSE;
  back_calculate_succ BOOLEAN := FALSE;
  line_change BOOLEAN := FALSE;

  --l_amount_changed NUMBER :=0;
  l_adjustment_amount NUMBER := 0;
  l_operand_value NUMBER := 0;
  l_back_calculate_start_type VARCHAR2(30);
  --l_prev_line_index NUMBER :=0;
  l_prev_line_index NUMBER := - 9999; -- SL_latest 2892848
  l_1st_bucket VARCHAR2(1) := 'N'; -- SL_latest
  l_list_price NUMBER := 0;
  --l_adjusted_price NUMBER :=0; -- 2892848
  --l_prev_bucket NUMBER :=0; -- 2892848
  l_adjusted_price NUMBER := NULL; --2892848 so we can nvl(l_adjusted_price, unit_price) when assign l_sub_total_price
  l_prev_bucket NUMBER := - 9999; --2892848
  l_line_adjusted_price NUMBER := 0;
  l_sub_total_price NUMBER := NULL; -- SL_more
  l_return_adjustment NUMBER := 0;
  l_sign NUMBER := 1;
  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);
  l_routine VARCHAR2(50) := 'Routine :QP_PREQ_PUB.Calculate_price ';
  --l_processed_flag VARCHAR2(1);
  --l_pbh_request_qty NUMBER :=0;

  --l_pbh_net_adj_amount NUMBER := 0; -- 2892848 no need
  --l_pbh_prev_net_adj_amount NUMBER := 0; -- 2892848 no need

  i PLS_INTEGER;
  j PLS_INTEGER;
  x PLS_INTEGER := 0; -- 3126019
  y PLS_INTEGER;
  l_tbl_index PLS_INTEGER;

  l_adj_tbl QP_PREQ_PUB.adj_tbl_type;
  l_frt_tbl FRT_CHARGE_TBL;
  l_back_calc_ret_rec back_calc_rec_type;

  l_ldet_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_list_hdr_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_list_line_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_operand_value_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_ldet_updated_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_ldet_pricing_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_process_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_pricing_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_price_break_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_line_quantity_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_operand_calc_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_pricing_grp_seq_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_list_type_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_limit_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_limit_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_list_line_no_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_charge_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_charge_subtype_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_automatic_flag_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_pricing_phase_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_modifier_level_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_is_max_frt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_calc_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_ldet_ordqty_operand_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ldet_ordqty_adjamt_tbl QP_PREQ_GRP.NUMBER_TYPE;


  l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_adj_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_amount_changed_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ordered_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_priced_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_catchweight_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_actual_order_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_pricing_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_process_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_upd_adj_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_processed_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_rounding_factor_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_selling_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ordqty_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ntamt_adj_unit_price QP_PREQ_GRP.NUMBER_TYPE; -- 3126019
  l_calc_quantity NUMBER;

  --[prarasto:Post Round] Start : new variables
  l_extended_selling_price_ur 	QP_PREQ_GRP.NUMBER_TYPE;
  l_adjusted_unit_price_ur	QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_selling_price_ur	QP_PREQ_GRP.NUMBER_TYPE;
  l_extended_selling_price 	QP_PREQ_GRP.NUMBER_TYPE;
  l_adjusted_unit_price		QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_selling_price		QP_PREQ_GRP.NUMBER_TYPE;
  --[prarasto:Post Round] End : new variables

  l_back_calc_dtl_index QP_PREQ_GRP.NUMBER_TYPE;
  l_back_calc_adj_amt QP_PREQ_GRP.NUMBER_TYPE;
  l_back_calc_plsql_tbl_index QP_PREQ_GRP.NUMBER_TYPE;

  l_back_calc_dtl_ind NUMBER;
  l_back_calc_adj_amount NUMBER;
  l_back_calc_plsql_index NUMBER;
  --begin 2388011
  l_req_value_per_unit NUMBER; --2388011 priya added this variable
  l_total_value NUMBER; --group_value --2388011 priya added this variable
  l_bucketed_adjustment NUMBER; --2388011 priya added this variable
  --end 2388011

  l_pricing_attribute VARCHAR2(240);

  --added to calculate order level adjustments' adj amt
  l_ord_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_qty_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_qty_operand_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_qty_adj_amt NUMBER := 0;
  l_ord_qty_operand NUMBER := 0;

  -- begin 2892848, net amount
  l_qualifier_value NUMBER := NULL; -- to qualify PBH
  s PLS_INTEGER := 0; -- counter for l_line_bucket_detail_tbl
  l_lg_adj_amt NUMBER := NULL; -- 2892848
  l_prev_lg_adj_amt NUMBER := 0;

  /* SL_latest 2892848
-- for linegroup
TYPE bucket_adj_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_bucket_adj_amt_tbl bucket_adj_amt_tbl;

-- for line level
TYPE bucket_index_adj_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_bucket_index_adj_tbl bucket_index_adj_tbl;

TYPE prev_bucket_index_adj_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_prev_bucket_index_adj_tbl prev_bucket_index_adj_tbl;
-- end 2892848
*/

  --begin SL_latest
  CURSOR l_net_mod_index_cur(p_list_line_id NUMBER) IS
    SELECT DISTINCT ldet.line_index
    FROM qp_npreq_ldets_tmp ldet
    WHERE ldet.created_from_list_line_id = p_list_line_id
    AND pricing_status_code IN (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED);

  l_line_bucket_amt NUMBER := 0;
  l_lg_net_amt NUMBER := 0;
  l_prev_qty NUMBER := 0;
  l_applied_req_value_per_unit NUMBER := 0;
  l_prod_line_bucket_amt NUMBER := 0;
  l_lg_prod_net_amt NUMBER := 0;

  -- record bucketed USP*qtyfor each line_index upon bucket change
  TYPE bucket_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_bucket_amt_tbl bucket_amt_tbl;
  l_prev_bucket_amt_tbl bucket_amt_tbl;

  -- hash table of list_line_id and its corresponding lg_net_amt
  TYPE mod_lg_net_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_mod_lg_net_amt_tbl mod_lg_net_amt_tbl;
  l_mod_lg_prod_net_amt_tbl mod_lg_net_amt_tbl; -- [julin/4112395/4220399]

  -- end SL_latest 2892848

  l_adj_exists_in_tmp_tbl VARCHAR2(1) := 'N'; -- bug 3618464
  L_LINE_INDEX_STR VARCHAR2(2000); -- bug 3618464
  L_INSTR_POS NUMBER; -- bug 3618464
  L_INDEX NUMBER; -- bug 3618464

  -- [julin/3265308] net amount calculation 'P', match product only.
  -- given a line line id, find the product attribute and context for
  -- the modifier and match all request lines with that context/attr
  -- pair.  exclude logic included.  price_flag clause included to
  -- ignore free goods.
  CURSOR l_prod_attr_info(p_list_line_id NUMBER) IS
    SELECT DISTINCT qla.line_index, ql.priced_quantity, ql.unit_price
    FROM qp_preq_line_attrs_tmp qla, qp_pricing_attributes qpa, qp_preq_lines_tmp ql
    WHERE qpa.list_line_id = p_list_line_id
    AND qla.context = qpa.product_attribute_context
    AND qla.attribute = qpa.product_attribute
    AND qla.value_from = qpa.product_attr_value
    AND qla.line_index = ql.line_index
    AND ql.price_flag <> G_PHASE
    AND ql.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                   QP_PREQ_PUB.G_STATUS_GSA_VIOLATION,
                                   QP_PREQ_PUB.G_STATUS_UNCHANGED)
    AND NOT EXISTS (SELECT qla2.line_index
                    FROM qp_preq_line_attrs_tmp qla2, qp_pricing_attributes qpa2
                    WHERE qpa2.list_line_id = p_list_line_id
                    AND qpa2.excluder_flag = G_YES
                    AND qla2.line_index = qla.line_index
                    AND qla2.context = qpa2.product_attribute_context
                    AND qla2.attribute = qpa2.product_attribute
                    AND qla2.value_from = qpa2.product_attr_value);

  l_netamt_flag VARCHAR2(1);
  l_bucketed_flag VARCHAR2(1);

  -- [julin/5025231]
  l_line_ind_ind_lookup_tbl QP_PREQ_GRP.NUMBER_TYPE;

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('begin calculate price 1');

      QP_PREQ_GRP.engine_debug('Display related records ');
    END IF;
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      THEN
      --fix for bug 2515762 to print in debug the rltd info
      FOR cl IN l_rltd_lines_cur
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('related records with status N '
                                   ||' line_dtl_index '|| cl.line_detail_index
                                   ||' rltd_line_dtl_index '|| cl.related_line_detail_index
                                   ||' line_index '|| cl.line_index
                                   ||' rltd_line_index '|| cl.related_line_index
                                   ||' list_line_id '|| cl.list_line_id
                                   ||' rltd_list_line_id '|| cl.related_list_line_id
                                   ||' rltd_list_line_type '|| cl.related_list_line_type
                                   ||' operand '|| cl.operand
                                   ||' operator '|| cl.operand_calculation_code
                                   ||' bucket '|| cl.pricing_group_sequence
                                   ||' setval_from '|| cl.setup_value_from
                                   ||' setval_to '|| cl.setup_value_to
                                   ||' qual_value '|| cl.qualifier_value);
        END IF;
      END LOOP;
    END IF;

    --reset order lvl adjustments' adj amt
    l_ord_dtl_index_tbl.DELETE;
    l_ord_adj_amt_tbl.DELETE;
    l_ord_qty_adj_amt_tbl.DELETE;
    l_ord_qty_operand_tbl.DELETE;

    G_ldet_plsql_index_tbl.DELETE;

    l_adj_tbl.DELETE;
    l_frt_tbl.DELETE;
    l_line_index_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_adj_unit_price_tbl.DELETE;
    l_amount_changed_tbl.DELETE;
    l_ordered_qty_tbl.DELETE;
    l_line_unit_price_tbl.DELETE;
    l_line_priced_qty_tbl.DELETE;
    l_catchweight_qty_tbl.DELETE;
    l_actual_order_qty_tbl.DELETE;
    l_pricing_sts_code_tbl.DELETE;
    l_pricing_sts_txt_tbl.DELETE;
    l_process_code_tbl.DELETE;
    l_upd_adj_unit_price_tbl.DELETE;
    l_processed_flag_tbl.DELETE;
    l_rounding_factor_tbl.DELETE;
    l_ordqty_unit_price_tbl.DELETE;
    l_ordqty_selling_price_tbl.DELETE;

    l_ldet_line_dtl_index_tbl.DELETE;
    l_ldet_line_index_tbl.DELETE;
    l_ldet_list_hdr_id_tbl.DELETE;
    l_ldet_list_line_id_tbl.DELETE;
    l_ldet_list_line_type_tbl.DELETE;
    l_ldet_operand_value_tbl.DELETE;
    l_ldet_adj_amt_tbl.DELETE;
    l_ldet_applied_flag_tbl.DELETE;
    l_ldet_updated_flag_tbl.DELETE;
    l_ldet_pricing_sts_code_tbl.DELETE;
    l_ldet_process_code_tbl.DELETE;
    l_ldet_pricing_sts_txt_tbl.DELETE;
    l_ldet_price_break_type_tbl.DELETE;
    l_ldet_line_quantity_tbl.DELETE;
    l_ldet_operand_calc_tbl.DELETE;
    l_ldet_pricing_grp_seq_tbl.DELETE;
    l_ldet_list_type_code_tbl.DELETE;
    l_ldet_limit_code_tbl.DELETE;
    l_ldet_limit_text_tbl.DELETE;
    l_ldet_list_line_no_tbl.DELETE;
    l_ldet_charge_type_tbl.DELETE;
    l_ldet_charge_subtype_tbl.DELETE;
    l_ldet_updated_flag_tbl.DELETE;
    l_ldet_automatic_flag_tbl.DELETE;
    l_ldet_pricing_phase_id_tbl.DELETE;
    l_ldet_modifier_level_tbl.DELETE;
    l_ldet_is_max_frt_tbl.DELETE;
    l_ldet_calc_code_tbl.DELETE;
    l_ldet_ordqty_operand_tbl.DELETE;
    l_ldet_ordqty_adjamt_tbl.DELETE;

    l_back_calc_dtl_index.DELETE;
    l_back_calc_adj_amt.DELETE;
    l_back_calc_plsql_tbl_index.DELETE;

    --l_bucket_adj_amt_tbl.delete; --2892848
    --l_bucket_index_adj_tbl.delete; --2892848
    --l_prev_bucket_index_adj_tbl.delete; --2892848
    l_bucket_amt_tbl.DELETE; -- 2892848 SL_latest
    l_prev_bucket_amt_tbl.DELETE;
    l_mod_lg_net_amt_tbl.DELETE; -- 2892848 SL_latest
    l_mod_lg_prod_net_amt_tbl.DELETE; --  -- [julin/4112395/4220399]
    l_ntamt_adj_unit_price.DELETE; --3126019

    l_adj_tbl := p_adj_tbl;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('begin calculate price 2');
      QP_PREQ_GRP.engine_debug('SL, this direct insert path'); -- 2892848

    END IF;
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('begin calculate price 3');
      END IF;
      FOR z IN 1..l_adj_tbl.COUNT
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Processing Adjustments:
                                   line index '|| l_adj_tbl(z).line_ind ||' '||
                                   ' line dtl index '|| l_adj_tbl(z).line_detail_index ||
                                   ' pricing_status '|| l_adj_tbl(z).pricing_status_code ||
                                   ' ldet rec '|| l_adj_tbl(z).is_ldet_rec ||
                                   ' list line id '|| l_adj_tbl(z).created_from_list_line_id ||  -- 2892848
                                   ' bucket '|| l_adj_tbl(z).pricing_group_sequence); --2892848
        END IF;
        --' bucket '||l_adj_tbl(z).pricing_group_sequence);
      END LOOP; --z l_adj_tbl
    END IF;

    --        back_calculate := false;
    --      line_change := true;
    --      l_prev_line_index := fnd_api.g_miss_num;
    i := l_ldet_line_dtl_index_tbl.COUNT;
    j := l_adj_tbl.COUNT;
    x := l_line_index_tbl.COUNT;
    --l_pbh_net_adj_amount := 0;  -- 2892848 no need
    --l_pbh_prev_net_adj_amount := 0; -- 2892848 no need

    j := l_adj_tbl.FIRST;
    WHILE J IS NOT NULL
      LOOP

      -- begin 2892848
      -- obtain net_adj_amount_flag from qp_list_lines table if null,
      -- since it may not be passed from calling application
      IF l_adj_tbl(j).net_amount_flag IS NULL THEN -- get it from setup just in case
        OPEN l_net_amount_flag_cur(l_adj_tbl(j).created_from_list_line_id);
        FETCH l_net_amount_flag_cur INTO l_adj_tbl(j).net_amount_flag;
        CLOSE l_net_amount_flag_cur;
      END IF;
      -- end 2892848

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Processing Line: Line Index '
                                 || l_adj_tbl(j).line_ind ||
                                 ' list price: '|| l_adj_tbl(j).unit_price ||
                                 ' l_adj_tbl(j).updated_adjusted_unit_price: '|| l_adj_tbl(j).updated_adjusted_unit_price ||
                                 ' previous l_adjusted_price: '|| l_adjusted_price ||  -- 2892848
                                 ' list line id: '|| l_adj_tbl(j).created_from_list_line_id ||
                                 ' bucket: '|| l_adj_tbl(j).pricing_group_sequence ||  -- 2892848
                                 ' net_amount_flag: '|| l_adj_tbl(j).net_amount_flag); -- 2892828

      END IF; -- end debug
      l_return_adjustment := 0;


      ------------------NET AMT STUFF, SL_latest
      -- begin 2892848
      -- ldet lines are ordered by bucket, line index
      -- l_sub_total_price is bucketed unit price,
      -- l_adjusted_price is the current USP
      -- defaulting l_sub_total_price and l_adjusted_price

      -- l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0); -- SL_more, do not reset, since we need USP from prev bucket sometimes
      IF (l_ntamt_adj_unit_price.EXISTS(l_adj_tbl(j).line_ind)) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l_ntamt_adj_unit_price(cur_line_ind): '|| l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind));
        END IF; --  Added For Bug No - 4033618
        l_adjusted_price := nvl(l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind), l_adj_tbl(j).unit_price);
      ELSE
        l_adjusted_price := nvl(l_adj_tbl(j).unit_price, 0); -- SL_more
      END IF;

      IF (l_adjusted_price IS NULL) THEN -- SL_more
        l_adjusted_price := 0; -- NULL cause nvl(l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind),l_adj_tbl(j).unit_price) being null
      END IF; -- end debug

      IF l_debug = FND_API.G_TRUE THEN -- SL_more
        QP_PREQ_GRP.engine_debug('l_adjusted_price default: '|| l_adjusted_price);
      END IF; -- end debug

      IF (l_adj_tbl(j).pricing_group_sequence IS NULL OR
          l_adj_tbl(j).pricing_group_sequence = 0) THEN
        l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
        -- begin 3126019
        IF l_prev_line_index = l_adj_tbl(j).line_ind THEN -- will be at least 1
          line_change := FALSE;
        ELSE
          line_change := TRUE;
          l_prev_line_index := l_adj_tbl(j).line_ind;
        END IF;
        -- end 3126019
        --l_adjusted_price := l_sub_total_price; -- do not reset this

      ELSE -- not null bucket modifiers or list line
        /*
			-- SL_more, we do not want this for same line same bucket case
			-- since we wnat l_bucket_amt_tbl(l_adj_tbl(j).line_ind)  stays at end of prev bucket level
	        -- default, in case there is no further lines to set this, SL_further fix
	        l_bucket_amt_tbl(l_adj_tbl(j).line_ind) :=
	        l_adjusted_price *l_adj_tbl(j).line_priced_quantity;
		     */

        IF l_debug = FND_API.G_TRUE THEN -- SL_more
          QP_PREQ_GRP.engine_debug('l_prev_line_index: '|| l_prev_line_index);
        END IF; -- end debug

        -- same line
        IF l_prev_line_index = l_adj_tbl(j).line_ind THEN -- will be at least 1
          line_change := FALSE;
          -- same line, bucket change
          -- line at least from 1 to up, bucket atleast from 1 to up
          IF (l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence) THEN -- same line, bucket change
            l_mod_lg_net_amt_tbl.DELETE; -- clear this table upon bucket change to keep it small
            l_mod_lg_prod_net_amt_tbl.DELETE; -- [julin/4112395/4220399]
            -- if they are the 1st bucketed modifiers
            -- later if is 1st bucket is linegroup net amt modifier, we use grp_amt as net_amt
            IF (l_prev_bucket = - 9999) THEN
              l_1st_bucket := 'Y';
            ELSE
              l_1st_bucket := 'N';
            END IF;
            l_prev_bucket := l_adj_tbl(j).pricing_group_sequence; -- preserve new bucket to be next prev_bucket

            -- use USP as l_sub_total_price upon bucket change
            IF (l_ntamt_adj_unit_price.EXISTS(l_adj_tbl(j).line_ind)) THEN
              l_sub_total_price := nvl(l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind), l_adj_tbl(j).unit_price);
              l_adjusted_price := l_sub_total_price;
            ELSE
              l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
              l_adjusted_price := l_sub_total_price;
            END IF;

            -- l_bucket_amt_tbl(line_index) stores USP * ord_qty of the line upon bucket change
            -- we sum up amts of lines related to the net amt modifier to calculate l_lg_net_amt later
            l_bucket_amt_tbl(l_adj_tbl(j).line_ind) := l_adjusted_price * l_adj_tbl(j).line_priced_quantity;

            -- [julin/4055310]
            l_prev_bucket_amt_tbl := l_bucket_amt_tbl;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('same line, different bucket.'
                                       ||' sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
              QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_adj_tbl(j).line_ind ||'): '
                                       || l_adjusted_price || '*' ||
                                       l_adj_tbl(j).line_priced_quantity || '=' || l_bucket_amt_tbl(l_adj_tbl(j).line_ind));
            END IF; -- end debug

          ELSE -- SL_more, same line same bucket, ELSE IF (l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence)
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('same line, same bucket.'
                                       ||' sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
            END IF; -- end debug
          END IF; -- END IF (l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence)

        ELSE -- line change (from -9999 to up, or from at least 1 to up)

          line_change := TRUE;
          -- line change , bucket change
          -- bucket from -9999 to up,or from at least 1 to up
          IF l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence THEN -- line change , bucket change
            -- l_mod_lg_net_amt_tbl(list_line_id) sotres l_lg_net_amt of the net amt modifier
            -- so no need to re-calculate l_lg_net_amt if same modifier is related to other line(s) in the same bucket
            -- clear this table upon bucket change to keep it small
            l_mod_lg_net_amt_tbl.DELETE;
            l_mod_lg_prod_net_amt_tbl.DELETE; -- [julin/4112395/4220399]

            -- preserve l_prev_bucket
            -- if they are the 1st bucketed modifiers
            -- later if is 1st bucket is linegroup net amt modifier, we use grp_amt as net_amt
            IF (l_prev_bucket = - 9999) THEN
              l_1st_bucket := 'Y';
            ELSE
              l_1st_bucket := 'N';
            END IF;
            l_prev_bucket := l_adj_tbl(j).pricing_group_sequence; -- preserve new bucket to be next prev_bucket

            -- use USP as l_sub_total_price upon bucket change
            IF (l_ntamt_adj_unit_price.EXISTS(l_adj_tbl(j).line_ind)) THEN
              l_sub_total_price := nvl(l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind), l_adj_tbl(j).unit_price);
              l_adjusted_price := l_sub_total_price;
            ELSE
              l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
              l_adjusted_price := l_sub_total_price;
            END IF;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('different line, different bucket. '
                                       ||' sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
            END IF; -- end debug

            IF l_prev_line_index =  - 9999 THEN -- 1st line as no USP in l_adj_unit_price_tbl
              l_bucket_amt_tbl(l_adj_tbl(j).line_ind) := nvl(l_adj_tbl(j).unit_price, 0) * l_adj_tbl(j).line_priced_quantity;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('prev_line_index is -9999');
                QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_adj_tbl(j).line_ind ||'): '
                                         || nvl(l_adj_tbl(j).unit_price, 0) || '*' ||
                                         l_adj_tbl(j).line_priced_quantity || '=' || l_bucket_amt_tbl(l_adj_tbl(j).line_ind));
              END IF; -- end debug

              -- bucket change, line change and not the 1st line
            ELSE -- l_prev_line_index <> -9999

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('bucket change, line change and not the 1st line, sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
              END IF; -- END DEBUG
              IF (l_ntamt_adj_unit_price.EXISTS(l_prev_line_index)) THEN
                -- moment to capture current USP for prev line_index,
                -- so we have correct amts in l_bucket_amt_tbl when using it
                l_bucket_amt_tbl(l_prev_line_index) := nvl(l_ntamt_adj_unit_price(l_prev_line_index), l_adj_tbl(j).unit_price) * l_prev_qty;

                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('capture bucket amt of prev_line_index l_bucket_amt_tbl('|| l_prev_line_index ||'): '
                                           || nvl(l_ntamt_adj_unit_price(l_prev_line_index), l_adj_tbl(j).unit_price) || '*' ||
                                           l_prev_qty || '=' || l_bucket_amt_tbl(l_prev_line_index));
                END IF; -- end debug

              ELSE -- ELSE IF (l_ntamt_adj_unit_price.EXISTS(l_prev_line_index))
                l_bucket_amt_tbl(l_prev_line_index) := nvl(l_adj_tbl(j).unit_price, 0) * l_prev_qty;
                IF l_debug = FND_API.G_TRUE THEN

                  QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_prev_line_index ||'): '
                                           || nvl(l_adj_tbl(j).unit_price, 0) || '*' ||
                                           l_prev_qty || '=' || l_bucket_amt_tbl(l_prev_line_index));
                END IF; -- end debug
              END IF; -- END (l_ntamt_adj_unit_price.EXISTS(l_prev_line_index))
              -- [julin/4055310]
              l_prev_bucket_amt_tbl := l_bucket_amt_tbl;

            END IF; -- END l_prev_line_index=-9999

          ELSE -- line change same bucket (bucket is at least from 1 to up, line is at least from 1 to up)
            IF (l_ntamt_adj_unit_price.EXISTS(l_adj_tbl(j).line_ind)) THEN
              l_sub_total_price := nvl(l_ntamt_adj_unit_price(l_adj_tbl(j).line_ind), l_adj_tbl(j).unit_price);
              l_adjusted_price := l_sub_total_price;

            ELSE
              l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
              l_adjusted_price := l_sub_total_price;

            END IF;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('different line, same bucket');
              QP_PREQ_GRP.engine_debug('sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
            END IF; -- end debug

            -- moment to capture current USP for prev line_index,
            -- so we have correct amts in l_bucket_amt_tbl when using it
            IF l_ntamt_adj_unit_price.EXISTS(l_prev_line_index) THEN
              l_bucket_amt_tbl(l_prev_line_index) := nvl(l_ntamt_adj_unit_price(l_prev_line_index), 0) * l_prev_qty;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('capture bucket_amt of prev line l_bucket_amt_tbl('|| l_prev_line_index ||'): '
                                         || nvl(l_ntamt_adj_unit_price(l_prev_line_index), 0) || '*' ||
                                         l_prev_qty || '=' || l_bucket_amt_tbl(l_prev_line_index));
              END IF; -- end debug
              /*
				 ELSE
				   l_bucket_amt_tbl(l_prev_line_index) := 0;
				   */
            END IF; -- end if

            -- SL_more, default, 1st bucket for this line has no prev buckets no prev adjs
            IF l_1st_bucket = 'Y' THEN -- 1st bucket for this line, bucket at lease 1 up
              l_bucket_amt_tbl(l_adj_tbl(j).line_ind) := nvl(l_adj_tbl(j).unit_price, 0) * l_adj_tbl(j).line_priced_quantity; -- for line level net amt we need this
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('1st bucket for this line l_bucket_amt_tbl('|| l_adj_tbl(j).line_ind ||'): '
                                         || nvl(l_adj_tbl(j).unit_price, 0) || '*' ||
                                         l_adj_tbl(j).line_priced_quantity || '=' || l_bucket_amt_tbl(l_adj_tbl(j).line_ind));
              END IF; -- end debug
            END IF; -- END IF l_1st_bucket ='Y'

          END IF; -- end bucket change in the line change block

          l_prev_line_index := l_adj_tbl(j).line_ind; -- preserve the new lind_ind to be l_prev_line_index
          l_prev_qty := l_adj_tbl(j).line_priced_quantity;
        END IF; --l_prev_line_index = line_index
      END IF; -- end if bucket is null or 0

      IF l_debug = FND_API.G_TRUE THEN

        QP_PREQ_GRP.engine_debug('after NET_AMT_STUFF block...');
        QP_PREQ_GRP.engine_debug('l_sub_total_price: '|| l_sub_total_price);
        QP_PREQ_GRP.engine_debug('l_adjusted_price: '|| l_adjusted_price);

      END IF; -- Added For 4033618
      --SL_more
      IF l_sub_total_price IS NULL THEN -- default just in case
        l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
      END IF;
      -- end 2892848, SL_latest NET_AMT STUFF

      /* 2892848 SL_latest
	-- begin 2892848
		-- ldet lines are ordered by bucket, line index
		-- when line_index changes, it means it is the point where bucket changes for that line index
		-- l_sub_total_price is bucketed unit price, l_adjusted_price is the current USP (diff data for diff line_index)
                ---Bucket calculations
                IF l_prev_line_index = l_adj_tbl(j).line_ind
                THEN
                        IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('no line change'
			||' prev_line_index '||l_prev_line_index
			||' prev_bucket '||l_prev_bucket);
                        END IF;
                        line_change := false;


                        IF l_debug = FND_API.G_TRUE THEN
                           QP_PREQ_GRP.engine_debug('same line.');
                           --||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                        END IF;
                 ELSE
                        line_change := true;
                        l_prev_line_index := l_adj_tbl(j).line_ind; -- preserve the new lind_ind to be l_prev_line_index

			IF l_adj_unit_price_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN -- do so 'cos first line of that each line_ind will have no data

			  -- reset to last USP of prev bucket when bucket and line_ind changes
                          IF l_adj_tbl(j).pricing_group_sequence is NULL THEN
                            l_sub_total_price := l_adj_tbl(j).unit_price; -- use original unit price if null bucket
                          ELSE
                            l_sub_total_price :=l_adj_unit_price_tbl(l_adj_tbl(j).line_ind);
                          END IF;
                          l_adjusted_price :=l_adj_unit_price_tbl(l_adj_tbl(j).line_ind);

                         ELSE -- 1st line of each line index has no data in l_adj_unit_price_tbl, use original unit_price

                           l_sub_total_price := l_adj_tbl(j).unit_price;
                           l_adjusted_price := l_adj_tbl(j).unit_price;

                         END IF; -- end index exists

                         IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug('line change '
                            ||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                         END IF;

                   END IF;   --l_prev_line_index = line_index
                   -- end 2892848

				   -- begin 2892848
                   -- MOVE TO HERE
                IF l_adj_tbl(J).pricing_group_sequence <> 0 AND l_adj_tbl(J).pricing_group_sequence IS NOT NULL THEN -- bucket 0 is line event list price
                   -- detect bucket change, need to CAPTURE unit_adjs (LINE) and adj_amts(LINEGROUP) up to the prev bucket
                  IF l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence THEN
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug ('------BUCKET CHANGE----, place to debug adj_amts or unit_adjs up to prev bucket.');
                    END IF; -- END debug

                    -- for LINE GROUP
                    -- need capture the l_prev_lg_adj_amt
                    -- l_bucket_adj_amt_tbl(bucket) stores adj_amts of all lines for each bucket
                    -- prev_lg_adj_amt is the sum of adj_amts for all lines up to prev buckets

                    IF l_bucket_adj_amt_tbl.EXISTS(l_prev_bucket) THEN
		      l_prev_lg_adj_amt := nvl(l_prev_lg_adj_amt,0) + l_bucket_adj_amt_tbl(l_prev_bucket);
		      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('debug LINEGROUP adj amts up to prev bucket - '||l_prev_bucket ||': '||l_prev_lg_adj_amt);
                      END IF; -- END debug

		    END IF; -- END IF l_bucket_adj_amt_tbl.EXISTS(l_prev_bucket)

                    -- bucket change for LINE LEVEL
                    -- l_bucket_index_adj_tbl(line_index) stores sum of unit_adjs for each line_index
                    -- l_prev_bucket_index_adj_tbl(line_index) is the sum of unit_adjs for that line_index up to prev bucket

                    IF l_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
                      IF l_prev_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
                        l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind):= nvl(l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind),0)
                          + l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind);
                      ELSE
                        l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind):= l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind);
                      END IF; -- END IF l_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind)

                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('debug LINE unit adjs up to prev bucket for line index'||l_adj_tbl(j).line_ind ||': '||l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind) );
                      END IF; -- END debug
                    END IF; -- END IF l_bucket_index_adj_tbl.EXISTS

                    -- begin shu fix bug for special case, bucket change within same line index
                    IF line_change = false THEN
                      l_sub_total_price :=l_adj_unit_price_tbl(l_adj_tbl(j).line_ind);

                      IF l_debug = FND_API.G_TRUE THEN
                           QP_PREQ_GRP.engine_debug('bucket change within same line'
                           ||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                      END IF;
                    END IF; -- END IF line_change = flase
                    -- end shu fix bug

                    l_prev_bucket := l_adj_tbl(j).pricing_group_sequence; -- preserve new bucket to be next prev_bucket

                  ELSE -- bucket did not change but line changes within bucket, we also need to capture line level unit adjs of prev bucket
                    IF line_change = true THEN
                      IF l_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
                      IF l_prev_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
                        l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind):= nvl(l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind),0)
                          + l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind);
                      ELSE
                        l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind):= l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind);
                      END IF; -- END IF l_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind)

                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('line change, debug LINE unit adjs up to prev bucket for line index'||l_adj_tbl(j).line_ind ||': '||l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind) );
                      END IF; -- END debug
                    END IF; -- END IF l_bucket_index_adj_tbl.EXISTS
                    END IF; -- END IF line_change true

                  END IF; -- end if l_prev_bucket <> l_adj_tbl(j).pricing_group_sequence

                ELSE -- bucket is 0 or null -- begin shu fix bug
                  l_sub_total_price := nvl(l_adj_tbl(j).unit_price, 0);
                  l_adjusted_price :=nvl (l_adj_unit_price_tbl(l_adj_tbl(j).line_ind),0);
                      IF l_debug = FND_API.G_TRUE THEN
                           QP_PREQ_GRP.engine_debug('bucket is 0 or null'
                           ||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                      END IF;
                  -- end shu fix bug

                END IF; -- END IF l_adj_tbl(J).pricing_group_sequence <> 0 AND ...
                   -- end 2892848
out SL_latest*/

      --This fix is for bug 1915355
      --To calculate lumpsum use group_qty/amt for linegrp
      --This is only for engine inserted records
      --for user passed adjustments, we will use only line_qty
      --to break the link from other lines that have this line
      --group adjustment
      l_calc_quantity := 0;
      --bug 4900095
      IF (QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_adj_tbl(j).line_ind)
      or QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_adj_tbl(j).line_detail_index))
      and l_adj_tbl(j).operand_calculation_code = G_LUMPSUM_DISCOUNT THEN
      --only for service items
      --when uom_quantity is passed as null,
      -- and contract_start/end_dates are passed
      --and for a line/linegroup lumpsum DIS/PBH/SUR/FREIGHT
        IF l_adj_tbl(j).modifier_level_code = G_LINE_GROUP  THEN
          IF G_Service_pbh_lg_amt_qty.exists(l_adj_tbl(j).line_detail_index)
          and QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_adj_tbl(j).line_detail_index) THEN
            l_calc_quantity := nvl(G_Service_pbh_lg_amt_qty(l_adj_tbl(j).line_detail_index),
              QP_PREQ_GRP.G_service_ldet_qty_tbl(l_adj_tbl(j).line_detail_index));
          ELSIF G_Service_pbh_lg_amt_qty.exists(l_adj_tbl(j).line_detail_index) THEN
            l_calc_quantity := G_Service_pbh_lg_amt_qty(l_adj_tbl(j).line_detail_index);
          ELSIF QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_adj_tbl(j).line_detail_index) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_ldet_qty_tbl(l_adj_tbl(j).line_detail_index);
          ELSIF QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_adj_tbl(j).line_ind) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_line_qty_tbl(l_adj_tbl(j).line_ind);
          ELSE
            l_calc_quantity :=
            nvl(nvl(l_adj_tbl(j).group_quantity
                , l_adj_tbl(j).group_amount) -- this is group_amount_per_unit
              , nvl(l_adj_tbl(j).priced_quantity
                  , l_adj_tbl(j).line_priced_quantity));
          END IF;--G_Service_pbh_lg_amt_qty.exists
        ELSIF l_adj_tbl(j).modifier_level_code = G_LINE_LEVEL THEN
          IF QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_adj_tbl(j).line_ind) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_line_qty_tbl(l_adj_tbl(j).line_ind);
          ELSE
            l_calc_quantity := nvl(l_adj_tbl(j).line_priced_quantity
                               , l_adj_tbl(j).priced_quantity) ; -- request line qty, shu fix recurring 2702384
          END IF;--QP_PREQ_GRP.G_service_line_qty_tbl.exists
        END IF;--l_adj_tbl(j).modifier_level_code
      ELSE
        IF l_adj_tbl(j).modifier_level_code = G_LINE_GROUP
        --			and nvl(l_adj_tbl(j).is_ldet_rec,G_YES) = G_YES
        THEN
          l_calc_quantity :=
          nvl(nvl(l_adj_tbl(j).group_quantity
                , l_adj_tbl(j).group_amount) -- this is group_amount_per_unit
            , nvl(l_adj_tbl(j).priced_quantity
                  , l_adj_tbl(j).line_priced_quantity));
        ELSE
          l_calc_quantity := nvl(l_adj_tbl(j).line_priced_quantity
                               , l_adj_tbl(j).priced_quantity) ; -- request line qty, shu fix recurring 2702384
        END IF;
      END IF;--QP_PREQ_GRP.G_service_line_qty_tbl.exists(

      l_calc_quantity := nvl(l_calc_quantity, 1);

      -- SHU
      -- priced_quantity is 4000, group_amount i.e. 20*100 + 10* 200
      -- group_amount is 40, group_amount_per_unit
      -- line_priced_quantity is 20, order qty for line 1

      IF l_debug = FND_API.G_TRUE THEN -- SHU
        QP_PREQ_GRP.engine_debug(
                                 'figuring out qty level '|| l_adj_tbl(j).modifier_level_code
                                 ||' priced_quantity '|| l_adj_tbl(j).priced_quantity -- from ldets.line_quantity
                                 ||' group_quantity '|| l_adj_tbl(j).group_quantity
                                 ||' group_amount '|| l_adj_tbl(j).group_amount
                                 ||' line_priced_quantity '|| l_adj_tbl(j).line_priced_quantity -- order_qty
                                 ||' calc '|| l_calc_quantity);
      END IF;
      --end fix for bug 1915355
      IF l_adj_tbl(j).created_from_list_line_type = G_PRICE_BREAK_TYPE
        AND l_adj_tbl(j).pricing_status_code
        IN (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED)
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Processing Price Break. call Price_Break_Calculation');

        END IF;

        --changes for PBH line group LUMPSUM bug 2388011 commented out
        --call to old signature of Price_Break_Calculation
        /*
--fix for bug 2515762 to pass line_dtl_index instead of list_line_id
                QP_Calculate_Price_PUB.Price_Break_Calculation(
                     l_adj_tbl(j).line_detail_index
                     ,l_adj_tbl(j).price_break_type_code
                     ,l_adj_tbl(j).line_ind
                     ,nvl(l_calc_quantity,1)
                     ,l_sub_total_price
                     ,l_return_adjustment
                     ,l_return_status
                     ,l_return_status_text);
*/
        --changes for PBH line group LUMPSUM bug 2388011 commented out
        --call to old signature of Price_Break_Calculation
        --changes for PBH line group LUMPSUM bug 2388011 calling new
        --overloaded procedure Price_Break_Calculation
        --for bug 2908174 for copied orders breaks from
        --oe_price_adj must not be re-evaluated for price_flag 'P'
        IF l_adj_tbl(j).price_flag = G_PHASE
          AND l_adj_tbl(j).is_ldet_rec IN
          (G_ADJ_LINE_TYPE, G_ADJ_ORDER_TYPE) THEN
          l_return_adjustment := nvl(l_adj_tbl(j).adjustment_amount, 0);
        ELSE --l_adj_tbl(j).price_flag
          -- [nirmkuma/4222552] since passed line group manual discounts are
          -- treated only as line level, using following line level path, which
          -- looks at updated line_priced_quantity.
          IF (l_adj_tbl(j).modifier_level_code IN (G_LINE_LEVEL, G_ORDER_LEVEL)
   or (l_adj_tbl(j).modifier_level_code = G_LINE_GROUP and l_adj_tbl(j).automatic_flag = G_NO)) THEN
            IF G_pbhvolattr_attribute.EXISTS(l_adj_tbl(j).created_from_list_line_id) THEN
              IF G_pbhvolattr_attribute(l_adj_tbl(j).created_from_list_line_id)
                = G_QUANTITY_ATTRIBUTE THEN
                l_total_value := 0;
                l_req_value_per_unit := l_adj_tbl(j).line_priced_quantity;
              ELSE --same for item amount or others(treat as item_amt)
                -- bug 4086952 BREAKS ARE NOT ADJUSTING ON CHANGING THE ORDERED QTY WITH ITM AMOUNT
                IF G_pbhvolattr_attribute(l_adj_tbl(j).created_from_list_line_id) = G_LINE_AMT_ATTRIBUTE THEN
                  l_total_value := l_adj_tbl(j).unit_price * l_adj_tbl(j).line_priced_quantity;
                  l_req_value_per_unit := l_adj_tbl(j).line_priced_quantity;
                  l_qualifier_value := l_adj_tbl(j).unit_price * l_adj_tbl(j).line_priced_quantity;
                ELSE --others volume attribute
                  l_total_value := l_adj_tbl(j).priced_quantity; --4000
                  l_req_value_per_unit := l_adj_tbl(j).line_priced_quantity; --20
                  l_qualifier_value := l_adj_tbl(j).priced_quantity; --2892848  SL_latest move to here as default
                END IF;
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('l_qualifier_value default: '|| l_adj_tbl(j).priced_quantity);
                  QP_PREQ_GRP.engine_debug('l_qualifier_value : '|| l_qualifier_value);
                END IF; -- end debug
                -- begin 2892848
                -- net_amount line level (not group of line) modifier
                IF l_adj_tbl(j).net_amount_flag IN (G_YES, 'P') THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('net amount line level modifier: '|| l_adj_tbl(J).created_from_list_line_id);
                  END IF; -- end debug

                  /* SL_latest 2892848
                        IF l_prev_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
						   -- priced_quantity is line amount, line_priced_quantity is order qty
                          l_qualifier_value:= l_adj_tbl(j).priced_quantity + nvl(l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind),0)* l_adj_tbl(j).line_priced_quantity;
                          IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug('line amount: '||l_adj_tbl(j).priced_quantity);
                            QP_PREQ_GRP.engine_debug('order qty : '||l_adj_tbl(j).line_priced_quantity);
                            QP_PREQ_GRP.engine_debug('unit adjs up to prev buckets: '|| nvl(l_prev_bucket_index_adj_tbl(l_adj_tbl(j).line_ind),0) );
                          END IF; -- end debug
                        ELSE
                          l_qualifier_value:= l_adj_tbl(j).priced_quantity;
                        END IF; -- END IF l_prev_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j))

                        IF l_debug = FND_API.G_TRUE THEN
                          QP_PREQ_GRP.engine_debug('line level net amount: '||l_qualifier_value);
                        END IF; -- end debug
                      ELSE -- not net_amount modifier
                        l_qualifier_value  := l_adj_tbl(j).priced_quantity; --2892848

                        IF l_debug = FND_API.G_TRUE THEN
                          QP_PREQ_GRP.engine_debug('not net amount pbh qualifier value: '||l_qualifier_value);
                        END IF; -- end debug
						*/
                  IF l_bucket_amt_tbl.EXISTS(l_adj_tbl(j).line_ind)THEN
                    l_qualifier_value := l_bucket_amt_tbl(l_adj_tbl(j).line_ind);
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('line level net amount: '|| l_qualifier_value);
                    END IF; -- end debug
                  END IF; -- END IF l_bucket_amt_tbl.EXISTs
                END IF; -- END IF net_amount modifier
                -- end 2892848

              END IF; --G_pbhvolattr_attribute

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('PBH calc dtls attribute '
                                         || G_pbhvolattr_attribute(l_adj_tbl(j).created_from_list_line_id)
                                         ||' l_total_value '|| l_total_value ||' l_req_value_per_unit '
                                         || l_req_value_per_unit);
              END IF; --l_debug
            ELSE --no attribute
              --this is a setup bug where no attribute for PBH
              l_total_value := NULL;
              l_req_value_per_unit := NULL;
            END IF; --G_pbhvolattr_attribute.exists

          ELSE --linegroup level
            IF G_pbhvolattr_attribute.EXISTS(l_adj_tbl(j).created_from_list_line_id) THEN
              IF G_pbhvolattr_attribute(l_adj_tbl(j).created_from_list_line_id)
                = G_QUANTITY_ATTRIBUTE THEN
                l_total_value := 0;
                l_req_value_per_unit := l_adj_tbl(j).group_quantity;
              ELSE --same for item amount or others(treat as item_amt)
                l_total_value := l_adj_tbl(j).priced_quantity; --4000
                IF l_adj_tbl(j).is_ldet_rec IN (G_LDET_ORDER_TYPE,
                                                G_LDET_LINE_TYPE) THEN
                  l_req_value_per_unit := l_adj_tbl(j).group_amount; --40
                ELSE
                  --for linegrp itemamt lumpsum, the adj_amt =
                  --operand/group_amount. When calculation is done after
                  --search, engine calculates group_amount as ldet.line_qty/
                  --unit_price. But when calling application passes or we
                  --fetch adj from OM, group_amt is range_break_qty which
                  --is the line_qty returned by the pricing engine and the
                  --the group_amt passed back by engine is not stored by OM
                  --so we need to do this for adj not searched by engine
                  -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                  IF (l_adj_tbl(j).unit_price = 0) THEN
                    l_req_value_per_unit := FND_API.G_NULL_NUM;
                  ELSE
                    l_req_value_per_unit := l_adj_tbl(j).group_amount / l_adj_tbl(j).unit_price;
                  END IF;
                END IF;

                -- begin 2892848
                -- IF net amount linegroup modifier
                IF l_adj_tbl(j).net_amount_flag IN (G_YES, 'P') THEN

                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('net amount linegroup modifier list_line_id: '|| l_adj_tbl(J).created_from_list_line_id);
                  END IF; -- end debug

                  -- begin SL_latest 2892848
                  l_lg_net_amt := 0; --SL_latest
                  l_line_bucket_amt := 0; -- note 0+null is null, so we need to default this to 0
                  -- [julin/4112395/4220399]
                  l_lg_prod_net_amt := 0;
                  l_prod_line_bucket_amt := 0;

                  -- fix of latest requirement, only add up net amounts within the group
                  -- l_mod_lg_net_amt_tbl is hastable of modifier and its lg_net_amt for that bucket
                  -- so we do not need to re-calculate l_lg_net_amt if the same modifier is related to other line index within the same bucket
                  -- lg_net_amt is the sum of (USP at end of prev bucket *Qty) for the lines related to this modifier
                  -- l_net_mod_index_cur has line_indexes from ldets tmp related to this net amount modifier

                  -- SL_further_fix
                  -- if there are no prev buckets for this modifier,we use group amount as l_lg_net_amt
                  -- since we do not have the adjs of other lines yet, so l_bucket_amt_tbl does not have complete data

                  -- [julin/3265308] net amount calculation 'P', match product only.
                  -- For category net amount, 1st_bucket means that this is the
                  -- first bucket of the line, so no adjustments have been ap-
                  -- plied.  However, other lines of the same category might
                  -- have had modifiers in previous buckets applied, so we look
                  -- at the bucket_amt_tbl to see if those have been calculated
                  -- else we can assume no modifiers applied yet, and can hence
                  -- calculate the list price * qty for those lines.
                  IF nvl(l_adj_tbl(j).net_amount_flag, 'N') = 'P' THEN
                    IF l_mod_lg_prod_net_amt_tbl.EXISTS(l_adj_tbl(j).created_from_list_line_id) THEN
                      l_lg_prod_net_amt := l_mod_lg_prod_net_amt_tbl(l_adj_tbl(j).created_from_list_line_id);
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('recycle l_lg_prod_net_amt from l_mod_lg_net_amt_tbl: '|| l_lg_prod_net_amt);
                      END IF; --end debug
                    ELSE -- need to calculate l_lg_net_amt
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('1st bucket = '|| l_1st_bucket ||', net amount flag = P');
                      END IF;
                      -- calculate amount using product attribute net amount grouping
                      FOR t IN l_prod_attr_info(l_adj_tbl(j).created_from_list_line_id) LOOP
                        IF l_prev_bucket_amt_tbl.EXISTS(t.line_index) THEN
                          l_prod_line_bucket_amt := nvl(l_prev_bucket_amt_tbl(t.line_index), 0);
                          IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug(t.line_index || ':' || l_prev_bucket_amt_tbl(t.line_index));
                          END IF; --end debug
                        ELSE
                          -- have to compute list price * qty for the line (query from qp_npreq_lines_tmp)
                          l_prod_line_bucket_amt := nvl(t.priced_quantity, 0) * nvl(t.unit_price, 0);
                          IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug('* line index '|| t.line_index ||' not in l_prev_bucket_amt_tbl');
                            QP_PREQ_GRP.engine_debug('  got value '|| l_prod_line_bucket_amt ||' from lines_tmp instead');
                          END IF;
                        END IF;
                        l_lg_prod_net_amt := l_lg_prod_net_amt + l_prod_line_bucket_amt;

                        IF l_debug = FND_API.G_TRUE THEN
                          QP_PREQ_GRP.engine_debug('(catnetamt) l_prod_line_bucket_amt: ' || l_prod_line_bucket_amt);
                          QP_PREQ_GRP.engine_debug('(catnetamt) up-tp-date l_lg_prod_net_amt: ' || l_lg_prod_net_amt); -- grp amt
                        END IF;
                      END LOOP;

                      l_mod_lg_prod_net_amt_tbl(l_adj_tbl(j).created_from_list_line_id) := l_lg_prod_net_amt; -- preserve this for recycle
                    END IF;
                  END IF; -- end l_adj_tbl(j).net_amount_flag = 'P'   -- [julin/3265308]

                  IF (l_1st_bucket = 'Y') THEN

                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug(' l_1st_bucket is Y, use group amount as l_lg_net_amt'); -- grp amt
                    END IF; -- end debug
                    l_lg_net_amt := l_adj_tbl(j).priced_quantity;

                  ELSE -- l_1st_bucket='N'

                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug(' - not first bucket');
                    END IF; --Added For Bug No - 4033618
                    IF l_mod_lg_net_amt_tbl.EXISTS(l_adj_tbl(j).created_from_list_line_id) THEN
                      l_lg_net_amt := l_mod_lg_net_amt_tbl(l_adj_tbl(j).created_from_list_line_id); -- 5346093
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('recycle lg_net_amt from l_mod_lg_net_amt_tbl: '|| l_lg_net_amt);
                      END IF; --end debug
                    ELSE -- need to calculate l_lg_net_amt
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('lg_net_amt for list line '|| l_adj_tbl(j).created_from_list_line_id ||' not cached');
                      END IF;
                      -- regular net amount processing
                      l_adj_exists_in_tmp_tbl := 'N'; -- reset bug 3618464
                      FOR t IN l_net_mod_index_cur(l_adj_tbl(j).created_from_list_line_id) LOOP
                        l_adj_exists_in_tmp_tbl := 'Y'; -- bug 3618464
                        IF l_bucket_amt_tbl.EXISTS(t.line_index) THEN
                          l_line_bucket_amt := nvl(l_bucket_amt_tbl(t.line_index), 0);
                          IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug(t.line_index || ':' || l_bucket_amt_tbl(t.line_index));
                          END IF; --end debug
                        ELSE
                          l_line_bucket_amt := 0;
                        END IF;
                        l_lg_net_amt := l_lg_net_amt + l_line_bucket_amt;

                        IF l_debug = FND_API.G_TRUE THEN
                          QP_PREQ_GRP.engine_debug('l_line_bucket_amt: ' || l_line_bucket_amt);
                          QP_PREQ_GRP.engine_debug('up-tp-date l_lg_net_amt: ' || l_lg_net_amt); -- grp amt
                        END IF; --end debug
                      END LOOP; -- end l_net_mod_index_cur

                      -- Bug 3618464 - GROUP OF LINES, NET AMOUNT, OVERRIDE MODIFIER
                      -- get the line indexes from G_LINE_INDEXES_FOR_LINE_ID for the given list_line_id
                      IF l_adj_exists_in_tmp_tbl = 'N' THEN
                        IF G_LINE_INDEXES_FOR_LINE_ID.EXISTS(l_adj_tbl(j).created_from_list_line_id) THEN
                          l_line_index_str := G_LINE_INDEXES_FOR_LINE_ID(l_adj_tbl(j).created_from_list_line_id);
                        END IF;
                        IF l_debug = FND_API.G_TRUE THEN
                          QP_PREQ_GRP.engine_debug('l_line_index_str = ' || l_line_index_str);
                        END IF;
                        IF l_line_index_str IS NOT NULL THEN
                          LOOP
                            l_instr_pos := instr(l_line_index_str, ',');
                            EXIT WHEN (nvl(l_instr_pos, 0) = 0);

                            l_index := ltrim(rtrim(substr(l_line_index_str, 1, l_instr_pos - 1)));
                            l_line_index_str := substr(l_line_index_str, l_instr_pos + 1);

                            IF l_bucket_amt_tbl.EXISTS(l_index) THEN
                              l_line_bucket_amt := nvl(l_bucket_amt_tbl(l_index), 0);
                              IF l_debug = FND_API.G_TRUE THEN
                                QP_PREQ_GRP.engine_debug('Net Amount Override PBH LINEGROUP ' || l_index || ':' || l_bucket_amt_tbl(l_index));
                              END IF; --end debug
                            ELSE
                              l_line_bucket_amt := 0;
                            END IF;
                            l_lg_net_amt := l_lg_net_amt + l_line_bucket_amt;

                            IF l_debug = FND_API.G_TRUE THEN
                              QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_index ||'): '|| l_line_bucket_amt);
                            END IF; --end debug
                          END LOOP;
                        END IF; --if l_line_index_str is not null
                      END IF; --if l_adj_exists_in_tmp_tbl = 'N'

                      l_mod_lg_net_amt_tbl(l_adj_tbl(j).created_from_list_line_id) := l_lg_net_amt; -- preserve this for recycle

                    END IF; --l_mod_lg_net_amt_tbl.EXIST

                  END IF; -- END IF l_prev_bucket = -9999

                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('final l_lg_net_amt: '|| l_lg_net_amt);
                  END IF; --end debug
                  -- end SL_latest

                  -- [julin/4112395/4220399]
                  IF (nvl(l_adj_tbl(j).net_amount_flag, 'N') = 'P') THEN
                    l_qualifier_value := l_lg_prod_net_amt;
                    -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                    IF (l_sub_total_price = 0) THEN
                      l_req_value_per_unit := FND_API.G_NULL_NUM;
                      l_applied_req_value_per_unit := FND_API.G_NULL_NUM;
                    ELSE
                      l_req_value_per_unit := l_lg_prod_net_amt / l_sub_total_price; --bug 3404493
                      l_applied_req_value_per_unit := l_lg_net_amt / l_sub_total_price;
                    END IF;
                  ELSE
                    l_qualifier_value := l_lg_net_amt;
                    -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                    IF (l_sub_total_price = 0) THEN
                      l_req_value_per_unit := FND_API.G_NULL_NUM;
                    ELSE
                      l_req_value_per_unit := l_lg_net_amt / l_sub_total_price; --bug 3404493
                    END IF;
                  END IF;

                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('group amount: ' || l_adj_tbl(j).priced_quantity); -- grp amt
                    QP_PREQ_GRP.engine_debug('group of lines net amt: '|| l_qualifier_value);
                  END IF; --end debug

                ELSE -- not net amount modifier
                  l_qualifier_value := l_adj_tbl(j).priced_quantity; -- not net amount grouop of line modifier
                END IF; -- END IF net_amount_flag = 'Y' for line group modifiers
                -- end 2892848

              END IF; --G_pbhvolattr_attribute

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('PBH calc dtls attribute '
                                         || G_pbhvolattr_attribute(l_adj_tbl(j).created_from_list_line_id)
                                         ||' l_total_value '|| l_total_value --4000
                                         ||' l_req_value_per_unit '|| l_req_value_per_unit); --40
              END IF; --l_debug
            ELSE --no attribute
              --this is a setup bug where no attribute for PBH
              l_total_value := NULL;
              l_req_value_per_unit := NULL;
            END IF; --G_pbhvolattr_attribute.exists
          END IF; --modifier level code

          /* out 2892848
                -- obtain net_adj_amount_flag from qp_list_lines table if null,
                -- since it may not be passed from calling application
                -- net_amount_new 2720717
                IF l_adj_tbl(j).net_amount_flag IS NULL THEN
                  OPEN l_net_amount_flag_cur(l_adj_tbl(j).created_from_list_line_id);
                  FETCH l_net_amount_flag_cur into l_adj_tbl(j).net_amount_flag;
                  CLOSE l_net_amount_flag_cur;
                END IF;
                   	 */ -- out 2892848

          -- [julin/3265308] Price_Break_Calculation should have same
          -- behavior for both net_amount_flag = G_YES and 'P'.
          IF (l_adj_tbl(j).net_amount_flag IN (G_YES, 'P')) THEN
            l_bucketed_flag := G_YES;
          ELSE
            l_bucketed_flag := G_NO;
          END IF;

          --4900095 used in price_break_calculation
          G_PBH_MOD_LEVEL_CODE(l_adj_tbl(j).line_detail_index) :=
                    l_adj_tbl(j).modifier_level_code;

          QP_Calculate_Price_PUB.Price_Break_Calculation(
                                                         l_adj_tbl(j).line_detail_index,  -- line_detail_index
                                                         l_adj_tbl(j).price_break_type_code,
                                                         l_adj_tbl(j).line_ind,
                                                         l_req_value_per_unit,  -- Group Value per unit,group quantity,item qty 40
                                                         l_applied_req_value_per_unit,  -- [julin/4112395/4220399]
                                                         l_total_value,  -- Total value (Group amount or item amount) 4000
                                                         l_sub_total_price,
                                                         l_adj_tbl(j).line_priced_quantity,  -- 2388011, SHU FIX diff PRIYA, 20
                                                         --l_pbh_prev_net_adj_amount, -- net_amount, 2720717 -- 2892848
                                                         l_qualifier_value,  -- p_bucketed_adj, 2892848
                                                         l_bucketed_flag,  -- net_amount_new, 2720717, [julin/3265308]
                                                         l_adj_tbl(j).automatic_flag, -- 5413797
                                                         l_return_adjustment,
                                                         l_return_status,
                                                         l_return_status_text);

          --end changes for bug 2388011

          l_return_adjustment :=  - 1 * nvl(l_return_adjustment, 0);

          -- 2892848
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('PBH return adjustment '|| l_return_adjustment); --40
          END IF; --l_debug
          -- end 2892848

        END IF; --l_adj_tbl(j).price_flag


      ELSE --created_from_list_line_type not PBH, 2892848 change comment only
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Processing DIS/SUR/FRT: '|| l_adj_tbl(j).created_from_list_line_id); -- 2892848, change debug msg
        END IF; -- end debug

        IF l_adj_tbl(j).created_from_list_line_type = G_DISCOUNT
          AND l_adj_tbl(j).operand_calculation_code <> G_NEWPRICE_DISCOUNT
          --included this newprice check for negative newprice bug 2065609
          THEN
          l_sign :=  - 1;
        ELSE
          l_sign := 1;
        END IF; --l_adj_tbl(j).created_from_list_line_type=g_discount

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this check '
                                   || l_adj_tbl(j).line_type_code ||' '
                                   || l_calc_quantity ||' '|| l_adj_tbl(j).operand_calculation_code);

        END IF;
        IF l_adj_tbl(j).modifier_level_code = G_ORDER_LEVEL
          AND l_calc_quantity = 0
          AND l_adj_tbl(j).operand_calculation_code = G_LUMPSUM_DISCOUNT
          THEN
          l_calc_quantity := 1;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Order lvl qty '||
                                     l_calc_quantity);
          END IF;
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this sign '|| l_sign);
        END IF;

        IF l_adj_tbl(j).PRICING_STATUS_CODE IN
          (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED)
          THEN
          /*
		   IF l_adj_tbl(j).updated_flag = G_YES
		   and nvl(l_adj_tbl(j).automatic_flag,G_NO) = G_NO
		   and (l_adj_tbl(j).adjustment_amount IS NOT NULL
			and l_adj_tbl(j).adjustment_amount <> g_miss_num) --FND_API.G_MISS_NUM)
		   THEN
			--to avoid rounding issues in rev calculations
			--for user-overridden adjustments
   IF l_debug = FND_API.G_TRUE THEN
			qp_preq_grp.engine_debug(' adj amt manual adj '||
				l_adj_tbl(j).adjustment_amount);
   END IF;
			l_return_adjustment := l_adj_tbl(j).adjustment_amount;
		   ELSE
		*/--commented to avoid overriding errors
          IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug(' adj amt manual adj '||
                                     l_adj_tbl(j).adjustment_amount);

          END IF;
          --bug 2691794
          IF
            --  l_adj_tbl(j).created_from_list_line_type <> G_FREIGHT_CHARGE and ** Commented for bug#3596827 **
            l_adj_tbl(j).price_flag = G_PHASE
            AND l_adj_tbl(j).line_category = 'RETURN'
            AND l_adj_tbl(j).operand_calculation_code = G_LUMPSUM_DISCOUNT
            and l_adj_tbl(j).is_ldet_rec not in
                (G_LDET_ORDER_TYPE, G_LDET_LINE_TYPE) -- 4534961/4492066
          THEN
            l_return_adjustment := l_adj_tbl(j).adjustment_amount;
            l_adj_tbl(j).operand_value :=
            l_adj_tbl(j).line_priced_quantity *
            l_adj_tbl(j).adjustment_amount *
            l_sign;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('return line frtchg operand '
                                       || l_adj_tbl(j).operand_value ||' adj amt '
                                       || l_return_adjustment);
            END IF; --l_debug
          ELSE --l_adj_tbl(j).created_from_list_line_type = frt
            IF l_adj_tbl(j).operand_calculation_code =
              G_LUMPSUM_DISCOUNT
              AND l_adj_tbl(j).modifier_level_code = G_LINE_GROUP
              AND l_adj_tbl(j).is_ldet_rec NOT IN
              (G_LDET_ORDER_TYPE, G_LDET_LINE_TYPE) THEN
              BEGIN
                SELECT pricing_attribute INTO l_pricing_attribute
                FROM qp_pricing_attributes
                WHERE list_line_id =
                    l_adj_tbl(j).created_from_list_line_id
                AND pricing_attribute_context =
                            G_PRIC_VOLUME_CONTEXT;
              EXCEPTION
                WHEN OTHERS THEN
                  l_pricing_attribute := NULL;
              END;

              IF l_pricing_attribute IS NOT NULL
                AND l_pricing_attribute = G_PRIC_ATTRIBUTE12
                AND l_adj_tbl(j).modifier_level_code = G_LINE_GROUP
                AND l_adj_tbl(j).is_ldet_rec NOT IN
                (G_LDET_ORDER_TYPE, G_LDET_LINE_TYPE) THEN
                --for linegrp itemamt lumpsum, the adj_amt =
                --operand/group_amount. When calculation is done after
                --search, engine calculates group_amount as ldet.line_qty/
                --unit_price. But when calling application passes or we
                --fetch adj from OM, group_amt is range_break_qty which
                --is the line_qty returned by the pricing engine and the
                --the group_amt passed back by engine is not stored by OM
                --so we need to do this for adj not searched by engine
                -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                IF (l_adj_tbl(j).unit_price = 0) THEN
                  l_calc_quantity := FND_API.G_NULL_NUM;
                ELSE
                  l_calc_quantity := l_calc_quantity / l_adj_tbl(j).unit_price;
                END IF;
              END IF; --l_pricing_attribute
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('l_calc_qty for lumpsum '
                                         || l_calc_quantity);
              END IF; --l_debug
            END IF; --l_adj_tbl(j).operand_calculation_code

            Calculate_bucket_price(
                                   l_adj_tbl(j).created_from_list_line_type
                                   , l_sub_total_price
                                   , nvl(l_calc_quantity, 1)
                                   , l_adj_tbl(j).operand_calculation_code
                                   , nvl(l_adj_tbl(j).operand_value, 0) * l_sign
                                   , l_return_adjustment
                                   , l_return_status
                                   , l_return_status_text);
          END IF; --l_adj_tbl(j).created_from_list_line_type = frt

          IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
            x_return_status := l_return_status;
            x_return_status_text := l_return_status_text;
          END IF;
          --  END IF;--manual adj updated and applied
        END IF;
      END IF;

      --This code is to avoid the order level adjustments being
      --returned with each line and to return only one order level
      --adjustment with the summary line

      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Is Ldet Rec : ' || l_adj_tbl(j).is_ldet_rec);
      END IF;

      IF ((l_adj_tbl(j).is_ldet_rec IN
           (G_LDET_LINE_TYPE, G_ADJ_LINE_TYPE, G_ASO_LINE_TYPE)
           AND l_adj_tbl(j).line_type_code = G_LINE_LEVEL)
          OR (l_adj_tbl(j).is_ldet_rec IN
              (G_LDET_ORDER_TYPE, G_ADJ_ORDER_TYPE, G_ASO_ORDER_TYPE)
              AND l_adj_tbl(j).line_type_code = G_ORDER_LEVEL))
        THEN
        i := i + 1;
        l_ldet_line_dtl_index_tbl(i) := l_adj_tbl(j).line_detail_index;
        --need to store this for bug 2833753
        G_ldet_plsql_index_tbl(l_ldet_line_dtl_index_tbl(i)) := i;
        IF (l_debug = FND_API.G_TRUE) THEN
          QP_PREQ_GRP.engine_debug('Adding line details : '
                                   || l_ldet_line_dtl_index_tbl(i) ||' plsqlind '
                                   || G_ldet_plsql_index_tbl(l_ldet_line_dtl_index_tbl(i)));
        END IF;
        l_ldet_line_index_tbl(i) := l_adj_tbl(j).curr_line_index;
        l_ldet_list_hdr_id_tbl(i) :=
        l_adj_tbl(j).created_from_list_header_id;
        l_ldet_list_line_id_tbl(i) :=
        l_adj_tbl(j).created_from_list_line_id;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('adjusted amt 1 ');
        END IF;
        l_ldet_list_line_type_tbl(i) :=
        l_adj_tbl(j).created_from_list_line_type;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('adjusted amt 2 ');
        END IF;
        l_ldet_adj_amt_tbl(i) := nvl(l_return_adjustment, 0);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('adjusted amt 3 ');
        END IF;

        -- begin 2892848
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(' unrounded adj_amt l_ldet_adj_amt_tbl('|| i ||'): '|| l_ldet_adj_amt_tbl(i)); -- 2892848
        END IF; --END IF l_debug
        /* SL_latest 2892848
		  -- CONTINUE building l_bucket_adj_amt_tbl and l_bucket_index_adj_tbl regardless of bucket
		  -- only for bucket modifiers, 0 is price list line, null is reg modifier
		IF l_adj_tbl(j).pricing_group_sequence IS NOT NULL AND l_adj_tbl(j).pricing_group_sequence <> 0 THEN
		  IF l_bucket_adj_amt_tbl.EXISTS(l_adj_tbl(j).pricing_group_sequence) THEN -- avoid no data found or table index not exists for 1st rec
		    IF l_debug = FND_API.G_TRUE THEN
		      QP_PREQ_GRP.engine_debug ('    accumulated adj amts by bucket BEFORE: ' || l_bucket_adj_amt_tbl(l_adj_tbl(j).pricing_group_sequence));
		    END IF; -- end debug
		    l_bucket_adj_amt_tbl(l_adj_tbl(j).pricing_group_sequence):= nvl(l_bucket_adj_amt_tbl(l_adj_tbl(j).pricing_group_sequence),0) +
		      nvl(l_ldet_adj_amt_tbl(i),0)* l_adj_tbl(j).line_priced_quantity;

		  ELSE -- avoid no data found err
		    l_bucket_adj_amt_tbl(l_adj_tbl(j).pricing_group_sequence):= nvl(l_ldet_adj_amt_tbl(i),0) * l_adj_tbl(j).line_priced_quantity;
		  END IF; -- END IF l_bucket_adj_amt_tbl.EXISTS
		  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug ('    (LINEGROUP) building l_bucket_adj_amt_tbl by bucket: '||l_adj_tbl(j).pricing_group_sequence);
                    QP_PREQ_GRP.engine_debug ('    nvl of current unit adj: '||nvl(l_ldet_adj_amt_tbl(i), 0));
                    QP_PREQ_GRP.engine_debug ('    order qty: '||l_adj_tbl(j).line_priced_quantity);
                    QP_PREQ_GRP.engine_debug ('    accumulated adj amts for this bucket: ' || l_bucket_adj_amt_tbl(l_adj_tbl(j).pricing_group_sequence));
                  END IF; -- END debug

                  -- for LINE LEVEL
                  IF l_bucket_index_adj_tbl.EXISTS(l_adj_tbl(j).line_ind) THEN
                    IF l_debug = FND_API.G_TRUE THEN
		      QP_PREQ_GRP.engine_debug ('    accumulated unit adj by line BEFORE: ' || nvl(l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind), 0));
		    END IF; -- end debug
                    l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind) := nvl(l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind), 0) + nvl(l_ldet_adj_amt_tbl(i), 0);
		  ELSE -- avoid no datat found err
		    l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind) := nvl(l_ldet_adj_amt_tbl(i), 0);
		  END IF; -- END IF l_bucket_index_adj_tbl.EXISTS
		  IF l_debug = FND_API.G_TRUE THEN
		      QP_PREQ_GRP.engine_debug ('    (LINE) building l_bucket_index_adj_tbl for line_index: '||l_adj_tbl(j).line_ind);
		      QP_PREQ_GRP.engine_debug ('    accumulated unit adjs by line index: '||l_bucket_index_adj_tbl(l_adj_tbl(j).line_ind));
		  END IF; -- END debug
		END IF; -- END IF bucket is not null and 0

		-- end 2892848
  */
        /* out 2892848
                --begin net_amount, 2720717
                l_pbh_net_adj_amount := l_pbh_net_adj_amount + l_ldet_adj_amt_tbl(i);
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('------ ');
                  QP_PREQ_GRP.engine_debug('i: '||i);
                  QP_PREQ_GRP.engine_debug('l_ldet_adj_amt_tbl(i): '||l_ldet_adj_amt_tbl(i));
                  QP_PREQ_GRP.engine_debug('l_pbh_net_adj_amount: '||l_pbh_net_adj_amount);
                END IF; --END IF l_debug
                --end net_amount, 2720717
                */

        IF l_adj_tbl(j).calculation_code = G_BACK_CALCULATE THEN
          l_back_calc_dtl_index(l_adj_tbl(j).line_ind)
          := l_adj_tbl(j).line_detail_index;
          l_back_calc_adj_amt(l_adj_tbl(j).line_ind)
          := nvl(l_return_adjustment, 0);
          l_back_calc_plsql_tbl_index(l_adj_tbl(j).line_ind)
          := i;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Back calc line index '
                                     || l_back_calc_dtl_index(l_adj_tbl(j).line_ind)
                                     ||' adjamt '|| l_back_calc_adj_amt(l_adj_tbl(j).line_ind)
                                     ||' plsql ind '
                                     || l_back_calc_plsql_tbl_index(l_adj_tbl(j).line_ind));
          END IF; --l_debug
        END IF; --l_adj_tbl(j).calculation_code

        --this procedure is called to calculate the
        --selling_price,adjustment_amount and operand in ordered_qty
        --which is the line_quantity on lines_tmp
        -- Ravi bug# 2745337-divisor by zero
        IF (l_adj_tbl(j).ordered_qty <> 0 OR l_adj_tbl(j).modifier_level_code = 'ORDER') THEN
          IF (l_debug = FND_API.G_TRUE) THEN
            QP_PREQ_GRP.engine_debug('Before Going into GET_ORDERQTY_VALUES #1');
          END IF;
          GET_ORDERQTY_VALUES(p_ordered_qty => l_adj_tbl(j).ordered_qty,
                              p_priced_qty => l_adj_tbl(j).line_priced_quantity,
                              p_catchweight_qty => l_adj_tbl(j).catchweight_qty,
                              p_actual_order_qty => l_adj_tbl(j).actual_order_qty,
                              p_operand => l_adj_tbl(j).operand_value,
                              p_adjustment_amt => l_ldet_adj_amt_tbl(i),
                              p_unit_price => l_adj_tbl(j).unit_price,
                              p_adjusted_unit_price => l_sub_total_price,
                              p_operand_calculation_code => l_adj_tbl(j).operand_calculation_code,
                              p_input_type => 'OPERAND',
                              x_ordqty_output1 => l_ldet_ordqty_operand_tbl(i),
                              x_ordqty_output2 => l_ldet_ordqty_adjamt_tbl(i),
                              x_return_status => x_return_status,
                              x_return_status_text => x_return_status_text);
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Ordered Qty #1: ' || l_adj_tbl(j).ordered_qty);
            QP_PREQ_GRP.engine_debug('OPERAND Ordered Qty is 0 or modifier level code is not ORDER');
          END IF;
          l_ldet_ordqty_operand_tbl(i) := 0;
          l_ldet_ordqty_adjamt_tbl(i) := 0;
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Printing ordqty_operand '
                                   || l_ldet_ordqty_operand_tbl(i) ||' ordqty_adjamt '
                                   || l_ldet_ordqty_adjamt_tbl(i));
        END IF; --l_debug

        --round the adjustment_amount with factor on the line
        --engine updates the factor on the line
        --w/nvl(user_passed,price_list rounding_factor)
        IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
          AND l_adj_tbl(j).rounding_factor IS NOT NULL
          THEN
          l_ldet_adj_amt_tbl(i) :=
          round(l_ldet_adj_amt_tbl(i),
                ( - 1 * l_adj_tbl(j).rounding_factor));
          l_ldet_ordqty_adjamt_tbl(i) :=
          round(l_ldet_ordqty_adjamt_tbl(i),
                ( - 1 * l_adj_tbl(j).rounding_factor));
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('rounded adj: '|| l_ldet_adj_amt_tbl(i) ||
                                   ' rounding fac '|| l_adj_tbl(j).rounding_factor ||
                                   ' ordqty_adjamt '|| l_ldet_ordqty_adjamt_tbl(i) ||
                                   ' '|| l_adj_tbl(j).curr_line_index ||' '|| l_adj_tbl(j).line_ind ||
                                   ' is_ldet_rec '|| l_adj_tbl(j).is_ldet_rec ||
                                   ' linetypecode '|| l_adj_tbl(j).line_type_code);

        END IF;

        l_ldet_process_code_tbl(i) := l_adj_tbl(j).process_code;
        l_ldet_calc_code_tbl(i) := l_adj_tbl(j).calculation_code;
        l_ldet_updated_flag_tbl(i) := l_adj_tbl(j).updated_flag;
        l_ldet_operand_value_tbl(i) := l_adj_tbl(j).operand_value;
        l_ldet_price_break_type_tbl(i) := l_adj_tbl(j).price_break_type_code;
        l_ldet_operand_calc_tbl(i) := l_adj_tbl(j).operand_calculation_code;
        l_ldet_pricing_grp_seq_tbl(i) := l_adj_tbl(j).pricing_group_sequence;
        l_ldet_list_type_code_tbl(i) := l_adj_tbl(j).created_from_list_type_code;
        l_ldet_limit_code_tbl(i) := l_adj_tbl(j).limit_code;
        l_ldet_limit_text_tbl(i) := l_adj_tbl(j).limit_text;
        l_ldet_list_line_no_tbl(i) := l_adj_tbl(j).list_line_no;
        l_ldet_charge_type_tbl(i) := l_adj_tbl(j).charge_type_code;
        l_ldet_charge_subtype_tbl(i) := l_adj_tbl(j).charge_subtype_code;
        l_ldet_pricing_phase_id_tbl(i) := l_adj_tbl(j).pricing_phase_id;
        l_ldet_automatic_flag_tbl(i) := l_adj_tbl(j).automatic_flag;
        l_ldet_modifier_level_tbl(i) := l_adj_tbl(j).modifier_level_code;
        --to store gro/line qty in line qty based on mod level
        --l_ldet_line_quantity_tbl(i) := nvl(l_calc_quantity,1);  -- 40,SHU, this is inconsistent with PL/SQL path
        l_ldet_line_quantity_tbl(i) := l_adj_tbl(j).priced_quantity; -- -- 2388011, SHU FIX diff PRIYA,to be the same as PL/SQL path
        l_ldet_is_max_frt_tbl(i) := G_NO;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('adjusted amt 4 ');

          QP_PREQ_GRP.engine_debug('Returned adj : '|| i
                                   ||' line detail index '|| l_ldet_line_dtl_index_tbl(i)
                                   ||' adj amt '|| l_ldet_adj_amt_tbl(i));


        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Calc Error');
          END IF;
          l_ldet_pricing_sts_code_tbl(i) := G_STATUS_CALC_ERROR;
          l_ldet_pricing_sts_txt_tbl(i) := l_return_status_text;
          l_ldet_applied_flag_tbl(i) := G_NO;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Calc Succ');
          END IF;
          l_ldet_pricing_sts_code_tbl(i) :=
          l_adj_tbl(j).pricing_status_code;
          IF l_adj_tbl(j).pricing_status_code = G_STATUS_UNCHANGED
            AND l_adj_tbl(j).is_ldet_rec IN (G_ASO_ORDER_TYPE,
                                             G_ASO_LINE_TYPE)
            THEN
            l_ldet_pricing_sts_code_tbl(i) := G_STATUS_NEW;
          END IF;
          --manual frt charges should not have appl flag YES
          --and manual adj which are updated and applied shdbe app
          --should retain applied flag as when auto overr adj
          --are deleted OM Int makes applied 'N' and updated
          --'Y' and does not physically delete records
          l_ldet_applied_flag_tbl(i) :=
          l_adj_tbl(j).applied_flag;
          /*
			IF nvl(l_adj_tbl(j).automatic_flag,G_NO) = G_YES
			or (nvl(l_adj_tbl(j).applied_flag,G_NO) = G_YES
                        and nvl(l_adj_tbl(j).updated_flag,G_NO) = G_YES)
			THEN
                        l_ldet_applied_flag_tbl(i) := G_YES;
			ELSE
                        l_ldet_applied_flag_tbl(i) := G_NO;
			END IF;
*/
          l_ldet_pricing_sts_txt_tbl(i) :=
          l_adj_tbl(j).pricing_status_text;
        END IF; --l_return_status = FND_API.G_RET_STS_ERROR

        IF l_adj_tbl(j).created_from_list_line_type = G_FREIGHT_CHARGE
          AND nvl(l_adj_tbl(j).automatic_flag, G_NO) = G_YES
          AND l_adj_tbl(j).pricing_status_code IN
          (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED)
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('looping thru FRT for list_line id '
                                     || l_adj_tbl(j).created_from_list_line_id ||' adj amt '
                                     || l_ldet_adj_amt_tbl(i) ||' upd '
                                     || l_adj_tbl(j).updated_flag
                                     ||' level '|| l_adj_tbl(j).modifier_level_code);
          END IF;
          l_ldet_pricing_sts_code_tbl(i) := G_STATUS_DELETED;
          l_ldet_pricing_sts_txt_tbl(i) := G_NOT_MAX_FRT_CHARGE;

          IF l_frt_tbl.COUNT = 0
            THEN
            --no record for charge type subtype combn
            --so insert into l_frt_tbl
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('No frtcharge in tbl: insert rec');
            END IF;
            l_frt_tbl(1).line_index := l_adj_tbl(j).line_ind;
            l_frt_tbl(1).line_detail_index :=
            l_adj_tbl(j).line_detail_index;
            l_frt_tbl(1).created_from_list_line_id :=
            l_adj_tbl(j).created_from_list_line_id;
            l_frt_tbl(1).adjustment_amount :=
            l_ldet_adj_amt_tbl(i);
            l_frt_tbl(1).charge_type_code :=
            l_adj_tbl(j).charge_type_code;
            l_frt_tbl(1).charge_subtype_code :=
            l_adj_tbl(j).charge_subtype_code;
            l_frt_tbl(1).updated_flag :=
            nvl(l_adj_tbl(j).updated_flag, G_NO);
            --this is to show if a frt rec is max or not
            l_ldet_is_max_frt_tbl(i) := G_YES;
            IF l_adj_tbl(j).modifier_level_code IN
              (G_LINE_LEVEL, G_LINE_GROUP)
              THEN
              l_frt_tbl(1).LEVEL := G_LINE_LEVEL;
            ELSIF l_adj_tbl(j).modifier_level_code = G_ORDER_LEVEL
              THEN
              l_frt_tbl(1).LEVEL := G_ORDER_LEVEL;
            END IF;
          ELSIF l_frt_tbl.COUNT > 0
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('frtchrg records exist');

            END IF;
            FOR N IN l_frt_tbl.FIRST..l_frt_tbl.LAST
              LOOP
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('existing frt record id '
                                         || l_frt_tbl(N).created_from_list_line_id
                                         ||' level '|| l_frt_tbl(N).LEVEL);

              END IF;
              IF l_adj_tbl(j).line_ind = l_frt_tbl(N).line_index AND
                nvl(l_adj_tbl(j).charge_type_code, 'NULL') =
                nvl(l_frt_tbl(N).charge_type_code, 'NULL') AND
                nvl(l_adj_tbl(j).charge_subtype_code, 'NULL') =
                nvl(l_frt_tbl(N).charge_subtype_code, 'NULL') AND
                (l_frt_tbl(N).LEVEL = l_adj_tbl(j).modifier_level_code
                 OR (l_frt_tbl(N).LEVEL = G_LINE_LEVEL AND
                     l_adj_tbl(j).modifier_level_code = G_LINE_GROUP))
                THEN
                --record exists for charge type subtype combn
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('charge combn match');

                END IF;
                IF nvl(l_frt_tbl(N).updated_flag, G_NO) = G_NO
                  THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Rec is NOT overriden');
                  END IF;
                  --only if user has not overridden
                  --replace the record with the ct adj

                  IF nvl(l_adj_tbl(j).updated_flag, G_NO) = G_YES
                    THEN
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('Repl overridden rec');
                    END IF;
                    --if ct adj is overridden
                    l_frt_tbl(N).line_detail_index
                    := l_adj_tbl(j).line_detail_index;
                    l_frt_tbl(N).created_from_list_line_id :=
                    l_adj_tbl(j).created_from_list_line_id;
                    l_frt_tbl(N).line_index
                    := l_adj_tbl(j).line_ind;
                    l_frt_tbl(N).adjustment_amount
                    := l_ldet_adj_amt_tbl(i);
                    l_frt_tbl(N).updated_flag
                    := l_adj_tbl(j).updated_flag;
                    --this is to show if a frt rec is max or not
                    l_ldet_is_max_frt_tbl(i) := G_YES;
                  ELSIF nvl(l_adj_tbl(j).updated_flag, G_NO) = G_NO
                    AND l_ldet_adj_amt_tbl(i)
                    > l_frt_tbl(N).adjustment_amount
                    THEN
                    --if ct adj's adj amt is greater
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('replace high adjamt');
                    END IF;
                    l_frt_tbl(N).line_detail_index
                    := l_adj_tbl(j).line_detail_index;
                    l_frt_tbl(N).created_from_list_line_id
                    := l_adj_tbl(j).created_from_list_line_id;
                    l_frt_tbl(N).line_index
                    := l_adj_tbl(j).line_ind;
                    l_frt_tbl(N).adjustment_amount
                    := l_ldet_adj_amt_tbl(i);
                    l_frt_tbl(N).updated_flag
                    := l_adj_tbl(j).updated_flag;
                    --this is to show if a frt rec is max or not
                    l_ldet_is_max_frt_tbl(i) := G_YES;
                  END IF; --l_adj_tbl(j).updated_flag

                END IF; --frt_tbl.updated_flag
                EXIT;
              ELSE
                --no match for charge type subtype combn
                --so insert into l_frt_tbl
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('charge combn no match');

                END IF;
                IF N = l_frt_tbl.LAST
                  THEN
                  --this is the last record and the
                  --charge type subtype combn not match
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('lastrec:insert new record');
                  END IF;
                  l_frt_tbl(N + 1).line_index :=
                  l_adj_tbl(j).line_ind;
                  l_frt_tbl(N + 1).line_detail_index :=
                  l_adj_tbl(j).line_detail_index;
                  l_frt_tbl(N + 1).created_from_list_line_id :=
                  l_adj_tbl(j).created_from_list_line_id;
                  l_frt_tbl(N + 1).adjustment_amount :=
                  l_ldet_adj_amt_tbl(i);
                  l_frt_tbl(N + 1).charge_type_code :=
                  l_adj_tbl(j).charge_type_code;
                  l_frt_tbl(N + 1).charge_subtype_code :=
                  l_adj_tbl(j).charge_subtype_code;
                  l_frt_tbl(N + 1).updated_flag :=
                  nvl(l_adj_tbl(j).updated_flag, G_NO);
                  IF l_adj_tbl(j).modifier_level_code IN
                    (G_LINE_LEVEL, G_LINE_GROUP)
                    THEN
                    l_frt_tbl(N + 1).LEVEL := G_LINE_LEVEL;
                  ELSIF l_adj_tbl(j).modifier_level_code =
                    G_ORDER_LEVEL
                    THEN
                    l_frt_tbl(N + 1).LEVEL := G_ORDER_LEVEL;
                  END IF;
                  --this is to show if a frt rec is max or not
                  l_ldet_is_max_frt_tbl(i) := G_YES;
                END IF; --last rec of frt_tbl
              END IF; --matching charge_type/subtype

            END LOOP; --loop thru the frt tbl
          END IF; --frt charge tbl count

        END IF; --created_from_list_line_type


      END IF; --is_ldet_rec

      -------------------------------------------------------------------------------
      --code added to calculate adj amt on order lvl adj
      --fix for bug 1767249
      IF l_adj_tbl(j).modifier_level_code =
        G_ORDER_LEVEL
        AND l_adj_tbl(j).created_from_list_line_type
        <> G_FREIGHT_CHARGE
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('ord lvl adj processing '
                                   || l_adj_tbl(j).modifier_level_code ||' listlineid '
                                   || l_adj_tbl(j).created_from_list_line_id ||' adj '
                                   || l_return_adjustment ||'qty '
                                   || l_adj_tbl(j).line_priced_quantity);
        END IF;
        IF l_ord_dtl_index_tbl.COUNT = 0
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('ord lvl firstrec');
          END IF;
          l_ord_dtl_index_tbl(1) :=
          l_adj_tbl(j).line_detail_index;
          --fix for bug2424931 multiply by priced_qty
          l_ord_adj_amt_tbl(1) :=
          nvl(l_return_adjustment, 0) *
          nvl(l_adj_tbl(j).line_priced_quantity, 0);

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('ord lvl1');
            QP_PREQ_GRP.engine_debug('ord lvl2'
                                     || l_adj_tbl(j).line_priced_quantity);
            QP_PREQ_GRP.engine_debug('ord lvl3'
                                     || l_adj_tbl(j).ordered_qty);
            QP_PREQ_GRP.engine_debug('ord lvl4'
                                     || l_adj_tbl(j).catchweight_qty);
            QP_PREQ_GRP.engine_debug('ord lvl5'
                                     || l_adj_tbl(j).actual_order_qty);
            QP_PREQ_GRP.engine_debug('ord lvl6'
                                     || l_adj_tbl(j).operand_value);
            QP_PREQ_GRP.engine_debug('ord lvl7'
                                     || l_adj_tbl(j).unit_price);
            QP_PREQ_GRP.engine_debug('ord lvl8'
                                     || l_adj_tbl(j).operand_calculation_code);
            QP_PREQ_GRP.engine_debug('ord lvl9'
                                     || l_return_adjustment);
            QP_PREQ_GRP.engine_debug('ord lvl10'
                                     || l_sub_total_price);
          END IF; --l_debug

          --l_ord_qty_adj_amt_tbl
          l_ord_qty_adj_amt := 0;
          l_ord_qty_operand := 0;
          GET_ORDERQTY_VALUES(
                              p_ordered_qty => l_adj_tbl(j).ordered_qty,
                              p_priced_qty =>
                              l_adj_tbl(j).line_priced_quantity,
                              p_catchweight_qty =>
                              l_adj_tbl(j).catchweight_qty,
                              p_actual_order_qty =>
                              l_adj_tbl(j).actual_order_qty,
                              p_operand => l_adj_tbl(j).operand_value,
                              p_adjustment_amt => nvl(l_return_adjustment, 0),
                              p_unit_price => l_adj_tbl(j).unit_price,
                              p_adjusted_unit_price => l_sub_total_price,
                              p_operand_calculation_code =>
                              l_adj_tbl(j).operand_calculation_code,
                              p_input_type => 'OPERAND',
                              x_ordqty_output1 => l_ord_qty_operand,
                              x_ordqty_output2 => l_ord_qty_adj_amt,
                              x_return_status => x_return_status,
                              x_return_status_text => x_return_status_text);

          l_ord_qty_operand_tbl(1) := l_ord_qty_operand;
          l_ord_qty_adj_amt_tbl(1) := l_ord_qty_adj_amt;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('ord lvl firstrec'
                                     ||' adjamt '|| l_ord_adj_amt_tbl(1)
                                     ||' ordqtyadjamt '|| l_ord_qty_adj_amt_tbl(1)
                                     ||' ordqtyoperand '|| l_ord_qty_operand_tbl(1));
          END IF;
        ELSE ---l_ord_dtl_index_tbl.COUNT
          FOR n IN
            l_ord_dtl_index_tbl.FIRST..l_ord_dtl_index_tbl.LAST
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('ord lvl adj index '||
                                       l_ord_dtl_index_tbl(n) ||' current rec index '
                                       || l_adj_tbl(j).line_detail_index
                                       ||' count '|| l_ord_dtl_index_tbl.COUNT
                                       ||' lastrec dtl index '
                                       || l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.LAST))
              ;
            END IF;
            IF l_ord_dtl_index_tbl(n) =
              l_adj_tbl(j).line_detail_index
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('found match '
                                         ||' ct adjamt '|| l_ord_adj_amt_tbl(n));
              END IF;
              --fix for bug2424931 multiply by priced_qty
              l_ord_adj_amt_tbl(n) := l_ord_adj_amt_tbl(n) +
              nvl(l_return_adjustment, 0) *
              nvl(l_adj_tbl(j).line_priced_quantity, 0);

              l_ord_qty_adj_amt := 0;
              l_ord_qty_operand := 0;

              --l_ord_qty_adj_amt_tbl
              GET_ORDERQTY_VALUES(
                                  p_ordered_qty => l_adj_tbl(j).ordered_qty,
                                  p_priced_qty =>
                                  l_adj_tbl(j).line_priced_quantity,
                                  p_catchweight_qty =>
                                  l_adj_tbl(j).catchweight_qty,
                                  p_actual_order_qty =>
                                  l_adj_tbl(j).actual_order_qty,
                                  p_operand => l_adj_tbl(j).operand_value,
                                  p_adjustment_amt => nvl(l_return_adjustment, 0),
                                  p_unit_price => l_adj_tbl(j).unit_price,
                                  p_adjusted_unit_price => l_sub_total_price,
                                  p_operand_calculation_code =>
                                  l_adj_tbl(j).operand_calculation_code,
                                  p_input_type => 'OPERAND',
                                  x_ordqty_output1 => l_ord_qty_operand,
                                  x_ordqty_output2 => l_ord_qty_adj_amt,
                                  x_return_status => x_return_status,
                                  x_return_status_text => x_return_status_text);

              l_ord_qty_adj_amt_tbl(n) :=
              l_ord_qty_adj_amt_tbl(n) + l_ord_qty_adj_amt;
              l_ord_qty_operand_tbl(n) := l_ord_qty_operand;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl adj amt '||
                                         l_ord_adj_amt_tbl(n)
                                         ||' ordqtyadjamt '|| l_ord_qty_adj_amt_tbl(n)
                                         ||' ordqtyoperand '|| l_ord_qty_operand_tbl(n));
              END IF;
              EXIT; --exit the loop once matches
            ELSIF l_ord_dtl_index_tbl(n) =
              l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.LAST)
              AND l_ord_dtl_index_tbl(n) <>
              l_adj_tbl(j).line_detail_index
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl lastrec '||
                                         l_adj_tbl(j).line_detail_index ||' adjamt '
                                         || l_return_adjustment
                                         ||' qty '|| l_adj_tbl(j).line_priced_quantity);
              END IF;
              l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.COUNT + 1)
              := l_adj_tbl(j).line_detail_index;
              --fix for bug2424931 multiply by priced_qty
              l_ord_adj_amt_tbl(l_ord_dtl_index_tbl.COUNT)
              := nvl(l_return_adjustment, 0) *
              nvl(l_adj_tbl(j).line_priced_quantity, 0);

              --l_ord_qty_adj_amt_tbl
              l_ord_qty_adj_amt := 0;
              l_ord_qty_operand := 0;

              GET_ORDERQTY_VALUES(
                                  p_ordered_qty => l_adj_tbl(j).ordered_qty,
                                  p_priced_qty =>
                                  l_adj_tbl(j).line_priced_quantity,
                                  p_catchweight_qty =>
                                  l_adj_tbl(j).catchweight_qty,
                                  p_actual_order_qty =>
                                  l_adj_tbl(j).actual_order_qty,
                                  p_operand => l_adj_tbl(j).operand_value,
                                  p_adjustment_amt => nvl(l_return_adjustment, 0),
                                  p_unit_price => l_adj_tbl(j).unit_price,
                                  p_adjusted_unit_price => l_sub_total_price,
                                  p_operand_calculation_code =>
                                  l_adj_tbl(j).operand_calculation_code,
                                  p_input_type => 'OPERAND',
                                  x_ordqty_output1 => l_ord_qty_operand,
                                  x_ordqty_output2 => l_ord_qty_adj_amt,
                                  x_return_status => x_return_status,
                                  x_return_status_text => x_return_status_text);

              l_ord_qty_operand_tbl(l_ord_dtl_index_tbl.COUNT)
              := l_ord_qty_operand;
              l_ord_qty_adj_amt_tbl(l_ord_dtl_index_tbl.COUNT)
              := l_ord_qty_adj_amt;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl lastadjamt '||
                                         l_ord_adj_amt_tbl(l_ord_dtl_index_tbl.COUNT));
              END IF;
            END IF; -----l_ord_dtl_index_tbl(n)
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('ord lvl adj:dtlindex '
                                       || l_ord_dtl_index_tbl(n) ||' adj amt '
                                       || l_ord_adj_amt_tbl(n)
                                       ||' ordqtyadjamt '|| l_ord_qty_adj_amt_tbl(n)
                                       ||' ordqtyoperand '|| l_ord_qty_operand_tbl(n));
            END IF;
          END LOOP; --l_ord_dtl_index_tbl
        END IF; --l_ord_dtl_index_tbl.COUNT
      END IF; --order level
      -------------------------------------------------------------------------------

      IF l_adj_tbl(j).created_from_list_line_type IN
        (G_DISCOUNT, G_SURCHARGE, G_PRICE_BREAK_TYPE)
        AND l_adj_tbl(j).pricing_status_code IN
        (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED)
        --added for auto overr deleted adj
        AND l_adj_tbl(j).applied_flag = G_YES
        AND nvl(l_adj_tbl(j).accrual_flag, G_NO) = G_NO
        THEN
        --Update the adjustment amount for each adjustment
        -- 2892848_latest
        -- so we have correct current USP, considered each adj shall be rounded
        IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
          AND l_adj_tbl(j).rounding_factor IS NOT NULL
          THEN
          l_return_adjustment := round (l_return_adjustment,  - 1 * l_adj_tbl(j).rounding_factor);
        END IF; -- end rounding
        -- end 2892848_latest
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('prev USP: '|| l_adjusted_price);
          QP_PREQ_GRP.engine_debug('current adjustment: '|| l_return_adjustment);
        END IF;

        l_adjusted_price := l_adjusted_price + nvl(l_return_adjustment, 0);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('adjusted price, i.e. current USP : '|| l_adjusted_price); -- 2892848, good place to debug current USP
        END IF;
      END IF; --created_from_list_line_type

      IF l_debug = FND_API.G_TRUE THEN

        QP_PREQ_GRP.engine_debug('Processed lines: line index'
                                 || l_adj_tbl(j).line_ind ||' adjusted price '
                                 --||l_adj_tbl(j).updated_adjusted_unit_price -- 2892848
                                 || l_adjusted_price -- 2892848
                                 ||' adjustment count '|| l_ldet_line_dtl_index_tbl.COUNT);

      END IF;

      -- begin 3126019 , this x loop cannot have gap for bulk insert later
      -- therefore we cannot do	x:=l_adj_tbl(j).line_ind;
      /* out 2892848*/

      IF line_change = TRUE
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line change ');
        END IF;

        --[julin/5025231]
        --x := x + 1;
        IF l_line_ind_ind_lookup_tbl.exists(l_adj_tbl(j).line_ind) THEN
          x := l_line_ind_ind_lookup_tbl(l_adj_tbl(j).line_ind);
        ELSE
          x := l_line_ind_ind_lookup_tbl.count + 1;
          l_line_ind_ind_lookup_tbl(l_adj_tbl(j).line_ind) := x;
        END IF;
      END IF;



      --x:=l_adj_tbl(j).line_ind; -- 2892848, 3126019

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Update the adjustment amount for each adjustment...');
        QP_PREQ_GRP.engine_debug('line_ind: '|| l_adj_tbl(j).line_ind);
        QP_PREQ_GRP.engine_debug('changing price in line_tbl('|| x || ')');

      END IF;
      --Update the adjustment amount for each adjustment
      l_line_index_tbl(x) := l_adj_tbl(j).line_ind;
      l_adj_unit_price_tbl(x) := l_adjusted_price;
      l_unit_price_tbl(x) := l_adj_tbl(j).unit_price;
      l_amount_changed_tbl(x) := l_adj_tbl(j).amount_changed;
      l_upd_adj_unit_price_tbl(x) :=
      l_adj_tbl(j).updated_adjusted_unit_price;

      --netamt tbls, 3126019
      l_ntamt_adj_unit_price(l_line_index_tbl(x)) := l_adj_unit_price_tbl(x); -- 3126019


      -- Ravi
      l_ordered_qty_tbl(x) := l_adj_tbl(j).ordered_qty;
      l_line_unit_price_tbl(x) := l_adj_tbl(j).line_unit_price;
      l_line_priced_qty_tbl(x) := l_adj_tbl(j).line_priced_quantity;
      l_catchweight_qty_tbl(x) := l_adj_tbl(j).catchweight_qty;
      l_actual_order_qty_tbl(x) := l_adj_tbl(j).actual_order_qty;
      -- End Ravi

      -- Ravi bug# 2745337-divisor by zero
      IF (l_adj_tbl(j).ordered_qty <> 0 OR l_adj_tbl(j).modifier_level_code = 'ORDER') THEN
        IF (l_debug = FND_API.G_TRUE) THEN
          QP_PREQ_GRP.engine_debug('Before Going into GET_ORDERQTY_VALUES #2');
        END IF;
        GET_ORDERQTY_VALUES(p_ordered_qty => l_adj_tbl(j).ordered_qty,
                            p_priced_qty => l_adj_tbl(j).line_priced_quantity,
                            p_catchweight_qty => l_adj_tbl(j).catchweight_qty,
                            p_actual_order_qty => l_adj_tbl(j).actual_order_qty,
                            p_unit_price => l_adj_tbl(j).unit_price,
                            p_adjusted_unit_price => l_adj_unit_price_tbl(x),
                            p_line_unit_price => l_adj_tbl(j).line_unit_price,
                            p_input_type => 'SELLING_PRICE',
                            x_ordqty_output1 => l_ordqty_unit_price_tbl(x),
                            x_ordqty_output2 => l_ordqty_selling_price_tbl(x),
                            x_return_status => x_return_status,
                            x_return_status_text => x_return_status_text);
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Ordered Qty #2 : ' || l_adj_tbl(j).ordered_qty);
          QP_PREQ_GRP.engine_debug('SELLING PRICE Ordered Qty is 0 or modifier level code is not ORDER');
        END IF;
        l_ordqty_unit_price_tbl(x) := 0;
        l_ordqty_selling_price_tbl(x) := 0;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Printing ordqty_selling_price '
                                 || l_ordqty_selling_price_tbl(x) ||' unit_price '
                                 || l_ordqty_unit_price_tbl(x));
      END IF; --l_debug

      --If PUB API fetches any out of phase or manual adjustments
      --pricing sts code on the line must be UPDATED
      --and should remain same otherwise
      --This change done because when manual adj are applied,
      --GRP puts pricing sts as UNCHANGED and OM Integration
      --will not change the new selling price
      IF l_adj_tbl(j).line_pricing_status_code <> G_STATUS_UPDATED
        AND l_adj_tbl(j).PROCESS_CODE = G_STATUS_UPDATED
        THEN
        l_pricing_sts_code_tbl(x) := G_STATUS_UPDATED;
      ELSE
        l_pricing_sts_code_tbl(x) :=
        l_adj_tbl(j).line_pricing_status_code;
      END IF;
      l_pricing_sts_txt_tbl(x) := l_adj_tbl(j).pricing_status_text;
      l_rounding_factor_tbl(x) := l_adj_tbl(j).rounding_factor;

      --round the selling price if ROUND_INDIVIDUAL_ADJ profile is N
      --in this case the adjustment_amt will not be rounded
      --IF G_ROUND_INDIVIDUAL_ADJ = G_NO_ROUND_ADJ

      /* 2892848_latest
		-- we should round adjs, move rounding ahead
		IF G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND -- shu fix bug 2239061
		-- this is not the final USP since now we order by bucket

		and l_rounding_factor_tbl(x) IS NOT NULL
		THEN
  IF l_debug = FND_API.G_TRUE THEN
		QP_PREQ_GRP.engine_debug('need to round selling price, rounding factor: '
					||l_rounding_factor_tbl(x));
  END IF;
		  l_adj_unit_price_tbl(x) :=
		  round(l_adj_unit_price_tbl(x),-1*l_rounding_factor_tbl(x));
		  l_ordqty_selling_price_tbl(x) :=
		  round(l_ordqty_selling_price_tbl(x),-1*l_rounding_factor_tbl(x));
		  l_ordqty_unit_price_tbl(x) :=
		  round(l_ordqty_unit_price_tbl(x),-1*l_rounding_factor_tbl(x));
		END IF;
		*/

      --This is for prg to get the oldfgline's selling price

      IF G_PRG_UNCH_LINE_IND_TBL.EXISTS(l_line_index_tbl(x)) THEN
        --fix for bug 2831270
        G_PRG_UNCH_CALC_PRICE_TBL(G_PRG_UNCH_LINE_IND_TBL(l_line_index_tbl(x))) :=
        l_adj_unit_price_tbl(x);

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('oldfgline line ind '
                                   || l_line_index_tbl(x) ||' adjprice '
                                   || G_PRG_UNCH_CALC_PRICE_TBL(G_PRG_UNCH_LINE_IND_TBL(l_line_index_tbl(x))));
        END IF; --l_debug
      END IF; --G_PRG_UNCH_LINE_IND_TBL

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('price in line_tbl'
                                 ||' table index '|| x
                                 ||' line index '|| l_line_index_tbl(x)
                                 ||' adjusted price '|| l_adj_unit_price_tbl(x)
                                 ||' orduomsellingprice '|| l_ordqty_selling_price_tbl(x)
                                 ||' lineunitprice '|| l_ordqty_unit_price_tbl(x)
                                 ||' amt changed '|| l_amount_changed_tbl(x));



        QP_PREQ_GRP.engine_debug('going to next line --------------'
                                 || i ||' x '|| x);
      END IF;
      J := l_adj_tbl.NEXT(j);
    END LOOP;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('----------------------------------');

    END IF;
    IF l_frt_tbl.COUNT > 0
      OR l_ldet_line_dtl_index_tbl.COUNT > 0
      THEN
      x := l_ldet_line_dtl_index_tbl.FIRST;
      WHILE x IS NOT NULL
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('frt charge processing  listlineid1 ');
          QP_PREQ_GRP.engine_debug('frt charge processing  listlineid '
                                   || l_ldet_line_dtl_index_tbl(x) ||' type '
                                   || l_ldet_list_line_type_tbl(x) ||' is max frt ');
        END IF;
        --		||l_ldet_is_max_frt_tbl(x));

        --fix for bug2424931 update order lvl adj amt
        IF (l_debug = FND_API.G_TRUE) THEN
          QP_PREQ_GRP.engine_debug('Modifier Level : ' || l_ldet_modifier_level_tbl(x));
        END IF;

        IF l_ldet_modifier_level_tbl(x) = G_ORDER_LEVEL
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('update ord lvl adj amt '
                                     ||'looping thru dtlind '|| l_ldet_line_dtl_index_tbl(x));
          END IF;
          i := l_ord_dtl_index_tbl.FIRST;
          WHILE i IS NOT NULL
            LOOP
            IF l_ord_dtl_index_tbl(i) =
              l_ldet_line_dtl_index_tbl(x)
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('update ord lvl '
                                         ||' line_dtl_index '|| l_ord_dtl_index_tbl(i)
                                         ||'adj amt '|| l_ord_adj_amt_tbl(i));
              END IF;
              l_ldet_adj_amt_tbl(x) :=
              l_ord_adj_amt_tbl(i);
              l_ldet_ordqty_adjamt_tbl(x) :=
              l_ord_qty_adj_amt_tbl(i);
              l_ldet_ordqty_operand_tbl(x) :=
              l_ord_qty_operand_tbl(i);
              l_ord_dtl_index_tbl.DELETE(i);
              l_ord_adj_amt_tbl.DELETE(i);
            END IF; --l_ord_dtl_index_tbl
            i := l_ord_dtl_index_tbl.NEXT(i);
          END LOOP;
        END IF; --l_ldet_modifier_level_tbl

        IF l_ldet_list_line_type_tbl(x) = G_FREIGHT_CHARGE
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('frt charge processing  listlineid2 ');
          END IF;
          y := l_frt_tbl.FIRST;
          WHILE y IS NOT NULL
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('frt charge processing  listlineid3 ');
              QP_PREQ_GRP.engine_debug('l_ldet_line_index_tbl(x): '|| l_ldet_line_index_tbl(x));
            END IF;
            IF l_frt_tbl(y).line_detail_index =
              l_ldet_line_dtl_index_tbl(x)
              AND l_ldet_line_index_tbl(x) =  -- 2892848 fix bug,
              l_frt_tbl(y).line_index -- 2892848 fix bug
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('frt charge processing  listlineid4 ');
              END IF;
              l_ldet_pricing_sts_code_tbl(x) := G_STATUS_NEW;
              l_ldet_pricing_sts_txt_tbl(x) := 'MAX FRT CHARGE';
              l_frt_tbl.DELETE(y);
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('frt charge retaind '
                                         || l_ldet_list_line_id_tbl(x) ||' '
                                         || l_ldet_pricing_sts_code_tbl(x));
              END IF;
            END IF;
            y := l_frt_tbl.NEXT(y);
          END LOOP; --frt_tbl
        END IF; --frt_charge
        x := l_ldet_line_dtl_index_tbl.NEXT(x);
      END LOOP; --ldet_line_dtl_index_tbl
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('----------------------------------');
      END IF;
    END IF; --frt_tbl.count

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('----------------------------------');

    END IF;
    --**************************************************************
    --BACK CALCULATION ROUTINE
    --**************************************************************
    --xxxxxxxxxxxxxx

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('back calculation for line ');
    END IF;
    IF l_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('back calculation1 for line ');
      END IF;
      i := l_line_index_tbl.FIRST;
      WHILE i IS NOT NULL
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('back calculation2 for line '
                                   || l_amount_changed_tbl(i));
        END IF; --l_debug

        IF l_back_calc_dtl_index.EXISTS(l_line_index_tbl(i)) THEN
          l_back_calc_adj_amount := nvl(l_back_calc_adj_amt(l_line_index_tbl(i)), 0);
          l_back_calc_dtl_ind := nvl(l_back_calc_dtl_index(l_line_index_tbl(i)), 0);
          l_back_calc_plsql_index := l_back_calc_plsql_tbl_index(l_line_index_tbl(i));
        ELSE
          l_back_calc_adj_amount := 0;
          l_back_calc_dtl_ind := 0;
          l_back_calc_plsql_index := 0;
        END IF;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('prev back calculation rec '
                                   || l_back_calc_dtl_ind
                                   ||' plsql '|| l_back_calc_plsql_index
                                   ||' adj amt '|| l_back_calc_adj_amount);
        END IF; --l_debug

        --l_back_calc_adj_amt has to be subtracted from amount changed
        --as we want to back calculate the amount overridden now
        --as the adjustment l_back_calc_dtl_index has been applied
        --already during calculation
        IF l_upd_adj_unit_price_tbl(i) IS NOT NULL
          AND ((l_upd_adj_unit_price_tbl(i) -
                l_adj_unit_price_tbl(i)) <> 0)
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('back calculation for line '
                                     || l_line_index_tbl(i));

          END IF;
          --fix for bug 2146050
          IF G_ROUND_INDIVIDUAL_ADJ not in (G_NO_ROUND, G_POST_ROUND)
				  --[prarasto:Post Round] added check to skip rounding for Post Rounding
            AND l_rounding_factor_tbl(i) IS NOT NULL
            THEN
            l_upd_adj_unit_price_tbl(i) :=
            round(l_upd_adj_unit_price_tbl(i),
                  - 1 * l_rounding_factor_tbl(i));

            -- 2892848
            l_adj_unit_price_tbl(i) :=
            round(l_adj_unit_price_tbl(i),
                  - 1 * l_rounding_factor_tbl(i));
          END IF;

          --l_back_calc_adj_amt is added to remove the
          --adjustment applied earlier
          l_amount_changed_tbl(i) :=
          (l_upd_adj_unit_price_tbl(i) +
           l_back_calc_adj_amount)
          - l_adj_unit_price_tbl(i);

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('amt changed '
                                     || l_amount_changed_tbl(i));
          END IF; --l_debug

          IF l_amount_changed_tbl(i) <= 0 THEN
            G_BACK_CALCULATION_CODE := 'DIS';
          ELSE
            G_BACK_CALCULATION_CODE := 'SUR';
          END IF; --l_amount_changed_tbl

          BACK_CALCULATION(l_line_index_tbl(i)
                           , l_amount_changed_tbl(i)
                           , l_back_calc_ret_rec
                           , l_return_status
                           , l_return_status_text);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN

            --need to do this check for bug 2833753
            IF G_ldet_plsql_index_tbl.EXISTS(l_back_calc_ret_rec.line_detail_index) THEN
              --if this is an existing adjustment, need to update
              l_tbl_index := G_ldet_plsql_index_tbl(l_back_calc_ret_rec.line_detail_index);
            ELSE
              l_tbl_index := l_ldet_line_dtl_index_tbl.COUNT + 1;
            END IF; --G_ldet_plsql_index_tbl

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('back cal succ insert rec '
                                       || l_tbl_index);
            END IF;
            l_ldet_line_dtl_index_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.line_detail_index;
            l_ldet_line_index_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.line_index;
            l_ldet_list_line_id_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.list_line_id;
            l_ldet_applied_flag_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.applied_flag;
            l_ldet_updated_flag_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.updated_flag;
            l_ldet_adj_amt_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.adjustment_amount;
            l_ldet_operand_value_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.operand_value;
            l_ldet_process_code_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.process_code;
            l_ldet_pricing_sts_code_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.pricing_status_code;
            l_ldet_pricing_sts_txt_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.pricing_status_text;
            l_ldet_list_hdr_id_tbl(l_tbl_index) := NULL;
            l_ldet_list_line_type_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.list_line_type_code;
            l_ldet_line_quantity_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.line_quantity;
            l_ldet_process_code_tbl(l_tbl_index) :=
            G_STATUS_NEW;
            l_ldet_list_hdr_id_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.list_header_id;
            l_ldet_list_type_code_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.list_type_code;
            l_ldet_price_break_type_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.price_break_type_code;
            l_ldet_charge_type_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.charge_type_code;
            l_ldet_charge_subtype_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.charge_subtype_code;
            l_ldet_automatic_flag_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.automatic_flag;
            l_ldet_pricing_phase_id_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.pricing_phase_id;
            l_ldet_limit_code_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.limit_code;
            l_ldet_limit_text_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.limit_text;
            l_ldet_operand_calc_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.operand_calculation_code;
            l_ldet_pricing_grp_seq_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.pricing_group_sequence;
            l_ldet_list_line_no_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.list_line_no;
            l_ldet_calc_code_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.calculation_code;
            l_ldet_modifier_level_tbl(l_tbl_index) :=
            l_back_calc_ret_rec.modifier_level_code;

            --if a different adj is selected this time
            --need to mark the old one as deleted
            IF l_back_calc_ret_rec.line_detail_index <>
              l_back_calc_dtl_ind
              AND l_back_calc_plsql_index <> 0 THEN
              l_ldet_applied_flag_tbl(l_back_calc_plsql_index)
              := G_NO;
              l_ldet_calc_code_tbl(l_back_calc_plsql_index)
              := NULL;
              l_ldet_pricing_sts_code_tbl(l_back_calc_plsql_index)
              := G_STATUS_DELETED;
              l_ldet_pricing_sts_txt_tbl(l_back_calc_plsql_index)
              := 'DELETED IN BACK CALC';
            END IF; --l_back_calc_ret_rec.line_detail_index


            l_adj_unit_price_tbl(i) := l_upd_adj_unit_price_tbl(i);

            --fix for bug 2812738
            --changes to calculate the order_uom_selling_price
            IF (l_ordered_qty_tbl(i) <> 0
                OR l_ldet_modifier_level_tbl(l_tbl_index) =
                G_ORDER_LEVEL) THEN
              IF (l_debug = FND_API.G_TRUE) THEN
                QP_PREQ_GRP.engine_debug('Before Going into '
                                         ||'GET_ORDERQTY_VALUES #2.5');
              END IF; --l_debug
              GET_ORDERQTY_VALUES(p_ordered_qty =>
                                  l_ordered_qty_tbl(i),
                                  p_priced_qty => l_line_priced_qty_tbl(i),
                                  p_catchweight_qty => l_catchweight_qty_tbl(i),
                                  p_actual_order_qty => l_actual_order_qty_tbl(i),
                                  p_unit_price => l_unit_price_tbl(i),
                                  p_adjusted_unit_price => l_adj_unit_price_tbl(i),
                                  p_line_unit_price => l_line_unit_price_tbl(i),
                                  p_input_type => 'SELLING_PRICE',
                                  x_ordqty_output1 => l_ordqty_unit_price_tbl(i),
                                  x_ordqty_output2 => l_ordqty_selling_price_tbl(i),
                                  x_return_status => x_return_status,
                                  x_return_status_text => x_return_status_text);
            ELSE --ordered_qty
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Ordered Qty #2.5 : '
                                         || l_ordered_qty_tbl(i));
                QP_PREQ_GRP.engine_debug('SELLING PRICE Ordered Qty is '
                                         ||'0 or modifier level code is not ORDER');
              END IF; --l_debug
              l_ordqty_unit_price_tbl(i) := 0;
              l_ordqty_selling_price_tbl(i) := 0;
            END IF; --ordered_qty

            -- Ravi
            --this procedure is called to calculate the
            --selling_price,adjustment_amount and operand in ordered_qty
            --which is the line_quantity on lines_tmp
            -- This needs to be called for back calculated adj record,otherwise
            -- l_ldet_ordqty_operand_tbl and l_ldet_ordqty_adjamt_tbl data is not there
            -- and is failing with error element at index[5] does not exist error when
            -- trying to override the selling price

            -- Ravi bug# 2745337-divisor by zero
            IF (l_ordered_qty_tbl(i) <> 0
                OR l_ldet_modifier_level_tbl(l_tbl_index) =
                G_ORDER_LEVEL) THEN
              IF (l_debug = FND_API.G_TRUE) THEN
                QP_PREQ_GRP.engine_debug('Before Going into GET_ORDERQTY_VALUES #3');
              END IF;
              GET_ORDERQTY_VALUES(p_ordered_qty => l_ordered_qty_tbl(i),
                                  p_priced_qty => l_line_priced_qty_tbl(i),
                                  p_catchweight_qty => l_catchweight_qty_tbl(i),
                                  p_actual_order_qty => l_actual_order_qty_tbl(i),
                                  p_operand => l_ldet_operand_value_tbl(l_tbl_index),
                                  p_adjustment_amt => l_ldet_adj_amt_tbl(l_tbl_index),
                                  p_unit_price => l_unit_price_tbl(i),
                                  p_adjusted_unit_price => l_adj_unit_price_tbl(i),
                                  p_operand_calculation_code => l_ldet_operand_calc_tbl(l_tbl_index),
                                  p_input_type => 'OPERAND',
                                  x_ordqty_output1 => l_ldet_ordqty_operand_tbl(l_tbl_index),
                                  x_ordqty_output2 => l_ldet_ordqty_adjamt_tbl(l_tbl_index),
                                  x_return_status => x_return_status,
                                  x_return_status_text => x_return_status_text);
            ELSE
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Ordered Qty #3 : ' || l_ordered_qty_tbl(i));
                QP_PREQ_GRP.engine_debug('OPERAND Ordered Qty is 0 or modifier level code is not ORDER');
              END IF;
              l_ldet_ordqty_operand_tbl(l_tbl_index) := 0;
              l_ldet_ordqty_adjamt_tbl(l_tbl_index) := 0;
            END IF;

            -- End Ravi

            --fix for bug 2146050 to round adjustment amt
            IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
              AND l_rounding_factor_tbl(i) IS NOT NULL
              THEN
              l_ldet_adj_amt_tbl(l_tbl_index) :=
              round(l_ldet_adj_amt_tbl(l_tbl_index),
                    - 1 * l_rounding_factor_tbl(i));
              l_ldet_ordqty_adjamt_tbl(l_tbl_index) :=
              round(l_ldet_ordqty_adjamt_tbl(l_tbl_index),
                    - 1 * l_rounding_factor_tbl(i));
            END IF;

            --round the selling price if ROUND_INDIVIDUAL_ADJ
            --profile is N in this case the adjustment_amt
            --will not be rounded
            IF G_ROUND_INDIVIDUAL_ADJ = G_NO_ROUND_ADJ -- 2892848_latest, not to round current USP for G_ROUND_ADJ case since it is not final USP yet
              --IF G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND -- shu fix 2239061
              AND l_rounding_factor_tbl(i) IS NOT NULL
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('need to round selling price, rounding factor: '
                                         || l_rounding_factor_tbl(i));
              END IF;
              l_adj_unit_price_tbl(i) :=
              round(l_adj_unit_price_tbl(i)
                    , - 1 * l_rounding_factor_tbl(i));
              l_ordqty_unit_price_tbl(i) :=
              round(l_ordqty_unit_price_tbl(i)
                    , - 1 * l_rounding_factor_tbl(i));
              l_ordqty_selling_price_tbl(i) :=
              round(l_ordqty_selling_price_tbl(i)
                    , - 1 * l_rounding_factor_tbl(i));
            END IF;

          ELSE --ret_status
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('back cal fail no insert rec');
            END IF;
            l_pricing_sts_code_tbl(i) := l_return_status;
            l_pricing_sts_txt_tbl(i) :=
            l_return_status_text;
          END IF; --ret_status
        END IF;
        i := l_line_index_tbl.NEXT(i);
      END LOOP;
    END IF; --count > 0
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('end back calc for line ');

    END IF;
    ---------------------------------------------------------------------
    --Debug Info
    ---------------------------------------------------------------------
    IF QP_PREQ_GRP.g_debug_engine = fnd_api.g_true
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('in debug --------------');
      END IF;
      j := l_line_index_tbl.FIRST;
      WHILE j IS NOT NULL
        LOOP
        -- begin 2892848_latest
        /* commented out for bug 3663518
			  	IF G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND -- 2892848_latest, round finalUSP
                	AND l_rounding_factor_tbl(j) IS NOT NULL THEN

					l_adj_unit_price_tbl(j) := round(l_adj_unit_price_tbl(j)
				         ,-1*l_rounding_factor_tbl(j));

					l_ordqty_unit_price_tbl(j) := round(l_ordqty_unit_price_tbl(j)
				      ,-1*l_rounding_factor_tbl(j));

					l_ordqty_selling_price_tbl(j) := round(l_ordqty_selling_price_tbl(j)
				       ,-1*l_rounding_factor_tbl(j));
				END IF; -- end rounding 2892848
                        */

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('(No final rounding) Line Info '|| j
                                   ||' line index '|| l_line_index_tbl(j)
                                   ||' unit price '|| l_unit_price_tbl(j)
                                   ||' final adjusted_unit_price '|| l_adj_unit_price_tbl(j)
                                   ||' pricing_status_code '|| l_pricing_sts_code_tbl(j)
                                   ||' pricing_status_text '|| l_pricing_sts_txt_tbl(j));
        END IF;
        --			||' processed_flag '||l_processed_flag_tbl(j));
        --			||' processed_code '||l_processed_code_tbl(j));
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('----------------------------------');
        END IF;
        i := l_ldet_line_dtl_index_tbl.FIRST;
        WHILE i IS NOT NULL
          LOOP
          IF l_line_index_tbl(j) = l_ldet_line_index_tbl(i)
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('Line detail Info '|| i
                                       ||' line detail index '|| l_ldet_line_dtl_index_tbl(i)
                                       ||' list_line_id '|| l_ldet_list_line_id_tbl(i)
                                       ||' operand '|| l_ldet_operand_value_tbl(i)
                                       ||' adjustment amount '|| l_ldet_adj_amt_tbl(i)
                                       ||' applied flag '|| l_ldet_applied_flag_tbl(i)
                                       ||' updated flag '|| l_ldet_updated_flag_tbl(i)
                                       ||' pricingstatus code '|| l_ldet_pricing_sts_code_tbl(i)
                                       ||' process code '|| l_ldet_process_code_tbl(i));
            END IF;
          END IF;
          i := l_ldet_line_dtl_index_tbl.NEXT(i);
        END LOOP;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('----------------------------------');
        END IF;
        j := l_line_index_tbl.NEXT(j);
      END LOOP;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('-------------------------------------------');

      END IF;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Updating the line details ------------------------');

    END IF;
    ---------------------------------------------------------------------
    --Update Adjustments
    ---------------------------------------------------------------------
    IF l_ldet_line_dtl_index_tbl.COUNT > 0
      THEN
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        i := l_ldet_line_dtl_index_tbl.FIRST;
        WHILE i IS NOT NULL
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('line details: line index '
                                     || l_ldet_line_index_tbl(i) ||' detail index '
                                     || l_ldet_line_dtl_index_tbl(i) ||' operand '
                                     || l_ldet_operand_value_tbl(i) ||' adjamt '
                                     || l_ldet_adj_amt_tbl(i) ||' applied flag '
                                     || l_ldet_applied_flag_tbl(i) ||' pricing_status '
                                     || l_ldet_pricing_sts_code_tbl(i) ||' text '
                                     || l_ldet_pricing_sts_txt_tbl(i) ||' process code '
                                     || l_ldet_process_code_tbl(i) ||' list hdr id '
                                     || l_ldet_list_hdr_id_tbl(i) ||' adj type '
                                     || l_ldet_list_line_type_tbl(i) ||' adj id '
                                     || l_ldet_list_line_id_tbl(i) || ' list line id '
                                     || l_ldet_ordqty_operand_tbl(i) || ' Ord Qty Operand '
                                     || l_ldet_ordqty_adjamt_tbl(i) || 'Ord Qty Adj Amt');
            QP_PREQ_GRP.engine_debug('------------------------');
          END IF;
          i := l_ldet_line_dtl_index_tbl.NEXT(i);
        END LOOP;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('line details: before update ');
      END IF;
      IF l_ldet_line_dtl_index_tbl.COUNT > 0
        THEN
        FORALL i IN l_ldet_line_dtl_index_tbl.FIRST..l_ldet_line_dtl_index_tbl.LAST
        UPDATE qp_npreq_ldets_tmp
        SET adjustment_amount = l_ldet_adj_amt_tbl(i),
                operand_value = l_ldet_operand_value_tbl(i),
                line_quantity = l_ldet_line_quantity_tbl(i),
                applied_flag = l_ldet_applied_flag_tbl(i),
                updated_flag = l_ldet_updated_flag_tbl(i),
                pricing_status_code = l_ldet_pricing_sts_code_tbl(i),
                pricing_status_text = l_ldet_pricing_sts_txt_tbl(i),
                process_code = l_ldet_process_code_tbl(i),
                calculation_code = l_ldet_calc_code_tbl(i),
                order_qty_operand = l_ldet_ordqty_operand_tbl(i),
                order_qty_adj_amt = nvl(l_ldet_ordqty_adjamt_tbl(i), l_ldet_adj_amt_tbl(i))
        WHERE line_detail_index = l_ldet_line_dtl_index_tbl(i)
--                        AND line_index = l_ldet_line_index_tbl(i)
        AND   pricing_status_code <> G_STATUS_DELETED --[julin/4671446]
                AND l_ldet_process_code_tbl(i) IN (G_STATUS_NEW,
                                                   G_STATUS_DELETED);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line details: before insert ');
        END IF;
      END IF; --l_ldet_line_dtl_index_tbl.count > 0

      FORALL i IN l_ldet_line_dtl_index_tbl.FIRST..l_ldet_line_dtl_index_tbl.LAST
      INSERT INTO qp_npreq_ldets_tmp
      (
       line_detail_index
       , line_index
       , line_detail_type_code
       , pricing_status_code
       , pricing_status_text
       , process_code
       , created_from_list_header_id
       , created_from_list_line_id
       , created_from_list_line_type
       , adjustment_amount
       , operand_value
       , modifier_level_code
       , price_break_type_code
       , line_quantity
       , operand_calculation_code
       , pricing_group_sequence
       , created_from_list_type_code
       , applied_flag
       , limit_code
       , limit_text
       , list_line_no
       , charge_type_code
       , charge_subtype_code
       , updated_flag
       , automatic_flag
       , pricing_phase_id
       , calculation_code
       , order_qty_operand
       , order_qty_adj_amt
       )
--		VALUES
      SELECT
      l_ldet_line_dtl_index_tbl(i)
      , l_ldet_line_index_tbl(i)
      , 'NULL'
      , l_ldet_pricing_sts_code_tbl(i)
      , l_ldet_pricing_sts_txt_tbl(i)
      , l_ldet_process_code_tbl(i)
      , l_ldet_list_hdr_id_tbl(i)
      , l_ldet_list_line_id_tbl(i)
      , l_ldet_list_line_type_tbl(i)
      , l_ldet_adj_amt_tbl(i)
      , l_ldet_operand_value_tbl(i)
      , l_ldet_modifier_level_tbl(i)
      , l_ldet_price_break_type_tbl(i)
      , l_ldet_line_quantity_tbl(i)
      , l_ldet_operand_calc_tbl(i)
      , l_ldet_pricing_grp_seq_tbl(i)
      , l_ldet_list_type_code_tbl(i)
      , l_ldet_applied_flag_tbl(i)
      , l_ldet_limit_code_tbl(i)
      , l_ldet_limit_text_tbl(i)
      , l_ldet_list_line_no_tbl(i)
      , l_ldet_charge_type_tbl(i)
      , l_ldet_charge_subtype_tbl(i)
      , l_ldet_updated_flag_tbl(i)
      , l_ldet_automatic_flag_tbl(i)
      , l_ldet_pricing_phase_id_tbl(i)
      , l_ldet_calc_code_tbl(i)
      , l_ldet_ordqty_operand_tbl(i)
      , nvl(l_ldet_ordqty_adjamt_tbl(i), l_ldet_adj_amt_tbl(i))
      FROM dual
      WHERE l_ldet_process_code_tbl(i) = G_STATUS_UPDATED;
    END IF;

    ---------------------------------------------------------------------
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Updating the line info ------------------------');
    END IF;
    ---------------------------------------------------------------------
    --Update Order Lines
    ---------------------------------------------------------------------


    IF l_line_index_tbl.COUNT > 0
      THEN
      FOR i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line info '|| l_line_index_tbl(i)
                                   ||' unit price '|| l_unit_price_tbl(i)
                                   ||' adj unit price '|| l_adj_unit_price_tbl(i));
        END IF;
      END LOOP;
      FOR i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
      LOOP

      --===[prarasto:Post Round] Start : Calculate rounded values ==--
      l_adjusted_unit_price_ur(i) := l_adj_unit_price_tbl(i);
      l_unit_selling_price_ur(i) := l_ordqty_selling_price_tbl(i);

    IF (G_ROUND_INDIVIDUAL_ADJ not in ( G_NO_ROUND , G_POST_ROUND )) AND (l_rounding_factor_tbl(i) is not null)
    THEN
      IF (l_catchweight_qty_tbl(i) is null) and (l_actual_order_qty_tbl(i) is not null) THEN
            l_extended_selling_price_ur(i) :=  round(l_unit_selling_price_ur(i), - 1 * l_rounding_factor_tbl(i))
	    					* l_actual_order_qty_tbl(i);
      ELSE
            l_extended_selling_price_ur(i) := round(l_unit_selling_price_ur(i), - 1 * l_rounding_factor_tbl(i))
	    					* l_ordered_qty_tbl(i);
      END IF;
    ELSE
      IF (l_catchweight_qty_tbl(i) is null) and (l_actual_order_qty_tbl(i) is not null) THEN
        l_extended_selling_price_ur(i) := l_unit_selling_price_ur(i) * l_actual_order_qty_tbl(i);
      ELSE
        l_extended_selling_price_ur(i) := l_unit_selling_price_ur(i) * l_ordered_qty_tbl(i);
      END IF;
    END IF;

      IF (G_ROUND_INDIVIDUAL_ADJ = G_NO_ROUND) or (l_rounding_factor_tbl(i) is null) THEN
--        l_adj_unit_price_tbl(i) := l_adjusted_unit_price_ur(i);
        l_unit_selling_price(i) := l_unit_selling_price_ur(i);
        l_extended_selling_price(i) := l_extended_selling_price_ur(i);
      ELSE
        l_adj_unit_price_tbl(i) := round(l_adjusted_unit_price_ur(i), - 1 * l_rounding_factor_tbl(i));
        l_ordqty_unit_price_tbl(i) := round(l_ordqty_unit_price_tbl(i),  - 1 * l_rounding_factor_tbl(i));
        l_unit_selling_price(i) := round(l_unit_selling_price_ur(i),  - 1 * l_rounding_factor_tbl(i));
        l_extended_selling_price(i) := round(l_extended_selling_price_ur(i),  - 1 * l_rounding_factor_tbl(i));
      END IF;

          IF l_debug = FND_API.G_TRUE THEN
	   QP_PREQ_GRP.engine_debug('Extended selling price unrounded : '||l_extended_selling_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Extended selling price : '||l_extended_selling_price(i));
	   QP_PREQ_GRP.engine_debug('Unit selling price unrounded : '||l_unit_selling_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Unit selling price : '||l_unit_selling_price(i));
	   QP_PREQ_GRP.engine_debug('Adjusted unit price unrounded : '||l_adjusted_unit_price_ur(i));
	   QP_PREQ_GRP.engine_debug('Adjusted unit price : '||l_adj_unit_price_tbl(i));
	   QP_PREQ_GRP.engine_debug('Line unit price : '||l_ordqty_unit_price_tbl(i));
          END IF; --l_debug
      --===[prarasto:Post Round] End : Calculate rounded values ==--


      UPDATE qp_npreq_lines_tmp
      SET unit_price = l_unit_price_tbl(i),
          adjusted_unit_price = l_adj_unit_price_tbl(i),        --[prarasto:Post Round]
          --adjusted_unit_price_ur = l_adjusted_unit_price_ur(i), --[prarasto:Post Round], [julin/postround] redesign
/*                                    decode(G_ROUND_INDIVIDUAL_ADJ,
                                       G_NO_ROUND, l_adj_unit_price_tbl(i),
                                       decode(l_rounding_factor_tbl(i),
                                              NULL, l_adj_unit_price_tbl(i),
                                              round(l_adj_unit_price_tbl(i),  - 1 * l_rounding_factor_tbl(i)))),
*/
--                  updated_adjusted_unit_price = l_upd_adj_unit_price_tbl(i)
          pricing_status_code = l_pricing_sts_code_tbl(i),
          pricing_status_text = l_pricing_sts_txt_tbl(i),
          processed_flag = G_PROCESSED,
          line_unit_price = l_ordqty_unit_price_tbl(i),         --[prarasto:Post Round]
/*                                   decode(G_ROUND_INDIVIDUAL_ADJ,
                                   G_NO_ROUND, l_ordqty_unit_price_tbl(i),
                                   decode(l_rounding_factor_tbl(i),
                                          NULL, l_ordqty_unit_price_tbl(i),
                                          round(l_ordqty_unit_price_tbl(i),  - 1 * l_rounding_factor_tbl(i)))),
*/
          order_uom_selling_price = l_unit_selling_price(i), --[prarasto:Post Round]
/*                                           decode(G_ROUND_INDIVIDUAL_ADJ,
                                           G_NO_ROUND, l_ordqty_selling_price_tbl(i),
                                           decode(l_rounding_factor_tbl(i),
                                                  NULL, l_ordqty_selling_price_tbl(i),
                                                  round(l_ordqty_selling_price_tbl(i),  - 1 * l_rounding_factor_tbl(i)))),
*/
          --order_uom_selling_price_ur = l_unit_selling_price_ur(i),  --[prarasto:Post Round], [julin/postround] redesign
          extended_price = l_extended_selling_price(i),             --[prarasto:Post Round]
          --extended_selling_price_ur = l_extended_selling_price_ur(i), --[prarasto:Post Round], [julin/postround] redesign
          QUALIFIERS_EXIST_FLAG = G_CALCULATE_ONLY
      WHERE line_index = l_line_index_tbl(i);
      --                AND l_processed_code_tbl(i) = G_STATUS_NEW;

      END LOOP; --[prarasto:Post Round]
    END IF;
    ---------------------------------------------------------------------

    --	QP_CLEANUP_ADJUSTMENTS_PVT.cleanup_adjustments('ONTVIEW',G_YES);


    --X_RETURN_STATUS:= FND_API.G_RET_STS_SUCCESS;
    --X_RETURN_STATUS_TEXT:= l_routine||' SUCCESS ';

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('end calculate price');
    END IF;
  EXCEPTION
    WHEN Calculate_exc THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error in calculate_price'|| X_RETURN_STATUS_TEXT);
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error in calculate_price'|| SQLERRM);
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_RETURN_STATUS_TEXT := l_routine || SQLERRM;

  END CALCULATE_PRICE;

  --this is used in pl/sql code path for OKC/OKS/ASO
  --this is called from QP_PREQ_PUB.price_request

  PROCEDURE CALCULATE_PRICE(p_rounding_flag IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_text OUT NOCOPY VARCHAR2) IS

  /*
INDX,QP_PREQ_PUB.calculate_price.l_line_cur,qp_npreq_lines_tmp_N2,LINE_TYPE_CODE,1
*/
  -- for bug 3820859, to start with adjusted_unit_price should be same as unit_price
  -- if not, then the same discount is getting applied twice if limit profile is set, because discounts calculations happens twice -
  -- once from QP_PREQ_GRP and then from QP_PREQ_PUB
  CURSOR l_line_cur IS SELECT
    line.line_index
    , line.unit_price adjusted_unit_price -- bug 3820859
    , line.unit_price
    , line.processed_flag
    , line.processed_code
    , line.updated_adjusted_unit_price
    , line.rounding_factor
    , line.pricing_status_code, line.pricing_status_text
    FROM qp_npreq_lines_tmp line
    WHERE
    line.price_flag IN (G_YES, G_PHASE, G_CALCULATE_ONLY)
    AND line.line_type_code IN (G_LINE_LEVEL, G_ORDER_LEVEL)
    AND line.pricing_status_code IN (G_STATUS_UPDATED
                                     , G_STATUS_GSA_VIOLATION
                                     , G_STATUS_UNCHANGED)
    AND nvl(processed_code, '0') <> G_BY_ENGINE
    AND line.usage_pricing_type IN
    (QP_PREQ_GRP.G_BILLING_TYPE, QP_PREQ_GRP.G_REGULAR_USAGE_TYPE);

  /*
INDX,QP_PREQ_PUB.calculate_price.l_bucket_price_cur,qp_npreq_lines_tmp_N1,LINE_INDEX,1
INDX,QP_PREQ_PUB.calculate_price.l_bucket_price_cur,qp_npreq_lines_tmp_N1,LINE_TYPE_CODE,2
INDX,QP_PREQ_PUB.calculate_price.l_bucket_price_cur,qp_npreq_lines_tmp_N2,LINE_TYPE_CODE,1
INDX,QP_PREQ_PUB.calculate_price.l_bucket_price_cur,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_PREQ_PUB.calculate_price.l_bucket_price_cur,qp_npreq_ldets_tmp_N3,CREATED_FROM_LIST_LINE_TYPE,2
*/
  CURSOR l_bucket_price_cur(p_line_index NUMBER) IS -- 2892848
    SELECT    ldet.created_from_list_line_id
            , line.line_index line_ind
            , ldet.line_detail_index
            , ldet.created_from_list_line_type
            , ldet.modifier_level_code
            , ldet.applied_flag
            , 1.0 amount_changed
            , line.adjusted_unit_price
--changed to make sure lumpsum on order level frt charge divide by 1 quantity
            , ldet.line_quantity priced_quantity
            , line.priced_quantity priced_qty
            , ldet.group_quantity
            , ldet.group_amount
            , line.updated_adjusted_unit_price
            , ldet.automatic_flag
            , ldet.override_flag
            , ldet.pricing_group_sequence
            , ldet.operand_calculation_code
            , ldet.operand_value
            , ldet.adjustment_amount
            , line.unit_price
            , ldet.accrual_flag
            , ldet.updated_flag
            , ldet.process_code
            , ldet.pricing_status_code
            , ldet.pricing_status_text
            , ldet.price_break_type_code
            , ldet.charge_type_code
            , ldet.charge_subtype_code
            , line.rounding_factor
            , G_LINE_LEVEL line_type
            , 'N' is_max_frt
            , ldet.net_amount_flag
    FROM qp_npreq_ldets_tmp ldet, qp_npreq_lines_tmp line
    --where line.line_index = p_line_index -- 2892848
    WHERE ldet.line_index = line.line_index -- 2892848
            --and ldet.line_index = line.line_index --2892848
            AND line.price_flag IN (G_YES, G_PHASE, G_CALCULATE_ONLY)
            AND ldet.process_code = G_STATUS_NEW
            AND (ldet.applied_flag = G_YES
                 OR ldet.created_from_list_line_type = G_FREIGHT_CHARGE)
            AND ldet.created_from_list_line_type IN (G_DISCOUNT
                                                     , G_SURCHARGE, G_PRICE_BREAK_TYPE, G_FREIGHT_CHARGE)
            AND nvl(ldet.created_from_list_type_code, 'NULL') NOT IN
                    (G_PRICE_LIST_HEADER, G_AGR_LIST_HEADER)
            AND ldet.line_detail_index NOT IN
                    (SELECT rltd.related_line_detail_index
                     FROM qp_npreq_rltd_lines_tmp rltd
                     WHERE rltd.pricing_status_code = G_STATUS_NEW
                     AND rltd.relationship_type_code = G_PBH_LINE)
            -- next 4 conditions added for 3435240
            AND line.line_type_code = G_LINE_LEVEL
            AND line.pricing_status_code IN (G_STATUS_UPDATED
                                             , G_STATUS_GSA_VIOLATION
                                             , G_STATUS_UNCHANGED)
            AND nvl(line.processed_code, '0') <> G_BY_ENGINE
            AND line.usage_pricing_type IN
                    (QP_PREQ_GRP.G_BILLING_TYPE, QP_PREQ_GRP.G_REGULAR_USAGE_TYPE)
    UNION
    SELECT    ldet.created_from_list_line_id
            , line.line_index line_ind
            , ldet.line_detail_index
            , ldet.created_from_list_line_type
            , ldet.modifier_level_code
            , ldet.applied_flag
            , 1.0 amount_changed
            , line.adjusted_unit_price
--changed to make sure lumpsum on order level frt charge divide by 1 quantity
            , ldet.line_quantity priced_quantity
            , line.priced_quantity priced_qty
            , ldet.group_quantity
            , ldet.group_amount
            , line.updated_adjusted_unit_price
            , ldet.automatic_flag
            , ldet.override_flag
            , ldet.pricing_group_sequence
            , ldet.operand_calculation_code
            , ldet.operand_value
            , ldet.adjustment_amount
            , line.unit_price
            , ldet.accrual_flag
            , ldet.updated_flag
            , ldet.process_code
            , ldet.pricing_status_code
            , ldet.pricing_status_text
            , ldet.price_break_type_code
            , ldet.charge_type_code
            , ldet.charge_subtype_code
            , line.rounding_factor
            , G_ORDER_LEVEL line_type
            , 'N' is_max_frt
            , ldet.net_amount_flag
    FROM qp_npreq_ldets_tmp ldet, qp_npreq_lines_tmp line
                               , qp_npreq_lines_tmp line1
    --where line.line_index = p_line_index -- 2892848
            --and ldet.line_index = line1.line_index -- 2892848
            WHERE ldet.line_index = line1.line_index -- 2892848
            AND line1.line_type_code = G_ORDER_LEVEL
            AND line1.price_flag IN (G_YES, G_PHASE, G_CALCULATE_ONLY)
            AND line.line_type_code = G_LINE_LEVEL
            AND ldet.process_code = G_STATUS_NEW
            AND (ldet.applied_flag = G_YES
                 OR ldet.created_from_list_line_type = G_FREIGHT_CHARGE)
            AND ldet.created_from_list_line_type IN (G_DISCOUNT,
                                                     G_SURCHARGE, G_PRICE_BREAK_TYPE, G_FREIGHT_CHARGE)
            AND nvl(ldet.created_from_list_type_code, 'NULL') NOT IN
                    (G_PRICE_LIST_HEADER, G_AGR_LIST_HEADER)
            AND ldet.line_detail_index NOT IN
                    (SELECT rltd.related_line_detail_index
                     FROM qp_npreq_rltd_lines_tmp rltd
                     WHERE rltd.pricing_status_code = G_STATUS_NEW
                     AND rltd.relationship_type_code = G_PBH_LINE)
            -- next 4 conditions added for 3435240
            AND line.price_flag IN (G_YES, G_PHASE, G_CALCULATE_ONLY)
            AND line.pricing_status_code IN (G_STATUS_UPDATED
                                             , G_STATUS_GSA_VIOLATION
                                             , G_STATUS_UNCHANGED)
            AND nvl(line.processed_code, '0') <> G_BY_ENGINE
            AND line.usage_pricing_type IN
                    (QP_PREQ_GRP.G_BILLING_TYPE, QP_PREQ_GRP.G_REGULAR_USAGE_TYPE)
    --order by line_ind,pricing_group_sequence; -- 2892848
    ORDER BY pricing_group_sequence, line_ind; -- 2829848

  CURSOR l_chk_backcal_adj_exist_cur(p_line_index NUMBER) IS
    SELECT ldet.line_detail_index
            , ldet.adjustment_amount
    FROM qp_npreq_ldets_tmp ldet
    WHERE line_index = p_line_index
    AND calculation_code = G_BACK_CALCULATE
    AND applied_flag = G_YES
    AND updated_flag = G_YES;

  -- net_amount 2720717
  CURSOR l_net_amount_flag_cur (p_list_line_id NUMBER) IS
    SELECT net_amount_flag
    FROM qp_list_lines
    WHERE list_line_id = p_list_line_id;

  l_bucket_price_rec l_bucket_price_cur%ROWTYPE;
  l_line_rec l_line_cur%ROWTYPE;
  l_return_adjustment NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_sub_total_price NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_list_price NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  --l_adjusted_price NUMBER := g_miss_num;--FND_API.G_MISS_NUM; -- 2892848



  TYPE LINES_TBL_TYPE IS TABLE OF l_line_rec%TYPE INDEX BY BINARY_INTEGER;
  l_lines_tbl LINES_TBL_TYPE;

  TYPE LBUCKET_TBL_TYPE IS TABLE OF l_bucket_price_rec%TYPE INDEX BY BINARY_INTEGER;
  l_ldet_tbl LBUCKET_TBL_TYPE;
  l_frt_charge_tbl FRT_CHARGE_TBL;
  l_back_calc_ret_rec back_calc_rec_type;

  BACK_CALCULATE BOOLEAN := TRUE;

  --l_prev_line_index NUMBER := g_miss_num;--FND_API.G_MISS_NUM;
  l_prev_line_index NUMBER :=  - 9999; -- 2892848, SL_latest
  l_1st_bucket VARCHAR2(1) := 'N';
  l_prev_adj NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_sign NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_amount_changed NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_adjustment_amount NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_operand_value NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_BACK_CALCULATE_START_TYPE VARCHAR2(30) := G_BACK_CALCULATION_STS_NONE; -- 2892848
  --l_prev_bucket qp_npreq_ldets_tmp.PRICING_GROUP_SEQUENCE%TYPE := g_miss_num;--FND_API.G_MISS_NUM;
  l_back_calc_dtl_index NUMBER := 0;
  l_back_calc_adj_amt NUMBER := 0;

  l_ldet_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_index NUMBER := g_miss_num; --FND_API.G_MISS_NUM;
  l_calc_quantity NUMBER := 0;

  --added to calculate order level adjustments' adj amt
  l_ord_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_ord_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;

  l_updated_adj_unit_price_ur QP_PREQ_GRP.NUMBER_TYPE; --[prarasto:Post Round]
  l_adjusted_unit_price_ur QP_PREQ_GRP.NUMBER_TYPE;    --[prarasto:Post Round]

  i NUMBER := 0;
  j NUMBER := 0;
  k NUMBER := 0;
  x NUMBER := 0;
  m NUMBER := 0;

  Calculate_Exc EXCEPTION;

  --begin 2388011
  l_req_value_per_unit NUMBER; --2388011 priya added this variable
  l_total_value NUMBER; --group_value --2388011 priya added this variable
  l_bucketed_adjustment NUMBER; --2388011 priya added this variable
  --end 2388011

  --net_amount 2720717
  --l_pbh_net_adj_amount NUMBER := 0; -- sum up adj amts  -- 2892848 SL_latest
  --l_pbh_prev_net_adj_amount NUMBER := 0; -- whenever bucket change - 2892848 SL_latest

  l_pbh_pricing_attr VARCHAR2(240);

  l_adjusted_price NUMBER := NULL; --2892848 so we can nvl(l_adjusted_price, unit_price) when assign l_sub_total_price
  l_prev_bucket NUMBER :=  - 9999; --2892848
  -- begin 2892848, net amount
  l_qualifier_value NUMBER := NULL; -- to qualify PBH
  s PLS_INTEGER := 0; -- counter for l_line_bucket_detail_tbl
  l_lg_adj_amt NUMBER := NULL; -- 2892848
  --l_prev_lg_adj_amt                  NUMBER:=0; -- 2892848 SL_latest
  line_change BOOLEAN := NULL;

  /* SL latest
-- for linegroup
TYPE bucket_adj_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_bucket_adj_amt_tbl bucket_adj_amt_tbl;

-- for line level
TYPE bucket_index_adj_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_bucket_index_adj_tbl bucket_index_adj_tbl;

TYPE prev_bucket_index_adj_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_prev_bucket_index_adj_tbl prev_bucket_index_adj_tbl;
*/
  --begin SL_latest
  CURSOR l_net_mod_index_cur(p_list_line_id NUMBER) IS
    SELECT DISTINCT ldet.line_index
    FROM qp_npreq_ldets_tmp ldet
    WHERE ldet.created_from_list_line_id = p_list_line_id
    AND pricing_status_code IN (G_STATUS_NEW, G_STATUS_UPDATED, G_STATUS_UNCHANGED);

  l_line_bucket_amt NUMBER := NULL;
  l_lg_net_amt NUMBER := NULL;
  l_prev_qty NUMBER := 0;

  -- [julin/4112395/4220399]
  l_applied_req_value_per_unit NUMBER := 0;
  l_prod_line_bucket_amt NUMBER := 0;
  l_lg_prod_net_amt NUMBER := 0;

  -- record bucketed USP*qtyfor each line_index upon bucket change
  TYPE bucket_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_bucket_amt_tbl bucket_amt_tbl;
  l_prev_bucket_amt_tbl bucket_amt_tbl;

  -- hash table of list_line_id and its corresponding lg_net_amt
  TYPE mod_lg_net_amt_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_mod_lg_net_amt_tbl mod_lg_net_amt_tbl;
  l_mod_lg_prod_net_amt_tbl mod_lg_net_amt_tbl; -- [julin/4112395/4220399]


  -- end SL_latest
  -- end 2892848

  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);
  l_routine VARCHAR2(50) := 'Routine :QP_PREQ_PUB.Calculate_price ';

  -- [julin/3265308] net amount calculation 'P', match product only.
  -- given a line line id, find the product attribute and context for
  -- the modifier and match all request lines with that context/attr
  -- pair.  exclude logic included.  price_flag clause included to
  -- ignore free goods.
  CURSOR l_prod_attr_info(p_list_line_id NUMBER) IS
    SELECT DISTINCT qla.line_index, ql.priced_quantity, ql.unit_price
    FROM qp_preq_line_attrs_tmp qla, qp_pricing_attributes qpa, qp_preq_lines_tmp ql
    WHERE qpa.list_line_id = p_list_line_id
    AND qla.context = qpa.product_attribute_context
    AND qla.attribute = qpa.product_attribute
    AND qla.value_from = qpa.product_attr_value
    AND qla.line_index = ql.line_index
    AND ql.price_flag <> G_PHASE
    AND ql.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED,
                                   QP_PREQ_PUB.G_STATUS_GSA_VIOLATION,
                                   QP_PREQ_PUB.G_STATUS_UNCHANGED)
    AND NOT EXISTS (SELECT qla2.line_index
                    FROM qp_preq_line_attrs_tmp qla2, qp_pricing_attributes qpa2
                    WHERE qpa2.list_line_id = p_list_line_id
                    AND qpa2.excluder_flag = G_YES
                    AND qla2.line_index = qla.line_index
                    AND qla2.context = qpa2.product_attribute_context
                    AND qla2.attribute = qpa2.product_attribute
                    AND qla2.value_from = qpa2.product_attr_value);

  l_netamt_flag VARCHAR2(1);
  l_bucketed_flag VARCHAR2(1);

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('begin calculate price');
      QP_PREQ_GRP.ENGINE_DEBUG('SL, this is Oracle IT path'); -- 2892848

    END IF;

--4900095 call Determine_svc_item_quantity
 IF QP_PREQ_GRP.G_Service_line_qty_tbl.COUNT = 0 THEN
   Determine_svc_item_quantity;
 END IF;



    --reset order lvl adjustments' adj amt
    l_ord_dtl_index_tbl.DELETE;
    l_ord_adj_amt_tbl.DELETE;
    --l_bucket_adj_amt_tbl.delete; --SL_latest 2892848
    --l_bucket_index_adj_tbl.delete; --2892848
    --l_prev_bucket_index_adj_tbl.delete; --2892848
    l_bucket_amt_tbl.DELETE; -- 2892848 SL_latest
    l_prev_bucket_amt_tbl.DELETE;
    l_mod_lg_net_amt_tbl.DELETE; -- 2892848 SL_latest
    l_mod_lg_prod_net_amt_tbl.DELETE; -- [julin/4112395/4220399]

    l_lines_tbl.DELETE;
    l_ldet_tbl.DELETE;
    FOR l_line_rec IN l_line_cur
      LOOP
      --The freight_charge functionality to return worst freight charge
      --has been coded with an assumption that only one line is dealt
      --with in the l_bucket_price_cur below
      l_lines_tbl(l_line_rec.line_index) := l_line_rec; -- bug 3306349

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Gather lines passed: Line_Index '|| l_line_rec.line_index ||
                                 ' list price '|| l_line_rec.unit_price ||
                                 ' adjusted unit price '|| l_line_rec.adjusted_unit_price ||
                                 ' updated adjusted unit price '|| l_line_rec.updated_adjusted_unit_price);

      END IF;
    END LOOP;

    /* shu 2892848 , move this loop head to be after l_bucket_price_cur loop end
j:=0;

	j:= l_lines_tbl.FIRST;
	While j IS NOT NULL LOOP
	*/

    -- net_amount_new, 2720717
    -- reset for every request line
    --l_pbh_net_adj_amount:= 0; -- 2892848
    --l_pbh_prev_net_adj_amount:=0; -- 2892848

    BACK_CALCULATE := FALSE;
    --l_list_price := l_lines_tbl(j).unit_price; -- 2892848
    --l_sub_total_price := l_list_price; -- 2892848
    --l_adjusted_price := l_list_price; -- 2892848
    --l_prev_bucket := g_miss_num;--FND_API.G_MISS_NUM; -- 2892848
    l_amount_changed := 0;
    l_BACK_CALCULATE_START_TYPE := G_BACK_CALCULATION_STS_NONE;
    l_return_status := '';
    l_return_status_text := '';

    IF l_debug = FND_API.G_TRUE THEN
      /* 2892848
              QP_PREQ_GRP.ENGINE_DEBUG('************************ looping through request lines');
	      QP_PREQ_GRP.ENGINE_DEBUG('Processing
	        Line Index'||l_lines_tbl(j).line_index||
		' list price '||l_lines_tbl(j).unit_price||
		' updated adjusted price '||l_lines_tbl(j).updated_adjusted_unit_price);
*/
      QP_PREQ_GRP.ENGINE_DEBUG('Display price: price '
                                                    || l_list_price ||' sub-t '|| l_sub_total_price
                                                    ||' adj price '|| l_adjusted_price);

    END IF; -- END IF l_debug

    l_frt_charge_tbl.DELETE;
    l_ldet_tbl.DELETE;

    i := 0; -- modifier lines in ldets
    --OPEN l_bucket_price_cur(l_lines_tbl(j).line_index);
    OPEN l_bucket_price_cur(1); -- 2892848
    LOOP -- process adjustments for each request line
      FETCH l_bucket_price_cur INTO l_bucket_price_rec;

      i := i + 1;

      EXIT WHEN l_bucket_price_cur%NOTFOUND;

      -- begin 2892848
      -- ASK PRIYA see if there is a way to tell if line is from calling application???
      -- obtain net_adj_amount_flag from qp_list_lines table if null,
      -- since it may not be passed from calling application
      IF l_bucket_price_rec.net_amount_flag IS NULL THEN -- get it from setup just in case
        OPEN l_net_amount_flag_cur(l_bucket_price_rec.created_from_list_line_id);
        FETCH l_net_amount_flag_cur INTO l_bucket_price_rec.net_amount_flag;
        CLOSE l_net_amount_flag_cur;
      END IF;
      l_return_adjustment := 0; -- diff other path ???
      -- end 2892848

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('------------------- looping through ldet lines');
        QP_PREQ_GRP.ENGINE_DEBUG('Processing Adjustments:
                                 line index '|| l_bucket_price_rec.line_ind ||
                                 ' list line id '|| l_bucket_price_rec.created_from_list_line_id ||
                                 ' bucket '|| l_bucket_price_rec.pricing_group_sequence ||
                                 ' net amount flag '|| l_bucket_price_rec.net_amount_flag ||  -- 2892848
                                 ' override_flag '|| l_bucket_price_rec.override_flag ||
                                 ' automatic '|| l_bucket_price_rec.automatic_flag ||
                                 ' line_type '|| l_bucket_price_rec.line_type);

      END IF;


      IF l_bucket_price_rec.created_from_list_line_type = G_DISCOUNT
        AND l_bucket_price_rec.operand_calculation_code <> G_NEWPRICE_DISCOUNT THEN
        l_sign :=  - 1;
      ELSE
        l_sign := 1;
      END IF;

      ------------------NET AMT STUFF, SL_latest
      -- begin 2892848
      -- ldet lines are ordered by bucket, line index
      -- l_sub_total_price is bucketed unit price, l_adjusted_unit_price is current USP

      -- defaults
      IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
        l_adjusted_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
        --l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0); --Bug No: 	7323594
      ELSE
        l_adjusted_price := 0;
        l_sub_total_price := 0;
      END IF;

      -- use original list_price for null bucket modifiers or
      -- use USP as l_sub_total_price for bucket modifiers
      IF (l_bucket_price_rec.pricing_group_sequence IS NULL OR
          l_bucket_price_rec.pricing_group_sequence = 0) THEN

        IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
          l_adjusted_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
          l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0);
        ELSE
          l_adjusted_price := 0;
          l_sub_total_price := 0;
        END IF;

      ELSE -- bucket not null and not 0

        /* SL_more do no want this for same line same bucket case
		    -- default, in case there is no further lines to set this, SL_further fix

			    l_bucket_amt_tbl(l_bucket_price_rec.line_ind) :=
			      l_adjusted_price *l_bucket_price_rec.priced_qty;
				*/
        IF l_prev_line_index = l_bucket_price_rec.line_ind THEN -- will be at least 1
          line_change := FALSE;

          -- line at least from 1 to up, bucket atleast from 1 to up
          IF (l_prev_bucket <> l_bucket_price_rec.pricing_group_sequence) THEN -- same line, bucket change
            l_mod_lg_net_amt_tbl.DELETE; -- clear this table upon bucket change to keep it small
            l_mod_lg_prod_net_amt_tbl.DELETE; -- [julin/4112395/4220399]
            -- so we can use it latest, use grp_amt as l_lg_net_amt for this case
            IF l_prev_bucket = - 9999 THEN
              l_1st_bucket := 'Y';
            ELSE
              l_1st_bucket := 'N';
            END IF;
            l_prev_bucket := l_bucket_price_rec.pricing_group_sequence; -- preserve new bucket to be next prev_bucket

            IF (l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)) THEN
              l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
              l_adjusted_price := l_sub_total_price;
              l_bucket_amt_tbl(l_bucket_price_rec.line_ind) := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, 0) * l_bucket_price_rec.priced_qty;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('bucket change within same line.'
                                         ||' sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
                QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_bucket_price_rec.line_ind ||'): '
                                         || nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, 0) || '*' ||
                                         l_bucket_price_rec.priced_qty || '=' || l_bucket_amt_tbl(l_bucket_price_rec.line_ind));
              END IF; -- end debug
            END IF; -- END IF 	l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)

            -- [julin/4055310]
            l_prev_bucket_amt_tbl := l_bucket_amt_tbl;

          END IF; -- end bucket change, (l_prev_bucket <> l_bucket_price_rec.pricing_group_sequence)

        ELSE -- line change (from -9999 to up, or from at least 1 to up)

          line_change := TRUE;

          -- bucket from -9999 to up,or from at least 1 to up
          IF l_prev_bucket <> l_bucket_price_rec.pricing_group_sequence THEN -- line change , bucket change

            l_mod_lg_net_amt_tbl.DELETE; -- clear this table upon bucket change to keep it small
            l_mod_lg_prod_net_amt_tbl.DELETE; -- [julin/4112395/4220399]

            -- preserve l_prev_bucket to be -9999 if this is 1st bucket
            -- so we can use it latest, use grp_amt as l_lg_net_amt for this case
            IF l_prev_bucket = - 9999 THEN
              l_1st_bucket := 'Y';
            ELSE
              l_1st_bucket := 'N';
            END IF;
            l_prev_bucket := l_bucket_price_rec.pricing_group_sequence; -- preserve new bucket to be next prev_bucket
            IF (l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)) THEN
              l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
            ELSE
              l_sub_total_price := 0;
            END IF; -- END IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)
            l_adjusted_price := l_sub_total_price;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('bucket change, line change. '
                                       ||' sub_total_price: '|| l_sub_total_price ||' adjusted_price: '|| l_adjusted_price );
            END IF; -- end debug

            IF l_prev_line_index =  - 9999 THEN
              IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                l_bucket_amt_tbl(l_bucket_price_rec.line_ind) := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0) * l_bucket_price_rec.priced_qty;
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('prev_line_index is -9999');
                  QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_bucket_price_rec.line_ind ||'): '
                                           || nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0) || '*' ||
                                           l_bucket_price_rec.priced_qty || '=' || l_bucket_amt_tbl(l_bucket_price_rec.line_ind));
                END IF; -- end debug
              END IF; -- END IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)

            ELSE -- l_prev_line_index <> -9999
              IF (l_lines_tbl.EXISTS(l_prev_line_index)) THEN
                l_bucket_amt_tbl(l_prev_line_index) := nvl(l_lines_tbl(l_prev_line_index).adjusted_unit_price, 0) * l_prev_qty;
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('capture bucket_amt of prev line l_bucket_amt_tbl('|| l_prev_line_index ||'): '
                                           || nvl(l_lines_tbl(l_prev_line_index).adjusted_unit_price, 0) || '*' ||
                                           l_prev_qty || '=' || l_bucket_amt_tbl(l_prev_line_index));
                END IF; -- end debug
              END IF; -- END IF l_lines_tbl.EXISTS(l_prev_line_index)

              -- [julin/4055310]
              l_prev_bucket_amt_tbl := l_bucket_amt_tbl;

            END IF; -- END l_prev_line_index=-9999

          ELSE -- line change same bucket (bucket is at least from 1 to up, line is at least from 1 to up)
            IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
              l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
            ELSE
              l_sub_total_price := 0;
            END IF; -- END IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)
            l_adjusted_price := l_sub_total_price;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('line change, same bucket');
              QP_PREQ_GRP.engine_debug('l_sub_total_price: '|| l_sub_total_price);
            END IF; -- end debug

            IF l_lines_tbl.EXISTS(l_prev_line_index) THEN
              l_bucket_amt_tbl(l_prev_line_index) := nvl(l_lines_tbl(l_prev_line_index).adjusted_unit_price, 0) * l_prev_qty;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('l_bucket_amt_tbl(' || l_prev_line_index ||'): '
                                         || nvl(l_lines_tbl(l_prev_line_index).adjusted_unit_price, 0) || '*' ||
                                         l_prev_qty || '=' || l_bucket_amt_tbl(l_prev_line_index));
              END IF; -- end debug
            END IF; -- END IF l_lines_tbl.EXISTS(l_prev_line_index)

            -- SL_more, to default and for line level net amt, in case no further line to set this
            IF l_1st_bucket = 'Y' THEN
              IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                l_bucket_amt_tbl(l_bucket_price_rec.line_ind) := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0) * l_bucket_price_rec.priced_qty; -- for line level net amt we need this
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('1st bucket for this line l_bucket_amt_tbl('|| l_bucket_price_rec.line_ind ||'): '
                                           || nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0) || '*' ||
                                           l_bucket_price_rec.priced_qty || '=' || l_bucket_amt_tbl(l_bucket_price_rec.line_ind));
                END IF; -- end debug
              END IF; -- END IF l_lines_tbl.EXISTS(l_bucket_price_rec.line_ind)
            END IF; -- END IF l_1st_bucket ='Y'

          END IF; -- end bucket change in the line change block

          l_prev_line_index := l_bucket_price_rec.line_ind; -- preserve the new lind_ind to be l_prev_line_index
          l_prev_qty := l_bucket_price_rec.priced_qty;
        END IF; --l_prev_line_index = line_index
      END IF; -- end if bucket is null or 0
      -- end 2892848, SL_latest

      /* SL_latest
                   -- begin 2892848
                   -- MOVE TO HERE
                IF l_bucket_price_rec.pricing_group_sequence <> 0 AND l_bucket_price_rec.pricing_group_sequence IS NOT NULL THEN -- bucket 0 is line event list price
                   -- detect bucket change, need to CAPTURE unit_adjs (LINE) and adj_amts(LINEGROUP) up to the prev bucket
                  IF l_prev_bucket <> l_bucket_price_rec.pricing_group_sequence THEN
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug ('------BUCKET CHANGE----, place to record bucket USP for each line_index');
                    END IF; -- END debug

                    -- for LINE GROUP
                    -- need capture the l_prev_lg_adj_amt
                    -- l_bucket_adj_amt_tbl(bucket) stores adj_amts of all lines for each bucket
                    -- prev_lg_adj_amt is the sum of adj_amts for all lines up to prev buckets

                    IF l_bucket_adj_amt_tbl.EXISTS(l_prev_bucket) THEN
		      l_prev_lg_adj_amt := nvl(l_prev_lg_adj_amt,0) + l_bucket_adj_amt_tbl(l_prev_bucket);
		      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('debug LINEGROUP adj amts up to prev bucket - '||l_prev_bucket ||': '||l_prev_lg_adj_amt);
                      END IF; -- END debug

		    END IF; -- END IF l_bucket_adj_amt_tbl.EXISTS(l_prev_bucket)

                    -- bucket change for LINE LEVEL
                    -- l_bucket_index_adj_tbl(line_index) stores sum of unit_adjs for each line_index
                    -- l_prev_bucket_index_adj_tbl(line_index) is the sum of unit_adjs for that line_index up to prev bucket

                    IF l_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                      IF l_prev_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                        l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind):= nvl(l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind),0)
                          + l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind);
                      ELSE
                        l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind):= l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind);
                      END IF; -- END IF l_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind)

                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('debug LINE unit adjs up to prev bucket for line index'||l_bucket_price_rec.line_ind ||': '||l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind) );
                      END IF; -- END debug
                    END IF; -- END IF l_bucket_index_adj_tbl.EXISTS


                    -- begin shu fix bug for special case, bucket change within same line index
                    IF line_change = false THEN
                      l_sub_total_price := nvl(l_adjusted_price, l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
                      IF l_debug = FND_API.G_TRUE THEN
                           QP_PREQ_GRP.engine_debug('bucket change within same line'
                           ||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                      END IF;
                    END IF; -- END IF line_change = flase
                    -- end shu fix bug

                    l_prev_bucket := l_bucket_price_rec.pricing_group_sequence; -- preserve new bucket to be next prev_bucket

                  ELSE -- bucket did not change but line changes within bucket, we also need to capture line level unit adjs of prev bucket


					IF line_change = true THEN
                      IF l_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                      IF l_prev_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                        l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind):= nvl(l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind),0)
                          + l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind);
                      ELSE
                        l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind):= l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind);
                      END IF; -- END IF l_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind)

                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug ('line change, debug LINE unit adjs up to prev bucket for line index'||l_bucket_price_rec.line_ind ||': '||l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind) );
                      END IF; -- END debug
                    END IF; -- END IF l_bucket_index_adj_tbl.EXISTS
                    END IF; -- END IF line_change true

                  END IF; -- end if l_prev_bucket <> l_bucket_price_rec.pricing_group_sequence

				ELSE -- bucket is 0 or null -- begin shu fix bug
                  l_sub_total_price := nvl(l_lines_tbl(l_bucket_price_rec.line_ind).unit_price, 0);
	              l_adjusted_price :=  nvl(l_lines_tbl(l_bucket_price_rec.line_ind).adjusted_unit_price,l_lines_tbl(l_bucket_price_rec.line_ind).unit_price);
                      IF l_debug = FND_API.G_TRUE THEN
                           QP_PREQ_GRP.engine_debug('bucket is 0 or null'
                           ||' sub_total_price '||l_sub_total_price ||' adjusted_price '||l_adjusted_price  );
                      END IF;
                  -- end shu fix bug
                END IF; -- END IF l_bucket_price_rec(J).pricing_group_sequence <> 0 AND ...
                   -- end 2892848
			------------------END NET AMT STUFF
*/

      --This code is for bug 1915355
      --To calculate lumpsum use group_qty/amt for linegrp
      --This is only for engine inserted records
      --for user passed adjustments, we will use only line_qty
      --to break the link from other lines that have this line
      --group adjustment
      --for bug2897524 retain line_quantity for zerounitprice
      IF l_bucket_price_rec.priced_quantity = 0
        AND l_bucket_price_rec.unit_price <> 0
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('line_qty zero changed to null');
        END IF;
        l_bucket_price_rec.priced_quantity := NULL;
      END IF;

      --bug 4900095
      IF (QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_bucket_price_rec.line_ind)
      or QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_bucket_price_rec.line_detail_index))
      and l_bucket_price_rec.operand_calculation_code = G_LUMPSUM_DISCOUNT THEN
      --only for service items
      --when uom_quantity is passed as null,
      -- and contract_start/end_dates are passed
      --and for a line/linegroup lumpsum DIS/PBH/SUR/FREIGHT
        IF l_bucket_price_rec.modifier_level_code = G_LINE_GROUP  THEN
          IF G_Service_pbh_lg_amt_qty.exists(l_bucket_price_rec.line_detail_index)
          and QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_bucket_price_rec.line_detail_index) THEN
            l_calc_quantity := nvl(G_Service_pbh_lg_amt_qty(l_bucket_price_rec.line_detail_index),
            QP_PREQ_GRP.G_service_ldet_qty_tbl(l_bucket_price_rec.line_detail_index));
          ELSIF G_Service_pbh_lg_amt_qty.exists(l_bucket_price_rec.line_detail_index) THEN
            l_calc_quantity := G_Service_pbh_lg_amt_qty(l_bucket_price_rec.line_detail_index);
          ELSIF QP_PREQ_GRP.G_service_ldet_qty_tbl.exists(l_bucket_price_rec.line_detail_index) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_ldet_qty_tbl(l_bucket_price_rec.line_detail_index);
          ELSIF QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_bucket_price_rec.line_ind) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_line_qty_tbl(l_bucket_price_rec.line_ind);
          ELSE
            l_calc_quantity :=
            nvl(nvl(l_bucket_price_rec.group_quantity
                , l_bucket_price_rec.group_amount)
            , nvl(l_bucket_price_rec.priced_quantity
                  , l_bucket_price_rec.priced_qty));
          END IF;--G_Service_pbh_lg_amt_qty.exists
        ELSIF l_bucket_price_rec.modifier_level_code = G_LINE_LEVEL THEN
          IF QP_PREQ_GRP.G_service_line_qty_tbl.exists(l_bucket_price_rec.line_ind) THEN
            l_calc_quantity := QP_PREQ_GRP.G_service_line_qty_tbl(l_bucket_price_rec.line_ind);
          ELSE
            l_calc_quantity :=
            nvl(nvl(l_bucket_price_rec.group_quantity
                , l_bucket_price_rec.group_amount)
            , nvl(l_bucket_price_rec.priced_quantity
                  , l_bucket_price_rec.priced_qty));
          END IF;--G_Service_pbh_lg_amt_qty.exists
        END IF;--l_bucket_price_rec.modifier_level_code
      ELSE
        IF l_bucket_price_rec.modifier_level_code =
          G_LINE_GROUP
        AND l_bucket_price_rec.pricing_status_code =
          G_STATUS_NEW
        THEN
          l_calc_quantity :=
          nvl(nvl(l_bucket_price_rec.group_quantity
                , l_bucket_price_rec.group_amount)
            , nvl(l_bucket_price_rec.priced_quantity
                  , l_bucket_price_rec.priced_qty));
        ELSE
          l_calc_quantity :=
          nvl(l_bucket_price_rec.priced_qty, l_bucket_price_rec.priced_quantity);
        END IF; --_bucket_price_rec.modifier_level_code
      END IF;--QP_PREQ_GRP.G_service_line_qty_tbl.exists

      --fix for bug2424931
      l_calc_quantity := nvl(l_calc_quantity, 1);

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('figuring out qty level '
                                 || l_bucket_price_rec.modifier_level_code
                                 ||' pricedqty '|| l_bucket_price_rec.priced_quantity
                                 ||' grpqty '|| l_bucket_price_rec.group_quantity
                                 ||' grpamt '|| l_bucket_price_rec.group_amount
                                 ||' lqty '|| l_bucket_price_rec.priced_qty -- order_qty of the line
                                 ||' calc '|| l_calc_quantity);
      END IF;
      --End fix for bug 1915355
      IF l_bucket_price_rec.created_from_list_line_type
        = G_PRICE_BREAK_TYPE
        THEN

        BEGIN
          SELECT pricing_attribute
          INTO l_pbh_pricing_attr
          FROM qp_pricing_attributes
          WHERE list_line_id =
          l_bucket_price_rec.created_from_list_line_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_pbh_pricing_attr := NULL;
        END;

        --changes for PBH line group LUMPSUM bug 2388011 commented out
        --call to old signature of Price_Break_Calculation
        /*
--fix for bug 2515762 to pass line_dtl_index instead of list_line_id
				QP_Calculate_Price_PUB.Price_Break_Calculation(
				l_bucket_price_rec.line_detail_index
                                ,l_bucket_price_rec.price_break_type_code
                                ,l_bucket_price_rec.line_ind
                                ,nvl(l_calc_quantity,1)
                                ,l_sub_total_price
                                ,l_return_adjustment
                                ,l_return_status
                                ,l_return_status_text);
*/
        --changes for PBH line group LUMPSUM bug 2388011 calling new
        --overloaded procedure Price_Break_Calculation

        -- [nirmkuma 4222552 ] since passed line group manual discounts are
        -- treated only as line level, using following line level path, which
        -- looks at updated line_priced_quantity.

        IF (l_bucket_price_rec.modifier_level_code IN (G_LINE_LEVEL, G_ORDER_LEVEL)
         or (l_bucket_price_rec.modifier_level_code = G_LINE_GROUP
                   and l_bucket_price_rec.automatic_flag = G_NO)) THEN
          IF nvl(l_pbh_pricing_attr, 'NULL') = G_QUANTITY_ATTRIBUTE THEN
            l_total_value := 0;
            l_req_value_per_unit := l_bucket_price_rec.priced_qty;
          ELSE --same for item amount or others(treat as item_amt)
            l_total_value := l_bucket_price_rec.priced_quantity;
            l_req_value_per_unit := l_bucket_price_rec.priced_qty;
            l_qualifier_value := l_bucket_price_rec.priced_quantity; --2892848  move to here

            -- begin 2892848
            -- net_amount line level (not group of line) modifier
            IF l_bucket_price_rec.net_amount_flag IN (G_YES, 'P') THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('net amount line level modifier: '|| l_bucket_price_rec.created_from_list_line_id);
              END IF; -- end debug
              /* SL_latest
                        IF l_prev_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
                          l_qualifier_value:= l_bucket_price_rec.priced_quantity
						  + nvl(l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind),0)* l_bucket_price_rec.priced_qty;
                          IF l_debug = FND_API.G_TRUE THEN
                            QP_PREQ_GRP.engine_debug('line amount: '||l_bucket_price_rec.priced_quantity);
                            QP_PREQ_GRP.engine_debug('order qty : '||l_bucket_price_rec.priced_qty);
                            QP_PREQ_GRP.engine_debug('unit adjs up to prev buckets: '|| nvl(l_prev_bucket_index_adj_tbl(l_bucket_price_rec.line_ind),0) );
                          END IF; -- end debug
                        ELSE
                          l_qualifier_value:= l_bucket_price_rec.priced_quantity;
                        END IF; -- END IF l_prev_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec)
                        */
              IF l_bucket_amt_tbl.EXISTS(l_bucket_price_rec.line_ind)THEN
                l_qualifier_value := l_bucket_amt_tbl(l_bucket_price_rec.line_ind);
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('line level net amount, SL_latest ?: '|| l_bucket_amt_tbl(l_bucket_price_rec.line_ind));
                END IF; -- end debug
              END IF; -- END IF l_bucket_amt_tbl.EXISTs
            END IF; -- END IF net_amount modifier
            -- end 2892848

          END IF; --l_pbh_pricing_attr
        ELSE --linegroup level
          IF nvl(l_pbh_pricing_attr, 'NULL') = G_QUANTITY_ATTRIBUTE THEN
            l_total_value := 0;
            l_req_value_per_unit := l_bucket_price_rec.group_quantity;
          ELSE --same for item amount or others(treat as item_amt)
            l_total_value := l_bucket_price_rec.priced_quantity;
            l_req_value_per_unit := l_bucket_price_rec.group_amount;

            -- begin 2892848
            -- IF net amount linegroup modifier
            IF l_bucket_price_rec.net_amount_flag IN (G_YES, 'P') THEN

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('net amount linegroup modifier id: '|| l_bucket_price_rec.created_from_list_line_id);
              END IF; -- end debug

              l_lg_net_amt := 0;
              l_line_bucket_amt := 0; -- note 0+null is null
              -- [julin/4112395/4220399]
              l_lg_prod_net_amt := 0;
              l_prod_line_bucket_amt := 0;

              -- net amount is grp_amt - (adj_amts of all lines from prev bucket)
              --l_qualifier_value  := l_bucket_price_rec.priced_quantity + l_prev_lg_adj_amt;  -- 2892848 old way

              -- begin SL_latest
              -- SL_further_fix
              -- if there are no prev buckets(l_prev_bucket=-9999) for this modifier, then use group amount
              -- since we do not have the adjs of other lines yet, l_bucket_amt_tbl does not have complete data

              -- [julin/3265308] net amount calculation 'P', match product only.
              -- For category net amount, 1st_bucket means that this is the
              -- first bucket of the line, so no adjustments have been ap-
              -- plied.  However, other lines of the same category might
              -- have had modifiers in previous buckets applied, so we look
              -- at the bucket_amt_tbl to see if those have been calculated
              -- else we can assume no modifiers applied yet, and can hence
              -- calculate the list price * qty for those lines.
              IF nvl(l_bucket_price_rec.net_amount_flag, 'N') = 'P' THEN
                IF l_mod_lg_prod_net_amt_tbl.EXISTS(l_bucket_price_rec.created_from_list_line_id) THEN
                  l_lg_prod_net_amt := l_mod_lg_prod_net_amt_tbl(l_bucket_price_rec.created_from_list_line_id);
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('recycle l_lg_prod_net_amt from l_mod_lg_net_amt_tbl: '|| l_lg_prod_net_amt);
                  END IF; --end debug
                ELSE -- need to calculate l_lg_net_amt
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('1st bucket = '|| l_1st_bucket ||', net amount flag = P');
                  END IF;
                  -- calculate amount using product attribute net amount grouping
                  FOR t IN l_prod_attr_info(l_bucket_price_rec.created_from_list_line_id) LOOP
                    IF l_prev_bucket_amt_tbl.EXISTS(t.line_index) THEN
                      l_prod_line_bucket_amt := nvl(l_prev_bucket_amt_tbl(t.line_index), 0);
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug(t.line_index || ':' || l_prev_bucket_amt_tbl(t.line_index));
                      END IF; --end debug
                    ELSE
                      -- have to compute list price * qty for the line (query from qp_npreq_lines_tmp)
                      l_prod_line_bucket_amt := nvl(t.priced_quantity, 0) * nvl(t.unit_price, 0);
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('* line index '|| t.line_index ||' not in l_prev_bucket_amt_tbl');
                        QP_PREQ_GRP.engine_debug('  got value '|| l_prod_line_bucket_amt ||' from lines_tmp instead');
                      END IF;
                    END IF;
                    l_lg_prod_net_amt := l_lg_prod_net_amt + l_prod_line_bucket_amt;

                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('(catnetamt) l_prod_line_bucket_amt: ' || l_prod_line_bucket_amt);
                      QP_PREQ_GRP.engine_debug('(catnetamt) up-tp-date l_lg_prod_net_amt: ' || l_lg_prod_net_amt); -- grp amt
                    END IF;
                  END LOOP;

                  l_mod_lg_prod_net_amt_tbl(l_bucket_price_rec.created_from_list_line_id) := l_lg_prod_net_amt; -- preserve this for recycle
                END IF;
              END IF; -- end l_bucket_price_rec.net_amount_flag = 'P'   -- [julin/3265308]

              IF l_1st_bucket = 'Y' THEN

                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug(' l_1st_bucket is Y, use group amount as l_lg_net_amt'); -- grp amt
                END IF; -- end debug
                l_lg_net_amt := l_bucket_price_rec.priced_quantity;

              ELSE --  l_1st_bucket <>'Y'

                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug(' - not first bucket');
                END IF;
                IF l_mod_lg_net_amt_tbl.EXISTS(l_bucket_price_rec.created_from_list_line_id) THEN
                  l_qualifier_value := l_mod_lg_net_amt_tbl(l_bucket_price_rec.created_from_list_line_id);
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('recycle lg_net_amt from l_mod_lg_net_amt_tbl('|| l_bucket_price_rec.line_ind ||'): '|| l_qualifier_value);
                  END IF; --end debug

                ELSE -- ELSE IF l_mod_lg_net_amt_tbl.EXISTS

                    -- regular net amount processing
                    -- fix of latest requirement, only add up net amounts with in the group
                    -- lg_net_amt_tbl is hastable of modifier and its lg_net_amt for that bucket, to_do
                    -- lg_net_amt is the sum of (USP at end of last bucket *Qty) for the lines related to this modifier
                    -- l_net_mod_index_cur has line_indexes related to this net amount modifier

                  -- regular net amount processing
                  -- fix of latest requirement, only add up net amounts with in the group
                  -- lg_net_amt_tbl is hastable of modifier and its lg_net_amt for that bucket, to_do
                  -- lg_net_amt is the sum of (USP at end of last bucket *Qty) for the lines related to this modifier
                  -- l_net_mod_index_cur has line_indexes related to this net amount modifier

                  FOR t IN l_net_mod_index_cur(l_bucket_price_rec.created_from_list_line_id) LOOP
                    IF l_bucket_amt_tbl.EXISTS(t.line_index) THEN
                      l_line_bucket_amt := nvl(l_bucket_amt_tbl(t.line_index), 0);
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug(t.line_index || ':' || l_bucket_amt_tbl(t.line_index));
                      END IF; --end debug
                    ELSE
                      l_line_bucket_amt := 0;
                    END IF;
                    l_lg_net_amt := l_lg_net_amt + l_line_bucket_amt;

                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('net amount l_bucket_amt_tbl('|| t.line_index ||'): '|| l_line_bucket_amt);
                    END IF; --end debug

                  END LOOP; -- end l_net_mod_index_cur

                  l_mod_lg_net_amt_tbl(l_bucket_price_rec.created_from_list_line_id) := l_lg_net_amt;

                END IF; --l_mod_lg_net_amt_tbl.EXIST
              END IF; -- END IF l_prev_bucket = -9999

              -- end SL_latest

              -- [julin/4112395/4220399]
              IF (nvl(l_bucket_price_rec.net_amount_flag, 'N') = 'P') THEN
                l_qualifier_value := l_lg_prod_net_amt;
                -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                IF (l_sub_total_price = 0) THEN
                  l_req_value_per_unit := FND_API.G_NULL_NUM;
                  l_applied_req_value_per_unit := FND_API.G_NULL_NUM;
                ELSE
                  l_req_value_per_unit := l_lg_prod_net_amt / l_sub_total_price; --bug 3404493
                  l_applied_req_value_per_unit := l_lg_net_amt / l_sub_total_price;
                END IF;
              ELSE
                l_qualifier_value := l_lg_net_amt;
                -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM means infinity
                IF (l_sub_total_price = 0) THEN
                  l_req_value_per_unit := FND_API.G_NULL_NUM;
                ELSE
                  l_req_value_per_unit := l_lg_net_amt / l_sub_total_price; --bug 3404493
                END IF;
              END IF;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('group amount: ' || l_bucket_price_rec.priced_quantity); -- grp amt
                QP_PREQ_GRP.engine_debug('group of lines net amt: '|| l_qualifier_value);

              END IF; --end debug

            ELSE -- not net amount modifier
              l_qualifier_value := l_bucket_price_rec.priced_quantity; -- not net amount grouop of line modifier

            END IF; -- END IF net_amount_flag = 'Y' for line group modifiers
            -- end 2892848

          END IF; --l_pbh_pricing_attr
        END IF; --modifier level code

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('PBH break dtls attribute '
                                   || l_pbh_pricing_attr ||' l_total_value '|| l_total_value
                                   ||' l_req_value_per_unit '|| l_req_value_per_unit);
        END IF; --l_debug

        -- obtain net_adj_amount_flag from qp_list_lines table if null,
        -- since it may not be passed from calling application
        -- net_amount_new 2720717
        IF l_bucket_price_rec.net_amount_flag IS NULL THEN
          OPEN l_net_amount_flag_cur(l_bucket_price_rec.created_from_list_line_id);
          FETCH l_net_amount_flag_cur INTO l_bucket_price_rec.net_amount_flag;
          CLOSE l_net_amount_flag_cur;
        END IF;

        -- [julin/3265308] Price_Break_Calculation should have same
        -- behavior for both net_amount_flag = G_YES and 'P'.
        IF (l_bucket_price_rec.net_amount_flag IN (G_YES, 'P')) THEN
          l_bucketed_flag := G_YES;
        ELSE
          l_bucketed_flag := G_NO;
        END IF;

          --4900095 used in price_break_calculation
          G_PBH_MOD_LEVEL_CODE(l_bucket_price_rec.line_detail_index) :=
                    l_bucket_price_rec.modifier_level_code;

        QP_Calculate_Price_PUB.Price_Break_Calculation(
                                                       l_bucket_price_rec.line_detail_index,  -- line_detail_index
                                                       l_bucket_price_rec.price_break_type_code,
                                                       l_bucket_price_rec.line_ind,
                                                       l_req_value_per_unit,  -- Group Value per unit,group quantity,item qty 40
                                                       l_applied_req_value_per_unit,  -- [julin/4112395/4220399]
                                                       l_total_value,  -- Total value (Group amount or item amount) 4000
                                                       l_sub_total_price,
                                                       --l_bucket_price_rec.priced_quantity, -- 2388011
                                                       l_bucket_price_rec.priced_qty,  -- FIX BUG 2880314, should be order qty of the line
                                                       --l_pbh_prev_net_adj_amount, -- net_amt_new 2720717--2892848
                                                       l_qualifier_value,  -- p_bucketed_adj, 2892848
                                                       l_bucketed_flag,  -- net_amt_new 2720717, [julin/3265308]
                                                       l_bucket_price_rec.automatic_flag, -- 5413797
                                                       l_return_adjustment,
                                                       l_return_status,
                                                       l_return_status_text);
        --end changes for bug 2388011

        l_return_adjustment :=
        - 1 * nvl(l_return_adjustment, 0);

        -- 2892848
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('PBH return adjustment '|| l_return_adjustment); --40
        END IF; --l_debug
        -- end 2892848

      ELSE --created_from_list_line_type not PBH 2892848 comment change
        /*
		   	  IF l_bucket_price_rec.updated_flag = G_YES
		   	  and nvl(l_bucket_price_rec.automatic_flag,G_NO) = G_NO
		   	  and (l_bucket_price_rec.adjustment_amount IS NOT NULL
				and l_bucket_price_rec.adjustment_amount <>
							G_MISS_NUM) --FND_API.G_MISS_NUM)
		   	  THEN
				--to avoid rounding issues in rev calculations
				--for user-overridden adjustments
			        l_return_adjustment :=
				        l_bucket_price_rec.adjustment_amount;
			  ELSE
			*/--commented to avoid overriding errors

        Calculate_bucket_price(
                               l_bucket_price_rec.created_from_list_line_type
                               , l_sub_total_price
                               , nvl(l_calc_quantity, 1)
                               , l_bucket_price_rec.operand_calculation_code
                               , nvl(l_bucket_price_rec.operand_value, 0) * l_sign
                               , l_return_adjustment
                               , l_return_status
                               , l_return_status_text);
        --  END IF;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
        x_return_status := l_return_status;
        x_return_status_text := l_return_status_text;
        RAISE Calculate_Exc;
      END IF;

      -- 2892848
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' unrounded adj_amt l_return_adjustment '|| l_return_adjustment); -- 2892848, will be rounded later, ok
      END IF; --END IF l_debug
      /* SL_latest
			-- CONTINUE building l_bucket_adj_amt_tbl and l_bucket_index_adj_tbl regardless of bucket
		IF l_bucket_price_rec.pricing_group_sequence IS NOT NULL THEN
		  IF l_bucket_adj_amt_tbl.EXISTS(l_bucket_price_rec.pricing_group_sequence) THEN -- avoid no data found or table index not exists for 1st rec
		    IF l_debug = FND_API.G_TRUE THEN
		      QP_PREQ_GRP.engine_debug ('    accumulated adj amts by bucket BEFORE: ' || l_bucket_adj_amt_tbl(l_bucket_price_rec.pricing_group_sequence));
		    END IF; -- end debug
		    l_bucket_adj_amt_tbl(l_bucket_price_rec.pricing_group_sequence):= nvl(l_bucket_adj_amt_tbl(l_bucket_price_rec.pricing_group_sequence),0) +
		      nvl(l_return_adjustment,0)* l_bucket_price_rec.priced_qty;

		  ELSE -- avoid no data found err
		    l_bucket_adj_amt_tbl(l_bucket_price_rec.pricing_group_sequence):= nvl(l_return_adjustment,0) * l_bucket_price_rec.priced_qty;
		  END IF; -- END IF l_bucket_adj_amt_tbl.EXISTS

		  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug ('    (LINEGROUP) building l_bucket_adj_amt_tbl by bucket: '||l_bucket_price_rec.pricing_group_sequence);
                    QP_PREQ_GRP.engine_debug ('    nvl of current unit adj: '||nvl(l_return_adjustment, 0));
                    QP_PREQ_GRP.engine_debug ('    order qty: '||l_bucket_price_rec.priced_qty);
                    QP_PREQ_GRP.engine_debug ('    accumulated adj amts for this bucket: ' || l_bucket_adj_amt_tbl(l_bucket_price_rec.pricing_group_sequence));
           END IF; -- END debug

           -- for LINE LEVEL
           IF l_bucket_index_adj_tbl.EXISTS(l_bucket_price_rec.line_ind) THEN
              IF l_debug = FND_API.G_TRUE THEN
		        QP_PREQ_GRP.engine_debug ('    accumulated unit adj by line BEFORE: ' || nvl(l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind), 0));
		      END IF; -- end debug
              l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind) := nvl(l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind), 0) + nvl(l_return_adjustment, 0);
		  ELSE -- avoid no datat found err
		    l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind) := nvl(l_return_adjustment, 0);
		  END IF; -- END IF l_bucket_index_adj_tbl.EXISTS

		  IF l_debug = FND_API.G_TRUE THEN
		      QP_PREQ_GRP.engine_debug ('    (LINE) building l_bucket_index_adj_tbl for line_index: '||l_bucket_price_rec.line_ind);
		      QP_PREQ_GRP.engine_debug ('    accumulated unit adjs by line index: '||l_bucket_index_adj_tbl(l_bucket_price_rec.line_ind));
		  END IF; -- END debug
		END IF; -- END IF l_bucket_price_rec.pricing_group_sequence IS NOT NULL
		-- end 2892848
		*/
      --round the adjustment_amount with factor on the line
      --engine updates the factor on the line
      --w/nvl(user_passed,price_list rounding_factor)
      IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ -- 2892848_latest
        AND l_bucket_price_rec.rounding_factor IS NOT NULL
        THEN
        l_return_adjustment :=
        round(l_return_adjustment,
              ( - 1 * l_bucket_price_rec.rounding_factor));
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('rounded adj: '||
                                 l_return_adjustment
                                 ||' roundingfac: '|| l_bucket_price_rec.rounding_factor);

      END IF;
      l_bucket_price_rec.adjustment_amount :=
      nvl(l_return_adjustment, 0);

      /*	SL_latest 2892848
		        l_pbh_net_adj_amount := l_pbh_net_adj_amount + l_bucket_price_rec.adjustment_amount; -- 2892848 SL_latest

			IF l_debug = FND_API.G_TRUE THEN
			  QP_PREQ_GRP.engine_debug('adjustment_amount: '||l_bucket_price_rec.adjustment_amount);
			  QP_PREQ_GRP.engine_debug('l_pbh_net_adj_amount: '||l_pbh_net_adj_amount);
			END IF; -- END IF l_debug
			*/
      --code added to calculate adj amt on order lvl adj
      --fix for bug 1767249
      IF l_bucket_price_rec.line_type =
        G_ORDER_LEVEL
        AND l_bucket_price_rec.created_from_list_line_type
        <> G_FREIGHT_CHARGE
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('ord lvl adj processing '
                                   || l_bucket_price_rec.line_type ||' listlineid '
                                   || l_bucket_price_rec.created_from_list_line_id);
        END IF;
        IF l_ord_dtl_index_tbl.COUNT = 0
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('ord lvl firstrec');
          END IF;
          l_ord_dtl_index_tbl(1) :=
          l_bucket_price_rec.line_detail_index;
          --fix for bug2424931 multiply by priced_qty
          l_ord_adj_amt_tbl(1) :=
          nvl(l_bucket_price_rec.adjustment_amount, 0) *
          nvl(l_bucket_price_rec.priced_qty, 0);
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('ordlvl firstrec adj '
                                     || l_ord_adj_amt_tbl(1));
          END IF;
        ELSE
          FOR n IN
            l_ord_dtl_index_tbl.FIRST..l_ord_dtl_index_tbl.LAST
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('ord lvl adj index '||
                                       l_ord_dtl_index_tbl(n) ||' current rec index '
                                       || l_bucket_price_rec.line_detail_index
                                       ||' count '|| l_ord_dtl_index_tbl.COUNT
                                       ||' lastrec dtl index '
                                       || l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.LAST));
            END IF;
            IF l_ord_dtl_index_tbl(n) =
              l_bucket_price_rec.line_detail_index
              THEN
              --fix for bug2424931 multiply by priced_qty
              l_ord_adj_amt_tbl(n) := l_ord_adj_amt_tbl(n) +
              nvl(l_bucket_price_rec.adjustment_amount, 0) *
              nvl(l_bucket_price_rec.priced_qty, 0);
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl adj amt '||
                                         l_ord_adj_amt_tbl(n));
              END IF;
              EXIT; --exit the loop once matches
            ELSIF l_ord_dtl_index_tbl(n) =
              l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.LAST)
              AND l_ord_dtl_index_tbl(n) <>
              l_bucket_price_rec.line_detail_index
              THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl lastrec '||
                                         l_bucket_price_rec.line_detail_index ||' adjamt '
                                         || l_bucket_price_rec.adjustment_amount
                                         ||' qty '|| l_bucket_price_rec.priced_qty);
              END IF;
              l_ord_dtl_index_tbl(l_ord_dtl_index_tbl.COUNT + 1)
              := l_bucket_price_rec.line_detail_index;
              --fix for bug2424931 multiply by priced_qty
              l_ord_adj_amt_tbl(l_ord_dtl_index_tbl.COUNT)
              := nvl(l_bucket_price_rec.adjustment_amount, 0) *
              nvl(l_bucket_price_rec.priced_qty, 0);
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('ord lvl adj amt '||
                                         l_ord_adj_amt_tbl(l_ord_dtl_index_tbl.COUNT));
              END IF;
            END IF;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('ord lvl adj:dtlindex '
                                       || l_ord_dtl_index_tbl(n) ||' adj amt '
                                       || l_ord_adj_amt_tbl(n));
            END IF;
          END LOOP; --l_ord_dtl_index_tbl
        END IF; --l_ord_dtl_index_tbl.COUNT
      END IF; --order level


      --end code added to calculate adj amt on order lvl adj
      --manual frt charges shd not be returned as applied
      IF nvl(l_bucket_price_rec.automatic_flag, G_NO) = G_YES
        OR (nvl(l_bucket_price_rec.applied_flag, G_NO) = G_YES
            AND nvl(l_bucket_price_rec.updated_flag, G_NO) = G_YES)
        THEN
        l_bucket_price_rec.applied_flag := G_YES;
      ELSE
        l_bucket_price_rec.applied_flag := G_NO;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        l_bucket_price_rec.process_code :=
        FND_API.G_RET_STS_ERROR;
        l_bucket_price_rec.pricing_status_text :=
        l_return_status_text;
      END IF;


      --populate grp/line qty into line qty
      l_bucket_price_rec.priced_quantity :=
      l_bucket_price_rec.priced_quantity;
      l_ldet_tbl(i) := l_bucket_price_rec;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Passed to table:
                                 line index '|| l_ldet_tbl(i).line_ind ||
                                 ' list_line_id '|| l_ldet_tbl(i).created_from_list_line_id ||
                                 ' adjustment amount '|| l_ldet_tbl(i).adjustment_amount ||
                                 ' applied flag '|| l_ldet_tbl(i).applied_flag);




      END IF;
      IF l_bucket_price_rec.created_from_list_line_type IN
        (G_DISCOUNT, G_SURCHARGE, G_PRICE_BREAK_TYPE)
        AND nvl(l_bucket_price_rec.accrual_flag, G_NO) = G_NO
        THEN

        l_adjusted_price := (l_adjusted_price + nvl(l_return_adjustment, 0));
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Display price: price '
                                   --||l_list_price||' sub-t '||l_sub_total_price -- 2892848
                                   ||' adj price (USP) '|| l_adjusted_price
                                   ||' ret adj '|| l_return_adjustment);
        END IF; -- end debug

        j := l_bucket_price_rec.line_ind; -- 2892848

        --Update the adjustment amount for each adjustment
        l_lines_tbl(j).line_index := l_bucket_price_rec.line_ind;
        l_lines_tbl(j).adjusted_unit_price := l_adjusted_price;

        -- 2892848_latest, do not round here since it is not final USP
        --round the selling price if G_ROUND_INDIVIDUAL_ADJ=Y
        -- need to re-evaluate how this should work now
        /*
             IF G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND -- shu, fix bug 2239061
             and l_lines_tbl(j).rounding_factor IS NOT NULL
                        THEN
             IF l_debug = FND_API.G_TRUE THEN
			   QP_PREQ_GRP.engine_debug('round current USP, rounding_factor: '
				||l_lines_tbl(j).rounding_factor);
             END IF;
                                l_lines_tbl(j).adjusted_unit_price :=
                                round(l_lines_tbl(j).adjusted_unit_price,
                                -1*l_lines_tbl(j).rounding_factor);
            END IF; -- END IF G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
            */

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('adjusted_price'
                                   || l_lines_tbl(j).adjusted_unit_price ||
                                   ' bucket '|| l_bucket_price_rec.pricing_group_sequence ||
                                   ' list_line_id '|| l_bucket_price_rec.created_from_list_line_id);
        END IF;
      END IF;


      --Freight Charge functionality
      IF l_bucket_price_rec.created_from_list_line_type =
        G_FREIGHT_CHARGE
        AND nvl(l_bucket_price_rec.automatic_flag, G_NO) = G_YES
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('frt chrge func '
                                   ||'looping thru freight charge for list_line id '
                                   || l_bucket_price_rec.created_from_list_line_id
                                   ||' adj amt '
                                   || l_bucket_price_rec.adjustment_amount ||' upd '
                                   || l_bucket_price_rec.updated_flag);

        END IF;
        --deleting all the frt charges to start with
        l_ldet_tbl(i).pricing_status_code := G_STATUS_DELETED;
        l_ldet_tbl(i).pricing_status_text :=
        G_NOT_MAX_FRT_CHARGE;

        IF l_frt_charge_tbl.COUNT = 0
          THEN
          --no record for charge type subtype combn
          --so insert into l_frt_charge_tbl
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('No frt charge so far'
                                     ||' insert new frt record ');
          END IF;
          l_frt_charge_tbl(1).line_index :=
          l_bucket_price_rec.line_ind;
          l_frt_charge_tbl(1).line_detail_index :=
          l_bucket_price_rec.line_detail_index;
          l_frt_charge_tbl(1).created_from_list_line_id :=
          l_bucket_price_rec.created_from_list_line_id;
          l_frt_charge_tbl(1).adjustment_amount :=
          l_bucket_price_rec.adjustment_amount;
          l_frt_charge_tbl(1).charge_type_code :=
          l_bucket_price_rec.charge_type_code;
          l_frt_charge_tbl(1).charge_subtype_code :=
          l_bucket_price_rec.charge_subtype_code;
          l_frt_charge_tbl(1).updated_flag :=
          nvl(l_bucket_price_rec.updated_flag, G_NO);
          --this is to show if a frt rec is max or not
          l_ldet_tbl(i).is_max_frt := G_YES;
          IF l_bucket_price_rec.modifier_level_code IN
            (G_LINE_LEVEL, G_LINE_GROUP)
            THEN
            l_frt_charge_tbl(1).LEVEL := G_LINE_LEVEL;
          ELSIF l_bucket_price_rec.modifier_level_code =
            G_ORDER_LEVEL
            THEN
            l_frt_charge_tbl(1).LEVEL := G_ORDER_LEVEL;
          END IF;
        ELSIF l_frt_charge_tbl.COUNT > 0
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('frtchrg records exist');

          END IF;
          FOR N IN l_frt_charge_tbl.FIRST..l_frt_charge_tbl.LAST
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('existing frt record id '
                                       || l_frt_charge_tbl(N).created_from_list_line_id);
              -- begin 2892848
              QP_PREQ_GRP.engine_debug('begin shu debug, line_ind: '-- 2892848
                                       || l_bucket_price_rec.line_ind ||' line_index: '|| l_frt_charge_tbl(N).line_index );
              QP_PREQ_GRP.engine_debug('charge_type_code, rec: '-- 2892848
                                       || l_bucket_price_rec.charge_type_code ||' frt tbl: '|| l_frt_charge_tbl(N).charge_type_code );
              QP_PREQ_GRP.engine_debug('charge_subtype_code, rec: '-- 2892848
                                       || l_bucket_price_rec.charge_subtype_code ||' frt tbl: '|| l_frt_charge_tbl(N).charge_subtype_code );
              QP_PREQ_GRP.engine_debug('level, rec: '-- 2892848
                                       || l_bucket_price_rec.modifier_level_code ||' frt tbl: '|| l_frt_charge_tbl(N).LEVEL );
              -- end 2892848

            END IF; -- end debug
            IF l_bucket_price_rec.line_ind = l_frt_charge_tbl(N).line_index -- 2892848, bug fix
              AND nvl(l_bucket_price_rec.charge_type_code, 'NULL') =  -- 2892848, bug fix
              nvl(l_frt_charge_tbl(N).charge_type_code, 'NULL')
              AND nvl(l_bucket_price_rec.charge_subtype_code, 'NULL') =
              nvl(l_frt_charge_tbl(N).charge_subtype_code, 'NULL')
              AND (l_frt_charge_tbl(N).LEVEL =
                   l_bucket_price_rec.modifier_level_code
                   OR (l_frt_charge_tbl(N).LEVEL = G_LINE_LEVEL AND
                       l_bucket_price_rec.modifier_level_code =
                       G_LINE_GROUP))
              THEN
              --record exists for charge type subtype combn
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('charge combn match'
                                         || l_frt_charge_tbl(N).updated_flag);
              END IF;
              IF nvl(l_frt_charge_tbl(N).updated_flag, G_NO) = G_NO
                THEN
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('Rec is NOT overriden');
                END IF;
                --only if user has not overridden
                --replace the record with the ct adj
                IF nvl(l_bucket_price_rec.updated_flag, G_NO) =
                  G_YES
                  THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Repl overridden rec');
                  END IF;
                  --if ct adj is overridden
                  l_frt_charge_tbl(N).line_detail_index
                  := l_bucket_price_rec.line_detail_index;
                  l_frt_charge_tbl(N).created_from_list_line_id :=
                  l_bucket_price_rec.created_from_list_line_id;
                  l_frt_charge_tbl(N).line_index
                  := l_bucket_price_rec.line_ind;
                  l_frt_charge_tbl(N).adjustment_amount
                  := l_bucket_price_rec.adjustment_amount;
                  l_frt_charge_tbl(N).updated_flag
                  := l_bucket_price_rec.updated_flag;
                ELSIF nvl(l_bucket_price_rec.updated_flag, G_NO) =
                  G_NO
                  AND l_bucket_price_rec.adjustment_amount
                  > l_frt_charge_tbl(N).adjustment_amount
                  THEN
                  --if ct adj's adj amt is greater
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('replace high adjamt');
                  END IF;
                  l_frt_charge_tbl(N).line_detail_index
                  := l_bucket_price_rec.line_detail_index;
                  l_frt_charge_tbl(N).created_from_list_line_id
                  := l_bucket_price_rec.created_from_list_line_id;
                  l_frt_charge_tbl(N).line_index
                  := l_bucket_price_rec.line_ind;
                  l_frt_charge_tbl(N).adjustment_amount
                  := l_bucket_price_rec.adjustment_amount;
                  l_frt_charge_tbl(N).updated_flag
                  := l_bucket_price_rec.updated_flag;
                END IF; --bucket_price_rec.updated_flag
              END IF; --frt_charge_tbl.updated_flag
              EXIT;
            ELSE
              --no match for charge type subtype combn
              --so insert into l_frt_charge_tbl
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('charge combn no match');
              END IF;
              IF N = l_frt_charge_tbl.LAST
                THEN
                --this is the last record and the
                --charge type subtype combn not match
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('hit last rec in tbl'
                                           ||' insert new record ');
                  QP_PREQ_GRP.engine_debug('shu debug, l_bucket_price_rec.adjustment_amount: '-- shu, 2892848
                                           || l_bucket_price_rec.adjustment_amount); -- 2892848
                END IF;
                l_frt_charge_tbl(N + 1).line_index :=
                l_bucket_price_rec.line_ind;
                l_frt_charge_tbl(N + 1).line_detail_index :=
                l_bucket_price_rec.line_detail_index;
                l_frt_charge_tbl(N + 1).created_from_list_line_id :=
                l_bucket_price_rec.created_from_list_line_id;
                l_frt_charge_tbl(N + 1).adjustment_amount :=
                l_bucket_price_rec.adjustment_amount;
                l_frt_charge_tbl(N + 1).charge_type_code :=
                l_bucket_price_rec.charge_type_code;
                l_frt_charge_tbl(N + 1).charge_subtype_code :=
                l_bucket_price_rec.charge_subtype_code;
                l_frt_charge_tbl(N + 1).updated_flag :=
                nvl(l_bucket_price_rec.updated_flag, G_NO);
                --this is to show if a frt rec is max or not
                l_ldet_tbl(i).is_max_frt := G_YES;
                IF l_bucket_price_rec.modifier_level_code IN
                  (G_LINE_LEVEL, G_LINE_GROUP)
                  THEN
                  l_frt_charge_tbl(N + 1).LEVEL :=
                  G_LINE_LEVEL;
                ELSIF l_bucket_price_rec.modifier_level_code =
                  G_ORDER_LEVEL
                  THEN
                  l_frt_charge_tbl(N + 1).LEVEL :=
                  G_ORDER_LEVEL;
                END IF;
              END IF; --last rec of frt_charge_tbl
            END IF; --matching charge_type/subtype
          END LOOP; --loop thru the frt charge tbl
        END IF; --frt charge tbl count

      END IF; --created_from_list_line_type is frt charge

    END LOOP;
    CLOSE l_bucket_price_cur;

    --Freight Charge Functionality update status of frt charge adj
    IF l_frt_charge_tbl.COUNT > 0
      THEN
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        FOR S IN l_frt_charge_tbl.FIRST..l_frt_charge_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('shu debug, line_index: '-- shu, 2892848
                                     || l_frt_charge_tbl(s).line_index); -- 2892848
            QP_PREQ_GRP.engine_debug('shu debug, l_frt_charge_tbl.line_detail_index: '-- shu, 2892848
                                     || l_frt_charge_tbl(s).line_detail_index); -- 2892848
            QP_PREQ_GRP.engine_debug('display frt dlts '
                                     ||' list line id '
                                     || l_frt_charge_tbl(s).created_from_list_line_id);
          END IF;
        END LOOP;
      END IF;
      FOR N IN l_ldet_tbl.FIRST..l_ldet_tbl.LAST
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('in frt charge loop (SL, l_ldet_tbl loop) '-- 2892848
                                   || l_ldet_tbl(N).created_from_list_line_id
                                   ||' '|| l_ldet_tbl(N).created_from_list_line_type
                                   ||' sts '|| l_ldet_tbl(N).pricing_status_code
                                   ||' is max frt '|| l_ldet_tbl(N).is_max_frt);
        END IF;
        IF l_ldet_tbl(N).created_from_list_line_type =
          G_FREIGHT_CHARGE
          THEN
          M := l_frt_charge_tbl.FIRST;
          WHILE M IS NOT NULL
            LOOP
            IF l_ldet_tbl(N).line_detail_index =
              l_frt_charge_tbl(M).line_detail_index
              AND l_ldet_tbl(N).line_ind =  -- 2892848 fix bug
              l_frt_charge_tbl(M).line_index -- 2892848 fix bug
              THEN
              l_ldet_tbl(N).pricing_status_code :=
              G_STATUS_NEW;
              l_ldet_tbl(N).pricing_status_text :=
              'MAX FRT CHARGE';
              l_frt_charge_tbl.DELETE(M);
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('applied frt charge '
                                         || l_ldet_tbl(N).created_from_list_line_id);
              END IF;
            END IF;
            M := l_frt_charge_tbl.NEXT(M);
          END LOOP; --frt_charge_tbl
        END IF;
      END LOOP;
    END IF; --frt_charge_tbl.count

    -- begin 2892848 shu test, move outer j loop head to here
    j := 0;

    j := l_lines_tbl.FIRST;
    WHILE j IS NOT NULL LOOP -- end 2892848

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Processed lines:
                                 line index'|| l_lines_tbl(j).line_index
                                 ||' updated adjusted price '
                                 || l_lines_tbl(j).updated_adjusted_unit_price
                                 ||' adjustment count '|| l_ldet_tbl.COUNT);

      END IF;
      x := l_ldet_tbl.FIRST;
      WHILE x IS NOT NULL LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('line_detail_index '
                                   || l_ldet_tbl(x).line_detail_index
                                   ||'up adj price1 '
                                   || l_ldet_tbl(x).created_from_list_line_id
                                   ||' status '
                                   || l_ldet_tbl(x).pricing_status_code
                                   ||' count '|| l_ldet_tbl.COUNT);
        END IF;

        /*
INDX,QP_PREQ_PUB.calculate_price.upd1,qp_npreq_ldets_tmp_U1,LINE_DETAIL_INDEX,1
*/
        UPDATE qp_npreq_ldets_tmp SET
                adjustment_amount = l_ldet_tbl(x).adjustment_amount,
                applied_flag = l_ldet_tbl(x).applied_flag,
                line_quantity = l_ldet_tbl(x).priced_quantity,
                --included for freight charge functionality
                pricing_status_code = l_ldet_tbl(x).pricing_status_code,
                pricing_status_text = l_ldet_tbl(x).pricing_status_text
                WHERE line_detail_index = l_ldet_tbl(x).line_detail_index;

        x := l_ldet_tbl.NEXT(x);
      END LOOP;


      /*****************************************************************
BACK CALCULATION ROUTINE
******************************************************************/

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION ROUTINE ');

      END IF;
      l_ldet_tbl.DELETE;

      --changes for bug 1963391
      --if a manual adj is applied and user overrides selling price back to original
      --price there is no point to check for back_calculate at the beginning
      --as l_amount_changed will be zero whereas at this point
      --l_amount_changed will not be zero

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BACK CALCULATION check: upd adj price '
                                 || l_lines_tbl(j).updated_adjusted_unit_price
                                 ||' adj price '|| l_lines_tbl(j).adjusted_unit_price);

      END IF;
      --fix for rounding issue for bug 2146050
      --round the overridden selling price

      l_adjusted_unit_price_ur(j) := l_lines_tbl(j).adjusted_unit_price; --[prarasto:Post Round]
      l_updated_adj_unit_price_ur(j) := l_lines_tbl(j).updated_adjusted_unit_price; --[prarasto:Post Round]

      IF l_lines_tbl(j).rounding_factor IS NOT NULL
        AND G_ROUND_INDIVIDUAL_ADJ not in ( G_NO_ROUND, G_POST_ROUND ) --[prarasto:Post Round] added check to
                                                                       --skip rounding for Post Round option
        THEN
        --first round the overridden selling price--2146050
        l_lines_tbl(j).updated_adjusted_unit_price :=
        round(l_lines_tbl(j).updated_adjusted_unit_price,
              - 1 * l_lines_tbl(j).rounding_factor);

        --also need to round final USP for the line here -2892848_latest
        l_lines_tbl(j).adjusted_unit_price :=
        round(l_lines_tbl(j).adjusted_unit_price,
              - 1 * l_lines_tbl(j).rounding_factor);
      END IF;

      -- 2892848
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('AFTER ROUNDING, adjusted_unit_price:'
                                 || l_lines_tbl(j).adjusted_unit_price
                                 ||' updated_adjusted_unit_price: '|| l_lines_tbl(j).adjusted_unit_price);

      END IF;

      --this amount changed is also rounded --2146050
      l_amount_changed := l_lines_tbl(j).updated_adjusted_unit_price
      - l_lines_tbl(j).adjusted_unit_price;

      l_back_calc_dtl_index := 0;
      l_back_calc_adj_amt := 0;

      --Back calculation
      IF (l_lines_tbl(j).updated_adjusted_unit_price IS NULL
          OR l_amount_changed = 0) --no back cal if no amt change
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('no back calculation');
        END IF;
        BACK_CALCULATE := FALSE;
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('back calculation set');
        END IF;
        BACK_CALCULATE := TRUE;

        OPEN l_chk_backcal_adj_exist_cur(l_lines_tbl(j).line_index);
        FETCH l_chk_backcal_adj_exist_cur INTO
        l_back_calc_dtl_index, l_back_calc_adj_amt;
        CLOSE l_chk_backcal_adj_exist_cur;

        l_back_calc_dtl_index :=
        nvl(l_back_calc_dtl_index, 0);
        l_back_calc_adj_amt :=
        nvl(l_back_calc_adj_amt, 0);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('back cal dtl '||
                                   l_back_calc_dtl_index ||' adjamt '|| l_back_calc_adj_amt);
        END IF;

        --changes for bug 2043442
        --calculate effective change in amount change which
        --includes the manual adjustment that may be applied
        --already irrespective of whether applied_flag is Y or N
        --This will recalculate adjustment amount rather
        --than calculating effective change when SP is overridden
        --second time or thereafter
        l_amount_changed := l_amount_changed +
        l_back_calc_adj_amt;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('back cal dtl '||
                                   ' amt changed '|| l_amount_changed);

        END IF;
        IF l_amount_changed <= 0 THEN
          l_BACK_CALCULATE_START_TYPE := G_DISCOUNT;
        ELSIF l_amount_changed > 0 THEN
          l_BACK_CALCULATE_START_TYPE := G_SURCHARGE;
        END IF;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('back calculation start type'
                                   || l_BACK_CALCULATE_START_TYPE
                                   ||' amount changed '|| l_amount_changed);

        END IF;
        l_return_status := '';
        l_return_status_text := '';

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('before back calculation '
                                   || l_lines_tbl(j).line_index
                                   ||' amt changed '|| l_amount_changed);
        END IF;
        IF l_amount_changed <= 0 THEN
          G_BACK_CALCULATION_CODE := 'DIS';
        ELSE
          G_BACK_CALCULATION_CODE := 'SUR';
        END IF; --l_amount_changed_tbl
        BACK_CALCULATION(l_lines_tbl(j).line_index
                         , l_amount_changed
                         , l_back_calc_ret_rec
                         , l_return_status
                         , l_return_status_text);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('after back calculation ');

        END IF;

        IF l_lines_tbl(j).rounding_factor IS NOT NULL
          AND G_ROUND_INDIVIDUAL_ADJ = G_ROUND_ADJ
          THEN
          --round the adjustment amount --2146050
          --it must have been rounded already
          l_back_calc_ret_rec.adjustment_amount :=
          round(l_back_calc_ret_rec.adjustment_amount,
                - 1 * l_back_calc_ret_rec.rounding_factor);
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('back calc rounded '
                                     || l_back_calc_ret_rec.adjustment_amount
                                     ||' roundingfac '
                                     || l_back_calc_ret_rec.rounding_factor);
          END IF;
        END IF;

      END IF;
      --end changes for bug 1963391



      IF BACK_CALCULATE
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Back calculate');
        END IF;
        IF l_back_calc_ret_rec.calculation_code
          = G_BACK_CALCULATE
          THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Back Calculate: '
                                     ||'before update ldets: line_detail_index '
                                     || l_back_calc_ret_rec.line_detail_index
                                     ||' list line id '
                                     || l_back_calc_ret_rec.list_line_id
                                     ||' adjustment amount '
                                     || l_back_calc_ret_rec.adjustment_amount
                                     ||' operand '|| l_back_calc_ret_rec.operand_value
                                     ||' calculation_code '
                                     || l_back_calc_ret_rec.calculation_code);

            QP_PREQ_GRP.engine_debug('chk back cal dtl '||
                                     l_back_calc_dtl_index);

          END IF;
          IF l_back_calc_dtl_index <> 0
            AND l_back_calc_dtl_index <>
            l_back_calc_ret_rec.line_detail_index
            THEN
            --delete the existing back calculated adj
            UPDATE qp_npreq_ldets_tmp
                    SET applied_flag = G_NO,
                    calculation_code = NULL,
                    pricing_status_code = G_STATUS_DELETED,
                    pricing_status_text =
                    'DELETED IN BACK CALC DUE TO CHANGE IN ADJ AMT'
            WHERE line_detail_index = l_back_calc_dtl_index;

          END IF;

          /*
INDX,QP_PREQ_PUB.calculate_price.upd2,qp_npreq_ldets_tmp_U1,LINE_DETAIL_INDEX,1
*/
          UPDATE qp_npreq_ldets_tmp ldet
          SET ldet.operand_value =
                  l_back_calc_ret_rec.operand_value
          , ldet.adjustment_amount =
                  l_back_calc_ret_rec.adjustment_amount
          , ldet.applied_flag =
                  l_back_calc_ret_rec.applied_flag
          , ldet.updated_flag =
                  l_back_calc_ret_rec.updated_flag
          , ldet.process_code =
                  l_back_calc_ret_rec.process_code
          , ldet.pricing_status_text =
                  l_back_calc_ret_rec.pricing_status_text
          , ldet.calculation_code =
                  l_back_calc_ret_rec.calculation_code
          WHERE ldet.line_detail_index =
                  l_back_calc_ret_rec.line_detail_index
          AND ldet.line_index =
                  l_back_calc_ret_rec.line_index
          AND ldet.created_from_list_line_id =
                  l_back_calc_ret_rec.list_line_id;
        END IF;
      END IF; --back_calculate

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('return sts '|| l_return_status);
        QP_PREQ_GRP.engine_debug('return txt '|| l_return_status_text);
      END IF;
      IF BACK_CALCULATE
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Back calculate');

        END IF;
        IF l_return_status = FND_API.G_RET_STS_SUCCESS
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Back calculate Success');
          END IF;
          l_lines_tbl(j).processed_flag := G_PROCESSED;
          --change for bug 2146050
          --recalculate the selling price again after back calc
          l_lines_tbl(j).adjusted_unit_price :=
          l_lines_tbl(j).adjusted_unit_price +
          nvl(l_back_calc_ret_rec.adjustment_amount, 0);

          --[prarasto:Post Round] added to calculate unrounded adjusted unit price after calculating adjustment amount
          l_adjusted_unit_price_ur(j) := l_adjusted_unit_price_ur(j) +
                                        nvl(l_back_calc_ret_rec.adjustment_amount, 0);

          --round the SP if G_ROUND_INDIVIDUAL_ADJ=G_NO_ROUND_ADJ
          --IF G_ROUND_INDIVIDUAL_ADJ = G_NO_ROUND_ADJ

--          IF G_ROUND_INDIVIDUAL_ADJ <> G_NO_ROUND -- shu fix 2239061,
         IF G_ROUND_INDIVIDUAL_ADJ not in ( G_NO_ROUND, G_POST_ROUND ) --[prarasto:Post Round] added check to
                                                                       --skip rounding for Post Round option
            AND l_lines_tbl(j).rounding_factor IS NOT NULL
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('need to round selling price, rounding_factor: '
                                       || l_lines_tbl(j).rounding_factor);
            END IF;
            l_lines_tbl(j).adjusted_unit_price :=
            round(l_lines_tbl(j).adjusted_unit_price,
                  - 1 * l_lines_tbl(j).rounding_factor);
          END IF;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Back calculate Failure');
          END IF;
          l_lines_tbl(j).processed_flag := G_NOT_PROCESSED;
          l_lines_tbl(j).processed_code :=
          QP_PREQ_PUB.G_BACK_CALCULATION_STS;
          l_lines_tbl(j).pricing_status_code :=
          QP_PREQ_PUB.G_BACK_CALCULATION_STS;
          l_lines_tbl(j).pricing_status_text := l_return_status_text;
        END IF; --l_return_status
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('NO Back calculate');
        END IF;
        l_lines_tbl(j).processed_flag := G_PROCESSED;
      END IF; --back_calculate


      IF l_lines_tbl(j).processed_flag = G_PROCESSED THEN
        /*
INDX,QP_PREQ_PUB.calculate_price.upd3,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
        UPDATE qp_npreq_lines_tmp SET adjusted_unit_price
                = nvl(l_lines_tbl(j).updated_adjusted_unit_price,
                      l_lines_tbl(j).adjusted_unit_price)
                --, adjusted_unit_price_ur = nvl(l_updated_adj_unit_price_ur(j), --[prarasto:Post Round] added unrounded adjusted unit price, [julin/postround] redesign
                --                               l_adjusted_unit_price_ur(j))
                , processed_flag = l_lines_tbl(j).processed_flag
                , processed_code = l_lines_tbl(j).processed_code
                , pricing_status_code =
                                l_lines_tbl(j).pricing_status_code
                , pricing_status_text =
                                l_lines_tbl(j).pricing_status_text
                , QUALIFIERS_EXIST_FLAG = G_CALCULATE_ONLY
                WHERE line_index = l_lines_tbl(j).line_index;


        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Processed Price:
                                   line index'|| l_lines_tbl(j).line_index ||
                                   ' adjusted price '|| l_lines_tbl(j).adjusted_unit_price ||
                                   'processed_code' || l_lines_tbl(j).processed_code);
        END IF;
      ELSE
        /*
INDX,QP_PREQ_PUB.calculate_price.upd4,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
        UPDATE qp_npreq_lines_tmp SET adjusted_unit_price
                = l_lines_tbl(j).adjusted_unit_price
                --, adjusted_unit_price_ur = l_adjusted_unit_price_ur(j) --[prarasto:Post Round] added unrounded adjusted unit price, [julin/postround] redesign
                , processed_flag = l_lines_tbl(j).processed_flag
                , processed_code = l_lines_tbl(j).processed_code
                , pricing_status_code =
                                l_lines_tbl(j).pricing_status_code
                , pricing_status_text =
                                l_lines_tbl(j).pricing_status_text
                , QUALIFIERS_EXIST_FLAG = G_CALCULATE_ONLY
                WHERE line_index = l_lines_tbl(j).line_index;


        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Failed Process price:
                                   line index '|| l_lines_tbl(j).line_index ||
                                   ' adjusted price '|| l_lines_tbl(j).adjusted_unit_price ||
                                   'processed_code' || l_lines_tbl(j).processed_code);
        END IF;
      END IF;







      j := l_lines_tbl.NEXT(j);
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('-----------------------------------');
      END IF;
    END LOOP;

    --to update adj amt on order level adjustments
    IF l_ord_dtl_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('updating order lvl adj amt: '||
                                 l_ord_dtl_index_tbl.COUNT);
      END IF;
      FORALL i IN l_ord_dtl_index_tbl.FIRST..l_ord_dtl_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
      SET adjustment_amount = l_ord_adj_amt_tbl(i)
              WHERE line_detail_index = l_ord_dtl_index_tbl(i);
    END IF;



    --GSA VIOLATION CHECK

    -- Call GSA Check only for non-gsa customers(GSA_QUALIFIER_FLAG IS NULL)
    IF G_GSA_CHECK_FLAG = G_YES
      AND G_GSA_ENABLED_FLAG = G_YES
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Pub GSA check');

      END IF;
      /*
INDX,QP_PREQ_PUB.calculate_price.upd5,qp_npreq_lines_tmp_N2,LINE_TYPE_CODE,1
INDX,QP_PREQ_PUB.calculate_price.upd5,qp_npreq_line_attrs_tmp_N2,LINE_TYPE_CODE,1
INDX,QP_PREQ_PUB.calculate_price.upd5,qp_npreq_line_attrs_tmp_N1,LINE_INDEX,1
INDX,QP_PREQ_PUB.calculate_price.upd5,qp_npreq_line_attrs_tmp_N1,ATTRIBUTE_TYPE,2
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,PRICING_PHASE_ID,1
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,QUALIFICATION_IND,2
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTRIBUTE_CONTEXT,3
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTRIBUTE,4
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTRIBUTE_VALUE,5
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,EXCLUDER_FLAG,6
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,LIST_HEADER_ID,7
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICING_ATTRIBUTES_N5,LIST_LINE_ID,8
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_PRICE_REQ_SOURCES_PK,REQUEST_TYPE_CODE,1
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,ACTIVE_FLAG,1
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,CURRENCY_CODE,2
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,LIST_TYPE_CODE,3
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,SOURCE_SYSTEM_CODE,4
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,LIST_HEADER_ID,5
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_HEADERS_B_N1,GSA_INDICATOR,6
INDX,QP_PREQ_PUB.calculate_price.upd5,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Pub GSA attr_mgr_installed '
                                 || G_ATTR_MGR_INSTALLED);
      END IF;
      IF G_ATTR_MGR_INSTALLED = G_NO
        THEN
        UPDATE qp_npreq_lines_tmp line
        SET line.pricing_status_code = G_STATUS_GSA_VIOLATION
           , line.pricing_status_text = 'QP_PREQ_PUB: GSA VIOLATION'
        WHERE line.line_type_code = G_LINE_LEVEL
        --made this change look at only successful lines
                AND line.pricing_status_code IN
                        (G_STATUS_UPDATED, G_STATUS_UNCHANGED)
                AND NOT EXISTS (SELECT 'X'
                                FROM qp_npreq_line_attrs_tmp gsa_attr
                                WHERE gsa_attr.line_index = line.line_index
                                --fix for bug 2080187
                                AND gsa_attr.pricing_status_code = G_STATUS_UNCHANGED
                                AND gsa_attr.attribute_type = G_QUALIFIER_TYPE
                                AND gsa_attr.context = G_CUSTOMER_CONTEXT
                                AND gsa_attr.attribute = G_GSA_ATTRIBUTE
                                AND gsa_attr.value_from = G_YES)
                  AND line.adjusted_unit_price <=
                --(SELECT /*+ ORDERED USE_NL(qpa ql req lhdr) */ MIN(ql.operand)  -- 7323912
		(SELECT /*+ ORDERED USE_NL(qpa ql req lhdr) INDEX(LHDR QP_LIST_HEADERS_B_N9) */ MIN(ql.operand)  -- 7323912
                 FROM qp_npreq_line_attrs_tmp lattr,
                 qp_pricing_attributes qpa,
                 qp_list_headers_b lhdr,   --7323912
		 qp_price_req_sources req, --7323912
                 qp_list_lines ql
                 WHERE lattr.line_index = line.line_index
                 AND lattr.attribute_type = G_PRODUCT_TYPE
                 AND lattr.context = qpa.product_attribute_context
                 AND lattr.attribute = qpa.product_attribute
                 AND lattr.value_from = qpa.product_attr_value
                 AND qpa.excluder_flag = G_NO
                 AND qpa.pricing_phase_id = 2
                 AND qpa.qualification_ind = 6
                 AND lattr.line_index = line.line_index
                 AND req.request_type_code = line.request_type_code
                 AND lhdr.list_header_id = qpa.list_header_id
                 AND lhdr.active_flag = G_YES
                 AND ((lhdr.currency_code IS NOT NULL AND lhdr.currency_code = line.currency_code)
                      OR
                      lhdr.currency_code IS NULL) -- optional currency
                 AND lhdr.list_type_code = G_DISCOUNT_LIST_HEADER
                 AND lhdr.source_system_code = req.source_system_code
                 AND lhdr.gsa_indicator = G_YES
                 AND trunc(line.pricing_effective_date) BETWEEN
                 trunc(nvl(lhdr.start_date_active
                           , line.pricing_effective_date))
                 AND trunc(nvl(lhdr.End_date_active
                               , line.pricing_effective_date))
                 AND qpa.list_line_id = ql.list_line_id
                 AND trunc(line.pricing_effective_date) BETWEEN
                 trunc(nvl(ql.start_date_active
                           , line.pricing_effective_date))
                 AND trunc(nvl(ql.End_date_active
                               , line.pricing_effective_date)));
      ELSE --G_ATTR_MGR_INSTALLED
        UPDATE qp_npreq_lines_tmp line
        SET line.pricing_status_code = G_STATUS_GSA_VIOLATION
           , line.pricing_status_text = 'QP_PREQ_PUB: GSA VIOLATION'
        WHERE line.line_type_code = G_LINE_LEVEL
        --made this change look at only successful lines
                AND line.pricing_status_code IN
                        (G_STATUS_UPDATED, G_STATUS_UNCHANGED)
                AND NOT EXISTS (SELECT 'X'
                                FROM qp_npreq_line_attrs_tmp gsa_attr
                                WHERE gsa_attr.line_index = line.line_index
                                --fix for bug 2080187
                                AND gsa_attr.pricing_status_code = G_STATUS_UNCHANGED
                                AND gsa_attr.attribute_type = G_QUALIFIER_TYPE
                                AND gsa_attr.context = G_CUSTOMER_CONTEXT
                                AND gsa_attr.attribute = G_GSA_ATTRIBUTE
                                AND gsa_attr.value_from = G_YES)
                  AND line.adjusted_unit_price <=
                 --(SELECT /*+ ORDERED USE_NL(qpa ql req lhdr) */ MIN(ql.operand)   --7323912
		 (SELECT /*+ ORDERED USE_NL(qpa ql req lhdr) INDEX(LHDR QP_LIST_HEADERS_B_N9) */ MIN(ql.operand)   --7323912
                 FROM qp_npreq_line_attrs_tmp lattr,
                 qp_pricing_attributes qpa,
                 qp_list_headers_b lhdr,	--7323912
		 qp_price_req_sources_v req,	--7323912
                 qp_list_lines ql
                 WHERE lattr.line_index = line.line_index
                 AND lattr.attribute_type = G_PRODUCT_TYPE
                 AND lattr.context = qpa.product_attribute_context
                 AND lattr.attribute = qpa.product_attribute
                 AND lattr.value_from = qpa.product_attr_value
                 AND qpa.excluder_flag = G_NO
                 AND qpa.pricing_phase_id = 2
                 AND qpa.qualification_ind = 6
                 AND lattr.line_index = line.line_index
                 AND req.request_type_code = line.request_type_code
                 AND lhdr.list_header_id = qpa.list_header_id
                 AND lhdr.active_flag = G_YES
                 AND ((lhdr.currency_code IS NOT NULL AND lhdr.currency_code = line.currency_code)
                      OR
                      lhdr.currency_code IS NULL) -- optional currency
                 AND lhdr.list_type_code = G_DISCOUNT_LIST_HEADER
                 AND lhdr.source_system_code = req.source_system_code
                 AND lhdr.gsa_indicator = G_YES
                 AND trunc(line.pricing_effective_date) BETWEEN
                 trunc(nvl(lhdr.start_date_active
                           , line.pricing_effective_date))
                 AND trunc(nvl(lhdr.End_date_active
                               , line.pricing_effective_date))
                 AND qpa.list_line_id = ql.list_line_id
                 AND trunc(line.pricing_effective_date) BETWEEN
                 trunc(nvl(ql.start_date_active
                           , line.pricing_effective_date))
                 AND trunc(nvl(ql.End_date_active
                               , line.pricing_effective_date)));
      END IF;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('End Pub GSA check');
      END IF;
    END IF;



    --GSA VIOLATION CHECK


    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_RETURN_STATUS_TEXT := l_routine ||' SUCCESS ';

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('end calculate price');
    END IF;
  EXCEPTION
    WHEN Calculate_Exc THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in calculate_price'|| x_return_status_text);
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in calculate_price'|| SQLERRM);
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_RETURN_STATUS_TEXT := l_routine || SQLERRM;
  END CALCULATE_PRICE;


  --coded for bug 2264566
  --This is to delete/cleanup the related lines inserted by GRP
  --for manual PBH adjustment
  --when the calling application is passing the manual PBH to be applied
  PROCEDURE Cleanup_rltd_lines(x_return_status OUT NOCOPY VARCHAR2,
                               x_return_status_text OUT NOCOPY VARCHAR2) IS
  CURSOR l_dbg_cleanup_cur IS
    SELECT rltd.line_detail_index,
            rltd.related_line_detail_index,
            rltd.list_line_id,
            rltd.related_list_line_id,
            rltd.pricing_status_code
    FROM qp_npreq_rltd_lines_tmp rltd
    WHERE rltd.relationship_type_code = G_PBH_LINE;
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE
      THEN
      QP_PREQ_GRP.engine_debug('------------------------------');
      FOR cl IN l_dbg_cleanup_cur
        LOOP
        QP_PREQ_GRP.engine_debug('Rltd lines: line_dtl_index '
                                 || cl.line_detail_index ||' rltd_line_dtl_index '
                                 || cl.related_line_detail_index ||' list_line_id '
                                 || cl.list_line_id ||' rltd_list_line_id '|| cl.related_list_line_id
                                 ||' pricing_status_code '|| cl.pricing_status_code);
      END LOOP;
    END IF;

    --mark the engine passed relationships of manual PBH as deleted
    --if the parent PBH line is deleted
    UPDATE qp_npreq_rltd_lines_tmp SET pricing_status_code = G_STATUS_DELETED
            WHERE line_detail_index IN (SELECT line_detail_index
                                        FROM qp_npreq_ldets_tmp ldet
                                        WHERE (ldet.process_code = G_STATUS_DELETED
                                               OR ldet.pricing_status_code = G_STATUS_DELETED))
--fix for bug 2515762 automatic overrideable break
--                                and ldet.automatic_flag = G_NO)
            AND pricing_status_code = G_STATUS_NEW
            AND relationship_type_code = G_PBH_LINE;

    --mark the engine returned manual child PBH lines as deleted
    UPDATE qp_npreq_ldets_tmp ldet SET pricing_status_code = G_STATUS_DELETED
            WHERE ldet.line_detail_index IN
                    (SELECT rltd.related_line_detail_index
                     FROM qp_npreq_rltd_lines_tmp rltd
                     WHERE rltd.relationship_type_code = G_PBH_LINE
                     AND rltd.pricing_status_code = G_STATUS_DELETED);

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('------------------------------');
      FOR cl IN l_dbg_cleanup_cur
        LOOP
        QP_PREQ_GRP.engine_debug('Rltd lines: line_dtl_index '
                                 || cl.line_detail_index ||' rltd_line_dtl_index '
                                 || cl.related_line_detail_index ||' list_line_id '
                                 || cl.list_line_id ||' rltd_list_line_id '|| cl.related_list_line_id
                                 ||' pricing_status_code '|| cl.pricing_status_code);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in QP_PREQ_PUB.Cleanup_rltd_lines '|| SQLERRM;
  END Cleanup_rltd_lines;


  --coded for bug 2264566
  --This is to update the related lines passed by calling application
  --along with a manual/auto-overridden PBH adjustments with the relevant
  --information needed to calculate adjustment amount for PBH from the setup
  PROCEDURE Update_Related_Line_Info(x_return_status OUT NOCOPY VARCHAR2,
                                     x_return_status_text OUT NOCOPY VARCHAR2) IS

  CURSOR l_dbg_rltd_cur IS
    SELECT
    qpa.pricing_attr_value_from,
    qpa.pricing_attr_value_to,
    ldet_pbh.price_break_type_code,
    ldet_pbh.created_from_list_line_id list_line_id,
    ldet.created_from_list_line_id related_list_line_id,
    ldet.created_from_list_line_type related_list_line_type,
    ldet.operand_calculation_code operand_calculation_code,
    ldet.operand_value operand,
    ldet.pricing_group_sequence pricing_group_sequence,
    nvl(ldet.line_quantity,
        nvl(line.priced_quantity, line.line_quantity))
                    qualifier_value
    FROM
    qp_npreq_rltd_lines_tmp rltd,
    qp_npreq_lines_tmp line,
    qp_npreq_ldets_tmp ldet,
    qp_npreq_ldets_tmp ldet_pbh,
    qp_pricing_attributes qpa
    WHERE
    rltd.pricing_status_code = G_STATUS_NEW
    AND ldet.line_detail_index =
                    rltd.related_line_detail_index
    AND ldet_pbh.line_detail_index = rltd.line_detail_index
    AND line.line_index = ldet.line_index
    AND qpa.list_line_id = ldet.created_from_list_line_id
    AND qpa.pricing_attribute_context = G_PRIC_VOLUME_CONTEXT
    AND ldet.process_code = G_STATUS_NEW
    AND ldet.pricing_status_code = G_STATUS_UNCHANGED
    AND rltd.relationship_type_code = G_PBH_LINE;

  CURSOR l_dbg_rltd_upd_cur IS
    SELECT setup_value_from,
            setup_value_to,
            relationship_type_detail,
            list_line_id,
            related_list_line_id,
            related_list_line_type,
            operand_calculation_code,
            operand,
            pricing_group_sequence,
            qualifier_value
    FROM qp_npreq_rltd_lines_tmp rltd
    WHERE rltd.pricing_status_code = G_STATUS_NEW
    AND rltd.relationship_type_code = G_PBH_LINE;

  BEGIN

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('-------------------------------------');
      FOR cl IN l_dbg_rltd_cur
        LOOP
        QP_PREQ_GRP.engine_debug('rltd info: value_from '
                                 || cl.pricing_attr_value_from
                                 ||' value to '|| cl.pricing_attr_value_to
                                 ||' price brktype '|| cl.price_break_type_code
                                 ||' list_line_id '|| cl.list_line_id
                                 ||' rltd_list_line_id '|| cl.related_list_line_id
                                 ||' rltd_list_line_type '|| cl.related_list_line_type
                                 ||' operand_calculation_code '|| cl.operand_calculation_code
                                 ||' operand '|| cl.operand
                                 ||' bucket '|| cl.pricing_group_sequence
                                 ||' qualifier_value '|| cl.qualifier_value);
      END LOOP;
    END IF;

    --when any changes are made to this, the similar updated stmt
    --in update_passed_in_pbh procedure in this file also needs to be changed
    UPDATE qp_npreq_rltd_lines_tmp rltd
            SET (setup_value_from,
                 setup_value_to,
                 relationship_type_detail,
                 list_line_id,
                 related_list_line_id,
                 related_list_line_type,
                 operand_calculation_code,
                 operand,
                 pricing_group_sequence,
                 qualifier_value)
                    =
                    (SELECT
                     qpa.pricing_attr_value_from,
                     qpa.pricing_attr_value_to,
                     ldet_pbh.price_break_type_code,
                     ldet_pbh.created_from_list_line_id,
                     ldet.created_from_list_line_id,
                     ldet.created_from_list_line_type,
                     ldet.operand_calculation_code,
                     ldet.operand_value,
                     ldet.pricing_group_sequence,
                     nvl(ldet.line_quantity,
                         nvl(line.priced_quantity, line.line_quantity))
                     FROM
                     qp_npreq_lines_tmp line,
                     qp_npreq_ldets_tmp ldet,
                     qp_npreq_ldets_tmp ldet_pbh,
                     qp_pricing_attributes qpa
                     WHERE
                     ldet.line_detail_index = rltd.related_line_detail_index
                     AND ldet_pbh.line_detail_index = rltd.line_detail_index
                     AND line.line_index = ldet.line_index
                     AND qpa.list_line_id = ldet.created_from_list_line_id
                     AND ldet.process_code = G_STATUS_NEW
                     AND ldet.pricing_status_code = G_STATUS_UNCHANGED
                     AND rltd.relationship_type_code = G_PBH_LINE
                     AND rltd.pricing_status_code = G_STATUS_NEW)
    WHERE rltd.line_detail_index IN (SELECT ldet.line_detail_index
                                     FROM qp_npreq_ldets_tmp ldet
                                     WHERE ldet.process_code = G_STATUS_NEW
                                     AND ldet.pricing_status_code = G_STATUS_UNCHANGED
                                     AND ldet.created_from_list_line_type = G_PRICE_BREAK_TYPE)
    AND rltd.relationship_type_code = G_PBH_LINE
    AND rltd.pricing_status_code = G_STATUS_NEW;

    IF l_debug = FND_API.G_TRUE
      THEN
      QP_PREQ_GRP.engine_debug('-------------------------------------');
      FOR cl IN l_dbg_rltd_upd_cur
        LOOP
        QP_PREQ_GRP.engine_debug('rltd info: value_from '
                                 || cl.setup_value_from
                                 ||' value to '|| cl.setup_value_to
                                 ||' price brktype '|| cl.relationship_type_detail
                                 ||' list_line_id '|| cl.list_line_id
                                 ||' rltd_list_line_id '|| cl.related_list_line_id
                                 ||' rltd_list_line_type '|| cl.related_list_line_type
                                 ||' operand_calculation_code '|| cl.operand_calculation_code
                                 ||' operand '|| cl.operand
                                 ||' bucket '|| cl.pricing_group_sequence
                                 ||' qualifier_value '|| cl.qualifier_value);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in QP_PREQ_PUB.Update_Related_Line_Info '|| SQLERRM;
  END Update_Related_Line_Info;


  --This is to cleanup duplicate adjustments between user passed
  --and engine returned adjustments and to consider out of phase adj
  PROCEDURE PROCESS_ADJUSTMENTS(P_PRICING_EVENT VARCHAR2
                                , X_RETURN_STATUS OUT NOCOPY VARCHAR2
                                , X_RETURN_STATUS_TEXT OUT NOCOPY VARCHAR2) IS

  /*
INDX,QP_PREQ_PUB.process_adjustments.l_duplicate_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_PREQ_PUB.process_adjustments.l_duplicate_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
  CURSOR l_duplicate_cur IS
    SELECT /*+ index (ldeta qp_preq_ldets_tmp_n5) */ -- 9362867
	    ldeta.line_detail_index
            , ldeta.line_index
            , ldeta.created_from_list_line_id
            , ldeta.pricing_status_code
            , ldeta.process_code
            , ldeta.pricing_status_text
            , ldeta.applied_flag
            , ldeta.updated_flag
    FROM qp_npreq_ldets_tmp ldeta
    WHERE --ldeta.pricing_status_code = 'X'
            ldeta.process_code = G_STATUS_NEW
            AND ldeta.created_from_list_line_id IN
                    (SELECT /*+ index (ldetb qp_preq_ldets_tmp_n5) */ -- 9362867
			ldetb.created_from_list_line_id
                     FROM qp_npreq_ldets_tmp ldetb
                     WHERE ldetb.created_from_list_line_id =
                     ldeta.created_from_list_line_id
                     AND ldetb.line_index = ldeta.line_index
                     AND ldetb.process_code = G_STATUS_NEW
                     GROUP BY ldetb.created_from_list_line_id
                     HAVING COUNT( * ) > 1)
    ORDER BY ldeta.line_index
            , ldeta.created_from_list_line_id
            , ldeta.pricing_status_code DESC;
  --		and ldetb.pricing_status_code = 'N'desc);

  l_duplicate_rec l_duplicate_cur%ROWTYPE;
  l_duplicate_rec1 l_duplicate_cur%ROWTYPE;

  TYPE DUP_ADJ_TBL_TYPE IS TABLE OF l_duplicate_rec%TYPE INDEX BY BINARY_INTEGER;

  l_dup_adj_tbl DUP_ADJ_TBL_TYPE;
  l_routine VARCHAR2(100) := 'Routine:QP_PREQ_PUB.PROCESS_ADJUSTMENTS';

  /*
indxno index used
*/
  CURSOR lcur IS
    SELECT    line_index
            , created_from_list_line_id
            , pricing_status_code, applied_flag
            , updated_flag, operand_value
    FROM qp_npreq_ldets_tmp
    WHERE PRICING_STATUS_CODE = G_STATUS_UNCHANGED;

  lrec lcur%ROWTYPE;

  /*
INDX,QP_PREQ_PUB.process_adjustments.lcur1,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_PREQ_PUB.process_adjustments.lcur1,qp_npreq_ldets_tmp_N3,PRICING_STATUS_CODE,4
*/
  CURSOR lcur1 IS
    SELECT    created_from_list_line_id
            , line_detail_index
            , line_quantity
            , line_index
            , applied_flag
            , updated_flag
            , pricing_status_code
            , process_code
    FROM qp_npreq_ldets_tmp
    ORDER BY line_index;

  lrec1 lcur1%ROWTYPE;

  i PLS_INTEGER;

  Process_Exc EXCEPTION;

  BEGIN



    /*
open lcur;LOOP
fetch lcur into lrec;
EXIT when lcur%NOTFOUND;
 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.ENGINE_DEBUG(lrec.line_index||
	' user passed list_line_id '||lrec.created_from_list_line_id||
	' pricing_status_code '||lrec.pricing_status_code||
	' applied_flag '||lrec.applied_flag||
	' updated_flag '||lrec.updated_flag||
	' operand '||lrec.operand_value);
 END IF;
END LOOP;
 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.ENGINE_DEBUG('--------------------------------------------------');
 END IF;
CLOSE lcur;
*/

    ----------------------------------------------------------------------------
    --The following code will process the information returned by the
    --pricing engine in the temporary tables, compare the adjustments passes
    --by the calling application and mark the temporary table qp_npreq_ldets_tmp
    --field process_code with a value G_STATUS_NEW
    ----------------------------------------------------------------------------
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('START PROCESS ADJUSTMENTS '|| p_pricing_event);

    END IF;
    --Step 0: Update all user passed adjustments to process_code 'DELETED'
    --to start with

    UPDATE qp_npreq_ldets_tmp ldet SET ldet.process_code = G_STATUS_DELETED
            WHERE ldet.pricing_status_code = G_STATUS_UNCHANGED;

    --First Step: Retain the adjustments input by user
    --which are in the phase which do not belong to the
    --event passed in the control record


    /*
INDX,QP_PREQ_PUB.process_adjustments.upd1,QP_EVENT_PHASES_U1,PRICING_EVENT_CODE,1
*/
    UPDATE qp_npreq_ldets_tmp ldet SET ldet.process_code = G_STATUS_NEW
            WHERE ldet.pricing_status_code = G_STATUS_UNCHANGED AND
            ldet.applied_flag = G_YES AND
            ldet.pricing_phase_id NOT IN (SELECT ev.pricing_phase_id
                                          FROM qp_event_phases ev, qp_pricing_phases ph
                                          , qp_npreq_lines_tmp line
                                          WHERE instr(p_pricing_event, ev.pricing_event_code || ',') > 0
                                          AND ev.pricing_phase_id = ph.pricing_phase_id
                                          AND line.price_flag <> G_CALCULATE_ONLY
                                          AND ((G_GET_FREIGHT_FLAG = G_YES AND ph.freight_exists = G_YES)
                                               OR (G_GET_FREIGHT_FLAG = G_NO))
                                          AND line.line_index = ldet.line_index
                                          AND ((nvl(Get_buy_line_price_flag(ldet.created_from_list_line_id, ldet.line_index), line.price_flag) = G_YES)
                                               OR ((nvl(Get_buy_line_price_flag(ldet.created_from_list_line_id, ldet.line_index), line.price_flag) = G_PHASE)
                                                   AND (nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = G_YES))));

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('PROCESS ADJUSTMENTS: Step1');

    END IF;
    --Second Step: Retain adjustments input by user
    --which have updated flag = 'Y'

    /*
upd2 indxno index used
*/
    --bug 2264566 update the child lines of manual PBH which get
    --passed with applied_flag null and updated_flag = 'Y'
    UPDATE qp_npreq_ldets_tmp ldet SET ldet.process_code = G_STATUS_NEW
            WHERE ldet.pricing_status_code = G_STATUS_UNCHANGED AND
--fix for bug 2515762 automatic overrideable break
            ldet.updated_flag = G_YES;
    --		((ldet.updated_flag = G_YES and ldet.applied_flag = G_YES)
    --		or (ldet.updated_flag = G_YES
    --		and nvl(ldet.automatic_flag, G_NO) = G_NO
    --		and ldet.line_detail_index in
    --			(select rltd.related_line_detail_index
    --			from qp_npreq_rltd_lines_tmp rltd
    --			where rltd.relationship_type_code = G_PBH_LINE)));

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('PROCESS ADJUSTMENTS: Step1.5');
    END IF;
    --summary line adjustments with price flag 'N' need to be considered for calc
    --reqt from contracts for performance
    UPDATE qp_npreq_ldets_tmp ldet SET ldet.process_code = G_STATUS_NEW
            WHERE ldet.line_index IN
            (SELECT line.line_index FROM qp_npreq_lines_tmp line
             WHERE line.line_type_code = G_ORDER_LEVEL
             AND line.price_flag = G_NO);

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('PROCESS ADJUSTMENTS: Step2');


    END IF;
    --Third Step : Mark the lines returned by the engine
    --changed this update because GRP will default process_code N for all ldets

    /*
upd3 indxno index used
*/
    UPDATE qp_npreq_ldets_tmp ldet SET ldet.process_code = G_STATUS_DELETED
            WHERE ldet.process_code = G_STATUS_NEW
            AND ldet.pricing_status_code NOT IN
            (G_STATUS_NEW, G_STATUS_UNCHANGED); -- and ldet.applied_flag = 'Y';

    /*
open lcur1; LOOP
fetch lcur1 into lrec1;
EXIT when lcur1%NOTFOUND;
 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.ENGINE_DEBUG('list_line_id'||lrec1.created_from_list_line_id);
 END IF;
END LOOP;
CLOSE lcur1;
*/

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('PROCESS ADJUSTMENTS: Step3');

    END IF;
    --Fourth Step : Among the lines with process_code = G_STATUS_NEW
    -- remove the duplicates. Retain lines passed by user with updated_flag 'Y' or
    --applied_flag 'Y' otherwise retain lines passed back by engine



    l_dup_adj_tbl.DELETE;
    i := 0;

    OPEN l_duplicate_cur; LOOP
      FETCH l_duplicate_cur INTO l_duplicate_rec;
      FETCH l_duplicate_cur INTO l_duplicate_rec1;

      EXIT WHEN l_duplicate_cur%NOTFOUND;
      i := i + 1;



      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('DUPLICATE REC:
                                 line index '|| l_duplicate_rec.line_index ||
                                 ' detail_index '|| l_duplicate_rec.line_detail_index ||
                                 'list_line_id '|| l_duplicate_rec.created_from_list_line_id ||
                                 'pricing_status_code '|| l_duplicate_rec.pricing_status_code ||
                                 ' process_code '|| l_duplicate_rec.process_code ||
                                 ' applied_flag '|| l_duplicate_rec.applied_flag ||
                                 ' updated_flag '|| l_duplicate_rec.updated_flag);
        QP_PREQ_GRP.ENGINE_DEBUG('DUPLICATE REC1:
                                 line index '|| l_duplicate_rec1.line_index ||
                                 ' detail_index '|| l_duplicate_rec1.line_detail_index ||
                                 'list_line_id '|| l_duplicate_rec1.created_from_list_line_id ||
                                 'pricing_status_code '|| l_duplicate_rec1.pricing_status_code ||
                                 ' process_code '|| l_duplicate_rec1.process_code ||
                                 ' applied_flag '|| l_duplicate_rec1.applied_flag ||
                                 ' updated_flag '|| l_duplicate_rec1.updated_flag);

      END IF;
      IF l_duplicate_rec1.pricing_status_code = G_STATUS_NEW THEN
        IF (l_duplicate_rec.pricing_status_code = G_STATUS_UNCHANGED AND
            ((nvl(l_duplicate_rec.updated_flag, G_NO) = G_YES)
             OR (nvl(l_duplicate_rec.applied_flag, G_NO) = G_YES))) THEN
          --retain adj passed by user
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('retain user passed');
          END IF;
          l_duplicate_rec.process_code := G_STATUS_NEW;
          l_duplicate_rec1.process_code := G_STATUS_UNCHANGED;
          l_duplicate_rec1.pricing_status_code := G_STATUS_DELETED;
          l_duplicate_rec1.pricing_status_text := 'QP_PREQ_PUB:DUPLICATE RECORD';

        ELSIF (l_duplicate_rec.pricing_status_code = G_STATUS_UNCHANGED AND
               ((nvl(l_duplicate_rec.updated_flag, G_NO) = G_NO) OR
                (nvl(l_duplicate_rec.updated_flag, G_NO) = G_NO))) THEN
          --retain adj passed by user
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('retain engine passed');
          END IF;
          l_duplicate_rec.process_code := G_STATUS_UNCHANGED;
          l_duplicate_rec.pricing_status_code := G_STATUS_DELETED;
          l_duplicate_rec1.pricing_status_text := 'QP_PREQ_PUB:DUPLICATE RECORD';
          l_duplicate_rec1.process_code := G_STATUS_NEW;
        ELSE
          --retain adj passed by engine
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('else retain engine');

          END IF;
          l_duplicate_rec.process_code := G_STATUS_UNCHANGED;
          l_duplicate_rec.pricing_status_code := G_STATUS_DELETED;
          l_duplicate_rec.pricing_status_text := 'QP_PREQ_PUB:DUPLICATE RECORD';
          l_duplicate_rec1.process_code := G_STATUS_NEW;
        END IF;
      ELSE
        NULL;
      END IF;

      l_dup_adj_tbl(i) := l_duplicate_rec;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Processed duplicate adj:
                                 line index '|| l_dup_adj_tbl(i).line_detail_index ||
                                 'list_line_id '|| l_dup_adj_tbl(i).created_from_list_line_id ||
                                 'process_code '|| l_dup_adj_tbl(i).process_code ||
                                 ' applied_flag '|| l_dup_adj_tbl(i).applied_flag ||
                                 ' updated_flag '|| l_dup_adj_tbl(i).updated_flag);
      END IF;
      i := i + 1;
      l_dup_adj_tbl(i) := l_duplicate_rec1;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Processed duplicate adj:
                                 line index '|| l_dup_adj_tbl(i).line_detail_index ||
                                 'list_line_id '|| l_dup_adj_tbl(i).created_from_list_line_id ||
                                 'process_code '|| l_dup_adj_tbl(i).process_code ||
                                 ' applied_flag '|| l_dup_adj_tbl(i).applied_flag ||
                                 ' updated_flag '|| l_dup_adj_tbl(i).updated_flag);
      END IF;
    END LOOP;


    i := l_dup_adj_tbl.FIRST;
    WHILE i IS NOT NULL LOOP

      /*
INDX,QP_PREQ_PUB.process_adjustments.upd4,qp_npreq_ldets_tmp_U1,LINE_DETAIL_INDEX,1
*/
      UPDATE qp_npreq_ldets_tmp SET
              process_code = l_dup_adj_tbl(i).process_code
              , pricing_status_code = l_dup_adj_tbl(i).pricing_status_code
              , pricing_status_text = l_dup_adj_tbl(i).pricing_status_text
              WHERE line_detail_index = l_dup_adj_tbl(i).line_detail_index;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Update processed adjustments:
                                 list_line_id '|| l_dup_adj_tbl(i).created_from_list_line_id ||
                                 ' pricing_status_code '|| l_dup_adj_tbl(i).pricing_status_code ||
                                 'process_code '|| l_dup_adj_tbl(i).process_code);

      END IF;
      i := l_dup_adj_tbl.NEXT(i);
    END LOOP;

    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN

      OPEN lcur1; LOOP
        FETCH lcur1 INTO lrec1;
        EXIT WHEN lcur1%NOTFOUND;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('line_index '|| lrec1.line_index ||
                                   ' line_dtl_index '|| lrec1.line_detail_index ||
                                   ' line_qty '|| lrec1.line_quantity ||
                                   ' list_line_id '|| lrec1.created_from_list_line_id ||
                                   ' applied '|| lrec1.applied_flag ||' status '|| lrec1.pricing_status_code ||
                                   ' updated '|| lrec1.updated_flag ||' process '|| lrec1.process_code);
        END IF;
      END LOOP;
      CLOSE lcur1;
    END IF;
    Cleanup_rltd_lines(x_return_status, x_return_status_text);
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('------------------------------------------');

    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
      RAISE Process_Exc;
    END IF;

    Update_Related_Line_Info(x_return_status, x_return_status_text);
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('------------------------------------------');
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
      RAISE Process_Exc;
    END IF;

    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN

      OPEN lcur1; LOOP
        FETCH lcur1 INTO lrec1;
        EXIT WHEN lcur1%NOTFOUND;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('line_index '|| lrec1.line_index ||
                                   ' list_line_id '|| lrec1.created_from_list_line_id ||
                                   ' applied '|| lrec1.applied_flag ||' status '|| lrec1.pricing_status_code ||
                                   ' updated '|| lrec1.updated_flag ||' process '|| lrec1.process_code);
        END IF;
      END LOOP;
      CLOSE lcur1;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('PROCESS ADJUSTMENTS: Step4');

    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_RETURN_STATUS_TEXT := l_routine ||' SUCCESS ';

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('END PROCESS ADJUSTMENTS');
    END IF;
  EXCEPTION
    WHEN Process_Exc THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('EXCEPTION PROCESS ADJUSTMENTS: '|| X_RETURN_STATUS_TEXT);
      END IF;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('EXCEPTION PROCESS ADJUSTMENTS: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END PROCESS_ADJUSTMENTS;


  --This is to populate the qualifier_value in the rltd_lines_tmp
  --for PBH adjustments inserted by calling application during
  --BILLING call for usage pricing. The pricing engine would have
  --returned PBH adjustments and rltd_lines_tmp records for them
  --during the AUTHORING call
  --but qualifier_value would not have been populated as there
  --is no quantity during the AUTHORING call
  PROCEDURE UPDATE_QUALIFIER_VALUE(x_return_status OUT NOCOPY VARCHAR2,
                                   x_return_status_text OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin UPDATE_QUALIFIER_VALUE routine');

    END IF;
    UPDATE qp_npreq_rltd_lines_tmp rltd
            SET rltd.qualifier_value = (SELECT
                                        decode(qpa.pricing_attribute,
                                               G_LINE_AMT_ATTRIBUTE,
                                               (nvl(line.priced_quantity, line.line_quantity)
                                                * nvl(line.unit_price, 0)),
                                               nvl(line.priced_quantity, line.line_quantity))
                                        FROM qp_npreq_lines_tmp line,
                                        qp_pricing_attributes qpa
                                        WHERE line.line_index = rltd.line_index
                                        AND qpa.list_line_id = rltd.related_list_line_id
                                        AND qpa.pricing_attribute_context =
                                        G_PRIC_VOLUME_CONTEXT)
    WHERE rltd.line_index IN (SELECT line.line_index
                              FROM qp_npreq_lines_tmp line
                              WHERE line.line_index = rltd.line_index
                              AND rltd.relationship_type_code = G_PBH_LINE
                              AND line.pricing_status_code IN
                              (G_STATUS_UNCHANGED, G_STATUS_UPDATED,
                               G_STATUS_GSA_VIOLATION)
                              AND line.usage_pricing_type =
                              QP_PREQ_GRP.G_BILLING_TYPE);
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End UPDATE_QUALIFIER_VALUE routine');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error UPDATE_QUALIFIER_VALUE routine '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.UPDATE_QUALIFIER_VALUE: '|| SQLERRM;
  END UPDATE_QUALIFIER_VALUE;

  --This is to update the status on the child break lines after calculation
  PROCEDURE Update_Child_Break_Lines(x_return_status OUT NOCOPY VARCHAR2,
                                     x_return_status_text OUT NOCOPY VARCHAR2) IS

  --[julin/pbperf] tuned to use QP_PREQ_LDETS_TMP_U1
  CURSOR l_child_break_cur IS
    SELECT /*+ ORDERED index(ldet QP_PREQ_LDETS_TMP_U1) */ldet.process_code,
            rltd.related_line_detail_index
    FROM qp_npreq_rltd_lines_tmp rltd,
--		qp_npreq_ldets_tmp ldet1,
         qp_npreq_ldets_tmp ldet
    WHERE rltd.relationship_type_code = G_PBH_LINE
    AND rltd.pricing_status_code = G_STATUS_NEW
    AND ldet.line_index = rltd.line_index
    AND ldet.line_detail_index = rltd.line_detail_index
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.process_code = G_STATUS_NEW;
  --	and ldet1.line_index = rltd.related_line_index
  --	and ldet1.line_detail_index = rltd.related_line_detail_index;

  l_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_child_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  nRows CONSTANT NUMBER := 500;
  I PLS_INTEGER;
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    --This is to update the status on the child break lines after calculation
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Update_Child_break_lines routine');
    END IF;
    OPEN l_child_break_cur;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('open l_child_break_cur');
    END IF;
    --	LOOP
    l_child_sts_code_tbl.DELETE;
    l_line_dtl_index_tbl.DELETE;
    FETCH l_child_break_cur
    BULK COLLECT INTO l_child_sts_code_tbl, l_line_dtl_index_tbl;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('fetch l_child_break_cur');
    END IF;
    --	LIMIT nRows;
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      THEN
      I := l_line_dtl_index_tbl.FIRST;
      WHILE I IS NOT NULL
        --			FOR I in l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l_child_break_cur count '|| i
                                   ||' childdtl index '|| l_line_dtl_index_tbl(i)
                                   ||' status code '|| l_child_sts_code_tbl(i));
        END IF;
        I := l_line_dtl_index_tbl.NEXT(I);
      END LOOP;
    END IF;

    IF l_line_dtl_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('before update');
      END IF;
      FORALL j IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
              SET process_code = l_child_sts_code_tbl(j)
              WHERE line_detail_index = l_line_dtl_index_tbl(j);
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('after update');
      END IF;
    END IF;
    --	EXIT WHEN l_line_dtl_index_tbl.COUNT =0;
    --	END LOOP;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('END LOOP');
    END IF;
    CLOSE l_child_break_cur;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('fetch l_child_break_cur');
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Update_Child_break_lines routine');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error Update_Child_break_lines routine '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Update_Child_Break_lines: '|| SQLERRM;

  END Update_Child_Break_Lines;


  --This is to calculate the line quantity on each child break line
  PROCEDURE PROCESS_PRICE_BREAK(p_rounding_flag IN VARCHAR2,
                                p_processing_order IN NUMBER,
                                x_line_index_tbl OUT NOCOPY QP_PREQ_GRP.NUMBER_TYPE,
                                x_list_price_tbl OUT NOCOPY QP_PREQ_GRP.NUMBER_TYPE,
                                x_pricing_sts_code_tbl OUT NOCOPY QP_PREQ_GRP.VARCHAR_TYPE,
                                x_pricing_sts_txt_tbl OUT NOCOPY QP_PREQ_GRP.VARCHAR_TYPE,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

  CURSOR l_request_line_detail_cur(p_processing_order NUMBER) IS
    SELECT rltd.line_detail_index parent_detail_index,
            rltd.line_index parent_line_index,
            ldet.line_detail_index child_detail_index,
            ldet.line_index child_line_index,
            ldet.line_detail_type_code,
            ldet.created_from_list_line_type,
            qpa.pricing_attr_value_from value_from,
            qpa.pricing_attr_value_to value_to,
            line.priced_quantity ordered_quantity,
            attr.value_from break_quantity,
            line.uom_quantity service_duration,
            line.rounding_factor,
--		ldet.line_quantity line_qty,
            ldet.created_from_list_line_id,
            ldet.price_break_type_code price_break_type,
            ldet.modifier_level_code,
            ldet.group_quantity,
            ldet.operand_calculation_code,
            ldet.operand_value,
            ldet.group_amount,
            line.parent_price
    FROM qp_npreq_lines_tmp line,
            qp_npreq_rltd_lines_tmp rltd,
            qp_npreq_ldets_tmp ldet,
            qp_pricing_attributes qpa,
            qp_npreq_line_attrs_tmp attr
    WHERE line.pricing_status_code IN (G_STATUS_UNCHANGED, G_STATUS_UPDATED)
    AND line.price_flag = G_CALCULATE_ONLY
    AND nvl(line.processing_order, 1) = p_processing_order
    AND line.usage_pricing_type = QP_PREQ_GRP.G_BILLING_TYPE
    AND line.line_index = rltd.line_index
    AND rltd.relationship_type_code = G_PBH_LINE
    AND ldet.line_index = line.line_index
    AND ldet.pricing_status_code = 'X'
    AND ldet.line_detail_index = rltd.related_line_detail_index
    AND qpa.list_line_id = ldet.created_from_list_line_id
    AND qpa.pricing_attribute_context = G_PRIC_VOLUME_CONTEXT
    AND attr.line_index = line.line_index
    AND attr.line_detail_index IS NULL
    AND attr.context = G_PRIC_VOLUME_CONTEXT
    AND attr.attribute = qpa.pricing_attribute
    ORDER BY child_detail_index, parent_detail_index;

  l_quantity NUMBER;
  l_satisfied_qty NUMBER;
  l_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_total_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
  --l_pricing_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  --l_pricing_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_total_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_percent_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_line_quantity_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;

  i NUMBER := 0;
  l_break_satisfied VARCHAR2(1) := G_NO;

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin process_price_break');

    END IF;
    FOR I IN l_request_line_detail_cur(p_processing_order)
      LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Loop thru child break '|| I.parent_detail_index
                                 ||' child index '|| I.child_detail_index ||' list_line_id '
                                 || I.created_from_list_line_id ||' level '|| I.modifier_level_code
                                 ||' parent price '|| I.parent_price
                                 ||' val from '|| I.value_from ||' to '|| I.value_to
                                 ||' grpqty '|| I.group_quantity ||' grpamt '|| I.group_amount
                                 ||' ordqty '|| I.ordered_quantity ||' brktype '|| I.price_break_type
                                 ||' brk qty '|| I.break_quantity);
      END IF;
      --this is not applicable for price lists
      IF I.modifier_level_code = G_LINE_GROUP
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this is line group');
        END IF;
        l_quantity := nvl(nvl(nvl(I.group_quantity
                                  , I.group_amount),
                              nvl(I.break_quantity, I.ordered_quantity)), 0);
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this is not line group');
        END IF;
        l_quantity := nvl(nvl(I.break_quantity,
                              I.ordered_quantity), 0);
      END IF;

      IF x_line_index_tbl.COUNT = 0
        THEN
        l_break_satisfied := G_NO;
      ELSIF x_line_index_tbl.COUNT > 0
        AND x_line_index_tbl(x_line_index_tbl.COUNT) <> I.child_line_index
        THEN
        l_break_satisfied := G_NO;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('process_price_break1');
      END IF;
      IF I.price_break_type = G_POINT_BREAK
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this is point break');
        END IF;
        IF l_quantity BETWEEN I.value_from AND I.value_to
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('point break satisfied');
          END IF;
          l_line_quantity_tbl(l_line_quantity_tbl.COUNT + 1)
          := l_quantity;
          l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
          I.child_line_index;
          l_applied_flag_tbl(l_applied_flag_tbl.COUNT + 1) := G_YES;
          l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1)
          := I.child_detail_index;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('point break not satisfied');
          END IF;
          l_line_quantity_tbl(l_line_quantity_tbl.COUNT + 1) := 0;
          l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
          I.child_line_index;
          l_applied_flag_tbl(l_applied_flag_tbl.COUNT + 1) := G_NO;
          l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1)
          := I.child_detail_index;
        END IF;

      ELSIF I.price_break_type = G_RANGE_BREAK
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('this is range break');
        END IF;
        l_satisfied_qty := 0;
        QP_Calculate_Price_PUB.Get_Satisfied_Range
        (p_value_from => I.value_from
         , p_value_to => I.value_to
         , p_qualifier_value => l_quantity
         , x_satisfied_value => l_satisfied_qty);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('range break '|| l_satisfied_qty);

        END IF;
        IF l_satisfied_qty <> 0
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('range break satisfied');
          END IF;
          l_line_quantity_tbl(l_line_quantity_tbl.COUNT + 1)
          := l_satisfied_qty;
          l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
          I.child_line_index;
          l_applied_flag_tbl(l_applied_flag_tbl.COUNT + 1) := G_YES;
          l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1)
          := I.child_detail_index;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('range break not satisfied');
          END IF;
          l_line_quantity_tbl(l_line_quantity_tbl.COUNT + 1) := 0;
          l_applied_flag_tbl(l_applied_flag_tbl.COUNT + 1) := G_NO;
          l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
          I.child_line_index;
          l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1)
          := I.child_detail_index;
        END IF;
      END IF;

      IF l_line_quantity_tbl.COUNT > 0
        AND l_line_quantity_tbl(l_line_quantity_tbl.COUNT) > 0
        THEN
        l_break_satisfied := G_YES;
        QP_Calculate_Price_PUB.Calculate_List_Price
        (I.OPERAND_CALCULATION_CODE,
         I.OPERAND_VALUE,
         l_line_quantity_tbl(l_line_quantity_tbl.COUNT),
         I.parent_price,
         nvl(I.service_duration, 1),
         p_rounding_flag,
         I.rounding_factor,
         l_adj_amt_tbl(l_line_quantity_tbl.COUNT),
         l_percent_price_tbl(l_line_quantity_tbl.COUNT),
         x_return_status,
         x_return_status_text);

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('plsql tbl info dtlindex '
                                   || l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' appl flag '|| l_applied_flag_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' line qty '|| l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' list price '|| l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' percent price '|| l_percent_price_tbl(l_line_dtl_index_tbl.COUNT));
        END IF;
      ELSE
        l_adj_amt_tbl(l_line_quantity_tbl.COUNT) := NULL;
      END IF;

      IF x_line_index_tbl.COUNT = 0
        THEN
        x_line_index_tbl(x_line_index_tbl.COUNT + 1) :=
        l_line_index_tbl(l_line_index_tbl.COUNT);
        l_total_qty_tbl(x_line_index_tbl.COUNT) :=
        I.ordered_quantity;
        l_total_price_tbl(x_line_index_tbl.COUNT) :=
        l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
        * nvl(l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT), 0);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('first line '
                                   || l_total_qty_tbl(x_line_index_tbl.COUNT) ||' '
                                   || l_total_price_tbl(x_line_index_tbl.COUNT)
                                   ||' qty '|| l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' adjamt '|| l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' brk satisfied '|| l_break_satisfied);
        END IF;
      ELSIF x_line_index_tbl.COUNT > 0
        AND x_line_index_tbl(x_line_index_tbl.COUNT) =
        l_line_index_tbl(l_line_index_tbl.COUNT)
        THEN
        l_total_price_tbl(x_line_index_tbl.COUNT) :=
        l_total_price_tbl(x_line_index_tbl.COUNT) +
        l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
        * nvl(l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT), 0);
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('same line '
                                   || l_total_qty_tbl(x_line_index_tbl.COUNT) ||' '
                                   || l_total_price_tbl(x_line_index_tbl.COUNT)
                                   ||' qty '|| l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' adjamt '|| l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' brk satisfied '|| l_break_satisfied);
        END IF;
      ELSIF x_line_index_tbl.COUNT > 0
        AND x_line_index_tbl(x_line_index_tbl.COUNT) <>
        l_line_index_tbl(l_line_index_tbl.COUNT)
        THEN
        --Calculation for pervious line
        x_list_price_tbl(x_line_index_tbl.COUNT) :=
        l_total_price_tbl(x_line_index_tbl.COUNT) /
        l_total_qty_tbl(x_line_index_tbl.COUNT);
        IF l_break_satisfied = G_NO
          THEN
          x_pricing_sts_code_tbl(x_line_index_tbl.COUNT) :=
          G_STATUS_CALC_ERROR;
          x_pricing_sts_txt_tbl(x_line_index_tbl.COUNT) :=
          'UNABLE TO PRICE LINE';
        ELSE
          x_pricing_sts_code_tbl(x_line_index_tbl.COUNT) :=
          G_STATUS_UPDATED;
          x_pricing_sts_txt_tbl(x_line_index_tbl.COUNT) :=
          '';
        END IF;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('next line ');
        END IF;
        x_line_index_tbl(x_line_index_tbl.COUNT + 1) :=
        l_line_index_tbl(l_line_index_tbl.COUNT);
        l_total_qty_tbl(x_line_index_tbl.COUNT) :=
        I.ordered_quantity;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('price info: line index '
                                   || x_line_index_tbl(x_line_index_tbl.COUNT)
                                   ||' price '|| x_list_price_tbl(x_line_index_tbl.COUNT)
                                   ||' qty '|| l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' adjamt '|| l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' brk satisfied '|| l_break_satisfied);
        END IF;
      END IF;
    END LOOP;

    IF x_line_index_tbl.COUNT > 0
      --for the last line
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('price info: line index ');
      END IF;
      IF l_break_satisfied = G_NO
        THEN
        x_pricing_sts_code_tbl(x_line_index_tbl.COUNT) :=
        G_STATUS_CALC_ERROR;
        x_pricing_sts_txt_tbl(x_line_index_tbl.COUNT) :=
        'UNABLE TO PRICE LINE';
      ELSE
        x_pricing_sts_code_tbl(x_line_index_tbl.COUNT) :=
        G_STATUS_UPDATED;
        x_pricing_sts_txt_tbl(x_line_index_tbl.COUNT) :=
        '';
      END IF;
      x_list_price_tbl(x_line_index_tbl.COUNT) :=
      l_total_price_tbl(x_line_index_tbl.COUNT) /
      l_total_qty_tbl(x_line_index_tbl.COUNT);
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('price info: line index '
                                 || x_line_index_tbl(x_line_index_tbl.COUNT)
                                 ||' price '|| x_list_price_tbl(x_line_index_tbl.COUNT) ||' '
                                 || l_total_qty_tbl(x_line_index_tbl.COUNT) ||' '
                                 || l_total_price_tbl(x_line_index_tbl.COUNT)
                                 ||' qty '|| l_line_quantity_tbl(l_line_dtl_index_tbl.COUNT)
                                 ||' adjamt '|| l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                 ||' brk satisfied '|| l_break_satisfied);
      END IF;
    END IF;

    IF l_line_quantity_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('process_price_break5: count '
                                 || l_line_quantity_tbl.COUNT ||' first '
                                 || l_line_quantity_tbl.FIRST ||' last '
                                 || l_line_quantity_tbl.LAST);
      END IF;
      FORALL i IN l_line_quantity_tbl.FIRST..l_line_quantity_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
      SET line_quantity = l_line_quantity_tbl(i)
      , applied_flag = l_applied_flag_tbl(i)
      , adjustment_amount = l_adj_amt_tbl(i)
      WHERE line_detail_index = l_line_dtl_index_tbl(i);
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('process_price_break5');

    END IF;
    IF x_line_index_tbl.COUNT > 0
      THEN
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        FOR i IN x_line_index_tbl.FIRST..x_line_index_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('line details '|| x_line_index_tbl(i)
                                     ||' price '|| x_list_price_tbl(i) ||' sts '
                                     || x_pricing_sts_code_tbl(i));
          END IF;
        END LOOP;
      END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('update PBH ');
      END IF;
      FORALL i IN x_line_index_tbl.FIRST..x_line_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
      SET line_quantity = l_total_qty_tbl(i)
      , applied_flag = G_YES
      , adjustment_amount = x_list_price_tbl(i)
      WHERE line_index = x_line_index_tbl(i)
      AND created_from_list_line_type = G_BY_PBH
      AND created_from_list_type_code IN
              (G_PRICE_LIST_HEADER, G_AGR_LIST_HEADER)
      AND x_pricing_sts_code_tbl(i) = G_STATUS_UPDATED;
    END IF; --x_line_index_tbl.COUNT

    UPDATE qp_npreq_ldets_tmp
    SET applied_flag = G_NO
    WHERE created_from_list_line_type = G_PRICE_BREAK_TYPE
    AND created_from_list_type_code IN
            (G_PRICE_LIST_HEADER, G_AGR_LIST_HEADER)
    AND adjustment_amount IS NULL;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End process_price_break');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Process_Price_Break Exception: '
      || SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception process_price_break '|| SQLERRM);
      END IF;
  END PROCESS_PRICE_BREAK;

  PROCEDURE Update_Service_Lines(x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_status_text OUT NOCOPY VARCHAR2) IS
  /*
INDX,QP_PREQ_PUB.Usage_pricing.l_Service_Cur,-No Index Used-,NA,NA
*/
  CURSOR l_Service_Cur IS
    SELECT rltd.line_index,
           rltd.related_line_index,
           line.unit_price,
           line.priced_quantity,
           line.priced_uom_code
    FROM qp_npreq_rltd_lines_tmp rltd, qp_npreq_lines_tmp line
    WHERE rltd.line_index IS NOT NULL
    AND   rltd.related_line_index IS NOT NULL
    AND   rltd.relationship_type_code = G_SERVICE_LINE
    AND   line.line_index = rltd.line_index;

  l_parent_line_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_service_line_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_priced_quantity_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_priced_uom_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Update_Service_Lines');

    END IF;
    OPEN l_Service_Cur;
    FETCH l_Service_Cur
    BULK COLLECT INTO
    l_parent_line_tbl,
    l_service_line_tbl,
    l_unit_price_tbl,
    l_priced_quantity_tbl,
    l_priced_uom_code_tbl;
    CLOSE l_Service_Cur;

    IF l_service_line_tbl.COUNT > 0
      THEN
      FORALL i IN l_service_line_tbl.FIRST..l_service_line_tbl.LAST
      UPDATE qp_npreq_lines_tmp
              SET parent_price = l_unit_price_tbl(i),
              parent_uom_code = l_priced_uom_code_tbl(i),
              processing_order = 2,
              parent_quantity = l_priced_quantity_tbl(i)
              WHERE line_index = l_service_line_tbl(i);
      FORALL i IN l_parent_line_tbl.FIRST..l_parent_line_tbl.LAST
      UPDATE qp_npreq_lines_tmp
              SET processing_order = 1
              WHERE line_index = l_parent_line_tbl(i);
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Update_Service_Lines');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Update_Service_Lines Exception: '
      || SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception Update_Service_Lines '|| SQLERRM);
      END IF;
  END Update_Service_Lines;


  PROCEDURE Usage_pricing(p_rounding_flag IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_return_status_text OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_price_cur(p_processing_order NUMBER) IS
    SELECT    ldet.created_from_list_line_id
            , line.line_index line_ind
            , ldet.line_detail_index
            , ldet.created_from_list_line_type
            , ldet.modifier_level_code
            , ldet.applied_flag
--		, 1.0 amount_changed
--		, line.adjusted_unit_price
--changed to make sure lumpsum on order level frt charge divide by 1 quantity
            , ldet.line_quantity priced_quantity
            , line.priced_quantity priced_qty
            , ldet.group_quantity
            , ldet.group_amount
            , ldet.operand_calculation_code
            , ldet.operand_value
            , ldet.adjustment_amount
            , line.unit_price
            , ldet.process_code
            , ldet.price_break_type_code
            , line.rounding_factor
            , line.uom_quantity service_duration
            , line.processing_order
            , line.parent_price
    FROM qp_npreq_lines_tmp line, qp_npreq_ldets_tmp ldet
    WHERE line.usage_pricing_type = QP_PREQ_GRP.G_BILLING_TYPE
            AND ldet.line_index = line.line_index
            AND line.price_flag = G_CALCULATE_ONLY
            AND nvl(processing_order, 1) = p_processing_order
            AND ldet.applied_flag = G_YES
            AND ldet.created_from_list_type_code IN
                    (G_PRICE_LIST_HEADER, G_AGR_LIST_HEADER)
            AND ldet.created_from_list_line_type = G_PRICE_LIST_TYPE
            AND nvl(ldet.line_detail_type_code, 'NULL') <>
                                            G_CHILD_DETAIL_TYPE
            ORDER BY line_ind;



  l_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_unit_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_percent_price_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_related_item_price NUMBER;
  l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  --l_detail_type_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_sts_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;

  USAGE_EXCEPTION EXCEPTION;
  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Usage Pricing');


    END IF;
    Process_Price_Break(p_rounding_flag => p_rounding_flag,
                        p_processing_order => 1,
                        x_line_index_tbl => l_line_index_tbl,
                        x_list_price_tbl => l_unit_price_tbl,
                        x_pricing_sts_code_tbl => l_pricing_sts_code_tbl,
                        x_pricing_sts_txt_tbl => l_pricing_sts_txt_tbl,
                        x_return_status => x_return_status,
                        x_return_status_text => x_return_status_text);
    IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
      RAISE Usage_Exception;
    END IF;
    FOR cl IN l_get_price_cur(1)
      LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Usage Pricing LOOP');
        QP_PREQ_GRP.engine_debug('PRL line type '
                                 || cl.created_from_list_line_type ||' operator '
                                 || cl.OPERAND_CALCULATION_CODE ||' operand '
                                 || cl.OPERAND_VALUE ||' svc duration '
                                 || nvl(cl.service_duration, 1) ||' rounding fac '
                                 || cl.rounding_factor ||' rounding flag '
                                 || p_rounding_flag);
      END IF;
      IF cl.created_from_list_line_type = G_PRICE_LIST_TYPE
        THEN
        l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1) :=
        cl.line_detail_index;
        l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
        cl.line_ind;

        QP_Calculate_Price_PUB.Calculate_List_Price
        (p_operand_calc_code => cl.OPERAND_CALCULATION_CODE,
         p_operand_value => cl.OPERAND_VALUE,
         p_request_qty => cl.priced_qty,
         p_rltd_item_price => l_related_item_price,
         p_service_duration => nvl(cl.service_duration, 1),
         p_rounding_flag => p_rounding_flag,
         p_rounding_factor => cl.rounding_factor,
         x_list_price => l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT),
         x_percent_price => l_percent_price_tbl(l_percent_price_tbl.COUNT + 1),
         x_return_status => x_return_status,
         x_return_status_txt => x_return_status_text);

        l_unit_price_tbl(l_unit_price_tbl.COUNT + 1) :=
        l_adj_amt_tbl(l_adj_amt_tbl.COUNT);

        IF l_unit_price_tbl(l_unit_price_tbl.COUNT) IS NULL
          THEN
          l_pricing_sts_code_tbl(l_pricing_sts_code_tbl.COUNT + 1)
          := G_STATUS_CALC_ERROR;
          l_pricing_sts_txt_tbl(l_pricing_sts_txt_tbl.COUNT + 1)
          := 'UNABLE TO PRICE LINE';
        ELSE
          l_pricing_sts_code_tbl(l_pricing_sts_code_tbl.COUNT + 1)
          := G_STATUS_UPDATED;
          l_pricing_sts_txt_tbl(l_pricing_sts_txt_tbl.COUNT + 1)
          := '';
        END IF; --l_unit_price_tbl

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('price returned '
                                   || l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' %price '|| l_percent_price_tbl(l_percent_price_tbl.COUNT)
                                   ||' line index '|| l_line_index_tbl(l_line_index_tbl.COUNT)
                                   ||' unit price '|| l_unit_price_tbl(l_unit_price_tbl.COUNT)
                                   ||' status '|| l_pricing_sts_code_tbl(l_line_index_tbl.COUNT)
                                   ||' text '|| l_pricing_sts_txt_tbl(l_line_index_tbl.COUNT));
        END IF;
      END IF;

    END LOOP;

    IF l_line_dtl_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Usage Pricing LOOP1');
      END IF;
      FORALL i IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
              SET adjustment_amount = l_adj_amt_tbl(i)
              WHERE line_detail_index = l_line_dtl_index_tbl(i);
    END IF; --l_line_dtl_index_tbl.COUNT

    IF l_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin LINES Usage Pricing LOOP1');
      END IF;
      FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp
              SET unit_price = l_unit_price_tbl(i),
              pricing_status_code = l_pricing_sts_code_tbl(i),
              pricing_status_text = l_pricing_sts_txt_tbl(i)
              WHERE line_index = l_line_index_tbl(i);
    END IF; --l_line_index_tbl.COUNT

    --now service lines need to be priced
    l_line_index_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_pricing_sts_code_tbl.DELETE;
    l_pricing_sts_txt_tbl.DELETE;
    l_adj_amt_tbl.DELETE;
    l_line_dtl_index_tbl.DELETE;


    Update_Service_Lines(x_return_status, x_return_status_text);

    IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
      RAISE Usage_Exception;
    END IF;


    Process_Price_Break(p_rounding_flag => p_rounding_flag,
                        p_processing_order => 2,
                        x_line_index_tbl => l_line_index_tbl,
                        x_list_price_tbl => l_unit_price_tbl,
                        x_pricing_sts_code_tbl => l_pricing_sts_code_tbl,
                        x_pricing_sts_txt_tbl => l_pricing_sts_txt_tbl,
                        x_return_status => x_return_status,
                        x_return_status_text => x_return_status_text);
    IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
      RAISE Usage_Exception;
    END IF;

    FOR cl IN l_get_price_cur(2)
      LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Usage Pricing LOOP2');
        QP_PREQ_GRP.engine_debug('PRL line type '
                                 || cl.created_from_list_line_type ||' operator '
                                 || cl.OPERAND_CALCULATION_CODE ||' operand '
                                 || cl.OPERAND_VALUE ||' svc duration '
                                 || nvl(cl.service_duration, 1) ||' rounding fac '
                                 || cl.rounding_factor ||' rounding flag '
                                 || p_rounding_flag ||' parent price '|| cl.parent_price);
      END IF;
      IF cl.created_from_list_line_type = G_PRICE_LIST_TYPE
        THEN
        l_line_dtl_index_tbl(l_line_dtl_index_tbl.COUNT + 1) :=
        cl.line_detail_index;
        l_line_index_tbl(l_line_index_tbl.COUNT + 1) :=
        cl.line_ind;

        QP_Calculate_Price_PUB.Calculate_List_Price
        (p_operand_calc_code => cl.OPERAND_CALCULATION_CODE,
         p_operand_value => cl.OPERAND_VALUE,
         p_request_qty => cl.priced_qty,
         p_rltd_item_price => cl.parent_price,
         p_service_duration => nvl(cl.service_duration, 1),
         p_rounding_flag => p_rounding_flag,
         p_rounding_factor => cl.rounding_factor,
         x_list_price => l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT),
         x_percent_price => l_percent_price_tbl(l_percent_price_tbl.COUNT + 1),
         x_return_status => x_return_status,
         x_return_status_txt => x_return_status_text);

        l_unit_price_tbl(l_unit_price_tbl.COUNT + 1) :=
        l_adj_amt_tbl(l_adj_amt_tbl.COUNT);

        IF l_unit_price_tbl(l_unit_price_tbl.COUNT) IS NULL
          THEN
          l_pricing_sts_code_tbl(l_pricing_sts_code_tbl.COUNT + 1)
          := G_STATUS_CALC_ERROR;
          l_pricing_sts_txt_tbl(l_pricing_sts_txt_tbl.COUNT + 1)
          := 'UNABLE TO PRICE LINE';
        ELSE
          l_pricing_sts_code_tbl(l_pricing_sts_code_tbl.COUNT + 1)
          := G_STATUS_UPDATED;
          l_pricing_sts_txt_tbl(l_pricing_sts_txt_tbl.COUNT + 1)
          := '';
        END IF; --l_unit_price_tbl
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('price returned '
                                   || l_adj_amt_tbl(l_line_dtl_index_tbl.COUNT)
                                   ||' %price '|| l_percent_price_tbl(l_percent_price_tbl.COUNT)
                                   ||' unit price '|| l_unit_price_tbl(l_unit_price_tbl.COUNT)
                                   ||' status '|| l_pricing_sts_code_tbl(l_line_index_tbl.COUNT)
                                   ||' text '|| l_pricing_sts_txt_tbl(l_line_index_tbl.COUNT));
        END IF;
      END IF;

    END LOOP;

    IF l_line_dtl_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin Usage Pricing LOOP2');
      END IF;
      FORALL i IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp
              SET adjustment_amount = l_adj_amt_tbl(i)
              WHERE line_detail_index = l_line_dtl_index_tbl(i);
    END IF; --l_line_dtl_index_tbl.COUNT

    IF l_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Begin LINES Usage Pricing LOOP2');
      END IF;
      FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp
              SET unit_price = l_unit_price_tbl(i),
              pricing_status_code = l_pricing_sts_code_tbl(i),
              pricing_status_text = l_pricing_sts_txt_tbl(i)
              WHERE line_index = l_line_index_tbl(i);
    END IF; --l_line_index_tbl.COUNT



    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Usage Pricing');

    END IF;
  EXCEPTION
    WHEN USAGE_EXCEPTION THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception Usage Pricing '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception Usage Pricing '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Usage_Pricing Exception: '
      || SQLERRM;
  END Usage_pricing;

  FUNCTION Call_Usage_Pricing RETURN VARCHAR2 IS

  CURSOR l_chk_usage_cur IS
    SELECT G_YES
    FROM qp_npreq_lines_tmp line
    WHERE line.pricing_status_code IN
    (G_STATUS_UPDATED, G_STATUS_UNCHANGED, G_STATUS_GSA_VIOLATION)
    AND line.usage_pricing_type = QP_PREQ_GRP.G_BILLING_TYPE;

  x_call_usage_pricing VARCHAR2(1) := G_NO;
  BEGIN
    OPEN l_chk_usage_cur;
    FETCH l_chk_usage_cur INTO x_call_usage_pricing;
    CLOSE l_chk_usage_cur;
    RETURN x_call_usage_pricing;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_PUB.Call_Usage_Pricing Exception: '|| SQLERRM);
      END IF;
      x_call_usage_pricing := NULL;
  END Call_Usage_Pricing;

  /***********************************************************************
PRG PROCESSING CODE
***********************************************************************/

  --this procedure identifies the passed in freegood lines
  --and updates the process_status on them with the get line's list_line_id
  PROCEDURE Identify_freegood_lines(p_event_code IN VARCHAR2
                                    , x_return_status OUT NOCOPY VARCHAR2
                                    , x_return_status_text OUT NOCOPY VARCHAR2) IS

  --this cursor identifies the passed in freegood lines
  CURSOR l_Identify_freegood_cur IS
    SELECT /*+ ORDERED USE_NL(ev ph oldprg oldrltd oldfgdis oldfreeline)*/
      oldfreeline.line_index,
      oldfgdis.list_line_id,
      nvl(oldfgdis.operand_per_pqty, oldfgdis.operand) operand_value,
      oldfgdis.arithmetic_operator operand_calculation_code,
      buyline.line_index,
      oldprg.list_line_id,
      oldprg.updated_flag
    FROM qp_npreq_lines_tmp buyline
      , qp_event_phases ev
      , qp_pricing_phases ph
      , oe_price_adjustments oldprg
      , oe_price_adj_assocs oldrltd
      , oe_price_adjustments oldfgdis
      , qp_npreq_lines_tmp oldfreeline
    --where G_REQUEST_TYPE_CODE = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
    --need not do freegoods cleanup if PRG line has price_flag 'P' or 'N'
    AND buyline.price_flag = G_YES --in (G_YES, G_PHASE)
    AND instr(p_event_code, ev.pricing_event_code || ',') > 0
    AND ph.pricing_phase_id = ev.pricing_phase_id
    AND ((G_GET_FREIGHT_FLAG = G_YES AND ph.freight_exists = 'Y')
         OR (G_GET_FREIGHT_FLAG = G_NO))
    AND (buyline.line_type_code = G_LINE_LEVEL
         AND oldprg.line_id = buyline.line_id)
    AND oldprg.list_line_type_code = G_PROMO_GOODS_DISCOUNT
    --we need to look for in phase PRGs only otherwise
    --OM will keep deleting the fg lines between LINE and ORDER event
    --after every reprice
    AND oldprg.pricing_phase_id = ph.pricing_phase_id
    --commented this out as OM passes price_flag as 'N' on fg line
    --and ((oldprg.pricing_phase_id = ev.pricing_phase_id
    --and buyline.price_flag = G_YES)
    --or (oldprg.pricing_phase_id = ev.pricing_phase_id
    --and buyline.price_flag = G_PHASE
    --and ph.freeze_override_flag = G_YES))
    AND oldrltd.price_adjustment_id = oldprg.price_adjustment_id
    AND oldfgdis.price_adjustment_id = oldrltd.rltd_price_adj_id
    AND oldfgdis.list_line_type_code = 'DIS'
    --and ((oldfgdis.line_id is null
    --and oldfreeline.line_type_code = G_ORDER_LEVEL
    --and oldfreeline.line_id = oldfgdis.header_id)
    --freegood line is always a line need not match header
    AND (oldfgdis.line_id IS NOT NULL
         AND oldfreeline.line_type_code = G_LINE_LEVEL
         AND oldfreeline.line_id = oldfgdis.line_id)
--Commented this UNION as there wont be any FREEGOOD type modifier
--at ORDER level. this is causing perf issue for 8407425
--    UNION
--    SELECT /*+ ORDERED USE_NL(ev ph oldprg oldrltd oldfgdis oldfreeline)*/
--      oldfreeline.line_index,
--    oldfgdis.list_line_id,
--      nvl(oldfgdis.operand_per_pqty, oldfgdis.operand) operand_value,
--      oldfgdis.arithmetic_operator operand_calculation_code,
--      buyline.line_index,
--      oldprg.list_line_id,
--      oldprg.updated_flag
--    FROM qp_npreq_lines_tmp buyline
--      , qp_event_phases ev
--      , qp_pricing_phases ph
--      , oe_price_adjustments oldprg
--      , oe_price_adj_assocs oldrltd
--      , oe_price_adjustments oldfgdis
--      , qp_npreq_lines_tmp oldfreeline
    --where G_REQUEST_TYPE_CODE = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
--    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
    --need not do freegoods cleanup if PRG line has price_flag 'P' or 'N'
--    AND buyline.price_flag = G_YES --in (G_YES, G_PHASE)
--    AND instr(p_event_code, ev.pricing_event_code || ',') > 0
--    AND ph.pricing_phase_id = ev.pricing_phase_id
--    AND ((G_GET_FREIGHT_FLAG = G_YES AND ph.freight_exists = 'Y')
--         OR (G_GET_FREIGHT_FLAG = G_NO))
--    AND (buyline.line_type_code = G_ORDER_LEVEL
--         AND oldprg.header_id = buyline.line_id
--         AND oldprg.line_id IS NULL)
--    AND oldprg.list_line_type_code = G_PROMO_GOODS_DISCOUNT
    --we need to look for in phase PRGs only otherwise
    --OM will keep deleting the fg lines between LINE and ORDER event
    --after every reprice
--    AND oldprg.pricing_phase_id = ph.pricing_phase_id
    --commented this out as OM passes price_flag as 'N' on fg line
    --and ((oldprg.pricing_phase_id = ev.pricing_phase_id
    --and buyline.price_flag = G_YES)
    --or (oldprg.pricing_phase_id = ev.pricing_phase_id
    --and buyline.price_flag = G_PHASE
    --and ph.freeze_override_flag = G_YES))
--    AND oldrltd.price_adjustment_id = oldprg.price_adjustment_id
--    AND oldfgdis.price_adjustment_id = oldrltd.rltd_price_adj_id
--    AND oldfgdis.list_line_type_code = 'DIS'
    --and ((oldfgdis.line_id is null
    --and oldfreeline.line_type_code = G_ORDER_LEVEL
    --and oldfreeline.line_id = oldfgdis.header_id)
    --freegood line is always a line need not match header
--    AND (oldfgdis.line_id IS NOT NULL
--         AND oldfreeline.line_type_code = G_LINE_LEVEL
--         AND oldfreeline.line_id = oldfgdis.line_id)
--  End comment 8407425
    UNION
    SELECT /*+ ORDERED USE_NL(ev ph oldprg oldrltd oldfgdis oldfreeline)*/
      oldfreeline.line_index,
      oldfgdis.created_from_list_line_id,
      oldfgdis.operand_value,
      oldfgdis.operand_calculation_code,
      buyline.line_index,
      oldprg.created_from_list_line_id,
      oldprg.updated_flag
    FROM qp_npreq_lines_tmp buyline
      , qp_event_phases ev
      , qp_pricing_phases ph
      , qp_npreq_ldets_tmp oldprg
      , qp_npreq_rltd_lines_tmp oldrltd
      , qp_npreq_ldets_tmp oldfgdis
      , qp_npreq_lines_tmp oldfreeline
    --where G_REQUEST_TYPE_CODE <> 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES
    AND buyline.price_flag = G_YES --in (G_YES, G_PHASE)
    AND instr(p_event_code, ev.pricing_event_code || ',') > 0
    AND ph.pricing_phase_id = ev.pricing_phase_id
    AND ((G_GET_FREIGHT_FLAG = G_YES AND ph.freight_exists = 'Y')
         OR (G_GET_FREIGHT_FLAG = G_NO))
    AND oldprg.line_index = buyline.line_index
    AND oldprg.created_from_list_line_type = G_PROMO_GOODS_DISCOUNT
    --we need to look for in phase PRGs only otherwise
    --OC will keep deleting the fg lines between LINE and ORDER event
    AND oldprg.pricing_phase_id = ph.pricing_phase_id
    --	and oldprg.pricing_status_code = G_STATUS_UNCHANGED
    AND oldprg.applied_flag = G_YES
    AND oldrltd.line_detail_index = oldprg.line_detail_index
    AND oldrltd.relationship_type_code = G_GENERATED_LINE
    --	and oldrltd.pricing_status_code = G_STATUS_UNCHANGED
    AND oldfgdis.line_detail_index = oldrltd.related_line_detail_index
    AND oldfgdis.pricing_status_code = G_STATUS_UNCHANGED
    AND oldfgdis.applied_flag = G_YES
    AND oldfgdis.created_from_list_line_type = 'DIS'
    AND oldfreeline.line_index = oldrltd.related_line_index;
  --commented this out as OM passes price_flag as 'N' on fg line
  --and ((buyline.price_flag = G_YES
  --and oldprg.pricing_phase_id = ev.pricing_phase_id)
  --or (buyline.price_flag = G_PHASE
  --and oldprg.pricing_phase_id = ev.pricing_phase_id
  --and ph.freeze_override_flag = G_YES));

  l_fg_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_fg_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_buy_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_buy_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_buy_updated_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
  l_fg_operand_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_fg_operator_tbl QP_PREQ_GRP.VARCHAR_TYPE;

  -- bug 3639169 - changed from dynamic sql to static sql for performance
  CURSOR l_prg_debug IS
    SELECT prg.line_id buy_line_id, prg.list_line_id prg_list_line_id,
     fgdis.list_line_id fgdis_list_line_id, prg.pricing_phase_id prg_phase_id,
     prg.price_adjustment_id prg_price_adj_id,
     fgdis.price_adjustment_id fg_price_adj_id, fgdis.line_id fg_line_id,
     prg.updated_flag
     FROM qp_npreq_lines_tmp line, oe_price_adjustments prg,
     oe_price_adj_assocs ass, oe_price_adjustments fgdis
     WHERE line.line_type_code = G_LINE_LEVEL
     AND prg.line_id = line.line_id
     AND prg.list_line_type_code = 'PRG'
     AND ass.price_adjustment_id = prg.price_adjustment_id
     AND fgdis.price_adjustment_id = ass.rltd_price_adj_id
     UNION
     SELECT prg.line_id buy_line_id, prg.list_line_id prg_list_line_id,
     fgdis.list_line_id fgdis_list_line_id, prg.pricing_phase_id prg_phase_id,
     prg.price_adjustment_id prg_price_adj_id,
     fgdis.price_adjustment_id fg_price_adj_id, fgdis.line_id fg_line_id,
     prg.updated_flag
     FROM qp_npreq_lines_tmp line, oe_price_adjustments prg,
     oe_price_adj_assocs ass, oe_price_adjustments fgdis
     WHERE line.line_type_code = G_ORDER_LEVEL
     AND prg.header_id = line.line_id
     AND prg.line_id IS NULL
     AND prg.list_line_type_code = 'PRG'
     AND ass.price_adjustment_id = prg.price_adjustment_id
     AND fgdis.price_adjustment_id = ass.rltd_price_adj_id;

  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Identify_freegood_lines ';
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Identify_freegood_lines: '|| p_event_code);

    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status_text := '';

    IF l_debug = FND_API.G_TRUE THEN
      -- bug 3639169 - changed from dynamic sql to static sql for performance
      FOR cl IN l_prg_debug
        LOOP
        QP_PREQ_GRP.engine_debug('Printing out all PRGs irrespective of phases: '
                                 ||' buylineid '|| cl.buy_line_id ||' prglistlineid '|| cl.prg_list_line_id
                                 ||' prgpriceadjid '|| cl.prg_price_adj_id ||' prgupdatedflag '|| cl.updated_flag
                                 ||' fglineid '|| cl.fg_line_id ||' fgdis_listlineid '|| cl.fgdis_list_line_id
                                 ||' fgpriceadjid '|| cl.fg_price_adj_id ||' prg_phase_id '|| cl.prg_phase_id);
      END LOOP;
    END IF; --l_debug

    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      AND l_debug = FND_API.G_TRUE
      THEN
      FOR cl IN
        (SELECT buyline.line_index
         , oldprg.list_line_id, oldfgdis.line_id
         , oldprg.updated_flag
         FROM qp_npreq_lines_tmp buyline
         , qp_event_phases ev
         , qp_pricing_phases ph
         , oe_price_adjustments oldprg
         , oe_price_adj_assocs oldrltd
         , oe_price_adjustments oldfgdis
         --  where G_REQUEST_TYPE_CODE = 'ONT'
         --bug 3085453 handle pricing availability UI
         -- they pass reqtype ONT and insert adj into ldets
         WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
         AND instr(p_event_code, ev.pricing_event_code || ',') > 0
         AND ph.pricing_phase_id = ev.pricing_phase_id
         AND ((buyline.line_type_code = G_LINE_LEVEL
               AND oldprg.line_id = buyline.line_id)
              OR (buyline.line_type_code = G_ORDER_LEVEL
                  AND oldprg.header_id = buyline.line_id
                  AND oldprg.line_id IS NULL))
         AND oldprg.list_line_type_code = 'PRG'
         AND oldprg.pricing_phase_id = ph.pricing_phase_id
         --  and ((oldprg.pricing_phase_id = ev.pricing_phase_id
         --  and buyline.price_flag = G_YES)
         --  or (oldprg.pricing_phase_id = ev.pricing_phase_id
         --  and buyline.price_flag = G_PHASE
         --  and ph.freeze_override_flag = G_YES))
         AND oldrltd.price_adjustment_id = oldprg.price_adjustment_id
         AND oldfgdis.price_adjustment_id = oldrltd.rltd_price_adj_id
         AND oldfgdis.list_line_type_code = 'DIS')
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('ident fg dtls: buylineindex '|| cl.line_index
                                   ||' prg-list_line_id '|| cl.list_line_id
                                   ||' fgline_id  '|| cl.line_id ||' updated_flag '|| cl.updated_flag);
        END IF;
      END LOOP; --for cl
    END IF; --debug

    OPEN l_Identify_freegood_cur;
    l_fg_line_index_tbl.DELETE;
    l_fg_list_line_id_tbl.DELETE;
    l_fg_operand_tbl.DELETE;
    l_fg_operator_tbl.DELETE;
    l_buy_line_index_tbl.DELETE;
    l_buy_list_line_id_tbl.DELETE;
    FETCH l_Identify_freegood_cur
    BULK COLLECT INTO l_fg_line_index_tbl
    , l_fg_list_line_id_tbl
    , l_fg_operand_tbl
    , l_fg_operator_tbl
    , l_buy_line_index_tbl
    , l_buy_list_line_id_tbl
    , l_buy_updated_flag_tbl;
    CLOSE l_Identify_freegood_cur;

    IF l_fg_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Freegood lines exist: '|| l_fg_line_index_tbl.COUNT);

      END IF;
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        FOR i IN l_fg_line_index_tbl.FIRST..l_fg_line_index_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('process_sts: line_ind '
                                     || l_fg_line_index_tbl(i) ||' fglist_line_id '
                                     || l_fg_list_line_id_tbl(i) ||' fgdis operand '
                                     || l_fg_operand_tbl(i) ||' fgdis operator '
                                     || l_fg_operator_tbl(i) ||' prglist_line_id '
                                     || l_buy_list_line_id_tbl(i) ||' prg-updated_flag '
                                     || l_buy_updated_flag_tbl(i));
          END IF;
        END LOOP; --l_fg_line_index_tbl
      END IF; --debug

      FORALL i IN l_fg_line_index_tbl.FIRST..l_fg_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp
      SET process_status = G_FREEGOOD || l_fg_list_line_id_tbl(i) || G_BUYLINE
      || l_buy_line_index_tbl(i) || G_PROMO_GOODS_DISCOUNT || l_buy_list_line_id_tbl(i)
      || G_PROMO_GOODS_DISCOUNT || nvl(l_buy_updated_flag_tbl(i), G_NO)
      || G_STATUS_UPDATED || l_fg_operand_tbl(i) || l_fg_operator_tbl(i)
      || G_PROMO_GOODS_DISCOUNT
        , priced_quantity = nvl(priced_quantity, line_quantity) -- 2970402, 2997007
        , priced_uom_code = nvl(priced_uom_code, line_uom_code) -- 2970402, 2997007
      WHERE line_index = l_fg_line_index_tbl(i);

    END IF; --l_fg_line_index_tbl.count

    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
      THEN
      FOR cl IN (SELECT line_index, process_status FROM qp_npreq_lines_tmp
                 WHERE instr(process_status, G_FREEGOOD) > 0)
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Freegood line dtl: line_ind '
                                   || cl.line_index ||' process_sts '|| cl.process_status);
        END IF;
      END LOOP; --for cl
    END IF; --debug

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Identify_freegood_lines');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
  END Identify_freegood_lines;

  --procedure to mark the prg lines as deleted if
  --called by OC or any other application other than OM
  --this is because there will be 2 prg adjustments one passed-in
  --and other inserted the pricing engine
  --the prg against the line which is marked as invalid needs to
  --be marked as deleted so that it is not visible to calling application
  --(created for bug 2970368)
  PROCEDURE Update_prg_pricing_status(x_return_status OUT NOCOPY VARCHAR2,
                                      x_return_status_text OUT NOCOPY VARCHAR2) IS
  CURSOR l_mark_prg_delete_cur IS
    SELECT rltd.line_detail_index, rltd.related_line_detail_index
    FROM qp_npreq_rltd_lines_tmp rltd, qp_npreq_lines_tmp line
    WHERE rltd.pricing_status_code = G_STATUS_NEW
    AND rltd.relationship_type_code = G_GENERATED_LINE
    AND line.line_index = rltd.related_line_index
    AND line.process_status IN (G_NOT_VALID, G_STATUS_DELETED); --bug 3126969

  l_mark_prg_delete_index QP_PREQ_GRP.number_type;
  l_mark_fgdis_delete_index QP_PREQ_GRP.number_type;
  l_prg_list_line_id NUMBER;

  l_debug VARCHAR2(3);
  l_routine VARCHAR2(50) := 'QP_PREQ_PUB.Update_prg_pricing_status';
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Update_prg_pricing_status');
    END IF;
    OPEN l_mark_prg_delete_cur;
    l_mark_prg_delete_index.DELETE;
    l_mark_fgdis_delete_index.DELETE;
    FETCH l_mark_prg_delete_cur BULK COLLECT INTO
    l_mark_prg_delete_index, l_mark_fgdis_delete_index;
    CLOSE l_mark_prg_delete_cur;

    IF l_mark_prg_delete_index.COUNT > 0 THEN
      IF l_debug = FND_API.G_TRUE THEN
        FOR i IN l_mark_prg_delete_index.FIRST..l_mark_prg_delete_index.LAST
          LOOP
          BEGIN
            SELECT created_from_list_line_id INTO l_prg_list_line_id
            FROM qp_npreq_ldets_tmp
            WHERE line_detail_index = l_mark_prg_delete_index(i);
            QP_PREQ_GRP.engine_debug('Mark delete prg '|| l_mark_prg_delete_index(i)
                                     ||' list_line_id '|| l_prg_list_line_id);
          EXCEPTION
            WHEN OTHERS THEN
              QP_PREQ_GRP.engine_debug('Mark delete prg list_line_id -1');
          END;
        END LOOP;
      END IF; --l_debug
      IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = 'N' THEN
        FORALL i IN l_mark_prg_delete_index.FIRST..l_mark_prg_delete_index.LAST
        UPDATE qp_npreq_ldets_tmp SET pricing_status_code = G_STATUS_DELETED
        WHERE line_detail_index = l_mark_prg_delete_index(i);
      END IF;
    END IF; --l_mark_prg_delete_index.COUNT

    IF l_mark_fgdis_delete_index.COUNT > 0 THEN

      IF l_debug = FND_API.G_TRUE THEN
        FOR i IN l_mark_fgdis_delete_index.FIRST..l_mark_fgdis_delete_index.LAST
          LOOP
          BEGIN
            SELECT created_from_list_line_id INTO l_prg_list_line_id
            FROM qp_npreq_ldets_tmp
            WHERE line_detail_index = l_mark_fgdis_delete_index(i);
            QP_PREQ_GRP.engine_debug('Mark delete fgdis '|| l_mark_fgdis_delete_index
                                     (i)
                                     ||' list_line_id '|| l_prg_list_line_id);
          EXCEPTION
            WHEN OTHERS THEN
              QP_PREQ_GRP.engine_debug('Mark delete fgdis list_line_id -1');
          END;
        END LOOP;
      END IF; --l_debug
      FORALL i IN l_mark_fgdis_delete_index.FIRST..l_mark_fgdis_delete_index.LAST
      UPDATE qp_npreq_ldets_tmp SET pricing_status_code = G_STATUS_DELETED
      WHERE line_detail_index = l_mark_fgdis_delete_index(i);
    END IF; --l_mark_fgdis_delete_index.count
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Update_prg_pricing_status');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
  END Update_prg_pricing_status;

  --This procedure processes the passed in freegood lines marked from the
  --previous procedure and tries to find matching newly created PRG modifiers
  --applied against the buy line
  --If there are no PRG modifiers applied, the passed in freegood line is
  --marked as deleted for the calling application to delete them
  --If there are matching PRG modifiers applied, then we compare the
  --passed in freegood lines against what the engine has newly created
  --If they do not match, the newly created lines are marked UPDATED
  --for the calling application to update
  --If they match, then we mark them as UNCHANGED prefixing OLD or NEW
  --to identify the old and new freegood line. This is to compare the
  --selling price later on, may be that could have changed
  PROCEDURE Process_PRG(x_return_status OUT NOCOPY VARCHAR2,
                        x_return_status_text OUT NOCOPY VARCHAR2) IS

  PRG_Exception EXCEPTION;

  CURSOR l_compare_freegood_cur IS
    SELECT newfgline.line_index new_line_index,
      newfgline.line_quantity new_line_quantity,
      newfgline.line_uom_code new_line_uom_code,
      newfgline.priced_quantity new_priced_quantity,
      newfgline.priced_uom_code new_priced_uom_code,
      newfgitem.value_from new_item,
      newfgline.UOM_QUANTITY new_UOM_QUANTITY,
      newfgline.CURRENCY_CODE new_CURRENCY_CODE,
      newfgline.UNIT_PRICE new_UNIT_PRICE,
      newfgline.PERCENT_PRICE new_PERCENT_PRICE,
      newfgline.ADJUSTED_UNIT_PRICE new_ADJUSTED_UNIT_PRICE,
      newfgline.PARENT_PRICE new_PARENT_PRICE,
      newfgline.PARENT_QUANTITY new_PARENT_QUANTITY,
      newfgline.PARENT_UOM_CODE new_PARENT_UOM_CODE,
      newfgline.PROCESSING_ORDER new_PROCESSING_ORDER,
      newfgline.PROCESSED_FLAG new_PROCESSED_FLAG,
      newfgline.PROCESSED_CODE new_PROCESSED_CODE,
      newfgline.PRICE_FLAG new_PRICE_FLAG,
      newfgline.PRICING_STATUS_CODE new_PRICING_STATUS_CODE,
      newfgline.PRICING_STATUS_TEXT new_PRICING_STATUS_TEXT,
      newfgline.START_DATE_ACTIVE_FIRST new_START_DATE_ACTIVE_FIRST,
      newfgline.ACTIVE_DATE_FIRST_TYPE new_ACTIVE_DATE_FIRST_TYPE,
      newfgline.START_DATE_ACTIVE_SECOND new_START_DATE_ACTIVE_SECOND,
      newfgline.ACTIVE_DATE_SECOND_TYPE new_ACTIVE_DATE_SECOND_TYPE,
      newfgline.GROUP_QUANTITY new_GROUP_QUANTITY,
      newfgline.GROUP_AMOUNT new_GROUP_AMOUNT,
      newfgline.LINE_AMOUNT new_LINE_AMOUNT,
      newfgline.ROUNDING_FLAG new_ROUNDING_FLAG,
      newfgline.ROUNDING_FACTOR new_ROUNDING_FACTOR,
      newfgline.UPDATED_ADJUSTED_UNIT_PRICE new_upd_ADJUSTED_UNIT_PRICE,
      newfgline.PRICE_REQUEST_CODE new_PRICE_REQUEST_CODE,
      newfgline.HOLD_CODE new_HOLD_CODE,
      newfgline.HOLD_TEXT new_HOLD_TEXT,
      newfgline.PRICE_LIST_HEADER_ID new_PRICE_LIST_HEADER_ID,
      newfgline.VALIDATED_FLAG new_VALIDATED_FLAG,
      newfgline.QUALIFIERS_EXIST_FLAG new_QUALIFIERS_EXIST_FLAG,
      newfgline.PRICING_ATTRS_EXIST_FLAG new_PRICING_ATTRS_EXIST_FLAG,
      newfgline.PRIMARY_QUALIFIERS_MATCH_FLAG new_PRIMARY_QUAL_MATCH_FLAG,
      newfgline.USAGE_PRICING_TYPE new_USAGE_PRICING_TYPE,
      newfgline.LINE_CATEGORY new_LINE_CATEGORY,
      newfgline.CONTRACT_START_DATE new_CONTRACT_START_DATE,
      newfgline.CONTRACT_END_DATE new_CONTRACT_END_DATE,
      newfgline.LINE_UNIT_PRICE new_LINE_UNIT_PRICE,
      oldfreeline.line_index old_line_index,
      oldfreeline.line_id old_line_id,
      oldfreeline.line_quantity old_line_quantity,
      oldfreeline.line_uom_code old_line_uom_code,
      oldfreeline.priced_quantity old_priced_quantity,
      oldfreeline.priced_uom_code old_priced_uom_code,
      oldfreeitem.value_from old_item,
      oldfreeline.UOM_QUANTITY old_UOM_QUANTITY,
      oldfreeline.CURRENCY_CODE old_CURRENCY_CODE,
      oldfreeline.UNIT_PRICE old_UNIT_PRICE,
      oldfreeline.PERCENT_PRICE old_PERCENT_PRICE,
      oldfreeline.ADJUSTED_UNIT_PRICE old_ADJUSTED_UNIT_PRICE,
      oldfreeline.PARENT_PRICE old_PARENT_PRICE,
      oldfreeline.PARENT_QUANTITY old_PARENT_QUANTITY,
      oldfreeline.PARENT_UOM_CODE old_PARENT_UOM_CODE,
      oldfreeline.PROCESSING_ORDER old_PROCESSING_ORDER,
      oldfreeline.PROCESSED_FLAG old_PROCESSED_FLAG,
      oldfreeline.PROCESSED_CODE old_PROCESSED_CODE,
      oldfreeline.PRICE_FLAG old_PRICE_FLAG,
      oldfreeline.PRICING_STATUS_CODE old_PRICING_STATUS_CODE,
      oldfreeline.PRICING_STATUS_TEXT old_PRICING_STATUS_TEXT,
      oldfreeline.START_DATE_ACTIVE_FIRST old_START_DATE_ACTIVE_FIRST,
      oldfreeline.ACTIVE_DATE_FIRST_TYPE old_ACTIVE_DATE_FIRST_TYPE,
      oldfreeline.START_DATE_ACTIVE_SECOND old_START_DATE_ACTIVE_SECOND,
      oldfreeline.ACTIVE_DATE_SECOND_TYPE old_ACTIVE_DATE_SECOND_TYPE,
      oldfreeline.GROUP_QUANTITY old_GROUP_QUANTITY,
      oldfreeline.GROUP_AMOUNT old_GROUP_AMOUNT,
      oldfreeline.LINE_AMOUNT old_LINE_AMOUNT,
      oldfreeline.ROUNDING_FLAG old_ROUNDING_FLAG,
      oldfreeline.ROUNDING_FACTOR old_ROUNDING_FACTOR,
      oldfreeline.UPDATED_ADJUSTED_UNIT_PRICE
      old_upd_ADJUSTED_UNIT_PRICE,
      oldfreeline.PRICE_REQUEST_CODE old_PRICE_REQUEST_CODE,
      oldfreeline.HOLD_CODE old_HOLD_CODE,
      oldfreeline.HOLD_TEXT old_HOLD_TEXT,
      oldfreeline.PRICE_LIST_HEADER_ID old_PRICE_LIST_HEADER_ID,
      oldfreeline.VALIDATED_FLAG old_VALIDATED_FLAG,
      oldfreeline.QUALIFIERS_EXIST_FLAG old_QUALIFIERS_EXIST_FLAG,
      oldfreeline.PRICING_ATTRS_EXIST_FLAG old_PRICING_ATTRS_EXIST_FLAG,
      oldfreeline.PRIMARY_QUALIFIERS_MATCH_FLAG
      old_PRIMARY_QUAL_MATCH_FLAG,
      oldfreeline.USAGE_PRICING_TYPE old_USAGE_PRICING_TYPE,
      oldfreeline.LINE_CATEGORY old_LINE_CATEGORY,
      oldfreeline.CONTRACT_START_DATE old_CONTRACT_START_DATE,
      oldfreeline.CONTRACT_END_DATE old_CONTRACT_END_DATE,
      oldfreeline.LINE_UNIT_PRICE old_LINE_UNIT_PRICE,
      oldfreeline.process_status old_list_line_id,
      newfgdis.created_from_list_line_id newfgdis_list_line_id,
      newfgdis.operand_value || newfgdis.operand_calculation_code newfgdis_operand
    FROM qp_npreq_lines_tmp oldfreeline
      , qp_npreq_rltd_lines_tmp newrltd
      , qp_npreq_ldets_tmp newfgdis
      , qp_npreq_lines_tmp newfgline
      , qp_npreq_line_attrs_tmp oldfreeitem
      , qp_npreq_line_attrs_tmp newfgitem
    --where G_REQUEST_TYPE_CODE = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
    AND instr(oldfreeline.process_status, G_FREEGOOD) > 0
    AND newrltd.pricing_status_code = G_STATUS_NEW
    AND instr(oldfreeline.process_status
              , G_BUYLINE || newrltd.line_index || G_PROMO_GOODS_DISCOUNT) > 0
    AND newfgdis.pricing_status_code = G_STATUS_NEW
    AND newfgdis.applied_flag = G_YES
    AND instr(oldfreeline.process_status
              , G_FREEGOOD || newfgdis.created_from_list_line_id || G_BUYLINE) > 0
    AND newfgdis.line_detail_index = newrltd.related_line_detail_index
    AND newfgline.line_index = newfgdis.line_index
    AND oldfreeitem.line_index = oldfreeline.line_index
    AND oldfreeitem.line_detail_index IS NULL
    AND oldfreeitem.context = G_ITEM_CONTEXT
    AND oldfreeitem.attribute = G_PRIC_ATTRIBUTE1
    AND newfgitem.line_index = newfgline.line_index
    AND newfgitem.context = G_ITEM_CONTEXT
    AND newfgitem.attribute = G_PRIC_ATTRIBUTE1
    UNION
    SELECT newfgline.line_index new_line_index,
      newfgline.line_quantity new_line_quantity,
      newfgline.line_uom_code new_line_uom_code,
      newfgline.priced_quantity new_priced_quantity,
      newfgline.priced_uom_code new_priced_uom_code,
      newfgitem.value_from new_item,
      newfgline.UOM_QUANTITY new_UOM_QUANTITY,
      newfgline.CURRENCY_CODE new_CURRENCY_CODE,
      newfgline.UNIT_PRICE new_UNIT_PRICE,
      newfgline.PERCENT_PRICE new_PERCENT_PRICE,
      newfgline.ADJUSTED_UNIT_PRICE new_ADJUSTED_UNIT_PRICE,
      newfgline.PARENT_PRICE new_PARENT_PRICE,
      newfgline.PARENT_QUANTITY new_PARENT_QUANTITY,
      newfgline.PARENT_UOM_CODE new_PARENT_UOM_CODE,
      newfgline.PROCESSING_ORDER new_PROCESSING_ORDER,
      newfgline.PROCESSED_FLAG new_PROCESSED_FLAG,
      newfgline.PROCESSED_CODE new_PROCESSED_CODE,
      newfgline.PRICE_FLAG new_PRICE_FLAG,
      newfgline.PRICING_STATUS_CODE new_PRICING_STATUS_CODE,
      newfgline.PRICING_STATUS_TEXT new_PRICING_STATUS_TEXT,
      newfgline.START_DATE_ACTIVE_FIRST new_START_DATE_ACTIVE_FIRST,
      newfgline.ACTIVE_DATE_FIRST_TYPE new_ACTIVE_DATE_FIRST_TYPE,
      newfgline.START_DATE_ACTIVE_SECOND new_START_DATE_ACTIVE_SECOND,
      newfgline.ACTIVE_DATE_SECOND_TYPE new_ACTIVE_DATE_SECOND_TYPE,
      newfgline.GROUP_QUANTITY new_GROUP_QUANTITY,
      newfgline.GROUP_AMOUNT new_GROUP_AMOUNT,
      newfgline.LINE_AMOUNT new_LINE_AMOUNT,
      newfgline.ROUNDING_FLAG new_ROUNDING_FLAG,
      newfgline.ROUNDING_FACTOR new_ROUNDING_FACTOR,
      newfgline.UPDATED_ADJUSTED_UNIT_PRICE new_upd_ADJUSTED_UNIT_PRICE,
      newfgline.PRICE_REQUEST_CODE new_PRICE_REQUEST_CODE,
      newfgline.HOLD_CODE new_HOLD_CODE,
      newfgline.HOLD_TEXT new_HOLD_TEXT,
      newfgline.PRICE_LIST_HEADER_ID new_PRICE_LIST_HEADER_ID,
      newfgline.VALIDATED_FLAG new_VALIDATED_FLAG,
      newfgline.QUALIFIERS_EXIST_FLAG new_QUALIFIERS_EXIST_FLAG,
      newfgline.PRICING_ATTRS_EXIST_FLAG new_PRICING_ATTRS_EXIST_FLAG,
      newfgline.PRIMARY_QUALIFIERS_MATCH_FLAG new_PRIMARY_QUAL_MATCH_FLAG,
      newfgline.USAGE_PRICING_TYPE new_USAGE_PRICING_TYPE,
      newfgline.LINE_CATEGORY new_LINE_CATEGORY,
      newfgline.CONTRACT_START_DATE new_CONTRACT_START_DATE,
      newfgline.CONTRACT_END_DATE new_CONTRACT_END_DATE,
      newfgline.LINE_UNIT_PRICE new_LINE_UNIT_PRICE,
      oldfreeline.line_index old_line_index,
      oldfreeline.line_id old_line_id,
      oldfreeline.line_quantity old_line_quantity,
      oldfreeline.line_uom_code old_line_uom_code,
      oldfreeline.priced_quantity old_priced_quantity,
      oldfreeline.priced_uom_code old_priced_uom_code,
      oldfreeitem.value_from old_item,
      oldfreeline.UOM_QUANTITY old_UOM_QUANTITY,
      oldfreeline.CURRENCY_CODE old_CURRENCY_CODE,
      oldfreeline.UNIT_PRICE old_UNIT_PRICE,
      oldfreeline.PERCENT_PRICE old_PERCENT_PRICE,
      oldfreeline.ADJUSTED_UNIT_PRICE old_ADJUSTED_UNIT_PRICE,
      oldfreeline.PARENT_PRICE old_PARENT_PRICE,
      oldfreeline.PARENT_QUANTITY old_PARENT_QUANTITY,
      oldfreeline.PARENT_UOM_CODE old_PARENT_UOM_CODE,
      oldfreeline.PROCESSING_ORDER old_PROCESSING_ORDER,
      oldfreeline.PROCESSED_FLAG old_PROCESSED_FLAG,
      oldfreeline.PROCESSED_CODE old_PROCESSED_CODE,
      oldfreeline.PRICE_FLAG old_PRICE_FLAG,
      oldfreeline.PRICING_STATUS_CODE old_PRICING_STATUS_CODE,
      oldfreeline.PRICING_STATUS_TEXT old_PRICING_STATUS_TEXT,
      oldfreeline.START_DATE_ACTIVE_FIRST old_START_DATE_ACTIVE_FIRST,
      oldfreeline.ACTIVE_DATE_FIRST_TYPE old_ACTIVE_DATE_FIRST_TYPE,
      oldfreeline.START_DATE_ACTIVE_SECOND old_START_DATE_ACTIVE_SECOND,
      oldfreeline.ACTIVE_DATE_SECOND_TYPE old_ACTIVE_DATE_SECOND_TYPE,
      oldfreeline.GROUP_QUANTITY old_GROUP_QUANTITY,
      oldfreeline.GROUP_AMOUNT old_GROUP_AMOUNT,
      oldfreeline.LINE_AMOUNT old_LINE_AMOUNT,
      oldfreeline.ROUNDING_FLAG old_ROUNDING_FLAG,
      oldfreeline.ROUNDING_FACTOR old_ROUNDING_FACTOR,
      oldfreeline.UPDATED_ADJUSTED_UNIT_PRICE
      old_upd_ADJUSTED_UNIT_PRICE,
      oldfreeline.PRICE_REQUEST_CODE old_PRICE_REQUEST_CODE,
      oldfreeline.HOLD_CODE old_HOLD_CODE,
      oldfreeline.HOLD_TEXT old_HOLD_TEXT,
      oldfreeline.PRICE_LIST_HEADER_ID old_PRICE_LIST_HEADER_ID,
      oldfreeline.VALIDATED_FLAG old_VALIDATED_FLAG,
      oldfreeline.QUALIFIERS_EXIST_FLAG old_QUALIFIERS_EXIST_FLAG,
      oldfreeline.PRICING_ATTRS_EXIST_FLAG old_PRICING_ATTRS_EXIST_FLAG,
      oldfreeline.PRIMARY_QUALIFIERS_MATCH_FLAG
      old_PRIMARY_QUAL_MATCH_FLAG,
      oldfreeline.USAGE_PRICING_TYPE old_USAGE_PRICING_TYPE,
      oldfreeline.LINE_CATEGORY old_LINE_CATEGORY,
      oldfreeline.CONTRACT_START_DATE old_CONTRACT_START_DATE,
      oldfreeline.CONTRACT_END_DATE old_CONTRACT_END_DATE,
      oldfreeline.LINE_UNIT_PRICE old_LINE_UNIT_PRICE,
      oldfreeline.process_status old_list_line_id,
      newfgdis.created_from_list_line_id newfgdis_list_line_id,
      newfgdis.operand_value || newfgdis.operand_calculation_code newfgdis_operand
    FROM qp_npreq_lines_tmp oldfreeline
      , qp_npreq_rltd_lines_tmp newrltd
      , qp_npreq_ldets_tmp newfgdis
      , qp_npreq_lines_tmp newfgline
      , qp_npreq_line_attrs_tmp newfgitem
      , qp_npreq_line_attrs_tmp oldfreeitem
    --WHERE G_REQUEST_TYPE_CODE <> 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES
    AND instr(oldfreeline.process_status, G_FREEGOOD) > 0
    AND newfgdis.pricing_status_code = G_STATUS_NEW
    AND newfgdis.applied_flag = G_YES
    AND instr(oldfreeline.process_status, G_FREEGOOD || newfgdis.created_from_list_line_id || G_BUYLINE) > 0
    AND newrltd.pricing_status_code = G_STATUS_NEW
    AND newrltd.related_line_index = newfgdis.line_index -- 2970380
    AND newrltd.related_line_detail_index = newfgdis.line_detail_index -- 2970380
    AND instr(oldfreeline.process_status
              , G_BUYLINE || newrltd.line_index || G_PROMO_GOODS_DISCOUNT) > 0
    AND newfgline.line_index = newfgdis.line_index
    AND newfgline.line_index = newrltd.related_line_index -- 2970380
    AND newfgitem.line_detail_index = newfgdis.line_detail_index
    AND newfgitem.context = G_ITEM_CONTEXT
    AND newfgitem.attribute = G_PRIC_ATTRIBUTE1
    AND oldfreeitem.line_index = oldfreeline.line_index
    AND oldfreeitem.line_detail_index IS NULL
    AND oldfreeitem.context = G_ITEM_CONTEXT
    AND oldfreeitem.attribute = G_PRIC_ATTRIBUTE1;

  CURSOR l_updated_prg_fg_cur IS
    SELECT /*+ INDEX(prg OE_PRICE_ADJUSTMENTS_N2) */ rltd.related_line_index
    FROM qp_npreq_lines_tmp buyline, oe_price_adjustments prg,
      qp_npreq_ldets_tmp ldet, qp_npreq_rltd_lines_tmp rltd
    --WHERE G_REQUEST_TYPE_CODE = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
    AND buyline.line_type_code = G_LINE_LEVEL
    AND prg.line_id = buyline.line_id
    AND prg.list_line_type_code = G_PROMO_GOODS_DISCOUNT
    AND prg.updated_flag = G_YES
    AND ldet.line_index = buyline.line_index
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.created_from_list_line_id = prg.list_line_id
    AND ldet.applied_flag = G_YES
    AND rltd.line_index = ldet.line_index
    AND rltd.line_detail_index = ldet.line_detail_index
    AND rltd.pricing_status_code = G_STATUS_NEW
    UNION
    SELECT /*+ INDEX(prg OE_PRICE_ADJUSTMENTS_N1) */ rltd.related_line_index
    FROM qp_npreq_lines_tmp buyline, oe_price_adjustments prg,
      qp_npreq_ldets_tmp ldet, qp_npreq_rltd_lines_tmp rltd
    --WHERE G_REQUEST_TYPE_CODE = 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES
    AND buyline.line_type_code = G_ORDER_LEVEL
    AND prg.line_id IS NULL
    AND prg.header_id = buyline.line_id
    AND prg.list_line_type_code = G_PROMO_GOODS_DISCOUNT
    AND prg.updated_flag = G_YES
    AND ldet.line_index = buyline.line_index
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.created_from_list_line_id = prg.list_line_id
    AND ldet.applied_flag = G_YES
    AND rltd.line_index = ldet.line_index
    AND rltd.line_detail_index = ldet.line_detail_index
    AND rltd.pricing_status_code = G_STATUS_NEW
    UNION
    -- hint added for 5575718
    SELECT /*+ ORDERED */ rltd.related_line_index
    FROM qp_npreq_lines_tmp buyline, qp_npreq_ldets_tmp prg,
      qp_npreq_ldets_tmp ldet, qp_npreq_rltd_lines_tmp rltd
    --WHERE G_REQUEST_TYPE_CODE <> 'ONT'
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES
    AND prg.line_index = buyline.line_index
    AND prg.pricing_status_code = G_STATUS_UNCHANGED
    AND prg.created_from_list_line_type = G_PROMO_GOODS_DISCOUNT
    AND prg.updated_flag = G_YES
    AND ldet.line_index = buyline.line_index
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.created_from_list_line_id = prg.created_from_list_line_id
    AND ldet.applied_flag = G_YES
    AND rltd.line_index = ldet.line_index
    AND rltd.line_detail_index = ldet.line_detail_index
    AND rltd.pricing_status_code = G_STATUS_NEW;

  l_prg_line_ind_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_prg_process_sts_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_prg_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_prg_price_flag_tbl QP_PREQ_GRP.VARCHAR_TYPE; -- Ravi

  l_upd_engine_fg_index QP_PREQ_GRP.NUMBER_TYPE;

  l_Process_PRG VARCHAR2(1) := G_NO;
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Process_PRG ';
  l_oldfgdis_list_line_id VARCHAR2(2000);
  l_old_operand VARCHAR2(240);

  i PLS_INTEGER;
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin process_prg');
      QP_PREQ_GRP.engine_debug('Process_prg req_type '|| G_REQUEST_TYPE_CODE);

    END IF;
    --initialize pl/sql tables
    l_prg_line_ind_tbl.DELETE;
    l_prg_process_sts_tbl.DELETE;
    l_prg_line_id_tbl.DELETE;
    l_prg_price_flag_tbl.DELETE;

    --initialize global pl/sql tables
    G_prg_unch_calc_price_tbl.DELETE;
    G_prg_unch_line_id_tbl.DELETE;
    G_prg_unch_line_ind_tbl.DELETE;
    G_prg_unch_new_index_tbl.DELETE;
    G_prg_unch_line_index_tbl.DELETE;
    G_prg_unch_process_sts_tbl.DELETE;

    BEGIN
      SELECT 'Y' INTO l_Process_PRG
      FROM qp_npreq_ldets_tmp
      WHERE created_from_list_line_type = G_PROMO_GOODS_DISCOUNT
      AND pricing_status_code = G_STATUS_NEW
      AND applied_flag = 'Y'
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('No PRG: ');
        END IF;
        l_Process_PRG := G_NO;
      WHEN OTHERS THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Error in PRG: '|| SQLERRM);
        END IF;
        --x_return_status := FND_API.G_RET_STS_ERROR;
        --x_return_status_text := l_routine||SQLERRM;
        RAISE PRG_Exception;
    END;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Value of process_PRG '|| l_Process_PRG);


    END IF;
    IF l_Process_PRG = G_NO
      THEN
      BEGIN
        SELECT 'Y' INTO l_Process_PRG
        FROM qp_npreq_lines_tmp line
        WHERE line.pricing_status_code IN (G_STATUS_UNCHANGED,
                                           G_STATUS_UPDATED, G_STATUS_NEW, G_STATUS_GSA_VIOLATION, G_STATUS_INVALID_PRICE_LIST)
        AND instr(line.process_status, G_FREEGOOD) > 0
        AND ROWNUM = 1;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Value of process_PRG after fg '|| l_Process_PRG);
        END IF; --l_debug

        IF l_Process_PRG = G_NO THEN
          SELECT 'Y' INTO l_Process_PRG
          FROM qp_npreq_lines_tmp line
          WHERE line.pricing_status_code IN (G_STATUS_UNCHANGED,
                                             G_STATUS_UPDATED, G_STATUS_NEW, G_STATUS_GSA_VIOLATION)
          AND EXISTS
          (SELECT 'Y' FROM oe_price_adjustments adj
           WHERE line.line_type_code = G_LINE_LEVEL
           AND adj.line_id = line.line_id
           AND adj.list_line_type_code = G_PROMO_GOODS_DISCOUNT
           AND adj.updated_flag = G_YES
           UNION
           SELECT 'Y' FROM oe_price_adjustments adj
           WHERE line.line_type_code = G_ORDER_LEVEL
           AND adj.header_id = line.line_id
           AND adj.line_id IS NULL
           AND adj.list_line_type_code = G_PROMO_GOODS_DISCOUNT
           AND adj.updated_flag = G_YES
           UNION
           SELECT 'Y' FROM qp_npreq_ldets_tmp adj
           WHERE adj.created_from_list_line_type = G_PROMO_GOODS_DISCOUNT
           AND adj.pricing_status_code = G_STATUS_UNCHANGED
           AND adj.updated_flag = G_YES);
        END IF; --l_PROCESS_PRG
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Value of process_PRG after over '|| l_Process_PRG);
        END IF; --Bug No - 4033618
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_Process_PRG := G_NO;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('No PRG in oe_price_adj');
          END IF;
        WHEN OTHERS THEN
          l_Process_PRG := G_NO;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Exception in prg '|| SQLERRM);
          END IF;
      END;
    END IF; --l_Process_PRG

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Value of process_PRG after query '|| l_Process_PRG);

    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      FOR cl IN
        (SELECT adj.list_line_id, adj.updated_flag, line.line_index,
         adj.pricing_phase_id, adj.price_adjustment_id, adj.line_id
         FROM qp_npreq_lines_tmp line, oe_price_adjustments adj
         WHERE line.line_type_code = G_LINE_LEVEL
         AND adj.line_id = line.line_id
         AND adj.list_line_type_code = G_PROMO_GOODS_DISCOUNT
         UNION
         SELECT adj.list_line_id, adj.updated_flag, line.line_index,
         adj.pricing_phase_id, adj.price_adjustment_id, adj.line_id
         FROM qp_npreq_lines_tmp line, oe_price_adjustments adj
         WHERE line.line_type_code = G_ORDER_LEVEL
         AND adj.header_id = line.line_id
         AND adj.line_id IS NULL
         AND adj.list_line_type_code = G_PROMO_GOODS_DISCOUNT)
        LOOP
        QP_PREQ_GRP.engine_debug('PRGs check whether update_flag: '
                                 ||'prg listlineid '|| cl.list_line_id ||' updatedflag '|| cl.updated_flag
                                 ||' buylineid '|| cl.line_id ||' prgphaseid '|| cl.pricing_phase_id);
        FOR fg IN
          (SELECT rltd.related_line_index, ldet.created_from_list_line_id
           FROM qp_npreq_ldets_tmp ldet, qp_npreq_rltd_lines_tmp rltd
           WHERE ldet.line_index = cl.line_index
           AND ldet.pricing_status_code = G_STATUS_NEW
           AND ldet.applied_flag = G_YES
           AND ldet.created_from_list_line_id = cl.list_line_id
           AND rltd.line_index = ldet.line_index
           AND rltd.line_detail_index = ldet.line_detail_index)
          LOOP
          QP_PREQ_GRP.engine_debug('PRGs check whether engine_prg: '
                                   ||'engine prg listlineid '|| fg.created_from_list_line_id
                                   ||' fg line_index '|| fg.related_line_index);
        END LOOP; --fgline
      END LOOP; --cl

    END IF; --l_debug


    --need to mark the freegood lines if the PRG has been overridden
    --this means that one or more freegood lines have been deleted by the
    --calling application in which case all the adjustments and relationships
    --on the deleted freegood line have been deleted and the PRG adjustment
    --is marked with updated_flag = 'Y'
    --if there are such PRG adjustments overridden, then the freegood lines
    --created by the pricing engine need to be ignored and marked as
    --process_status = G_NOT_VALID and the freegood lines not deleted
    --need to be marked as process_status = G_STATUS_UNCHANGED. If there
    --are any changes to the setup, say the quantity on the remaining freegood
    --line has been increased, that will not apply to the freegood line that
    --has not been deleted as the PRG has been overridden
    --pricing_status_code needs to be set to G_NOT_VALID so that this does not get into OM's
    --update statement to update lines with UPDATE status

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Updated PRGs No. of passed-in fg lines updated '
                               || SQL%ROWCOUNT);
    END IF; --l_debug

    OPEN l_updated_prg_fg_cur;
    l_upd_engine_fg_index.DELETE;
    FETCH l_updated_prg_fg_cur
    BULK COLLECT INTO
    l_upd_engine_fg_index; --, l_upd_passedin_fg_index;
    CLOSE l_updated_prg_fg_cur;

    IF l_debug = FND_API.G_TRUE THEN
      --  QP_PREQ_GRP.engine_debug('Count. of passed-in fg lines '
      --  ||l_upd_passedin_fg_index.count);
      QP_PREQ_GRP.engine_debug('Count. of engine-created fg lines '
                               || l_upd_engine_fg_index.COUNT);
    END IF;


    IF l_upd_engine_fg_index.COUNT > 0 THEN
      --update the engine inserted fg line to G_NOT_VALID
      FORALL i IN l_upd_engine_fg_index.FIRST..l_upd_engine_fg_index.LAST
      UPDATE qp_npreq_lines_tmp SET
        pricing_status_code = G_NOT_VALID, process_status = G_NOT_VALID
      WHERE line_index = l_upd_engine_fg_index(i);


    --the following update will mark the overridden PRG's passed in
    --freegood lines as process_status = G_STATUS_UNCHANGED
    UPDATE qp_npreq_lines_tmp oldfg SET process_status = G_STATUS_UNCHANGED
  --fix for bug 2691794
                      , processed_flag = G_FREEGOOD_LINE
    WHERE oldfg.pricing_status_code IN (G_STATUS_UPDATED, G_STATUS_UNCHANGED)
    AND instr(oldfg.process_status, G_PROMO_GOODS_DISCOUNT || G_YES || G_STATUS_UPDATED) > 0;


    END IF; --l_upd_engine_fg_index


    IF l_Process_PRG = G_YES
      THEN
      --only if there are prg based modifiers
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        AND l_debug = FND_API.G_TRUE
        THEN
        FOR cl IN (SELECT newprg.line_index line_ind
                   , newprg.created_from_list_line_id
                   FROM qp_npreq_lines_tmp oldfgline
                   , qp_npreq_ldets_tmp newprg
                   WHERE --ldet.line_index = oldfgline.line_index
                   instr(oldfgline.process_status
                         , G_BUYLINE || newprg.line_index || G_PROMO_GOODS_DISCOUNT) > 0
                   AND newprg.applied_flag = G_YES
                   AND newprg.pricing_status_code = G_STATUS_NEW
                   AND instr(oldfgline.process_status
                             , G_PROMO_GOODS_DISCOUNT || newprg.created_from_list_line_id || G_PROMO_GOODS_DISCOUNT) > 0)
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('prg fgline: ind '|| cl.line_ind
                                     ||' prg '|| cl.created_from_list_line_id);
          END IF;
        END LOOP; --for cl
      END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE

      --the following update will update the process_status on freegood lines
      --identified from the previous identify_freegood_lines procedure
      --to G_STATUS_DELETED if the pricing engine has not created matching
      --PRG modifiers against its buy line
      UPDATE qp_npreq_lines_tmp oldfgline
      SET oldfgline.process_status = G_STATUS_DELETED
      WHERE NOT EXISTS (SELECT newprg.line_index
                        FROM qp_npreq_ldets_tmp newprg
                        --, qp_npreq_line_attrs_tmp newfgitem <-- commented out, sql repos
                        WHERE --G_REQUEST_TYPE_CODE = 'ONT'
                        newprg.pricing_status_code = G_STATUS_NEW
                        AND newprg.applied_flag = G_YES
                        AND instr(oldfgline.process_status
                                  , G_BUYLINE || newprg.line_index || G_PROMO_GOODS_DISCOUNT) > 0
                        AND newprg.created_from_list_line_type = G_PROMO_GOODS_DISCOUNT
                        AND instr(oldfgline.process_status
                                  , G_PROMO_GOODS_DISCOUNT || newprg.created_from_list_line_id || G_PROMO_GOODS_DISCOUNT) > 0)
        AND instr(oldfgline.process_status, G_FREEGOOD) > 0;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('updated delete prg lines rowcnt: '|| SQL%ROWCOUNT);

      END IF;
      FOR freegood IN l_compare_freegood_cur
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('In compare_cur '
                                   ||'     new_priced_qty '|| freegood.new_priced_quantity
                                   ||' old_priced_qty '|| freegood.old_priced_quantity
                                   ||' new_priced_uom '|| freegood.new_priced_uom_code
                                   ||' old_priced_uom '|| freegood.old_priced_uom_code
                                   ||' new_item '|| freegood.new_item ||' old_item '|| freegood.old_item
                                   ||' new_currency '|| freegood.new_CURRENCY_CODE
                                   ||' old_currency '|| freegood.old_CURRENCY_CODE
                                   ||' new_unit_price '|| freegood.new_unit_price
                                   ||' old_unit_price '|| freegood.old_unit_price
                                   ||' new_adj_price '|| freegood.new_ADJUSTED_UNIT_PRICE
                                   ||' old_adj_unit_price '|| freegood.old_ADJUSTED_UNIT_PRICE
                                   ||' new_pricelist_id '|| freegood.new_PRICE_LIST_HEADER_ID
                                   ||' old_pricelist_id '|| freegood.old_PRICE_LIST_HEADER_ID
                                   ||' new_rounding_fac '|| freegood.new_rounding_factor
                                   ||' old_rounding_fac '|| freegood.old_rounding_factor
                                   ||' old_price_flag '|| freegood.old_price_flag
                                   ||' new_price_flag '|| freegood.new_price_flag
                                   ||' old_line_index '|| freegood.old_line_index
                                   ||' new_line_index '|| freegood.new_line_index
                                   ||' old_line_id '|| freegood.old_line_id
                                   ||' old_process_status '|| freegood.old_list_line_id
                                   ||' newfgdis_list_line_id '|| freegood.newfgdis_list_line_id
                                   ||' newoperand '|| freegood.newfgdis_operand);
        END IF;

        --this is to get the old_list_line_id for bug 2970384
        l_oldfgdis_list_line_id := REPLACE(substr(freegood.old_list_line_id, 1,
                                                  -- need to subtract 1 from instr o/p to exclude the
                                                  --position of 'B' from the string 'BUYLINE'
                                                  instr(freegood.old_list_line_id, G_BUYLINE) - 1),
                                           G_FREEGOOD, '');
        l_old_operand := REPLACE(substr(freegood.old_list_line_id,
                                        instr(freegood.old_list_line_id, G_STATUS_UPDATED) + 7),
                                 G_PROMO_GOODS_DISCOUNT, '');

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(' The old_fg_list_line_id is '
                                   || l_oldfgdis_list_line_id
                                   ||' the old_operand is '|| l_old_operand);
        END IF; --l_debug


        IF ((nvl(freegood.new_priced_quantity, freegood.new_line_quantity) =
             nvl(freegood.old_priced_quantity, freegood.old_line_quantity))
            AND (nvl(freegood.new_priced_uom_code, freegood.new_line_uom_code) =
                 nvl(freegood.old_priced_uom_code, freegood.old_line_uom_code))
            AND (nvl(freegood.new_item, 'NULL') =
                 nvl(freegood.old_item, 'NULL'))
            AND (nvl(freegood.new_CURRENCY_CODE, 'NULL') =
                 nvl(freegood.old_CURRENCY_CODE, 'NULL'))
            AND (nvl(freegood.new_unit_price, 0) =
                 nvl(freegood.old_unit_price, 0)))
          --and (nvl(freegood.new_ADJUSTED_UNIT_PRICE, 0) =
          --nvl(freegood.old_ADJUSTED_UNIT_PRICE, 0))
          --and (nvl(freegood.new_PRICING_STATUS_CODE, 'NULL') =
          --nvl(freegood.old_PRICING_STATUS_CODE, 'NULL'))
          --and (nvl(freegood.new_START_DATE_ACTIVE_FIRST, sysdate) =
          --nvl(freegood.old_START_DATE_ACTIVE_FIRST, sysdate))
          --and (nvl(freegood.new_ACTIVE_DATE_FIRST_TYPE, 'NULL') =
          --nvl(freegood.old_ACTIVE_DATE_FIRST_TYPE, 'NULL'))
          --and (nvl(freegood.new_START_DATE_ACTIVE_SECOND, sysdate) =
          --nvl(freegood.old_START_DATE_ACTIVE_SECOND, sysdate))
          --and (nvl(freegood.new_ACTIVE_DATE_SECOND_TYPE, 'NULL') =
          --nvl(freegood.old_ACTIVE_DATE_SECOND_TYPE, 'NULL'))
          AND (nvl(freegood.new_PRICE_LIST_HEADER_ID,  - 1) =
               nvl(freegood.old_PRICE_LIST_HEADER_ID,  - 1))
          --and (nvl(freegood.new_list_line_id, -1) =
          --nvl(freegood.old_list_line_id, -1))
          --and (nvl(freegood.new_rounding_factor, 0) =
          --nvl(freegood.old_rounding_factor, 0)))
          --and (nvl(freegood.new_rounding_flag, 'NULL') =
          --nvl(freegood.old_rounding_flag, 'NULL')))
          --for bug 2970384 to compare if it the fglist_line_id is the same
          --and if the operand has not changed in the setup
          AND (nvl(l_oldfgdis_list_line_id, 0) =
               nvl(freegood.newfgdis_list_line_id, 0))
          AND (nvl(l_old_operand, 0) = nvl(freegood.newfgdis_operand, 0))
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('In PRG if data unchanged ');
          END IF;
          G_prg_unch_line_index_tbl(G_prg_unch_line_index_tbl.COUNT + 1) :=
          freegood.old_line_index;
          --fix for bug 2931437 this may not get populated if calculation does
          --not take place and raise a no_data_found populating the old
          --selling price just in case
          G_prg_unch_calc_price_tbl(G_prg_unch_line_index_tbl.COUNT) :=
          freegood.old_adjusted_unit_price;
          G_prg_unch_new_index_tbl(G_prg_unch_line_index_tbl.COUNT) :=
          freegood.new_line_index;
          --      G_prg_unch_adj_price_tbl(G_prg_unch_line_index_tbl.COUNT) :=
          --                freegood.old_ADJUSTED_UNIT_PRICE;
          G_prg_unch_line_id_tbl(G_prg_unch_line_index_tbl.COUNT) :=
          freegood.old_line_id;
          --this will be used in calculation
          G_prg_unch_line_ind_tbl(freegood.old_line_index) :=
          G_prg_unch_line_index_tbl.COUNT;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('if data unchanged: oldfg_lineindex '
                                     || G_prg_unch_line_index_tbl(G_prg_unch_line_index_tbl.COUNT) ||' selprice '
                                     || G_prg_unch_calc_price_tbl(G_prg_unch_line_index_tbl.COUNT));
          END IF; --l_debug

          l_prg_line_ind_tbl(l_prg_line_ind_tbl.COUNT + 1) :=
          freegood.old_line_index;
          l_prg_process_sts_tbl(l_prg_line_ind_tbl.COUNT) := G_STATUS_UNCHANGED;
          --                'OLD'||G_STATUS_UNCHANGED;
          l_prg_line_id_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_line_id;
          l_prg_price_flag_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_price_flag; -- Ravi
          l_prg_line_ind_tbl(l_prg_line_ind_tbl.COUNT + 1) := freegood.new_line_index;
          l_prg_process_sts_tbl(l_prg_line_ind_tbl.COUNT) := G_NOT_VALID;
          --                'NEW'||G_STATUS_UNCHANGED;
          l_prg_line_id_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_line_id;
          l_prg_price_flag_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_price_flag; -- Ravi
        ELSE --freegood cur
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('In PRG if data updated ');
          END IF;
          l_prg_line_ind_tbl(l_prg_line_ind_tbl.COUNT + 1) := freegood.old_line_index;
          l_prg_process_sts_tbl(l_prg_line_ind_tbl.COUNT) := G_NOT_VALID;
          l_prg_line_id_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_line_id;
          l_prg_price_flag_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_price_flag; -- Ravi
          l_prg_line_ind_tbl(l_prg_line_ind_tbl.COUNT + 1) := freegood.new_line_index;
          l_prg_process_sts_tbl(l_prg_line_ind_tbl.COUNT) := G_STATUS_UPDATED;
          l_prg_line_id_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_line_id;
          l_prg_price_flag_tbl(l_prg_line_ind_tbl.COUNT) := freegood.old_price_flag; -- Ravi
        END IF; --freegood cur
      END LOOP; --freegood

      IF l_prg_line_ind_tbl.COUNT > 0
        THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('prg details Here #1000');
        END IF; -- Bug No 4033618
        IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
          THEN
          FOR i IN l_prg_line_ind_tbl.FIRST..l_prg_line_ind_tbl.LAST
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('prg details: line_index '
                                       || l_prg_line_ind_tbl(i) ||' process_status '
                                       || l_prg_process_sts_tbl(i) ||' line_id '|| l_prg_line_id_tbl(i)
                                       || 'price flag ' || l_prg_price_flag_tbl(i));
            END IF;
          END LOOP; --l_prg_line_ind_tbl
        END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('passed in frg update '|| l_prg_line_ind_tbl.COUNT);

        END IF;
        FORALL i IN l_prg_line_ind_tbl.FIRST..l_prg_line_ind_tbl.LAST
        UPDATE qp_npreq_lines_tmp line SET
          line.process_status = l_prg_process_sts_tbl(i)
  --pricing_status_code needs to be set to G_NOT_VALID so that
  --this does not get into OM's
  --update statement to update lines with UPDATE status
          , line.pricing_status_code = decode(l_prg_process_sts_tbl(i), G_NOT_VALID
                                              , l_prg_process_sts_tbl(i), line.pricing_status_code)
  --fix for bug 2691794
          , line.processed_flag = G_FREEGOOD_LINE
          , line.line_id = l_prg_line_id_tbl(i)
          , line.price_flag = l_prg_price_flag_tbl(i) -- Ravi
        WHERE line.line_index = l_prg_line_ind_tbl(i);
      END IF; --l_prg_line_ind_tbl.COUNT

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('End process_prg');
      END IF;
    END IF; --l_process_prg

    --bug 2970368
    --IF G_REQUEST_TYPE_CODE <> 'ONT' THEN
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets

    -- Bug 3348208
    -- the following if condition for check_cust_view_flag is commented out so that
    -- update_prg_pricing_status is always run.  Previously, it was introduced only
    -- for ASO, not OM, but we discovered it needs to go for OM as well.
    --IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES THEN
    update_prg_pricing_status(x_return_status, x_return_status_text);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status_text := NULL;
  EXCEPTION
    WHEN PRG_Exception THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
  END Process_PRG;

  --This procedure compares the selling price of the old and new
  --unchanged freegood lines that resulted from the previous procedure
  --If the selling price changed, then it marks the newly created line
  --as UPDATED, else the passed in freegood line is marked as unchanged
  PROCEDURE Update_PRG_Process_status(x_return_status OUT NOCOPY VARCHAR2,
                                      x_return_status_text OUT NOCOPY VARCHAR2) IS
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Update_PRG_Process_status ';

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Update_PRG_Process_status');

    END IF;
    IF G_prg_unch_line_index_tbl.COUNT > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('unchanged prg update '
                                 || G_prg_unch_line_index_tbl.COUNT);

      END IF;
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        FOR j IN G_prg_unch_line_index_tbl.FIRST..G_prg_unch_line_index_tbl.LAST
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Unchanged details unch line_index '
                                     || G_prg_unch_line_index_tbl(j) ||' new line_index '
                                     || G_prg_unch_new_index_tbl(j) ||' adj_unit_price '
                                     || G_prg_unch_calc_price_tbl(j));
          END IF;
        END LOOP; --G_prg_unch_line_index_tbl
      END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE

      FORALL i IN G_prg_unch_line_index_tbl.FIRST..G_prg_unch_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp line SET line.process_status =
          --fix for bug 2831270
        decode(line.adjusted_unit_price, G_prg_unch_calc_price_tbl(i),
               G_NOT_VALID, G_STATUS_UPDATED)
  --Calling application looks at pricing_status_code this also needs to be updated
  --pricing_status_code needs to be set to G_NOT_VALID
  --so that this does not get into OM's
  --update statement to update lines with UPDATE status
        , line.pricing_status_code = decode(line.adjusted_unit_price,
                                            G_prg_unch_calc_price_tbl(i), G_NOT_VALID, line.pricing_status_code)
        , line.line_id = G_prg_unch_line_id_tbl(i)
      WHERE line.line_index = G_prg_unch_new_index_tbl(i)
      RETURNING line.process_status BULK COLLECT INTO G_prg_unch_process_sts_tbl;

      FORALL i IN G_prg_unch_line_index_tbl.FIRST..G_prg_unch_line_index_tbl.LAST
      UPDATE qp_npreq_lines_tmp line SET line.process_status =
        decode(G_prg_unch_process_sts_tbl(i), G_NOT_VALID
               , G_STATUS_UNCHANGED, G_STATUS_UPDATED, G_NOT_VALID)
  --pricing_status_code needs to be set
  --to G_NOT_VALID so that this does not get into OM's
  --update statement to update lines with UPDATE status
        , line.pricing_status_code = decode(G_prg_unch_process_sts_tbl(i)
                                            , G_NOT_VALID, line.pricing_status_code, G_STATUS_UPDATED, G_NOT_VALID)
      WHERE line.process_status = 'OLD' || G_STATUS_UNCHANGED
      AND line.line_index = G_prg_unch_line_index_tbl(i);
    END IF; --G_prg_unch_line_index_tbl.COUNT

    --bug 2970368
    --IF G_REQUEST_TYPE_CODE <> 'ONT' THEN
    --bug 3085453 handle pricing availability UI
    -- they pass reqtype ONT and insert adj into ldets
    IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> G_YES THEN
      update_prg_pricing_status(x_return_status, x_return_status_text);
    END IF; --G_REQUEST_TYPE_CODE

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Update_PRG_Process_status');

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
  END Update_PRG_Process_status;

  --This procedure will populate g_buyline_price_flag
  --This information will be used to select out-of-phase adjustments
  --from oe tables or engine selected based on the price_flag on
  --the buy line for OID/PRG's child discounts
  PROCEDURE Populate_buy_line_price_flag(x_return_status OUT NOCOPY VARCHAR2,
                                         x_return_status_text OUT NOCOPY VARCHAR2) IS

  -- 3493716: added prg.line_detail_index to cursor
  CURSOR l_buyline_price_flag_cur IS
    SELECT /*+ ORDERED USE_NL(buyline prg dis)*/
    dis.created_from_list_line_id, prg.line_detail_index, buyline.price_flag, 'Y' is_ldet, dis.line_index
    FROM qp_npreq_rltd_lines_tmp rltd, qp_npreq_lines_tmp buyline
         , qp_npreq_ldets_tmp prg, qp_npreq_ldets_tmp dis
    WHERE rltd.pricing_status_code = G_STATUS_NEW
    AND rltd.relationship_type_code = G_GENERATED_LINE
    AND buyline.line_index = rltd.line_index
    AND prg.line_detail_index = rltd.line_detail_index
    AND prg.created_from_list_line_type IN
            (G_OTHER_ITEM_DISCOUNT, G_PROMO_GOODS_DISCOUNT)
    AND prg.pricing_status_code = G_STATUS_NEW
    AND dis.line_detail_index = rltd.related_line_detail_index
    AND dis.pricing_status_code = G_STATUS_NEW;

  I PLS_INTEGER;
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Populate_buy_line_price_flag';
  BEGIN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Populate_buy_line_price_flag');

    END IF;
    --G_buyline_price_flag.delete;
    G_BUYLINE_INDEXES_FOR_LINE_ID.DELETE;

    IF l_debug = FND_API.G_TRUE THEN
      FOR c1 IN (SELECT line_detail_index, related_line_detail_index, line_index
                 FROM qp_npreq_rltd_lines_tmp WHERE pricing_status_code = G_STATUS_NEW
                 AND relationship_type_code = G_GENERATED_LINE)
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('loop linedtl '|| c1.line_detail_index ||' rltddtl '
                                   || c1.related_line_detail_index ||' lineind '|| c1.line_index);
        END IF;
        FOR c2 IN (SELECT line_index, line_detail_index FROM qp_npreq_ldets_tmp
                   WHERE line_detail_index = c1.line_detail_index
                   AND pricing_status_code = G_STATUS_NEW
                   AND created_from_list_line_type IN
                   (G_OTHER_ITEM_DISCOUNT, G_PROMO_GOODS_DISCOUNT))
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('loop ldet linedtl '|| c2.line_detail_index);
          END IF;
        END LOOP; --c2
      END LOOP; --c1
    END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE

    FOR buyline IN l_buyline_price_flag_cur
      LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('In buyline loop list_line_id '
                                 || buyline.created_from_list_line_id
                                 ||' w/PRG ldet '|| buyline.line_detail_index -- 3493716
                                 ||' price_flag '|| buyline.price_flag
                                 ||' get line_index '|| buyline.line_index);
      END IF;
      --G_buyline_price_flag(buyline.created_from_list_line_id) := buyline.price_flag;
      -- bug 3721860 - G_BUYLINE_INDEXES_FOR_LINE_ID stores the info like - ,line_index1,line_index2,line_index3, - for a line_id
      IF G_BUYLINE_INDEXES_FOR_LINE_ID.EXISTS(buyline.created_from_list_line_id) THEN
        G_BUYLINE_INDEXES_FOR_LINE_ID(buyline.created_from_list_line_id) := G_BUYLINE_INDEXES_FOR_LINE_ID(buyline.created_from_list_line_id) || buyline.line_index || ',';
      ELSE
        G_BUYLINE_INDEXES_FOR_LINE_ID(buyline.created_from_list_line_id) := ',' || buyline.line_index || ',';
      END IF;
    END LOOP;
    /*
  IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
    i := G_buyline_price_flag.FIRST;
    WHILE i IS NOT NULL
    LOOP
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In g_buyline loop list_line_id '
      ||I||' price_flag '||G_buyline_price_flag(I));
      END IF;
      I := G_buyline_price_flag.NEXT(I);
    END LOOP;--while
  END IF;--QP_PREQ_GRP.G_DEBUG_ENGINE

  OPEN l_buyline_price_flag_cur;
  FETCH l_buyline_price_flag_cur BULK COLLECT INTO
        G_buyline_list_line_id, G_buyline_price_flag;
  CLOSE l_buyline_price_flag_cur;
UPDATE qp_npreq_ldets_tmp freegood_dis set buy_line_price_flag =
    (select buyline.price_flag
    from qp_npreq_rltd_lines_tmp rl, qp_npreq_lines_tmp buyline
    where rl.pricing_status_code = G_STATUS_NEW
    and rl.relationship_type_code = G_GENERATED_LINE
    and rl.related_line_detail_index = freegood_dis.line_detail_index
    and buyline.line_index = rl.line_index)
where freegood_dis.pricing_status_code = G_STATUS_NEW
and freegood_dis.applied_flag = G_YES
and freegood_dis.created_from_list_line_type in (G_OTHER_ITEM_DISCOUNT,
                                                 G_PROMO_GOODS_DISCOUNT)
and freegood_dis.line_detail_index in (select rltd.related_line_detail_index
    from qp_npreq_rltd_lines_tmp rltd
    where rltd.pricing_status_code = G_STATUS_NEW
    and rltd.relationship_type_code = G_GENERATED_LINE
    and rltd.line_detail_index = freegood_dis.line_detail_index);
*/

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('End Populate_buy_line_price_flag');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in '|| l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.Engine_debug(x_return_status_text);
      END IF;
  END Populate_buy_line_price_flag;

  -- 3721860: Added a parameter p_line_index
  FUNCTION Get_buy_line_price_flag(p_list_line_id IN NUMBER,
                                   p_line_index IN NUMBER)
  RETURN VARCHAR2 IS

  i PLS_INTEGER;
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Get_buy_line_price_flag';
  l_count NUMBER;
  BEGIN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Begin Get_buy_line_price_flag, p_list_line_id p_line_index: '|| p_list_line_id || ' ' || p_line_index);

    END IF;
    IF G_BUYLINE_INDEXES_FOR_LINE_ID.COUNT > 0 THEN
      IF G_BUYLINE_INDEXES_FOR_LINE_ID.EXISTS(p_list_line_id) THEN
        l_count := instr(G_BUYLINE_INDEXES_FOR_LINE_ID(p_list_line_id), ',' || p_line_index || ',');
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('G_BUYLINE_INDEXES_FOR_LINE_ID(p_list_line_id) ' || G_BUYLINE_INDEXES_FOR_LINE_ID(p_list_line_id));
          QP_PREQ_GRP.engine_debug('l_count ' || l_count);
        END IF;
        IF l_count > 0 THEN
          RETURN 'Y';
        ELSE
          RETURN NULL;
        END IF;
      ELSE
        RETURN NULL;
      END IF; --G_BUYLINE_INDEXES_FOR_LINE_ID.EXISTS
    ELSE
      RETURN NULL;
    END IF; --G_BUYLINE_INDEXES_FOR_LINE_ID.count

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.Engine_debug('Exception in '|| l_routine ||' '|| SQLERRM);
      END IF;
      RETURN NULL;
  END Get_buy_line_price_flag;


  /*****************************************************************
--------------------Coupon Issue Processing-----------------------
*****************************************************************/
  --This procedure will call QP_Process_Other_Benefits_PVT.process_coupon_issue
  --for every coupon issue modifier applied by the search engine
  --We do not want to do this in GRP because, GRP would generate coupons
  --during every reprice. During reprice, new coupons should not be
  --generated for existing adjustments

  PROCEDURE Process_coupon_issue(p_pricing_event IN VARCHAR2,
                                 p_simulation_flag IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_status_text OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_list_lines_cur IS
    SELECT /*+ index (ldets qp_preq_ldets_tmp_N2) */
      created_from_list_line_id
      , line_quantity
      , line_detail_index
      , pricing_phase_id
    FROM   qp_npreq_ldets_tmp ldets
    WHERE  created_from_list_line_type = G_COUPON_ISSUE
    AND applied_flag = G_YES
    /*
--you don't need to match the phase as this will be called after cleanup
--and by the time adjustments w/b picked up from oe_price_adj and ldets
--from the right phases
AND    pricing_phase_id in (select ph.pricing_phase_id
  from qp_event_phases evt , qp_pricing_phases ph, qp_npreq_lines_tmp line
  where ph.pricing_phase_id = evt.pricing_phase_id
  and instr(p_pricing_event,evt.pricing_event_code||',') > 0
  and line.line_index = ldets.line_index
  and (line.price_flag = G_YES
  or (line.price_flag = G_PHASE
  and ph.freeze_override_flag = G_YES)
*/
    --  AND    LINE_INDEX = p_line_index
    --  AND    ASK_FOR_FLAG IN (G_YES,G_NO)
    AND pricing_status_code = G_STATUS_NEW
    AND process_code = G_STATUS_NEW;

  Coupon_Exception EXCEPTION;

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    FOR ldet IN l_get_list_lines_cur
      LOOP
      QP_COUPON_PVT.PROCESS_COUPON_ISSUE(
                                         p_line_detail_index => ldet.line_detail_index,
                                         p_pricing_phase_id => ldet.pricing_phase_id,
                                         p_line_quantity => ldet.line_quantity,
                                         p_simulation_flag => p_simulation_flag,
                                         x_return_status => x_return_status,
                                         x_return_status_txt => x_return_status_text);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE Coupon_Exception;
      END IF; --x_return_status
    END LOOP; --get_list_lines_cur

  EXCEPTION
    WHEN Coupon_Exception THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in QP_PREQ_PUB.Process_coupon_issue '|| x_return_status_text);
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'Exception in QP_PREQ_PUB.Process_coupon_issue '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(x_return_status_text);
      END IF;
  END Process_coupon_issue;

  --This procedure will update the line_quantity on ldets
  --in case of a recurring break to reflect the right quantity
  PROCEDURE Update_Recurring_Quantity(x_return_status OUT NOCOPY VARCHAR2,
                                      x_return_status_text OUT NOCOPY VARCHAR2) IS

  --[julin/pbperf] tuned to use QP_PREQ_LDETS_TMP_N2
  CURSOR l_get_recurring_cur IS
    SELECT /*+ ORDERED index(ldet QP_PREQ_LDETS_TMP_N2) */ ldet.line_detail_index
    , lattr.context
    , lattr.attribute
    , lattr.value_from
    , lattr.setup_value_from
    , ldet.modifier_level_code
  --  , ldet.line_detail_index
    , ldet.line_quantity
    , ldet.group_quantity
    , ldet.group_amount
    , ldet.created_from_list_line_type
    , ldet.operand_value
    , qpl.operand
    , ldet.benefit_qty
    , ldet.accrual_flag
    , qpl.accrual_conversion_rate
    , qpl.estim_accrual_rate
  --  , qpl.benefit_qty
    FROM qp_npreq_ldets_tmp ldet, qp_npreq_line_attrs_tmp lattr, qp_list_lines qpl
    WHERE ldet.pricing_phase_id > 1
    AND ldet.pricing_status_code = G_STATUS_NEW
    AND ldet.line_index > -1
    AND ldet.created_from_list_line_type IN ('DIS', 'SUR', 'FREIGHT_CHARGE',
                                             'CIE', 'PBH', 'IUE', 'TSN')
    AND ldet.price_break_type_code = G_RECURRING_BREAK
    AND nvl(ldet.created_from_list_type_code, 'NULL') NOT IN ('PRL', 'AGR')
    AND lattr.line_detail_index = ldet.line_detail_index
    AND lattr.context = G_PRIC_VOLUME_CONTEXT
    AND qpl.list_line_id = ldet.created_from_list_line_id
    AND qpl.automatic_flag = 'N' ;  -- this procedure is needed only for manual modifiers since for automatic modifiers will be calculated in QPXGPREB

  l_recur_dtl_index_tbl QP_PREQ_GRP.number_type;
  l_recur_tot_benefit_qty_tbl QP_PREQ_GRP.number_type;
  l_recur_benefit_qty_tbl QP_PREQ_GRP.number_type; --Bug 2804053
  l_recur_benefit_qty NUMBER;
  l_recur_base_qty NUMBER;
  l_recur_qualifying_qty NUMBER;
  l_routine VARCHAR2(100) := 'QP_PREQ_PUB.Update_recurring_quantity';

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    l_recur_dtl_index_tbl.DELETE;
    l_recur_tot_benefit_qty_tbl.DELETE;

    FOR recurring IN l_get_recurring_cur
      LOOP
      IF l_debug = FND_API.G_TRUE THEN -- shu 2702384
        QP_PREQ_GRP.engine_debug ('------in l_get_recurring_cur loop------');
      END IF; -- END IF l_debug

      IF recurring.created_from_list_line_type IN (G_DISCOUNT, G_SURCHARGE,
                                                   G_PROMO_GOODS_DISCOUNT, G_COUPON_ISSUE) THEN
        l_recur_dtl_index_tbl(l_recur_dtl_index_tbl.COUNT + 1) :=
        recurring.line_detail_index;
        IF recurring.created_from_list_line_type IN (G_DISCOUNT, G_SURCHARGE) THEN
          -- gets the engine calculated value from the grp calculation engine which is wrong
          l_recur_benefit_qty := recurring.operand_value; -- reverted fix 2747387 for bug 4127734
          --l_recur_benefit_qty := recurring.operand; -- get the original value bug# 2747387
        ELSIF recurring.created_from_list_line_type = G_PROMO_GOODS_DISCOUNT THEN
          l_recur_benefit_qty := recurring.benefit_qty;
        ELSIF recurring.created_from_list_line_type = G_COUPON_ISSUE THEN
          l_recur_benefit_qty := 1;
        END IF; --recurring.created_from_list_line_type

        IF l_debug = FND_API.G_TRUE THEN -- shu 2702384
          QP_PREQ_GRP.engine_debug ('l_recur_benefit_qty' || l_recur_benefit_qty);
        END IF;

        IF recurring.modifier_level_code IN (G_LINE_LEVEL, G_ORDER_LEVEL) THEN
          l_recur_qualifying_qty := recurring.line_quantity;
        ELSE
          IF recurring.attribute = G_QUANTITY_ATTRIBUTE THEN
            --l_recur_qualifying_qty := recurring.group_quantity; -- SHU this is null
            l_recur_qualifying_qty := nvl(recurring.group_quantity, recurring.line_quantity) ; -- 2388011, SHU FIX.
          ELSE
            --l_recur_qualifying_qty := recurring.group_amount; -- SHU, wrong since group_amount is per_unit value
            l_recur_qualifying_qty := recurring.line_quantity; -- 2388011, SHU FIX.
          END IF; --recurring.attribute
        END IF; --recurring.modifier_level_code

        l_recur_base_qty := recurring.setup_value_from;

        l_recur_tot_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT) :=
        TRUNC((l_recur_qualifying_qty / l_recur_base_qty))
        * l_recur_benefit_qty;
        --Bug 2804053
        IF recurring.accrual_flag = G_YES THEN
          l_recur_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT) :=
          l_recur_tot_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT) *
          1 / nvl(recurring.accrual_conversion_rate, 1) *
          nvl(recurring.estim_accrual_rate, 100) / 100;
        ELSE
          l_recur_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT) :=
          recurring.benefit_qty;
        END IF;

        IF l_debug = FND_API.G_TRUE THEN -- shu 2702384
          QP_PREQ_GRP.engine_debug ('l_recur_qualifying_qty' || l_recur_qualifying_qty);
          QP_PREQ_GRP.engine_debug ('l_recur_base_qty' || l_recur_base_qty);
          QP_PREQ_GRP.engine_debug ('l_recur_tot_benefit_qty' || l_recur_tot_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT));
          QP_PREQ_GRP.engine_debug ('l_recur_benefit_qty' || l_recur_benefit_qty_tbl(l_recur_dtl_index_tbl.COUNT));
        END IF; -- END IF l_debug

      END IF; --recurring.created_from_list_line_type
    END LOOP; --recurring

    IF l_recur_dtl_index_tbl.COUNT > 0 THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Updating recurring qty '|| l_recur_dtl_index_tbl.COUNT);
      END IF;
      FORALL i IN l_recur_dtl_index_tbl.FIRST .. l_recur_dtl_index_tbl.LAST
      UPDATE qp_npreq_ldets_tmp recur SET operand_value =  -- shu fix 2702384
                             l_recur_tot_benefit_qty_tbl(i)
                            , benefit_qty = l_recur_benefit_qty_tbl(i) --Bug 2804053
      WHERE recur.line_detail_index = l_recur_dtl_index_tbl(i);
    END IF; --l_recur_dtl_index_tbl.COUNT
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Exception in '|| x_return_status_text);
      END IF;
  END Update_recurring_quantity;

  --added by yangli for Java Engine
  --This is for debugging purposes
  PROCEDURE Populate_Output_INT(x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

  /*
INDX,QP_PREQ_PUB.populate_output_int.l_lines_cur,- No Index Used -,NA,NA
*/
  CURSOR l_lines_cur IS
    SELECT LINE_INDEX,
           LINE_ID,
           LINE_TYPE_CODE,
           LINE_QUANTITY,
           LINE_UOM_CODE,
           LINE_UNIT_PRICE,  --shu_latest
           PRICED_QUANTITY,
           UOM_QUANTITY,
           PRICED_UOM_CODE,
           CURRENCY_CODE,
           UNIT_PRICE,
           PERCENT_PRICE,
           PARENT_PRICE,
           PARENT_QUANTITY,
           PARENT_UOM_CODE,
           PRICE_FLAG,
           ADJUSTED_UNIT_PRICE,
           UPDATED_ADJUSTED_UNIT_PRICE,
           PROCESSING_ORDER,
           PROCESSED_CODE,
           PROCESSED_FLAG,
           PRICING_STATUS_CODE,
           PRICING_STATUS_TEXT,
           HOLD_CODE,
           HOLD_TEXT,
           PRICE_REQUEST_CODE,
           PRICING_EFFECTIVE_DATE,
           PRICE_LIST_HEADER_ID,
           PROCESS_STATUS,
           CATCHWEIGHT_QTY,
           ACTUAL_ORDER_QUANTITY,
           ORDER_UOM_SELLING_PRICE
    FROM   QP_INT_LINES;

  /*
INDX,QP_PREQ_GRP.populate_output_int.l_ldets_cur,QP_LIST_LINES_PK,LIST_LINE_ID,1
INDX,QP_PREQ_GRP.populate_output_int.l_ldets_cur,QP_INT_LDETS_N4,PRICING_STATUS_CODE,1
INDX,QP_PREQ_GRP.populate_output_int.l_ldets_cur,QP_LIST_HEADERS_B_PK,LIST_HEADER_ID,1
*/
  CURSOR l_ldets_cur(p_line_index NUMBER) IS
    SELECT /*+ ORDERED USE_NL(A B C) l_ldets_cur */
           a.LINE_DETAIL_INDEX,
           a.LINE_DETAIL_TYPE_CODE,
           a.LINE_INDEX,
           a.CREATED_FROM_LIST_HEADER_ID LIST_HEADER_ID,
           a.CREATED_FROM_LIST_LINE_ID   LIST_LINE_ID,
           a.CREATED_FROM_LIST_LINE_TYPE LIST_LINE_TYPE_CODE,
           a.PRICE_BREAK_TYPE_CODE,
           a.LINE_QUANTITY,
           a.ADJUSTMENT_AMOUNT,
           a.AUTOMATIC_FLAG,
           a.PRICING_PHASE_ID,
           a.OPERAND_CALCULATION_CODE,
           a.OPERAND_VALUE,
           a.PRICING_GROUP_SEQUENCE,
           a.CREATED_FROM_LIST_TYPE_CODE,
           a.APPLIED_FLAG,
           a.PRICING_STATUS_CODE,
           a.PRICING_STATUS_TEXT,
           a.LIMIT_CODE,
           a.LIMIT_TEXT,
           a.LIST_LINE_NO,
           a.GROUP_QUANTITY,
           a.UPDATED_FLAG,
           a.PROCESS_CODE,
           a.CALCULATION_CODE,
           a.PRICE_ADJUSTMENT_ID,
           b.SUBSTITUTION_VALUE SUBSTITUTION_VALUE_TO,
           b.SUBSTITUTION_ATTRIBUTE,
           b.ACCRUAL_FLAG,
           a.modifier_level_code,
           b.ESTIM_GL_VALUE,
           b.ACCRUAL_CONVERSION_RATE,
           --Pass throuh components
           b.OVERRIDE_FLAG,
           b.PRINT_ON_INVOICE_FLAG,
           b.INVENTORY_ITEM_ID,
           b.ORGANIZATION_ID,
           b.RELATED_ITEM_ID,
           b.RELATIONSHIP_TYPE_ID,
           b.ESTIM_ACCRUAL_RATE,
           b.EXPIRATION_DATE,
           b.BENEFIT_PRICE_LIST_LINE_ID,
           b.RECURRING_FLAG,
           b.BENEFIT_LIMIT,
           b.CHARGE_TYPE_CODE,
           b.CHARGE_SUBTYPE_CODE,
           a.BENEFIT_QTY,  --bug 2804053
           b.BENEFIT_UOM_CODE,
           b.PRORATION_TYPE_CODE,
           b.INCLUDE_ON_RETURNS_FLAG,
           b.REBATE_TRANSACTION_TYPE_CODE,
           b.NUMBER_EXPIRATION_PERIODS,
           b.EXPIRATION_PERIOD_UOM,
           b.COMMENTS,
           a.ORDER_QTY_OPERAND,
           a.ORDER_QTY_ADJ_AMT
    FROM  QP_INT_LDETS a,
          QP_LIST_LINES     b
    WHERE a.line_index = p_line_index
        AND a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
        AND   a.PRICING_STATUS_CODE = G_STATUS_NEW;

  BEGIN

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('---------------------------------------------------');
    END IF;

    FOR l_line IN l_lines_cur LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('----price line info--------------------------------');
        QP_PREQ_GRP.engine_debug('---------------------------------------------------');
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('*LINE_INDEX :='|| l_line.LINE_INDEX);
        QP_PREQ_GRP.engine_debug('*LINE_ID    :='|| l_line.LINE_ID);
        QP_PREQ_GRP.engine_debug('LINE_TYPE_CODE :='|| l_line.LINE_TYPE_CODE);
        QP_PREQ_GRP.engine_debug('UOM_QUANTITY :='|| l_line.UOM_QUANTITY);
        QP_PREQ_GRP.engine_debug('CURRENCY_CODE :='|| l_line.CURRENCY_CODE);
        QP_PREQ_GRP.engine_debug('PRICED_QUANTITY :='|| l_line.PRICED_QUANTITY);
        QP_PREQ_GRP.engine_debug('PRICED_UOM_CODE :='|| l_line.PRICED_UOM_CODE);
        QP_PREQ_GRP.engine_debug('*UNIT_PRICE :='|| l_line.UNIT_PRICE);
        QP_PREQ_GRP.engine_debug('*PRICE_LIST_ID :='|| l_line.PRICE_LIST_HEADER_ID);
        QP_PREQ_GRP.engine_debug('LINE_QUANTITY:=' || l_line.LINE_QUANTITY);
        QP_PREQ_GRP.engine_debug('LINE_UOM_CODE:=' || l_line.LINE_UOM_CODE);
        QP_PREQ_GRP.engine_debug('LINE_UNIT_PRICE:=' || l_line.LINE_UNIT_PRICE); -- shu_latest
        QP_PREQ_GRP.engine_debug('PERCENT_PRICE :='|| l_line.PERCENT_PRICE);
        QP_PREQ_GRP.engine_debug('*ADJUSTED_UNIT_PRICE :='|| l_line.ADJUSTED_UNIT_PRICE);
        QP_PREQ_GRP.engine_debug('PARENT_PRICE :='|| l_line.PARENT_PRICE);
        QP_PREQ_GRP.engine_debug('PARENT_QUANTITY :='|| l_line.PARENT_QUANTITY);
        QP_PREQ_GRP.engine_debug('PARENT_UOM_CODE :='|| l_line.PARENT_UOM_CODE);
        QP_PREQ_GRP.engine_debug('processed_code :='|| l_line.processed_code);
        QP_PREQ_GRP.engine_debug('processed_flag :='|| l_line.processed_flag);
        QP_PREQ_GRP.engine_debug('Price Flag :='|| l_line.price_flag);
        QP_PREQ_GRP.engine_debug('*STATUS_CODE :='|| l_line.PRICING_STATUS_CODE);
        QP_PREQ_GRP.engine_debug('*STATUS_TEXT :='|| substr(l_line.PRICING_STATUS_TEXT, 1, 2000));
        QP_PREQ_GRP.engine_debug('HOLD_CODE := '|| l_line.HOLD_CODE);
        QP_PREQ_GRP.engine_debug('HOLD_TEXT := '|| substr(l_line.HOLD_TEXT, 1, 240));
        QP_PREQ_GRP.engine_debug('PRICE_REQUEST_CODE := '|| l_line.PRICE_REQUEST_CODE);
        QP_PREQ_GRP.engine_debug('PRICING_DATE := '|| l_line.PRICING_EFFECTIVE_DATE);
        QP_PREQ_GRP.engine_debug('*PROCESS_STATUS :='|| l_line.PROCESS_STATUS);
        QP_PREQ_GRP.engine_debug('*CATCHWEIGHT_QTY :='|| l_line.CATCHWEIGHT_QTY);
        QP_PREQ_GRP.engine_debug('*ACTUAL_ORDER_QTY :='|| l_line.ACTUAL_ORDER_QUANTITY);
        QP_PREQ_GRP.engine_debug('*ORDER_UOM_SELLING_PRICE :='|| l_line.ORDER_UOM_SELLING_PRICE);
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('---------------------------------------------------');

      END IF;
      --Populate Line detail
      FOR l_dets IN l_ldets_cur(l_line.LINE_INDEX) LOOP

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('-----------Line detail Info -----------------------');
          QP_PREQ_GRP.engine_debug('---------------------------------------------------');
          QP_PREQ_GRP.engine_debug('*LINE_DETAIL_INDEX :='|| l_dets.LINE_DETAIL_INDEX);
          QP_PREQ_GRP.engine_debug('LINE_DETAIL_TYPE_CODE:=' || l_dets.LINE_DETAIL_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('*LINE_INDEX:=' || l_dets.LINE_INDEX);
          QP_PREQ_GRP.engine_debug('*PROCESS_CODE:=' || l_dets.PROCESS_CODE);
          QP_PREQ_GRP.engine_debug('*CALCULATION_CODE:=' || l_dets.CALCULATION_CODE);
          QP_PREQ_GRP.engine_debug('*LIST_HEADER_ID:=' || l_dets.LIST_HEADER_ID);
          QP_PREQ_GRP.engine_debug('*LIST_LINE_ID:=' || l_dets.LIST_LINE_ID);
          QP_PREQ_GRP.engine_debug('*PRICE_ADJUSTMENT_ID:=' || l_dets.PRICE_ADJUSTMENT_ID);
          QP_PREQ_GRP.engine_debug('LIST_LINE_TYPE_CODE:=' || l_dets.LIST_LINE_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('SUBSTITUTION_TO:=' || l_dets.SUBSTITUTION_VALUE_TO);
          QP_PREQ_GRP.engine_debug('LINE_QUANTITY :='|| l_dets.LINE_QUANTITY);
          QP_PREQ_GRP.engine_debug('*ADJUSTMENT_AMOUNT :='|| l_dets.ADJUSTMENT_AMOUNT);
          QP_PREQ_GRP.engine_debug('*AUTOMATIC_FLAG    :='|| l_dets.AUTOMATIC_FLAG);
          QP_PREQ_GRP.engine_debug('APPLIED_FLAG      :='|| l_dets.APPLIED_FLAG);
          QP_PREQ_GRP.engine_debug('UPDATED_FLAG      :='|| l_dets.UPDATED_FLAG);
          QP_PREQ_GRP.engine_debug('PRICING_GROUP_SEQUENCE :='|| l_dets.PRICING_GROUP_SEQUENCE);
          QP_PREQ_GRP.engine_debug('CREATED_FROM_LIST_TYPE_CODE:=' || l_dets.CREATED_FROM_LIST_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('PRICE_BREAK_TYPE_CODE :='|| l_dets.PRICE_BREAK_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('*OVERRIDE_FLAG   :='|| l_dets.override_flag);
          QP_PREQ_GRP.engine_debug('PRINT_ON_INVOICE_FLAG :='|| l_dets.print_on_invoice_flag);
          QP_PREQ_GRP.engine_debug('PRICING_PHASE_ID :='|| l_dets.PRICING_PHASE_ID);
          QP_PREQ_GRP.engine_debug('*OPERAND_CALCULATION_CODE :='|| l_dets.OPERAND_CALCULATION_CODE);
          QP_PREQ_GRP.engine_debug('*OPERAND_VALUE :='|| l_dets.OPERAND_VALUE);
          QP_PREQ_GRP.engine_debug('*ORDER_QTY_OPERAND :='|| l_dets.ORDER_QTY_OPERAND);
          QP_PREQ_GRP.engine_debug('*ORDER_QTY_ADJ_AMT :='|| l_dets.ORDER_QTY_ADJ_AMT);
          QP_PREQ_GRP.engine_debug('*STATUS_CODE:=' || l_dets.PRICING_STATUS_CODE);
          QP_PREQ_GRP.engine_debug('*STATUS_TEXT:=' || substr(l_dets.PRICING_STATUS_TEXT, 1, 240));
          QP_PREQ_GRP.engine_debug('SUBSTITUTION_ATTRIBUTE:=' || l_dets.SUBSTITUTION_ATTRIBUTE);
          QP_PREQ_GRP.engine_debug('ACCRUAL_FLAG:=' || l_dets.ACCRUAL_FLAG);
          QP_PREQ_GRP.engine_debug('LIST_LINE_NO:=' || l_dets.LIST_LINE_NO);
          QP_PREQ_GRP.engine_debug('ESTIM_GL_VALUE:=' || l_dets.ESTIM_GL_VALUE);
          QP_PREQ_GRP.engine_debug('ACCRUAL_CONVERSION_RATE:=' || l_dets.ACCRUAL_CONVERSION_RATE);
        END IF;
        --Pass throuh components
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('OVERRIDE_FLAG:=' || l_dets.OVERRIDE_FLAG);
          QP_PREQ_GRP.engine_debug('INVENTORY_ITEM_ID:=' || l_dets.INVENTORY_ITEM_ID);
          QP_PREQ_GRP.engine_debug('ORGANIZATION_ID:=' || l_dets.ORGANIZATION_ID);
          QP_PREQ_GRP.engine_debug('RELATED_ITEM_ID:=' || l_dets.RELATED_ITEM_ID);
          QP_PREQ_GRP.engine_debug('RELATIONSHIP_TYPE_ID:=' || l_dets.RELATIONSHIP_TYPE_ID);
          QP_PREQ_GRP.engine_debug('ESTIM_ACCRUAL_RATE:=' || l_dets.ESTIM_ACCRUAL_RATE);
          QP_PREQ_GRP.engine_debug('EXPIRATION_DATE:=' || l_dets.EXPIRATION_DATE);
          QP_PREQ_GRP.engine_debug('BENEFIT_PRICE_LIST_LINE_ID:=' || l_dets.BENEFIT_PRICE_LIST_LINE_ID);
          QP_PREQ_GRP.engine_debug('RECURRING_FLAG:=' || l_dets.RECURRING_FLAG);
          QP_PREQ_GRP.engine_debug('BENEFIT_LIMIT:=' || l_dets.BENEFIT_LIMIT);
          QP_PREQ_GRP.engine_debug('CHARGE_TYPE_CODE:=' || l_dets.CHARGE_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('CHARGE_SUBTYPE_CODE:=' || l_dets.CHARGE_SUBTYPE_CODE);
          QP_PREQ_GRP.engine_debug('BENEFIT_QTY:=' || l_dets.BENEFIT_QTY);
          QP_PREQ_GRP.engine_debug('BENEFIT_UOM_CODE:=' || l_dets.BENEFIT_UOM_CODE);
          QP_PREQ_GRP.engine_debug('PRORATION_TYPE_CODE:=' || l_dets.PRORATION_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('INCLUDE_ON_RETURNS_FLAG :='|| l_dets.INCLUDE_ON_RETURNS_FLAG);
          QP_PREQ_GRP.engine_debug('MODIFIER_LEVEL_CODE :='|| l_dets.MODIFIER_LEVEL_CODE);
          QP_PREQ_GRP.engine_debug('GROUP VALUE :='|| l_dets.GROUP_QUANTITY);
          QP_PREQ_GRP.engine_debug('LIMIT_CODE :='|| l_dets.LIMIT_CODE);
          QP_PREQ_GRP.engine_debug('LIMIT_TEXT :='|| substr(l_dets.LIMIT_TEXT, 1, 240));

          QP_PREQ_GRP.engine_debug('---------------------------------------------------');
        END IF;
      END LOOP; --l_ldets_cur
    END LOOP; --end l_lines_cur
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('---------------------------------------------------');

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_PUB.Populate_Output_INT: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Populate_Output_INT: '|| SQLERRM;
  END Populate_Output_INT;
  --added by yangli for Java Engine project

  --This is for debugging purposes
  PROCEDURE Populate_Output(x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_text OUT NOCOPY VARCHAR2) IS

  /*
INDX,QP_PREQ_PUB.populate_output.l_lines_cur,- No Index Used -,NA,NA
*/
  CURSOR l_lines_cur IS
    SELECT LINE_INDEX,
           LINE_ID,
           LINE_TYPE_CODE,
           LINE_QUANTITY,
           LINE_UOM_CODE,
           LINE_UNIT_PRICE,  --shu_latest
           PRICED_QUANTITY,
           UOM_QUANTITY,
           PRICED_UOM_CODE,
           CURRENCY_CODE,
           UNIT_PRICE,
           PERCENT_PRICE,
           PARENT_PRICE,
           PARENT_QUANTITY,
           PARENT_UOM_CODE,
           PRICE_FLAG,
           ADJUSTED_UNIT_PRICE,
           UPDATED_ADJUSTED_UNIT_PRICE,
           PROCESSING_ORDER,
           PROCESSED_CODE,
           PROCESSED_FLAG,
           PRICING_STATUS_CODE,
           PRICING_STATUS_TEXT,
           HOLD_CODE,
           HOLD_TEXT,
           PRICE_REQUEST_CODE,
           PRICING_EFFECTIVE_DATE,
           PRICE_LIST_HEADER_ID,
           PROCESS_STATUS,
           CATCHWEIGHT_QTY,
           ACTUAL_ORDER_QUANTITY,
           ORDER_UOM_SELLING_PRICE
    FROM   qp_npreq_lines_tmp;

  /*
INDX,QP_PREQ_GRP.populate_output.l_ldets_cur,QP_LIST_LINES_PK,LIST_LINE_ID,1
INDX,QP_PREQ_GRP.populate_output.l_ldets_cur,qp_npreq_ldets_tmp_N4,PRICING_STATUS_CODE,1
INDX,QP_PREQ_GRP.populate_output.l_ldets_cur,QP_LIST_HEADERS_B_PK,LIST_HEADER_ID,1
*/
  CURSOR l_ldets_cur(p_line_index NUMBER) IS
    SELECT /*+ ORDERED USE_NL(A B C) l_ldets_cur */
           a.LINE_DETAIL_INDEX,
           a.LINE_DETAIL_TYPE_CODE,
           a.LINE_INDEX,
           a.CREATED_FROM_LIST_HEADER_ID LIST_HEADER_ID,
           a.CREATED_FROM_LIST_LINE_ID   LIST_LINE_ID,
           a.CREATED_FROM_LIST_LINE_TYPE LIST_LINE_TYPE_CODE,
           a.PRICE_BREAK_TYPE_CODE,
           a.LINE_QUANTITY,
           a.ADJUSTMENT_AMOUNT,
           a.AUTOMATIC_FLAG,
           a.PRICING_PHASE_ID,
           a.OPERAND_CALCULATION_CODE,
           a.OPERAND_VALUE,
           a.PRICING_GROUP_SEQUENCE,
           a.CREATED_FROM_LIST_TYPE_CODE,
           a.APPLIED_FLAG,
           a.PRICING_STATUS_CODE,
           a.PRICING_STATUS_TEXT,
           a.LIMIT_CODE,
           a.LIMIT_TEXT,
           a.LIST_LINE_NO,
           a.GROUP_QUANTITY,
           a.UPDATED_FLAG,
           a.PROCESS_CODE,
           a.CALCULATION_CODE,
           a.PRICE_ADJUSTMENT_ID,
           b.SUBSTITUTION_VALUE SUBSTITUTION_VALUE_TO,
           b.SUBSTITUTION_ATTRIBUTE,
           b.ACCRUAL_FLAG,
           a.modifier_level_code,
           b.ESTIM_GL_VALUE,
           b.ACCRUAL_CONVERSION_RATE,
           --Pass throuh components
           b.OVERRIDE_FLAG,
           b.PRINT_ON_INVOICE_FLAG,
           b.INVENTORY_ITEM_ID,
           b.ORGANIZATION_ID,
           b.RELATED_ITEM_ID,
           b.RELATIONSHIP_TYPE_ID,
           b.ESTIM_ACCRUAL_RATE,
           b.EXPIRATION_DATE,
           b.BENEFIT_PRICE_LIST_LINE_ID,
           b.RECURRING_FLAG,
           b.BENEFIT_LIMIT,
           b.CHARGE_TYPE_CODE,
           b.CHARGE_SUBTYPE_CODE,
           a.BENEFIT_QTY,  --bug 2804053
           b.BENEFIT_UOM_CODE,
           b.PRORATION_TYPE_CODE,
           b.INCLUDE_ON_RETURNS_FLAG,
           b.REBATE_TRANSACTION_TYPE_CODE,
           b.NUMBER_EXPIRATION_PERIODS,
           b.EXPIRATION_PERIOD_UOM,
           b.COMMENTS,
           a.ORDER_QTY_OPERAND,
           a.ORDER_QTY_ADJ_AMT
    FROM  qp_npreq_ldets_tmp a,
          QP_LIST_LINES     b
    WHERE a.line_index = p_line_index
        AND a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
            AND   a.PRICING_STATUS_CODE = G_STATUS_NEW;

  BEGIN

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('---------------------------------------------------');
    END IF;

    FOR l_line IN l_lines_cur LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('----price line info--------------------------------');
        QP_PREQ_GRP.engine_debug('---------------------------------------------------');
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('*LINE_INDEX :='|| l_line.LINE_INDEX);
        QP_PREQ_GRP.engine_debug('*LINE_ID    :='|| l_line.LINE_ID);
        QP_PREQ_GRP.engine_debug('LINE_TYPE_CODE :='|| l_line.LINE_TYPE_CODE);
        QP_PREQ_GRP.engine_debug('UOM_QUANTITY :='|| l_line.UOM_QUANTITY);
        QP_PREQ_GRP.engine_debug('CURRENCY_CODE :='|| l_line.CURRENCY_CODE);
        QP_PREQ_GRP.engine_debug('PRICED_QUANTITY :='|| l_line.PRICED_QUANTITY);
        QP_PREQ_GRP.engine_debug('PRICED_UOM_CODE :='|| l_line.PRICED_UOM_CODE);
        QP_PREQ_GRP.engine_debug('*UNIT_PRICE :='|| l_line.UNIT_PRICE);
        QP_PREQ_GRP.engine_debug('*PRICE_LIST_ID :='|| l_line.PRICE_LIST_HEADER_ID);
        QP_PREQ_GRP.engine_debug('LINE_QUANTITY:=' || l_line.LINE_QUANTITY);
        QP_PREQ_GRP.engine_debug('LINE_UOM_CODE:=' || l_line.LINE_UOM_CODE);
        QP_PREQ_GRP.engine_debug('LINE_UNIT_PRICE:=' || l_line.LINE_UNIT_PRICE); -- shu_latest
        QP_PREQ_GRP.engine_debug('PERCENT_PRICE :='|| l_line.PERCENT_PRICE);
        QP_PREQ_GRP.engine_debug('*ADJUSTED_UNIT_PRICE :='|| l_line.ADJUSTED_UNIT_PRICE);
        QP_PREQ_GRP.engine_debug('PARENT_PRICE :='|| l_line.PARENT_PRICE);
        QP_PREQ_GRP.engine_debug('PARENT_QUANTITY :='|| l_line.PARENT_QUANTITY);
        QP_PREQ_GRP.engine_debug('PARENT_UOM_CODE :='|| l_line.PARENT_UOM_CODE);
        QP_PREQ_GRP.engine_debug('processed_code :='|| l_line.processed_code);
        QP_PREQ_GRP.engine_debug('processed_flag :='|| l_line.processed_flag);
        QP_PREQ_GRP.engine_debug('Price Flag :='|| l_line.price_flag);
        QP_PREQ_GRP.engine_debug('*STATUS_CODE :='|| l_line.PRICING_STATUS_CODE);
        QP_PREQ_GRP.engine_debug('*STATUS_TEXT :='|| substr(l_line.PRICING_STATUS_TEXT, 1, 2000));
        QP_PREQ_GRP.engine_debug('HOLD_CODE := '|| l_line.HOLD_CODE);
        QP_PREQ_GRP.engine_debug('HOLD_TEXT := '|| substr(l_line.HOLD_TEXT, 1, 240));
        QP_PREQ_GRP.engine_debug('PRICE_REQUEST_CODE := '|| l_line.PRICE_REQUEST_CODE);
        QP_PREQ_GRP.engine_debug('PRICING_DATE := '|| l_line.PRICING_EFFECTIVE_DATE);
        QP_PREQ_GRP.engine_debug('*PROCESS_STATUS :='|| l_line.PROCESS_STATUS);
        QP_PREQ_GRP.engine_debug('*CATCHWEIGHT_QTY :='|| l_line.CATCHWEIGHT_QTY);
        QP_PREQ_GRP.engine_debug('*ACTUAL_ORDER_QTY :='|| l_line.ACTUAL_ORDER_QUANTITY);
        QP_PREQ_GRP.engine_debug('*ORDER_UOM_SELLING_PRICE :='|| l_line.ORDER_UOM_SELLING_PRICE);
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('---------------------------------------------------');

      END IF;
      --Populate Line detail
      FOR l_dets IN l_ldets_cur(l_line.LINE_INDEX) LOOP

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('-----------Line detail Info -----------------------');
          QP_PREQ_GRP.engine_debug('---------------------------------------------------');
          QP_PREQ_GRP.engine_debug('*LINE_DETAIL_INDEX :='|| l_dets.LINE_DETAIL_INDEX);
          QP_PREQ_GRP.engine_debug('LINE_DETAIL_TYPE_CODE:=' || l_dets.LINE_DETAIL_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('*LINE_INDEX:=' || l_dets.LINE_INDEX);
          QP_PREQ_GRP.engine_debug('*PROCESS_CODE:=' || l_dets.PROCESS_CODE);
          QP_PREQ_GRP.engine_debug('*CALCULATION_CODE:=' || l_dets.CALCULATION_CODE);
          QP_PREQ_GRP.engine_debug('*LIST_HEADER_ID:=' || l_dets.LIST_HEADER_ID);
          QP_PREQ_GRP.engine_debug('*LIST_LINE_ID:=' || l_dets.LIST_LINE_ID);
          QP_PREQ_GRP.engine_debug('*PRICE_ADJUSTMENT_ID:=' || l_dets.PRICE_ADJUSTMENT_ID);
          QP_PREQ_GRP.engine_debug('LIST_LINE_TYPE_CODE:=' || l_dets.LIST_LINE_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('SUBSTITUTION_TO:=' || l_dets.SUBSTITUTION_VALUE_TO);
          QP_PREQ_GRP.engine_debug('LINE_QUANTITY :='|| l_dets.LINE_QUANTITY);
          QP_PREQ_GRP.engine_debug('*ADJUSTMENT_AMOUNT :='|| l_dets.ADJUSTMENT_AMOUNT);
          QP_PREQ_GRP.engine_debug('*AUTOMATIC_FLAG    :='|| l_dets.AUTOMATIC_FLAG);
          QP_PREQ_GRP.engine_debug('APPLIED_FLAG      :='|| l_dets.APPLIED_FLAG);
          QP_PREQ_GRP.engine_debug('UPDATED_FLAG      :='|| l_dets.UPDATED_FLAG);
          QP_PREQ_GRP.engine_debug('PRICING_GROUP_SEQUENCE :='|| l_dets.PRICING_GROUP_SEQUENCE);
          QP_PREQ_GRP.engine_debug('CREATED_FROM_LIST_TYPE_CODE:=' || l_dets.CREATED_FROM_LIST_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('PRICE_BREAK_TYPE_CODE :='|| l_dets.PRICE_BREAK_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('*OVERRIDE_FLAG   :='|| l_dets.override_flag);
          QP_PREQ_GRP.engine_debug('PRINT_ON_INVOICE_FLAG :='|| l_dets.print_on_invoice_flag);
          QP_PREQ_GRP.engine_debug('PRICING_PHASE_ID :='|| l_dets.PRICING_PHASE_ID);
          QP_PREQ_GRP.engine_debug('*OPERAND_CALCULATION_CODE :='|| l_dets.OPERAND_CALCULATION_CODE);
          QP_PREQ_GRP.engine_debug('*OPERAND_VALUE :='|| l_dets.OPERAND_VALUE);
          QP_PREQ_GRP.engine_debug('*ORDER_QTY_OPERAND :='|| l_dets.ORDER_QTY_OPERAND);
          QP_PREQ_GRP.engine_debug('*ORDER_QTY_ADJ_AMT :='|| l_dets.ORDER_QTY_ADJ_AMT);
          QP_PREQ_GRP.engine_debug('*STATUS_CODE:=' || l_dets.PRICING_STATUS_CODE);
          QP_PREQ_GRP.engine_debug('*STATUS_TEXT:=' || substr(l_dets.PRICING_STATUS_TEXT, 1, 240));
          QP_PREQ_GRP.engine_debug('SUBSTITUTION_ATTRIBUTE:=' || l_dets.SUBSTITUTION_ATTRIBUTE);
          QP_PREQ_GRP.engine_debug('ACCRUAL_FLAG:=' || l_dets.ACCRUAL_FLAG);
          QP_PREQ_GRP.engine_debug('LIST_LINE_NO:=' || l_dets.LIST_LINE_NO);
          QP_PREQ_GRP.engine_debug('ESTIM_GL_VALUE:=' || l_dets.ESTIM_GL_VALUE);
          QP_PREQ_GRP.engine_debug('ACCRUAL_CONVERSION_RATE:=' || l_dets.ACCRUAL_CONVERSION_RATE);
        END IF;
        --Pass throuh components
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('OVERRIDE_FLAG:=' || l_dets.OVERRIDE_FLAG);
          QP_PREQ_GRP.engine_debug('INVENTORY_ITEM_ID:=' || l_dets.INVENTORY_ITEM_ID);
          QP_PREQ_GRP.engine_debug('ORGANIZATION_ID:=' || l_dets.ORGANIZATION_ID);
          QP_PREQ_GRP.engine_debug('RELATED_ITEM_ID:=' || l_dets.RELATED_ITEM_ID);
          QP_PREQ_GRP.engine_debug('RELATIONSHIP_TYPE_ID:=' || l_dets.RELATIONSHIP_TYPE_ID);
          QP_PREQ_GRP.engine_debug('ESTIM_ACCRUAL_RATE:=' || l_dets.ESTIM_ACCRUAL_RATE);
          QP_PREQ_GRP.engine_debug('EXPIRATION_DATE:=' || l_dets.EXPIRATION_DATE);
          QP_PREQ_GRP.engine_debug('BENEFIT_PRICE_LIST_LINE_ID:=' || l_dets.BENEFIT_PRICE_LIST_LINE_ID);
          QP_PREQ_GRP.engine_debug('RECURRING_FLAG:=' || l_dets.RECURRING_FLAG);
          QP_PREQ_GRP.engine_debug('BENEFIT_LIMIT:=' || l_dets.BENEFIT_LIMIT);
          QP_PREQ_GRP.engine_debug('CHARGE_TYPE_CODE:=' || l_dets.CHARGE_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('CHARGE_SUBTYPE_CODE:=' || l_dets.CHARGE_SUBTYPE_CODE);
          QP_PREQ_GRP.engine_debug('BENEFIT_QTY:=' || l_dets.BENEFIT_QTY);
          QP_PREQ_GRP.engine_debug('BENEFIT_UOM_CODE:=' || l_dets.BENEFIT_UOM_CODE);
          QP_PREQ_GRP.engine_debug('PRORATION_TYPE_CODE:=' || l_dets.PRORATION_TYPE_CODE);
          QP_PREQ_GRP.engine_debug('INCLUDE_ON_RETURNS_FLAG :='|| l_dets.INCLUDE_ON_RETURNS_FLAG);
          QP_PREQ_GRP.engine_debug('MODIFIER_LEVEL_CODE :='|| l_dets.MODIFIER_LEVEL_CODE);
          QP_PREQ_GRP.engine_debug('GROUP VALUE :='|| l_dets.GROUP_QUANTITY);
          QP_PREQ_GRP.engine_debug('LIMIT_CODE :='|| l_dets.LIMIT_CODE);
          QP_PREQ_GRP.engine_debug('LIMIT_TEXT :='|| substr(l_dets.LIMIT_TEXT, 1, 240));

          QP_PREQ_GRP.engine_debug('---------------------------------------------------');
        END IF;
      END LOOP; --l_ldets_cur
    END LOOP; --end l_lines_cur
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('---------------------------------------------------');

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('QP_PREQ_PUB.Populate_Output: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := 'QP_PREQ_PUB.Populate_Output: '|| SQLERRM;
  END Populate_Output;




  PROCEDURE PRICE_REQUEST
  (p_line_tbl IN QP_PREQ_GRP.LINE_TBL_TYPE,
   p_qual_tbl IN QP_PREQ_GRP.QUAL_TBL_TYPE,
   p_line_attr_tbl IN QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
   p_line_detail_tbl IN QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
   p_line_detail_qual_tbl IN QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
   p_line_detail_attr_tbl IN QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
   p_related_lines_tbl IN QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
   p_control_rec IN QP_PREQ_GRP.CONTROL_RECORD_TYPE,
   x_line_tbl OUT NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE,
   x_line_qual OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
   x_line_attr_tbl OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
   x_line_detail_tbl OUT NOCOPY QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
   x_line_detail_qual_tbl OUT NOCOPY QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
   x_line_detail_attr_tbl OUT NOCOPY QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
   x_related_lines_tbl OUT NOCOPY QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
   x_return_status OUT NOCOPY VARCHAR2,
   x_return_status_text OUT NOCOPY VARCHAR2
   ) IS

  PRICE_REQUEST_EXC EXCEPTION;
  E_BYPASS_PRICING EXCEPTION;
  E_DEBUG_ROUTINE_ERROR EXCEPTION;
  --added by yangli for Java Engine projecct 3086881
  E_ROUTINE_ERRORS EXCEPTION;
  Pricing_Exception EXCEPTION;
  JAVA_ENGINE_PRICING_EXCEPTION EXCEPTION;
  --added by yangli for Java Engine projecct 3086881
  E_NO_LINES_TO_PRICE EXCEPTION; -- 4865787

  l_control_rec QP_PREQ_GRP.CONTROL_RECORD_TYPE;

  l_routine VARCHAR2(50) := 'Routine: QP_PREQ_PUB.PRICE_REQUEST';
  l_output_file VARCHAR2(240);

  i PLS_INTEGER;
  j PLS_INTEGER;

  /*
INDX,QP_PREQ_PUB.price_request.lcur1,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_PREQ_PUB.price_request.lcur1,qp_npreq_ldets_tmp_N3,PRICING_STATUS_CODE,4
*/
  CURSOR lcur1 IS
    SELECT    ldet.created_from_list_line_id
            , line.line_index line_ind
            , line.price_flag
            , line.process_status
            , ldet.applied_flag
            , ldet.pricing_status_code
            , ldet.line_detail_index
            , ldet.process_code
            , ldet.automatic_flag
            , ldet.override_flag
            , line.unit_price
            , line.adjusted_unit_price
            , ldet.updated_flag
            , ldet.calculation_code
            , line.qualifiers_exist_flag
            , ldet.pricing_group_sequence bucket
    FROM qp_npreq_ldets_tmp ldet, qp_npreq_lines_tmp line
    WHERE line.line_index = ldet.line_index
    ORDER BY line_ind;

  --3169430
  CURSOR modifier_exists IS
    SELECT 'X'
    FROM
    QP_LIST_LINES A
    WHERE A.PRICING_PHASE_ID >1
    AND modifier_level_code IN ('LINE', 'LINEGROUP', 'ORDER')
    AND ROWNUM = 1;

  lrec1 lcur1%ROWTYPE;
  l_debug_switch CONSTANT VARCHAR2(30) := 'QP_DEBUG';
  l_return_status VARCHAR2(240);
  l_return_status_text VARCHAR2(240);
  l_pricing_event VARCHAR2(240);
  l_pricing_start_time NUMBER;
  l_pricing_end_time NUMBER;
  l_time_difference NUMBER;
  l_pricing_start_redo NUMBER;
  l_pricing_end_redo NUMBER;
  l_redo_difference NUMBER;
  l_request_type_code VARCHAR2(30);
  l_time_stats VARCHAR2(240);
  l_mod VARCHAR2(1);
  --added by yangli for JAVA ENGINE 3086881
  l_request_id NUMBER;
  l_status_text VARCHAR2(240);
  l_cleanup_flag VARCHAR2(1) := QP_PREQ_PUB.G_YES;
  --added by yangli for JAVA ENGINE 3086881
  l_no_of_lines NUMBER; -- 4865787

--added for moac
  l_default_org_id NUMBER;
--perf fix for bug 7309551 smbalara
  l_dynamic_sampling_level NUMBER :=0;
  l_old_dynamic_sampling_level NUMBER :=0;

  l_qp_license_product VARCHAR2(30) := NULL; /*Added for bug 8865594*/

  l_total_engine_time NUMBER;
  BEGIN

	qp_debug_util.addSummaryTimeLog('Total time taken in Fetching Input Attributes :' || qp_debug_util.getAttribute('BLD_CNTXT_ACCUM_TIME') || 'ms',0,1,1);
	qp_debug_util.tstart(x_Marker=>'ENGINE_CALL_QPXPPREB',x_Desc=>'QPXPPREB Price Request for Event : '||p_control_rec.PRICING_EVENT,x_PutLine=>true);

    --===============START: Pre-pricing process needed by JAVA and PL/SQL engine====
    -- Set the debug variable G_DEBUG_ENGINE in QP_PREQ_GRP
    QP_PREQ_GRP.Set_QP_Debug;
    G_QP_DEBUG := FND_PROFILE.VALUE(l_debug_switch); --3085171

    --Setting current event in debug util
     qp_debug_util.setCurrentEvent(p_control_rec.PRICING_EVENT);
     --QP_PREQ_GRP.G_CURR_PRICE_EVENT := p_control_rec.PRICING_EVENT;

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    l_pricing_start_time := dbms_utility.get_time;

    /* 4865787: error out if there are no lines to be priced */
    IF nvl(p_control_rec.temp_table_insert_flag, G_YES) = G_NO
    THEN
      -- temp table/direct insert path
      select count(*) into l_no_of_lines
      from qp_npreq_lines_tmp;
    ELSE
      -- PL/SQL table path
      l_no_of_lines := p_line_tbl.count;
    END IF;

    IF l_no_of_lines = 0 THEN
      RAISE E_NO_LINES_TO_PRICE;
    END IF;
    /* 4865787 */

    --moved down, since specific to only PL/SQL engine
    /*-- Changes made for bug 3169430 Customer Handleman as this customer has price lists only, no modifiers.
  open modifier_exists;
  fetch modifier_exists into l_mod;
  IF modifier_exists%NOTFOUND THEN
        G_NO_ADJ_PROCESSING := G_NO;
  ELSE
        G_NO_ADJ_PROCESSING := G_YES;
  END IF;
  CLOSE modifier_exists;
  */
    ----------------------------------------------------
    --setting time
    ----------------------------------------------------
    IF G_QP_DEBUG = G_ENGINE_TIME_TRACE_ON THEN --3085171
      --  l_pricing_start_time := dbms_utility.get_time;
      --added to note redo generation
      BEGIN
        SELECT VALUE INTO l_pricing_start_redo
       FROM v$mystat, v$statname
       WHERE v$mystat.statistic# = v$statname.statistic#
       AND v$statname.name = 'redo size';
      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error in looking up debug in PUB '|| SQLERRM);
          END IF; -- Bug No 4033618
      END;
    END IF;

    --MOVED TO HERE SINCE BOTH JAVA ENGINE AND PL/SQL ENGINE NEED by yangli
    --ASO is not passing request_type_code on control_rec, it is passed
    --on the lines
    IF p_control_rec.request_type_code IS NULL THEN
      l_request_type_code := p_LINE_tbl(1).request_type_code;
    END IF; --p_control_rec.request_type_code

    l_control_rec := p_control_rec;

    --added for moac
    --Initialize MOAC and set org context to Org passed in nvl(p_control_rec.org_id, mo_default_org_id)
    --so that the pricing engine will look at data specific to the
    --passed org or mo_default_org plus global data only

    IF MO_GLOBAL.get_access_mode is null THEN
      MO_GLOBAL.Init('QP');
      l_control_rec.org_id := nvl(p_control_rec.org_id, QP_UTIL.get_org_id);
      MO_GLOBAL.set_policy_context('S', l_control_rec.org_id);
    END IF;--MO_GLOBAL

    --OC used to pass request_type_code only on the lines tbl
    l_control_rec.request_type_code := nvl(p_control_rec.request_type_code,
                                           l_request_type_code);
    G_CHECK_CUST_VIEW_FLAG := nvl(p_control_rec.check_cust_view_flag, G_NO);
    --3401941
    G_CALCULATE_FLAG := nvl(l_control_rec.CALCULATE_FLAG, 'NULL');
    G_REQUEST_TYPE_CODE := l_control_rec.request_type_code;

    --this is added for the FTE get_freight functionality to return adj
    --from the freight charge phases
    G_GET_FREIGHT_FLAG := nvl(l_control_rec.get_freight_flag, G_NO);

    -- for QP-PO integration

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('G_REQUEST_TYPE_CODE = ' || G_REQUEST_TYPE_CODE);
      qp_debug_util.print_support_csv('START');
    END IF;


    IF G_REQUEST_TYPE_CODE IN ('PO', 'ICX') THEN
      IF G_LICENSED_FOR_PRODUCT IS NULL THEN
        G_LICENSED_FOR_PRODUCT := nvl(fnd_profile.VALUE('QP_LICENSED_FOR_PRODUCT'), 'ZZZZZZ');
        /*Added for bug 8865594*/
	--l_qp_license_product := FND_PROFILE.VALUE_SPECIFIC(NAME => 'QP_LICENSED_FOR_PRODUCT',application_id => 201);

      END IF;

      -- bug9285924
      l_qp_license_product := FND_PROFILE.VALUE_SPECIFIC(NAME => 'QP_LICENSED_FOR_PRODUCT',application_id => 201);

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('G_LICENSED_FOR_PRODUCT = ' || G_LICENSED_FOR_PRODUCT);
        QP_PREQ_GRP.engine_debug('l_qp_license_product = ' || l_qp_license_product);
      END IF;

      IF (G_LICENSED_FOR_PRODUCT = 'PO' OR
          nvl(l_qp_license_product, 'X') = 'PO') THEN -- Added for 8865594
        NULL;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_NOT_LICENSED_PO');
        x_return_status_text := FND_MESSAGE.get;
        RETURN;
      END IF;
    END IF;

    -- for QP-CMRO integration
    IF G_REQUEST_TYPE_CODE = 'AHL' THEN
      IF G_LICENSED_FOR_PRODUCT IS NULL THEN
        G_LICENSED_FOR_PRODUCT := nvl(fnd_profile.VALUE('QP_LICENSED_FOR_PRODUCT'), 'ZZZZZZ');
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('G_LICENSED_FOR_PRODUCT = ' || G_LICENSED_FOR_PRODUCT);
      END IF;

      IF G_LICENSED_FOR_PRODUCT = 'AHL' THEN
        NULL;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_NOT_LICENSED_CMRO');
        x_return_status_text := FND_MESSAGE.get;
        RETURN;
      END IF;
    END IF;

    IF (G_QP_DEBUG = G_YES) OR
      (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN -- If Debug is on

      -- A call to QP_COPY_DEBUG_PVT.Generate_Debug_Req_Seq to initialize Global Variables
      QP_COPY_DEBUG_PVT.Generate_Debug_Req_Seq(l_return_status,
                                               l_return_status_text);
      x_return_status := l_return_status;
      x_return_status_text := l_return_status_text;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE E_DEBUG_ROUTINE_ERROR;
      END IF;

    END IF;
    --MOVED TO HERE SINCE BOTH JAVA ENGINE AND PL/SQL ENGINE NEED by yangli
    --===========END: Pre-pricing process needed by JAVA and PL/SQL engine=========

    --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
      --===========START: Globals Initialization specific only to PL/SQL Engine=======
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('01 Java Engine not Installed ----------');
      END IF;

      -- Changes made for bug 3169430 Customer Handleman as this customer has price lists only, no modifiers.
      OPEN modifier_exists;
      FETCH modifier_exists INTO l_mod;
      IF modifier_exists%NOTFOUND THEN
        G_NO_ADJ_PROCESSING := G_NO;
      ELSE
        G_NO_ADJ_PROCESSING := G_YES;
      END IF;
      CLOSE modifier_exists;

      ----------------------------------------------------
      --setting debug level
      ----------------------------------------------------
      --QP_PREQ_GRP.G_DEBUG_ENGINE:= oe_debug_pub.G_DEBUG;
      ----------------------------------------------------
      --New QP profile to say whether to round adjustment_amt or selling/list_price
      --default to 'Y' if the profile or rounding_flag are null
      -- QP Profile QP_SELLING_PRICE_ROUNDING_OPTIONS
      --Values for the profile:
      --NO_ROUND - No rounding  :
      --        Selling Price = unrounded list price + unrounded adjustments;
      --ROUND_ADJ - Round Selling Price and adjustments :
      --        Selling Price = round(list price) + round(adjustments);
      --NO_ROUND_ADJ - Round Selling Price after adding unrounded list price and adjustments :
      --        Selling price = round(list _price + adjustments);
      --Rounding Option Changes:
      --Control Record Variable mapping to profile for backword compatibility.
      --    NULL - ROUND_ADJ for non-ASO req_type and look at the QP profile for ASO
      --    Y - ROUND_ADJ
      --    N - NO_ROUND
      --    U - NO_ROUND_ADJ
      --    Q - look at the QP profile
      --Change for 2635440 - pass 'Q' as default value for OC if request_type is 'ASO'
      ----------------------------------------------------
      G_ROUNDING_OPTIONS := FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS');
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Rounding profile value '|| G_ROUNDING_OPTIONS);
      END IF;

      /*--ASO is not passing request_type_code on control_rec, it is passed
--on the lines
IF p_control_rec.request_type_code IS NULL THEN
  l_request_type_code := p_LINE_tbl(1).request_type_code;
END IF;--p_control_rec.request_type_code

l_control_rec := p_control_rec;
--OC used to pass request_type_code only on the lines tbl
l_control_rec.request_type_code := nvl(p_control_rec.request_type_code,
                                            l_request_type_code);
G_REQUEST_TYPE_CODE := l_control_rec.request_type_code;
*/ --moved to top since both PL/SQL path and Java Engine path need.

      /*--this is added for the FTE get_freight functionality to return adj
--from the freight charge phases
G_GET_FREIGHT_FLAG := nvl(l_control_rec.get_freight_flag, G_NO);
*/ --moved to top since needed by both PL/SQL and Java Engine

      -- Added new profile (QP_MULTI_CURRENCY_USAGE) with default value 'N' to maintain
      -- current behaviour,bug 2943033
      IF p_control_rec.use_multi_currency = 'Y' THEN
        G_USE_MULTI_CURRENCY_PUB := p_control_rec.use_multi_currency;
      ELSE
        G_USE_MULTI_CURRENCY_PUB := nvl(fnd_profile.VALUE('QP_MULTI_CURRENCY_USAGE'), 'N');
        l_control_rec.use_multi_currency := G_USE_MULTI_CURRENCY_PUB;
      END IF;

      IF nvl(p_control_rec.rounding_flag, G_YES) = G_ROUNDING_PROFILE
        THEN
        G_ROUND_INDIVIDUAL_ADJ := nvl(G_ROUNDING_OPTIONS, G_NO_ROUND);
      ELSIF nvl(p_control_rec.rounding_flag, G_YES) = G_YES
        THEN
        --this is done for bug 2635440 for OC to default the rounding_flag to 'Q'
        --to look at the profile for rounding if the rounding_flag is null
        --in the pl/sql code path. OC will pass Q for direct insert path
        IF G_REQUEST_TYPE_CODE = 'ASO'
          AND nvl(p_control_rec.temp_table_insert_flag, G_YES) = G_YES
          AND p_control_rec.rounding_flag IS NULL THEN
          G_ROUND_INDIVIDUAL_ADJ := nvl(G_ROUNDING_OPTIONS, G_NO_ROUND);
        ELSE
          G_ROUND_INDIVIDUAL_ADJ := G_ROUND_ADJ;
        END IF; --l_control_rec.request_type_code
      ELSIF nvl(p_control_rec.rounding_flag, G_YES) = G_NO
        THEN
        G_ROUND_INDIVIDUAL_ADJ := G_NO_ROUND;
      ELSIF nvl(p_control_rec.rounding_flag, G_YES) = 'U'
        THEN
        G_ROUND_INDIVIDUAL_ADJ := G_NO_ROUND_ADJ;
      ELSIF nvl(p_control_rec.rounding_flag, G_YES) = 'P' --[prarasto:Post Round] added condition to update
                                                          --G_ROUND_INDIVIDUAL_ADJ for post rounding
        THEN
        G_ROUND_INDIVIDUAL_ADJ := G_POST_ROUND;
      END IF;

      -- The below code is replaced with QP_PREQ_GRP.Set_QP_Debug

      --getting debug profilE
      ----------------------------------------------------
      --G_QP_DEBUG := FND_PROFILE.VALUE(l_debug_switch);   --3085171
      ----------------------------------------------------

      /* ----------------------------------------------------

 -- Introduced for facilitating debugging for non OM Applications
IF (NOT OE_DEBUG_PUB.ISDebugOn) THEN --If om debug is not on , then only look at
                                     --qp_debug

 IF (G_QP_DEBUG = G_YES) OR
    (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN  -- If Debug is on
  oe_debug_pub.SetDebugLevel(10);
  oe_debug_pub.Initialize;
  oe_debug_pub.debug_on;
  l_output_file := oe_debug_pub.Set_Debug_Mode('FILE');
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug ('The output file is : ' || l_output_file );
  END IF;
  QP_PREQ_GRP.G_DEBUG_ENGINE:= FND_API.G_TRUE;
 ELSE
  QP_PREQ_GRP.G_DEBUG_ENGINE:= FND_API.G_FALSE;
 END IF;
ELSE
 QP_PREQ_GRP.G_DEBUG_ENGINE:= FND_API.G_TRUE;
END IF;

*/

      --MOVED UP TO BOTH JAVA AND PL/SQL ENGINE PATH by yangli
      /* IF (G_QP_DEBUG = G_YES) OR
    (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN  -- If Debug is on

  -- A call to QP_COPY_DEBUG_PVT.Generate_Debug_Req_Seq to initialize Global Variables
  QP_COPY_DEBUG_PVT.Generate_Debug_Req_Seq(l_return_status,
                                           l_return_status_text);
  x_return_status := l_return_status;
  x_return_status_text := l_return_status_text;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE E_DEBUG_ROUTINE_ERROR;
  END IF;

 END IF;
*/

      --GSA Check
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: Begin GSA check ');
      END IF;
      G_GSA_INDICATOR := Check_GSA_Indicator;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: GSA_indicator '|| G_GSA_INDICATOR);
        QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: GSA_profile '|| G_GSA_ENABLED_FLAG);

      END IF;
      G_GSA_CHECK_FLAG := nvl(p_control_rec.GSA_CHECK_FLAG, G_YES);
      G_GSA_ENABLED_FLAG := nvl(FND_PROFILE.VALUE(G_GSA_Max_Discount_Enabled), G_NO);


      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: request_type_code '|| G_REQUEST_TYPE_CODE);
        QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: check_cust_view_flag '|| G_check_cust_view_flag);
        QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: round_indv_adj '|| G_ROUND_INDIVIDUAL_ADJ);

      END IF;
      --===========END: Globals Initialization specific only to PL/SQL Engine=======
    END IF; --java engine is not installed

    --============START: Debug print needed by JAVA and PL/SQL Engine=====
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: Version '|| Get_Version);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: temp table insert flag '|| p_control_rec.temp_table_insert_flag);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: calculate_flag '|| p_control_rec.calculate_flag);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: check_cust_view_flag '|| p_control_rec.check_cust_view_flag ||' reqtype '|| l_control_rec.request_type_code);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: pricing_event '|| p_control_rec.pricing_event);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: rounding_flag '|| p_control_rec.rounding_flag);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: gsa_check '|| p_control_rec.gsa_check_flag);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: full_pricing '|| p_control_rec.full_pricing_call);
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: get_freight_flag '|| G_GET_FREIGHT_FLAG);
    END IF;
    --============END: Debug print needed by JAVA and PL/SQL Engine=====

    /*
--GSA Check
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: Begin GSA check ');
END IF;
G_GSA_INDICATOR := Check_GSA_Indicator;
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: GSA_indicator '||G_GSA_INDICATOR);
QP_PREQ_GRP.ENGINE_DEBUG('PRICE REQUEST PUB: GSA_profile '||G_GSA_ENABLED_FLAG);

END IF;
G_GSA_CHECK_FLAG := nvl(p_control_rec.GSA_CHECK_FLAG, G_YES);
G_GSA_ENABLED_FLAG := nvl(FND_PROFILE.VALUE(G_GSA_Max_Discount_Enabled), G_NO);


IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: request_type_code '||G_REQUEST_TYPE_CODE);
QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: check_cust_view_flag '||G_check_cust_view_flag);
QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: round_indv_adj '||G_ROUND_INDIVIDUAL_ADJ);

END IF;
*/ --moved up into PL/SQL Engine specific path

    --===========START: l_control_record needed by JAVA and PL/SQL Engine===
    --to convert multiple events passed as string to a readable format
    --to remove the commas and single quotes in the pricing_event in ctrl rec
    IF instr(l_control_rec.pricing_event, ',') > 0
      THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: pricing_event '|| l_control_rec.pricing_event);
      END IF;
      --Changes for bug 2258525: Introduced local vairable l_pricing_event
      --instead of changing the control_rec
      --this is to remove any blank spaces in the string
      l_pricing_event := REPLACE(l_control_rec.pricing_event,' ', '');
      --this is to remove any single quotes in the string
      l_pricing_event := REPLACE(l_pricing_event, '''', '');
    ELSE
      l_pricing_event := l_control_rec.pricing_event;
    END IF;

    --this is to make the cursor work for the last event
    l_pricing_event := l_pricing_event || ',';
    l_control_rec.pricing_event := l_pricing_event;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('BEGIN PRICE REQUEST PUB: pricing_event '|| l_control_rec.pricing_event);
    END IF;
    l_control_rec.GSA_DUP_CHECK_FLAG := G_NO;
    l_control_rec.temp_table_insert_flag :=
    nvl(p_control_rec.temp_table_insert_flag, G_YES);
    l_control_rec.public_api_call_flag := G_YES;
    l_control_rec.check_cust_view_flag := nvl(p_control_rec.check_cust_view_flag, G_NO);

    --changes for bug 2635440
    --default rounding_flag to 'Q' when called by ASO/OC and 'Y' otherwise
    IF p_control_rec.rounding_flag IS NULL
      AND l_control_rec.temp_table_insert_flag = G_YES
      AND G_REQUEST_TYPE_CODE = 'ASO' THEN
      l_control_rec.rounding_flag := G_ROUNDING_PROFILE;
    ELSE
      l_control_rec.rounding_flag := nvl(p_control_rec.rounding_flag, G_YES);
    END IF; --p_control_rec.rounding_flag

    -- Added for Bug 2847866
    QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG := nvl(l_control_rec.public_api_call_flag, 'N');
    --============END: l_control_rec needed by JAVA and PL/SQL Engine====

    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
      --===========START: specific only to PL/SQL Engine=======
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('02 Java Engine not Installed ----------');
      END IF;
      -----------------------------------------------------------------
      --Need to set the global constants for the engine to see
      --if the calling application populates into the temp tables directly
      -----------------------------------------------------------------

      --initialize for usage_pricing and OM calls
      IF l_control_rec.temp_table_insert_flag = G_NO THEN
        --removing this for bug 2830206 as calculate_flag can be 'Y', 'C' or 'N'.
        --l_control_rec.calculate_flag := G_SEARCH_ONLY;

        /*-- Added for Bug 2847866
QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG:=nvl(l_control_rec.public_api_call_flag,'N');*/--moved above, needed by Java and PL/SQL Engine

        IF (G_NO_ADJ_PROCESSING = G_YES) AND (G_QP_INSTALL_STATUS = 'I') THEN -- Added for 3169430
          Identify_freegood_lines(l_control_rec.pricing_event
                                  , x_return_status, x_return_status_text);

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('Exception Initialize_cons: '
                                       || x_return_status_text);
            END IF;
            RAISE PRICE_REQUEST_EXC;
          END IF; --x_return_status
        END IF;
        Initialize_constants(
                             l_control_rec
                             , x_return_status_text
                             , x_return_status);

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Initialize_cons: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        ELSIF X_RETURN_STATUS = 'BYPASS_PRICING'
          THEN
          RAISE E_BYPASS_PRICING;
        END IF;
      END IF;
      --=======END: Specific only to PL/SQL Engine==================
    END IF; --java engine is not installed by yangli for Java Engine PUB 3086881

    --added by yangli for Java Engine PUB 3086881
    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
      --=======START: Specific only to PL/SQL Engine==================
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('03 Java Engine not Installed ----------');
      END IF;
      --added by yangli for Java Engine PUB 3086881
      IF l_control_rec.calculate_flag IN
        (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_SEARCH_ONLY)
        THEN

	--Performance bug fix 7309551
            BEGIN
            SELECT VALUE INTO l_old_dynamic_sampling_level
             FROM v$parameter
             WHERE name = 'optimizer_dynamic_sampling';
            IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Default Dynamic sampling Level :'|| l_old_dynamic_sampling_level);
            END IF;
            l_dynamic_sampling_level := TO_NUMBER(NVL(FND_PROFILE.VALUE(G_DYNAMIC_SAMPLING_LEVEL),1));
            IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('QP Profile Dynamic sampling level :'|| l_dynamic_sampling_level);
            END If;
            EXCEPTION
            WHEN OTHERS THEN
                IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Error in looking up Dynamic sampling level '|| SQLERRM);
                    QP_PREQ_GRP.engine_debug('Setting Dynamic Sampling level to 1');
                END IF;
                l_dynamic_sampling_level := 1;
            END;

            IF (l_dynamic_sampling_level IN (1) AND l_dynamic_sampling_level <> l_old_dynamic_sampling_level) THEN
                IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.ENGINE_DEBUG('Setting dynamic sampling level to '|| l_dynamic_sampling_level);
                END IF;
                BEGIN
                Execute immediate 'Alter session set optimizer_dynamic_sampling = '||l_dynamic_sampling_level;
                EXCEPTION
                WHEN OTHERS THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Error in setting dynamic sampling level'|| SQLERRM);
                  END IF;
                END;
            END IF;
	----7309551

        --Call pricing engine only if calculate flag is search_only or search and calculate
        QP_PREQ_GRP.PRICE_REQUEST
        (p_line_tbl => p_line_tbl,
         p_qual_tbl => p_qual_tbl,
         p_line_attr_tbl => p_line_attr_tbl,
         p_LINE_DETAIL_tbl => p_line_detail_tbl,
         p_LINE_DETAIL_qual_tbl => p_line_detail_qual_tbl,
         p_LINE_DETAIL_attr_tbl => p_line_detail_attr_tbl,
         p_related_lines_tbl => p_related_lines_tbl,
         p_control_rec => l_control_rec,
         x_line_tbl => x_line_tbl,
         x_line_qual => x_line_qual,
         x_line_attr_tbl => x_line_attr_tbl,
         x_line_detail_tbl => x_line_detail_tbl,
         x_line_detail_qual_tbl => x_line_detail_qual_tbl,
         x_line_detail_attr_tbl => x_line_detail_attr_tbl,
         x_related_lines_tbl => x_related_lines_tbl,
         x_return_status => x_return_status,
         x_return_status_text => x_return_status_text
         );
      END IF;


      IF X_RETURN_STATUS IN (FND_API.G_RET_STS_ERROR
                             , FND_API.G_RET_STS_UNEXP_ERROR) THEN

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request GRP: '|| x_return_status_text);
        END IF;
        RAISE PRICE_REQUEST_EXC;
      END IF;

      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
        OPEN lcur1; LOOP
          FETCH lcur1 INTO lrec1;
          EXIT WHEN lcur1%NOTFOUND;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('line_index '|| lrec1.line_ind ||
                                     ' list_line_id '|| lrec1.created_from_list_line_id ||
                                     ' line_detail_index '|| lrec1.line_detail_index ||
                                     ' pricess_sts '|| lrec1.process_status ||
                                     ' price_flag '|| lrec1.price_flag ||
                                     ' automatic '|| lrec1.automatic_flag ||' overr '|| lrec1.override_flag ||
                                     ' applied '|| lrec1.applied_flag ||' status '|| lrec1.pricing_status_code ||
                                     ' unitprice '|| lrec1.unit_price ||' adjprice '|| lrec1.adjusted_unit_price
                                     ||' process_code '|| lrec1.process_code ||' updated '|| lrec1.updated_flag
                                     ||' calc_code '|| lrec1.calculation_code ||' qualex '
                                     || lrec1.qualifiers_exist_flag ||
                                     ' bucket '|| nvl(lrec1.bucket, - 1));
          END IF;
        END LOOP;
        CLOSE lcur1;
      END IF;

      IF nvl(l_control_rec.temp_table_insert_flag, G_YES) = G_YES
        AND nvl(l_control_rec.check_cust_view_flag, G_NO) = G_NO
        AND nvl(Call_Usage_Pricing, G_NO) = G_YES
        THEN
        --rounding of list price will be taken care of in Calculate_price_pub
        Usage_pricing(l_control_rec.rounding_flag,
                      x_return_status, x_return_status_text);

        IF x_return_status IN (FND_API.G_RET_STS_ERROR
                               , FND_API.G_RET_STS_UNEXP_ERROR)
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request PUB: '
                                     || x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;
        Update_Qualifier_Value(x_return_status, x_return_status_text);
        IF x_return_status IN (FND_API.G_RET_STS_ERROR
                               , FND_API.G_RET_STS_UNEXP_ERROR)
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request PUB: '
                                     || x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;

      END IF;
      IF (G_NO_ADJ_PROCESSING = G_YES) AND (G_QP_INSTALL_STATUS = 'I') THEN -- Added for 3169430
        QP_PREQ_PUB.process_prg(x_return_status, x_return_status_text);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE PRICE_REQUEST_EXC;
        END IF; --x_return_status
      END IF;

      IF p_control_rec.calculate_flag IN
        (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_CALCULATE_ONLY)
        AND nvl(l_control_rec.check_cust_view_flag, G_NO) = G_NO
        --this needs to be changed for OC and others who do direct insert
        AND nvl(l_control_rec.temp_table_insert_flag, G_YES) = G_YES
        THEN
        --call calculate portion only if calculate flag is calculate or
        --calculate and search and overridden adjustments exist

        Process_Adjustments(l_CONTROL_REC.PRICING_EVENT
                            , x_return_status
                            , x_return_status_text);

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Process_Adjustments: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;
      END IF;


      IF p_control_rec.calculate_flag IN
        (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_CALCULATE_ONLY)
        AND nvl(l_control_rec.check_cust_view_flag, G_NO) = G_NO
        --this needs to be changed for OC and others who do direct insert
        AND nvl(l_control_rec.temp_table_insert_flag, G_YES) = G_YES
        THEN
        --call calculate portion only if calculate flag is calculate or
        --calculate and search and overridden adjustments exist
        Calculate_price(nvl(l_control_rec.rounding_flag, G_YES)
                        , x_return_status
                        , x_return_status_text);

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Calculate_price: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;

        -- begin 2892848 instructed to add this
        Update_Unit_Price (x_return_status
                           , x_return_status_text);
        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Update_Unit_Price: '|| x_return_status_text);
          END IF; -- end debug
          RAISE PRICE_REQUEST_EXC;
        END IF;
        -- end 2892848

      END IF;


      IF p_control_rec.calculate_flag IN
        (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_CALCULATE_ONLY)
        --and nvl(l_control_rec.check_cust_view_flag,G_NO) = G_YES
        --this needs to be changed for OC and others who do direct insert
        AND nvl(l_control_rec.temp_table_insert_flag, G_YES) = G_NO
        AND G_NO_ADJ_PROCESSING = G_YES -- Added for 3169430
        THEN

        --before doing calculation we need to populate g_buyline_price_flag
        Populate_buy_line_price_flag(x_return_status, x_return_status_text);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Populate_buy_line_price_flag: '
                                     || x_return_status_text);
          END IF; --l_debug
          RAISE PRICE_REQUEST_EXC;
        END IF;

        Update_recurring_quantity(x_return_status, x_return_status_text);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Update_recurring_quantity: '
                                     || x_return_status_text);
          END IF; --l_debug
          RAISE PRICE_REQUEST_EXC;
        END IF;

        IF G_QP_INSTALL_STATUS = 'I' THEN -- Added for 3169430
          Process_Coupon_issue(l_control_rec.pricing_event,
                               l_control_rec.simulation_flag,
                               x_return_status, x_return_status_text);
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('Exception Process_Coupon_issue: '
                                       || x_return_status_text);
            END IF; --debug
            RAISE PRICE_REQUEST_EXC;
          END IF;
        END IF; --G_QP_INSTALL_STATUS

        QP_CLEANUP_ADJUSTMENTS_PVT.fetch_adjustments
        (
         p_view_code => l_control_rec.view_code
         , p_event_code => l_control_rec.pricing_event
         , p_calculate_flag => l_control_rec.calculate_flag
         , p_rounding_flag => nvl(l_control_rec.rounding_flag, G_YES)
         , p_request_type_code => G_REQUEST_TYPE_CODE
         , x_return_status => x_return_status
         , x_return_status_text => x_return_status_text
         );

        --		Update_Child_Break_Lines(x_return_status,
        --					 x_return_status_text);


        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Calculate_price: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;
        -- bug 3487840 - duplicate PBH child lines causing ORA-01427: single-row subquery returns more than one row
        Cleanup_rltd_lines(x_return_status, x_return_status_text);
        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Cleanup_rltd_lines: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;

        Update_Adj_orderqty_cols(x_return_status, x_return_status_text);
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Update_Adj_orderqty_cols: '
                                     || x_return_status_text);
          END IF; --debug
          RAISE PRICE_REQUEST_EXC;
        END IF;

        --to check if new order level adj are inserted when changed
        --lines are passed
        IF l_control_rec.full_pricing_call = G_NO
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Starting changed lines check');
          END IF;
          CHECK_ORDER_LINE_CHANGES(p_request_type_code =>
                                   G_REQUEST_TYPE_CODE,
                                   p_full_pricing_call =>
                                   l_control_rec.full_pricing_call,
                                   x_return_status => x_return_status,
                                   x_return_status_text => x_return_status_text);
          IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('Exception CHECK_ORDER_LINE_CHANGES: '|| x_return_status_text);
            END IF;
            RAISE PRICE_REQUEST_EXC;
          END IF;
        END IF;

        --  Update_PRG_Process_status(x_return_status, x_return_status_text);
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Update_PRG_Process_status: '
                                     || x_return_status_text);
          END IF; --debug
          RAISE PRICE_REQUEST_EXC;
        END IF;

        --this needs to be done for OC/ASO as they pass in adj as G_STATUS_UNCHANGED
        /*
indxno index used
*/
        UPDATE qp_npreq_ldets_tmp
                SET pricing_status_code = G_STATUS_NEW
                        WHERE process_code = G_STATUS_NEW
        --changes for bug 2264566
        --changed to populate w/updated_flag = Y for child lines of manualPBH
                        AND (applied_flag = G_YES OR updated_flag = G_YES)
                        AND pricing_status_code = G_STATUS_UNCHANGED;


        IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
          THEN
          Populate_Output(x_return_status, x_return_status);

          IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.ENGINE_DEBUG('Exception Populate_Output: '|| x_return_status_text);
            END IF;
            RAISE PRICE_REQUEST_EXC;
          END IF; --X_RETURN_STATUS
        END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('-------------------rltd info--------------------');

        END IF;
        IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
          --this is for debug for rltd lines
          FOR cl IN (SELECT line_index,
                     related_line_index,
                     line_detail_index,
                     related_line_detail_index,
                     relationship_type_code,
                     list_line_id,
                     related_list_line_id,
                     related_list_line_type,
                     operand_calculation_code,
                     operand,
                     pricing_group_sequence,
                     setup_value_from,
                     setup_value_to,
                     qualifier_value
                     FROM qp_npreq_rltd_lines_tmp
                     WHERE pricing_status_code = G_STATUS_NEW)
            LOOP
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('related records with status N '
                                       ||' line_dtl_index '|| cl.line_detail_index
                                       ||' rltd_line_dtl_index '|| cl.related_line_detail_index
                                       ||' line_index '|| cl.line_index
                                       ||' rltd_line_index '|| cl.related_line_index
                                       ||' list_line_id '|| cl.list_line_id
                                       ||' rltd_list_line_id '|| cl.related_list_line_id
                                       ||' rltd_list_line_type '|| cl.related_list_line_type
                                       ||' operand '|| cl.operand
                                       ||' operator '|| cl.operand_calculation_code
                                       ||' bucket '|| cl.pricing_group_sequence
                                       ||' setval_from '|| cl.setup_value_from
                                       ||' setval_to '|| cl.setup_value_to
                                       ||' qual_value '|| cl.qualifier_value);
            END IF;
          END LOOP; --for cl
        END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE
      END IF;



      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
        OPEN lcur1; LOOP
          FETCH lcur1 INTO lrec1;
          EXIT WHEN lcur1%NOTFOUND;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('line_index '|| lrec1.line_ind ||
                                     ' list_line_id '|| lrec1.created_from_list_line_id ||
                                     ' line_detail_index '|| lrec1.line_detail_index ||
                                     ' applied '|| lrec1.applied_flag ||' status '|| lrec1.pricing_status_code
                                     ||' process_code '|| lrec1.process_code);
          END IF;
        END LOOP;
        CLOSE lcur1;
      END IF;
      --Performance bug fix 7309551
        IF (l_dynamic_sampling_level IN (1) AND l_dynamic_sampling_level <> l_old_dynamic_sampling_level) THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Setting dynamic sampling level back to '|| l_old_dynamic_sampling_level);
            BEGIN
            Execute immediate 'alter session set optimizer_dynamic_sampling = '||l_old_dynamic_sampling_level;
            EXCEPTION
            WHEN OTHERS THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Error in resetting the dynamic sampling level to old value'|| SQLERRM);
                  END IF;
            END;
        END IF;
      --End 7309551

      --Update_PRG_Process_status;
      --=======END: Specific only to PL/SQL Engine==================
      --added by yangli for Java Engine PUB 3086881
    ELSE -- java engine is installed
      --=======START: Specific only to JAVA Engine==================
      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('03 Java Engine is installed');
        QP_PREQ_GRP.ENGINE_DEBUG('temp_table_insert_flag:' || l_control_rec.temp_table_insert_flag);
        QP_PREQ_GRP.ENGINE_DEBUG('QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG:' || QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG);
      END IF;

      --for OM call, need Pre-Insert Logic to fetch/format data from OE tables into
      --Java Engine interface tables
      IF l_control_rec.temp_table_insert_flag = G_NO THEN
        --Initialize_Constants() logic for Interface Tables

        --    IF G_REQUEST_TYPE_CODE = 'ONT' THEN
        --bug 3085453 handle pricing availability UI
        -- they pass reqtype ONT and insert adj into ldets
        IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES THEN
          --Preinsert Logic for OM call
          --to fetch out-of-phases modifiers and in-phase PRG modifiers
          --to fetch rltd information
          IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Before calling INT_TABLES_PREINSERT');
          END IF;
          INT_TABLES_PREINSERT(p_calculate_flag => l_control_rec.calculate_flag,
                               p_event_code => l_control_rec.pricing_event,
                               x_return_status => l_return_status,
                               x_return_status_text => l_status_Text);
          IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Existing INT_TABLES_PREINSERT');
          END IF;
          IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
            l_status_text := 'INT_TABLES_PREINSERT:' || l_status_text;
            RAISE E_ROUTINE_ERRORS;
          END IF;
        END IF;
      END IF;

      IF l_control_rec.temp_table_insert_flag = G_NO THEN
        l_request_id := QP_Price_Request_Context.GET_REQUEST_ID;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Request Id:'|| l_request_id);
        END IF;
        QP_JAVA_ENGINE.request_price(request_id => l_request_id,
                                     p_control_rec => l_control_rec,
                                     x_return_status => l_return_status,
                                     x_return_status_text => l_status_Text);

        IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
          --l_status_text:= 'QP_JAVA_ENGINE.request_price failed for request id:'||l_request_id||l_status_text;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_status_text);
          END IF; --Bug No 4033618
          x_return_status := l_return_status;
          x_return_status_text := l_status_text;
          RAISE JAVA_ENGINE_PRICING_EXCEPTION;
        END IF;
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Before calling QP_PREQ_GRP.PRICE_REQUEST.....');
        END IF;
        QP_PREQ_GRP.PRICE_REQUEST
        (p_line_tbl => p_line_tbl,
         p_qual_tbl => p_qual_tbl,
         p_line_attr_tbl => p_line_attr_tbl,
         p_LINE_DETAIL_tbl => p_line_detail_tbl,
         p_LINE_DETAIL_qual_tbl => p_line_detail_qual_tbl,
         p_LINE_DETAIL_attr_tbl => p_line_detail_attr_tbl,
         p_related_lines_tbl => p_related_lines_tbl,
         p_control_rec => l_control_rec,
         x_line_tbl => x_line_tbl,
         x_line_qual => x_line_qual,
         x_line_attr_tbl => x_line_attr_tbl,
         x_line_detail_tbl => x_line_detail_tbl,
         x_line_detail_qual_tbl => x_line_detail_qual_tbl,
         x_line_detail_attr_tbl => x_line_detail_attr_tbl,
         x_related_lines_tbl => x_related_lines_tbl,
         x_return_status => x_return_status,
         x_return_status_text => x_return_status_text
         );
        IF X_RETURN_STATUS IN (FND_API.G_RET_STS_ERROR
                               , FND_API.G_RET_STS_UNEXP_ERROR) THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request GRP: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF;
      END IF; --TEMP_TABLE_INSERT_FLAG=Y

      --  IF G_REQUEST_TYPE_CODE = 'ONT' THEN
      --bug 3085453 handle pricing availability UI
      -- they pass reqtype ONT and insert adj into ldets
      IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = G_YES THEN
        -- still need Cleanup_Adjustments logic
        -- and Populate_Price_Adj_Id logic
        -- from QP_CLEANUP_ADJUSTMENTS_PVT.Fetch_Adjustments
        --call cleanup of adj only for OM

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('deleting related lines');
        END IF;
        DELETE FROM qp_int_rltd_lines
        WHERE pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
        AND relationship_type_code = QP_PREQ_PUB.G_PBH_LINE
        AND pricing_status_text = 'INSERTED FOR CALCULATION';
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('deleted related lines '|| SQL%ROWCOUNT);
        END IF;

        IF l_control_rec.calculate_flag IN
          (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_CALCULATE_ONLY)
          THEN
          l_cleanup_flag := QP_PREQ_PUB.G_YES;
          --added for bug 3399997 by yangli
          Update_Line_Status(x_return_status, x_return_status_text);
          IF x_return_status = FND_API.G_RET_STS_ERROR
            THEN
            RAISE Pricing_Exception;
          END IF;
          --added for bug 3399997 by yangli

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Java Engine calling QP_CLEANUP_ADJUSTMENTS_PVT.cleanup_adjustments');
          END IF;
          QP_CLEANUP_ADJUSTMENTS_PVT.cleanup_adjustments('ONTVIEW',
                                                         G_REQUEST_TYPE_CODE,
                                                         l_cleanup_flag,
                                                         x_return_status,
                                                         x_return_status_text);
          IF x_return_status = FND_API.G_RET_STS_ERROR
            THEN
            RAISE Pricing_Exception;
          END IF;
          --moved down per bug3238607
          /*IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Java Engine calling QP_CLEANUP_ADJUSTMENTS_PVT.Populate_Price_Adj_ID');
      END IF;

      --populate the price adjustment id from sequence for rec with process_code = N
      QP_CLEANUP_ADJUSTMENTS_PVT.Populate_Price_Adj_ID(x_return_status,x_return_status_text);

      IF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
        Raise Pricing_Exception;
      END IF;*/
          --moved down per bug3238607
        END IF;
      END IF;
      --per bug3238607's decision, OM will pass simulation_flag=N
      --to indicate populate_price_adj_id is needed
      IF G_REQUEST_TYPE_CODE = 'ONT' AND
        l_control_rec.simulation_flag = G_NO THEN
        IF l_control_rec.calculate_flag IN
          (QP_PREQ_GRP.G_SEARCH_N_CALCULATE, QP_PREQ_GRP.G_CALCULATE_ONLY)
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Java Engine calling QP_CLEANUP_ADJUSTMENTS_PVT.Populate_Price_Adj_ID');
          END IF;

          --populate the price adjustment id from sequence for rec with process_code = N
          QP_CLEANUP_ADJUSTMENTS_PVT.Populate_Price_Adj_ID(x_return_status, x_return_status_text);

          IF x_return_status = FND_API.G_RET_STS_ERROR
            THEN
            RAISE Pricing_Exception;
          END IF;
        END IF;
      END IF;

      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        Populate_Output_INT(x_return_status, x_return_status);

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('Exception Populate_Output: '|| x_return_status_text);
          END IF;
          RAISE PRICE_REQUEST_EXC;
        END IF; --X_RETURN_STATUS
      END IF; --QP_PREQ_GRP.G_DEBUG_ENGINE
      --=======END: Specific only to JAVA Engine==================
    END IF; -- java  engine is installed
    --added by yangli for Java Engine PUB 3086881


    ------------------------------------------------------------
    --POPULATE OUT TEMPORARY TABLES
    ------------------------------------------------------------
    IF l_control_rec.temp_table_insert_flag = G_YES
      AND l_control_rec.check_cust_view_flag = G_NO
      THEN

      --added by yangli for Java Engine PUB 3086881
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
        ------------------------------------------------------------
        --POPULATE OUT PROCESS CODE IN PRICING_STATUS_CODE
        --ONLY UPDATE THE RECORDS INPUT BY USER WHCH WERE USED IN CALCULATION
        ------------------------------------------------------------
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Java Engine not Installed ----------');
        END IF;
        --added by yangli for Java Engine PUB 3086881

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('Update Process code to Pricing Code ');
        END IF;
        /*
indxno index used Ravi
*/
        UPDATE qp_npreq_ldets_tmp
                SET pricing_status_code = G_STATUS_NEW
                        WHERE process_code = G_STATUS_NEW
        --changes for bug 2264566
        --changed to populate w/updated_flag = Y for child lines of manualPBH
                        AND (applied_flag = G_YES OR updated_flag = G_YES)
                        AND pricing_status_code = G_STATUS_UNCHANGED;

        --added by yangli for Java Engine PUB 3086881
      END IF; --Java Engine is not installed;
      --added by yangli for Java Engine PUB 3086881
      QP_PREQ_GRP.POPULATE_OUTPUT(
                                  x_line_tbl => x_line_tbl,
                                  x_line_qual_tbl => x_line_qual,
                                  x_line_attr_tbl => x_line_attr_tbl,
                                  x_line_detail_tbl => x_line_detail_tbl,
                                  x_line_detail_qual_tbl => x_line_detail_qual_tbl,
                                  x_line_detail_attr_tbl => x_line_detail_attr_tbl,
                                  x_related_lines_tbl => x_related_lines_tbl);


      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Line Detail Count : ' || x_line_detail_tbl.COUNT);

      END IF;
      --*******************************************************************
      --DEBUG

      IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
        j := x_line_tbl.FIRST;
        WHILE j IS NOT NULL
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('PRICE LINE : '||
                                     x_line_tbl(j).line_index ||
                                     ' list price '|| x_line_tbl(j).unit_price ||
                                     ' adj price '|| x_line_tbl(j).adjusted_unit_price ||
                                     ' up adj price '|| x_line_tbl(j).updated_adjusted_unit_price ||
                                     ' process code '|| x_line_tbl(j).processed_code);

            QP_PREQ_GRP.ENGINE_DEBUG('---------------------------------------------------');
          END IF;
          i := x_line_detail_tbl.FIRST;
          WHILE i IS NOT NULL
            LOOP
            IF x_line_detail_tbl(i).line_index = x_line_tbl(j).line_index THEN
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.ENGINE_DEBUG('PRICE ADJUSTMENTS: '
                                         ||' mod_id '|| x_line_detail_tbl(i).list_line_id
                                         ||' dtl_index '|| x_line_detail_tbl(i).line_detail_index
                                         ||' adj amount '|| x_line_detail_tbl(i).adjustment_amount
                                         ||' op '|| x_line_detail_tbl(i).operand_calculation_code
                                         ||' operand value '|| x_line_detail_tbl(i).operand_value
                                         ||' applied '|| x_line_detail_tbl(i).applied_flag
                                         ||' updated '|| x_line_detail_tbl(i).updated_flag
                                         ||' process_code '|| x_line_detail_tbl(i).process_code
                                         ||' pricing_status '|| x_line_detail_tbl(i).status_code);
              END IF;
            END IF;
            i := x_line_detail_tbl.NEXT(i);
          END LOOP;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('---------------------------------------------------');
          END IF;
          j := x_line_tbl.NEXT(j);
        END LOOP;

        --fix for bug 2515762 automatic overrideable break debug for rltd info
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('------------Rltd Info----------------');
          QP_PREQ_GRP.ENGINE_DEBUG('Rltd Info count '|| x_related_lines_tbl.COUNT);
        END IF;
        j := x_related_lines_tbl.FIRST;
        WHILE j IS NOT NULL
          LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.ENGINE_DEBUG('line_index '
                                     || x_related_lines_tbl(j).line_index ||' related_line_index '
                                     || x_related_lines_tbl(j).related_line_index ||' dtl_index '
                                     || x_related_lines_tbl(j).line_detail_index ||' rltd_dtl_index '
                                     || x_related_lines_tbl(j).related_line_detail_index ||' relation '
                                     || x_related_lines_tbl(j).relationship_type_code);
          END IF;
          j := x_related_lines_tbl.NEXT(j);
        END LOOP;

      END IF; --IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      --*******************************************************************
    END IF; --temp_table_insert_flag = G_YES and check_cust_view_flag = G_NO


    --Fix for bug 3550303 need to reset QP_BULK_PREQ_GRP.G_HVOP_PRICING_ON
    --at the end of HVOP call
    QP_UTIL_PUB.RESET_HVOP_PRICING_ON;



    --============START: Post-pricing process needed by JAVA and PL/SQL Engine======
    --to write temp table data into debug tables
    IF (G_QP_DEBUG = G_YES) OR
      (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN -- If Debug is on
      QP_COPY_DEBUG_PVT.WRITE_TO_DEBUG_TABLES(p_control_rec,
                                              l_return_status,
                                              l_return_status_text
                                              );
      x_return_status := l_return_status;
      x_return_status_text := l_return_status_text;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE E_DEBUG_ROUTINE_ERROR;
      END IF;
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_RETURN_STATUS_TEXT := l_routine ||' SUCCESS';

    l_pricing_end_time := dbms_utility.get_time;

    IF G_QP_DEBUG = G_ENGINE_TIME_TRACE_ON THEN --3085171
      --added to note redo log
      BEGIN
        SELECT VALUE INTO l_pricing_end_redo
         FROM v$mystat, v$statname
         WHERE v$mystat.statistic# = v$statname.statistic#
         AND v$statname.name = 'redo size';
      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error in looking up redo end in PUB '|| SQLERRM);
          END IF;
      END;
    END IF;

    l_time_difference := (l_pricing_end_time - l_pricing_start_time) / 100 ;
    l_redo_difference := l_pricing_end_redo - l_pricing_start_redo ;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Total time taken in PUB Pkg: '|| l_time_difference);
      QP_PREQ_GRP.engine_debug('redo log in PUB: '|| l_redo_difference);

    END IF;

    --Changes for bug2961617

    /*
 execute immediate 'select '||''''|| ' Total Time in QP_PREQ_PUB(in sec) : ' ||
l_time_difference||' Total redo in QP_PREQ_PUB : '|| l_redo_difference||''''||' from dual ';
*/

    IF G_QP_DEBUG = G_ENGINE_TIME_TRACE_ON THEN --3085171
      BEGIN

        /*
select 'Total Time in QP_PREQ_PUB(in sec) : ' ||l_time_difference ||
' Total redo in QP_PREQ_PUB : '||l_redo_difference into l_time_stats from dual ;
*/

        EXECUTE IMMEDIATE 'select '|| '''' || ' Total Time in QP_PREQ_PUB(in sec) : ' ||
        l_time_difference ||' Total redo in QP_PREQ_PUB : '|| l_redo_difference || '''' ||' from dual ';

      EXCEPTION

        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Failed to get time statistics in QP_PREQ_PUB');
          END IF;
      END;
    END IF;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('End Price Request');
      qp_debug_util.print_support_csv('END');
   END IF;
    --============END: Post-pricing process needed by JAVA and PL/SQL Engine======

    qp_debug_util.tstop('ENGINE_CALL_QPXPPREB',l_total_engine_time);
    qp_debug_util.addSummaryTimeLog('Total Pricing Engine time (search and calculation included): '||l_total_engine_time||'ms',1,1,0);
    qp_debug_util.dumpSummaryTimeLog;
    qp_debug_util.tdump;
    qp_debug_util.tflush;

  	EXCEPTION
    WHEN E_BYPASS_PRICING THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Bypassed Pricing Engine');
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --to write temp table data into debug tables
      IF (G_QP_DEBUG = G_YES) OR
        (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN -- If Debug is on
        QP_COPY_DEBUG_PVT.WRITE_TO_DEBUG_TABLES(p_control_rec,
                                                l_return_status,
                                                l_return_status_text
                                                );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error occured in Debug Routine: ' || l_return_status_text);
          END IF;
        END IF;
      END IF;
      --added by yangli for Java Engine PUB 3086881
    WHEN PRICING_EXCEPTION THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('error in fetch_adjustments: '|| SQLERRM);
        QP_PREQ_GRP.engine_debug('error in fetch_adjustments: '|| x_return_status_text);
      END IF;
    WHEN JAVA_ENGINE_PRICING_EXCEPTION THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('error in QP_JAVA_ENGINE.price_request():'|| SQLERRM);
        QP_PREQ_GRP.engine_debug('error in QP_JAVA_ENGINE.price_request():'|| x_return_status_text);
      END IF;
      --added by yangli for Java Engine PUB 3086881

    WHEN PRICE_REQUEST_EXC THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request: '|| SQLERRM);
      END IF;
      NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- x_return_status_TEXT := l_routine||' '||SQLERRM;
      --to write temp table data into debug tables
      IF (G_QP_DEBUG = G_YES) OR
        (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN -- If Debug is on
        QP_COPY_DEBUG_PVT.WRITE_TO_DEBUG_TABLES(p_control_rec,
                                                l_return_status,
                                                l_return_status_text
                                                );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error occured in Debug Routine: ' || l_return_status_text);
          END IF;
        END IF;
      END IF;
    WHEN E_DEBUG_ROUTINE_ERROR THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error occured in Debug Routine: ' || x_return_status_text);
      END IF;
    WHEN E_NO_LINES_TO_PRICE THEN -- 4865787
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error in QP_PREQ_PUB.Price_Request: There are no lines to price!');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| ': There are no lines to price!';
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_TEXT := l_routine ||' '|| SQLERRM;
      --to write temp table data into debug tables
      IF (G_QP_DEBUG = G_YES) OR
        (G_QP_DEBUG = G_DONT_WRITE_TO_DEBUG) THEN -- If Debug is on
        QP_COPY_DEBUG_PVT.WRITE_TO_DEBUG_TABLES(p_control_rec,
                                                l_return_status,
                                                l_return_status_text
                                                );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error occured in Debug Routine: ' || l_return_status_text);
          END IF;
        END IF;
      END IF;


  END PRICE_REQUEST;

  -- returns TRUE if given price is lower or equal than GSA price for non-GSA customer, else FALSE
  FUNCTION Raise_GSA_Error
  (
   p_request_type_code IN VARCHAR2
   , p_inventory_item_id IN NUMBER
   , p_pricing_date IN DATE
   , p_unit_price IN NUMBER
   , p_cust_account_id IN NUMBER
   )
  RETURN BOOLEAN

  IS

  l_operand NUMBER := 0;
  l_gsa_indicator_flag VARCHAR2(5) := 'N';
  v_return_value BOOLEAN := NULL;


  BEGIN


    IF p_cust_account_id IS NOT NULL THEN

      --obtain_gsa indicator_flag
      /*
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel1,HZ_CUST_ACCOUNTS_U1,CUST_ACCOUNT_ID,1
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel1,HZ_PARTIES_U1,PARTY_ID,1
*/



      /* begin changes made for tracking bug 2693700 */
      BEGIN
        SELECT NVL(gsa_indicator, 'N')
        INTO l_gsa_indicator_flag
        FROM hz_cust_site_uses_all hsu
        WHERE site_use_id = OE_ORDER_PUB.G_HDR.invoice_to_org_id
        AND  NVL(hsu.org_id,
                 NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'), 1, 1), ' ', NULL,
                                      SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))), - 99)) =
         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'), 1, 1), ' ', NULL,
                              SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))),  - 99);

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_gsa_indicator_flag := 'N';

      END;

      IF l_gsa_indicator_flag = 'N' THEN

        BEGIN

          SELECT NVL(gsa_indicator_flag, 'N')
          INTO l_gsa_indicator_flag
          FROM hz_parties hp, hz_cust_accounts hca
          WHERE hp.party_id = hca.party_id
          AND hca.cust_account_id = p_cust_account_id ;

        EXCEPTION

          WHEN NO_DATA_FOUND THEN
            l_gsa_indicator_flag := NULL;

        END;

      END IF;
      /*		SELECT nvl(gsa_indicator_flag,'N') into l_gsa_indicator_flag
		FROM hz_parties hp, hz_cust_accounts hca
		WHERE hp.party_id = hca.party_id and hca.cust_account_id = p_cust_account_id;
	ELSE
		-- treat it as non-GSA customer if p_cust_account_id is NULL
		l_gsa_indicator_flag := 'N';
*/
      --end bug 2693700

    END IF;


    -- Perform the GSA check if l_gsa_indicator_flag is N
    -- 'N' or NULL means it is not a GSA customer, then check if GSA error should be raised
    IF l_gsa_indicator_flag = 'N' THEN

      /*
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_QUALIFIERS_N7,QUALIFIER_CONTEXT,1
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_QUALIFIERS_N7,QUALIFIER_ATTRIBUTE,2
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_QUALIFIERS_N7,LIST_HEADER_ID,3
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_QUALIFIERS_N7,ACTIVE_FLAG,4
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_QUALIFIERS_N7,QUALIFIER_ATTR_VALUE,5
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,PRICING_PHASE_ID,1
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,QUALIFICATION_IND,2
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTRIBUTE_CONTEXT,3
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTRIBUTE,4
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,PRODUCT_ATTR_VALUE,5
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,EXCLUDER_FLAG,6
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,LIST_HEADER_ID,7
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICING_ATTRIBUTES_N5,LIST_LINE_ID,8
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_LIST_HEADERS_B_PK,LIST_HEADER_ID,1
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICE_REQ_SOURCES_PK,REQUEST_TYPE_CODE,1
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_PRICE_REQ_SOURCES_PK,SOURCE_SYSTEM_CODE,2
INDX,QP_PREQ_PUB.Raise_GSA_Error.sel2,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
      SELECT MIN(qpll.operand) INTO l_operand
       FROM
              QP_QUALIFIERS qpq,
              QP_PRICING_ATTRIBUTES qppa,
              QP_LIST_LINES qpll,
              QP_LIST_HEADERS_B qplh,
              QP_PRICE_REQ_SOURCES_V qpprs
      WHERE
              qpq.qualifier_context = 'CUSTOMER' AND
              qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE15' AND
              qpq.qualifier_attr_value = 'Y' AND
              qppa.list_header_id = qplh.list_header_id AND
              qplh.active_flag = 'Y' AND
              qpprs.request_type_code = p_request_type_code AND
              qpprs.source_system_code = qplh.source_system_code AND
              qppa.pricing_phase_id = 2 AND
              qppa.qualification_ind = 6 AND
              qppa.product_attribute_context = 'ITEM' AND
              qppa.product_attribute = 'PRICING_ATTRIBUTE1' AND
              qppa.product_attr_value = p_inventory_item_id AND
              qppa.excluder_flag = 'N' AND
              qppa.list_header_id = qpq.list_header_id AND
              qppa.list_line_id = qpll.list_line_id AND
              p_pricing_date BETWEEN nvl(trunc(qplh.start_date_active), p_pricing_date) AND nvl(trunc(qplh.end_date_active), p_pricing_date);

      IF l_operand IS NOT NULL THEN

        -- if given price is lower than GSA price, then raise GSA error
        IF p_unit_price <= l_operand THEN
          v_return_value := TRUE;
        ELSE
          v_return_value := FALSE;
        END IF;
      ELSE
        -- return FALSE if l_operand is NULL
        v_return_value := FALSE;
      END IF;


    ELSE -- l_gsa_indicator_flag != 'N'
      -- No need to check GSA error if it is a GSA customer, return FALSE
      v_return_value := FALSE;
    END IF;

    RETURN v_return_value;
  END Raise_GSA_Error;

  --overloaded for applications who insert into temp tables directly
  PROCEDURE PRICE_REQUEST
  (p_control_rec IN QP_PREQ_GRP.CONTROL_RECORD_TYPE,
   x_return_status OUT NOCOPY VARCHAR2,
   x_return_status_text OUT NOCOPY VARCHAR2
   ) IS

  l_line_tbl QP_PREQ_GRP.LINE_TBL_TYPE;
  l_qual_tbl QP_PREQ_GRP.QUAL_TBL_TYPE;
  l_line_attr_tbl QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
  l_line_detail_tbl QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  l_line_detail_qual_tbl QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
  l_line_detail_attr_tbl QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
  l_related_lines_tbl QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
  l_control_rec QP_PREQ_GRP.CONTROL_RECORD_TYPE;
  --l_return_status          VARCHAR2(30);
  --l_return_status_text     VARCHAR2(240);

  PRICE_REQUEST_EXC EXCEPTION;

  l_routine VARCHAR2(50) := 'Routine :QP_PREQ_PUB.Price_Request ';


  BEGIN


    PRICE_REQUEST
    (p_line_tbl => l_line_tbl,
     p_qual_tbl => l_qual_tbl,
     p_line_attr_tbl => l_line_attr_tbl,
     p_line_detail_tbl => l_line_detail_tbl,
     p_line_detail_qual_tbl => l_line_detail_qual_tbl,
     p_line_detail_attr_tbl => l_line_detail_attr_tbl,
     p_related_lines_tbl => l_related_lines_tbl,
     p_control_rec => p_control_rec,
     x_line_tbl => l_line_tbl,
     x_line_qual => l_qual_tbl,
     x_line_attr_tbl => l_line_attr_tbl,
     x_line_detail_tbl => l_line_detail_tbl,
     x_line_detail_qual_tbl => l_line_detail_qual_tbl,
     x_line_detail_attr_tbl => l_line_detail_attr_tbl,
     x_related_lines_tbl => l_related_lines_tbl,
     x_return_status => x_return_status,
     x_return_status_text => x_return_status_text
     );

    /*
IF l_return_status IN (FND_API.G_RET_STS_ERROR
                                  ,FND_API.G_RET_STS_UNEXP_ERROR)
THEN

        RAISE PRICE_REQUEST_EXC;
END IF;
*/



  EXCEPTION
    WHEN PRICE_REQUEST_EXC THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request: '|| SQLERRM);
      END IF;
      NULL;
      -- x_return_status := FND_API.G_RET_STS_ERROR;
      -- x_return_status_TEXT := l_routine||' '||SQLERRM;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Exception Price Request: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_TEXT := l_routine ||' '|| SQLERRM;

  END PRICE_REQUEST;

  --procedure to return price and status code and text -- needed by PO team
  -- changed the out param value for x_adjusted_unit_price to qp_npreq_lines_tmp.order_uom_selling_price
  PROCEDURE get_price_for_line(p_line_index IN NUMBER,
                               p_line_id IN NUMBER,
                               x_line_unit_price OUT NOCOPY NUMBER,
                               x_adjusted_unit_price OUT NOCOPY NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_pricing_status_code OUT NOCOPY VARCHAR2,
                               x_pricing_status_text OUT NOCOPY VARCHAR2
                               )
  IS

  l_routine VARCHAR2(100) := 'Routine :QP_PREQ_PUB.get_price_for_line ';
  BEGIN

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('In : ' || l_routine);
      QP_PREQ_GRP.ENGINE_DEBUG('p_line_index : ' || p_line_index);
      QP_PREQ_GRP.ENGINE_DEBUG('p_line_id : ' || p_line_id);
    END IF;

    --added by yangli for java engine
    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('java engine is not running');
      END IF;
      IF p_line_index IS NOT NULL THEN
        SELECT line_unit_price,
             order_uom_selling_price,
             pricing_status_code,
             pricing_status_text
        INTO   x_line_unit_price,
             x_adjusted_unit_price,
             x_pricing_status_code,
             x_pricing_status_text
        FROM   QP_NPREQ_LINES_TMP
        WHERE  line_index = p_line_index;
      ELSIF p_line_id IS NOT NULL THEN
        SELECT line_unit_price,
             order_uom_selling_price,
             pricing_status_code,
             pricing_status_text
        INTO   x_line_unit_price,
             x_adjusted_unit_price,
             x_pricing_status_code,
             x_pricing_status_text
        FROM   QP_NPREQ_LINES_TMP
        WHERE  line_id = p_line_id;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_pricing_status_text := 'Must pass either p_line_index or p_line_id while calling ' || l_routine;
      END IF;
      --added by yangli for java engine
    ELSE
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('java engine running');
      END IF;
      IF p_line_index IS NOT NULL THEN
        SELECT line_unit_price,
             order_uom_selling_price,
             pricing_status_code,
             pricing_status_text
        INTO   x_line_unit_price,
             x_adjusted_unit_price,
             x_pricing_status_code,
             x_pricing_status_text
        FROM   QP_INT_LINES
        WHERE  line_index = p_line_index;
      ELSIF p_line_id IS NOT NULL THEN
        SELECT line_unit_price,
             order_uom_selling_price,
             pricing_status_code,
             pricing_status_text
        INTO   x_line_unit_price,
             x_adjusted_unit_price,
             x_pricing_status_code,
             x_pricing_status_text
        FROM   QP_INT_LINES
        WHERE  line_id = p_line_id;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_pricing_status_text := 'Must pass either p_line_index or p_line_id while calling ' || l_routine;
      END IF;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('x_line_unit_price : ' || x_line_unit_price);
      QP_PREQ_GRP.ENGINE_DEBUG('x_adjusted_unit_price : ' || x_adjusted_unit_price);
      QP_PREQ_GRP.ENGINE_DEBUG('x_pricing_status_code : ' || x_pricing_status_code);
      QP_PREQ_GRP.ENGINE_DEBUG('x_pricing_status_text : ' || x_pricing_status_text);
    END IF;

    IF x_pricing_status_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_UNCHANGED) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('no_data_found Exception in : ' || l_routine || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_pricing_status_text := 'No record found for line_index ' || p_line_index || ' or line_id ' || p_line_id || ' in ' || l_routine;

    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Others Exception in : ' || l_routine || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_pricing_status_text := 'Others Exception in : ' || l_routine || ' ' || SQLERRM;
  END get_price_for_line;


END QP_PREQ_PUB;

/
