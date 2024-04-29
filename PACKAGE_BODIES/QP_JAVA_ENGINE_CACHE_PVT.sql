--------------------------------------------------------
--  DDL for Package Body QP_JAVA_ENGINE_CACHE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_JAVA_ENGINE_CACHE_PVT" AS
/* $Header: QPXJCCVB.pls 120.2 2006/03/09 16:09:52 hwong noship $ */

l_debug VARCHAR2(3);

PROCEDURE UPDATE_CACHE_STATS
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER
)
IS

/*****************************************************************
 Cursors for permanent full data objects
*****************************************************************/

CURSOR pattern_csr IS
SELECT count(*)
FROM qp_patterns;

CURSOR segment_csr IS
SELECT count(*)
FROM qp_segments_b qps,
qp_prc_contexts_b qpc
WHERE qps.prc_context_id = qpc.prc_context_id;

CURSOR request_source_csr IS
SELECT count(*)
FROM qp_price_req_sources;

CURSOR event_phase_csr IS
SELECT count(*)
FROM qp_pricing_phases qpp,
qp_event_phases qpe
WHERE qpe.pricing_phase_id = qpp.pricing_phase_id;

CURSOR profile_csr IS
SELECT count(*)
FROM FND_PROFILE_OPTIONS o, FND_PROFILE_OPTION_VALUES ov
WHERE o.APPLICATION_ID = 661 and o.PROFILE_OPTION_ID = ov.PROFILE_OPTION_ID (+) and o.APP_ENABLED_FLAG = 'N' and o.RESP_ENABLED_FLAG = 'N' and o.USER_ENABLED_FLAG = 'N';

CURSOR cache_do_size_csr IS
SELECT count(*)
FROM qp_cache_do_sizes;

CURSOR cache_stat_csr IS
SELECT count(*)
FROM qp_cache_stats;

CURSOR header_csr IS
SELECT count(*)
FROM qp_list_headers_b
WHERE active_flag = 'Y';

CURSOR second_price_list_csr IS
SELECT count(*)
FROM qp_qualifiers qpq, qp_list_headers_b qph1, qp_list_headers_b qph2
WHERE qualifier_context = 'MODLIST' and qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
and qph1.active_flag = 'Y' and qph2.active_flag = 'Y'
and qph1.list_header_id = qpq.list_header_id
and to_char(qph2.list_header_id) = qpq.qualifier_attr_value
and qph1.list_type_code = 'PRL';

CURSOR header_attr_csr IS
SELECT count(*) FROM (
SELECT 1
FROM qp_attribute_groups qp, qp_list_headers_b qph
WHERE qp.list_line_id = -1 and qph.active_flag = 'Y' and qp.list_header_id(+) = qph.list_header_id UNION ALL
SELECT 1
FROM qp_list_headers_b qp
WHERE qp.active_flag = 'Y' and NOT EXISTS (SELECT * FROM qp_attribute_groups qpg WHERE qpg.list_line_id=-1 and qpg.list_header_id = qp.list_header_id));

CURSOR header_ph_csr IS
SELECT count(*)
FROM (select /*+ ordered index(qph qp_list_headers_b_n7) use_nl(qpl) */
      distinct qpl.pricing_phase_id, qpl.list_header_id, qph.currency_code
      FROM qp_list_headers_b qph, qp_list_lines qpl
      WHERE qph.active_flag = 'Y'
      and qph.ask_for_flag <> 'Y'
      and qph.list_header_id = qpl.list_header_id);

CURSOR pattern_ph_csr IS
SELECT count(*)
FROM qp_pattern_phases qpph, qp_patterns qpp
WHERE qpp.pattern_type = 'HP' and qpp.pattern_id = qpph.pattern_id;

CURSOR okc_uom_csr IS
SELECT count(*)
FROM okx_units_of_measure_v;

CURSOR okc_time_unit_csr IS
SELECT count(*)
FROM okc_time_code_units_b
WHERE active_flag = 'Y';

/*****************************************************************
 Cursors for permanent partial data objects
*****************************************************************/

CURSOR line_perm_csr IS
SELECT count(*)
FROM qp_list_headers_b qph, qp_list_lines qpl
WHERE qpl.qualification_ind in (0, 2)
and qpl.list_header_id = qph.list_header_id
and qph.active_flag = 'Y';

CURSOR uom_perm_csr IS
SELECT count(*)
FROM mtl_uom_conversions
WHERE (disable_date is null or disable_date > sysdate)
and inventory_item_id = 0;

/*****************************************************************
 Cursors for cache-keys
*****************************************************************/

CURSOR modifier_cache_key_cnt_csr IS
SELECT /*+ ordered use_nl(qpl) index(qph qp_list_headers_b_n7) */ count(DISTINCT
qpl.cache_key)
FROM qp_list_headers_b qph, qp_list_lines qpl
WHERE qph.active_flag = 'Y'
and qph.list_type_code not in ('PML', 'PRL', 'AGR')
and qpl.list_header_id = qph.list_header_id;

CURSOR price_cache_key_cnt_csr IS
SELECT /*+ ordered use_nl(qpl) index(qph qp_list_headers_b_n7) */ count(DISTINCT
qpl.cache_key)
FROM qp_list_headers_b qph, qp_list_lines qpl
WHERE qph.active_flag = 'Y'
and qph.list_type_code = 'PRL'
and qpl.list_header_id = qph.list_header_id;

CURSOR formula_cache_key_cnt_csr IS
SELECT count(*)
FROM qp_price_formulas qpf;

CURSOR factor_cache_key_cnt_csr IS
SELECT count(*)
FROM qp_list_headers_b qlh
WHERE qlh.list_type_code = 'PML';

CURSOR uom_cache_key_cnt_csr IS
SELECT count(*)
FROM mtl_uom_conversions
WHERE (disable_date IS null or disable_date > sysdate)
and inventory_item_id <> 0;

CURSOR currency_cache_key_cnt_csr IS
SELECT count(DISTINCT qpc.currency_header_id)
FROM qp_currency_lists_b qpc, qp_list_headers_b qph
WHERE qph.active_flag = 'Y'
and qph.currency_code = qpc.base_currency_code;

CURSOR modifier_cache_key_csr IS
SELECT /*+ ordered use_nl(qpl) index(qph qp_list_headers_b_n7) */ DISTINCT
qpl.cache_key
FROM qp_list_headers_b qph, qp_list_lines qpl
WHERE qph.active_flag = 'Y'
and qph.list_type_code not in ('PML', 'PRL', 'AGR')
and qpl.list_header_id = qph.list_header_id
and ROWNUM < 200;

