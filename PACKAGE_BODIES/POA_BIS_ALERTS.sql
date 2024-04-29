--------------------------------------------------------
--  DDL for Package Body POA_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_BIS_ALERTS" AS
/* $Header: poaalrtb.pls 115.9 2003/03/15 00:22:54 jhou ship $ */

PROCEDURE get_target_value(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_time_period IN VARCHAR2,
p_org_id IN NUMBER,
p_found OUT NOCOPY BOOLEAN,
p_target_value OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type) IS
l_index NUMBER := 0;
CURSOR cr_target IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_short_name
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id = p_time_period
  AND tv.org_level_value_id = TO_CHAR(p_org_id)
  AND tv.plan_short_name = p_plan_short_name;
BEGIN
  OPEN cr_target;
  FETCH cr_target INTO
    p_target_value.target_level_short_name,
    p_target_value.target_level_name,
    p_target_value.target_level_id,
    p_target_value.plan_short_name,
    p_target_value.plan_name,
    p_target_value.org_level_value_id,
    p_target_value.time_level_value_id,
    p_target_value.target,
    p_target_value.range1_low,
    p_target_value.range1_high,
    p_target_value.range2_low,
    p_target_value.range2_high,
    p_target_value.range3_low,
    p_target_value.range3_high,
    p_target_value.notify_resp1_id,
    p_target_value.notify_resp1_short_name,
    p_target_value.notify_resp2_id,
    p_target_value.notify_resp2_short_name,
    p_target_value.notify_resp3_id,
    p_target_value.notify_resp3_short_name;
    p_found := (cr_target%FOUND);
  CLOSE cr_target;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting target values:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    RAISE;
END get_target_value;

PROCEDURE get_target_orgs(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_target_orgs OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_Type) IS
l_index NUMBER := 0;
CURSOR cr_target_org IS
  SELECT  distinct(org_level_value_id) org_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.plan_short_name = p_plan_short_name;
BEGIN

  FOR cr IN cr_target_org LOOP
    l_index := l_index + 1;
    p_target_orgs(l_index).org_level_value_id := cr.org_id;
  END LOOP;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting organizations with targets defined:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    RAISE;
END get_target_orgs;

PROCEDURE get_gl_info(
p_org_id IN NUMBER,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2) IS
l_sob_id NUMBER;
l_period_set_name VARCHAR2(15);
x_progress VARCHAR2(3);
BEGIN
  x_progress := '001';

  IF (p_org_id = -1) THEN
    l_sob_id := fnd_profile.value('GL_SET_OF_BKS_ID');
  ELSE
    SELECT to_number(org_information1) INTO l_sob_id
    FROM hr_organization_information
    WHERE organization_id = p_org_id
    AND org_information_context = 'Accounting Information';
  END IF;

  x_progress := '002';

  SELECT period_set_name, currency_code, accounted_period_type
  INTO p_period_set_name, p_currency, p_period_type
  FROM gl_sets_of_books
  WHERE set_of_books_id = l_sob_id;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting GL information:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm || ': ' || x_progress);
    RAISE;
END get_gl_info;

PROCEDURE get_period_info(
p_org_id IN NUMBER,
p_for_current_period IN BOOLEAN,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2) IS
BEGIN

  IF p_for_current_period THEN
    get_current_period_info(p_org_id, p_start_date, p_end_date,
                            p_period_name, p_period_set_name, p_currency,
                            p_period_type);
  ELSE
    get_previous_period_info(p_org_id, p_start_date, p_end_date,
                             p_period_name, p_period_set_name, p_currency,
                             p_period_type);
  END IF;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting period information:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END get_period_info;

PROCEDURE get_current_period_info(
p_org_id IN NUMBER,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2) IS
l_sob_id NUMBER;
l_period_type VARCHAR2(15);
BEGIN

  get_gl_info(p_org_id, p_period_set_name, p_currency, l_period_type);
  p_period_type := l_period_type;

  SELECT per.period_name, per.start_date, per.end_date
  INTO p_period_name, p_start_date, p_end_date
  FROM gl_periods per
  WHERE per.period_set_name = p_period_set_name
  AND per.period_type = l_period_type
  AND per.adjustment_period_flag = 'N'
  AND per.start_date <= TRUNC(sysdate)
  AND per.end_date >= TRUNC(sysdate);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting current GL period:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    RAISE;
END get_current_period_info;

PROCEDURE get_previous_period_info(
p_org_id IN NUMBER,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2) IS
l_sob_id NUMBER;
l_period_type VARCHAR2(15);
BEGIN

  get_gl_info(p_org_id, p_period_set_name, p_currency, l_period_type);
  p_period_type := l_period_type;

  SELECT per.period_name, per.start_date, per.end_date
  INTO p_period_name, p_start_date, p_end_date
  FROM gl_periods per
  WHERE per.period_set_name = p_period_set_name
  AND per.period_type = l_period_type
  AND per.adjustment_period_flag = 'N'
  AND per.end_date = (SELECT max(end_date)
                      FROM gl_periods per2
                      WHERE per2.period_set_name = p_period_set_name
                      AND per2.period_type = l_period_type
                      AND per2.adjustment_period_flag = 'N'
                      AND per2.end_date < TRUNC(sysdate));

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting previous GL period:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    RAISE;
END get_previous_period_info;

