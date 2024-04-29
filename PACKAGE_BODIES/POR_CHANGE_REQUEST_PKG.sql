--------------------------------------------------------
--  DDL for Package Body POR_CHANGE_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_CHANGE_REQUEST_PKG" AS
/* $Header: PORRCHOB.pls 120.3.12010000.6 2014/08/22 06:53:25 rkandima ship $ */

  g_debug         CONSTANT VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'PO_CHANGE_REQUEST_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

 /**************************************************************************
  * This procedure returns organizational currency's precision and         *
  * extended precision settings.                                           *
  **************************************************************************/
  PROCEDURE get_org_precision_values (PRECISION OUT NOCOPY NUMBER,
                                      ext_precision OUT NOCOPY NUMBER,
                                      min_acct_unit OUT NOCOPY NUMBER)
  IS
  functional_cur_code gl_sets_of_books.currency_code%TYPE  := '';
  BEGIN
    -- get functional currency code
    SELECT gls.currency_code
    INTO functional_cur_code
    FROM
      financials_system_parameters fsp,
      gl_sets_of_books gls
    WHERE
      fsp.set_of_books_id = gls.set_of_books_id;

    fnd_currency.get_info(functional_cur_code, PRECISION,
                          ext_precision, min_acct_unit);

  END get_org_precision_values;


 /**************************************************************************
  * This function returns conversion rate between Req functional currency  *
  * and PO currency.                                                       *      **************************************************************************/
  FUNCTION get_conversion_rate(p_req_ou           IN NUMBER,
                               p_po_ou            IN NUMBER,
                               p_po_currency_code IN VARCHAR2,
                               p_rate_type        IN VARCHAR2,
                               p_rate_date        IN DATE) RETURN NUMBER
  IS
  l_req_ou_sob_id gl_sets_of_books.set_of_books_id%TYPE;
  l_rate          NUMBER := 1;
  l_rate_type     po_headers_all.rate_type%TYPE;
  l_inverse_rate_display_flag  VARCHAR2(1) := 'N';
  l_display_rate               NUMBER;
  l_api_name VARCHAR2(30) := 'get_conversion_rate';
  l_progress VARCHAR2(3) := '000';
  BEGIN

    IF (g_debug = 'Y' AND
        fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,
                     g_module_prefix || l_api_name,
                     'Parameters:' || to_char(p_req_ou) || ' ' || to_char(p_po_ou) || ' ' || p_po_currency_code || ' ' || p_rate_type || ' ' || p_rate_date);
    END IF;

    SELECT req_fsp.set_of_books_id
    INTO l_req_ou_sob_id
    FROM financials_system_params_all req_fsp
    WHERE nvl(req_fsp.org_id, - 99) = nvl(p_req_ou, - 99);

    l_progress := '001';

    IF p_rate_type IS NULL THEN
      SELECT default_rate_type
      INTO  l_rate_type
      FROM  po_system_parameters_all psp
      WHERE nvl(psp.org_id, - 99) = nvl(p_po_ou, - 99);
    ELSE
      l_rate_type := p_rate_type;
    END IF;

    l_progress := '002';

    po_currency_sv.get_rate(l_req_ou_sob_id,
                            p_po_currency_code,
                            l_rate_type,
                            p_rate_date,
                            l_inverse_rate_display_flag,
                            l_rate,
                            l_display_rate);

    l_progress := '003';

    IF (g_debug = 'Y' AND
        fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,
                     g_module_prefix || l_api_name,
                     'Return:' || ' Rate:' || to_char(l_rate));
    END IF;

    RETURN l_rate;
  EXCEPTION
    WHEN OTHERS THEN
    IF (g_debug = 'Y' AND
        fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_unexpected,
                     g_module_prefix || l_api_name,
                     'Exception:' || l_progress || ' ' || SQLERRM );
    END IF;
    RETURN 1;
  END get_conversion_rate;


 /**************************************************************************
  * This function calculates price difference between req price and po     *
  * price.                                                                 *      **************************************************************************/
  FUNCTION calculate_price_diff(p_req_ou NUMBER,
                                p_po_ou NUMBER,
                                p_req_cur_code VARCHAR2,
                                p_req_price NUMBER,
                                p_po_cur_code VARCHAR2,
                                p_po_rate NUMBER,
                                p_po_rate_type VARCHAR2,
                                p_po_rate_date DATE,
                                p_linelocation_price NUMBER,
                                p_po_line_price NUMBER,
                                p_precision NUMBER ) RETURN NUMBER
  IS
  l_conversion_rate NUMBER := 1;
  l_req_cur_code po_requisition_lines.currency_code%TYPE;
  l_po_cur_code po_headers.currency_code%TYPE;
  l_req_ou_cur_code gl_sets_of_books.currency_code%TYPE;
  l_po_ou_cur_code gl_sets_of_books.currency_code%TYPE;
  l_api_name VARCHAR2(30) := 'calculate_price_diff';
  l_progress VARCHAR2(3)  := '000';
  BEGIN

    IF (g_debug = 'Y' AND
        fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,
                     g_module_prefix || l_api_name,
                     'Parameters:' ||
                     to_char(p_req_ou) || ' ' ||
                     to_char(p_po_ou) || ' ' ||
                     p_req_cur_code || ' ' ||
                     to_char(p_req_price) || ' ' ||
                     p_po_cur_code || ' ' ||
                     to_char(p_po_rate) || ' ' ||
                     p_po_rate_type || ' ' ||
                     p_po_rate_date || ' ' ||
                     to_char(p_linelocation_price) || ' ' ||
                     p_po_line_price || ' ' || to_char(p_precision));
    END IF;

    l_req_cur_code := p_req_cur_code;
    l_po_cur_code  := p_po_cur_code;

    l_progress := '001';

    -- If Req's Org is different then PO's Org
    IF (p_req_ou <> p_po_ou) THEN

      -- get req's and po's org's functional currency code
      po_currency_sv.get_functional_currency_code(p_req_ou, l_req_ou_cur_code);
      po_currency_sv.get_functional_currency_code(p_po_ou, l_po_ou_cur_code);

      l_progress := '002';

      IF (l_req_cur_code IS NULL) THEN
        -- use functional currency code of REQ's OU
        l_req_cur_code := l_req_ou_cur_code;
      END IF;

      IF (l_po_cur_code IS NULL) THEN
         -- use functional currency of PO's OU
        l_po_cur_code := l_po_ou_cur_code;
      END IF;

      l_progress := '003';

       -- conversion needed only if REQ's functional currency is different
       -- then PO's functional currency
      IF (l_req_ou_cur_code <> l_po_ou_cur_code) THEN

        l_conversion_rate := get_conversion_rate(p_req_ou,
                                                 p_po_ou,
                                                 l_po_cur_code,
                                                 p_po_rate_type,
                                                 p_po_rate_date );

      END IF;

      IF (g_debug = 'Y' AND
          fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,
                       g_module_prefix || l_api_name,
                       'Conversion Rate:' || to_char(l_conversion_rate));
      END IF;

      l_progress := '004';

      RETURN abs(p_req_price - (l_conversion_rate * nvl(p_linelocation_price, p_po_line_price))) * power(10, p_precision);

    ELSE  -- req and po in the same org

      RETURN abs(p_req_price - (nvl(p_po_rate, 1) * nvl(p_linelocation_price, p_po_line_price))) * power(10, p_precision);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    IF (g_debug = 'Y' AND
        fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_unexpected,
                     g_module_prefix || l_api_name,
                     'Exception:' || l_progress || ' ' || SQLERRM );
    END IF;
  END calculate_price_diff;

 /**************************************************************************
  * This function calculates amount difference between req and po for      *
  * amount based lines.                                                    *
  **************************************************************************/
  FUNCTION calculate_amount_diff(p_req_ou NUMBER,
                                 p_po_ou NUMBER,
                                 p_req_cur_code VARCHAR2,
                                 p_req_amount NUMBER,
                                 p_po_cur_code VARCHAR2,
                                 p_po_rate NUMBER,
                                 p_po_rate_type VARCHAR2,
                                 p_po_rate_date DATE,
                                 p_linelocation_amount NUMBER,
                                 p_po_line_amount NUMBER,
                                 p_precision NUMBER ) RETURN NUMBER
  IS
  l_conversion_rate NUMBER := 1;
  l_req_cur_code po_requisition_lines.currency_code%TYPE;
  l_po_cur_code po_headers.currency_code%TYPE;
  l_req_ou_cur_code gl_sets_of_books.currency_code%TYPE;
  l_po_ou_cur_code gl_sets_of_books.currency_code%TYPE;
  l_api_name VARCHAR2(30) := 'calculate_amount_diff';
  l_progress VARCHAR2(3)  := '000';
  BEGIN

    IF (g_debug = 'Y' AND
        fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,
                     g_module_prefix || l_api_name,
                     'Parameters:' ||
                     to_char(p_req_ou) || ' ' ||
                     to_char(p_po_ou) || ' ' ||
                     p_req_cur_code || ' ' ||
                     to_char(p_req_amount) || ' ' ||
                     p_po_cur_code || ' ' ||
                     to_char(p_po_rate) || ' ' ||
                     p_po_rate_type || ' ' ||
                     p_po_rate_date || ' ' ||
                     to_char(p_linelocation_amount) || ' ' ||
                     p_po_line_amount || ' ' || to_char(p_precision));
    END IF;

    l_req_cur_code := p_req_cur_code;
    l_po_cur_code  := p_po_cur_code;

    l_progress := '001';

    -- If Req's Org is different then PO's Org
    IF (p_req_ou <> p_po_ou) THEN

      -- get req's and po's org's functional currency code
      po_currency_sv.get_functional_currency_code(p_req_ou, l_req_ou_cur_code);
      po_currency_sv.get_functional_currency_code(p_po_ou, l_po_ou_cur_code);

      l_progress := '002';

      IF (l_req_cur_code IS NULL) THEN
        -- use functional currency code of REQ's OU
        l_req_cur_code := l_req_ou_cur_code;
      END IF;

      IF (l_po_cur_code IS NULL) THEN
         -- use functional currency of PO's OU
        l_po_cur_code := l_po_ou_cur_code;
      END IF;

      l_progress := '003';

       -- conversion needed only if REQ's functional currency is different
       -- then PO's functional currency
      IF (l_req_ou_cur_code <> l_po_ou_cur_code) THEN

        l_conversion_rate := get_conversion_rate(p_req_ou,
                                                 p_po_ou,
                                                 l_po_cur_code,
                                                 p_po_rate_type,
                                                 p_po_rate_date );

      END IF;

      IF (g_debug = 'Y' AND
          fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,
                       g_module_prefix || l_api_name,
                       'Conversion Rate:' || to_char(l_conversion_rate));
      END IF;

      l_progress := '004';

      RETURN abs(p_req_amount - (l_conversion_rate * nvl(p_linelocation_amount, p_po_line_amount))) * power(10, p_precision);

    ELSE  -- req and po in the same org

      RETURN abs(p_req_amount - (nvl(p_po_rate, 1) * nvl(p_linelocation_amount, p_po_line_amount))) * power(10, p_precision);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    IF (g_debug = 'Y' AND
        fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_unexpected,
                     g_module_prefix || l_api_name,
                     'Exception:' || l_progress || ' ' || SQLERRM );
    END IF;
  END calculate_amount_diff;

 /**************************************************************************
  * This function returns whether values for updatable values differ       *
  * between requisition line and corresponding purchase order line or not  *
  *                                                                        *
  *   The function returns following values depending on the requisition   *
  *   type :                                                               *
  *   - FIXED_PRICE : if requisition line is a fixed price service line    *
  *     type and updatable values are different between req and po         *
  *   - LABOR : if requisition line is a temp labor line                   *
  *     and updatable values are different between req and po              *
  *   - Y : if requisition line is otherwise  and updatable values         *
  *     are different between req and po                                   *
  *   - N : if the updatable values are not different                      *
  **************************************************************************/
  FUNCTION is_order_values_differ(reqlineid NUMBER) RETURN VARCHAR2
  IS
  date_diff INTEGER       := 0;
  quantity_diff NUMBER    := 0;
  unit_price_diff NUMBER  := 0;
  amount_diff NUMBER      := 0;
  start_date_diff INTEGER := 0;
  end_date_diff INTEGER   := 0;
  purchase_basis  po_requisition_lines.purchase_basis%TYPE := '';
  matching_basis  po_requisition_lines.matching_basis%TYPE := '';
  PRECISION NUMBER     := 0;
  ext_precision NUMBER := 0;
  min_acct_unit NUMBER := 0;
  po_ou NUMBER;
  req_ou NUMBER;
  req_cur_code po_requisition_lines.currency_code%TYPE;
  req_price NUMBER;
  po_cur_code po_headers.currency_code%TYPE;
  po_rate NUMBER;
  po_rate_type po_headers.rate_type%TYPE;
  po_rate_date DATE;
  line_location_price NUMBER;
  po_line_price NUMBER;
  req_amount NUMBER;
  line_location_amount NUMBER;
  po_line_amount NUMBER;
  l_api_name VARCHAR2(30) := 'is_order_values_differ';
  l_progress VARCHAR2(3)  := '000';
  BEGIN

    get_org_precision_values(PRECISION, ext_precision, min_acct_unit);

    l_progress := '001';

    SELECT
      prl.purchase_basis,
      prl.matching_basis,
      trunc(prl.need_by_date) - trunc(pll.need_by_date),
      (prl.quantity - nvl(prl.quantity_cancelled, 0)) - pll.quantity,
      prl.org_id,
      poh.org_id,
      prl.currency_code,
      prl.unit_price,
      poh.currency_code,
      poh.rate, poh.rate_type, poh.rate_date, pll.price_override,
      pol.unit_price,
      prl.amount,
      pll.amount,
      pol.amount,
      trunc(prl.need_by_date) - trunc(pol.start_date),
      trunc(prl.assignment_end_date) - trunc(pol.expiration_date)
    INTO
      purchase_basis,
      matching_basis,
      date_diff,
      quantity_diff,
      req_ou,
      po_ou,
      req_cur_code,
      req_price,
      po_cur_code,
      po_rate,
      po_rate_type,
      po_rate_date,
      line_location_price,
      po_line_price,
      req_amount,
      line_location_amount,
      po_line_amount,
      start_date_diff,
      end_date_diff
    FROM
      po_requisition_lines prl,
      po_req_distributions prd,
      po_line_locations_all pll,
      po_headers_all poh,
      po_lines_all pol,
      po_distributions_all pod
    WHERE
      prl.requisition_line_id = reqlineid AND
      prd.requisition_line_id = prl.requisition_line_id AND
      prl.line_location_id = pll.line_location_id AND
      pll.po_header_id = poh.po_header_id AND
      pol.po_header_id = poh.po_header_id AND
      pod.po_line_id = pol.po_line_id AND
      pod.req_distribution_id = prd.distribution_id AND ROWNUM = 1;

    l_progress := '002';

    /* temp labor line case */
    IF (purchase_basis = 'TEMP LABOR') THEN

      amount_diff := calculate_amount_diff(req_ou, po_ou, req_cur_code,
                                           req_amount, po_cur_code, po_rate, po_rate_type,
                                           po_rate_date, line_location_amount, po_line_amount,
                                           PRECISION);

      IF (g_debug = 'Y' AND
          fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,
                       g_module_prefix || l_api_name,
                       'Start_Date_Diff:' || to_char(start_date_diff) || ' ' ||
                       'End_Date_Diff:' || to_char(end_date_diff) || ' ' ||                            'Amount_Diff:' || to_char(amount_diff));
      END IF;

      IF (start_date_diff <> 0 OR
          end_date_diff <> 0 OR
          amount_diff >= 1) THEN
        RETURN 'LABOR';
      END IF;

      RETURN 'N';

    /* fixed price service line case */
    ELSIF (purchase_basis = 'SERVICES' AND matching_basis = 'AMOUNT') THEN

      amount_diff := calculate_amount_diff(req_ou, po_ou, req_cur_code,
                                           req_amount, po_cur_code, po_rate, po_rate_type,
                                           po_rate_date, line_location_amount, po_line_amount,
                                           PRECISION);

      IF (g_debug = 'Y' AND
          fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,
                       g_module_prefix || l_api_name,
                       'Date_Diff:' || to_char(date_diff) || ' ' ||
                       'Amount_Diff:' || to_char(amount_diff));
      END IF;

      IF (date_diff <> 0 OR
          amount_diff >= 1) THEN
        RETURN 'FIXED_SERVICE';
      END IF;

      RETURN 'N';

    ELSE /* other cases */

      unit_price_diff := calculate_price_diff(req_ou, po_ou, req_cur_code,
                                              req_price, po_cur_code, po_rate, po_rate_type,
                                              po_rate_date, line_location_price, po_line_price,
                                              ext_precision);

      IF (g_debug = 'Y' AND
          fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,
                       g_module_prefix || l_api_name,
                       'Date_Diff:' || to_char(date_diff) || ' ' ||
                       'Quantity_Diff:' || to_char(quantity_diff) || ' ' ||
                       'Unit_Price_Diff:' || to_char(unit_price_diff));
      END IF;

      IF (date_diff <> 0 OR
          quantity_diff <> 0 OR
          unit_price_diff >= 1) THEN
        RETURN 'Y';
      END IF;

      RETURN 'N';

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    IF (g_debug = 'Y' AND
        fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_unexpected,
                     g_module_prefix || l_api_name,
                     'Exception:' || l_progress || ' ' || SQLERRM );
    END IF;
    RETURN 'N';

  END is_order_values_differ;


 /**************************************************************************
  * This function calculates the new requisition total during requester    *
  * change order flow                                                      *
  **************************************************************************/
  FUNCTION get_changed_req_total(reqheaderid IN NUMBER)
  RETURN NUMBER IS
  req_total NUMBER := 0;
  BEGIN

    -- calculate req total by calculating sum of changed line totals
    SELECT nvl(SUM(get_changed_line_total(requisition_line_id)), 0)
    INTO req_total
    FROM
      po_requisition_lines
    WHERE
     requisition_header_id = reqheaderid AND
     nvl(cancel_flag, 'N') = 'N' AND
     nvl(modified_by_agent_flag, 'N') = 'N' AND
     requisition_line_id NOT IN
     (SELECT DISTINCT document_line_id
     FROM po_change_requests
     WHERE document_header_id = reqheaderid
     AND request_level = 'LINE'
     AND action_type = 'CANCELLATION');


    RETURN req_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;

  END get_changed_req_total;


 /**************************************************************************
  * This function returns the new non recoverable tax total during         *
  * requester change order flow                                            *
  **************************************************************************/
  FUNCTION get_changed_nonrec_tax_total(reqheaderid IN NUMBER) RETURN NUMBER IS
  tax_total NUMBER := 0;
  BEGIN

    SELECT nvl(SUM(get_chn_line_nonrec_tax_total(requisition_line_id)), 0)
    INTO tax_total
    FROM
      po_requisition_lines
    WHERE
      requisition_header_id =  reqheaderid
      AND requisition_line_id NOT IN
      (SELECT DISTINCT document_line_id
      FROM po_change_requests
      WHERE document_header_id = reqheaderid
      AND request_level = 'LINE'
      AND action_type = 'CANCELLATION');

    RETURN tax_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_changed_nonrec_tax_total;


 /**************************************************************************
  * This function returns unit price of a given line. If there is any      *
  * unit price change exist in po_change_requests table, it returns        *
  * that value otherwise returns unit_price from po_requisition_lines	   *
  **************************************************************************/
  FUNCTION get_unit_price(reqlineid NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  unit_price NUMBER := 0;
  BEGIN
    --Bug:19280546
    --unit_price := get_price_break_price(reqlineid, chgreqgrpid);

    --IF (unit_price IS NULL) THEN

      SELECT new_price
      INTO unit_price
      FROM po_change_requests
      WHERE
        document_line_id = reqlineid AND
        document_type = 'REQ' AND
        action_type = 'MODIFICATION' AND
        request_status = 'SYSTEMSAVE' AND
        new_price IS NOT NULL;
    --END IF;

    RETURN unit_price;

  EXCEPTION

    WHEN no_data_found THEN
    SELECT unit_price
    INTO unit_price
    FROM po_requisition_lines_all
    WHERE
      requisition_line_id = reqlineid;

    RETURN unit_price;

    WHEN OTHERS THEN
    RETURN NULL;

  END get_unit_price;

 /**************************************************************************
  * This function returns the new line total during requester change order *
  * flow                                                                   *
  **************************************************************************/
  FUNCTION get_int_changed_line_total(reqlineid IN NUMBER)
  RETURN NUMBER IS
  changed_total  NUMBER := 0;
  grp_id NUMBER := 0;
  amount NUMBER := 0;
  matching_basis po_requisition_lines.matching_basis%TYPE := '';
  line_qty  NUMBER := 0;

  BEGIN


    SELECT MIN(pcr.change_request_group_id)
    INTO grp_id
    FROM
      po_requisition_lines_all prl,
      po_change_requests pcr
    WHERE
      pcr.document_header_id = prl.requisition_header_id
      AND prl.requisition_line_id = reqlineid
      AND pcr.request_status = 'SYSTEMSAVE';



  -- quantity based item
    BEGIN
      SELECT new_quantity
      INTO line_qty
      FROM
        po_change_requests
      WHERE
        document_line_id = reqlineid AND
        change_request_group_id = grp_id AND
        document_type = 'REQ' AND
        new_quantity IS NOT NULL;
    EXCEPTION
      WHEN no_data_found THEN
      line_qty := get_hist_changed_line_qty(reqlineid, grp_id);

    END;


    changed_total := line_qty * get_unit_price(reqlineid, grp_id);



    IF (changed_total IS NULL) THEN
      changed_total := 0;
    END IF;



    RETURN changed_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_int_changed_line_total;

  FUNCTION get_changed_line_total(reqlineid IN NUMBER)
  RETURN NUMBER IS
  changed_total  NUMBER := 0;
  grp_id NUMBER := 0;
  amount NUMBER := 0;
  matching_basis po_requisition_lines.matching_basis%TYPE := '';
  quantity NUMBER := 0;
  BEGIN




    SELECT MIN(pcr.change_request_group_id)
    INTO grp_id
    FROM
      po_requisition_lines_all prl,
      po_change_requests pcr
    WHERE
      pcr.document_header_id = prl.requisition_header_id
      AND prl.requisition_line_id = reqlineid
      AND pcr.request_status = 'SYSTEMSAVE';




  -- get matching basis
    SELECT prl.matching_basis
    INTO matching_basis
    FROM
      po_requisition_lines_all prl
    WHERE
      prl.requisition_line_id = reqlineid;




  -- quantity based item
    IF (matching_basis = 'QUANTITY') THEN
      quantity := get_hist_changed_line_qty(reqlineid, grp_id);



      IF (quantity IS NULL) THEN
        quantity := get_hist_line_qty(reqlineid, grp_id);

      END IF;
      changed_total := quantity * get_unit_price(reqlineid, grp_id);

      IF (changed_total IS NULL) THEN
        changed_total := 0;
      END IF;

  -- amount based item
    ELSE




      changed_total := get_hist_changed_line_amount(reqlineid, grp_id);
      IF (changed_total IS NULL) THEN
        changed_total := get_hist_line_amount(reqlineid, grp_id);
      END IF;

    END IF;

    RETURN changed_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_changed_line_total;


 /**************************************************************************
  * This function returns the new currency line total during requester     *
  * change order flow                                                      *
  **************************************************************************/
  FUNCTION get_changed_cur_line_total(reqlineid IN NUMBER)
  RETURN NUMBER IS
  changed_total  NUMBER := 0;
  grp_id NUMBER := 0;
  amount NUMBER := 0;
  matching_basis po_requisition_lines.matching_basis%TYPE := '';
  quantity NUMBER := 0;
  unit_price NUMBER := 0;
  BEGIN

    SELECT MIN(pcr.change_request_group_id)
    INTO grp_id
    FROM
      po_requisition_lines_all prl,
      po_change_requests pcr
    WHERE
      pcr.document_header_id = prl.requisition_header_id
      AND prl.requisition_line_id = reqlineid
      AND pcr.request_status = 'SYSTEMSAVE';

  -- get matching basis
    SELECT prl.matching_basis
    INTO matching_basis
    FROM
      po_requisition_lines_all prl
    WHERE
      prl.requisition_line_id = reqlineid;

  -- quantity based item
    IF (matching_basis = 'QUANTITY') THEN
      quantity := get_hist_changed_line_qty(reqlineid, grp_id);
      IF (quantity IS NULL) THEN
        quantity := get_hist_line_qty(reqlineid, grp_id);
      END IF;
      unit_price := get_currency_unit_price(reqlineid, grp_id);

      IF (unit_price IS NULL) THEN
        unit_price := get_unit_price(reqlineid, grp_id);
      END IF;

      changed_total := quantity * unit_price;
      IF (changed_total IS NULL) THEN
        changed_total := 0;
      END IF;

  -- amount based item
    ELSE

      changed_total := get_hist_chng_cur_line_amount(reqlineid, grp_id);
      IF (changed_total IS NULL) THEN
        changed_total := get_hist_cur_line_amount(reqlineid, grp_id);
      END IF;

    END IF;

    RETURN changed_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_changed_cur_line_total;


 /**************************************************************************
  * This function returns the non recoverable tax amount of a requisition  *
  * line during requester change order flow                                *
  **************************************************************************/
  FUNCTION get_chn_line_nonrec_tax_total(reqlineid IN NUMBER) RETURN NUMBER IS
  changed_tax_total NUMBER := 0;
  new_line_total NUMBER := 0;
  old_nonrec_tax NUMBER := 0;
  old_line_total NUMBER := 0;
  BEGIN

     -- get changed line total
    new_line_total := get_changed_line_total(reqlineid);

     -- get old line total
    SELECT SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount, prd.req_line_quantity * prl.unit_price))
      INTO old_line_total
    FROM
      po_requisition_lines_all prl,
      po_req_distributions prd
    WHERE
      prl.requisition_line_id = reqlineid AND
      prl.requisition_line_id =  prd.requisition_line_id;

     -- get old tax
    old_nonrec_tax := por_view_reqs_pkg.get_line_nonrec_tax_total(reqlineid);

    changed_tax_total := nvl((old_nonrec_tax * (new_line_total / old_line_total)), 0);

    RETURN changed_tax_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_chn_line_nonrec_tax_total;


 /**************************************************************************
  * This function returns the recoverable tax amount of a requisition      *
  * line during requester change order flow                                *
  **************************************************************************/
  FUNCTION get_changed_line_rec_tax_total(reqlineid IN NUMBER) RETURN NUMBER IS
  changed_tax_total NUMBER := 0;
  new_line_total NUMBER := 0;
  old_rec_tax NUMBER := 0;
  old_line_total NUMBER := 0;
  BEGIN
     -- get changed line total
    new_line_total := get_changed_line_total(reqlineid);

     -- get old line total
    SELECT SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount, prd.req_line_quantity * prl.unit_price))
      INTO old_line_total
    FROM
      po_requisition_lines_all prl,
      po_req_distributions_all prd
    WHERE
      prl.requisition_line_id = reqlineid AND
      prl.requisition_line_id =  prd.requisition_line_id;

     -- get old tax
    old_rec_tax := por_view_reqs_pkg.get_line_rec_tax_total(reqlineid);

    changed_tax_total := nvl((old_rec_tax * (new_line_total / old_line_total)), 0);

    RETURN changed_tax_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_changed_line_rec_tax_total;


  /**********************************************************************
   * This function returns overall status for a given request group id  *
   * and a given requisition line id. The overall status value is       *
   * displayed on Change History Page                                   *
   *                                                                    *
   * The logic :                                                        *
   *   - If all requests for the given requisition line is accepted     *
   *     return 'ACCEPTED'                                              *
   *   - If any request for the given requisition line is rejected      *
   *     return 'REJECTED'                                              *
   *   - else return 'PENDING'                                          *
   **********************************************************************/
  FUNCTION get_change_hist_overall_status(requestgroupid IN NUMBER,
                                          reqlineid NUMBER)
  RETURN VARCHAR2 IS
  overall_status VARCHAR2(30) := 'PENDING';
  x_value VARCHAR2(30) := '';
  distinct_values NUMBER := 0;

  CURSOR status_cursor(groupid NUMBER, documentlineid NUMBER) IS
  SELECT DISTINCT(request_status)
  FROM
    po_change_requests pcr
  WHERE
    pcr.document_type = 'REQ' AND
    pcr.document_line_id = documentlineid AND
    pcr.action_type IN ('MODIFICATION', 'CANCELLATION') AND
    pcr.change_request_group_id = groupid;

  BEGIN

    OPEN status_cursor(requestgroupid, reqlineid);

    LOOP

      FETCH status_cursor
      INTO  x_value;

      IF (x_value = 'REJECTED') THEN
        overall_status := 'REJECTED';
        EXIT;  -- exit the loop
      END IF;

      EXIT WHEN status_cursor%notfound;

      distinct_values := distinct_values + 1;

    END LOOP;

    CLOSE status_cursor;

    IF (x_value = 'ACCEPTED' AND distinct_values < 2) THEN
      overall_status := 'ACCEPTED';
    END IF;

    RETURN overall_status;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_change_hist_overall_status;


  /**********************************************************************
   * This function returns request status for a given request group id  *
   * and a given requisition line id for rco notifications.             *
   *                                                                    *
   * The logic :                                                        *
   *   - If all requests for the given requisition line is accepted     *
   *     return 'ACCEPTED'                                              *
   *   - If all requests for the given requisition line is rejected     *
   *     return 'REJECTED'                                              *
   *   - If some requests for the given requisition line are rejected   *
   *     and some are accepted                                          *
   *     return 'PARTIALLY'                                             *
   *   - else return 'PENDING'                                          *
   **********************************************************************/
  FUNCTION get_chng_hist_req_status_notfn(requestgroupid IN NUMBER,
                                          reqlineid NUMBER)
  RETURN VARCHAR2 IS
  overall_status VARCHAR2(30) := 'PENDING';
  x_value VARCHAR2(30) := '';

  CURSOR status_cursor(groupid NUMBER, documentlineid NUMBER) IS
  SELECT DISTINCT(request_status)
  FROM
    po_change_requests pcr
  WHERE
    pcr.document_type = 'REQ' AND
    pcr.document_line_id = documentlineid AND
    pcr.action_type IN ('MODIFICATION', 'CANCELLATION') AND
    pcr.change_request_group_id = groupid;
  BEGIN
    OPEN status_cursor(requestgroupid, reqlineid);

    LOOP
      FETCH status_cursor INTO x_value;
      EXIT WHEN status_cursor%notfound;
      IF (x_value IN ('REJECTED', 'ACCEPTED') AND overall_status <> 'PENDING') THEN
        overall_status := 'PARTIALLY';
        EXIT;  --exit the loop
      ELSIF (x_value = 'REJECTED') THEN
        overall_status := 'REJECTED';
      ELSIF (x_value = 'ACCEPTED') THEN
        overall_status := 'ACCEPTED';
      END IF;
    END LOOP;
    CLOSE status_cursor;

    RETURN overall_status;
  EXCEPTION
    WHEN OTHERS THEN
    RETURN 'PENDING';
  END get_chng_hist_req_status_notfn;

 /**************************************************************************
  * This function returns multiple_value if there are multiple             *
  * distributions or 'SINGLE_VALUE' if there are multiple distributions    *
  * fo the given requisition line id 				    	   *
  **************************************************************************/
  FUNCTION get_multiple_distributions(req_line_id NUMBER) RETURN VARCHAR2 IS
  no_of_values NUMBER := 0;
  BEGIN
    SELECT COUNT(distribution_id)
    INTO no_of_values
    FROM po_req_distributions_all
    WHERE requisition_line_id = req_line_id;

    IF (no_of_values > 1) THEN
      RETURN 'MULTIPLE_VALUE';
    ELSE
      RETURN 'SINGLE_VALUE';
    END IF;

  END get_multiple_distributions;


  FUNCTION get_changed_line_quantity(reqlineid IN NUMBER)
  RETURN NUMBER IS
  changed_quantity  NUMBER := 0;
  grp_id NUMBER := 0;
  BEGIN

    SELECT MIN(pcr.change_request_group_id)
    INTO grp_id
    FROM
      po_requisition_lines_all prl,
      po_change_requests pcr
    WHERE
      pcr.document_header_id = prl.requisition_header_id
      AND prl.requisition_line_id = reqlineid
      AND pcr.request_status = 'SYSTEMSAVE';

    SELECT nvl(po_rcotolerance_pvt.get_new_line_quantity(prl.requisition_header_id, prl.requisition_line_id, grp_id), 0)
      INTO changed_quantity
      FROM po_requisition_lines_all prl
      WHERE prl.requisition_line_id = reqlineid ;

    RETURN changed_quantity;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_changed_line_quantity;

 /**************************************************************************
  * This function returns the updated line total for a given requisition   *
  * line id and change request group id.                                   *
  **************************************************************************/
  FUNCTION get_hist_changed_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  matching_basis po_requisition_lines.matching_basis%TYPE := '';
  BEGIN

    SELECT matching_basis
    INTO matching_basis
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (matching_basis = 'QUANTITY') THEN
      --Bug:19280546
      RETURN (nvl(/*nvl(get_price_break_price(reqlineid, chgreqgrpid), */get_hist_changed_line_price(reqlineid, chgreqgrpid), nvl(get_hist_line_price(reqlineid, chgreqgrpid), 0)) *
              nvl(get_hist_changed_line_qty(reqlineid, chgreqgrpid), get_hist_line_qty(reqlineid, chgreqgrpid)));
    ELSE
      RETURN nvl(get_hist_changed_line_amount(reqlineid, chgreqgrpid), get_hist_line_amount(reqlineid, chgreqgrpid));
    END IF;

  EXCEPTION WHEN OTHERS THEN
    RETURN 0;

  END get_hist_changed_line_total;

 /**************************************************************************
  * This function returns the updated line price for history page          *
  * for a given requisition line id and change request group id            *
  * if there is no price change, then it returns null                      *
  **************************************************************************/
  FUNCTION get_hist_changed_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  new_price  NUMBER;
  BEGIN

    SELECT new_price
    INTO new_price
    FROM po_change_requests
    WHERE
      change_request_group_id = chgreqgrpid AND
      document_line_id = reqlineid AND
      document_type = 'REQ' AND
      action_type = 'MODIFICATION' AND --Bug:19280546
      request_level = 'LINE' AND
      new_price IS NOT NULL;

    RETURN new_price;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;

  END get_hist_changed_line_price;


 /**************************************************************************
  * This function returns the old/unchanged line total during
  * a change request in Requester Change Order
  * it calculates the old line total for a particular change request group id
  **************************************************************************/
  FUNCTION get_hist_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  matching_basis  po_requisition_lines.matching_basis%TYPE := '';
  BEGIN

    SELECT matching_basis
    INTO matching_basis
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (matching_basis = 'QUANTITY') THEN
      RETURN nvl(get_hist_line_price(reqlineid, chgreqgrpid), 0) * get_hist_line_qty(reqlineid, chgreqgrpid);
    ELSE
      RETURN get_hist_line_amount(reqlineid, chgreqgrpid);
    END IF;

  EXCEPTION WHEN OTHERS THEN
    RETURN 0;

  END get_hist_line_total;


 /***************************************************************************
  * This function returns the original line price before the change request *
  * for a given requisition line id and change request group id             *
  ***************************************************************************/
  FUNCTION get_hist_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  line_price  NUMBER;
  BEGIN

    SELECT DISTINCT(old_price)
    INTO line_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      old_price IS NOT NULL;

    RETURN line_price;

  EXCEPTION

    WHEN OTHERS THEN
    RETURN NULL;

  END get_hist_line_price;

 /***************************************************************************
  * This function returns the original currency line price before the change*
  * request for a given requisition line id and change request group id     *
  ***************************************************************************/
  FUNCTION get_hist_cur_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  cur_line_price  NUMBER;
  l_req_rate      NUMBER := 1;

  BEGIN

    SELECT DISTINCT(old_currency_unit_price)
    INTO cur_line_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      old_currency_unit_price IS NOT NULL;

    RETURN cur_line_price;

  EXCEPTION
    WHEN OTHERS THEN

    SELECT rate INTO l_req_rate
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (l_req_rate IS NOT NULL ) THEN

      RETURN get_hist_line_price(reqlineid, chgreqgrpid) / l_req_rate;
    ELSE

      RETURN get_hist_line_price(reqlineid, chgreqgrpid);

    END IF;

  END get_hist_cur_line_price;

 /***************************************************************************
  * This function returns the changed currency line price                   *
  * for a given requisition line id and change request group id             *
  ***************************************************************************/
  FUNCTION get_hist_chng_cur_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  cur_line_price  NUMBER := 0;
  l_req_rate NUMBER := 1;

  BEGIN

    SELECT DISTINCT(new_currency_unit_price)
    INTO cur_line_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      new_currency_unit_price IS NOT NULL;

    RETURN cur_line_price;

  EXCEPTION

    WHEN OTHERS THEN
    cur_line_price := get_hist_changed_line_price(reqlineid, chgreqgrpid);
    IF (cur_line_price IS NULL) THEN
      cur_line_price := nvl(get_hist_line_price(reqlineid, chgreqgrpid), 0);
    END IF;

      -- if req is created in txn currency, need to convert with rate
    SELECT rate INTO l_req_rate
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (l_req_rate IS NOT NULL) THEN
      RETURN cur_line_price / l_req_rate;

    ELSE
      RETURN cur_line_price;

    END IF;

  END get_hist_chng_cur_line_price;


 /**************************************************************************
  * This function returns the old/unchanged line quantity                  *
  * for a specific requisition line and change request group id            *
  **************************************************************************/
  FUNCTION get_hist_line_qty(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  line_qty  NUMBER := 0;
  BEGIN

    SELECT old_quantity
    INTO line_qty
    FROM
      po_change_requests pcr
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      (action_type = 'DERIVED'  OR (action_type = 'MODIFICATION'
       AND NOT EXISTS (SELECT 1 FROM po_change_requests
       WHERE change_request_group_id = pcr.change_request_group_id
       AND document_line_id = pcr.document_line_id
       AND  document_type = 'REQ'
       AND action_type = 'DERIVED')))
      AND old_quantity IS NOT NULL;

    RETURN line_qty;

  EXCEPTION
    WHEN no_data_found THEN
    SELECT quantity
    INTO line_qty
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    RETURN line_qty;

    WHEN OTHERS THEN
    RETURN 0;

  END get_hist_line_qty;


 /**************************************************************************
  * This function returns the newly updated line quantity                  *
  * for a specific change request group                                    *
  **************************************************************************/
  FUNCTION get_hist_changed_line_qty(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  line_qty  NUMBER;
  BEGIN

    SELECT new_quantity
    INTO line_qty
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
     ( action_type = 'DERIVED' OR REQUEST_LEVEL = 'LINE') AND
      new_quantity IS NOT NULL;

    RETURN line_qty;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;

  END get_hist_changed_line_qty;


 /**************************************************************************
  * This function returns the price break price from po_change_requests    *
  * for a given requisition line id and change request group id            *
  * if there is no price break price, it returns NULL                      *
  **************************************************************************/
  FUNCTION get_price_break_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  new_price  NUMBER;
  BEGIN

    SELECT new_price
    INTO new_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      new_price IS NOT NULL;

    RETURN new_price;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;

  END get_price_break_price;

 /**************************************************************************
  * This function returns the price break price from po_change_requests    *
  * for a given requisition line id and change request group id            *
  * if there is no price break price, it returns NULL                      *
  **************************************************************************/
  FUNCTION get_price_break_cur_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  new_cur_price  NUMBER;
  BEGIN

    SELECT new_currency_unit_price
    INTO new_cur_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      new_currency_unit_price IS NOT NULL;

    RETURN new_cur_price;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;

  END get_price_break_cur_price;

 /**************************************************************************
  * This function returns the price break currency unit price from         *
  * po_change_requests                                                     *
  * for a given requisition line id and change request group id            *
  * if there is no price break price, it returns NULL                      *
  **************************************************************************/
  FUNCTION get_price_break_trx_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  new_price  NUMBER;
  BEGIN

    SELECT nvl(new_currency_unit_price, new_price)
    INTO new_price
    FROM
      po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      new_price IS NOT NULL;

    RETURN new_price;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;

  END get_price_break_trx_price;


 /**************************************************************************
  * This function is called from ChangeOrderReviewDistributionsVO          *
  * returns changed line quantity for the current change request           *
  **************************************************************************/
  FUNCTION get_dist_changed_line_qty(reqheaderid NUMBER, reqlineid NUMBER)
  RETURN NUMBER IS
  chggroupid NUMBER := 0;
  BEGIN
    SELECT MAX(change_request_group_id)
    INTO chggroupid
    FROM po_change_requests
    WHERE document_header_id = reqheaderid AND
    document_type = 'REQ';

    RETURN get_hist_changed_line_qty(reqlineid, chggroupid);

  END get_dist_changed_line_qty;

 /**************************************************************************
  * This function is called from ChangeOrderReviewDistributionsVO          *
  * returns changed line quantity for the current change request           *
  **************************************************************************/
  FUNCTION get_dist_changed_line_amt(reqheaderid NUMBER, reqlineid NUMBER)
  RETURN NUMBER IS
  chggroupid NUMBER := 0;
  BEGIN
    SELECT MAX(change_request_group_id)
    INTO chggroupid
    FROM po_change_requests
    WHERE document_header_id = reqheaderid AND
    document_type = 'REQ';

    RETURN get_hist_changed_line_amount(reqlineid, chggroupid);

  END get_dist_changed_line_amt;


 /**************************************************************************
  * This function returns changed line total for amount based lines        *
  **************************************************************************/
  FUNCTION get_hist_changed_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN
    SELECT new_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      new_amount IS NOT NULL;

    RETURN amount;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;

  END get_hist_changed_line_amount;


 /**************************************************************************
  * This function returns the old/unchanged line amount for a given        *
  * requisition line and change request group id                           *
  **************************************************************************/
  FUNCTION get_hist_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN
    SELECT old_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      old_amount IS NOT NULL;

    RETURN amount;

  EXCEPTION
    WHEN no_data_found THEN
    SELECT amount
    INTO amount
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    RETURN amount;

    WHEN OTHERS THEN
    RETURN 0;

  END get_hist_line_amount;

 /**************************************************************************
  * This function returns the old/unchanged currency line total during
  * a change request in Requester Change Order
  * it calculates the old line total for a particular change request group id
  **************************************************************************/
  FUNCTION get_hist_cur_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  matching_basis  po_requisition_lines.matching_basis%TYPE := '';
  BEGIN

    SELECT matching_basis
    INTO matching_basis
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (matching_basis = 'QUANTITY') THEN
      RETURN nvl(get_hist_cur_line_price(reqlineid, chgreqgrpid), 0) * get_hist_line_qty(reqlineid, chgreqgrpid);
    ELSE
      RETURN get_hist_cur_line_amount(reqlineid, chgreqgrpid);
    END IF;

  EXCEPTION WHEN OTHERS THEN
    RETURN 0;

  END get_hist_cur_line_total;

 /**************************************************************************
  * This function returns line total for amount based lines
  **************************************************************************/
  FUNCTION get_hist_cur_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN
    SELECT old_currency_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      old_currency_amount IS NOT NULL;

    RETURN amount;

  EXCEPTION
    WHEN no_data_found THEN
    SELECT nvl(currency_amount, amount)
    INTO amount
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    RETURN amount;

    WHEN OTHERS THEN
    RETURN 0;

  END get_hist_cur_line_amount;

 /**************************************************************************
  * This function returns currency unit price of a given line.             *
  * If there is any currency unit price change exist in po_change_requests *
  * table, it returns that value otherwise returns currency_unit_price     *
  * from po_requisition_lines                                   	   *
  **************************************************************************/
  FUNCTION get_currency_unit_price(reqlineid NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  cur_unit_price NUMBER := 0;
  BEGIN
    --Bug:19280546
    --cur_unit_price := get_price_break_cur_price(reqlineid, chgreqgrpid);

    --IF (cur_unit_price IS NULL) THEN

      SELECT new_currency_unit_price
      INTO cur_unit_price
      FROM po_change_requests
      WHERE
        document_line_id = reqlineid AND
        document_type = 'REQ' AND
        action_type = 'MODIFICATION' AND
        request_status = 'SYSTEMSAVE' AND
        new_currency_unit_price IS NOT NULL;
    --END IF;

    RETURN cur_unit_price;

  EXCEPTION

    WHEN no_data_found THEN
    SELECT currency_unit_price
    INTO cur_unit_price
    FROM po_requisition_lines_all
    WHERE
      requisition_line_id = reqlineid;

    RETURN cur_unit_price;

    WHEN OTHERS THEN
    RETURN NULL;

  END get_currency_unit_price;

 /**************************************************************************
  * This function returns the changed currency line total during
  * a change request in Requester Change Order
  * it calculates the old line total for a particular change request group id
  **************************************************************************/
  FUNCTION get_hist_chng_cur_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  matching_basis  po_requisition_lines.matching_basis%TYPE := '';
  BEGIN

    SELECT matching_basis
    INTO matching_basis
    FROM po_requisition_lines_all
    WHERE requisition_line_id = reqlineid;

    IF (matching_basis = 'QUANTITY') THEN
      RETURN get_hist_chng_cur_line_price(reqlineid, chgreqgrpid) * get_hist_changed_line_qty(reqlineid, chgreqgrpid);
    ELSE
      RETURN get_hist_chng_cur_line_amount(reqlineid, chgreqgrpid);
    END IF;

  EXCEPTION WHEN OTHERS THEN
    RETURN 0;

  END get_hist_chng_cur_line_total;

 /**************************************************************************
  * This function returns line total for amount based lines
  **************************************************************************/
  FUNCTION get_hist_chng_cur_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN
    SELECT new_currency_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_line_id = reqlineid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ' AND
      action_type = 'DERIVED' AND
      new_currency_amount IS NOT NULL;

    RETURN amount;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;

  END get_hist_chng_cur_line_amount;

/**************************************************************************
  * This function returns distribution currency total for amount based lines
  **************************************************************************/
  FUNCTION get_hist_cur_dist_amount(reqdistid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN

    SELECT old_currency_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_distribution_id = reqdistid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ';

    RETURN amount;

  END get_hist_cur_dist_amount;


  /**************************************************************************
  * This function returns changed distribution currency total for amount based lines
  **************************************************************************/
  FUNCTION get_chng_hist_cur_dist_amount(reqdistid IN NUMBER, chgreqgrpid IN NUMBER)
  RETURN NUMBER IS
  amount NUMBER := 0;
  BEGIN
    SELECT new_currency_amount
    INTO amount
    FROM po_change_requests
    WHERE
      document_distribution_id = reqdistid AND
      change_request_group_id = chgreqgrpid AND
      document_type = 'REQ';

    RETURN amount;


  END get_chng_hist_cur_dist_amount;


 /**************************************************************************
  * This function returns the non recoverable tax amount of a requisition  *
  * line during requester change order flow                                *
  **************************************************************************/
  FUNCTION get_intchnline_nonrectax_total(reqlineid IN NUMBER) RETURN NUMBER IS
  changed_tax_total NUMBER := 0;
  new_line_total NUMBER := 0;
  old_nonrec_tax NUMBER := 0;
  old_line_total NUMBER := 0;
  BEGIN

     -- get changed line total
    new_line_total := get_int_changed_line_total(reqlineid);

     -- get old line total
     --SELECT SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount,prd.req_line_quantity*prl.unit_price))
    SELECT SUM(prd.req_line_quantity * prl.unit_price)
     INTO old_line_total
  FROM
    po_requisition_lines_all prl,
    po_req_distributions prd
  WHERE
    prl.requisition_line_id = reqlineid AND
    prl.requisition_line_id =  prd.requisition_line_id;

     -- get old tax
    old_nonrec_tax := por_view_reqs_pkg.get_line_nonrec_tax_total(reqlineid);

    changed_tax_total := nvl((old_nonrec_tax * (new_line_total / old_line_total)), 0);

    RETURN changed_tax_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_intchnline_nonrectax_total;


 /**************************************************************************
  * This function returns the recoverable tax amount of a requisition      *
  * line during requester change order flow                                *
  **************************************************************************/
  FUNCTION get_intchnline_rectax_total(reqlineid IN NUMBER) RETURN NUMBER IS
  changed_tax_total NUMBER := 0;
  new_line_total NUMBER := 0;
  old_rec_tax NUMBER := 0;
  old_line_total NUMBER := 0;
  BEGIN
     -- get changed line total
    new_line_total := get_int_changed_line_total(reqlineid);

     -- get old line total
   --  SELECT SUM(decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount,prd.req_line_quantity*prl.unit_price))
    SELECT SUM(prd.req_line_quantity * prl.unit_price)
    INTO old_line_total
  FROM
    po_requisition_lines_all prl,
    po_req_distributions_all prd
  WHERE
    prl.requisition_line_id = reqlineid AND
    prl.requisition_line_id =  prd.requisition_line_id;

     -- get old tax
    old_rec_tax := por_view_reqs_pkg.get_line_rec_tax_total(reqlineid);

    changed_tax_total := nvl((old_rec_tax * (new_line_total / old_line_total)), 0);

    RETURN changed_tax_total;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
  END get_intchnline_rectax_total;




END por_change_request_pkg;

/