CURSOR price_cache_key_csr IS
SELECT /*+ ordered use_nl(qpl) index(qph qp_list_headers_b_n7) */ DISTINCT
qpl.cache_key
FROM qp_list_headers_b qph, qp_list_lines qpl
WHERE qph.active_flag = 'Y'
and qph.list_type_code = 'PRL'
and qpl.list_header_id = qph.list_header_id
and ROWNUM < 200;

CURSOR formula_cache_key_csr IS
SELECT
qpf.price_formula_id
FROM qp_price_formulas qpf
WHERE ROWNUM < 200;

CURSOR factor_cache_key_csr IS
SELECT
qlh.list_header_id
FROM qp_list_headers_b qlh
WHERE qlh.list_type_code = 'PML'
and ROWNUM < 200;

CURSOR uom_cache_key_csr IS
SELECT
inventory_item_id
FROM mtl_uom_conversions
WHERE (disable_date IS null or disable_date > sysdate)
and inventory_item_id <> 0
and ROWNUM < 200;

CURSOR currency_cache_key_csr IS
SELECT DISTINCT
qpc.currency_header_id
FROM qp_currency_lists_b qpc, qp_list_headers_b qph
WHERE qph.active_flag = 'Y'
and qph.currency_code = qpc.base_currency_code
and ROWNUM < 200;

/*****************************************************************
 Cursors for on-demand data objects
*****************************************************************/

CURSOR line_csr(p_cache_key varchar2) IS
SELECT sum(c) FROM (
  SELECT /*+ ordered use_nl(qph, qpr) index(qph qp_list_headers_b_pk) index(qpa qp_pricing_attributes_n2) */ count(*) c
  FROM qp_list_lines qpl, qp_list_headers_b qph, qp_pricing_attributes qpa
  WHERE qph.active_flag = 'Y' and qpl.list_header_id = qph.list_header_id and qpl.cache_key = p_cache_key and qpl.list_line_id = qpa.list_line_id(+)
  UNION ALL
  SELECT /*+ ordered use_nl(qph, qpr) index(qph qp_list_headers_b_pk) index(qpa qp_pricing_attributes_n2) */ count(*) c
  FROM qp_list_lines qpl2, qp_rltd_modifiers qpr, qp_list_lines qpl, qp_list_headers_b qph, qp_pricing_attributes qpa
  WHERE qph.active_flag = 'Y' and qpl.list_header_id = qph.list_header_id and qpl2.cache_key = p_cache_key and qpl2.list_line_id = qpr.from_rltd_modifier_id and qpl.list_line_id = qpr.to_rltd_modifier_id and qpl.list_line_id = qpa.list_line_id(+)
);

CURSOR line_attr_grp_csr(p_cache_key varchar2) IS
SELECT sum(c) FROM (
  SELECT count(*) c
  FROM qp_attribute_groups qp, qp_list_headers_b qph
  WHERE qp.pricing_phase_id <> -1 and qph.active_flag = 'Y' and qp.cache_key = p_cache_key and qp.list_header_id = qph.list_header_id
  UNION ALL
  SELECT /*+ ordered use_nl(qph) */ count(*) c
  FROM qp_list_lines qp, qp_list_headers_b qph
  WHERE qph.active_flag = 'Y' and qp.cache_key = p_cache_key and (qp.pattern_id IS not null or (qp.pattern_id is null and qp.qualification_ind in (0, 2))) and qp.list_header_id = qph.list_header_id
);

CURSOR non_eq_attr_csr(p_cache_key varchar2) IS
SELECT sum(c) FROM (
  SELECT /*+ ordered use_nl(qpr, qph, qpaq) */ count(*) c
  FROM qp_list_lines qplag, qp_list_headers_b qph, qp_pricing_attributes qpaq
  WHERE qph.active_flag = 'Y' and qph.list_header_id = qplag.list_header_id and qpaq.list_line_id = qplag.list_line_id and qpaq.pricing_segment_id is not null and qplag.cache_key = p_cache_key and qpaq.comparison_operator_code <> '='
  UNION ALL
  SELECT /*+ ordered use_nl(qpr, qph, qpaq) */ count(*) c
  FROM qp_list_lines qplag, qp_list_headers_b qph, qp_qualifiers qpaq
  WHERE qph.active_flag = 'Y' and qph.list_header_id = qplag.list_header_id and qpaq.list_line_id = qplag.list_line_id and qpaq.segment_id is not null and qplag.cache_key = p_cache_key and qpaq.comparison_operator_code <> '='
  UNION ALL
  SELECT /*+ ordered use_nl(qpr, qph, qpaq) */ count(*) c
  FROM qp_list_lines qpl, qp_rltd_modifiers qpr, qp_list_lines qplag, qp_list_headers_b qph, qp_pricing_attributes qpaq
  WHERE qph.active_flag = 'Y' and qph.list_header_id = qplag.list_header_id and qpaq.list_line_id = qplag.list_line_id and qpaq.pricing_segment_id is not null and qpl.cache_key = p_cache_key
    and qpl.list_line_id = qpr.from_rltd_modifier_id and qplag.list_line_id = qpr.to_rltd_modifier_id and qpaq.comparison_operator_code <> '='
  UNION ALL
  SELECT /*+ ordered use_nl(qpr, qph, qpaq) */ count(*) c
  FROM qp_list_lines qpl, qp_rltd_modifiers qpr, qp_list_lines qplag, qp_list_headers_b qph, qp_qualifiers qpaq
  WHERE qph.active_flag = 'Y' and qph.list_header_id = qplag.list_header_id and qpaq.list_line_id = qplag.list_line_id and qpaq.segment_id is not null and qpl.cache_key = p_cache_key
    and qpl.list_line_id = qpr.from_rltd_modifier_id and qplag.list_line_id = qpr.to_rltd_modifier_id and qpaq.comparison_operator_code <> '='
);

CURSOR uom_csr (p_cache_key varchar2) IS
SELECT count(*)
FROM mtl_uom_conversions
WHERE (disable_date is null or disable_date > sysdate) and inventory_item_id = p_cache_key;

CURSOR uom_class_csr (p_cache_key varchar2) IS
SELECT count(*)
FROM mtl_uom_class_conversions
WHERE (disable_date is null or disable_date > sysdate) and inventory_item_id = p_cache_key;

CURSOR formula_csr(p_cache_key varchar2) IS
SELECT count(*)
FROM qp_price_formulas
WHERE price_formula_id = p_cache_key;

