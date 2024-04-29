--------------------------------------------------------
--  DDL for Package Body CSE_AP_PA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_AP_PA_PKG" AS
/* $Header: CSEAPINB.pls 120.16.12010000.5 2009/12/23 13:23:41 dsingire ship $  */

  l_debug varchar2(1) := nvl(fnd_profile.value('cse_debug_option'),'N');

  TYPE ap_pa_rec IS RECORD(
    invoice_id                 number,
    invoice_type               varchar2(30),
    invoice_line_number        number,
    invoice_distribution_id    number,
    invoice_distribution_type  varchar2(30),
    distribution_line_number   varchar2(30),
    po_header_id               number,
    po_line_id                 number,
    po_distribution_id         number,
    project_id                 number,
    task_id                    number,
    expenditure_item_date      date,
    expenditure_type           varchar2(30),
    exp_org_id                 number,
    dest_org_id                number,
    org_id                     number,
    accounting_date            date,
    base_amount                number,
    prorated_amount            number,
    quantity_invoiced          number,
    unit_price                 number,
    inv_dist_ccid              number,
    acct_pay_ccid              number,
    inventory_item_id          number,
    item_name                  varchar2(80),
    project_num                varchar2(30),
    task_num                   varchar2(30),
    exp_org_name               varchar2(240),--#5763437
    exp_ending_date            date,
    depreciable                varchar2(1),
    vendor_id                  number,
    vendor_num                 varchar2(30),
    expenditure_item_id        number,
    expenditure_item_qty       number,
    attribute6                 varchar2(150),
    attribute7                 varchar2(150),
    attribute8                 varchar2(150),
    attribute9                 varchar2(150),
    attribute10                varchar2(150),
    orig_transaction_reference varchar2(150),
    in_service_flag            varchar2(1));

  TYPE ap_pa_tbl IS TABLE OF ap_pa_rec index by binary_integer;

  TYPE ap_ft_rec IS RECORD (
    invoice_type               varchar2(15),
    chrg_dist_id               number,
    item_dist_id               number,
    base_amount                number,
    alloc_amount               number,
    accounting_date            date,
    inv_dist_ccid              number);

  TYPE ap_ft_tbl IS TABLE OF ap_ft_rec index by binary_integer;

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

  PROCEDURE get_prorated_ei(
    px_ap_pa_tbl     in out nocopy ap_pa_tbl,
    x_in_service_flag out nocopy varchar2, -- Bug 8565319
    x_return_status     out nocopy varchar2)
  IS

    l_ap_pa_tbl         ap_pa_tbl;
    l_ind               binary_integer := 0;
    l_unit_ipv_amount   number;
    l_remaining_qty     number;
    l_prorate_qty       number;
    l_already_prorated  boolean;

    MAX_BUFFER_SIZE NUMBER := 5000;

   --Modified cursor for bug6754713
    CURSOR rcv_ei_cur(p_project_id IN number, p_task_id IN NUMBER, p_org_ID IN NUMBER, p_po_distribution_id IN number) IS
      SELECT 'EI' ei_stage,
      ei.expenditure_item_id,
      ei.quantity,
      ei.attribute6,
      ei.attribute7,
      ei.attribute8,
      ei.attribute9,
      ei.attribute10,
      ei.orig_transaction_reference,
      substr(orig_transaction_reference, 1,(instr(orig_transaction_reference, '-', 1, 2)-1)) instance_id,
      ei.transaction_source
      FROM pa_cost_distribution_lines_all cdl,
      pa_expenditure_items_all ei
      WHERE cdl.project_id = p_project_id
      AND cdl.task_id = p_task_id
      AND cdl.org_id = p_org_id
      AND cdl.project_id = ei.project_id
      AND cdl.task_id = ei.task_id
      AND cdl.org_id = ei.org_id
      AND ei.expenditure_item_id = cdl.expenditure_item_id
      AND ei.transaction_source IN ( 'CSE_PO_RECEIPT', 'CSE_IPV_ADJUSTMENT')
      AND (ei.transaction_source, cdl.system_reference3) IN (
      SELECT 'CSE_PO_RECEIPT' txn_source , p_po_distribution_id sys_reference3
      FROM dual
      UNION ALL
      SELECT 'CSE_IPV_ADJUSTMENT' txn_source , distribution_line_number
      sys_reference3
      FROM ap_invoice_distributions_all aida
      WHERE po_distribution_id = p_po_distribution_id
      and aida.invoice_id = cdl.system_reference2)
      AND nvl(ei.net_zero_adjustment_flag, 'N') = 'N'
      UNION ALL
      SELECT 'TI' ei_stage,
      null expenditure_item_id,
      ti.quantity,
      ti.attribute6,
      ti.attribute7,
      ti.attribute8,
      ti.attribute9,
      ti.attribute10,
      ti.orig_transaction_reference,
      substr(orig_transaction_reference, 1,(instr(orig_transaction_reference, '-', 1, 2)-1)) instance_id,
      ti.transaction_source
      FROM pa_transaction_interface_all ti
      WHERE ti.transaction_source IN ( 'CSE_PO_RECEIPT', 'CSE_IPV_ADJUSTMENT')
      AND (ti.transaction_source, cdl_system_reference3) IN ( SELECT
      'CSE_PO_RECEIPT' txn_source , p_po_distribution_id sys_reference3
      FROM dual
      UNION ALL
      SELECT 'CSE_IPV_ADJUSTMENT' txn_source , distribution_line_number
      sys_reference3
      FROM ap_invoice_distributions_all aida
      WHERE po_distribution_id = p_po_distribution_id
      and aida.invoice_id = ti.cdl_system_reference2)
      ORDER BY instance_id, transaction_source desc;

     TYPE rcv_ei_tbl IS TABLE OF rcv_ei_cur%ROWTYPE index by binary_integer;

     l_rcv_ei_tbl rcv_ei_tbl;

  BEGIN
    x_in_service_flag := 'Y';  -- Bug 8565319
    x_return_status := fnd_api.g_ret_sts_success;

    debug('Inside API cse_ap_pa_pkg.get_prorated_ei');

    IF px_ap_pa_tbl.COUNT > 0 THEN
      FOR ind IN px_ap_pa_tbl.FIRST .. px_ap_pa_tbl.LAST
      LOOP

        IF px_ap_pa_tbl(ind).depreciable = 'Y' THEN
          l_ind := l_ind + 1;
          l_ap_pa_tbl(l_ind) := px_ap_pa_tbl(ind);
          l_ap_pa_tbl(l_ind).orig_transaction_reference := 'IPV-DEPR-'||px_ap_pa_tbl(ind).invoice_distribution_id;
          l_ap_pa_tbl(l_ind).prorated_amount            := px_ap_pa_tbl(ind).base_amount;
        ELSE

          l_remaining_qty   := px_ap_pa_tbl(ind).quantity_invoiced;
          l_unit_ipv_amount := px_ap_pa_tbl(ind).base_amount/px_ap_pa_tbl(ind).quantity_invoiced;

          debug(' invoiced_quantity     : '||px_ap_pa_tbl(ind).quantity_invoiced);
          debug(' base_ipv_amount       : '||px_ap_pa_tbl(ind).base_amount);
          debug(' unit_ipv_amount       : '||l_unit_ipv_amount);

           debug(' Project_id         : '||px_ap_pa_tbl(ind).project_id);
          debug(' Task id            : '||px_ap_pa_tbl(ind).task_id);
          debug(' Org Id             : '||px_ap_pa_tbl(ind).org_id);
          debug(' Dist Id            : '||px_ap_pa_tbl(ind).po_distribution_id);

           OPEN rcv_ei_cur(px_ap_pa_tbl(ind).project_id, px_ap_pa_tbl(ind).task_id, px_ap_pa_tbl(ind).org_id, px_ap_pa_tbl(ind).po_distribution_id);
           LOOP
           debug(' Inside rcv cursor - open');

	  --Added bulk  collect for bug 6716720--
           FETCH rcv_ei_cur  BULK COLLECT
           INTO  l_rcv_ei_tbl
           LIMIT MAX_BUFFER_SIZE;
           debug(' Inside rcv cursor -fetch count '||l_rcv_ei_tbl.COUNT);

        IF l_rcv_ei_tbl.COUNT > 0 THEN
         FOR j IN 1 .. l_rcv_ei_tbl.COUNT
          LOOP
            if (l_rcv_ei_tbl(j).transaction_source = 'CSE_PO_RECEIPT') THEN --loop added anjgupta
            debug('received expenditure record # '||j);
            debug('  expenditure_stage      : '||l_rcv_ei_tbl(j).ei_stage);
            debug('  expenditure_item_id    : '||l_rcv_ei_tbl(j).expenditure_item_id);
            debug('  orig_transaction_ref   : '||l_rcv_ei_tbl(j).orig_transaction_reference);
            debug('  attribute6             : '||l_rcv_ei_tbl(j).attribute6);
            debug('  attribute7             : '||l_rcv_ei_tbl(j).attribute7);

            --Modified the below code FP bug--
            -- check if this ei is already prorated for an earlier ipv

            for q in j .. l_rcv_ei_tbl.LAST
               loop
                l_already_prorated := FALSE;
                if (l_rcv_ei_tbl(q).transaction_source = 'CSE_IPV_ADJUSTMENT') THEN
                    IF (l_rcv_ei_tbl(q).instance_id = 'EI-'||l_rcv_ei_tbl(j).expenditure_item_id OR
                       l_rcv_ei_tbl(q).instance_id = 'TI-'||l_rcv_ei_tbl(j).orig_transaction_reference OR
                       l_rcv_ei_tbl(q).attribute6 = l_rcv_ei_tbl(j).attribute6 OR
                       l_rcv_ei_tbl(q).attribute7 = l_rcv_ei_tbl(j).attribute7 )
                    THEN
                        l_already_prorated := TRUE;
                        exit;
                    end if;
                end if;
            end loop;

            IF (NOT l_already_prorated) THEN
              debug('  not already prorated');
            ELSE
              debug('  already prorated');
            END IF;

            IF (px_ap_pa_tbl(ind).quantity_invoiced < l_rcv_ei_tbl(j).quantity) THEN
              debug('  partially prorated already');
            END IF;

            IF (NOT l_already_prorated) OR (px_ap_pa_tbl(ind).quantity_invoiced < l_rcv_ei_tbl(j).quantity) THEN

              l_prorate_qty := l_rcv_ei_tbl(j).quantity;

              l_remaining_qty := l_remaining_qty - l_rcv_ei_tbl(j).quantity;

              IF l_remaining_qty < 0 THEN
                l_prorate_qty := px_ap_pa_tbl(ind).quantity_invoiced;
              END IF;

              debug('  remaining_quantity   : '||l_remaining_qty);
              debug('  prorate_quantity     : '||l_prorate_qty);

              l_ind := l_ind + 1;
              l_ap_pa_tbl(l_ind) := px_ap_pa_tbl(ind);
              l_ap_pa_tbl(l_ind).attribute6  := l_rcv_ei_tbl(j).attribute6;
              l_ap_pa_tbl(l_ind).attribute7  := l_rcv_ei_tbl(j).attribute7;
              l_ap_pa_tbl(l_ind).attribute8  := l_rcv_ei_tbl(j).attribute8;
              l_ap_pa_tbl(l_ind).attribute9  := l_rcv_ei_tbl(j).attribute9;
              l_ap_pa_tbl(l_ind).attribute10 := l_rcv_ei_tbl(j).attribute10;
              IF l_rcv_ei_tbl(j).ei_stage = 'EI' THEN
                l_ap_pa_tbl(l_ind).orig_transaction_reference := 'EI-'||l_rcv_ei_tbl(j).expenditure_item_id||'-'||
                  px_ap_pa_tbl(ind).invoice_distribution_id;
              ELSIF l_rcv_ei_tbl(j).ei_stage = 'TI' THEN
                l_ap_pa_tbl(l_ind).orig_transaction_reference := 'TI-'||l_rcv_ei_tbl(j).orig_transaction_reference||'-'||
                  px_ap_pa_tbl(ind).invoice_distribution_id;
              END IF;

              l_ap_pa_tbl(l_ind).prorated_amount      := l_prorate_qty * l_unit_ipv_amount;
              l_ap_pa_tbl(l_ind).expenditure_item_id  := l_rcv_ei_tbl(j).expenditure_item_id;
              l_ap_pa_tbl(l_ind).expenditure_item_qty := l_rcv_ei_tbl(j).quantity;

              IF l_rcv_ei_tbl(j).attribute7 is not null AND l_rcv_ei_tbl(j).attribute8 is not null THEN
                l_ap_pa_tbl(l_ind).in_service_flag := 'Y';
              ELSE
                l_ap_pa_tbl(l_ind).in_service_flag := 'N';
                x_in_service_flag := 'N'; -- Bug 8565319
              END IF;

              EXIT WHEN l_remaining_qty <= 0;

              END IF; -- if rcv ei not already processed by another partial ipv txn
   	      END IF;
             END LOOP;
            END IF;
           EXIT when rcv_ei_cur%NOTFOUND OR l_remaining_qty <= 0;
          END LOOP; -- get all the received eis  rcv_ei_cur loop

	  CLOSE rcv_ei_cur;
        END IF; -- depreciable
      END LOOP;
    END IF; -- px tbl count > 0

    px_ap_pa_tbl := l_ap_pa_tbl;

  END get_prorated_ei;

  PROCEDURE populate_pa_txn_intf(
    p_ap_pa_tbl      IN  ap_pa_tbl,
    x_return_status  OUT nocopy varchar2,
    x_error_message  OUT nocopy varchar2)
  IS

    l_ind                 binary_integer := 0;
    l_nl_pa_tbl           cse_ipa_trans_pkg.nl_pa_interface_tbl_type;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message       varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('Inside API cse_ap_pa_pkg.populate_pa_txn_intf');

    IF p_ap_pa_tbl.count > 0 THEN
      FOR ind IN p_ap_pa_tbl.FIRST .. p_ap_pa_tbl.LAST
      LOOP

        debug('prorated invoice distributions. record # '||ind);
        debug('  invoice_distribution_id : '||p_ap_pa_tbl(ind).invoice_distribution_id);
        debug('  project_id              : '||p_ap_pa_tbl(ind).project_id);
        debug('  task_id                 : '||p_ap_pa_tbl(ind).task_id);
        debug('  prorated_amount         : '||p_ap_pa_tbl(ind).prorated_amount);
        debug('  related_exp_item_id     : '||p_ap_pa_tbl(ind).expenditure_item_id);
        debug('  orig_transaction_ref    : '||p_ap_pa_tbl(ind).orig_transaction_reference);

        l_ind := l_ind + 1;
        l_nl_pa_tbl(l_ind).expenditure_ending_date := p_ap_pa_tbl(ind).exp_ending_date;
        l_nl_pa_tbl(l_ind).organization_name       := p_ap_pa_tbl(ind).exp_org_name;
        l_nl_pa_tbl(l_ind).expenditure_item_date   := p_ap_pa_tbl(ind).expenditure_item_date;
        l_nl_pa_tbl(l_ind).project_number          := p_ap_pa_tbl(ind).project_num;
        l_nl_pa_tbl(l_ind).task_number             := p_ap_pa_tbl(ind).task_num;
        l_nl_pa_tbl(l_ind).expenditure_type        := p_ap_pa_tbl(ind).expenditure_type;
        l_nl_pa_tbl(l_ind).quantity                := 1;
        l_nl_pa_tbl(l_ind).batch_name              := 'IPV-'||p_ap_pa_tbl(ind).invoice_distribution_id;
        l_nl_pa_tbl(l_ind).raw_cost_rate           := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).acct_raw_cost           := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).burdened_cost           := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).burdened_cost_rate      := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).denom_raw_cost          := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).raw_cost                := p_ap_pa_tbl(ind).prorated_amount;
        l_nl_pa_tbl(l_ind).expenditure_comment     := 'ENTERPRISE INSTALL BASE';
        l_nl_pa_tbl(l_ind).transaction_status_code := 'P';
        l_nl_pa_tbl(l_ind).attribute6              := p_ap_pa_tbl(ind).attribute6;
        l_nl_pa_tbl(l_ind).attribute7              := p_ap_pa_tbl(ind).attribute7;
        l_nl_pa_tbl(l_ind).attribute8              := p_ap_pa_tbl(ind).attribute8;
        l_nl_pa_tbl(l_ind).attribute9              := p_ap_pa_tbl(ind).attribute9;
        l_nl_pa_tbl(l_ind).attribute10             := p_ap_pa_tbl(ind).attribute10;
        l_nl_pa_tbl(l_ind).orig_transaction_reference  := p_ap_pa_tbl(ind).orig_transaction_reference;
        l_nl_pa_tbl(l_ind).unmatched_negative_txn_flag := 'Y';
        l_nl_pa_tbl(l_ind).org_Id                  := p_ap_pa_tbl(ind).org_id ;
        l_nl_pa_tbl(l_ind).dr_code_combination_id  := p_ap_pa_tbl(ind).inv_dist_ccid;
        l_nl_pa_tbl(l_ind).cr_code_combination_id  := p_ap_pa_tbl(ind).acct_pay_ccid;
        l_nl_pa_tbl(l_ind).gl_date                 := p_ap_pa_tbl(ind).accounting_date;
        l_nl_pa_tbl(l_ind).system_linkage          := 'VI';
        l_nl_pa_tbl(l_ind).cdl_system_reference1   := p_ap_pa_tbl(ind).vendor_id;
        l_nl_pa_tbl(l_ind).cdl_system_reference2   := p_ap_pa_tbl(ind).invoice_id ;
        l_nl_pa_tbl(l_ind).cdl_system_reference3   := p_ap_pa_tbl(ind).invoice_line_number;
        l_nl_pa_tbl(l_ind).cdl_system_reference5   := p_ap_pa_tbl(ind).invoice_distribution_id;
        l_nl_pa_tbl(l_ind).document_type           := p_ap_pa_tbl(ind).invoice_type;
        l_nl_pa_tbl(l_ind).document_distribution_type := p_ap_pa_tbl(ind).invoice_distribution_type;
        l_nl_pa_tbl(l_ind).user_transaction_source := 'ENTERPRISE INSTALL BASE';
        l_nl_pa_tbl(l_ind).last_update_date        := sysdate;
        l_nl_pa_tbl(l_ind).last_updated_by         := fnd_global.user_id;
        l_nl_pa_tbl(l_ind).creation_date           := sysdate;
        l_nl_pa_tbl(l_ind).created_by              := fnd_global.user_Id;
        l_nl_pa_tbl(l_ind).vendor_number           := p_ap_pa_tbl(ind).vendor_num;
        l_nl_pa_tbl(l_ind).vendor_id               := p_ap_pa_tbl(ind).vendor_id;
        l_nl_pa_tbl(l_ind).inventory_item_id       := p_ap_pa_tbl(ind).inventory_item_id;
        l_nl_pa_tbl(l_ind).project_id              := p_ap_pa_tbl(ind).project_id;
        l_nl_pa_tbl(l_ind).task_id                 := p_ap_pa_tbl(ind).task_id;
        l_nl_pa_tbl(l_ind).po_header_id            := p_ap_pa_tbl(ind).po_header_id;
        l_nl_pa_tbl(l_ind).po_line_id              := p_ap_pa_tbl(ind).po_line_id;

        IF p_ap_pa_tbl(ind).depreciable = 'Y' THEN
          l_nl_pa_tbl(l_ind).billable_flag      := 'N';
          l_nl_pa_tbl(l_ind).transaction_source := 'CSE_IPV_ADJUSTMENT_DEPR';
        ELSE
          l_nl_pa_tbl(l_ind).billable_flag      := 'Y';
          l_nl_pa_tbl(l_ind).transaction_source := 'CSE_IPV_ADJUSTMENT';
        END IF;

      END LOOP;

      debug('Inside API cse_ipa_trans_pkg.populate_pa_interface');
      debug('  nl_pa_tbl.count      : '||l_nl_pa_tbl.COUNT);

      cse_ipa_trans_pkg.populate_pa_interface(
        p_nl_pa_interface_tbl  => l_nl_pa_tbl,
        x_return_status        => l_return_status,
        x_error_message        => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := l_error_message;
  END populate_pa_txn_intf;


  PROCEDURE process_ipv_to_pa(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_project_id              IN         number,
    p_task_id                 IN         number,
    p_po_header_id            IN         number,
    p_inventory_item_id       IN         number,
    p_organization_id         IN         number)
  IS

    CURSOR ap_inv_ipv_cur(p_project_id IN number) IS
      SELECT aia.invoice_type_lookup_code invoice_type,
             aida.line_type_lookup_code invoice_distribution_type,
             aida.invoice_distribution_id,
             pda.po_header_id,
             pda.po_line_id,
             pda.po_distribution_id,
             pda.project_id,
             pda.task_id,
             pda.expenditure_item_date,
             pda.expenditure_type,
             pda.expenditure_organization_id exp_org_id,
             pda.destination_organization_id dest_org_id,
             aida.org_id,
             aida.accounting_date,
             aida.invoice_id,
             aida.distribution_line_number,
             nvl(aida.amount,0)  base_amount,
             aila.line_number,
             decode(aida.line_type_lookup_code,'NONREC_TAX', (SELECT aida1.quantity_invoiced
						                   FROM ap_invoice_distributions_all aida1
						                   WHERE aida1.invoice_distribution_id = aida.charge_applicable_to_dist_id),aila.quantity_invoiced) quantity_invoiced, --Modified for bug 8927385

             aida.unit_price,
             aida.price_var_code_combination_id  inv_dist_ccid
      FROM   po_distributions_all pda,
             ap_invoice_distributions_all aida,
             ap_invoice_lines_all aila,
             ap_invoices_all aia
      WHERE  EXISTS (
        SELECT '1' FROM csi_transactions ct
        WHERE  ct.transaction_type_id     = 105
        AND    ct.transaction_status_code = 'COMPLETE'
        AND    ct.source_dist_ref_id1     = pda.po_distribution_id)
      AND    pda.project_id             = nvl(p_project_id, pda.project_id)
      AND    pda.task_id                = nvl(p_task_id, pda.task_id)
      AND    aida.po_distribution_id    = pda.po_distribution_id
      and    aida.line_type_lookup_code  IN ('IPV','FREIGHT', 'REC_TAX', 'NONREC_TAX') --Modified for bug 8927385
      AND    aida.posted_flag           = 'Y'
      AND    aida.pa_addition_flag      = 'N'
      AND    nvl(aida.reversal_flag, 'N') <> 'Y'
      AND    aila.invoice_id            = aida.invoice_id
      AND    aila.line_number           = aida.invoice_line_number
      AND    aia.invoice_id             = aida.invoice_id;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message       varchar2(2000);
    l_txn_error_rec       csi_datastructures_pub.transaction_error_rec;
    l_msg_data            varchar2(2000);
    l_msg_count           number;
    l_txn_error_id        number;
    l_inv_dist_id         number;
    l_total_ipv_amount    number := 0;
    l_total_ft_amount     number := 0;
    l_total_amount        number := 0;
    l_ap_ft_tbl           ap_ft_tbl;
    l_ap_pa_tbl           ap_pa_tbl;
    l_in_service_flag     varchar2(1); -- Bug 8565319

    PROCEDURE get_freight_and_tax(
      p_item_dist_id  IN  number,
      p_invoice_id    IN  number,
      p_project_id    IN  number,
      p_task_id       IN  number,
      x_ft_amount     OUT nocopy number,
      px_ap_ft_tbl    OUT nocopy ap_ft_tbl)
    IS

      l_ft_amount        number         := 0;
      l_alloc_ft_amount  number         := 0;
      l_ind              binary_integer := 0;

      CURSOR ft_cur IS
        SELECT aida.line_type_lookup_code     invoice_distribution_type,
               aida.invoice_distribution_id,
               aida.invoice_line_number,
               aia.invoice_type_lookup_code   invoice_type,
               nvl(aida.amount,0)             base_amount,
               aida.accounting_date,
               aida.dist_code_combination_id  inv_dist_ccid
         FROM   ap_invoice_distributions_all aida,
                ap_invoice_distributions_all aida1,
                ap_invoices_all              aia
         WHERE   aida.invoice_id                    = p_invoice_id
         AND    aida.project_id                     = p_project_id
         AND    aida.task_id                        = p_task_id
         AND    aida.line_type_lookup_code IN ('FREIGHT', 'REC_TAX',
 'NONREC_TAX')
         and   aida.posted_flag                    = 'Y'
         AND    aida.pa_addition_flag               = 'N'
         AND    nvl(aida.reversal_flag, 'N')       <> 'Y'
     --    AND    nvl(aida.tax_recoverable_flag, 'N') = 'N'
         AND    aia.invoice_id                      = aida.invoice_id
         AND    aida.charge_applicable_to_dist_id = aida1.invoice_distribution_id
	 AND    aida1.invoice_distribution_id = p_item_dist_id;

/*
      FUNCTION allocated_amount (pf_item_dist_id IN number, pf_charge_dist_id IN number)
      RETURN   number
      IS
        l_alloc_amount   number := 0;
        CURSOR chrg_alloc_cur IS
          SELECT allocated_amount
          FROM   ap_chrg_allocations_all
          WHERE  item_dist_id   = pf_item_dist_id
          AND    charge_dist_id = pf_charge_dist_id;
      BEGIN
        FOR chrg_alloc_rec IN chrg_alloc_cur
        LOOP
          l_alloc_amount := l_alloc_amount + chrg_alloc_rec.allocated_amount;
        END LOOP;
        RETURN l_alloc_amount;
      END allocated_amount;
*/

    BEGIN
      debug('Inside API get_freight_and_tax');
      FOR ft_rec IN ft_cur
      LOOP
        debug('  Inside freight cur....');
        debug('  invoice_dist_id    : '||ft_rec.invoice_distribution_id);
        debug('  line_type          : '||ft_rec.invoice_type);
        debug('  base_amount        : '||ft_rec.base_amount);

        l_ind := px_ap_ft_tbl.COUNT + 1;
        px_ap_ft_tbl(l_ind).invoice_type            := ft_rec.invoice_type;
        px_ap_ft_tbl(l_ind).chrg_dist_id            := ft_rec.invoice_distribution_id;
        px_ap_ft_tbl(l_ind).item_dist_id            := p_item_dist_id;
        px_ap_ft_tbl(l_ind).base_amount             := ft_rec.base_amount;
        px_ap_ft_tbl(l_ind).accounting_date         := ft_rec.accounting_date;
        px_ap_ft_tbl(l_ind).inv_dist_ccid           := ft_rec.inv_dist_ccid;

--        l_alloc_ft_amount := allocated_amount(p_item_dist_id, ft_rec.invoice_distribution_id);
          l_alloc_ft_amount := ft_rec.base_amount;
        debug('  allocated_amount       : '||l_alloc_ft_amount);
        px_ap_ft_tbl(l_ind).alloc_amount            := l_alloc_ft_amount;

        l_ft_amount := l_ft_amount + l_alloc_ft_amount;
        debug('l_ft_amount '||l_ft_amount);

      END LOOP;
      x_ft_amount := l_ft_amount;
      debug('TOTAL freight and tax amount         : '||l_ft_amount);
    END get_freight_and_tax;

  BEGIN
    l_in_service_flag := 'Y'; -- Bug 8565319
    cse_util_pkg.set_debug;

    debug('Inside API cse_ap_pa_pkg.process_ipv_to_pa');

    debug('  p_project_id           : '||p_project_id);


    FOR ap_inv_rec in ap_inv_ipv_cur(p_project_id)
    LOOP

      debug('invoice dist record # '||ap_inv_ipv_cur%rowcount);

      debug('  invoice_dist_id        : '||ap_inv_rec.invoice_distribution_id);
      debug('  invoice_id             : '||ap_inv_rec.invoice_id);
      debug('  po_distribution_id     : '||ap_inv_rec.po_distribution_id);
      debug('  project_id             : '||ap_inv_rec.project_id);
      debug('  task_id                : '||ap_inv_rec.task_id);
      debug('  base_amount            : '||ap_inv_rec.base_amount);
      debug('  org_id                 : '||ap_inv_rec.org_id);

      l_total_ft_amount  := 0;
      l_total_ipv_amount := 0;
      l_ap_pa_tbl.delete;

      IF ap_inv_rec.base_amount <> 0 THEN
        l_total_ipv_amount := l_total_ipv_amount + ap_inv_rec.base_amount;
      END IF;

      debug('Calling freight and tax');
/*--Modified for bug 8927385
      get_freight_and_tax(
        p_item_dist_id => ap_inv_rec.invoice_distribution_id,
        p_invoice_id   => ap_inv_rec.invoice_id,
        p_project_id   => ap_inv_rec.project_id,
        p_task_id      => ap_inv_rec.task_id,
        x_ft_amount    => l_total_ft_amount,
        px_ap_ft_tbl   => l_ap_ft_tbl);
*/--Modified for bug 8927385
      l_total_amount := l_total_ipv_amount + l_total_ft_amount;

      debug('l_total_ipv_amount '||l_total_ipv_amount);
      debug('l_total_ft_amount '||l_total_ft_amount);
      debug('l_total_amount '||l_total_amount);

      debug('TOTAL ipv and freight and tax amount : '||l_total_amount);

      IF l_total_amount <> 0 THEN

        mo_global.set_policy_context('S', ap_inv_rec.org_id);

        SELECT accts_pay_code_combination_id
        INTO   l_ap_pa_tbl(1).acct_pay_ccid
        FROM   ap_system_parameters_all
        WHERE  org_id = ap_inv_rec.org_id;

        debug('  ap_code_combination_id : '||l_ap_pa_tbl(1).acct_pay_ccid);

        SELECT item_id
        INTO   l_ap_pa_tbl(1).inventory_item_id
        FROM   po_lines_all
        WHERE  po_line_id = ap_inv_rec.po_line_id;

        debug('  inventory_item_id      : '||l_ap_pa_tbl(1).inventory_item_id);

        SELECT concatenated_segments
        INTO   l_ap_pa_tbl(1).item_name
        FROM   mtl_system_items_kfv
        WHERE  inventory_item_id = l_ap_pa_tbl(1).inventory_item_id
        AND    organization_id   = ap_inv_rec.dest_org_id;

        debug('  inventory_item         : '||l_ap_pa_tbl(1).item_name);

        SELECT name
        INTO   l_ap_pa_tbl(1).exp_org_name
        FROM   hr_all_organization_units
        WHERE  organization_id = ap_inv_rec.exp_org_id;

        debug('  organization           : '||l_ap_pa_tbl(1).exp_org_name);

        SELECT segment1
        INTO   l_ap_pa_tbl(1).project_num
        FROM   pa_projects_all
        WHERE  project_id = ap_inv_rec.project_id;

        debug('  project_number         : '||l_ap_pa_tbl(1).project_num);

        SELECT task_number
        INTO   l_ap_pa_tbl(1).task_num
        FROM   pa_tasks
        WHERE  project_id = ap_inv_rec.project_id
        AND    task_id    = ap_inv_rec.task_id;

        debug('  task_number            : '||l_ap_pa_tbl(1).task_num);

        SELECT vendor_id
        INTO   l_ap_pa_tbl(1).vendor_id
        FROM   ap_invoices_all
        WHERE  invoice_id = ap_inv_rec.invoice_id;

        debug('  vendor_id              : '||l_ap_pa_tbl(1).vendor_id);

        SELECT segment1
        INTO   l_ap_pa_tbl(1).vendor_num
        FROM   po_vendors
        WHERE  vendor_id = l_ap_pa_tbl(1).vendor_id;

        debug('  vendor_number          : '||l_ap_pa_tbl(1).vendor_num);

        cse_util_pkg.check_depreciable(
          p_inventory_item_id   => l_ap_pa_tbl(1).inventory_item_id,
          p_depreciable         => l_ap_pa_tbl(1).depreciable);

        l_ap_pa_tbl(1).exp_ending_date := pa_utils.getweekending(ap_inv_rec.expenditure_item_date);

        debug('  exp_ending_date        : '||l_ap_pa_tbl(1).exp_ending_date);

        l_ap_pa_tbl(1).invoice_id               := ap_inv_rec.invoice_id;
        l_ap_pa_tbl(1).invoice_type             := ap_inv_rec.invoice_type;
        l_ap_pa_tbl(1).invoice_line_number      := ap_inv_rec.line_number;
        l_ap_pa_tbl(1).invoice_distribution_id  := ap_inv_rec.invoice_distribution_id;
        l_ap_pa_tbl(1).invoice_distribution_type := ap_inv_rec.invoice_distribution_type;
        l_ap_pa_tbl(1).po_header_id             := ap_inv_rec.po_header_id;
        l_ap_pa_tbl(1).po_line_id               := ap_inv_rec.po_line_id;
        l_ap_pa_tbl(1).po_distribution_id       := ap_inv_rec.po_distribution_id;
        l_ap_pa_tbl(1).project_id               := ap_inv_rec.project_id;
        l_ap_pa_tbl(1).task_id                  := ap_inv_rec.task_id;
        l_ap_pa_tbl(1).expenditure_item_date    := ap_inv_rec.expenditure_item_date;
        l_ap_pa_tbl(1).expenditure_type         := ap_inv_rec.expenditure_type;
        l_ap_pa_tbl(1).exp_org_id               := ap_inv_rec.exp_org_id;
        l_ap_pa_tbl(1).dest_org_id              := ap_inv_rec.dest_org_id;
        l_ap_pa_tbl(1).org_id                   := ap_inv_rec.org_id;
        l_ap_pa_tbl(1).accounting_date          := ap_inv_rec.accounting_date;
        l_ap_pa_tbl(1).distribution_line_number := ap_inv_rec.distribution_line_number;
        l_ap_pa_tbl(1).base_amount              := l_total_amount;
        l_ap_pa_tbl(1).quantity_invoiced        := ap_inv_rec.quantity_invoiced;
        l_ap_pa_tbl(1).unit_price               := ap_inv_rec.unit_price;

				----Modified for bug 8927385
				IF ap_inv_rec.invoice_distribution_type = 'IPV' THEN
          l_ap_pa_tbl(1).inv_dist_ccid          := cse_asset_util_pkg.get_ap_sla_acct_id(
                                                     p_invoice_id        => ap_inv_rec.invoice_id,
                                                     p_invoice_dist_type => 'IPV');
				ELSIF  ap_inv_rec.invoice_distribution_type = 'FREIGHT' THEN
          l_ap_pa_tbl(1).inv_dist_ccid          := cse_asset_util_pkg.get_ap_sla_acct_id(
                                                     p_invoice_id        => ap_inv_rec.invoice_id,
                                                     p_invoice_dist_type => 'FREIGHT');
				ELSIF  ap_inv_rec.invoice_distribution_type = 'REC_TAX' THEN
          l_ap_pa_tbl(1).inv_dist_ccid          := cse_asset_util_pkg.get_ap_sla_acct_id(
                                                     p_invoice_id        => ap_inv_rec.invoice_id,
                                                     p_invoice_dist_type => 'RTAX');
				ELSIF  ap_inv_rec.invoice_distribution_type = 'NONREC_TAX' THEN
          l_ap_pa_tbl(1).inv_dist_ccid          := cse_asset_util_pkg.get_ap_sla_acct_id(
                                                     p_invoice_id        => ap_inv_rec.invoice_id,
                                                     p_invoice_dist_type => 'NRTAX');
				END IF; -- need to put TIPV for TIPV case --Modified for bug 8927385

        debug('  ipv_ccid             : '||l_ap_pa_tbl(1).inv_dist_ccid);
        IF l_ap_pa_tbl(1).inv_dist_ccid = -99 THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        get_prorated_ei(
          px_ap_pa_tbl    => l_ap_pa_tbl,
          x_in_service_flag => l_in_service_flag,  -- Bug 8565319
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_in_service_flag <> 'N' THEN  -- Bug 8565319
          populate_pa_txn_intf(
            p_ap_pa_tbl      => l_ap_pa_tbl,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);
        END IF;   -- Bug 8565319

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

      IF l_in_service_flag <> 'N' THEN  -- Bug 8565319
        debug('updating ap_invoice_distributions_all.pa_addition_flag = Y ');

        UPDATE ap_invoice_distributions_all
        SET    pa_addition_flag        = 'Y',
               last_update_date        = sysdate,
               last_updated_by         = fnd_global.user_id,
               last_update_login       = fnd_global.login_id,
               request_id              = fnd_global.conc_request_id
        WHERE  invoice_distribution_id = ap_inv_rec.invoice_distribution_id;

        UPDATE ap_invoice_distributions_all
        SET    pa_addition_flag        = 'Y',
               last_update_date        = sysdate,
               last_updated_by         = fnd_global.user_id,
               last_update_login       = fnd_global.login_id,
               request_id              = fnd_global.conc_request_id
        WHERE  charge_applicable_to_dist_id = ap_inv_rec.invoice_distribution_id;

      ELSE -- Bug 8565319
        debug('Not processing this record as the item is not in service');
      END IF;   -- Bug 8565319

      IF l_ap_ft_tbl.COUNT > 0 THEN
        FOR l_ind IN l_ap_ft_tbl.FIRST .. l_ap_ft_tbl.LAST
        LOOP

          null;
          --debug('updating ap_invoice_distributions_all.pa_addition_flag = Y ');
        END LOOP;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      l_txn_error_rec                     := CSE_UTIL_PKG.init_txn_error_Rec;
      l_txn_error_rec.error_text          := nvl(l_error_message,cse_util_pkg.dump_error_stack);
      l_txn_error_rec.source_group_ref_id := fnd_global.conc_request_id;
      l_txn_error_rec.source_type         := 'CSEIPVP';
      l_txn_error_rec.source_id           := l_inv_dist_id;
      l_txn_error_rec.processed_flag      := 'N';

      csi_transactions_pvt.create_txn_error(
        p_api_version           => 1.0 ,
        p_init_msg_list         => fnd_api.g_true,
        p_commit                => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_transaction_error_id  => l_txn_error_id);

  END process_ipv_to_pa;

END cse_ap_pa_pkg;

/
