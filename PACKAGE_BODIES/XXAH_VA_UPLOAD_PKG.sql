--------------------------------------------------------
--  DDL for Package Body XXAH_VA_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_UPLOAD_PKG" AS

/**************************************************************************
 * VERSION      : $Id: XXAH_VA_INTERFACE_PKG.pkb 68 2015-04-29 07:56:51Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the Vendor Allowance Integration
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 5-NOV-2010  Marc Smeenge   Initial
 * 13-05-2016  Vema Reddy     Added Volume,Price and Chartfield2  as per te RFC EBS001.
 * 14-09-2016  Sunil Thamke   Added  New Calendar Name as per the 445 calendar project.
 * 29-09-2016  Vema Reddy     Added Final Invoice Flag as per the RFC EBS002.
 *************************************************************************/

  -- ----------------------------------------------------------------------
  -- Private types
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- Private constants
  -- ----------------------------------------------------------------------
--$Id$
  PROCEDURE Log(p_level IN fnd_log_messages.log_level%TYPE
               ,p_point IN VARCHAR2
               ,p_string IN fnd_log_messages.message_text%TYPE) IS
    c_start CONSTANT VARCHAR2(40) :=
       'xxah.plsql.xxah_va_upload_pkg';
       va_period_name               VARCHAR2(100):=fnd_profile.value('XXAH_VA_PERIOD_NAME'); -- New calendar name fetch from profile.
  BEGIN
    IF p_level >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(p_level,c_start||p_point,p_string);
    END IF;
    fnd_file.put_line(fnd_file.log,p_string);
  END Log;
  --
  FUNCTION get_order_type_id(p_order_type IN ra_batch_sources_all.name%TYPE
                            ,p_org_id IN ra_batch_sources_all.org_id%TYPE)
  RETURN oe_order_types_115_all.order_type_id%TYPE IS
    CURSOR c_oot(b_order_type IN oe_order_types_115_all.name%TYPE
                ,b_org_id IN oe_order_types_115_all.org_id%TYPE) IS
    SELECT transaction_type_id order_type_id
    FROM  oe_transaction_types_all tta
    ,     ra_batch_sources_all rbs
    WHERE tta.org_id = b_org_id
    AND   tta.org_id = rbs.org_id
    AND   tta.invoice_source_id = rbs.batch_source_id
    AND   rbs.name = b_order_type
    AND   tta.transaction_type_code = 'ORDER'
    AND   nvl(end_date_active,sysdate) >= sysdate
    ;
    v_return oe_order_types_115_all.order_type_id%TYPE;
  BEGIN
    OPEN c_oot(p_order_type
              ,p_org_id);
    FETCH c_oot INTO v_return;
    CLOSE c_oot;
    RETURN v_return;
  END get_order_type_id;
  --
  PROCEDURE create_releases(errbuf OUT VARCHAR2
                           ,retcode OUT NUMBER) IS
                           va_period_name               VARCHAR2(100):=fnd_profile.value('XXAH_VA_PERIOD_NAME'); -- New calendar name fetch from profile.
    CURSOR c_blanket IS
    SELECT xvu.blanket_number header_id
    ,      xvu.order_type
    ,      least(trunc(sysdate),gp.end_date) order_date
    FROM xxah_va_upload xvu
    ,    gl_periods_v gp
    WHERE xvu.request_id = fnd_global.conc_request_id
    AND   gp.user_period_type =va_period_name --'VAPS'
    AND   xvu.order_type = 'VA-ACCRUAL'
    AND   nvl(xvu.order_date,sysdate) BETWEEN gp.start_date and gp.end_date
    AND   xvu.attribute10 = fnd_global.user_id
    AND   NOT EXISTS
      (SELECT 1
       FROM   xxah_va_upload xvu2
       WHERE  xvu2.blanket_number = xvu.blanket_number
       AND    xvu2.request_id = xvu.request_id
       AND NOT EXISTS
         (SELECT 1
          FROM oe_blanket_lines_all ol
          WHERE ol.header_id = xvu2.blanket_number
          AND   ol.line_number = xvu2.blanket_line_number))
    GROUP BY blanket_number, order_type, least(trunc(sysdate),gp.end_date)
    UNION ALL
    SELECT xvu.blanket_number header_id
    ,      xvu.order_type
    ,      nvl(order_date,trunc(sysdate)) order_date
    FROM xxah_va_upload xvu
    WHERE xvu.request_id = fnd_global.conc_request_id
    AND   xvu.order_type = 'VA-INVOICE'
    AND   xvu.attribute10 = fnd_global.user_id
    AND   NOT EXISTS
      (SELECT 1
       FROM   xxah_va_upload xvu2
       WHERE  xvu2.blanket_number = xvu.blanket_number
       AND    xvu2.request_id = xvu.request_id
       AND NOT EXISTS
         (SELECT 1
          FROM oe_blanket_lines_all ol
          WHERE ol.header_id = xvu2.blanket_number
          AND   ol.line_number = xvu2.blanket_line_number))
    GROUP BY blanket_number, order_type, nvl(order_date,trunc(sysdate))
    ;
    CURSOR c_rejected IS
    SELECT rpad(bha.order_number,14,' ') order_number
    ,      xvu.blanket_line_number
    FROM   xxah_va_upload xvu
    ,      oe_blanket_headers_all bha
    WHERE  xvu.blanket_number = bha.header_id
    AND    xvu.request_id = fnd_global.conc_request_id
    AND NOT EXISTS
      (SELECT 1
       FROM oe_blanket_lines_all ol
       WHERE ol.header_id = xvu.blanket_number
       AND   ol.line_number = xvu.blanket_line_number)
    ;
    CURSOR c_header(b_header_id oe_blanket_headers_all.header_id%TYPE) IS
    SELECT bha.order_number
    ,      bha.ordered_date
    ,      bha.ship_to_org_id ship_to_org_id
    ,      bha.sold_to_org_id sold_to_org_id
    ,      bha.invoice_to_org_id invoice_to_org_id
    ,      bha.org_id org_id
    ,      bha.salesrep_id salesrep_id
    ,      bha.transactional_curr_code transactional_curr_code
    ,      bha.price_list_id price_list_id
    ,      bha.payment_term_id payment_term_id
    ,      bha.tax_exempt_flag tax_exempt_flag
    ,      bha.flow_status_code flow_status_code
    FROM oe_blanket_headers_all bha
    WHERE bha.header_id = b_header_id
    ;
    CURSOR c_lines(
       b_header_id IN oe_blanket_headers_all.header_id%TYPE
       ,b_order_type IN xxah_va_upload.order_type%TYPE
       ,b_order_date xxah_va_upload.order_date%TYPE) IS
    SELECT l.line_id
    ,      l.line_number
    ,      l.inventory_item_id
    ,      l.request_date
    ,      l.calculate_price_flag
    ,      nvl(xvu.price_list_id,l.price_list_id) price_list_id
    ,      l.salesrep_id
    ,      (SELECT max(end_date_active)
            FROM   oe_blanket_lines_ext ext
            WHERE  ext.line_id = l.line_id) end_date_active
    ,      decode(xvu.order_type,'VA-INVOICE',xvu.tax_code,NULL) tax_code
    ,      xvu.quantity quantity
    ,      nvl(xvu.cost_center,ld.cost_center) cost_center
    ,      nvl(xvu.comments,ld.line_description) line_description
    ,      ld.open_item_key open_item_key
    ,      decode(xvu.order_type,'VA-INVOICE',ld.bill_type,null) bill_type
    ,      xvu.supplier_doc_nrs supplier_doc_nrs
    ,      gp.period_year period_year
    ,      xvu.chartfield3 chartfield3
    ,      xvu.attribute1 reference
    ,      xvu.attribute2 volume
    ,      xvu.attribute3 price
    ,      xvu.attribute4 chartfield2
    ,      upper(xvu.attribute5) Final_Invoice_Flag
    FROM   oe_blanket_lines_all l
    ,      oe_blanket_lines_all_dfv ld
    ,      xxah_va_upload xvu
    ,      gl_periods_v gp
    WHERE  l.header_id = b_header_id
    AND    l.rowid = ld.row_id
    AND    xvu.blanket_line_number = l.line_number
    AND    xvu.blanket_number = l.header_id
    AND    xvu.order_type = b_order_type
    AND    xvu.request_id = fnd_global.conc_request_id
    AND    nvl(xvu.order_date,sysdate) BETWEEN gp.start_date and gp.end_date
    AND    least(trunc(sysdate),gp.end_date) = b_order_date
    AND    gp.user_period_type =va_period_name-- 'VAPS'
    AND    xvu.order_type = 'VA-ACCRUAL'
    UNION ALL
    SELECT l.line_id
    ,      l.line_number
    ,      l.inventory_item_id
    ,      l.request_date
    ,      l.calculate_price_flag
    ,      nvl(xvu.price_list_id,l.price_list_id) price_list_id
    ,      l.salesrep_id
    ,      (SELECT max(end_date_active)
            FROM   oe_blanket_lines_ext ext
            WHERE  ext.line_id = l.line_id) end_date_active
    ,      decode(xvu.order_type,'VA-INVOICE',xvu.tax_code,NULL) tax_code
    ,      xvu.quantity quantity
    ,      nvl(xvu.cost_center,ld.cost_center) cost_center
    ,      nvl(xvu.comments,ld.line_description) line_description
    ,      ld.open_item_key open_item_key
    ,      decode(xvu.order_type,'VA-INVOICE',ld.bill_type,null) bill_type
    ,      xvu.supplier_doc_nrs supplier_doc_nrs
    ,      gp.period_year period_year
    ,      xvu.chartfield3 chartfield3
    ,      xvu.attribute1 reference
    ,      xvu.attribute2 volume
    ,      xvu.attribute3 price
    ,      xvu.attribute4 chartfield2
    ,      upper(xvu.attribute5) Final_Invoice_Flag
    FROM   oe_blanket_lines_all l
    ,      oe_blanket_lines_all_dfv ld
    ,      xxah_va_upload xvu
    ,      gl_periods_v gp
    WHERE  l.header_id = b_header_id
    AND    l.rowid = ld.row_id
    AND    xvu.blanket_line_number = l.line_number
    AND    xvu.blanket_number = l.header_id
    AND    xvu.order_type = b_order_type
    AND    xvu.request_id = fnd_global.conc_request_id
    AND    nvl(xvu.order_date,sysdate) BETWEEN gp.start_date and gp.end_date
    AND    nvl(xvu.order_date,trunc(sysdate)) = b_order_date
    AND    gp.user_period_type = va_period_name--'VAPS'
    AND    xvu.order_type = 'VA-INVOICE'
    ORDER BY 2, 10 desc
    ;
    CURSOR c_resp(b_org_id oe_blanket_headers_all.org_id%TYPE) IS
    SELECT resp.responsibility_id
    FROM   fnd_responsibility_vl resp
    ,      fnd_profile_option_values val
    ,      fnd_profile_options opt
    WHERE opt.profile_option_id = val.profile_option_id
    AND val.level_id = 10003
    AND val.level_value = to_char(resp.responsibility_id)
    AND resp.responsibility_name like 'Order Management Super User%'
    AND opt.profile_option_name = 'ORG_ID'
    AND val.profile_option_value = to_char(b_org_id)
    ;
    CURSOR c_msg IS
    SELECT distinct rpad(bha.order_number,14,' ') order_number
    ,      xvu.message message
    ,      xvu.attribute1 reference
    FROM   xxah_va_upload xvu
    ,      oe_blanket_headers_all bha
    WHERE  xvu.blanket_number = bha.header_id
    AND    xvu.request_id = fnd_global.conc_request_id
    AND    xvu.status = 'E'
    ;
    CURSOR c_oos IS
    SELECT order_source_id
    FROM   oe_order_sources
    where  name = 'SO Upload Tool'
    ;

    CURSOR c_oe_order_header(p_oe_header_id IN NUMBER)
    IS
    SELECT distinct ooha.blanket_number,ooha.header_id,oola.blanket_line_number,oola.Attribute12
    from
    oe_order_headers_all ooha,
    oe_order_lines_all    oola
    where ooha.header_id = oola.header_id
    --AND nvl(oola.Attribute12, 'X') = 'Y'
    AND ooha.header_id = p_oe_header_id;

    CURSOR c_blanket_order_lines(p_blanket_number IN NUMBER,p_line_number in number)
    IS
    SELECT obla.line_id,obha.header_id
    from
    oe_blanket_headers_all obha,
    oe_blanket_lines_all obla
    where obha.header_id = obla.header_id
    AND NVL(obla.attribute10, 'X') <> 'Y'
    AND obha.order_number = p_blanket_number
    and obla.line_number=p_line_number;

    c_module CONSTANT VARCHAR2(20) := 'create_releases';
    v_api_version_number NUMBER  := 1;
    v_return_status      VARCHAR2(10);
    v_msg_count          NUMBER;
    v_msg_data           VARCHAR2(2000);
    v_debug_level        NUMBER  := 0;        -- OM DEBUG LEVEL (MAX 5)
    v_line_tbl           oe_order_pub.line_tbl_type := oe_order_pub.
      g_miss_line_tbl;
    v_line_out_tbl       oe_order_pub.line_tbl_type;
    v_line_count         PLS_INTEGER;
    v_msg_index          NUMBER;
    v_data               VARCHAR2 (2000);
    v_message            xxah_va_upload.message%TYPE;
    v_status             xxah_va_upload.status%TYPE;
    v_header             c_header%ROWTYPE;
    v_org_id             oe_blanket_headers_all.org_id%TYPE;
    v_resp               fnd_responsibility_vl.responsibility_id%TYPE;
    v_flow_status        oe_blanket_headers_all.flow_status_code%TYPE;
    v_header_rec         oe_order_pub.header_rec_type := oe_order_pub.
      g_miss_header_rec;
    v_header_out_rec     oe_order_pub.header_rec_type := oe_order_pub.
      g_miss_header_rec;
    v_header_found       BOOLEAN;
    v_found              BOOLEAN;
    v_lines_found        BOOLEAN;
    v_session_id         fnd_sessions.session_id%TYPE;
    v_order_source_id    oe_order_sources.order_source_id%TYPE;
    v_err_found          BOOLEAN;
    v_quantity           varchar2(255);
    l_order_number    oe_blanket_headers_all.order_number%TYPE;
    l_oe_header_id     oe_order_headers_all.header_id%TYPE;

  BEGIN
    log(fnd_log.level_procedure,c_module||'.flow','Start');
    /*****INITIALIZE DEBUG INFO***********/
    IF (v_debug_level > 0) THEN
      oe_debug_pub.initialize;
      oe_debug_pub.setdebuglevel (v_debug_level);
      oe_msg_pub.initialize;
    END IF;
    --
    retcode := 0;
    --
    UPDATE xxah_va_upload
    SET    request_id = fnd_global.conc_request_id
    WHERE  request_id IS NULL
    AND    attribute10 = fnd_global.user_id
    ;
    --
    OPEN c_oos;
    FETCH c_oos INTO v_order_source_id;
    CLOSE c_oos;
    --
    fnd_file.put_line(fnd_file.output,'Created Orders: ');
    fnd_file.put_line(fnd_file.output,'Order Number        Blanket Number');
    FOR v_blanket IN c_blanket LOOP
      v_message := NULL;
      SAVEPOINT start_order;