CURSOR formula_line_csr(p_cache_key varchar2) IS
SELECT count(*)
FROM qp_price_formula_lines
WHERE price_formula_id = p_cache_key;

CURSOR currency_csr(p_cache_key varchar2) IS
SELECT count(*)
FROM qp_list_headers_b qph, qp_currency_lists_b qpc
WHERE qph.active_flag = 'Y' and qpc.currency_header_id = p_cache_key and qph.currency_code = qpc.base_currency_code;

-- cursor rewritten for sql repository exercise
CURSOR currency_line_csr(p_cache_key varchar2) IS
SELECT count(*)
FROM   qp_currency_details qpd
WHERE  exists
       (select 'X' from qp_list_headers_b
        where list_type_code in ('AGR', 'PRL')
        and active_flag = 'Y'
        and currency_header_id = p_cache_key)
AND    qpd.currency_header_id = p_cache_key;

CURSOR do_size_csr IS
SELECT
do_name,
do_size
FROM qp_cache_do_sizes
order by do_name;

l_cache_key_header_tbl number_tbl_type;
l_cache_key_attr_tbl varchar1000_tbl_type;
l_cache_key_val_tbl varchar1000_tbl_type;
l_do_type_tbl varchar30_tbl_type;
l_do_size_tbl number_tbl_type;
l_cache_key_size_tbl number_tbl_type;

l_cache_type_tbl varchar30_tbl_type;
l_cache_size_tbl number_tbl_type;
l_creation_date_final_tbl     date_tbl_type;
l_created_by_final_tbl        number_tbl_type;
l_last_update_date_final_tbl  date_tbl_type;
l_last_updated_by_final_tbl   number_tbl_type;
l_last_update_login_final_tbl number_tbl_type;
l_program_appl_id_final_tbl   number_tbl_type;
l_program_id_final_tbl        number_tbl_type;
l_program_upd_date_final_tbl  date_tbl_type;
l_request_id_final_tbl        number_tbl_type;

l_total_cache_key_size number_tbl_type;
l_perm_cache_key_size number := 0;

l_max_cache_key_size number_tbl_type;
l_max_cache_key_header number_tbl_type;
l_max_cache_key_val varchar240_tbl_type;

l_ondemand_size number;
l_full_size number;
l_perm_full_size number;
l_perm_partial_size number;
l_perm_size number;
l_min_size number;

l_avg_cache_key_size number_tbl_type;

l_cache_key_cnt number;
l_cache_key_pool_cnt number;
l_cache_key_increment number;
l_cache_key_max number := 50;
l_i number := 1;
l_calc_cnt number;
l_cnt number;

-- cache-key types
L_MODIFIER_CACHE_KEY    CONSTANT NUMBER := 0;
L_PRICE_CACHE_KEY       CONSTANT NUMBER := 1;
L_FORMULA_CACHE_KEY     CONSTANT NUMBER := 2;
L_FACTOR_CACHE_KEY      CONSTANT NUMBER := 3;
L_UOM_CACHE_KEY         CONSTANT NUMBER := 4;
L_CURRENCY_CACHE_KEY    CONSTANT NUMBER := 5;
L_LAST_CACHE_KEY        CONSTANT NUMBER := 5;

-- data object sizes
l_pattern_size number;
l_segment_size number;
l_request_source_size number;
l_event_phase_size number;
l_profile_size number;
l_cache_do_size_size number;
l_cache_stat_size number;
l_header_size number;
l_second_price_list_size number;
l_header_attr_size number;
l_header_ph_size number;
l_pattern_ph_size number;
l_okc_uom_size number;
l_okc_time_unit_size number;
l_cache_key_stat_size number;
l_line_size number;
l_line_attr_grp_size number;
l_non_eq_attr_size number;
l_uom_size number;
l_uom_class_size number;
l_formula_size number;
l_formula_line_size number;
l_currency_size number;
l_currency_line_size number;