PROCEDURE get_value(
p_label IN VARCHAR2,
p_value_tbl IN POA_Label_Value_Tbl,
p_index OUT NOCOPY NUMBER,
p_heading OUT NOCOPY VARCHAR2,
p_value OUT NOCOPY VARCHAR2) IS
l_index NUMBER;
BEGIN
  FOR l_index IN 1..p_value_tbl.COUNT LOOP
    IF p_value_tbl(l_index).label = p_label THEN
      p_index := l_index;
      p_heading := p_value_tbl(l_index).heading;
      p_value := p_value_tbl(l_index).value;
      RETURN;
    END IF;
  END LOOP;

  p_index := to_number(NULL);
  p_value := FND_API.G_MISS_CHAR;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in get_value procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END get_value;

PROCEDURE set_value(
p_label IN VARCHAR2,
p_heading IN VARCHAR2,
p_value IN VARCHAR2,
p_value_tbl IN OUT NOCOPY POA_Label_Value_Tbl) IS
l_index NUMBER;
BEGIN
  FOR l_index IN 1..p_value_tbl.COUNT LOOP
    IF p_value_tbl(l_index).label = p_label THEN
      p_value_tbl(l_index).heading := p_heading;
      p_value_tbl(l_index).value := p_value;
      RETURN;
    END IF;
  END LOOP;
EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting period information:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END set_value;

PROCEDURE insert_row(
p_label IN VARCHAR2,
p_heading IN VARCHAR2,
p_value IN VARCHAR2,
p_value_tbl IN OUT NOCOPY POA_Label_Value_Tbl) IS
l_index NUMBER;
BEGIN
  l_index := p_value_tbl.COUNT + 1;
  p_value_tbl(l_index).label := p_label;
  p_value_tbl(l_index).heading := p_heading;
  p_value_tbl(l_index).value := p_value;
EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting period information:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END insert_row;

PROCEDURE get_actual_poactlkg_all_m(
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
l_leakage_percent VARCHAR2(120);
l_total_purchases VARCHAR2(120);
l_leakage_amount VARCHAR2(120);
l_potential_savings VARCHAR2(120);
l_format_mask VARCHAR2(120);
BEGIN
  l_format_mask := FND_CURRENCY.get_format_mask(p_currency, 25);

  SELECT
  TO_CHAR(DECODE(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  0,0,100*SUM(NVL(poa.pot_contract_amount,0) *NVL(gl.conversion_rate,1))/
  SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1))),
  POA_BIS_ALERTS.g_percent_mask),
  TO_CHAR(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.potential_saving,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.pot_contract_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask)
  INTO l_leakage_percent, l_total_purchases, l_potential_savings,
  l_leakage_amount
  FROM gl_daily_rates gl,
  poa_bis_savings poa
  WHERE gl.from_currency (+) = poa.currency_code
  AND gl.to_currency (+) = p_currency
  AND gl.conversion_date (+) = poa.rate_date
  AND gl.conversion_type (+) = NVL(poa.rate_type, 'Corporate')
  AND poa.purchase_creation_date < p_end_date + 1
  AND poa.purchase_creation_date >= p_start_date;

  insert_row('L_ACTUAL', fnd_message.get_string('PO', 'POA_ACTUAL'),
    l_leakage_percent, p_value_tbl);
  insert_row('L_CHAR_ATTR1',
    fnd_message.get_string('POA', 'POA_TOTAL_PURCHASES'),
    l_total_purchases, p_value_tbl);
  insert_row('L_CHAR_ATTR2',
    fnd_message.get_string('POA', 'POA_LEAKAGE'),
    l_leakage_amount, p_value_tbl);
  insert_row('L_CHAR_ATTR3',
    fnd_message.get_string('POA', 'POA_TOTAL_SAVINGS'),
    l_potential_savings, p_value_tbl);
  insert_row('L_CURRENCY',
    fnd_message.get_string('POA', 'POA_CURRENCY'), p_currency, p_value_tbl);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Actual:');
    POA_LOG.put_line('POACTLKG_ALL_M:' || sqlcode || ': ' || sqlerrm);
    RAISE;
END get_actual_poactlkg_all_m;