log(fnd_log.level_statement,c_module||'.debug','Blanket: '||v_blanket.
      header_id);
      v_status := 'S';
      v_message := NULL;
      v_header_rec := oe_order_pub.g_miss_header_rec;
      v_header_out_rec := oe_order_pub.g_miss_header_rec;
      v_line_tbl.DELETE;
      --
      OPEN c_header(v_blanket.header_id);
      FETCH c_header INTO v_header;
      v_header_found := c_header%FOUND;
      CLOSE c_header;
      --
      IF v_header_found THEN
        IF v_header.org_id != nvl(v_org_id,-2) THEN
          v_org_id := v_header.org_id;
          OPEN c_resp(v_org_id);
          FETCH c_resp INTO v_resp;
          v_found := c_resp%FOUND;
          CLOSE c_resp;
          IF NOT v_found THEN
            v_status := 'E';
            v_message :=
      'No valid Order Management Super User responsibility found for blanket org.'
      ;
          ELSE
log(fnd_log.level_statement,c_module||'.debug','init: '||v_resp);
            fnd_global.initialize(session_id => v_session_id
                                 ,user_id => fnd_global.user_id
                                 ,resp_id => v_resp
                                 ,resp_appl_id => 660
                                 ,security_group_id => fnd_global.
      security_group_id
                                 ,site_id => null
                                 ,login_id => fnd_global.login_id
                                 ,conc_login_id => fnd_global.conc_login_id
                                 ,prog_appl_id => fnd_global.prog_appl_id
                                 ,conc_program_id => fnd_global.
      conc_program_id
                                 ,conc_request_id => fnd_global.
      conc_request_id
                                 ,conc_priority_request => fnd_global.
      conc_priority_request);
            mo_global.set_policy_context('S',v_org_id);
          END IF;
        END IF;
        --
        IF v_status = 'S' THEN
          v_flow_status := v_header.flow_status_code;
          IF v_flow_status != 'ACTIVE' THEN
            --fix for bug 3192386 is hindering us here...
            UPDATE  oe_blanket_headers_all
            SET flow_status_code = 'ACTIVE'
            WHERE header_id = v_blanket.header_id
            ;
          END IF;
          v_header_rec.order_type_id := get_order_type_id(v_blanket.order_type
      , v_org_id);
          v_header_rec.ordered_date := v_blanket.order_date;
          v_header_rec.ship_to_org_id := v_header.ship_to_org_id;
          v_header_rec.sold_to_org_id := v_header.sold_to_org_id;
          v_header_rec.invoice_to_org_id := v_header.invoice_to_org_id;
          v_header_rec.salesrep_id := v_header.salesrep_id;
          v_header_rec.transactional_curr_code := v_header.
      transactional_curr_code;
          v_header_rec.price_list_id := v_header.price_list_id;
          v_header_rec.payment_term_id := v_header.payment_term_id;
          v_header_rec.tax_exempt_flag := 'S';
          v_header_rec.blanket_number := v_header.order_number;
          v_header_rec.order_source_id := v_order_source_id;
          v_header_rec.operation := oe_globals.g_opr_create;
          oe_order_pub.process_header(p_header_rec => v_header_rec
                                     ,p_org_id => v_org_id
                                     ,p_operating_unit => NULL
                                     ,x_header_out_rec => v_header_out_rec
                                     ,x_return_status => v_return_status
                                     ,x_msg_count => v_msg_count
                                     ,x_msg_data => v_msg_data
                                     );
          IF v_return_status != fnd_api.g_ret_sts_success THEN
            FOR i IN 1 .. v_msg_count LOOP
               oe_msg_pub.get
               ( p_msg_index => i
               , p_encoded => fnd_api.g_false
               , p_data => v_data
               , p_msg_index_out => v_msg_index
               );
               IF v_message IS NULL THEN
                 v_message := v_data;
               ELSE
                 v_message := v_message||'+'||v_data;
               END IF;
               log(fnd_log.level_procedure,c_module||'.error',v_data);
            END LOOP;
            v_message := 'Error in creation of release header '||v_header.
      order_number||'+'||v_message;
            v_status := 'E';
            ROLLBACK TO start_order;
          ELSE
            v_line_count := 1;
            v_lines_found := FALSE;
            v_line_tbl.DELETE;
            FOR v_lines IN c_lines(v_blanket.header_id
                                  ,v_blanket.order_type
                                  ,v_blanket.order_date) LOOP

                                   if v_lines.volume=0 then
                                  raise_application_error(-20101, 'Please do not enter Zero as volume and provide some value');
                                  end if;

                                  v_quantity:=v_lines.volume*to_number(v_lines.price,'9999999999D999','nls_numeric_characters='',.''');





              v_message := NULL;
              v_lines_found := TRUE;
              v_line_tbl(v_line_count)                        := oe_order_pub.
      g_miss_line_rec;
              v_line_tbl(v_line_count).header_id              :=
      v_header_out_rec.header_id;
              v_line_tbl(v_line_count).operation              := oe_globals.
      g_opr_create;
              v_line_tbl(v_line_count).inventory_item_id      := v_lines.
      inventory_item_id;
              IF v_lines.end_date_active < v_header_out_rec.ordered_date THEN
                v_line_tbl(v_line_count).request_date           := v_lines.
      end_date_active;
              ELSE
                v_line_tbl(v_line_count).request_date           :=
      v_header_out_rec.ordered_date;
              END IF;
              v_line_tbl(v_line_count).ship_to_org_id         :=
      v_header_out_rec.ship_to_org_id;
              v_line_tbl(v_line_count).invoice_to_org_id      :=
      v_header_out_rec.invoice_to_org_id;
              v_line_tbl(v_line_count).sold_to_org_id         :=
      v_header_out_rec.sold_to_org_id;
              v_line_tbl(v_line_count).calculate_price_flag   := v_lines.
      calculate_price_flag;
              v_line_tbl(v_line_count).blanket_number         := v_header.
      order_number;
              v_line_tbl(v_line_count).blanket_line_number    := v_lines.
      line_number;
              v_line_tbl(v_line_count).salesrep_id            := v_lines.
      salesrep_id;
              v_line_tbl(v_line_count).price_list_id          := v_lines.
      price_list_id;
              v_line_tbl(v_line_count).tax_code               := v_lines.
      tax_code;
              v_line_tbl(v_line_count).ordered_quantity       := round(v_quantity,2); --modified based on RFC v_lines.volume*v_lines.price; v_lines.volume*v_lines.price;--
              v_line_tbl(v_line_count).tax_exempt_flag        := v_header_rec.
      tax_exempt_flag;
              v_line_tbl(v_line_count).attribute1             := fnd_date.
      date_to_canonical(v_lines.end_date_active);
              v_line_tbl(v_line_count).attribute2             := substr(
      v_lines.line_description,1,240);
              v_line_tbl(v_line_count).attribute3             := v_lines.
      cost_center;
              v_line_tbl(v_line_count).attribute4             := v_lines.
      open_item_key||'|'||v_lines.period_year;
              v_line_tbl(v_line_count).attribute5             := v_lines.
      bill_type;
              v_line_tbl(v_line_count).attribute6             := v_lines.
      supplier_doc_nrs;
              v_line_tbl(v_line_count).attribute7             := v_lines.
      chartfield3;
              v_line_tbl(v_line_count).attribute8             := v_lines.
      reference;
              v_line_tbl(v_line_count).attribute9             := v_lines.
      volume;
              v_line_tbl(v_line_count).attribute10            := v_lines.price
      ;
              v_line_tbl(v_line_count).attribute11            := v_lines.
      chartfield2;
             v_line_tbl(v_line_count).attribute12           := v_lines.
      Final_Invoice_Flag;
              v_line_count := v_line_count + 1;


            END LOOP;
            IF NOT v_lines_found THEN
              v_message := 'No Matching line found for blanket '||v_header.
      order_number;
              v_status := 'E';
              ROLLBACK TO start_order;
            ELSE
              oe_order_pub.Process_Line(
                  p_line_tbl => v_line_tbl
                , p_org_id => v_org_id
                , p_operating_unit => v_org_id
                , x_line_out_tbl => v_line_out_tbl
                , x_return_status => v_return_status
                , x_msg_count => v_msg_count
                , x_msg_data => v_msg_data
                );
              IF v_flow_status != 'ACTIVE' THEN
                --and revert...
                UPDATE  oe_blanket_headers_all
                SET flow_status_code = v_flow_status
                WHERE header_id = v_blanket.header_id
                ;
              END IF;

              l_order_number    := NULL;
              l_oe_header_id     := NULL;