/* misc debug
l_line_attr_grp_cache_key_cnt number;
l_line_cnt number;
l_line_attr_grp_cnt number;
l_uom_cnt number;
*/

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  err_buff := '';
  retcode := 0;

  /*****************************************************************
   Retrieve data object sizes
  *****************************************************************/

  OPEN do_size_csr;
  FETCH do_size_csr bulk collect INTO
  	l_do_type_tbl,
  	l_do_size_tbl;
  CLOSE do_size_csr;

  for i in 1..l_do_type_tbl.last loop

    if (l_do_type_tbl(i) = 'PatternDO') then
      l_pattern_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'SegmentDO') then
      l_segment_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'RequestSourceDO') then
      l_request_source_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'EventPhaseDO') then
      l_event_phase_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'ProfileDO') then
      l_profile_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'CacheDOSizeDO') then
      l_cache_do_size_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'CacheStatDO') then
      l_cache_stat_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'HeaderDO') then
      l_header_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'SecondPriceListDO') then
      l_second_price_list_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'HeaderAttrGrpDO') then
      l_header_attr_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'HeaderPhDO') then
      l_header_ph_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'PatternPhDO') then
      l_pattern_ph_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'OKCUOMDO') then
      l_okc_uom_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'OKCTimeUnitDO') then
      l_okc_time_unit_size := l_do_size_tbl(i);

    elsif (l_do_type_tbl(i) = 'LineDO') then
      l_line_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'UOMDO') then
      l_uom_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'UOMClassDO') then
      l_uom_class_size := l_do_size_tbl(i);

    elsif (l_do_type_tbl(i) = 'NonEqAttrDO') then
      l_non_eq_attr_size := l_do_size_tbl(i);

    elsif (l_do_type_tbl(i) = 'CacheKeyStatDO') then
      l_cache_key_stat_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'LineAttrGrpDO') then
     l_line_attr_grp_size := l_do_size_tbl(i);

    elsif (l_do_type_tbl(i) = 'FormulaDO') then
      l_formula_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'FormulaLineDO') then
      l_formula_line_size := l_do_size_tbl(i);

    elsif (l_do_type_tbl(i) = 'CurrencyDO') then
      l_currency_size := l_do_size_tbl(i);
    elsif (l_do_type_tbl(i) = 'CurrencyLineDO') then
      l_currency_line_size := l_do_size_tbl(i);
    END if;
  END loop;

  /*****************************************************************
   Calculate on-demand cache statistics
     - populate l_avg_cache_key_size(ck_type)
     - populate l_max_cache_key_size(ck_type)
     - populate l_total_cache_key_size(ck_type)
  *****************************************************************/

  for ck_type in 0..L_LAST_CACHE_KEY loop
    l_total_cache_key_size(ck_type) := 0;
    l_max_cache_key_size(ck_type) := 0;
    l_max_cache_key_header(ck_type) := 0;
    l_max_cache_key_val(ck_type) := 'none';
    l_avg_cache_key_size(ck_type) := 0;
  END loop;

  for ck_type in 0..l_max_cache_key_size.last loop

    l_total_cache_key_size(ck_type) := 0;
    l_cache_key_val_tbl.delete;

    -- get pool of cache-keys
    if (ck_type = L_MODIFIER_CACHE_KEY) then
      OPEN modifier_cache_key_csr;
      FETCH modifier_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE modifier_cache_key_csr;
    elsif (ck_type = L_PRICE_CACHE_KEY) then
      OPEN price_cache_key_csr;
      FETCH price_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE price_cache_key_csr;
    elsif (ck_type = L_FORMULA_CACHE_KEY) then
      OPEN formula_cache_key_csr;
      FETCH formula_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE formula_cache_key_csr;
    elsif (ck_type = L_FACTOR_CACHE_KEY) then
      OPEN factor_cache_key_csr;
      FETCH factor_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE factor_cache_key_csr;
    elsif (ck_type = L_UOM_CACHE_KEY) then
      OPEN uom_cache_key_csr;
      FETCH uom_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE uom_cache_key_csr;
    elsif (ck_type = L_CURRENCY_CACHE_KEY) then
      OPEN currency_cache_key_csr;
      FETCH currency_cache_key_csr bulk collect INTO
            l_cache_key_val_tbl;
      CLOSE currency_cache_key_csr;
    END if;

    -- get count
    if (ck_type = L_MODIFIER_CACHE_KEY) then
      OPEN modifier_cache_key_cnt_csr;
      FETCH modifier_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE modifier_cache_key_cnt_csr;
    elsif (ck_type = L_PRICE_CACHE_KEY) then
      OPEN price_cache_key_cnt_csr;
      FETCH price_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE price_cache_key_cnt_csr;
    elsif (ck_type = L_FORMULA_CACHE_KEY) then
      OPEN formula_cache_key_cnt_csr;
      FETCH formula_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE formula_cache_key_cnt_csr;
    elsif (ck_type = L_FACTOR_CACHE_KEY) then
      OPEN factor_cache_key_cnt_csr;
      FETCH factor_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE factor_cache_key_cnt_csr;
    elsif (ck_type = L_UOM_CACHE_KEY) then
      OPEN uom_cache_key_cnt_csr;
      FETCH uom_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE uom_cache_key_cnt_csr;
    elsif (ck_type = L_CURRENCY_CACHE_KEY) then
      OPEN currency_cache_key_cnt_csr;
      FETCH currency_cache_key_cnt_csr  INTO
            l_cache_key_cnt;
      CLOSE currency_cache_key_cnt_csr;
    END if;

    l_cache_key_pool_cnt := l_cache_key_val_tbl.count;
    l_cache_key_increment := round(l_cache_key_pool_cnt / l_cache_key_max, 0);
    if (l_cache_key_increment < 1) then
      l_cache_key_increment := 1;
    END if;
    l_calc_cnt := 0;

    l_cache_key_size_tbl.delete;

    if (l_cache_key_pool_cnt > 0) then

      l_i := 1;
      while (l_i <= l_cache_key_val_tbl.last) loop
        --dbms_output.put_line('i: ' || l_i);
        l_cache_key_size_tbl(l_i) := 0;
        l_calc_cnt := l_calc_cnt + 1;

        if (ck_type in (L_MODIFIER_CACHE_KEY, L_PRICE_CACHE_KEY, L_FACTOR_CACHE_KEY)) then
          OPEN line_csr(l_cache_key_val_tbl(l_i));
          FETCH line_csr INTO l_cnt;
          CLOSE line_csr;
          --dbms_output.put_line('a l_cnt: ('||l_cache_key_val_tbl(l_i)||') '||l_cnt);
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_line_size);

          OPEN line_attr_grp_csr(l_cache_key_val_tbl(l_i));
          FETCH line_attr_grp_csr INTO l_cnt;
          CLOSE line_attr_grp_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_line_attr_grp_size);

          OPEN non_eq_attr_csr(l_cache_key_val_tbl(l_i));
          FETCH non_eq_attr_csr INTO l_cnt;
          CLOSE non_eq_attr_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_non_eq_attr_size);

          -- julin: debug
          /*if (l_cache_key_header_tbl(l_i) = 1000 and l_cache_key_val_tbl(l_i) = '474') then
            dbms_output.put_line('l_line_cnt: ' || l_line_cnt);
            dbms_output.put_line('l_line_attr_grp_cnt: ' || l_line_attr_grp_cnt);
            dbms_output.put_line('l_line_attr_grp_cache_key_cnt: ' || l_line_attr_grp_cache_key_cnt);
            dbms_output.put_line('l_uom_cnt: ' || l_uom_cnt);
          end if;
          if (l_cache_key_val_tbl(l_i) = '1000|PRICING_ATTRIBUTE1|149') then
            dbms_output.put_line('l_cache_key_size_tbl(l_i): ' || l_cache_key_size_tbl(l_i));
          end if;
          */

          -- julin: why null?
          /*if (l_cache_key_val_tbl(l_i) is null or
              (l_cache_key_attr_tbl(l_i) = 'PRICING_ATTRIBUTE3' and l_cache_key_val_tbl(l_i) = 'ALL')) then
            l_perm_cache_key_size := l_perm_cache_key_size + l_cache_key_size_tbl(l_i);
            l_perm_cache_key_cnt := l_perm_cache_key_cnt + 1;
          else
            l_total_cache_key_size(ck_type) := l_total_cache_key_size(ck_type) + l_cache_key_size_tbl(l_i);
            if (l_cache_key_size_tbl(l_i) > l_max_cache_key_size(ck_type)) then
              l_max_cache_key_size(ck_type) := l_cache_key_size_tbl(l_i);
              l_max_cache_key_header(ck_type) := l_cache_key_header_tbl(l_i);
              l_max_cache_key_val(ck_type) := l_cache_key_val_tbl(l_i);
            end if;
          end if;
          */

        elsif (ck_type = L_FORMULA_CACHE_KEY) then
          OPEN formula_csr(l_cache_key_val_tbl(l_i));
          FETCH formula_csr INTO l_cnt;
          CLOSE formula_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_formula_size);

          OPEN formula_line_csr(l_cache_key_val_tbl(l_i));
          FETCH formula_line_csr INTO l_cnt;
          CLOSE formula_line_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_formula_line_size);

        elsif (ck_type = L_UOM_CACHE_KEY) then
          OPEN uom_csr(l_cache_key_val_tbl(l_i));
          FETCH uom_csr INTO l_cnt;
          CLOSE uom_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_uom_size);

          OPEN uom_class_csr(l_cache_key_val_tbl(l_i));
          FETCH uom_class_csr INTO l_cnt;
          CLOSE uom_class_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_uom_class_size);

        elsif (ck_type = L_CURRENCY_CACHE_KEY) then

          OPEN currency_csr(l_cache_key_val_tbl(l_i));
          FETCH currency_csr INTO l_cnt;
          CLOSE currency_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_currency_size);

          OPEN currency_line_csr(l_cache_key_val_tbl(l_i));
          FETCH currency_line_csr INTO l_cnt;
          CLOSE currency_line_csr;
          l_cache_key_size_tbl(l_i) := l_cache_key_size_tbl(l_i) + (l_cnt*l_currency_line_size);

        END if;

        l_total_cache_key_size(ck_type) := l_total_cache_key_size(ck_type) + l_cache_key_size_tbl(l_i);
        if (l_cache_key_size_tbl(l_i) > l_max_cache_key_size(ck_type)) then
          l_max_cache_key_size(ck_type) := l_cache_key_size_tbl(l_i);
          l_max_cache_key_val(ck_type) := l_cache_key_val_tbl(l_i);
        END if;

        l_i := l_i + l_cache_key_increment;
      END loop; -- cache-keys

      l_avg_cache_key_size(ck_type) := round(l_total_cache_key_size(ck_type)/l_calc_cnt);
      l_total_cache_key_size(ck_type) := l_avg_cache_key_size(ck_type) * l_cache_key_cnt;

      /* julin: debug
      IF l_debug = FND_API.G_TRUE THEN
        dbms_output.put_line('ck_type: ' || ck_type);
        dbms_output.put_line('l_cache_key_stat_cnt: ' || l_cache_key_stat_cnt);
        dbms_output.put_line('l_cache_key_increment: ' || l_cache_key_increment);
        dbms_output.put_line('l_max_cache_key_size(ck_type): ' || l_max_cache_key_size(ck_type));
        dbms_output.put_line('l_max_cache_key_val(ck_type): ' || l_max_cache_key_val(ck_type));
        dbms_output.put_line('l_avg_cache_key_size(ck_type): ' || l_avg_cache_key_size(ck_type));
      END IF;
      */

    END if;

  END loop; -- ck_type

  /*****************************************************************
   Calculate permanent full cache statistics
     - populate l_perm_full_size
  *****************************************************************/

  l_perm_full_size := 0;

  OPEN pattern_csr;
  FETCH pattern_csr INTO l_cnt;
  CLOSE pattern_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_pattern_size);

  OPEN segment_csr;
  FETCH segment_csr INTO l_cnt;
  CLOSE segment_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_segment_size);

  OPEN request_source_csr;
  FETCH request_source_csr INTO l_cnt;
  CLOSE request_source_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_request_source_size);

  OPEN event_phase_csr;
  FETCH event_phase_csr INTO l_cnt;
  CLOSE event_phase_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_event_phase_size);

  OPEN profile_csr;
  FETCH profile_csr INTO l_cnt;
  CLOSE profile_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_profile_size);

  OPEN cache_do_size_csr;
  FETCH cache_do_size_csr INTO l_cnt;
  CLOSE cache_do_size_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_cache_do_size_size);

  OPEN cache_stat_csr;
  FETCH cache_stat_csr INTO l_cnt;
  CLOSE cache_stat_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_cache_stat_size);

  OPEN header_csr;
  FETCH header_csr INTO l_cnt;
  CLOSE header_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_header_size);

  OPEN second_price_list_csr;
  FETCH second_price_list_csr INTO l_cnt;
  CLOSE second_price_list_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_second_price_list_size);

  OPEN header_attr_csr;
  FETCH header_attr_csr INTO l_cnt;
  CLOSE header_attr_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_header_attr_size);

  OPEN header_ph_csr;
  FETCH header_ph_csr INTO l_cnt;
  CLOSE header_ph_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_header_ph_size);

  OPEN pattern_ph_csr;
  FETCH pattern_ph_csr INTO l_cnt;
  CLOSE pattern_ph_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_pattern_ph_size);

  OPEN okc_uom_csr;
  FETCH okc_uom_csr INTO l_cnt;
  CLOSE okc_uom_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_okc_uom_size);

  OPEN okc_time_unit_csr;
  FETCH okc_time_unit_csr INTO l_cnt;
  CLOSE okc_time_unit_csr;
  l_perm_full_size := l_perm_full_size + (l_cnt * l_okc_time_unit_size);

  /*****************************************************************
   Calculate permanent partial cache statistics
     - populate l_perm_full_size
  *****************************************************************/

  l_perm_partial_size := 0;

  OPEN line_perm_csr;
  FETCH line_perm_csr INTO l_cnt;
  CLOSE line_perm_csr;
  l_perm_partial_size := l_perm_partial_size + (l_cnt * l_line_size);

  OPEN uom_perm_csr;
  FETCH uom_perm_csr INTO l_cnt;
  CLOSE uom_perm_csr;
  l_perm_partial_size := l_perm_partial_size + (l_cnt * l_uom_size);


  /*****************************************************************
   Calculate aggregate statistics
     - populate l_perm_size
     - populate l_full_size
     - populate l_min_size
  *****************************************************************/

  l_perm_size := l_perm_full_size + l_perm_partial_size;

  l_ondemand_size := l_total_cache_key_size(L_MODIFIER_CACHE_KEY) +
                     l_total_cache_key_size(L_PRICE_CACHE_KEY) +
                     l_total_cache_key_size(L_FORMULA_CACHE_KEY) +
                     l_total_cache_key_size(L_FACTOR_CACHE_KEY) +
                     l_total_cache_key_size(L_UOM_CACHE_KEY) +
                     l_total_cache_key_size(L_CURRENCY_CACHE_KEY);

  l_full_size := l_perm_size + l_ondemand_size;
  l_min_size := l_perm_size + greatest(l_max_cache_key_size(L_MODIFIER_CACHE_KEY), l_max_cache_key_size(L_PRICE_CACHE_KEY), l_max_cache_key_size(L_FORMULA_CACHE_KEY), l_max_cache_key_size(L_FACTOR_CACHE_KEY));


  /*****************************************************************
   Insert into qp_cache_stats;
  *****************************************************************/

  l_cache_type_tbl(1) := 'FULL_SIZE';
  l_cache_size_tbl(1) := l_full_size;

  l_cache_type_tbl(2) := 'MIN_SIZE';
  l_cache_size_tbl(2) := l_min_size;

  l_cache_type_tbl(3) := 'PERM_SIZE';
  l_cache_size_tbl(3) := l_perm_size;

  l_cache_type_tbl(4) := 'PERM_FULL_SIZE';
  l_cache_size_tbl(4) := l_perm_full_size;

  l_cache_type_tbl(5) := 'ON_DEMAND_SIZE';
  l_cache_size_tbl(5) := l_ondemand_size;

  l_cache_type_tbl(6) := 'CACHE_KEY_MODIFIER_MAX_SIZE';
  l_cache_size_tbl(6) := l_max_cache_key_size(L_MODIFIER_CACHE_KEY);

  l_cache_type_tbl(7) := 'CACHE_KEY_MODIFIER_AVG_SIZE';
  l_cache_size_tbl(7) := l_avg_cache_key_size(L_MODIFIER_CACHE_KEY);

  l_cache_type_tbl(8) := 'CACHE_KEY_PRICE_MAX_SIZE';
  l_cache_size_tbl(8) := l_max_cache_key_size(L_PRICE_CACHE_KEY);

  l_cache_type_tbl(9) := 'CACHE_KEY_PRICE_AVG_SIZE';
  l_cache_size_tbl(9) := l_avg_cache_key_size(L_PRICE_CACHE_KEY);

  l_cache_type_tbl(10) := 'CACHE_KEY_FORMULA_MAX_SIZE';
  l_cache_size_tbl(10) := l_max_cache_key_size(L_FORMULA_CACHE_KEY);

  l_cache_type_tbl(11) := 'CACHE_KEY_FORMULA_AVG_SIZE';
  l_cache_size_tbl(11) := l_avg_cache_key_size(L_FORMULA_CACHE_KEY);

  l_cache_type_tbl(12) := 'CACHE_KEY_FACTOR_MAX_SIZE';
  l_cache_size_tbl(12) := l_max_cache_key_size(L_FACTOR_CACHE_KEY);

  l_cache_type_tbl(13) := 'CACHE_KEY_FACTOR_AVG_SIZE';
  l_cache_size_tbl(13) := l_avg_cache_key_size(L_FACTOR_CACHE_KEY);

  l_cache_type_tbl(14) := 'CACHE_KEY_UOM_MAX_SIZE';
  l_cache_size_tbl(14) := l_max_cache_key_size(L_UOM_CACHE_KEY);

  l_cache_type_tbl(15) := 'CACHE_KEY_UOM_AVG_SIZE';
  l_cache_size_tbl(15) := l_avg_cache_key_size(L_UOM_CACHE_KEY);

  l_cache_type_tbl(16) := 'CACHE_KEY_CURRENCY_MAX_SIZE';
  l_cache_size_tbl(16) := l_max_cache_key_size(L_CURRENCY_CACHE_KEY);

  l_cache_type_tbl(17) := 'CACHE_KEY_CURRENCY_AVG_SIZE';
  l_cache_size_tbl(17) := l_avg_cache_key_size(L_CURRENCY_CACHE_KEY);

  l_cache_type_tbl(18) := 'CACHE_KEY_MODIFIER_TOTAL_SIZE';
  l_cache_size_tbl(18) := l_total_cache_key_size(L_MODIFIER_CACHE_KEY);

  -- populate WHO columns
  FOR i IN 1..l_cache_type_tbl.last loop
    l_creation_date_final_tbl(i) := sysdate;
    l_created_by_final_tbl(i) := FND_GLOBAL.USER_ID;
    l_last_update_date_final_tbl(i) := sysdate;
    l_last_updated_by_final_tbl(i) := FND_GLOBAL.USER_ID;
    l_last_update_login_final_tbl(i) := FND_GLOBAL.LOGIN_ID;
    l_program_appl_id_final_tbl(i) := FND_GLOBAL.PROG_APPL_ID;
    l_program_id_final_tbl(i) := FND_GLOBAL.CONC_PROGRAM_ID;
    l_program_upd_date_final_tbl(i) := sysdate;
    l_request_id_final_tbl(i) := FND_GLOBAL.CONC_REQUEST_ID;
  END LOOP;

  DELETE FROM qp_cache_stats;

  forall i in 1..l_cache_type_tbl.last
    INSERT INTO qp_cache_stats (
      name,
      value,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID)
    VALUES (
      l_cache_type_tbl(i),
      l_cache_size_tbl(i),
      l_creation_date_final_tbl(i),
      l_created_by_final_tbl(i),
      l_last_update_date_final_tbl(i),
      l_last_updated_by_final_tbl(i),
      l_last_update_login_final_tbl(i),
      l_program_appl_id_final_tbl(i),
      l_program_id_final_tbl(i),
      l_program_upd_date_final_tbl(i),
      l_request_id_final_tbl(i)
    );
  commit;