PROCEDURE get_actual_poactlkg_ou_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
l_leakage_percent VARCHAR2(120);
l_total_purchases VARCHAR2(120);
l_leakage_amount VARCHAR2(120);
l_potential_savings VARCHAR2(120);
l_format_mask VARCHAR2(120);
BEGIN
  l_format_mask := FND_CURRENCY.get_format_mask(p_currency, 25);

  SELECT
  TO_CHAR(DECODE(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  0,0,100*SUM(NVL(poa.pot_contract_amount,0) *NVL(gl.conversion_rate,1))/
  SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1))),
  POA_BIS_ALERTS.g_percent_mask),
  TO_CHAR(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.potential_saving,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.pot_contract_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask)
  INTO l_leakage_percent, l_total_purchases, l_potential_savings,
  l_leakage_amount
  FROM gl_daily_rates gl,
  poa_bis_savings poa
  WHERE gl.from_currency (+) = poa.currency_code
  AND gl.to_currency (+) = p_currency
  AND gl.conversion_date (+) = poa.rate_date
  AND gl.conversion_type (+) = NVL(poa.rate_type, 'Corporate')
  AND poa.operating_unit_id = p_org_id
  AND poa.purchase_creation_date < p_end_date + 1
  AND poa.purchase_creation_date >= p_start_date;

  insert_row('L_ACTUAL', fnd_message.get_string('PO', 'POA_ACTUAL'),
    l_leakage_percent, p_value_tbl);
  insert_row('L_CHAR_ATTR1',
    fnd_message.get_string('POA', 'POA_TOTAL_PURCHASES'),
    l_total_purchases, p_value_tbl);
  insert_row('L_CHAR_ATTR2',
    fnd_message.get_string('POA', 'POA_LEAKAGE'),
    l_leakage_amount, p_value_tbl);
  insert_row('L_CHAR_ATTR3',
    fnd_message.get_string('POA', 'POA_TOTAL_SAVINGS'),
    l_potential_savings, p_value_tbl);
  insert_row('L_CURRENCY',
    fnd_message.get_string('POA', 'POA_CURRENCY'), p_currency, p_value_tbl);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Actual:');
    POA_LOG.put_line('POACTLKG_OU_M:' || sqlcode || ': ' || sqlerrm);
    RAISE;
END get_actual_poactlkg_ou_m;

PROCEDURE get_actual_poactlkg_org_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
l_leakage_percent VARCHAR2(120);
l_total_purchases VARCHAR2(120);
l_leakage_amount VARCHAR2(120);
l_potential_savings VARCHAR2(120);
l_format_mask VARCHAR2(120);
BEGIN
  l_format_mask := FND_CURRENCY.get_format_mask(p_currency, 25);

  SELECT
  TO_CHAR(DECODE(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  0,0,100*SUM(NVL(poa.pot_contract_amount,0) *NVL(gl.conversion_rate,1))/
  SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1))),
  POA_BIS_ALERTS.g_percent_mask),
  TO_CHAR(SUM(NVL(poa.purchase_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.potential_saving,0)*NVL(gl.conversion_rate,1)),
  l_format_mask),
  TO_CHAR(SUM(NVL(poa.pot_contract_amount,0)*NVL(gl.conversion_rate,1)),
  l_format_mask)
  INTO l_leakage_percent, l_total_purchases, l_potential_savings,
  l_leakage_amount
  FROM gl_daily_rates gl,
  poa_bis_savings poa
  WHERE gl.from_currency (+) = poa.currency_code
  AND gl.to_currency (+) = p_currency
  AND gl.conversion_date (+) = poa.rate_date
  AND gl.conversion_type (+) = NVL(poa.rate_type, 'Corporate')
  AND poa.ship_to_organization_id = p_org_id
  AND poa.purchase_creation_date < p_end_date + 1
  AND poa.purchase_creation_date >= p_start_date;

  insert_row('L_ACTUAL', fnd_message.get_string('PO', 'POA_ACTUAL'),
    l_leakage_percent, p_value_tbl);
  insert_row('L_CHAR_ATTR1',
    fnd_message.get_string('POA', 'POA_TOTAL_PURCHASES'),
    l_total_purchases, p_value_tbl);
  insert_row('L_CHAR_ATTR2',
    fnd_message.get_string('POA', 'POA_LEAKAGE'),
    l_leakage_amount, p_value_tbl);
  insert_row('L_CHAR_ATTR3',
    fnd_message.get_string('POA', 'POA_TOTAL_SAVINGS'),
    l_potential_savings, p_value_tbl);
  insert_row('L_CURRENCY',
    fnd_message.get_string('POA', 'POA_CURRENCY'), p_currency, p_value_tbl);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Actual:');
    POA_LOG.put_line('POACTLKG_ORG_M:' || sqlcode || ': ' || sqlerrm);
    RAISE;
END get_actual_poactlkg_org_m;

PROCEDURE get_actual_poaspsal_ou_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
l_actual VARCHAR2(120);
BEGIN
  --The time dimension is set to a particular period
  --and the org dimension is set to a particular organization
  SELECT
  TO_CHAR(decode(sum(poa.sales_amount), NULL, 0,0,0,
  nvl(100*sum((poa.purchase_amount)*nvl(gl.conversion_rate,1))/
  nvl(sum((poa.sales_amount)*nvl(gl.conversion_rate,1)),1),0)),
  POA_BIS_ALERTS.g_percent_mask) Actual
  INTO l_actual
  FROM poa_purchase_sales_v poa,
  gl_daily_rates gl
  WHERE gl.from_currency (+) = poa.currency
  and gl.to_currency (+) = p_currency
  and gl.conversion_date (+) = poa.transaction_date
  and gl.conversion_type (+) = 'Corporate'
  and poa.transaction_date < p_end_date + 1
  and poa.transaction_date >= p_start_date
  and poa.ou_id = p_org_id;

  insert_row('L_ACTUAL', fnd_message.get_string('PO', 'POA_ACTUAL'),
    l_actual, p_value_tbl);
  insert_row('L_CURRENCY',
    fnd_message.get_string('POA', 'POA_CURRENCY'), p_currency, p_value_tbl);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Actual:');
    POA_LOG.put_line('POASPSAL_OU_M:' || sqlcode || ': ' || sqlerrm);
    RAISE;
