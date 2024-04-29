--------------------------------------------------------
--  DDL for Package Body CSTPPWMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWMT" AS
/* $Header: CSTPWMTB.pls 120.8 2006/07/03 11:18:35 sikhanna noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPWMT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE charge_wip_material(
        p_pac_period_id			IN         NUMBER,
        p_cost_group_id			IN         NUMBER,
        p_txn_id			IN         NUMBER,
        p_exp_item			IN         NUMBER DEFAULT NULL,
        p_exp_flag			IN         NUMBER DEFAULT NULL,
        p_legal_entity			IN         NUMBER,
        p_cost_type_id			IN         NUMBER,
        p_cost_method			IN         NUMBER,
        p_pac_rates_id			IN         NUMBER,
        p_master_org_id			IN         NUMBER,
        p_material_relief_algorithm     IN         NUMBER,
        p_uom_control			IN         NUMBER,
        p_user_id			IN         NUMBER,
        p_login_id			IN         NUMBER,
        p_request_id			IN         NUMBER,
        p_prog_id			IN         NUMBER,
        p_prog_app_id			IN         NUMBER,
        p_txn_category			IN         NUMBER,
        x_cost_method_hook		OUT NOCOPY NUMBER,
        x_err_num			OUT NOCOPY NUMBER,
        x_err_code			OUT NOCOPY VARCHAR2,
        x_err_msg			OUT NOCOPY VARCHAR2)
IS

l_uom_conv_rate         NUMBER;
l_cost_layer_id         NUMBER;
l_qty_layer_id          NUMBER;
l_entity_id             NUMBER;
l_entity_type           NUMBER;
l_line_id               NUMBER;
l_pri_qty               NUMBER;
l_org_id                NUMBER;
l_item_id               NUMBER;
l_op_seq                NUMBER;
l_txn_action_id         NUMBER;
l_exp_flag              NUMBER;
l_exp_item              NUMBER;
l_subinv                VARCHAR2(10);
l_stmt_num              NUMBER;
l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(2000);
l_cost_method_hook      NUMBER;
cst_fail_method_hook    EXCEPTION;
cst_no_wip_comp_txn     EXCEPTION;
cst_process_error       EXCEPTION;

-- Variables for eAM Support in PAC
l_zero_cost_flag       NUMBER := 0;
l_applied_value        NUMBER := 0;
l_return_status        VARCHAR(1);
l_msg_return_status    VARCHAR2(1);
l_msg_count            NUMBER := 0;
l_msg_data             VARCHAR2(8000);

l_api_name            CONSTANT VARCHAR2(30) := 'charge_wip_material';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


BEGIN

       IF (l_pLog) THEN
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.begin',
                        l_api_name || ' <<< Parameters:
			p_txn_id = ' || p_txn_id || '
			p_exp_item = ' || p_exp_item || '
			p_exp_flag = ' || p_exp_flag || '
			p_material_relief_algorithm = '|| p_material_relief_algorithm || '
			p_txn_category = ' || p_txn_category);
       END IF;

        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_cost_method_hook := -1;
        l_msg_data := '';
        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_return_status := FND_API.G_RET_STS_SUCCESS;

        ----------------------------------------------------------------------
        -- Make sure the txn is a WIP Component Txn
        ----------------------------------------------------------------------

        l_stmt_num := 5;

        SELECT  mmt.transaction_source_id entity_id,
                we.entity_type entity_type,
                mmt.repetitive_line_id line_id,
                mmt.primary_quantity pri_qty,
                mmt.inventory_item_id item_id,
                mmt.operation_seq_num op_seq,
                mmt.organization_id,
                mmt.subinventory_code subinv,
                mmt.transaction_action_id
        INTO    l_entity_id,
                l_entity_type,
                l_line_id,
                l_pri_qty,
                l_item_id,
                l_op_seq,
                l_org_id,
                l_subinv,
                l_txn_action_id
        FROM    mtl_material_transactions mmt,
                wip_entities we
        WHERE   mmt.transaction_id = p_txn_id
        AND     mmt.transaction_source_type_id = 5
        AND     mmt.transaction_action_id IN (1,27, 33, 34)
        AND     we.wip_entity_id = mmt.transaction_source_id;

        IF SQL%ROWCOUNT = 0 THEN
                RAISE CST_NO_WIP_COMP_TXN;
        END IF;

        ----------------------------------------------------------------------
        -- Check for row in cst_pac_wip_balance
        ----------------------------------------------------------------------

        l_stmt_num := 10;

        CSTPPWRO.check_pacwip_bal_record (p_pac_period_id => p_pac_period_id,
                                         p_cost_group_id  => p_cost_group_id,
                                         p_cost_type_id   => p_cost_type_id,
                                         p_org_id         => l_org_id,
                                         p_entity_id      => l_entity_id,
                                         p_entity_type    => l_entity_type,
                                         p_line_id        => l_line_id,
                                         p_op_seq         => l_op_seq,
                                         p_user_id        => p_user_id,
                                         p_request_id     => p_request_id,
                                         p_prog_app_id    => p_prog_app_id,
                                         p_prog_id        => p_prog_id,
                                         p_login_id       => p_login_id,
                                         x_err_num        => l_err_num,
                                         x_err_code       => l_err_code,
                                         x_err_msg        => l_err_msg
                                );

        IF (l_err_num <> 0) THEN

                l_err_msg := SUBSTR('Fail_check_bal_rec: ent/line/op'
                                             ||TO_CHAR(l_entity_id)
                                             ||'/'
                                             ||TO_CHAR(l_line_id)
                                             ||'/'
                                             ||TO_CHAR(l_op_seq)
                                             ||':'
                                             ||l_err_msg,1,2000);


                RAISE CST_PROCESS_ERROR;
        END IF;

        ----------------------------------------------------------------------
        -- Check and Create layer  for the componenet item, if required
        ----------------------------------------------------------------------

        l_stmt_num := 15;

        CSTPPCLM.layer_id (
                                i_pac_period_id     => p_pac_period_id,
                                i_legal_entity      => p_legal_entity,
                                i_item_id           => l_item_id,
                                i_cost_group_id     => p_cost_group_id,
                                o_cost_layer_id     => l_cost_layer_id,
                                o_quantity_layer_id => l_qty_layer_id,
                                o_err_num           => l_err_num,
                                o_err_code          => l_err_code,
                                o_err_msg           => l_err_msg);

        IF (l_err_num <> 0) THEN
                RAISE CST_PROCESS_ERROR;
        END IF;

        IF (l_cost_layer_id = 0 AND l_qty_layer_id = 0) THEN

          l_stmt_num := 20;

          CSTPPCLM.create_layer (
                                i_pac_period_id     => p_pac_period_id,
                                i_legal_entity      => p_legal_entity,
                                i_item_id           => l_item_id,
                                i_cost_group_id     => p_cost_group_id,
                                i_user_id           => p_user_id,
                                i_login_id          => p_login_id,
                                i_request_id        => p_request_id,
                                i_prog_id           => p_prog_id,
                                i_prog_appl_id      => p_prog_app_id,
                                o_cost_layer_id     => l_cost_layer_id,
                                o_quantity_layer_id => l_qty_layer_id,
                                o_err_num           => l_err_num,
                                o_err_code          => l_err_code,
                                o_err_msg           => l_err_msg);

          IF (l_err_num <> 0) THEN
                   RAISE CST_PROCESS_ERROR;
          END IF;

        END IF; -- Check Create Layer

        ----------------------------------------------------------------------
        -- Get the expense flags  for this transaction if they are NULL
        ----------------------------------------------------------------------

        IF (p_exp_item IS NULL OR p_exp_flag IS NULL) THEN

          l_stmt_num := 25;

          CSTPPWAS.check_expense_flags (
                                p_item_id      => l_item_id,
                                p_subinv       => l_subinv,
                                p_org_id       => l_org_id,
                                x_exp_item     => l_exp_item,
                                x_exp_flag     => l_exp_flag,
                                x_err_num      => l_err_num,
                                x_err_code     => l_err_code,
                                x_err_msg      => l_err_msg);

          IF (l_err_num <> 0) THEN

                l_err_msg := SUBSTR('Item_id: '
                                                ||TO_CHAR(l_item_id)
                                                ||' '
                                                ||l_err_msg,1,2000);

                RAISE CST_PROCESS_ERROR;

          END IF;

        ELSE

          l_exp_item := p_exp_item;

          l_exp_flag := p_exp_flag;

        END IF; -- check for exp flags


        ----------------------------------------------------------------------
        -- The hook is called for a costing method other than PWAC.
        -- The hook should return -1 if it is not being used.
        -- If the hook is used the transaction cost is picked from MPACD
        -- The user will write a customized script to insert costs into
        -- MPACD for WIP component transactions if hook is to be used.
        -- If hook is not used then transaction costs are picked from CPIC
        ----------------------------------------------------------------------


        IF (p_cost_method  <> 3) THEN

          --------------------------------------------------------------------
          -- The cost method is not Period weighted average.
          -- The user should compute the issue costs and update
          -- WPPB IN columns within their custom logic.
          --------------------------------------------------------------------

          l_stmt_num := 30;

          l_cost_method_hook := CSTPFCHK.pac_wip_issue_cost_hook(
                                        i_pac_period_id    => p_pac_period_id,
                                        i_org_id           => l_org_id,
                                        i_cost_group_id    => p_cost_group_id,
                                        i_cost_type_id     => p_cost_type_id,
                                        i_cost_method      => p_cost_method,
                                        i_txn_id           => p_txn_id,
                                        i_cost_layer_id    => l_cost_layer_id,
                                        i_qty_layer_id     => l_qty_layer_id,
                                        i_pac_rates_id     => p_pac_rates_id,
                                        i_item_id          => l_item_id,
                                        i_pri_qty          => l_pri_qty,
                                        i_txn_action_id    => l_txn_action_id,
                                        i_entity_id        => l_entity_id,
                                        i_line_id          => l_line_id,
                                        i_op_seq           => l_op_seq,
                                        i_exp_flag         => l_exp_flag,
                                        i_user_id          => p_user_id,
                                        i_login_id         => p_login_id,
                                        i_req_id           => p_request_id,
                                        i_prg_appl_id      => p_prog_app_id,
                                        i_prg_id           => p_prog_id,
                                        o_err_num          => l_err_num,
                                        o_err_code         => l_err_code,
                                        o_err_msg          => l_err_msg);

          IF (l_err_num <> 0) THEN

                RAISE CST_FAIL_METHOD_HOOK;

          END IF;

        ELSE -- Cost method is not PWAC get cost from MPACD

          --------------------------------------------------------------------
          -- Cost Method is weighted average so get cost from CPIC table
          --------------------------------------------------------------------

          l_stmt_num := 35;

        -- Check if eAM entity then compute actuals
        IF l_entity_type in (6,7) THEN /* Also include closed WO for Actuals Bug 5366094 */

            CST_UTILITY_PUB.get_ZeroCostIssue_Flag(
                                        p_api_version    => 1.0,
                                        x_return_status  => l_return_status,
                                        x_msg_count      => l_msg_count,
                                        x_msg_data       => l_msg_data,
                                        p_txn_id         => p_txn_id,
                                        x_zero_cost_flag => l_zero_cost_flag);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_err_msg := SUBSTR('fail_zero_cost_flag txn_id : '
                                        ||TO_CHAR(p_txn_id)
                                        ||l_err_msg,1,2000);
                RAISE CST_PROCESS_ERROR;
            END IF;


            SELECT DECODE(l_zero_cost_flag,
                          0, nvl(cpic.item_cost,0), 0) *  (-1 * l_pri_qty )
            INTO   l_applied_value
            FROM   wip_discrete_jobs wdj,
                   cst_pac_item_costs cpic
            WHERE  cpic.pac_period_id = p_pac_period_id
            AND    cpic.cost_group_id = p_cost_group_id
            AND    cpic.inventory_item_id = l_item_id
            AND    wdj.wip_entity_id = l_entity_id;


            CST_PacEamCost_GRP.Compute_PAC_JobActuals(
                                p_api_version      => 1.0,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data,
                                p_legal_entity_id  => p_legal_entity,
                                p_cost_group_id    => p_cost_group_id,
                                p_cost_type_id     => p_cost_type_id,
                                p_pac_period_id    => p_pac_period_id,
                                p_pac_ct_id        => p_pac_rates_id,
                                p_organization_id  => l_org_id,
                                p_txn_mode         => 1,    -- To indicate it is Material Item txn
                                p_txn_id           => p_txn_id,
                                p_value            => l_applied_value,
                                p_wip_entity_id    => l_entity_id,
                                p_op_seq           => l_op_seq,
                                p_resource_id      => NULL,
                                p_resource_seq_num => NULL,
                                p_user_id          => p_user_id,
                                p_request_id       => p_request_id,
                                p_prog_app_id      => p_prog_app_id,
                                p_prog_id          => p_prog_id,
                                p_login_id         => p_login_id);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_err_msg := SUBSTR('fail_MAT_PAC_comt_jobAct ent : '
                                        ||TO_CHAR(l_entity_id)
                                        ||': (' || to_char(l_stmt_num) || '): '
                                        ||l_err_msg,1,2000);
                RAISE CST_PROCESS_ERROR;
            END IF;

        END IF; -- end eAM check

          charge_wip_pwac_cost(
                                p_pac_period_id			=> p_pac_period_id,
                                p_cost_group_id			=> p_cost_group_id,
                                p_pri_qty			=> l_pri_qty,
                                p_item_id			=> l_item_id,
                                p_entity_id			=> l_entity_id,
                                p_line_id			=> l_line_id,
                                p_op_seq			=> l_op_seq,
			        p_material_relief_algorithm     => p_material_relief_algorithm,
                                p_user_id			=> p_user_id,
                                p_login_id			=> p_login_id,
                                p_request_id			=> p_request_id,
                                p_prog_id			=> p_prog_id,
                                p_prog_app_id			=> p_prog_app_id,
                                x_err_num			=> l_err_num,
                                x_err_code			=> l_err_code,
                                x_err_msg			=> l_err_msg,
                                p_zero_cost_flag		=> l_zero_cost_flag); -- Sending this as rebuild items should respect this

          IF (l_err_num <> 0) THEN
                l_err_msg := SUBSTR('Item_id: ' || TO_CHAR(l_item_id) || ':' || l_err_msg,1,0040);
                RAISE CST_PROCESS_ERROR;
          END IF;


        END IF; -- check for hook

        ----------------------------------------------------------------------
        -- Call Cost Processor
        ----------------------------------------------------------------------

        l_stmt_num := 40;

        l_uom_conv_rate := 1;

        IF (p_uom_control <> 1) THEN

                l_stmt_num := 45;

                CSTPPINV.get_um_rate (
                        i_txn_org_id            => l_org_id,
                        i_master_org_id         => p_master_org_id,
                        i_txn_cost_group_id     => -1,
                        i_txfr_cost_group_id    => -2,
                        i_txn_action_id         => l_txn_action_id,
                        i_item_id               => l_item_id,
                        i_uom_control           => p_uom_control,
                        i_user_id               => p_user_id,
                        i_login_id              => p_login_id,
                        i_request_id            => p_request_id,
                        i_prog_id               => p_prog_id,
                        i_prog_appl_id          => p_prog_app_id,
                        o_um_rate               => l_uom_conv_rate,
                        o_err_num               => l_err_num,
                        o_err_code              => l_err_code,
                        o_err_msg               => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('UOM conv error txn_id: '
                                                ||TO_CHAR(p_txn_id)
                                                ||':'
                                                ||l_err_msg,1,2000);
                         RAISE CST_PROCESS_ERROR;

                END IF;

        END IF; -- check for uom control level

        l_stmt_num := 50;

        CSTPPWAC.cost_processor
                (i_legal_entity         => p_legal_entity,
                 i_pac_period_id        => p_pac_period_id,
                 i_org_id               => l_org_id,
                 i_cost_group_id        => p_cost_group_id,
                 i_txn_cost_group_id    => NULL,
                 i_txfr_cost_group_id   => NULL,
                 i_cost_type_id         => p_cost_type_id,
                 i_cost_method          => p_cost_method,
                 i_process_group        => 2,
                 i_txn_id               => p_txn_id,
                 i_qty_layer_id         => l_qty_layer_id,
                 i_cost_layer_id        => l_cost_layer_id,
                 i_pac_rates_id         => p_pac_rates_id,
                 i_item_id              => l_item_id,
                 i_txn_qty              => l_pri_qty * l_uom_conv_rate,
                 i_txn_action_id        => l_txn_action_id,
                 i_txn_src_type_id      => 5,
                 i_fob_point            => NULL,
                 i_exp_item             => l_exp_item,
                 i_exp_flag             => l_exp_flag,
                 i_cost_hook_used       => l_cost_method_hook,
                 i_user_id              => p_user_id,
                 i_login_id             => p_login_id,
                 i_req_id               => p_request_id,
                 i_prg_appl_id          => p_prog_app_id,
                 i_prg_id               => p_prog_id,
                 i_txn_category         => p_txn_category,
                 o_err_num              => l_err_num,
                 o_err_code             => l_err_code,
                 o_err_msg              => l_err_msg);

        IF (l_err_num <> 0) THEN

                l_err_msg := SUBSTR('Txn_id: '
                                                ||TO_CHAR(p_txn_id)
                                                ||':'
                                                ||l_err_msg,1,2000);

                RAISE CST_PROCESS_ERROR;

        END IF;

        x_cost_method_hook := l_cost_method_hook;

       IF (l_pLog) THEN
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
       END IF;

EXCEPTION

        WHEN CST_NO_WIP_COMP_TXN THEN
                x_err_num := 20007;
                x_err_code := SUBSTR('CSTPPWMT.charge_wip_material('
                                || to_char(l_stmt_num)
                                || '): '
                                || l_err_msg
                                || '. ',1,240);
                fnd_message.set_name('BOM', 'CST_NO_WIP_COMP_TXN');
                x_err_msg := SUBSTR(fnd_message.get,1,2000);

        WHEN CST_FAIL_METHOD_HOOK THEN
                x_err_num := 20010;
                x_err_code := SUBSTR('CSTPPWMT.charge_wip_material('
                                || to_char(l_stmt_num)
                                || '): '
                                || l_err_msg
                                || '. ',1,240);
                fnd_message.set_name('BOM', 'CST_FAIL_METHOD_HOOK');
                x_err_msg := SUBSTR(fnd_message.get,1,2000);

        WHEN CST_PROCESS_ERROR THEN
                x_err_num := l_err_num;
                x_err_code := l_err_code;
                x_err_msg := l_err_msg;

        WHEN OTHERS THEN
	         IF (l_uLog) THEN
                    FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                   l_module || '.' || l_stmt_num,
                                   SQLERRM);
                END IF;
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWMT.charge_wip_material('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);

END charge_wip_material;

/*----------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                           |
|       charge_wip_pwac_cost                                                  |
*----------------------------------------------------------------------------*/
PROCEDURE charge_wip_pwac_cost(
        p_pac_period_id			IN           NUMBER,
        p_cost_group_id			IN           NUMBER,
        p_pri_qty			IN           NUMBER,
        p_item_id			IN           NUMBER,
        p_entity_id			IN           NUMBER,
        p_line_id			IN           NUMBER,
        p_op_seq			IN           NUMBER,
        p_material_relief_algorithm     IN           NUMBER,
        p_user_id			IN           NUMBER,
        p_login_id			IN           NUMBER,
        p_request_id			IN           NUMBER,
        p_prog_id			IN           NUMBER,
        p_prog_app_id			IN           NUMBER,
        x_err_num			OUT NOCOPY   NUMBER,
        x_err_code			OUT NOCOPY   VARCHAR2,
        x_err_msg			OUT NOCOPY   VARCHAR2,
        p_zero_cost_flag		IN           NUMBER) -- Default 0 Variable added for eAM support in PAC

IS

l_stmt_num                   NUMBER;
l_err_num                    NUMBER;
l_err_code                   VARCHAR2(240);
l_err_msg                    VARCHAR2(240);

l_api_name            CONSTANT VARCHAR2(30) := 'charge_wip_pwac_cost';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

       IF (l_pLog) THEN
         FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.begin',
                        l_api_name || ' <<< Parameters:
			p_pri_qty = ' || p_pri_qty || '
			p_item_id = ' || p_item_id || '
			p_entity_id = ' || p_entity_id || '
			p_line_id = ' || p_line_id ||'
			p_op_seq = ' || p_op_seq );
       END IF;
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';

        --------------------------------------------------------------------
        -- Cost Method is weighted average so get cost from CPIC table
        -- and update WPPB
        --------------------------------------------------------------------

        l_stmt_num := 5;

        UPDATE wip_pac_period_balances wppb
        SET
          (pl_material_in,
           pl_material_overhead_in,
           pl_resource_in,
           pl_outside_processing_in,
           pl_overhead_in,
           last_update_date,
           last_updated_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date) =
          (
            SELECT -- Checking p_zero_cost_flag for rebuild items as part of eAM support in PAC
                NVL(wppb.pl_material_in,0) +
                    (DECODE(p_zero_cost_flag,0,NVL(cpic.material_cost,0),0) * (-1 * p_pri_qty)),

                NVL(wppb.pl_material_overhead_in,0)  +
                    (DECODE(p_zero_cost_flag,0,NVL(cpic.material_overhead_cost,0),0) * (-1 * p_pri_qty)),

                NVL(wppb.pl_resource_in,0) +
                    (DECODE(p_zero_cost_flag,0,NVL(cpic.resource_cost,0),0) * (-1 * p_pri_qty)),

                NVL(wppb.pl_outside_processing_in,0)+
                    (DECODE(p_zero_cost_flag,0,NVL(cpic.outside_processing_cost,0),0) * (-1 * p_pri_qty)),

                NVL(wppb.pl_overhead_in,0) +
                    (DECODE(p_zero_cost_flag,0,NVL(cpic.overhead_cost,0),0) * (-1 * p_pri_qty)),

                SYSDATE,
                p_user_id,
                p_login_id,
                p_request_id,
                p_prog_app_id,
                p_prog_id,
                SYSDATE
            FROM    cst_pac_item_costs cpic
            WHERE   cpic.pac_period_id = p_pac_period_id
            AND     cpic.cost_group_id = p_cost_group_id
            AND     cpic.inventory_item_id = p_item_id
          )
        WHERE       wppb.pac_period_id = p_pac_period_id
        AND         wppb.cost_group_id = p_cost_group_id
        AND         wppb.wip_entity_id = p_entity_id
        AND         NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
        AND         wppb.operation_seq_num = p_op_seq
        AND EXISTS
                ( SELECT 'X'
                  FROM    cst_pac_item_costs cpic2
                  WHERE   cpic2.pac_period_id = p_pac_period_id
                  AND     cpic2.cost_group_id = p_cost_group_id
                  AND     cpic2.inventory_item_id = p_item_id);

/*Bug 2995978 - Added for updating assembly pull Components IN values*/
-- No need to Check p_zero_cost_flag for rebuild items as eAM does not have Assembly pull items.

       l_stmt_num := 10;

        UPDATE wip_pac_period_balances wppb
        SET
          (pl_material_in_apull,
           pl_material_overhead_in_apull,
           pl_resource_in_apull,
           pl_outside_processing_in_apull,
           pl_overhead_in_apull,
           last_update_date,
           last_updated_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date) =
          (
        SELECT
                  NVL(wppb.pl_material_in_apull,0) +
                        (NVL(cpic.material_cost,0) * (-1 * p_pri_qty)),

                  NVL(wppb.pl_material_overhead_in_apull,0)  +
                        (NVL(cpic.material_overhead_cost,0) * (-1 * p_pri_qty)),

                  NVL(wppb.pl_resource_in_apull,0) +
                        (NVL(cpic.resource_cost,0) * (-1 * p_pri_qty)),

                  NVL(wppb.pl_outside_processing_in_apull,0)+
                        (NVL(cpic.outside_processing_cost,0)* (-1 * p_pri_qty)),

                  NVL(wppb.pl_overhead_in_apull,0) +
                        (NVL(cpic.overhead_cost,0) * (-1 * p_pri_qty)),

                  SYSDATE,
                  p_user_id,
                  p_login_id,
                  p_request_id,
                  p_prog_app_id,
                  p_prog_id,
                  SYSDATE
        FROM      cst_pac_item_costs cpic
        WHERE     cpic.pac_period_id = p_pac_period_id
        AND       cpic.cost_group_id = p_cost_group_id
        AND       cpic.inventory_item_id = p_item_id
  )
        WHERE     wppb.pac_period_id = p_pac_period_id
        AND       wppb.cost_group_id = p_cost_group_id
        AND       wppb.wip_entity_id = p_entity_id
        AND       NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
        AND       wppb.operation_seq_num = p_op_seq
        AND EXISTS
                ( SELECT  'X'
                  FROM    cst_pac_item_costs cpic2
                  WHERE   cpic2.pac_period_id = p_pac_period_id
                  AND     cpic2.cost_group_id = p_cost_group_id
                  AND     cpic2.inventory_item_id = p_item_id)
       AND EXISTS
               ( SELECT    'ASSY PULL'
                 FROM      wip_requirement_operations wro
                 WHERE     wro.wip_entity_id = p_entity_id
                AND        wro.wip_supply_type = 2
                AND        wro.inventory_item_id = p_item_id
                AND        wro.operation_seq_num = p_op_seq);

/* R12 PAC Enhancement: Populate CPROCD only for Use BOM based Material Algo  */
IF (p_material_relief_algorithm = 0) THEN
   -- BOM Based algo
 l_stmt_num := 40;
 MERGE INTO CST_PAC_REQ_OPER_COST_DETAILS cprocd
 USING (SELECT sum(NVL(cpicd.ITEM_COST,0) * -1 * p_pri_qty)  cost,
              (-1 * p_pri_qty) qty,
               cpicd.cost_element_id cost_element_id
         FROM  CST_PAC_ITEM_COSTS cpic,
               CST_PAC_ITEM_COST_DETAILS cpicd
         WHERE cpic.pac_period_id = p_pac_period_id
         AND   cpic.cost_group_id = p_cost_group_id
         AND   cpic.inventory_item_id = p_item_id
         AND   cpic.cost_layer_id = cpicd.cost_layer_id
         GROUP BY cpicd.cost_element_id ) s

ON  ( cprocd.wip_entity_id = p_entity_id
     AND nvl(cprocd.line_id,-99) = nvl(p_line_id, -99)
     AND cprocd.inventory_item_id = p_item_id
     AND cprocd.operation_seq_num = p_op_seq
     AND cprocd.pac_period_id = p_pac_period_id
     AND cprocd.cost_group_id = p_cost_group_id
     AND cprocd.cost_element_id = s.cost_element_id)

WHEN MATCHED THEN UPDATE SET cprocd.applied_value = nvl(cprocd.applied_value,0) + nvl(s.cost,0),
                             cprocd.applied_quantity = nvl( cprocd.applied_quantity,0) + nvl(s.qty,0),
                             cprocd.last_update_date = SYSDATE,
                             cprocd.last_updated_by = p_user_id,
                             cprocd.last_update_login = p_login_id,
                             cprocd.request_id = p_request_id,
                             cprocd.program_application_id = p_prog_app_id,
                             cprocd.program_id = p_prog_id,
                             cprocd.program_update_date = SYSDATE

WHEN NOT MATCHED THEN INSERT ( pac_period_id,
                               cost_group_id,
                               wip_entity_id,
                               line_id,
                               inventory_item_id,
                               cost_element_id,
                               operation_seq_num,
                               applied_value,
                               applied_quantity,
                               relieved_value,
                               relieved_quantity,
                               comp_variance,
                               creation_date,
                               created_by,
			       last_update_date,
                               last_updated_by,
                               last_update_login,
                               request_id,
                               program_application_id,
                               program_id,
                               program_update_date)
                       VALUES (p_pac_period_id,
                               p_cost_group_id,
                               p_entity_id,
                               p_line_id,
                               p_item_id,
                               s.cost_element_id,
                               p_op_seq,
                               s.cost,
                               s.qty,
                               0,
                               0,
                               0,
                               SYSDATE,
                               p_user_id,
			       SYSDATE,
                               p_user_id,
                               p_login_id,
                               p_request_id,
                               p_prog_app_id,
                               p_prog_id,
                               SYSDATE);
END IF;

       IF (l_pLog) THEN
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
       END IF;

EXCEPTION
        WHEN OTHERS THEN
             IF (l_uLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                l_module || '.' || l_stmt_num,
                               SQLERRM);
             END IF;
             ROLLBACK;
             x_err_num := SQLCODE;
             x_err_code := NULL;
             x_err_msg := SUBSTR('CSTPPWMT.charge_wip_pwac_cost('
                             || to_char(l_stmt_num)
                             || '): '
                             ||SQLERRM,1,240);

END charge_wip_pwac_cost;

END cstppwmt;

/
