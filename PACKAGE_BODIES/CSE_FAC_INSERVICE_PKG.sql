--------------------------------------------------------
--  DDL for Package Body CSE_FAC_INSERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_FAC_INSERVICE_PKG" AS
/*  $Header: CSEFPISB.pls 120.23.12010000.5 2010/02/25 06:05:08 dsingire ship $ */

  l_debug      VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');
  g_request_id NUMBER := NVL(FND_GLOBAL.conc_request_id,-1);

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

  PROCEDURE complete_csi_txn(
    p_csi_txn_id       IN number,
    x_return_status    OUT nocopy varchar2,
    x_error_message    OUT nocopy varchar2)
  IS
    l_txn_rec          csi_datastructures_pub.transaction_rec;
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count        number;
    l_msg_data         varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_txn_rec.transaction_id          := p_csi_txn_id;
    l_txn_rec.source_group_ref_id     := fnd_global.conc_request_id;
    l_txn_rec.transaction_status_code := cse_datastructures_pub.g_complete ;

    SELECT object_version_number
    INTO   l_txn_rec.object_version_number
    FROM   csi_transactions
    WHERE  transaction_id = l_txn_rec.transaction_id;

    csi_transactions_pvt.update_transactions(
      p_api_version      => 1.0,
      p_init_msg_list    => fnd_api.g_true,
      p_commit           => fnd_api.g_false,
      p_validation_level => fnd_api.g_valid_level_full,
      p_transaction_rec  => l_txn_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END complete_csi_txn;

  PROCEDURE create_expitem(
    x_return_status OUT    NOCOPY VARCHAR2,
    x_error_message OUT    NOCOPY VARCHAR2,
    p_project_num          IN     VARCHAR2 ,
    p_task_num             IN     VARCHAR2 ,
    p_conc_request_id      IN     NUMBER   )
  IS
    l_Api_Version               NUMBER :=1;
    l_Commit                    VARCHAR2(1) := FND_API.G_False;
    l_Validation_Level          NUMBER      := FND_API.G_Valid_Level_Full;
    l_Init_Msg_List             VARCHAR2(1) := FND_API.G_True;
    l_Msg_Data                  VARCHAR2(2000);
    l_Msg_Count                 NUMBER;
    l_Return_Status             VARCHAR2(1);
    l_Error_Message             VARCHAR2(2000);
    l_Msg_Text                  VARCHAR2(4000);
    l_Msg_Index                 NUMBER;
    l_org_id                    number;

    l_project_id                NUMBER;
    l_task_id                   NUMBER;

    l_Project_Id_in             NUMBER;
    l_Task_Id_in                NUMBER;

    l_depreciable               VARCHAR2(1);
    l_txn_error_id              number;
    l_txn_error_rec             csi_datastructures_pub.transaction_error_rec;
    l_in_srv_pa_attr_rec        cse_datastructures_pub.proj_itm_insv_pa_attr_rec_type;

    CURSOR project_id_cur(p_project_num IN VARCHAR2) IS
      SELECT project_id
      FROM   pa_projects_all
      WHERE  segment1 = p_project_num;

    CURSOR task_id_cur(p_project_id in number, p_task_num in varchar2) IS
      SELECT task_id
      FROM   pa_tasks
      WHERE  project_id  = p_project_id
      AND    task_number = p_task_num;

    CURSOR inservice_txn_cur(p_project_id in number, p_task_id in number) IS
      SELECT transaction_id,
             transaction_date,
             transacted_by,
             transaction_quantity,
             source_transaction_date,
             object_version_number,
             message_id,
             source_header_ref_id project_id,
             source_line_ref_id   task_id
      FROM   csi_transactions
      WHERE  transaction_type_id     = 108
      AND    transaction_status_code = cse_datastructures_pub.g_pending
      AND    source_header_ref_id    = nvl(p_project_id, source_header_ref_id)
      AND    source_line_ref_id      = nvl(p_task_id, source_line_ref_id);

   CURSOR inservice_inst_cur(p_csi_txn_id IN number) IS
     SELECT ciih.instance_id,
            cii.inventory_item_id,
            cii.last_vld_organization_id,
            cii.lot_number,
            cii.serial_number,
            cii.inventory_revision,
            cii.last_pa_project_id,
            cii.last_pa_task_id,
            cii.quantity,
            cii.location_type_code,
            cii.location_id,
            cii.operational_status_code
      FROM  csi_item_instances_h ciih,
            csi_item_instances   cii
      WHERE ciih.transaction_id     = p_csi_txn_id
      AND   cii.instance_id         = ciih.instance_id
      AND   (cii.operational_status_code  = 'IN_SERVICE' OR ciih.new_operational_status_code = 'IN_SERVICE');

  BEGIN

    cse_util_pkg.set_debug;

    debug('Inside API cse_fac_inservice_pkg.create_expitem');

    x_return_status := g_ret_sts_success;
    x_error_message := null;

    debug('  param.project_number : '||p_project_num);
    debug('  param.task_number    : '||p_task_num);

    l_project_id_in := NULL;
    l_task_id_in    := NULL;

    IF NOT p_project_num IS NULL THEN

      OPEN  project_id_cur(p_project_num);
      FETCH project_id_cur INTO l_project_id_in;
      CLOSE project_id_cur;

      IF p_task_num is not null THEN
        OPEN  task_id_cur(l_project_id_in,p_task_num);
        FETCH task_id_cur INTO l_task_id_in;
        CLOSE task_id_cur;
      END IF;

    END IF;

    FOR inservice_txn_rec IN inservice_txn_cur(l_project_id_in, l_task_id_in)
    LOOP

      debug('  transaction_id       : '||inservice_txn_rec.transaction_id);
      debug('  transaction_qty      : '||inservice_txn_rec.transaction_quantity);
      debug('  source_txn_date      : '||inservice_txn_rec.source_transaction_date);
      debug('  transacted_by        : '||inservice_txn_rec.transacted_by);

      l_project_id := inservice_txn_rec.project_id;
      l_task_id    := inservice_txn_rec.task_id;

      BEGIN

        savepoint start_csi_transaction;

        FOR inservice_inst_rec IN inservice_inst_cur(inservice_txn_rec.transaction_id)
        LOOP

          debug('  instance_id          : '||inservice_inst_rec.instance_id);
          debug('  inventory_item_id    : '||inservice_inst_rec.inventory_item_id);
          debug('  serial_number        : '||inservice_inst_rec.serial_number);
          debug('  organization_id      : '||inservice_inst_rec.last_vld_organization_id);
          debug('  last_pa_project_id   : '||inservice_inst_rec.last_pa_project_id);
          debug('  last_pa_task_id      : '||inservice_inst_rec.last_pa_task_id);
          debug('  location_type_code   : '||inservice_inst_rec.location_type_code);
          debug('  location_id          : '||inservice_inst_rec.location_id);
          debug('  operation_status_code: '||inservice_inst_rec.operational_status_code);

          cse_util_pkg.check_depreciable(inservice_inst_rec.inventory_item_id, l_depreciable);

          IF p_project_num is null THEN --Added for Bug 9326077
            l_project_id := inservice_inst_rec.last_pa_project_id; --Added for Bug 9326077
          END IF; --Added for Bug 9326077

          IF p_task_num is null THEN --Added for Bug 9209549
            l_task_id := inservice_inst_rec.last_pa_task_id; --Added for Bug 9209549
          END IF; --Added for Bug 9209549

          debug('  depreciable_flag     : '||l_depreciable);

          IF l_depreciable = 'N' THEN

            SELECT org_id
            INTO   l_in_srv_pa_attr_rec.org_id
            FROM   pa_projects_all
            WHERE  project_id = l_project_id;

            l_in_srv_pa_attr_rec.item_id               := inservice_inst_rec.inventory_item_id;
            l_in_srv_pa_attr_rec.inv_master_org_id     := inservice_inst_rec.last_vld_organization_id;
            l_in_srv_pa_attr_rec.serial_number         := inservice_inst_rec.serial_number;
            l_in_srv_pa_attr_rec.quantity              := inservice_txn_rec.transaction_quantity;
            l_in_srv_pa_attr_rec.location_id           := inservice_inst_rec.location_id;
            l_in_srv_pa_attr_rec.location_type         := inservice_inst_rec.location_type_code;
            l_in_srv_pa_attr_rec.project_id            := l_project_id;
            l_in_srv_pa_attr_rec.task_id               := l_task_id;
            l_in_srv_pa_attr_rec.transaction_date      := inservice_txn_rec.transaction_date;
            l_in_srv_pa_attr_rec.transacted_by         := inservice_txn_rec.transacted_by;
            l_in_srv_pa_attr_rec.message_id            := inservice_txn_rec.message_id;
            l_in_srv_pa_attr_rec.transaction_id        := inservice_txn_rec.transaction_id;
            l_in_srv_pa_attr_rec.instance_id           := inservice_inst_rec.instance_id;
            l_in_srv_pa_attr_rec.object_version_number := inservice_txn_rec.object_version_number;

            cse_proj_item_in_srv_pkg.interface_nl_to_pa(
              P_in_srv_pa_attr_rec => l_in_srv_pa_attr_rec,
              p_conc_request_id    => p_conc_request_id,
              x_return_status      => l_return_status,
              x_error_message      => l_error_message);

            IF NOT l_Return_Status = g_ret_sts_success THEN
              debug('error interfacing nl_to_pa '||substr(l_error_message,1,200));
              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE

            complete_csi_txn(
              p_csi_txn_id     => inservice_txn_rec.transaction_id,
              x_return_status  => l_return_status,
              x_error_message  => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

        END LOOP;


      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          rollback to start_csi_transaction;

          x_return_status                     := g_ret_sts_error;

          BEGIN
            SELECT transaction_error_id
            INTO   l_txn_error_id
            FROM   csi_txn_errors
            WHERE  transaction_id = inservice_txn_rec.transaction_id
            AND    source_type    = 'CSENIISEI'
            AND    rownum = 1;

            UPDATE csi_txn_errors
            SET    error_text           = l_error_message,
                   last_update_date     = sysdate,
                   last_updated_by      = fnd_global.user_id,
                   last_update_login    = fnd_global.login_id
            WHERE  transaction_error_id = l_txn_error_id;

          EXCEPTION
            WHEN no_data_found THEN

              l_txn_error_rec                     := cse_util_pkg.init_txn_error_rec;
              l_txn_error_rec.error_text          := l_error_message;
              l_txn_error_rec.source_group_ref_id := NVL(p_conc_request_id,g_request_id);
              l_txn_error_rec.transaction_id      := inservice_txn_rec.transaction_id;
              l_txn_error_rec.source_type         := 'CSENIISEI';
              l_txn_error_rec.source_id           := inservice_txn_rec.transaction_id;
              l_txn_error_rec.processed_flag      := 'N';

              csi_transactions_pvt.create_txn_Error(
                P_api_version           => l_api_version,
                P_Init_Msg_List         => l_init_msg_list,
                P_Commit                => l_commit,
                p_validation_level      => l_validation_level,
                p_txn_error_rec         => l_txn_error_rec,
                X_Return_Status         => l_return_status,
                X_Msg_Count             => l_msg_count,
                X_Msg_Data              => l_msg_data,
                X_Transaction_Error_Id  => l_txn_error_id);
          END;

        WHEN OTHERS THEN

          rollback to start_csi_transaction;

          fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
          fnd_message.set_token('ERR_MSG',SQLERRM);

          x_return_status                     := g_ret_sts_unexp_error;
          x_error_message                     := fnd_message.get;

          BEGIN
            SELECT transaction_error_id
            INTO   l_txn_error_id
            FROM   csi_txn_errors
            WHERE  transaction_id = inservice_txn_rec.transaction_id
            AND    source_type    = 'CSENIISEI'
            AND    rownum = 1;

            UPDATE csi_txn_errors
            SET    error_text           = l_error_message,
                   last_update_date     = sysdate,
                   last_updated_by      = fnd_global.user_id,
                   last_update_login    = fnd_global.login_id
            WHERE  transaction_error_id = l_txn_error_id;
          EXCEPTION
            WHEN no_data_found THEN
              l_txn_error_rec                     := cse_util_pkg.init_txn_error_rec;
              l_txn_error_rec.error_text          := x_error_message;
              l_txn_error_rec.Transaction_id      := inservice_txn_rec.transaction_id;
              l_txn_error_rec.source_group_ref_id := nvl(p_conc_request_id,g_request_id);
              l_txn_error_rec.source_type         := 'NORMAL_ITEM_EXP_ITEM';
              l_txn_error_rec.source_id           := null;
              l_txn_error_rec.processed_flag      := 'N';

              CSI_Transactions_Pvt.Create_Txn_Error(
                P_api_version          => l_Api_Version,
                P_Init_Msg_List         => l_Init_Msg_List,
                P_Commit                => l_Commit,
                p_validation_level      => l_Validation_Level,
                p_txn_error_rec         => l_txn_error_rec,
                X_Return_Status         => l_Return_Status,
                X_Msg_Count             => l_Msg_Count,
                X_Msg_Data              => l_Msg_Data,
                X_Transaction_Error_Id  => l_txn_Error_Id);
          END;
      END;

      COMMIT;
    END LOOP;

    debug('cse_fac_inservice_pkg.create_expitem completed successfully');

  END Create_ExpItem;

  PROCEDURE create_project_asset(
    p_csi_txn_id             IN  number,
    p_project_id             IN  number,
    p_task_id                IN  number,
    p_instance_id            IN  number,
    p_serial_number          IN  varchar2,
    p_date_placed_in_service IN  date,
    x_project_asset_id       OUT nocopy number,
    x_processed_flag         OUT nocopy varchar2,
    x_return_status          OUT nocopy varchar2,
    x_error_message          OUT nocopy varchar2,
    P_conc_request_id        IN  NUMBER)
  IS

    l_org_id                 number;
    l_project_num            varchar2(80);
    l_project_name           varchar2(240);
    l_task_id                number;
    l_task_num               varchar2(80);
    l_task_name              varchar2(240);
    l_task_attribute10       varchar2(80);

    l_date_placed_in_service date;
    l_asset_units            number;
    l_asset_attrib_rec      CSE_DATASTRUCTURES_PUB.asset_attrib_rec;

    -- asset naming convention variables
    l_anc_name               varchar2(30);
    l_anc_desc1              varchar2(30);
    l_anc_desc2              varchar2(30);
    l_anc_desc3              varchar2(30);
    l_anc_sep                varchar2(30);
    l_anc_loc                varchar2(30);
    l_anc_cat                varchar2(30);

    l_skip_create            boolean;

    l_asset_name             varchar2(240);
    l_asset_description      varchar2(300); -- Bug 5897139
    l_asset_category         varchar2(300);
    l_asset_category_id      number;
    l_asset_location         varchar2(300);
    l_asset_location_id      number;
    l_book_type_code         varchar2(15);
    l_acc_flex_structure     number;
    l_deprn_expense_ccid     number;
    l_suffix                 number;

    -- out variables
    l_pa_project_id          number;
    l_pa_project_number      varchar2(80);
    l_pa_project_asset_id    number;
    l_pm_asset_reference     varchar2(80);
    l_source_ref             varchar2(30);
    l_asset_key_required     varchar2(1);
    l_asset_key_ccid         number;


    -- status and error handling variables
    l_err_stack              varchar2(2000);
    l_err_stage              varchar2(640);
    l_err_code               varchar2(640);
    l_rejection_code         varchar2(640);
    l_error_message          varchar2(2000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_hook_used              number;

    l_Api_Version      NUMBER :=1;
    l_Commit           VARCHAR2(1) := FND_API.G_False;
    l_Validation_Level NUMBER := FND_API.G_Valid_Level_Full;
    l_Init_Msg_List    VARCHAR2(1) := FND_API.G_True;
    l_Msg_Text         VARCHAR2(4000);
    l_Transaction_Error_Id NUMBER;
    l_txn_error_rec           CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;

    CURSOR exp_line_cur(p_project_id IN number, p_task_id IN number, p_instance_id IN number) IS
      SELECT pei.expenditure_item_id expenditure_item_id,
             pei.quantity            quantity,
             pei.Task_Id             task_id,
             pei.attribute6          attribute6,
             pei.attribute7          attribute7,
             pei.attribute8          attribute8,
             pei.attribute9          attribute9,
             pei.attribute10         attribute10
      FROM   pa_expenditure_items_all pei
      WHERE  pei.project_id         = p_project_id
      AND    pei.task_Id            = p_task_id
      AND    pei.transaction_source IN ('CSE_PO_RECEIPT', 'CSE_INV_ISSUE')
      AND    substr(pei.orig_transaction_reference,1,
             instr(pei.orig_transaction_reference,'-') -1) = to_char(p_instance_id)
      AND   (pei.Attribute8 IS NOT NULL AND pei.Attribute9 IS NOT NULL)
      AND    pei.billable_flag ='Y'
      AND    nvl(pei.crl_asset_creation_status_code,'N') <> 'Y'
      AND    not exists (
        SELECT 'This CDL was summarized before'
        FROM   pa_project_asset_line_details pald,
               pa_project_asset_lines pal
        WHERE  pald.expenditure_item_id          = pei.expenditure_item_id
        AND    pald.project_asset_line_detail_id = pal.project_asset_line_detail_id
        AND    pal.project_asset_id             >= 1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    x_processed_flag := 'N';

    debug('Inside API create_project_asset');

    SELECT segment1,
           name,
           org_id
    INTO   l_project_num,
           l_project_name,
           l_org_id
    FROM   pa_projects_all
    WHERE  project_id = p_project_id;

    debug('  project_name         : '||l_project_name);

    SELECT task_number,
           task_name,
           attribute10
    INTO   l_task_num,
           l_task_name,
           l_task_attribute10
    FROM   pa_tasks
    WHERE  project_Id  = p_project_id
    AND    task_id     = p_task_id;

    debug('  task_name            : '||l_task_name);
    debug('  org_id               : '||l_org_id);

    mo_global.set_policy_context('S',l_org_id);

    SELECT asset_name,
           asset_description1,
           asset_description2,
           asset_description3,
           asset_desc_separator,
           asset_location,
           asset_category
    INTO   l_anc_name,
           l_anc_desc1,
           l_anc_desc2,
           l_anc_desc3,
           l_anc_sep,
           l_anc_loc,
           l_anc_cat
    FROM   ipa_asset_naming_convents_all
    WHERE  org_id = l_org_id;

    debug('l_anc_name :'||l_anc_name);


    FOR exp_line_rec IN exp_line_cur(p_project_id, p_task_id, p_instance_id)
    LOOP
      l_date_placed_in_service := p_date_placed_in_service ;
      debug('  expenditure_item_id  : '||exp_line_rec.expenditure_item_id);

      BEGIN
        SELECT  ppa.project_asset_id,
                ppa.date_placed_in_service,
                ppa.asset_units
        INTO    l_pa_project_asset_id,
                l_date_placed_in_service,
                l_asset_units
        FROM    pa_project_asset_assignments ppaa,
                pa_project_assets_all        ppa
        WHERE   ppaa.project_id       = p_project_id
        AND     ppaa.task_Id          = p_task_id
        AND     ppaa.project_asset_id = ppa.project_asset_id
        AND     nvl(ppaa.Attribute6, '**##**') = nvl(exp_line_rec.attribute6, '**##**')
        AND     nvl(ppaa.Attribute7, '**##**') = nvl(exp_line_rec.attribute7, '**##**')
        AND     nvl(ppaa.Attribute8, '**##**') = nvl(exp_line_rec.attribute8, '**##**')
        AND     nvl(ppaa.Attribute9, '**##**') = nvl(exp_line_rec.attribute9, '**##**')
        AND     nvl(ppaa.Attribute10,'**##**') = nvl(exp_line_rec.attribute10,'**##**');
        l_skip_create := TRUE;
      EXCEPTION
        WHEN no_data_found THEN
          l_skip_create := FALSE;
        WHEN too_many_rows THEN
          l_skip_create := TRUE;
      END;

      IF NOT(l_skip_create) THEN

        debug('processing_mode : CREATE');

	l_asset_attrib_rec.Transaction_ID :=p_csi_txn_id;

	l_error_message := fnd_api.g_miss_char;

        cse_asset_client_ext_stub.get_asset_name(
          p_asset_attrib_rec   => l_asset_attrib_rec,
          x_asset_name         => l_asset_name,
          x_hook_used          => l_hook_used,
          x_error_msg          => l_error_message);

	IF nvl(l_error_message,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
          x_error_message := l_error_message; --- Added for bug 6030501
          RAISE fnd_api.g_exc_error;
        END IF;

        SELECT csi_pa_interface_s.nextval
        INTO   l_suffix
        FROM   sys.dual;

        IF l_hook_used = 0 THEN
        IF l_anc_name = 'ANT' THEN
          l_asset_name := l_task_name;
        ELSIF l_anc_name = 'ANP' THEN
          l_asset_name := l_project_num;
        ELSIF l_anc_name = 'ANGE1' THEN
          l_asset_name := exp_line_rec.attribute8;
        ELSIF l_anc_name = 'ANGE2' THEN
          l_asset_name := exp_line_rec.attribute9;
        ELSIF l_anc_name = 'ANGE3' THEN
          l_asset_name := exp_line_rec.attribute10;
        END IF;

        l_asset_name := l_asset_name||'-'||l_suffix;

        END IF;

        cse_asset_client_ext_stub.get_asset_description(
          p_asset_attrib_rec   => l_asset_attrib_rec,
          x_description        => l_asset_description,
          x_hook_used          => l_hook_used,
          x_error_msg          => l_error_message);

        IF l_hook_used = 0 THEN
        SELECT decode(l_anc_desc1,
                 'ADT',l_task_name,
                 'ADP',l_project_name,
                 'ADGE1',exp_line_rec.attribute8,
                 'ADGE2',exp_line_rec.attribute9,
                 'ADGE3',exp_line_rec.attribute10)||
               decode(l_anc_desc2,'None',null,l_anc_sep)||
               decode(l_anc_desc2,
                 'ADT',l_task_name,
                 'ADP',l_project_name,
                 'ADGE1',exp_line_rec.attribute8,
                 'ADGE2',exp_line_rec.attribute9,
                 'ADGE3',exp_line_rec.attribute10)||
               decode(l_anc_desc3,'None',null,l_anc_sep)||
               decode(l_anc_desc3,
                 'ADT',l_task_name,
                 'ADP',l_project_name,
                 'ADGE1',exp_line_rec.attribute8,
                 'ADGE2',exp_line_rec.attribute9,
                 'ADGE3',exp_line_rec.attribute10)||
               decode(exp_line_rec.attribute6,null,null,l_anc_sep||exp_line_rec.attribute6)||
               decode(exp_line_rec.attribute7,null,null,l_anc_sep||exp_line_rec.attribute7)
        INTO   l_asset_description
        FROM   SYS.dual;

        l_asset_description := substr(l_asset_description, 1, 80);

        END IF;
        IF l_anc_cat = 'ACT' THEN
          l_asset_category := l_task_name;
        ELSIF l_anc_cat = 'ACDF' THEN
          l_asset_category := l_task_attribute10;
        ELSIF l_anc_cat = 'ACGE1' THEN
          l_asset_category := exp_line_rec.attribute8;
        ELSIF l_anc_cat = 'ACGE2' THEN
          l_asset_category := exp_line_rec.attribute9;
        ELSIF l_anc_cat = 'ACGE3' THEN
          l_asset_category := exp_line_rec.attribute10;
        END IF;

        SELECT category_id
        INTO   l_asset_category_id
        FROM   fa_categories
        WHERE  upper(segment1||segment2||segment3||segment4||segment5||segment6||segment7) =
               upper(l_asset_category);

        IF l_anc_loc = 'ALGE1' THEN
          l_asset_location := exp_line_rec.attribute8;
        ELSIF l_anc_loc = 'ALGE2' then
          l_asset_location := exp_line_rec.attribute9;
        ELSIF l_anc_loc = 'ALGE3' then
          l_asset_location := exp_line_rec.attribute10;
        END IF;

        SELECT location_id
        INTO   l_asset_location_id
        FROM   fa_locations
        WHERE  upper(segment1||segment2||segment3||segment4||segment5||segment6||segment7) =
               upper(l_asset_location);

        --l_book_type_code := fnd_profile.value('cse_fa_book_type_code');

   l_asset_attrib_rec.instance_id := p_instance_id; -- Bug 6492235, added for multiple FA book support

   l_book_type_code := cse_asset_util_pkg.book_type(
       p_asset_attrib_rec   => l_asset_attrib_rec,
       x_error_msg       => l_error_message,
       x_return_status   => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
    x_error_message := l_error_message; --- Added for bug 6030501
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  book_type_code       : '||l_book_type_code);


    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  book_type_code       : '||l_book_type_code);

	l_error_message := fnd_api.g_miss_char;
        cse_asset_client_ext_stub.get_deprn_expense_ccid(
          p_asset_attrib_rec   => l_asset_attrib_rec,
          x_deprn_expense_ccid  => l_deprn_expense_ccid,
          x_hook_used           => l_hook_used,
          x_error_msg           => l_error_message);

	  IF nvl(l_error_message,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
             x_error_message := l_error_message; --- Added for bug 6030501
             RAISE fnd_api.g_exc_error;
          END IF;

        IF l_hook_used = 0 THEN
        ipa_client_extension_pkg.get_default_deprn_expense(
          p_book_type_code      => l_book_type_code,
          p_asset_category_id   => l_asset_category_id,
          p_location_id         => l_asset_location_id ,
          p_expenditure_item_id => exp_line_rec.expenditure_item_id ,
          p_expense_ccid_out    => l_deprn_expense_ccid,
          p_err_stack           => l_err_stack ,
          p_err_stage           => l_err_stage ,
          p_err_code            => l_err_code);

        IF l_err_code <> '0' THEN
          l_rejection_code := substr(l_err_code,1,30);
          END IF;
        END IF;

        IF nvl(l_deprn_expense_ccid,0) > 0  THEN

          SELECT accounting_flex_structure
          INTO   l_acc_flex_structure
          FROM   fa_book_controls
          WHERE  book_type_code  = l_book_type_code;

          IF NOT (FND_FLEX_KEYVAL.validate_ccid(
                    appl_short_name  => 'SQLGL',
                    key_flex_code    => 'GL#',
                    structure_number => l_acc_flex_structure,
                    combination_id   => l_deprn_expense_ccid,
                    vrule            => 'GL_ACCOUNT\\nGL_ACCOUNT_TYPE\\nI\\n' ||
                                        'APPL=''OFA'';NAME=FA_SHARED_NOT_EXPENSE_ACCOUNT\\nE' ||
                                        '\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nI\\n' ||
                                        'APPL=''SQLGL'';NAME=GL Detail Posting Not Allowed\\nY' ||
                                        '\\0\\nSUMMARY_FLAG\\nI\\n' ||
                                        'APPL=''SQLGL'';NAME=GL summary credit debit\\nN'))
          THEN
            l_rejection_code := 'IFA_INVALID_DEPR_CCID';
          END IF;
        END IF;

        l_source_ref := 'OAT-'||p_csi_txn_id||'-'||l_suffix;

	--- Start of Fix for Bug 5887759

        debug('Calling cse_asset_util_pkg.validate_ccid_required');
        cse_asset_util_pkg.validate_ccid_required (l_asset_key_required);
        debug('l_asset_key_required: '||l_asset_key_required);

        IF l_asset_key_required = 'Y' THEN
          debug('Before calling cse_asset_util_pkg.asset_key');
	  l_asset_attrib_rec.Transaction_ID := p_csi_txn_id;
	  l_asset_attrib_rec.Instance_ID := p_instance_id;
          l_asset_key_ccid := cse_asset_util_pkg.asset_key(
			        l_asset_attrib_rec,
                                x_error_msg         =>    l_msg_data,
                                x_return_status     =>    l_return_status);

          debug('After calling cse_asset_util_pkg.asset_key');
          debug('l_asset_key_ccid: '||l_asset_key_ccid);

          l_msg_count := 1;

          debug('l_return_status : '||l_return_status);
          debug('l_msg_data      : '||l_msg_data);
          debug('l_msg_count     : '||l_msg_count);

          l_msg_data := fnd_message.get;
          debug('l_msg_data      : '||l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
	   x_error_message := l_msg_data; --- Added for bug 6030501
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF; -- l_asset_key_required

        --- End of Fix for Bug 5887759


        debug('Inside API pa_project_assets_pub.add_project_asset');

        pa_project_assets_pub.add_project_asset(
          p_api_version_number          => 1.0,
          p_init_msg_list               => fnd_api.g_true,
          p_pm_product_code             => 'CSE',
          p_pm_project_reference        => l_project_num,
          p_pa_project_id               => p_project_id,
          p_pa_asset_name               => l_asset_name,
          p_pm_asset_reference          => l_source_ref,
          p_asset_description           => l_asset_description,
          p_project_asset_type          => 'AS-BUILT',
          p_location_id                 => l_asset_location_id,
          p_date_placed_in_service      => l_date_placed_in_service,
          p_asset_category_id           => l_asset_category_id,
          p_book_type_code              => l_book_type_code,
          p_asset_units                 => exp_line_rec.quantity,
          p_depreciate_flag             => 'Y',
          p_depreciation_expense_ccid   => l_deprn_expense_ccid,
          p_amortize_flag               => 'N',
          p_attribute6                  => exp_line_rec.attribute6,
          p_attribute7                  => exp_line_rec.attribute7,
          p_attribute8                  => exp_line_rec.attribute8,
          p_attribute9                  => exp_line_rec.attribute9,
          p_attribute10                 => exp_line_rec.attribute10,
          p_pa_project_id_out           => l_pa_project_id,
          p_pa_project_number_out       => l_pa_project_number,
          p_pa_project_asset_id_out     => l_pa_project_asset_id,
          p_pm_asset_reference_out      => l_pm_asset_reference,
          p_return_status               => l_return_status,
          p_msg_count                   => l_msg_count,
          p_msg_data                    => l_msg_data,
	  p_asset_key_ccid              => l_asset_key_ccid);

        l_msg_data := fnd_message.get;
        debug('l_msg_data      : '||l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
	debug('Error in API pa_project_assets_pub.add_project_asset');   -- Added for Bug 6152305
	  -- x_error_message := l_msg_data; --- Added for bug 6030501
	  --debug('l_msg_data      : '||l_msg_data);
	  RAISE fnd_api.g_exc_error;
        END IF;

        debug('  pa_project_asset_id  : '||l_pa_project_asset_id);

        debug('Inside API pa_project_assets_pub.add_asset_assignment');

	pa_project_assets_pub.add_asset_assignment(
          p_api_version_number          => 1.0,
          p_init_msg_list               => fnd_api.g_true,
          p_pm_product_code             => 'CSE',
          p_pm_project_reference        => l_project_num,
          p_pa_project_id               => p_project_id,
          p_pm_task_reference           => l_task_num,
          p_pa_task_id                  => p_task_id,
          p_pm_asset_reference          => l_source_ref,
          p_pa_project_asset_id         => l_pa_project_asset_id,
          p_attribute6                  => exp_line_rec.attribute6,
          p_attribute7                  => exp_line_rec.attribute7,
          p_attribute8                  => exp_line_rec.attribute8,
          p_attribute9                  => exp_line_rec.attribute9,
          p_attribute10                 => exp_line_rec.attribute10,
          p_pa_task_id_out              => l_task_id,
          p_pa_project_asset_id_out     => l_pa_project_asset_id,
          p_return_status               => l_return_status,
          p_msg_count                   => l_msg_count,
          p_msg_data                    => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
	debug('Error in API pa_project_assets_pub.add_asset_assignment');  -- Added for Bug 6152305
	--x_error_message := l_msg_data; --- Added for bug 6030501
          RAISE fnd_api.g_exc_error;
        END IF;

        x_processed_flag := 'Y';

      ELSE

        debug('processing_mode : UPDATE');
        debug('  pa_project_asset_id  : '||l_pa_project_asset_id);
        debug('  asset_units          : '||l_asset_units);
        debug('  adjusted_units       : '||exp_line_rec.quantity);

        UPDATE pa_project_assets_all
        SET    asset_units            = asset_units +  exp_line_rec.quantity,
               date_placed_in_service = nvl(date_placed_in_service, l_date_placed_in_service),
               project_asset_type     = 'AS-BUILT'
        WHERE  project_asset_id       = l_pa_project_asset_id;

        x_processed_flag := 'Y';

      END IF;

      UPDATE pa_expenditure_items_all
      SET    crl_asset_creation_status_code = 'Y'
      WHERE  expenditure_item_id = exp_line_rec.expenditure_item_id;

    END LOOP;

    x_project_asset_id := l_pa_project_asset_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
    ----- Code start for bug 6030501
     IF x_error_message IS NULL then
        x_error_message := nvl(cse_util_pkg.dump_error_stack, l_error_message);
     END IF;
      x_return_status := fnd_api.g_ret_sts_error;

      debug(' Error Message '||x_error_message);
      l_txn_error_rec := CSE_UTIL_PKG.Init_Txn_Error_Rec;
      l_txn_error_rec.ERROR_TEXT  := x_error_message;
      l_txn_error_rec.source_group_ref_id  := NVL(p_conc_request_id,g_request_id);
      l_txn_error_rec.SOURCE_TYPE := 'NORMAL_ITEM_ASSET_UNITS';
      l_txn_error_rec.SOURCE_ID   := NULL;
      l_txn_error_rec.PROCESSED_FLAG := 'N';

      csi_transactions_pvt.create_txn_error(
        P_api_version           => l_Api_Version,
        P_Init_Msg_List         => l_Init_Msg_List,
        P_Commit                => l_Commit,
        p_validation_level      => l_Validation_Level,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_Return_Status,
        x_msg_count             => l_Msg_Count,
        x_msg_data              => l_Msg_Data,
        x_transaction_error_id  => l_Transaction_Error_Id);

   --   x_error_message := nvl(cse_util_pkg.dump_error_stack, l_error_message);
      x_return_status := fnd_api.g_ret_sts_error;

---- Code end for bug 6030501
  END create_project_asset ;


  PROCEDURE create_pa_asset_headers(
    errbuf              OUT nocopy varchar2,
    retcode             OUT nocopy number,
    p_project_id     IN            number,
    p_task_id        IN            number,
    P_conc_request_id   IN         NUMBER)
  IS

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message         varchar2(2000);
    l_project_asset_id      number;
    l_fa_group_by           varchar2(30);
    l_serial_number         varchar2(200);

    l_dpis               date;
    l_book_type_code     varchar2(30) := fnd_profile.value('CSE_FA_BOOK_TYPE_CODE');

    l_processed_flag        varchar2(1) := 'N';
    l_process_flag          boolean := FALSE;
    l_project_id                NUMBER; -- Added for Bug 9326077
    l_task_id                   NUMBER; -- Added for Bug 9326077

    CURSOR insrv_txn_cur IS
      SELECT transaction_id,
             transacted_by,
             transaction_quantity,
             source_transaction_date dpis,
             source_header_ref_id    project_id,
             source_line_ref_id      task_id,
             object_version_number   csi_txn_ovn
      FROM   csi_transactions
      WHERE  transaction_type_id     = 108   -- PROJECT_ITEM_IN_SERVICE
      AND    transaction_status_code = 'INTERFACED_TO_PA'
      AND    source_header_ref_id    = nvl(p_project_id, source_header_ref_id)
      AND    source_line_ref_id      = nvl(p_task_id, source_line_ref_id) ;

    CURSOR insrv_inst_cur(p_csi_txn_id IN number) IS
      SELECT cii.instance_id,
             cii.serial_number,
             cii.last_pa_project_id, --Added for Bug 9326077
             cii.last_pa_task_id --Added for Bug 9326077
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii
      WHERE  ciih.transaction_id         = p_csi_txn_id
      AND    cii.instance_id             = ciih.instance_id
      AND    (ciih.new_operational_status_code   = 'IN_SERVICE' OR cii.operational_status_code = 'IN_SERVICE');

    l_Api_Version      NUMBER :=1;
    l_Commit           VARCHAR2(1) := FND_API.G_False;
    l_Validation_Level NUMBER := FND_API.G_Valid_Level_Full;
    l_Init_Msg_List    VARCHAR2(1) := FND_API.G_True;
    l_Msg_Text         VARCHAR2(4000);
    l_Transaction_Error_Id NUMBER;
    l_txn_error_rec           CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_hook_used              number;
    l_transaction_id         NUMBER;

  BEGIN

    cse_util_pkg.set_debug;

    debug('Inside API cse_fac_inservice_pkg.create_pa_asset_header');
    debug('param.project_id       : '||p_project_id);
    debug('param.task_id          : '||p_task_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_fa_group_by := csi_datastructures_pub.g_install_param_rec.fa_creation_group_by;

    FOR insrv_txn_rec IN insrv_txn_cur
    LOOP
      l_transaction_id := insrv_txn_rec.transaction_id ;
      l_process_flag := FALSE;

      debug('transaction_rec # '||insrv_txn_cur%rowcount);
      debug('  transaction_id       : '||insrv_txn_rec.transaction_id);
      debug('  transaction_qty      : '||insrv_txn_rec.transaction_quantity);
      debug('  src_transaction_date : '||insrv_txn_rec.dpis);

      BEGIN
        savepoint insrv_txn;

        FOR insrv_inst_rec IN insrv_inst_cur(insrv_txn_rec.transaction_id)
        LOOP

          debug('  instance_id          : '||insrv_inst_rec.instance_id);
          debug('  serial_number        : '||insrv_inst_rec.serial_number);

          l_serial_number := insrv_inst_rec.serial_number;

          IF l_fa_group_by = 'ITEM' THEN
            l_serial_number := null;
          END IF;

          IF l_serial_number is null THEN
            SELECT start_date
            INTO   l_dpis
            FROM   fa_book_controls    fbc,
                   fa_calendar_periods fcp
            WHERE  fbc.book_type_code   = l_book_type_code
            AND    fcp.calendar_type    = fbc.deprn_calendar
            AND    insrv_txn_rec.dpis BETWEEN fcp.start_date AND fcp.end_date;
          ELSE
            l_dpis := insrv_txn_rec.dpis;
          END IF;

          IF NVL(p_project_id,0) = 0 THEN --Added for Bug 9326077
            l_project_id := insrv_inst_rec.last_pa_project_id; --Added for Bug 9326077
          ELSE
            l_project_id := insrv_txn_rec.project_id;
          END IF; --Added for Bug 9326077

          IF NVL(p_task_id,0) = 0 THEN --Added for Bug 9326077
            l_task_id := insrv_inst_rec.last_pa_task_id; --Added for Bug 9326077
          ELSE
            l_task_id := insrv_txn_rec.task_id;
          END IF; --Added for Bug 9326077

          create_project_asset(
            p_csi_txn_id             => insrv_txn_rec.transaction_id,
            p_project_id             => l_project_id,  --Added for Bug 9326077
            p_task_id                => l_task_id,     --Added for Bug 9326077
            p_instance_id            => insrv_inst_rec.instance_id,
            p_serial_number          => l_serial_number,
            p_date_placed_in_service => l_dpis,
            x_project_asset_id       => l_project_asset_id,
            x_processed_flag         => l_processed_flag,
            x_return_status          => l_return_status,
            x_error_message          => l_error_message,
	    P_conc_request_id        => P_conc_request_id);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_processed_flag = 'Y' THEN
            l_process_flag  := TRUE;
          END IF;

        END LOOP;

        IF l_process_flag THEN

          complete_csi_txn(
            p_csi_txn_id     => insrv_txn_rec.transaction_id,
            x_return_status  => l_return_status,
            x_error_message  => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('csi transaction interfaced to project asset successfully.');

          commit;

        END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          debug(l_error_message);
          rollback to insrv_txn;
	  debug(' Error Message '||l_error_message);
      l_txn_error_rec := CSE_UTIL_PKG.Init_Txn_Error_Rec;
      l_txn_error_rec.ERROR_TEXT  := l_error_message;
      l_txn_error_rec.source_group_ref_id  := NVL(p_conc_request_id,g_request_id);
      l_txn_error_rec.SOURCE_TYPE := 'NORMAL_ITEM_ASSET_UNITS';
      l_txn_error_rec.SOURCE_ID   := NULL;
      l_txn_error_rec.PROCESSED_FLAG := 'N';
      l_txn_error_rec.transaction_id := l_transaction_id;

      csi_transactions_pvt.create_txn_error(
        P_api_version           => l_Api_Version,
        P_Init_Msg_List         => l_Init_Msg_List,
        P_Commit                => l_Commit,
        p_validation_level      => l_Validation_Level,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_Return_Status,
        x_msg_count             => l_Msg_Count,
        x_msg_data              => l_Msg_Data,
        x_transaction_error_id  => l_Transaction_Error_Id);
        commit;

	 -- log error;

	WHEN others THEN	-- Added for Bug 7361370
	  rollback to insrv_txn;
	  debug(' Error Message '||sqlerrm);
      END;

    END LOOP;
  EXCEPTION
    WHEN others THEN
      --x_return_status := fnd_api.g_ret_sts_error;
      retcode := -1;
      errbuf  := sqlerrm;
  END create_pa_asset_headers;

  PROCEDURE update_units(
    x_return_status      OUT nocopy varchar2,
    x_error_message      OUT nocopy varchar2,
    p_conc_request_id    IN  number)
  IS
    l_asset_id               number;
    l_book_type_code         varchar2(30);
    l_units                  number;
    l_location_id            number;
    l_expense_ccid           number;
    l_employee_id            number;
    l_new_dist_id            number;

    l_msg_data               varchar2(2000);
    l_msg_count              number;
    l_return_status          varchar2(1);
    l_error_message          varchar2(4000);

    l_instance_id            number;
    l_instance_asset_id      number;
    l_asset_quantity         number;
    l_object_version_number  number;

    l_csi_txn_rec            csi_datastructures_pub.Transaction_Rec;
    l_inst_asset_rec         csi_datastructures_pub.Instance_Asset_Rec;
    l_asset_count_rec        csi_asset_pvt.asset_count_rec ;
    l_asset_id_tbl           csi_asset_pvt.asset_id_tbl ;
    l_asset_loc_tbl          csi_asset_pvt.asset_loc_tbl ;
    l_lookup_tbl             csi_asset_pvt.lookup_tbl ;

    CURSOR txn_cur IS
      SELECT transaction_error_id,
             transaction_type_id,
             message_string
      FROM   csi_txn_errors
      WHERE  processed_flag = 'B'
      AND    error_stage    = 'FA_UPDATE'
      AND    source_type    = 'FA_UNIT_ADJUSTMENT_NORMAL';

  BEGIN

    x_return_status     := fnd_api.g_ret_sts_success;
    x_error_message     := NULL;

    debug('inside api cse_fac_inservice_pkg.update_units');

    FOR txn_rec IN txn_cur
    LOOP

      BEGIN

        savepoint eachtxn;

        debug('unit adjustment record # '||txn_cur%rowcount);

        l_asset_id := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'ASSET_ID',
          x_value       => l_asset_id);

        l_book_type_code := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'BOOK_TYPE_CODE',
          x_value       => l_book_type_code);

        l_units := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'UNITS',
          x_value       => l_units);

        l_location_id := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'LOCATION_ID',
          x_value       => l_location_id);

        l_expense_ccid := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'DEPRN_EXPENSE_CCID',
          x_value       => l_expense_ccid);

        l_employee_id := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'EMPLOYEE_ID',
          x_value       => l_employee_id);

        l_instance_id := null;

        cse_util_pkg.get_string_value(
          p_string      => txn_rec.message_string,
          p_attribute   => 'INSTANCE_ID',
          x_value       => l_instance_id);

        debug('  asset_id           : '||l_asset_id);
        debug('  book_type_code     : '||l_book_type_code);
        debug('  units              : '||l_units);
        debug('  location_id        : '||l_location_id);
        debug('  expense_ccid       : '||l_expense_ccid);
        debug('  employee_id        : '||l_employee_id);
        debug('  instance_id        : '||l_instance_id);

        IF l_instance_id is not null THEN

          SELECT instance_asset_id,
                 asset_quantity,
                 object_version_number
          INTO   l_instance_asset_id,
                 l_asset_quantity,
                 l_object_version_number
          FROM   csi_i_assets
          WHERE  instance_id = l_instance_id
          AND    fa_asset_id = l_asset_id
          AND    sysdate between nvl(active_start_date, sysdate-1) and nvl(active_end_date, sysdate+1);

          l_csi_txn_rec                              := cse_util_pkg.init_txn_rec;
          l_csi_txn_rec.transaction_date             := sysdate;
          l_csi_txn_rec.source_transaction_date      := sysdate;
          l_csi_txn_rec.transaction_quantity         := l_units;
          l_csi_txn_rec.source_header_ref            := 'ASSET_ID';
          l_csi_txn_rec.source_header_ref_id         := l_asset_id;
          l_csi_txn_rec.transaction_status_code      := cse_datastructures_pub.g_complete;
          l_csi_txn_rec.transaction_type_id          := cse_util_pkg.get_txn_type_id('INSTANCE_ASSET_TIEBACK','CSE');

          l_inst_asset_rec                           := cse_util_pkg.init_instance_asset_rec;
          l_inst_asset_rec.asset_quantity            := l_asset_quantity + l_units;
          l_inst_asset_rec.instance_asset_id         := l_instance_asset_id;
          l_inst_asset_rec.object_version_number     := l_object_version_number;
          l_inst_asset_rec.update_status             := cse_datastructures_pub.g_in_service;
          l_inst_asset_rec.active_end_date           := null;
          l_inst_asset_rec.check_for_instance_expiry := fnd_api.g_false;

          debug('  instance_asset_id      : '||l_inst_asset_rec.instance_asset_id);
          debug('  asset_quantity         : '||l_inst_asset_rec.asset_quantity);

          debug('calling csi_asset_pvt.update_instance_asset');

          csi_asset_pvt.update_instance_asset(
            p_api_version        => 1.0,
            p_commit             => fnd_api.g_false,
            p_init_msg_list      => fnd_api.g_true,
            p_validation_level   => fnd_api.g_valid_level_full,
            p_instance_asset_rec => l_inst_asset_rec,
            p_txn_rec            => l_csi_txn_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_lookup_tbl         => l_lookup_tbl,
            p_asset_count_rec    => l_asset_count_rec,
            p_asset_id_tbl       => l_asset_id_tbl,
            p_asset_loc_tbl      => l_asset_loc_tbl);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

        cse_ifa_trans_pkg.adjust_fa_distribution(
          p_asset_id        => l_asset_id,
          p_book_type_code  => l_book_type_code,
          p_units           => l_units,
          p_location_id     => l_location_id,
          p_expense_ccid    => l_expense_ccid,
          p_employee_id     => l_employee_id,
          x_new_dist_id     => l_new_dist_id,
          x_return_status   => l_return_status,
          x_error_msg       => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        UPDATE csi_txn_errors
        SET    processed_flag       = 'S',
               source_group_ref_id  = fnd_global.conc_request_id,
               last_update_date     = sysdate,
               last_updated_by      = fnd_global.user_id
        WHERE  transaction_error_id = txn_rec.transaction_error_id;

        commit work;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN

          rollback to eachtxn;

          UPDATE csi_txn_errors
          SET    error_text          = x_error_message,
                 source_group_ref_id = fnd_global.conc_request_id,
                 last_update_date     = sysdate,
                 last_updated_by      = fnd_global.user_id
          WHERE transaction_error_id = txn_rec.transaction_error_id;

          commit work;

      END;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_error_message := sqlerrm;
      debug(' ERROR : '||x_error_message);
  END Update_Units;

END cse_fac_inservice_pkg;

/
