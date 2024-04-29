--------------------------------------------------------
--  DDL for Package Body CSE_COST_COLLECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_COST_COLLECTOR" AS
/* $Header: CSECSTHB.pls 120.9.12010000.1 2008/07/30 05:17:16 appldev ship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

  PROCEDURE debug(p_message IN varchar2) IS
  BEGIN
    IF (l_debug = 'Y') THEN
      cse_debug_pub.add (p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log,p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE eib_cost_collector_stub(
    p_transaction_id             IN NUMBER,
    p_organization_id            IN NUMBER,
    p_transaction_action_id      IN NUMBER,
    p_transaction_source_type_id IN NUMBER,
    p_type_class                 IN NUMBER,
    p_project_id                 IN NUMBER,
    p_task_id                    IN NUMBER,
    p_transaction_date           IN DATE,
    p_primary_quantity           IN NUMBER,
    p_cost_group_id              IN NUMBER,
    p_transfer_cost_group_id     IN NUMBER,
    p_inventory_item_id          IN NUMBER,
    p_transaction_source_id      IN NUMBER,
    p_to_project_id              IN NUMBER,
    p_to_task_id                 IN NUMBER,
    p_source_project_id          IN NUMBER,
    p_source_task_id             IN NUMBER,
    p_transfer_transaction_id    IN NUMBER,
    p_primary_cost_method        IN NUMBER,
    p_acct_period_id             IN NUMBER,
    p_exp_org_id                 IN NUMBER,
    p_distribution_account_id    IN NUMBER,
    p_proj_job_ind               IN NUMBER,
    p_first_matl_se_exp_type     IN VARCHAR2,
    p_inv_txn_source_literal     IN VARCHAR2,
    p_cap_txn_source_literal     IN VARCHAR2,
    p_inv_syslink_literal        IN VARCHAR2,
    p_bur_syslink_literal        IN VARCHAR2,
    p_wip_syslink_literal        IN VARCHAR2,
    p_user_def_exp_type          IN NUMBER,
    p_transfer_organization_id   IN NUMBER,
    p_flow_schedule              IN VARCHAR2,
    p_si_asset_yes_no            IN NUMBER,
    p_transfer_si_asset_yes_no   IN NUMBER,
    p_denom_currency_code        IN VARCHAR2,
    p_exp_type                   IN VARCHAR2,
    p_dr_code_combination_id     IN NUMBER,
    p_cr_code_combination_id     IN NUMBER,
    p_raw_cost                   IN NUMBER,
    p_burden_cost                IN NUMBER,
    p_cr_sub_ledger_id           IN number default null,
    p_dr_sub_ledger_id           IN number default null,
    p_cost_element_id            IN number,
    o_hook_used                  OUT NOCOPY NUMBER,
    o_err_num                    OUT NOCOPY NUMBER,
    o_err_code                   OUT NOCOPY NUMBER,
    o_err_msg                    OUT NOCOPY NUMBER)
  IS
    CURSOR cse_transactions_cur (c_txn_id IN NUMBER) IS
      SELECT cii.serial_number       serial_number,
             ct.transaction_quantity transaction_quantity,
             ct.transaction_id       transaction_id,
             'TO_PROJECT'            issue_type
      FROM   csi_item_instances cii,
             csi_item_instances_h ciih,
             csi_transactions ct
      WHERE  cii.instance_id = ciih.instance_id
      AND    ciih.transaction_id = ct.transaction_id
      AND    ct.inv_material_transaction_id = c_txn_id
      AND    ct.transaction_type_id  IN (
             cse_util_pkg.get_txn_type_id('MISC_ISSUE_TO_PROJECT','INV'),
             cse_util_pkg.get_txn_type_id('MOVE_ORDER_ISSUE_TO_PROJECT','INV'))
      AND    NVL(ciih.new_location_type_code, cii.location_type_code)= 'PROJECT'
      UNION
      SELECT cii.serial_number       serial_number,
             ct.transaction_quantity transaction_quantity,
             ct.transaction_id       transaction_id,
             'FROM_PROJECT'          issue_type
      FROM   csi_item_instances cii,
             csi_item_instances_h ciih,
             csi_transactions ct
      WHERE  cii.instance_id = ciih.instance_id
      AND    ciih.transaction_id = ct.transaction_id
      AND    ct.inv_material_transaction_id = c_txn_id
      AND    ct.transaction_type_id  IN(
                   cse_util_pkg.get_txn_type_id('MISC_RECEIPT_FROM_PROJECT','INV'))
      AND    NVL(ciih.new_location_type_code, cii.location_type_code) = 'INVENTORY'
      ORDER BY 1 DESC;

    CURSOR mtl_trx_cur (l_transaction_id IN NUMBER) IS
      SELECT mmt.transaction_quantity ,
             mtt.transaction_source_type_id,
             mtt.type_class,
             mtt.transaction_action_id
      FROM   mtl_material_transactions mmt,
             mtl_trx_types_view mtt
      WHERE  mmt.transaction_id        = l_transaction_id
      AND    ((mmt.transaction_action_id = 1 AND mmt.transaction_source_type_id = 4)
               OR
              (mmt.transaction_action_id = 1 AND mmt.transaction_source_type_id = 13)
               OR
              (mmt.transaction_action_id = 27 AND mmt.transaction_source_type_id = 13))
      AND    mtt.transaction_type_id = mmt.transaction_type_id
      AND    mtt.type_class = 1;

    CURSOR org_name_cur (l_exp_org_id IN NUMBER) IS
      SELECT name
      FROM   hr_organization_units hr
      WHERE  hr.organization_id = l_exp_org_id;

    CURSOR proj_number_cur (l_source_project_id IN NUMBER) IS
      SELECT  segment1
      FROM    pa_projects_all
      WHERE   project_id = l_source_project_id;

    CURSOR task_number_cur (l_source_task_id IN NUMBER, l_source_project_id IN NUMBER) IS
      SELECT  task_number
      FROM    pa_tasks task
      WHERE   task_id = l_source_task_id
      AND     project_id = l_source_project_id;

    CURSOR item_name_cur (p_item_id IN NUMBER, p_organization_id IN NUMBER) IS
      SELECT concatenated_segments
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = p_item_id
      AND    organization_id = p_organization_id;

    CURSOR gl_date_cur (l_organization_id IN NUMBER, l_acct_period_id  IN NUMBER) IS
      SELECT schedule_close_date
      FROM   org_acct_periods oap
      WHERE  oap.organization_id = l_organization_id
      AND    oap.acct_period_id = l_acct_period_id;

    CURSOR c_costing IS
      SELECT NVL(FND_PROFILE.VALUE('CSE_EIB_COSTING_USED'),'Y')
      FROM   sys.dual;

    l_org_name        hr_all_organization_units.name%TYPE;
    l_project_number  pa_projects_all.segment1%TYPE;
    l_task_number     pa_tasks.task_number%TYPE;
    l_eib_trackable_flag VARCHAR2(5);
    l_item_name       mtl_system_items.segment1%TYPE;
    l_exp_item_date   DATE ;
    l_exp_end_date    DATE ;
    l_gl_date         DATE ;
    l_eib_installed    VARCHAR2(1);
    l_user_id         NUMBER ;
    l_err_msg         VARCHAR2(1000);
    l_ou_org_id       NUMBER ;
    i                 NUMBER :=0 ;
    l_depreciable     VARCHAR2(1);
    l_mtl_trx_quantity NUMBER ;
    l_Error_Message    VARCHAR2(2000);
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_msg_index        NUMBER;
    l_raw_cost         NUMBER ;
    l_file             VARCHAR2(500);
    l_type_class       NUMBER ;
    l_txn_source_type_id NUMBER ;
    l_txn_action_id    NUMBER ;
    l_eib_costing_used VARCHAR2(1);
    l_redeploy_flag    VARCHAR2(1);

    l_pa_interface_tbl   cse_ipa_trans_pkg.nl_pa_interface_tbl_type ;

  CURSOR c_Business_Group_cur( c_org_id NUMBER ) IS
    SELECT ho.name
    FROM   hr_all_organization_units ho, hr_all_organization_units hoc
    WHERE  hoc.organization_id =  c_org_id
    AND    ho.organization_id  = hoc.business_group_id  ;

  l_Business_Group_rec   c_Business_Group_cur%ROWTYPE;
--
BEGIN

    cse_util_pkg.set_debug;

    -- Get costing profile
    OPEN  c_costing;
    FETCH c_costing into l_eib_costing_used;
    CLOSE c_costing;

    debug('Begin : cse_cost_collector stub '||p_transaction_id);

    l_eib_installed := cse_util_pkg.is_eib_installed ;
    i := 0 ;

    IF l_eib_installed = 'Y' AND l_eib_costing_used = 'Y' THEN
      fnd_profile.get('ORG_ID',l_ou_org_id);
      l_txn_source_type_id := NULL ;

      OPEN  mtl_trx_cur(p_transaction_id) ;
      FETCH mtl_trx_cur INTO l_mtl_trx_quantity, l_txn_source_type_id, l_type_class, l_txn_action_id;
      CLOSE mtl_trx_cur ;

      debug('  l_type_class         : '||l_type_class);
      debug('  l_txn_source_type_id : '||l_txn_source_type_id);
      debug('  l_txn_action_id      : '||l_txn_action_id);

      cse_util_pkg.check_item_trackable(p_inventory_item_id, l_eib_trackable_flag);

      IF l_eib_trackable_flag = 'TRUE' AND l_txn_source_type_id IS NOT NULL AND p_cost_element_id = 1 THEN

        l_user_id := fnd_global.user_id ;

        OPEN  org_name_cur(p_exp_org_id);
        FETCH org_name_cur INTO l_org_name ;
        CLOSE org_name_cur ;

        OPEN c_Business_Group_cur( p_exp_org_id ) ;
        FETCH c_Business_Group_cur INTO l_Business_Group_rec;
        CLOSE c_Business_Group_cur;

        OPEN  proj_number_cur(p_source_project_id);
        FETCH proj_number_cur INTO l_project_number ;
        CLOSE proj_number_cur ;

        OPEN  task_number_cur(p_source_task_id, p_source_project_id);
        FETCH task_number_cur INTO l_task_number ;
        CLOSE task_number_cur ;

        OPEN  item_name_cur(p_inventory_item_id, p_organization_id);
        FETCH item_name_cur INTO l_item_name ;
        CLOSE item_name_cur ;

        l_exp_item_date := p_transaction_date ;
        l_exp_end_date := pa_utils.GetWeekEnding(l_exp_item_date);

        OPEN  gl_date_cur(p_organization_id, p_acct_period_id);
        FETCH gl_date_cur INTO l_gl_date ;
        CLOSE gl_date_cur ;

        cse_util_pkg.check_depreciable(p_inventory_item_id, l_depreciable) ;

        FOR  cse_transactions_rec IN cse_transactions_cur (p_transaction_id)
        LOOP
          i := i + 1;
          debug ('Issue Type : '||cse_transactions_rec.issue_type);

          IF l_depreciable = 'Y' THEN
            l_pa_interface_tbl(i).transaction_source := 'CSE_INV_ISSUE_DEPR' ;
            l_pa_interface_tbl(i).billable_flag := 'N' ;
          ELSE
            l_pa_interface_tbl(i).transaction_source := 'CSE_INV_ISSUE' ;
            l_pa_interface_tbl(i).billable_flag := 'Y' ;
          END IF ;

          l_pa_interface_tbl(i).batch_name := NULL ;
          l_pa_interface_tbl(i).expenditure_ending_date := NVL(l_exp_end_date,sysdate);
          l_pa_interface_tbl(i).organization_name := l_org_name ;
          l_pa_interface_tbl(i).expenditure_item_date := l_exp_item_date;
          l_pa_interface_tbl(i).project_number := l_project_number;
          l_pa_interface_tbl(i).task_number := l_task_number;
          l_pa_interface_tbl(i).expenditure_type := p_exp_type;

          IF cse_transactions_rec.serial_number IS NULL THEN
            --Costing passes p_primary quantity as -ve for Issue to PJ
            --and +ve for receipt from PJ. But we need it to be +ve for
            --issue to PJ and -ve for Receipt from PJ.
            --Costs are appropriately paased.

            l_pa_interface_tbl(i).quantity := (-1)*p_primary_quantity ;
            l_pa_interface_tbl(i).denom_raw_cost := ROUND(p_raw_cost,2);
            l_pa_interface_tbl(i).acct_raw_cost := ROUND(p_raw_cost,2);
          ELSE
            l_raw_cost := ROUND((p_raw_cost/ABS(p_primary_quantity)),2);
            --Check if this is a redeployment
            cse_util_pkg.get_redeploy_flag(
              p_inventory_item_id => p_inventory_item_id,
              p_serial_number     => cse_transactions_rec.serial_number,
              p_transaction_date  => p_transaction_date,
              x_redeploy_flag     => l_redeploy_flag,
              x_return_status     => l_return_status,
              x_error_message     => l_error_message) ;

            debug ('Serial Number : '||cse_transactions_rec.serial_number);
            debug ('Redeploy Flag :'||l_redeploy_flag);

            IF l_redeploy_flag = 'Y' THEN
              l_raw_cost := 0;
            END IF ;

            l_pa_interface_tbl(i).quantity := (-1)*(p_primary_quantity/ABS(p_primary_quantity)) ;
            l_pa_interface_tbl(i).denom_raw_cost := l_raw_cost ;
            l_pa_interface_tbl(i).acct_raw_cost := l_raw_cost ;
          END IF ; --Serialized/Non_Serialized

          l_pa_interface_tbl(i).expenditure_comment := 'ENTERPRISE INSTALL BASE' ;
          l_pa_interface_tbl(i).transaction_status_code := 'P';
          l_pa_interface_tbl(i).attribute6 := l_item_name ;
          l_pa_interface_tbl(i).attribute7 := cse_transactions_rec.serial_number;

          IF l_pa_interface_tbl(i).attribute7 IS NOT NULL THEN
            l_pa_interface_tbl(i).orig_transaction_reference:=cse_transactions_rec.transaction_id||'-'||i;
          ELSE
           l_pa_interface_tbl(i).orig_transaction_reference := cse_transactions_rec.transaction_id||'-'||i;
          END IF ;

          l_pa_interface_tbl(i).interface_id := NULL ;
          l_pa_interface_tbl(i).unmatched_negative_txn_flag := 'Y';
          l_pa_interface_tbl(i).org_id := l_ou_org_id ;
          l_pa_interface_tbl(i).dr_code_combination_id := p_dr_code_combination_id ;
          l_pa_interface_tbl(i).cr_code_combination_id := p_cr_code_combination_id ;
          l_pa_interface_tbl(i).gl_date := l_gl_date ;
          l_pa_interface_tbl(i).system_linkage := 'INV';
          l_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE' ;
          l_pa_interface_tbl(i).last_update_date := SYSDATE;
          l_pa_interface_tbl(i).last_updated_by := l_user_id;
          l_pa_interface_tbl(i).creation_date := SYSDATE;
          l_pa_interface_tbl(i).created_by := l_user_id ;
          l_pa_interface_tbl(i).batch_name := 'ISSUE' ;
          l_pa_interface_tbl(i).cdl_system_reference4 := p_cr_sub_ledger_id;
          l_pa_interface_tbl(i).cdl_system_reference5 := p_dr_sub_ledger_id;
          l_pa_interface_tbl(i).project_id := p_source_project_id;
          l_pa_interface_tbl(i).task_id := p_source_task_id;
          l_pa_interface_tbl(i).organization_id := p_organization_id;
          l_pa_interface_tbl(i).inventory_item_id := p_inventory_item_id;
          l_pa_interface_tbl(i).person_business_group_name := l_Business_Group_rec.name;
        END LOOP ;

        IF i > 0 THEN
          debug('Calling Populate PA Interface..');
          cse_ipa_trans_pkg.populate_pa_interface(l_pa_interface_tbl, l_return_status, l_error_message);
        END IF ;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_msg_index := 1;
          WHILE l_msg_count > 0
          LOOP
            l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
            l_msg_index := l_msg_index + 1;
            l_Msg_Count := l_Msg_Count - 1;
          END LOOP;
          debug('Error Occured :' || l_error_message);
        END IF;

        --NL has used the Hook.
        O_err_num  := 0;
        O_hook_used  := 1 ;
        IF l_eib_trackable_flag = 'TRUE' THEN
          IF i = 0 THEN
            debug('Could not find Instances for this transaction in IB');
            O_hook_used  := 1 ;
            O_err_num  := -1 ;
          END IF ;
        END IF ;

      ELSE
        --As item is NOT IB trackable EIB has not used this hook.
        O_hook_used  := 0 ;
        O_err_num  := 0;
        debug('eIB did not override cost collector ');
      END IF ; --l_eib_tracked

    ELSE
      --EIB has not used this hook.
       O_hook_used  := 0 ;
       O_err_num  := 0;
    END IF ; --l_eib_installed

    debug('End : cse_cost_collector');

  EXCEPTION
    WHEN OTHERS THEN
      --This is just to notify the hook that , Nl indeed used the hook ,
      --though it was not successful attempt. This hook should pick the transaction
      --record when cost collection manager is run next time.
       O_hook_used  := 1 ;
       O_err_num  := -1;
       l_err_msg := SQLERRM ;
       debug('Error Occured :' || l_err_msg);
  END eib_cost_collector_stub ;

  ------------------------------------------------------------------------------------
  PROCEDURE reverse_expenditures IS
    CURSOR csi_txn_cur IS
      SELECT ct.transaction_id
      FROM   csi_transactions ct
      WHERE  ct.transaction_status_code = 'PENDING'  ;

    CURSOR csi_pending_txn_cur (c_transaction_id IN NUMBER) IS
      SELECT cii.serial_number,
             cii.inventory_item_id,
             cii.instance_id,
             cii.inv_master_organization_id,
             ct.transaction_id,
             ct.object_version_number,
             ct.transaction_date
      FROM   csi_item_instances cii,
             csi_item_instances_h ciih,
             csi_transactions ct
      WHERE  ct.transaction_id = c_transaction_id
      AND    ct.transaction_id = ciih.transaction_id
      AND    cii.instance_id = ciih.instance_id
      AND    cii.serial_number IS NOT NULL
      AND    ciih.old_inst_usage_code = 'INSTALLED'
      AND    ciih.new_location_type_code = 'INVENTORY' ;

    CURSOR get_first_proj_cur (c_instance_id IN NUMBER, c_transaction_id IN NUMBER) IS
      SELECT old_pa_project_id,
             old_pa_project_task_id
      FROM   csi_item_instances_h ciih
      WHERE  ciih.instance_id = c_instance_id
      ---We are looking for the immediate PROJ/TAsk info of the Receipt from Field Location transaction
      AND    ciih.transaction_id < c_transaction_id
      AND    old_location_type_code = 'PROJECT'
      AND    new_inst_usage_code = 'INSTALLED'
      ORDER BY transaction_id DESC ;

    CURSOR exp_cur (
      c_item_name IN VARCHAR2,
      c_serial_number IN VARCHAR2,
      c_project_id IN NUMBER,
      c_task_id IN NUMBER)
    IS
      SELECT org.name  organization_name,
             exp.expenditure_ending_date,
             proj.segment1  project_number,
             task.task_number,
             item.org_id,
             item.expenditure_type,
             item.expenditure_item_date,
             item.denom_currency_code,
             item.attribute6,
             item.attribute7,
             item.quantity ,
             item.raw_cost ,
             item.denom_raw_cost ,
             round(item.denom_raw_cost,2) unit_denom_raw_cost,
             item.raw_cost_rate,
             item.burden_cost,
             round(item.burden_cost,2) burden_cost_rate,
             dist.dr_code_combination_id,
             dist.cr_code_combination_id,
             dist.gl_date,
             dist.acct_raw_cost,
             item.transaction_source
      FROM   pa_expenditure_items_all         item,
             pa_cost_distribution_lines_all  dist,
             pa_expenditure_groups_all       grp,
             pa_expenditures_all             exp,
             pa_projects_all                 proj,
             pa_tasks                        task,
             hr_organization_units           org
      WHERE  org.organization_id = NVL(item.override_to_organization_id,
                                     exp.incurred_by_organization_id)
      AND    NVL(dist.reversed_flag, 'N') <> 'Y'
      AND    dist.cr_code_combination_id IS NOT NULL
      AND    dist.dr_code_combination_id IS NOT NULL
      AND    dist.line_type = 'R'
      AND    item.expenditure_item_id = dist.expenditure_item_id
      AND    grp.transaction_source IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
      AND    grp.expenditure_group = exp.expenditure_group
      AND    exp.expenditure_id = item.expenditure_id
      AND    item.attribute6 = c_item_name
      AND    NVL(item.attribute7, 'xyz') = c_serial_number
      AND    item.attribute8 IS NULL
      AND    item.attribute9 IS NULL
      AND    item.attribute10 IS NULL
      AND    item.billable_flag = 'Y'
      AND    task.project_id = c_project_id
      AND    item.task_id = c_task_id
      AND    task.task_id=item.task_id
      AND    proj.project_id = task.project_id ;

    CURSOR c_Business_Group_cur( c_org_id NUMBER ) IS
    SELECT ho.name
    FROM   hr_all_organization_units ho, hr_all_organization_units hoc
    WHERE  hoc.organization_id =  c_org_id
    AND    ho.organization_id  = hoc.business_group_id  ;
    l_Business_Group_rec   c_Business_Group_cur%ROWTYPE;

    l_item_name             mtl_system_items_kfv.concatenated_segments%TYPE;
    l_serial_number         VARCHAR2(30);
    l_project_id            NUMBER;
    l_task_id               NUMBER;
    l_ref_suffix            NUMBER;
    l_sysdate               DATE;
    l_user_id               NUMBER;
    i                       NUMBER;
    l_nl_pa_interface_tbl   CSE_IPA_TRANS_PKG.nl_pa_interface_tbl_type;
    l_return_status         VARCHAR2(1);
    l_error_message         VARCHAR2(2000);
    e_next                  EXCEPTION ;
    l_api_version          NUMBER := 1.0;
    l_commit               VARCHAR2(1) := fnd_api.G_FALSE;
    l_init_msg_list        VARCHAR2(1) := fnd_api.G_TRUE;
    l_validation_level     NUMBER := fnd_api.G_VALID_LEVEL_FULL;
    l_msg_count            NUMBER ;
    l_msg_data             VARCHAR2(2000);
    l_msg_index            PLS_INTEGER;
    l_txn_rec              csi_datastructures_pub.transaction_rec;
    l_txn_obj_ver          NUMBER ;
    l_redeploy_flag        VARCHAR2(1);
    l_depreciable          VARCHAR2(1);
    l_txn_processed        BOOLEAN ;

  BEGIN
    cse_util_pkg.write_log('Reversing the expenditures, for serialized items which are
                               being returned from Installed location');

    l_user_id      := fnd_global.user_id ;
    SELECT sysdate INTO l_sysdate FROM sys.dual ;
    i := 0;
    FOR csi_txn_rec IN csi_txn_cur
    LOOP
      i := 0 ;
      l_nl_pa_interface_tbl.DELETE ;
      l_txn_processed := FALSE;
      BEGIN
        SAVEPOINT A ;
        FOR csi_pending_txn_rec IN csi_pending_txn_cur(csi_txn_rec.transaction_id)
        LOOP
          i := i+1 ;
          l_txn_obj_ver := csi_pending_txn_rec.object_version_number ;

          cse_util_pkg.write_log('Processing Serial Number : '|| csi_pending_txn_rec.serial_number);

          cse_util_pkg.check_depreciable(
            p_inventory_item_id => csi_pending_txn_rec.inventory_item_id,
            p_depreciable => l_depreciable) ;

          cse_util_pkg.write_log('l_depreciable :'|| l_depreciable);
          IF l_depreciable = 'N' THEN
            cse_util_pkg.get_redeploy_flag(
              p_inventory_item_id => csi_pending_txn_rec.inventory_item_id
             ,p_serial_number     => csi_pending_txn_rec.serial_number
             ,p_transaction_date  => csi_pending_txn_rec.transaction_date
             ,x_redeploy_flag     => l_redeploy_flag
             ,x_return_status     => l_return_status
             ,x_error_message     => l_error_message);

            IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
              RAISE e_next ;
            END IF ;
            cse_util_pkg.write_log('Redeploy Flag :'|| l_redeploy_flag);
          END IF ; --l_depreciable

          IF l_redeploy_flag = 'N' AND l_depreciable   = 'N' THEN
            IF i = 1 THEN
              SELECT concatenated_segments
              INTO   l_item_name
              FROM   mtl_system_items_kfv
              WHERE  inventory_item_id = csi_pending_txn_rec.inventory_item_id
              AND    organization_id = csi_pending_txn_rec.inv_master_organization_id
              AND    ROWNUM = 1;
            END IF ;

            OPEN get_first_proj_cur(csi_pending_txn_rec.instance_id,csi_pending_txn_rec.transaction_id);
            FETCH get_first_proj_cur INTO l_project_id, l_task_id ;
            CLOSE get_first_proj_cur ;

            cse_util_pkg.write_log('Project ID :'|| l_project_id);
            cse_util_pkg.write_log('Task ID :'|| l_task_id);
            cse_util_pkg.write_log('Item Name : '|| l_item_name);

            FOR exp_rec in exp_cur(l_item_name , csi_pending_txn_rec.serial_number, l_project_id, l_task_id)
            LOOP

              SELECT csi_pa_interface_s.NEXTVAL
              INTO  l_ref_suffix
              FROM DUAL;
              l_txn_processed := TRUE ;

              OPEN c_Business_Group_cur( exp_rec.org_id ) ;
      FETCH c_Business_Group_cur INTO l_Business_Group_rec;
      CLOSE c_Business_Group_cur;


              l_nl_pa_interface_tbl(i).transaction_source := exp_rec.transaction_source ;
              l_nl_pa_interface_tbl(i).batch_name:=csi_pending_txn_rec.transaction_id;
              l_nl_pa_interface_tbl(i).expenditure_ending_date := exp_rec.expenditure_ending_date;
              l_nl_pa_interface_tbl(i).employee_number :=Null;
              l_nl_pa_interface_tbl(i).organization_name :=  exp_rec.organization_name;
              l_nl_pa_interface_tbl(i).expenditure_item_date := exp_rec.expenditure_item_date;
              l_nl_pa_interface_tbl(i).project_number:=exp_rec.project_number;
              l_nl_pa_interface_tbl(i).task_number :=  exp_rec.task_number;
              l_nl_pa_interface_tbl(i).expenditure_type := exp_rec.expenditure_type;
              l_nl_pa_interface_tbl(i).expenditure_comment := 'ENTERPRISE INSTALL BASE';
              l_nl_pa_interface_tbl(i).transaction_status_code := 'P';
              l_nl_pa_interface_tbl(i).orig_transaction_reference
                                       := csi_pending_txn_rec.instance_id||'-'||l_ref_suffix;
              l_nl_pa_interface_tbl(i).attribute_category := NULL;
              l_nl_pa_interface_tbl(i).attribute6 := l_item_name;
              l_nl_pa_interface_tbl(i).attribute7 := csi_pending_txn_rec.serial_number ;
              l_nl_pa_interface_tbl(i).interface_id := NULL;
              l_nl_pa_interface_tbl(i).unmatched_negative_txn_flag := 'Y';
              l_nl_pa_interface_tbl(i).org_id := exp_rec.org_id;
              l_nl_pa_interface_tbl(i).dr_code_combination_id
                                       := exp_rec.dr_code_combination_id;
              l_nl_pa_interface_tbl(i).cr_code_combination_id
                                       := exp_rec.cr_code_combination_id;
              l_nl_pa_interface_tbl(i).cdl_system_reference1 := NULL;
              l_nl_pa_interface_tbl(i).cdl_system_reference2 := NULL;
              l_nl_pa_interface_tbl(i).cdl_system_reference3 := NULL;
              l_nl_pa_interface_tbl(i).gl_date := exp_rec.gl_date;
              l_nl_pa_interface_tbl(i).system_linkage := 'INV';
              l_nl_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE';
              l_nl_pa_interface_tbl(i).last_update_date := l_sysdate;
              l_nl_pa_interface_tbl(i).last_updated_by := l_user_id;
              l_nl_pa_interface_tbl(i).creation_date := l_sysdate;
              l_nl_pa_interface_tbl(i).created_by := l_user_id;
              l_nl_pa_interface_tbl(i).billable_flag := 'N';
              l_nl_pa_interface_tbl(i).quantity := -1;
              l_nl_pa_interface_tbl(i).denom_raw_cost := (-1)*exp_rec.unit_denom_raw_cost ;
              l_nl_pa_interface_tbl(i).acct_raw_cost:= (-1)*exp_rec.unit_denom_raw_cost ;
              l_nl_pa_interface_tbl(i).person_business_group_name := l_Business_Group_rec.name;
            END LOOP ; ---exp_cur
          END IF ; ---l_redeploy_flag
        END LOOP ; --csi_pending_txn_cur

        IF l_txn_processed  AND  i > 0 THEN
          cse_util_pkg.write_log('Calling cse_ipa_trans_pkg.populate_pa_interface, number of recs: '||i);
          CSE_IPA_TRANS_PKG.populate_pa_interface(
            p_nl_pa_interface_tbl => l_nl_pa_interface_tbl,
            x_return_status => l_return_status,
            x_error_message => l_error_message);

          IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  e_next ;
          END IF;

          --Update the transaction Status Here

          cse_util_pkg.write_log('Now updating the CSI txn to COMPLETE');
          l_txn_rec := CSE_UTIL_PKG.init_txn_rec;
          l_txn_rec.transaction_id := csi_txn_rec.transaction_id ;
          l_txn_rec.transaction_status_code := CSE_DATASTRUCTURES_PUB.G_COMPLETE ;
          l_txn_rec.object_version_number := l_txn_obj_ver ;

          csi_transactions_pvt.update_transactions(
            p_api_version      => l_api_version
           ,p_init_msg_list    => l_init_msg_list
           ,p_commit           => l_commit
           ,p_validation_level => l_validation_level
           ,p_transaction_rec  => l_txn_rec
           ,x_return_status    => l_return_status
           ,x_msg_count        => l_msg_count
           ,x_msg_data         => l_msg_data);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_error_message := l_msg_data;
            WHILE l_msg_count > 0
            LOOP
              l_error_message := FND_MSG_PUB.get(l_msg_index, FND_API.G_FALSE) || l_error_message;
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE e_next;
          END IF;
          COMMIT ;
        END IF ; ----l_txn_processed.
      EXCEPTION
        WHEN e_next THEN
          cse_util_pkg.write_log('Call to cse_ipa_trans_pkg.populate_pa_interface failed :'||l_error_message);
          ROLLBACK TO A ;
      END ; --csi_txn_cur
    END LOOP ; --csi_txn_cur
  EXCEPTION
    WHEN OTHERS THEN null;
  END reverse_expenditures;

END cse_cost_collector;

/
