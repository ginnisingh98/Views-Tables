--------------------------------------------------------
--  DDL for Package Body XXAH_VA_AUTOACCRUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_AUTOACCRUAL_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_AUTOACCRUAL_PKG.plb 72 2015-08-05 10:59:01Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the approval workflow.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 11-AUG-2010 Kevin Bouwmeester Genesis.
 *  7-DEC-2010 Joost Voordouw    pickup only blanket agreements of type 'VA-ACCRUAL'
 *  7-DEC-2010 Joost Voordouw    select default 'ACCRUAL' pricelist-id
 *  5-JANUARI-2011 Joost Voordouw Added Oe_Transaction_Types_All
 *  7-JANUARI-2011 Joost Voordouw ONLY for OE_BLANKET_HEADERS_ALL
 *                                Added Oe_Transaction_Types_All tta_2
 * 12-MAR-2012 Richard Velden     Modified interface to also process already accrued lines.
 *								  Updates to Sales Agreements will result in updated accruals
  *************************************************************************/

-- ----------------------------------------------------------------------
-- Private types
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private constants
-- ----------------------------------------------------------------------
    gc_order_type_acc CONSTANT VARCHAR2(30) := 'VA-ACCRUAL';
-- ----------------------------------------------------------------------
-- Private variables
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private cursors
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private exceptions
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Forward declarations
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private subprograms
-- ----------------------------------------------------------------------

    PROCEDURE write_log (
        p_message IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        fnd_log.string(log_level => fnd_log.level_statement, module => 'XXAH_VA_AME_WF_PKG', message => to_char(systimestamp, 'HH24:MI:SS.FF2 '
        )
                                                                                                        || p_message);
    END write_log;

    PROCEDURE out (
        p_message IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        fnd_file.put(fnd_file.output, p_message);
    END out;

    PROCEDURE outline (
        p_message IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        fnd_file.put_line(fnd_file.output, p_message);
    END outline;

    PROCEDURE log (
        p_message IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        fnd_file.put_line(fnd_file.log, to_char(systimestamp, 'HH24:MI:SS.FF2 ')
                                        || p_message);

        dbms_output.put_line(p_message);
    END log;

  /*
   * get_accrual_amount
   */
    FUNCTION get_accrual_amount (
        p_blanket_line_id IN oe_blanket_lines_all.line_id%TYPE,
        p_period_set_name IN gl_periods.period_set_name%TYPE,
        p_period_type     IN gl_periods.period_type%TYPE,
        p_period_name     IN gl_periods.period_name%TYPE
    ) RETURN NUMBER IS

        CURSOR c_total_periods (
            b_start_date      IN DATE,
            b_end_date        IN DATE,
            b_period_type     IN gl_periods.period_type%TYPE,
            b_period_set_name IN gl_periods.period_set_name%TYPE
        ) IS
        SELECT
            COUNT(gp.period_name)
        FROM
            gl_periods gp
        WHERE
                gp.period_set_name = b_period_set_name
            AND gp.period_type = b_period_type
            AND ( b_start_date BETWEEN gp.start_date AND gp.end_date
                  OR b_end_date BETWEEN gp.start_date AND gp.end_date
                  OR ( b_start_date < gp.start_date
                       AND b_end_date >= gp.end_date ) );

        CURSOR c_done_periods (
            b_cur_start_date  IN DATE,
            b_start_date      IN DATE,
            b_end_date        IN DATE,
            b_period_type     IN gl_periods.period_type%TYPE,
            b_period_set_name IN gl_periods.period_set_name%TYPE
        ) IS
        SELECT
            COUNT(gp.period_name)
        FROM
            gl_periods gp
        WHERE
                gp.period_set_name = b_period_set_name
            AND gp.period_type = b_period_type
            AND ( b_start_date BETWEEN gp.start_date AND gp.end_date
                  OR b_end_date BETWEEN gp.start_date AND gp.end_date
                  OR ( b_start_date < gp.start_date
                       AND b_end_date >= gp.end_date ) )
            AND gp.end_date <= b_cur_start_date;

    -- RVELDEN: Added returns to the equation.
	-- Net amount = released - returned
        CURSOR c_accrued (
            b_blanket_line_id oe_blanket_lines_all.line_id%TYPE
        ) IS
        SELECT
            e.blanket_line_min_amount,
            nvl(e.released_amount, 0)                                                         released_amount,
            nvl(e.returned_amount, 0)                                                         returned_amount,
            e.blanket_line_min_amount - nvl(e.released_amount, 0) + nvl(e.returned_amount, 0) amount_to_release,
            e.start_date_active,
            e.end_date_active
        FROM
            oe_blanket_lines_ext e
        WHERE
            e.line_id = b_blanket_line_id;

        CURSOR c_invoiced (
            b_blanket_line_id oe_blanket_lines_all.line_id%TYPE
        ) IS
        SELECT
            SUM(olin.fulfilled_quantity * nvl(olin.unit_list_price_per_pqty, 1)) invoiced_amount
        FROM
            oe_blanket_lines_all     blin,
            oe_blanket_headers_all   bhea,
            oe_order_headers_all     ohea,
            oe_order_lines_all       olin,
            ra_batch_sources_all     rbs,
            oe_transaction_types_all tta
        WHERE
                blin.header_id = bhea.header_id
            AND olin.blanket_number = bhea.order_number
            AND olin.blanket_line_number = blin.line_number
            AND ohea.header_id = olin.header_id
            AND tta.org_id = ohea.org_id
            AND tta.org_id = rbs.org_id
            AND blin.line_id = b_blanket_line_id
            AND tta.invoice_source_id = rbs.batch_source_id
            AND rbs.name = 'VA-INVOICE'
            AND tta.transaction_type_id = ohea.order_type_id;

        r_accrued           c_accrued%rowtype;
        v_invoiced          oe_order_lines_all.fulfilled_quantity%TYPE;
        l_period_count      NUMBER;
        l_period_done       NUMBER;
        l_amount_per_period NUMBER;
        l_cur_start_date    DATE;
        l_cur_end_date      DATE;
        l_return_value      NUMBER;
    BEGIN
        SELECT
            p.start_date,
            p.end_date
        INTO
            l_cur_start_date,
            l_cur_end_date
        FROM
            gl_periods p
        WHERE
                p.period_type = p_period_type
            AND p.period_set_name = p_period_set_name
            AND p.period_name = p_period_name;

    -- [(N+1) * P] - A
    -- N = number of periods already booked
    -- P = quantity to accrue per period
    -- A = quantity already accrued in the previous periods
	-- =A.released_amount-A.returned_amount

        OPEN c_accrued(p_blanket_line_id);
        FETCH c_accrued INTO r_accrued; -- A
        CLOSE c_accrued;
        OPEN c_total_periods(r_accrued.start_date_active, r_accrued.end_date_active, p_period_type, p_period_set_name);
        FETCH c_total_periods INTO l_period_count;
        CLOSE c_total_periods;
        OPEN c_done_periods(l_cur_start_date, r_accrued.start_date_active, r_accrued.end_date_active, p_period_type, p_period_set_name
        );
        FETCH c_done_periods INTO l_period_done; -- N
        CLOSE c_done_periods;

    -- determine P
    -- When an invoice is linked to this blanket, it will show up as a release when created from the
    -- webadi upload, and not when created via copy lines. (in the last case, the blanket_line_number
    -- is empty...) However, the invoice amount should not influence the accrued amount.
    -- so substract the invoice amount from linked lines...
        OPEN c_invoiced(p_blanket_line_id);
        FETCH c_invoiced INTO v_invoiced;
        IF c_invoiced%notfound THEN
            v_invoiced := 0;
        END IF;
        CLOSE c_invoiced;
        IF v_invoiced IS NULL THEN
            v_invoiced := 0;
        END IF;
    --
        l_amount_per_period := ( r_accrued.blanket_line_min_amount ) / l_period_count;
        l_return_value := ( ( l_period_done + 1 ) * l_amount_per_period ) - ( ( r_accrued.released_amount - v_invoiced ) - r_accrued.returned_amount
        );

        RETURN l_return_value;
    END get_accrual_amount;

  /*
   * Create_order
   */
    PROCEDURE create_order (
        p_blanket_header_id IN oe_blanket_headers_all.header_id%TYPE,
        p_blanket_number    IN oe_blanket_headers_all.order_number%TYPE,
        p_ship_to_org_id    IN NUMBER,
        p_sold_to_org_id    IN NUMBER,
        p_invoice_to_org_id IN NUMBER,
        p_period_name       IN gl_periods.period_name%TYPE,
        p_sales_rep_id      IN NUMBER,
        p_payment_term_id   IN NUMBER,
        p_price_list_id     IN NUMBER,
        p_order_type_id     IN NUMBER,
        p_period_set_name   IN VARCHAR2,
        p_period_type       IN VARCHAR2,
        x_order_number      OUT VARCHAR2
    ) IS

        CURSOR c_lines (
            b_blanket_header_id IN oe_blanket_headers_all.header_id%TYPE,
            b_period_name       IN gl_periods.period_name%TYPE,
            b_blanket_number    IN oe_blanket_headers_all.order_number%TYPE
        ) IS
        SELECT
            h.header_id,
            h.org_id,
            e.end_date_active expiration_date,
            l.line_id,
            l.line_number,
            l.inventory_item_id,
            l.ship_to_org_id,
            l.sold_to_org_id,
            l.invoice_to_org_id,
            lfl.cost_center,
            lfl.line_description,
            lfl.open_item_key
            || '|'
            || gp.period_year open_item_key
        FROM
            oe_blanket_headers_all     h,
            oe_blanket_headers_all_dfv hfv,
            oe_blanket_lines_ext       e,
            oe_blanket_lines_all       l,
            oe_blanket_lines_all_dfv   lfl,
            gl_periods                 gp,
            ra_batch_sources_all       rbs    -- JV: 7/12/2010
            ,
            oe_transaction_types_all   tta_1,
            oe_transaction_types_all   tta_2
        WHERE
                h.header_id = b_blanket_header_id
            AND gp.period_name = b_period_name
            AND rbs.name = gc_order_type_acc
            AND tta_1.transaction_type_id = h.order_type_id    -- JV: 5/1/2011
            AND tta_1.attribute1 = tta_2.transaction_type_id   -- JV: 5/1/2011
            AND tta_2.invoice_source_id = rbs.batch_source_id   -- JV: 5/1/2011
            AND l.header_id = h.header_id
            AND l.line_id = e.line_id
            AND lfl.row_id = l.rowid
            AND h.rowid = hfv.row_id
            AND nvl(hfv.automatic_accrual, 'Y') = 'Y'
            AND nvl(lfl.accrue_yes_no, 'Y') = 'Y'
            AND nvl(rbs.name, gc_order_type_acc) = gc_order_type_acc
            AND ( ( e.start_date_active <= gp.start_date
                    AND e.end_date_active >= gp.end_date )
                  OR ( e.start_date_active BETWEEN gp.start_date AND gp.end_date )
                  OR ( e.end_date_active BETWEEN gp.start_date AND gp.end_date ) )
    -- Line not yet accrued
/*
--RVELDEN: Also take already accrued items into account
--Whenever updates occur on Sales Agreements, we need to create a new accrual line
--to reflect this change
    AND    l.line_number NOT IN		-- 12-03-2012 no longer exclude already accrued agreement lines
    ( SELECT ola.blanket_line_number
      FROM   oe_order_lines_all ola
      ,      oe_order_headers_all oha
      WHERE  ola.blanket_number = b_blanket_number
      AND    oha.ordered_date BETWEEN gp.start_date AND gp.end_date
      AND    ola.header_id = oha.header_id
      )
*/
            AND EXISTS (
                SELECT
                    1
                FROM
                    hr_organization_information hoi,
                    mtl_cross_references_b      mcr
                WHERE
                        hoi.organization_id = l.org_id
                    AND hoi.org_information_context = 'Operating Unit Information'
                    AND hoi.org_information19 = mcr.cross_reference_type
                    AND l.inventory_item_id = mcr.inventory_item_id
                    AND mcr.attribute1 IS NOT NULL
            );

        l_api_version_number         NUMBER := 1;
        l_return_status              VARCHAR2(2000);
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
    /*****************PARAMETERS****************************************************/
        l_debug_level                NUMBER := 0;        -- OM DEBUG LEVEL (MAX 5)

    /*****************INPUT VARIABLES FOR PROCESS_ORDER API*************************/
        l_header_rec                 oe_order_pub.header_rec_type;
        l_line_tbl                   oe_order_pub.line_tbl_type;
        l_action_request_tbl         oe_order_pub.request_tbl_type;
        l_line_adj_tbl               oe_order_pub.line_adj_tbl_type;
    /*****************OUT VARIABLES FOR PROCESS_ORDER API***************************/
        l_header_rec_out             oe_order_pub.header_rec_type;
        l_header_val_rec_out         oe_order_pub.header_val_rec_type;
        l_header_adj_tbl_out         oe_order_pub.header_adj_tbl_type;
        l_header_adj_val_tbl_out     oe_order_pub.header_adj_val_tbl_type;
        l_header_price_att_tbl_out   oe_order_pub.header_price_att_tbl_type;
        l_header_adj_att_tbl_out     oe_order_pub.header_adj_att_tbl_type;
        l_header_adj_assoc_tbl_out   oe_order_pub.header_adj_assoc_tbl_type;
        l_header_scredit_tbl_out     oe_order_pub.header_scredit_tbl_type;
        l_header_scredit_val_tbl_out oe_order_pub.header_scredit_val_tbl_type;
        l_line_tbl_out               oe_order_pub.line_tbl_type;
        l_line_val_tbl_out           oe_order_pub.line_val_tbl_type;
        l_line_adj_tbl_out           oe_order_pub.line_adj_tbl_type;
        l_line_adj_val_tbl_out       oe_order_pub.line_adj_val_tbl_type;
        l_line_price_att_tbl_out     oe_order_pub.line_price_att_tbl_type;
        l_line_adj_att_tbl_out       oe_order_pub.line_adj_att_tbl_type;
        l_line_adj_assoc_tbl_out     oe_order_pub.line_adj_assoc_tbl_type;
        l_line_scredit_tbl_out       oe_order_pub.line_scredit_tbl_type;
        l_line_scredit_val_tbl_out   oe_order_pub.line_scredit_val_tbl_type;
        l_lot_serial_tbl_out         oe_order_pub.lot_serial_tbl_type;
        l_lot_serial_val_tbl_out     oe_order_pub.lot_serial_val_tbl_type;
        l_action_request_tbl_out     oe_order_pub.request_tbl_type;
        l_msg_index                  NUMBER;
        l_data                       VARCHAR2(2000);
        l_line_count                 NUMBER;
        l_accrual_qty                NUMBER;
        l_organization_id            hr_all_organization_units.organization_id%TYPE;
        l_accrual_period_end_date    DATE;
    BEGIN
        SELECT
            gp.end_date
        INTO l_accrual_period_end_date
        FROM
            gl_periods gp
        WHERE
            gp.period_name = p_period_name;
    /*****************INITIALIZE DEBUG INFO************************************/
        IF ( l_debug_level > 0 ) THEN
      -- l_debug_file := oe_debug_pub.set_debug_mode ('FILE');
            oe_debug_pub.initialize;
            oe_debug_pub.setdebuglevel(l_debug_level);
            oe_msg_pub.initialize;
        END IF;

    /*****************INITIALIZE HEADER RECORD*********************************/
        l_header_rec := oe_order_pub.g_miss_header_rec;

    /*****************POPULATE REQUIRED ATTRIBUTES ****************************/
        l_header_rec.operation := oe_globals.g_opr_create;
        l_header_rec.order_type_id := p_order_type_id;
        l_header_rec.sold_to_org_id := p_sold_to_org_id;
        l_header_rec.ship_to_org_id := nvl(p_ship_to_org_id, p_invoice_to_org_id);
        l_header_rec.invoice_to_org_id := p_invoice_to_org_id;
        l_header_rec.ordered_date := l_accrual_period_end_date;
        l_header_rec.order_source_id := 0;
        l_header_rec.booked_flag := 'Y';
        l_header_rec.price_list_id := p_price_list_id;
        l_header_rec.pricing_date := sysdate;
        l_header_rec.transactional_curr_code := 'EUR';
        l_header_rec.flow_status_code := 'BOOKED';
        l_header_rec.blanket_number := p_blanket_number;
        l_header_rec.salesrep_id := p_sales_rep_id;
        l_header_rec.payment_term_id := p_payment_term_id;
        l_header_rec.shipping_instructions := p_period_name;
        l_header_rec.attribute4 := '.'; -- comment is mandatory

    /*****************INITIALIZE ACTION REQUEST RECORD*************************/
        l_action_request_tbl(1) := oe_order_pub.g_miss_request_rec;
        l_action_request_tbl(1).request_type := oe_globals.g_book_order;
        l_action_request_tbl(1).entity_code := oe_globals.g_entity_header;
        l_line_count := 1;
        log('Starting with lines for id: ' || p_blanket_header_id);
        log('Starting with lines for blanket number: ' || p_blanket_number);
        FOR r_line IN c_lines(b_blanket_header_id => p_blanket_header_id, b_period_name => p_period_name, b_blanket_number => p_blanket_number
        ) LOOP
            log('Line: ' || r_line.line_id);

      -- determine accrual amount , but put it in quantity field
            l_accrual_qty := get_accrual_amount(p_blanket_line_id => r_line.line_id, p_period_set_name => p_period_set_name, p_period_type => p_period_type
            , p_period_name => p_period_name);

            IF TO_NUMBER ( to_char(l_accrual_qty, '9999999999D99') ) != 0 THEN

        /*****************INITIALIZE LINE RECORD*********************************/
                l_line_tbl(l_line_count) := oe_order_pub.g_miss_line_rec;
                l_line_tbl(l_line_count).operation := oe_globals.g_opr_create;
                l_line_tbl(l_line_count).inventory_item_id := r_line.inventory_item_id;
                IF nvl(r_line.expiration_date, l_accrual_period_end_date) < l_accrual_period_end_date THEN
                    l_line_tbl(l_line_count).request_date := r_line.expiration_date;
                ELSE
                    l_line_tbl(l_line_count).request_date := l_accrual_period_end_date;
                END IF;

                l_line_tbl(l_line_count).ship_to_org_id := nvl(nvl(r_line.ship_to_org_id, p_ship_to_org_id), p_invoice_to_org_id);

                l_line_tbl(l_line_count).invoice_to_org_id := nvl(r_line.invoice_to_org_id, p_invoice_to_org_id);
                l_line_tbl(l_line_count).sold_to_org_id := nvl(r_line.sold_to_org_id, p_sold_to_org_id);
                l_line_tbl(l_line_count).calculate_price_flag := 'Y';
                l_line_tbl(l_line_count).blanket_line_number := r_line.line_number;
                l_line_tbl(l_line_count).blanket_number := p_blanket_number;
                l_line_tbl(l_line_count).attribute2 := r_line.line_description;
                l_line_tbl(l_line_count).attribute3 := r_line.cost_center;
                l_line_tbl(l_line_count).attribute4 := r_line.open_item_key;
                IF l_accrual_qty < 0 THEN
                    l_line_tbl(l_line_count).return_reason_code := 'NO REASON';
                END IF;
                log('Amount: ' || l_accrual_qty);
                l_line_tbl(l_line_count).ordered_quantity := TO_NUMBER ( to_char(l_accrual_qty, '9999999999D99') );
                l_line_count := l_line_count + 1;
            ELSE
                log('Line amount is zero for line_id '
                    || r_line.line_id
                    || ', line might already be completely accrued.');
            END IF;

        END LOOP;

    -- call API only of there are any lines for this header
    -- needed to start line count at one due to an issue with the process order api
        IF l_line_count > 1 THEN
            log('Calling API.');
            oe_msg_pub.reset;
            oe_order_pub.process_order(p_api_version_number => l_api_version_number, p_init_msg_list => fnd_api.g_true, p_header_rec => l_header_rec
            , p_line_tbl => l_line_tbl, p_action_request_tbl => l_action_request_tbl,
                                      p_line_adj_tbl => l_line_adj_tbl
      -- OUT variables
                                      , x_header_rec => l_header_rec_out, x_header_val_rec => l_header_val_rec_out, x_header_adj_tbl => l_header_adj_tbl_out
                                      , x_header_adj_val_tbl => l_header_adj_val_tbl_out,
                                      x_header_price_att_tbl => l_header_price_att_tbl_out, x_header_adj_att_tbl => l_header_adj_att_tbl_out
                                      , x_header_adj_assoc_tbl => l_header_adj_assoc_tbl_out, x_header_scredit_tbl => l_header_scredit_tbl_out
                                      , x_header_scredit_val_tbl => l_header_scredit_val_tbl_out,
                                      x_line_tbl => l_line_tbl_out, x_line_val_tbl => l_line_val_tbl_out, x_line_adj_tbl => l_line_adj_tbl_out
                                      , x_line_adj_val_tbl => l_line_adj_val_tbl_out, x_line_price_att_tbl => l_line_price_att_tbl_out
                                      ,
                                      x_line_adj_att_tbl => l_line_adj_att_tbl_out, x_line_adj_assoc_tbl => l_line_adj_assoc_tbl_out,
                                      x_line_scredit_tbl => l_line_scredit_tbl_out, x_line_scredit_val_tbl => l_line_scredit_val_tbl_out
                                      , x_lot_serial_tbl => l_lot_serial_tbl_out,
                                      x_lot_serial_val_tbl => l_lot_serial_val_tbl_out, x_action_request_tbl => l_action_request_tbl_out
                                      , x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data);

      /*****************CHECK RETURN STATUS**************************************/
            IF l_return_status = fnd_api.g_ret_sts_success THEN
                IF ( l_debug_level > 0 ) THEN
                    log('success');
                END IF;
                COMMIT;
            ELSE
                IF ( l_debug_level > 0 ) THEN
                    log('failure');
                END IF;
                ROLLBACK;
            END IF;

      /*****************DISPLAY RETURN STATUS FLAGS******************************/

            IF ( l_debug_level >= 0 ) THEN
                log('process ORDER ret status IS: ' || l_return_status);
        --log('process ORDER msg data IS: ' || l_msg_data);
        --log('process ORDER msg COUNT IS: ' || l_msg_count);
        --log('header.order_number IS: ' || TO_CHAR (l_header_rec_out.order_number));
        -- log('adjustment.return_status IS: '|| l_line_adj_tbl_out (1).return_status);
        --log('header.header_id IS: ' || l_header_rec_out.header_id);
        --log('line.unit_selling_price IS: ' || l_line_tbl_out (1).unit_selling_price);
            END IF;

      /*****************DISPLAY ERROR MSGS***************************************/
            IF ( l_debug_level >= 0 ) THEN
                FOR i IN 1..l_msg_count LOOP
                    oe_msg_pub.get(p_msg_index => i, p_encoded => fnd_api.g_false, p_data => l_data, p_msg_index_out => l_msg_index);

                    log('message is: ' || l_data);
                    log('message index is: ' || l_msg_index);
                END LOOP;
            END IF;

            IF ( l_debug_level > 0 ) THEN
                log('Debug = ' || oe_debug_pub.g_debug);
                log('Debug Level = ' || to_char(oe_debug_pub.g_debug_level));
                log('Debug File = '
                    || oe_debug_pub.g_dir
                    || '/'
                    || oe_debug_pub.g_file);
                log('****************************************************');
                oe_debug_pub.debug_off;
            END IF;

            x_order_number := to_char(l_header_rec_out.order_number);
        ELSE
            log('Release not created for header_id '
                || p_blanket_header_id
                || ', because no lines were selected.');
        END IF;

    END create_order;

-- ----------------------------------------------------------------------
-- Public subprograms
-- ----------------------------------------------------------------------
   /**************************************************************************
   *
   * PROCEDURE
   *   periodic_accrual
   *
   * DESCRIPTION
   *   Get the detais for the approval notification body.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * errbuf            OUT            output buffer for error messages
   * retcode           OUT            return code for concurrent program
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
    PROCEDURE periodic_accrual (
        errbuf        OUT VARCHAR2,
        retcode       OUT NUMBER,
        p_period_name IN VARCHAR2
    ) IS

        CURSOR c_calendar_type (
            b_org_id IN hr_all_organization_units.organization_id%TYPE
        ) IS
        SELECT
            i.org_information16 period_set_name,
            i.org_information17 period_type
        FROM
            hr_all_organization_units   u,
            hr_organization_information i
        WHERE
                u.organization_id = b_org_id
            AND i.organization_id = u.organization_id
            AND i.org_information_context = 'Operating Unit Information';

        CURSOR c_sales_agreements (
            b_period_name gl_periods.period_name%TYPE
        ) IS
        SELECT
            h.header_id                 header_id,
            h.order_number              order_number,
            h.ship_to_org_id            ship_to_org_id,
            h.sold_to_org_id            sold_to_org_id,
            h.invoice_to_org_id         invoice_to_org_id,
            h.salesrep_id               salesrep_id,
            h.payment_term_id           payment_term_id,
            (-- JV 7/12/2010
                SELECT
                    list_header_id
                FROM
                    qp_list_headers_all
                WHERE
                        list_header_id = nvl(fnd_profile.value('XXAH_ACCRUAL_PRICE_LIST'),
                                             6010)
                    AND ROWNUM = 1
            )                           price_list_id,
            p.party_name                customer,
            TO_NUMBER(tta_1.attribute1) order_type_id,
            h.flow_status_code          flow_status_code,
            COUNT(*)                    line_count
        FROM
            oe_blanket_headers_all     h,
            oe_blanket_headers_all_dfv hfv,
            oe_blanket_lines_ext       e,
            oe_blanket_lines_all       l,
            oe_blanket_lines_all_dfv   lfl,
            gl_periods                 gp,
            hz_parties                 p,
            hz_cust_accounts           c,
            ra_batch_sources_all       rbs,
            oe_transaction_types_all   tta_1,
            oe_transaction_types_all   tta_2
        WHERE
                l.header_id = h.header_id
            AND l.line_id = e.line_id
            AND h.org_id = fnd_global.org_id
            AND h.org_id = l.org_id
            AND h.org_id = tta_1.org_id
            AND h.flow_status_code IN ( 'ACTIVE', 'EXPIRED' )
            AND h.rowid = hfv.row_id
            AND nvl(hfv.automatic_accrual, 'Y') = 'Y'
            AND lfl.row_id = l.rowid
            AND nvl(lfl.accrue_yes_no, 'Y') = 'Y'
            AND nvl(l.attribute2, 'Y') = 'Y'
            AND rbs.name = gc_order_type_acc
            AND rbs.org_id = tta_1.org_id
            AND tta_1.transaction_type_id = h.order_type_id
            AND tta_1.attribute1 = tta_2.transaction_type_id
            AND tta_2.invoice_source_id = rbs.batch_source_id
            AND h.sold_to_org_id = c.cust_account_id
            AND c.party_id = p.party_id
            AND gp.period_name = b_period_name
            AND ( ( e.start_date_active <= gp.start_date
                    AND e.end_date_active >= gp.end_date )
                  OR ( e.start_date_active BETWEEN gp.start_date AND gp.end_date )
                  OR ( e.end_date_active BETWEEN gp.start_date AND gp.end_date ) )
        GROUP BY
            h.header_id,
            h.order_number,
            h.ship_to_org_id,
            h.sold_to_org_id,
            h.invoice_to_org_id,
            h.salesrep_id,
            h.payment_term_id,
            p.party_name,
            tta_1.attribute1,
            h.flow_status_code
        ORDER BY
            h.order_number;

        CURSOR c_sales_order (
            b_blanket_number    oe_blanket_headers_all.order_number%TYPE,
            b_blanket_header_id oe_blanket_headers_all.header_id%TYPE,
            b_period_name       gl_periods.period_name%TYPE
        ) IS
        SELECT
            COUNT(l.line_id) accrued_line_count
        FROM
            oe_order_headers_all     o,
            oe_order_lines_all       l,
            oe_blanket_lines_all     b,
            gl_periods               p,
            ra_batch_sources_all     rbs    -- JV: 7/12/2010
            ,
            oe_transaction_types_all tta   -- JV: 5/1/2011
        WHERE
                l.blanket_number = b_blanket_number
            AND o.flow_status_code = 'BOOKED'
            AND l.blanket_line_number = b.line_number
            AND o.header_id = l.header_id
            AND rbs.name = gc_order_type_acc
            AND rbs.org_id = tta.org_id
            AND tta.transaction_type_id (+) = o.order_type_id    -- JV: 5/1/2011
            AND tta.invoice_source_id = rbs.batch_source_id   -- JV: 5/1/2011
            AND b.header_id = b_blanket_header_id
            AND p.period_name = b_period_name
            AND o.org_id = fnd_global.org_id
            AND trunc(o.ordered_date) BETWEEN p.start_date AND p.end_date;
    --
        CURSOR c_already_accrued (
            b_blanket_number IN oe_blanket_headers_all.order_number%TYPE,
            b_period_name    IN gl_periods.period_name%TYPE
        ) IS
        SELECT
            h.order_number,
            SUM(l.ordered_quantity) accrued_qty
        FROM
            oe_order_headers_all     h,
            oe_order_lines_all       l,
            oe_blanket_lines_all     bl,
            oe_blanket_headers_all   bh,
            gl_periods               p,
            ra_batch_sources_all     rbs    -- JV: 7/12/2010
            ,
            oe_transaction_types_all tta   -- JV: 5/1/2011
        WHERE
                h.blanket_number = b_blanket_number
            AND h.blanket_number = l.blanket_number
            AND h.header_id = l.header_id
            AND bl.line_number = l.blanket_line_number
            AND bh.order_number = h.blanket_number
            AND bl.header_id = bh.header_id
            AND h.flow_status_code = 'BOOKED'
            AND rbs.name = gc_order_type_acc
            AND tta.transaction_type_id (+) = h.order_type_id    -- JV: 5/1/2011
            AND tta.invoice_source_id = rbs.batch_source_id   -- JV: 5/1/2011
            AND nvl(bl.attribute2, 'Y') = 'Y'
            AND p.period_name = b_period_name
            AND h.ordered_date BETWEEN p.start_date AND p.end_date
        GROUP BY
            h.order_number;

        l_order_number_line_count NUMBER;
        l_new_order_number        oe_order_headers_all.order_number%TYPE;
        l_data_incomplete         BOOLEAN := FALSE;
        e_already_accrued EXCEPTION;
        l_order_quantity          NUMBER;
        l_period_set_name         VARCHAR2(150);
        l_period_type             VARCHAR2(150);

        PROCEDURE write_outline (
            p_blanket     VARCHAR2,
            p_customer    VARCHAR2,
            p_released    VARCHAR2,
            p_description VARCHAR2
        ) IS
        BEGIN
            outline(rpad(p_blanket, 10)
                    || ' '
                    || rpad(p_customer, 25)
                    || ' '
                    || rpad(p_released, 15)
                    || ' '
                    || rpad(p_description, 40));
        END;
    --
    BEGIN
    --
    -- determine calendar type
        OPEN c_calendar_type(b_org_id => fnd_global.org_id);
        FETCH c_calendar_type INTO
            l_period_set_name,
            l_period_type;
        CLOSE c_calendar_type;
        outline('Program XXAH: Vendor Allowance Automatic Accrual');
        outline('Parameter: '
                || p_period_name
                || ' period will be used.');
        outline('');
        outline('This program picks up all sales agreements of any type that have status ACTIVE or EXPIRED.');
        outline('Furthermore, the sales agreement should have one or more line(s) with an ACCRUAL item and the');
        outline('flexfield on that line should have Accrual set to YES. And last, the activation and expiration');
        outline('dates should be overlapping the start and end date of the accrual period: '
                || p_period_name
                || '.');
        outline('');
        outline('The following sales agreements have been found:');
        outline('');
        outline(rpad('Blanket', 10)
                || ' '
                || rpad('Customer', 25)
                || ' '
                || rpad('Release Qty', 15)
                || ' '
                || rpad('Description', 40));

        outline(rpad('-', 10, '-')
                || ' '
                || rpad('-', 25, '-')
                || ' '
                || rpad('-', 15, '-')
                || ' '
                || rpad('-', 40, '-'));

    -- loop over all blankets
        FOR r_blanket IN c_sales_agreements(b_period_name => p_period_name) LOOP
            BEGIN

        -- check if already accrued
                OPEN c_sales_order(b_blanket_number => r_blanket.order_number, b_blanket_header_id => r_blanket.header_id, b_period_name => p_period_name
                );

                FETCH c_sales_order INTO l_order_number_line_count;
                CLOSE c_sales_order;
                IF l_order_number_line_count = r_blanket.line_count THEN
            --RAISE e_already_accrued;
			-- Lines already accrued will be updated (when neccesairy)
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'WARNING: ALL blanket lines already accrued -checking for updates'
                    );
                ELSIF l_order_number_line_count > 0 THEN
          -- partly accrued
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'WARNING: some blanket lines already accrued ');
                END IF;

                l_data_incomplete := FALSE;
                IF r_blanket.order_type_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: order-type is empty');
                    l_data_incomplete := TRUE;
                END IF;
        -- check for all fields to be filled
                IF r_blanket.ship_to_org_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: ship-to is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF r_blanket.sold_to_org_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: sold-to is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF r_blanket.invoice_to_org_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: invoice-to is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF r_blanket.salesrep_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: salesperson is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF r_blanket.payment_term_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: payment-term is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF r_blanket.price_list_id IS NULL THEN
                    write_outline(r_blanket.order_number, r_blanket.customer, '-', 'ERROR: price-list is empty');
                    l_data_incomplete := TRUE;
                END IF;

                IF NOT l_data_incomplete THEN
                    IF r_blanket.flow_status_code != 'ACTIVE' THEN
          --fix for bug 3192386 is hindering us here...
                        UPDATE oe_blanket_headers_all
                        SET
                            flow_status_code = 'ACTIVE'
                        WHERE
                            header_id = r_blanket.header_id;

                    END IF;

                    create_order(r_blanket.header_id, r_blanket.order_number, r_blanket.ship_to_org_id, r_blanket.sold_to_org_id, r_blanket.invoice_to_org_id
                    ,
                                p_period_name, r_blanket.salesrep_id, r_blanket.payment_term_id, r_blanket.price_list_id, r_blanket.order_type_id
                                ,
                                l_period_set_name, l_period_type, l_new_order_number);

                    IF r_blanket.flow_status_code != 'ACTIVE' THEN
          --and revert...
                        UPDATE oe_blanket_headers_all
                        SET
                            flow_status_code = r_blanket.flow_status_code
                        WHERE
                            header_id = r_blanket.header_id;

                    END IF;

                    SELECT
                        SUM(decode(l.line_category_code, 'RETURN', - 1 * l.ordered_quantity, l.ordered_quantity) * l.unit_selling_price_per_pqty
                        )
                    INTO l_order_quantity
                    FROM
                        oe_order_headers_all h,
                        oe_order_lines_all   l
                    WHERE
                            h.order_number = l_new_order_number
                        AND h.header_id = l.header_id
                        AND h.header_id = r_blanket.header_id;

                    IF l_new_order_number IS NULL OR l_order_quantity IS NULL THEN
                        write_outline(r_blanket.order_number, r_blanket.customer, nvl(l_order_quantity, 0), 'ERROR: release not created, see log'
                        );
                    ELSE
                        write_outline(r_blanket.order_number, r_blanket.customer, nvl(l_order_quantity, 0), 'SUCCESS: release '
                                                                                                            || l_new_order_number
                                                                                                            || ' created');
                    END IF;

                END IF;

            EXCEPTION
                WHEN e_already_accrued THEN
                    FOR r_accrued IN c_already_accrued(r_blanket.order_number, p_period_name) LOOP
                        write_outline(r_blanket.order_number, r_blanket.customer, r_accrued.accrued_qty, 'Already accrued by ' || r_accrued.order_number
                        );
                    END LOOP;
            END;
        END LOOP;

    -- Return 0 for successful completion.
        errbuf := '';
        retcode := 0;
    EXCEPTION
        WHEN OTHERS THEN
            errbuf := sqlerrm;
            retcode := 2;
    END periodic_accrual;

END xxah_va_autoaccrual_pkg;

/