END get_actual_poaspsal_ou_m;

PROCEDURE get_actual_poaspsal_all_m(
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
l_actual VARCHAR2(120);
BEGIN
  --The time dimension is set to a particular period
  --and the org dimension is set to a particular organization
  SELECT
  TO_CHAR(decode(sum(poa.sales_amount), NULL, 0,0,0,
  nvl(100*sum((poa.purchase_amount)*nvl(gl.conversion_rate,1))/
  nvl(sum((poa.sales_amount)*nvl(gl.conversion_rate,1)),1),0)),
  POA_BIS_ALERTS.g_percent_mask) Actual
  INTO l_actual
  FROM poa_purchase_sales_v poa,
  gl_daily_rates gl
  WHERE gl.from_currency (+) = poa.currency
  and gl.to_currency (+) = p_currency
  and gl.conversion_date (+) = poa.transaction_date
  and gl.conversion_type (+) = 'Corporate'
  and poa.transaction_date < p_end_date + 1
  and poa.transaction_date >= p_start_date;

  insert_row('L_ACTUAL', fnd_message.get_string('PO', 'POA_ACTUAL'),
    l_actual, p_value_tbl);
  insert_row('L_CURRENCY',
    fnd_message.get_string('POA', 'POA_CURRENCY'), p_currency, p_value_tbl);

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Actual:');
    POA_LOG.put_line('POASPSAL_ALL_M:' || sqlcode || ': ' || sqlerrm);
    RAISE;
END get_actual_poaspsal_all_m;

PROCEDURE get_actual(
p_target_level_short_name IN VARCHAR2,
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl) IS
BEGIN
  IF (p_target_level_short_name = 'POACTLKG_ALL_M') THEN
    get_actual_poactlkg_all_m(p_start_date, p_end_date, p_currency,
    p_value_tbl);
  ELSIF (p_target_level_short_name = 'POACTLKG_OU_M') THEN
    get_actual_poactlkg_ou_m(p_org_id, p_start_date, p_end_date, p_currency,
    p_value_tbl);
  ELSIF (p_target_level_short_name = 'POACTLKG_ORG_M') THEN
    get_actual_poactlkg_org_m(p_org_id, p_start_date, p_end_date,
    p_currency, p_value_tbl);
  ELSIF (p_target_level_short_name = 'POASPSAL_ALL_M') THEN
    get_actual_poaspsal_all_m(p_start_date, p_end_date, p_currency,
    p_value_tbl);
  ELSIF (p_target_level_short_name = 'POASPSAL_OU_M') THEN
    get_actual_poaspsal_ou_m(p_org_id, p_start_date, p_end_date, p_currency,
    p_value_tbl);
  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in get_actual procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END get_actual;

PROCEDURE get_report_param(
p_target_level_short_name IN VARCHAR2,
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_period_type IN VARCHAR2,
p_param OUT NOCOPY VARCHAR2) IS
l_default NUMBER := -9999;
BEGIN

  IF (p_target_level_short_name = 'POACTLKG_ALL_M') THEN
    p_param := 'p_comm_id=' || l_default ||
    '*p_period_type=' || p_period_type ||
    '*p_supp_id=' || l_default ||
    '*p_supp_is_valid=Y' ||
    '*p_org_id=' ||  l_default ||
    '*p_oper_id=' || l_default ||
    '*p_buyer_id=' || l_default ||
    '*p_view_dim=1' ||
    '*p_fdate=' || to_char(p_start_date, 'DD-MON-YYYY') ||
    '*p_tdate=' || to_char(p_end_date, 'DD-MON-YYYY') ||
    '*paramform=NO';
  ELSIF (p_target_level_short_name = 'POACTLKG_OU_M') THEN
    p_param :=  'p_comm_id=' || l_default ||
    '*p_period_type=' || p_period_type ||
    '*p_supp_id=' || l_default ||
    '*p_supp_is_valid=Y' ||
    '*p_org_id=' ||  l_default ||
    '*p_oper_id=' || to_char(p_org_id) ||
    '*p_buyer_id=' || l_default ||
    '*p_view_dim=1' ||
    '*p_fdate=' || to_char(p_start_date, 'DD-MON-YYYY') ||
    '*p_tdate=' || to_char(p_end_date, 'DD-MON-YYYY') ||
    '*paramform=NO';
  ELSIF (p_target_level_short_name = 'POACTLKG_ORG_M') THEN
    p_param :=  'p_comm_id=' || l_default ||
    '*p_period_type=' || p_period_type ||
    '*p_supp_id=' || l_default ||
    '*p_supp_is_valid=Y' ||
    '*p_org_id=' || to_char(p_org_id) ||
    '*p_oper_id=' ||  l_default ||
    '*p_buyer_id=' || l_default ||
    '*p_view_dim=1' ||
    '*p_fdate=' || to_char(p_start_date, 'DD-MON-YYYY') ||
    '*p_tdate=' || to_char(p_end_date, 'DD-MON-YYYY') ||
    '*paramform=NO';
  ELSIF (p_target_level_short_name = 'POASPSAL_ALL_M') THEN
    p_param := 'p_period_type=' || p_period_type ||
    '*p_ou_id=' || l_default ||
    '*p_view_dim=1' ||
    '*p_fdate=' || to_char(p_start_date, 'DD-MON-YYYY') ||
    '*p_tdate=' || to_char(p_end_date, 'DD-MON-YYYY') ||
    '*paramform=NO';
  ELSIF (p_target_level_short_name = 'POASPSAL_OU_M') THEN
    p_param := 'p_period_type=' || p_period_type ||
    '*p_ou_id=' || to_char(p_org_id) ||
    '*p_view_dim=1' ||
    '*p_fdate=' || to_char(p_start_date, 'DD-MON-YYYY') ||
    '*p_tdate=' || to_char(p_end_date, 'DD-MON-YYYY') ||
    '*paramform=NO';
  END IF;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in get_report_param procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END get_report_param;

PROCEDURE get_org_name(
p_org_id IN NUMBER,
p_org_name OUT NOCOPY VARCHAR2) IS
BEGIN
  IF (p_org_id = -1) THEN
    -- All organizations
    SELECT displayed_field INTO p_org_name
    FROM po_lookup_codes
    WHERE lookup_code = 'ALL'
    AND lookup_type = 'POA BIS REPORT OPTION';
  ELSE
    SELECT name INTO p_org_name
    FROM hr_organization_units
    WHERE organization_id = p_org_id;
  END IF;

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error getting Organization Name:');
    POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    p_org_name := NULL;
    RAISE;
END get_org_name;

PROCEDURE post_actual(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN) IS
l_target_level_rec   BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_index              NUMBER;
l_return_status      VARCHAR2(30);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(250);
l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
l_period_name        VARCHAR2(15);
l_period_type        VARCHAR2(15);
l_period_set_name    VARCHAR2(15);
l_currency           VARCHAR2(20);
l_start_date         DATE;
l_end_date           DATE;
l_actual_rec         BIS_ACTUAL_PUB.Actual_Rec_Type;
l_value_tbl          POA_Label_Value_Tbl;
l_value              VARCHAR2(120);
l_found_index        NUMBER;
l_heading            VARCHAR2(250);
BEGIN
  POA_LOG.put_line('Posting actual values...');
  l_target_level_rec.target_level_short_name := p_target_level_short_name;

  BIS_ACTUAL_PUB.Retrieve_User_Selections
  (p_api_version => 1.0,
   p_Target_Level_Rec => l_target_level_rec,
   x_Indicator_Region_Tbl => l_user_selection_tbl,
   x_return_status => l_return_status,
   x_msg_count => l_msg_count,
   x_msg_data => l_msg_data,
   x_error_Tbl => l_error_tbl);

/** DEBUG: Default 1 record for testing purposes  **/
--  l_user_selection_tbl(1).org_level_value_id := 204;

/** DEBUG: Loop 1 record for testing purposes  **/
  FOR l_index IN 1..l_user_selection_tbl.COUNT LOOP
--  FOR l_index IN 1..1 LOOP
    BEGIN
      POA_LOG.debug_line('Processing ORG_ID: ' ||
        l_user_selection_tbl(l_index).org_level_value_id);
      get_period_info(
      to_number(l_user_selection_tbl(l_index).org_level_value_id),
      p_for_current_period, l_start_date, l_end_date, l_period_name,
      l_period_set_name, l_currency, l_period_type);

      POA_LOG.debug_line('Period: ' || l_period_name);
      POA_LOG.debug_line('Currency: ' || l_currency);

      get_actual(p_target_level_short_name,
      to_number(l_user_selection_tbl(l_index).org_level_value_id),
      l_start_date, l_end_date, l_currency, l_value_tbl);

      get_value('L_ACTUAL', l_value_tbl, l_found_index, l_heading, l_value);
      l_actual_rec.actual := to_number(l_value);
      l_actual_rec.target_level_short_name := p_target_level_short_name;
      l_actual_rec.org_level_value_id :=
        l_user_selection_tbl(l_index).org_level_value_id;
      l_actual_rec.time_level_value_id :=
        l_period_set_name || '+' || l_period_name;

      l_actual_rec.target_level_id := l_user_selection_tbl(l_index).target_level_id;

      POA_LOG.debug_line('Actual: ' || l_actual_rec.actual);

      poa_log.debug_line('p_Actual_Rec='|| 'actual_id='||l_actual_rec.actual_id || ' ' ||
	'target_level_id='||l_actual_rec.target_level_id || ' ' ||
        'target_level_name='||l_actual_rec.target_level_name ||' ' ||
	'target_level_shortname='||l_actual_rec.Target_Level_Short_Name      ||' ' ||
	'org_level_id='||l_actual_rec.Org_Level_value_ID	||' ' ||
	'time_level_id='||l_actual_rec.time_Level_value_ID	||' ' ||
        'p_commit='|| FND_API.g_true ||' ' ||
        'x_return_status='|| l_return_status ||' ' ||
        'x_msg_count='|| l_msg_count
		       );

      BIS_ACTUAL_PUB.Post_Actual(p_api_version => 1.0,
        p_Actual_Rec => l_actual_rec,
        p_commit => FND_API.G_TRUE,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_error_tbl => l_error_tbl);

      POA_LOG.debug_line('Posted Actual: ' || l_return_status);
      POA_LOG.debug_line('End Processing ORG_ID: ' ||
        l_user_selection_tbl(l_index).org_level_value_id);
    EXCEPTION
      WHEN others THEN
        POA_LOG.put_line('Failed to post actual for organization:');
        POA_LOG.put_line(l_user_selection_tbl(l_index).org_level_value_id ||
          sqlcode || ': ' || sqlerrm);
    END;
  END LOOP;

  POA_LOG.put_line('Done.');

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in post_actual procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END post_actual;

PROCEDURE compare_targets(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN) IS
l_workflow_item_type VARCHAR2(8);
l_workflow_process VARCHAR2(30);
l_target_level_short_name VARCHAR2(30);
l_measure_short_name VARCHAR2(30);
l_target_level_name VARCHAR2(80);
l_param VARCHAR2(1000);
l_target_orgs BIS_TARGET_PUB.Target_Tbl_Type;
l_target_rec BIS_TARGET_PUB.Target_Rec_Type;
l_actual NUMBER;
l_index NUMBER;
l_start_date DATE;
l_end_date DATE;
l_period_set_name VARCHAR2(15);
l_period_name VARCHAR2(15);
l_period_type VARCHAR2(15);
l_found BOOLEAN;
l_return_status VARCHAR2(30);
l_currency VARCHAR2(20);
l_value_tbl POA_Label_Value_Tbl;
l_value VARCHAR2(120);
l_found_index NUMBER;
l_index2 NUMBER;
l_range_low NUMBER;
l_range_high NUMBER;
l_org_name VARCHAR2(80);
l_app_name VARCHAR2(240);
l_heading VARCHAR2(250);
BEGIN
  POA_LOG.put_line('Comparing actual against target values...');

-- Get Application Name
  SELECT application_name INTO l_app_name
  FROM fnd_application_vl
  WHERE application_short_name = 'POA';

-- Get target level information
  SELECT workflow_item_type,
         workflow_process_short_name,
         measure_short_name,
         target_level_name
  INTO   l_workflow_item_type,
         l_workflow_process,
         l_measure_short_name,
         l_target_level_name
  FROM BISFV_TARGET_LEVELS
  WHERE target_level_short_name = p_target_level_short_name;

-- Get all orgs with targets defined for the given target level
  get_target_orgs(p_target_level_short_name, p_plan_short_name,
                  l_target_orgs);

  FOR l_index IN 1..l_target_orgs.COUNT LOOP
    BEGIN
      POA_LOG.debug_line('Processing ORG_ID: ' ||
        l_target_orgs(l_index).org_level_value_id);

      get_period_info(
      to_number(l_target_orgs(l_index).org_level_value_id),
      p_for_current_period, l_start_date, l_end_date, l_period_name,
      l_period_set_name, l_currency, l_period_type);

      POA_LOG.debug_line('Period: '||l_period_set_name || '+' || l_period_name);
      POA_LOG.debug_line('Currency: ' || l_currency);

      get_target_value(p_target_level_short_name, p_plan_short_name,
      l_period_set_name || '+' || l_period_name,
      to_number(l_target_orgs(l_index).org_level_value_id),
      l_found, l_target_rec);

      POA_LOG.debug_line('Target: ' || l_target_rec.target);

      IF (l_found) THEN
        -- Clear value table
        l_value_tbl.DELETE;

        get_actual(p_target_level_short_name,
                   to_number(l_target_orgs(l_index).org_level_value_id),
                   l_start_date, l_end_date, l_currency, l_value_tbl);

        -- get_actual returns a record with more than one value,
        -- need to get the 'real' actual
        get_value('L_ACTUAL', l_value_tbl, l_found_index, l_heading, l_value);
        l_actual := TO_NUMBER(l_value);

        POA_LOG.debug_line('Actual: ' || l_actual);

        IF (l_target_rec.range1_low <> FND_API.g_miss_num AND
            l_target_rec.range1_high <> FND_API.g_miss_num) THEN
          l_range_low := l_target_rec.target*(1-l_target_rec.range1_low/100);
          l_range_high := l_target_rec.target*(1+l_target_rec.range1_high/100);

          IF (l_actual NOT BETWEEN l_range_low AND l_range_high) THEN
             POA_LOG.debug_line('Outside Range 1');
            insert_row('L_SUBJECT', fnd_message.get_string('POA',
              'POA_' || UPPER(l_measure_short_name) || '_SUBJECT'), '(' ||
              fnd_message.get_string('PO','POA_ACTUAL') || ': ' || l_value ||
              ' ' || fnd_message.get_string('PO','POA_TARGET') || ': ' ||
              to_char(l_target_rec.target,POA_BIS_ALERTS.g_percent_mask) || ')',
              l_value_tbl);
            insert_row('L_TARGET_LEVEL',
              fnd_message.get_string('POA','POA_TARGET_LEVEL'),
              l_target_level_name, l_value_tbl);
            get_org_name(to_number(l_target_orgs(l_index).org_level_value_id),
              l_org_name);
            insert_row('L_ORG',
              fnd_message.get_string('PO','POA_ORGANIZATION'), l_org_name,
              l_value_tbl);
            insert_row('L_PERIOD',
              fnd_message.get_string('PO','POA_PERIOD'), l_period_name,
              l_value_tbl);
            insert_row('L_TARGET',
              fnd_message.get_string('PO','POA_TARGET'),
              to_char(l_target_rec.target, POA_BIS_ALERTS.g_percent_mask),
              l_value_tbl);
            insert_row('L_TARGET_RANGE',
              fnd_message.get_string('POA','POA_TARGET_RANGE'),
              to_char(l_range_low, POA_BIS_ALERTS.g_percent_mask) || ' - ' ||
              to_char(l_range_high,POA_BIS_ALERTS.g_percent_mask),l_value_tbl);
            insert_row('L_THANKS',
              fnd_message.get_string('POA','POA_THANKS'), NULL, l_value_tbl);
            insert_row('L_SENDER', l_app_name, NULL, l_value_tbl);
            get_report_param(p_target_level_short_name,
              to_number(l_target_orgs(l_index).org_level_value_id),
              l_start_date, l_end_date, l_period_type, l_param);
            insert_row('L_URL', fnd_profile.value('ICX_REPORT_LINK') ||
              'OracleOASIS.RunReport?report='|| l_measure_short_name ||
              '&' || 'parameters=' || l_param || '&' ||
              'responsibility_id=' ||
              l_target_rec.notify_resp1_id, NULL, l_value_tbl);
            start_workflow(l_workflow_item_type, l_workflow_process,
              l_target_rec.notify_resp1_short_name,l_value_tbl,l_return_status);
          END IF;

        END IF;

        IF (l_target_rec.range2_low <> FND_API.g_miss_num AND
            l_target_rec.range2_high <> FND_API.g_miss_num) THEN
          l_range_low := l_target_rec.target*(1-l_target_rec.range2_low/100);
          l_range_high := l_target_rec.target*(1+l_target_rec.range2_high/100);

          IF (l_actual NOT BETWEEN l_range_low AND l_range_high) THEN
            POA_LOG.debug_line('Outside Range 2');
            set_value('L_TARGET_RANGE',
              fnd_message.get_string('POA','POA_TARGET_RANGE'),
              to_char(l_range_low, POA_BIS_ALERTS.g_percent_mask) || ' - ' ||
              to_char(l_range_high,POA_BIS_ALERTS.g_percent_mask),l_value_tbl);
            get_report_param(p_target_level_short_name,
              to_number(l_target_orgs(l_index).org_level_value_id),
              l_start_date, l_end_date, l_period_type, l_param);
            set_value('L_URL', fnd_profile.value('ICX_REPORT_LINK') ||
              'OracleOASIS.RunReport?report='|| l_measure_short_name ||
              '&' || 'parameters=' || l_param || '&' ||
              'responsibility_id=' ||
              l_target_rec.notify_resp2_id, NULL, l_value_tbl);

            start_workflow(l_workflow_item_type, l_workflow_process,
              l_target_rec.notify_resp2_short_name,l_value_tbl,l_return_status);
          END IF;

        END IF;

        IF (l_target_rec.range3_low <> FND_API.g_miss_num AND
            l_target_rec.range3_high <> FND_API.g_miss_num) THEN
          l_range_low := l_target_rec.target*(1-l_target_rec.range3_low/100);
          l_range_high := l_target_rec.target*(1+l_target_rec.range3_high/100);

          IF (l_actual NOT BETWEEN l_range_low AND l_range_high) THEN
            POA_LOG.debug_line('Outside Range 3');
            set_value('L_TARGET_RANGE',
              fnd_message.get_string('POA','POA_TARGET_RANGE'),
              to_char(l_range_low, POA_BIS_ALERTS.g_percent_mask) || ' - ' ||
              to_char(l_range_high,POA_BIS_ALERTS.g_percent_mask),l_value_tbl);
            get_report_param(p_target_level_short_name,
              to_number(l_target_orgs(l_index).org_level_value_id),
              l_start_date, l_end_date, l_period_type, l_param);
            set_value('L_URL', fnd_profile.value('ICX_REPORT_LINK') ||
              'OracleOASIS.RunReport?report='|| l_measure_short_name ||
              '&' || 'parameters=' || l_param || '&' ||
              'responsibility_id=' ||
              l_target_rec.notify_resp3_id, NULL, l_value_tbl);
            start_workflow(l_workflow_item_type, l_workflow_process,
              l_target_rec.notify_resp3_short_name,l_value_tbl,l_return_status);
          END IF;

        END IF;

      ELSE
        POA_LOG.debug_line('No target defined');
      END IF;

      POA_LOG.debug_line('End Processing ORG_ID: ' ||
        l_target_orgs(l_index).org_level_value_id);

    EXCEPTION
      WHEN others THEN
        POA_LOG.put_line('Failed to compare target for organization:' ||
          l_target_orgs(l_index).org_level_value_id);
        POA_LOG.put_line(sqlcode || ': ' || sqlerrm);
    END;
  END LOOP;

  POA_LOG.put_line('Done.');

END compare_targets;

PROCEDURE process_alert_current_period(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2) IS
BEGIN
  process_alert(p_target_level_short_name, p_plan_short_name, TRUE);
END process_alert_current_period;

PROCEDURE process_alert_previous_period(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2) IS
BEGIN
  process_alert(p_target_level_short_name, p_plan_short_name, FALSE);
END process_alert_previous_period;

PROCEDURE process_alert(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN) IS
x_progress VARCHAR2(3);
BEGIN
  POA_LOG.setup('POAALRTS');
  POA_LOG.debug_line('In Process Alerts');

  post_actual(p_target_level_short_name, p_plan_short_name,
    p_for_current_period);
  compare_targets(p_target_level_short_name, p_plan_short_name,
    p_for_current_period);

  POA_LOG.wrapup('SUCCESS');

EXCEPTION WHEN OTHERS THEN
  POA_LOG.put_line('Process Alerts: ' || sqlcode || ': ' ||
    sqlerrm || ': ' || x_progress);
  POA_LOG.put_line(' ');
  POA_LOG.wrapup('ERROR');
END process_alert;

PROCEDURE start_workflow(
p_wf_item_type IN VARCHAR2,
p_wf_process IN VARCHAR2,
p_role IN VARCHAR2,
p_value_tbl IN POA_Label_Value_Tbl,
x_return_status OUT NOCOPY VARCHAR2) IS
l_index NUMBER;
l_wf_item_key NUMBER;
l_role_name VARCHAR2(80);
l_string VARCHAR2(500);
CURSOR c_role_name IS
  SELECT name
  FROM wf_roles
  WHERE name = p_role;
BEGIN
  POA_LOG.debug_line('Starting Workflow Notification');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_wf_process is NULL or p_role is NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
  END IF;

  OPEN c_role_name;
  FETCH c_role_name INTO l_role_name;

  IF C_ROLE_NAME%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    return;
  END IF;

  POA_LOG.debug_line('Notifying: ' || l_role_name);

  -- Generate workflow process key
  SELECT bis_excpt_wf_s.nextval
  INTO l_wf_item_key
  FROM dual;

  -- Create workflow process
  wf_engine.CreateProcess(itemtype => p_wf_item_type,
                          itemkey => l_wf_item_key,
                          process => p_wf_process);

  -- Set workflow process role
  wf_engine.SetItemAttrText(itemtype => p_wf_item_type,
                            itemkey => l_wf_item_key,
                            aname=> 'L_ROLE_NAME',
                            avalue=> l_role_name);

  -- Set other workflow attributes
  FOR l_index IN 1..p_value_tbl.COUNT LOOP

    IF (p_value_tbl(l_index).value IS NULL) THEN
      l_string := nvl(p_value_tbl(l_index).heading, p_value_tbl(l_index).label);
    ELSE
      l_string := nvl(p_value_tbl(l_index).heading, p_value_tbl(l_index).label)
                  || ': ' || p_value_tbl(l_index).value;
    END IF;

    POA_LOG.debug_line('Label: ' || p_value_tbl(l_index).label);
    POA_LOG.debug_line('Value: ' || l_string);

    wf_engine.SetItemAttrText(itemtype => p_wf_item_type,
                         itemkey => l_wf_item_key,
                         aname=> p_value_tbl(l_index).label,
                         avalue=> l_string);
  END LOOP;

  -- Start workflow process
  wf_engine.StartProcess(itemtype => p_wf_item_type,
                         itemkey => l_wf_item_key);

  COMMIT;
  POA_LOG.debug_line('Exit POA_STRT_WF_PROCESS');

EXCEPTION
  WHEN others THEN
    POA_LOG.put_line('Error in start_workflow procedure:');
    POA_LOG.put_line(sqlcode);
    RAISE;
END start_workflow;

END POA_BIS_ALERTS;

/
