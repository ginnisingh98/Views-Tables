--------------------------------------------------------
--  DDL for Package Body CSE_PROJ_ITEM_IN_SRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_PROJ_ITEM_IN_SRV_PKG" AS
/* $Header: CSEITSVB.pls 120.16.12010000.5 2010/04/16 20:14:03 lakmohan ship $ */

  l_debug VARCHAR2(1) := nvl(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id,-1) <> -1 THEN
        fnd_file.put_line(fnd_file.log,p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE get_fa_location_id(
    p_location_type_code  IN  varchar2,
    p_location_id         IN  number,
    x_fa_location_id      OUT nocopy number,
    x_return_status       OUT nocopy varchar2)
  IS

    l_location_table      varchar2(30);
    l_hz_or_hr            varchar2(1);

    CURSOR loc_map_cur(p_location_table IN varchar2) IS
      SELECT fa_location_id
      FROM   csi_a_locations
      WHERE  location_table in (p_location_table , 'LOCATION_CODES')
      AND    location_id    = p_location_id
      AND    sysdate BETWEEN nvl(active_start_date, sysdate - 1)
                     AND     nvl(active_end_date, sysdate + 1);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('  location_type_code   : '||p_location_type_code);
    debug('  location_id          : '||p_location_id);

    IF p_location_type_code IN ('INVENTORY', 'INTERNAL_SITE') THEN
      l_location_table := 'HR_LOCATIONS';
    ELSIF p_location_type_code = 'HZ_LOCATIONS' THEN
      BEGIN
        SELECT 'Y' INTO l_hz_or_hr
        FROM   hz_locations
        WHERE  location_id = p_location_id;
        l_location_table := 'HZ_LOCATIONS';
      EXCEPTION
        WHEN no_data_found THEN
          l_location_table := 'HR_LOCATIONS';
      END;
    ELSE
      l_location_table := p_location_type_code;
    END IF;

    FOR loc_rec IN loc_map_cur(l_location_table)
    LOOP
      x_fa_location_id := loc_rec.fa_location_id;
      exit;
    END LOOP;

    IF x_fa_location_id is null then
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_fa_location_id;

  PROCEDURE interface_nl_to_pa(
    p_in_srv_pa_attr_rec IN  cse_datastructures_pub.proj_itm_insv_pa_attr_rec_type,
    p_conc_request_id    IN  NUMBER ,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_error_message      OUT NOCOPY VARCHAR2)
  IS
    l_api_name       CONSTANT  VARCHAR2(30) := 'cse_proj_item_in_service_pkg';
    l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_error_message            VARCHAR2(2000);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_api_version              NUMBER         DEFAULT  1.0;
    l_commit                   VARCHAR2(1)    DEFAULT  FND_API.G_FALSE;
    l_init_msg_list            VARCHAR2(1)    DEFAULT  FND_API.G_TRUE;
    l_validation_level         NUMBER         DEFAULT  FND_API.G_VALID_LEVEL_FULL;
    l_active_instance_only     VARCHAR2(1)    DEFAULT  FND_API.G_TRUE;
    l_txn_rec                  csi_datastructures_pub.transaction_rec;
    l_asset_location_rec       csi_datastructures_pub.instance_asset_location_rec;
    l_asset_location_tbl       csi_datastructures_pub.instance_asset_location_tbl;
    l_nl_pa_interface_tbl      CSE_IPA_TRANS_PKG.nl_pa_interface_tbl_type;
    l_nl_pa_interface_rec      CSE_IPA_TRANS_PKG.nl_pa_interface_rec_type;
    l_burden_cost_sum          NUMBER;
    l_qty_sum                  NUMBER;
    l_sum_of_qty               NUMBER;
    l_fa_location_id           NUMBER;
    l_attribute8               VARCHAR2(150);
    l_attribute9               VARCHAR2(150);
    l_attribute10              VARCHAR2(150);
    l_Proj_Itm_Insv_qty        NUMBER;

    l_book_type_code           varchar2(30);  -- Bug 6492235, changed to support multiple FA book
    l_dpis                     date;
    l_fa_period_name           varchar2(15);
    l_serial_code              number;

    l_location_id              NUMBER;
    l_location_type_code       varchar2(30);

    i                          PLS_INTEGER := 0;
    l_org_id                   NUMBER;
    l_incurred_by_org_id       PA_EXPENDITURES_ALL.INCURRED_BY_ORGANIZATION_ID%TYPE;
    l_item_name                MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
    l_user_id                  NUMBER  DEFAULT FND_GLOBAL.USER_ID;
    l_transaction_source       PA_EXPENDITURE_ITEMS_ALL.TRANSACTION_SOURCE%TYPE;
    l_sysdate                  date:=sysdate;
    l_ref_sufix                NUMBER;

    l_project_number           varchar2(25);
    l_task_number              varchar2(25);
    l_organization_name        varchar2(240);

    l_ou_id                    number; -- Bug 6492235, added to support multiple FA book
	l_skip_interface           boolean := FALSE;
    TYPE exp_item_rec IS RECORD (
      expenditure_item_id number,
      expenditure_id      number,
      quantity            number,
      split_flag          varchar2(1),
      split_quantity      number);

    l_exp_item_rec  exp_item_rec;

    CURSOR ei_cur IS
      SELECT item.expenditure_item_id,
             item.project_id,
             item.task_id,
             item.transaction_source,
             item.org_id,
             item.expenditure_type,
             item.expenditure_item_date,
             item.denom_currency_code,
             item.attribute6,
             item.attribute7,
             item.quantity        quantity,
             item.raw_cost        raw_cost,
             item.denom_raw_cost  denom_raw_cost,
             item.denom_raw_cost/item.quantity unit_denom_raw_cost,
             item.raw_cost_rate,
             item.burden_cost     burden_cost,
             item.burden_cost/item.quantity burden_cost_rate,
             item.override_to_organization_id,
             item.system_linkage_function,
             item.orig_transaction_reference,
             dist.dr_code_combination_id,
             dist.cr_code_combination_id,
             dist.gl_date,
             dist.acct_raw_cost,
             dist.system_reference1,
             dist.system_reference2,
             dist.system_reference3,
             dist.system_reference4,
             dist.system_reference5,
             exp.expenditure_id,
             exp.expenditure_ending_date,
             exp.incurred_by_organization_id,
             item.vendor_id,
             item.po_line_id,
             item.inventory_item_id,
             item.document_type,
             item.document_distribution_type
      FROM   pa_expenditure_items_all        item,
             pa_cost_distribution_lines_all  dist,
             pa_expenditures_all             exp
      WHERE  item.transaction_source IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
      AND    item.project_id          = p_in_srv_pa_attr_rec.project_id
      AND    item.task_id             = p_in_srv_pa_attr_rec.task_id
      AND    item.attribute8         IS null
      AND    item.attribute9         IS null
      AND    item.attribute10        IS null
      AND    item.quantity            > 0
      AND    item.attribute6          = l_item_name
      AND    nvl(item.attribute7, '**xyz**') = NVL(p_in_srv_pa_attr_rec.serial_number, '**xyz**')
      AND    nvl(item.net_zero_adjustment_flag, 'N') <> 'Y'
      AND    dist.expenditure_item_id = item.expenditure_item_id
      AND    dist.line_type           = 'R'
      AND    nvl(dist.reversed_flag, 'N') <> 'Y'
      AND    dist.cr_code_combination_id IS NOT NULL
      AND    dist.dr_code_combination_id IS NOT NULL
      AND    exp.expenditure_id       = item.expenditure_id
      AND    item.expenditure_item_id NOT IN (SELECT  NVL(adjusted_expenditure_item_id,0)   --Added for bug 9263804 expenditures already reversed should not be considered
                                         FROM    pa_transaction_interface_all
                                         WHERE   transaction_source IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
                                         AND     attribute8         IS null
                                         AND     attribute9         IS null
                                         AND     attribute10        IS null);

    subtype ei_cur_rec is ei_cur%rowtype;

    l_fa_group_by            varchar2(30);

    skip_this_ei             exception ;
    l_rcv_sub_ledger_id      number;

    PROCEDURE reversal_exp_item(
      p_csi_txn_id           IN  number,
      p_organization_name    IN  varchar2,
      p_project_number       IN  varchar2,
      p_task_number          IN  varchar2,
      p_item_name            IN  varchar2,
      p_ei_rec               IN  ei_cur_rec,
      x_nl_pa_interface_rec  OUT nocopy CSE_IPA_TRANS_PKG.nl_pa_interface_rec_type)
    IS
      l_ref_suffix_inner     number;  -- Changes for bug 7368371
    BEGIN

      SELECT csi_pa_interface_s.nextval
      INTO   l_ref_suffix_inner       -- Changes for bug 7368371
      FROM   sys.dual;

      x_nl_pa_interface_rec.transaction_source      := p_ei_rec.transaction_source;
      x_nl_pa_interface_rec.batch_name              := p_in_srv_pa_attr_rec.transaction_id;
      x_nl_pa_interface_rec.expenditure_ending_date := p_ei_rec.expenditure_ending_date;
      x_nl_pa_interface_rec.employee_number         := null;
      x_nl_pa_interface_rec.organization_name       := p_organization_name;
      x_nl_pa_interface_rec.expenditure_item_date   := p_ei_rec.expenditure_item_date;
      x_nl_pa_interface_rec.project_number          := p_project_number;
      x_nl_pa_interface_rec.task_number             := p_task_number;
      x_nl_pa_interface_rec.expenditure_type        := p_ei_rec.expenditure_type;
      x_nl_pa_interface_rec.expenditure_comment     := 'ENTERPRISE INSTALL BASE';
      x_nl_pa_interface_rec.transaction_status_code := 'P';
      x_nl_pa_interface_rec.orig_transaction_reference := p_csi_txn_id||'-'||l_ref_suffix_inner;  -- Changes for bug 7368371
      x_nl_pa_interface_rec.attribute_category      := NULL;
      x_nl_pa_interface_rec.attribute1              := NULL;
      x_nl_pa_interface_rec.attribute2              := NULL;
      x_nl_pa_interface_rec.attribute3              := NULL;
      x_nl_pa_interface_rec.attribute4              := NULL;
      x_nl_pa_interface_rec.attribute5              := NULL;
      x_nl_pa_interface_rec.attribute6              := p_item_name;
      x_nl_pa_interface_rec.attribute7              := p_ei_rec.attribute7;
      x_nl_pa_interface_rec.attribute8              := null;
      x_nl_pa_interface_rec.attribute9              := null;
      x_nl_pa_interface_rec.attribute10             := null;
      x_nl_pa_interface_rec.interface_id            := NULL;
      x_nl_pa_interface_rec.unmatched_negative_txn_flag := 'N';
      x_nl_pa_interface_rec.org_id                  := p_ei_rec. org_id;
      x_nl_pa_interface_rec.dr_code_combination_id  := p_ei_rec.dr_code_combination_id;
      x_nl_pa_interface_rec.cr_code_combination_id  := p_ei_rec.cr_code_combination_id;
      x_nl_pa_interface_rec.gl_date                 := p_ei_rec.gl_date;
      x_nl_pa_interface_rec.system_linkage          := p_ei_rec.system_linkage_function;
      IF p_ei_rec.transaction_source = 'CSE_PO_RECEIPT' THEN
        BEGIN
          SELECT segment1
          INTO   x_nl_pa_interface_rec.vendor_number
          FROM   po_vendors
          WHERE  vendor_id =  p_ei_rec.system_reference1;
        EXCEPTION
          WHEN no_data_found THEN
            x_nl_pa_interface_rec.system_linkage     := 'INV';
        END;
      END IF;
      x_nl_pa_interface_rec.user_transaction_source := 'ENTERPRISE INSTALL BASE';
      x_nl_pa_interface_rec.cdl_system_reference1   := p_ei_rec.system_reference1;
      x_nl_pa_interface_rec.cdl_system_reference2   := p_ei_rec.system_reference2;
      x_nl_pa_interface_rec.cdl_system_reference3   := p_ei_rec.system_reference3;
      x_nl_pa_interface_rec.cdl_system_reference4   := p_ei_rec.system_reference4;
      x_nl_pa_interface_rec.cdl_system_reference5   := p_ei_rec.system_reference5;
      x_nl_pa_interface_rec.last_update_date        := sysdate;
      x_nl_pa_interface_rec.last_updated_by         := fnd_global.user_id;
      x_nl_pa_interface_rec.creation_date           := sysdate;
      x_nl_pa_interface_rec.created_by              := fnd_global.user_id;
      x_nl_pa_interface_rec.billable_flag           := 'Y';
      x_nl_pa_interface_rec.quantity                := -1*(p_ei_rec.quantity);
      x_nl_pa_interface_rec.denom_raw_cost          :=
        p_ei_rec.unit_denom_raw_cost * x_nl_pa_interface_rec.quantity;
      x_nl_pa_interface_rec.acct_raw_cost           :=
        p_ei_rec.unit_denom_raw_cost * x_nl_pa_interface_rec.quantity;
      x_nl_pa_interface_rec.net_zero_adjustment_flag := 'Y';
      x_nl_pa_interface_rec.adjusted_expenditure_item_id := p_ei_rec.expenditure_item_id;
      x_nl_pa_interface_rec.vendor_id                  := p_ei_rec.vendor_id;
      x_nl_pa_interface_rec.inventory_item_id          := p_ei_rec.inventory_item_id;
      x_nl_pa_interface_rec.po_line_id                 := p_ei_rec.po_line_id;
      x_nl_pa_interface_rec.project_id                 := p_ei_rec.project_id;
      x_nl_pa_interface_rec.task_id                    := p_ei_rec.task_id;
      x_nl_pa_interface_rec.document_type              := p_ei_rec.document_type;
      x_nl_pa_interface_rec.document_distribution_type := p_ei_rec.document_distribution_type;
    END reversal_exp_item;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := NULL;

    cse_util_pkg.set_debug;

    debug('Inside API cse_proj_item_in_srv_pkg.interface_nl_to_pa');

    debug('  inventory_item_id    : '||p_in_srv_pa_attr_rec.item_id);
    debug('  organization_id      : '||p_in_srv_pa_attr_rec.inv_master_org_id);
    debug('  project_id           : '||p_in_srv_pa_attr_rec.project_id);
    debug('  task_id              : '||p_in_srv_pa_attr_rec.task_id);
    debug('  serial_number        : '||p_in_srv_pa_attr_rec.serial_number);
    debug('  transaction_id       : '||p_in_srv_pa_attr_rec.transaction_id);
    debug('  in_service_qty       : '||p_in_srv_pa_attr_rec.quantity);
    debug('  org_id               : '||p_in_srv_pa_attr_rec.org_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_fa_group_by := csi_datastructures_pub.g_install_param_rec.fa_creation_group_by;

    SELECT concatenated_segments,
           serial_number_control_code
    INTO   l_item_name,
           l_serial_code
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = p_in_srv_pa_attr_rec.item_id
    AND    organization_id   = p_in_srv_pa_attr_rec.inv_master_org_id;

    debug('  item                 : '||l_item_name);

    l_location_id        := p_in_srv_pa_attr_rec.location_id;
    l_location_type_code := p_in_srv_pa_attr_rec.location_type;

    IF p_in_srv_pa_attr_rec.location_type ='HZ_PARTY_SITES' THEN

      debug('Inside API cse_util_pkg.get_hz_location');

      cse_util_pkg.get_hz_location (
        p_party_site_id  => p_in_srv_pa_attr_rec.location_id,
        x_hz_location_id => l_location_id,
        x_Return_Status  => l_return_status,
        x_Error_Message  => l_error_message );

      l_location_type_code := 'HZ_LOCATIONS';

    END IF;

    get_fa_location_id(
      p_location_type_code  => l_location_type_code,
      p_location_id         => l_location_id,
      x_fa_location_id      => l_fa_location_id,
      x_return_status       => l_return_status);

    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
      fnd_message.set_token('ASSET_ATTRIBUTE','LOCATION');
      fnd_message.set_token('CSI_TRANSACTION_ID',p_in_srv_pa_attr_rec.transaction_id);
      l_error_message := fnd_message.get;
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  fa_location_id       : '||l_fa_location_id);

    debug('Inside API cse_ipa_trans_pkg.get_grouping_attribute');

    cse_ipa_trans_pkg.get_grouping_attribute(
      p_item_id         => p_in_srv_pa_attr_rec.item_id,
      p_organization_id => p_in_srv_pa_attr_rec.inv_master_org_id,
      p_project_id      => p_in_srv_pa_attr_rec.project_id,
      p_fa_location_id  => l_fa_location_id,
      p_transaction_id  => p_in_srv_pa_attr_rec.transaction_id,
      p_org_id          => p_in_srv_pa_attr_rec.org_id,
      x_attribute8      => l_attribute8,
      x_attribute9      => l_attribute9,
      x_attribute10     => l_attribute10,
      x_return_status   => l_return_status,
      x_error_message   => l_error_message);

    debug('  attribute8       : '||l_attribute8);
    debug('  attribute9       : '||l_attribute9);
    debug('  attribute10      : '||l_attribute10);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('CSE_IPA_TRANS_PKG.get_grouping_attribute failed : '||l_error_message);
      RAISE fnd_api.g_exc_error;
    END IF;

    SELECT segment1, org_id           -- Bug 6492235, changed to support multiple FA book
    INTO   l_project_number, l_ou_id  -- Bug 6492235, changed to support multiple FA book
    FROM   pa_projects_all
    WHERE  project_id = p_in_srv_pa_attr_rec.project_id;

	BEGIN
		SELECT task_number
		INTO   l_task_number
		FROM   pa_tasks
		WHERE  task_id = p_in_srv_pa_attr_rec.task_id;
	EXCEPTION
		WHEN no_data_found THEN
			l_skip_interface := TRUE;
	END;

	IF l_skip_interface = FALSE THEN
    	SELECT source_transaction_date
    	INTO   l_dpis
    	FROM   csi_transactions
    	WHERE  transaction_id = p_in_srv_pa_attr_rec.transaction_id;

	    -- Bug 6492235, added to support multiple FA book
    	l_book_type_code := fnd_profile.VALUE_SPECIFIC(
         			name => 'cse_fa_book_type_code',
         			ORG_ID => l_ou_id
         			);

    	l_fa_period_name := cse_asset_util_pkg.get_fa_period_name (l_book_type_code, l_dpis);

	    l_proj_itm_insv_qty := p_in_srv_pa_attr_rec.quantity;
	    i := 0;

    	FOR ei_rec IN ei_cur LOOP

      	debug('cursor record # '||ei_cur%rowcount);

    	debug('  expenditure_item_id  : '||ei_rec.expenditure_item_id);
      	debug('  quantity             : '||ei_rec.quantity);
      	debug('  l_proj_itm_insv_qty  : '||l_proj_itm_insv_qty);

      	debug('  transaction_source   : '||ei_rec.transaction_source);
      	debug('  system_reference4    : '||ei_rec.system_reference4);
      	debug('  system_reference5    : '||ei_rec.system_reference5);

      	BEGIN

	        -- accrual at period end cases. for accrual at receipt cases we will have system_ref5 populated
        	IF ei_rec.transaction_source = 'CSE_PO_RECEIPT' AND ei_rec.system_reference5 is null THEN

          	-- check if the period end accrual is done
          	l_rcv_sub_ledger_id := cse_asset_util_pkg.get_rcv_sub_ledger_id(ei_rec.system_reference4);
          	debug('  rcv_sub_ledger_id    : '||l_rcv_sub_ledger_id);

          	IF l_rcv_sub_ledger_id is null THEN
            	debug('  rcv sub ledger id not found. receipt not accounted yet. skipping this ei to be placed in service.');
            	RAISE skip_this_ei;
          	END IF;

        	END IF;

        	IF l_proj_itm_insv_qty = 0 THEN
          		exit;
        	END IF;

        	IF ei_rec.quantity <= l_proj_itm_insv_qty THEN
          		l_proj_itm_insv_qty := l_proj_itm_insv_qty - ei_rec.quantity;
          		l_exp_item_rec.expenditure_item_id := ei_rec.expenditure_item_id;
          		l_exp_item_rec.expenditure_id      := ei_rec.expenditure_id;
          		l_exp_item_rec.quantity            := ei_rec.quantity;
          		l_exp_item_rec.split_flag          := 'N';
        	ELSE
          		l_exp_item_rec.expenditure_item_id := ei_rec.expenditure_item_id;
          		l_exp_item_rec.expenditure_id      := ei_rec.expenditure_id;
          		l_exp_item_rec.quantity            := l_proj_itm_insv_qty;
          		l_exp_item_rec.split_flag          := 'Y';
          		l_exp_item_rec.split_quantity      := ei_rec.quantity - l_proj_itm_insv_qty;
        	END IF;

        	SELECT name
        	INTO   l_organization_name
        	FROM   hr_organization_units
        	WHERE  organization_id =
               nvl(ei_rec.override_to_organization_id, ei_rec.incurred_by_organization_id);

        	reversal_exp_item(
          		p_csi_txn_id           => p_in_srv_pa_attr_rec.transaction_id,
          		p_organization_name    => l_organization_name,
          		p_project_number       => l_project_number,
          		p_task_number          => l_task_number,
          		p_item_name            => l_item_name,
          		p_ei_rec               => ei_rec,
          		x_nl_pa_interface_rec  => l_nl_pa_interface_rec);

	        i := i+1;

	        debug('reversal record      # '||i);
        	l_nl_pa_interface_tbl(i) := l_nl_pa_interface_rec;

	        i := i+1;

    	    debug('capitalizable record # '||i);
        	debug('  capitalizable exp_item_id : '||l_exp_item_rec.expenditure_item_id);
        	debug('  capitalizable quantity    : '||l_exp_item_rec.quantity);

        	SELECT csi_pa_interface_s.nextval
        	INTO   l_ref_sufix
        	FROM   sys.dual;

	        l_nl_pa_interface_tbl(i).transaction_source      := ei_rec.transaction_source;
    	    l_nl_pa_interface_tbl(i).batch_name              := p_in_srv_pa_attr_rec.transaction_id;
        	l_nl_pa_interface_tbl(i).expenditure_ending_date := ei_rec.expenditure_ending_date;
        	l_nl_pa_interface_tbl(i).employee_number         := null;
        	l_nl_pa_interface_tbl(i).organization_name       := l_organization_name;
        	l_nl_pa_interface_tbl(i).expenditure_item_date   := ei_rec.expenditure_item_date;
        	l_nl_pa_interface_tbl(i).project_number          := l_project_number;
        	l_nl_pa_interface_tbl(i).task_number             := l_task_number;
        	l_nl_pa_interface_tbl(i).expenditure_type        := ei_rec.expenditure_type;
        	l_nl_pa_interface_tbl(i).expenditure_comment     := 'ENTERPRISE INSTALL BASE';
        	l_nl_pa_interface_tbl(i).transaction_status_code := 'P';
        	l_nl_pa_interface_tbl(i).orig_transaction_reference
                                 := p_in_srv_pa_attr_rec.instance_id||'-'||l_ref_sufix;
        	l_nl_pa_interface_tbl(i).attribute_category      := NULL;
        	l_nl_pa_interface_tbl(i).attribute1              := NULL;
        	l_nl_pa_interface_tbl(i).attribute2              := NULL;
        	l_nl_pa_interface_tbl(i).attribute3              := NULL;
        	l_nl_pa_interface_tbl(i).attribute4              := NULL;
        	l_nl_pa_interface_tbl(i).attribute5              := NULL;
        	l_nl_pa_interface_tbl(i).attribute6              := l_item_name;
        	IF l_serial_code in (2, 5) THEN
          		IF l_fa_group_by = 'ITEM' THEN
            		l_nl_pa_interface_tbl(i).attribute7          := l_fa_period_name;
          		ELSE
            		l_nl_pa_interface_tbl(i).attribute7          := p_in_srv_pa_attr_rec.serial_number;
          		END IF;
        	ELSE
          		l_nl_pa_interface_tbl(i).attribute7            := l_fa_period_name;
        	END IF;
        	l_nl_pa_interface_tbl(i).attribute8              := l_attribute8;
        	l_nl_pa_interface_tbl(i).attribute9              := l_attribute9;
        	l_nl_pa_interface_tbl(i).attribute10             := l_attribute10;
        	l_nl_pa_interface_tbl(i).interface_id            := NULL;
        	l_nl_pa_interface_tbl(i).unmatched_negative_txn_flag := 'Y';
        	l_nl_pa_interface_tbl(i).org_id                  := ei_rec. org_id;
        	l_nl_pa_interface_tbl(i).dr_code_combination_id  := ei_rec.dr_code_combination_id;
        	l_nl_pa_interface_tbl(i).cr_code_combination_id  := ei_rec.cr_code_combination_id;
        	l_nl_pa_interface_tbl(i).gl_date                 := ei_rec.gl_date;
        	l_nl_pa_interface_tbl(i).system_linkage          := ei_rec.system_linkage_function;
        	IF ei_rec.transaction_source = 'CSE_PO_RECEIPT' THEN
          		BEGIN
            		SELECT segment1
            		INTO   l_nl_pa_interface_tbl(i).vendor_number
            		FROM   po_vendors
            		WHERE  vendor_id =  ei_rec.system_reference1;
          		EXCEPTION
            		WHEN no_data_found THEN
              			l_nl_pa_interface_tbl(i).system_linkage     := 'INV';
          		END;
        	END IF;
        	l_nl_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE';
        	l_nl_pa_interface_tbl(i).cdl_system_reference1   := ei_rec.system_reference1;
        	l_nl_pa_interface_tbl(i).cdl_system_reference2   := ei_rec.system_reference2;
        	l_nl_pa_interface_tbl(i).cdl_system_reference3   := ei_rec.system_reference3;
        	l_nl_pa_interface_tbl(i).cdl_system_reference4   := ei_rec.system_reference4;
        	IF ei_rec.transaction_source = 'CSE_PO_RECEIPT' AND ei_rec.system_reference5 is NULL THEN
          		l_nl_pa_interface_tbl(i).cdl_system_reference5 := l_rcv_sub_ledger_id;
        	ELSE
          		l_nl_pa_interface_tbl(i).cdl_system_reference5   := ei_rec.system_reference5;
        	END IF;
        		l_nl_pa_interface_tbl(i).last_update_date        := l_sysdate;
        		l_nl_pa_interface_tbl(i).last_updated_by         := l_user_id;
        		l_nl_pa_interface_tbl(i).creation_date           := l_sysdate;
        		l_nl_pa_interface_tbl(i).created_by              := l_user_id;
        		l_nl_pa_interface_tbl(i).billable_flag           := 'Y';
        		l_nl_pa_interface_tbl(i).quantity                := l_exp_item_rec.quantity;
        		l_nl_pa_interface_tbl(i).denom_raw_cost          :=
          		ei_rec.unit_denom_raw_cost * l_exp_item_rec.quantity;
        		l_nl_pa_interface_tbl(i).acct_raw_cost           :=
          		ei_rec.unit_denom_raw_cost * l_exp_item_rec.quantity;
        		l_nl_pa_interface_tbl(i).vendor_id                  := ei_rec.vendor_id;
        		l_nl_pa_interface_tbl(i).inventory_item_id          := ei_rec.inventory_item_id;
        		l_nl_pa_interface_tbl(i).po_line_id                 := ei_rec.po_line_id;
        		l_nl_pa_interface_tbl(i).project_id                 := ei_rec.project_id;
        		l_nl_pa_interface_tbl(i).task_id                    := ei_rec.task_id;
        		l_nl_pa_interface_tbl(i).document_type              := ei_rec.document_type;
        		l_nl_pa_interface_tbl(i).document_distribution_type := ei_rec.document_distribution_type;

    	    IF l_exp_item_rec.split_flag = 'Y' THEN
         		i := i + 1;
          		debug('spillover record # '||i);
          		debug('  spillover exp_item_id : '|| l_exp_item_rec.expenditure_item_id);
          		debug('  spillover quantity    : '|| l_exp_item_rec.split_quantity);

        		l_nl_pa_interface_tbl(i) := l_nl_pa_interface_tbl(i-1);

          		SELECT csi_pa_interface_s.nextval
          		INTO   l_ref_sufix
          		FROM   sys.dual;

    		    l_nl_pa_interface_tbl(i).orig_transaction_reference := p_in_srv_pa_attr_rec.transaction_id;
          		l_nl_pa_interface_tbl(i).attribute8            := null;
          		l_nl_pa_interface_tbl(i).attribute9            := null;
          		l_nl_pa_interface_tbl(i).attribute10           := null;
          		l_nl_pa_interface_tbl(i).quantity              := l_exp_item_rec.split_quantity;
          		l_nl_pa_interface_tbl(i).denom_raw_cost        :=
                	ei_rec.unit_denom_raw_cost * l_exp_item_rec.split_quantity;
          		l_nl_pa_interface_tbl(i).acct_raw_cost         :=
                                   ei_rec.unit_denom_raw_cost * l_exp_item_rec.split_quantity;
          		exit;
        	END IF;

      	EXCEPTION
        	WHEN skip_this_ei THEN
          		debug('skipped this expenditure_item_id : '||ei_rec.expenditure_item_id);
      	END;

    	END LOOP;

    	debug('l_nl_pa_interface_tbl.count : '||l_nl_pa_interface_tbl.COUNT);

    	IF l_nl_pa_interface_tbl.COUNT > 0 THEN

      		debug('Inside API cse_ipa_trans_pkg.populate_pa_interface');

      		cse_ipa_trans_pkg.populate_pa_interface(
        		p_nl_pa_interface_tbl => l_nl_pa_interface_tbl,
        		x_return_status       => l_return_status,
        		x_error_message       => l_error_message);

    		IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
        		debug('error_ message : '||l_error_message);
        		RAISE fnd_api.g_exc_error;
      		END IF;

      	--update transaction record with new txn_status_code = 'INTERFACE_TO_PA'
      		l_txn_rec                         := CSE_UTIL_PKG.init_txn_rec;
      		l_txn_rec.transaction_id          := p_in_srv_pa_attr_rec.transaction_id;
      		l_txn_rec.source_group_ref_id     := p_conc_request_id;
      		l_txn_rec.source_header_ref_id    := p_in_srv_pa_attr_rec.project_id;
      		l_txn_rec.source_header_ref       := l_project_number;
      		l_txn_rec.source_line_ref_id      := p_in_srv_pa_attr_rec.task_id;
      		l_txn_rec.source_line_ref         := l_task_number;
      		l_txn_rec.transaction_status_code := cse_datastructures_pub.G_INTERFACED_TO_PA;
      		--Begin Changes for Bug 7354734
      		--l_txn_rec.object_version_number   := p_in_srv_pa_attr_rec.object_version_number;

    		BEGIN
				SELECT  object_version_number
        		INTO    l_txn_rec.object_version_number
        		FROM    csi_transactions
        		WHERE   transaction_id = p_in_srv_pa_attr_rec.transaction_id;
      		EXCEPTION
      			WHEN OTHERS THEN
        			fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
        			fnd_message.set_token('ERR_MSG',l_api_name||'='|| SQLERRM);
        			x_error_message := fnd_message.get;
        			x_return_status := fnd_api.g_ret_sts_unexp_error;
        			debug('Inside OTHERS in interface_nl_to_pa : ' ||x_error_message);
      		END;
      		--End Changes for Bug 7354734

	      debug('Inside API csi_transactions_pvt.update_transactions');
    	  debug('  transaction_id : '||l_txn_rec.transaction_id);

	      csi_transactions_pvt.update_transactions(
        	p_api_version      => l_api_version,
        	p_init_msg_list    => l_init_msg_list,
        	p_commit           => l_commit,
        	p_validation_level => l_validation_level,
        	p_transaction_rec  => l_txn_rec,
        	x_return_status    => l_return_status,
        	x_msg_count        => l_msg_count,
        	x_msg_data         => l_msg_data);

	      IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        	l_error_message := cse_util_pkg.dump_error_stack ;
        	RAISE fnd_api.g_exc_error;
      	  END IF;
    	END IF;

  END IF; -- End l_skip_interface
	EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := l_return_status;
      x_error_message := l_error_message;
      debug('error  in interface_nl_to_pa : '||x_error_message);
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG',l_api_name||'='|| SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      debug('Inside OTHERS in interface_nl_to_pa : ' ||x_error_message);
  END interface_nl_to_pa;

  PROCEDURE interface_nl_to_pa(
    p_in_srv_pa_attr_tbl  IN CSE_DATASTRUCTURES_PUB.Proj_Itm_Insv_PA_ATTR_tbl_TYPE,
    p_conc_request_id               IN  NUMBER DEFAULT NULL,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_error_message                 OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF NOT p_in_srv_pa_attr_tbl.COUNT = 0 THEN

      FOR i IN p_in_srv_pa_attr_tbl.FIRST .. p_in_srv_pa_attr_tbl.LAST
      LOOP
        IF p_in_srv_pa_attr_tbl.EXISTS(i) THEN
          interface_nl_to_pa( p_in_srv_pa_attr_tbl(i),
                            p_conc_request_id,
                            x_return_status,
                            x_error_message);
        END IF;

      END LOOP;
    END IF; -- tbl.count IF
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG','CSE_PROJ_ITEM_IN_SRV_PKG.Interface_Nl_To_PA'||'='|| SQLERRM);
      x_error_message := fnd_message.get;
      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  END interface_nl_to_pa;

END cse_proj_item_in_srv_pkg;

/