BEGIN
              select header_id into l_oe_header_id from oe_order_headers_all
                    where order_number = v_header_out_rec.order_number;


EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -l_order_number '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
end;


              --FND_FILE.PUT_LINE(FND_FILE.LOG,'Line Nnmber'||v_flow_status);
              commit;
              --- Final Invoice Flag Change Start --RFC 002 ---
    IF v_return_status='S' then
        FOR r_oe_order_header IN c_oe_order_header(l_oe_header_id)
            LOOP
                FOR r_blanket_order_lines in c_blanket_order_lines(r_oe_order_header.blanket_number,r_oe_order_header.blanket_line_number)
                        LOOP
BEGIN
                            UPDATE oe_blanket_lines_all
                            SET    attribute10 =r_oe_order_header.attribute12-- 'Y'
                            WHERE  header_id=r_blanket_order_lines.header_id
                            AND    line_id = r_blanket_order_lines.line_id;
                            commit;
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error update attribute10 '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
end;

                        END LOOP;

            END LOOP;
            --commit;
    END IF;
    --- Final Invoice Flag Change Ends --RFC 002 ---

               IF v_return_status != fnd_api.g_ret_sts_success THEN
                FOR i IN 1 .. v_msg_count LOOP
                   oe_msg_pub.get
                   ( p_msg_index => i
                   , p_encoded => fnd_api.g_false
                   , p_data => v_data
                   , p_msg_index_out => v_msg_index
                   );
                   log(fnd_log.level_procedure,c_module||'.error',v_data);
                  IF v_message IS NULL THEN
                    v_message := v_data;
                  ELSE
                    v_message := v_message||'+'||v_data;
                  END IF;
                END LOOP;
                v_message := 'Error in creation of release lines for blanket '
      ||v_header.order_number||'+'||v_message;
                v_status := 'E';
                ROLLBACK TO start_order;
              END IF;
            END IF;
          END IF;
        END IF;
      ELSE
        v_message := 'No blanket found with number '||v_header.order_number;
        v_status := 'E';
      END IF;
      UPDATE xxah_va_upload
      SET message = v_message
      ,   status = v_status
      WHERE blanket_number = v_blanket.header_id
      AND   order_type = v_blanket.order_type
      AND   request_id = fnd_global.conc_request_id
      AND   nvl(order_date,trunc(sysdate)) = v_blanket.order_date
      ;
      IF v_status = 'S' THEN

        fnd_file.put_line(fnd_file.output,rpad(v_header_out_rec.order_number,
      20,' ')||v_header.order_number);
      END IF;
    END LOOP;
    v_err_found := FALSE;
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,'Rejected Releases: ');
    fnd_file.put_line(fnd_file.output,'Blanket Number  -Reference-  Message');
    FOR v_msg IN c_msg LOOP
      retcode := 1;
      v_err_found := TRUE;
      fnd_file.put_line(fnd_file.output,v_msg.order_number||'-'||v_msg.
      reference||'-'||'  '||v_msg.message);
    END LOOP;
    --
    IF NOT v_err_found THEN
      fnd_file.put_line(fnd_file.output,'None');
    END IF;
    --
    fnd_file.put_line(fnd_file.output,' ');
    v_err_found := FALSE;
    fnd_file.put_line(fnd_file.output,
      'The following blankets have been ignored because at least one line does not exist on the blanket.'
      );
    fnd_file.put_line(fnd_file.output,'Blanket Number  Line Number');
    FOR v_rejected IN c_rejected LOOP
      retcode := 1;
      v_err_found := TRUE;
      fnd_file.put_line(fnd_file.output,v_rejected.order_number||'  '||
      v_rejected.blanket_line_number);
    END LOOP;
    --
    IF NOT v_err_found THEN
      fnd_file.put_line(fnd_file.output,'None');
    END IF;
    --
--    INSERT INTO xxah_va_upload_bak
--    SELECT * from xxah_va_upload
--    WHERE request_id = fnd_global.conc_request_id
--    ;
    --
    DELETE FROM xxah_va_upload
    WHERE request_id = fnd_global.conc_request_id
    ;
    IF retcode = 1 THEN
      errbuf := 'Errors exist; please check the output for details.';
    END IF;
    log(fnd_log.level_procedure,c_module||'.flow','End');
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := SQLERRM;
      log(fnd_log.level_procedure,c_module||'.exception',SQLERRM);
  END create_releases;
  --
END xxah_va_upload_pkg;

/
