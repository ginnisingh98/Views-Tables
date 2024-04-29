--------------------------------------------------------
--  DDL for Package Body CSI_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_DEBUG_PKG" as
/* $Header: csidbugb.pls 120.3 2005/07/08 17:10:11 brmanesh noship $ */

  l_mmt_tbl_cache   mmt_tbl;
  l_item_tbl_cache  item_tbl;
  l_inst_tbl_cache  instance_tbl;

  FUNCTION fill(
    p_column in varchar2,
    p_width  in number,
    p_side   in varchar2 default 'R')
  RETURN varchar2 is
    l_column varchar2(2000);
  BEGIN
    l_column := nvl(p_column, ' ');
    IF p_side = 'L' THEN
      return(lpad(l_column, p_width, ' '));
    ELSIF p_side = 'R' THEN
      return(rpad(l_column, p_width, ' '));
    END IF;
  END fill;

  PROCEDURE check_and_init_debug
  IS
    l_debug_level    number;
    l_debug_path     varchar2(240);
    l_utl_file_dir   varchar2(2000);
  BEGIN
    g_utl_check_done := 'Y';

    SELECT fnd_profile.value('csi_debug_level')
    INTO   l_debug_level
    FROM   sys.dual;

    IF nvl(l_debug_level, 0) = 0 THEN
      csi_t_gen_utility_pvt.g_debug_level := 10;
    END IF;

    SELECT fnd_profile.value('csi_logfile_path')
    INTO   l_debug_path
    FROM   sys.dual;

    SELECT value
    INTO   l_utl_file_dir
    FROM   v$parameter
    WHERE  name = 'utl_file_dir';

    IF l_debug_path not like '%'||l_utl_file_dir||'%' THEN
      SELECT substr(l_utl_file_dir, 1,
             decode(instr(l_utl_file_dir, ',', 1), 0,
             length(l_utl_file_dir), instr(l_utl_file_dir, ',', 1)-1 ))
      INTO   l_debug_path
      FROM   sys.dual;
    END IF;

    csi_t_gen_utility_pvt.g_dir := l_debug_path;

    --dbms_output.put_line('Output File : '||
      --csi_t_gen_utility_pvt.g_dir||'/'||csi_t_gen_utility_pvt.g_file);

  EXCEPTION
    WHEN others THEN
      null;
  END check_and_init_debug;

  PROCEDURE add(
    p_message            IN varchar2)
  IS
  BEGIN
    IF g_utl_check_done = 'N' THEN
      check_and_init_debug;
    END IF;
    csi_t_gen_utility_pvt.add(p_message);
    fnd_file.put_line(fnd_file.output, p_message);
  END add;

  PROCEDURE blank_line IS
  BEGIN
    add(' ');
  END blank_line;

  PROCEDURE cache_instance_id(
    p_inst_id IN number )
  IS
    l_new_ind binary_integer := 0;
    l_cached  boolean := FALSE;
  BEGIN

    IF nvl(p_inst_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      IF l_inst_tbl_cache.COUNT > 0 THEN
        FOR l_ind IN l_inst_tbl_cache.FIRST..l_inst_tbl_cache.LAST
        LOOP
          IF p_inst_id = l_inst_tbl_cache(l_ind).instance_id THEN
            l_cached := TRUE;
            exit;
          END IF;
        END LOOP;
      END IF;

      IF not(l_cached) THEN
        l_new_ind := l_inst_tbl_cache.COUNT + 1;
        l_inst_tbl_cache(l_new_ind).instance_id := p_inst_id;
      END IF;

    END IF;

  END cache_instance_id;

  PROCEDURE cache_item_rec(
    p_item_rec      IN item_rec)
  IS
    l_ind binary_integer := 0;
  BEGIN
    l_ind := l_item_tbl_cache.COUNT + 1;
    l_item_tbl_cache(l_ind) := p_item_rec;
  END cache_item_rec;

  PROCEDURE get_item_rec_from_cache(
    p_item_id          IN  number,
    p_organization_id  IN  number,
    x_item_rec         OUT nocopy item_rec,
    x_cached           OUT nocopy boolean)
  IS
  BEGIN
    x_cached := FALSE;
    IF l_item_tbl_cache.COUNT > 0 THEN
      FOR l_ind IN l_item_tbl_cache.FIRST .. l_item_tbl_cache.LAST
      LOOP
        IF l_item_tbl_cache(l_ind).item_id = p_item_id AND
           l_item_tbl_cache(l_ind).organization_id = p_organization_id
        THEN
          x_item_rec := l_item_tbl_cache(l_ind);
          x_cached  := TRUE;
          exit;
        END IF;
      END LOOP;
    END IF;
  END get_item_rec_from_cache;

  PROCEDURE get_item_rec(
    p_item_id            IN number,
    p_organization_id    IN number,
    x_item_rec           OUT nocopy item_rec)
  IS
    l_item_rec           item_rec;
    l_cached             boolean := FALSE;
  BEGIN

    get_item_rec_from_cache(
      p_item_id          => p_item_id,
      p_organization_id  => p_organization_id,
      x_item_rec         => l_item_rec,
      x_cached           => l_cached);

    IF NOT (l_cached) THEN
      SELECT inventory_item_id,
             organization_id,
             reservable_type,
             nvl(comms_nl_trackable_flag,'N'),
             serial_number_control_code,
             lot_control_code,
             shippable_item_flag,
             bom_item_type,
             concatenated_segments,
             primary_uom_code,
             location_control_code,
             revision_qty_control_code,
             base_item_id,
             pick_components_flag,
             returnable_flag,
             wip_supply_type,
             planning_make_buy_code,
             inventory_item_flag,
             mtl_transactions_enabled_flag
      INTO   l_item_rec.item_id,
             l_item_rec.organization_id,
             l_item_rec.reservable_type,
             l_item_rec.ib_trackable_flag,
             l_item_rec.serial_code,
             l_item_rec.lot_code,
             l_item_rec.shippable_flag,
             l_item_rec.bom_item_type,
             l_item_rec.item,
             l_item_rec.primary_uom_code,
             l_item_rec.locator_code,
             l_item_rec.revision_code,
             l_item_rec.base_item_id,
             l_item_rec.pick_flag,
             l_item_rec.returnable_flag,
             l_item_rec.wip_supply_type,
             l_item_rec.make_buy_code,
             l_item_rec.inventory_flag,
             l_item_rec.inv_transactable_flag
      FROM   mtl_system_items_vl
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_organization_id;

      cache_item_rec(p_item_rec => l_item_rec);

    END IF;

    x_item_rec := l_item_rec;

  END get_item_rec;

  PROCEDURE get_next_level(
    p_parent_line_id      IN     number,
    p_order_lines         IN     order_lines,
    x_next_level_lines       OUT nocopy order_lines)
  IS
    x_ind                 binary_integer := 0;
    l_ind                 binary_integer := 0;
  BEGIN
    IF p_order_lines.COUNT > 0 THEN
      l_ind := 0;
      LOOP

        l_ind := p_order_lines.NEXT(l_ind);
        EXIT when l_ind is null;

        IF p_order_lines(l_ind).link_to_line_id = p_parent_line_id THEN
          x_ind := x_ind + 1;
          x_next_level_lines(x_ind) := p_order_lines(l_ind);
        END IF;
      END LOOP;
    END IF;
  END get_next_level;

  FUNCTION already_pushed(
    p_line_id             IN number,
    p_sorted_lines        IN order_lines)
  RETURN boolean
  IS
    l_return   boolean := FALSE;
  BEGIN
    IF p_sorted_lines.COUNT > 0 THEN
      FOR l_ind IN p_sorted_lines.FIRST .. p_sorted_lines.LAST
      LOOP
        IF p_sorted_lines(l_ind).line_id = p_line_id THEN
          l_return := TRUE;
          exit;
        END IF;
      END LOOP;
    END IF;
    RETURN l_return;
  END already_pushed;

  PROCEDURE get_model_lines(
    p_model_line_id       IN  number,
    p_order_lines         IN  order_lines,
    x_model_lines         OUT nocopy order_lines)
  IS
    l_ind                 binary_integer := 0;
    x_ind                 binary_integer := 0;
  BEGIN
    IF p_order_lines.COUNT > 0 THEN
      l_ind := 0;
      LOOP
        l_ind := p_order_lines.NEXT(l_ind);
        EXIT when l_ind is null;

        IF p_order_lines(l_ind).top_model_line_id = p_model_line_id THEN
          x_ind := x_ind + 1;
          x_model_lines(x_ind) := p_order_lines(l_ind);
        END IF;

      END LOOP;
    END IF;
  END get_model_lines;

  PROCEDURE sort_the_order(
    px_order_lines        IN OUT nocopy order_lines)
  IS

    l_order_lines         order_lines;
    l_top_lines           order_lines;
    l_model_lines         order_lines;
    l_sorted_lines        order_lines;
    l_next_level_lines    order_lines;

    l_model_count         number := 0;

    l_ind                 binary_integer := 0;
    l_s_ind               binary_integer := 0;
    l_t_ind               binary_integer := 0;

  BEGIN

    l_order_lines := px_order_lines;

    IF l_order_lines.COUNT > 0 THEN
      -- get the top_model lines first
      FOR  l_ind IN l_order_lines.FIRST .. l_order_lines.LAST
      LOOP

        IF l_order_lines(l_ind).link_to_line_id is null THEN

          l_t_ind := l_t_ind + 1;
          l_top_lines(l_t_ind) := l_order_lines(l_ind);

        END IF;

      END LOOP;

      IF l_top_lines.COUNT > 0 THEN

        FOR l_t_ind IN l_top_lines.FIRST .. l_top_lines.LAST
        LOOP

          get_model_lines(
            p_model_line_id => l_top_lines(l_t_ind).line_id,
            p_order_lines   => l_order_lines,
            x_model_lines   => l_model_lines);

          l_model_count := l_model_lines.count;

          l_s_ind := l_s_ind + 1;
          l_sorted_lines(l_s_ind) := l_top_lines(l_t_ind);

          l_model_count := l_model_count - 1;

          --get the next level
          get_next_level(
            p_parent_line_id      => l_top_lines(l_t_ind).line_id,
            p_order_lines         => l_model_lines,
            x_next_level_lines    => l_next_level_lines);

          LOOP

            IF l_model_count <= 0 THEN
              exit;
            END IF;

            IF l_next_level_lines.count > 0 THEN

              l_ind := 0;
              LOOP

                <<skip>>

                l_ind := l_next_level_lines.NEXT(l_ind);
                EXIT when l_ind is null;

                IF already_pushed(l_next_level_lines(l_ind).line_id, l_sorted_lines) THEN
                  GOTO SKIP;
                END IF;

                l_s_ind := l_s_ind + 1;
                l_sorted_lines(l_s_ind) := l_next_level_lines(l_ind);
                l_model_count := l_model_count - 1;

                get_next_level(
                  p_parent_line_id      => l_sorted_lines(l_s_ind).line_id,
                  p_order_lines         => l_model_lines,
                  x_next_level_lines    => l_next_level_lines);

                IF l_next_level_lines.count = 0 THEN
                  l_next_level_lines := l_model_lines;
                END IF;

                exit;

              END LOOP;
            END IF;

          END LOOP;

        END LOOP;

      END IF;

    END IF;

    px_order_lines := l_sorted_lines;

  END sort_the_order;

  PROCEDURE dump_order_line(
    p_order_line         IN order_line)
  IS
    l_line               varchar2(2000);
    l_ib_ind             varchar2(1);
  BEGIN

    SELECT decode(p_order_line.ib_trackable_flag, 'Y', '*', ' ')
    INTO   l_ib_ind
    FROM   sys.dual;

    l_line := l_ib_ind||fill(p_order_line.line_id, 9)||
              fill(p_order_line.line_number, 8)||
              fill(lpad(' ', p_order_line.level*2, ' ')||p_order_line.item_number, 25)||
              fill(p_order_line.identified_item_type, 14)||
              fill(p_order_line.item_id, 9)||
              fill(p_order_line.ship_from_org_id, 4)||
              fill(p_order_line.order_qty, 5)||
              fill(p_order_line.order_uom, 3)||
              fill(p_order_line.link_to_line_id, 9)||
              fill(p_order_line.line_status, 12);
    add(l_line);
  END dump_order_line;

  PROCEDURE dump_order_summary(
    p_order_number         IN number,
    px_order_lines         IN OUT nocopy order_lines)
  IS
    l_order_lines          order_lines;
    l_line_header          varchar2(2000);
  BEGIN

    l_order_lines := px_order_lines;

    IF l_order_lines.count > 0 THEN

      blank_line;
      add('Order Number : '||p_order_number);
      blank_line;

      sort_the_order(l_order_lines);

      l_line_header := fill(' LineID', 10)||
                       fill('Line',8)||
                       fill('Item', 25)||
                       fill('Type   ',14)||
                       fill('ItemId ',9)||
                       fill('Org', 4)||
                       fill('Qty ', 5)||
                       fill('UM',3)||
                       fill('Link   ',9)||
                       fill('Status',12);
      add(l_line_header);
      l_line_header := fill('--------', 10)||
                       fill('--------',8)||
                       fill('--------------------', 25)||
                       fill('-------',14)||
                       fill('-------',9)||
                       fill('---', 4)||
                       fill('----', 5)||
                       fill('--',3)||
                       fill('-------',9)||
                       fill('--------',12);
      add(l_line_header);

      FOR l_ind in l_order_lines.FIRST .. l_order_lines.LAST
      LOOP
        dump_order_line(l_order_lines(l_ind));
      END LOOP;

      blank_line;

    END IF;

    px_order_lines := l_order_lines;

  END dump_order_summary;

  PROCEDURE dump_order_detail(
    p_order_line   IN order_line)
  IS
    l_out varchar2(2000);
  BEGIN
    blank_line;
    l_out := fill(p_order_line.line_number, 9)||
             fill(p_order_line.line_id, 9)||
             fill(p_order_line.identified_item_type, 14);
    add(l_out);
    blank_line;
    l_out := '  '||fill('org_id',22)||': '||fill(p_order_line.org_id,20)||
                   fill('order_qty', 22)||': '||fill(p_order_line.order_qty, 20);
    add(l_out);
    l_out := '  '||fill('header_id',22)||': '||fill(p_order_line.header_id, 20)||
                   fill('order_uom', 22)||': '||fill(p_order_line.order_uom, 20);
    add(l_out);
    l_out := '  '||fill('creation_date',22)||': '||
                   fill(to_char(p_order_line.creation_date,'MM/DD/YY HH24:MI:SS'), 20)||
                   fill('item_revision', 22)||': '||fill(p_order_line.item_revision, 20);
    add(l_out);

    l_out := '  '||fill('shippable_flag',22)||': '||fill(p_order_line.shippable_flag, 20);
    add(l_out);

    l_out := '  '||fill('shipped_flag',22)||': '||fill(p_order_line.shipped_flag, 20)||
                   fill('fulfilled_flag', 22)||': '||fill(p_order_line.fulfilled_flag, 20);
    add(l_out);

    l_out := '  '||fill('shipped_quantity',22)||': '||fill(p_order_line.shipped_quantity, 20)||
                   fill('fulfilled_quantity', 22)||': '||fill(p_order_line.fulfilled_quantity, 20);
    add(l_out);

    l_out := '  '||fill('shipment_date',22)||': '||
                   fill(to_char(p_order_line.shipment_date, 'MM/DD/YY HH24:MI:SS'), 20)||
                   fill('fulfillment_date', 22)||': '||
                   fill(to_char(p_order_line.fulfillment_date,'MM/DD/YY HH24:MI:SS'), 20);
    add(l_out);

    l_out := '  '||fill('order_type_id',22)||': '||fill(p_order_line.order_type_id, 20)||
                   fill('link_to_line_id', 22)||': '||fill(p_order_line.link_to_line_id, 20);
    add(l_out);

    l_out := '  '||fill('line_type_id',22)||': '||fill(p_order_line.line_type_id, 20)||
                   fill('ato_line_id',22)||': '||fill(p_order_line.ato_line_id, 20);
    add(l_out);

    l_out := '  '||fill('item_type',22)||': '||fill(p_order_line.item_type, 20)||
                   fill('top_model_line_id',22)||': '||fill(p_order_line.top_model_line_id, 20);
    add(l_out);

    l_out := '  '||fill('line_category_code',22)||': '||fill(p_order_line.line_category_code, 20)||
                   fill('split_from_line_id',22)||': '||fill(p_order_line.split_from_line_id, 20);
    add(l_out);

    l_out := '  '||fill('ship_from_org_id',22)||': '||fill(p_order_line.ship_from_org_id, 20);

    add(l_out);
    l_out := '  '||fill('ship_to_org_id',22)||': '||fill(p_order_line.ship_to_org_id, 20)||
                   fill('ship_to_contact_id',22)||': '||fill(p_order_line.ship_to_contact_id, 20);
    add(l_out);

    l_out := '  '||fill('invoice_to_org_id', 22)||': '||fill(p_order_line.invoice_to_org_id, 20)||
                 fill('invoice_to_contact_id', 22)||': '||fill(p_order_line.invoice_to_contact_id, 20);
    add(l_out);

    l_out := '  '||fill('deliver_to_org_id',22)||': '||fill(p_order_line.deliver_to_org_id, 20)||
                 fill('deliver_to_contact_id',22)||': '||fill(p_order_line.deliver_to_contact_id, 20);
    add(l_out);

    l_out := '  '||fill('price_list_id',22)||': '||fill(p_order_line.price_list_id, 20)||
                   fill('drop_ship_flag',22)||': '||fill(p_order_line.drop_ship_flag, 20);
    add(l_out);
    l_out := '  '||fill('unit_selling_price',22)||': '||fill(p_order_line.unit_selling_price, 20)||
                   fill('cancelled_flag',22)||': '||fill(p_order_line.cancelled_flag, 20);
    add(l_out);
    l_out := '  '||fill('configuration_id',22)||': '||fill(p_order_line.configuration_id, 20);
    add(l_out);
    l_out := '  '||fill('config_header_id',22)||': '||fill(p_order_line.config_header_id, 20);
    add(l_out);
    l_out := '  '||fill('config_rev_nbr',22)||': '||fill(p_order_line.config_rev_nbr, 20);
    add(l_out);

  END dump_order_detail;

  PROCEDURE get_ib_trackable_lines(
    px_order_lines       IN OUT nocopy order_lines)
  IS
    l_order_lines        order_lines;
    l_ind                binary_integer := 0;
  BEGIN
    IF px_order_lines.count > 0 THEN
      FOR px_ind IN px_order_lines.FIRST .. px_order_lines.LAST
      LOOP
        IF px_order_lines(px_ind).ib_trackable_flag = 'Y' THEN
          l_ind := l_ind + 1;
          l_order_lines(l_ind) :=  px_order_lines(px_ind);
        END IF;
      END LOOP;
    END IF;
    px_order_lines := l_order_lines;
  END get_ib_trackable_lines;

  PROCEDURE dump_tld(
    p_transaction_line_id     IN number,
    px_tld_tbl                IN OUT nocopy tld_tbl)
  IS

    l_out          varchar2(2000);
    l_tld_ind      binary_integer := 0;
    l_instance_key varchar2(30);

    CURSOR tld_cur(p_transaction_line_id IN number) IS
      SELECT transaction_line_id,
             txn_line_detail_id,
             inventory_item_id,
             quantity,
             serial_number,
             lot_number,
             instance_id,
             changed_instance_id,
             location_type_code,
             location_id,
             processing_status,
             source_transaction_flag,
             config_inst_baseline_rev_num,
             config_inst_hdr_id,
             config_inst_item_id,
             config_inst_rev_num
      FROM   csi_t_txn_line_details
      WHERE  transaction_line_id     = p_transaction_line_id
      ORDER BY source_transaction_flag desc, txn_line_detail_id asc;

  BEGIN

    blank_line;

    l_tld_ind := px_tld_tbl.COUNT;

    FOR tld_rec IN tld_cur(p_transaction_line_id)
    LOOP

      IF tld_cur%rowcount = 1 THEN
        l_out := '  '||fill('S', 2)||
                       fill('TLDID  ', 9)||
                       fill('ItemID', 9)||
                       fill('Qty',9)||
                       fill('InstID', 9)||
                       fill('InstKey',20)||
                       fill('Status', 10)||
                       fill('Serial', 15)||
                       fill('Lot', 12);
        add(l_out);
        l_out := '  '||fill('-', 2)||
                       fill('-----  ', 9)||
                       fill('------', 9)||
                       fill('---',9)||
                       fill('------', 9)||
                       fill('--------', 20)||
                       fill('-------', 10)||
                       fill('------', 15)||
                       fill('---', 12);
        add(l_out);
      END IF;

      l_tld_ind := l_tld_ind + 1;

      px_tld_tbl(l_tld_ind).transaction_line_id          := tld_rec.transaction_line_id;
      px_tld_tbl(l_tld_ind).txn_line_detail_id           := tld_rec.txn_line_detail_id;
      px_tld_tbl(l_tld_ind).inventory_item_id            := tld_rec.inventory_item_id;
      px_tld_tbl(l_tld_ind).quantity                     := tld_rec.quantity;
      px_tld_tbl(l_tld_ind).serial_number                := tld_rec.serial_number;
      px_tld_tbl(l_tld_ind).lot_number                   := tld_rec.lot_number;
      px_tld_tbl(l_tld_ind).instance_id                  := tld_rec.changed_instance_id;
      px_tld_tbl(l_tld_ind).location_type_code           := tld_rec.location_type_code;
      px_tld_tbl(l_tld_ind).location_id                  := tld_rec.location_id;
      px_tld_tbl(l_tld_ind).processing_status            := tld_rec.processing_status;
      px_tld_tbl(l_tld_ind).source_transaction_flag      := tld_rec.source_transaction_flag;
      px_tld_tbl(l_tld_ind).config_inst_baseline_rev_num := tld_rec.config_inst_baseline_rev_num;
      px_tld_tbl(l_tld_ind).config_inst_hdr_id           := tld_rec.config_inst_hdr_id;
      px_tld_tbl(l_tld_ind).config_inst_item_id          := tld_rec.config_inst_item_id;
      px_tld_tbl(l_tld_ind).config_inst_rev_num          := tld_rec.config_inst_rev_num;

      IF tld_rec.processing_status = 'ERROR' THEN
        cache_instance_id(tld_rec.changed_instance_id);
      END IF;

      l_instance_key := tld_rec.config_inst_hdr_id||'.'||
                        tld_rec.config_inst_item_id||'.'||
                        tld_rec.config_inst_rev_num||'.'||
                        tld_rec.config_inst_baseline_rev_num;

      l_out := '  '||fill(tld_rec.source_transaction_flag, 2)||
                     fill(tld_rec.txn_line_detail_id, 9)||
                     fill(tld_rec.inventory_item_id, 9)||
                     fill(tld_rec.quantity, 9)||
                     fill(tld_rec.instance_id, 9)||
                     fill(l_instance_key, 20)||
                     fill(tld_rec.processing_status, 10)||
                     fill(tld_rec.serial_number, 15)||
                     fill(tld_rec.lot_number, 12);
      add(l_out);

    END LOOP;

  END dump_tld;

  PROCEDURE dump_tld_details(
    p_tld_tbl IN tld_tbl)
  IS

    l_out          varchar2(2000);

    CURSOR tld_pty_cur(p_txn_line_detail_id IN number) IS
      SELECT txn_party_detail_id,
             party_source_table,
             party_source_id,
             relationship_type_code,
             contact_flag,
             contact_party_id
      FROM   csi_t_party_details
      WHERE  txn_line_detail_id = p_txn_line_detail_id;

    CURSOR tld_acct_cur(p_txn_party_detail_id IN number) IS
      SELECT txn_account_detail_id,
             ip_account_id,
             relationship_type_code,
             account_id,
             active_start_date,
             ship_to_address_id,
             bill_to_address_id
      FROM   csi_t_party_accounts
      WHERE  txn_party_detail_id = p_txn_party_detail_id;

  BEGIN

    IF p_tld_tbl.COUNT > 0 THEN
      FOR tld_ind IN p_tld_tbl.FIRST .. p_tld_tbl.LAST
      LOOP

        FOR tld_pty_rec IN tld_pty_cur(p_tld_tbl(tld_ind).txn_line_detail_id)
        LOOP
          l_out := '    '||fill('TPDID', 9)||
                           fill('RelType', 12)||
                           fill('PartySource', 20)||
                           fill('PartyID', 9)||
                           fill('C',2)||
                           fill('ConPtyID', 9);
          add(l_out);
          l_out := '    '||fill('-----', 9)||
                           fill('-------', 12)||
                           fill('-----------', 20)||
                           fill('-------', 9)||
                           fill('-',2)||
                           fill('--------', 9);
          add(l_out);

          l_out := '    '||fill(tld_pty_rec.txn_party_detail_id, 9)||
                           fill(tld_pty_rec.relationship_type_code, 12)||
                           fill(tld_pty_rec.party_source_table, 20)||
                           fill(tld_pty_rec.party_source_id, 9)||
                           fill(tld_pty_rec.contact_flag, 2)||
                           fill(tld_pty_rec.contact_party_id, 9);
          add(l_out);

          l_out := '      '||fill('TADID',9)||
                         fill('RelType',12)||
                         fill('AcctID',9)||
                         fill('IPAcctID',9)||
                         fill('ShipToID',9)||
                         fill('BillToID',9);
          add(l_out);
          l_out := '      '||fill('-----',9)||
                         fill('-------',12)||
                         fill('------',9)||
                         fill('--------',9)||
                         fill('--------',9)||
                         fill('--------',9);
          add(l_out);

          FOR tld_acct_rec IN tld_acct_cur(tld_pty_rec.txn_party_detail_id)
          LOOP
            l_out := '      '||fill(tld_acct_rec.txn_account_detail_id,9)||
                           fill(tld_acct_rec.relationship_type_code,12)||
                           fill(tld_acct_rec.account_id,9)||
                           fill(tld_acct_rec.ip_account_id,9)||
                           fill(tld_acct_rec.ship_to_address_id,9)||
                           fill(tld_acct_rec.bill_to_address_id,9);
            add(l_out);
          END LOOP;
        END LOOP;
      END LOOP;
    END IF;
  END dump_tld_details;

  PROCEDURE dump_tiir(
    p_tl_rec       IN  csi_t_transaction_lines%rowtype,
    p_tld_tbl      IN  tld_tbl)
  IS
    l_out varchar2(2000);
    CURSOR t_iir_cur(p_txn_line_id IN NUMBER) IS
      SELECT txn_relationship_id,
             subject_type,
             subject_id,
             relationship_type_code,
             object_type,
             object_id,
             position_reference,
             display_order,
             mandatory_flag,
             active_end_date,
             csi_inst_relationship_id,
             migrated_flag,
             sub_config_inst_hdr_id,
             sub_config_inst_rev_num,
             sub_config_inst_item_id,
             obj_config_inst_hdr_id,
             obj_config_inst_rev_num,
             obj_config_inst_item_id
      FROM   csi_t_ii_relationships
      WHERE  transaction_line_id = p_txn_line_id;

   CURSOR macd_iir_cur(p_inst_hdr_id IN NUMBER, p_inst_item_id IN number, p_inst_rev_num in number) IS
      SELECT txn_relationship_id,
             subject_type,
             subject_id,
             relationship_type_code,
             object_type,
             object_id,
             position_reference,
             display_order,
             mandatory_flag,
             active_end_date,
             csi_inst_relationship_id,
             migrated_flag,
             sub_config_inst_hdr_id,
             sub_config_inst_rev_num,
             sub_config_inst_item_id,
             obj_config_inst_hdr_id,
             obj_config_inst_rev_num,
             obj_config_inst_item_id
      FROM   csi_t_ii_relationships
      WHERE  (sub_config_inst_hdr_id  = p_inst_hdr_id
              AND
              sub_config_inst_item_id = p_inst_item_id
              AND
              sub_config_inst_rev_num = p_inst_rev_num)
      OR     (obj_config_inst_hdr_id  = p_inst_hdr_id
              AND
              obj_config_inst_item_id = p_inst_item_id
              AND
              obj_config_inst_rev_num = p_inst_rev_num);

  BEGIN
    blank_line;

    IF p_tl_rec.source_transaction_table = 'CONFIGURATOR' THEN
      IF p_tld_tbl.COUNT > 0 THEN
        l_out := '  '||fill('TRID', 9)||
                       fill('SType', 6)||
                       fill('SubID', 9)||
                       fill('RelTypeCode', 18)||
                       fill('OType', 6)||
                       fill('ObjID',9);
        add(l_out);
        l_out := '  '||fill('----', 9)||
                       fill('-----', 6)||
                       fill('-----', 9)||
                       fill('-----------', 18)||
                       fill('-----', 6)||
                       fill('-----',9);
        add(l_out);

        FOR l_ind IN p_tld_tbl.FIRST .. p_tld_tbl.LAST
        LOOP
          FOR iir_rec IN macd_iir_cur(
            p_inst_hdr_id  => p_tld_tbl(l_ind).config_inst_hdr_id,
            p_inst_item_id => p_tld_tbl(l_ind).config_inst_item_id,
            p_inst_rev_num => p_tld_tbl(l_ind).config_inst_rev_num)
          LOOP
            l_out := '  '||fill(iir_rec.txn_relationship_id, 9)||
                           fill(iir_rec.subject_type, 6)||
                           fill(iir_rec.subject_id, 9)||
                           fill(iir_rec.relationship_type_code, 18)||
                           fill(iir_rec.object_type, 6)||
                           fill(iir_rec.object_id,9);
            add(l_out);
          END LOOP;
        END LOOP;
      END IF;
    ELSE
      FOR iir_rec IN t_iir_cur(p_tl_rec.transaction_line_id)
      LOOP

        IF t_iir_cur%rowcount = 1 THEN
          l_out := '  '||fill('TRID', 9)||
                         fill('SType', 6)||
                         fill('SubID', 9)||
                         fill('RelTypeCode', 18)||
                         fill('OType', 6)||
                         fill('ObjID',9);
          add(l_out);
          l_out := '  '||fill('----', 9)||
                         fill('-----', 6)||
                         fill('-----', 9)||
                         fill('-----------', 18)||
                         fill('-----', 6)||
                         fill('-----',9);
          add(l_out);
        END IF;

        l_out := '  '||fill(iir_rec.txn_relationship_id, 9)||
                       fill(iir_rec.subject_type, 6)||
                       fill(iir_rec.subject_id, 9)||
                       fill(iir_rec.relationship_type_code, 18)||
                       fill(iir_rec.object_type, 6)||
                       fill(iir_rec.object_id,9);
        add(l_out);
      END LOOP;
    END IF;
  END dump_tiir;

  PROCEDURE dump_installation_details(
    p_order_lines           IN order_lines,
    p_source_table          IN varchar2)
  IS

    l_order_lines           order_lines;
    l_rowcount              number;
    l_prepend               varchar2(30);
    l_out                   varchar2(2000);
    l_tl_rec                csi_t_transaction_lines%rowtype;
    l_tld_tbl               tld_tbl;

    l_print_header          boolean := TRUE;
    l_session_key           varchar2(30);

  BEGIN

    l_order_lines := p_order_lines;

    IF l_order_lines.COUNT > 0 THEN

      FOR l_ind IN l_order_lines.FIRST .. l_order_lines.LAST
      LOOP
        IF l_order_lines(l_ind).macd_flag = 'Y' THEN
          SELECT *
          INTO   l_tl_rec
          FROM   csi_t_transaction_lines
          WHERE  source_transaction_table = 'CONFIGURATOR'
          AND    config_session_hdr_id    = l_order_lines(l_ind).config_header_id
          AND    config_session_rev_num   = l_order_lines(l_ind).config_rev_nbr
          AND    config_session_item_id   = l_order_lines(l_ind).configuration_id;
        ELSE
          BEGIN
            SELECT  *
            INTO    l_tl_rec
            FROM    csi_t_transaction_lines
            WHERE   source_transaction_table = p_source_table
            AND     source_transaction_id    = l_order_lines(l_ind).line_id;
          EXCEPTION
            WHEN no_data_found THEN
              l_tl_rec.transaction_line_id := null;
          END;
        END IF;

        IF l_tl_rec.transaction_line_id is not null THEN
          IF l_print_header THEN
            blank_line;
            blank_line;
            add('Installation Details ('||p_source_table||') :- ');
            add('--------------------');
            l_print_header := FALSE;
          END IF;

          blank_line;

          l_session_key := l_tl_rec.config_session_hdr_id||'.'||
                           l_tl_rec.config_session_item_id||'.'||
                           l_tl_rec.config_session_rev_num;

          l_out := fill(l_order_lines(l_ind).line_number, 9)||
                   fill(l_order_lines(l_ind).line_id, 9)||
                   fill(l_order_lines(l_ind).identified_item_type, 14)||
                   fill(l_tl_rec.transaction_line_id, 9)||
                   fill(l_tl_rec.source_txn_header_id, 9)||
                   fill(l_session_key, 20)||
                   fill(l_tl_rec.config_valid_status, 5)||
                   fill(l_tl_rec.processing_status, 15);
          add(l_out);

          dump_tld(
            p_transaction_line_id     => l_tl_rec.transaction_line_id,
            px_tld_tbl                => l_tld_tbl);

          dump_tiir(
            p_tl_rec  => l_tl_rec,
            p_tld_tbl => l_tld_tbl);

        END IF;
      END LOOP;
    END IF;
  END dump_installation_details;

  PROCEDURE cache_mmt_rec(
    p_mmt_rec      IN mmt_rec)
  IS
    l_ind binary_integer := 0;
  BEGIN
    l_ind := l_mmt_tbl_cache.COUNT + 1;
    l_mmt_tbl_cache(l_ind) := p_mmt_rec;
  END cache_mmt_rec;

  PROCEDURE get_mmt_rec_from_cache(
    p_mtl_txn_id   IN         number,
    x_mmt_rec      OUT nocopy mmt_rec,
    x_cached       OUT nocopy boolean)
  IS
  BEGIN
    x_cached := FALSE;
    IF l_mmt_tbl_cache.COUNT > 0 THEN
      FOR l_ind IN l_mmt_tbl_cache.FIRST .. l_mmt_tbl_cache.LAST
      LOOP
        IF l_mmt_tbl_cache(l_ind).mtl_txn_id = p_mtl_txn_id THEN
          x_mmt_rec := l_mmt_tbl_cache(l_ind);
          x_cached  := TRUE;
          exit;
        END IF;
      END LOOP;
    END IF;
  END get_mmt_rec_from_cache;

  PROCEDURE get_mmt_status(
    px_mmt_rec     IN OUT nocopy mmt_rec)
  IS
  BEGIN

    IF csi_inv_trxs_pkg.valid_ib_txn(px_mmt_rec.mtl_txn_id) THEN
      BEGIN
        SELECT transaction_id,
               transaction_date
        INTO   px_mmt_rec.csi_txn_id,
               px_mmt_rec.csi_txn_date
        FROM   csi_transactions
        WHERE  inv_material_transaction_id = px_mmt_rec.mtl_txn_id
        AND    rownum = 1;
        px_mmt_rec.status := 'PROCESSED';
      EXCEPTION
        WHEN no_data_found THEN
          px_mmt_rec.csi_txn_id   := null;
          px_mmt_rec.csi_txn_date := null;
          BEGIN
            SELECT transaction_error_id,
                   error_text
            INTO   px_mmt_rec.error_id,
                   px_mmt_rec.error_text
            FROM   csi_txn_errors
            WHERE  inv_material_transaction_id = px_mmt_rec.mtl_txn_id
            AND    processed_flag in ('E', 'R');
            px_mmt_rec.status := 'ERROR';
          EXCEPTION
            WHEN no_data_found THEN
              px_mmt_rec.error_id   := null;
              px_mmt_rec.error_text := null;
              BEGIN
                SELECT msg_id,
                       msg_code,
                       msg_status
                INTO   px_mmt_rec.message_id,
                       px_mmt_rec.message_code,
                       px_mmt_rec.message_status
                FROM   xnp_msgs
                WHERE  dbms_lob.instr(body_text, 'MTL_TRANSACTION_ID') > 0
                AND    dbms_lob.instr(body_text, px_mmt_rec.mtl_txn_id) > 0
                AND    rownum = 1;
                px_mmt_rec.status := 'IN_QUEUE';
              EXCEPTION
                WHEN no_data_found THEN
                  px_mmt_rec.status := 'UNKNOWN';
                  px_mmt_rec.message_id     := null;
                  px_mmt_rec.message_code   := null;
                  px_mmt_rec.message_status := null;
              END;
          END;
      END;
    ELSE
      px_mmt_rec.status         := 'UNKNOWN';
      px_mmt_rec.message_id     := null;
      px_mmt_rec.message_code   := null;
      px_mmt_rec.message_status := null;
    END IF;

  END get_mmt_status;

  PROCEDURE get_mmt_rec(
    p_mtl_txn_id         IN number,
    x_mmt_rec            OUT nocopy mmt_rec)
  IS

    l_cached    boolean := FALSE;
    l_mmt_rec   mmt_rec;
    m_ind       binary_integer := 0;
    l_out       varchar2(2000);

    CURSOR mtl_txn_cur(p_txn_id IN number) IS
      SELECT mmt.transaction_id,
             mmt.transaction_date,
             mmt.transaction_quantity,
             mmt.transaction_uom,
             mmt.primary_quantity,
             mmt.transaction_action_id,
             mmt.transaction_source_type_id,
             mmt.transaction_type_id,
             mmt.inventory_item_id,
             mmt.organization_id ,
             mmt.transaction_source_id,
             mmt.trx_source_line_id,
             mmt.transfer_transaction_id,
             mtt.transaction_type_name,
             mtt.type_class,
             mtt.user_defined_flag
      FROM   mtl_material_transactions mmt,
             mtl_transaction_types     mtt
      WHERE  mmt.transaction_id      = p_txn_id
      AND    mtt.transaction_type_id = mmt.transaction_type_id;

  BEGIN

    get_mmt_rec_from_cache(
      p_mtl_txn_id   => p_mtl_txn_id,
      x_mmt_rec      => l_mmt_rec,
      x_cached       => l_cached);

    IF NOT (l_cached) THEN
      FOR mtl_txn_rec IN mtl_txn_cur(p_mtl_txn_id)
      LOOP

        l_mmt_rec.mtl_txn_id           := mtl_txn_rec.transaction_id;
        l_mmt_rec.mtl_txn_date         := mtl_txn_rec.transaction_date;
        l_mmt_rec.item_id              := mtl_txn_rec.inventory_item_id;
        l_mmt_rec.organization_id      := mtl_txn_rec.organization_id;
        l_mmt_rec.mtl_type_id          := mtl_txn_rec.transaction_type_id;
        l_mmt_rec.mtl_txn_name         := mtl_txn_rec.transaction_type_name;
        l_mmt_rec.mtl_action_id        := mtl_txn_rec.transaction_action_id;
        l_mmt_rec.mtl_source_type_id   := mtl_txn_rec.transaction_source_type_id;
        l_mmt_rec.mtl_source_id        := mtl_txn_rec.transaction_source_id;
        l_mmt_rec.mtl_source_line_id   := mtl_txn_rec.trx_source_line_id;
        l_mmt_rec.mtl_txn_qty          := mtl_txn_rec.transaction_quantity;
        l_mmt_rec.mtl_txn_uom          := mtl_txn_rec.transaction_uom;
        l_mmt_rec.mtl_pri_qty          := mtl_txn_rec.primary_quantity;
        l_mmt_rec.mtl_type_class       := mtl_txn_rec.type_class;
        l_mmt_rec.mtl_xfer_txn_id      := mtl_txn_rec.transfer_transaction_id;
        l_mmt_rec.user_defined         := mtl_txn_rec.user_defined_flag;

        get_mmt_status(l_mmt_rec);

      END LOOP;

      cache_mmt_rec(p_mmt_rec => l_mmt_rec);

    END IF;

    x_mmt_rec := l_mmt_rec;

  END get_mmt_rec;

  PROCEDURE dump_mmt_rec(
    p_mmt_rec        IN mmt_rec,
    p_index          IN number default 1)
  IS
    l_out       varchar2(2000);
    l_reference varchar2(2000);
  BEGIN

    IF p_index = 1 THEN
      blank_line;
      l_out := ' '||
               fill('OrgID', 6)||
               fill('TxnName', 22)||
               fill('TxnID', 10)||
               fill('TxnDate', 18)||
               fill('TQty', 8)||
               fill('TUOM', 5)||
               fill('SrcID', 8)||
               fill('SrcLnID', 8);
      add(l_out);

      l_out := ' '||
               fill('-----', 6)||
               fill('-------', 22)||
               fill('-----', 10)||
               fill('-------', 18)||
               fill('------', 8)||
               fill('----', 5)||
               fill('-----', 8)||
               fill('-------', 8);
       add(l_out);
    END IF;

    IF p_mmt_rec.status = 'PROCESSED' THEN
      l_reference := '                             '||fill(p_mmt_rec.status, 10)||
                     'CsiTxnID : '||p_mmt_rec.csi_txn_id;
    ELSIF p_mmt_rec.status = 'ERROR' THEN
      l_reference := '       ERROR : '||
                     p_mmt_rec.error_text;
    ELSIF p_mmt_rec.status = 'IN_QUEUE' THEN
      l_reference := '                             '||fill(p_mmt_rec.status, 10)||
                     'MsgID    : '||p_mmt_rec.message_id||'.'||p_mmt_rec.message_status;
    ELSIF p_mmt_rec.status = 'UNKNOWN' THEN
      l_reference := '                             '||fill(p_mmt_rec.status, 10);
    END IF;

    l_out := ' '||
             fill(p_mmt_rec.organization_id, 6)||
             fill(p_mmt_rec.mtl_txn_name, 22)||
             fill(p_mmt_rec.mtl_txn_id, 10)||
             fill(to_char(p_mmt_rec.mtl_txn_date, 'MM/DD/YY HH24:MI:SS'), 18)||
             fill(p_mmt_rec.mtl_txn_qty, 8)||
             fill(p_mmt_rec.mtl_txn_uom, 5)||
             fill(p_mmt_rec.mtl_source_id, 8)||
             fill(p_mmt_rec.mtl_source_line_id, 8);
    add(l_out);

    l_out := l_reference;
    add(l_out);

  END dump_mmt_rec;

  PROCEDURE get_mut_tbl(
    p_mtl_txn_id    IN  number,
    p_error_flag    IN  varchar2 default 'N',
    x_mut_tbl       OUT nocopy mut_tbl)
  IS

    l_mut_tbl       mut_tbl;
    l_mut_ind       binary_integer := 0;

    CURSOR srl_cur(
      p_txn_id     in number)
    IS
      SELECT mut.serial_number           serial_number,
             mut.inventory_item_id       item_id,
             mut.organization_id         organization_id,
             to_char(null)               lot_number
      FROM   mtl_unit_transactions mut
      WHERE  mut.transaction_id    = p_txn_id
      UNION
      SELECT mut.serial_number           serial_number,
             mut.inventory_item_id       item_id,
             mut.organization_id         organization_id,
             mtln.lot_number             lot_number
      FROM   mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut
      WHERE  mtln.transaction_id   = p_txn_id
      AND    mut.transaction_id    = mtln.serial_transaction_id
      ORDER  BY 1;

  BEGIN

    FOR srl_rec IN srl_cur(p_mtl_txn_id)
    LOOP
      l_mut_ind := l_mut_ind + 1;
      l_mut_tbl(l_mut_ind).serial_number := srl_rec.serial_number;
      l_mut_tbl(l_mut_ind).item_id       := srl_rec.item_id;
      l_mut_tbl(l_mut_ind).lot_number    := srl_rec.lot_number;

      BEGIN
        SELECT instance_id,
               location_type_code,
               instance_usage_code
        INTO   l_mut_tbl(l_mut_ind).instance_id ,
               l_mut_tbl(l_mut_ind).location_type_code,
               l_mut_tbl(l_mut_ind).instance_usage_code
        FROM   csi_item_instances
        WHERE  inventory_item_id = srl_rec.item_id
        AND    serial_number     = srl_rec.serial_number;

        IF p_error_flag = 'Y' THEN
          cache_instance_id(l_mut_tbl(l_mut_ind).instance_id);
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

    END LOOP;

    x_mut_tbl := l_mut_tbl;

  END get_mut_tbl;

  PROCEDURE dump_mut_tbl(
    p_mut_tbl      IN mut_tbl)
  IS
    l_out          varchar2(2000);
  BEGIN
    IF p_mut_tbl.COUNT > 0 THEN
      l_out := '    '||fill('Serial#', 15)||
             fill('Lot#', 15)||
             fill('InstID', 10)||
             fill('LocationType', 18)||
             fill('UsageCode', 18);
      add(l_out);

      l_out := '    '||fill('-------', 15)||
             fill('----', 15)||
             fill('------', 10)||
             fill('------------', 18)||
             fill('---------', 18);
      add(l_out);

      FOR p_ind IN p_mut_tbl.FIRST .. p_mut_tbl.LAST
      LOOP
        l_out := '    '||fill(p_mut_tbl(p_ind).serial_number, 15)||
               fill(p_mut_tbl(p_ind).lot_number, 15)||
               fill(p_mut_tbl(p_ind).instance_id, 10)||
               fill(p_mut_tbl(p_ind).location_type_code, 18)||
               fill(p_mut_tbl(p_ind).instance_usage_code, 18);
        add(l_out);
      END LOOP;
    END IF;
  END dump_mut_tbl;

  PROCEDURE get_srl_mmt_tbl(
    p_serial_number      IN  varchar2,
    p_item_id            IN  number,
    x_mmt_tbl            OUT nocopy mmt_tbl)
  IS

    l_mmt_rec            mmt_rec;
    l_mmt_tbl            mmt_tbl;
    l_mmt_ind            binary_integer := 0;

    CURSOR all_txn_cur(
      p_serial_number  in varchar2,
      p_item_id        in number)
    IS
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id
      FROM   mtl_unit_transactions     mut,
             mtl_material_transactions mmt
      WHERE  mut.serial_number       = p_serial_number
      AND    mut.inventory_item_id   = p_item_id
      AND    mmt.transaction_id      = mut.transaction_id
      UNION ALL
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id
      FROM   mtl_unit_transactions       mut,
             mtl_transaction_lot_numbers mtln,
             mtl_material_transactions   mmt
      WHERE  mut.serial_number          = p_serial_number
      AND    mut.inventory_item_id      = p_item_id
      AND    mtln.organization_id       = mut.organization_id
      AND    mtln.transaction_date      = mut.transaction_date
      AND    mtln.serial_transaction_id = mut.transaction_id
      AND    mmt.transaction_id         = mtln.transaction_id
      ORDER BY 1 desc, 2 desc;

  BEGIN
    FOR all_txn_rec IN all_txn_cur(
      p_serial_number => p_serial_number,
      p_item_id       => p_item_id)
    LOOP
      get_mmt_rec(
        p_mtl_txn_id => all_txn_rec.mtl_txn_id,
        x_mmt_rec    => l_mmt_rec);
      l_mmt_ind  := l_mmt_ind + 1;
      l_mmt_tbl(l_mmt_ind) := l_mmt_rec;
    END LOOP;
    x_mmt_tbl := l_mmt_tbl;
  END get_srl_mmt_tbl;

  PROCEDURE txn_status(
    p_mtl_txn_id         IN number)
  IS
    l_error_flag         varchar2(1);
    l_mmt_rec            mmt_rec;
    l_mut_tbl            mut_tbl;
  BEGIN

    IF csi_t_gen_utility_pvt.g_file is null THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csimtltxn',
        p_file_segment2 => p_mtl_txn_id);
    END IF;

    get_mmt_rec(
      p_mtl_txn_id => p_mtl_txn_id,
      x_mmt_rec    => l_mmt_rec);

    dump_mmt_rec(
      p_mmt_rec    => l_mmt_rec);

    IF l_mmt_rec.status = 'ERROR' THEN
      l_error_flag := 'Y';
    ELSE
      l_error_flag := 'N';
    END IF;

    get_mut_tbl(
      p_mtl_txn_id => p_mtl_txn_id,
      p_error_flag => l_error_flag,
      x_mut_tbl    => l_mut_tbl);

    dump_mut_tbl(l_mut_tbl);

    IF l_mut_tbl.count > 0 THEN

      blank_line;
      add('Serial Transactions :-');
      add('-------------------');

      FOR l_ind IN l_mut_tbl.FIRST .. l_mut_tbl.LAST
      LOOP

        serial_status(
          p_serial_number   => l_mut_tbl(l_ind).serial_number,
          p_item_id         => l_mut_tbl(l_ind).item_id,
          p_standalone_mode => 'N');

      END LOOP;
    END IF;

  END txn_status;

  PROCEDURE get_job_rec(
    p_wip_entity_name    IN  varchar2,
    p_organization_id    IN  number,
    x_job_rec            OUT nocopy job_rec)
  IS
    l_job_rec            job_rec;
  BEGIN

    l_job_rec.wip_entity_name := p_wip_entity_name;

    SELECT wip_entity_id,
           entity_type,
           organization_id
    INTO   l_job_rec.wip_entity_id,
           l_job_rec.wip_entity_type,
           l_job_rec.organization_id
    FROM   wip_entities
    WHERE  wip_entity_name = p_wip_entity_name
    AND    organization_id = p_organization_id;

    BEGIN
      IF l_job_rec.wip_entity_type = 4 THEN  -- flow schedules
        SELECT primary_item_id,
               quantity_completed,
               quantity_completed,
               status
        INTO   l_job_rec.primary_item_id,
               l_job_rec.start_qty, -- wo less case compl qty is job qty
               l_job_rec.qty_completed,
               l_job_rec.wip_job_status
        FROM   wip_flow_schedules
        WHERE  wip_entity_id   = l_job_rec.wip_entity_id
        AND    organization_id = l_job_rec.organization_id;
      ELSE -- discrete jobs
        SELECT primary_item_id,
               start_quantity,
               quantity_completed,
               job_type,
               status_type,
               nvl(maintenance_object_source, 0),
               source_code,
               source_line_id
        INTO   l_job_rec.primary_item_id,
               l_job_rec.start_qty,
               l_job_rec.qty_completed,
               l_job_rec.wip_entity_type,
               l_job_rec.wip_job_status,
               l_job_rec.maint_obj_source,
               l_job_rec.source_code,
               l_job_rec.source_line_id
        FROM   wip_discrete_jobs
        WHERE  wip_entity_id   = l_job_rec.wip_entity_id
        AND    organization_id = l_job_rec.organization_id;
      END  IF;
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;
    x_job_rec := l_job_rec;
  END get_job_rec;

  PROCEDURE dump_job_rec(
    p_job_rec            IN job_rec)
  IS
    l_out varchar2(2000);
  BEGIN

    blank_line;
    add('Job Name   : '||p_job_rec.wip_entity_name);
    blank_line;

    l_out := fill('WipEntityID',14)||
             fill('Type', 6)||
             fill('Status',8)||
             fill('ItemID', 14)||
             fill('Org', 4)||
             fill('JobQty', 10)||
             fill('ComplQty',10);
    add(l_out);

    l_out := fill('-----------',14)||
             fill('----', 6)||
             fill('------',8)||
             fill('------', 14)||
             fill('---', 4)||
             fill('------', 10)||
             fill('--------',10);
    add(l_out);

    l_out := fill(p_job_rec.wip_entity_id,14)||
             fill(p_job_rec.wip_entity_type, 6)||
             fill(p_job_rec.wip_job_status,8)||
             fill(p_job_rec.primary_item_id, 14)||
             fill(p_job_rec.organization_id, 4)||
             fill(p_job_rec.start_qty, 10)||
             fill(p_job_rec.qty_completed,10);
    add(l_out);

  END dump_job_rec;

  PROCEDURE get_wip_req_tbl(
    p_wip_entity_id      IN number,
    p_organization_id    IN number,
    x_wip_req_tbl        OUT nocopy wip_req_tbl)
  IS
    l_wip_req_tbl        wip_req_tbl;
    l_ind                binary_integer := 0;
    l_item_rec           item_rec;
    l_ib_ind             char;
    CURSOR req_cur IS
      SELECT segment1,
             inventory_item_id,
             organization_id,
             operation_seq_num,
             component_sequence_id,
             quantity_per_assembly,
             required_quantity,
             quantity_issued,
             wip_supply_type,
             supply_subinventory
      FROM   wip_requirement_operations
      WHERE  wip_entity_id   = p_wip_entity_id
      AND    organization_id = p_organization_id
      ORDER  BY operation_seq_num, component_sequence_id;
  BEGIN
    FOR req_rec IN req_cur
    LOOP

      l_ind := req_cur%rowcount;

      get_item_rec(
        p_item_id         => req_rec.inventory_item_id,
        p_organization_id => req_rec.organization_id,
        x_item_rec        => l_item_rec);

      SELECT decode(l_item_rec.ib_trackable_flag, 'Y', '*', ' ')
      INTO   l_ib_ind
      FROM   sys.dual;

      l_wip_req_tbl(l_ind).comp_item        := l_ib_ind||req_rec.segment1;
      l_wip_req_tbl(l_ind).comp_item_id     := req_rec.inventory_item_id;
      l_wip_req_tbl(l_ind).oper_seq_num     := req_rec.operation_seq_num;
      l_wip_req_tbl(l_ind).comp_seq_id      := req_rec.component_sequence_id;
      l_wip_req_tbl(l_ind).qty_per_assy     := req_rec.quantity_per_assembly;
      l_wip_req_tbl(l_ind).required_qty     := req_rec.required_quantity;
      l_wip_req_tbl(l_ind).qty_issued       := req_rec.quantity_issued;
      l_wip_req_tbl(l_ind).wip_supply_type  := req_rec.wip_supply_type;
      l_wip_req_tbl(l_ind).supply_subinv    := req_rec.supply_subinventory;
      l_wip_req_tbl(l_ind).primary_uom_code := l_item_rec.primary_uom_code;
      l_wip_req_tbl(l_ind).serial_code      := l_item_rec.serial_code;
      l_wip_req_tbl(l_ind).lot_code         := l_item_rec.lot_code;

    END LOOP;

    x_wip_req_tbl := l_wip_req_tbl;

  END get_wip_req_tbl;

  PROCEDURE dump_wip_req_tbl(
    p_wip_req_tbl        IN wip_req_tbl)
  IS
    l_out varchar2(2000);
  BEGIN

    blank_line;

    IF p_wip_req_tbl.count > 0 THEN

      add('WIP Material Requirements :-');
      blank_line;

      l_out := '  '||fill('CompItem',19)||
               fill('ItemID', 12)||
               fill('Oper', 5)||
               fill('QPA',10)||
               fill('Required', 10)||
               fill('Issued', 10)||
               fill('SType', 8)||
               fill('SrlCtrl', 8)||
               fill('LotCtrl', 8);
      add(l_out);

      l_out := '  '||fill('---------',19)||
               fill('-------', 12)||
               fill('----', 5)||
               fill('---',10)||
               fill('--------', 10)||
               fill('------', 10)||
               fill('-----', 8)||
               fill('-------', 8)||
               fill('-------', 8);
      add(l_out);

      FOR l_ind IN p_wip_req_tbl.FIRST .. p_wip_req_tbl.LAST
      LOOP
        l_out := ' '||fill(p_wip_req_tbl(l_ind).comp_item,20)||
                 fill(p_wip_req_tbl(l_ind).comp_item_id, 12)||
                 fill(p_wip_req_tbl(l_ind).oper_seq_num, 5)||
                 fill(p_wip_req_tbl(l_ind).qty_per_assy,10)||
                 fill(p_wip_req_tbl(l_ind).required_qty, 10)||
                 fill(p_wip_req_tbl(l_ind).qty_issued, 10)||
                 fill(p_wip_req_tbl(l_ind).wip_supply_type, 8)||
                 fill(p_wip_req_tbl(l_ind).serial_code, 8)||
                 fill(p_wip_req_tbl(l_ind).lot_code, 8);
        add(l_out);

      END LOOP;

    END IF;

  END dump_wip_req_tbl;

  PROCEDURE get_wip_mmt_tbl(
    p_wip_entity_id      IN number,
    p_organization_id    IN number,
    x_wip_mmt_tbl        OUT nocopy mmt_tbl)
  IS
    l_mmt_tbl        mmt_tbl;
    l_mmt_rec        mmt_rec;
    mmt_ind          binary_integer := 0;

    CURSOR wip_txn_cur(p_wip_entity_id IN number, p_organization_id IN number) IS
      SELECT mmt.transaction_id
      FROM   mtl_material_transactions mmt,
             mtl_system_items msi
      WHERE  mmt.transaction_source_type_id = 5
      AND    mmt.organization_id            = p_organization_id
      AND    mmt.transaction_source_id      = p_wip_entity_id
      AND    msi.inventory_item_id          = mmt.inventory_item_id
      AND    msi.organization_id            = mmt.organization_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y'
      ORDER  BY transaction_date desc;

  BEGIN

    FOR wip_txn_rec IN wip_txn_cur(p_wip_entity_id, p_organization_id)
    LOOP

      get_mmt_rec(
        p_mtl_txn_id => wip_txn_rec.transaction_id,
        x_mmt_rec    => l_mmt_rec);

      mmt_ind := mmt_ind + 1;
      l_mmt_tbl(mmt_ind) := l_mmt_rec;

    END LOOP;

    x_wip_mmt_tbl := l_mmt_tbl;

  END get_wip_mmt_tbl;

  PROCEDURE dump_wip_mmt_tbl(
    p_wip_mmt_tbl  IN mmt_tbl)
  IS
    l_mut_tbl         mut_tbl;
  BEGIN

    IF p_wip_mmt_tbl.COUNT > 0 THEN

      blank_line;
      add('WIP Material Transactions :-');

      FOR p_ind IN p_wip_mmt_tbl.FIRST .. p_wip_mmt_tbl.LAST
      LOOP

        dump_mmt_rec(p_wip_mmt_tbl(p_ind));

        get_mut_tbl(
          p_mtl_txn_id => p_wip_mmt_tbl(p_ind).mtl_txn_id,
          x_mut_tbl    => l_mut_tbl);

        dump_mut_tbl(l_mut_tbl);
      END LOOP;
    END IF;

  END dump_wip_mmt_tbl;

  PROCEDURE serial_status(
    p_serial_number      IN varchar2,
    p_item_id            IN number,
    p_standalone_mode    IN varchar2)
  IS
    l_out                  varchar2(2000);
    l_srl_mmt_tbl          mmt_tbl;
    l_current_status       number;
    l_current_org_id       number;
    l_gen_object_id        number;
    l_parent_serial_number varchar2(80);
    l_parent_item_id       number;

    l_instance_id          number;
    l_instance_number      varchar2(30);

  CURSOR parent_srl_cur(p_gen_object_id in number) IS
    SELECT msn.serial_number,
           msn.inventory_item_id
    FROM   mtl_object_genealogy mog,
           mtl_serial_numbers   msn
    WHERE  mog.object_type        = 2  -- serial genealogy
    AND    mog.object_id          = p_gen_object_id
    AND    mog.parent_object_type = 2  -- serial genealogy
    AND    msn.gen_object_id      = mog.parent_object_id
    AND    sysdate BETWEEN nvl(mog.start_date_active, sysdate-1)
                   AND     nvl(mog.end_date_active,   sysdate+1);
  BEGIN

    IF csi_t_gen_utility_pvt.g_file is null THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csisrl',
        p_file_segment2 => p_serial_number);
    END IF;

    blank_line;
    l_out := fill('Serial#', 15)||
             fill('ItemID', 9)||
             fill('Stat', 5)||
             fill('CurrOrg', 8)||
             fill('GObjID', 7)||
             fill('PSerial#',15)||
             fill('InstNum',10);
    add(l_out);

    l_out := fill('-------', 15)||
             fill('------', 9)||
             fill('----', 5)||
             fill('-------', 8)||
             fill('------', 7)||
             fill('--------',15)||
             fill('-------',10);
    add(l_out);

    SELECT current_status,
           current_organization_id,
           gen_object_id
    INTO   l_current_status,
           l_current_org_id,
           l_gen_object_id
    FROM   mtl_serial_numbers
    WHERE  serial_number     = p_serial_number
    AND    inventory_item_id = p_item_id;

    FOR parent_srl_rec IN parent_srl_cur(l_gen_object_id)
    LOOP
      IF parent_srl_cur%rowcount = 1 THEN
        l_parent_serial_number := parent_srl_rec.serial_number;
        l_parent_item_id       := parent_srl_rec.inventory_item_id;
      ELSE
        l_parent_serial_number := '*Multiple*';
      END IF;
    END LOOP;

    BEGIN
      SELECT instance_id,
             instance_number
      INTO   l_instance_id,
             l_instance_number
      FROM   csi_item_instances
      WHERE  inventory_item_id = p_item_id
      AND    serial_number     = p_serial_number;
      IF p_standalone_mode = 'Y' THEN
        cache_instance_id(l_instance_id);
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        l_instance_id     := null;
        l_instance_number := '*None*';
      WHEN too_many_rows THEN
        l_instance_id     := null;
        l_instance_number := '*Multiple*';
    END;

    l_out := fill(p_serial_number, 15)||
             fill(p_item_id, 9)||
             fill(l_current_status, 5)||
             fill(l_current_org_id, 8)||
             fill(l_gen_object_id, 7)||
             fill(l_parent_serial_number,15)||
             fill(l_instance_number, 10);
    add(l_out);

    get_srl_mmt_tbl(
      p_serial_number => p_serial_number,
      p_item_id       => p_item_id,
      x_mmt_tbl       => l_srl_mmt_tbl);

    IF l_srl_mmt_tbl.COUNT > 0 THEN
      FOR srl_mmt_ind IN l_srl_mmt_tbl.FIRST .. l_srl_mmt_tbl.LAST
      LOOP
        dump_mmt_rec(
          p_mmt_rec    => l_srl_mmt_tbl(srl_mmt_ind),
          p_index      => srl_mmt_ind);
      END LOOP;
    END IF;

    IF p_standalone_mode = 'Y' THEN
      IF l_instance_id is not null THEN
        blank_line;
        add('Instance Details :-');
        add('---------------- :-');
        blank_line;
        instance_status(
          p_instance_id     => l_instance_id,
          p_standalone_mode => 'N');
      END IF;
    END IF;

  EXCEPTION
    WHEN others THEN
      add('  other error : '||substr(sqlerrm, 1, 255));
  END serial_status;

  PROCEDURE dump_fulfill_transactions(
    p_order_lines        IN order_lines)
  IS

    l_out                varchar2(2000);
    l_processed          boolean := FALSE;
    l_print_header       boolean := TRUE;

    CURSOR csi_txn_cur(p_order_line_id IN number) IS
      SELECT transaction_id,
             transaction_type_id,
             transaction_date,
             source_header_ref_id,
             source_header_ref,
             source_line_ref
      FROM   csi_transactions
      WHERE  source_line_ref_id = p_order_line_id;

    CURSOR err_cur(p_order_line_id IN number) IS
      SELECT transaction_error_id,
             source_type,
             source_header_ref,
             error_text
      FROM   csi_txn_errors
      WHERE  source_id = p_order_line_id
      AND    processed_flag in ('E', 'R');

  BEGIN
    IF p_order_lines.COUNT > 0 THEN
      FOR l_ind IN p_order_lines.FIRST .. p_order_lines.LAST
      LOOP
        IF p_order_lines(l_ind).fulfilled_flag = 'Y' AND
           p_order_lines(l_ind).shipped_flag = 'N'
        THEN

          IF l_print_header THEN
            blank_line;
            blank_line;
            add('Fulfillment Transactions :-');
            add('------------------------');
            l_print_header := FALSE;
          END IF;

          blank_line;
          l_out := fill(p_order_lines(l_ind).line_number, 9)||
                   fill(p_order_lines(l_ind).line_id, 9)||
                   fill(p_order_lines(l_ind).identified_item_type, 14);
          add(l_out);
          l_processed := FALSE;
          FOR csi_txn_rec IN csi_txn_cur(p_order_lines(l_ind).line_id)
          LOOP
            l_processed := TRUE;
            IF csi_txn_cur%rowcount = 1 THEN
              l_out := '  '||fill('csi_txn_id', 11)||
                             fill('csi_txn_type_id', 16)||
                             fill('csi_txn_date', 19)||
                             fill('src_hdr_ref', 12);
              add(l_out);
              l_out := '  '||fill('----------', 11)||
                             fill('---------------', 16)||
                             fill('------------', 19)||
                             fill('-----------', 12);
              add(l_out);
            END IF;
            l_out := '  '||fill(csi_txn_rec.transaction_id, 11)||
                           fill(csi_txn_rec.transaction_type_id, 16)||
                           fill(to_char(csi_txn_rec.transaction_date, 'MM/DD/YY HH24:MI:SS'), 19)||
                           fill(csi_txn_rec.source_header_ref, 12);
            add(l_out);
          END LOOP;

          --IF NOT (l_processed)  THEN
          FOR err_rec IN err_cur(p_order_lines(l_ind).line_id)
          LOOP
            IF err_cur%rowcount = 1 THEN
              l_out := '  '||fill('txn_error_id', 13)||
                             fill('source_type', 12)||
                             fill('error_text', 75);
              add(l_out);
              l_out := '  '||fill('------------', 13)||
                             fill('-----------', 12)||
                             fill('----------', 75);
              add(l_out);
            END IF;
            l_out := '  '||fill(err_rec.transaction_error_id, 13)||
                           fill(err_rec.source_type, 12)||
                           fill(err_rec.error_text, 75);
            add(l_out);
          END LOOP;
          --END IF;

        END IF;
      END LOOP;
    END IF;
  END dump_fulfill_transactions;

  PROCEDURE dump_shipping_transactions(
    p_order_lines        IN order_lines)
  IS

    l_mmt_rec            mmt_rec;
    l_mmt_tbl            mmt_tbl;
    l_mut_tbl            mut_tbl;
    l_all_mut_tbl        mut_tbl;
    l_srl_mmt_tbl        mmt_tbl;

    all_mut_ind          binary_integer := 0;
    mmt_ind              binary_integer := 0;
    l_out                varchar2(2000);
    l_print_header       boolean := TRUE;
    l_error_flag         varchar2(1);

    CURSOR ship_txn_cur(p_line_id IN number, p_item_id IN number) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_source_type_id = 2
      AND    transaction_action_id      = 1
      AND    inventory_item_id          = p_item_id
      AND    trx_source_line_id         = p_line_id
      ORDER BY transaction_id desc;

  BEGIN

    IF p_order_lines.COUNT > 0 THEN
      FOR l_ind IN p_order_lines.FIRST .. p_order_lines.LAST
      LOOP

        IF p_order_lines(l_ind).shipped_flag = 'Y' THEN

          FOR ship_txn_rec IN ship_txn_cur(p_order_lines(l_ind).line_id, p_order_lines(l_ind).item_id)
          LOOP

            IF l_print_header THEN
              blank_line;
              blank_line;
              add('Shipping Transactions :-');
              add('---------------------');
              l_print_header := FALSE;
            END IF;

            IF ship_txn_cur%rowcount = 1 THEN
              blank_line;
              l_out := fill(p_order_lines(l_ind).line_number, 9)||
                       fill(p_order_lines(l_ind).line_id, 9)||
                       fill(p_order_lines(l_ind).identified_item_type, 14);
              add(l_out);
            END IF;

            get_mmt_rec(
              p_mtl_txn_id => ship_txn_rec.transaction_id,
              x_mmt_rec    => l_mmt_rec);

            dump_mmt_rec(l_mmt_rec);

            IF l_mmt_rec.status = 'ERROR' THEN
              l_error_flag := 'Y';
            ELSE
              l_error_flag := 'N';
            END IF;

            get_mut_tbl(
              p_mtl_txn_id => ship_txn_rec.transaction_id,
              p_error_flag => l_error_flag,
              x_mut_tbl    => l_mut_tbl);

            dump_mut_tbl(l_mut_tbl);

            mmt_ind := mmt_ind + 1;
            l_mmt_tbl(mmt_ind) := l_mmt_rec;

            IF l_mmt_rec.status = 'ERROR' THEN
              IF l_mut_tbl.COUNT > 0 THEN
                FOR mut_ind IN l_mut_tbl.FIRST..l_mut_tbl.LAST
                LOOP
                  all_mut_ind := all_mut_ind + 1;
                  l_all_mut_tbl(all_mut_ind) := l_mut_tbl(mut_ind);
                END LOOP;
              END IF;
            END IF;

          END LOOP;

        END IF;

      END LOOP;

      l_print_header := TRUE;
      IF l_all_mut_tbl.COUNT > 0 THEN
        FOR l_ind IN l_all_mut_tbl.FIRST .. l_all_mut_tbl.LAST
        LOOP

          IF l_print_header THEN
            blank_line;
            blank_line;
            add('Serial Transactions :-');
            add('-------------------');
            l_print_header := FALSE;
          END IF;

          serial_status(
            p_serial_number   => l_all_mut_tbl(l_ind).serial_number,
            p_item_id         => l_all_mut_tbl(l_ind).item_id,
            p_standalone_mode => 'N');
        END LOOP;
      END IF;

    END IF;

  END dump_shipping_transactions;

  PROCEDURE get_item_type(
    p_item_type_code    IN varchar2,
    p_line_id           IN number,
    p_ato_line_id       IN number,
    p_top_model_line_id IN number,
    x_item_type            OUT nocopy varchar2)
  IS
    l_sub_model_flag    varchar2(1);
  BEGIN

    IF p_item_type_code = 'MODEL' THEN
      IF p_ato_line_id = p_line_id THEN
        x_item_type := 'ATO_MODEL';
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_MODEL';
      END IF;
    ELSIF p_item_type_code = 'KIT' THEN
      x_item_type := 'KIT';
    ELSIF p_item_type_code = 'OPTION' THEN
      IF p_ato_line_id is not null THEN
        x_item_type := 'ATO_OPTION';
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_OPTION';
      END IF;
    ELSIF p_item_type_code = 'CLASS' THEN
      IF p_ato_line_id is not null THEN
        BEGIN
          SELECT 'Y'
          INTO   l_sub_model_flag
          FROM   sys.dual
          WHERE  exists (
            SELECT 'X'
            FROM   bom_cto_order_lines
            WHERE  ato_line_id = p_ato_line_id
            AND    parent_ato_line_id = p_line_id);
          x_item_type := 'ATO_SUB_MODEL';
        EXCEPTION
          WHEN no_data_found THEN
            x_item_type := 'ATO_CLASS';
        END;
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_CLASS';
      END IF;
    ELSIF p_item_type_code = 'INCLUDED' THEN
      x_item_type := 'INCLUDED_ITEM';
    ELSIF p_item_type_code = 'CONFIG' THEN
      x_item_type := 'CONFIG_ITEM';
    ELSIF p_item_type_code = 'STANDARD' THEN
      x_item_type := 'STANDARD';
    END IF;
  END get_item_type;

  PROCEDURE dump_item_rec(
    p_item_rec           IN item_rec)
  IS
    l_out  varchar2(2000);
  BEGIN
    blank_line;

    l_out := '  '||fill('item', 22)||': '||p_item_rec.item;
    add(l_out);

    l_out := '  '||fill('item_id',22)||': '||fill(p_item_rec.item_id, 20)||
                   fill('organization_id', 22)||': '||fill(p_item_rec.organization_id, 25);

    add(l_out);

    l_out := '  '||fill('ib_trackable_flag', 22)||': '||fill(p_item_rec.ib_trackable_flag, 20)||
                   fill('srl_control_code', 22)||': '||fill(p_item_rec.serial_code, 20);
    add(l_out);

    l_out := '  '||fill('shippable_flag', 22)||': '||fill(p_item_rec.shippable_flag, 20)||
             fill('lot_control_code', 22)||': '||fill(p_item_rec.lot_code, 20);
    add(l_out);

    l_out := '  '||fill('returnable_flag', 22)||': '||fill(p_item_rec.returnable_flag, 20)||
             fill('rev_control_code',22)||': '||fill(p_item_rec.revision_code, 20);
    add(l_out);

    l_out := '  '||fill('pick_component_flag', 22)||': '||fill(p_item_rec.pick_flag, 20)||
             fill('loc_control_code', 22)||': '||fill(p_item_rec.locator_code, 20);
    add(l_out);

    l_out := '  '||fill('inv_transactable_flag', 22)||': '||fill(p_item_rec.inv_transactable_flag, 20)||
                   fill('primary_uom_code', 22)||': '||fill(p_item_rec.primary_uom_code, 20);
    add(l_out);

    l_out := '  '||fill('bom_item_type', 22)||': '||fill(p_item_rec.bom_item_type, 20)||
                   fill('wip_supply_type', 22)||': '||fill(p_item_rec.wip_supply_type, 20);

    add(l_out);
    l_out := '  '||fill('plan_make_buy_code', 22)||': '||fill(p_item_rec.make_buy_code, 20)||
                   fill('reservable_type', 22)||': '||fill(p_item_rec.reservable_type, 20);
    add(l_out);

  END dump_item_rec;

  PROCEDURE dump_item_info_for_order(
    p_order_lines        IN order_lines)
  IS
    l_item_rec           item_rec;
    l_out                varchar2(2000);
  BEGIN
    IF p_order_lines.COUNT > 0 THEN
      blank_line;
      add('Item details for Order :-');
      add('----------------------');
      FOR l_ind IN p_order_lines.FIRST .. p_order_lines.LAST
      LOOP

        blank_line;
        l_out := fill(p_order_lines(l_ind).line_number, 9)||
                 fill(p_order_lines(l_ind).line_id, 9)||
                 fill(p_order_lines(l_ind).identified_item_type, 14);
        add(l_out);

        get_item_rec(
          p_item_id         => p_order_lines(l_ind).item_id,
          p_organization_id => p_order_lines(l_ind).ship_from_org_id,
          x_item_rec        => l_item_rec);

        dump_item_rec(
          p_item_rec        => l_item_rec);

      END LOOP;
    END IF;
  END dump_item_info_for_order;

  PROCEDURE dump_order_details(
    p_order_lines        IN order_lines)
  IS
    l_item_rec           item_rec;
  BEGIN

    IF p_order_lines.COUNT > 0 THEN
      blank_line;
      add('Order Details :-');
      add('----------------');
      FOR l_ind IN p_order_lines.FIRST .. p_order_lines.LAST
      LOOP

        dump_order_detail(p_order_lines(l_ind));

        get_item_rec(
          p_item_id         => p_order_lines(l_ind).item_id,
          p_organization_id => p_order_lines(l_ind).ship_from_org_id,
          x_item_rec        => l_item_rec);

        dump_item_rec(
          p_item_rec        => l_item_rec);

      END LOOP;
    END IF;
  END dump_order_details;

  PROCEDURE get_ato_models(
    p_order_lines        IN order_lines,
    x_ato_model_tbl      OUT nocopy ato_model_tbl)
  IS
    l_ind                binary_integer := 0;
    l_ato_model_tbl      ato_model_tbl;
    l_check_in_cto_table boolean := FALSE;
    l_config_item_id     number;
    l_request_id         number;

    CURSOR wdj_cur(
      p_line_id         IN number,
      p_item_id         IN number,
      p_organization_id IN number)
    IS
      SELECT wip_entity_id,
             organization_id,
             request_id
      FROM   wip_discrete_jobs
      WHERE  primary_item_id = p_item_id
      AND    organization_id = p_organization_id
      AND    source_line_id  = p_line_id
      AND    status_type     <> 7  -- excluding the cancelled wip jobs
      ORDER  by wip_entity_id desc;

    CURSOR wdj_sub_cur(
      p_item_id         IN number,
      p_organization_id IN number,
      p_request_id      IN number)
    IS
      SELECT wip_entity_id,
             organization_id,
             request_id
      FROM   wip_discrete_jobs
      WHERE  primary_item_id = p_item_id
      AND    organization_id = p_organization_id
      AND    request_id      = p_request_id
      AND    status_type     <> 7  -- excluding the cancelled wip jobs
      ORDER  by wip_entity_id desc;

  BEGIN
    IF p_order_lines.COUNT > 0 THEN
      FOR p_ind IN p_order_lines.FIRST .. p_order_lines.LAST
      LOOP
        IF p_order_lines(p_ind).identified_item_type in ('ATO_MODEL', 'ATO_SUB_MODEL') THEN

          l_ind := l_ind + 1;

          l_ato_model_tbl(l_ind).model_line_id  := p_order_lines(p_ind).line_id;
          l_ato_model_tbl(l_ind).model_item_id  := p_order_lines(p_ind).item_id;

          l_check_in_cto_table := FALSE;

          IF p_order_lines(p_ind).identified_item_type = 'ATO_MODEL' THEN
            l_ato_model_tbl(l_ind).sub_model_flag := 'N';
            BEGIN
              SELECT line_id,
                     inventory_item_id
              INTO   l_ato_model_tbl(l_ind).config_line_id,
                     l_ato_model_tbl(l_ind).config_item_id
              FROM   oe_order_lines_all
              WHERE  header_id       = p_order_lines(p_ind).header_id
              AND    link_to_line_id = p_order_lines(p_ind).ato_line_id
              AND    item_type_code  = 'CONFIG';
            EXCEPTION
              WHEN no_data_found THEN
                l_check_in_cto_table := TRUE;
              WHEN too_many_rows THEN
                BEGIN
                  SELECT line_id,
                         inventory_item_id
                  INTO   l_ato_model_tbl(l_ind).config_line_id,
                         l_ato_model_tbl(l_ind).config_item_id
                  FROM   oe_order_lines_all
                  WHERE  header_id       = p_order_lines(p_ind).header_id
                  AND    link_to_line_id = p_order_lines(p_ind).ato_line_id
                  AND    item_type_code  = 'CONFIG'
                  AND    split_from_line_id is null;
                EXCEPTION
                  WHEN others THEN
                    l_check_in_cto_table := TRUE;
                END;
            END;
          ELSE
            l_check_in_cto_table := TRUE;
            l_ato_model_tbl(l_ind).sub_model_flag := 'Y';
            l_ato_model_tbl(l_ind).config_line_id := null;
          END IF;

          SELECT wip_supply_type,
                 parent_ato_line_id,
                 config_item_id
          INTO   l_ato_model_tbl(l_ind).wip_supply_type,
                 l_ato_model_tbl(l_ind).parent_ato_line_id,
                 l_config_item_id
          FROM   bom_cto_order_lines
          WHERE  line_id     =  p_order_lines(p_ind).line_id;

          l_ato_model_tbl(l_ind).config_item_id := l_config_item_id;

          IF l_ato_model_tbl(l_ind).wip_supply_type = 6 OR
             l_ato_model_tbl(l_ind).config_line_id is null
          THEN
             l_ato_model_tbl(l_ind).phantom_flag := 'Y';
          ELSE
             l_ato_model_tbl(l_ind).phantom_flag := 'N';
          END IF;

          IF l_ato_model_tbl(l_ind).phantom_flag = 'N' THEN
            FOR wdj_rec IN wdj_cur(
              p_line_id         => l_ato_model_tbl(l_ind).config_line_id,
              p_item_id         => l_ato_model_tbl(l_ind).config_item_id,
              p_organization_id => p_order_lines(p_ind).ship_from_org_id)
            LOOP
              l_ato_model_tbl(l_ind).wip_entity_id   := wdj_rec.wip_entity_id;
              l_ato_model_tbl(l_ind).organization_id := wdj_rec.organization_id;
              l_request_id := wdj_rec.request_id;
              exit;
            END LOOP;

          ELSE
            IF l_request_id IS not null THEN
              FOR wdj_sub_rec IN wdj_sub_cur(
                p_item_id         => l_ato_model_tbl(l_ind).config_item_id,
                p_organization_id => p_order_lines(p_ind).ship_from_org_id,
                p_request_id      => l_request_id)
              LOOP
                l_ato_model_tbl(l_ind).wip_entity_id   := wdj_sub_rec.wip_entity_id;
                l_ato_model_tbl(l_ind).organization_id := wdj_sub_rec.organization_id;
                exit;
              END LOOP;
            END IF;
          END IF;

          IF l_ato_model_tbl(l_ind).wip_entity_id is not null THEN
            SELECT wip_entity_name
            INTO   l_ato_model_tbl(l_ind).wip_entity_name
            FROM   wip_entities
            WHERE  wip_entity_id = l_ato_model_tbl(l_ind).wip_entity_id;
          END IF;

        END IF;
      END LOOP;
    END IF;
    x_ato_model_tbl := l_ato_model_tbl;
  END get_ato_models;

  PROCEDURE dump_ato_models(
    p_order_lines        IN order_lines)
  IS
    l_ato_model_tbl      ato_model_tbl;
    l_out                varchar2(2000);
  BEGIN

    IF p_order_lines.COUNT > 0 THEN
      get_ato_models(
        p_order_lines   => p_order_lines,
        x_ato_model_tbl => l_ato_model_tbl);

      IF l_ato_model_tbl.COUNT > 0 THEN
        blank_line;
        add('ATO Model Information :-');
        blank_line;
        l_out := fill('ato_line_id', 12)||
                 fill('ato_item_id', 12)||
                 fill('con_line_id', 12)||
                 fill('con_item_id', 12)||
                 fill('wip_job_id', 12)||
                 fill('wip_job_name', 20);
        add(l_out);
        l_out := fill('-----------', 12)||
                 fill('-----------', 12)||
                 fill('-----------', 12)||
                 fill('-----------', 12)||
                 fill('----------', 12)||
                 fill('------------', 20);
        add(l_out);
        FOR l_ind IN l_ato_model_tbl.FIRST .. l_ato_model_tbl.LAST
        LOOP

          l_out := fill(l_ato_model_tbl(l_ind).model_line_id, 12)||
                   fill(l_ato_model_tbl(l_ind).model_item_id, 12)||
                   fill(l_ato_model_tbl(l_ind).config_line_id, 12)||
                   fill(l_ato_model_tbl(l_ind).config_item_id, 12)||
                   fill(l_ato_model_tbl(l_ind).wip_entity_id, 12)||
                   fill(l_ato_model_tbl(l_ind).wip_entity_name, 20);
          add(l_out);

        END LOOP;

        FOR l_ind IN l_ato_model_tbl.FIRST .. l_ato_model_tbl.LAST
        LOOP
          IF l_ato_model_tbl(l_ind).wip_entity_name is not null THEN
            job_status(
              p_job_name        => l_ato_model_tbl(l_ind).wip_entity_name,
              p_organization_id => l_ato_model_tbl(l_ind).organization_id);
          END IF;
        END LOOP;

      END IF;

    END IF;

  END dump_ato_models;

  PROCEDURE dump_install_parameters IS
    l_out varchar2(2000);
    CURSOR param_cur IS
      SELECT internal_party_id,
             project_location_id,
             wip_location_id,
             in_transit_location_id,
             po_location_id,
             category_set_id,
             freeze_flag,
             freeze_date,
             show_all_party_location,
             ownership_override_at_txn,
             sfm_queue_bypass_flag,
             auto_allocate_comp_at_wip,
             to_date(null) txn_seq_start_date,
             null ownership_cascade_at_txn
      FROM   csi_install_parameters;
  BEGIN

    blank_line;
    blank_line;
    add('Install Parameters :-');
    add('------------------');
    blank_line;

    FOR param_rec IN param_cur
    LOOP
      l_out := '  '||fill('internal_party_id', 25)||': '||param_rec.internal_party_id;
      add(l_out);
      l_out := '  '||fill('project_location_id', 25)||': '||param_rec.project_location_id;
      add(l_out);
      l_out := '  '||fill('wip_location_id', 25)||': '||param_rec.wip_location_id;
      add(l_out);
      l_out := '  '||fill('in_transit_location_id', 25)||': '||param_rec.in_transit_location_id;
      add(l_out);
      l_out := '  '||fill('po_location_id', 25)||': '||param_rec.po_location_id;
      add(l_out);
      l_out := '  '||fill('category_set_id', 25)||': '||param_rec.category_set_id;
      add(l_out);
      l_out := '  '||fill('freeze_flag', 25)||': '||param_rec.freeze_flag;
      add(l_out);
      l_out := '  '||fill('freeze_date', 25)||': '||
                     to_char(param_rec.freeze_date, 'DD-MON-YYYY HH24:MI:SS');
      add(l_out);
      l_out := '  '||fill('show_all_party_location', 25)||': '||param_rec.show_all_party_location;
      add(l_out);
      l_out := '  '||fill('ownership_override_at_txn', 25)||': '||param_rec.ownership_override_at_txn;
      add(l_out);
      l_out := '  '||fill('sfm_queue_bypass_flag', 25)||': '||param_rec.sfm_queue_bypass_flag;
      add(l_out);
      l_out := '  '||fill('auto_allocate_comp_at_wip', 25)||': '||param_rec.auto_allocate_comp_at_wip;
      add(l_out);
      l_out := '  '||fill('txn_seq_start_date', 25)||': '||
                     to_char(param_rec.txn_seq_start_date, 'DD-MON-YYYY HH24:MI:SS');
      add(l_out);
      l_out := '  '||fill('ownership_cascade_at_txn', 25)||': '||param_rec.ownership_cascade_at_txn;
      add(l_out);
    END LOOP;
  END dump_install_parameters;

  PROCEDURE get_order_lines(
    p_order_number       IN number,
    x_order_lines        OUT nocopy order_lines)
  IS

    l_order_lines         order_lines;
    l_ind                 binary_integer;
    l_message             varchar2(2000);
    l_line_header         varchar2(2000);
    l_item_rec            item_rec;
    l_macd_processing     boolean := FALSE;
    l_om_session_key      csi_utility_grp.config_session_key;
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR order_cur(p_order_number IN number) IS
      SELECT oeh.header_id,
             oel.line_id,
             oel.inventory_item_id,
             oel.ordered_quantity,
             oel.order_quantity_uom,
             oel.ordered_item,
             oel.item_revision,
             oel.line_number||'.'||nvl(oel.option_number,0)||'.'||oel.shipment_number line_number,
             nvl(oel.ship_from_org_id,oeh.ship_from_org_id) ship_from_org_id,
             nvl(oel.sold_to_org_id, oeh.sold_to_org_id)    sold_to_org_id,
             nvl(oel.deliver_to_org_id, oeh.deliver_to_org_id) deliver_to_org_id,
             nvl(oel.invoice_to_org_id, oeh.invoice_to_org_id) invoice_to_org_id,
             nvl(oel.ship_to_org_id, oeh.ship_to_org_id) ship_to_org_id,
             oel.fulfilled_quantity,
             oel.flow_status_code,
             oel.item_type_code,
             oel.link_to_line_id,
             oel.ato_line_id,
             oel.top_model_line_id,
             oel.sort_order,
             oel.org_id,
             oeh.order_type_id,
             oel.line_type_id,
             oel.ship_to_contact_id,
             oel.invoice_to_contact_id,
             oel.deliver_to_contact_id,
             nvl(oel.price_list_id, oeh.price_list_id) price_list_id,
             oel.unit_selling_price,
             oel.creation_date,
             oel.component_sequence_id,
             oel.line_category_code,
             oel.cancelled_flag,
             oel.source_type_code,
             oel.drop_ship_flag,
             nvl(oel.fulfilled_flag, 'N') fulfilled_flag,
             oel.configuration_id,
             oel.config_header_id,
             oel.config_rev_nbr,
             oel.shippable_flag,
             oel.fulfillment_date,
             oel.shipping_interfaced_flag,
             oel.split_from_line_id,
             oel.actual_shipment_date,
             oel.shipped_quantity
      FROM   oe_order_lines_all oel,
             oe_order_headers_all oeh
      WHERE  oeh.order_number = p_order_number
      AND    oel.header_id    = oeh.header_id
      ORDER  BY oel.line_number, oel.sort_order;


  BEGIN

    FOR order_rec in order_cur(p_order_number)
    LOOP

      l_ind := order_cur%rowcount;
      l_order_lines(l_ind).header_id         := order_rec.header_id;
      l_order_lines(l_ind).line_id           := order_rec.line_id;
      l_order_lines(l_ind).line_number       := order_rec.line_number;
      l_order_lines(l_ind).item_id           := order_rec.inventory_item_id;
      l_order_lines(l_ind).ship_from_org_id  := order_rec.ship_from_org_id;
      l_order_lines(l_ind).item_number       := order_rec.ordered_item;
      l_order_lines(l_ind).order_qty         := order_rec.ordered_quantity;
      l_order_lines(l_ind).order_uom         := order_rec.order_quantity_uom;
      l_order_lines(l_ind).line_status       := order_rec.flow_status_code;
      l_order_lines(l_ind).item_type         := order_rec.item_type_code;
      l_order_lines(l_ind).link_to_line_id   := order_rec.link_to_line_id;
      l_order_lines(l_ind).ato_line_id       := order_rec.ato_line_id;
      l_order_lines(l_ind).top_model_line_id := order_rec.top_model_line_id;
      l_order_lines(l_ind).sort_order        := order_rec.sort_order;

      l_order_lines(l_ind).level             := (length(order_rec.sort_order)/4) - 1;

      get_item_type(
        p_item_type_code    => order_rec.item_type_code,
        p_line_id           => order_rec.line_id,
        p_ato_line_id       => order_rec.ato_line_id,
        p_top_model_line_id => order_rec.top_model_line_id,
        x_item_type         => l_order_lines(l_ind).identified_item_type);

      get_item_rec(
        p_item_id         => order_rec.inventory_item_id,
        p_organization_id => order_rec.ship_from_org_id,
        x_item_rec        => l_item_rec);

      l_order_lines(l_ind).ib_trackable_flag := l_item_rec.ib_trackable_flag;
      l_order_lines(l_ind).shippable_flag    := l_item_rec.shippable_flag;


      l_order_lines(l_ind).org_id                 := order_rec.org_id;
      l_order_lines(l_ind).order_type_id          := order_rec.order_type_id;
      l_order_lines(l_ind).line_type_id           := order_rec.line_type_id;
      l_order_lines(l_ind).ship_to_contact_id     := order_rec.ship_to_contact_id;
      l_order_lines(l_ind).invoice_to_contact_id  := order_rec.invoice_to_contact_id;
      l_order_lines(l_ind).deliver_to_contact_id  := order_rec.deliver_to_contact_id;
      l_order_lines(l_ind).price_list_id          := order_rec.price_list_id;
      l_order_lines(l_ind).unit_selling_price     := order_rec.unit_selling_price;
      l_order_lines(l_ind).creation_date          := order_rec.creation_date;
      l_order_lines(l_ind).comp_seq_id            := order_rec.component_sequence_id;
      l_order_lines(l_ind).line_category_code     := order_rec.line_category_code;
      l_order_lines(l_ind).cancelled_flag         := order_rec.cancelled_flag;
      l_order_lines(l_ind).source_type_code       := order_rec.source_type_code;
      l_order_lines(l_ind).drop_ship_flag         := order_rec.drop_ship_flag;
      l_order_lines(l_ind).fulfilled_flag         := order_rec.fulfilled_flag;
      l_order_lines(l_ind).configuration_id       := order_rec.configuration_id;
      l_order_lines(l_ind).config_header_id       := order_rec.config_header_id;
      l_order_lines(l_ind).config_rev_nbr         := order_rec.config_rev_nbr;
      l_order_lines(l_ind).fulfillment_date       := order_rec.fulfillment_date;
      l_order_lines(l_ind).shipment_date          := order_rec.actual_shipment_date;
      l_order_lines(l_ind).shipped_flag           := order_rec.shipping_interfaced_flag;
      l_order_lines(l_ind).split_from_line_id     := order_rec.split_from_line_id;

      l_order_lines(l_ind).ship_to_org_id         := order_rec.ship_to_org_id;
      l_order_lines(l_ind).invoice_to_org_id      := order_rec.invoice_to_org_id;
      l_order_lines(l_ind).deliver_to_org_id      := order_rec.deliver_to_org_id;
      l_order_lines(l_ind).item_revision          := order_rec.item_revision;
      l_order_lines(l_ind).fulfilled_quantity     := order_rec.fulfilled_quantity;
      l_order_lines(l_ind).shipped_quantity       := order_rec.shipped_quantity;


    l_om_session_key.session_hdr_id  := order_rec.config_header_id;
    l_om_session_key.session_rev_num := order_rec.config_rev_nbr;
    l_om_session_key.session_item_id := order_rec.configuration_id;

    l_macd_processing := csi_interface_pkg.check_macd_processing(
                            p_config_session_key => l_om_session_key,
                            x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_macd_processing THEN
      l_order_lines(l_ind).macd_flag := 'Y';
    END IF;

    END LOOP;

    x_order_lines := l_order_lines;

  END get_order_lines;

  PROCEDURE dump_shipping_file_versions IS
    l_source_files csi_debug_pkg.source_files;
  BEGIN

    l_source_files(1).file_name := 'csipioss.pls';
    l_source_files(2).file_name := 'csipiosb.pls';
    l_source_files(3).file_name := 'csipiofs.pls';
    l_source_files(4).file_name := 'csipiofb.pls';
    l_source_files(5).file_name := 'csiutls.pls';
    l_source_files(6).file_name := 'csiutlb.pls';

    csi_debug_pkg.dump_file_versions(l_source_files);

  END dump_shipping_file_versions;

  PROCEDURE order_status(
    p_order_number IN number)
  IS
    l_order_lines      order_lines;
    l_all_order_lines  order_lines;
  BEGIN

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiorder',
      p_file_segment2 => p_order_number);

    get_order_lines(
      p_order_number => p_order_number,
      x_order_lines  => l_order_lines);

    IF l_order_lines.COUNT > 0 THEN

      dump_order_summary(
        p_order_number => p_order_number,
        px_order_lines => l_order_lines);

      dump_order_details(
        p_order_lines  => l_order_lines);

      dump_ato_models(
        p_order_lines   => l_order_lines);

      l_all_order_lines := l_order_lines;

      get_ib_trackable_lines(
        px_order_lines  => l_order_lines);

      dump_installation_details(
        p_order_lines   => l_order_lines,
        p_source_table  => 'OE_ORDER_LINES_ALL');

      dump_installation_details(
        p_order_lines   => l_order_lines,
        p_source_table  => 'WSH_DELIVERY_DETAILS');

      dump_shipping_transactions(
        p_order_lines   => l_order_lines);

      dump_fulfill_transactions(
        p_order_lines   => l_order_lines);

      /*
      IF l_inst_tbl_cache.count > 0 THEN
        blank_line;
        add('Instance Details :-');
        add('---------------- :-');
        FOR l_ind IN l_inst_tbl_cache.FIRST .. l_inst_tbl_cache.LAST
        LOOP
          blank_line;
          instance_status(
            p_instance_id     => l_inst_tbl_cache(l_ind).instance_id,
            p_standalone_mode => 'N');
        END LOOP;
      END IF;
      */

      dump_install_parameters;

      dump_shipping_file_versions;

    ELSE
      add('Order Number '||p_order_number||' is invalid.');
    END IF;

  END order_status;

  PROCEDURE rma_status(
    p_rma_number         IN number)
  IS
  BEGIN
    null;
  END rma_status;

  PROCEDURE instance_status(
    p_instance_id        IN number,
    p_standalone_mode    IN varchar2)
  IS

    CURSOR inst_cur(p_inst_id in number) IS
      SELECT instance_id,
             instance_number,
             inventory_item_id,
             serial_number,
             lot_number,
             location_type_code,
             location_id,
             instance_usage_code,
             last_oe_order_line_id,
             last_vld_organization_id,
             active_end_date
      FROM   csi_item_instances
      WHERE  instance_id = p_inst_id;

    CURSOR comp_cur(p_inst_id in number) IS
      SELECT iir.relationship_id,
             iir.subject_id,
             iir.relationship_type_code,
             iir.active_end_date rel_end_date,
             ii.serial_number,
             ii.location_type_code,
             ii.instance_usage_code,
             ii.active_end_date instance_end_date
      FROM   csi_ii_relationships iir,
             csi_item_instances ii
      WHERE  iir.object_id = p_inst_id
      AND    ii.instance_id = iir.subject_id;

    CURSOR txn_cur(p_inst_id IN number) IS
      SELECT ct.transaction_id,
             ct.transaction_type_id,
             to_char(ct.transaction_date, 'mm/dd/yy hh:mi:ss')        transaction_date,
             to_char(ct.source_transaction_date, 'mm/dd/yy hh:mi:ss') source_transaction_date,
             ctt.source_transaction_type,
             ct.inv_material_transaction_id
      FROM   csi_item_instances_h ciih,
             csi_transactions     ct,
             csi_txn_types        ctt
      WHERE  ciih.instance_id     = p_inst_id
      AND    ct.transaction_id    = ciih.transaction_id
      AND    ctt.transaction_type_id = ct.transaction_type_id
      ORDER  BY ct.source_transaction_date desc;

    l_out          varchar2(2000);

  BEGIN

    IF csi_t_gen_utility_pvt.g_file is null THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csiinst',
        p_file_segment2 => p_instance_id);
    END IF;

    FOR inst_rec IN inst_cur(p_instance_id)
    LOOP

      add('Instance ID : '||inst_rec.instance_id);
      blank_line;

      l_out := ' '||fill('Inst#', 10)||
               fill('Serial#', 15)||
               fill('Lot#', 15)||
               fill('LocationType', 18)||
               fill('UsageCode', 18)||
               fill('EndDate', 10);
      add(l_out);

      l_out := ' '||fill('------', 10)||
               fill('-------', 15)||
               fill('----', 15)||
               fill('------------', 18)||
               fill('---------', 18)||
               fill('------', 10);
      add(l_out);

      l_out := ' '||fill(inst_rec.instance_number, 10)||
               fill(inst_rec.serial_number, 15)||
               fill(inst_rec.lot_number, 15)||
               fill(inst_rec.location_type_code, 18)||
               fill(inst_rec.instance_usage_code, 18)||
               fill(inst_rec.active_end_date, 10);
      add(l_out);


      FOR comp_rec IN comp_cur(p_instance_id)
      LOOP
        IF comp_cur%rowcount = 1 THEN
          blank_line;
          add(' Instance Relationships :-');
          blank_line;
          l_out := '  '||
                   fill('RelID', 10)||
                   fill('CompInstID', 12)||
                   fill('Relationship', 14)||
                   fill('RelEndDate', 12)||
                   fill('Serial#', 15)||
                   fill('UsageCode', 16)||
                   fill('InstEndDate', 12);
          add(l_out);
          l_out := '  '||
                   fill('-----', 10)||
                   fill('----------', 12)||
                   fill('------------', 14)||
                   fill('----------', 12)||
                   fill('-------', 15)||
                   fill('---------', 16)||
                   fill('-----------', 12);
          add(l_out);
        END IF;

        l_out := '  '||
                 fill(comp_rec.relationship_id, 10)||
                 fill(comp_rec.subject_id, 12)||
                 fill(comp_rec.relationship_type_code, 14)||
                 fill(comp_rec.rel_end_date, 12)||
                 fill(comp_rec.serial_number, 15)||
                 fill(comp_rec.instance_usage_code, 18)||
                 fill(comp_rec.instance_end_date, 12);
        add(l_out);
      END LOOP;

      FOR txn_rec IN txn_cur(p_instance_id)
      LOOP
        IF txn_cur%rowcount = 1 THEN
          blank_line;
          add(' Instance Transactions :-');
          blank_line;
          l_out := '  '||
                   fill('TTID', 5)||
                   fill('TxnType', 25)||
                   fill('TxnID', 10)||
                   fill('TxnDate', 19)||
                   fill('SrcTxnDate', 19)||
                   fill('MtlTxnID', 12);
          add(l_out);
          l_out := '  '||
                   fill('----', 5)||
                   fill('-------', 25)||
                   fill('-----', 10)||
                   fill('-------', 19)||
                   fill('----------', 19)||
                   fill('--------', 12);
          add(l_out);
        END IF;

        l_out := '  '||
                 fill(txn_rec.transaction_type_id, 5)||
                 fill(txn_rec.source_transaction_type, 25)||
                 fill(txn_rec.transaction_id, 10)||
                 fill(txn_rec.transaction_date, 19)||
                 fill(txn_rec.source_transaction_date, 19)||
                 fill(txn_rec.inv_material_transaction_id, 12);
        add(l_out);

      END LOOP;

      IF p_standalone_mode = 'Y' THEN
        IF inst_rec.serial_number is not null THEN
          serial_status(
            p_serial_number   => inst_rec.serial_number,
            p_item_id         => inst_rec.inventory_item_id,
            p_standalone_mode => 'N');
        END IF;
      END IF;

    END LOOP;

  END instance_status;

  PROCEDURE job_status(
    p_job_name           IN varchar2,
    p_organization_id    IN number)
  IS
    l_job_rec            job_rec;
    l_item_rec           item_rec;
    l_wip_req_tbl        wip_req_tbl;
    l_wip_mmt_tbl        mmt_tbl;
  BEGIN

    IF csi_t_gen_utility_pvt.g_file is null THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csijob',
        p_file_segment2 => p_job_name);
    END IF;

    get_job_rec(
      p_wip_entity_name    => p_job_name,
      p_organization_id    => p_organization_id,
      x_job_rec            => l_job_rec);

    dump_job_rec(l_job_rec);

    get_item_rec(
      p_item_id         => l_job_rec.primary_item_id,
      p_organization_id => l_job_rec.organization_id,
      x_item_rec        => l_item_rec);

    dump_item_rec(
      p_item_rec        => l_item_rec);

    get_wip_req_tbl(
      p_wip_entity_id   => l_job_rec.wip_entity_id,
      p_organization_id => l_job_rec.organization_id,
      x_wip_req_tbl     => l_wip_req_tbl);

    dump_wip_req_tbl(
      p_wip_req_tbl     => l_wip_req_tbl);

    get_wip_mmt_tbl(
      p_wip_entity_id   => l_job_rec.wip_entity_id,
      p_organization_id => l_job_rec.organization_id,
      x_wip_mmt_tbl     => l_wip_mmt_tbl);

    dump_wip_mmt_tbl(
     p_wip_mmt_tbl      => l_wip_mmt_tbl);

  END job_status;

  PROCEDURE dump_patch_history(
    p_file_id            IN number)
  IS
    CURSOR patch_hist_cur(p_file_id IN number) IS
      SELECT distinct afv.version, afv.creation_date, ab.bug_number
      FROM   ad_file_versions afv,
             ad_patch_run_bug_actions aprba,
             ad_patch_run_bugs aprb,
             ad_bugs ab
      WHERE  afv.file_id                    = p_file_id
      AND    aprba.file_id(+)               = afv.file_id
      AND    aprba.patch_file_version_id(+) = afv.file_version_id
      AND    aprb.patch_run_bug_id(+)       = aprba.patch_run_bug_id
      AND    aprb.success_flag(+)           = 'Y'
      AND    ab.bug_id(+)                   = aprb.bug_id
      ORDER BY afv.creation_date desc;
    l_out varchar2(2000);
  BEGIN
    blank_line;
    FOR patch_hist_rec IN patch_hist_cur(p_file_id)
    LOOP
      IF patch_hist_cur%rowcount = 1 THEN
        l_out := '  '||
                 fill('Patch Date', 12)||
                 fill('Version', 20)||
                 fill('Bug Number', 15);
        add(l_out);
        l_out := '  '||
                 fill('-----------', 12)||
                 fill('------------------', 20)||
                 fill('--------------', 15);
        add(l_out);
      END IF;
      l_out := '  '||
               fill(patch_hist_rec.creation_date, 12)||
               fill(patch_hist_rec.version, 20)||
               fill(patch_hist_rec.bug_number, 15);
      add(l_out);

      EXIT WHEN patch_hist_cur%rowcount = 5;

    END LOOP;
  END dump_patch_history;

  PROCEDURE dump_file_version(
    p_file_name          IN varchar2,
    p_subdir             IN varchar2 default 'patch/115/sql',
    p_prod_code          IN varchar2 default 'CSI')
  IS
    l_file_id            number;
    l_latest_version     varchar2(80);
    l_out                varchar2(2000);

    CURSOR latest_version_cur(p_file_id IN number) IS
      SELECT version
      FROM   ad_file_versions
      WHERE  file_id = p_file_id
      ORDER  BY file_version_id desc;

  BEGIN

    SELECT file_id
    INTO   l_file_id
    FROM   ad_files
    WHERE  filename       = p_file_name
    AND    subdir         = p_subdir
    AND    app_short_name = p_prod_code;

    OPEN  latest_version_cur(l_file_id);
    FETCH latest_version_cur INTO l_latest_version;
    CLOSE latest_version_cur;

    blank_line;
    l_out := 'File Name : '||p_file_name||'  Version : '||l_latest_version;
    add(l_out);

    IF l_latest_version is not null THEN
      dump_patch_history(
        p_file_id  => l_file_id);
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      add('Invalid File : '||p_file_name);
  END dump_file_version;

  PROCEDURE dump_file_versions(
    p_source_files       IN source_files)
  IS
  BEGIN
    IF p_source_files.count > 0 THEN
      FOR l_ind IN p_source_files.FIRST .. p_source_files.LAST
      LOOP
        dump_file_version(p_source_files(l_ind).file_name);
      END LOOP;
    END IF;
  END dump_file_versions;

  PROCEDURE diagnose(
    errbuf               OUT nocopy varchar2,
    retcode              OUT nocopy number,
    p_entity             IN varchar2,
    p_parameter1         IN varchar2,
    p_parameter2         IN varchar2)
  IS
    l_order_number       number;

    l_job_name           varchar2(30);
    l_organization_id    number;

    l_mtl_txn_id         number;
    l_serial_number      varchar2(80);
    l_inventory_item_id  number;

  BEGIN

    IF p_entity = 'ORDER' THEN
      l_order_number := to_number(p_parameter1);
      order_status(
        p_order_number => l_order_number);
    END IF;

    IF p_entity = 'SERIAL' THEN
      l_serial_number     := p_parameter1;
      l_inventory_item_id := to_number(p_parameter2);
      serial_status(
        p_serial_number => l_serial_number,
        p_item_id       => l_inventory_item_id);
    END IF;

    IF p_entity = 'JOB' THEN
      l_job_name        := p_parameter1;
      l_organization_id := to_number(p_parameter2);
      job_status(
        p_job_name        => l_job_name,
        p_organization_id => l_organization_id);
    END IF;

    IF p_entity = 'TRANSACTION' THEN
      l_mtl_txn_id  := p_parameter1;
      txn_status(
        p_mtl_txn_id => l_mtl_txn_id);
    END IF;

  EXCEPTION
    WHEN others THEN
      add(sqlerrm);
  END diagnose;

END csi_debug_pkg;

/