EXCEPTION
  WHEN OTHERS THEN
    err_buff := sqlerrm;
    retcode := 2;
END UPDATE_CACHE_STATS;

/*
PROCEDURE UPDATE_CAT_NO_PROD_PRICING IS

CURSOR cat_no_prod_mod_csr IS
SELECT DISTINCT 'M', category_id
FROM mtl_item_categories ic
WHERE NOT EXISTS (SELECT 1
                  FROM qp_pricing_attributes pa, qp_list_lines ll
                  WHERE pa.product_attribute_context = 'ITEM' and
                        pa.product_attribute = 'PRICING_ATTRIBUTE1' and
                        pa.product_attr_value = to_char(ic.inventory_item_id) and
                        ll.list_line_id = pa.list_line_id and
                        ll.list_line_type_code not in ('PLL'));

CURSOR cat_no_prod_price_csr IS
SELECT DISTINCT 'P', category_id
FROM mtl_item_categories ic
WHERE NOT EXISTS (SELECT 1
                  FROM qp_pricing_attributes pa, qp_list_lines ll
                  WHERE pa.product_attribute_context = 'ITEM' and
                        pa.product_attribute = 'PRICING_ATTRIBUTE1' and
                        pa.product_attr_value = to_char(ic.inventory_item_id) and
                        ll.list_line_id = pa.list_line_id and
                        ll.list_line_type_code in ('PLL'));

l_cat_no_prod_mod_tbl varchar240_tbl_type;
l_cat_no_prod_price_tbl varchar240_tbl_type;
l_cat_no_prod_type_tbl varchar240_tbl_type;
l_cat_no_prod_cat_tbl number_tbl_type;

BEGIN

  IF l_debug = FND_API.G_TRUE THEN
    dbms_output.put_line('qp_java_engine_cache_pub.update_cat_no_prod_pricing');
  END IF;

  DELETE FROM qp_cache_cat_no_prod_pricing;

  OPEN cat_no_prod_mod_csr;
  FETCH cat_no_prod_mod_csr bulk collect INTO
    l_cat_no_prod_type_tbl,
    l_cat_no_prod_cat_tbl;
  CLOSE cat_no_prod_mod_csr;

  IF l_debug = FND_API.G_TRUE THEN
    dbms_output.put_line('l_cat_no_prod_type_tbl: ' || l_cat_no_prod_type_tbl.count);
  END IF;

  forall i in 1..l_cat_no_prod_type_tbl.last
    INSERT INTO qp_cache_cat_no_prod_pricing (
      cache_type,
      category_id)
    VALUES (
       l_cat_no_prod_type_tbl(i),
       l_cat_no_prod_cat_tbl(i)
    );

  OPEN cat_no_prod_price_csr;
  FETCH cat_no_prod_price_csr bulk collect INTO
    l_cat_no_prod_type_tbl,
    l_cat_no_prod_cat_tbl;
  CLOSE cat_no_prod_price_csr;

  IF l_debug = FND_API.G_TRUE THEN
    dbms_output.put_line('l_cat_no_prod_type_tbl: ' || l_cat_no_prod_type_tbl.count);
  END IF;

  forall i in 1..l_cat_no_prod_type_tbl.last
    INSERT INTO qp_cache_cat_no_prod_pricing (
      cache_type,
      category_id)
    VALUES (
      l_cat_no_prod_type_tbl(i),
      l_cat_no_prod_cat_tbl(i)
    );

  commit;

END UPDATE_CAT_NO_PROD_PRICING;
*/

