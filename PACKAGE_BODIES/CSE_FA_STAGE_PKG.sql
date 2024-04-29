--------------------------------------------------------
--  DDL for Package Body CSE_FA_STAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_FA_STAGE_PKG" AS
/* $Header: CSEPFASB.pls 120.13 2006/08/25 00:41:42 brmanesh noship $ */

  l_debug varchar2(1) := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');

  g_clob  clob;

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log,p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  -- valid candidates for staging
  --    1. no invoice information on asset
  --    2. invoice found but no po distribution info on invoice
  --    3. po distribution found but description based item on po line
  --    4. po item is ib tracked

  FUNCTION potential_for_ib(
    p_po_dist_id          IN number,
    p_invoice_id          IN number,
    p_ap_dist_line_number IN number)
  RETURN boolean
  IS

    l_candidate           boolean := FALSE;
    l_po_dist_id          number;
    l_inventory_item_id   number;
    l_organization_id     number;
    l_ib_trackable_flag   varchar2(1);

    CURSOR po_cur(p_dist_id IN number) IS
      SELECT pol.item_id,
             pol.line_num,
             pol.item_description,
             pod.destination_type_code,
             pod.destination_organization_id,
             pol.org_id
      FROM   po_distributions_all pod,
             po_lines_all         pol
      WHERE  pod.po_distribution_id = p_dist_id
      AND    pol.po_line_id         = pod.po_line_id;

    CURSOR ap_inv_cur IS
      SELECT po_distribution_id
      FROM   ap_invoice_distributions_all aid
      WHERE  aid.invoice_id                = p_invoice_id
      AND    aid.distribution_line_number  = p_ap_dist_line_number;

  BEGIN

    IF p_po_dist_id is not null THEN
      l_po_dist_id := p_po_dist_id;
    ELSE
      IF p_invoice_id is not null THEN
        FOR ap_inv_rec IN ap_inv_cur
        LOOP
          l_po_dist_id := ap_inv_rec.po_distribution_id;
          exit;
        END LOOP;
      ELSE
        l_po_dist_id := null;
      END IF;
    END IF;

    IF l_po_dist_id is null THEN
      l_candidate := TRUE;
    ELSE
      FOR po_rec IN po_cur(l_po_dist_id)
      LOOP
        IF po_rec.item_id is null THEN
          l_candidate := TRUE;
        ELSE
          l_inventory_item_id := po_rec.item_id;

          IF po_rec.destination_type_code = 'EXPENSE' THEN
            SELECT inventory_organization_id
            INTO   l_organization_id
            FROM   financials_system_params_all
            WHERE  org_id = po_rec.org_id;
          ELSE
            l_organization_id := po_rec.destination_organization_id;
          END IF;

          SELECT nvl(comms_nl_trackable_flag, 'N')
          INTO   l_ib_trackable_flag
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_inventory_item_id
          AND    organization_id   = l_organization_id;

          IF l_ib_trackable_flag = 'Y' THEN
            l_candidate := TRUE;
          ELSE
            l_candidate := FALSE;
          END IF;
        END IF;
      END LOOP;

      IF po_cur%notfound THEN
        l_candidate := TRUE;
      END IF;

    END IF;
    RETURN l_candidate;
  EXCEPTION
    WHEN others THEN
      RETURN l_candidate;
  END potential_for_ib;

  PROCEDURE stage_addition(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_desc_rec    IN     fa_api_types.asset_desc_rec_type,
    p_asset_fin_rec     IN     fa_api_types.asset_fin_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type)
  IS
    l_interface_header_id      number;
    l_interface_line_id        number;
    l_rowid                    varchar2(30);
    l_feeder_system_name       varchar2(80) := 'NONE';
    l_stage_flag               boolean      := FALSE;
    l_parent_mass_addition_id  number;
    l_pa_asset_line_id         number;
  BEGIN

    debug('inside api cse_fa_stage_pkg.stage_addition');
    debug('  p_inv_tbl.count        : '||p_inv_tbl.COUNT);

    IF p_inv_tbl.COUNT = 0 THEN
      l_stage_flag := TRUE;
    ELSE

      FOR inv_ind IN p_inv_tbl.FIRST .. p_inv_tbl.LAST
      LOOP

        debug('  po_distribution_id     : '||p_inv_tbl(inv_ind).po_distribution_id);
        debug('  p_invoice_id           : '||p_inv_tbl(inv_ind).invoice_id);
        debug('  p_ap_dist_line_number  : '||p_inv_tbl(inv_ind).ap_distribution_line_number);

        IF potential_for_ib(
             p_po_dist_id          => p_inv_tbl(inv_ind).po_distribution_id,
             p_invoice_id          => p_inv_tbl(inv_ind).invoice_id,
             p_ap_dist_line_number => p_inv_tbl(inv_ind).ap_distribution_line_number)
        THEN

          l_feeder_system_name      := nvl(p_inv_tbl(inv_ind).feeder_system_name, 'NONE');
          l_parent_mass_addition_id := p_inv_tbl(inv_ind).parent_mass_addition_id;
          l_pa_asset_line_id        := p_inv_tbl(inv_ind).project_asset_line_id;

          l_stage_flag := TRUE;
          exit;

        END IF; -- potential for ib

      END LOOP; -- inv_tbl loop

    END IF; -- inv_tbl.count > 0

    IF l_stage_flag THEN

      BEGIN

        SELECT csi_fa_headers_s.nextval
        INTO   l_interface_header_id
        FROM   sys.dual;

        csi_fa_headers_pkg.INSERT_ROW (
          X_ROWID               => l_rowid,
          X_INTERFACE_HEADER_ID => l_interface_header_id,
          X_FA_ASSET_ID         => p_asset_hdr_rec.asset_id,
          X_FEEDER_SYSTEM_NAME  => l_feeder_system_name,
          X_STATUS_CODE         => 'NEW',
          X_FA_BOOK_TYPE_CODE   => p_asset_hdr_rec.book_type_code,
          X_CREATION_DATE       => sysdate,
          X_CREATED_BY          => fnd_global.user_id,
          X_LAST_UPDATE_DATE    => sysdate,
          X_LAST_UPDATED_BY     => fnd_global.user_id,
          X_LAST_UPDATE_LOGIN   => fnd_global.login_id);

      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

      IF p_asset_dist_tbl.COUNT > 0 THEN
        FOR dist_ind IN p_asset_dist_tbl.FIRST .. p_asset_dist_tbl.LAST
        LOOP

          SELECT csi_fa_transactions_s.nextval
          INTO   l_interface_line_id
          FROM   sys.dual;

          csi_fa_transactions_pkg.INSERT_ROW (
            X_ROWID                    => l_rowid,
            X_INTERFACE_LINE_ID        => l_interface_line_id,
            X_INTERFACE_HEADER_ID      => l_interface_header_id,
            X_DISTRIBUTION_ID          => p_asset_dist_tbl(dist_ind).distribution_id,
            X_TRANSACTION_DATE         => p_trans_rec.transaction_date_entered,
            X_TRANSACTION_UNITS => nvl(p_asset_dist_tbl(dist_ind).transaction_units, p_asset_desc_rec.current_units),
            X_TRANSACTION_COST         => p_asset_fin_rec.cost,
            X_PARENT_MASS_ADDITION_ID  => l_parent_mass_addition_id,
            X_PA_ASSET_LINE_ID         => l_pa_asset_line_id,
            X_TRANSFER_DISTRIBUTION_ID => null,
            X_RETIREMENT_ID            => null,
            X_STATUS_CODE              => 'NEW',
            X_DATE_PROCESSED           => null,
            X_DATE_NOTIFIED            => null,
            X_ERROR_FLAG               => 'N',
            X_ERROR_TEXT               => null,
            X_TRANSACTION_SOURCE_TYPE  => p_trans_rec.transaction_type_code,
            X_CREATION_DATE            => sysdate,
            X_CREATED_BY               => fnd_global.user_id,
            X_LAST_UPDATE_DATE         => sysdate,
            X_LAST_UPDATED_BY          => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN        => fnd_global.login_id);

        END LOOP; -- asset_dist_tbl loop

      END IF; -- p_asset_dist_tbl.count > 0
    END IF;

  END stage_addition;

  PROCEDURE stage_unit_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type)
  IS
  BEGIN
    null;
  END stage_unit_adjustment;

  PROCEDURE stage_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_fin_rec_adj IN     fa_api_types.asset_fin_rec_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type)
  IS
  BEGIN
    null;
  END stage_adjustment;

  PROCEDURE stage_transfer(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type)
  IS
  BEGIN
    null;
  END stage_transfer;

 PROCEDURE stage_retirement(
    p_asset_id          IN     number,
    p_book_type_code    IN     varchar2,
    p_retirement_id     IN     number,
    p_retirement_date   IN     date,
    p_retirement_units  IN     number)
  IS
  BEGIN
    null;
  END stage_retirement;

  PROCEDURE stage_reinstatement(
    p_asset_id            IN   number,
    p_book_type_code      IN   varchar2,
    p_retirement_id       IN   number,
    p_reinstatement_date  IN   date,
    p_reinstatement_units IN   number)
  IS
  BEGIN
    null;
  END stage_reinstatement;

  -- notification related code

  PROCEDURE report_output  IS

    CURSOR stage_cur IS
      SELECT cfh.interface_header_id,
             cfh.fa_asset_id,
             fa.asset_number,
             fa.description asset_description,
             cfh.fa_book_type_code,
             cfh.created_by,
             cft.interface_line_id,
             cft.transaction_source_type,
             cft.transaction_units,
             cft.transaction_date,
             cft.transaction_cost,
             cfh.feeder_system_name
      FROM   csi_fa_headers      cfh,
             csi_fa_transactions cft,
             fa_additions        fa
      WHERE  cfh.status_code         = 'NEW'
      AND    cft.interface_header_id = cfh.interface_header_id
      AND    cft.status_code         = 'NEW'
      AND    fa.asset_id             = cfh.fa_asset_id;

    l_out            varchar2(2000);

    PROCEDURE out(
      p_message in varchar2)
    IS
      l_message_with_newline varchar2(520);

      FUNCTION add_newline(p_message in varchar2) RETURN varchar2 IS
        l_with_newline varchar2(520);
      BEGIN
        l_with_newline := '<pre>'||p_message||'</pre>';
        return l_with_newline;
      END add_newline;

    BEGIN
      fnd_file.put_line(fnd_file.output, p_message);
      l_message_with_newline := add_newline(p_message);
      dbms_lob.writeappend(g_clob, length(l_message_with_newline), l_message_with_newline);
    END out;

    FUNCTION fill(
      p_column IN varchar2,
      p_width  IN number,
      p_side   IN varchar2 default 'R')
    RETURN varchar2 IS
      l_column varchar2(2000);
    BEGIN
      l_column := nvl(p_column, ' ');
      IF p_side = 'L' THEN
        return(lpad(l_column, p_width, ' '));
      ELSIF p_side = 'R' THEN
        return(rpad(l_column, p_width, ' '));
      END IF;
    END fill;

  BEGIN
    FOR stage_rec IN stage_cur
    LOOP

      IF stage_cur%rowcount = 1 THEN
        dbms_lob.createtemporary(g_clob,TRUE, dbms_lob.session);

        l_out := '                    New Assets to be Tracked in Installed Base - Report';
        out(l_out);
        l_out := '                    ---------------------------------------------------';
        out(l_out);
        l_out := fill('Asset Number', 13)||
                 fill('Book Type', 12)||
                 fill('Description', 25)||
                 fill('Units', 10, 'L')||
                 fill('Cost', 15, 'L')||
                 fill('  Feeder System', 25);
        out(l_out);
        l_out := fill('------------', 13)||
                 fill('---------', 12)||
                 fill('-----------', 25)||
                 fill('-----', 10, 'L')||
                 fill('----', 15, 'L')||
                 fill('  -------------', 25);
        out(l_out);
      END IF;

      l_out := fill(stage_rec.asset_number, 13)||
               fill(stage_rec.fa_book_type_code, 12)||
               fill(stage_rec.asset_description, 25)||
               fill(stage_rec.transaction_units, 10, 'L')||
               fill(stage_rec.transaction_cost, 15, 'L')||
               '  '||fill(stage_rec.feeder_system_name, 23);

      out(l_out);

    END LOOP;
  END report_output;

  PROCEDURE get_report_clob (
    p_report_clob     IN            clob,
    p_display_type    IN            varchar2,
    x_document        IN OUT NOCOPY clob,
    x_document_type   IN OUT NOCOPY varchar2)
  IS
  BEGIN
    dbms_lob.append(x_document, p_report_clob);
  END get_report_clob;


  PROCEDURE ib_url(
    x_ib_url      OUT NOCOPY varchar2)
  IS
    l_ib_url   varchar2(240);
  BEGIN

    SELECT fnd_profile.value('apps_framework_agent')||'/OA_HTML/OA.jsp?OAFunc=CSE_OANF_FA_SEARCH'
    INTO   l_ib_url
    FROM   sys.dual;

    x_ib_url := l_ib_url;

  END ib_url;

  PROCEDURE send_mail(
    p_request_id        IN number)
  IS
    l_resp_name         varchar2(240);
    l_item_type         varchar2(40)  := 'CSEWF';
    l_item_key_seq      integer ;
    l_item_key          varchar2(240);
    l_process           varchar2(40)  := 'CSEPAPRC';
    l_ib_url            varchar2(240);
    l_message_subject   varchar2(240);
    l_message_body      varchar2(2000);
    l_display_type      varchar2(30) := 'text/plain';
  BEGIN

    debug('send mail');

    SELECT csi_wf_item_key_number_s.nextval
    INTO   l_item_key_seq
    FROM   sys.dual;

    l_item_key := l_item_type||'-'||l_item_key_seq;

    debug('item key : '||l_item_key);

    WF_ENGINE.CreateProcess (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      process         => 'CSEPAPRC');

    SELECT responsibility_name
    INTO   l_resp_name
    FROM   fnd_responsibility fr, fnd_responsibility_tl frt
    WHERE  fr.responsibility_key = 'CSE_SUPER_USER_RESP'
    AND    frt.responsibility_id = fr.responsibility_id
    AND    frt.language = 'US';

    debug('resp name : '||l_resp_name);

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => '#FROM_ROLE',
      avalue          => 'Asset Tracking Super User');

    l_message_subject := fnd_message.get_string('CSE', 'CSE_FA_NOTIFICATION_SUBJECT');

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'MESSAGE_SUBJECT',
      avalue          => l_message_subject);

    l_message_body    := fnd_message.get_string('CSE', 'CSE_FA_NOTIFICATION_MSG');

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'MESSAGE_BODY',
      avalue          => l_message_body);

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'CONC_REQUEST_ID',
      avalue          => p_request_id);

    ib_url(l_ib_url);

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'IB_URL',
      avalue          => l_ib_url);

    SELECT responsibility_name
    INTO   l_resp_name
    FROM   fnd_responsibility fr, fnd_responsibility_tl frt
    WHERE  fr.responsibility_key = 'CSE_ASSET_PLANNER'
    AND    frt.responsibility_id = fr.responsibility_id
    AND    frt.language = 'US';

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'SEND_TO',
      avalue          => l_resp_name);

    WF_ENGINE.SetItemAttrText (
      itemtype        => l_item_type,
      itemkey         => l_item_key,
      aname           => 'ATTACHMENT',
      avalue          => 'PLSQLCLOB:CSE_FA_STAGE_PKG.GET_REPORT_CLOB/'||g_clob);

    WF_ENGINE.StartProcess (
      itemtype        => l_item_type,
      itemkey         => l_item_key);

  END send_mail;

  PROCEDURE notify_users(
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER)
  IS
    l_request_id     number;
  BEGIN

    report_output;

    l_request_id := fnd_global.conc_request_id;

    send_mail(l_request_id);

  END notify_users;

END cse_fa_stage_pkg;

/
