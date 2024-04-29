--------------------------------------------------------
--  DDL for Package Body XXAH_COPY_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_COPY_ORDER_PKG" AS
--$Id: XXAH_COPY_ORDER_PKG.plb 71 2015-05-20 11:23:53Z marc.smeenge@oracle.com $
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_INTERFACE_PKG.pkb 68 2015-04-29 07:56:51Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the Vendor Allowance Integration
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 14-09-2016  Sunil Thamke   Added  New Calendar Name as per the 445 calendar project.
 *************************************************************************/
  PROCEDURE Log(p_level IN fnd_log_messages.log_level%TYPE
               ,p_point IN VARCHAR2
               ,p_string IN fnd_log_messages.message_text%TYPE) IS
    c_start CONSTANT VARCHAR2(40) :=
       'xxah.plsql.xxah_copy_order_pkg';
  BEGIN
    IF p_level >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(p_level,c_start||p_point,p_string);
    END IF;
  END Log;
  --
  PROCEDURE store_order(p_header_id IN oe_order_headers_all.header_id%TYPE) IS
  BEGIN
    INSERT INTO xxah_order_header_tab
    SELECT p_header_id FROM DUAL
    WHERE NOT EXISTS
    (SELECT 1
     FROM xxah_order_header_tab
     WHERE header_id = p_header_id)
     ;
  END store_order;
  --
  FUNCTION count_lines(p_header_id IN oe_order_headers_all.header_id%TYPE)
  RETURN PLS_INTEGER IS
    CURSOR c_line(b_header_id oe_order_headers_all.header_id%TYPE) IS
    SELECT count(1)
    FROM   oe_order_lines_all
    WHERE  header_id = b_header_id
    ;
    v_return PLS_INTEGER;
    c_module CONSTANT VARCHAR2(20) := 'count_lines';
  BEGIN
    log(fnd_log.level_procedure,c_module||'.flow','Start');
    log(fnd_log.level_statement,c_module||'.param','p_header_id: '||p_header_id);
    OPEN c_line(p_header_id);
    FETCH c_line INTO v_return;
    CLOSE c_line;
    log(fnd_log.level_statement,c_module||'.param','return: '||v_return);
    log(fnd_log.level_procedure,c_module||'.flow','End');
    RETURN v_return;
  END count_lines;
  --
  PROCEDURE copy_lines(p_header_id IN oe_order_headers_all.header_id%TYPE
                      ,p_blanket_number IN oe_blanket_headers_all.order_number%TYPE) IS
                      va_period_name               VARCHAR2(100):=fnd_profile.value('XXAH_VA_PERIOD_NAME');
    CURSOR c_lines(
       b_blanket_number IN oe_blanket_headers_all.order_number%TYPE
       ,b_ordered_date IN DATE) IS
    SELECT h.header_id
    ,      h.org_id
    ,      l.line_id
    ,      l.line_number
    ,      l.inventory_item_id
    ,      nvl(l.ship_to_org_id,h.ship_to_org_id) ship_to_org_id
    ,      nvl(l.sold_to_org_id,h.sold_to_org_id) sold_to_org_id
    ,      nvl(l.invoice_to_org_id,h.invoice_to_org_id) invoice_to_org_id
    ,      l.request_date
    ,      l.calculate_price_flag
    ,      l.return_reason_code
    ,      l.price_list_id
    ,      h.flow_status_code
    ,      (SELECT max(end_date_active)
            FROM   oe_blanket_lines_ext ext
            WHERE  ext.order_number = h.order_number
            AND    ext.line_id = l.line_id
            AND    ext.line_number = l.line_number) end_date_active
    ,      ld.cost_center cost_center
    ,      ld.line_description line_description
    ,      ld.open_item_key open_item_key
    ,      ld.bill_type bill_type
    ,      gp.period_year period_year
    FROM   oe_blanket_headers_all h
    ,      oe_blanket_lines_all l
    ,      oe_blanket_lines_all_dfv ld
    ,      gl_periods_v gp
    WHERE  h.order_number = b_blanket_number
    and    l.header_id = h.header_id
    AND    l.rowid = ld.row_id
    AND    b_ordered_date BETWEEN gp.start_date and gp.end_date
    AND    gp.user_period_type =va_period_name--'VAPS'
    ;
    CURSOR c_head(b_header_id IN oe_order_headers_all.header_id%TYPE) IS
    SELECT ordered_date
    ,      ship_to_org_id ship_to_org_id
    ,      sold_to_org_id sold_to_org_id
    ,      invoice_to_org_id invoice_to_org_id
    FROM   oe_order_headers_all
    WHERE  header_id = b_header_id
    ;
    c_module CONSTANT VARCHAR2(20) := 'copy_lines';
    v_api_version_number           NUMBER  := 1;
    v_return_status                VARCHAR2(10);
    v_msg_count                    NUMBER;
    v_msg_data                     VARCHAR2(2000);
    v_debug_level                  NUMBER  := 0;        -- OM DEBUG LEVEL (MAX 5)
    v_line_tbl                     oe_order_pub.line_tbl_type := oe_order_pub.g_miss_line_tbl;
    v_line_out_tbl                 oe_order_pub.line_tbl_type;
    v_line_count                   PLS_INTEGER;
    v_msg_index                    NUMBER;
    v_data                         VARCHAR2 (2000);
    v_head c_head%ROWTYPE;
    v_flow_status oe_blanket_headers_all.flow_status_code%TYPE;
  BEGIN
    log(fnd_log.level_procedure,c_module||'.flow','Start');
    log(fnd_log.level_statement,c_module||
       '.param','p_header_id: '||p_header_id);
    log(fnd_log.level_statement,c_module||
       '.param','p_blanket_number: '||p_blanket_number);
    /*****INITIALIZE DEBUG INFO***********/
    IF (v_debug_level > 0) THEN
      oe_debug_pub.initialize;
      oe_debug_pub.setdebuglevel (v_debug_level);
      oe_msg_pub.initialize;
    END IF;
    --
    v_line_count := 1;
    OPEN c_head(p_header_id);
    FETCH c_head INTO v_head;
    CLOSE c_head;
    FOR v_lines IN c_lines(p_blanket_number
                          ,v_head.ordered_date) LOOP
      -- unit_selling_percent default 0?
      v_flow_status := v_lines.flow_status_code;
      v_line_tbl(v_line_count)                        := oe_order_pub.g_miss_line_rec;
      v_line_tbl(v_line_count).header_id              := p_header_id;
      v_line_tbl(v_line_count).operation              := oe_globals.g_opr_create;
      v_line_tbl(v_line_count).inventory_item_id      := v_lines.inventory_item_id;
      v_line_tbl(v_line_count).request_date           := v_head.ordered_date;
      v_line_tbl(v_line_count).ship_to_org_id         := v_head.ship_to_org_id;
      v_line_tbl(v_line_count).invoice_to_org_id      := v_head.invoice_to_org_id;
      v_line_tbl(v_line_count).sold_to_org_id         := v_head.sold_to_org_id;
      v_line_tbl(v_line_count).calculate_price_flag   := v_lines.calculate_price_flag;
      v_line_tbl(v_line_count).blanket_line_number    := v_lines.line_number;
      v_line_tbl(v_line_count).return_reason_code     := v_lines.return_reason_code;
      v_line_tbl(v_line_count).price_list_id          := v_lines.price_list_id;
      v_line_tbl(v_line_count).tax_code               := NULL;
      v_line_tbl(v_line_count).ordered_quantity       := 0;
      v_line_tbl(v_line_count).attribute1             := fnd_date.date_to_canonical(v_lines.end_date_active);
      v_line_tbl(v_line_count).attribute2             := v_lines.line_description;
      v_line_tbl(v_line_count).attribute3             := v_lines.cost_center;
      v_line_tbl(v_line_count).attribute4             := v_lines.open_item_key||'|'||v_lines.period_year;
      v_line_tbl(v_line_count).attribute5             := v_lines.bill_type;
      v_line_count := v_line_count + 1;
    END LOOP;
    IF v_flow_status != 'ACTIVE' THEN
      --fix for bug 3192386 is hindering us here...
      UPDATE  oe_blanket_headers_all
      SET flow_status_code = 'ACTIVE'
      WHERE order_number = p_blanket_number
      ;
    END IF;
    oe_order_pub.Process_Line(
        p_line_tbl => v_line_tbl
      , p_org_id => NULL
      , p_operating_unit => NULL
      , x_line_out_tbl => v_line_out_tbl
      , x_return_status => v_return_status
      , x_msg_count => v_msg_count
      , x_msg_data => v_msg_data
      );
    IF v_flow_status != 'ACTIVE' THEN
      --and revert...
      UPDATE  oe_blanket_headers_all
      SET flow_status_code = v_flow_status
      WHERE order_number = p_blanket_number
      ;
    END IF;
    IF v_return_status != fnd_api.g_ret_sts_success THEN
      FOR i IN 1 .. v_msg_count LOOP
         oe_msg_pub.get
         ( p_msg_index => i
         , p_encoded => fnd_api.g_false
         , p_data => v_data
         , p_msg_index_out => v_msg_index
         );
         log(fnd_log.level_procedure,c_module||'.error',v_data);
      END LOOP;
      ROLLBACK;
    END IF;
    log(fnd_log.level_procedure,c_module||'.flow','End');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      log(fnd_log.level_procedure,c_module||'.exception',SQLERRM);
  END copy_lines;
  --
  PROCEDURE book_order(errbuf OUT VARCHAR2
                      ,retcode OUT NUMBER
                      ,p_order IN oe_order_headers_all.header_id%TYPE
                      ,p_order_type IN oe_order_headers_all.order_type_id%TYPE
                      ,p_user_id IN fnd_user.user_id%TYPE) IS
  CURSOR c_headers(b_order oe_order_headers_all.header_id%TYPE
                  ,b_order_type oe_order_headers_all.order_type_id%TYPE
                  ,b_status oe_order_headers_all.flow_status_code%TYPE
                  ,b_user_id fnd_user.user_id%TYPE) IS
    SELECT header_id
    ,      order_number
    ,      booked_date
    ,      org_id
    ,      upper((SELECT rbs.name
            FROM   Oe_Transaction_Types_All tta
            ,      ra_batch_sources_all rbs
            WHERE  ooh.order_type_id = tta.transaction_type_id
            AND    tta.org_id = rbs.org_id
            AND    rbs.batch_source_id = tta.invoice_source_id)) order_type
    FROM   oe_order_headers ooh
    WHERE  ooh.header_id = nvl(b_order,ooh.header_id)
    AND    ooh.created_by = nvl(b_user_id,ooh.created_by)
    AND    ooh.flow_status_code = b_status
    AND    ooh.order_type_id =  nvl(b_order_type,ooh.order_type_id)
    AND NOT EXISTS (SELECT 1
                    FROM xxah_order_header_tab
                    WHERE header_id = ooh.header_id)
    ORDER BY order_number
    ;
    CURSOR c_count(b_header_id oe_order_lines_all.header_id%TYPE) IS
    SELECT sum(decode(tax_code,NULL,1,0)) tax_code_empty
    ,      sum(case when ordered_quantity > 0 then 1 else 0 end) quantity_zero
    FROM   oe_order_lines_all
    WHERE  header_id = b_header_id
    ;
    CURSOR c_resp IS
    SELECT resp.responsibility_id
    FROM   fnd_responsibility_vl resp
    ,      fnd_profile_option_values val
    ,      fnd_profile_options opt
    WHERE opt.profile_option_id = val.profile_option_id
    AND val.level_id = 10003
    AND val.level_value = to_char(resp.responsibility_id)
    AND resp.responsibility_name like 'Order Management Super User%'
    AND opt.profile_option_name = 'ORG_ID'
    AND val.profile_option_value = to_char(fnd_profile.value('ORG_ID'))
    ;
    c_module CONSTANT VARCHAR2(20) := 'book_order';
    v_debug_level                  NUMBER  := 0;
    v_return_status      VARCHAR2(30);
    v_msg_count        NUMBER;
    v_msg_data        VARCHAR2(2000);
    x_msg_count        NUMBER;
    x_msg_data        VARCHAR2(2000);
    v_msg_table oe_msg_pub.Msg_Tbl_Type;
    v_date DATE;
    v_count_tax PLS_INTEGER;
    v_count PLS_INTEGER;
    v_msg_index                    NUMBER;
    v_header c_headers%ROWTYPE;
    v_found BOOLEAN;
    v_processed NUMBER;
    v_resp fnd_responsibility_vl.responsibility_id%TYPE;
  BEGIN
    log(fnd_log.level_procedure,c_module||'.flow','Start');
    log(fnd_log.level_statement,c_module||
       '.param','p_order: '||p_order);
    log(fnd_log.level_statement,c_module||
       '.param','p_order_type: '||p_order_type);
    /*****INITIALIZE DEBUG INFO***********/
    IF (v_debug_level > 0) THEN
      oe_debug_pub.initialize;
      oe_debug_pub.setdebuglevel (v_debug_level);
      oe_msg_pub.initialize;
    END IF;
    --
    OPEN c_resp;
    FETCH c_resp INTO v_resp;
    v_found := c_resp%FOUND;
    CLOSE c_resp;
    IF NOT v_found THEN
      retcode := 2;
      errbuf := 'No valid Order Management Super User responsibility found for current org.';
    ELSE
      fnd_global.apps_initialize(fnd_global.user_id,v_resp,660);
      mo_global.set_policy_context('S',fnd_global.org_id);
      --
      v_found := TRUE;
      v_processed := 0;
      WHILE v_found LOOP
        OPEN c_headers(p_order
                      ,p_order_type
                      ,'ENTERED'
                      ,p_user_id);
        FETCH c_headers INTO v_header;
        v_found := c_headers%FOUND;
        CLOSE c_headers;
        --
        IF v_found THEN
         /*
          * place order in table to make sure its not processed
          * again in case of an error
          */
          v_processed := v_processed + 1;
          store_order(v_header.header_id);
          OPEN c_count(v_header.header_id);
          FETCH c_count INTO v_count_tax, v_count;
          CLOSE c_count;
          IF v_count > 0 AND (v_count_tax = 0 OR v_header.order_type LIKE '%ACCRUAL%') THEN
            OE_Order_Book_Util.Complete_Book_Eligible
                 ( p_api_version_number  => 1.0
                , p_init_msg_list  => fnd_api.g_true
                , p_header_id      => v_header.header_id
                , x_return_status  => v_return_status
                , x_msg_count      => v_msg_count
                , x_msg_data      => v_msg_data);
            IF v_return_status != fnd_api.g_ret_sts_success THEN
              retcode := 1;
              oe_msg_pub.get_msg_tbl(v_msg_table);
              log(fnd_log.level_statement,c_module,'Order '||v_header.order_number||
                               ' cannot be booked.');
              fnd_file.put_line(fnd_file.output,'Order '||v_header.order_number||
                               ' cannot be booked.');
              OE_MSG_PUB.Count_And_Get
                    (   p_count     =>      x_msg_count
                    ,   p_data      =>      x_msg_data
                    );
              FOR i IN 1..x_msg_count LOOP
                log(fnd_log.level_statement,c_module,oe_msg_pub.get(i,fnd_api.g_false));
                fnd_file.put_line(fnd_file.output,oe_msg_pub.get(i,fnd_api.g_false));
              END LOOP;
              fnd_file.put_line(fnd_file.output,' ');
            ELSE
              /*
               * commit is needed because an event picks up the order as soon
               * as its booked. This event is in the same session, but apparently
               * not really... So one commit after each booked order...
               */
              COMMIT;
              fnd_file.put_line(fnd_file.output,'Order '||v_header.order_number||
                               ' is booked.');
              fnd_file.put_line(fnd_file.output,' ');
            END IF;
          ELSE
            IF v_count = 0 THEN
              fnd_file.put_line(fnd_file.output,'Order '||v_header.order_number||
                               ' Does not have lines with quantity more than one.');
              fnd_file.put_line(fnd_file.output,' ');
              retcode := 1;
            END IF;
            IF v_count_tax > 0 AND v_header.order_type NOT LIKE '%ACCRUAL%' THEN
              fnd_file.put_line(fnd_file.output,'Invoice '||v_header.order_number||
                               ' contains lines without tax code.');
              fnd_file.put_line(fnd_file.output,' ');
              retcode := 1;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;
    IF v_processed = 0 THEN
      retcode := 1;
      errbuf := 'No Eligible orders found.';
    END IF;
    log(fnd_log.level_procedure,c_module||'.flow','End');
  END book_order;
END xxah_copy_order_pkg;

/