PROCEDURE WARM_UP
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER
)
is
l_routine             VARCHAR2(240):='QP_JAVA_ENGINE_CACHE_PVT.WARM_UP';
l_output_file         VARCHAR2(240);
l_debug               VARCHAR2(3);
l_url_param_string    VARCHAR2(240);
l_return_status       VARCHAR2(240);
l_return_status_text  VARCHAR2(240);
JAVA_ENGINE_NOT_RUNNING_ERROR EXCEPTION;
E_ROUTINE_ERRORS EXCEPTION;

BEGIN

  synchronize(err_buff             => err_buff,
              retcode              => retcode,
              p_list_header_id     => -1,
              p_price_formula_id   => -1,
              p_currency_header_id => -1,
              p_all_others         => 'N',
              p_full_cache         => 'N' );

  IF (retcode = 0) THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_WARMUP_SUCCESS');
    err_buff := FND_MESSAGE.GET;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_CACHE_ERROR');
    err_buff := err_buff || FND_MESSAGE.GET;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_routine);
    retcode := 2;
END WARM_UP;

PROCEDURE SYNCHRONIZE
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER,
 p_list_header_id NUMBER,
 p_price_formula_id NUMBER,
 p_currency_header_id NUMBER,
 p_all_others VARCHAR2,
 p_full_cache VARCHAR2
)
IS
L_MAX_STATUS_REQUESTS        NUMBER:=240;
L_STATUS_REQUEST_INTERVAL    NUMBER:=15;   -- seconds
L_TRANSFER_TIMEOUT           NUMBER:=3600; -- seconds
l_routine             VARCHAR2(240):='[QP_JAVA_ENGINE_CACHE_PVT.SYNCHRONIZE]';
l_output_file         VARCHAR2(240);
l_debug               VARCHAR2(3);
l_url_param_string    VARCHAR2(240);
l_return_status       VARCHAR2(240);
l_return_status_text  VARCHAR2(2000);
l_status_request_cnt  NUMBER;
NO_PARAMS_ERROR EXCEPTION;
E_ROUTINE_ERRORS EXCEPTION;
JAVA_ENGINE_NOT_RUNNING_ERROR EXCEPTION;
MAX_STATUS_REQUESTS_REACHED EXCEPTION;

BEGIN

  QP_PREQ_GRP.Set_QP_Debug;
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
    l_output_file := OE_DEBUG_PUB.SET_DEBUG_MODE('FILE');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'The output file is : ' || l_output_file );
  END IF;

  IF (QP_JAVA_ENGINE_UTIL_PUB.JAVA_ENGINE_RUNNING <> 'Y') THEN
    RAISE JAVA_ENGINE_NOT_RUNNING_ERROR;
  END IF;

  IF (p_list_header_id IS NULL AND
      p_price_formula_id IS NULL AND
      p_currency_header_id IS NULL AND
      p_all_others IS NULL AND
      p_full_cache IS NULL) THEN
    RAISE NO_PARAMS_ERROR;
  END IF;

  --update_cache_stats;
  update_cache_stats(
    err_buff,
    retcode
  );
  if (err_buff <> '' or retcode <> 0) then
    return;
  end if;
  --update_cat_no_prod_pricing;

  l_url_param_string := 'Action=synchronize'||
    qp_java_engine_util_pub.G_HARD_CHAR||'concRequestId='||nvl(FND_GLOBAL.CONC_REQUEST_ID, -1)||
    qp_java_engine_util_pub.G_HARD_CHAR||'listHeaderId='||nvl(p_list_header_id, -1)||
    qp_java_engine_util_pub.G_HARD_CHAR||'priceFormulaId='||nvl(p_price_formula_id, -1)||
    qp_java_engine_util_pub.G_HARD_CHAR||'currencyHeaderId='||nvl(p_currency_header_id, -1)||
    qp_java_engine_util_pub.G_HARD_CHAR||'allOthers='||nvl(p_all_others, 'N')||
    qp_java_engine_util_pub.G_HARD_CHAR||'fullCache='||nvl(p_full_cache, 'N');
  qp_java_engine_util_pub.send_java_engine_request(l_url_param_string,
                                                   l_return_status,
                                                   l_return_status_text,
                                                   L_TRANSFER_TIMEOUT,
                                                   FND_API.G_TRUE);

  l_status_request_cnt := 0;
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_return_status_text = 'UTL_TCP.END_OF_INPUT') THEN
      LOOP
        DBMS_LOCK.SLEEP(L_STATUS_REQUEST_INTERVAL);
        l_url_param_string := 'Action=synchronize'||
          qp_java_engine_util_pub.G_HARD_CHAR||'concRequestId='||nvl(FND_GLOBAL.CONC_REQUEST_ID, -1)||
          qp_java_engine_util_pub.G_HARD_CHAR||'statusRequest=Y';
        qp_java_engine_util_pub.send_java_engine_request(l_url_param_string,
                                                         l_return_status,
                                                         l_return_status_text);
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE E_ROUTINE_ERRORS;
        END IF;
        EXIT WHEN l_return_status_text = 'COMPLETED';
        IF l_status_request_cnt > L_MAX_STATUS_REQUESTS THEN
          RAISE MAX_STATUS_REQUESTS_REACHED;
        END IF;
        l_status_request_cnt := l_status_request_cnt + 1;
      END LOOP;
    ELSE
      RAISE E_ROUTINE_ERRORS;
    END IF;
  END IF;

  FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_SYNC_SUCCESS');
  err_buff := FND_MESSAGE.GET;
  retcode := 0;

EXCEPTION
  WHEN JAVA_ENGINE_NOT_RUNNING_ERROR THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_NOT_RUNNING');
    err_buff := FND_MESSAGE.GET;
    retcode := 2;
  WHEN NO_PARAMS_ERROR THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_SYNC_PARAM_REQD');
    err_buff := FND_MESSAGE.GET;
    retcode := 2;
  WHEN E_ROUTINE_ERRORS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||'l_return_status_text:'||l_return_status_text);
      QP_PREQ_GRP.engine_debug(l_routine||'SQLERRM:'||SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_CACHE_ERROR');
    err_buff := '(' || l_return_status || ') ';
    err_buff := err_buff || FND_MESSAGE.GET;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_return_status_text );
    retcode := 2;
  WHEN MAX_STATUS_REQUESTS_REACHED THEN
    err_buff := 'Request has exceeded '||(L_MAX_STATUS_REQUESTS*L_STATUS_REQUEST_INTERVAL)||' seconds.';
    retcode := 1;
  WHEN OTHERS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||'l_return_status_text:'||l_return_status_text);
      QP_PREQ_GRP.engine_debug(l_routine||'SQLERRM:'||SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_CACHE_ERROR');
    err_buff := '(' || l_return_status || ') ';
    err_buff := err_buff || FND_MESSAGE.GET;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_return_status_text );
    retcode := 2;
END SYNCHRONIZE;

PROCEDURE MANAGE
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER,
 p_manage_action VARCHAR2,
 p_dump_type VARCHAR2,
 p_dump_input1 VARCHAR2,
 p_dump_input2 VARCHAR2,
 p_dump_input3 VARCHAR2
)
IS
l_routine             VARCHAR2(240):='QP_JAVA_ENGINE_CACHE_PVT.MANAGE';
l_output_file         VARCHAR2(240);
l_debug               VARCHAR2(3);
l_url_param_string    VARCHAR2(240);
l_return_status       VARCHAR2(240);
l_return_status_text  VARCHAR2(2000);
l_cr                  VARCHAR2(1);
JAVA_ENGINE_NOT_RUNNING_ERROR EXCEPTION;
E_ROUTINE_ERRORS EXCEPTION;
l_return_details UTL_HTTP.HTML_PIECES;
BEGIN

  retcode := 0;

  IF (p_manage_action = 'WARM_UP') THEN
    synchronize(err_buff             => err_buff,
                retcode              => retcode,
                p_list_header_id     => -1,
                p_price_formula_id   => -1,
                p_currency_header_id => -1,
                p_all_others         => 'N',
                p_full_cache         => 'N' );
  ELSE
    QP_PREQ_GRP.Set_QP_Debug;
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      l_output_file := OE_DEBUG_PUB.SET_DEBUG_MODE('FILE');
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'The output file is : ' || l_output_file );
    END IF;

    IF (QP_JAVA_ENGINE_UTIL_PUB.JAVA_ENGINE_RUNNING <> 'Y') THEN
      RAISE JAVA_ENGINE_NOT_RUNNING_ERROR;
    END IF;

    l_url_param_string := 'Action=manage'||
         qp_java_engine_util_pub.G_HARD_CHAR||'manageAction='||nvl(p_manage_action, '-1')||
         qp_java_engine_util_pub.G_HARD_CHAR||'dumpType='||nvl(p_dump_type, '-1')||
         qp_java_engine_util_pub.G_HARD_CHAR||'dumpInput1='||nvl(p_dump_input1, '-1')||
         qp_java_engine_util_pub.G_HARD_CHAR||'dumpInput2='||nvl(p_dump_input2, '-1')||
         qp_java_engine_util_pub.G_HARD_CHAR||'dumpInput3='||nvl(p_dump_input3, '-1');
    qp_java_engine_util_pub.send_java_engine_request(l_url_param_string,
                                                     l_return_status,
                                                     l_return_status_text,
                                                     l_return_details,
                                                     TRUE);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE E_ROUTINE_ERRORS;
    END IF;

    FND_FILE.NEW_LINE( FND_FILE.LOG );
    FOR i IN 1 .. l_return_details.count loop
      FND_FILE.PUT( FND_FILE.LOG, l_return_details(i) );
    END LOOP;
    FND_FILE.NEW_LINE( FND_FILE.LOG );

  END IF;

  IF (retcode = 0) THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_MANAGE_SUCCESS');
    err_buff := FND_MESSAGE.GET;
    retcode := 0;
  END IF;

EXCEPTION
  WHEN JAVA_ENGINE_NOT_RUNNING_ERROR THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_NOT_RUNNING');
    err_buff := FND_MESSAGE.GET;
    retcode := 2;
  WHEN E_ROUTINE_ERRORS THEN
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_CACHE_ERROR');
    err_buff := '(' || l_return_status || ') ';
    err_buff := err_buff || FND_MESSAGE.GET;
    --err_buff := err_buff || ' ' || l_return_status_text;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_return_status_text );
    retcode := 2;
  WHEN OTHERS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||' '||l_return_status_text);
    END IF;
    FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM);
    FND_MESSAGE.SET_NAME('QP','QP_JAVA_ENGINE_CACHE_ERROR');
    err_buff := '(' || l_return_status || ') ';
    err_buff := err_buff || FND_MESSAGE.GET;
    --err_buff := err_buff || ' ' || l_return_status_text;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_return_status_text );
    retcode := 2;
END MANAGE;

END QP_JAVA_ENGINE_CACHE_PVT;


/
