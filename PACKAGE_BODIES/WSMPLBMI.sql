--------------------------------------------------------
--  DDL for Package Body WSMPLBMI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLBMI" AS
/* $Header: WSMLBMIB.pls 120.97.12010000.3 2009/12/23 12:02:50 sisankar ship $ */

--mes
g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error         NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success       NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error             VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
--mes end

/*-------------------------------------------------------------+
| CUSTOM_VALIDATION:                                           |
---------------------------------------------------------------*/

/* Project I : Jump_enh
This procedure assumes that it is a jump-from-queue transaction.
If there are no charges (material/resources/overheads) then
the jump should not consider the "from op" as completed and
no material/resource/overhead charges are applicable for the
'from op'.
This is a PRIVATE procedure */

Procedure val_jump_from_queue(p_wip_entity_id   IN  NUMBER,
                  p_org_id          IN  NUMBER,
                  p_fm_op_seq_num   IN  NUMBER,
                  p_wo_op_seq_id    IN  NUMBER,
                  x_return_code     OUT NOCOPY NUMBER,
                  x_err_buf         OUT NOCOPY VARCHAR2)
IS
l_charges_exist             number;
l_manually_added_comp       number;
l_issued_material           number;
l_manually_added_resource   number;
l_issued_resource           number;
l_stmt_num          number;

BEGIN
    l_stmt_num := 10;
    WSMPUTIL.check_charges_exist (  p_wip_entity_id,
                    p_org_id,
                                p_fm_op_seq_num,
                    p_wo_op_seq_id,
                        l_charges_exist,
                        l_manually_added_comp,
                        l_issued_material,
                        l_manually_added_resource,
                        l_issued_resource,
                                x_return_code,
                                x_err_buf);

       /* The condition x_return_code <> 0 will be handled by the main WSMLBMIB
          code */
       If (x_return_code = 0) THEN
    If l_debug = 'Y' Then
        fnd_file.put_line(fnd_file.log, 'Returned success from check_charges_exist. l_charges_exist='||l_charges_exist);
        End if;
    if (l_charges_exist=1) then
        if ((l_manually_added_resource = 1) or (l_issued_resource = 1)) then

                    fnd_message.set_name('WSM', 'WSM_MANUAL_CHARGES_EXIST');
                    fnd_message.set_token('ELEMENT', 'Resources');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, x_err_buf);
        end if;

                if (l_manually_added_comp = 2) then
                        FND_MESSAGE.Set_Name('WSM','WSM_PHANTOM_COMPONENTS_EXIST');
                        x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, x_err_buf);
                end if;

        if ((l_manually_added_comp = 1) or (l_issued_material = 1)) then
                    fnd_message.set_name('WSM', 'WSM_MANUAL_CHARGES_EXIST');
                    fnd_message.set_token('ELEMENT', 'Materials');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, x_err_buf);
        end if;

    end if;
       end if;

EXCEPTION
    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'WSMPLBMI.val_jump_from_queue' ||'(stmt_num='||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END val_jump_from_queue;


FUNCTION custom_validation( p_header_id                 IN  NUMBER,
                            p_txn_id                    IN  NUMBER,
                            p_txn_qty                   IN  NUMBER,
                            p_txn_date                  IN  DATE,
                            p_txn_uom                   IN  VARCHAR2,
                            p_primary_uom               IN  VARCHAR2,
                            p_txn_type                  IN  NUMBER,
                            p_fm_op_seq_num             IN  OUT NOCOPY NUMBER,
                            p_fm_op_code                IN  VARCHAR2,
                            p_fm_intraop_step_type      IN  NUMBER,
                            p_to_op_seq_num             IN  NUMBER,
                            p_to_op_code                IN  VARCHAR2,
                            p_to_intraop_step_type      IN  NUMBER,
                            p_to_dept_id                IN  NUMBER,
                            p_wip_entity_name           IN  VARCHAR2,
                            p_org_id                    IN  NUMBER,
                            p_jump_flag                 IN  VARCHAR2,
                            -- ST : Serial Support Project --
                            x_serial_ctrl_code          OUT NOCOPY NUMBER,
                            x_available_qty             OUT NOCOPY NUMBER,
                            x_current_job_op_seq_num    OUT NOCOPY NUMBER,
                            x_current_intraop_step      OUT NOCOPY NUMBER,
                            x_current_rtg_op_seq_num    OUT NOCOPY NUMBER,
                            x_old_scrap_transaction_id  OUT NOCOPY NUMBER,
                            x_old_move_transaction_id   OUT NOCOPY NUMBER,
                            -- ST : Serial Support Project --
                            x_err_buf              OUT NOCOPY VARCHAR2,
                            x_undo_source_code      OUT NOCOPY VARCHAR2
                            ) RETURN NUMBER IS

    x_return_code           NUMBER;
    l_stmt_num              NUMBER;
    l_wip_entity_id         NUMBER := 0;
    l_entity_type           NUMBER := 0;
    l_status_type           NUMBER := 0;
    l_current_op_seq        NUMBER := 0;
    l_current_intraop_step  NUMBER := 0;
    l_std_operation_id      NUMBER := 0;
    l_intra_op_flag_value   NUMBER := 0;
    l_operation_qty         NUMBER := 0;
    l_converted_txn_qty     NUMBER := 0;
    l_uom                   VARCHAR2(5);
    l_err_condition         NUMBER := 0;
    l_next_mand_step        NUMBER := 0;
    l_res_rows              NUMBER := 0;
    l_routing_seq_id        NUMBER := 0;
    l_retcode               NUMBER := 0;
    l_reason_id             NUMBER := 0;
    l_wlmti_wip_entity_id   NUMBER := 0;
    l_mtr_reason_name       VARCHAR2(30);
    l_reason_name           VARCHAR2(30);
    l_wlmti_org_code        VARCHAR2(3);
    l_org_code              VARCHAR2(3);
    l_wlmti_last_upd_by     NUMBER := 0;
    l_wlmti_last_upd_name   VARCHAR2(100);
    l_wlmti_created_by      NUMBER := 0;
    l_wlmti_created_by_name VARCHAR2(100);
    l_user_name             VARCHAR2(100);
    l_wlmti_acct_period_id  NUMBER := 0;

    l_wo_op_seq_num         NUMBER := 0;
    l_wo_op_seq_id          NUMBER := 0;
    l_wo_std_op_id          NUMBER := 0;
    l_wo_dept_id            NUMBER := 0;
    l_wo_qty_scrap_step     NUMBER := 0;
    l_wo_qty_in_queue       NUMBER := 0;
    l_wo_qty_in_running     NUMBER := 0;
    l_wo_qty_in_tomove      NUMBER := 0;
    l_wo_qty_in_scrap       NUMBER := 0;
    l_wo_op_code            VARCHAR2(4);
    l_wo_qty_iop_step       NUMBER := 0;
    l_wo_qty                NUMBER := 0;

    l_end_op_seq_num        NUMBER := 0;
    l_end_op_code           VARCHAR2(4);
    l_end_op_seq_id         NUMBER := 0;
    l_end_std_op_id         NUMBER := 0;
    l_end_dept_id           NUMBER := 0;

    l_op_code               VARCHAR2(4);
    l_op_seq_id             NUMBER := 0;
    l_std_op_id             NUMBER := 0;
    l_dept_id               NUMBER := 0;

    l_jmp_op_code           VARCHAR2(4);
    l_jmp_op_seq_id         NUMBER := 0;
    l_jmp_std_op_id         NUMBER := 0;
    l_jmp_dept_id           NUMBER := 0;

    l_txn_type              NUMBER := 0;
    l_primary_item_id       NUMBER := 0;
    l_wlmti_primary_item_id NUMBER := 0;
    l_bom_revision_date     DATE;
    l_rtg_revision_date     DATE;         --ADD: CZH.I_OED-1
    l_alt_bom_desig         VARCHAR2(10);
    l_max_op_seq            NUMBER := 0;
    l_max_qty_op_seq_num    NUMBER := 0;
    l_max_txn_id            NUMBER := 0;

    l_cmp_primary_item_id       NUMBER := 0;
    l_cmp_subinv                VARCHAR2(10);
    l_cmp_loc_id                NUMBER := 0;
--bug 4665604 OSFM-UT: OPMCONV: UNABLE TO RETURN A JOB WITH LENGTH 80 CHARS THRU INTERFACE
--    l_cmp_lot_number            VARCHAR2(30);
    l_cmp_lot_number            VARCHAR2(240);
    l_cmp_txn_qty               NUMBER := 0;
    l_cmp_fm_op_seq_num         NUMBER := 0;
    l_cmp_fm_op_code            VARCHAR2(4);
    l_cmp_fm_intra_op_step      NUMBER := 0;
    l_cmp_fm_dept_id            NUMBER := 0;
    l_cmp_to_op_seq_num         NUMBER := 0;
    l_cmp_to_op_code            VARCHAR2(4);
    l_cmp_to_dept_id            NUMBER := 0;
    l_onhand_qty                NUMBER := 0;
    l_kanban_card_id            NUMBER := ''; --abbKanban
    x_warning_mesg              VARCHAR2(2000);  --abbKanban
    l_returnStatus              VARCHAR2(1) := ''; --abbKanban
    l_cur_supply_status         NUMBER := ''; --abbKanban

    l_fm_op_seq_num             NUMBER := 0;
    l_fm_op_code                VARCHAR2(4);
    l_fm_intraop_step           NUMBER := 0;
    l_fm_dept_id                NUMBER := 0;
    l_to_op_seq_num             NUMBER := 0;
    l_to_op_code                VARCHAR2(4);
    l_to_intraop_step           NUMBER := 0;
    l_to_dept_id                NUMBER := 0;

    l_txn_id                    NUMBER := 0;
    l_wmt_txn_qty               NUMBER := 0;
    --bug 5349187 initialize l_wmt_scrap_acct_id as -1 found a related issue when fixing bug 5349187
    --initialization of l_wmt_scrap_acct_id to 0 causes nvl to consider it as not null causing problems
    --since scrap_account_id gets stamped as 0
    --l_wmt_scrap_acct_id         NUMBER := 0;
    l_wmt_scrap_acct_id         NUMBER := -1;
    l_wlmti_scrap_acct_id       NUMBER := 0;
    l_allow_bkw_move            NUMBER := 0;
    l_qty_completed             NUMBER := 0;
    l_primary_uom               VARCHAR2(3);
    l_est_scrap_acc             NUMBER := 0; -- abb H
    l_job_type                  NUMBER := 0; -- abb H
    l_bom_reference_id          NUMBER := 0; -- abb H

    l_iop_move_out_rtg          BOOLEAN := FALSE;
    l_group_id                  NUMBER := 0;
    l_temp                      NUMBER := 0;
    l_fm_op_code_temp           VARCHAR2(4);   -- Fix for bug #2081442
    l_wip_entity_name_temp      VARCHAR2(240); -- Fix for bug #2095035
    l_error_msg                 VARCHAR2(2000) := NULL; -- CZH.BUG2135538
    l_scrap_account     number;
    l_est_scrap_abs_account number;
    p_est_scrap_account     number;
    p_est_scrap_var_account number;
    l_jump_from_queue           boolean:=FALSE;
    l_class_code        varchar2(10);
    l_err_code          number;
    l_err_msg           varchar2(2000);
    l_yes           number:=1;
--move enh
--bug 3387642 default to 0
    l_scrap_qty     NUMBER := 0;
    l_cmp_batch_id      NUMBER;
--bug 3385113 default to 0
    l_scrap_at_operation_flag   NUMBER := 0;
    l_recommended       VARCHAR2(1) := 'N';
    l_scrap_acc_id      NUMBER;
--bug 3571019
    l_from_scrap_id      NUMBER;
    l_to_scrap_id        NUMBER;
--end bug 3571019
    l_jmp_to_dept_code  VARCHAR2(10);
    l_wmt_scrap_qty NUMBER;
    l_wmt_pri_scrap_qty NUMBER;
    l_wmt_pri_txn_qty   NUMBER;
--bug 3387642 default to 0
    l_converted_scrap_qty   NUMBER := 0;
    l_wmt_scrap_at_op_flag  NUMBER;
        l_to_dept_code      VARCHAR2(10);
    l_new_op_txn_qty    NUMBER;
    l_bk_move_chk_qty   NUMBER;
    l_fm_op_bkflsh_flag     NUMBER;
    l_to_op_bkflsh_flag     NUMBER;
--bug 3370199
    l_wo_rtg_op_seq_num     NUMBER;
--bug 3615826
    l_scrap_txn_id      NUMBER;
--end move enh
    l_wmt_scrap_acc     NUMBER;
--mes
    l_source_code       WSM_LOT_MOVE_TXN_INTERFACE.source_code%type;
    -- Logging variables.....
    l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
    l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.custom_validations';
    l_param_tbl                             WSM_Log_PVT.param_tbl_type;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             number;
    l_msg_data                              varchar2(4000);
--mes end
    -- ST : Serial Support Project --
    l_serial_ctrl_code  NUMBER;
    -- ST : Serial Support Project --
    p_fm_op_seq_num_orig number; -- bug 5349187
BEGIN
    x_return_code := 0;
    x_err_buf := '';
    l_stmt_num := 10;

    if (l_debug = 'Y') then
fnd_file.put_line(fnd_file.log, 'g_aps_wps_profile '||g_aps_wps_profile);
        fnd_file.put_line(fnd_file.log, '*******************Parameters to WSMPLBMI*******************');

        fnd_file.put_line(fnd_file.log, 'p_header_id='||p_header_id||
                                        ', p_txn_id='||p_txn_id||
                                        ', p_wip_entity_name='||p_wip_entity_name||
                                        ', p_txn_qty='||p_txn_qty||
                                        ', p_txn_date='||p_txn_date||
                                        ', p_txn_uom='||p_txn_uom||
                                        ', p_primary_uom='||p_primary_uom||
                                        ', p_txn_type='||p_txn_type||
                                        ', p_fm_op_seq_num='||p_fm_op_seq_num||
                                        ', p_fm_op_code='||p_fm_op_code||
                                        ', p_fm_intraop_step_type='||p_fm_intraop_step_type||
                                        ', p_to_op_seq_num='||p_to_op_seq_num||
                                        ', p_to_op_code='||p_to_op_code||
                                        ', p_to_intraop_step_type='||p_to_intraop_step_type||
                                        ', p_to_dept_id='||p_to_dept_id||
                                        ', p_org_id='||p_org_id||
                                        ', p_jump_flag='||p_jump_flag );
        fnd_file.put_line(fnd_file.log, '');

        fnd_file.put_line(fnd_file.log, 'g_prev_org_id='||g_prev_org_id||
                                        ', g_prev_org_code='||g_prev_org_code||
                                        ', g_prev_cr_user_id='||g_prev_cr_user_id||
                                        ', g_prev_cr_user_name='||g_prev_cr_user_name||
                                        ', g_prev_upd_user_id='||g_prev_upd_user_id||
                                        ', g_prev_upd_user_name='||g_prev_upd_user_name||
                                        ', g_prev_op_seq_incr='||g_prev_op_seq_incr||
                                        ', g_acct_period_id='||g_acct_period_id||
                                        ', g_prev_txn_date='||g_prev_txn_date);
        fnd_file.put_line(fnd_file.log, '');
    end if;

    --***VJ Added for Performance Upgrade***--
    IF (p_txn_type < 1) OR (p_txn_type > 4) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_type');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    -- Changed p_txn_type to l_txn_type in this procedure
    l_txn_type := p_txn_type;
    --***VJ End Additions***--

    --***VJ Added for Performance Upgrade***--
    if (g_prev_org_id <> p_org_id) THEN
    --g_prev_org_id := p_org_id;    -- bugfix 2363469 : Reset the prev_org_id later
    --***VJ End Additions***--

    BEGIN
/*****************Bug 5051836*******************************
            select organization_code
            into   l_org_code
            from   org_organization_definitions
            where  organization_id = p_org_id;
*****************Bug 5051836*******************************/

        select organization_code
        into   l_org_code
        from   mtl_parameters
        where  organization_id = p_org_id;
    EXCEPTION
        when no_data_found then
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Organization_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log,
         'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                x_return_code := 1;
            return(x_return_code);
    END;

        x_return_code := WSMPUTIL.CHECK_WSM_ORG (p_org_id, l_retcode, x_err_buf);

        IF ( (x_return_code = 0) OR (l_retcode<>0) ) THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_NON_WSM_ORG');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

            return(x_return_code);
        END IF;

    l_stmt_num := 20;
        g_prev_org_code := l_org_code;

    --***VJ: Start changes for removal of 9999***--
--      SELECT nvl(last_operation_seq_num, 9999), nvl(op_seq_num_increment, 10)
--      INTO   g_prev_last_op, g_prev_op_seq_incr

        SELECT nvl(op_seq_num_increment, 10),
           allow_backward_move_flag,
           charge_jump_from_queue
        INTO   g_prev_op_seq_incr,
           g_allow_bkw_move,
           g_param_jump_fm_q
        FROM   wsm_parameters
        WHERE  organization_id = p_org_id;
    --***VJ: End changes for removal of 9999***--

    --
        -- bugfix 2363469 : as part of this fix, we realized that the acct_prd check was being performed
    -- only when there is an organization change which is incorrect.
    -- When the txn_date changes within the same orgn, we should get the acct_period.
    --
    END IF;  -- end of org_id check : g_prev_org_id <> p_org_id


l_stmt_num := 25;
    -- IF (trunc(nvl(p_txn_date, sysdate)) <> trunc(nvl(g_prev_txn_date, sysdate))) THEN
    -- Start fix for bug #2081464
    IF (p_org_id <> g_prev_org_id)    -- bugfix 2363469 : added orgn_id condn
                          -- g_prev_org_id has already been initialized before.
       --AND    -- CHG: BUG2644080/2762011, whenever org_id is different, fetch acct_period_id
       OR       -- CHG: BUG2644080/2762011
       ( (g_prev_txn_date IS NOT NULL AND trunc(nvl(p_txn_date, sysdate)) <> trunc(nvl(g_prev_txn_date, sysdate)))
     OR
     (g_prev_txn_date IS NULL) )
    THEN
    --End fix for bug #2081464
--bug 3126650 changed from SQL to the following procedure
/*        SELECT MAX(ACCT_PERIOD_ID)
        INTO   g_acct_period_id
            FROM   ORG_ACCT_PERIODS
            WHERE  PERIOD_CLOSE_DATE IS NULL
            AND    ORGANIZATION_ID = p_org_id
            AND    TRUNC(NVL(p_txn_date,SYSDATE))
                   BETWEEN PERIOD_START_DATE and SCHEDULE_CLOSE_DATE;*/

        g_acct_period_id := WSMPUTIL.GET_INV_ACCT_PERIOD(x_err_code         => l_err_code,
                                                        x_err_msg           => l_err_msg,
                                                        p_organization_id   => p_org_id,
                                                        p_date              => p_txn_date);

        IF (l_err_code <> 0) THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INFO_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'acct_period_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

            l_stmt_num := 30;
        g_prev_txn_date := trunc(nvl(p_txn_date, sysdate));
    END IF;
    g_prev_org_id := p_org_id;      --2363469 :set the prev_org_id here;

l_stmt_num := 31;

    -- Start fix for bug #2095035
    IF (p_wip_entity_name IS NULL) THEN -- if the user has passed wip_entity_id and not wip_entity_name
        SELECT wip_entity_id
        INTO   l_wip_entity_id
        FROM   wsm_lot_move_txn_interface
        WHERE  header_id = p_header_id;

        IF (l_wip_entity_id IS NULL) THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_name/wip_entity_id');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

        l_stmt_num := 32;

            BEGIN

                SELECT wip_entity_name, entity_type
                INTO   l_wip_entity_name_temp, l_entity_type
                FROM   wip_entities
                WHERE  organization_id = p_org_id
                AND    wip_entity_id = l_wip_entity_id;

                IF (l_entity_type <> 5) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_NOT_WSM_LOT_JOB');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entities');
                    x_err_buf := FND_MESSAGE.GET;

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                    return(x_return_code);
                END IF;

        l_stmt_num := 33;

        UPDATE wsm_lot_move_txn_interface
        SET    wip_entity_name = l_wip_entity_name_temp
        WHERE  header_id = p_header_id;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_name');
            x_err_buf := FND_MESSAGE.GET;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_id');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);

            WHEN OTHERS THEN
            x_return_code := SQLCODE;
            x_err_buf := 'WSMPLBMI.custom_validation' ||'(stmt_num='||l_stmt_num||') : '||substrb(sqlerrm,1,1000);
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
           END;

    ELSE  -- if the user has passed wip_entity_name and not wip_entity_id
    -- End fix for bug #2095035
        --***VJ Changed for Performance Upgrade***--
        BEGIN

l_stmt_num := 34;

            SELECT wip_entity_id, entity_type
            INTO   l_wip_entity_id, l_entity_type
            FROM   wip_entities
            WHERE  organization_id = p_org_id
--          AND    wip_entity_name = p_wip_entity_name;
            AND    wip_entity_name = NVL(p_wip_entity_name, l_wip_entity_name_temp); -- Fix for bug #2095035

            IF (l_entity_type <> 5) THEN
            x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_NOT_WSM_LOT_JOB');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entities');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_name');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        END;
        --***VJ End Changes***--
    END IF; -- Fix for bug #2095035

--bug 3512105
    l_stmt_num := 34;
    IF ((g_aps_wps_profile = 'Y')
    AND (WSMPUTIL.get_internal_copy_type(l_wip_entity_id)=3)) THEN
        fnd_message.set_name(
            application => 'WSM',
            name        => 'WSM_NO_VALID_COPY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;
--bug 3512105 end

l_stmt_num := 35;
    --***VJ Added for Performance Upgrade***--
    SELECT status_type, primary_item_id
    INTO   l_status_type, l_primary_item_id
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id = l_wip_entity_id
    AND    organization_id = p_org_id;
    --***VJ End Additions***--

l_stmt_num := 40.1;
    -- Start Fix for bug #2094358
    IF (l_status_type = 4) THEN -- completed job
        --bugfix 1667427
        --if calling the following procedure returns l_current_intraop_step as 5,
        --then it is a completed scrap,

        wsmpoprn.get_current_op(p_wip_entity_id   => l_wip_entity_id,
                                p_current_op_seq  => l_current_op_seq,
                                p_current_op_step => l_current_intraop_step,
                                p_next_mand_step  => l_next_mand_step,
                                x_error_code      => x_return_code,
                                x_error_msg       => x_err_buf);

        --NO CHECK FOR RETURN VALUES HERE....-VJ--
        -- ST : This procedure returns NULL l_current_intraop_step in case of completed jobs and
        -- and returns l_current_intraop_step = 5 in case of completed scrap (all qty scrapped)

        l_stmt_num := 43;
        if (l_current_intraop_step <> 5) then
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_NOT_RELEASED_JOB');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', p_wip_entity_name);
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
         end if;
         --end bug fix 1667427

    ELSIF (l_status_type <> 3) THEN -- not a released job
        l_stmt_num := 46;
        x_return_code := 1;

        -- ST : Bug fix : 4454300 : Instead of the message WSM_NOT_RELEASED_JOB use a new message
        -- for assembly return transaction
        IF p_txn_type = 3 THEN
                -- Assembly return txn
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_RET_JOB_STATUS');
                FND_MESSAGE.SET_TOKEN('JOB', p_wip_entity_name);
        ELSE
                FND_MESSAGE.SET_NAME('WSM', 'WSM_NOT_RELEASED_JOB');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', p_wip_entity_name);
        END IF;
        -- ST : Bug fix : 4454300 : End

        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;
    -- End Fix for bug #2094358

    l_stmt_num := 50;

    -- Validate/Populate wip_entity_id
    SELECT nvl(wip_entity_id, -1)
    INTO   l_wlmti_wip_entity_id
    FROM   wsm_lot_move_txn_interface
    WHERE  header_id = p_header_id
    AND    wip_entity_name = NVL(p_wip_entity_name, l_wip_entity_name_temp); -- Fix for bug #2095035

l_stmt_num := 55;
    IF (l_wlmti_wip_entity_id = -1) THEN

        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_id');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    wip_entity_id = l_wip_entity_id,
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 60;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);

    ELSIF (l_wlmti_wip_entity_id <> l_wip_entity_id) THEN

        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_id');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;

    -- BA: CZH.I_OED-1, get job routing revision date after l_wip_entity_id is available
    SELECT nvl(routing_revision_date, SYSDATE)
    INTO   l_rtg_revision_date
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id = l_wip_entity_id;
    -- EA: CZH.I_OED-1
--mes added source_code
--move enh added l_scrap_at_operation_flag, l_scrap_qty
--bug 3387642 added nvl to scrap_quantity
    --***VJ Added for Performance Upgrade***--
    SELECT  group_id,
        entity_type,
        nvl(primary_item_id, -1),
        organization_code,
        nvl(last_updated_by, -1),
        last_updated_by_name,
        nvl(created_by, -1),
        created_by_name,
        nvl(acct_period_id, -1),
        nvl(reason_id, -1),
        reason_name,
        nvl(scrap_account_id, -1),
        scrap_at_operation_flag,
--        scrap_quantity
    nvl(scrap_quantity, 0),
        source_code
    INTO    l_group_id,
        l_entity_type,
        l_wlmti_primary_item_id,
        l_wlmti_org_code,
        l_wlmti_last_upd_by,
        l_wlmti_last_upd_name,
        l_wlmti_created_by,
        l_wlmti_created_by_name,
        l_wlmti_acct_period_id,
        l_reason_id,
        l_reason_name,
        l_wlmti_scrap_acct_id,
        l_scrap_at_operation_flag,
        l_scrap_qty,
        l_source_code
    FROM    wsm_lot_move_txn_interface
    WHERE   wip_entity_id = l_wip_entity_id
    AND     header_id = p_header_id;
    --***VJ End Additions***--

l_stmt_num := 65;
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'l_entity_type='||l_entity_type||
                                        ', l_wlmti_primary_item_id='||l_wlmti_primary_item_id||
                                        ', l_wlmti_org_code='||l_wlmti_org_code||
                                        ', l_wlmti_last_upd_by='||l_wlmti_last_upd_by||
                                        ', l_wlmti_last_upd_name='||l_wlmti_last_upd_name||
                                        ', l_wlmti_created_by='||l_wlmti_created_by||
                                        ', l_wlmti_created_by_name='||l_wlmti_created_by_name||
                                        ', l_wlmti_acct_period_id='||l_wlmti_acct_period_id||
                                        ', l_reason_id='||l_reason_id||
                                        ', l_reason_name='||l_reason_name||
                                        ', l_wlmti_scrap_acct_id='||l_wlmti_scrap_acct_id);
        fnd_file.put_line(fnd_file.log, '');
    end if;

    IF (l_entity_type <> 5) THEN
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_NOT_WSM_LOT_JOB');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wsm_lot_move_txn_interface');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;

l_stmt_num := 70;
    IF (l_wlmti_primary_item_id = -1) THEN
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'primary_item_id');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    primary_item_id = l_primary_item_id,
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 75;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    ELSIF (l_wlmti_primary_item_id <> l_primary_item_id) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'primary_item_id');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    IF (l_wlmti_org_code IS NULL) THEN
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'organization_code');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    organization_code = g_prev_org_code, --l_org_code,
            --***VJ Changed for Performance Upgrade***--
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;
l_stmt_num := 80;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);

    ELSIF (l_wlmti_org_code <> g_prev_org_code) THEN  --***VJ Changed for Performance Upgrade***--
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_ORG_ID-CODE_COMB_INVALID');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'B4 IF (l_wlmti_last_upd_name IS NULL) '||
            ';l_wlmti_last_upd_by '||
            l_wlmti_last_upd_by||
            ';g_prev_upd_user_id '||
            g_prev_upd_user_id,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
          );
    END IF;

    --mes added following if condition
    IF (nvl(l_source_code, 'interface') NOT IN ('move in oa page', 'move out oa page', 'jump oa page',
            'move to next op oa page', 'undo oa page'))
    THEN
        l_stmt_num := 85;
        --***VJ Added for Performance Upgrade***--
        IF (l_wlmti_last_upd_by <> -1) OR (l_wlmti_last_upd_by <> g_prev_upd_user_id) THEN
        BEGIN
                select user_name
                into   l_user_name
                from   fnd_user
                where  user_id = l_wlmti_last_upd_by
                and    sysdate between START_DATE and NVL(END_DATE,SYSDATE+1);
                    --***VJ Added for Performance Upgrade***--
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'last_updated_by');
                    x_err_buf := FND_MESSAGE.GET;

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                    return(x_return_code);
        END;

    l_stmt_num := 90;
            g_prev_upd_user_id := l_wlmti_last_upd_by;
            g_prev_upd_user_name := l_user_name;
        --***VJ End Additions***--

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'B4 IF (l_wlmti_last_upd_name IS NULL) '||
                ';l_wlmti_last_upd_name '||
                l_wlmti_last_upd_name||
                ';g_prev_upd_user_name '||
                g_prev_upd_user_name,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;
            IF (l_wlmti_last_upd_name IS NULL) THEN
                FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'last_updated_by_name');
                x_err_buf := FND_MESSAGE.GET;
                l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                update wsm_lot_move_txn_interface
                set    last_updated_by_name = g_prev_upd_user_name, --l_user_name,
            --***VJ Changed for Performance Upgrade***--
                       --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                where  header_id = p_header_id;

    l_stmt_num := 95;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            ELSIF (l_wlmti_last_upd_name <> g_prev_upd_user_name) THEN
            --***VJ Changed for Performance Upgrade***--
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'last_updated_by_name');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
            END IF;
        END IF;

    l_stmt_num := 100;
        --***VJ Added for Performance Upgrade***--
        IF (l_wlmti_created_by <> -1) OR (l_wlmti_created_by <> g_prev_cr_user_id) THEN
            IF (l_wlmti_last_upd_by <> l_wlmti_created_by) THEN
                BEGIN
                    select user_name
                    into   l_user_name
                    from   fnd_user
                    where  user_id = l_wlmti_created_by
                    and    sysdate BETWEEN START_DATE and NVL(END_DATE,SYSDATE+1);
                    --***VJ Added for Performance Upgrade***--
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'created_by');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                                        ||l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                END;
        END IF;

            g_prev_cr_user_id := l_wlmti_created_by;
            g_prev_cr_user_name := l_user_name;
        --***VJ End Additions***--

    l_stmt_num := 105;

            IF (l_wlmti_created_by_name IS NULL) THEN
                FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'created_by_name');
                x_err_buf := FND_MESSAGE.GET;
                l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                update wsm_lot_move_txn_interface
                set    created_by_name = g_prev_cr_user_name, --l_user_name,
                    --***VJ Changed for Performance Upgrade***--
                       --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                where  header_id = p_header_id;

    l_stmt_num := 110;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            ELSIF (l_wlmti_created_by_name <> g_prev_cr_user_name) THEN
                    --***VJ Changed for Performance Upgrade***--
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'created_by_name');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
            END IF;
        END IF;
    END IF; --IF (l_source_code NOT IN ('move in oa page',
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'g_prev_org_id='||g_prev_org_id||
                                        ', g_prev_org_code='||g_prev_org_code||
                                        ', g_prev_cr_user_id='||g_prev_cr_user_id||
                                        ', g_prev_cr_user_name='||g_prev_cr_user_name||
                                        ', g_prev_upd_user_id='||g_prev_upd_user_id||
                                        ', g_prev_upd_user_name='||g_prev_upd_user_name||
--** VJ: Deleted for removal of 9999**  ', g_prev_last_op='||g_prev_last_op||
                                        ', g_prev_op_seq_incr='||g_prev_op_seq_incr||
                                        ', g_acct_period_id='||g_acct_period_id||
                                        ', g_prev_txn_date='||g_prev_txn_date);
        fnd_file.put_line(fnd_file.log, '');
    end if;


    -- Validate acct_period_id
l_stmt_num := 115;
--bug 3126650 changed the if condition and commented out the sql inside. Inv API has been called
--before to get the acct_period_id into g_acct_period_id
    IF (l_wlmti_acct_period_id <> -1) AND (l_wlmti_acct_period_id <> 0) AND
    (l_wlmti_acct_period_id <> g_acct_period_id) THEN
    --***VJ Changed for Performance Upgrade***--
/***        BEGIN
        SELECT acct_period_id
        INTO   l_temp
        FROM   org_acct_periods
        WHERE  acct_period_id = l_wlmti_acct_period_id
        -- begin bugfix 1631484: check if the acct period is open.
            AND    open_flag = 'Y'
            AND    organization_id = p_org_id
            AND    period_start_date <= p_txn_date;
        -- end bugfix 1631484

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
***/
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'acct_period_id');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
--    END;
    --***VJ End Changes***--
    END IF;

l_stmt_num := 120;

    -- Begin Fix for bug #1497882
    IF( l_reason_id <> -1) THEN
    BEGIN
            SELECT reason_name
            INTO   l_mtr_reason_name
        FROM   mtl_transaction_reasons
        where  reason_id = l_reason_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'reason_id');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
    END;
    END IF;

l_stmt_num := 125;

    -- Validate/Populate reason_name
    --***VJ Added for Performance Upgrade***--
    IF (l_reason_name IS NULL) THEN

        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'reason_name');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    reason_name = l_mtr_reason_name,
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 130;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    --***VJ End Additions***--
    ELSIF (l_reason_name <> l_mtr_reason_name) THEN
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'reason_name');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    reason_name = l_mtr_reason_name,
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 135;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    END IF;
    -- END Fix for bug #1497882


l_stmt_num := 140;

--bug 3453139 removed CHECK_WMTI, CHECK_WSMT
/*    l_res_rows := WSMPUTIL.CHECK_WMTI (l_wip_entity_id,
                                       NVL(p_wip_entity_name, l_wip_entity_name_temp), -- Fix for bug #2095035
                                       p_txn_date,
                                       x_return_code,
                                       x_err_buf,
                                       p_org_id); -- ADD: CZH
    IF ( (l_res_rows > 0) OR (x_return_code <> 0) ) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_PENDING_TXN');
        FND_MESSAGE.SET_TOKEN('TABLE', 'wip_move_txn_interface');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

l_stmt_num := 145;

    l_res_rows := WSMPUTIL.CHECK_WSMT (l_wip_entity_id,
                                       NVL(p_wip_entity_name, l_wip_entity_name_temp), -- Fix for bug #2095035
                                       p_txn_id,
                                       p_txn_date,
                                       x_return_code,
                                       x_err_buf,
                                       p_org_id); -- ADD: CZH

    IF ( (l_res_rows > 0) OR (x_return_code <> 0) ) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_PENDING_TXN');
        FND_MESSAGE.SET_TOKEN('TABLE', 'wsm_split_merge_transactions');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

    return(x_return_code);
    END IF;

*/
    --***VJ End Changes***--

l_stmt_num := 150;

    --**VJ: Start Deletion for 9999 Removal **--
    --IF(p_fm_intraop_step_type = 3 AND p_fm_op_seq_num = g_prev_last_op) THEN
                --***VJ Changed for Performance Upgrade***--
    --    x_return_code := 1;

    --    FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_MOVE_FM_LAST_OP');
    --    x_err_buf := FND_MESSAGE.GET;

    --    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    --    return(x_return_code);
    --END IF;
    --**VJ: End Deletion for 9999 Removal **--

l_stmt_num := 151;
    --***VJ Added for Performance Upgrade***--
    IF (p_jump_flag IS NOT NULL) AND (p_jump_flag <> 'Y') AND (p_jump_flag <> 'N') THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'jump_flag');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;
    --***VJ End Additions***--

l_stmt_num := 153;
    -- bugfix 1765389
    -- Validation of p_primary_uom.
    -- If p_primary_uom in WLMTI is null, then populate it from mtl_system_items.
    -- ST : Serial Support Project ---
    -- Query up the serial number control code also in this existing query...
    SELECT msi.primary_uom_code,
           msi.serial_number_control_code
    INTO   l_primary_uom,
           l_serial_ctrl_code
    FROM   mtl_system_items msi,
           wip_discrete_jobs wdj
    WHERE  wdj.wip_entity_id   = l_wip_entity_id
    AND    wdj.primary_item_id = msi.inventory_item_id
    AND    msi.organization_id = wdj.organization_id;

    x_serial_ctrl_code := l_serial_ctrl_code;
    -- ST : Serial Support Project ---
l_stmt_num := 155;

    IF (p_primary_uom IS NULL) THEN
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'p_primary_uom');
        x_err_buf := FND_MESSAGE.GET;
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
    set    primary_uom = l_primary_uom,
               --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
               error = l_error_msg                                    -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 160;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    ELSE
         IF (p_primary_uom <> l_primary_uom) THEN
             x_return_code := 1;

             FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_PRI_UOM');
             FND_MESSAGE.SET_TOKEN('FLD_NAME', 'primary_uom');
             x_err_buf := FND_MESSAGE.GET;

             fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
             return(x_return_code);
     END IF;
    END IF;
    -- end fix for bug1765389

    -- begin bugfix 1840372
    --  Check Shop Floor Status for this job.
    --  Do not allow move transaction if a shop floor status of "allow no move"
    --  is assigned to this wip entity at a particular operation.

    l_stmt_num := 162;
    declare
        l_dummy   number := 0;
        l_err_buf varchar2(2000);       -- to display the complete error in the log file.
    begin
        select max(1)
        into   l_dummy
        from   wip_shop_floor_statuses ws,
               wip_shop_floor_status_codes wsc
        where  wsc.organization_id = p_org_id
        and    ws.organization_id = p_org_id
        and    ws.wip_entity_id = l_wip_entity_id
        and    ws.line_id is null
        and    ws.operation_seq_num = p_fm_op_seq_num
        and    ws.intraoperation_step_type = p_fm_intraop_step_type
        and    ws.shop_floor_status_code = wsc.shop_floor_status_code
        and    wsc.status_move_flag = 2
        and    nvl(wsc.disable_date, sysdate + 1) > sysdate;

        if l_dummy = 1 then
            x_return_code := 1;
            fnd_message.set_name(
                    application => 'WIP',
                    name        => 'WIP_STATUS_NO_TXN1');
            l_err_buf := fnd_message.get;
            x_err_buf := substrb(l_err_buf,1,150);

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):');
            fnd_file.put_line(fnd_file.log, 'ERROR :' ||l_err_buf);
            return(x_return_code);
        end if;
    end;

    --  Check for no move statuses in between operations.
    --  If the WIP parameter "Allow Moves Over No Move Shop Floor Statuses"
    --  is on (checked)..
    --     only moves from intraoperation steps that have 'no move' statuses are prohibited.
    --     If the parameter is not checked
    --  is off (not checked)..
    --     system checks all autocharge operations and TO MOVE, RUN, QUEUE intraoperation steps
    --     between the From and To operations and intraoperation steps for 'no move' statuses.
    --     The system also checks the statuses of intervening intraoperation steps at the
    --     From and To operations if those operations are direct charge. If a staus that can
    --     prevent moves is found, the move is disallowed. Direct charge operations between the
    --     From and To operations and statuses at Scrap and Reject intraoperation steps do not
    --     prevent  moves.

    l_stmt_num := 164;
    declare
        l_err_buf                       varchar2(2000); -- to display the complete error in the log file.
        l_override_no_move_no_skip      number;
    begin
        select  moves_over_no_move_statuses
        into    l_override_no_move_no_skip
        from    wip_parameters
        where   organization_id = p_org_id;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'Check for no move statuses'||
                ';p_fm_op_seq_num '||
                p_fm_op_seq_num||
                ';p_fm_intraop_step_type '||
                p_fm_intraop_step_type||
                ';p_to_op_seq_num '||
                p_to_op_seq_num||
                ';p_to_intraop_step_type '||
                p_to_intraop_step_type||
                ';l_override_no_move_no_skip '||
                l_override_no_move_no_skip
                ,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
              WSM_log_PVT.logMessage (
                  p_module_name     => l_module,
                  p_msg_text          => 'Value returned by WIP_SF_STATUS.COUNT_NO_MOVE_STATUSES '||
                  WIP_SF_STATUS.COUNT_NO_MOVE_STATUSES(
                        p_org_id,               /* organization_id */
                        l_wip_entity_id,        /* wip_entity_id */
                        null,                   /* line_id */                 -- for discrete/LBJ, this should be null
                        null,                   /* first_schedule_id */ -- for discrete/LBJ, this should be null
                        p_fm_op_seq_num,        /* fm_operation_seq_num */
                        p_fm_intraop_step_type, /* fm_intraoperation_step_type */
                        p_to_op_seq_num,        /* to_operation_seq_num */
                        p_to_intraop_step_type  /* to_intraoperation_step_type */
                ),
                  p_stmt_num          => l_stmt_num,
                  p_msg_tokens        => l_msg_tokens,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                  p_run_log_level     => l_log_level
              );

        END IF;

        if (p_fm_op_seq_num is NOT NULL        and
            p_fm_intraop_step_type is NOT NULL and
            p_to_op_seq_num is NOT NULL        and
            p_to_intraop_step_type is NOT NULL and
            l_override_no_move_no_skip = 2   and        /* No */
            WIP_SF_STATUS.COUNT_NO_MOVE_STATUSES(
                  p_org_id,               /* organization_id */
                  l_wip_entity_id,        /* wip_entity_id */
                  null,                   /* line_id */                 -- for discrete/LBJ, this should be null
                  null,                   /* first_schedule_id */ -- for discrete/LBJ, this should be null
                  p_fm_op_seq_num,        /* fm_operation_seq_num */
                  p_fm_intraop_step_type, /* fm_intraoperation_step_type */
                  p_to_op_seq_num,        /* to_operation_seq_num */
                  p_to_intraop_step_type  /* to_intraoperation_step_type */
                ) > 0)
        then
            x_return_code := 1;
            fnd_message.set_name(
                application => 'WIP',
                name        => 'WIP_NO_MOVE_SF_STATUS_BETWEEN');
            l_err_buf := fnd_message.get;
            x_err_buf := substrb(l_err_buf,1,150);

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):');
            fnd_file.put_line(fnd_file.log, 'ERROR :' ||l_err_buf);
            return(x_return_code);
        end if;
    end;
    -- end bugfix 1840372

-------------------------------------------------------------------------------------
---------------------------------MOVE AND COMPLETION---------------------------------
-------------------------------------------------------------------------------------

IF (l_txn_type IN (1,2)) THEN    -- only for forward moves and completions
    --***VJ Changed for Performance Upgrade***--

l_stmt_num := 165;

    -- Allow forward moves in the open interface, Returns are not allowed
    IF ( (l_txn_type = 2) AND   -- Move and Completion
         (p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) ) THEN
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_TXN_FOR_SCR');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;

    --***VJ Changed for Performance Upgrade***--
    BEGIN
        select max(OPERATION_SEQ_NUM)
        into   l_max_qty_op_seq_num
        from   wip_operations
        where  organization_id = p_org_id
        and    wip_entity_id = l_wip_entity_id
        and    ((QUANTITY_IN_QUEUE > 0) or
                (QUANTITY_RUNNING > 0) or
                (QUANTITY_WAITING_TO_MOVE > 0) or
                (QUANTITY_SCRAPPED > 0));

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_code := 1;

            -- CZH: this should be an invalid LBJ
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'from_operation_seq_num/code/intraoperation_step');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

            return(x_return_code);
    END;
    --***VJ End Changes***--

l_stmt_num := 170;

    -- Find out at which operation/intra-op step the quantity lies in WIP_OPERATIONS table
    --bug 3370199 added wsm_op_seq_num
    select operation_seq_num,
           operation_sequence_id,
           standard_operation_id,
           department_id,
           decode(sign(QUANTITY_IN_QUEUE),1,QUANTITY_IN_QUEUE,0),
           decode(sign(QUANTITY_RUNNING),1,QUANTITY_RUNNING,0),
           decode(sign(QUANTITY_WAITING_TO_MOVE),1,QUANTITY_WAITING_TO_MOVE,0),
           decode(sign(QUANTITY_SCRAPPED),1,QUANTITY_SCRAPPED,0),
           nvl(wsm_op_seq_num, -1)
    into   l_wo_op_seq_num,
           l_wo_op_seq_id,
           l_wo_std_op_id,
           l_wo_dept_id,
           l_wo_qty_in_queue,
           l_wo_qty_in_running,
           l_wo_qty_in_tomove,
           l_wo_qty_in_scrap,
           l_wo_rtg_op_seq_num
    from   wip_operations
    where  organization_id = p_org_id
    and    wip_entity_id = l_wip_entity_id
    and    OPERATION_SEQ_NUM = l_max_qty_op_seq_num; --***VJ Changed for Performance Upgrade***--


    IF (l_wo_std_op_id IS NOT NULL) THEN
         SELECT operation_code
         INTO   l_wo_op_code
         FROM   bom_standard_operations
         WHERE  standard_operation_id = l_wo_std_op_id;
    ELSE
         l_wo_op_code := NULL;
    END IF;

l_stmt_num := 175;

    if(l_wo_qty_in_queue <> 0) then
         l_wo_qty_iop_step := 1;
         l_wo_qty := l_wo_qty_in_queue;
    elsif(l_wo_qty_in_running <> 0) then
         l_wo_qty_iop_step := 2;
         l_wo_qty := l_wo_qty_in_running;
    elsif(l_wo_qty_in_tomove <> 0) then
         l_wo_qty_iop_step := 3;
         l_wo_qty := l_wo_qty_in_tomove;
    elsif(l_wo_qty_in_scrap <> 0) then
         --This will be executed only if the entire qty is scrapped.
         --A future scrap is not allowed, and if there is a scrap in the current op
         --then the remaining qty would exist in either Q/R/TM.
         l_wo_qty_iop_step := 5;
         l_wo_qty := l_wo_qty_in_scrap;
    end if;

    -- ST : Serial Support Project --
    -- l_wo_qty is the quantity available.. set it to the OUT parameter...
    -- l_wo_qty_iop_step is the current intraop step .. add to the OUT parameter..
    -- l_wo_op_seq_num is the current job op seq num
    -- l_wo_rtg_op_seq_num is the current rtg op seq num
    x_available_qty             := l_wo_qty     ;
    x_current_job_op_seq_num    := l_wo_op_seq_num      ;
    x_current_intraop_step      := l_wo_qty_iop_step    ;
    x_current_rtg_op_seq_num    := l_wo_rtg_op_seq_num  ;
    -- ST : Serial Support Project --

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'p_fm_op_seq_num='||p_fm_op_seq_num||'l_wo_op_seq_num='||l_wo_op_seq_num);
    end if;

    -- p_fm_op_seq_num must be l_wo_op_seq_num
    IF (p_fm_op_seq_num <> l_wo_op_seq_num) THEN
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_op_seq_num');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;

    l_stmt_num := 176;

    -- Check if p_fm_op_code is l_wo_op_code --NSO Modification by abedajna
    --IF (p_fm_op_code <> l_wo_op_code) THEN --because p_fm_op_code can be NULL now that we are allowing NSO

    -- begin 2363380 : Modified the cryptic logic and made it more readable.
    -- (for old code, checkout the previous version)
    -- Logic here is that If p_fm_op_code (populated in interface table)
    -- is not equal to l_wo_op_code (that in wip_operations table, we need
    -- to error out. If they have left it blank, populate it.
    if (p_fm_op_code is null and l_wo_op_code is null) then
        null; -- do nothing

    elsif (p_fm_op_code is not null and l_wo_op_code is null) then
        x_return_code := 1;
            fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
            fnd_message.set_token('FLD_NAME', 'fm_op_code');
            x_err_buf := fnd_message.get;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    elsif (p_fm_op_code is null and l_wo_op_code is not null) then
        UPDATE wsm_lot_move_txn_interface
        SET    fm_operation_code = l_wo_op_code
        WHERE  header_id = p_header_id;

            fnd_message.set_name('WSM', 'WSM_MODIFIED_FIELD');
            fnd_message.set_token('FLD_NAME', 'fm_operation_code');
            x_err_buf := fnd_message.get;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);

            -- henceforth, if p_fm_op_code is NULL, use l_fm_op_code_temp instead.
            l_fm_op_code_temp := l_wo_op_code;

    elsif ((p_fm_op_code is not null and l_wo_op_code is not null) and (p_fm_op_code <> l_wo_op_code) ) then
        x_return_code := 1;
            fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
            fnd_message.set_token('FLD_NAME', 'fm_op_code');
            x_err_buf := fnd_message.get;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    end if;
    -- end bugfix 2363380

    -- Check if p_fm_intraop_step_type is l_wo_qty_iop_step
    IF (p_fm_intraop_step_type <> l_wo_qty_iop_step) THEN
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_intraop_step_type');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;

    -- p_fm_intraop_step_type should not be Scrap
    IF ( (p_fm_intraop_step_type = WIP_CONSTANTS.SCRAP) AND
         (l_txn_type <> 4) )  THEN      -- Added condition as a part of fix for bug #2083671
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_MOVE_FM_SCRAP');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;


    -- to take care of intra-op move for an operation which is outside routing..
    -- NSO Modification by abedajna
    -- CZH: if l_iop_move_out_rtg = TURE, we are corrently in outside rtg, and want to move to the same op
    --bugfix 2969238 added condition for move after update WLT case. op_seq_id is not null and was from original routing
    --so should be treated as outside routing.

    IF ( (nvl(p_to_op_seq_num, -1) = -1) AND
         (l_wo_op_code = p_to_op_code) AND
         ((p_jump_flag = 'N') OR  (p_jump_flag is NULL))) THEN
    --AND (l_wo_op_seq_id is null ) )

         if (l_wo_op_seq_id is null ) then
            l_iop_move_out_rtg := TRUE;

          else
            begin
               select  1
                 into  l_temp
                 from  bom_operation_sequences
                 where operation_sequence_id = l_wo_op_seq_id
                 and   routing_sequence_id = l_routing_seq_id;

            exception
               when NO_DATA_FOUND then
                  l_iop_move_out_rtg := TRUE;
                  -- assign this as null, since validation for outside routing below all assume op_seq_id is null.
                  -- otherwise might get validation error.
                  l_wo_op_seq_id := '';

               when others then
                  l_iop_move_out_rtg := FALSE;
            end;
         end if;
         --end fix 2969238

    ELSE
       l_iop_move_out_rtg := FALSE;
    END IF;

/************************************************************************************************************************
MOVE ENH g_aps_wps_profile='N'
***********************************************************************************************************************
************************************************************************************************************************/
IF (g_aps_wps_profile='N') THEN

l_stmt_num := 180;
    UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET    (FM_DEPARTMENT_ID,
            FM_DEPARTMENT_CODE) =
           (SELECT bd.department_id,
                   bd.department_code
            FROM   BOM_DEPARTMENTS bd
            WHERE  bd.department_id = l_wo_dept_id)
    WHERE  WLMTI.header_id = p_header_id;

    IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wo_dept_id');  --bugfix 1587295: changed the token
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    ELSE
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_department_id/fm_department_code');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    END IF;

    l_stmt_num := 185;
    SELECT nvl(common_routing_sequence_id, routing_reference_id)
    INTO   l_routing_seq_id
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id = l_wip_entity_id;

l_stmt_num := 190;
    l_op_seq_id := NULL;

l_stmt_num := 195;
    WSMPUTIL.find_routing_end(l_routing_seq_id,
                              l_rtg_revision_date, -- Add: CZH.I_OED-1, use rtg rev date
                              l_end_op_seq_id,
                              x_return_code,
                              x_err_buf);
    IF (x_return_code <> 0) THEN
        FND_MESSAGE.SET_NAME('WSM', 'WSM_CANNOT_GET_RTG_END');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    ELSE
    if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                                          ||'): Returned success from WSMPUTIL.find_routing_end');
    end if;
    END IF;

    -- BA: CZH.I_OED-2, should consider operation replacement, will never get NULL since x_return_code = 0
    l_end_op_seq_id := WSMPUTIL.replacement_op_seq_id(
                                       l_end_op_seq_id,
                                       l_rtg_revision_date);
    --NO CHECK FOR RETURN VALUES HERE....-VJ--
    -- EA: CZH.I_OED-2

----------------------------------
-- MOVE (NOT JUMP) TRANSACTIONS --
----------------------------------

    IF (upper(nvl(p_jump_flag, 'N')) = 'N') THEN -- If Jump Flag is not set

        -- NSO Modification by abedajna
l_stmt_num := 200;

        -- must specify p_to_op_seq_num if outside_routing is FALSE
    IF ( ( l_iop_move_out_rtg = FALSE ) AND (nvl(p_to_op_seq_num, -1) = -1) ) THEN
            -- CZH: l_iop_move_out_rtg = FALSE means this is NOT an intraop move @ an op outside routing.
            -- AND this is not a JUMP, hence, p_to_op_seq_num must be specified

            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NULL_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'p_to_op_seq_num');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);

        END IF;

-- *** (NSO Modification by abedajna) -- begin addition
        if ( l_iop_move_out_rtg = FALSE ) then

            -- BA: CZH.I_OED-1, give warning message if there is no effective next operation
l_stmt_num := 202;

            IF(WSMPUTIL.effective_next_op_exists(
                        p_organization_id => p_org_id,
                        p_wip_entity_id   => l_wip_entity_id,
                        p_wo_op_seq_num   => p_fm_op_seq_num,
                        p_end_op_seq_id   => l_end_op_seq_id,   -- CZH.I_9999
                        x_err_code        => x_return_code,
                        x_err_msg         => x_err_buf) = 0)
            THEN
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_EFFECTIVE_NEXT_OP');
                x_err_buf := FND_MESSAGE.GET;
                l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            END IF;
            -- EA: CZH.I_OED-1

        --NO CHECK FOR RETURN VALUES HERE....-VJ--

            -- CZH: Not intraop move @ outside routing, hence, p_to_op_seq_num is rtg op seq num
            --***VJ Changed for Performance Upgrade***--
            BEGIN
                SELECT operation_sequence_id,
                       department_id,
                       standard_operation_id
                INTO   l_op_seq_id, -- CZH.I_OED-2: since select from BOS, replacement is already considered!
                       l_dept_id,
                   l_std_op_id
                FROM   bom_operation_sequences
                WHERE  operation_seq_num   = p_to_op_seq_num
                AND    routing_sequence_id = l_routing_seq_id
                -- BC: CZH.I_OED-1, use wdj.routing_revision_date instead of SYSDATE
                --and  nvl(disable_date, sysdate+1) > sysdate
                --and  nvl(effectivity_date, sysdate) <= sysdate;
                and    nvl(disable_date,     l_rtg_revision_date) >= l_rtg_revision_date
                and    nvl(effectivity_date, l_rtg_revision_date) <= l_rtg_revision_date;
                -- EC: CZH.I_OED-1

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
            END;
            --***VJ End Changes***--

--bug 3463128 give a message if the current operation has been replaced and the user is trying a
--intraop move
            IF ((l_wo_rtg_op_seq_num = p_to_op_seq_num) AND (l_wo_op_seq_id <> l_op_seq_id)) THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_MOVE_CURR_OP_REPLACED');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
            END IF;
--end bug 3463128

        if (l_std_op_id is NOT NULL) then  -- it is a std op
l_stmt_num := 205;
                SELECT operation_code
                INTO   l_op_code
                FROM   bom_standard_operations
                WHERE  NVL(operation_type, 1) = 1  -- Standard operation
                AND    organization_id = p_org_id
                AND    standard_operation_id = l_std_op_id;
        else -- it is a non-std op
l_stmt_num := 210;
            l_op_code := '';
        end if;

        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'p_to_op_code='||p_to_op_code||'l_op_code='||l_op_code);
        end if;

        if (p_to_op_code is NULL) AND (l_op_code is not NULL) then
l_stmt_num := 215;
        update wsm_lot_move_txn_interface
        set    to_operation_code = l_op_code
        where  header_id = p_header_id;
        elsif nvl(l_op_code, '@@**') <> nvl(p_to_op_code, '@@**') then
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        end if;

        else  -- l_iop_move_out_rtg = TURE, intraop move @ outside rtg

        l_op_seq_id := NULL;           -- CZH: !!!!
        l_to_op_seq_num := NULL;       -- CZH: !!!!

        if (p_to_op_code is null) then
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        else
                -- BA: CZH.bug 2362225, because we use l_op_code later on
                l_op_code := p_to_op_code;
                -- EA: CZH.bug 2362225
l_stmt_num := 220;
            begin
                select standard_operation_id,
                           department_id
                into   l_std_op_id,
                           l_dept_id
                from   bom_standard_operations
                where  nvl(operation_type, 1) = 1
                and    organization_id = p_org_id
                and    operation_code = p_to_op_code;
            exception
                when no_data_found then
                        x_return_code := 1;
                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                        x_err_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                          ||l_stmt_num||'): ' ||x_err_buf);
                    return(x_return_code);
                end;
        end if;

        end if;  -- l_iop_move_out_rtg is TRUE

-- *** (NSO Modification by abedajna) -- end addition

l_stmt_num := 225;
        IF ( nvl(p_to_dept_id, -1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_dept_id) THEN -- Fix bug #1501376
        -- Bugfix 1587295: added nvl since p_to_dept_id could be null. If null, derive it.
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

        UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
        SET     ( TO_DEPARTMENT_ID,                     -- Fix bug #1501376
                  TO_DEPARTMENT_CODE )=
                (SELECT bd.department_id,       -- Fix bug #1501376
                    bd.department_code
                 FROM   BOM_DEPARTMENTS bd
                 WHERE  bd.department_id = l_dept_id)   -- Fix bug #1501376
        WHERE   WLMTI.header_id = p_header_id;

        IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
            -- x_return_code := SQLCODE;
            x_return_code := 1; -- Bugfix 1587295: we should return 1 instead of SQLCODE since
                                -- even if the above update updates 0 records, sqlcode will be 0.

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        ELSE
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_department_id/to_department_code');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        END IF;


l_stmt_num := 230;
    -- Fix bug #1501376
        l_to_dept_id := l_dept_id; -- l_to_dept_id is a local variable for p_to_dept_id, if NULL


-- NSO Modification by abedajna begin

        if l_op_seq_id <> l_wo_op_seq_id then  -- CZH: move from inside rtg to inside rtg, to a diff op
l_stmt_num := 235;
        l_temp := 0;

            -- Here we are just checking that a intra-routing move is really possible
            -- from the operation user specifies to the operation inside the routing
            -- he specifies. This means that the from and the to ops should be a record
            -- in BON. The following sql thus suffices. The view is more suitable for the form.

        begin
                --BC: CZH.I_OED-1, this sql doesn't suffice because the operation can be disabled
            --select 1
            --into   l_temp
            --from   bom_operation_networks
            --where  from_op_seq_id = l_wo_op_seq_id
            --and    to_op_seq_id = l_op_seq_id
                --and    nvl(disable_date,     sysdate) >= sysdate
                --and    nvl(effectivity_date, sysdate) <= sysdate;

                -- BC: CZH.I_OED-2, should consider op replacement
            --select 1
            --into   l_temp
            --from   bom_operation_networks  bon,
                --       bom_operation_sequences bos
            --where  bon.from_op_seq_id        = l_wo_op_seq_id
            --and    bon.to_op_seq_id          = l_op_seq_id
            --and    bos.operation_sequence_id = l_op_seq_id
                --and    nvl(bos.disable_date,     l_rtg_revision_date) >= l_rtg_revision_date
                --and    nvl(bos.effectivity_date, l_rtg_revision_date) <= l_rtg_revision_date
                --and    nvl(bon.disable_date,     l_rtg_revision_date) >= l_rtg_revision_date  -- not used
                --and    nvl(bon.effectivity_date, l_rtg_revision_date) <= l_rtg_revision_date; -- not used

            select 1
            into   l_temp
            from   bom_operation_networks
            --where  WSMPUTIL.replacement_op_seq_id (
                --                from_op_seq_id,
                --                l_rtg_revision_date) = l_wo_op_seq_id
                where  from_op_seq_id IN (
                           select bos.operation_sequence_id
                           from   bom_operation_sequences bos,
                                  bom_operation_sequences bos2
                           where  bos.operation_seq_num      = bos2.operation_seq_num
                           AND    bos.routing_sequence_id    = bos2.routing_sequence_id
                           AND    bos2.operation_sequence_id = l_wo_op_seq_id
                       )
            and    WSMPUTIL.replacement_op_seq_id (
                                to_op_seq_id,
                                l_rtg_revision_date) = l_op_seq_id;
                -- EC: CZH.I_OED-2
                -- EC: CZH.I_OED-1
        exception
            when others then
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num/to_op_code');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                                    ||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        end;
        elsif l_op_seq_id = l_wo_op_seq_id then  -- CZH: move from inside rtg to inside rtg, to the same op

l_stmt_num := 240;
            if p_to_intraop_step_type <= l_wo_qty_iop_step then
                x_return_code := -1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_intraop_step_type');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        end if;

        end if;

-- NSO Modification by abedajna end


--------------------
-- JUMP OPERATION --
--------------------

    ELSE -- A Jump Operation

l_stmt_num := 245;
        IF ( nvl(p_to_op_seq_num, -1) <> -1) THEN  -- JUMP to inside routing

        --***VJ Changed for Performance Upgrade***--
        BEGIN
            SELECT nvl(standard_operation_id, -1),
                       nvl(department_id, -1),
               operation_sequence_id
            INTO   l_jmp_std_op_id,
                   l_jmp_dept_id,
               l_jmp_op_seq_id
                FROM   bom_operation_sequences
                WHERE  operation_seq_num = p_to_op_seq_num
                AND    routing_sequence_id = l_routing_seq_id
                -- BC: CZH.I_OED-1, use wdj.routing_revision_date instead of SYSDATE
                --and  nvl(disable_date,     sysdate+1) >=  sysdate
                --and  nvl(effectivity_date, sysdate)   <= sysdate;
                and    nvl(disable_date,     l_rtg_revision_date) >= l_rtg_revision_date
                and    nvl(effectivity_date, l_rtg_revision_date) <= l_rtg_revision_date;
                -- EC: CZH.I_OED-1

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_return_code := 1;
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);

        WHEN TOO_MANY_ROWS THEN
                    x_return_code := 1;
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);

        END;
            --***VJ End Changes***--

l_stmt_num := 250;

        IF (l_jmp_std_op_id <> -1) THEN -- a standard op

            -- Get corresponding op_code from BOS/BSO
                SELECT operation_code
                INTO   l_jmp_op_code
                FROM   bom_standard_operations
                WHERE  standard_operation_id = l_jmp_std_op_id
                AND    organization_id = p_org_id;

l_stmt_num := 255;
        ELSE
            l_jmp_op_code := '';
        END IF;

          l_std_op_id := l_jmp_std_op_id;
            l_dept_id   := l_jmp_dept_id;
            l_op_code   := l_jmp_op_code;
            l_op_seq_id := l_jmp_op_seq_id;

-- NSO Modification by abedajna: additions begin
        if (p_to_op_code is NULL) AND (l_jmp_op_code is not NULL) then

                update wsm_lot_move_txn_interface
                set    to_operation_code = l_jmp_op_code
                where  header_id = p_header_id;

l_stmt_num := 260;
        elsif (p_to_op_code <> nvl(l_jmp_op_code, '@@**')) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                    x_err_buf := FND_MESSAGE.GET;

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
            end if;
-- NSO Modification by abedajna: additions end

            IF ( nvl(p_to_dept_id, -1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_jmp_dept_id) THEN
                x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                return(x_return_code);
        END IF;

    ELSE -- p_to_op_seq_num is NULL, i.e. jump to outside routing

        IF (p_to_op_code IS NOT NULL) THEN -- Jumping to a std-op

l_stmt_num := 270;
        --***VJ Changed for Performance Upgrade***--
        BEGIN
                    SELECT nvl(standard_operation_id, -1),
                           nvl(department_id, -1)
                    INTO   l_jmp_std_op_id,
                           l_jmp_dept_id
                    FROM   bom_standard_operations
                    WHERE  operation_code = p_to_op_code
                    AND    organization_id = p_org_id;

        EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                          ||l_stmt_num||'):'||x_err_buf);
                        return(x_return_code);
        END;
        --***VJ End Changes***--

l_stmt_num := 275;
        l_std_op_id := l_jmp_std_op_id;
        l_dept_id   := l_jmp_dept_id;
        l_op_code   := p_to_op_code;
        l_op_seq_id := NULL;

        IF (l_jmp_std_op_id = -1) OR (l_jmp_dept_id = -1) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                      ||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
        END IF;


                IF (nvl(p_to_dept_id,-1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_jmp_dept_id) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
                x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
        END IF;

        ELSE -- IF p_to_op_code IS NULL

                --CZH: one cannot jump to a non-std op outside routing !!!!
                --Added to remove non-std-ops functionality.
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
                --End additions

        END IF; -- p_to_op_code IS NULL/NOT NULL

    END IF; -- p_to_op_seq_num is NULL/NOT NULL

        /* JUMP_ENH:
       If the parameter is set not to charge jump_from_queue operations
           and the txn's from intraoperation step is 'Queue' then check to see
           if it qualifies for a jump_from_queue transaction without incurring
           any charges. */
        if (g_param_jump_fm_q = 2 and
            p_fm_intraop_step_type=1) then

        if (l_wo_qty_in_scrap <> 0 ) then
               fnd_message.set_name('WSM', 'WSM_SCRAP_EXISTS');
               x_err_buf := FND_MESSAGE.GET;
               fnd_file.put_line(fnd_file.log, x_err_buf);
               if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log, 'Jump from Queue is set to FALSE');
           end if;
        else
               WSMPLBMI.val_jump_from_queue(l_wip_entity_id,
                               p_org_id,
                               p_fm_op_seq_num,
                               l_wo_op_seq_id,
                               x_return_code,
                               x_err_buf);

               if (x_return_code <> 0) then
                  fnd_file.put_line(fnd_file.log,
                    'After calling WSMPLBMI.val_jump_from_queue ' || x_err_buf);
                  return(x_return_code);
               end if;
               l_jump_from_queue := TRUE;
               if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log,
            'Jump from Queue is set to TRUE');
           end if;
         end if; /* scrap <> 0 */
        end if; /* g_param_jump_fm_q = 2 */

    l_stmt_num := 280;
        UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
        SET    ( TO_DEPARTMENT_ID,      -- Fix bug #1501376
                 TO_DEPARTMENT_CODE )=
               (SELECT bd.department_id,    -- Fix bug #1501376
               bd.department_code
                FROM   BOM_DEPARTMENTS bd
                WHERE  bd.department_id = l_jmp_dept_id)
        WHERE  WLMTI.header_id = p_header_id;

    l_stmt_num := 285;
        IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
            --x_return_code := SQLCODE;
        x_return_code := 1; -- Bugfix 1587295: Set it to 1. Setting to SQLCODE is incorrect
                                -- since it will have a value of 0 in this case.

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        ELSE
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_department_id/to_department_code');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        END IF;

    -- Fix bug #1501376
    l_to_dept_id := l_jmp_dept_id; -- l_to_dept_id is a local variable for p_to_dept_id, if NULL

    END IF; -- Check for Jumps
-----------------------------------------------------------------------------------
-- End of Jump
-----------------------------------------------------------------------------------
/***********************************************************************************************************************
************************************************************************************************************************
MOVE ENH g_aps_wps_profile='Y'
***********************************************************************************************************************
************************************************************************************************************************/
ELSE --(g_aps_wps_profile='Y')

l_stmt_num := 180;

    UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET    (FM_DEPARTMENT_ID,
            FM_DEPARTMENT_CODE) =
           (SELECT WCO.department_id,
                   WCO.department_code
            FROM   WSM_COPY_OPERATIONS WCO
            WHERE  WCO.wip_entity_id = l_wip_entity_id
            AND    WCO.operation_sequence_id = l_op_seq_id)
    WHERE  WLMTI.header_id = p_header_id;

    IF ((SQL%ROWCOUNT > 0) OR (SQL%NOTFOUND)) THEN
    UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET    (FM_DEPARTMENT_ID,
            FM_DEPARTMENT_CODE) =
           (SELECT bd.department_id,
                   bd.department_code
            FROM   BOM_DEPARTMENTS bd
            WHERE  bd.department_id = l_wo_dept_id)
    WHERE  WLMTI.header_id = p_header_id;
        END IF;

    IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wo_dept_id');  --bugfix 1587295: changed the token
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    ELSE
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_department_id/fm_department_code');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    END IF;

    l_stmt_num := 190;
    BEGIN
    SELECT  operation_sequence_id,
        standard_operation_id,
        department_id,
        operation_seq_num,
        standard_operation_code
        INTO    l_end_op_seq_id,
            l_end_std_op_id,
            l_end_dept_id,
            l_end_op_seq_num,
        l_end_op_code
    FROM    WSM_COPY_OPERATIONS WCO
    WHERE   WCO.wip_entity_id=l_wip_entity_id
    AND WCO.network_start_end='E';
    EXCEPTION
        WHEN no_data_found THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_CANNOT_GET_RTG_END');
             x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END;
               if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): l_end_op_seq_id '||l_end_op_seq_id||' l_end_std_op_id '||l_end_std_op_id||' l_end_dept_id '||l_end_dept_id||' l_end_op_seq_num '||l_end_op_seq_num);
           end if;

    l_op_seq_id := NULL;

----------------------------------
-- MOVE (NOT JUMP) TRANSACTIONS --
----------------------------------

    IF (upper(nvl(p_jump_flag, 'N')) = 'N') THEN -- If Jump Flag is not set

        -- NSO Modification by abedajna
l_stmt_num := 200;

        -- must specify p_to_op_seq_num if outside_routing is FALSE
    IF ( ( l_iop_move_out_rtg = FALSE ) AND (nvl(p_to_op_seq_num, -1) = -1) ) THEN
            -- CZH: l_iop_move_out_rtg = FALSE means this is NOT an intraop move @ an op outside routing.
            -- AND this is not a JUMP, hence, p_to_op_seq_num must be specified

            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NULL_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'p_to_op_seq_num');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);

        END IF;

        if ( l_iop_move_out_rtg = FALSE ) then
        BEGIN
        SELECT operation_sequence_id,
            department_id,
            department_code,
            standard_operation_id,
            standard_operation_code,
            nvl(WCO.recommended, 'N'),
            scrap_account,
            backflush_flag
        INTO   l_op_seq_id,
            l_dept_id,
            l_to_dept_code,
            l_std_op_id,
            l_op_code,
            l_recommended,
--bug 3571019 changed l_scrap_acc_id to l_to_scrap_id for clarity
--          l_scrap_acc_id,
            l_to_scrap_id,
            l_to_op_bkflsh_flag
        FROM    WSM_COPY_OPERATIONS WCO
        WHERE   WCO.wip_entity_id=l_wip_entity_id
        AND WCO.operation_seq_num   = p_to_op_seq_num;
        EXCEPTION
        WHEN no_data_found THEN
            x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        END;

--bug 3463128 give a message if the current operation has been replaced and the user is trying a
--intraop move
        IF ((l_wo_rtg_op_seq_num = p_to_op_seq_num) AND (l_wo_op_seq_id <> l_op_seq_id)) THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MOVE_CURR_OP_REPLACED');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;
--end bug 3463128

        if (l_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log, 'p_to_op_code='||p_to_op_code||'l_op_code='||l_op_code);
                end if;

        if (p_to_op_code is NULL) AND (l_op_code is not NULL) then
            l_stmt_num := 215;
                update wsm_lot_move_txn_interface
                set    to_operation_code = l_op_code
                where  header_id = p_header_id;
        elsif nvl(l_op_code, '@@**') <> nvl(p_to_op_code, '@@**') then
                        x_return_code := 1;
                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                        x_err_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
        end if;

        else  -- l_iop_move_out_rtg = TURE, intraop move @ outside rtg

        l_op_seq_id := NULL;           -- CZH: !!!!
        l_to_op_seq_num := NULL;       -- CZH: !!!!

        if (p_to_op_code is null) then
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        else
                -- BA: CZH.bug 2362225, because we use l_op_code later on
                l_op_code := p_to_op_code;
                -- EA: CZH.bug 2362225
l_stmt_num := 220;
            begin
                select standard_operation_id,
                           department_id
                into   l_std_op_id,
                           l_dept_id
                from   bom_standard_operations
                where  nvl(operation_type, 1) = 1
                and    organization_id = p_org_id
                and    operation_code = p_to_op_code;
            exception
                when no_data_found then
                        x_return_code := 1;
                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                        x_err_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                          ||l_stmt_num||'): ' ||x_err_buf);
                    return(x_return_code);
                end;
        end if;

        end if;  -- l_iop_move_out_rtg is TRUE

-- *** (NSO Modification by abedajna) -- end addition

l_stmt_num := 225;
        IF ( nvl(p_to_dept_id, -1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_dept_id) THEN -- Fix bug #1501376
        -- Bugfix 1587295: added nvl since p_to_dept_id could be null. If null, derive it.
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

--move enh
    IF (l_to_dept_code IS NULL) THEN
        UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
        SET     ( TO_DEPARTMENT_ID,                     -- Fix bug #1501376
                  TO_DEPARTMENT_CODE )=
                (SELECT bd.department_id,       -- Fix bug #1501376
                    bd.department_code
                 FROM   BOM_DEPARTMENTS bd
                 WHERE  bd.department_id = l_dept_id)   -- Fix bug #1501376
        WHERE   WLMTI.header_id = p_header_id
        RETURNING   TO_DEPARTMENT_CODE
        INTO        l_to_dept_code;

        IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
            -- x_return_code := SQLCODE;
            x_return_code := 1; -- Bugfix 1587295: we should return 1 instead of SQLCODE since
                                -- even if the above update updates 0 records, sqlcode will be 0.

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        ELSE
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_department_id/to_department_code');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        END IF;
        ELSE --(l_to_dept_code IS NOT NULL)
            UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
            SET     TO_DEPARTMENT_CODE=l_to_dept_code
            WHERE   WLMTI.header_id = p_header_id;
        END IF;


l_stmt_num := 230;
    -- Fix bug #1501376
        l_to_dept_id := l_dept_id; -- l_to_dept_id is a local variable for p_to_dept_id, if NULL

    if l_op_seq_id <> l_wo_op_seq_id then -- CZH: move from inside rtg to i nside rtg, to a diff op
         l_stmt_num := 235;
            l_temp := 0;

--move enh? indices on op seq num
--bug 3370199 introduced the if block after this SQL
            BEGIN
                SELECT  1
                INTO    l_temp
                FROM    WSM_COPY_OP_NETWORKS WCON
                WHERE   WCON.wip_entity_id=l_wip_entity_id
                AND WCON.from_op_seq_id=l_wo_op_seq_id
                AND WCON.to_op_seq_num=p_to_op_seq_num;
            EXCEPTION
                WHEN others THEN
                    l_temp := 0;
            END;

            IF (l_temp = 0) THEN
                    BEGIN
                        SELECT  1
                        INTO    l_temp
                        FROM    WSM_COPY_OP_NETWORKS WCON
                        WHERE   WCON.wip_entity_id=l_wip_entity_id
                        AND     WCON.from_op_seq_num = l_wo_rtg_op_seq_num
                        AND     WCON.to_op_seq_num=p_to_op_seq_num;

                    exception
                        when others then
                            x_return_code := 1;
                            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num/to_op_code');
                            x_err_buf := FND_MESSAGE.GET;
                            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation( stmt_num=' ||l_stmt_num||'): '||x_err_buf);
                            return(x_return_code);
                    end;
            END IF;

        ELSIF l_op_seq_id = l_wo_op_seq_id then  -- CZH: move from inside rtg to inside rtg, to the same op

l_stmt_num := 240;
            if p_to_intraop_step_type <= l_wo_qty_iop_step then
                x_return_code := -1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_intraop_step_type');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
        end if;

        end if;

-- NSO Modification by abedajna end

--------------------
-- JUMP OPERATION --
--------------------

    ELSE -- A Jump Operation

l_stmt_num := 245;
    IF ( nvl(p_to_op_seq_num, -1) <> -1) THEN  -- JUMP to inside routing
        BEGIN
            SELECT  operation_sequence_id,
                    department_id,
                    department_code,
                    standard_operation_id,
                    standard_operation_code,
                    nvl(WCO.recommended, 'N'),
                    scrap_account,
                    backflush_flag
            INTO    l_jmp_op_seq_id,
                    l_jmp_dept_id,
                    l_jmp_to_dept_code,
                    l_jmp_std_op_id,
                    l_jmp_op_code,
                    l_recommended,
--bug 3571019 changed l_scrap_acc_id to l_to_scrap_id for clarity
--                  l_scrap_acc_id,
                    l_to_scrap_id,
                    l_to_op_bkflsh_flag
        FROM    WSM_COPY_OPERATIONS WCO
        WHERE   WCO.wip_entity_id=l_wip_entity_id
        AND WCO.operation_seq_num   = p_to_op_seq_num;
        EXCEPTION
        WHEN no_data_found THEN
                    x_return_code := 1;
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);

                WHEN TOO_MANY_ROWS THEN
                    x_return_code := 1;
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
        END;

          l_std_op_id := l_jmp_std_op_id;
            l_dept_id   := l_jmp_dept_id;
            l_op_code   := l_jmp_op_code;
            l_op_seq_id := l_jmp_op_seq_id;
            l_to_dept_code :=l_jmp_to_dept_code;

-- NSO Modification by abedajna: additions begin
        if (p_to_op_code is NULL) AND (l_jmp_op_code is not NULL) then

                update wsm_lot_move_txn_interface
                set    to_operation_code = l_jmp_op_code
                where  header_id = p_header_id;

l_stmt_num := 260;
        elsif (p_to_op_code <> nvl(l_jmp_op_code, '@@**')) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                    x_err_buf := FND_MESSAGE.GET;

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
            end if;
-- NSO Modification by abedajna: additions end

            IF ( nvl(p_to_dept_id, -1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_jmp_dept_id) THEN
                x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                return(x_return_code);
        END IF;

    ELSE -- p_to_op_seq_num is NULL, i.e. jump to outside routing

        IF (p_to_op_code IS NOT NULL) THEN -- Jumping to a std-op

l_stmt_num := 270;
        --***VJ Changed for Performance Upgrade***--
        BEGIN
                    SELECT nvl(standard_operation_id, -1),
                           nvl(department_id, -1)
                    INTO   l_jmp_std_op_id,
                           l_jmp_dept_id
                    FROM   bom_standard_operations
                    WHERE  operation_code = p_to_op_code
                    AND    organization_id = p_org_id;

        EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                          ||l_stmt_num||'):'||x_err_buf);
                        return(x_return_code);
        END;
        --***VJ End Changes***--

l_stmt_num := 275;
        l_std_op_id := l_jmp_std_op_id;
        l_dept_id   := l_jmp_dept_id;
        l_op_code   := p_to_op_code;
        l_op_seq_id := NULL;

        IF (l_jmp_std_op_id = -1) OR (l_jmp_dept_id = -1) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                      ||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
        END IF;


                IF (nvl(p_to_dept_id,-1) <> -1) AND (nvl(p_to_dept_id,-1) <> l_jmp_dept_id) THEN
                    x_return_code := 1;

                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
                x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    return(x_return_code);
        END IF;

        ELSE -- IF p_to_op_code IS NULL

                --CZH: one cannot jump to a non-std op outside routing !!!!
                --Added to remove non-std-ops functionality.
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_code');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
                --End additions

        END IF; -- p_to_op_code IS NULL/NOT NULL

    END IF; -- p_to_op_seq_num is NULL/NOT NULL
        /* JUMP_ENH:
       If the parameter is set not to charge jump_from_queue operations
           and the txn's from intraoperation step is 'Queue' then check to see
           if it qualifies for a jump_from_queue transaction without incurring
           any charges. */
        if (g_param_jump_fm_q = 2 and
            p_fm_intraop_step_type=1) then

        if (l_wo_qty_in_scrap <> 0 ) then
               fnd_message.set_name('WSM', 'WSM_SCRAP_EXISTS');
               x_err_buf := FND_MESSAGE.GET;
               fnd_file.put_line(fnd_file.log, x_err_buf);
               if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log, 'Jump from Queue is set to FALSE');
           end if;
        else
               WSMPLBMI.val_jump_from_queue(l_wip_entity_id,
                               p_org_id,
                               p_fm_op_seq_num,
                               l_wo_op_seq_id,
                               x_return_code,
                               x_err_buf);

               if (x_return_code <> 0) then
                  fnd_file.put_line(fnd_file.log,
                    'After calling WSMPLBMI.val_jump_from_queue ' || x_err_buf);
                  return(x_return_code);
               end if;
               l_jump_from_queue := TRUE;
               if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log,
            'Jump from Queue is set to TRUE');
           end if;
         end if; /* scrap <> 0 */
        end if; /* g_param_jump_fm_q = 2 */

    l_stmt_num := 280;
    IF (l_to_dept_code IS NULL) THEN
        UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
        SET    ( TO_DEPARTMENT_ID,      -- Fix bug #1501376
                 TO_DEPARTMENT_CODE )=
               (SELECT bd.department_id,    -- Fix bug #1501376
               bd.department_code
                FROM   BOM_DEPARTMENTS bd
                WHERE  bd.department_id = l_jmp_dept_id)
        WHERE  WLMTI.header_id = p_header_id
        RETURNING   TO_DEPARTMENT_CODE
        INTO        l_to_dept_code;

    l_stmt_num := 285;
        IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
            --x_return_code := SQLCODE;
        x_return_code := 1; -- Bugfix 1587295: Set it to 1. Setting to SQLCODE is incorrect
                                -- since it will have a value of 0 in this case.

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        ELSE
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_department_id/to_department_code');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        END IF;
        END IF; --l_to_dept_code IS NULL

    -- Fix bug #1501376
    l_to_dept_id := l_jmp_dept_id; -- l_to_dept_id is a local variable for p_to_dept_id, if NULL

    END IF; -- Check for Jumps
-----------------------------------------------------------------------------------
-- End of Jump
-----------------------------------------------------------------------------------
END IF; --(g_aps_wps_profile='Y')
/***********************************************
MOVE ENH END g_aps_wps_profile='Y'
******************************************************/
--move enh end
    --move enh move and scrap

    IF (l_scrap_qty < 0) THEN
        x_return_code := 1;
--      FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
--      FND_MESSAGE.SET_TOKEN('FLD_NAME', 'SCRAP QUANTITY-CAP');
/*          fnd_message.set_name(
            application => 'WIP',
            name        => 'WIP_GREATER_THAN');
          fnd_message.set_token(
            token     => 'ENTITY1',
            value     => 'SCRAP QUANTITY-CAP',
            translate => TRUE);
          fnd_message.set_token(
            token     => 'ENTITY2',
            value     => 'zero',
            translate => TRUE); */
        FND_MESSAGE.SET_NAME('WSM', 'WSM_SCRAP_NOT_LESS_THAN_ZERO');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    IF (p_txn_qty < 0) THEN
        x_return_code := 1;
--      FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
--      FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_quantity');
          fnd_message.set_name(
            application => 'WIP',
            name        => 'WIP_GREATER_THAN');
          fnd_message.set_token(
            token     => 'ENTITY1',
            value     => 'TRANSACTION QUANTITY-CAP',
            translate => TRUE);
          fnd_message.set_token(
            token     => 'ENTITY2',
            value     => 'zero',
            translate => TRUE);
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    IF ((l_scrap_qty = 0) AND (p_txn_qty = 0)) THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
--move enh? get the meaning of /
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_quantity/transaction_quantity');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    IF ((p_to_intraop_step_type = 5)) THEN
        IF ((l_scrap_qty > 0) AND (p_txn_qty > 0)) THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_quantity/transaction_quantity');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

        END IF;

        IF (l_scrap_at_operation_flag IS NOT NULL) THEN
            l_scrap_at_operation_flag := null;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_at_operation_flag');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        END IF;

    ELSIF (l_scrap_qty>0) THEN
--bug 3385113 added nvls
        IF ((nvl(p_jump_flag, 'N')='Y') OR (nvl(l_wo_op_seq_id, -1) <> nvl(l_op_seq_id, -1))) THEN

            IF (nvl(l_scrap_at_operation_flag, -1) NOT IN (1, 2)) THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_at_operation_flag');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            return(x_return_code);
            END IF;
        ELSE
            IF (nvl(l_scrap_at_operation_flag, -1) <>  1) THEN
            l_scrap_at_operation_flag := null;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_at_operation_flag');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            END IF;
        END IF;
    END IF;

--bug 3385113 added nvls
--    IF ((p_jump_flag='Y')  AND ((l_scrap_qty>0) AND (l_scrap_at_operation_flag=1)) AND (g_param_jump_fm_q = 2)) THEN
    IF ((nvl(p_jump_flag,'N')='Y')  AND ((l_scrap_qty>0) AND (nvl(l_scrap_at_operation_flag, -1)=1))
    AND (g_param_jump_fm_q = 2)) THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_SCRAP_AT_TO_ONLY');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    -- p_to_intraop_step_type should not be > 5  -- NSO Modification by abedajna
    IF ((p_to_intraop_step_type > 5) OR (p_to_intraop_step_type is NULL) OR
        (p_to_intraop_step_type = WIP_CONSTANTS.REJECT)) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_intraop_step_type');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    -- Cannot Scrap in a Future Op
    IF ( (p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) AND
         -- BC: CZH.bug2362225 need to consider NULL value
         --(l_wo_op_seq_id <> l_op_seq_id)
         ( nvl(l_wo_op_seq_id, -99) <> nvl(l_op_seq_id, -99)
           or -- ADD: CZH, jump will always add a new op, hence, cannot scrap
           upper(nvl(p_jump_flag, 'N')) <> 'N'
         )
    ) THEN
         -- EC: CZH.bug2362225
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_FUTURE_SCR');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;

    --mes added following if condition
    IF (nvl(l_source_code, 'interface') NOT IN ('move in oa page', 'move out oa page', 'jump oa page',
            'move to next op oa page', 'undo oa page'))
    THEN
        -- Get the next mandatory step
        -- NSO Modification by abedajna begin
        -- we call this routine only if we are currently in a std op,
        -- since mandatory steps do not make sense for nso.
    l_stmt_num := 290;
        if l_wo_std_op_id is not null then
            WSMPOPRN.get_current_op(l_wip_entity_id,
                                    l_current_op_seq,
                                    l_current_intraop_step,
                                    l_next_mand_step,
                                    x_return_code,
                                    x_err_buf);
            IF (x_return_code <> 0) THEN
                FND_MESSAGE.SET_NAME('WSM', 'WSM_CANNOT_GET_NEXT_MAND_STEP');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
            ELSE
            if (l_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                        ||'): Returned success from WSMPOPRN.get_current_op');
            end if;
            END IF;
        else
        l_next_mand_step := null;
        end if;

        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'l_next_mand_step: '||l_next_mand_step);
        end if;

        -- Cannot skip a mandatory intraop in the current op seq
        l_err_condition := 0;

        IF (l_next_mand_step is not NULL)  AND (l_next_mand_step > 0) THEN
                        -- there is a mandatory intraop in the current op

            -- CZH.DBG: WHAT IF l_wo_op_seq_id or l_op_seq_id IS NULL???
            IF (l_wo_op_seq_id <> l_op_seq_id) THEN -- Check if p_fm_op_seq_num = p_to_op_seq_num
                        l_err_condition := 1;
            ELSE -- p_fm_op_seq_num = p_to_op_seq_num
                IF (    (   (p_to_intraop_step_type = WIP_CONSTANTS.SCRAP)
                            OR
                            (   (l_scrap_qty>0)
                                AND
    --bug 3385113 add nvl
                                (nvl(l_scrap_at_operation_flag, -1)=1)))
                        AND
                        (   (p_fm_intraop_step_type = WIP_CONSTANTS.QUEUE)
                            AND
                            (l_next_mand_step = WIP_CONSTANTS.RUN)
                        )) THEN

                        l_err_condition := 1;

                END IF;
    --            ELSE
    --move enh case 2100 added p_to_intraop_step_type <> WIP_CONSTANTS.SCRAP
                IF ((p_txn_qty > 0) AND (p_to_intraop_step_type <> WIP_CONSTANTS.SCRAP)
                AND (p_to_intraop_step_type > l_next_mand_step)) THEN

                        l_err_condition := 1;

                END IF;
            END IF;
        ELSIF (l_next_mand_step is not NULL) THEN
                -- there is no mandatory intraop in the current op, for non-Jump moves

    l_stmt_num := 295;
            IF (l_wo_op_seq_id <> l_op_seq_id) AND (l_op_code is not NULL) THEN
                -- Check if p_fm_op_seq_num = p_to_op_seq_num
    --move enh changed l_std_operation_id to l_std_op_id
                IF (l_std_op_id IS NULL) THEN
                    SELECT  standard_operation_id
                    INTO    l_std_op_id
                    FROM    bom_standard_operations
                    WHERE   operation_code = l_op_code
                    AND     organization_id = p_org_id;

                 END IF;
                 l_std_operation_id := l_std_op_id;

    l_stmt_num := 300;

                l_intra_op_flag_value := WSMPOPRN.get_intra_operation_value
                                                          (l_std_operation_id,
                                                             x_return_code,
                                                            x_err_buf);
    --move enh end
                IF (x_return_code <> 0) THEN
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_INTRAOP_VALUE');
                    x_err_buf := FND_MESSAGE.GET;

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                    return(x_return_code);
                ELSE
                if (l_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                                  ||'): Returned success from WSMPOPRN.get_intra_operation_value');
            end if;
                END IF;

    l_stmt_num := 305;

                l_next_mand_step := WSMPOPRN.get_next_mandatory_step(0, l_intra_op_flag_value);
                -- l_next_mand_step is now the mandatory intra-op in p_to_op_seq_num

                IF (l_next_mand_step > 0) THEN -- there is a mandatory intraop
        IF ((l_scrap_qty>0) AND (l_scrap_at_operation_flag=2) AND (l_next_mand_step IN (WIP_CONSTANTS.QUEUE,
        WIP_CONSTANTS.RUN))) THEN
                        l_err_condition := 1;
        END IF;
            IF ((p_txn_qty > 0) AND (p_to_intraop_step_type > l_next_mand_step)) THEN
                        l_err_condition := 1;
                    END IF;
                END IF;
            END IF;
        END IF;

        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                              || ') l_err_condition: '||l_err_condition);
        end if;

        IF (l_err_condition = 1) THEN
            l_err_condition := 0;
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_MAND_STEP');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;
    END IF; --IF (nvl(l_source_code, 'interface') NOT IN ('move in oa page'

    IF (l_next_mand_step is NULL) then -- i.e. a nso

        -- bugfix 4090905 added jump flag check, when user doing a same operation jump, which equivalent to rework
        -- it's not necessary to check the intro-op-step.
            if (l_wo_op_seq_id = l_op_seq_id) and (p_jump_flag <> 'Y') then -- i.e. intra op move

                if (p_to_intraop_step_type <= p_fm_intraop_step_type) then
                    x_return_code := 1;
                    FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                    FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_intraop_step_type/to_intraop_step_type');
                    x_err_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                    return(x_return_code);
                end if;

            end if;

    end if;

-- NSO Modification by abedajna end

    l_operation_qty := l_wo_qty;
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'l_operation_qty='||l_operation_qty);
    end if;

    -- Validate UOM and quantity
l_stmt_num := 310;
--move enh
    if (p_txn_qty>0) then
        l_converted_txn_qty := inv_convert.inv_um_convert(item_id       => l_primary_item_id,
                                  precision     => NULL,
                                  from_quantity => p_txn_qty,
                                  from_unit     => p_txn_uom,
                                  to_unit       => l_primary_uom,
                                  from_name     => NULL,
                                  to_name       => NULL);
        if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'l_converted_txn_qty='||l_converted_txn_qty);
        end if;

        --bug 5496297 throw a message if api returns -99999 which means that no valid conversion exists
        if (l_converted_txn_qty = -99999) then
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_UOM_CONV');
            FND_MESSAGE.SET_TOKEN('VALUE1', p_txn_uom);
            FND_MESSAGE.SET_TOKEN('VALUE2', l_primary_uom);
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        end if;
        --end bug 5496297

        -- ST : Serial Support Project ---
        -- Validate the txn quantity and the converted qty here...
        IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
           (
             -- ST : Demo issue Commenting out :floor(p_txn_qty) <> p_txn_qty OR
             floor(l_converted_txn_qty) <> l_converted_txn_qty
           )
        THEN
                x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);

        END IF;
        -- ST : Serial Support Project ---

    end if;


    if (l_scrap_qty>0) then
        l_converted_scrap_qty := inv_convert.inv_um_convert(item_id       => l_primary_item_id,
                                                      precision     => NULL,
                                                      from_quantity => l_scrap_qty,
                                                      from_unit     => p_txn_uom,
                                                      to_unit       => l_primary_uom,
                                                      from_name     => NULL,
                                                      to_name       => NULL);
        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'l_converted_scrap_qty='||l_converted_scrap_qty);
    end if;

    -- ST : Serial Support Project ---
    -- Validate the scrap quantity and the converted qty here...
    IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
       (
        -- ST : Demo issue : Commenting out : floor(l_scrap_qty) <> l_scrap_qty OR
        floor(l_converted_scrap_qty) <> l_converted_scrap_qty
           )
        THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;
    -- ST : Serial Support Project ---

    end if;
            IF (l_converted_txn_qty > l_operation_qty) THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_quantity');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

        IF (l_converted_scrap_qty > l_operation_qty) THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_quantity');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;
--end move enh

l_stmt_num := 315;
    -- Must use entire operation qty as txn qty except for Scrap
    -- For Scrap txn qty must be <= operation qty
    --move enh added the condition OR (l_scrap_qty>0) to the if statement
    IF ((p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) OR (l_scrap_qty>0)) THEN

        if (l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log, 'IOP = SCRAP');
        end if;

-- abb H optional scap accounting begin
/*******************************************************************************
bug 3571019 rewriting the ESA validations for clarity
    l_est_scrap_acc := wsmputil.wsm_esa_enabled(l_wip_entity_id,
                            x_return_code,
                                                    x_err_buf);

        IF (x_return_code <> 0) THEN
            return(x_return_code);
    END IF;

    select job_type
    into   l_job_type
    from   wip_discrete_jobs
    where  wip_entity_id = l_wip_entity_id;

        if l_est_scrap_acc = 1 and l_job_type = 1 then

      IF (l_wlmti_scrap_acct_id = -1) THEN
--              get scrap_account from WCO
--          if scrap_account is null then
--              get scrap_account from BD
--          end if
bug 3571019 additionally we should try to get the scrap account from WCO for both the from op/to op
and then try BD
--bug 3571019 get the scrap account depending on the l_scrap_at_operation_flag
--if intraop scrap or scrap at from or if l_scrap_acc_id is null
--        IF (((p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) OR (nvl(l_scrap_at_operation_flag, 1)=1))
--        OR (l_scrap_acc_id IS NULL)) THEN
--move enh added the IF (l_scrap_acc_id IS NULL) condition
--      IF (l_scrap_acc_id IS NULL) THEN
--        SELECT nvl(scrap_account, -1)
--        INTO   l_wlmti_scrap_acct_id
--        FROM   BOM_DEPARTMENTS
--        WHERE  DEPARTMENT_ID=decode(l_scrap_at_operation_flag,
--                                    2, l_to_dept_id,
--                                    l_wo_dept_id)       --p_to_dept_id    --Fixed bug #1928993
--        WHERE  DEPARTMENT_ID=l_to_dept_id --p_to_dept_id    --Fixed bug #1928993
--        AND    ORGANIZATION_ID=p_org_id;
--        ELSE
--            l_wlmti_scrap_acct_id := l_scrap_acc_id;
--        END IF;

--bug 3571019
--      get scrap_account from WCO
        IF ((g_aps_wps_profile='Y') AND
            ((p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) OR (nvl(l_scrap_at_operation_flag, 1)=1)))
        THEN
            SELECT  WCO.scrap_account
            INTO    l_scrap_acc_id
            FROM    WSM_COPY_OPERATIONS WCO
            WHERE   WCO.wip_entity_id = l_wip_entity_id
            AND     WCO.operation_seq_num = l_wo_rtg_op_seq_num;
        END IF;

        IF l_scrap_acc_id IS NULL THEN
--          get scrap_account from BD
            SELECT nvl(scrap_account, -1)
            INTO   l_wlmti_scrap_acct_id
            FROM   BOM_DEPARTMENTS
            WHERE  DEPARTMENT_ID=decode(l_scrap_at_operation_flag,
                                    2, l_to_dept_id,
                                    l_wo_dept_id)       --p_to_dept_id    --Fixed bug #1928993
            AND    ORGANIZATION_ID=p_org_id;
        ELSE
            l_wlmti_scrap_acct_id := l_scrap_acc_id;
        END IF;
--end bug 3571019
l_stmt_num := 320;
        IF (l_wlmti_scrap_acct_id <> -1) THEN
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
            x_err_buf := FND_MESSAGE.GET;
                l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                              -- CZH.BUG2135538
            update wsm_lot_move_txn_interface
            set    scrap_account_id = l_wlmti_scrap_acct_id,
                       --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
            where  header_id = p_header_id;

l_stmt_num := 325;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        ELSE
            x_return_code := 1;
                -- abb changed the message
                fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                fnd_message.set_token('DEPT_ID',to_char(l_to_dept_id));
        x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
        END IF;
      END IF;

      --***VJ Added for Performance Upgrade***--
--bug 3571019 added decode so that we get the scrap account depending on the l_scrap_at_operation_flag
      BEGIN
            SELECT bd.department_id
            INTO   l_temp
            FROM   gl_code_combinations gcc,
           bom_departments bd
            WHERE  gcc.code_combination_id = l_wlmti_scrap_acct_id
            AND    bd.scrap_account = l_wlmti_scrap_acct_id
--            AND    bd.department_id = l_dept_id;
            AND    bd.department_id = decode(l_scrap_at_operation_flag,
                                        2, l_dept_id,
                                        l_wo_dept_id);

          EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_return_code := 1;

                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                x_err_buf := FND_MESSAGE.GET;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||
                        l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
          END;
      --***VJ End Additions***--

        elsif ((l_est_scrap_acc = 2 or l_job_type = 3)  and l_wlmti_scrap_acct_id <> -1) then

          BEGIN

            SELECT code_combination_id
            INTO   l_temp
            FROM   gl_code_combinations gl
            WHERE  gl.code_combination_id = l_wlmti_scrap_acct_id
            and    gl.enabled_flag = 'Y'
            and    gl.summary_flag = 'N'
            and    NVL(gl.start_date_active, sysdate) <=  sysdate
            and    NVL(gl.end_date_active, sysdate) >= sysdate;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='|| l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
          END;

        elsif  ((l_est_scrap_acc = 2 or l_job_type = 3) and l_wlmti_scrap_acct_id = -1) then

          l_wlmti_scrap_acct_id := '';

        end if; -- org is scrap acc enabled.
*******************************************************************************/
        l_est_scrap_acc := wsmputil.wsm_esa_enabled(l_wip_entity_id,
                                                    x_return_code,
                                                    x_err_buf);

        IF (x_return_code <> 0) THEN
            return(x_return_code);
        END IF;

        select job_type
        into   l_job_type
        from   wip_discrete_jobs
        where  wip_entity_id = l_wip_entity_id;

        if l_est_scrap_acc = 1 and l_job_type = 1 then
            IF (g_aps_wps_profile='Y') THEN
                IF (l_wlmti_scrap_acct_id = -1) THEN

                    IF ((p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) OR
                        (nvl(l_scrap_at_operation_flag, 1)=1))
                    THEN
                        BEGIN
                            SELECT  WCO.scrap_account
                            INTO    l_from_scrap_id
                            FROM    WSM_COPY_OPERATIONS WCO
                            WHERE   WCO.wip_entity_id = l_wip_entity_id
                            AND     WCO.operation_seq_num = l_wo_rtg_op_seq_num;
                        EXCEPTION
                            WHEN no_data_found THEN
                                fnd_file.put_line(fnd_file.log, 'in no data found after selecting from wco');
                        END;
                    END IF;

                    IF (((nvl(l_scrap_at_operation_flag, 1)=1) AND (l_from_scrap_id IS NULL)) OR
                        ((nvl(l_scrap_at_operation_flag, 1)=2) AND (l_to_scrap_id IS NULL)))
                    THEN
                        SELECT nvl(scrap_account, -1)
                        INTO   l_wlmti_scrap_acct_id
                        FROM   BOM_DEPARTMENTS
                        WHERE  DEPARTMENT_ID=decode(l_scrap_at_operation_flag,
                                                2, l_to_dept_id,
                                                l_wo_dept_id)
                        AND    ORGANIZATION_ID=p_org_id;
                    ELSE
                        IF (nvl(l_scrap_at_operation_flag, 1) = 1) THEN
                            l_wlmti_scrap_acct_id := l_from_scrap_id;
                        ELSE
                            l_wlmti_scrap_acct_id := l_to_scrap_id;
                        END IF;
                    END IF;

                    l_stmt_num := 320;
                    IF (l_wlmti_scrap_acct_id <> -1) THEN
                        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;
                        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);

                        update  wsm_lot_move_txn_interface
                        set     scrap_account_id = l_wlmti_scrap_acct_id,
                                error = l_error_msg
                        where   header_id = p_header_id;

                        l_stmt_num := 325;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    ELSE
                        x_return_code := 1;
                        fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                        IF (nvl(l_scrap_at_operation_flag, 1) = 1) THEN
                            fnd_message.set_token('DEPT_ID',to_char(l_wo_dept_id));
                        ELSE
                            fnd_message.set_token('DEPT_ID',to_char(l_to_dept_id));
                        END IF;
                        x_err_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END IF;

                    BEGIN
                        SELECT  gcc.code_combination_id
                        INTO    l_temp
                        FROM    gl_code_combinations gcc
                        WHERE   gcc.code_combination_id = l_wlmti_scrap_acct_id;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||
                                l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END;
                ELSE --(l_wlmti_scrap_acct_id <> -1)
                    BEGIN
                    --bug 4480248: If the current operation has been reached by jumping outside the routing then
                    --record will not be there in WCO.
                        IF (nvl(p_to_op_seq_num, -1) <> -1) THEN --regular move or jump inside rtg
                            SELECT  gcc.code_combination_id
                            INTO    l_temp
                            FROM    gl_code_combinations gcc,
                                    WSM_COPY_OPERATIONS WCO
                            WHERE   gcc.code_combination_id = l_wlmti_scrap_acct_id
                            AND     WCO.scrap_account       = gcc.code_combination_id
                            AND     WCO.wip_entity_id       = l_wip_entity_id
                            AND     WCO.operation_seq_num   = decode(l_scrap_at_operation_flag,
                                                                2, p_to_op_seq_num,
                                                                l_wo_rtg_op_seq_num);
                        ELSE --jump outside rtg
                            SELECT  gcc.code_combination_id
                            INTO    l_temp
                            FROM    gl_code_combinations gcc,
                                    bom_departments bd
                            WHERE   gcc.code_combination_id = l_wlmti_scrap_acct_id
                            AND     bd.scrap_account        = gcc.code_combination_id
                            AND     bd.department_id        = decode(l_scrap_at_operation_flag,
                                                                2, l_dept_id,
                                                                l_wo_dept_id);
                        END IF;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||
                                l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END;
                END IF;
            ELSE --(g_aps_wps_profile='N')
                IF (l_wlmti_scrap_acct_id = -1) THEN

                    IF ((l_from_scrap_id IS NULL) OR
                        (l_to_scrap_id IS NULL))
                    THEN
                        SELECT nvl(scrap_account, -1)
                        INTO   l_wlmti_scrap_acct_id
                        FROM   BOM_DEPARTMENTS
                        WHERE  DEPARTMENT_ID=decode(l_scrap_at_operation_flag,
                                                2, l_to_dept_id,
                                                l_wo_dept_id)
                        AND    ORGANIZATION_ID=p_org_id;
                    ELSE
                        IF (nvl(l_scrap_at_operation_flag, 1) = 1) THEN
                            l_wlmti_scrap_acct_id := l_from_scrap_id;
                        ELSE
                            l_wlmti_scrap_acct_id := l_to_scrap_id;
                        END IF;
                    END IF;

                    l_stmt_num := 320;
                    IF (l_wlmti_scrap_acct_id <> -1) THEN
                        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;
                        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);

                        update  wsm_lot_move_txn_interface
                        set     scrap_account_id = l_wlmti_scrap_acct_id,
                                error = l_error_msg
                        where   header_id = p_header_id;

                        l_stmt_num := 325;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
                    ELSE
                        x_return_code := 1;
                        fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                        IF (nvl(l_scrap_at_operation_flag, 1) = 1) THEN
                            fnd_message.set_token('DEPT_ID',to_char(l_wo_dept_id));
                        ELSE
                            fnd_message.set_token('DEPT_ID',to_char(l_to_dept_id));
                        END IF;
                        x_err_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END IF;

                    BEGIN
                        SELECT gcc.code_combination_id
                        INTO   l_temp
                        FROM   gl_code_combinations gcc
                        WHERE  gcc.code_combination_id = l_wlmti_scrap_acct_id;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||
                                l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END;
                ELSE --(l_wlmti_scrap_acct_id <> -1)

                    BEGIN
                        SELECT  gcc.code_combination_id
                        INTO    l_temp
                        FROM    gl_code_combinations gcc,
                                bom_departments bd
                        WHERE   gcc.code_combination_id = l_wlmti_scrap_acct_id
                        AND     bd.scrap_account        = gcc.code_combination_id
                        AND     bd.department_id        = decode(l_scrap_at_operation_flag,
                                                            2, l_dept_id,
                                                            l_wo_dept_id);
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_return_code := 1;

                        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                        x_err_buf := FND_MESSAGE.GET;

                        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||
                                l_stmt_num||'): '||x_err_buf);
                        return(x_return_code);
                    END;
                END IF; --(l_wlmti_scrap_acct_id = -1)
            END IF; --(g_aps_wps_profile='Y')

        elsif ((l_est_scrap_acc = 2 or l_job_type = 3)  and l_wlmti_scrap_acct_id <> -1) then

          BEGIN

            SELECT code_combination_id
            INTO   l_temp
            FROM   gl_code_combinations gl
            WHERE  gl.code_combination_id = l_wlmti_scrap_acct_id
            and    gl.enabled_flag = 'Y'
            and    gl.summary_flag = 'N'
            and    NVL(gl.start_date_active, sysdate) <=  sysdate
            and    NVL(gl.end_date_active, sysdate) >= sysdate;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_code := 1;
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
                x_err_buf := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='|| l_stmt_num||'): '||x_err_buf);
                return(x_return_code);
          END;

        elsif  ((l_est_scrap_acc = 2 or l_job_type = 3) and l_wlmti_scrap_acct_id = -1) then

          l_wlmti_scrap_acct_id := '';

        end if; -- org is scrap acc enabled.

-- abb H optional scap accounting end

    END IF; --(p_to_intraop_step_type = WIP_CONSTANTS.SCRAP) OR (l_scrap_qty>0)
l_stmt_num := 330;
--move enh commenting out the following IF and adding the new checks for move and scrap qty
/*        IF ( (l_converted_txn_qty > l_operation_qty) OR
             (l_converted_txn_qty < 0) )
        THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'primary_quantity');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;*/

--bug 3385113 added nvls
        IF ((p_to_intraop_step_type <> WIP_CONSTANTS.SCRAP)
        AND (nvl(l_converted_txn_qty, 0)+nvl(l_converted_scrap_qty, 0) <> l_operation_qty)) THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_SCRAP_MOVE_QTY_INCORRECT');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;
--move enh commented out ELSE branch

/*    ELSE   -- intraop step <> Scrap

    if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'IOP <>SCRAP');
    end if;

        IF (l_converted_txn_qty <> l_operation_qty) THEN

            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_TXN_QTY');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        END IF;

    END IF;
END IF;*/
--end move enh

l_stmt_num := 152;

    --** VJ: Start Changes for removal of 9999 **--
    -- BC: CZH.I_9999, the following logic is not correct
    /**********************************************
    BEGIN
        SELECT operation_seq_num
        INTO   l_temp -- <> 0, if moving from the last op
        FROM   bom_operation_sequences
        WHERE  operation_seq_num = p_fm_op_seq_num
        AND    operation_sequence_id = l_end_op_seq_id;
    EXCEPTION
        WHEN OTHERS THEN
            l_temp := 0;
    END;
    ***********************************************/
    BEGIN
        SELECT operation_sequence_id, backflush_flag
        INTO   l_temp, l_fm_op_bkflsh_flag
        FROM   wip_operations
        WHERE  operation_seq_num = p_fm_op_seq_num
        AND    wip_entity_id     = l_wip_entity_id
        AND    ORGANIZATION_ID   = p_org_id;
    EXCEPTION
        WHEN OTHERS THEN
            l_temp := 0;
    END;
    -- EC: CZH.I_9999

    -- no jumping is allowed at the last operation.
    -- if (p_fm_op_seq_num = g_prev_last_op and (upper(nvl(p_jump_flag, 'N')) = 'Y')) then
    if (l_temp = l_end_op_seq_id  and (upper(nvl(p_jump_flag, 'N')) = 'Y')) then
    --**VJ: End Changes for removal of 9999 **--
                    --***VJ Changed for Performance Upgrade***--
    x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'jump_flag');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

        return(x_return_code);
    end if;

l_stmt_num := 340;
        IF (g_aps_wps_profile='N') THEN
    SELECT standard_operation_id,
           department_id,
           operation_seq_num
    INTO   l_end_std_op_id,
           l_end_dept_id,
           l_end_op_seq_num
    FROM   bom_operation_sequences
    WHERE  operation_sequence_id = l_end_op_seq_id;
    END IF; --(g_aps_wps_profile='N')

l_stmt_num := 342;
    -- bugfix 3632605 if there is no sub defined or for whatever reason completion sub is missing
    -- completion transaction should not be allowed.

    select  completion_subinventory
    into    l_cmp_subinv
    from    wip_discrete_jobs
    where   wip_entity_id = l_wip_entity_id
    and     organization_id = p_org_id;

l_stmt_num := 345;
    IF (l_end_std_op_id IS NOT NULL) THEN
        IF (g_aps_wps_profile='N') THEN
        SELECT operation_code
        INTO   l_end_op_code
        FROM   bom_standard_operations
        WHERE  standard_operation_id = l_end_std_op_id;
            END IF; --(g_aps_wps_profile='N')

l_stmt_num := 350;
        --NSO Modification by abedajna begin
        -- Check if the to op_code is the last op_code in the routing
        IF ( (l_op_code = l_end_op_code) AND
             (p_to_op_seq_num = l_end_op_seq_num) AND
             (p_to_intraop_step_type = WIP_CONSTANTS.TOMOVE) )
        THEN

             --bugfix 3632605
            if (l_cmp_subinv is NULL)  then
              x_return_code := 1;

              fnd_message.set_name('WIP', 'WIP_EZ_NO_SUBINV_DEFAULT1');
              x_err_buf := fnd_message.get;

              fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

              return(x_return_code);
            end if;
            --endfix

            IF (l_txn_type <> 2) THEN  -- Move and Completion
        --NSO Modification by abedajna end
                l_error_msg := substr(l_error_msg||'WARNING: Changing transaction_type to 2.| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                UPDATE wsm_lot_move_txn_interface
                SET    transaction_type = 2,
                       --error = 'WARNING: Changing transaction_type to 2'    -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                WHERE  header_id = p_header_id;

l_stmt_num := 355;
        l_txn_type := 2;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                  ||l_stmt_num||'): WARNING: Changed transaction_type to 2 in WLMTI');

            END IF;
        ELSE -- not the last operation
            IF (l_txn_type <> 1) THEN -- Move only
                l_error_msg := substr(l_error_msg||'WARNING: Changing transaction_type to 1.| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                UPDATE wsm_lot_move_txn_interface
                SET    transaction_type = 1,
                       --error = 'WARNING: Changing transaction_type to 1'    -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                WHERE  header_id = p_header_id;

l_stmt_num := 360;
        l_txn_type := 1;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                  ||l_stmt_num||'): WARNING: Changed transaction_type to 1 in WLMTI');
            END IF;
        END IF;

    ELSE    -- l_end_std_op_id IS NULL  -- CZH: non-std end op

        -- Check if the to dept_id is the dept_id of the last operation in the routing
        IF ( (l_to_dept_id = l_end_dept_id) AND
             (p_to_op_seq_num = l_end_op_seq_num) AND
             (p_to_intraop_step_type = WIP_CONSTANTS.TOMOVE) )
        THEN

             --bugfix 3632605
            if (l_cmp_subinv is NULL)  then
              x_return_code := 1;

              fnd_message.set_name('WIP', 'WIP_EZ_NO_SUBINV_DEFAULT1');
              x_err_buf := fnd_message.get;

              fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

              return(x_return_code);
            end if;
            --endfix

            IF (l_txn_type <> 2) THEN  -- Move and Completion
                l_error_msg := substr(l_error_msg||'WARNING: Changing transaction_type to 2.| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                UPDATE wsm_lot_move_txn_interface
                SET    transaction_type = 2,
                       --error = 'WARNING: Changing transaction_type to 2'    -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                WHERE  header_id = p_header_id;

l_stmt_num := 365;
        l_txn_type := 2;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                  ||l_stmt_num||'): WARNING: Changed transaction_type to 2 in WLMTI');
            END IF;
        ELSE -- not the last operation
            IF (l_txn_type <> 1) THEN -- Move only
                l_error_msg := substr(l_error_msg||'WARNING: Changing transaction_type to 1.| ', 1, 2000);
                                                                              -- CZH.BUG2135538
                UPDATE wsm_lot_move_txn_interface
                SET    transaction_type = 1,
                       --error = 'WARNING: Changing transaction_type to 1'    -- CZH.BUG2135538
                       error = l_error_msg                                    -- CZH.BUG2135538
                WHERE  header_id = p_header_id;

l_stmt_num := 370;
        l_txn_type := 1;

                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                  ||l_stmt_num||'): WARNING: Changed transaction_type to 1 in WLMTI');
            END IF;
        END IF;
    END IF;

--move enh 115.135 check for backflush flag
		--bug 5905993 Replace the if condition with different cases for interface and MES transaction. In MES scrap can only
		--be performed at the from operation
    --IF (((l_fm_op_bkflsh_flag = 2) or (l_to_op_bkflsh_flag = 2)) AND
    --(l_scrap_at_operation_flag IS NOT NULL)) THEN
    IF  (((nvl(l_source_code, 'interface') NOT IN ('move in oa page', 'move out oa page', 'jump oa page', 'move to next op oa page', 'undo oa page'))
					AND
					(((l_fm_op_bkflsh_flag = 2)
							OR
							(l_to_op_bkflsh_flag = 2))
						AND
						(l_scrap_at_operation_flag IS NOT NULL)))
				OR
				((nvl(l_source_code, 'interface') = 'move out oa page')
					AND
					((l_fm_op_bkflsh_flag = 2)
						AND
						(nvl(l_scrap_at_operation_flag, 0) = 1))))
		THEN
        l_stmt_num := 371;
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_SCRAP_BKFLSH_OFF');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        return(x_return_code);
    END IF;

END IF;   -- for forward moves and completions

-------------------------------------------------------------------------------------
-----------------------------END MOVE AND COMPLETION---------------------------------
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
------------------------------------ASSEMBLY RETURNS---------------------------------
-------------------------------------------------------------------------------------
--   Assy returns are treated as undoing the last completion transaction.
IF (l_txn_type = 3) then   -- for Assy returns

    -- Get the details of the last completion transaction for this job
l_stmt_num := 375;

    --***VJ Changed for Performance Upgrade***--
    BEGIN
    select max(transaction_id)
    into   l_max_txn_id
        from   wip_move_transactions
        where  organization_id = p_org_id
        and    wip_entity_id = l_wip_entity_id
--        and    to_operation_seq_num = g_prev_last_op -- l_wsm_last_op --**VJ: Deleted for removal of 9999**
            --***VJ Changed for Performance Upgrade***--
        and    to_intraoperation_step_type = 3
--move enh --FP bug 5178168 (base bug 5168406) changed the line below
    --and transaction_id = batch_id;
    and transaction_id = nvl(batch_id, transaction_id);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_COMPLETION');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            return(x_return_code);
    END;
    --***VJ End Changes***--

l_stmt_num := 377;
    IF (nvl(l_max_txn_id, -1) = -1) THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_COMPLETION');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        return(x_return_code);
    END IF;

l_stmt_num := 380;
--move enh added batch_id to the list of columns
--mes added source_code
    select FM_OPERATION_SEQ_NUM,
           FM_OPERATION_CODE,
           FM_INTRAOPERATION_STEP_TYPE,
           FM_DEPARTMENT_ID,
       TO_OPERATION_SEQ_NUM,    --**VJ: Added for Removal of 9999**
           TO_OPERATION_CODE,
           TO_DEPARTMENT_ID,
           TRANSACTION_QUANTITY,
           --FP bug 5178168 (base bug 5168406) changed the line below
           --BATCH_ID,
           nvl(BATCH_ID, transaction_id),
           --bug 5185751 get scrap account id from scrap txn only
           --scrap_account_id,
           source_code
     into   l_cmp_fm_op_seq_num,
           l_cmp_fm_op_code,
           l_cmp_fm_intra_op_step,
           l_cmp_fm_dept_id,
           l_cmp_to_op_seq_num,     --**VJ: Added for Removal of 9999**
           l_cmp_to_op_code,
           l_cmp_to_dept_id,
           l_cmp_txn_qty,
           l_cmp_batch_id,
            --l_wmt_scrap_acc,           --bug 4090866 get scrap_account_id from WMT
            x_undo_source_code
    from   wip_move_transactions
    where  transaction_id = l_max_txn_id; --***VJ Changed for Performance Upgrade***--

--mes
    IF ((nvl(x_undo_source_code, 'interface') IN ('move in oa page', 'move out oa page', 'jump oa page',
        'move to next op oa page')) AND (nvl(l_source_code, 'interface') = 'interface'))
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MES_UNDO_OA_FORMSINTERFACE');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        return(x_return_code);
    END IF;
--mes end

    IF (l_cmp_fm_op_seq_num <> l_cmp_to_op_seq_num) THEN
        UPDATE  WSM_LOT_BASED_JOBS
        SET     current_job_op_seq_num = l_cmp_fm_op_seq_num,
                current_rtg_op_seq_num =
                    (SELECT wsm_op_seq_num
                    FROM    WIP_OPERATIONS WO
                    WHERE   WO.wip_entity_id = l_wip_entity_id
                    AND     WO.operation_seq_num = l_cmp_fm_op_seq_num)
        WHERE   WIP_ENTITY_ID = l_wip_entity_id;
    END IF;
--mes end
    -- ST : Serial Support Project --
    -- Copy the old move transaction id...
    x_old_move_transaction_id := l_max_txn_id;
    -- ST : Serial Support Project --

--bug 4090866 get scrap_account_id from WMT and update WLMTI
--bug 5185751 get scrap account id from scrap txn only. Moved this validation after getting
--scrap account id from scrap txn
/*************
    IF (nvl(l_wmt_scrap_acc, -1) <> nvl(l_wlmti_scrap_acct_id, -1)) THEN
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
            x_err_buf := FND_MESSAGE.GET;
            l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);

            update wsm_lot_move_txn_interface
            set scrap_account_id = l_wmt_scrap_acc,
                error = l_error_msg
            where header_id = p_header_id;
    END IF;
*****/
--bug 4090866 end

l_stmt_num := 385;

    -- Check if WLMTI.to_op is null or not. If so, update it with the right op seq

--NSO modification by abedajna begin

/*    if (
    ((nvl(p_to_op_seq_num,-1) <> -1) and (p_to_op_seq_num <> l_cmp_fm_op_seq_num)) or
        ((p_to_op_code is not null) and (p_to_op_code <> l_cmp_fm_op_code))  or
        ((p_to_intraop_step_type is not null) and (p_to_intraop_step_type <> l_cmp_fm_intra_op_step)) or
        ((p_txn_qty  is not null) and (p_txn_qty <> l_cmp_txn_qty))
    ) then
*/
    --bug 3217724 modified the above if condition consistent with the OSFM interface manual
    if (
        ((nvl(p_to_op_seq_num,-1) <> -1) and (p_to_op_seq_num <> l_cmp_fm_op_seq_num)) or
            ((p_to_op_code is null) or (p_to_op_code <> l_cmp_fm_op_code))  or
            ((p_to_intraop_step_type is null) or (p_to_intraop_step_type <> l_cmp_fm_intra_op_step)) or
            ((p_txn_qty  is null) or (p_txn_qty <> l_cmp_txn_qty))
    ) then

--NSO modification by abedajna end

            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_operation_seq_num/to_operation_code/to_intraoperation_step_type/transaction_quantity');
            x_err_buf := FND_MESSAGE.GET;
            l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                          -- CZH.BUG2135538
            update wsm_lot_move_txn_interface
            set TO_OPERATION_SEQ_NUM = l_cmp_fm_op_seq_num,
                TO_OPERATION_CODE = l_cmp_fm_op_code,
                TO_INTRAOPERATION_STEP_TYPE = l_cmp_fm_intra_op_step,
                TRANSACTION_QUANTITY = l_cmp_txn_qty,
            --ERROR = 'WARNING:'||x_err_buf                           -- CZH.BUG2135538
                error = l_error_msg                                       -- CZH.BUG2135538
            where header_id = p_header_id;

l_stmt_num := 390;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    end if;

    BEGIN
             -- ST : Serial Support Project ---
             -- Retrieve the old scrap transaction id by qurerying up the transaction id in this below sql...
             SELECT  transaction_quantity,
                    primary_quantity,
                    decode(WMT.to_operation_seq_num, l_cmp_fm_op_seq_num, 1, 2),
                    transaction_id,
                    --bug 5185751 get scrap account id from scrap txn only
                    scrap_account_id
             INTO    l_wmt_scrap_qty,
                    l_wmt_pri_scrap_qty,
                    l_wmt_scrap_at_op_flag,
                    x_old_scrap_transaction_id,
                    l_wmt_scrap_acc
             FROM WIP_MOVE_TRANSACTIONS WMT
             WHERE organization_id = p_org_id
             and    wip_entity_id = l_wip_entity_id
             --FP bug 5178168 (base bug 5168406) changed the line below
             --and WMT.batch_id=l_max_txn_id
             and nvl(WMT.batch_id, wmt.transaction_id)=l_max_txn_id
             AND WMT.transaction_id <> l_max_txn_id
             AND to_intraoperation_step_type = 5;
             -- ST : Serial Support Project ---
    EXCEPTION
            WHEN no_data_found THEN
                null;
    END;

    --bug 4090866 get scrap_account_id from WMT and update WLMTI
    --bug 5185751 get scrap account id from scrap txn only. Moved this validation after getting
    --scrap account id from scrap txn
    IF (nvl(l_wmt_scrap_acc, -1) <> nvl(l_wlmti_scrap_acct_id, -1)) THEN
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
            x_err_buf := FND_MESSAGE.GET;
            l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);

            update wsm_lot_move_txn_interface
            set scrap_account_id = l_wmt_scrap_acc,
                error = l_error_msg
            where header_id = p_header_id;
    END IF;
    --bug 4090866 end

    IF (g_aps_wps_profile = 'Y') THEN
            BEGIN
            SELECT  nvl(WCO.recommended, 'N')
                    INTO    l_recommended
                    FROM    WSM_COPY_OPERATIONS WCO,
                            WIP_OPERATIONS WO
                    WHERE   WO.wip_entity_id = l_wip_entity_id
                    AND     WO.organization_id = p_org_id
                    AND     WO.operation_seq_num = l_cmp_fm_op_seq_num
                    AND     WCO.wip_entity_id = WO.wip_entity_id
                    AND WCO.operation_sequence_id = WO.operation_sequence_id;
                EXCEPTION
            WHEN    no_data_found THEN
                l_recommended := 'N';
            END;
    END IF;

    -- Update WLMTI.from_op to NULL. No need to validate.
--move enh moved the update further down
 /*   update wsm_lot_move_txn_interface
    set    FM_OPERATION_SEQ_NUM = NULL,
           FM_OPERATION_CODE = NULL,
           FM_INTRAOPERATION_STEP_TYPE = NULL
    where  header_id = p_header_id;*/

l_stmt_num := 395;
    -- Get the onhand quantity for the WDJ.lot_number, completion_subinventory, locator_id and
    -- compare it with p_txn_qty. If not equal, then error out


    select PRIMARY_ITEM_ID,
           COMPLETION_SUBINVENTORY,
           COMPLETION_LOCATOR_ID,
           LOT_NUMBER,
       class_code, --bug 2484294
       job_type, --bug 2484294
           kanban_card_id, -- abbKanban
           quantity_completed   -- Fix for bug #2095267
    into   l_cmp_primary_item_id,
           l_cmp_subinv,
           l_cmp_loc_id,
           l_cmp_lot_number,
       l_class_code,
           l_job_type,
           l_kanban_card_id,
       l_qty_completed  -- Fix for bug #2095267
    from   wip_discrete_jobs
    where  organization_id = p_org_id
    and    wip_entity_id = l_wip_entity_id;

l_stmt_num := 400;

    -- Fix bug 1495104
    --select sum(transaction_quantity)
    -- Fix bug 1495104
    select nvl(sum(transaction_quantity),0)
    into   l_onhand_qty
--bug 3324825 change to mtl_onhand_quantities_detail
--    from   mtl_onhand_quantities
    from   mtl_onhand_quantities_detail
    where  organization_id = p_org_id
    and    inventory_item_id = l_cmp_primary_item_id
    and    subinventory_code = l_cmp_subinv
    and    nvl(locator_id, -1) = nvl(l_cmp_loc_id, nvl(locator_id, -1)) --Fix for bug 1495104
    and    lot_number = nvl(l_cmp_lot_number, lot_number);


    if (l_debug = 'Y') then
    fnd_file.put_line(fnd_file.log, 'l_onhand_qty='||l_onhand_qty
                          ||', p_txn_qty='||p_txn_qty||', l_qty_completed='||l_qty_completed);
    end if;

--BA: CZH: BUG2154720
l_stmt_num := 403;
    l_converted_txn_qty := inv_convert.inv_um_convert (item_id       => l_primary_item_id,
                                                       precision     => NULL,
                                                       from_quantity => p_txn_qty,
                                                       from_unit     => p_txn_uom,
                                                       to_unit       => l_primary_uom,
                                                       from_name     => NULL,
                                                       to_name       => NULL);
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'l_converted_txn_qty='||l_converted_txn_qty);
    end if;

    -- ST : Serial Support ---
    -- Place validations here for the transaction quantity and the converted txn quantity,...
    IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
       (
        -- ST : Demo issue : Commenting out : floor(p_txn_qty) <> p_txn_qty OR
        floor(l_converted_txn_qty) <> l_converted_txn_qty
       )
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;
    -- ST : Serial Support ---

--EA: CZH: BUG 2154720
--move enh not needed since wmt already has pri scrap qty
/*  IF (l_scrap_qty > 0) THEN
        l_converted_scrap_qty := inv_convert.inv_um_convert (item_id       => l_primary_item_id,
                                                       precision     => NULL,
                                                       from_quantity => l_scrap_qty,
                                                       from_unit     => p_txn_uom,
                                                       to_unit       => l_primary_uom,
                                                       from_name     => NULL,
                                                           to_name       => NULL);

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'l_converted_txn_qty='||l_converted_txn_qty);
    end if;
    END IF; --l_scrap_qty > 0  */

    IF (nvl(l_scrap_qty, -1) <> nvl(l_wmt_scrap_qty, -1)) THEN
        l_scrap_qty := l_wmt_scrap_qty;
        l_converted_scrap_qty := l_wmt_pri_scrap_qty;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_quantity');
            x_err_buf := FND_MESSAGE.GET;
    END IF;

    IF (nvl(l_scrap_at_operation_flag, -1) <> nvl(l_wmt_scrap_at_op_flag, -1)) THEN
        l_scrap_at_operation_flag := l_wmt_scrap_at_op_flag;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_at_operation_flag');
        x_err_buf := FND_MESSAGE.GET;
    END IF;

    update wsm_lot_move_txn_interface
    set    FM_OPERATION_SEQ_NUM = l_cmp_to_op_seq_num,
           FM_OPERATION_CODE = l_cmp_to_op_code,
           FM_INTRAOPERATION_STEP_TYPE = WIP_CONSTANTS.TOMOVE,
           SCRAP_QUANTITY = l_wmt_scrap_qty
    where  header_id = p_header_id;

    l_converted_scrap_qty := l_wmt_pri_scrap_qty;

--move enh


l_stmt_num := 405;

    -- if (l_onhand_qty <> p_txn_qty) OR                -- CZH: BUG 2154720
    if (l_onhand_qty <> NVL(l_converted_txn_qty,0)) OR  -- CZH: BUG 2154720
       ((l_onhand_qty) <> l_qty_completed) then -- Added 2nd condition to fix bug #2095267
--            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
--            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction quantity');
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_RETURN'); -- Fix for bug #2095267
            x_return_code := 1;
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            return(x_return_code);
    end if;

-- abbKanban begin
l_stmt_num := 406;

-- when returning, if the job has a kanban reference, just provide a warning...
                if l_kanban_card_id is not null then
                              FND_MESSAGE.set_name('WSM', 'WSM_KNBN_RET_ISSUES');
                              x_warning_mesg := fnd_message.get;
                              fnd_file.put_line(fnd_file.log, '******** WARNING *********');
                              fnd_file.put_line(fnd_file.log, x_warning_mesg);
                              fnd_file.put_line(fnd_file.log, '******** WARNING *********');
                end if; --kanban card is not null



/*                if l_kanban_card_id is not null then
**-- when you return, if the kanban is in InProcess status, do not allow the return
**-- after return, the kanban status should be changed to InProcess
**                        select supply_status
**                        into l_cur_supply_status
**                        from mtl_kanban_card_activity
**                        where kanban_card_id = l_kanban_card_id
**                        and kanban_activity_id =
**                                (select max(kanban_activity_id)
**                                 from mtl_kanban_card_activity
**                                 where kanban_card_id = l_kanban_card_id);
**
**l_stmt_num := 406.1;
**          if l_cur_supply_status = 5 then
**              FND_MESSAGE.set_name('WSM', 'WSM_KNBN_RET_ISSUES');
**              x_warning_mesg := fnd_message.get;
**              fnd_file.put_line(fnd_file.log, '******** WARNING *********');
**              fnd_file.put_line(fnd_file.log, x_warning_mesg);
**              fnd_file.put_line(fnd_file.log, '******** WARNING *********');
**          else
**                              inv_kanban_pvt.Update_Card_Supply_Status
**                                        (X_Return_Status => l_returnStatus,
**                                         p_Kanban_Card_Id => l_kanban_card_id,
**                                         p_Supply_Status =>  inv_kanban_pvt.g_supply_status_InProcess);
**
**                              if ( l_returnStatus <> fnd_api.g_ret_sts_success) then
**                                    FND_MESSAGE.SET_NAME('WSM', 'WSM_KNBN_CARD_STS_FAIL');
**                                    fnd_message.set_token('STATUS','InProcess');
**                                    x_return_code := 1;
**                                    x_err_buf := FND_MESSAGE.GET;
**                                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
**                                    return(x_return_code);
**                              end if;
**          end if;
**
**                end if; --kanban card is not null
*/
-- abbKanban end


l_stmt_num := 410;
-- abb bugfix 2484294 begin
-- check that the class code and the dept of the last operation have the relevant accounts defined.
    l_est_scrap_acc := wsmputil.WSM_ESA_ENABLED(
                p_wip_entity_id => l_wip_entity_id,
                                err_code => l_err_code,
                                err_msg => l_err_msg,
                                p_org_id => p_org_id,
                                p_job_type => l_job_type);

    --NO CHECK FOR RETURN VALUES HERE....-VJ--

    select est_scrap_account, est_scrap_var_account
    into   p_est_scrap_account, p_est_scrap_var_account
    from   wip_accounting_classes
    where  class_code = l_class_code
    and    organization_id = p_org_id;

    if p_est_scrap_account is null or p_est_scrap_var_account is null then
    if l_est_scrap_acc = 1 then
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_WAC_SCRAP_ACC');
            fnd_message.set_token('CC', l_class_code);
        x_return_code := 1;
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
            return(x_return_code);
    end if;
    end if;

    update wip_discrete_jobs wdj
    set    wdj.est_scrap_account = nvl(p_est_scrap_account, wdj.est_scrap_account),
           wdj.est_scrap_var_account = nvl(p_est_scrap_var_account, wdj.est_scrap_var_account)
    where  wip_entity_id = l_wip_entity_id;

    select scrap_account, est_absorption_account
    into   l_scrap_account, l_est_scrap_abs_account
    from   bom_departments
    where  department_id = l_cmp_to_dept_id;

    if l_scrap_account is null or l_est_scrap_abs_account is null then
    if l_est_scrap_acc = 1 then
        fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
        fnd_message.set_token('DEPT_ID',to_char(l_cmp_to_dept_id));
        x_return_code := 1;
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        return(x_return_code);
    end if;
    end if;

    UPDATE WIP_OPERATION_YIELDS WOY
    SET    SCRAP_ACCOUNT = nvl(l_scrap_account, WOY.SCRAP_ACCOUNT),
           EST_SCRAP_ABSORB_ACCOUNT = nvl(l_est_scrap_abs_account, WOY.EST_SCRAP_ABSORB_ACCOUNT)
    WHERE  WIP_ENTITY_ID = l_wip_entity_id
    --** VJ: Start Changes for removal of 9999 **--
--    and    operation_seq_num = g_prev_last_op;
    and    operation_seq_num = l_cmp_to_op_seq_num;
    --** VJ: End Changes for removal of 9999 **--

-- abb bugfix 2484294 end

END IF;   -- for assy returns

-------------------------------------------------------------------------------------
------------------------------------END ASSEMBLY RETURNS-----------------------------
-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
------------------------------------BACKWARD MOVES-----------------------------------
-------------------------------------------------------------------------------------
IF (l_txn_type = 4) then   -- for Backward moves
    -- Find  out whether there is an operation that has positive qty

   l_stmt_num := 410;
   -- Check if Backward moves are allowed or not.
   /*  JUMP_ENH: Commented the following because it's moved to the
       beginning and called only when the organization_id is changed
    select ALLOW_BACKWARD_MOVE_FLAG
    into   l_allow_bkw_move
    from   wsm_parameters
    where  organization_id = p_org_id;  */

    if (g_allow_bkw_move <> 1) then
        x_return_code := 1;
        --bug 4202723
        --FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        --FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Backward Move Flag');
        FND_MESSAGE.SET_NAME('WSM', 'WSM_UNDO_NOT_ENABLED');
        --end bug 4202723
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

        return(x_return_code);
    end if;


    --***VJ Changed for Performance Upgrade***--
    BEGIN
    select max(OPERATION_SEQ_NUM)
    into   l_max_qty_op_seq_num
        from   wip_operations
        where  organization_id = p_org_id
        and    wip_entity_id = l_wip_entity_id
        and    ((QUANTITY_IN_QUEUE > 0) or
                (QUANTITY_RUNNING > 0) or
                (QUANTITY_WAITING_TO_MOVE > 0) or
                (QUANTITY_SCRAPPED > 0));

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_name');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
    END;
    --***VJ End Changes***--

l_stmt_num := 420;

    -- Find  out at which operation/intra-op step the quantity lies in WIP

    BEGIN
    select  OPERATION_SEQ_NUM,
            decode(sign(QUANTITY_IN_QUEUE),1,QUANTITY_IN_QUEUE,0),
            decode(sign(QUANTITY_RUNNING),1,QUANTITY_RUNNING,0),
            decode(sign(QUANTITY_WAITING_TO_MOVE),1,QUANTITY_WAITING_TO_MOVE,0),
            decode(sign(QUANTITY_SCRAPPED),1,QUANTITY_SCRAPPED,0)
    into    l_wo_op_seq_num,
            l_wo_qty_in_queue,
            l_wo_qty_in_running,
            l_wo_qty_in_tomove,
            l_wo_qty_in_scrap
    from    wip_operations
    where   organization_id = p_org_id
    and     wip_entity_id = l_wip_entity_id
    and     OPERATION_SEQ_NUM = l_max_qty_op_seq_num; --***VJ Changed for Performance Upgrade***--

    p_fm_op_seq_num_orig := p_fm_op_seq_num; --bug 5349187: Store the original value of p_fm_op_seq_num
-- OSP FP I added the next line
    p_fm_op_seq_num := l_wo_op_seq_num;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
             x_return_code := 1;

             FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
             FND_MESSAGE.SET_TOKEN('FLD_NAME', 'wip_entity_name');
             x_err_buf := FND_MESSAGE.GET;

             fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
             return(x_return_code);
    END;


l_stmt_num := 425;


    -- Check if qty exists in 2 intraops in the same op (e.g. Run and Scrap)

    l_wo_qty_iop_step := 0;
    l_wo_qty_scrap_step := 0;

    if(l_wo_qty_in_queue <> 0) then
         l_wo_qty_iop_step := 1;
         l_wo_qty := l_wo_qty_in_queue;
    elsif(l_wo_qty_in_running <> 0) then
         l_wo_qty_iop_step := 2;
         l_wo_qty := l_wo_qty_in_running;
    elsif(l_wo_qty_in_tomove <> 0) then
         l_wo_qty_iop_step := 3;
         l_wo_qty := l_wo_qty_in_tomove;
    end if;

    --bug 4380374
    x_available_qty := l_wo_qty;
    --end bug 4380374

    if(l_wo_qty_in_scrap <> 0) then
         l_wo_qty_scrap_step := 5;
    end if;

    -- Start fix for bug #2095253
    BEGIN
        SELECT max(transaction_id)
        INTO   l_txn_id
        FROM   wip_move_transactions
        WHERE  organization_id = p_org_id
        AND    wip_entity_id = l_wip_entity_id
--move enh added transaction_id = batch_id --FP bug 5178168 (base bug 5168406) changed the line below
    --AND transaction_id = batch_id;
        AND transaction_id = nvl(batch_id, transaction_id);

    IF (l_txn_id IS NULL) THEN
             x_return_code := 1;

             FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_MOVE_TXNS');
             x_err_buf := FND_MESSAGE.GET;

             fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

             return(x_return_code);
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
             x_return_code := 1;

             FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_MOVE_TXNS');
             x_err_buf := FND_MESSAGE.GET;

             fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
             return(x_return_code);
    END;
    -- End fix for bug #2095253

    -- abb changes for bug 2427171 begins
    l_txn_id := null;
    -- abb changes for bug 2427171 ends

    --***VJ Changed for Performance Upgrade***--
    BEGIN
        select max(transaction_id)
        into   l_txn_id
        from   wip_move_transactions
        where  organization_id = p_org_id
        and    wip_entity_id = l_wip_entity_id
        and    to_operation_seq_num = l_wo_op_seq_num
        and    to_intraoperation_step_type IN (l_wo_qty_iop_step, l_wo_qty_scrap_step)
        and    (fm_operation_seq_num < to_operation_seq_num OR
                (fm_operation_seq_num = to_operation_seq_num AND
             fm_intraoperation_step_type < to_intraoperation_step_type)
               )
--move enh added transaction_id = batch_id --FP bug 5178168 (base bug 5168406) changed the line below
    --AND transaction_id = batch_id;
       AND transaction_id = nvl(batch_id, transaction_id);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             x_return_code := 1;

             FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
             FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_operation_seq_num/transaction_quantity');
             x_err_buf := FND_MESSAGE.GET;

             fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
             return(x_return_code);
    END;

    -- abb changes for bug 2427171 begin
    if l_txn_id is null then
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_MOVE_CAND');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf) ;
        return(x_return_code);
    end if;
    -- abb changes for bug 2427171 end
    --***VJ End Changes***--


l_stmt_num := 430;

    -- Get the from_op_seq/code/iop from which the move was made to the above op_seq/iop

    select   FM_OPERATION_SEQ_NUM,
             FM_OPERATION_CODE,
             FM_INTRAOPERATION_STEP_TYPE,
             FM_DEPARTMENT_ID,
             TO_OPERATION_SEQ_NUM,
             TO_OPERATION_CODE,
             TO_INTRAOPERATION_STEP_TYPE,
             TO_DEPARTMENT_ID,
             TRANSACTION_QUANTITY,
             PRIMARY_QUANTITY,
             --bug 5349187 reversed part of the fix for bug 5185751 by uncommenting following line since
             --l_wmt_scrap_acct_id was not getting populated for undo of scrap only transaction
             NVL(SCRAP_ACCOUNT_ID, -1),
             source_code
    into     l_fm_op_seq_num,
             l_fm_op_code,
             l_fm_intraop_step,
             l_fm_dept_id,
             l_to_op_seq_num,
             l_to_op_code,
             l_to_intraop_step,
             l_to_dept_id,
             l_wmt_txn_qty,
             l_wmt_pri_txn_qty,
             --bug 5349187 reversed part of the fix for bug 5185751 by uncommenting following line since
             --l_wmt_scrap_acct_id was not getting populated for undo of scrap only transaction
             l_wmt_scrap_acct_id,
             x_undo_source_code
    from   wip_move_transactions
    where  transaction_id = l_txn_id;

--mes

    IF ((x_undo_source_code IN ('move in oa page', 'move out oa page', 'jump oa page',
        'move to next op oa page')) AND (nvl(l_source_code, 'interface') = 'interface'))
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MES_UNDO_OA_FORMSINTERFACE');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        return(x_return_code);
    END IF;

    IF (l_fm_op_seq_num <> l_to_op_seq_num) THEN
        UPDATE  WSM_LOT_BASED_JOBS
        SET     current_job_op_seq_num = l_fm_op_seq_num,
                current_rtg_op_seq_num =
                    (SELECT wsm_op_seq_num
                    FROM    WIP_OPERATIONS WO
                    WHERE   WO.wip_entity_id = l_wip_entity_id
                    AND     WO.operation_seq_num = l_fm_op_seq_num)
        WHERE   WIP_ENTITY_ID = l_wip_entity_id;
    END IF;
--mes end

    -- ST : Serial Support Project --
    -- Assign the old move transaction id...
    x_old_move_transaction_id := l_txn_id;
    -- ST : Serial Support Project --

l_stmt_num := 435;
    BEGIN
            -- ST : Serial Support ---
            -- Obtain the scrap txn id also...
            SELECT  transaction_quantity,
                    primary_quantity,
                    decode(to_operation_seq_num,FM_OPERATION_SEQ_NUM, 1, 2),
                    transaction_id,
                    --bug 5185751 SCRAP_ACCOUNT_ID should be obtained from scrap txn only
                    scrap_account_id
            INTO    l_wmt_scrap_qty,
                    l_wmt_pri_scrap_qty,
                    l_wmt_scrap_at_op_flag,
                    x_old_scrap_transaction_id,
                    l_wmt_scrap_acct_id
            FROM    WIP_MOVE_TRANSACTIONS
            --move enh 115.135 added wip_entity_id after perf check
            WHERE   wip_entity_id = l_wip_entity_id
            --FP bug 5178168 (base bug 5168406) changed the line below
            --AND     batch_id=l_txn_id
            AND     nvl(batch_id, transaction_id) =l_txn_id
            AND     transaction_id<>l_txn_id;
            -- ST : Serial Support ---
    EXCEPTION
           WHEN no_data_found THEN
               null;
    END;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'After select on WIP_MOVE_TRANSACTIONS: '||
        'l_wmt_scrap_qty '||l_wmt_scrap_qty||
        '; l_wmt_pri_scrap_qty '||l_wmt_pri_scrap_qty||
        '; l_wmt_scrap_at_op_flag '||l_wmt_scrap_at_op_flag||
        '; l_wmt_pri_txn_qty '||l_wmt_pri_txn_qty||
        '; l_wmt_txn_qty '||l_wmt_txn_qty||
        '; l_wmt_scrap_acct_id '||l_wmt_scrap_acct_id,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;

    IF (x_undo_source_code IN ('move in oa page', 'move out oa page', 'jump oa page',
            'move to next op oa page'))
    THEN
        l_converted_scrap_qty := l_wmt_pri_scrap_qty;
    END IF;

IF (g_aps_wps_profile = 'Y') THEN
    BEGIN
    SELECT  nvl(WCO.recommended, 'N')
            INTO    l_recommended
            FROM    WSM_COPY_OPERATIONS WCO,
                    WIP_OPERATIONS WO
            WHERE   WO.wip_entity_id = l_wip_entity_id
            AND     WO.organization_id = p_org_id
            AND     WO.operation_seq_num = l_fm_op_seq_num
            AND     WCO.wip_entity_id = WO.wip_entity_id
            AND WCO.operation_sequence_id = WO.operation_sequence_id;
        EXCEPTION
    WHEN    no_data_found THEN
        l_recommended := 'N';
    END;
    END IF;
    -- Verify if the given p_from_op_seq/code/iop is same as the above retrieved l_to_op_seq/code/iop.
    x_err_buf := NULL;

    -- Bugfix 1587295: Added NVLs to the parameter variables
    /* bug 5349187: Use p_fm_op_seq_num_orig for finding out whether fm_op_se_num, fm_op_code,
                            fm_intraop_step_type needs to be defaulted. This is because p_fm_op_seq_num
                            might have been changed by the code at l_stmt_num := 420 for OSP enhancement.
        */
    --IF (( (nvl(p_fm_op_seq_num,-1) <> -1) AND
    --      (nvl(p_fm_op_seq_num,-1) <> l_to_op_seq_num) ) or
    IF (( (nvl(p_fm_op_seq_num_orig,-1) <> -1) AND   -- bug 5349187
          (nvl(p_fm_op_seq_num_orig,-1) <> l_to_op_seq_num) ) or  --bug 5349187
     --Bug# 2775819. Changed l_fm_op_code_temp to l_fm_op_code because for undo txn
         --the code never fetches values into l_fm_op_code_temp.
        ( (NVL(p_fm_op_code, l_fm_op_code) IS NOT NULL) AND -- Fix for bug #2081442
          (NVL(p_fm_op_code, l_fm_op_code) <> l_to_op_code) ) or -- Fix for bug #2081442
        ( (nvl(p_fm_intraop_step_type,-1) <> -1) AND
          (nvl(p_fm_intraop_step_type,-1) <> l_to_intraop_step) ) )
    THEN
         FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
         FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_op_seq_num/fm_op_code/fm_intraop_step_type');
         x_err_buf := FND_MESSAGE.GET;
    --ELSIF( (nvl(p_fm_op_seq_num,-1) = -1) AND
    ELSIF( (nvl(p_fm_op_seq_num_orig,-1) = -1) AND  --bug 5349187
           (NVL(p_fm_op_code, l_fm_op_code_temp) IS NULL) AND  -- Fix for bug #2081442
           (nvl(p_fm_intraop_step_type,-1) = -1)
     ) THEN

         FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
         FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_op_seq_num,fm_op_code,fm_intraop_step_type');
         x_err_buf := FND_MESSAGE.GET;
    END IF;

--move enh 115.135 added the l_to_intraop_step condn after perf check
    IF ((l_to_intraop_step <> g_scrap) AND ((nvl(l_scrap_qty, -1)<>nvl(l_wmt_scrap_qty, -1))
    OR (nvl(l_scrap_at_operation_flag, -1)<>nvl(l_wmt_scrap_at_op_flag, -1)))) THEN
        l_scrap_qty := l_wmt_scrap_qty;
        l_converted_scrap_qty := l_wmt_pri_scrap_qty;
        l_scrap_at_operation_flag := l_wmt_scrap_at_op_flag;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_quantity/scrap_at_operation_flag');
            x_err_buf := x_err_buf || FND_MESSAGE.GET;
        END IF;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'VALUES FETCHED FROM WMT TABLE '||
                    '  l_fm_op_seq_num='||l_fm_op_seq_num||
                    ', l_fm_op_code='||l_fm_op_code||
                    ', l_fm_dept_id='||l_fm_dept_id||
                    ', l_fm_intraop_step_type='||l_fm_intraop_step ||
                    ', l_to_op_seq_num='||l_to_op_seq_num||
                    ', l_to_op_code='||l_to_op_code||
                    ', l_to_intraop_step_type='|| l_to_intraop_step ||
                    ', l_to_dept_id='||l_to_dept_id||
                    ', error_msg ' || l_error_msg);
    end if;

    fnd_file.put_line(fnd_file.log, 'x_err_buf '||x_err_buf);
    IF (x_err_buf IS NOT NULL) THEN
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
--move enh added SCRAP_QUANTITY, SCRAP_QUANTITY
-- CZH.BUG2135538

        update wsm_lot_move_txn_interface
        set FM_OPERATION_SEQ_NUM = l_to_op_seq_num,
            FM_OPERATION_CODE = l_to_op_code,
            FM_INTRAOPERATION_STEP_TYPE = l_to_intraop_step,
            FM_DEPARTMENT_ID = l_to_dept_id,
            SCRAP_QUANTITY = l_wmt_scrap_qty,
            --ERROR = 'WARNING:'||x_err_buf                           -- CZH.BUG2135538
            error = l_error_msg                                       -- CZH.BUG2135538
        where header_id = p_header_id;

    l_converted_scrap_qty := l_wmt_pri_scrap_qty;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'In IF (x_err_buf IS NOT NULL) THEN '||
            ';l_converted_scrap_qty '||
            l_converted_scrap_qty,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
          );
        END IF;
l_stmt_num := 440;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

    END IF;

    -- Verify if the given p_to_op_seq/code/iop/dept_id is same as the above retrieved l_from_op_seq/code/iop/dept_id.

    -- Bugfix 1587295: Added NVLs to the parameter variables
    x_err_buf := NULL;
    IF (( (nvl(p_to_op_seq_num,-1) <> -1) AND
          (nvl(p_to_op_seq_num,-1) <> l_fm_op_seq_num) ) or
        ( (p_to_op_code IS NOT NULL) AND
          (p_to_op_code <> l_fm_op_code) ) or
        ( (nvl(p_to_intraop_step_type,-1) <> -1) AND
          (nvl(p_to_intraop_step_type,-1) <> l_fm_intraop_step) ) or
        ( (nvl(p_to_dept_id,-1) <> -1) AND
          (nvl(p_to_dept_id,-1) <> l_fm_dept_id) )
       ) THEN

         FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
         FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num/to_op_code/to_intraop_step_type/to_dept_id');
         x_err_buf := FND_MESSAGE.GET;

    ELSIF( (nvl(p_to_op_seq_num,-1) = -1) AND
           (p_to_op_code IS NULL) AND
           (nvl(p_to_intraop_step_type,-1) = -1) AND
           (nvl(p_to_dept_id,-1) = -1) ) THEN

         FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
         FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_op_seq_num,to_op_code,to_intraop_step_type,to_dept_id');
         x_err_buf := FND_MESSAGE.GET;

    END IF;

    IF (x_err_buf IS NOT NULL) THEN
        l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                      -- CZH.BUG2135538
        update wsm_lot_move_txn_interface
        set    TO_OPERATION_SEQ_NUM = l_fm_op_seq_num,
               TO_OPERATION_CODE = l_fm_op_code,
               TO_INTRAOPERATION_STEP_TYPE = l_fm_intraop_step,
               TO_DEPARTMENT_ID = l_fm_dept_id,
               --ERROR = 'WARNING:'||x_err_buf                           -- CZH.BUG2135538
               error = l_error_msg                                       -- CZH.BUG2135538
        where  header_id = p_header_id;

l_stmt_num := 445;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    END IF;

--BA: CZH:BUG2154720
l_stmt_num := 447;

    l_converted_txn_qty := inv_convert.inv_um_convert (item_id       => l_primary_item_id,
                                                       precision     => NULL,
                                                       from_quantity => p_txn_qty,
                                                       from_unit     => p_txn_uom,
                                                       to_unit       => l_primary_uom,
                                                       from_name     => NULL,
                                                       to_name       => NULL);


    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'after converting @447 l_converted_txn_qty='||l_converted_txn_qty);
    end if;

    -- ST : Serial Support ---
    -- Place the check for qty here...
    IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
       (
        -- ST : Demo issue : Commenting out : floor(p_txn_qty) <> p_txn_qty OR
        floor(l_converted_txn_qty) <> l_converted_txn_qty
       )
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;
    -- ST : Serial Support ---

    --move enh 115.135 modified the qty check after perf check
    --move enh 115.136 corrected the from_quantity
    if (l_debug = 'Y') then
    fnd_file.put_line(fnd_file.log, 'l_scrap_qty '||l_scrap_qty||' l_to_intraop_step '||l_to_intraop_step);
    end if;

    IF ((l_to_intraop_step = 5) AND (l_scrap_qty > 0)) THEN
        l_converted_scrap_qty := inv_convert.inv_um_convert (item_id       => l_primary_item_id,
                                                       precision     => NULL,
                                                       from_quantity => l_scrap_qty,
                                                       from_unit     => p_txn_uom,
                                                       to_unit       => l_primary_uom,
                                                       from_name     => NULL,
                                                       to_name       => NULL);
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'After inv_convert.inv_um_convert '||
            ';l_converted_scrap_qty '||
            l_converted_scrap_qty,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
          );
        END IF;
    if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'l_converted_scrap_qty='||l_converted_scrap_qty);
    end if;

    -- ST : Serial Support ---
    -- Place the check here for qty ...
    IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
       (
        -- ST : Demo issue : Commenting out : floor(l_scrap_qty) <> l_scrap_qty OR
        floor(l_converted_scrap_qty) <> l_converted_scrap_qty
       )
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;
    -- ST : Serial Support ---

    END IF;



--EA: CZH:BUG2154720

    --  Verify if the p_txn_qty is the same as the l_wo_qty_in_scrap, if undoing a scrap,
    --  ELSE check if it is the same as l_wo_qty. If not error out.
--move enh 115.135 this check not needed here after perf check
/*    IF ((l_to_intraop_step = 5) AND (nvl(l_converted_txn_qty, nvl(l_converted_scrap_qty, 0))
    <> l_wmt_pri_scrap_qty)) THEN
--   OR ((l_to_intraop_step <> 5) AND (nvl(l_converted_scrap_qty, 0)) <> nvl(l_wmt_scrap_qty, 0))) THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_SCRAP_QTY_INCORRECT');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):
 '||x_err_buf);

            return(x_return_code);
    END IF;
*/
--move enh changed the IF condition
--move enh
    IF ((l_to_intraop_step <> 5) AND (nvl(l_converted_txn_qty, 0) <> l_wo_qty)) THEN
            x_return_code := 1;
 /*  IF ((l_to_intraop_step <> 5) OR (NVL(l_converted_txn_qty,0) <> 0)) THEN
        --if (p_txn_qty <> l_wo_qty) then                -- CZH: BUG 2154720
        if (NVL(l_converted_txn_qty,0) <> l_wo_qty) then -- CZH: BUG 2154720*/
                 x_return_code := 1;

        --FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        --FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_quantity');
            FND_MESSAGE.SET_NAME('WSM', 'WSM_LOT_INVALID_CANDIDATE'); -- Fix for bug #2095253
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
    end if;
--    END IF;


l_stmt_num := 450;
    -- If we are undoing a scrap operation, then get the scrap account from WLMTI
    --if (l_fm_intraop_step = WIP_CONSTANTS.SCRAP) then
--move enh added the condition nvl(l_scrap_qty, 0) <> 0
    if ((l_to_intraop_step = WIP_CONSTANTS.SCRAP) OR (nvl(l_converted_scrap_qty, 0) <> 0)) then -- Changed to fix bug #2083671

        select nvl(scrap_account_id,-1)
        into   l_wlmti_scrap_acct_id
        from   wsm_lot_move_txn_interface
        where  header_id = p_header_id;
l_stmt_num := 455;

--abb H optional scrap acc begin
        l_est_scrap_acc := wsmputil.wsm_esa_enabled(l_wip_entity_id,
                                                    x_return_code,
                                                    x_err_buf);

        IF (x_return_code <> 0) THEN
            return(x_return_code);
        END IF;

        select job_type
        into   l_job_type
        from   wip_discrete_jobs
        where  wip_entity_id = l_wip_entity_id;

    if l_est_scrap_acc = 2 or l_job_type = 3 then
        if l_wmt_scrap_acct_id = -1 then
            l_wmt_scrap_acct_id := null;
        end if;
    end if;

--abb H optional scrap acc begin
    if (l_wlmti_scrap_acct_id = -1) then    -- Changed to fix bug #2083671

            FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account_id');
            x_err_buf := FND_MESSAGE.GET;
            l_error_msg := substr(l_error_msg||'WARNING: '||x_err_buf||'| ', 1, 2000);
                                                                          -- CZH.BUG2135538
            update wsm_lot_move_txn_interface
            set    scrap_account_id = l_wmt_scrap_acct_id,
                   --ERROR = 'WARNING:'||x_err_buf                        -- CZH.BUG2135538
                   error = l_error_msg                                    -- CZH.BUG2135538
            where  header_id = p_header_id;

l_stmt_num := 460;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
        --bug 5185751 modify line below since l_wmt_scrap_acct_id may be null
        --elsif (l_wmt_scrap_acct_id <> l_wlmti_scrap_acct_id) then
        elsif (nvl(l_wmt_scrap_acct_id, -1) <> l_wlmti_scrap_acct_id) then
            x_return_code := 1;

            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'scrap_account');
            x_err_buf := FND_MESSAGE.GET;

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);

            return(x_return_code);
        end if;

    end if;

l_stmt_num := 470;

--NSO Modification by abedajna addition begin
--move enh? first look at copy table
    UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET     FM_DEPARTMENT_CODE = (select department_code
                                  from   bom_departments
                                  where  department_id = l_to_dept_id)
    WHERE   WLMTI.header_id = p_header_id;

    --***VJ Added for Performance Upgrade***--
    IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_dept_id');  --bugfix 1587295: changed the token
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    ELSE
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_department_code');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    END IF;
    --***VJ End Additions***--

l_stmt_num := 475;
    UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET     TO_DEPARTMENT_CODE = (select department_code
                  from   bom_departments
                  where  department_id = l_fm_dept_id)
    WHERE    WLMTI.header_id = p_header_id;

    --***VJ Added for Performance Upgrade***--
    IF (SQL%ROWCOUNT = 0) OR (SQL%NOTFOUND) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_dept_id');  --bugfix 1587295: changed the token
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    ELSE
        FND_MESSAGE.SET_NAME('WSM', 'WSM_MODIFIED_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'to_department_code');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'):'||x_err_buf);
    END IF;
    --***VJ End Additions***--

--NSO Modification by abedajna addition end

l_stmt_num := 480;
    /* Call to make sure that the bwd move is ok if there are lot transactions */
--move enh 115.136 changed the l_fm_intraop_step to l_to_intraop_step

    IF (l_to_intraop_step = WIP_CONSTANTS.SCRAP) THEN
        IF (l_converted_txn_qty > 0) THEN
            l_bk_move_chk_qty := l_converted_txn_qty;
        ELSE
            l_bk_move_chk_qty := l_converted_scrap_qty;
        END IF;
    ELSE
        l_bk_move_chk_qty := NVL(l_converted_txn_qty,0);
    END IF;

    x_return_code := 0;
    x_err_buf := '';
--move enh replaced NVL(l_converted_txn_qty,0) with l_bk_move_chk_qty
    x_return_code := WSMPLBMI.validate_lot_txn_for_bk_move(p_org_id,
                                                           l_wip_entity_id,
--                                                           NVL(l_converted_txn_qty,0), -- CZH: BUG2154720
                                                            l_bk_move_chk_qty,
                                                           l_txn_type,
                                                           l_to_op_seq_num,
                                                           l_to_op_code,
                                                           l_to_intraop_step,
                                                           l_fm_op_seq_num,
                                                           l_fm_op_code,
                                                           l_fm_intraop_step,
                                                           l_wlmti_scrap_acct_id,
                                                           x_err_buf);

    if (x_return_code = 1) then
         return (x_return_code);
    end if;

l_stmt_num := 485;
END IF;  -- for Backward moves

-------------------------------------------------------------------------------------
----------------------------------END BACKWARD MOVES---------------------------------
-------------------------------------------------------------------------------------

    UPDATE WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET    acct_period_id = g_acct_period_id --***VJ Changed for Performance Upgrade***--
    WHERE  WLMTI.header_id = p_header_id;

l_stmt_num := 490;
    IF (SQL%ROWCOUNT = 0) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INFO_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'acct_period_id');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;


    --Bugfix  1765389. Moved the following validation to the beginning so that
    -- this validation is done for all txn types.

    -- Validate primary and transaction UOM


    --***VJ Changed for Performance Upgrade***--
    SELECT msi.primary_uom_code
    INTO   l_uom
    FROM   mtl_system_items msi
    WHERE  msi.inventory_item_id = l_primary_item_id
    AND    msi.organization_id = p_org_id;
    --***VJ End Changes***--
l_stmt_num := 495;

    IF l_uom <> p_primary_uom THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_PRI_UOM');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'fm_op_seq_num/fm_intraop_step_type');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;


l_stmt_num := 500;
    -- Validate UOM and quantity
    l_converted_txn_qty := inv_convert.inv_um_convert (item_id       => l_primary_item_id,
                                                       precision     => NULL,
                                                       from_quantity => p_txn_qty,
                                                       from_unit     => p_txn_uom,
                                                       to_unit       => l_primary_uom,
                                                       from_name     => NULL,
                                                       to_name       => NULL);
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, ' after converting l_converted_txn_qty='||l_converted_txn_qty);
    end if;

    -- ST : Serial Support ---
    -- Place the check here for qty also ...
    -- Why is qty derived in so many places..?
    IF l_serial_ctrl_code = 2 AND -- Pre-defined Serial controlled assembly...
       (-- ST : Demo issue : Commenting out : floor(p_txn_qty) <> p_txn_qty OR
        floor(l_converted_txn_qty) <> l_converted_txn_qty)
    THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_JOB_TXN_QTY');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);

    END IF;
    -- ST : Serial Support ---

l_stmt_num := 505;

--move enh
--bug 3615826 added the internal_scrap_txn_id column in WLMTI
    IF ((l_converted_txn_qty > 0) AND (l_converted_scrap_qty > 0)) THEN
        SELECT wip_transactions_s.nextval INTO l_scrap_txn_id from dual;
    END IF;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'B4 UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI'||
        ';l_converted_scrap_qty '||
        l_converted_scrap_qty,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;

    UPDATE  WSM_LOT_MOVE_TXN_INTERFACE WLMTI
    SET     primary_quantity = NVL(l_converted_txn_qty,0),
            primary_scrap_quantity = NVL(l_converted_scrap_qty,0),
            scrap_at_operation_flag = l_scrap_at_operation_flag,
            internal_scrap_txn_id = l_scrap_txn_id
    WHERE   WLMTI.header_id = p_header_id;

l_stmt_num := 510;
    IF (SQL%ROWCOUNT = 0) THEN
        x_return_code := 1;

        FND_MESSAGE.SET_NAME('WSM', 'WSM_UPDATE_INVALID');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'primary_quantity');
        x_err_buf := FND_MESSAGE.GET;

        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
    return(x_return_code);
    END IF;


-------------------------------------------------------------------------------------
---------------------------------MOVE AND COMPLETION---------------------------------
-------------------------------------------------------------------------------------

IF (l_txn_type IN (1, 2) ) THEN

    BEGIN
        SELECT operation_seq_num
        INTO   l_temp -- <> 0, if moving to the last op
        FROM   bom_operation_sequences
        WHERE  operation_seq_num = p_to_op_seq_num
        AND    operation_sequence_id = l_end_op_seq_id;
    EXCEPTION
    WHEN OTHERS THEN
        l_temp := 0;
    END;

    -- Bug# 1475494. For jumps, l_op_seq_id can be NULL, hence added nvl() to l_op_seq_id
    -- so that the flow goes into this IF condition and adds the new operation

    -- Bug# 1658301. Added the OR condition in the following IF clause
    -- so that the IF condition doesn't fail when a move/jump is done
    -- after jumping outside the routing.

    if (l_debug = 'Y') then
    fnd_file.put_line(fnd_file.log, ' l_wo_op_seq_id='  ||l_wo_op_seq_id
                      ||' l_op_seq_id='     ||l_op_seq_id
                      ||' l_wo_op_code='    ||l_wo_op_code
                      ||' l_op_code='       ||l_op_code
                                      || 'l_end_op_seq_num='||l_end_op_seq_num
                      ||' p_to_op_seq_num=' ||p_to_op_seq_num
                      ||' l_temp='          ||l_temp);
    end if;

--NSO modification by abedajna begin

    --** VJ: Start Deletions for removal of 9999 **--
-- BA: CZH.BUG2168828
--    IF ( l_temp <> 0 )  THEN
--l_stmt_num := 512;
--        WSMPOPRN.disable_operations (l_wip_entity_id,
--                                     p_org_id,
--                                     p_fm_op_seq_num,
--                                     x_return_code,
--                                     x_err_buf);
--
--        IF (x_return_code <> 0) THEN
--            FND_MESSAGE.SET_NAME('WSM', 'WSM_DISABLE_OPS_FAILED');
--            x_err_buf := FND_MESSAGE.GET;
--
--            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
--            return(x_return_code);
--        ELSE
--            if (l_debug = 'Y') then
--                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
--                                                ||'): Returned success from WSMPOPRN.disable_operations');
--            end if;
--        END IF;
-- EA: CZH.BUG2168828
    --** VJ: End Deletions for removal of 9999 **--

    --IF ( ( l_temp <> 0 ) OR
    IF ( (p_jump_flag = 'Y') OR
            ( (l_wo_op_seq_id is not null AND l_wo_op_seq_id <> nvl(l_op_seq_id,-1))
              OR
              (l_wo_op_seq_id is NULL AND l_wo_op_code <> nvl(l_op_code,-99))
            ) --NSO modification by abedajna end
          ) THEN
    --AND (l_temp = 0) THEN -- Fix for bug #1524416

        if (l_op_code is not NULL) then
            l_stmt_num := 515;
            SELECT  standard_operation_id
            INTO    l_std_operation_id
            FROM    bom_standard_operations
            WHERE   operation_code = l_op_code
            AND     organization_id = p_org_id;
        end if;

        l_stmt_num := 520;
--Added to fix bug #1496147
        SELECT unique max(operation_seq_num)
        INTO   l_max_op_seq
        FROM   wip_operations
        WHERE  WIP_ENTITY_ID = l_wip_entity_id;
    --***VJ: Start Deletion for removal of 9999 ***--
        -- AND    operation_seq_num NOT IN
        --     ( SELECT nvl(last_operation_seq_num, 9999)
        --       FROM   wsm_parameters
        --       WHERE  organization_id = p_org_id ) ;
    --***VJ: End Deletion for removal of 9999 ***--
--End additions  to fix bug #1496147

        l_stmt_num := 525;
-- NSO Modification by abedajna begin
-- Changed the signature of the procedure so that l_op_seq_id is passed with l_std_operation_id.
--move enh
        IF (l_scrap_at_operation_flag=2) THEN
            l_new_op_txn_qty := l_converted_txn_qty + nvl(l_converted_scrap_qty, 0);
        ELSE
            l_new_op_txn_qty := l_converted_txn_qty;
        END IF;

        WSMPOPRN.add_operation(l_txn_type,
                                1,
                                l_wip_entity_id,
                                p_org_id,
                                l_wo_op_seq_num,
                                --l_max_op_seq+l_op_seq_incr,
                                l_max_op_seq+g_prev_op_seq_incr,
                    --***VJ Changed for Performance Upgrade***--
                                l_std_operation_id,
                                l_op_seq_id,
                                x_return_code,
                                x_err_buf,
                                l_new_op_txn_qty,
                                l_recommended,
                                p_to_op_seq_num,
                                p_txn_date,
                                'N',
                                p_jump_flag);
--move enh end
        l_stmt_num := 530;
--NSO Modification by abedajna end

-- OSP FP I begin chages : added if condition 'if x_err_buf is null'

        IF (x_return_code <> 0) THEN
            if x_err_buf is null then
                FND_MESSAGE.SET_NAME('WSM', 'WSM_INS_TBL_FAILED');
                FND_MESSAGE.SET_TOKEN('TABLE', 'wip_operations');
                x_err_buf := FND_MESSAGE.GET;
            end if;

-- OSP FP I end changes

            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
        ELSE
            if (l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                        ||'): Returned success from WSMPOPRN.add_operation');
            end if;

        END IF;

       /* JUMP_ENH: Set the skip_flag to 1 if jump_from_queue is set to TRUE */
        l_stmt_num:=532;
        IF (l_jump_from_queue) THEN
            l_stmt_num:=533;
           update wip_operations
           set    skip_flag=l_yes,    -- Set skip_flag to Yes
                  disable_date =p_txn_date  -- Added this line for bug 5367603
           where  organization_id  = p_org_id
           and    wip_entity_id    = l_wip_entity_id
           and    operation_seq_num= p_fm_op_seq_num;
        END IF;

        if (l_debug = 'Y') then
           fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num||'): ');
        end if;

--abb H Non Std Jobs
        IF (g_aps_wps_profile='N') THEN
            select job_type
            into   l_job_type
            from   wip_discrete_jobs
            where  wip_entity_id = l_wip_entity_id;

            select  bom_reference_id,
                    bom_revision_date,
                    alternate_bom_designator
            into   l_bom_reference_id,
                   l_bom_revision_date,
                   l_alt_bom_desig
            from   wip_discrete_jobs
            where  organization_id = p_org_id
            and    wip_entity_id = l_wip_entity_id;

            if l_job_type = 3 then
                l_primary_item_id := l_bom_reference_id;
            end if;

            l_stmt_num := 535;

        -- BA: CZH.BUGFIX 2350705
        --     call WSMPWROT.POPULATE_WRO only if move/jump within routing
            if(l_op_seq_id IS NOT NULL) then
        -- EA: CZH.BUGFIX 2350705
--move enh changed p_txn_qty to l_new_op_txn_qty
                WSMPWROT.POPULATE_WRO (
                    p_first_flag            => 0, --l_first_flag,
                    p_wip_entity_id         => l_wip_entity_id,
                    p_organization_id       => p_org_id,
                    p_assembly_item_id      => l_primary_item_id,
                    p_bom_revision_date     => l_bom_revision_date,
                    p_alt_bom               => l_alt_bom_desig,
--                    p_quantity              => p_txn_qty, -- CZH: BUG2154720 we may need to change it to primary qty
                    p_quantity              => l_new_op_txn_qty,
                    p_operation_sequence_id => l_op_seq_id,
                    x_err_code              => x_return_code,
                    x_err_msg               => x_err_buf);

                l_stmt_num := 540;
                IF (x_return_code <> 0) THEN
                    -- use the error message returned from WSMPWROT.POPULATE_WRO

                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='
                                      ||l_stmt_num||') calling WSMPWROT.POPULATE_WRO: '||x_err_buf);
                    return(x_return_code);
                ELSE
                    if (l_debug = 'Y') then
                            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.custom_validation(stmt_num='||l_stmt_num
                                ||'): Returned success from WSMPWROT.POPULATE_WRO');
                    end if;
                END IF;
        -- BA: CZH.BUGFIX 2350705
            end if; -- if(l_op_seq_id IS NOT NULL)
        -- EA: CZH.BUGFIX 2350705
        END IF; --(g_aps_wps_profile='N')
    END IF;  -- ELSIF ( (p_jump_flag = 'Y')
END IF;

-------------------------------------------------------------------------------------
---------------------------------END MOVE AND COMPLETION-----------------------------
-------------------------------------------------------------------------------------
    IF ((g_aps_wps_profile='Y') AND (l_txn_type IN (3, 4))) THEN
        l_stmt_num := 550;

        UPDATE WSM_LOT_BASED_JOBS wlbj
        SET wlbj.on_rec_path = l_recommended
        WHERE wlbj.wip_entity_id = l_wip_entity_id
        AND wlbj.organization_id = p_org_id
        AND wlbj.on_rec_path <> l_recommended;
    END IF;

    x_return_code := 0;
    x_err_buf :=  NULL;
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,  'WSMPLBMI.custom_validation' ||': Returned Success');
    end if;

    return x_return_code;

EXCEPTION
    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'WSMPLBMI.custom_validation' ||'(stmt_num='||l_stmt_num||') : '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

        return x_return_code;
END custom_validation;


/*-------------------------------------------------------------+
| validate_lot_txn_for_bk_move:                                |
---------------------------------------------------------------*/

/* This function is called by the WSM lot move txn form as well as the
   interface custom validation routine for validating the backward moves
   w.r.t the lot transactions */


FUNCTION validate_lot_txn_for_bk_move( p_org_id         IN NUMBER,
                                       p_wip_entity_id      IN NUMBER,
                                       p_txn_qty        IN NUMBER,
                                       p_txn_type       IN NUMBER,
                                       p_from_op_seq_num    IN NUMBER,
                                       p_from_op_code       IN VARCHAR2,
                                       p_from_intraop_step_type IN NUMBER,
                                       p_to_op_seq_num      IN NUMBER,
                                       p_to_op_code         IN VARCHAR2,
                                       p_to_intraop_step_type   IN NUMBER,
                                       p_scrap_acct_id      IN NUMBER,
                                       x_err_buf            OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

    x_return_code               NUMBER := 0;
    l_stmt_num                  NUMBER := 0;
    l_first_rtg_seq_id          NUMBER := 0;
    l_current_rtg_seq_id        NUMBER := 0;
    l_first_pri_item_id         NUMBER := 0;
    l_current_pri_item_id       NUMBER := 0;
    l_orig_mv_txn_qty           NUMBER := 0;
    l_temp          NUMBER := 0;
    l_wmt_time          DATE   := NULL; -- ADD: BUG2804111 use txn time
    l_wlt_time          DATE   := NULL; -- ADD: BUG2804111 use txn time

BEGIN

    x_return_code := 0;
    x_err_buf := '';

    l_stmt_num := 10;
    -- Check if the transaction is a backward move, if not, error out

    IF (p_txn_type <> 4) THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_type');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.validate_lot_txn_for_bk_move(stmt_num='
                          ||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;


    l_stmt_num := 20;
    -- Get the routing seq id and primary item id from WDJ.

    select nvl(COMMON_ROUTING_SEQUENCE_ID, ROUTING_REFERENCE_ID),
           PRIMARY_ITEM_ID
    into   l_current_rtg_seq_id,
           l_current_pri_item_id
    from   wip_discrete_jobs
    where  organization_id = p_org_id
    and    wip_entity_id = p_wip_entity_id;


    l_stmt_num := 30;
    -- Check if there was a move between the two operations , if not, then error out

    BEGIN
    select distinct(wip_entity_id)
    into   l_temp
    from   wip_move_transactions
    where  organization_id = p_org_id
    and    wip_entity_id   = p_wip_entity_id
    and    FM_OPERATION_SEQ_NUM = p_to_op_seq_num
    and    nvl(FM_OPERATION_CODE, '&&!!@@') = nvl(p_to_op_code, '&&!!@@')
                        --NSO modification by abedajna
    and    FM_INTRAOPERATION_STEP_TYPE = p_to_intraop_step_type
    and    TO_OPERATION_SEQ_NUM = p_from_op_seq_num
    and    nvl(TO_OPERATION_CODE, '&&!!@@') = nvl(p_from_op_code, '&&!!@@')
                        --NSO modification by abedajna
    and    TO_INTRAOPERATION_STEP_TYPE = p_from_intraop_step_type;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
            x_return_code := 1;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'move');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.validate_lot_txn_for_bk_move(stmt_num='
                                            || l_stmt_num||'): '||x_err_buf);
            return(x_return_code);
    END;


    l_stmt_num := 40;
    -- BA: CZH.JUMPENH
    -- since the logic for UNDO is changed, this needed to be changed
    select PRIMARY_QUANTITY,        -- CZH: BUG2154720
           transaction_date         -- ADD: BUG2804111 use txn time
    into   l_orig_mv_txn_qty,
           l_wmt_time               -- ADD: BUG2804111 use txn time
    from   wip_move_transactions
    where  transaction_id  = ( select max(wmt1.transaction_id)
                               from   wip_move_transactions wmt1
                               where  wmt1.organization_id = p_org_id
                               and    wmt1.wip_entity_id = p_wip_entity_id
                               and    wmt1.wsm_undo_txn_id IS NULL
--move enh --FP bug 5178168 (base bug 5168406) changed the line below
                                --and wmt1.transaction_id = wmt1.batch_id);
                                and wmt1.transaction_id = nvl(wmt1.batch_id, wmt1.transaction_id));

    -- EA: CZH.JUMPENH

    -- Check if the original move qty is the same as the given txn qty. If not, error out

    IF (l_orig_mv_txn_qty <> p_txn_qty) THEN
        x_return_code := 1;
        --FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        --FND_MESSAGE.SET_TOKEN('FLD_NAME', 'transaction_quantity');
        FND_MESSAGE.SET_NAME('WSM', 'WSM_LOT_INVALID_CANDIDATE');   -- Fix for bug #2095253
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.validate_lot_txn_for_bk_move(stmt_num='
                                        ||l_stmt_num||'): '||x_err_buf);
        return(x_return_code);
    END IF;


    -- BD: BUG2804111 use txn time, hence the following code lines are removed.
    -- BD: BUG2804111 use txn time

    l_stmt_num := 90;

    -- BA: BUG2804111 use txn time
    -- check if WLT exists after this move transaction
    BEGIN
        select max(wsmt.transaction_date)
        into   l_wlt_time
        from   wsm_split_merge_transactions wsmt,
               wsm_sm_starting_jobs wssj
        where  wsmt.organization_id     = p_org_id
        and    wsmt.transaction_id      = wssj.transaction_id
        and    wssj.wip_entity_id       = p_wip_entity_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_wlt_time := NULL;
    END;

    if(l_wlt_time IS NOT NULL) then
        if(l_wlt_time > l_wmt_time) then
            x_return_code := 1;
        end if;
    end if;
    -- EA: BUG2804111 use txn time


    return(x_return_code);

EXCEPTION
     WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'WSMPLBMI.validate_lot_txn_for_bk_move' ||'(stmt_num='||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);
        return x_return_code;
END validate_lot_txn_for_bk_move;




/*-------------------------------------------------------------+
| set_undo_txn_id:
---------------------------------------------------------------*/


-- BA: CZH.JUMPENH, new undo logic
FUNCTION set_undo_txn_id( p_org_id                 IN NUMBER,
                          p_wip_entity_id          IN NUMBER,
                          p_undo_txn_id            IN NUMBER,
                          x_err_buf                OUT NOCOPY VARCHAR2
                         )
RETURN NUMBER IS
--    x_undone_txn_id number;
    x_undone_batch_id number;
    l_stmt_num      NUMBER;
    x_return_code   NUMBER;
-- Logging variables.....
    l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
    l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.set_undo_txn_id';
    l_param_tbl                             WSM_Log_PVT.param_tbl_type;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             number;
    l_msg_data                              varchar2(4000);
BEGIN
    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'Begin set_undo_txn_id '
        ||';p_org_id '
        ||p_org_id
        ||';p_wip_entity_id '
        ||p_wip_entity_id
        ||';p_undo_txn_id '
        ||p_undo_txn_id,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;
    x_return_code := 0;

    l_stmt_num := 10;
    -- find the transaction id that is just undone
    --move enh? use the condition from_op <= to OR use batch_id to identify the undone txns
    --FP bug 5178168 (base bug 5168406) changed the line below
    --select max(batch_id)
    select max(nvl(batch_id, transaction_id))
--    into   x_undone_txn_id
    into   x_undone_batch_id
    from   wip_move_transactions
    where  organization_id = p_org_id
    and    wip_entity_id   = p_wip_entity_id
    and    wsm_undo_txn_id IS NULL
    --FP bug 5178168 (base bug 5168406) changed the line below
    --and    batch_id  < p_undo_txn_id;
    and    nvl(batch_id, transaction_id)  < p_undo_txn_id;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.set_undo_txn_id(stmt_num=' || l_stmt_num || '): p_undo_txn_id ' ||p_undo_txn_id||' x_undone_batch_id '||x_undone_batch_id);
    end if;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'x_undone_batch_id '
        ||x_undone_batch_id,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;
    -- update transaction idi, so that
--move enh
    l_stmt_num := 20;
    update wip_move_transactions
    --FP bug 5178168 (base bug 5168406) changed the line below
    --set    wsm_undo_txn_id = decode(batch_id,
    set    wsm_undo_txn_id = decode(nvl(batch_id, transaction_id),
                                    p_undo_txn_id, x_undone_batch_id,
                                    p_undo_txn_id)
    where  organization_id = p_org_id
    and    wip_entity_id   = p_wip_entity_id
--    and    transaction_id  in (p_undo_txn_id, x_undone_txn_id);
    --FP bug 5178168 (base bug 5168406) changed the line below
    --and    batch_id  in (p_undo_txn_id, x_undone_batch_id);
    and    nvl(batch_id, transaction_id)  in (p_undo_txn_id, x_undone_batch_id);

/*    update wip_move_transactions
    set    wsm_undo_txn_id = x_undone_batch_id
    where  organization_id = p_org_id
    and    wip_entity_id   = p_wip_entity_id
    --    and    transaction_id  in (p_undo_txn_id, x_undone_txn_id);
    and    batch_id = p_undo_txn_id;

    update wip_move_transactions
    set    wsm_undo_txn_id = p_undo_txn_id
    where  organization_id = p_org_id
    and    wip_entity_id   = p_wip_entity_id
    --    and    transaction_id  in (p_undo_txn_id, x_undone_txn_id);
    and    batch_id = x_undone_batch_id;
*/
    return(x_return_code);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_SET_UNDO_TXN_ID_FAILED');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.set_undo_txn_id(stmt_num=' ||
                              l_stmt_num || '): ' ||x_err_buf);
        return(x_return_code);

    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'WSMPLBMI.set_undo_txn_id' ||'(stmt_num='||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);
        return x_return_code;

END set_undo_txn_id;

-- EA: CZH.JUMPENH

/* JUMP_ENH: Overloaded the following function so that the original
   set_undo_txn_id is called after resetting the skip_flag to 2  */
FUNCTION set_undo_txn_id( p_org_id                 IN NUMBER,
                          p_wip_entity_id          IN NUMBER,
                          p_undo_txn_id            IN NUMBER,
                          p_to_op_seq_num          IN NUMBER,
                          p_undo_jump_fromq    IN BOOLEAN,
                          x_err_buf                OUT NOCOPY VARCHAR2
                         )
RETURN NUMBER IS
    l_yes       NUMBER:=1;
    l_no        NUMBER:=2;
    l_stmt_num      NUMBER;
    x_return_code   NUMBER := 0;
BEGIN
    l_stmt_num := 30;
    if (p_undo_jump_fromq) then
        l_stmt_num := 40;
    update wip_operations
        set    skip_flag=l_no,
               disable_date = null   -- Added this line for bug 5367603
        where  organization_id  = p_org_id
        and    wip_entity_id    = p_wip_entity_id
        and    operation_seq_num=p_to_op_seq_num
    and    skip_flag=l_yes;
    end if;

    x_return_code:=set_undo_txn_id(p_org_id,
                       p_wip_entity_id,
                       p_undo_txn_id,
                       x_err_buf);

    return(x_return_code);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_code := 1;
        FND_MESSAGE.SET_NAME('WSM', 'WSM_SET_UNDO_TXN_ID_FAILED');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPLBMI.set_undo_txn_id(stmt_num=' ||
                              l_stmt_num || '): ' ||x_err_buf);
        return(x_return_code);

    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'WSMPLBMI.set_undo_txn_id' ||'(stmt_num='||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);
        return x_return_code;

END set_undo_txn_id;

/******************************
 *  Move Enhancements         *
 ******************************/
--move enh
PROCEDURE copy_WTIE_to_WIE(x_error_code     OUT NOCOPY NUMBER,
                        x_error_msg         OUT NOCOPY VARCHAR2,
                        p_header_id         IN  NUMBER,
                        p_transaction_id    IN  NUMBER,
                        p_error_message     IN  VARCHAR2)

IS
PRAGMA autonomous_transaction;
        l_stmt_num NUMBER;
        l_wmt_group_id NUMBER;
        l_transaction_id NUMBER;
BEGIN
        l_stmt_num := 10;
        fnd_file.put_line(fnd_file.log,'Inside copy_WTIE_to_WIE...');

        l_stmt_num := 40;
        INSERT INTO WSM_INTERFACE_ERRORS (
                HEADER_ID,
                TRANSACTION_ID,
                MESSAGE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_ID,
                PROGRAM_APPLICATION_ID,
                MESSAGE_TYPE    )
        VALUES  (p_header_id
                , p_transaction_id
                , p_error_message
                , SYSDATE
                , g_user_id
                , SYSDATE
                , g_user_id
                , g_login_id
                , g_request_id
                , g_program_id
                , g_program_application_id
                , 1);

        COMMIT;

EXCEPTION
WHEN OTHERS THEN
        x_error_code := SQLCODE;
        x_error_msg := substrb('WSMPLMTI.copy_WTIE_to_WIE' ||'(stmt_num='||l_stmt_num||') : '||sqlerrm, 1,4000);
         FND_FILE.PUT_LINE(FND_FILE.LOG, x_error_msg);

END copy_WTIE_to_WIE;

PROCEDURE update_txn_status(x_error_code OUT NOCOPY NUMBER
                , x_error_msg OUT NOCOPY VARCHAR2
                , p_group_id      IN  NUMBER
                , p_wmti_group_id      IN  NUMBER)
IS
    l_stmt_num NUMBER;
BEGIN
    l_stmt_num := 10;
--move enh this logic is based on the fact that if even a single txn in WMTI errors out
--WIP API will rollback all processing.
    UPDATE wsm_lot_move_txn_interface WLMTI
    SET    status = 4
    WHERE   WLMTI.internal_group_id=p_wmti_group_id
    AND     WLMTI.group_id=p_group_id;

EXCEPTION
WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_msg := substrb('WSMPLMTI.update_txn_status' ||'(stmt_num='||l_stmt_num||') : '||sqlerrm, 1,4000);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_error_msg);
END update_txn_status;


PROCEDURE error_handler(x_error_code OUT NOCOPY NUMBER,
            x_error_msg OUT NOCOPY VARCHAR2,
            p_header_id IN NUMBER,
            p_transaction_id IN NUMBER,
            p_error_msg IN VARCHAR2)
IS

    l_stmt_num NUMBER;
    l_transaction_id NUMBER;
BEGIN
    l_stmt_num := 10;
    fnd_file.put_line(fnd_file.log, 'Inside error_handler '||'p_error_msg='||p_error_msg||' p_header_id='||' p_txn_id='||p_transaction_id);
    WSMPUTIL.AUTONOMOUS_TXN(p_user=> g_user_id,
            p_login=> g_login_id,
            p_header_id => p_header_id,
            p_message      => p_error_msg,
            p_request_id   => g_request_id,
            p_program_id   => g_program_id,
            p_program_application_id => g_program_application_id,
            p_message_type => 1, --ERROR
            p_txn_id => p_transaction_id,
            x_err_code     => x_error_code,
            x_err_msg      => x_error_msg);

    if (x_error_code <> 0) then
        x_error_msg := 'WSMPLMTI.error_handler' ||'(stmt_num='||l_stmt_num||') : '||substrb(x_error_msg, 1,4000);
        fnd_file.put_line(fnd_file.log, x_error_msg);
        return;
    end if;

    l_stmt_num := 20;
    UPDATE wsm_lot_move_txn_interface
    SET    status = 3,
    ERROR = g_fnd_generic_err_msg
    WHERE  header_id = p_header_id;

    fnd_file.put_line(fnd_file.log, 'Errors populated in wsm_interface_errors table');
EXCEPTION
WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_msg := substrb('WSMPLMTI.error_handler' ||'(stmt_num='||l_stmt_num||') : '||sqlerrm, 1,4000);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_error_msg);
END error_handler;

Procedure update_int_grp_id(x_error_code OUT NOCOPY NUMBER,
            x_error_msg OUT NOCOPY VARCHAR2,
            p_header_id IN NUMBER,
            p_wmti_group_id IN NUMBER)
IS
BEGIN
    UPDATE wsm_lot_move_txn_interface
    SET    internal_group_id = p_wmti_group_id
    WHERE  header_id = p_header_id;
END;

Procedure MoveTransaction (retcode  OUT NOCOPY NUMBER,
            errbuf          OUT NOCOPY VARCHAR2,
            p_group_id      IN  NUMBER)
IS
    p_sec_uom_code_tbls                     t_sec_uom_code_tbls_type ;
    p_sec_move_out_qty_tbls                 t_sec_move_out_qty_tbls_type;
    p_jobop_scrap_serials_tbls              t_scrap_serials_tbls_type;
    p_jobop_bonus_serials_tbls              t_bonus_serials_tbls_type;
    p_scrap_codes_tbls                      t_scrap_codes_tbls_type;
    p_scrap_code_qty_tbls                   t_scrap_code_qty_tbls_type;
    p_bonus_codes_tbls                      t_bonus_codes_tbls_type;
    p_bonus_code_qty_tbls                   t_bonus_code_qty_tbls_type;
    p_jobop_resource_usages_tbls            t_jobop_res_usages_tbls_type;
    x_wip_move_api_sucess_msg               VARCHAR2(1);
BEGIN

    MoveTransaction(
      p_group_id                              => p_group_id,
      p_bonus_account_id                      => null,
      p_employee_id                           => null,
      p_operation_start_date                  => null,
      p_operation_completion_date             => null,
      p_expected_completion_date              => null,
      p_bonus_quantity                        => null,
      p_low_yield_trigger_limit               => null,
      p_source_code                           => null,
      p_mtl_txn_hdr_id                        => null,
      p_sec_uom_code_tbls                     => p_sec_uom_code_tbls,
      p_sec_move_out_qty_tbls                 => p_sec_move_out_qty_tbls,
      p_jobop_scrap_serials_tbls              => p_jobop_scrap_serials_tbls,
      p_jobop_bonus_serials_tbls              => p_jobop_bonus_serials_tbls,
      p_scrap_codes_tbls                      => p_scrap_codes_tbls,
      p_scrap_code_qty_tbls                   => p_scrap_code_qty_tbls,
      p_bonus_codes_tbls                      => p_bonus_codes_tbls,
      p_bonus_code_qty_tbls                   => p_bonus_code_qty_tbls,
      p_jobop_resource_usages_tbls            => p_jobop_resource_usages_tbls,
      x_wip_move_api_sucess_msg               => x_wip_move_api_sucess_msg,
      retcode                                 => retcode,
      errbuf                                  => errbuf
    );

END;

Procedure add_Resource_error_info(
    p_resource_id             IN NUMBER
  , p_resource_instance_id    IN NUMBER
  , p_resource_serial_number  IN VARCHAR2
  , p_organization_id         IN NUMBER
)
IS
  l_resource_code     VARCHAR2(10) := null;
  l_resource_instance VARCHAR2(4000) := null;
  l_stmt_num          NUMBER := 0;
BEGIN
  l_stmt_num := 110.192;
  SELECT  resource_code
  INTO    l_resource_code
  FROM    BOM_RESOURCES
  WHERE   resource_id     = p_resource_id
  AND     organization_id = p_organization_id;

  l_stmt_num := 110.193;
  IF (p_resource_instance_id IS NOT NULL) THEN
    select  decode(p_resource_serial_number,
              NULL, msik.concatenated_segments,
              msik.concatenated_segments||':'||p_resource_serial_number)
    into    l_resource_instance
    from    bom_resource_equipments bre, mtl_system_items_kfv msik
    where bre.inventory_item_id = msik.inventory_item_id
    and   bre.organization_id   = msik.organization_id
    and   bre.resource_id       = p_resource_id
    and   bre.instance_id       = p_resource_instance_id
    and   bre.organization_id   = p_organization_id;

    FND_MESSAGE.SET_NAME('WSM','WSM_MES_INS_ERR_INFO');
    FND_MESSAGE.SET_TOKEN('RESOURCE', l_resource_code);
    FND_MESSAGE.SET_TOKEN('INSTANCE', l_resource_instance);
  ELSE
    FND_MESSAGE.SET_NAME('WSM','WSM_MES_RES_ERR_INFO');
    FND_MESSAGE.SET_TOKEN('RESOURCE', l_resource_code);
  END IF;

  FND_MSG_PUB.add;
END add_Resource_error_info;

Function reason_code_err_info(
    p_reason_code_num             IN NUMBER
  , p_reason_code_type            IN NUMBER
)
RETURN VARCHAR2
IS
  x_reason_code   VARCHAR2(80);
BEGIN
  IF (p_reason_code_type = 1) THEN
    SELECT  ML.meaning
    INTO    x_reason_code
    FROM    MFG_LOOKUPS ML
    WHERE   ML.lookup_type = 'BOM_SCRAP_CODES'
    AND     ML.lookup_code = p_reason_code_num;
  ELSE
    SELECT  ML.meaning
    INTO    x_reason_code
    FROM    MFG_LOOKUPS ML
    WHERE   ML.lookup_type = 'BOM_BONUS_CODES'
    AND     ML.lookup_code = p_reason_code_num;
  END IF;

  return x_reason_code;
END reason_code_err_info;

Procedure MoveTransaction(
    p_group_id                              IN NUMBER,
    p_bonus_account_id                      IN NUMBER,
    p_employee_id                           IN NUMBER,
    p_operation_start_date                  IN DATE,
    p_operation_completion_date             IN DATE,
    p_expected_completion_date              IN DATE,
    p_bonus_quantity                        IN NUMBER,
    p_low_yield_trigger_limit               IN NUMBER,
    p_source_code                           IN wsm_lot_move_txn_interface.source_code%type,
    p_mtl_txn_hdr_id                        IN NUMBER,
    p_sec_uom_code_tbls                     IN t_sec_uom_code_tbls_type,
    p_sec_move_out_qty_tbls                 IN t_sec_move_out_qty_tbls_type,
    p_jobop_scrap_serials_tbls              IN t_scrap_serials_tbls_type,
    p_jobop_bonus_serials_tbls              IN t_bonus_serials_tbls_type,
    p_scrap_codes_tbls                      IN t_scrap_codes_tbls_type,
    p_scrap_code_qty_tbls                   IN t_scrap_code_qty_tbls_type,
    p_bonus_codes_tbls                      IN t_bonus_codes_tbls_type,
    p_bonus_code_qty_tbls                   IN t_bonus_code_qty_tbls_type,
    p_jobop_resource_usages_tbls            IN t_jobop_res_usages_tbls_type,
    x_wip_move_api_sucess_msg               OUT NOCOPY VARCHAR2,
    retcode                                 OUT NOCOPY NUMBER,
    errbuf                                  OUT NOCOPY VARCHAR2
)
IS

    l_count         NUMBER;
    l_done          NUMBER;
    l_header_id     NUMBER;
    l_organization_id   NUMBER;
    l_undo_txn_id       NUMBER;
    l_transaction_id    NUMBER;
    l_fm_op_seq_num     NUMBER;
    l_to_op_seq_num     NUMBER;
    l_transaction_type  NUMBER;
    l_max_op_seq        NUMBER;
    l_wip_entity_id     NUMBER;
    l_to_dept_id        NUMBER;
    l_txn_type      NUMBER;
    l_dup_flag      NUMBER;
    l_job_exists        NUMBER;
    l_error_code        NUMBER;
    l_wmti_group_id     NUMBER;
    l_total_txns        NUMBER :=0;
    l_charge_jump_from_queue    NUMBER := 1;
    l_transaction_uom   VARCHAR2(3);
    l_fm_operation_code VARCHAR2(4);
    l_to_operation_code VARCHAR2(4);
    l_jump_flag     VARCHAR2(1);
    l_wip_entity_name   VARCHAR2(240);
    l_primary_uom       VARCHAR2(3);
    l_transaction_date  DATE;
    l_error_msg     VARCHAR2(4000);
    l_subinventory      VARCHAR2(10);
    l_new_jobname       VARCHAR2(240);
    l_rowid         VARCHAR2(2000);
    l_rtg_revision_date VARCHAR2(30);
    l_transaction_quantity  NUMBER := 0;
    l_txn_qty       NUMBER;
    l_stmt_num      NUMBER := 0;
    l_err_flag      NUMBER := 0;
--bug 3347485
--    l_pre_org_id        NUMBER := 0;
    l_pre_org_id        NUMBER := -9999;
--end bug 3347485
    l_ac_ar_exists      NUMBER := 0;
    l_undo_exists       NUMBER := 0;
    l_first_time        NUMBER := 0;
    l_outer_loop        NUMBER := 1;
    l_inserted_wmti         NUMBER := 0;
    l_n_rows            NUMBER := 0;
    i           NUMBER := 0;
    l_scrap_at_operation_flag   NUMBER := 0;
    l_scrap_qty NUMBER := 0;
    l_scrap_txn_id      NUMBER := 0;
    x_scrap_move_txn_id NUMBER := 0;
    l_conc_status       BOOLEAN;
    l_wro_op_seq_num    NUMBER;
    l_batch_id      NUMBER;
    l_op_flag       NUMBER;
    l_end_op_seq_id     NUMBER;
    l_converted_scrap_qty   NUMBER := 0;
    l_fm_intraoperation_step_type  NUMBER;
    l_to_intraoperation_step_type  NUMBER;
    l_routing_seq_id    NUMBER;
    l_to_op_seq_id      NUMBER;
    l_fm_op_seq_id      NUMBER;
    l_wmti_err_txns NUMBER := 0;
    l_success       NUMBER := 0;
    x_returnStatus      VARCHAR2(1);
    x_return_code       NUMBER := 0;
    l_new_op_txn_qty    NUMBER;
    l_primary_quantity  NUMBER;

    CURSOR C_TXNS IS
        SELECT   rowid,
                header_id,
                transaction_id,
                transaction_quantity,
                transaction_date,
                transaction_uom,
                transaction_type,
                fm_operation_seq_num,
                fm_operation_code,
                fm_intraoperation_step_type,
                to_operation_seq_num,
                to_operation_code,
                to_intraoperation_step_type,
                to_department_id,
                primary_uom,
                wip_entity_id,
                wip_entity_name,
                organization_id,
                nvl(jump_flag, 'N'), --bug 5469479 added nvl
                scrap_at_operation_flag,
                scrap_quantity,
                serial_start_flag -- ST : Serial Support Project --
        FROM     wsm_lot_move_txn_interface
        WHERE    group_id = p_group_id
        AND  status = g_running -- WIP_CONSTANTS.RUNNING    --Added condition to fix bug #1815584
        ORDER BY transaction_date, organization_id, wip_entity_id, processing_order;

--move enh To be used when we switch to the new logging scheme
/*  l_current_runtime_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module := 'WSM.Plsql.WSMPLMTI.MoveTransactions';
    l_level_unexpected := FND_LOG.LEVEL_UNEXPECTED;
    l_level_error := FND_LOG.LEVEL_ERROR;
    l_level_exception := FND_LOG.LEVEL_EXCEPTION;
    l_level_event := FND_LOG.LEVEL_EVENT;
    l_level_procedure := FND_LOG.LEVEL_PROCEDURE;
    l_level_statement := FND_LOG.LEVEL_STATEMENT; */
    x_error_msg VARCHAR2(4000);
    x_err_code  NUMBER;
    x_error_code    NUMBER;
    e_proc_exception    EXCEPTION;
    my_exception    EXCEPTION;
    x_err_msg  VARCHAR2(4000);
    l_no_txns   NUMBER :=0;
    l_del_profile_value NUMBER;
    l_job_copy_flag NUMBER;

    -- ST : Serial Support Project ---
    type t_number is table of number index by binary_integer;

    l_header_id_tbl             t_number;
    l_primary_item_id           NUMBER;
    l_serial_ctrl_code          NUMBER;
    l_available_qty             NUMBER;
    l_current_job_op_seq_num    NUMBER;
    l_current_intraop_step      NUMBER;
    l_current_rtg_op_seq_num    NUMBER;
    l_old_scrap_transaction_id  NUMBER;
    l_old_move_transaction_id   NUMBER;
    l_user_serial_tracking      NUMBER;
    -- ST : Serial Support Project ---

--MES
    l_total_scrap_code_qty      NUMBER := 0;
    l_total_bonus_code_qty      NUMBER := 0;
    l_mtl_txn_profile           NUMBER;
    l_cpl_txn_id                NUMBER;
    l_return_status             VARCHAR2(1);
    l_max_acceptable_scrap_qty  NUMBER;
    l_put_job_on_hold           NUMBER;
    l_reason_id                 wsm_lot_move_txn_interface.reason_id%TYPE;
    l_transaction_reference     wsm_lot_move_txn_interface.reference%TYPE;
    l_job_to_op_seq_num         wsm_lot_move_txn_interface.to_operation_seq_num%TYPE;
    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;

    l_wltx_transactions_rec     WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE;
    l_wltx_starting_job_tbl     WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE;
    l_wltx_resulting_job_tbl    WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE;
    l_wltx_secondary_qty_tbl    WSM_WIP_LOT_TXN_PVT.WSM_JOB_SECONDARY_QTY_TBL_TYPE;
    l_WSM_SERIAL_NUM_TBL        WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL;
    l_wip_include_comp_yield    NUMBER;
    --Bug 5480482:Following variable declaration is commented.
    --l_wco_fm_op_network_start   WSM_COPY_OPERATIONS.network_start_end%TYPE;
    --l_wco_to_op_network_end     WSM_COPY_OPERATIONS.network_start_end%TYPE;
    --l_wo_min_op_seq_num         NUMBER;
    l_undone_txn_source_code    WIP_MOVE_TRANSACTIONS.source_code%type;
    l_mes_scrap_txn_id          NUMBER; --bug 5446252
--MES END

    l_temp_txn_type                  NUMBER; --bug 4380374
-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module            CONSTANT VARCHAR2(100)  := 'wsm.plsql.wsmplbmi.movetransaction.main';
l_param_tbl     WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
    IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
            p_module_name     => l_module ,
            p_msg_text          => 'Begin MoveTransactions Main',
            p_stmt_num          => l_stmt_num   ,
            p_msg_tokens        => l_msg_tokens   ,
            p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
            p_run_log_level     => l_log_level
            );
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

        l_param_tbl.delete;
        l_param_tbl(1).paramName := 'p_group_id';
        l_param_tbl(1).paramValue := p_group_id;
        l_param_tbl(2).paramName := 'p_bonus_account_id';
        l_param_tbl(2).paramValue := p_bonus_account_id;
        l_param_tbl(3).paramName := 'p_employee_id';
        l_param_tbl(3).paramValue := p_employee_id;
        l_param_tbl(4).paramName := 'p_operation_start_date';
        l_param_tbl(5).paramValue := p_operation_start_date;
        l_param_tbl(6).paramName := 'p_operation_completion_date';
        l_param_tbl(6).paramValue := p_operation_completion_date;
        l_param_tbl(7).paramName := 'p_expected_completion_date';
        l_param_tbl(7).paramValue := p_expected_completion_date;
        l_param_tbl(8).paramName := 'p_bonus_quantity';
        l_param_tbl(8).paramValue := p_bonus_quantity;
        l_param_tbl(9).paramName := 'p_low_yield_trigger_limit';
        l_param_tbl(9).paramValue := p_low_yield_trigger_limit;
        l_param_tbl(10).paramName := 'p_source_code';
        l_param_tbl(10).paramValue := p_source_code;
        l_param_tbl(11).paramName := 'p_mtl_txn_hdr_id';
        l_param_tbl(11).paramValue := p_mtl_txn_hdr_id;

        WSM_Log_PVT.logProcParams(p_module_name   => l_module   ,
                p_param_tbl     => l_param_tbl,
                p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE
        );
    END IF;


    l_stmt_num := 10;
--move enh? to be removed
    IF (l_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Inside Move Worker....');
        --dmfut11i
/*       fnd_global.apps_initialize(user_id => 1006484,
                                 resp_id => 22435,
                                 resp_appl_id => 410);
        fnd_file.put_line(fnd_file.log, 'session ID = ' || fnd_global.session_id);

        --dmfdv11i
        fnd_global.apps_initialize(user_id => 1005369,
                                     resp_id => 50511,
                                     resp_appl_id => 700);
fnd_file.put_line(fnd_file.log, 'session ID = ' || fnd_global.session_id);*/
    END IF;
--move enh 115.137 changed from WSMPCNST to WSMPUTIL
    IF WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y' THEN
        l_job_copy_flag := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE;
    END IF;

    if (l_job_copy_flag = 1) then
        g_aps_wps_profile := 'Y';
    else
        g_aps_wps_profile := 'N';
    end if;
    /*--------------------------------------------------------------
     | Set the status to Running and Commit
     +--------------------------------------------------------------*/
    IF (p_group_id >0 ) THEN
        l_count := 0;
        l_stmt_num := 20;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module,
                    p_msg_text          => 'B4 UPDATE  wsm_lot_move_txn_interface wlmti '||
                    ';g_user_id '||
                    g_user_id||
                    ';g_login_id '||
                    g_login_id,
                    p_stmt_num          => l_stmt_num,
                    p_msg_tokens        => l_msg_tokens,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                    p_run_log_level     => l_log_level
                  );
        END IF;
        UPDATE  wsm_lot_move_txn_interface wlmti
            /* LOTATTR: Changed the following so that transaction_id is
                updated ONLY if it wasn't populated by the user */
        SET transaction_id=nvl(transaction_id,wip_transactions_s.nextval),
               wlmti.error = NULL,
                       wlmti.status = WIP_CONSTANTS.RUNNING,
                       wlmti.last_update_date = SYSDATE,
               wlmti.last_updated_by = decode(nvl(g_user_id, -1),
                              -1, wlmti.last_updated_by,
                              g_user_id),
               wlmti.last_update_login = decode(nvl(g_login_id, -1),
                                -1, wlmti.last_update_login,
                                g_login_id),
               wlmti.request_id = g_request_id,
               wlmti.program_id = g_program_id,
               wlmti.program_application_id = g_program_application_id
        WHERE   group_id = p_group_id
        AND wlmti.status = WIP_CONSTANTS.PENDING
        AND wlmti.transaction_date <= SYSDATE+1;

        IF (SQL%ROWCOUNT = 0) THEN
            FND_MESSAGE.SET_NAME('WSM', 'WSM_UPDATE_INVALID');
            FND_MESSAGE.SET_TOKEN('FLD_NAME', 'STATUS');
            errbuf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, errbuf);
            l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', errbuf);
            return;
        ELSE
            IF (l_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'updated status to running');
            END IF;
--mes
            IF (nvl(p_source_code, 'interface') = 'interface') THEN
                COMMIT;
            END IF;
        END IF;
    ELSE
        FND_MESSAGE.SET_NAME('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'GROUP_ID');
        errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, errbuf);
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', errbuf);
        return;
    END IF;

    l_stmt_num := 30;

--move enh getting the generic message to be used in all errors and warnings
    FND_MESSAGE.SET_NAME('WSM', 'WSM_ERRORS_IN_WIE');
    g_fnd_generic_err_msg := FND_MESSAGE.GET;

--move enh
    LOOP   /* outer loop */
        IF (l_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'begin outer loop');
        END IF;

        l_ac_ar_exists  := 0;
        l_inserted_wmti := 0;
        l_undo_exists   := 0;    /* CZH.JUMPENH, new UNDO logic */
        l_first_time    := 1;

        OPEN C_TXNS;
        LOOP /* inner loop */
            <<inner_loop>>

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'begin inner loop');
            END IF;

            i := i+1;

                l_stmt_num := 40;

            l_header_id                    := -1;
            l_transaction_id               := -1;
            l_transaction_quantity         := -1;
            l_transaction_type             := -1;
            l_fm_op_seq_num                := -1;
            l_fm_intraoperation_step_type  := -1;
            l_to_op_seq_num                := -1;
            l_to_intraoperation_step_type  := -1;
            l_to_dept_id                   := -1;
            l_organization_id              := -1;
            l_scrap_qty         :=-1;
            l_scrap_at_operation_flag   :=-1;

            FETCH C_TXNS INTO
                l_rowid,
                l_header_id,
                l_transaction_id,
                l_transaction_quantity,
                l_transaction_date,
                l_transaction_uom,
                l_transaction_type,
                l_fm_op_seq_num,
                l_fm_operation_code,
                l_fm_intraoperation_step_type,
                l_to_op_seq_num,
                l_to_operation_code,
                l_to_intraoperation_step_type,
                l_to_dept_id,
                l_primary_uom,
                l_wip_entity_id,
                l_wip_entity_name,
                l_organization_id,
                l_jump_flag,
                l_scrap_qty,
                l_scrap_at_operation_flag,
                l_user_serial_tracking; -- ST : Serial Support Project --
--move enh 115.137 changed from WSMPCNST to WSMPUTIL
            IF WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y' THEN
                if (WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(l_organization_id) = 2) then
                    g_aps_wps_profile := 'N';
                else
                    g_aps_wps_profile := 'Y';
                end if;
            END IF;


            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'g_aps_wps_profile '||g_aps_wps_profile);
            END IF;

            IF (C_TXNS%NOTFOUND) THEN
        /* if no row left, break inner loop;  if first_time, break inner and outer loop */
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'NO rows this round');
                END IF;
--move enh
                IF (l_first_time=1) THEN
                    IF (g_mrp_debug='Y') THEN
                        fnd_file.put_line(fnd_file.log, 'NO more rows left, done!');
                    END IF;
                    GOTO outer_loop;
                    END IF;
                EXIT;
            END IF;

            IF (g_mrp_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'Transaction_id ='||l_transaction_id||' header_id = '||l_header_id);
            END IF;

            l_job_exists :=0;
            IF (l_first_time=1) THEN
                l_stmt_num := 60;

                SELECT  wip_transactions_s.nextval
                INTO    l_wmti_group_id
                FROM    dual;

            ELSE
                l_stmt_num := 70;
                BEGIN
                    SELECT 1
                        INTO   l_job_exists
                        FROM   wip_move_txn_interface
                        WHERE  group_id=l_wmti_group_id
                        AND    wip_entity_id=l_wip_entity_id
                        AND    process_status = g_running;
                    EXCEPTION
                        WHEN no_data_found THEN
                            null;
                        WHEN too_many_rows THEN
                            l_job_exists := 1;
                    END;
            END IF;

            IF (l_job_exists=1) THEN/* If a move txn exists in WMTI for this job, Skip the remaining */
                         /* processing for this job this time. This txn will be considered
                                 for processing next time when the cursor is re-opened
                     by the outer loop */
                IF (l_debug = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'Skipped this row since txn of the same job exists in WMTI');
                END IF;
                GOTO inner_loop;
            END IF;

            l_first_time :=0;

            IF (l_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'Calling custom_validation');
            END IF;

            SAVEPOINT validation;

            l_stmt_num := 80;
/************************************************
 * call custom_validation to validate the entry *
 ************************************************/

            x_error_code := WSMPLBMI.custom_validation(
                                                l_header_id,
                                               l_transaction_id,
                                               l_transaction_quantity,
                                               l_transaction_date,
                                               l_transaction_uom,
                                               l_primary_uom,
                                               l_transaction_type,
                                               l_fm_op_seq_num,
                                               l_fm_operation_code,
                                               l_fm_intraoperation_step_type,
                                               l_to_op_seq_num,
                                               l_to_operation_code,
                                               l_to_intraoperation_step_type,
                                               l_to_dept_id,
                                               l_wip_entity_name,
                                               l_organization_id,
                                               l_jump_flag,
                                               -- ST : Serial Support Project --
                                               l_serial_ctrl_code     ,
                                               l_available_qty              ,
                                               l_current_job_op_seq_num     ,
                                               l_current_intraop_step       ,
                                               l_current_rtg_op_seq_num     ,
                                               l_old_scrap_transaction_id   ,
                                               l_old_move_transaction_id    ,
                                               -- ST : Serial Support Project --
                                               x_error_msg,
                                               l_undone_txn_source_code
                                               );

            l_total_txns := l_total_txns+1;

            IF (x_error_code<> 0) THEN
                l_error_msg := x_error_msg;
                FND_FILE.PUT_LINE(FND_FILE.LOG, substrb('WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                    , p_transaction_id => l_transaction_id
                    , p_error_msg => l_error_msg
                    , x_error_code => x_err_code
                    , x_error_msg => x_err_msg);
                IF (x_err_code <> 0) THEN
                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module ,
                        p_msg_text          => 'error_handler returned error '||l_error_msg,
                        p_stmt_num          => l_stmt_num   ,
                        p_msg_tokens        => l_msg_tokens   ,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                        p_run_log_level     => l_log_level
                      );
                    END IF;
                    raise e_proc_exception;
                END IF;
--                  l_err_flag := 1; /*Added to fix bug #1815584*/
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'custom_validation returned failure. Rolled back to validation');
                END IF;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'custom_validation returned error '||l_error_msg,
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END IF;
                GOTO inner_loop;     /* go to get next entry */
            ELSE
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'custom_validation returned success');
                END IF;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'custom_validation returned success',
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END IF;
            END IF;

            IF (l_organization_id <> l_pre_org_id) THEN
                l_pre_org_id := l_organization_id;

        /* Move this SQL from OSP so that this parameter is fetched
           ONLY when the current txn's organization is different
           from the previous txn's organization. -- Pons */

                l_stmt_num := 90;

                SELECT charge_jump_from_queue
                INTO   l_charge_jump_from_queue
                FROM   wsm_parameters
                WHERE  organization_id = l_organization_id;
            END IF;

        /* OSP Enhancement Changes Begin
           Enter a warning into the wsm_interface_errors table
           if there is a Purchase Requistion or Purchase Order linked
           to an operation under certain conditions */
                l_stmt_num := 100;

            IF (( (l_fm_intraoperation_step_type = 1) AND
                 ( (l_jump_flag = 'Y') AND (l_charge_jump_from_queue = 2) ) OR
                 ( l_transaction_type = 4 ) )
                 AND  (wip_osp.PO_REQ_EXISTS(l_wip_entity_id,
                                        NULL,
                                        l_organization_id,
                                        l_fm_op_seq_num,
                                        5 ))) then
                fnd_message.set_name('WSM','WSM_OP_PURCHASE_REQ');
                l_error_msg := fnd_message.get;
--move enh? consider warnings
                error_handler(p_header_id => l_header_id
                                , p_transaction_id => l_transaction_id
                                , p_error_msg => l_error_msg
                                , x_error_code => x_err_code
                                , x_error_msg => x_err_msg);

                IF (x_err_code <> 0) THEN
                    RAISE e_proc_exception;
                END IF;
            END IF;
        /*  OSP Enchancement Changes End */


        /* LotAttr */
            l_stmt_num := 95;
            IF (g_mrp_debug='Y') THEN
                fnd_file.put_line(fnd_file.log,'p_wip_entity_id => ' || l_wip_entity_id   || 'p_org_id =>' || l_organization_id || ' p_intf_txn_id =>' || l_transaction_id);
               fnd_file.put_line(fnd_file.log, 'Before Calling WSM_LotAttr_PVT.create_update_lotattr');
            END IF;
            WSM_LotAttr_PVT.create_update_lotattr(
                                x_err_code => x_err_code,
                                x_err_msg  => x_error_msg,
                                p_wip_entity_id => l_wip_entity_id,
                                p_org_id => l_organization_id,
                                p_intf_txn_id => l_header_id, /*l_transaction_id, Bug 5372863. Should pass header id for lot attributes package to upd lot attributes.  */
                                p_intf_src_code => 'WSM');

            IF (x_err_code<> 0) THEN
                l_error_msg := x_error_msg;
                FND_FILE.PUT_LINE(FND_FILE.LOG, substrb('WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                    , p_transaction_id => l_transaction_id
                    , p_error_msg => l_error_msg
                    , x_error_code => x_err_code
                    , x_error_msg => x_error_msg);
                IF (x_err_code <> 0) THEN
                    raise e_proc_exception;
                END IF;
                GOTO inner_loop;     /* go to get next entry */
            END IF;
            IF (g_mrp_debug='Y') THEN
               fnd_file.put_line(fnd_file.log, 'No Error reported from WSM_LotAttr_PVT.create_update_lotattr');
            END IF;
        /* Fixed bug #1560345 */

            l_stmt_num := 110;
--move enh 115.135 removed extra wip_entity_id  after perf check
            SELECT   TRANSACTION_TYPE,
                    wip_entity_id,
                    transaction_quantity,
                    fm_operation_seq_num,
                    fm_intraoperation_step_type,
                    to_intraoperation_step_type,
                    organization_id,
                    nvl(primary_quantity, 0),
                    nvl(scrap_quantity, 0),
                    nvl(primary_scrap_quantity, 0),
                    scrap_at_operation_flag,
                    fm_operation_code,
                    reason_id,
                    transaction_date,
                    reference,
                    internal_scrap_txn_id,
                    to_operation_seq_num,
                    wip_entity_name
            INTO    l_transaction_type,
                    l_wip_entity_id,
                    l_txn_qty,
                    l_fm_op_seq_num,
                    l_fm_intraoperation_step_type,
                    l_to_intraoperation_step_type,
                    l_organization_id,
                    l_primary_quantity,
                    l_scrap_qty,
                    l_converted_scrap_qty,
                    l_scrap_at_operation_flag,
                    l_fm_operation_code,
                    l_reason_id,
                    l_transaction_date,
                    l_transaction_reference,
                    l_scrap_txn_id,
                    l_job_to_op_seq_num,
                    l_wip_entity_name
            FROM    wsm_lot_move_txn_interface
            WHERE   rowid=l_rowid;

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'to_op_seq_num '||l_to_op_seq_num||' l_to_intraoperation_step_type '||l_to_intraoperation_step_type||
                ' l_fm_op_seq_num '||l_fm_op_seq_num||
                ' l_transaction_type '||l_transaction_type||
                ' l_scrap_qty '||l_scrap_qty||
                ' l_converted_scrap_qty '||l_converted_scrap_qty||
                ' l_scrap_at_operation_flag '||l_scrap_at_operation_flag);
            END IF;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'SELECT from WLMTI after custom_validations '||
                ';l_transaction_type '||
                l_transaction_type||
                ';l_wip_entity_id '||
                l_wip_entity_id||
                ';l_txn_qty '||
                l_txn_qty||
                ';l_fm_op_seq_num '||
                l_fm_op_seq_num||
                ';l_fm_intraoperation_step_type '||
                l_fm_intraoperation_step_type||
                ';l_to_intraoperation_step_type '||
                l_to_intraoperation_step_type||
                ';l_organization_id '||
                l_organization_id||
                ';l_primary_quantity '||
                l_primary_quantity||
                ';l_scrap_qty '||
                l_scrap_qty||
                ';l_converted_scrap_qty '||
                l_converted_scrap_qty||
                ';l_scrap_at_operation_flag '||
                l_scrap_at_operation_flag||
                ';l_fm_operation_code '||
                l_fm_operation_code||
                ';l_reason_id '||
                l_reason_id||
                ';l_transaction_date '||
                l_transaction_date||
                ';l_transaction_reference '||
                l_transaction_reference||
                ';l_scrap_txn_id '||
                l_scrap_txn_id||
                ';l_job_to_op_seq_num '||
                l_job_to_op_seq_num,
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

--MES
           IF (nvl(p_source_code, 'interface') = 'move out oa page') THEN
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Begin MES Validations',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

            l_stmt_num := 110.101;
            l_total_scrap_code_qty := 0;
            l_stmt_num := 110.102;
            l_total_bonus_code_qty := 0;
            l_stmt_num := 110.103;
            l_put_job_on_hold       := 0;
            l_stmt_num := 110.104;
            --bug 5490644 perform this check only if the txn is move txn
            --bug 5185512 Changed '<=' to '<' below
            --IF ((l_primary_quantity/(l_converted_scrap_qty+l_primary_quantity)) <= nvl(p_low_yield_trigger_limit, -1)) THEN
            IF ((l_transaction_type = WIP_CONSTANTS.MOVE_TXN) AND ((l_primary_quantity/(l_converted_scrap_qty+l_primary_quantity)) < nvl(p_low_yield_trigger_limit, -1))) THEN
                l_stmt_num := 253.14;
                l_put_job_on_hold := 1;
/*************************No need to throw error************************************
                l_msg_tokens.delete;
                WSM_LOG_PVT.LogMessage(
                  p_module_name     => l_module,
                  p_msg_name        => 'WSM_MES_SCRAP_YIELD_LIMIT',
                  p_msg_appl_name   => 'WSM',
                  p_msg_text        => NULL,
                  p_stmt_num        => l_stmt_num,
                  p_msg_tokens      => l_msg_tokens,
                  p_wsm_warning     => 1,
                  p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                  p_run_log_level   => l_log_level
                );

                FND_MESSAGE.SET_NAME('WSM','WSM_MES_SCRAP_YIELD_LIMIT');
                FND_MSG_PUB.add;
*************************No need to throw error************************************/
            END IF;

            l_stmt_num := 110.3;
            IF ((p_scrap_codes_tbls IS NOT NULL) AND p_scrap_codes_tbls.exists(l_header_id)
            AND (p_scrap_codes_tbls(l_header_id).count > 0))
            THEN
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin Scrap code Validations',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;

                l_stmt_num := 110.4;
              FOR i in 1..p_scrap_codes_tbls(l_header_id).last LOOP
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          =>
                    '; i '||
                    i||
                    '; p_scrap_codes_tbls(l_header_id)(i) '||
                    p_scrap_codes_tbls(l_header_id)(i)||
                    '; Scrap code '||
                    reason_code_err_info(
                        p_reason_code_num             => to_number(p_scrap_codes_tbls(l_header_id)(i))
                      , p_reason_code_type            => 1
                    )||
                    '; Scrap code qty'||
                    p_scrap_code_qty_tbls(l_header_id)(i),
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END IF;
              l_stmt_num := 110.5;
                IF nvl(p_scrap_code_qty_tbls(l_header_id)(i), 0) < 0 THEN
                  l_msg_tokens.delete;
                  l_msg_tokens(0).TokenName := 'FIELD_NAME';
                  l_msg_tokens(0).TokenValue := reason_code_err_info(
                                                    p_reason_code_num             => to_number(p_scrap_codes_tbls(l_header_id)(i))
                                                  , p_reason_code_type            => 1
                                                );
                  WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_FIELD_NEGATIVE',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_FIELD_NEGATIVE');
                  FND_MESSAGE.SET_TOKEN('FIELD_NAME', l_msg_tokens(0).TokenValue);
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;

                ELSE

                  l_stmt_num := 110.6;
                  SELECT  max_acceptable_scrap_qty
                  INTO    l_max_acceptable_scrap_qty
                  FROM    BOM_STD_OP_SCRAP_CODES BSOSC, BOM_STANDARD_OPERATIONS BSO
                  WHERE   BSO.operation_code = l_fm_operation_code
                  AND     BSO.organization_id = l_organization_id
                  AND     BSOSC.standard_operation_id = BSO.standard_operation_id
                  AND     BSOSC.scrap_code = p_scrap_codes_tbls(l_header_id)(i);

                    l_stmt_num := 110.7;
                    --bug 5490644 perform this check only if the txn is move txn
                    IF ((l_transaction_type = WIP_CONSTANTS.MOVE_TXN) AND ((l_max_acceptable_scrap_qty IS NOT NULL) AND (nvl(p_scrap_code_qty_tbls(l_header_id)(i), 0) > l_max_acceptable_scrap_qty)))
                    THEN
                        l_stmt_num := 253.14;
                        l_put_job_on_hold := 1;
/*************************No need to throw error************************************
                        l_msg_tokens.delete;
                        l_msg_tokens(0).TokenName := 'FIELD_NAME';
                        l_msg_tokens(0).TokenValue := reason_code_err_info(
                                                          p_reason_code_num             => to_number(p_scrap_codes_tbls(l_header_id)(i))
                                                        , p_reason_code_type            => 1
                                                       );
                        WSM_LOG_PVT.LogMessage(
                          p_module_name     => l_module,
                          p_msg_name        => 'WSM_MES_SCRAP_CODE_MAX_QTY',
                          p_msg_appl_name   => 'WSM',
                          p_msg_text        => NULL,
                          p_stmt_num        => l_stmt_num,
                          p_msg_tokens      => l_msg_tokens,
                          p_wsm_warning     => 1,
                          p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                          p_run_log_level   => l_log_level
                        );

                        FND_MESSAGE.SET_NAME('WSM','WSM_MES_SCRAP_CODE_MAX_QTY');
                        FND_MESSAGE.SET_TOKEN('FIELD_NAME', l_msg_tokens(0).TokenValue);
                        FND_MSG_PUB.add;
*************************No need to throw error***********************************/
                    END IF;
                    l_total_scrap_code_qty := l_total_scrap_code_qty + nvl(p_scrap_code_qty_tbls(l_header_id)(i), 0);

                END IF;
              END LOOP;

              IF (nvl(l_total_scrap_code_qty, 0) <> nvl(l_scrap_qty, 0)) THEN
                l_stmt_num := 110.801;
                l_msg_tokens.delete;
                WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_SCRAPCODEQTY_MISMATCH',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                );
                FND_MESSAGE.SET_NAME('WSM','WSM_MES_SCRAPCODEQTY_MISMATCH');
                FND_MSG_PUB.add;
                ROLLBACK TO validation;
                RAISE FND_API.G_EXC_ERROR;

              END IF;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Validated scrap codes successfully',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;
            END IF;

            l_stmt_num := 110.9;

            IF ((p_bonus_codes_tbls IS NOT NULL) AND (p_bonus_codes_tbls.exists(l_header_id))
            AND (p_bonus_codes_tbls(l_header_id).count > 0)) THEN
                l_stmt_num := 110.10;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin Bonus code Validations',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;

              FOR i in p_bonus_codes_tbls(l_header_id).first..p_bonus_codes_tbls(l_header_id).last LOOP
                l_stmt_num := 110.11;

                IF nvl(p_bonus_code_qty_tbls(l_header_id)(i), 0) < 0 THEN
                  l_stmt_num := 110.1101;
                  l_msg_tokens.delete;
                  l_msg_tokens(0).TokenName := 'FIELD_NAME';
                  l_msg_tokens(0).TokenValue := reason_code_err_info(
                                                    p_reason_code_num             => to_number(p_bonus_codes_tbls(l_header_id)(i))
                                                  , p_reason_code_type            => 2
                                                 );
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_FIELD_NEGATIVE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_FIELD_NEGATIVE');
                  FND_MESSAGE.SET_TOKEN('FIELD_NAME', l_msg_tokens(0).TokenValue);
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;

                ELSE
                l_stmt_num := 110.1102;

                  l_total_bonus_code_qty := l_total_bonus_code_qty + nvl(p_bonus_code_qty_tbls(l_header_id)(i), 0);
                END IF;
              END LOOP;

                l_stmt_num := 110.12;

              IF (nvl(l_total_bonus_code_qty, 0) <> nvl(p_bonus_quantity, 0)) THEN
                l_stmt_num := 110.121;
                l_msg_tokens.delete;
                WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_BONUSCODEQTY_MISMATCH',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                );
                FND_MESSAGE.SET_NAME('WSM','WSM_MES_BONUSCODEQTY_MISMATCH');
                FND_MSG_PUB.add;
                ROLLBACK TO validation;
                RAISE FND_API.G_EXC_ERROR;

              END IF;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Validated bonus codes successfully',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;
            END IF;


            l_stmt_num := 110.13;


            IF ((p_jobop_scrap_serials_tbls IS NOT NULL) AND (p_jobop_scrap_serials_tbls.exists(l_header_id))
            AND (p_jobop_scrap_serials_tbls(l_header_id).count > 0))
            THEN
            l_stmt_num := 110.131;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin Scrap Serials Validations',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
                FOR i in p_jobop_scrap_serials_tbls(l_header_id).first..p_jobop_scrap_serials_tbls(l_header_id).last LOOP
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text        => 'p_jobop_scrap_serials_tbls '
                    ||';i '
                    ||i
                    ||';serial '
                    ||p_jobop_scrap_serials_tbls(l_header_id)(i).Serial_Number,
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END LOOP;
              END IF;

              IF (nvl(l_scrap_qty, 0) <> (nvl(p_jobop_scrap_serials_tbls(l_header_id).last, 0))) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_SCRAPSERIAL_QTY',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                );
                FND_MESSAGE.SET_NAME('WSM','WSM_MES_SCRAPSERIAL_QTY');
                FND_MSG_PUB.add;
                ROLLBACK TO validation;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module,
                  p_msg_text          => 'Validated scrap serials successfully',
                  p_stmt_num          => l_stmt_num,
                  p_msg_tokens        => l_msg_tokens,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                  p_run_log_level     => l_log_level
                );
              END IF;
            END IF;

            l_stmt_num := 110.14;

            IF ((p_jobop_bonus_serials_tbls IS NOT NULL) AND p_jobop_bonus_serials_tbls.exists(l_header_id)
            AND (p_jobop_bonus_serials_tbls(l_header_id).count > 0)
            AND (nvl(p_bonus_quantity, 0) <> (nvl(p_jobop_bonus_serials_tbls(l_header_id).last, 0))))
            THEN
            l_stmt_num := 110.141;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin Bonus Serials Validations',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
                FOR i in p_jobop_bonus_serials_tbls(l_header_id).first..p_jobop_bonus_serials_tbls(l_header_id).last LOOP
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text        => 'p_jobop_bonus_serials_tbls '
                    ||';i '
                    ||i
                    ||';serial '
                    ||p_jobop_bonus_serials_tbls(l_header_id)(i).Serial_Number,
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END LOOP;
              END IF;

              l_msg_tokens.delete;
              WSM_log_PVT.LogMessage(
                  p_module_name     => l_module,
                  p_msg_name        => 'WSM_MES_BONUSSERIAL_QTY',
                  p_msg_appl_name   => 'WSM',
                  p_msg_text        => NULL,
                  p_stmt_num        => l_stmt_num,
                  p_msg_tokens      => l_msg_tokens,
                  p_wsm_warning     => NULL,
                  p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                  p_run_log_level   => l_log_level
              );
              FND_MESSAGE.SET_NAME('WSM','WSM_MES_BONUSSERIAL_QTY');
              FND_MSG_PUB.add;
              ROLLBACK TO validation;
              RAISE FND_API.G_EXC_ERROR;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module,
                  p_msg_text          => 'Validated bonus serials successfully',
                  p_stmt_num          => l_stmt_num,
                  p_msg_tokens        => l_msg_tokens,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                  p_run_log_level     => l_log_level
                );
              END IF;
            END IF;

            l_stmt_num := 110.15;

            IF (p_jobop_resource_usages_tbls IS NOT NULL) AND p_jobop_resource_usages_tbls.exists(l_header_id)
            AND (p_jobop_resource_usages_tbls(l_header_id).count > 0)THEN

                l_stmt_num := 110.16;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin Resource Validations',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;
              FOR i in 1..p_jobop_resource_usages_tbls(l_header_id).last LOOP
                l_stmt_num := 110.17;
--removed check on null start, comletion dates in
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'Resource info '||
            ';i '||
            i||
            ';resource_seq_num '||
            p_jobop_resource_usages_tbls(l_header_id)(i).resource_seq_num||
            ';resource_id '||
            p_jobop_resource_usages_tbls(l_header_id)(i).resource_id||
            ';instance_id '||
            p_jobop_resource_usages_tbls(l_header_id)(i).instance_id||
            ';serial_number '||
            p_jobop_resource_usages_tbls(l_header_id)(i).serial_number||
            ';l_organization_id '||
            l_organization_id,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
              );
            END IF;
                l_stmt_num := 110.19;

                IF (p_jobop_resource_usages_tbls(l_header_id)(i).start_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).start_date > sysdate) THEN
                  l_stmt_num := 110.191;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_START>CURRENTDATE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_START>CURRENTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;

                END IF;

                l_stmt_num := 110.20;

                IF (p_jobop_resource_usages_tbls(l_header_id)(i).start_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).end_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).end_date <
                p_jobop_resource_usages_tbls(l_header_id)(i).start_date)
                THEN
                  l_stmt_num := 110.201;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_RESCOMPL<RESSTARTDATE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_RESCOMPL<RESSTARTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_stmt_num := 110.21;
/*****************This is needed only for multiple resource usage dates*******/
                FOR j in 1..p_jobop_resource_usages_tbls(l_header_id).last LOOP

                    l_stmt_num := 110.22;
                    DECLARE
                      l_i_start DATE := p_jobop_resource_usages_tbls(l_header_id)(i).start_date;
                      l_i_end   DATE := p_jobop_resource_usages_tbls(l_header_id)(i).end_date;
                      l_j_start DATE := p_jobop_resource_usages_tbls(l_header_id)(j).start_date;
                      l_j_end   DATE := p_jobop_resource_usages_tbls(l_header_id)(j).end_date;
                    BEGIN
                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'B4 move out overlap dates check '||
                        ';i '||
                        i||
                        ';l_i_start '||
                        to_char(l_i_start, 'DD-MON-YYYY HH24:MI:SS')||
                        ';l_i_end '||
                        to_char(l_i_end, 'DD-MON-YYYY HH24:MI:SS')||
                        ';resource_seq_num '||
                        p_jobop_resource_usages_tbls(l_header_id)(i).resource_seq_num||
                        ';instance_id '||
                        p_jobop_resource_usages_tbls(l_header_id)(i).instance_id||
                        ';serial_number '||
                        p_jobop_resource_usages_tbls(l_header_id)(i).serial_number||
                        ';j '||
                        j||
                        ';l_j_start '||
                        to_char(l_j_start, 'DD-MON-YYYY HH24:MI:SS')||
                        ';l_j_end '||
                        to_char(l_j_end, 'DD-MON-YYYY HH24:MI:SS')||
                        ';resource_seq_num '||
                        p_jobop_resource_usages_tbls(l_header_id)(j).resource_seq_num||
                        ';instance_id '||
                        p_jobop_resource_usages_tbls(l_header_id)(j).instance_id||
                        ';serial_number '||
                        p_jobop_resource_usages_tbls(l_header_id)(j).serial_number,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                    END IF;
                    IF (i <> j)
                    AND (l_i_start IS NOT NULL)
                    AND (l_j_start IS NOT NULL)
                    AND (l_i_end IS NOT NULL)
                    AND (l_j_end IS NOT NULL)
                    AND (p_jobop_resource_usages_tbls(l_header_id)(i).resource_seq_num =
                        p_jobop_resource_usages_tbls(l_header_id)(j).resource_seq_num)
                    AND (p_jobop_resource_usages_tbls(l_header_id)(i).instance_id =
                        p_jobop_resource_usages_tbls(l_header_id)(j).instance_id)
                    AND (p_jobop_resource_usages_tbls(l_header_id)(i).serial_number =
                        p_jobop_resource_usages_tbls(l_header_id)(j).serial_number)
                    AND (
                        ((l_i_start >= l_j_start) AND (l_i_start <= l_j_end))
                        OR
                        ((l_i_start <= l_j_start) AND (l_j_start <= l_i_end))
                        OR
                        ((l_i_start <= l_j_start) AND (l_j_end <= l_i_end))
                        OR
                        ((l_i_start >= l_j_start) AND (l_j_end >= l_i_end))
                        )
                    THEN
                      l_stmt_num := 110.221;
                      l_msg_tokens.delete;
                      WSM_log_PVT.LogMessage(
                          p_module_name     => l_module,
                          p_msg_name        => 'WSM_MES_OVERLAP_RES_DATES',
                          p_msg_appl_name   => 'WSM',
                          p_msg_text        => NULL,
                          p_stmt_num        => l_stmt_num,
                          p_msg_tokens      => l_msg_tokens,
                          p_wsm_warning     => NULL,
                          p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                          p_run_log_level   => l_log_level
                      );
                      add_Resource_error_info(
                          p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                        , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                        , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                        , p_organization_id         => l_organization_id
                      );
                      FND_MESSAGE.SET_NAME('WSM','WSM_MES_OVERLAP_RES_DATES');
                      FND_MSG_PUB.add;
                      ROLLBACK TO validation;
                      RAISE FND_API.G_EXC_ERROR;

                    END IF;
                    END;
                  END LOOP;
/***************************************/
                l_stmt_num := 110.23;

                IF (p_operation_start_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).start_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).start_date < p_operation_start_date) THEN
                  l_stmt_num := 110.231;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_START>RESSTARTDATE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_START>RESSTARTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;

                END IF;

                l_stmt_num := 110.24;

                IF (p_operation_completion_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).end_date IS NOT NULL)
                AND (p_jobop_resource_usages_tbls(l_header_id)(i).end_date > p_operation_completion_date) THEN
                  l_stmt_num := 110.241;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_COMPL<RESCOMPLDATE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_COMPL<RESCOMPLDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

              END LOOP;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module,
                  p_msg_text          => 'Validated resource usage successfully',
                  p_stmt_num          => l_stmt_num,
                  p_msg_tokens        => l_msg_tokens,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                  p_run_log_level     => l_log_level
                );
              END IF;
            END IF;

            l_stmt_num := 110.25;

            IF (p_operation_start_date IS NOT NULL) AND (p_operation_completion_date IS NOT NULL)
            AND (p_operation_start_date > p_operation_completion_date)
            THEN
              l_stmt_num := 110.251;
              l_msg_tokens.delete;
              WSM_log_PVT.LogMessage(
                  p_module_name     => l_module,
                  p_msg_name        => 'WSM_MES_COMPL<STARTDATE',
                  p_msg_appl_name   => 'WSM',
                  p_msg_text        => NULL,
                  p_stmt_num        => l_stmt_num,
                  p_msg_tokens      => l_msg_tokens,
                  p_wsm_warning     => NULL,
                  p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                  p_run_log_level   => l_log_level
              );
              FND_MESSAGE.SET_NAME('WSM','WSM_MES_COMPL<STARTDATE');
              FND_MSG_PUB.add;
              ROLLBACK TO validation;
              RAISE FND_API.G_EXC_ERROR;

            END IF;
            l_stmt_num := 110.252;
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'End MES Move Out Validations',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;
          ELSIF (nvl(p_source_code, 'interface') = 'move in oa page') THEN
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Begin MES Move In Validations '||
                'p_jobop_resource_usages_tbls(l_header_id).count '||
                p_jobop_resource_usages_tbls(l_header_id).count,
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

            IF (p_jobop_resource_usages_tbls IS NOT NULL) AND p_jobop_resource_usages_tbls.exists(l_header_id)
            AND (p_jobop_resource_usages_tbls(l_header_id).count > 0)THEN
              l_stmt_num := 110.19;
              --bug 5435687 corrected the variable j to i
              --FOR j in 1..p_jobop_resource_usages_tbls(l_header_id).last LOOP
              FOR i in 1..p_jobop_resource_usages_tbls(l_header_id).last LOOP
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'Begin MES Move In Validations '||
                    'i '||
                    i||
                    ' p_jobop_resource_usages_tbls(l_header_id)(i).resource_id '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).resource_id||
                    ' p_jobop_resource_usages_tbls(l_header_id)(i).instance_id '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).instance_id||
                    ' p_jobop_resource_usages_tbls(l_header_id)(i).serial_number '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).serial_number||
                    ' p_jobop_resource_usages_tbls(l_header_id)(i).instance_id '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).instance_id||
                    ' l_organization_id '||
                    l_organization_id||
                    ';start_date '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).start_date||
                    ';projected_completion_date '||
                    p_jobop_resource_usages_tbls(l_header_id)(i).projected_completion_date,
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
                END IF;
                IF nvl(p_jobop_resource_usages_tbls(l_header_id)(i).start_date, sysdate) > sysdate THEN
                  IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                      p_module_name     => l_module ,
                      p_msg_text          => 'inside IF nvl(p_jobop_resource_usages_tbls(l_header_id)(i).start_date, sysdate) > sysdate ',
                      p_stmt_num          => l_stmt_num   ,
                      p_msg_tokens        => l_msg_tokens   ,
                      p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                      p_run_log_level     => l_log_level
                    );
                  END IF;
                  l_stmt_num := 110.191;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_START>CURRENTDATE',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                  );

                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_START>CURRENTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF nvl(p_jobop_resource_usages_tbls(l_header_id)(i).projected_completion_date, sysdate) <
                nvl(p_jobop_resource_usages_tbls(l_header_id)(i).start_date, sysdate) THEN
                  l_stmt_num := 110.201;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                      p_module_name     => l_module,
                      p_msg_name        => 'WSM_MES_RESPROJCOMPL<STARTDATE',
                      p_msg_appl_name   => 'WSM',
                      p_msg_text        => NULL,
                      p_stmt_num        => l_stmt_num,
                      p_msg_tokens      => l_msg_tokens,
                      p_wsm_warning     => NULL,
                      p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                      p_run_log_level   => l_log_level
                    );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_RESPROJCOMPL<STARTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (p_operation_start_date IS NOT NULL) AND (p_jobop_resource_usages_tbls(l_header_id)(i).start_date < p_operation_start_date) THEN
                  l_stmt_num := 110.231;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_START>RESSTARTDATE',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_START>RESSTARTDATE');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_stmt_num := 110.24;

                IF nvl(p_jobop_resource_usages_tbls(l_header_id)(i).projected_completion_date, sysdate) > p_expected_completion_date THEN
                  l_stmt_num := 110.241;
                  l_msg_tokens.delete;
                  WSM_log_PVT.LogMessage(
                    p_module_name     => l_module,
                    p_msg_name        => 'WSM_MES_PROJCOMPL<RESPROJCOMPL',
                    p_msg_appl_name   => 'WSM',
                    p_msg_text        => NULL,
                    p_stmt_num        => l_stmt_num,
                    p_msg_tokens      => l_msg_tokens,
                    p_wsm_warning     => NULL,
                    p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                    p_run_log_level   => l_log_level
                  );
                  add_Resource_error_info(
                      p_resource_id             => p_jobop_resource_usages_tbls(l_header_id)(i).resource_id
                    , p_resource_instance_id    => p_jobop_resource_usages_tbls(l_header_id)(i).instance_id
                    , p_resource_serial_number  => p_jobop_resource_usages_tbls(l_header_id)(i).serial_number
                    , p_organization_id         => l_organization_id
                  );
                  FND_MESSAGE.SET_NAME('WSM','WSM_MES_PROJCOMPL<RESPROJCOMPL');
                  FND_MSG_PUB.add;
                  ROLLBACK TO validation;
                  RAISE FND_API.G_EXC_ERROR;

                END IF;

              END LOOP;

              IF (p_operation_start_date IS NOT NULL) AND (p_expected_completion_date IS NOT NULL)
              AND (p_operation_start_date > p_expected_completion_date)
              THEN
                l_stmt_num := 110.251;
                l_msg_tokens.delete;
                WSM_log_PVT.LogMessage(
                  p_module_name     => l_module,
                  p_msg_name        => 'WSM_MES_PROJCOMPL<STARTDATE',
                  p_msg_appl_name   => 'WSM',
                  p_msg_text        => NULL,
                  p_stmt_num        => l_stmt_num,
                  p_msg_tokens      => l_msg_tokens,
                  p_wsm_warning     => NULL,
                  p_fnd_log_level   => G_LOG_LEVEL_ERROR,
                  p_run_log_level   => l_log_level
                );

                FND_MESSAGE.SET_NAME('WSM','WSM_MES_PROJCOMPL<STARTDATE');
                FND_MSG_PUB.add;
                ROLLBACK TO validation;
                RAISE FND_API.G_EXC_ERROR;

              END IF;

            END IF;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'End MES Move In Validations',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;
          END IF;
l_stmt_num := 110.253;

--MES END

           l_stmt_num := 120;

           -- ST : Serial Project --
           -- Obtain assembly item id
           SELECT nvl(common_routing_sequence_id, routing_reference_id),
                   TO_CHAR(nvl(routing_revision_date, SYSDATE), 'YYYY/MM/DD HH24:MI:SS'), /* CHG: BUG2380517 add SS */
                                      /* ADD: CZH.I_OED-1 */
                   primary_item_id
            INTO   l_routing_seq_id,
                   l_rtg_revision_date,                /* ADD: CZH.I_OED-1 */
                   l_primary_item_id
            FROM   wip_discrete_jobs
            WHERE  wip_entity_id = l_wip_entity_id;
            -- ST : Serial Project --

            l_stmt_num := 130.2;
            WSMPUTIL.find_routing_end(l_routing_seq_id,
                          /* BA: CZH.I_OED-1 */
                          TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS'),  /* CHG: BUG2380517 add SS */                                /* EA: CZH.I_OED-1 */
                          l_end_op_seq_id,
                          x_error_code,
                          x_error_msg);

            IF (x_error_code=0) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'find_routing_end returned success');
            ELSE
                l_error_msg := x_error_msg;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'WSMPLBMI.custom_validation' ||'(stmt_num='||l_stmt_num||') : '||substrb(l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                            , p_transaction_id => l_transaction_id
                            , p_error_msg => l_error_msg
                            , x_error_code => x_err_code
                            , x_error_msg => x_err_msg);
                IF (x_err_code <> 0) THEN
                    raise e_proc_exception;
                END IF;
--              l_err_flag := 1;       /*Added to fix bug #1815584*/
                GOTO inner_loop;     /* go to get next entry */
            END IF;

            /* BA: CZH.I_OED-2, should consider operation replacement */
            l_stmt_num := 140;
            l_end_op_seq_id := WSMPUTIL.replacement_op_seq_id(l_end_op_seq_id,
                            TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS') ); /* CHG: BUG2380517 add SS */
            /* EA: CZH.I_OED-2 */

            IF (l_transaction_type = 4) THEN
                l_undo_exists := 1;
            END IF;


            -- ST : Serial Support Project ---
            -- Place the call to the interface wrapper...
            IF l_serial_ctrl_code = 2 THEN
                   DECLARE
                        l_return_status     VARCHAR2(1);
                        l_error_msg     VARCHAR2(2000);
                        l_error_count     NUMBER;
                        l_serial_track_flag NUMBER;
                        l_serial_tbl    WSM_Serial_Support_Grp.wsm_serial_num_tbl;
                        --Bug 5208097: Start of changes
                        l_move_quantity NUMBER;
                        l_scrap_quantity NUMBER;
                        l_scrap_txn_id1  NUMBER;
                        --Bug 5208097:End of changes
                   BEGIN

                        -- Pass the serial numbers table only when the data exists..
                        IF p_jobop_scrap_serials_tbls.exists(l_header_id)
                        THEN
                                l_serial_tbl := p_jobop_scrap_serials_tbls(l_header_id);
                        END IF;

                       if l_to_intraoperation_step_type = 5 then
                           l_move_quantity := 0;
                           l_scrap_quantity := l_primary_quantity;
                           l_scrap_txn_id1 := l_transaction_id;
                       else
                           l_move_quantity := l_primary_quantity;
                           l_scrap_quantity := l_converted_scrap_qty;
                           l_scrap_txn_id1 := l_scrap_txn_id;
                       end if;

                        WSM_Serial_support_Pvt.Move_serial_intf_proc (  p_header_id              => l_header_id                  ,
                                                                        -- p_wsm_serial_nums_tbl => p_jobop_scrap_serials_tbls(l_header_id),
                                                                        p_wsm_serial_nums_tbl    => l_serial_tbl,
                                                                        p_move_txn_type          => l_transaction_type           ,
                                                                        p_wip_entity_id          => l_wip_entity_id              ,
                                                                        p_organization_id        => l_organization_id            ,
                                                                        p_inventory_item_id      => l_primary_item_id            ,
                                                                        --Bug 5208097: Start of changes
                                                                        --p_move_qty               => l_primary_quantity           ,
                                                                        --p_scrap_qty              => l_converted_scrap_qty        ,
                                                                        p_move_qty               => l_move_quantity,
                                                                        p_scrap_qty              => l_scrap_quantity,
                                                                        --Bug 5208097: End of changes
                                                                        p_available_qty          => l_available_qty              ,
                                                                        -- the following fields will be used for forward move/completion alone....
                                                                        p_curr_job_op_seq_num    => l_current_job_op_seq_num     ,
                                                                        p_curr_job_intraop_step  => l_current_intraop_step       ,
                                                                        p_from_rtg_op_seq_num    => l_current_rtg_op_seq_num     ,
                                                                        p_to_rtg_op_seq_num      => l_to_op_seq_num              ,
                                                                        p_to_intraoperation_step => l_to_intraoperation_step_type,
                                                                        ---------------------------------------------------------------------------
                                                                        p_user_serial_tracking   => l_user_serial_tracking       ,
                                                                        p_move_txn_id            => l_transaction_id             ,
                                                                        --Bug 5208097: End of changes
                                                                        --p_scrap_txn_id           => l_scrap_txn_id              ,
                                                                        p_scrap_txn_id           => l_scrap_txn_id1              ,
                                                                        --Bug 5208097: End of changes
                                                                        p_old_move_txn_id        => l_old_move_transaction_id    ,
                                                                        p_old_scrap_txn_id       => l_old_scrap_transaction_id   ,
                                                                        p_jump_flag              => l_jump_flag                  ,
                                                                        p_scrap_at_operation     => l_scrap_at_operation_flag    ,
                                                                        -- ST : Fix for bug 5140761 Addded the above parameter --
                                                                        x_serial_track_flag      => l_serial_track_flag          ,
                                                                        x_return_status          => l_return_status              ,
                                                                        x_error_msg              => l_error_msg                  ,
                                                                        x_error_count            => l_error_count
                                                                     );

                        if l_return_status = FND_API.G_RET_STS_SUCCESS then
                            IF (l_debug='Y') THEN
                                fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Move_serial_intf_proc returned Success');
                            END IF;
                        ELSE

                                IF (l_error_count = 1)  THEN
                                        fnd_file.put_line(fnd_file.log, l_error_msg);
                                ELSIF (l_error_count > 1)  THEN
                                        FOR i IN 1..l_error_count LOOP
                                                l_error_msg := fnd_msg_pub.get( p_msg_index => l_error_count - i + 1,
                                                                                p_encoded   => FND_API.G_FALSE
                                                                               );
                                                fnd_file.put_line(fnd_file.log, l_error_msg);
                                        END LOOP;
                                ELSE
                                        l_error_msg := 'WSM_Serial_support_PVT.LBJ_serial_intf_proc returned failure';
                                END IF;

                                IF (l_debug='Y') THEN
                                        fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Move_serial_intf_proc returned failure');
                                END IF;

                                ROLLBACK TO validation;
                                error_handler(p_header_id       => l_header_id            ,
                                              p_transaction_id  => l_transaction_id       ,
                                              p_error_msg       => l_error_msg            ,
                                              x_error_code      => x_err_code             ,
                                              x_error_msg       => x_err_msg);

                                IF (x_err_code <> 0) THEN
                                        raise e_proc_exception;
                                END IF;

                                GOTO inner_loop;     -- go to get next interface record...
                        END IF;
                   END;
              END IF;
              -- ST : Serial Support Project ---
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'B4 IF ((l_transaction_type=2) OR (l_transaction_type = 3))'||
                ';l_transaction_type '||
                l_transaction_type,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'B4 IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                ';l_transaction_type '||
                l_transaction_type,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'B4 IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                'l_scrap_qty '||l_scrap_qty||
                ' l_available_qty '||l_available_qty||
                ' l_primary_quantity '||l_primary_quantity,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;

            IF ((l_transaction_type=2) OR (l_transaction_type = 3)) THEN
                l_ac_ar_exists := 1;    /* Assy completion or Return exists */
                l_dup_flag := 0;      /* Initialize dup flag */

                DECLARE
                    l_subinventory      VARCHAR2(10);
                    l_new_name          VARCHAR2(240);
                    l_dup_name          VARCHAR2(240);
                    l_update_flag   BOOLEAN:=FALSE;
                BEGIN
                    l_stmt_num := 150;

                    SELECT completion_subinventory
                    INTO   l_subinventory
                    FROM   wip_discrete_jobs
                    WHERE  wip_entity_id = l_wip_entity_id;

                    /* Call  for Assy completion as well as Assy returns */
                    IF (l_debug = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, 'l_wip_entity_id '||l_wip_entity_id||
                                        ' l_subinventory '||l_subinventory||
                                        ' l_organization_id '||l_organization_id||
                                        ' l_transaction_type '||l_transaction_type||
                                        ' l_dup_name '||l_dup_name);
                    END IF;

                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'In IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                        'l_wip_entity_id '||l_wip_entity_id||
                        ' l_subinventory '||l_subinventory||
                        ' l_organization_id '||l_organization_id||
                        ' l_transaction_type '||l_transaction_type||
                        ' l_dup_name '||l_dup_name,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                    END IF;

                    l_stmt_num := 130.3;
                    l_new_name := WSMPOPRN.update_job_name(l_wip_entity_id,
                                           l_subinventory,
                                           l_organization_id,
                                           l_transaction_type,
                                           l_update_flag,
                                           l_dup_name,
                                           x_error_code,
                                           x_error_msg);

                    IF (l_debug = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, 'x_error_code '||x_error_code||
                        ' x_error_msg '||x_error_msg||
                        ' l_new_name '||l_new_name);
                    END IF;

                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'In IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                        ' x_error_msg '||x_error_msg||
                        ' l_new_name '||l_new_name,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                    END IF;

                    IF ((l_new_name IS NOT NULL) AND (l_new_name <> '-1')) THEN
                        UPDATE wsm_lot_move_txn_interface
                        SET    new_wip_entity_name=l_new_name
                        where  rowid=l_rowid;
                    ELSE
                        l_error_msg := x_error_msg;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||substrb(l_error_msg, 1,4000));
                        ROLLBACK TO validation;
                        error_handler(p_header_id => l_header_id
                                    , p_transaction_id => l_transaction_id
                                    , p_error_msg => l_error_msg
                                    , x_error_code => x_err_code
                                    , x_error_msg => x_err_msg);
                        IF (x_err_code <> 0) THEN
                            raise e_proc_exception;
                        END IF;
    --                  l_err_flag := 1;       /*Added to fix bug #1815584*/
                        GOTO inner_loop;     /* go to get next entry */
                    END IF;
                END;

                l_stmt_num := 205;
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'update_job_name returned success');
                END IF;
            END IF;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          =>
                'l_transaction_type '||l_transaction_type||
                ' l_converted_scrap_qty '||l_converted_scrap_qty||
                ' l_available_qty '||l_available_qty||
                ' l_primary_quantity '||l_primary_quantity,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;
            --bug 4380374
            IF (  (  (l_transaction_type = 1)
                     AND
                     (  (l_converted_scrap_qty = l_available_qty)
                        OR
                        ( (l_primary_quantity = l_available_qty)
                          AND
                          (l_to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
                        )
                     )
                  )
                  OR
                  (  (l_transaction_type = 4)
                     AND
                     (l_available_qty = 0)
                  )
                )
            THEN
                l_dup_flag := 0;      /* Initialize dup flag */

                DECLARE
                    l_subinventory      VARCHAR2(10);
                    l_new_name          VARCHAR2(240);
                    l_dup_name          VARCHAR2(240);
                    l_update_flag   BOOLEAN:=FALSE;
                BEGIN
                    l_stmt_num := 150;

                    SELECT completion_subinventory
                    INTO   l_subinventory
                    FROM   wip_discrete_jobs
                    WHERE  wip_entity_id = l_wip_entity_id;

                    /* Call  for Assy completion as well as Assy returns */
                    IF (l_debug = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, 'l_wip_entity_id '||l_wip_entity_id||
                                        ' l_subinventory '||l_subinventory||
                                        ' l_organization_id '||l_organization_id||
                                        ' l_transaction_type '||l_transaction_type||
                                        ' l_dup_name '||l_dup_name);
                    END IF;

                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'In IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                        'l_wip_entity_id '||l_wip_entity_id||
                        ' l_subinventory '||l_subinventory||
                        ' l_organization_id '||l_organization_id||
                        ' l_transaction_type '||l_transaction_type||
                        ' l_dup_name '||l_dup_name||
                        ' l_converted_scrap_qty '||l_converted_scrap_qty||
                        ' l_available_qty '||l_available_qty||
                        ' l_fm_intraoperation_step_type '||l_fm_intraoperation_step_type||
                        ' l_to_intraoperation_step_type '||l_to_intraoperation_step_type||
                        ' l_primary_quantity '||l_primary_quantity,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                    END IF;

                    l_stmt_num := 130.3;
                    IF (l_transaction_type = 1) THEN
                        l_temp_txn_type := 2;
                    ELSIF (l_transaction_type = 4) THEN
                        l_temp_txn_type := 3;
                    END IF;

                    l_new_name := WSMPOPRN.update_job_name(l_wip_entity_id,
                                       l_subinventory,
                                       l_organization_id,
                                       l_temp_txn_type,
                                       l_update_flag,
                                       l_dup_name,
                                       x_error_code,
                                       x_error_msg);

                    IF (l_debug = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, 'x_error_code '||x_error_code||
                        ' x_error_msg '||x_error_msg||
                        ' l_new_name '||l_new_name);
                    END IF;

                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'In IF ((l_transaction_type=2) OR (l_transaction_type = 3)) '||
                        ' x_error_msg '||x_error_msg||
                        ' l_new_name '||l_new_name,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                    END IF;

                    IF ((l_new_name IS NOT NULL) AND (l_new_name <> '-1')) THEN
                      UPDATE wip_entities
                      SET    wip_entity_name = l_new_name
                      WHERE  wip_entity_id = l_wip_entity_id;

                      UPDATE wsm_lot_move_txn_interface
                      SET    wip_entity_name=l_new_name
                      where  rowid=l_rowid;
                    ELSE
                      l_error_msg := x_error_msg;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||substrb(l_error_msg, 1,4000));
                      ROLLBACK TO validation;
                      error_handler(p_header_id => l_header_id
                                  , p_transaction_id => l_transaction_id
                                  , p_error_msg => l_error_msg
                                  , x_error_code => x_err_code
                                  , x_error_msg => x_err_msg);
                      IF (x_err_code <> 0) THEN
                          raise e_proc_exception;
                      END IF;
  --                  l_err_flag := 1;       /*Added to fix bug #1815584*/
                      GOTO inner_loop;     /* go to get next entry */
                    END IF;
                END;

                l_stmt_num := 205;
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'update_job_name returned success');
                END IF;
            END IF;
            --end bug 4380374

            l_fm_operation_code := null;
            l_to_operation_code := null;

            /* abb, NSO addition begin */
            /* BC: CZH.BUG2442776 if jumping outside routing, this should not be called */
            l_to_op_seq_id := -2;   /* init it to 2 */
            /* EC: CZH.BUG2442776*/

            IF (g_aps_wps_profile='N') THEN
                IF (l_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'l_to_op_seq_num '||l_to_op_seq_num||' l_routing_seq_id '
                    ||l_routing_seq_id||' l_rtg_revision_date '||l_rtg_revision_date);
                END IF;

                -- Bug 4480248   Added the condition ( AND l_to_op_seq_num is NOT NULL) in the IF statement below
                IF (((l_jump_flag <> 'Y') AND (l_transaction_type NOT IN (3, 4))) AND l_to_op_seq_num is NOT NULL) THEN
                    l_stmt_num := 160;

                    SELECT NVL(operation_sequence_id, -2)
                    INTO   l_to_op_seq_id
                    FROM   bom_operation_sequences
                    WHERE  operation_seq_num =   l_to_op_seq_num
                    AND    routing_sequence_id = l_routing_seq_id
                    /* BC: CZH.I_OED-1 compare against rtg_rev_date */
                    AND    nvl(disable_date, TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS')+1)
                           >= TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS') /* CHG: BUG2380517 add SS, > to >= */
                    AND    nvl(effectivity_date, TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS')) <= TO_DATE(l_rtg_revision_date, 'YYYY/MM/DD HH24:MI:SS');   /* CHG: BUG2380517 add SS */
                    /* EC: CZH.I_OED-1 */
                    /* CZH: no exception will be thrown if no data found, l_to_op_seq_id remain unchanged */
                END IF;
            ELSE
                l_stmt_num := 170;

                -- Bug 4480248   Added the condition ( AND l_to_op_seq_num is NOT NULL) in the IF statement below
                IF (((l_jump_flag <> 'Y') AND (l_transaction_type NOT IN (3, 4))) AND l_to_op_seq_num is NOT NULL) THEN
                    SELECT  nvl(operation_sequence_id, -2)
                    INTO    l_to_op_seq_id
                    FROM    WSM_COPY_OPERATIONS
                    WHERE   wip_entity_id=l_wip_entity_id
                    AND     operation_seq_num =   l_to_op_seq_num;
                END IF;
            END IF;

            l_stmt_num := 180;
--move enh added IF condn
            IF (l_transaction_type <> 3) THEN
                select NVL(operation_sequence_id, -1) -- CZH.bug2393850 in op outside routing
                into   l_fm_op_seq_id
                from   wip_operations
                where  wip_entity_id = l_wip_entity_id
                and    operation_seq_num = l_fm_op_seq_num;
            END IF;

/*abb, NSO addition end*/

            /* if( ( (l_to_op_seq_id == l_fm_op_seq_id) && (l_fm_op_seq_num == l_to_op_seq_num) ) */
            /* CHG: CZH, should not compare op_seq_num */
            --bug 4090905: added jump flag check.
            IF ( ((l_to_op_seq_id = l_fm_op_seq_id) and (l_jump_flag <> 'Y'))/* @ inside rtg */
                OR
                ( l_fm_op_seq_id = -1   /* @ outside routing */
                  AND (l_fm_operation_code = l_to_operation_code))
                  /*
                   * CZH: added the following condition, this was a bug in OSFM code for a while.
                   *      user should be able to jump to the same op code @ outside routing
                   */
                  AND (l_jump_flag <> 'Y') )   THEN
                l_max_op_seq := l_fm_op_seq_num;
            else
                l_stmt_num := 190;

                SELECT unique max(operation_seq_num)
                INTO   l_max_op_seq -- will be the newly added row in WO
                FROM   wip_operations
                WHERE  WIP_ENTITY_ID = l_wip_entity_id;


            END IF;

            /* End Fixed bug #1560345 */

            l_stmt_num := 200;
                    /******************************************************************
         * insert record into WMTI, will call WIP user_exit to process it *
         ******************************************************************/

        --move enh To determine the WIP move txns we need to insert we need the data in the variables we pass into LBMIB.
            l_count := 0;

            IF (l_scrap_qty>0) THEN
                IF (l_transaction_type in (1, 2)) THEN
                        l_op_flag := 1;
                ELSE
                        IF ((l_scrap_at_operation_flag=1) or (l_scrap_at_operation_flag IS NULL)) THEN
                                l_op_flag := 2;
                        ELSIF (l_scrap_at_operation_flag=2) THEN
                                l_op_flag := 1;
                        END IF;
                END IF;
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Inserting WMTI row for scrap qty',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;

                INSERT INTO wip_move_txn_interface(
                 TRANSACTION_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATED_BY_NAME,
                 CREATION_DATE,
                 CREATED_BY,
                 CREATED_BY_NAME,
                 LAST_UPDATE_LOGIN,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 GROUP_ID,
                 SOURCE_CODE,
                 SOURCE_LINE_ID,
                 PROCESS_PHASE,
                 PROCESS_STATUS ,
                 TRANSACTION_TYPE,
                 ORGANIZATION_ID,
                 ORGANIZATION_CODE,
                 WIP_ENTITY_ID,
                 WIP_ENTITY_NAME,
                 ENTITY_TYPE,
                 PRIMARY_ITEM_ID,
                 LINE_ID,
                 LINE_CODE,
                 REPETITIVE_SCHEDULE_ID,
                 TRANSACTION_DATE,
                 ACCT_PERIOD_ID,
                 FM_OPERATION_SEQ_NUM,
                 FM_OPERATION_CODE,
                 FM_DEPARTMENT_ID,
                 FM_DEPARTMENT_CODE,
                 FM_INTRAOPERATION_STEP_TYPE,
                 TO_OPERATION_SEQ_NUM,
                 TO_OPERATION_CODE,
                 TO_DEPARTMENT_ID,
                 TO_DEPARTMENT_CODE,
                 TO_INTRAOPERATION_STEP_TYPE,
                 TRANSACTION_QUANTITY,
                 TRANSACTION_UOM,
                 PRIMARY_QUANTITY,
                 PRIMARY_UOM ,
                 SCRAP_ACCOUNT_ID,
                 REASON_ID,
                 REASON_NAME,
                 REFERENCE,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 QA_COLLECTION_ID,
                 KANBAN_CARD_ID,
                 OVERCOMPLETION_TRANSACTION_QTY,
                 OVERCOMPLETION_PRIMARY_QTY,
                 OVERCOMPLETION_TRANSACTION_ID,
                 PROCESSING_ORDER,
                 BATCH_ID,
                 EMPLOYEE_ID)
                (SELECT
                 decode(l_transaction_quantity,
                    0, l_transaction_id,
--bug 3615826
--                    wip_transactions_s.nextval),
                    internal_scrap_txn_id),
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATED_BY_NAME,
                 CREATION_DATE,
                 CREATED_BY,
                 CREATED_BY_NAME,
                 LAST_UPDATE_LOGIN,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 decode(SOURCE_CODE,
                    --bug 5446252 match transaction_id with group_id for WIP single move api
                    --'move out oa page', internal_scrap_txn_id,
                    'move out oa page', decode(l_transaction_quantity,
                                          0, l_transaction_id,
                                          internal_scrap_txn_id),
                    --'undo oa page', internal_scrap_txn_id,
                    'undo oa page', decode(l_transaction_quantity,
                                      0, l_transaction_id,
                                      internal_scrap_txn_id),
                    l_wmti_group_id),  -- GROUP_ID
                 SOURCE_CODE,
                 SOURCE_LINE_ID,
                 decode(SOURCE_CODE,
                    'move out oa page', WIP_CONSTANTS.MOVE_PROC,
                    'undo oa page', WIP_CONSTANTS.MOVE_PROC,
                    g_move_val),        --1 Process_Phase,  --2721366: Replaced 1 with constant
                 g_running,         --1 Process_Status ,    --2721366: Replaced 1 with constant
                 g_move_txn,
                 ORGANIZATION_ID,
                 ORGANIZATION_CODE,
                 WIP_ENTITY_ID,
                 WIP_ENTITY_NAME,
                 ENTITY_TYPE,
                 PRIMARY_ITEM_ID,
                 LINE_ID,
                 LINE_CODE,
                 REPETITIVE_SCHEDULE_ID,
                 TRANSACTION_DATE,
                 ACCT_PERIOD_ID,
                 decode(l_op_flag,
                            1, fm_operation_seq_num,
                            2, to_operation_seq_num),
                 decode(l_op_flag,
                            1, fm_operation_code,
                            2, to_operation_code),
                 decode(l_op_flag,
                            1, fm_department_id,
                            2, to_department_id),
                 decode(l_op_flag,
                            1, fm_department_code,
                            2, to_department_code),
                 decode(TRANSACTION_TYPE,
                    4, g_scrap,
                    g_ret_txn, g_scrap,
                    FM_INTRAOPERATION_STEP_TYPE),
                 decode(TRANSACTION_TYPE,
                    g_ret_txn, TO_OPERATION_SEQ_NUM,
                    4, TO_OPERATION_SEQ_NUM,
                    decode(SCRAP_AT_OPERATION_FLAG,
                                1, fm_operation_seq_num,
                                l_max_op_seq)),
                 decode(TRANSACTION_TYPE,
                    g_ret_txn, TO_OPERATION_CODE,
                    4, TO_OPERATION_CODE,
                    decode(SCRAP_AT_OPERATION_FLAG,
                                            1, fm_OPERATION_CODE,
                                            to_OPERATION_CODE)),
                 decode(TRANSACTION_TYPE,
                    g_ret_txn, TO_DEPARTMENT_ID,
                    4, TO_DEPARTMENT_ID,
                    decode(SCRAP_AT_OPERATION_FLAG,
                                            1, fm_DEPARTMENT_ID,
                                            to_DEPARTMENT_ID)),
                 decode(TRANSACTION_TYPE,
                    g_ret_txn, TO_DEPARTMENT_CODE,
                    4, TO_DEPARTMENT_CODE,
                    decode(SCRAP_AT_OPERATION_FLAG,
                                            1, fm_DEPARTMENT_CODE,
                                            TO_DEPARTMENT_CODE)),
                 decode(TRANSACTION_TYPE,
                    g_move_txn, g_scrap,
                    g_comp_txn, g_scrap,
                    TO_INTRAOPERATION_STEP_TYPE),
                 SCRAP_QUANTITY,
                 TRANSACTION_UOM,
                 PRIMARY_SCRAP_QUANTITY,
                 PRIMARY_UOM ,
                 SCRAP_ACCOUNT_ID,
                 REASON_ID,
                 REASON_NAME,
                 REFERENCE,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 QA_COLLECTION_ID,
                 --move enh?
                 KANBAN_CARD_ID, --move enh?
                 OVERCOMPLETION_TRANSACTION_QTY,
                 OVERCOMPLETION_PRIMARY_QTY,
                 OVERCOMPLETION_TRANSACTION_ID,
--The decode below is not required and is incorrect, but decided not to remove since code is stable
                 decode(TRANSACTION_TYPE,
                    g_comp_txn, g_ret_txn,
                    1), /*processing_order*/
                 TRANSACTION_ID,
                 p_employee_id
                 FROM    wsm_lot_move_txn_interface
                 WHERE   header_id = l_header_id);

                l_count := SQL%ROWCOUNT;
                IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') :
                    Inserted Scrap Txn');
                END IF;

                --mes populate l_job_fm_op_seq_num, l_job_to_op_seq_num
                IF (l_transaction_quantity = 0) THEN
                    SELECT  fm_operation_seq_num, to_operation_seq_num
                    INTO    l_fm_op_seq_num, l_job_to_op_seq_num
                    FROM    WIP_MOVE_TXN_INTERFACE
                    WHERE   transaction_id = l_transaction_id;
                END IF;
            END IF;

            l_stmt_num := 210;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'B4 IF (l_transaction_quantity>0) l_transaction_quantity '||l_transaction_quantity,
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

            IF (l_transaction_quantity > 0) THEN
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Inserting WMTI row for move qty',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;

                INSERT INTO wip_move_txn_interface(
                 TRANSACTION_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATED_BY_NAME,
                 CREATION_DATE,
                 CREATED_BY,
                 CREATED_BY_NAME,
                 LAST_UPDATE_LOGIN,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 GROUP_ID,
                 SOURCE_CODE,
                 SOURCE_LINE_ID,
                 PROCESS_PHASE,
                 PROCESS_STATUS ,
                 TRANSACTION_TYPE,
                 ORGANIZATION_ID,
                 ORGANIZATION_CODE,
                 WIP_ENTITY_ID,
                 WIP_ENTITY_NAME,
                 ENTITY_TYPE,
                 PRIMARY_ITEM_ID,
                 LINE_ID,
                 LINE_CODE,
                 REPETITIVE_SCHEDULE_ID,
                 TRANSACTION_DATE,
                 ACCT_PERIOD_ID,
                 FM_OPERATION_SEQ_NUM,
                 FM_OPERATION_CODE,
                 FM_DEPARTMENT_ID,
                 FM_DEPARTMENT_CODE,
                 FM_INTRAOPERATION_STEP_TYPE,
                 TO_OPERATION_SEQ_NUM,
                 TO_OPERATION_CODE,
                 TO_DEPARTMENT_ID,
                 TO_DEPARTMENT_CODE,
                 TO_INTRAOPERATION_STEP_TYPE,
                 TRANSACTION_QUANTITY,
                 TRANSACTION_UOM,
                 PRIMARY_QUANTITY,
                 PRIMARY_UOM ,
                 SCRAP_ACCOUNT_ID,
                 REASON_ID,
                 REASON_NAME,
                 REFERENCE,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 QA_COLLECTION_ID,
                 KANBAN_CARD_ID,
                 OVERCOMPLETION_TRANSACTION_QTY,
                 OVERCOMPLETION_PRIMARY_QTY,
                 OVERCOMPLETION_TRANSACTION_ID,
                 PROCESSING_ORDER,
                 BATCH_ID,
                 EMPLOYEE_ID)
            (SELECT
             TRANSACTION_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATED_BY_NAME,
             CREATION_DATE,
             CREATED_BY,
             CREATED_BY_NAME,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             decode(SOURCE_CODE,
                'move in oa page', TRANSACTION_ID,
                'move out oa page', TRANSACTION_ID,
                'move to next op oa page', TRANSACTION_ID,
                'jump oa page', TRANSACTION_ID,
                'undo oa page', TRANSACTION_ID,
                l_wmti_group_id),  -- GROUP_ID
             SOURCE_CODE,
             SOURCE_LINE_ID,
             decode(SOURCE_CODE,
                'move in oa page', WIP_CONSTANTS.MOVE_PROC,
                'move out oa page', WIP_CONSTANTS.MOVE_PROC,
                'move to next op oa page', WIP_CONSTANTS.MOVE_PROC,
                'jump oa page', WIP_CONSTANTS.MOVE_PROC,
                'undo oa page', WIP_CONSTANTS.MOVE_PROC,
                g_move_val),        --1 Process_Phase,  --2721366: Replaced 1 with constant
             g_running,         --1 Process_Status ,    --2721366: Replaced 1 with constant
             decode(TRANSACTION_TYPE,4, 1, TRANSACTION_TYPE),
             ORGANIZATION_ID,
             ORGANIZATION_CODE,
             WIP_ENTITY_ID,
             WIP_ENTITY_NAME,
             ENTITY_TYPE,
             PRIMARY_ITEM_ID,
             LINE_ID,
             LINE_CODE,
             REPETITIVE_SCHEDULE_ID,
             TRANSACTION_DATE,
             ACCT_PERIOD_ID,
             FM_OPERATION_SEQ_NUM,
             FM_OPERATION_CODE,
             FM_DEPARTMENT_ID,
             FM_DEPARTMENT_CODE,
             FM_INTRAOPERATION_STEP_TYPE,
             decode(TRANSACTION_TYPE, 1, l_max_op_seq, 2, l_max_op_seq, TO_OPERATION_SEQ_NUM),
             TO_OPERATION_CODE,
             TO_DEPARTMENT_ID,
             TO_DEPARTMENT_CODE,
             TO_INTRAOPERATION_STEP_TYPE,
             TRANSACTION_QUANTITY,
             TRANSACTION_UOM,
             PRIMARY_QUANTITY,
             PRIMARY_UOM ,
             --bug 5092117 added decode statements
             decode(TO_INTRAOPERATION_STEP_TYPE,
                    WIP_CONSTANTS.SCRAP, SCRAP_ACCOUNT_ID,
                    decode(FM_INTRAOPERATION_STEP_TYPE,
                          WIP_CONSTANTS.SCRAP, SCRAP_ACCOUNT_ID,
                          NULL)
                    ),
             REASON_ID,
             REASON_NAME,
             REFERENCE,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             QA_COLLECTION_ID,
             KANBAN_CARD_ID,
             OVERCOMPLETION_TRANSACTION_QTY,
             OVERCOMPLETION_PRIMARY_QTY,
             OVERCOMPLETION_TRANSACTION_ID,
             decode(TRANSACTION_TYPE, 3, 1, 2), /*processing_order*/
             TRANSACTION_ID,
             p_employee_id
             FROM    wsm_lot_move_txn_interface
             WHERE   header_id = l_header_id
                );

            l_count := l_count+SQL%ROWCOUNT;
            IF (g_mrp_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'Inserted '||l_count||' row(s) in WMTI, group_id '|| l_wmti_group_id||', txn_id '
                ||l_transaction_id||' scrap txn id '||l_scrap_txn_id);
            END IF;

            --mes populate l_job_fm_op_seq_num, l_job_to_op_seq_num
            SELECT  fm_operation_seq_num, to_operation_seq_num
            INTO    l_fm_op_seq_num, l_job_to_op_seq_num
            FROM    WIP_MOVE_TXN_INTERFACE
            WHERE   transaction_id = l_transaction_id;
        END IF;


        IF (l_count = 0) THEN
            fnd_file.put_line(fnd_file.log, 'WARNING: Could not insert into WMTI');

            l_stmt_num := 230;
            FND_MESSAGE.SET_NAME('WSM', 'WSM_INS_TBL_FAILED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'wip_move_txn_interface');
            l_error_msg := FND_MESSAGE.GET;
            ROLLBACK TO VALIDATION;

            error_handler(p_header_id => l_header_id
                    , p_transaction_id => l_transaction_id
                    , p_error_msg => l_error_msg
                    , x_error_code => x_err_code
                    , x_error_msg => x_err_msg);
            fnd_file.put_line(fnd_file.log, 'WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') : '||l_error_msg);
            IF (x_err_code <> 0) THEN
                raise e_proc_exception;
            END IF;

            GOTO inner_loop;
        ELSE
            l_inserted_wmti := l_inserted_wmti + l_count;
        END IF;
    -- Code to handle sale order reservations.
    -- Modified for bug 5286219. Have code for transferring reservation from
    -- inv to LBJ during return txn before we call move processor code.
    IF (l_transaction_type in (2,3)) THEN
      declare
      l_rsv_exists BOOLEAN;
      l_net_quantity NUMBER;
      l_primary_item_id NUMBER;
      l_msg_count NUMBER;
      l_msg_data     VARCHAR2(2000);
      begin
        l_rsv_exists:=FALSE;
        l_stmt_num := 230.1;

        select net_quantity,primary_item_id
        into l_net_quantity,l_primary_item_id
        from wip_discrete_jobs
        where wip_entity_id=l_wip_entity_id
        and organization_id=l_organization_id;

        if   l_transaction_type = 2 then
        l_rsv_exists:= wsm_reservations_pvt.check_reservation_exists(
                           p_wip_entity_id     => l_wip_entity_id ,
                           p_org_id            => l_organization_id ,
                           p_inventory_item_id =>  l_primary_item_id
                           );
        end if;

        if l_transaction_type = 3 then
            l_rsv_exists:=TRUE;
        end if;

        If l_rsv_exists then
            --If l_transaction_type = 2 THEN --not normal move or undo

                        l_stmt_num := 251.2;
                        wsm_reservations_pvt.modify_reservations_move (
                             p_wip_entity_id         => l_wip_entity_id,
                             P_inventory_item_id     => l_primary_item_id,
                             P_org_id                => l_organization_id,
                             P_txn_type              => l_transaction_type,--2,
                             --Bug 5530944:Reserved qty should be compared
                             --with completed qty.
                             p_net_qty               => l_primary_quantity,--l_net_quantity,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data
                             );
                         IF(l_return_status <> 'S') THEN
                            raise e_proc_exception;
                         END IF;
              --  End if;--not normal move or undo
       End if ;
    END;
    END IF;--End of check on transaction type.
        WSMPLBMI.update_costed_qty_compl(
              p_transaction_type        => l_transaction_type
            , p_job_fm_op_seq_num       => l_fm_op_seq_num
            , p_job_to_op_seq_num       => l_job_to_op_seq_num
            , p_wip_entity_id           => l_wip_entity_id
            , p_fm_intraoperation_step_type => l_fm_intraoperation_step_type
            , p_to_intraoperation_step_type => l_to_intraoperation_step_type
            , p_primary_move_qty        => l_primary_quantity
            , p_primary_scrap_qty       => l_converted_scrap_qty
            , p_scrap_at_op             => l_scrap_at_operation_flag
        );


--                Start additions for Costing for WLTEnh
    --move enh? should we use primary qty?
        IF ( (l_to_intraoperation_step_type = 5) OR (l_fm_intraoperation_step_type = 5) /* if this is a scrap/unscrap transaction */
            OR (l_converted_scrap_qty>0)) THEN
            IF (l_fm_intraoperation_step_type = 5) THEN
                l_txn_qty := -1 * l_txn_qty;
                l_wro_op_seq_num := l_fm_op_seq_num;
            END IF;
            /* Bug 8835930 */
            IF (( (l_converted_scrap_qty>0) OR (l_converted_scrap_qty=0 and l_txn_qty >0)) AND (l_transaction_type IN (3, 4)))THEN
                l_converted_scrap_qty := -1 * l_converted_scrap_qty;
                IF (l_scrap_at_operation_flag = 1) THEN
                    l_wro_op_seq_num := l_to_op_seq_num;
                ELSE
                    l_wro_op_seq_num := l_fm_op_seq_num;
                END IF;
            /* Bug 8835930 */
            ELSIF (( (l_converted_scrap_qty>0) OR (l_converted_scrap_qty=0 and l_txn_qty >0)) AND (l_transaction_type IN (1, 2)))THEN
                IF (l_scrap_at_operation_flag = 1) THEN
                    l_wro_op_seq_num := l_fm_op_seq_num;
                ELSE
                    l_wro_op_seq_num := l_to_op_seq_num;
                END IF;
            END IF;


            l_stmt_num := 230;
            SELECT  nvl(include_component_yield, 1)
            INTO    l_wip_include_comp_yield
            FROM    WIP_PARAMETERS
            WHERE   organization_id = l_organization_id;

            --LBM enh: Modified the expression for quantity_relieved
            UPDATE  wip_requirement_operations wro
            SET     QUANTITY_RELIEVED = NVL(wro.QUANTITY_RELIEVED, 0) +
                            decode(l_converted_scrap_qty,
                                0, decode(wro.basis_type, 2, 1, l_txn_qty),
                                decode(wro.basis_type, 2, 1, l_converted_scrap_qty)) * decode(l_wip_include_comp_yield,
                                                            2, wro.quantity_per_assembly,
                                                            (wro.quantity_per_assembly / NVL(wro.component_yield_factor,1)))
            WHERE   wro.wip_entity_id      = l_wip_entity_id
            AND     wro.organization_id    = l_organization_id
            AND     wro.operation_seq_num <= l_wro_op_seq_num
                                -- since scrap can be done only at curr op
            AND     wro.quantity_per_assembly <> 0
            AND     wro.wip_supply_type <> 6
            AND     wro.wip_supply_type <> 4
            AND     wro.wip_supply_type <> 5
            AND     NOT EXISTS
                        (SELECT  1
                         FROM    wip_operations wo
                         WHERE   wo.organization_id     = wro.organization_id
                         AND     wo.wip_entity_id       = wro.wip_entity_id
                         AND     wo.operation_seq_num   = wro.operation_seq_num
                         AND     wo.count_point_type    = 3);

            IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') :
                    Updated '||SQL%ROWCOUNT||' rows in WRO');
            END IF;

        END IF;
--     End additions for Costing for WLTEnh
--MES
        IF (nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page', 'move to next op oa page',
        'jump oa page', 'undo oa page' )) THEN
          update_int_grp_id(x_error_code,
                              x_error_msg,
                              l_header_id,
                              l_transaction_id);
          IF (x_err_code <> 0) THEN
              raise e_proc_exception;
          END IF;
        ELSE
          update_int_grp_id(x_error_code,
                  x_error_msg,
                  l_header_id,
                  l_wmti_group_id);
          IF (x_err_code <> 0) THEN
              raise e_proc_exception;
          END IF;
        END IF;

        l_stmt_num := 250;
--move enh 115.135 changed WIP_CONSTANTS.MOVE_TXN to global variable after perf check
        IF ((l_transaction_type = g_move_txn) AND (l_fm_op_seq_num <> l_max_op_seq)
        and (g_aps_wps_profile='Y')) THEN
            IF (l_scrap_at_operation_flag = 2) THEN
--bug 3385113 add nvl
                l_new_op_txn_qty := nvl(l_primary_quantity, 0) + nvl(l_converted_scrap_qty, 0);
            ELSE
                l_new_op_txn_qty := l_primary_quantity;
            END IF;
            l_stmt_num := 250.1;
            WSMPOPRN.call_infinite_scheduler(
                        x_error_code            => x_return_code,
                        x_error_msg             => l_error_msg,
                        p_jump_flag             => l_jump_flag,
                        p_wip_entity_id         => l_wip_entity_id,
                        p_org_id                => l_organization_id,
                        p_to_op_seq_id          => l_to_op_seq_id,
                        p_fm_job_op_seq_num     => l_fm_op_seq_num,
                        p_to_job_op_seq_num     => l_max_op_seq,
                        p_scheQuantity          => l_new_op_txn_qty);
            IF (x_return_code = 0) THEN
                IF (g_mrp_debug='Y') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'WSMPOPRN.call_infinite_scheduler returned success');
                END IF;
            ELSE
                l_error_msg := x_error_msg;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'WSMPLBMI.custom_validation' ||'(stmt_num='||l_stmt_num||') : '||substrb(l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                            , p_transaction_id => l_transaction_id
                            , p_error_msg => l_error_msg
                            , x_error_code => x_err_code
                            , x_error_msg => x_err_msg);
                IF (x_err_code <> 0) THEN
                    raise e_proc_exception;
                END IF;
                GOTO inner_loop;     /* go to get next entry */
            END IF;
        END IF;


--MES
      IF (nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page', 'move to next op oa page',
        'jump oa page', 'undo oa page' )) THEN
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Begin MES processing'||
                ';l_converted_scrap_qty '||
                l_converted_scrap_qty||
                ';l_primary_quantity '||
                l_primary_quantity||
                ';l_to_intraoperation_step_type '||
                l_to_intraoperation_step_type||
                ';l_fm_intraoperation_step_type '||
                l_fm_intraoperation_step_type,
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

--!! get l_mtl_txn_profile from inv profiles
--MTL_TRANS_PROC 1 online, 2 immediate concurrent, 3 background, 4 form level

        l_mtl_txn_profile := FND_PROFILE.value('TRANSACTION_PROCESS_MODE');

        IF (l_mtl_txn_profile = WIP_CONSTANTS.FORM_LEVEL) THEN
          --l_mtl_txn_profile := FND_PROFILE.value('WIP_MOVE_TRANSACTION');
          l_mtl_txn_profile := FND_PROFILE.value('WIP_SHOP_FLOOR_MTL_TRANSACTION');
        END IF;

          -- ST : Serial MES Fix : Start
          -- Have to store the attributes before invoking the Wip processor...
          -- Temporarily store the Serial Attributes of serial numbers from MSN and
          -- present in WMTI...(use the txn IDs) for completion and assembly return txns..
          DECLARE
                  l_return_status     VARCHAR2(1);
                  l_error_msg     VARCHAR2(2000);
                  l_error_count     NUMBER;

          BEGIN
                 IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                          l_msg_tokens.delete;
                          WSM_log_PVT.logMessage (  p_module_name       => l_module ,
                                                    p_msg_text          => 'B4 calling WSM_Serial_support_PVT.Insert_MOVE_attr',
                                                    p_stmt_num          => l_stmt_num   ,
                                                    p_msg_tokens        => l_msg_tokens   ,
                                                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                                                    p_run_log_level     => l_log_level
                                                  );
                 END IF;

                 l_stmt_num := 253.13;
                 WSM_Serial_support_PVT.Insert_MOVE_attr (  p_group_id       => null             ,
                                                            p_move_txn_id    => l_transaction_id ,
                                                            p_scrap_txn_id   => l_scrap_txn_id   ,
                                                            x_return_status  => l_return_status  ,
                                                            x_error_count    => l_error_msg      ,
                                                            x_error_msg      => l_error_count
                                                         );

                 if l_return_status = FND_API.G_RET_STS_SUCCESS then
                        IF (l_debug='Y') THEN
                                 fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Insert_attr_WSTI returned Success');
                        END IF;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                  l_msg_tokens.delete;
                                  WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                          p_msg_text          => 'WSM_Serial_support_PVT.Insert_MOVE_attr returned successfully',
                                                          p_stmt_num          => l_stmt_num   ,
                                                          p_msg_tokens        => l_msg_tokens   ,
                                                          p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                                                          p_run_log_level     => l_log_level
                                                          );
                        END IF;
                  ELSE
                        IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                                  l_msg_tokens.delete;
                                  WSM_log_PVT.logMessage (  p_module_name     => l_module ,
                                                            p_msg_text          => 'WSM_Serial_support_PVT.Insert_MOVE_attr returned error',
                                                            p_stmt_num          => l_stmt_num   ,
                                                            p_msg_tokens        => l_msg_tokens   ,
                                                            p_fnd_log_level     => G_LOG_LEVEL_ERROR  ,
                                                            p_run_log_level     => l_log_level
                                                          );
                        END IF;
                        IF (l_error_count = 1)  THEN
                                  fnd_file.put_line(fnd_file.log, l_error_msg);
                        ELSIF (l_error_count > 1)  THEN
                                 FOR i IN 1..l_error_count LOOP
                                       l_error_msg := fnd_msg_pub.get( p_msg_index => l_error_count - i + 1,
                                                                       p_encoded   => FND_API.G_FALSE
                                                                     );
                                       fnd_file.put_line(fnd_file.log, l_error_msg);
                                 END LOOP;
                        ELSE
                                 l_error_msg := 'WSM_Serial_support_PVT.Insert_attr_WSTI returned failure';
                        END IF;

                        IF (l_debug='Y') THEN
                                fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Insert_attr_WSTI returned failure');
                        END IF;
                        -- This call is supposed to not return any error...
                        raise e_proc_exception;
                END IF;
        END;
        -- ST : Serial MES Fix : end
        -- ST : Serial Support Project --

        IF (l_scrap_qty > 0) THEN
            l_stmt_num := 251;
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Calling wip move api for scrap qty',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

            --bug 5446252 since l_scrap_txn_id is not populated if l_primary_quantity = 0
            IF (l_primary_quantity > 0) THEN
                l_mes_scrap_txn_id := l_scrap_txn_id;
            ELSE
                l_mes_scrap_txn_id := l_transaction_id;
            END IF;
            --end bug 5446252

            --bug 5446252 replace l_scrap_txn_id with l_mes_scrap_txn_id
            wip_movProc_grp.processInterface(
              p_movTxnID        => l_mes_scrap_txn_id,
              p_procPhase       => WIP_CONSTANTS.MOVE_PROC,
              p_txnHdrID        => p_mtl_txn_hdr_id,
              p_mtlMode         => l_mtl_txn_profile,
              p_cplTxnID        => null,
              p_commit          => null,
              x_returnStatus    => l_return_status,
              x_errorMsg        => l_error_msg);

              IF(l_return_status <> 'S')THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, substrb('WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                 , p_transaction_id => l_transaction_id
                 , p_error_msg => l_error_msg
                 , x_error_code => x_err_code
                 , x_error_msg => x_error_msg);
                 x_error_msg := l_error_msg;
                IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module,
                    p_msg_text          => 'wip_movProc_grp.processInterface for scrap txn returned error: '||l_error_msg,
                    p_stmt_num          => l_stmt_num,
                    p_msg_tokens        => l_msg_tokens,
                    p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                    p_run_log_level     => l_log_level
                  );
                END IF;
                 raise e_proc_exception;
               ELSIF (l_return_status = 'S') THEN
                x_wip_move_api_sucess_msg := fnd_msg_pub.get;
                IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'wip_movProc_grp.processInterface for scrap txn returned success: ',
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                   p_run_log_level     => l_log_level
                 );
                END IF;
              END IF;
        END IF;

        IF (l_transaction_type = g_comp_txn) THEN
          SELECT mtl_material_transactions_s.nextval
          INTO l_cpl_txn_id
          FROM dual;
        END IF;

        IF ((l_primary_quantity > 0) and (l_to_intraoperation_step_type <> WIP_CONSTANTS.SCRAP)
        and (l_fm_intraoperation_step_type <> WIP_CONSTANTS.SCRAP)) THEN
            l_stmt_num := 252;
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Calling wip move api for move qty',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;

            wip_movProc_grp.processInterface(
              p_movTxnID        => l_transaction_id,
              p_procPhase       => WIP_CONSTANTS.MOVE_PROC,
              p_txnHdrID        => p_mtl_txn_hdr_id,
              p_mtlMode         => l_mtl_txn_profile,
              p_cplTxnID        => l_cpl_txn_id,
              p_commit          => null,
              x_returnStatus    => l_return_status,
              x_errorMsg        => l_error_msg);

              IF (l_return_status <> 'S') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, substrb('WSMPLBMI.MoveTransactions' ||'(stmt_num='||l_stmt_num||') : '||l_error_msg, 1,4000));
                ROLLBACK TO validation;
                error_handler(p_header_id => l_header_id
                 , p_transaction_id => l_transaction_id
                 , p_error_msg => l_error_msg
                 , x_error_code => x_err_code
                 , x_error_msg => x_error_msg);
                 x_error_msg := l_error_msg;
                 IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                   l_msg_tokens.delete;
                   WSM_log_PVT.logMessage (
                     p_module_name     => l_module,
                     p_msg_text          => 'wip_movProc_grp.processInterface for move txn returned error: '||l_error_msg,
                     p_stmt_num          => l_stmt_num,
                     p_msg_tokens        => l_msg_tokens,
                     p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                     p_run_log_level     => l_log_level
                   );
                END IF;
                 raise e_proc_exception;
              END IF;
--l_mtl_txn_profile IN (WIP_CONSTANTS.BACKGROUND,
--                         WIP_CONSTANTS.IMMED_CONC)

              x_wip_move_api_sucess_msg := fnd_msg_pub.get;
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              IF (l_return_status = 'S') THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'wip_movProc_grp.processInterface for move txn returned success: '||x_wip_move_api_sucess_msg,
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                   p_run_log_level     => l_log_level
                 );
              END IF;
            END IF;
        END IF;

        --bug 5210799 Update quantity_completed to null if jump from queue
        UPDATE  (
                SELECT  quantity_completed
                FROM    WIP_OPERATIONS
                WHERE   wip_entity_id = l_wip_entity_id
                AND     operation_seq_num = l_fm_op_seq_num
                AND     skip_flag = 1
                )
        SET     quantity_completed = 0;
        --end bug 5210799

        IF (nvl(p_source_code, 'interface') = 'move out oa page') THEN
            l_stmt_num := 253.1;
            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Begin inserting MES data',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                p_run_log_level     => l_log_level
              );
            END IF;
            IF ((p_sec_uom_code_tbls IS NOT NULL) AND (p_sec_uom_code_tbls.exists(l_header_id))
            AND (p_sec_uom_code_tbls(l_header_id).count > 0)) THEN

                l_stmt_num := 253.2;
                forall i in p_sec_uom_code_tbls(l_header_id).first..p_sec_uom_code_tbls(l_header_id).last
                update wsm_op_secondary_quantities
                set MOVE_OUT_QUANTITY = p_sec_move_out_qty_tbls(l_header_id)(i),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_fm_op_seq_num
                and uom_code = p_sec_uom_code_tbls(l_header_id)(i);

    l_stmt_num := 253.21;
                forall i in p_sec_uom_code_tbls(l_header_id).first..p_sec_uom_code_tbls(l_header_id).last
                update wsm_job_secondary_quantities
                set CURRENT_QUANTITY = p_sec_move_out_qty_tbls(l_header_id)(i),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
                where wip_entity_id = l_wip_entity_id
                and uom_code = p_sec_uom_code_tbls(l_header_id)(i);

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                   l_msg_tokens.delete;
                   WSM_log_PVT.logMessage (
                     p_module_name     => l_module,
                     p_msg_text          => 'Updated secondary quantities successfully',
                     p_stmt_num          => l_stmt_num,
                     p_msg_tokens        => l_msg_tokens,
                     p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                     p_run_log_level     => l_log_level
                   );
                END IF;
            END IF;

            l_stmt_num := 253.3;
            IF ((p_scrap_codes_tbls IS NOT NULL) AND (p_scrap_codes_tbls.exists(l_header_id))
            AND (p_scrap_codes_tbls(l_header_id).count > 0)) THEN

                l_stmt_num := 253.4;
                forall i in p_scrap_codes_tbls(l_header_id).first..p_scrap_codes_tbls(l_header_id).last
                update wsm_op_reason_codes
                set QUANTITY = p_scrap_code_qty_tbls(l_header_id)(i),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id,
                    LAST_UPDATED_LOGIN = g_login_id
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_fm_op_seq_num
                and CODE_TYPE = 1
                and REASON_CODE = p_scrap_codes_tbls(l_header_id)(i);

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'Updated scrap codes successfully',
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                   p_run_log_level     => l_log_level
                 );
                END IF;
            END IF;

            l_stmt_num := 253.5;
            IF ((p_bonus_codes_tbls IS NOT NULL) AND (p_bonus_codes_tbls.exists(l_header_id))
            AND (p_bonus_codes_tbls(l_header_id).count > 0)) THEN
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  FOR i in p_bonus_codes_tbls(l_header_id).first..p_bonus_codes_tbls(l_header_id).last
                  LOOP
                    l_msg_tokens.delete;
                     WSM_log_PVT.logMessage (
                       p_module_name     => l_module,
                       p_msg_text          => 'i '||i||'; bonus code '||
                       p_bonus_codes_tbls(l_header_id)(i)
                       ||'; bonus code qty '
                       ||p_bonus_code_qty_tbls(l_header_id)(i),
                       p_stmt_num          => l_stmt_num,
                       p_msg_tokens        => l_msg_tokens,
                       p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                       p_run_log_level     => l_log_level
                     );
                  END LOOP;
                END IF;
                l_stmt_num := 253.6;
                forall i in p_bonus_codes_tbls(l_header_id).first..p_bonus_codes_tbls(l_header_id).last
                update wsm_op_reason_codes
                set QUANTITY = p_bonus_code_qty_tbls(l_header_id)(i),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id,
                    LAST_UPDATED_LOGIN = g_login_id
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_fm_op_seq_num
                and CODE_TYPE = 2
                and REASON_CODE = p_bonus_codes_tbls(l_header_id)(i);

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'Updated bonus codes successfully',
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                   p_run_log_level     => l_log_level
                 );
                END IF;
            END IF;
        END IF;

        IF (nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page')) THEN
          IF (nvl(p_source_code, 'interface') = 'move in oa page') THEN
              l_stmt_num := 253.6;
            IF (p_jobop_resource_usages_tbls IS NOT NULL) AND p_jobop_resource_usages_tbls.exists(l_header_id)
            AND (p_jobop_resource_usages_tbls(l_header_id).count > 0)THEN
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  FOR i in p_jobop_resource_usages_tbls(l_header_id).first..p_jobop_resource_usages_tbls(l_header_id).last
                  LOOP
                    l_msg_tokens.delete;
                     WSM_log_PVT.logMessage (
                       p_module_name     => l_module,
                       p_msg_text          => 'i '||i||'; RESOURCE_ID '||
                       p_jobop_resource_usages_tbls(l_header_id)(i).RESOURCE_ID
                       ||'; INSTANCE_ID '
                       ||p_jobop_resource_usages_tbls(l_header_id)(i).INSTANCE_ID
                       ||'; SERIAL_NUMBER '
                       ||p_jobop_resource_usages_tbls(l_header_id)(i).SERIAL_NUMBER,
                       p_stmt_num          => l_stmt_num,
                       p_msg_tokens        => l_msg_tokens,
                       p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                       p_run_log_level     => l_log_level
                     );
                  END LOOP;
                END IF;
                l_stmt_num := 253.7;
                DECLARE
                -- create an exception handler for ORA-24381
                   errors NUMBER;
                   dml_errors EXCEPTION;
                   PRAGMA EXCEPTION_INIT(dml_errors, -24381);
                BEGIN
                    forall i in p_jobop_resource_usages_tbls(l_header_id).first..p_jobop_resource_usages_tbls(l_header_id).last SAVE EXCEPTIONS
                      insert into WIP_RESOURCE_ACTUAL_TIMES values p_jobop_resource_usages_tbls(l_header_id)(i);
                -- If any errors occurred during the FORALL SAVE EXCEPTIONS,
                -- a single exception is raised when the statement completes.

                EXCEPTION
                  WHEN dml_errors THEN -- Now we figure out what failed and why.
                   errors := SQL%BULK_EXCEPTIONS.COUNT;
                   FOR i IN 1..errors LOOP
                    IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level) THEN
                      l_msg_tokens.delete;
                       WSM_log_PVT.logMessage (
                         p_module_name     => l_module,
                         p_msg_text          => 'Number of statements that failed: ' || errors||'Error #' || i || ' occurred during '||
                           'iteration #' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX,
                         p_stmt_num          => l_stmt_num,
                         p_msg_tokens        => l_msg_tokens,
                         p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED,
                         p_run_log_level     => l_log_level
                       );

                       WSM_log_PVT.logMessage (
                          p_module_name     => l_module,
                          p_msg_text          => 'Error message is ' ||
                            SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),
                          p_stmt_num          => l_stmt_num,
                          p_msg_tokens        => l_msg_tokens,
                          p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED,
                          p_run_log_level     => l_log_level
                       );
                     END IF;

                   END LOOP;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;
/*
                forall i in p_jobop_resource_usages_tbls(l_header_id).first..p_jobop_resource_usages_tbls(l_header_id).last SAVE EXCEPTIONS
                insert into WIP_RESOURCE_ACTUAL_TIMES values p_jobop_resource_usages_tbls(l_header_id)(i);
*/
              DECLARE
                cursor C_WOR is
                select  resource_id
                from    wip_operation_resources wor
                where   wor.wip_entity_id = l_wip_entity_id
                and     wor.operation_seq_num = l_fm_op_seq_num;

                Type t_wor_resource_id is table of wip_operation_resources.resource_id%TYPE index by binary_integer;
                l_wor_resource_id t_wor_resource_id;
              BEGIN
                OPEN C_WOR;
                FETCH C_WOR BULK COLLECT INTO l_wor_resource_id;
                CLOSE C_WOR;

                FORALL i in l_wor_resource_id.FIRST..l_wor_resource_id.LAST
                  UPDATE  WIP_OPERATION_RESOURCES
                  SET     actual_start_date =
                    (SELECT min(start_date)
                    FROM    WIP_RESOURCE_ACTUAL_TIMES wrat
                    WHERE   wrat.wip_entity_id = l_wip_entity_id
                    AND     wrat.operation_seq_num = l_fm_op_seq_num
                    AND     wrat.resource_id = l_wor_resource_id(i)),
                          projected_completion_date =
                    (SELECT max(projected_completion_date)
                    FROM    WIP_RESOURCE_ACTUAL_TIMES wrat
                    WHERE   wrat.wip_entity_id = l_wip_entity_id
                    AND     wrat.operation_seq_num = l_fm_op_seq_num
                    AND     wrat.resource_id = l_wor_resource_id(i)),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
                  WHERE   wip_entity_id = l_wip_entity_id
                  AND     operation_seq_num = l_fm_op_seq_num
                  AND     resource_id = l_wor_resource_id(i);

              END;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'Updated resource usage successfully',
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                   p_run_log_level     => l_log_level
                 );
              END IF;

            END IF;

            l_stmt_num := 253.6121;
            UPDATE  WIP_OPERATIONS
            SET     actual_start_date = p_operation_start_date,
                    projected_completion_date = p_expected_completion_date,
                    employee_id = p_employee_id,
                    wsm_bonus_quantity = p_bonus_quantity,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
            WHERE   wip_entity_id = l_wip_entity_id
            AND     operation_seq_num = l_fm_op_seq_num;

          ELSIF (nvl(p_source_code, 'interface') = 'move out oa page') THEN
            l_stmt_num := 253.6;
            IF (p_jobop_resource_usages_tbls IS NOT NULL) AND p_jobop_resource_usages_tbls.exists(l_header_id)
            AND (p_jobop_resource_usages_tbls(l_header_id).count > 0)THEN
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
               l_msg_tokens.delete;
               WSM_log_PVT.logMessage (
                 p_module_name     => l_module,
                 p_msg_text          => 'Begin inserting resource usage'
                 ||'; l_wip_entity_id: '
                 ||l_wip_entity_id
                 ||'; l_fm_op_seq_num: '
                 ||l_fm_op_seq_num,
                 p_stmt_num          => l_stmt_num,
                 p_msg_tokens        => l_msg_tokens,
                 p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                 p_run_log_level     => l_log_level
               );
              END IF;

              l_stmt_num := 253.61;
              DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
              WHERE wip_entity_id = l_wip_entity_id
              AND   operation_seq_num = l_fm_op_seq_num;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                FOR i in p_jobop_resource_usages_tbls(l_header_id).first..p_jobop_resource_usages_tbls(l_header_id).last
                LOOP
                  l_msg_tokens.delete;
                   WSM_log_PVT.logMessage (
                     p_module_name     => l_module,
                     p_msg_text          => 'i '||i||'; RESOURCE_ID '||
                     p_jobop_resource_usages_tbls(l_header_id)(i).RESOURCE_ID
                     ||'; INSTANCE_ID '
                     ||p_jobop_resource_usages_tbls(l_header_id)(i).INSTANCE_ID
                     ||'; SERIAL_NUMBER '
                     ||p_jobop_resource_usages_tbls(l_header_id)(i).SERIAL_NUMBER,
                     p_stmt_num          => l_stmt_num,
                     p_msg_tokens        => l_msg_tokens,
                     p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                     p_run_log_level     => l_log_level
                   );
                END LOOP;
              END IF;

              l_stmt_num := 253.7;
              DECLARE
              -- create an exception handler for ORA-24381
                 errors NUMBER;
                 dml_errors EXCEPTION;
                 PRAGMA EXCEPTION_INIT(dml_errors, -24381);
              BEGIN
                  forall i in p_jobop_resource_usages_tbls(l_header_id).first..p_jobop_resource_usages_tbls(l_header_id).last SAVE EXCEPTIONS
                    insert into WIP_RESOURCE_ACTUAL_TIMES values p_jobop_resource_usages_tbls(l_header_id)(i);
              -- If any errors occurred during the FORALL SAVE EXCEPTIONS,
              -- a single exception is raised when the statement completes.

              EXCEPTION
                WHEN dml_errors THEN -- Now we figure out what failed and why.
                 errors := SQL%BULK_EXCEPTIONS.COUNT;
                 FOR i IN 1..errors LOOP
                  IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level) THEN
                    l_msg_tokens.delete;
                     WSM_log_PVT.logMessage (
                       p_module_name     => l_module,
                       p_msg_text          => 'Number of statements that failed: ' || errors||'Error #' || i || ' occurred during '||
                         'iteration #' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX,
                       p_stmt_num          => l_stmt_num,
                       p_msg_tokens        => l_msg_tokens,
                       p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED,
                       p_run_log_level     => l_log_level
                     );

                     WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'Error message is ' ||
                          SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED,
                        p_run_log_level     => l_log_level
                     );
                   END IF;

                 END LOOP;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;

              DECLARE
                cursor C_WOR is
                select  resource_id
                from    wip_operation_resources wor
                where   wor.wip_entity_id = l_wip_entity_id
                and     wor.operation_seq_num = l_fm_op_seq_num;
              BEGIN
                FOR rec in C_WOR LOOP
                  UPDATE  WIP_OPERATION_RESOURCES
                  SET     actual_start_date =
                    (SELECT min(start_date)
                    FROM    WIP_RESOURCE_ACTUAL_TIMES wrat
                    WHERE   wrat.wip_entity_id = l_wip_entity_id
                    AND     wrat.operation_seq_num = l_fm_op_seq_num
                    AND     wrat.resource_id = rec.resource_id),
                          actual_completion_date =
                    (SELECT max(end_date)
                    FROM    WIP_RESOURCE_ACTUAL_TIMES wrat
                    WHERE   wrat.wip_entity_id = l_wip_entity_id
                    AND     wrat.operation_seq_num = l_fm_op_seq_num
                    AND     wrat.resource_id = rec.resource_id),
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
                  WHERE   wip_entity_id = l_wip_entity_id
                  AND     operation_seq_num = l_fm_op_seq_num
                  AND     resource_id = rec.resource_id;

                END LOOP;
              END;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
               l_msg_tokens.delete;
               WSM_log_PVT.logMessage (
                 p_module_name     => l_module,
                 p_msg_text          => 'Updated resource usage successfully',
                 p_stmt_num          => l_stmt_num,
                 p_msg_tokens        => l_msg_tokens,
                 p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                 p_run_log_level     => l_log_level
               );
              END IF;

            END IF;--IF (p_jobop_resource_usages_tbls IS NOT NULL)

            l_stmt_num := 253.611;
            UPDATE  WIP_OPERATIONS
            SET     actual_start_date = p_operation_start_date,
                    actual_completion_date = p_operation_completion_date,
                    employee_id = p_employee_id,
                    wsm_bonus_quantity = p_bonus_quantity,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
            WHERE   wip_entity_id = l_wip_entity_id
            AND     operation_seq_num = l_fm_op_seq_num;
            --Bug 5480482:Variable l_wco_to_op_network_end is not needed.
        --Start of changes for bug 5480482
            --l_stmt_num := 253.612;
            --BEGIN
              --if last op update wdj.actual_completion_date
              --SELECT  WCO.network_start_end
              --INTO    l_wco_to_op_network_end
              --FROM    WSM_COPY_OPERATIONS WCO, WIP_OPERATIONS WO
             -- WHERE   WCO.wip_entity_id = WO.wip_entity_id
             -- AND     WCO.operation_seq_num = WO.wsm_op_seq_num
              --AND     WO.wip_entity_id = l_wip_entity_id
             -- AND     WO.operation_seq_num = l_job_to_op_seq_num;
           -- EXCEPTION
             -- WHEN no_data_found THEN
              --  l_wco_to_op_network_end := null;
           -- END;
            --End of changes for bug 5480482

            --bug 5057593
            IF (l_to_intraoperation_step_type = WIP_CONSTANTS.QUEUE) THEN
                IF ((p_sec_uom_code_tbls IS NOT NULL) AND (p_sec_uom_code_tbls.exists(l_header_id))
                AND (p_sec_uom_code_tbls(l_header_id).count > 0))
                THEN
                    FORALL i in p_sec_uom_code_tbls(l_header_id).FIRST..p_sec_uom_code_tbls(l_header_id).LAST
                    UPDATE  WSM_OP_SECONDARY_QUANTITIES
                    SET     move_in_quantity = p_sec_move_out_qty_tbls(l_header_id)(i)
                    WHERE   wip_entity_id = l_wip_entity_id
                    AND     operation_seq_num = l_job_to_op_seq_num
                    AND     uom_code = p_sec_uom_code_tbls(l_header_id)(i);
                END IF; --IF ((p_sec_uom_code_tbls IS NOT NULL)
            END IF; --(l_to_intraoperation_step_type = WIP_CONSTANTS.QUEUE)
            --bug 5057593 end
          END IF; --ELSIF (nvl(p_source_code, 'interface') = 'move out oa page') THEN
          --Bug 5480482:WDJ.actual_start_date should be update only if this is
      --the first move txn.
      --Start of changes for bug 5480482
          --l_stmt_num := 253.613;
          --BEGIN
            --if 1st op update wdj.actual_start_date
            --SELECT  WCO.network_start_end
            --INTO    l_wco_fm_op_network_start
            --FROM    WSM_COPY_OPERATIONS WCO, WIP_OPERATIONS WO
            --WHERE   WCO.wip_entity_id = WO.wip_entity_id
            --AND     WCO.operation_seq_num = WO.wsm_op_seq_num
            --AND     WO.wip_entity_id = l_wip_entity_id
            --AND     WO.operation_seq_num = l_fm_op_seq_num;
          --EXCEPTION
            --WHEN no_data_found THEN
              --l_wco_fm_op_network_start := null;
          --END;

          --IF (l_wco_fm_op_network_start = 'S') OR (l_wco_to_op_network_end = 'E') THEN
            --l_stmt_num := 253.614;
            --UPDATE  WIP_DISCRETE_JOBS
            --SET     actual_start_date = decode(l_wco_fm_op_network_start,
              --                            'S', p_operation_start_date,
                --                          actual_start_date),
    --Bug 4485174: Following update is commented out
    /*
                    actual_completion_date = decode(l_wco_to_op_network_end,
                                              'E', p_operation_completion_date,
                                              actual_completion_date),
    */
            --        LAST_UPDATE_DATE = sysdate,
            --        LAST_UPDATED_BY = g_user_id
            --WHERE   wip_entity_id = l_wip_entity_id;
          --END IF;
           UPDATE  WIP_DISCRETE_JOBS wdj
           SET     actual_start_date = p_operation_start_date,
                   LAST_UPDATE_DATE = sysdate,
                   LAST_UPDATED_BY = g_user_id
           WHERE   wip_entity_id = l_wip_entity_id
           and     not exists (select 1 from wip_move_transactions wmt
                               where wmt.wip_entity_id = wdj.wip_entity_id
                       and   wmt.organization_id = wdj.organization_id
                               and   wmt.transaction_id <> l_transaction_id
                       and   wmt.wsm_undo_txn_id is NULL);
      --End of changes for bug 5480482
        ELSIF (nvl(p_source_code, 'interface') ='undo oa page') THEN

            --Undo of Move Out from 10R to 10TM, 10Q to 10TM, 10R to 20Q, 10Q to 20Q
            --bug 5446252 added (l_fm_intraoperation_step_type = 5) for the case when undoing complete scrap
            IF (((l_fm_intraoperation_step_type = 1) OR (l_fm_intraoperation_step_type = 3) OR (l_fm_intraoperation_step_type = 5))
            AND ((l_to_intraoperation_step_type = 1) OR (l_to_intraoperation_step_type = 2)))
            AND (l_undone_txn_source_code = 'move out oa page')
            THEN --Move Out
                update wsm_op_secondary_quantities
                set MOVE_OUT_QUANTITY = NULL,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_job_to_op_seq_num;

                UPDATE  WSM_JOB_SECONDARY_QUANTITIES WJSQ
                SET     WJSQ.CURRENT_QUANTITY =
                    (SELECT MOVE_IN_QUANTITY
                    FROM    WSM_OP_SECONDARY_QUANTITIES WOSC
                    WHERE   WJSQ.UOM_CODE = WOSC.UOM_CODE
                    AND     WJSQ.wip_entity_id = WOSC.wip_entity_id
                    AND     WOSC.wip_entity_id = l_wip_entity_id
                    AND     WOSC.operation_seq_num = l_job_to_op_seq_num),
                        LAST_UPDATE_DATE = sysdate,
                        LAST_UPDATED_BY = g_user_id
                WHERE   WJSQ.wip_entity_id = l_wip_entity_id;

                update wsm_op_reason_codes
                set QUANTITY = NULL,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id,
                    LAST_UPDATED_LOGIN = g_login_id
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_job_to_op_seq_num;

                l_stmt_num := 253.612;
                --Bug 5480482:WDJ.actual_start_date should be update only if this is
                --undo of first move txn
                --Start of changes for 5480482
                --SELECT  min(operation_seq_num)
                --INTO    l_wo_min_op_seq_num
               -- FROM    WIP_OPERATIONS WO
               -- WHERE   WO.wip_entity_id = l_wip_entity_id;

                --IF (l_job_to_op_seq_num = l_wo_min_op_seq_num) AND (l_to_intraoperation_step_type = 1) THEN
                    --l_stmt_num := 253.614;
                   -- UPDATE  WIP_DISCRETE_JOBS wdj
                   -- SET     actual_start_date = null,
                   --         LAST_UPDATE_DATE = sysdate,
                   --         LAST_UPDATED_BY = g_user_id
                   -- WHERE   wip_entity_id = l_wip_entity_id
                   -- and     not exists (select 1 from wip_move_transactions wmt
                   --            where wmt.wip_entity_id = wdj.wip_entity_id
           --            and   wmt.organization_id = wdj.organization_id
           --            and   wmt.wsm_undo_txn_id is NULL);
                --END IF;
                    --End of changes for 5480482
                --Undo of Move Out from 10Q to 10TM, 10Q to 20Q
                --bug 5446252 added (l_fm_intraoperation_step_type = 5) for the case when undoing complete scrap
                IF (((l_fm_intraoperation_step_type = 1) OR (l_fm_intraoperation_step_type = 3) OR (l_fm_intraoperation_step_type = 5))
                AND (l_to_intraoperation_step_type = 1)) THEN
                --no Move In b4 Move Out
                    DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
                    where wip_entity_id = l_wip_entity_id
                    and operation_seq_num = l_job_to_op_seq_num;

                    UPDATE  WIP_OPERATIONS
                    SET     actual_start_date = null,
                            actual_completion_date = null,
                            employee_id = null,
                            LAST_UPDATE_DATE = sysdate,
                            LAST_UPDATED_BY = g_user_id
                    WHERE   wip_entity_id = l_wip_entity_id
                    AND     operation_seq_num = l_job_to_op_seq_num;

                    --bug 5158378
                    UPDATE WIP_OPERATION_RESOURCES
                    SET    actual_start_date = null,
                           actual_completion_date = null
                    WHERE   wip_entity_id = l_wip_entity_id
                    AND     operation_seq_num = l_job_to_op_seq_num;
                    --end bug 5158378

                --bug 5158378 - OSFMST1: UNDO MOVE TRANSACTION NOT CLEARING THE ACTUAL COMPLETION DATE
                --Added the following ELSIF branch
                --Undo of Move Out from 10R to 10TM, 10R to 20Q
                --bug 5446252 added (l_fm_intraoperation_step_type = 5) for the case when undoing complete scrap
                ELSIF (((l_fm_intraoperation_step_type = 1) OR (l_fm_intraoperation_step_type = 3) OR (l_fm_intraoperation_step_type = 5))
                AND (l_to_intraoperation_step_type = 2)) THEN
                --Move In b4 Move Out

                    UPDATE  WIP_OPERATIONS
                    SET     actual_completion_date = null
                    WHERE   wip_entity_id = l_wip_entity_id
                    AND     operation_seq_num = l_job_to_op_seq_num;

                    UPDATE  WIP_RESOURCE_ACTUAL_TIMES
                    SET     end_date = NULL
                    where wip_entity_id = l_wip_entity_id
                    and operation_seq_num = l_job_to_op_seq_num;

                    UPDATE  WIP_OPERATION_RESOURCES
                    SET     actual_completion_date = null
                    WHERE   wip_entity_id = l_wip_entity_id
                    AND     operation_seq_num = l_job_to_op_seq_num;

/*
                    DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
                    where wip_entity_id = l_wip_entity_id
                    and operation_seq_num = l_job_to_op_seq_num
                    and projected_completion_date IS NULL;
*/
                END IF;
            ELSIF ((l_fm_intraoperation_step_type = 2) AND (l_to_intraoperation_step_type = 1))
            AND (l_undone_txn_source_code = 'move in oa page')
            THEN --Move In

                DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
                where wip_entity_id = l_wip_entity_id
                and operation_seq_num = l_job_to_op_seq_num;

                UPDATE  WIP_OPERATIONS
                SET     actual_start_date = null,
                        projected_completion_date = null,
                        employee_id = null,
                        LAST_UPDATE_DATE = sysdate,
                        LAST_UPDATED_BY = g_user_id
                WHERE   wip_entity_id = l_wip_entity_id
                AND     operation_seq_num = l_fm_op_seq_num;

                --bug 5158378
                UPDATE WIP_OPERATION_RESOURCES
                SET    actual_start_date = null
                WHERE   wip_entity_id = l_wip_entity_id
                AND     operation_seq_num = l_job_to_op_seq_num;
                --end bug 5158378
            END IF;

        END IF; --(nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page'))

        l_stmt_num := 253.7;
        UPDATE  WSM_LOT_MOVE_TXN_INTERFACE
        SET     status = 4,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = g_user_id
        WHERE   header_id = l_header_id;

        l_stmt_num := 253.8;
        IF nvl(p_bonus_quantity, 0) > 0 THEN
            l_stmt_num := 253.9;

            l_wltx_transactions_rec.TRANSACTION_TYPE_ID     := WSMPCNST.UPDATE_QUANTITY;
            l_wltx_transactions_rec.TRANSACTION_DATE        := l_transaction_date;
            l_wltx_transactions_rec.TRANSACTION_REFERENCE   := l_transaction_reference;
            l_wltx_transactions_rec.REASON_ID               := l_reason_id;
            l_wltx_transactions_rec.EMPLOYEE_ID             := p_employee_id;
            l_wltx_transactions_rec.ORGANIZATION_ID         := l_organization_id;

            select wsm_split_merge_transactions_s.nextval
            into l_wltx_transactions_rec.TRANSACTION_ID
            from dual;

            l_wltx_starting_job_tbl(0).WIP_ENTITY_ID          := l_wip_entity_id;
            l_wltx_starting_job_tbl(0).OPERATION_SEQ_NUM      := l_job_to_op_seq_num;

            l_wltx_resulting_job_tbl(0).WIP_ENTITY_ID                := l_wip_entity_id;
            l_wltx_resulting_job_tbl(0).START_QUANTITY               := l_primary_quantity + p_bonus_quantity;
            l_wltx_resulting_job_tbl(0).BONUS_ACCT_ID                := p_bonus_account_id;
            l_wltx_resulting_job_tbl(0).STARTING_OPERATION_SEQ_NUM   := l_fm_op_seq_num;
            l_wltx_resulting_job_tbl(0).SPLIT_HAS_UPDATE_ASSY        := 0;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module,
                p_msg_text          => 'Populated l_wltx_transactions_rec'
                ||'; TRANSACTION_TYPE_ID '
                ||l_wltx_transactions_rec.TRANSACTION_TYPE_ID
                ||'; TRANSACTION_DATE '
                ||l_wltx_transactions_rec.TRANSACTION_DATE
                ||'; TRANSACTION_REFERENCE '
                ||l_wltx_transactions_rec.TRANSACTION_REFERENCE
                ||'; REASON_ID '
                ||l_wltx_transactions_rec.REASON_ID
                ||'; EMPLOYEE_ID '
                ||l_wltx_transactions_rec.EMPLOYEE_ID
                ||'; ORGANIZATION_ID '
                ||l_wltx_transactions_rec.ORGANIZATION_ID
                ||'; TRANSACTION_ID '
                ||l_wltx_transactions_rec.TRANSACTION_ID
                ||'; Populated l_wltx_starting_job_tbl'
                ||'; WIP_ENTITY_ID '
                ||l_wltx_starting_job_tbl(0).WIP_ENTITY_ID
                ||'; OPERATION_SEQ_NUM '
                ||l_wltx_starting_job_tbl(0).OPERATION_SEQ_NUM
                ||'; Populated l_wltx_resulting_job_tbl'
                ||l_wltx_resulting_job_tbl(0).WIP_ENTITY_ID
                ||'; START_QUANTITY '
                ||l_wltx_resulting_job_tbl(0).START_QUANTITY
                ||'; BONUS_ACCT_ID '
                ||l_wltx_resulting_job_tbl(0).BONUS_ACCT_ID,
                p_stmt_num          => l_stmt_num,
                p_msg_tokens        => l_msg_tokens,
                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                p_run_log_level     => l_log_level
              );
            END IF;
            l_stmt_num := 253.10;
            IF ((p_sec_uom_code_tbls IS NOT NULL) AND (p_sec_uom_code_tbls.exists(l_header_id))
            AND (p_sec_uom_code_tbls(l_header_id).count > 0))
            THEN
                FOR i IN p_sec_uom_code_tbls(l_header_id).first..p_sec_uom_code_tbls(l_header_id).last LOOP
                  l_wltx_secondary_qty_tbl(i).wip_entity_name        := l_wip_entity_name;
                  l_wltx_secondary_qty_tbl(i).wip_entity_id          := l_wip_entity_id;
                  l_wltx_secondary_qty_tbl(i).uom_code               := p_sec_uom_code_tbls(l_header_id)(i);
                  l_wltx_secondary_qty_tbl(i).current_quantity       := p_sec_move_out_qty_tbls(l_header_id)(i);
                  IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'Populating l_wltx_secondary_qty_tbl',
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                      );
                  END IF;
                END LOOP;
            END IF; --IF ((p_sec_uom_code_tbls IS NOT NULL)

            l_stmt_num := 253.11;
            IF ((p_jobop_bonus_serials_tbls IS NOT NULL) AND (p_jobop_bonus_serials_tbls.exists(l_header_id))
            AND (p_jobop_bonus_serials_tbls(l_header_id).count > 0))
            THEN
              FOR i in p_jobop_bonus_serials_tbls(l_header_id).first..p_jobop_bonus_serials_tbls(l_header_id).last LOOP
                l_WSM_SERIAL_NUM_TBL(i) := p_jobop_bonus_serials_tbls(l_header_id)(i);
                l_WSM_SERIAL_NUM_TBL(i).action_flag := 1;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                      p_module_name     => l_module,
                      p_msg_text          => 'Populating l_WSM_SERIAL_NUM_TBL '||
                      ';i '||
                      i||
                      ';serial_number '||
                      p_jobop_bonus_serials_tbls(l_header_id)(i).serial_number||
                      ';action_flag '||
                      l_WSM_SERIAL_NUM_TBL(i).action_flag,
                      p_stmt_num          => l_stmt_num,
                      p_msg_tokens        => l_msg_tokens,
                      p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                      p_run_log_level     => l_log_level
                    );
                END IF;
              END LOOP;
            END IF; --IF ((p_jobop_bonus_serials_tbls IS NOT NULL)

            IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
                DECLARE
                    l_start_qty NUMBER;
                BEGIN
                    SELECT start_quantity
                    INTO    l_start_qty
                    FROM    WIP_DISCRETE_JOBS
                    WHERE   wip_entity_id = l_wip_entity_id;

                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                    p_module_name     => l_module,
                    p_msg_text          => 'B4 Calling WSM_WIP_LOT_TXN_PVT.invoke_txn_API '||
                    ';wdj l_start_qty '||
                    l_start_qty,
                    p_stmt_num          => l_stmt_num,
                    p_msg_tokens        => l_msg_tokens,
                    p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
                    p_run_log_level     => l_log_level
                    );
                EXCEPTION
                    WHEN others THEN
                        null;
                END;
            END IF;

            l_stmt_num := 253.12;
            WSM_WIP_LOT_TXN_PVT.invoke_txn_API (
                p_api_version           => 1.0,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                p_init_msg_list         => FND_API.G_FALSE,
                p_calling_mode          => 1,
                p_txn_header_rec        => l_wltx_transactions_rec,
                p_starting_jobs_tbl     => l_wltx_starting_job_tbl,
                p_resulting_jobs_tbl    => l_wltx_resulting_job_tbl,
                p_wsm_serial_num_tbl    => l_WSM_SERIAL_NUM_TBL,
                p_secondary_qty_tbl     => l_wltx_secondary_qty_tbl,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_error_msg             => x_error_msg
             );

            IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
              IF (x_return_status = g_ret_success) THEN
               l_msg_tokens.delete;
               WSM_log_PVT.logMessage (
                 p_module_name     => l_module,
                 p_msg_text          => 'WSM_WIP_LOT_TXN_PVT.invoke_txn_API returned '||
                 ';x_return_status '||
                 x_return_status||
                 ';x_msg_count '||
                 x_msg_count||
                 '; x_error_msg '||
                 x_error_msg,
                 p_stmt_num          => l_stmt_num,
                 p_msg_tokens        => l_msg_tokens,
                 p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
                 p_run_log_level     => l_log_level
               );
              END IF;
            END IF;

            IF (x_return_status = g_ret_error) THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = g_ret_unexpected) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
                IF (x_return_status = g_ret_success) THEN
                 l_msg_tokens.delete;
                 WSM_log_PVT.logMessage (
                   p_module_name     => l_module,
                   p_msg_text          => 'WSM_WIP_LOT_TXN_PVT.invoke_txn_API returned successfully',
                   p_stmt_num          => l_stmt_num,
                   p_msg_tokens        => l_msg_tokens,
                   p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
                   p_run_log_level     => l_log_level
                 );
                END IF;
            END IF;
             l_stmt_num := 253.61;
            UPDATE  WIP_OPERATIONS
            SET     WSM_UPDATE_QUANTITY_TXN_ID = l_wltx_transactions_rec.TRANSACTION_ID,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = g_user_id
            WHERE   wip_entity_id = l_wip_entity_id
            AND     operation_seq_num = l_fm_op_seq_num;

        END IF; --IF nvl(p_bonus_quantity, 0) > 0

        IF (l_put_job_on_hold = 1) THEN
          UPDATE  WIP_DISCRETE_JOBS
          SET     STATUS_TYPE = WIP_CONSTANTS.HOLD,
                  LAST_UPDATE_DATE = sysdate,
                  LAST_UPDATED_BY = g_user_id
          WHERE   wip_entity_id = l_wip_entity_id;
        END IF;
      END IF; --IF (nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page',
--MES END
  --Bug 5368120:For MES txns,update attr move should be called inside the inner loop.
  --            as outside this loop, l_transaction_id and l_scrap_txn_id do not point
  --            to current transaction.
  DECLARE
          l_return_status     VARCHAR2(1);
          l_error_msg         VARCHAR2(2000);
          l_error_count       NUMBER;
          l_move_txn_id       NUMBER := null;
          l_scrap_id          NUMBER := null;
  BEGIN
     IF nvl(p_source_code, 'interface') = 'undo oa page'
     THEN
          l_move_txn_id := l_transaction_id;
          l_scrap_id    := l_scrap_txn_id  ;


          WSM_Serial_support_PVT.Update_attr_move( p_group_id             => NULL           ,
                                                   p_internal_group_id    => NULL  ,
                                                   p_move_txn_id          => l_move_txn_id        ,
                                                   p_scrap_txn_id         => l_scrap_id           ,
                                                   p_organization_id      => null                 ,
                                                   x_return_status        => l_return_status      ,
                                                   x_error_count          => l_error_count        ,
                                                   x_error_msg            => l_error_msg
                                                );

          if l_return_status = FND_API.G_RET_STS_SUCCESS then
                 IF (l_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Update_attr_move returned Success');
               END IF;
           ELSE
                 IF (l_error_count = 1)  THEN
                       fnd_file.put_line(fnd_file.log, l_error_msg);
                 ELSIF (l_error_count > 1)  THEN
                       FOR i IN 1..l_error_count LOOP
                              l_error_msg := fnd_msg_pub.get( p_msg_index => l_error_count - i + 1,
                                                              p_encoded   => FND_API.G_FALSE
                                                            );
                              fnd_file.put_line(fnd_file.log, l_error_msg);
                       END LOOP;
                 ELSE
                       l_error_msg := 'WSM_Serial_support_PVT.Update_attr_move returned failure';
                 END IF;

                 IF (l_debug='Y') THEN
                       fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Update_attr_move returned failure');
                 END IF;
                 -- This call is supposed to not return any error...
                 raise e_proc_exception;

           END IF;
       END IF; --End of  check in source code.
   END;
   --Bug 5368120:End of changes.

    END LOOP; /* end inner loop */

    CLOSE C_TXNS;

    IF (l_inserted_wmti=0) THEN
        IF (g_mrp_debug='Y') THEN
            fnd_file.put_line(fnd_file.log, 'No txns inserted in WMTI');
        END IF;
        EXIT;
    ELSE
        IF (g_mrp_debug='Y') THEN
            fnd_file.put_line(fnd_file.log, 'Inserted '||l_inserted_wmti||' row(s) in WMTI');
        END IF;
    END IF;

    -- MES
    -- ST : Serial MES Fix :
    -- Moved this IF clause to encompass the Serial code as well...
    IF nvl(p_source_code, 'interface') NOT IN ('move in oa page', 'move out oa page', 'move to next op oa page',
        'jump oa page', 'undo oa page' )
    THEN
          -- ST : Serial Support Project --
          -- Temporarily store the Serial Attributes of serial numbers from MSN and
          -- present in WMTI...(use p_group_id)
          DECLARE
                  l_return_status     VARCHAR2(1);
                  l_error_msg     VARCHAR2(2000);
                  l_error_count     NUMBER;

          BEGIN
                 IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                          l_msg_tokens.delete;
                          WSM_log_PVT.logMessage (  p_module_name       => l_module ,
                                                    p_msg_text          => 'B4 calling WSM_Serial_support_PVT.Insert_MOVE_attr',
                                                    p_stmt_num          => l_stmt_num   ,
                                                    p_msg_tokens        => l_msg_tokens   ,
                                                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                                                    p_run_log_level     => l_log_level
                                                  );
                 END IF;

                 l_stmt_num := 253.13;
                 WSM_Serial_support_PVT.Insert_MOVE_attr (  p_group_id       => l_wmti_group_id  ,
                                                            x_return_status  => l_return_status  ,
                                                            x_error_count    => l_error_msg      ,
                                                            x_error_msg      => l_error_count
                                                         );

                 if l_return_status = FND_API.G_RET_STS_SUCCESS then
                        IF (l_debug='Y') THEN
                                 fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Insert_attr_WSTI returned Success');
                        END IF;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                  l_msg_tokens.delete;
                                  WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                          p_msg_text          => 'WSM_Serial_support_PVT.Insert_MOVE_attr returned successfully',
                                                          p_stmt_num          => l_stmt_num   ,
                                                          p_msg_tokens        => l_msg_tokens   ,
                                                          p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                                                          p_run_log_level     => l_log_level
                                                          );
                        END IF;
                  ELSE
                        IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                                  l_msg_tokens.delete;
                                  WSM_log_PVT.logMessage (  p_module_name     => l_module ,
                                                            p_msg_text          => 'WSM_Serial_support_PVT.Insert_MOVE_attr returned error',
                                                            p_stmt_num          => l_stmt_num   ,
                                                            p_msg_tokens        => l_msg_tokens   ,
                                                            p_fnd_log_level     => G_LOG_LEVEL_ERROR  ,
                                                            p_run_log_level     => l_log_level
                                                          );
                        END IF;
                        IF (l_error_count = 1)  THEN
                                  fnd_file.put_line(fnd_file.log, l_error_msg);
                        ELSIF (l_error_count > 1)  THEN
                                 FOR i IN 1..l_error_count LOOP
                                       l_error_msg := fnd_msg_pub.get( p_msg_index => l_error_count - i + 1,
                                                                       p_encoded   => FND_API.G_FALSE
                                                                     );
                                       fnd_file.put_line(fnd_file.log, l_error_msg);
                                 END LOOP;
                        ELSE
                                 l_error_msg := 'WSM_Serial_support_PVT.Insert_attr_WSTI returned failure';
                        END IF;

                        IF (l_debug='Y') THEN
                                fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Insert_attr_WSTI returned failure');
                        END IF;
                        -- This call is supposed to not return any error...
                        raise e_proc_exception;
                END IF;
        END;
        -- ST : Serial Support Project --

        -- ST : Serial MES Fix :  Commented out the below clause and moved it forward..
        -- MES
        -- IF nvl(p_source_code, 'interface') NOT IN ('move in oa page', 'move out oa page', 'move to next op oa page',
        -- 'jump oa page', 'undo oa page' ) THEN

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage( p_module_name       => l_module ,
                                        p_msg_text          => 'B4 calling Wip_movProc_grp.processInterface',
                                        p_stmt_num          => l_stmt_num   ,
                                        p_msg_tokens        => l_msg_tokens   ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                                        p_run_log_level     => l_log_level
                                       );
         END IF;
   /*******
         IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
             DECLARE
                 CURSOR C_WRO IS
                 SELECT  WRO.wip_entity_id,
                         WRO.operation_seq_num,
                         WRO.segment1,
                         WRO.INVENTORY_ITEM_ID,
                         WRO.REQUIRED_QUANTITY,
                         WRO.QUANTITY_ISSUED,
                         WRO.QUANTITY_PER_ASSEMBLY,
                         WRO.QUANTITY_RELIEVED,
                         WRO.COMPONENT_YIELD_FACTOR,
                         WRO.basis_type
                 FROM    wsm_lot_move_txn_interface WLMTI,
                         WIP_REQUIREMENT_OPERATIONS WRO
                 WHERE   WLMTI.group_id = p_group_id
                 AND     WLMTI.wip_entity_id = 1439883
                 AND     WLMTI.wip_entity_id = WRO.wip_entity_id
                 AND     WRO.operation_seq_num IN (10, 20)
                 ORDER BY WRO.wip_entity_id,
                         WRO.operation_seq_num,
                         WRO.segment1;
             BEGIN
                 FOR rec in C_WRO LOOP
                     l_msg_tokens.delete;
                     WSM_log_PVT.logMessage(
                         p_module_name       => l_module ,
                         p_msg_text          => 'B4 calling Wip_movProc_grp.processInterface '||
                         '; wip_entity_id '||rec.wip_entity_id||
                         '; operation_seq_num '||rec.operation_seq_num||
                         '; segment1 '||rec.segment1||
                         '; INVENTORY_ITEM_ID '||rec.INVENTORY_ITEM_ID||
                         '; REQUIRED_QUANTITY '||rec.REQUIRED_QUANTITY||
                         '; QUANTITY_ISSUED '||rec.QUANTITY_ISSUED||
                         '; QUANTITY_PER_ASSEMBLY '||rec.QUANTITY_PER_ASSEMBLY||
                         '; QUANTITY_RELIEVED '||rec.QUANTITY_RELIEVED||
                         '; COMPONENT_YIELD_FACTOR '||rec.COMPONENT_YIELD_FACTOR||
                         '; basis_type '||rec.basis_type
                         ,
                         p_stmt_num          => l_stmt_num   ,
                         p_msg_tokens        => l_msg_tokens   ,
                         p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                         p_run_log_level     => l_log_level
                        );
                 END LOOP;
             END;
         END IF;
*********/



      l_stmt_num := 240;
         Wip_movProc_grp.processInterface(p_groupID      => l_wmti_group_id,
                                          p_commit       => null, --fnd_api.g_true,
                                          x_returnStatus => x_returnStatus);
         /***
         IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
            DECLARE
                CURSOR C_WRO IS
                SELECT  WRO.wip_entity_id,
                        WRO.operation_seq_num,
                        WRO.segment1,
                        WRO.INVENTORY_ITEM_ID,
                        WRO.REQUIRED_QUANTITY,
                        WRO.QUANTITY_ISSUED,
                        WRO.QUANTITY_PER_ASSEMBLY,
                        WRO.QUANTITY_RELIEVED,
                        WRO.COMPONENT_YIELD_FACTOR,
                        WRO.basis_type
                FROM    wsm_lot_move_txn_interface WLMTI,
                        WIP_REQUIREMENT_OPERATIONS WRO
                WHERE   WLMTI.group_id = p_group_id
                AND     WLMTI.wip_entity_id = WRO.wip_entity_id
                AND     WRO.operation_seq_num IN (WLMTI.FM_OPERATION_SEQ_NUM, WLMTI.TO_OPERATION_SEQ_NUM)
                ORDER BY WRO.wip_entity_id,
                        WRO.operation_seq_num,
                        WRO.segment1;
            BEGIN
                FOR rec in C_WRO LOOP
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage(
                        p_module_name       => l_module ,
                        p_msg_text          => 'After calling Wip_movProc_grp.processInterface '||
                        '; wip_entity_id '||rec.wip_entity_id||
                        '; operation_seq_num '||rec.operation_seq_num||
                        '; segment1 '||rec.segment1||
                        '; INVENTORY_ITEM_ID '||rec.INVENTORY_ITEM_ID||
                        '; REQUIRED_QUANTITY '||rec.REQUIRED_QUANTITY||
                        '; QUANTITY_ISSUED '||rec.QUANTITY_ISSUED||
                        '; QUANTITY_PER_ASSEMBLY '||rec.QUANTITY_PER_ASSEMBLY||
                        '; QUANTITY_RELIEVED '||rec.QUANTITY_RELIEVED||
                        '; COMPONENT_YIELD_FACTOR '||rec.COMPONENT_YIELD_FACTOR||
                        '; basis_type '||rec.basis_type
                        ,
                        p_stmt_num          => l_stmt_num   ,
                        p_msg_tokens        => l_msg_tokens   ,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                        p_run_log_level     => l_log_level
                       );
                END LOOP;
            END;
         END IF;
         **/
        IF (x_returnStatus=fnd_api.g_ret_sts_unexp_error) THEN
            --move enh? this logic is based on the fact that after going through osfm validations wip api
            --should not throw any errors and if errors are encountered we will rollback and exit the worker
            --Checks for such errors should be added to osfm validations.
            DECLARE
                cursor c_wtie is
                SELECT  WLMTI.header_id
                        , wtie.transaction_id
                        , wtie.error_message
                FROM    WIP_TXN_INTERFACE_ERRORS wtie,
                        WSM_LOT_MOVE_TXN_INTERFACE WLMTI,
                        WIP_MOVE_TXN_INTERFACE WMTI
                WHERE   WTIE.transaction_id = WMTI.transaction_id
                --FP bug 5178168 (base bug 5168406) changed the line below
                --AND     WMTI.batch_id   = WLMTI.transaction_id
                AND     nvl(WMTI.batch_id, wmti.transaction_id)   = WLMTI.transaction_id
                AND     WMTI.group_id   = l_wmti_group_id
                AND     WLMTI.group_id   = p_group_id;
            BEGIN
                FOR rec in c_wtie LOOP
                    copy_WTIE_to_WIE(x_error_code,
                            x_error_msg,
                            rec.header_id,
                            rec.transaction_id,
                            rec.error_message);
                END LOOP;
            END;
            l_success := 0;
            fnd_file.put_line(fnd_file.log, 'Returned unsuccessfully from Wip_movProc_grp.processInterface');
            IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level) THEN
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Wip_movProc_grp.processInterface returned unexpected failure',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED  ,
                p_run_log_level     => l_log_level
              );
            END IF;
            raise e_proc_exception;
        ELSIF (x_returnStatus=fnd_api.g_ret_sts_success) THEN
            l_wmti_err_txns := 0;

            SELECT  count(*)
            INTO    l_wmti_err_txns
            FROM    WIP_MOVE_TXN_INTERFACE
            WHERE   GROUP_ID=l_wmti_group_id
            AND PROCESS_STATUS = 3;

            IF (g_mrp_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'Returned successfully from Wip_movProc_grp.processInterface');
            END IF;
            IF (l_wmti_err_txns > 0) THEN
                l_success := 0;
            ELSE
              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'Wip_movProc_grp.processInterface returned successfully',
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
                  );
              END IF;
                l_success := 1;
                update_txn_status(x_error_code,
                    x_error_msg,
                    p_group_id,
                    l_wmti_group_id);
            END IF;
            IF (l_success=0) THEN
                IF (G_LOG_LEVEL_ERROR >= l_log_level) THEN
                  l_msg_tokens.delete;
                  WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'Wip_movProc_grp.processInterface returned failure',
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_ERROR  ,
                    p_run_log_level     => l_log_level
                  );
                END IF;
                fnd_file.put_line(fnd_file.log, 'Returned unsuccessfully from Wip_movProc_grp.processInterface');
                raise e_proc_exception;
            END IF;

        END IF;

        --bug 5210799 Update quantity_completed to null if jump from queue
        UPDATE  WIP_OPERATIONS
        SET     quantity_completed = 0
        WHERE   rowid IN
                (
                SELECT  WO.rowid
                FROM    WIP_OPERATIONS WO,
                        WSM_LOT_MOVE_TXN_INTERFACE WLMTI
                WHERE   WLMTI.group_id = p_group_id
                AND     WLMTI.internal_group_id = l_wmti_group_id
                AND     WLMTI.status = 4
                AND     WO.wip_entity_id = WLMTI.wip_entity_id
                AND     WO.operation_seq_num = WLMTI.fm_operation_seq_num
                AND     WO.skip_flag = 1
                );
        --end bug 5210799

      END IF; --p_source_code NOT IN ('move in oa page', 'move out oa page', 'move to next op oa page',

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'B4 UPDATE WIP_OPERATION_YIELDS woy '
            ||';p_group_id '
            ||p_group_id
            ||';l_wmti_group_id '
            ||l_wmti_group_id ,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
          );
        END IF;

        l_stmt_num := 270;

        /* Bug Fix 5969857. Use UNION ALL for wmt.transaction_id instead of wmt.transaction_id in
		 (wlmti.transaction_id, wlmti.internal_scrap_txn_id)*/

        UPDATE WIP_OPERATION_YIELDS woy
            SET    status                = 1,
                   last_update_date      = sysdate,
                   last_update_login     = g_login_id,
                   request_id            = g_request_id,
                   program_application_id= g_program_application_id,
                   program_id            = g_program_id,
                   program_update_date   = DECODE(g_request_id,NULL,NULL,SYSDATE)
            WHERE  woy.rowid IN ((
                   SELECT woy2.rowid
                   FROM   WIP_OPERATIONS         wop2,
                          WIP_OPERATION_YIELDS   woy2,
                          WSM_PARAMETERS         wp,  -- ESA
                          WIP_DISCRETE_JOBS      wdj, -- NSLBJ
                          WIP_MOVE_TRANSACTIONS wmt,
                          WSM_LOT_MOVE_TXN_INTERFACE wlmti
--bug 3615826
--                   WHERE  wmt.group_id          = l_wmti_group_id
                    WHERE   wlmti.group_id = p_group_id
                    --mes commented out the following and added subsequent lines
                    -- AND     wlmti.internal_group_id = l_wmti_group_id;
                    AND (   (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                    'move in oa page', wlmti.transaction_id,
                                                    'move out oa page', wlmti.transaction_id,
                                                    'move to next op oa page', wlmti.transaction_id,
                                                    'jump oa page', wlmti.transaction_id,
                                                    'undo oa page', wlmti.transaction_id,
                                                    l_wmti_group_id)
                            )
                        OR
                            (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                        'move in oa page', wlmti.internal_scrap_txn_id,
                                                        'move out oa page', wlmti.internal_scrap_txn_id,
                                                        'move to next op oa page', wlmti.internal_scrap_txn_id,
                                                        'jump oa page', wlmti.internal_scrap_txn_id,
                                                        'undo oa page', wlmti.internal_scrap_txn_id,
                                                        l_wmti_group_id)
                            )
                        )
                    AND     (wmt.transaction_id =wlmti.transaction_id)
--move enh not needed since we are looking at WMT
--                           AND    wmt.process_phase     = g_move_proc
--                           AND    wmt.process_status    = g_running
--             AND    TRUNC(wti.transaction_date) = to_date(:l_temp_date, WCD_CANONICAL_DATE)   /*bugfix 2856703*/
                   AND    wp.organization_id    = wmt.organization_id  -- ESA
                   AND    nvl(wp.ESTIMATED_SCRAP_ACCOUNTING, 1) = 1    -- ESA
                   AND    wdj.wip_entity_id     = wmt.wip_entity_id    -- NSLBJ
                   AND    wdj.job_type          <>3                    -- NSLBJ
                   AND    wop2.organization_id  = wmt.organization_id
                   AND    wop2.wip_entity_id    = wmt.wip_entity_id
                   AND    woy2.organization_id  = wmt.organization_id
                   AND    woy2.wip_entity_id    = wmt.wip_entity_id
                   AND    woy2.operation_seq_num= wop2.operation_seq_num
                   AND    ( /* Forward Move */
                            ( wop2.operation_seq_num >= wmt.fm_operation_seq_num
                               + DECODE(sign(wmt.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              wop2.operation_seq_num < wmt.to_operation_seq_num
                               + DECODE(sign(wmt.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              ( wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                                OR
                                (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                                 AND wmt.fm_intraoperation_step_type<=g_run
                                 AND wmt.to_intraoperation_step_type>g_run)
                              )
                              AND
                              ( wop2.count_point_type < g_no_manual
                                OR wop2.operation_seq_num = wmt.fm_operation_seq_num
                                OR (wop2.operation_seq_num = wmt.to_operation_seq_num
                                   AND wmt.to_intraoperation_step_type > g_run)
                              )
                            )
                            OR /* Backward Move */
                            ( wop2.operation_seq_num < wmt.fm_operation_seq_num
                               + DECODE(sign(wmt.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              wop2.operation_seq_num >= wmt.to_operation_seq_num
                               + DECODE(sign(wmt.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              ( wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                                OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                                    AND wmt.to_intraoperation_step_type<=g_run
                                    AND wmt.fm_intraoperation_step_type>g_run)
                              )
                              AND
                              ( wop2.count_point_type < g_no_manual
                                OR(wop2.operation_seq_num = wmt.to_operation_seq_num
                                   AND wop2.count_point_type < g_no_manual)
                                OR(wop2.operation_seq_num = wmt.fm_operation_seq_num
                                   AND wmt.fm_intraoperation_step_type > g_run)
                              )
                            )
                          )
                   )
				   UNION ALL
				   (
                   SELECT woy2.rowid
                   FROM   WIP_OPERATIONS         wop2,
                          WIP_OPERATION_YIELDS   woy2,
                          WSM_PARAMETERS         wp,  -- ESA
                          WIP_DISCRETE_JOBS      wdj, -- NSLBJ
                          WIP_MOVE_TRANSACTIONS wmt,
                          WSM_LOT_MOVE_TXN_INTERFACE wlmti
--bug 3615826
--                   WHERE  wmt.group_id          = l_wmti_group_id
                    WHERE   wlmti.group_id = p_group_id
                    --mes commented out the following and added subsequent lines
                    -- AND     wlmti.internal_group_id = l_wmti_group_id;
                    AND (   (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                    'move in oa page', wlmti.transaction_id,
                                                    'move out oa page', wlmti.transaction_id,
                                                    'move to next op oa page', wlmti.transaction_id,
                                                    'jump oa page', wlmti.transaction_id,
                                                    'undo oa page', wlmti.transaction_id,
                                                    l_wmti_group_id)
                            )
                        OR
                            (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                        'move in oa page', wlmti.internal_scrap_txn_id,
                                                        'move out oa page', wlmti.internal_scrap_txn_id,
                                                        'move to next op oa page', wlmti.internal_scrap_txn_id,
                                                        'jump oa page', wlmti.internal_scrap_txn_id,
                                                        'undo oa page', wlmti.internal_scrap_txn_id,
                                                        l_wmti_group_id)
                            )
                        )
                    AND     (wmt.transaction_id = wlmti.internal_scrap_txn_id)
--move enh not needed since we are looking at WMT
--                           AND    wmt.process_phase     = g_move_proc
--                           AND    wmt.process_status    = g_running
--             AND    TRUNC(wti.transaction_date) = to_date(:l_temp_date, WCD_CANONICAL_DATE)   /*bugfix 2856703*/
                   AND    wp.organization_id    = wmt.organization_id  -- ESA
                   AND    nvl(wp.ESTIMATED_SCRAP_ACCOUNTING, 1) = 1    -- ESA
                   AND    wdj.wip_entity_id     = wmt.wip_entity_id    -- NSLBJ
                   AND    wdj.job_type          <>3                    -- NSLBJ
                   AND    wop2.organization_id  = wmt.organization_id
                   AND    wop2.wip_entity_id    = wmt.wip_entity_id
                   AND    woy2.organization_id  = wmt.organization_id
                   AND    woy2.wip_entity_id    = wmt.wip_entity_id
                   AND    woy2.operation_seq_num= wop2.operation_seq_num
                   AND    ( /* Forward Move */
                            ( wop2.operation_seq_num >= wmt.fm_operation_seq_num
                               + DECODE(sign(wmt.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              wop2.operation_seq_num < wmt.to_operation_seq_num
                               + DECODE(sign(wmt.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              ( wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                                OR
                                (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                                 AND wmt.fm_intraoperation_step_type<=g_run
                                 AND wmt.to_intraoperation_step_type>g_run)
                              )
                              AND
                              ( wop2.count_point_type < g_no_manual
                                OR wop2.operation_seq_num = wmt.fm_operation_seq_num
                                OR (wop2.operation_seq_num = wmt.to_operation_seq_num
                                   AND wmt.to_intraoperation_step_type > g_run)
                              )
                            )
                            OR /* Backward Move */
                            ( wop2.operation_seq_num < wmt.fm_operation_seq_num
                               + DECODE(sign(wmt.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              wop2.operation_seq_num >= wmt.to_operation_seq_num
                               + DECODE(sign(wmt.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                              AND
                              ( wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                                OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                                    AND wmt.to_intraoperation_step_type<=g_run
                                    AND wmt.fm_intraoperation_step_type>g_run)
                              )
                              AND
                              ( wop2.count_point_type < g_no_manual
                                OR(wop2.operation_seq_num = wmt.to_operation_seq_num
                                   AND wop2.count_point_type < g_no_manual)
                                OR(wop2.operation_seq_num = wmt.fm_operation_seq_num
                                   AND wmt.fm_intraoperation_step_type > g_run)
                              )
                            )
                          )
                   ));

        IF (g_mrp_debug='Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') :
                    Updated '||SQL%ROWCOUNT||' rows in WOY');
        END IF;
/**********************************
                    UPDATE WIP_OPERATION_YIELDS woy
                    SET    status                = 1,
                           last_update_date      = sysdate,
                           last_update_login     = g_login_id,
                           request_id            = g_request_id,
                           program_application_id= g_program_application_id,
                           program_id            = g_program_id,
                           program_update_date   = DECODE(g_request_id,NULL,NULL,SYSDATE)
                    WHERE  woy.rowid IN (
                           SELECT woy2.rowid
                           FROM   WIP_OPERATIONS         wop2,
                                  WIP_OPERATION_YIELDS   woy2,
                                  WSM_PARAMETERS         wp,  -- ESA
                                  WIP_DISCRETE_JOBS      wdj, -- NSLBJ
                                  WIP_MOVE_TXN_INTERFACE wti
                           WHERE  wti.group_id          = l_wmti_group_id
                           AND    wti.process_phase     = g_move_proc
                           AND    wti.process_status    = g_running
--             AND    TRUNC(wti.transaction_date) = to_date(:l_temp_date, WCD_CANONICAL_DATE)   --bugfix 2856703
                           AND    wp.organization_id    = wti.organization_id  -- ESA
                           AND    nvl(wp.ESTIMATED_SCRAP_ACCOUNTING, 1) = 1    -- ESA
                           AND    wdj.wip_entity_id     = wti.wip_entity_id    -- NSLBJ
                           AND    wdj.job_type          <>3                    -- NSLBJ
                           AND    wop2.organization_id  = wti.organization_id
                           AND    wop2.wip_entity_id    = wti.wip_entity_id
                           AND    woy2.organization_id  = wti.organization_id
                           AND    woy2.wip_entity_id    = wti.wip_entity_id
                           AND    woy2.operation_seq_num= wop2.operation_seq_num
                           AND    ( -- Forward Move
                                    ( wop2.operation_seq_num >= wti.fm_operation_seq_num
                                       + DECODE(sign(wti.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                                      AND
                                      wop2.operation_seq_num < wti.to_operation_seq_num
                                       + DECODE(sign(wti.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                                      AND
                                      ( wti.to_operation_seq_num > wti.fm_operation_seq_num
                                        OR
                                        (wti.to_operation_seq_num = wti.fm_operation_seq_num
                                         AND wti.fm_intraoperation_step_type<=g_run
                                         AND wti.to_intraoperation_step_type>g_run)
                                      )
                                      AND
                                      ( wop2.count_point_type < g_no_manual
                                        OR wop2.operation_seq_num = wti.fm_operation_seq_num
                                        OR (wop2.operation_seq_num = wti.to_operation_seq_num
                                           AND wti.to_intraoperation_step_type > g_run)
                                      )
                                    )
                                    OR --Backward Move
                                    ( wop2.operation_seq_num < wti.fm_operation_seq_num
                                       + DECODE(sign(wti.fm_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                                      AND
                                      wop2.operation_seq_num >= wti.to_operation_seq_num
                                       + DECODE(sign(wti.to_intraoperation_step_type-g_run), 0,0,-1,0,1,1)
                                      AND
                                      ( wti.fm_operation_seq_num > wti.to_operation_seq_num
                                        OR (wti.fm_operation_seq_num = wti.to_operation_seq_num
                                            AND wti.to_intraoperation_step_type<=g_run
                                            AND wti.fm_intraoperation_step_type>g_run)
                                      )
                                      AND
                                      ( wop2.count_point_type < g_no_manual
                                        OR(wop2.operation_seq_num = wti.to_operation_seq_num
                                           AND wop2.count_point_type < g_no_manual)
                                        OR(wop2.operation_seq_num = wti.fm_operation_seq_num
                                           AND wti.fm_intraoperation_step_type > g_run)
                                      )
                                    )
                                  )
                           );
*****************************/


            /* BA: CZH.JUMPENH, new UNDO logic */
        l_stmt_num := 280;
        if (l_undo_exists=1) THEN  /* For undo transaction, set the wsm_undo_txn_id */

            DECLARE
                CURSOR  undo_txns IS
                    SELECT  wlmti.transaction_id,
                         wlmti.organization_id,
                         wlmti.wip_entity_id,
                        wlmti.fm_operation_seq_num,
                        wlmti.to_operation_seq_num,
                        wlmti.to_intraoperation_step_type,
                        wlmti.fm_intraoperation_step_type,
                        wlmti.scrap_quantity,
                        wlmti.source_code --Added for bug 5480482
                    FROM     wsm_lot_move_txn_interface wlmti
                    WHERE    wlmti.group_id = p_group_id
                    AND      wlmti.status = 4
                    AND      wlmti.transaction_type = 4
--move enh 115.135 changed the AND clause for performance
--mes commented out the following and added subsequent lines
--                        AND     wlmti.internal_group_id = l_wmti_group_id;
                    AND (   (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                    'move in oa page', wlmti.transaction_id,
                                                    'move out oa page', wlmti.transaction_id,
                                                    'move to next op oa page', wlmti.transaction_id,
                                                    'jump oa page', wlmti.transaction_id,
                                                    'undo oa page', wlmti.transaction_id,
                                                    l_wmti_group_id)
                            )
/*********
                        OR
                            (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                        'move in oa page', wlmti.internal_scrap_txn_id,
                                                        'move out oa page', wlmti.internal_scrap_txn_id,
                                                        'move to next op oa page', wlmti.internal_scrap_txn_id,
                                                        'jump oa page', wlmti.internal_scrap_txn_id,
                                                        'undo oa page', wlmti.internal_scrap_txn_id,
                                                        l_wmti_group_id)
                            )
*********/
                     );
--                    AND      wlmti.transaction_id IN (SELECT wmt.batch_id
--                    FROM     wip_move_transactions wmt
--                    WHERE   wmt.group_id = l_wmti_group_id);

                l_dup_flag NUMBER :=0;
                undo_jump_from_queue BOOLEAN := FALSE;
            BEGIN
--move enh
                FOR rec IN undo_txns LOOP
                    IF (rec.fm_operation_seq_num <> rec.to_operation_seq_num
                       AND rec.to_intraoperation_step_type=1
                        AND l_charge_jump_from_queue=2) THEN
                           undo_jump_from_queue:=TRUE;
                    END IF;

                    x_return_code := WSMPLBMI.set_undo_txn_id(
                                           rec.organization_id,
                                           rec.wip_entity_id,
                                           --mes replacing l_undo_txn_id with rec.transaction_id
                                           --l_undo_txn_id,
                                           rec.transaction_id,
                                           rec.to_operation_seq_num,
                                           undo_jump_from_queue,
                                           x_err_msg);
                     -- ST : Serial Support Project --
                     -- Add code here to clear the WDJ if serialization is ended...
                     UPDATE wip_discrete_jobs wdj
                     SET    wdj.serialization_start_op = null
                     where  wdj.wip_entity_id = rec.wip_entity_id
                     and    wdj.wip_entity_id IN (select wlbj.wip_entity_id
                                                  from wsm_lot_based_jobs wlbj
                                                  where wlbj.wip_entity_id = rec.wip_entity_id
                                                  and   first_serial_txn_id IS NULL);
                     -- ST : Serial Support Project --
                    --Bug 5480482:Start of changes
                    if nvl(rec.source_code,'interface') = 'undo oa page' then
                       UPDATE  WIP_DISCRETE_JOBS wdj
                       SET     actual_start_date = null,
                            LAST_UPDATE_DATE = sysdate,
                            LAST_UPDATED_BY = g_user_id
                       WHERE   wip_entity_id = rec.wip_entity_id
                       and     not exists (select 1 from wip_move_transactions wmt
                               where wmt.wip_entity_id = wdj.wip_entity_id
                       and   wmt.organization_id = wdj.organization_id
                       and   wmt.wsm_undo_txn_id is NULL);
                    end if;--End of check on source_code.
                    --Bug 5480482EndStart of changes
                  END LOOP;
            END;

            IF (g_mrp_debug='Y') THEN
                fnd_file.put_line(fnd_file.log, 'set_undo_txn_id undo_txn_id= '||l_undo_txn_id);
            END IF;

            IF (x_return_code <> 0) THEN
                fnd_file.put_line(fnd_file.log, 'wip_move_transactions: set wsm_undo_txn_id failed');
            END IF;

        END IF; /* End of if (undo_exists) */
            /* EA: CZH.JUMPENH */

            l_stmt_num := 290;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
            l_msg_tokens.delete;
            WSM_log_PVT.logMessage (
            p_module_name     => l_module,
            p_msg_text          => 'b4 IF (l_ac_ar_exists=1) '||
            ' l_ac_ar_exists '||l_ac_ar_exists,
            p_stmt_num          => l_stmt_num,
            p_msg_tokens        => l_msg_tokens,
            p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
            p_run_log_level     => l_log_level
            );
        END IF;

        IF (l_ac_ar_exists=1) THEN  /* Assy completion/return exists */
            DECLARE
                CURSOR  ac_ar_txns IS
                    SELECT  wlmti.new_wip_entity_name,
                            wlmti.organization_id,  -- CZH.BUG2282570
                            wlmti.wip_entity_id,
                            wlmti.header_id,
                            wlmti.transaction_type, -- CZH.BUG2282570
                            wlmti.transaction_id,
                            wlmti.to_operation_seq_num,
                            wlmti.fm_intraoperation_step_type,
                            wlmti.scrap_quantity,
                            wlmti.transaction_quantity,
                            wlmti.source_code
                    FROM    wsm_lot_move_txn_interface wlmti
                    WHERE    wlmti.group_id = p_group_id
                        AND      wlmti.status = 4
                     /* Added condition to fix bug #1815584 */
                        AND      wlmti.transaction_type in (2,3)
                     /* Assy Completion/return */
                        AND      wlmti.new_wip_entity_name is NOT NULL
--move enh 115.135 changed the AND clause for performance
                        --mes commented out the following and added subsequent lines
--                        AND     wlmti.internal_group_id = l_wmti_group_id;
                        AND (   (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                    'move in oa page', wlmti.transaction_id,
                                                    'move out oa page', wlmti.transaction_id,
                                                    'move to next op oa page', wlmti.transaction_id,
                                                    'jump oa page', wlmti.transaction_id,
                                                    'undo oa page', wlmti.transaction_id,
                                                    l_wmti_group_id)
                                )
                            OR
                                (wlmti.internal_group_id = decode(wlmti.SOURCE_CODE,
                                                        'move in oa page', wlmti.internal_scrap_txn_id,
                                                        'move out oa page', wlmti.internal_scrap_txn_id,
                                                        'move to next op oa page', wlmti.internal_scrap_txn_id,
                                                        'jump oa page', wlmti.internal_scrap_txn_id,
                                                        'undo oa page', wlmti.internal_scrap_txn_id,
                                                        l_wmti_group_id)
                                )
                        );
--                        AND      wlmti.transaction_id IN (SELECT wmt.batch_id
--                                FROM     wip_move_transactions wmt
--                                WHERE   wmt.group_id = l_wmti_group_id);
            BEGIN
                FOR rec IN ac_ar_txns LOOP

                    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (
                        p_module_name     => l_module,
                        p_msg_text          => 'b4 UPDATE wip_entities '||
                        ' rec.new_wip_entity_name '||rec.new_wip_entity_name||
                        ' rec.wip_entity_id '||rec.wip_entity_id,
                        p_stmt_num          => l_stmt_num,
                        p_msg_tokens        => l_msg_tokens,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
                        p_run_log_level     => l_log_level
                        );
                    END IF;

                    l_dup_flag:=0;

                    UPDATE wip_entities
                    SET    wip_entity_name = rec.new_wip_entity_name
                    WHERE  wip_entity_id = rec.wip_entity_id;



                    IF (SQL%ROWCOUNT=0) THEN
                            fnd_file.put_line(fnd_file.log, 'wip_entities : Update failed '||l_new_jobname);
                    ELSE
                        IF (g_mrp_debug='Y') THEN
                            fnd_file.put_line(fnd_file.log, 'updated wip_entity_id= '||l_wip_entity_id||' with the new_job_name '||l_new_jobname);
                        END IF;
                    END IF;

                    l_stmt_num := 290;
                    /* BA: CZH.BUG2282570 */
                    /* for UNDO, set WMT.wsm_undo_txn_id */
                    IF (rec.transaction_type = 3) THEN
                             x_return_code := WSMPLBMI.set_undo_txn_id(rec.organization_id,
                                                                       rec.wip_entity_id,
                                                                       rec.transaction_id,
                                                                       x_err_msg);

                              -- ST : Serial Support Project --
                              -- Add code here to clear the WDJ if serialization is ended...
                              UPDATE wip_discrete_jobs wdj
                              SET    wdj.serialization_start_op = null
                              where  wdj.wip_entity_id = rec.wip_entity_id
                              and    wdj.wip_entity_id IN (select wlbj.wip_entity_id
                                                           from wsm_lot_based_jobs wlbj
                                                           where wlbj.wip_entity_id = rec.wip_entity_id
                                                           and   first_serial_txn_id IS NULL);
                              -- ST : Serial Support Project --
                              --Bug 5480482:Start of changes
                              if nvl(rec.source_code,'interface') = 'undo oa page' then
                                 UPDATE  WIP_DISCRETE_JOBS wdj
                                 SET     actual_start_date = null,
                                      LAST_UPDATE_DATE = sysdate,
                                      LAST_UPDATED_BY = g_user_id
                                 WHERE   wip_entity_id = rec.wip_entity_id
                                 and     not exists (select 1 from wip_move_transactions wmt
                                         where wmt.wip_entity_id = wdj.wip_entity_id
                                         and   wmt.organization_id = wdj.organization_id
                                         and   wmt.wsm_undo_txn_id is NULL);
                              end if;--End of check on source_code.
                              --Bug 5480482EndStart of changes


                    END IF;

                    IF (g_mrp_debug='Y') THEN
                        fnd_file.put_line(fnd_file.log, 'set_undo_txn_id undo_txn_id= '||l_batch_id);
                    END IF;

                    IF (x_return_code <> 0) THEN
                        fnd_file.put_line(fnd_file.log, 'wip_move_transactions: set wsm_undo_txn_id failed');
                    END IF;
            -- Commented for bug 5286219. Code for trf reservation during return txn will be present
            -- before we call move processor.
            /*
            IF (rec.transaction_type = 3)THEN --not normal move or undo
            declare
              l_rsv_exists BOOLEAN;
              l_net_quantity NUMBER;
              l_primary_item_id NUMBER;
              l_msg_count NUMBER;
              l_msg_data     VARCHAR2(2000);
            begin
              select net_quantity,primary_item_id
              into l_net_quantity,l_primary_item_id
              from wip_discrete_jobs
              where wip_entity_id=rec.wip_entity_id
              and organization_id=rec.organization_id;
              l_stmt_num := 290.1;
              wsm_reservations_pvt.modify_reservations_move(
                      p_wip_entity_id         => rec.wip_entity_id,
                      P_inventory_item_id     => l_primary_item_id,
                      P_org_id                => rec.organization_id,
                      P_txn_type              => 3,
                      p_net_qty               => l_net_quantity,
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data
              );
             IF(l_return_status <> 'S') THEN
                raise e_proc_exception;
             END IF;

            END;
            End if;
            */

        --                    END IF;
                            /* EA: CZH.BUG2282570 */

                END LOOP;/* End of While */
            END;

        END IF;   /* End if of Assy completion/return exists */

        -- ST : Serial Project --
        -- Time to update the serial attributes back to the original value after being cleared by the WIP processor...
        if nvl(p_source_code, 'interface') = 'interface' then --Added for Bug 5368120
        DECLARE
                l_return_status     VARCHAR2(1);
                l_error_msg         VARCHAR2(2000);
                l_error_count       NUMBER;
                l_move_txn_id       NUMBER := null;
                l_group_id          NUMBER := null;
                l_scrap_id          NUMBER := null;
                l_internal_group_id NUMBER := null;
        BEGIN
               --Bug 5368120: For MES,call to update_attr_move is handled inside inner loop.
               --             Hence the following code is commented out.
                -- ST : Serial MES Fix : Added this code since p_group_id and l_wmti_group_id arent used for MES
                --IF nvl(p_source_code, 'interface') IN ('move in oa page', 'move out oa page', 'move to next op oa page',
                --                                           'jump oa page', 'undo oa page' )
                --THEN
                --        l_move_txn_id := l_transaction_id;
                --        l_scrap_id    := l_scrap_txn_id  ;
                --ELSE
                        -- normal interface code..
                        l_group_id := p_group_id;
                        l_internal_group_id := l_wmti_group_id;
                --END IF;
                -- ST : Serial MES Fix : End

                WSM_Serial_support_PVT.Update_attr_move( p_group_id             => l_group_id           ,
                                                         p_internal_group_id    => l_internal_group_id  ,
                                                         p_move_txn_id          => l_move_txn_id        ,
                                                         p_scrap_txn_id         => l_scrap_id           ,
                                                         -- Pass the org as NULL since can process across orgs...
                                                         p_organization_id      => null                 ,
                                                         x_return_status        => l_return_status      ,
                                                         x_error_count          => l_error_count        ,
                                                         x_error_msg            => l_error_msg
                                                      );

                if l_return_status = FND_API.G_RET_STS_SUCCESS then
                       IF (l_debug='Y') THEN
                            fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Update_attr_move returned Success');
                       END IF;
                ELSE
                      IF (l_error_count = 1)  THEN
                            fnd_file.put_line(fnd_file.log, l_error_msg);
                      ELSIF (l_error_count > 1)  THEN
                            FOR i IN 1..l_error_count LOOP
                                   l_error_msg := fnd_msg_pub.get( p_msg_index => l_error_count - i + 1,
                                                                   p_encoded   => FND_API.G_FALSE
                                                                 );
                                   fnd_file.put_line(fnd_file.log, l_error_msg);
                            END LOOP;
                      ELSE
                            l_error_msg := 'WSM_Serial_support_PVT.Update_attr_move returned failure';
                      END IF;

                      IF (l_debug='Y') THEN
                            fnd_file.put_line(fnd_file.log, 'WSM_Serial_support_PVT.Update_attr_move returned failure');
                      END IF;
                      -- This call is supposed to not return any error...
                      raise e_proc_exception;

                END IF;
        END;
        end if; --End of check on p_source_code added for bug 5368120.
        -- ST : Serial Project --

        l_stmt_num := 300;
        l_del_profile_value := fnd_profile.value('WSM_INTERFACE_HISTORY_DAYS');

        -- ST : Serial Support Project --
        -- User inserted records...

        -- DELETE wsm_serial_txn_interface
        -- WHERE  header_id in (SELECT header_id
        --         from wsm_lot_move_txn_interface wlmti
        --         WHERE  group_id = l_wmti_group_id
        --         and    status = WIP_CONSTANTS.COMPLETED
        --         AND    transaction_date <= decode(l_del_profile_value, NULL,
        --               transaction_date-1, SYSDATE-l_del_profile_value)
        --              )
        -- AND   action_flag in (1,2,3,4,5,6)
        -- and   transaction_type_id = 2;
        --
        -- -- Delete the inserted records for Attributes...
        -- DELETE wsm_serial_txn_interface
        -- WHERE  header_id IN (Select wmt.transaction_id
        --        from   wip_move_transactions wmt,
        --               wsm_lot_move_txn_interface wlmti
        --        where  wlmti.group_id = l_wmti_group_id
        --        and    wlmti.wip_entity_id = wmt.wip_entity_id
        --        and    wlmti.status =  WIP_CONSTANTS.COMPLETED)
        -- AND transaction_type_id = 5;
        -- ST : Serial Support Project --

        DELETE wsm_lot_move_txn_interface wlmti
        WHERE  status = WIP_CONSTANTS.COMPLETED
        AND    transaction_date <= decode(l_del_profile_value, NULL,
                                          transaction_date-1, SYSDATE-l_del_profile_value)
        RETURNING header_id BULK COLLECT INTO l_header_id_tbl;

        -- ST : Serial Support Project --
        -- User inserted records...
        IF l_header_id_tbl.count > 0 THEN
                forall l_index in l_header_id_tbl.first..l_header_id_tbl.last
                        DELETE wsm_serial_txn_interface
                        WHERE  header_id = l_header_id_tbl(l_index)
                        AND    transaction_type_id = 2;
        END IF;
        -- ST : Serial Support Project --

        /* commit for every successful set of records in the inner loop */
        --mes
        IF (nvl(p_source_code, 'interface') = 'interface') THEN
            COMMIT;
        END IF;
    END LOOP;/* end outer_loop */
    <<outer_loop>>
/****************************
    --mes
    BEGIN
      UPDATE WIP_OPERATIONS
      SET wsm_costed_quantity_completed = quantity_completed
      WHERE   ROWID IN
          (SELECT WO.ROWID
          FROM    WIP_OPERATIONS WO, WIP_MOVE_TRANSACTIONS WMT, WSM_LOT_MOVE_TXN_INTERFACE WLMTI
          WHERE   WLMTI.group_id = p_group_id
          AND     WMT.transaction_id = WLMTI.transaction_id
          AND     WO.wip_entity_id = WMT.wip_entity_id
          AND     (WO.operation_seq_num IN (WMT.fm_operation_seq_num, WMT.to_operation_seq_num))
          AND     NOT (
                    (nvl(WO.quantity_waiting_to_move, 0) <> 0)
                    AND
                    (EXISTS (SELECT    WSMT.ROWID
                              FROM     WSM_SPLIT_MERGE_TRANSACTIONS WSMT,
                                       WSM_SM_RESULTING_JOBS WSRJ
                              WHERE    WSRJ.wip_entity_id = WO.wip_entity_id
                              AND      WSRJ.starting_operation_seq_num = WO.operation_seq_num
                              AND      WSRJ.starting_intraoperation_step = g_tomove
                              AND      WSRJ.transaction_id = WSMT.transaction_id
                            )
                     )
                   )
           );

    END;
*****************************/
    --mes
    IF (nvl(p_source_code, 'interface') = 'interface') THEN
      COMMIT;
    END IF;
    --mes end
    l_stmt_num := 320;

    DECLARE
        CONC_STATUS  BOOLEAN;
        l_tot_count  NUMBER := l_total_txns;
        l_err_count  NUMBER;

    BEGIN
        SELECT count(*)
        INTO   l_err_count
        FROM   wsm_lot_move_txn_interface
        WHERE  group_id = p_group_id
        AND    status = 3;

        IF (l_debug = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_err_count '||l_err_count);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_total_txns '||l_total_txns);
        END IF;

        IF (l_tot_count = l_err_count  AND l_tot_count <>0) THEN
            CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                  'Errors encountered in interface txn, '
                  || 'please check the log file.');
    -- Added to fix bug 1815584 - moved here from error_handler
        ELSIF (l_err_count > 0) THEN
            CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
                      'Errors encountered in interface txn, '
                      || 'please check the log file.');
    -- End additions to fix bug 1815584
        ELSIF ((l_err_count = 0) AND (l_tot_count = 0)) THEN
            CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('COMPLETE', null);
        END IF;
    END;

/*Changes for skaradib*/
--move enh 115.135 added IF condn after perf check
    IF (g_aps_wps_profile='N') THEN
    l_stmt_num := 330;
    DECLARE
        x_group_id NUMBER;
    BEGIN
        x_group_id := WSMPWROT.GET_EXPLOSION_GROUP_ID;
        DELETE from BOM_EXPLOSION_TEMP
        WHERE  group_id = x_group_id;

        WSMPWROT.SET_EXPLOSION_GROUP_ID_NULL;
        COMMIT;
    END;
    END IF;

/*Changes for skaradib*/

    l_stmt_num := 340;
    IF (g_mrp_debug='Y') THEN
        fnd_file.put_line(fnd_file.log,'WSMPLBMI.MoveTransaction Successful ');
    END IF;

    IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'End MoveTransactions Main',
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
                p_run_log_level     => l_log_level
                );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (x_return_status = g_ret_success) THEN
       l_msg_tokens.delete;
       WSM_log_PVT.logMessage (
         p_module_name     => l_module,
         p_msg_text          => 'inside WHEN FND_API.G_EXC_ERROR THEN',
         p_stmt_num          => l_stmt_num,
         p_msg_tokens        => l_msg_tokens,
         p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
         p_run_log_level     => l_log_level
       );
      END IF;
      retcode := 1;
      ROLLBACK;
      UPDATE  wsm_lot_move_txn_interface WLMTI
      SET WLMTI.ERROR = 'Error WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||')',
          WLMTI.STATUS = g_error,
          WLMTI.LAST_UPDATE_DATE = SYSDATE
      WHERE   WLMTI.GROUP_ID = p_group_id
      AND WLMTI.STATUS in (g_pending, g_running) ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_return_status = g_ret_success) THEN
       l_msg_tokens.delete;
       WSM_log_PVT.logMessage (
         p_module_name     => l_module,
         p_msg_text          => 'inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN',
         p_stmt_num          => l_stmt_num,
         p_msg_tokens        => l_msg_tokens,
         p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
         p_run_log_level     => l_log_level
       );
      END IF;
      retcode := -1;
      ROLLBACK;
      UPDATE  wsm_lot_move_txn_interface WLMTI
      SET WLMTI.ERROR = 'Error WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||')',
          WLMTI.STATUS = g_error,
          WLMTI.LAST_UPDATE_DATE = SYSDATE
      WHERE   WLMTI.GROUP_ID = p_group_id
      AND WLMTI.STATUS in (g_pending, g_running) ;

    WHEN e_proc_exception THEN

        retcode := -1;
        errbuf := 'WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') : '||x_error_msg;
        fnd_file.put_line(fnd_file.log, errbuf);
        ROLLBACK;

        UPDATE  wsm_lot_move_txn_interface WLMTI
        SET WLMTI.ERROR = substrb('Error:' ||errbuf, 1, 2000),
            WLMTI.STATUS = g_error,
            WLMTI.LAST_UPDATE_DATE = SYSDATE
        WHERE   WLMTI.GROUP_ID = p_group_id
        AND WLMTI.STATUS in (g_pending, g_running) ;

        IF (g_mrp_debug='Y') THEN
            fnd_file.put_line(fnd_file.log, 'Updated # of txns: '||SQL%ROWCOUNT||' (set WLMTI.error = ErrorMsg)');  /* bugfix 2721366 */
        END IF;

        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                      'errors encountered in interface txn, please check the log file.');

        --mes
        IF (nvl(p_source_code, 'interface') = 'interface') THEN
            COMMIT;
        END IF;

    WHEN my_exception THEN

         l_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('COMPLETE', null);
         ROLLBACK;
         --COMMIT;

    WHEN OTHERS THEN
        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)     OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
          WSM_log_PVT.handle_others(
            p_module_name           => l_module     ,
             p_stmt_num             => l_stmt_num   ,
             p_fnd_log_level        => G_LOG_LEVEL_UNEXPECTED ,
             p_run_log_level        => l_log_level
          );
        END IF;

        retcode := SQLCODE;
        errbuf :='WSMPLBMI.MoveTransaction' ||'(stmt_num='||l_stmt_num||') : '||sqlerrm;
        fnd_file.put_line(fnd_file.log, errbuf);
        ROLLBACK;

        UPDATE  wsm_lot_move_txn_interface WLMTI
        SET WLMTI.ERROR = substrb('Unexpected SQL Error:' ||errbuf, 1, 2000),
            WLMTI.STATUS = g_error,
            WLMTI.LAST_UPDATE_DATE = SYSDATE
        WHERE   WLMTI.GROUP_ID = p_group_id
        AND WLMTI.STATUS in (g_pending, g_running) ;

        IF (g_mrp_debug='Y') THEN
            fnd_file.put_line(fnd_file.log, 'Updated # of txns: '||SQL%ROWCOUNT||' (set WLMTI.error = ErrorMsg)');  /* bugfix 2721366 */
        END IF;

        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                      'errors encountered in interface txn, please check the log file.');

        --mes
        IF (nvl(p_source_code, 'interface') = 'interface') THEN
            COMMIT;
        END IF;

END MoveTransaction;

/****************************************************************************
Called from Move Out page via Rosetta wrapper for processing Move Transaction. This in turn inserts
the data into the interface table and calls the overloaded MoveTransaction procedure.
****************************************************************************/

  Procedure MoveTransaction(
      p_group_id                              IN NUMBER,
      p_transaction_id                        IN NUMBER,
      p_source_code                           IN VARCHAR2,
      p_TRANSACTION_TYPE                      IN NUMBER,
      p_ORGANIZATION_ID                       IN NUMBER,
      p_WIP_ENTITY_ID                         IN NUMBER,
      p_WIP_ENTITY_NAME                       IN VARCHAR2,
      p_primary_item_id                       IN NUMBER,
      p_TRANSACTION_DATE                      IN DATE,
      p_FM_OPERATION_SEQ_NUM                  IN NUMBER,
      p_FM_OPERATION_CODE                     IN VARCHAR2,
      p_FM_DEPARTMENT_ID                      IN NUMBER,
      p_FM_DEPARTMENT_CODE                    IN VARCHAR2,
      p_FM_INTRAOPERATION_STEP_TYPE           IN NUMBER,
      p_TO_OPERATION_SEQ_NUM                  IN NUMBER,
      p_TO_OPERATION_CODE                     IN VARCHAR2,
      p_TO_DEPARTMENT_ID                      IN NUMBER,
      p_TO_DEPARTMENT_CODE                    IN VARCHAR2,
      p_TO_INTRAOPERATION_STEP_TYPE           IN NUMBER,
      p_PRIMARY_QUANTITY                      IN NUMBER,
      p_low_yield_trigger_limit               IN NUMBER,
      p_primary_uom                           IN VARCHAR2,
      p_SCRAP_ACCOUNT_ID                      IN NUMBER,
      p_REASON_ID                             IN NUMBER,
      p_REASON_NAME                           IN VARCHAR2,
      p_REFERENCE                             IN VARCHAR2,
      p_QA_COLLECTION_ID                      IN NUMBER,
      p_JUMP_FLAG                             IN VARCHAR2,
      p_HEADER_ID                             IN NUMBER,
      p_PRIMARY_SCRAP_QUANTITY                IN NUMBER,
      p_bonus_quantity                        IN NUMBER,
      p_SCRAP_AT_OPERATION_FLAG               IN NUMBER,
      p_bonus_account_id                      IN NUMBER,
      p_employee_id                           IN NUMBER,
      p_operation_start_date                  IN DATE,
      p_operation_completion_date             IN DATE,
      p_expected_completion_date              IN DATE,
      p_mtl_txn_hdr_id                        IN NUMBER,
      p_sec_uom_code_tbl                     IN t_sec_uom_code_tbl_type,
      p_sec_move_out_qty_tbl                 IN t_sec_move_out_qty_tbl_type,
      p_jobop_scrap_serials_tbl              IN WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL,
      p_jobop_bonus_serials_tbl              IN WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL,
      p_scrap_codes_tbl                      IN t_scrap_codes_tbl_type,
      p_scrap_code_qty_tbl                   IN t_scrap_code_qty_tbl_type,
      p_bonus_codes_tbl                      IN t_bonus_codes_tbl_type,
      p_bonus_code_qty_tbl                   IN t_bonus_code_qty_tbl_type,
      p_jobop_resource_usages_tbl            IN t_jobop_res_usages_tbl_type,
      x_wip_move_api_sucess_msg               OUT NOCOPY VARCHAR2
      , x_return_status                       OUT NOCOPY VARCHAR2
      , x_msg_count                           OUT NOCOPY NUMBER
      , x_msg_data                            OUT NOCOPY VARCHAR2
  )
  IS
      l_sec_uom_code_tbls                     t_sec_uom_code_tbls_type;
      l_sec_move_out_qty_tbls                 t_sec_move_out_qty_tbls_type;
      l_scrap_codes_tbls                      t_scrap_codes_tbls_type;
      l_scrap_code_qty_tbls                   t_scrap_code_qty_tbls_type;
      l_bonus_codes_tbls                      t_bonus_codes_tbls_type;
      l_bonus_code_qty_tbls                   t_bonus_code_qty_tbls_type;
      l_jobop_scrap_serials_tbls                t_scrap_serials_tbls_type ;
      l_jobop_bonus_serials_tbls                t_bonus_serials_tbls_type ;
      l_jobop_resource_usages_tbls              t_jobop_res_usages_tbls_type;

      l_transaction_id                          NUMBER;
      l_group_id                                NUMBER;
      l_header_id                   NUMBER;
      TYPE t_err_msg_tbl_type                   IS TABLE OF VARCHAR2(240);
      l_err_msg_tbl                             t_err_msg_tbl_type;
      l_stmt_num                                NUMBER;
      retcode                                     NUMBER;
      errbuf                                      VARCHAR2(4000);
      x_message                                   VARCHAR2(4000);
      x_msg_index                                 NUMBER;

      -- Logging variables.....
      l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
      l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.MoveTransactions.html';
      l_param_tbl                             WSM_Log_PVT.param_tbl_type;
      x_error_count                           NUMBER;
      x_return_code                           NUMBER;
      x_error_msg                             VARCHAR2(4000);
  BEGIN
      x_return_status := G_RET_SUCCESS;
      IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
            l_msg_tokens.delete;
            WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'Begin MoveTransactions html',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
                  p_run_log_level     => l_log_level
                  );
      END IF;

      IF G_LOG_LEVEL_PROCEDURE >= l_log_level THEN

          l_param_tbl.delete;
          l_param_tbl(1).paramName := 'p_group_id';
          l_param_tbl(1).paramValue := p_group_id;
          l_param_tbl(2).paramName := 'p_transaction_id';
          l_param_tbl(2).paramValue := p_transaction_id;
          l_param_tbl(3).paramName := 'p_source_code';
          l_param_tbl(3).paramValue := p_source_code;
          l_param_tbl(4).paramName := 'p_transaction_type';
          l_param_tbl(4).paramValue := p_transaction_type;
          l_param_tbl(5).paramName := 'p_organization_id';
          l_param_tbl(5).paramValue := p_organization_id;
          l_param_tbl(6).paramName := 'p_wip_entity_id';
          l_param_tbl(6).paramValue := p_wip_entity_id;
          l_param_tbl(7).paramName := 'p_wip_entity_name';
          l_param_tbl(7).paramValue := p_wip_entity_name;
          l_param_tbl(8).paramName := 'p_primary_item_id';
          l_param_tbl(8).paramValue := p_primary_item_id;
          l_param_tbl(9).paramName := 'p_transaction_date';
          l_param_tbl(9).paramValue := p_transaction_date;
          l_param_tbl(10).paramName := 'p_fm_operation_seq_num';
          l_param_tbl(10).paramValue := p_fm_operation_seq_num;
          l_param_tbl(11).paramName := 'p_fm_operation_code';
          l_param_tbl(11).paramValue := p_fm_operation_code;
          l_param_tbl(12).paramName := 'p_fm_department_id';
          l_param_tbl(12).paramValue := p_fm_department_id;
          l_param_tbl(13).paramName := 'p_fm_department_code';
          l_param_tbl(13).paramValue := p_fm_department_code;
          l_param_tbl(14).paramName := 'p_fm_intraoperation_step_type';
          l_param_tbl(14).paramValue := p_fm_intraoperation_step_type;
          l_param_tbl(15).paramName := 'p_to_operation_seq_num';
          l_param_tbl(15).paramValue := p_to_operation_seq_num;
          l_param_tbl(16).paramName := 'p_to_operation_code';
          l_param_tbl(16).paramValue := p_to_operation_code;
          l_param_tbl(17).paramName := 'p_to_department_id';
          l_param_tbl(17).paramValue := p_to_department_id;
          l_param_tbl(18).paramName := 'p_to_department_code';
          l_param_tbl(18).paramValue := p_to_department_code;
          l_param_tbl(19).paramName := 'p_to_intraoperation_step_type';
          l_param_tbl(19).paramValue := p_to_intraoperation_step_type;
          l_param_tbl(20).paramName := 'p_primary_quantity';
          l_param_tbl(20).paramValue := p_primary_quantity;
          l_param_tbl(21).paramName := 'p_low_yield_trigger_limit';
          l_param_tbl(21).paramValue := p_low_yield_trigger_limit;
          l_param_tbl(22).paramName := 'p_primary_uom';
          l_param_tbl(22).paramValue := p_primary_uom;
          l_param_tbl(23).paramName := 'p_scrap_account_id';
          l_param_tbl(23).paramValue := p_scrap_account_id;
          l_param_tbl(24).paramName := 'p_reason_id';
          l_param_tbl(24).paramValue := p_reason_id;
          l_param_tbl(25).paramName := 'p_reason_name';
          l_param_tbl(25).paramValue := p_reason_name;
          l_param_tbl(26).paramName := 'p_reference';
          l_param_tbl(26).paramValue := p_reference;
          l_param_tbl(27).paramName := 'p_qa_collection_id';
          l_param_tbl(27).paramValue := p_qa_collection_id;
          l_param_tbl(28).paramName := 'p_jump_flag';
          l_param_tbl(28).paramValue := p_jump_flag;
          l_param_tbl(29).paramName := 'p_header_id';
          l_param_tbl(29).paramValue := p_header_id;
          l_param_tbl(30).paramName := 'p_primary_scrap_quantity';
          l_param_tbl(30).paramValue := p_primary_scrap_quantity;
          l_param_tbl(31).paramName := 'p_bonus_quantity';
          l_param_tbl(31).paramValue := p_bonus_quantity;
          l_param_tbl(32).paramName := 'p_scrap_at_operation_flag';
          l_param_tbl(32).paramValue := p_scrap_at_operation_flag;
          l_param_tbl(33).paramName := 'p_bonus_account_id';
          l_param_tbl(33).paramValue := p_bonus_account_id;
          l_param_tbl(34).paramName := 'p_employee_id';
          l_param_tbl(34).paramValue := p_employee_id;
          l_param_tbl(35).paramName := 'p_operation_start_date';
          l_param_tbl(35).paramValue := p_operation_start_date;
          l_param_tbl(36).paramName := 'p_operation_completion_date';
          l_param_tbl(36).paramValue := p_operation_completion_date;
          l_param_tbl(37).paramName := 'p_expected_completion_date';
          l_param_tbl(37).paramValue := p_expected_completion_date;
          l_param_tbl(38).paramName := 'p_mtl_txn_hdr_id';
          l_param_tbl(38).paramValue := p_mtl_txn_hdr_id;

          WSM_Log_PVT.logProcParams(p_module_name   => l_module   ,
                  p_param_tbl     => l_param_tbl,
                  p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE
                  );
      END IF;

      l_stmt_num := 10;

      DELETE FROM WSM_INTERFACE_ERRORS WHERE header_id = p_header_id;

      IF (p_transaction_type IN (1, 2)) THEN
          DECLARE
              l_mti_rows      NUMBER;
              l_mtli_rows     NUMBER;
              l_msni_rows     NUMBER;
              l_numErrRows    NUMBER;
              l_numTempRows   NUMBER;
              x_trans_count   NUMBER;
              type err_tbl_t is table of varchar2(240);
              type item_tbl_t is table of varchar2(2000);
              l_errExplTbl err_tbl_t;
              l_itemNameTbl item_tbl_t;
          BEGIN
            BEGIN
              select count(*)
              into l_mti_rows
              from MTL_TRANSACTIONS_INTERFACE
              where transaction_header_id = p_mtl_txn_hdr_id;
            EXCEPTION
              WHEN no_data_found THEN
                l_mti_rows := 0;
            END;

            IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
/*************
                BEGIN
                  select count(*)
                  into l_mtli_rows
                  from mtl_serial_numbers_interface
                  where transaction_header_id = p_mtl_txn_hdr_id;
                EXCEPTION
                  WHEN no_data_found THEN
                    l_mti_rows := 0;
                END;

              BEGIN
                select count(*)
                into l_mti_rows
                from mtl_serial_numbers_interface
                where transaction_header_id = p_mtl_txn_hdr_id;
              EXCEPTION
                WHEN no_data_found THEN
                  l_mti_rows := 0;
              END;
**************/
              DECLARE
                CURSOR C_MTLI IS
                SELECT  MTLI.TRANSACTION_INTERFACE_ID, MTLI.LOT_NUMBER, MTLI.TRANSACTION_QUANTITY,
                        MTLI.PRIMARY_QUANTITY
                FROM    mtl_transaction_lots_interface MTLI,
                        mtl_transactions_interface MTI
                WHERE   MTI.TRANSACTION_HEADER_ID = p_mtl_txn_hdr_id
                AND     MTI.TRANSACTION_INTERFACE_ID = MTLI.TRANSACTION_INTERFACE_ID;
              BEGIN
                FOR rec in C_MTLI LOOP
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                        p_module_name     => l_module ,
                        p_msg_text          => 'B4 call to INV_TXN_MANAGER_GRP.Validate_Transactions: '
                        ||'p_mtl_txn_hdr_id: '
                        ||p_mtl_txn_hdr_id
                        ||'MTLI.TRANSACTION_INTERFACE_ID: '
                        ||rec.TRANSACTION_INTERFACE_ID
                        ||'MTLI.LOT_NUMBER: '
                        ||rec.LOT_NUMBER
                        ||'MTLI.TRANSACTION_QUANTITY: '
                        ||rec.TRANSACTION_QUANTITY
                        ||'MTLI.PRIMARY_QUANTITY: '
                        ||rec.PRIMARY_QUANTITY,
                        p_stmt_num          => l_stmt_num   ,
                        p_msg_tokens        => l_msg_tokens   ,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                        p_run_log_level     => l_log_level
                    );
                END LOOP;
              END;
              l_msg_tokens.delete;
              WSM_log_PVT.logMessage (
                    p_module_name     => l_module ,
                    p_msg_text          => 'B4 call to INV_TXN_MANAGER_GRP.Validate_Transactions: '
                    ||'Number of mti rows: '
                    ||l_mti_rows,
                    p_stmt_num          => l_stmt_num   ,
                    p_msg_tokens        => l_msg_tokens   ,
                    p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                    p_run_log_level     => l_log_level
              );
            END IF;

            IF (l_mti_rows > 0) THEN


              UPDATE  MTL_TRANSACTIONS_INTERFACE MTL
              SET     MTL.wip_entity_type = WIP_CONSTANTS.LOTBASED,
              	      --bug 5584140 operation_seq_num is already stamped in the UI and there could be multiple
              	      --operation seq nums so don't overwrite. Get department_id for each operation
                      --operation_seq_num = p_fm_operation_seq_num,
                      --department_id = p_fm_department_id
                      MTL.department_id = (SELECT department_id
                      			FROM  WIP_OPERATIONS WO
                      			WHERE WO.wip_entity_id = p_wip_entity_id
                      			AND   WO.operation_seq_num = MTL.operation_seq_num)
              WHERE   MTL.transaction_header_id = p_mtl_txn_hdr_id;

              retcode := INV_TXN_MANAGER_GRP.Validate_Transactions(
                              p_api_version           => 1.0,
                              p_init_msg_list         => fnd_api.g_false,
                              p_validation_level      => fnd_api.g_valid_level_full,
                              p_header_id             => p_mtl_txn_hdr_id,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data,
                              x_trans_count           => x_trans_count);

              select count(*)
              into l_numErrRows
              from mtl_transactions_interface
              where transaction_header_id = p_mtl_txn_hdr_id;

              select count(*)
              into l_numTempRows
              from mtl_material_transactions_temp
              where transaction_header_id = p_mtl_txn_hdr_id;

              IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'B4 call to INV_TXN_MANAGER_GRP.Validate_Transactions: '
                  ||'Number of mti rows: '
                  ||l_numErrRows
                  ||'; Number of mmtt rows: '
                  ||l_numTempRows,
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                  p_run_log_level     => l_log_level
                );
              END IF;

              IF (x_return_status = g_ret_success) THEN
                  if(l_numErrRows <> 0) then
                    select msik.concatenated_segments, mti.error_explanation
                    bulk collect into l_itemNameTbl,l_errExplTbl
                    from mtl_transactions_interface mti,
                    mtl_system_items_kfv msik
                    where mti.transaction_header_id = p_mtl_txn_hdr_id
                    and mti.error_explanation is not null
                    and mti.inventory_item_id = msik.inventory_item_id
                    and mti.organization_id = msik.organization_id;

                    for i in 1..l_itemNameTbl.count loop
                      fnd_message.set_name('WIP', 'WIP_TMPINSERT_ERR');
                      fnd_message.set_token('ITEM_NAME', l_itemNameTbl(i));
                      fnd_message.set_token('ERR_MSG', l_errExplTbl(i));
                      fnd_msg_pub.add;
                      fnd_msg_pub.get
                      (   p_msg_index     => fnd_msg_pub.G_NEXT - 1,
                        p_encoded       => 'T',
                        p_data          => x_message,
                        p_msg_index_out => x_msg_index
                      );
                      IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (
                          p_module_name     => l_module ,
                          p_msg_text          => 'Error from INV_TXN_MANAGER_GRP.Validate_Transactions '||x_message,
                          p_stmt_num          => l_stmt_num   ,
                          p_msg_tokens        => l_msg_tokens   ,
                          p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                          p_run_log_level     => l_log_level
                        );
                      END IF;
                    end loop;

                    RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                          p_module_name     => l_module ,
                          p_msg_text          => 'After call to INV_TXN_MANAGER_GRP.Validate_Transactions: '||
                            'x_return_status '||x_return_status||
                            '; no of rows in mmtt '||l_numTempRows,
                          p_stmt_num          => l_stmt_num   ,
                          p_msg_tokens        => l_msg_tokens   ,
                          p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                          p_run_log_level     => l_log_level
                    );
                  END IF;
                ELSIF (x_return_status = g_ret_error) THEN
                  IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                      l_msg_tokens.delete;
                      WSM_log_PVT.logMessage (
                        p_module_name     => l_module ,
                        p_msg_text          => 'Error from INV_TXN_MANAGER_GRP.Validate_Transactions '
                        ||x_msg_data,
                        p_stmt_num          => l_stmt_num   ,
                        p_msg_tokens        => l_msg_tokens   ,
                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                        p_run_log_level     => l_log_level
                      );
                    END IF;
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF (x_return_status = g_ret_unexpected) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF; --(l_mti_rows > 0)
        END;
      ELSE --p_transaction_type IN (g_undo_txn, g_ret_txn)
        WSM_Serial_support_GRP.populate_components(
          p_wip_entity_id     => p_wip_entity_id,
          p_organization_id   => p_organization_id,
          p_move_txn_id       => p_transaction_id,
          p_move_txn_type     => p_transaction_type,
          p_txn_date          => p_transaction_date,
          p_mtl_txn_hdr_id    => p_mtl_txn_hdr_id,
          p_compl_txn_id      => null,
          x_return_status     => x_return_status,
          x_error_count       => x_msg_count,
          x_error_msg         => x_msg_data
         );

        IF (x_return_status = g_ret_error) THEN
         RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = g_ret_unexpected) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN

            DECLARE
                l_mmtt_rows NUMBER;
                l_mtlt_rows NUMBER;
                l_msnt_rows NUMBER;
            BEGIN

                SELECT  count(*)
                INTO    l_mmtt_rows
                FROM    mtl_material_transactions_temp
                WHERE   transaction_header_id = p_mtl_txn_hdr_id;

                SELECT  count(*)
                INTO    l_mtlt_rows
                FROM    mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_header_id = p_mtl_txn_hdr_id
                AND     mtlt.TRANSACTION_TEMP_ID = mmtt.TRANSACTION_TEMP_ID;

                SELECT  count(*)
                INTO    l_msnt_rows
                FROM    mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_header_id = p_mtl_txn_hdr_id
                AND     msnt.TRANSACTION_TEMP_ID = mmtt.TRANSACTION_TEMP_ID;

                IF (x_return_status = g_ret_success) THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage (
                      p_module_name     => l_module ,
                      p_msg_text          => 'WSM_Serial_support_GRP.populate_components returned successfully '||
                      ';l_mmtt_rows '||
                      l_mmtt_rows||
                      ';l_mtlt_rows '||
                      l_mtlt_rows||
                      ';l_msnt_rows '||
                      l_msnt_rows,
                      p_stmt_num          => l_stmt_num   ,
                      p_msg_tokens        => l_msg_tokens   ,
                      p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
                      p_run_log_level     => l_log_level
                    );
                END IF;
            END;
        END IF;

      END IF; --p_transaction_type IN (g_undo_txn, g_ret_txn)

      DELETE FROM WSM_LOT_MOVE_TXN_INTERFACE WHERE header_id = p_header_id;

      INSERT into WSM_LOT_MOVE_TXN_INTERFACE
          (
          --  INTERFACE_ID -- commented for bugfix 7163496
            TRANSACTION_ID
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATED_BY_NAME
          , CREATION_DATE
          , CREATED_BY
          , CREATED_BY_NAME
          , LAST_UPDATE_LOGIN
          , GROUP_ID
          , SOURCE_CODE
          , STATUS
          , TRANSACTION_TYPE
          , ORGANIZATION_ID
          , ORGANIZATION_CODE
          , WIP_ENTITY_ID
          , WIP_ENTITY_NAME
          , ENTITY_TYPE
          , PRIMARY_ITEM_ID
          , TRANSACTION_DATE
          , FM_OPERATION_SEQ_NUM
          , FM_OPERATION_CODE
          , FM_DEPARTMENT_ID
          , FM_DEPARTMENT_CODE
          , FM_INTRAOPERATION_STEP_TYPE
          , TO_OPERATION_SEQ_NUM
          , TO_OPERATION_CODE
          , TO_DEPARTMENT_ID
          , TO_DEPARTMENT_CODE
          , TO_INTRAOPERATION_STEP_TYPE
          , TRANSACTION_QUANTITY
          , TRANSACTION_UOM
          , PRIMARY_QUANTITY
          , PRIMARY_UOM
          , SCRAP_ACCOUNT_ID
          , REASON_ID
          , REASON_NAME
          , REFERENCE
          , ATTRIBUTE_CATEGORY
          , ATTRIBUTE1
          , ATTRIBUTE2
          , ATTRIBUTE3
          , ATTRIBUTE4
          , ATTRIBUTE5
          , ATTRIBUTE6
          , ATTRIBUTE7
          , ATTRIBUTE8
          , ATTRIBUTE9
          , ATTRIBUTE10
          , ATTRIBUTE11
          , ATTRIBUTE12
          , ATTRIBUTE13
          , ATTRIBUTE14
          , ATTRIBUTE15
          , QA_COLLECTION_ID
          , JUMP_FLAG
          , HEADER_ID
          , PRIMARY_SCRAP_QUANTITY
          , SCRAP_QUANTITY
          , SCRAP_AT_OPERATION_FLAG
      )
      VALUES
      (
        --    NULL  -- commented for bugfix 7163496
            p_transaction_id
          , sysdate --LAST_UPDATE_DATE
          , g_user_id --LAST_UPDATED_BY
          , fnd_global.user_name --LAST_UPDATED_BY_NAME
          , sysdate --CREATION_DATE
          , g_user_id --CREATED_BY
          , fnd_global.user_name--CREATED_BY_NAME
          , g_login_id --LAST_UPDATE_LOGIN
          , WIP_TRANSACTIONS_S.NEXTVAL --p_group_id --GROUP_ID
          , p_source_code --source_code
          , WIP_CONSTANTS.PENDING --STATUS
          , p_TRANSACTION_TYPE
          , p_ORGANIZATION_ID
          , null --!! ORGANIZATION_CODE
          , p_WIP_ENTITY_ID
          , p_WIP_ENTITY_NAME
          , WIP_CONSTANTS.LOTBASED --!!ENTITY_TYPE
          , null --PRIMARY_ITEM_ID
          , nvl(p_TRANSACTION_DATE, sysdate)
          , p_FM_OPERATION_SEQ_NUM
          , p_FM_OPERATION_CODE
          , p_FM_DEPARTMENT_ID
          , p_FM_DEPARTMENT_CODE
          , p_FM_INTRAOPERATION_STEP_TYPE
          , p_TO_OPERATION_SEQ_NUM
          , p_TO_OPERATION_CODE
          , p_TO_DEPARTMENT_ID
          , p_TO_DEPARTMENT_CODE
          , p_TO_INTRAOPERATION_STEP_TYPE
          , p_PRIMARY_QUANTITY --TRANSACTION_QUANTITY
          , p_PRIMARY_UOM --TRANSACTION_UOM
          , p_PRIMARY_QUANTITY
          , p_PRIMARY_UOM
          , p_SCRAP_ACCOUNT_ID
          , p_REASON_ID
          , p_REASON_NAME
          , p_REFERENCE
          , null --ATTRIBUTE_CATEGORY
          , null --ATTRIBUTE1
          , null --ATTRIBUTE2
          , null --ATTRIBUTE3
          , null --ATTRIBUTE4
          , null --ATTRIBUTE5
          , null --ATTRIBUTE6
          , null --ATTRIBUTE7
          , null --ATTRIBUTE8
          , null --ATTRIBUTE9
          , null --ATTRIBUTE10
          , null --ATTRIBUTE11
          , null --ATTRIBUTE12
          , null --ATTRIBUTE13
          , null --ATTRIBUTE14
          , null --ATTRIBUTE15
          , p_QA_COLLECTION_ID
          , p_JUMP_FLAG
          , nvl(p_HEADER_ID, wsm_lot_move_txn_interface_s.nextval) --HEADER_ID
          , p_PRIMARY_SCRAP_QUANTITY --PRIMARY_SCRAP_QUANTITY
          , p_PRIMARY_SCRAP_QUANTITY --SCRAP_QUANTITY
          , decode(p_primary_scrap_quantity, --bug 5584140 Added decode so that SCRAP_AT_OPERATION_FLAG=null when there is no scrap
          	null, null,
          	0, null,
          	1) --SCRAP_AT_OPERATION_FLAG
          )
          RETURNING transaction_id, group_id, header_id INTO l_transaction_id, l_group_id, l_header_id;

      l_stmt_num := 20;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
            l_msg_tokens.delete;
            WSM_log_PVT.logMessage (
              p_module_name     => l_module,
              p_msg_text          => 'B4 UPDATE  wsm_lot_move_txn_interface wlmti '||
              ';g_user_id '||
              g_user_id||
              ';fnd_global.user_name '||
              fnd_global.user_name,
              p_stmt_num          => l_stmt_num,
              p_msg_tokens        => l_msg_tokens,
              p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
              p_run_log_level     => l_log_level
            );
        END IF;

      l_stmt_num := 30;
      l_sec_uom_code_tbls(l_header_id)        := p_sec_uom_code_tbl;
      l_sec_move_out_qty_tbls(l_header_id)                 := p_sec_move_out_qty_tbl;
      l_scrap_codes_tbls(l_header_id)                      := p_scrap_codes_tbl;
      l_scrap_code_qty_tbls(l_header_id)                   := p_scrap_code_qty_tbl;
      l_bonus_codes_tbls(l_header_id)                      := p_bonus_codes_tbl;
      l_bonus_code_qty_tbls(l_header_id)                   := p_bonus_code_qty_tbl;
      l_jobop_scrap_serials_tbls(l_header_id)              :=   p_jobop_scrap_serials_tbl ;
      l_jobop_bonus_serials_tbls(l_header_id)              :=   p_jobop_bonus_serials_tbl ;
      l_jobop_resource_usages_tbls(l_header_id)            :=   p_jobop_resource_usages_tbl;
      l_stmt_num := 40;

      l_stmt_num := 50;
      MoveTransaction(
        p_group_id                              => l_group_id,
        p_bonus_account_id                      => p_bonus_account_id,
        p_employee_id                           => p_employee_id,
        p_operation_start_date                  => p_operation_start_date,
        p_operation_completion_date             => p_operation_completion_date,
        p_expected_completion_date              => p_expected_completion_date,
        p_bonus_quantity                        => p_bonus_quantity,
        p_low_yield_trigger_limit               => p_low_yield_trigger_limit,
        p_source_code                           => p_source_code,
        p_mtl_txn_hdr_id                        => p_mtl_txn_hdr_id,
        p_sec_uom_code_tbls                     => l_sec_uom_code_tbls,
        p_sec_move_out_qty_tbls                 => l_sec_move_out_qty_tbls,
        p_jobop_scrap_serials_tbls              => l_jobop_scrap_serials_tbls,
        p_jobop_bonus_serials_tbls              => l_jobop_bonus_serials_tbls,
        p_scrap_codes_tbls                      => l_scrap_codes_tbls,
        p_scrap_code_qty_tbls                   => l_scrap_code_qty_tbls,
        p_bonus_codes_tbls                      => l_bonus_codes_tbls,
        p_bonus_code_qty_tbls                   => l_bonus_code_qty_tbls,
        p_jobop_resource_usages_tbls            => l_jobop_resource_usages_tbls,
        x_wip_move_api_sucess_msg               => x_wip_move_api_sucess_msg,
        retcode                                 => retcode,
        errbuf                                  => errbuf
      );

      IF (x_return_status = g_ret_success) THEN
         l_msg_tokens.delete;
         WSM_log_PVT.logMessage (
           p_module_name     => l_module,
           p_msg_text          => 'WSMPLBMI.MoveTransaction returned '||
           ';x_wip_move_api_sucess_msg '||
           x_wip_move_api_sucess_msg||
           ';retcode '||
           retcode||
           ';errbuf '||
           errbuf,
           p_stmt_num          => l_stmt_num,
           p_msg_tokens        => l_msg_tokens,
           p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE,
           p_run_log_level     => l_log_level
         );
      END IF;

      l_stmt_num := 60;
/*
      DECLARE
        cursor C_WIE IS
        SELECT  message
        FROM    WSM_INTERFACE_ERRORS
        WHERE   transaction_id = l_transaction_id;

        i INTEGER := 0;
      BEGIN
        OPEN C_WIE;
        FETCH C_WIE BULK COLLECT INTO l_err_msg_tbl;
        CLOSE C_WIE;

        LOOP
          IF l_err_msg_tbl.exists(i) THEN
            FND_MESSAGE.set_encoded(l_err_msg_tbl(i));
            FND_MSG_PUB.add;
            i := i+1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END;
*/
      IF retcode > 0 THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF retcode < 0 THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (   p_count             =>      x_msg_count         ,
          p_data              =>      x_msg_data
      );

      IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
            l_msg_tokens.delete;
            WSM_log_PVT.logMessage (
                  p_module_name     => l_module ,
                  p_msg_text          => 'End MoveTransactions html',
                  p_stmt_num          => l_stmt_num   ,
                  p_msg_tokens        => l_msg_tokens   ,
                  p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
                  p_run_log_level     => l_log_level
                  );
      END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK;
              x_return_status := G_RET_ERROR;
              FND_MSG_PUB.Count_And_Get
              (   p_count             =>      x_msg_count         ,
                  p_data              =>      x_msg_data
              );


          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK;
              x_return_status := G_RET_UNEXPECTED;
              FND_MSG_PUB.Count_And_Get
              (   p_count             =>      x_msg_count         ,
                  p_data              =>      x_msg_data
              );

          WHEN OTHERS THEN
           ROLLBACK;
               x_return_status := G_RET_UNEXPECTED;

               IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)      OR
                 (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
               THEN
                  WSM_log_PVT.handle_others( p_module_name        => l_module         ,
                                 p_stmt_num           => l_stmt_num       ,
                                 p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                 p_run_log_level      => l_log_level
                               );
              END IF;

              FND_MSG_PUB.Count_And_Get
              (   p_count             =>      x_msg_count         ,
                  p_data              =>      x_msg_data
              );

    END;

/****************************************************************************
Called from the Move Out page to set the page properties
****************************************************************************/

    Procedure getMoveOutPageProperties(
          p_organization_id                     IN NUMBER
        , p_wip_entity_id                       IN NUMBER
        , p_operation_seq_num                   IN NUMBER
        , p_routing_operation                   IN NUMBER
        , p_job_type                            IN NUMBER
        , p_current_step                        IN NUMBER
        , p_user_id                             IN NUMBER
        , x_last_operation                      OUT NOCOPY NUMBER
        , x_estimated_scrap_accounting          OUT NOCOPY NUMBER
        , x_show_next_op_by_default             OUT NOCOPY NUMBER
        , x_multiple_res_usage_dates            OUT NOCOPY NUMBER
        , x_show_scrap_codes                    OUT NOCOPY NUMBER
        , x_scrap_codes_defined                 OUT NOCOPY NUMBER
        , x_bonus_codes_defined                 OUT NOCOPY NUMBER
        , x_show_lot_attrib                     OUT NOCOPY NUMBER
        , x_show_scrap_serials                  OUT NOCOPY NUMBER
        , x_show_serial_region                  OUT NOCOPY NUMBER
        , x_show_secondary_quantities           OUT NOCOPY NUMBER
        , x_transaction_type                    OUT NOCOPY NUMBER
        , x_quality_region                      OUT NOCOPY VARCHAR2
        , x_show_scrap_qty                      OUT NOCOPY NUMBER
        , x_show_next_op_choice                 OUT NOCOPY NUMBER
        , x_show_next_op                        OUT NOCOPY NUMBER
        , x_employee_id                         OUT NOCOPY NUMBER
        , x_operator                            OUT NOCOPY VARCHAR2
        , x_default_start_date                  OUT NOCOPY DATE
        , x_default_completion_date             OUT NOCOPY DATE
        , x_return_status                       OUT NOCOPY VARCHAR2
        , x_msg_count                           OUT NOCOPY NUMBER
        , x_msg_data                            OUT NOCOPY VARCHAR2
    )
    IS
        l_bos_use_org_settings NUMBER;
        l_bos_show_next_op_by_default NUMBER;
        l_bos_show_scrap_codes NUMBER;
        l_bos_show_lot_attrib NUMBER;
        l_bos_mul_res_usage_dates NUMBER;
        l_bos_to_move_mandatory_flag NUMBER;
        l_bos_run_mandatory_flag NUMBER;

        l_wsm_show_next_op_by_default NUMBER;
        l_wsm_mul_res_usage_dates NUMBER;
        l_wsm_move_in NUMBER;
        l_wsm_move_to_next_op NUMBER;

        l_wip_queue_enabled_flag NUMBER;
        l_wip_run_enabled_flag NUMBER;
        l_wip_to_move_enabled_flag NUMBER;
        l_wip_scrap_enabled_flag NUMBER;

        l_osfm_quality_txn_number                 NUMBER;
        l_serialization_start_op                  NUMBER;
        l_end_routing_operation                   NUMBER;
        l_stmt_num                                NUMBER;
        l_serialization_started                   NUMBER := 0; --bug 5444062 initialize to 0
        l_job_type                                NUMBER;
        l_first_serial_txn_id                     NUMBER; --bug 5444062
    -- Logging variables.....
        l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
        l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.getMoveOutPageProperties';
        l_param_tbl                             WSM_Log_PVT.param_tbl_type;
        l_next_links_exist                      NUMBER := 0; --bug 5531107
        x_error_count                           NUMBER;
        x_return_code                           NUMBER;
        x_error_msg                             VARCHAR2(4000);
    BEGIN
/*
        fnd_global.apps_initialize(user_id => 1008623,
                                                 resp_id => 56236,
                                         resp_appl_id => 724);
*/
--      delete from debug_sk;
--      debug_pkg.ins('session_id '||fnd_global.session_id);
        x_return_status := g_ret_success;
        IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
          l_msg_tokens.delete;
          WSM_log_PVT.logMessage (
                p_module_name     => l_module ,
                p_msg_text          => 'Begin getMoveOutPageProperties  '||
                '; p_organization_id '||p_organization_id||
                ' ;p_wip_entity_id '||p_wip_entity_id||
                ' ;p_operation_seq_num '||p_operation_seq_num||
                ' ;p_routing_operation '||p_routing_operation||
                ' ;p_job_type '||p_job_type||
                ' ;p_current_step '||p_current_step||
                ' ;p_user_id '||p_user_id,
                p_stmt_num          => l_stmt_num   ,
                p_msg_tokens        => l_msg_tokens   ,
                p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
                p_run_log_level     => l_log_level
                );
        END IF;

    l_stmt_num := 10;
    --SELECT  queue_enabled_flag, run_enabled_flag, to_move_enabled_flag, scrap_enabled_flag
    --Bug 5051836:Replaced wip_parameters_v with wvis to fix the
    --share memory violation
    SELECT  DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,1,1,0)),0,2,1),
            DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,2,1,0)),0,2,1),
            DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,3,
            DECODE(WVIS.RECORD_CREATOR,'USER',1,0),0)),0,2,1),
            DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,5,1,0)),0,2,1)
    INTO    l_wip_queue_enabled_flag, l_wip_run_enabled_flag, l_wip_to_move_enabled_flag, l_wip_scrap_enabled_flag
    --FROM    WIP_PARAMETERS_V
    FROM    WIP_VALID_INTRAOPERATION_STEPS WVIS
    WHERE   organization_id = p_organization_id;

    l_stmt_num := 20;
    SELECT  nvl(show_next_op_by_default, 0),
        nvl(track_multi_usage_dates, 0), nvl(move_in_option, 2), nvl(move_to_next_op_option, 2)
    INTO    l_wsm_show_next_op_by_default,
        l_wsm_mul_res_usage_dates, l_wsm_move_in, l_wsm_move_to_next_op
    FROM    WSM_PARAMETERS
    WHERE   organization_id = p_organization_id;

    l_stmt_num := 30;
    /********bug 5463926 Always look at BSO instead of BOS. For the case of non standard operation
    trap the no data found exception and set the values

    IF (p_routing_operation IS NOT NULL) THEN
      --bug 5300662 change the interpretation of NULL value for the column use_org_settings to YES
      --SELECT  nvl(BOS.use_org_settings, 0), nvl(BOS.show_next_op_by_default, 0),
      --bug 5463926
      SELECT  nvl(BOS.use_org_settings, 1), nvl(BOS.show_next_op_by_default, 0),
        nvl(BOS.show_scrap_code, 0), nvl(BOS.show_lot_attrib, 0),
        nvl(BOS.track_multiple_res_usage_dates, 0), nvl(BOS.to_move_mandatory_flag, 0),
        reference_flag
      INTO    l_bos_use_org_settings, l_bos_show_next_op_by_default,
        x_show_scrap_codes, l_bos_show_lot_attrib, l_bos_mul_res_usage_dates,
        l_bos_to_move_mandatory_flag, l_reference_flag
      FROM    BOM_OPERATION_SEQUENCES BOS, WIP_OPERATIONS WO
      WHERE   WO.wip_entity_id            = p_wip_entity_id
      AND     WO.operation_seq_num        = p_operation_seq_num
      AND     BOS.operation_sequence_id   = WO.operation_sequence_id;
    ELSE
      --bug 5300662 change the interpretation of NULL value for the column use_org_settings to YES
      --SELECT  nvl(BSO.use_org_settings, 0), nvl(BSO.show_next_op_by_default, 0),
      SELECT  nvl(BSO.use_org_settings, 1), nvl(BSO.show_next_op_by_default, 0),
      nvl(BSO.show_scrap_code, 0), nvl(BSO.show_lot_attrib, 0),
      nvl(BSO.track_multiple_res_usage_dates, 0), nvl(BSO.to_move_mandatory_flag, 0)
      INTO    l_bos_use_org_settings, l_bos_show_next_op_by_default,
        x_show_scrap_codes, l_bos_show_lot_attrib, l_bos_mul_res_usage_dates,
        l_bos_to_move_mandatory_flag
      FROM    BOM_STANDARD_OPERATIONS BSO, WIP_OPERATIONS WO
      WHERE   WO.wip_entity_id            = p_wip_entity_id
      AND     WO.operation_seq_num        = p_operation_seq_num
      AND     BSO.standard_operation_id   = WO.standard_operation_id
      AND     BSO.organization_id         = WO.organization_id;
    END IF;
    ********/
    BEGIN
      SELECT  nvl(BSO.use_org_settings, 1), nvl(BSO.show_next_op_by_default, 0),
        nvl(BSO.show_scrap_code, 0), nvl(BSO.show_lot_attrib, 0),
        nvl(BSO.track_multiple_res_usage_dates, 0), nvl(BSO.to_move_mandatory_flag, 0)
      INTO    l_bos_use_org_settings, l_bos_show_next_op_by_default,
        x_show_scrap_codes, l_bos_show_lot_attrib, l_bos_mul_res_usage_dates,
        l_bos_to_move_mandatory_flag
      FROM    BOM_STANDARD_OPERATIONS BSO, WIP_OPERATIONS WO
      WHERE   WO.wip_entity_id            = p_wip_entity_id
      AND     WO.operation_seq_num        = p_operation_seq_num
      AND     BSO.standard_operation_id   = WO.standard_operation_id
      AND     BSO.organization_id         = WO.organization_id;
    EXCEPTION
      WHEN no_data_found THEN
         l_bos_use_org_settings := 1;
         l_bos_show_next_op_by_default := 0;
         x_show_scrap_codes := 0;
         l_bos_show_lot_attrib := 0;
         l_bos_mul_res_usage_dates := 0;
         l_bos_to_move_mandatory_flag := 0;
    END;
    --bug 5463926 end

    l_stmt_num := 40;
    SELECT  operation_seq_num
    INTO    l_end_routing_operation
    FROM    WSM_COPY_OPERATIONS WCO
    WHERE   WCO.wip_entity_id = p_wip_entity_id
    AND     WCO.network_start_end = 'E';

    l_stmt_num := 50;
    SELECT  WO.actual_start_date, WO.employee_id, nvl(WO.actual_completion_date, sysdate)
    INTO    x_default_start_date, x_employee_id, x_default_completion_date
    FROM    WIP_OPERATIONS WO
    WHERE   WO.wip_entity_id = p_wip_entity_id
    AND     WO.operation_seq_num = p_operation_seq_num;

    IF (l_end_routing_operation = p_routing_operation) THEN
        x_last_operation := 1;
    ELSE
        x_last_operation := 0;
    END IF;

/******* Moved to the Txn Validation API******
    l_stmt_num := 60;
    IF l_wip_to_move_enabled_flag = 2 THEN
        IF l_bos_use_org_settings = 1 THEN
            IF l_wsm_move_to_next_op = 1 THEN
                IF g_log_level_error >= l_log_level OR
                FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage(
                        p_module_name       => l_module,
                        p_msg_name          => 'WSM_MES_WIP_WSM_MOVE',
                        p_msg_appl_name     => 'WSM',
                        p_msg_tokens        => l_msg_tokens,
                        p_stmt_num          => l_stmt_num,
                        p_fnd_msg_level     => G_MSG_LVL_ERROR,
                        p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                        p_run_log_level     => l_log_level
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            IF l_bos_to_move_mandatory_flag = 1 THEN
                IF g_log_level_error >= l_log_level OR
                FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN
                    l_msg_tokens.delete;
                    WSM_log_PVT.logMessage(
                        p_module_name       => l_module,
                        p_msg_name          => 'WSM_MES_WIP_BOS_MOVE',
                        p_msg_appl_name     => 'WSM',
                        p_msg_tokens        => l_msg_tokens,
                        p_stmt_num          => l_stmt_num,
                        p_fnd_msg_level     => G_MSG_LVL_ERROR,
                        p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                        p_run_log_level     => l_log_level
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;
************************/
/******* This should get trapped in the move txn allowed api******
    l_stmt_num := 70;
    IF (p_current_step = g_queue)
    AND (((l_bos_use_org_settings = 1) AND (l_bos_run_mandatory_flag = 1))
        OR
        ((l_bos_use_org_settings <> 1) AND (l_wsm_move_in = 1)))
    THEN
        IF g_log_level_error >= l_log_level OR
        FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
        THEN
            l_msg_tokens.delete;
            WSM_log_PVT.logMessage(
                p_module_name       => l_module,
                p_msg_name          => 'WSM_MES_MOVE_OUT_RUN_MAND',
                p_msg_appl_name     => 'WSM',
                p_msg_tokens        => l_msg_tokens,
                p_stmt_num          => l_stmt_num,
                p_fnd_msg_level     => G_MSG_LVL_ERROR,
                p_fnd_log_level     => G_LOG_LEVEL_ERROR,
                p_run_log_level     => l_log_level
            );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
********/
    IF l_wip_scrap_enabled_flag = 2 THEN
        x_show_scrap_qty := 0;
    ELSE
        x_show_scrap_qty := 1;
    END IF;

    l_stmt_num := 80;
    x_estimated_scrap_accounting := wsmputil.wsm_esa_enabled(
                                        p_wip_entity_id => p_wip_entity_id,
                                        err_code        => x_return_code,
                                        err_msg         => x_error_msg,
                                        p_org_id        => p_organization_id,
                                        p_job_type      => p_job_type
                                     );

    l_stmt_num := 90;
    BEGIN
      SELECT  1
      INTO    x_show_secondary_quantities
      FROM    dual
      WHERE   EXISTS(
                SELECT  'secondary quantities exist'
                FROM    WSM_OP_SECONDARY_QUANTITIES
                WHERE   wip_entity_id = p_wip_entity_id
                AND     operation_seq_num = p_operation_seq_num

              );
    EXCEPTION
      WHEN no_data_found THEN
        x_show_secondary_quantities := 0;
    END;

    l_stmt_num := 100;
/********bug 5182689 modified the SELECT below to account for the case when serialization_start_op is null
    SELECT  decode(first_serial_txn_id,
              null, decode(serialization_start_op,
                      p_routing_operation, 1,
                      0), 1)
************/
    /****bug 5444062 Replaced the sql below with a sql getting the values and logic in pl/sql for determining
    l_serialization_started
    SELECT  decode(first_serial_txn_id,
              null, decode(serialization_start_op,
                      null, 0,
                      decode(serialization_start_op,
                        p_routing_operation, 1,
                        0)),
              1)
    INTO    l_first_serial_txn_id
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_wip_entity_id;
    ******/
    SELECT  first_serial_txn_id, serialization_start_op
    INTO    l_first_serial_txn_id, l_serialization_start_op
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_wip_entity_id;

    --serialization started
    IF (l_first_serial_txn_id IS NOT NULL) THEN
        l_serialization_started := 1;
    ELSE
        --job outside routing
        IF (p_routing_operation IS NULL) THEN
            l_serialization_started := 0;
        --assembly is serial controlled tracked and job is at last operation
        ELSIF (l_serialization_start_op IS NOT NULL) and (p_routing_operation = l_end_routing_operation) THEN
            l_serialization_started := 1;
        --job is at serialization op
        ELSIF (l_serialization_start_op = p_routing_operation) THEN
            l_serialization_started := 1;
        END IF;
    END IF;
    --end bug 5444062

    IF (l_serialization_started = 0) OR (l_wip_scrap_enabled_flag = 2) THEN
        x_show_scrap_serials := 0;
    ELSE
        x_show_scrap_serials := 1;
    END IF;

    x_show_serial_region := l_serialization_started;

    l_stmt_num := 110;
    BEGIN
      SELECT  1
      INTO    x_scrap_codes_defined
      FROM    dual
      WHERE   EXISTS(
                SELECT  'scrap codes exist'
                FROM    WSM_OP_REASON_CODES
                WHERE   wip_entity_id = p_wip_entity_id
                --bug 5191223 Added the condition operation_seq_num = p_operation_seq_num
                AND     operation_seq_num = p_operation_seq_num
                AND     code_type = 1
              );
    EXCEPTION
      WHEN no_data_found THEN
        x_scrap_codes_defined := 0;
    END;

    l_stmt_num := 120;
    BEGIN
      SELECT  1
      INTO    x_bonus_codes_defined
      FROM    dual
      WHERE   EXISTS(
                SELECT  'bonus codes exist'
                FROM    WSM_OP_REASON_CODES
                WHERE   wip_entity_id = p_wip_entity_id
                --bug 5191223 Added the condition operation_seq_num = p_operation_seq_num
                AND     operation_seq_num = p_operation_seq_num
                AND     code_type = 2
              );
    EXCEPTION
      WHEN no_data_found THEN
        x_bonus_codes_defined := 0;
    END;

    IF l_bos_use_org_settings = 1 THEN
        x_multiple_res_usage_dates := l_wsm_mul_res_usage_dates;
    ELSE
        x_multiple_res_usage_dates := l_bos_mul_res_usage_dates;
    END IF;
/********************
    IF l_wip_to_move_enabled_flag = 2 AND l_wsm_move_to_next_op = 1 THEN
        x_show_next_op_choice := 0;
        x_show_next_op := 1;
        x_show_next_op_by_default := 1;
    ELSE
        x_show_next_op_choice := 1;
        x_show_next_op := 1;
        IF (l_bos_use_org_settings = 1) AND (l_wsm_show_next_op_by_default = 1) THEN
            x_show_next_op_by_default := 1;
        ELSIF (l_bos_use_org_settings = 0) AND (l_bos_show_next_op_by_default = 1) THEN
            x_show_next_op_by_default := 1;
        ELSE
            x_show_next_op_by_default := 2;
        END IF;
    END IF;
**********************/
    x_show_next_op_choice := 1;
    x_show_next_op := 1;
    x_show_next_op_by_default := 1;

    IF (l_wip_to_move_enabled_flag = 2) THEN
        x_show_next_op_choice := 0;
        x_show_next_op := 1;
        x_show_next_op_by_default := 1;
    ELSE
        IF (l_bos_use_org_settings = 1) AND (l_wsm_move_to_next_op = 0) THEN
            x_show_next_op_choice := 1;
            IF (l_wsm_show_next_op_by_default = 1) THEN
                x_show_next_op := 1;
                x_show_next_op_by_default := 1;
            ELSE
                x_show_next_op := 0;
                x_show_next_op_by_default := 2;
            END IF;
        ELSIF (l_bos_use_org_settings = 1) AND (l_wsm_move_to_next_op = 1) THEN
            x_show_next_op_choice := 0;
            x_show_next_op_by_default := 2;
            x_show_next_op := 0;
        ELSIF (l_bos_use_org_settings = 1) AND (l_wsm_move_to_next_op = 2) THEN
            x_show_next_op_choice := 0;
            x_show_next_op_by_default := 1;
            x_show_next_op := 1;
        ELSIF (l_bos_use_org_settings <> 1) AND (l_bos_to_move_mandatory_flag = 1) THEN
            x_show_next_op_choice := 0;
            x_show_next_op_by_default := 2;
            x_show_next_op := 0;
        ELSIF (l_bos_use_org_settings <> 1) AND (l_bos_to_move_mandatory_flag <> 1) THEN
            x_show_next_op_choice := 1;
            IF (l_bos_show_next_op_by_default = 1) THEN
                x_show_next_op_by_default := 1;
                x_show_next_op := 1;
            ELSE
                x_show_next_op_by_default := 2;
                x_show_next_op := 0;
            END IF;
        END IF;
    END IF;

    --bug 5531107 check if next operation links exist
    BEGIN
        SELECT  1
        INTO    l_next_links_exist
        FROM    dual
        WHERE   EXISTS
            (SELECT 'next_links_exist'
             FROM   wsm_copy_op_networks wcon
             WHERE  wcon.wip_entity_id = p_wip_entity_id
             AND    wcon.from_op_seq_num = p_routing_operation
            );
    EXCEPTION
        WHEN no_data_found THEN
            l_next_links_exist := 0;
    END;

    --bug 5531107 Reset the values depending on the existence of next operation links
    IF (l_next_links_exist = 0) THEN
        IF (x_show_next_op_choice = 1) THEN
            x_show_next_op_choice := 0;
        END IF;

        IF (x_show_next_op = 1) THEN
            x_show_next_op := 0;
        END IF;

        IF (x_show_next_op_by_default = 1) THEN
            x_show_next_op_by_default := 2;
        END IF;
    END IF;
    --end bug 5531107
    x_show_lot_attrib := l_bos_show_lot_attrib;

    l_stmt_num := 130;
    l_osfm_quality_txn_number := 23;
    x_quality_region := QA_TXN_GRP.qa_enabled(
                          p_txn_number  => l_osfm_quality_txn_number,
                          p_org_id      => p_organization_id
                        );
--!!hardcode
--    x_quality_region := 'F';

    IF (l_end_routing_operation = p_routing_operation) THEN
      x_transaction_type := WIP_CONSTANTS.COMP_TXN;
      x_show_next_op_choice := 0;
      x_show_next_op := 0;
      x_show_next_op_by_default := 2;
    ELSIF (p_routing_operation IS NULL) THEN
      x_transaction_type := WIP_CONSTANTS.MOVE_TXN;
      x_show_next_op_choice := 0;
      x_show_next_op := 0;
      x_show_next_op_by_default := 2;
    ELSE
      x_transaction_type := WIP_CONSTANTS.MOVE_TXN;
    END IF;

    l_stmt_num := 140;
    IF x_employee_id IS NULL THEN
        SELECT  FU.employee_id
        INTO    x_employee_id
        FROM    FND_USER FU
        WHERE   FU.user_id = p_user_id;
    END IF;

    l_stmt_num := 150;
    IF (x_employee_id is NOT NULL) THEN
      BEGIN
        SELECT DISTINCT(PPF.FULL_NAME) FULL_NAME
        INTO    x_operator
        FROM    PER_PEOPLE_F PPF
        WHERE   PPF.person_id = x_employee_id;
      EXCEPTION
        WHEN no_data_found THEN
          x_operator := null;
      END;
    END IF;

    FND_MSG_PUB.Count_And_Get
    (   p_count             =>      x_msg_count         ,
        p_data              =>      x_msg_data
    );

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module ,
        p_msg_text          => 'End procedure getMoveOutPageProperties '
        ||';x_last_operation '
        ||x_last_operation
        ||';x_estimated_scrap_accounting '
        ||x_estimated_scrap_accounting
        ||';x_show_next_op_by_default '
        ||x_show_next_op_by_default
        ||';x_multiple_res_usage_dates '
        ||x_multiple_res_usage_dates
        ||';x_show_scrap_codes '
        ||x_show_scrap_codes
        ||';x_scrap_codes_defined '
        ||x_scrap_codes_defined
        ||';x_bonus_codes_defined '
        ||x_bonus_codes_defined
        ||';x_show_lot_attrib '
        ||x_show_lot_attrib
        ||';x_show_scrap_serials '
        ||x_show_scrap_serials
        ||';x_show_serial_region '
        ||x_show_serial_region
        ||';x_show_secondary_quantities '
        ||x_show_secondary_quantities
        ||';x_transaction_type '
        ||x_transaction_type
        ||';x_quality_region '
        ||x_quality_region
        ||';x_show_scrap_qty '
        ||x_show_scrap_qty
        ||';x_show_next_op_choice '
        ||x_show_next_op_choice
        ||';x_show_next_op '
        ||x_show_next_op
        ||';x_employee_id '
        ||x_employee_id
        ||';x_operator '
        ||x_operator
        ||';x_default_start_date '
        ||x_default_start_date
        ||';x_default_completion_date '
        ||x_default_completion_date
        ||';x_return_status '
        ||x_return_status
        ||';x_msg_count '
        ||x_msg_count
        ||';x_msg_data '
        ||x_msg_data,
        p_stmt_num          => l_stmt_num   ,
        p_msg_tokens        => l_msg_tokens   ,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
        p_run_log_level     => l_log_level
      );
    END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := G_RET_ERROR;
        FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count         ,
            p_data              =>      x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := G_RET_UNEXPECTED;
        FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count         ,
            p_data              =>      x_msg_data
        );

    WHEN OTHERS THEN

         x_return_status := G_RET_UNEXPECTED;

         IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)      OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
         THEN
            WSM_log_PVT.handle_others(
              p_module_name        => l_module         ,
              p_stmt_num           => l_stmt_num       ,
              p_fnd_log_level      => G_LOG_LEVEL_UNEXPECTED   ,
              p_run_log_level      => l_log_level
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count         ,
            p_data              =>      x_msg_data
        );

  END;

/****************************************************************************
Called from Job Op page and Undo Move page to set the page properties
****************************************************************************/

    Procedure getJobOpPageProperties(
          p_organization_id                     IN NUMBER
        , p_wip_entity_id                       IN NUMBER
        , p_operation_seq_num                   IN NUMBER
        , p_routing_operation                   IN NUMBER
        , p_responsibility_id                   IN NUMBER
        , p_standard_op_id                      IN NUMBER
        , p_current_step_type                   IN NUMBER
        , p_status_type                         IN NUMBER
        , x_show_move_in                        OUT NOCOPY NUMBER
        , x_show_move_out                       OUT NOCOPY NUMBER
        , x_show_move_to_next_op                OUT NOCOPY NUMBER
        , x_show_serial_region                  OUT NOCOPY NUMBER
        , x_show_scrap_codes                    OUT NOCOPY NUMBER
        , x_show_bonus_codes                    OUT NOCOPY NUMBER
        , x_show_secondary_quantities           OUT NOCOPY NUMBER
        , x_show_lot_attrib                     OUT NOCOPY NUMBER
        , x_return_status                       OUT NOCOPY VARCHAR2
        , x_msg_count                           OUT NOCOPY NUMBER
        , x_msg_data                            OUT NOCOPY VARCHAR2
    )
    IS
      l_stmt_num                                NUMBER := 0;
      l_serialization_started                   NUMBER;
      l_first_serial_txn_id                     NUMBER; --bug 5444062
      l_serialization_start_op                  NUMBER; --bug 5444062
      l_end_routing_operation                   NUMBER; --bug 5444062
      l_move_codemask                           NUMBER;
      l_current_job_op_seq_num                  NUMBER;
    -- Logging variables.....
        l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
        l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.getJobOpPageProperties';
        l_param_tbl                             WSM_Log_PVT.param_tbl_type;
        x_error_count                           NUMBER;
        x_return_code                           NUMBER;
        x_error_msg                             VARCHAR2(4000);
    BEGIN
      l_stmt_num := 10;
        x_return_status := 'S';
      IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
         l_msg_tokens.delete;
         WSM_log_PVT.logMessage (
               p_module_name     => l_module ,
               p_msg_text          => 'Begin getMoveOutPageProperties: '||
                 'p_organization_id '||p_organization_id||
                 '; p_wip_entity_id '||p_wip_entity_id||
                 '; p_operation_seq_num '||p_operation_seq_num||
                 '; p_routing_operation '||p_routing_operation||
                 '; p_responsibility_id '||p_responsibility_id||
                 '; p_standard_op_id '||p_standard_op_id||
                 '; p_current_step_type '||p_current_step_type||
                 '; p_status_type '||p_status_type,
               p_stmt_num          => l_stmt_num   ,
               p_msg_tokens        => l_msg_tokens   ,
               p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE  ,
               p_run_log_level     => l_log_level
               );
       END IF;

    l_stmt_num := 40;
    /****bug 5444062 Replaced the sql below with a sql getting the values and logic in pl/sql for determining
    x_show_serial_region
    --bug 5236293 added the decode to check if p_routing_operation is null
    SELECT  decode(first_serial_txn_id,
              null, decode(p_routing_operation,
                        null, 0,
                        decode(serialization_start_op,
                            p_routing_operation, 1,
                            0)
                        ),
              1),
              current_job_op_seq_num
    INTO    x_show_serial_region, l_current_job_op_seq_num
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_wip_entity_id;
    ******/

    SELECT  first_serial_txn_id, serialization_start_op, current_job_op_seq_num
    INTO    l_first_serial_txn_id, l_serialization_start_op, l_current_job_op_seq_num
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_wip_entity_id;

    x_show_serial_region := 0;
    --serialization started
    IF (l_first_serial_txn_id IS NOT NULL) THEN
        x_show_serial_region := 1;
    ELSE
        --job outside routing
        IF (p_routing_operation IS NULL) THEN
            x_show_serial_region := 0;
        --job is at serialization op
        ELSIF (l_serialization_start_op = p_routing_operation) THEN
            x_show_serial_region := 1;
        --assembly is serial controlled tracked and job is at last operation
        ELSIF (l_serialization_start_op IS NOT NULL) THEN

            l_stmt_num := 40.1;
            SELECT  operation_seq_num
            INTO    l_end_routing_operation
            FROM    WSM_COPY_OPERATIONS WCO
            WHERE   WCO.wip_entity_id = p_wip_entity_id
            AND     WCO.network_start_end = 'E';

            IF (p_routing_operation = l_end_routing_operation) THEN
                x_show_serial_region := 1;
            END IF;
        END IF;
    END IF;
    --end bug 5444062

    IF ((p_status_type = 3) AND (p_current_step_type IS NOT NULL) AND (l_current_job_op_seq_num = p_operation_seq_num)) THEN
        l_stmt_num := 20;
        l_move_codemask := WSM_MES_UTILITIES_PVT.move_txn_allowed(
                            p_responsibility_id         => fnd_global.resp_id,
                            p_wip_entity_id             => p_wip_entity_id,
                            p_org_id                    => p_organization_id,
                            p_job_op_seq_num            => p_operation_seq_num,
                            p_standard_op_id            => p_standard_op_id,
                            p_intraop_step              => p_current_step_type,
                            p_status_type               => p_status_type
                          );
    END IF;

      l_stmt_num := 30;
    SELECT  decode(bitand(l_move_codemask, 65536), 65536, 1, 0),
            decode(bitand(l_move_codemask, 131072), 131072, 1, 0),
            decode(bitand(l_move_codemask, 262144), 262144, 1, 0)
    INTO    x_show_move_in, x_show_move_out, x_show_move_to_next_op
    FROM    dual;

    l_stmt_num := 50;
    BEGIN
      SELECT  1
      INTO    x_show_scrap_codes
      FROM    dual
      WHERE   EXISTS(
                SELECT  'scrap codes exist'
                FROM    WSM_OP_REASON_CODES
                WHERE   wip_entity_id = p_wip_entity_id
                --bug 5191223 Added the condition operation_seq_num = p_operation_seq_num
                AND     operation_seq_num = p_operation_seq_num
                AND     code_type = 1
              );
    EXCEPTION
      WHEN no_data_found THEN
        x_show_scrap_codes := 0;
    END;

      l_stmt_num := 60;
    BEGIN
      SELECT  1
      INTO    x_show_bonus_codes
      FROM    dual
      WHERE   EXISTS(
                SELECT  'bonus codes exist'
                FROM    WSM_OP_REASON_CODES
                WHERE   wip_entity_id = p_wip_entity_id
                --bug 5191223 Added the condition operation_seq_num = p_operation_seq_num
                AND     operation_seq_num = p_operation_seq_num
                AND     code_type = 2
              );
    EXCEPTION
      WHEN no_data_found THEN
        x_show_bonus_codes := 0;
    END;

      l_stmt_num := 70;
    BEGIN
      SELECT  1
      INTO    x_show_secondary_quantities
      FROM    dual
      WHERE   EXISTS(
                SELECT  'secondary quantities exist'
                FROM    WSM_OP_SECONDARY_QUANTITIES
                WHERE   wip_entity_id = p_wip_entity_id
                AND     operation_seq_num = p_operation_seq_num

              );
    EXCEPTION
      WHEN no_data_found THEN
        x_show_secondary_quantities := 0;
    END;

      l_stmt_num := 80;
/*****bug 5192129 OSFMST1: LOT ATTRIBUTES TAB IS DISPLAYED EVEN WITH SHOW LOT ATTRIBUTES SET TO NO*****
**show_lot_attrib is not applicable for job operation page - always set it to 1**
    IF (p_routing_operation IS NOT NULL) THEN
        SELECT  nvl(BOS.show_lot_attrib, 0)
        INTO    x_show_lot_attrib
        FROM    BOM_OPERATION_SEQUENCES BOS, WIP_OPERATIONS WO
        WHERE   WO.wip_entity_id            = p_wip_entity_id
        AND     WO.operation_seq_num        = p_operation_seq_num
        AND     BOS.operation_sequence_id   = WO.operation_sequence_id;
    ELSE
        SELECT  nvl(BSO.show_lot_attrib, 0)
        INTO    x_show_lot_attrib
        FROM    BOM_STANDARD_OPERATIONS BSO
        WHERE   BSO.standard_operation_id = p_standard_op_id;
    END IF;
********************************************************************/
    x_show_lot_attrib := 1;

      IF G_LOG_LEVEL_PROCEDURE >= l_log_level THEN

          l_param_tbl.delete;
          l_param_tbl(1).paramName := 'x_show_move_in';
          l_param_tbl(1).paramValue := x_show_move_in;
          l_param_tbl(2).paramName := 'x_show_move_out';
          l_param_tbl(2).paramValue := x_show_move_out;
          l_param_tbl(3).paramName := 'x_show_move_to_next_op';
          l_param_tbl(3).paramValue := x_show_move_to_next_op;
          l_param_tbl(4).paramName := 'x_show_serial_region';
          l_param_tbl(4).paramValue := x_show_serial_region;
          l_param_tbl(5).paramName := 'x_show_scrap_codes';
          l_param_tbl(5).paramValue := x_show_scrap_codes;
          l_param_tbl(6).paramName := 'x_show_bonus_codes';
          l_param_tbl(6).paramValue := x_show_bonus_codes;
          l_param_tbl(7).paramName := 'x_show_secondary_quantities';
          l_param_tbl(7).paramValue := x_show_secondary_quantities;
          l_param_tbl(8).paramName := 'x_show_lot_attrib';
          l_param_tbl(8).paramValue := x_show_lot_attrib;
          l_param_tbl(9).paramName := 'x_return_status';
          l_param_tbl(9).paramValue := x_return_status;
          l_param_tbl(10).paramName := 'x_msg_count';
          l_param_tbl(10).paramValue := x_msg_count;
          l_param_tbl(11).paramName := 'x_msg_data';
          l_param_tbl(11).paramValue := x_msg_data;
          WSM_Log_PVT.logProcParams(
            p_module_name   => l_module   ,
            p_param_tbl     => l_param_tbl,
            p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
            );
      END IF;


        FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count         ,
            p_data              =>      x_msg_data
        );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := G_RET_ERROR;
            FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count         ,
                p_data              =>      x_msg_data
            );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := G_RET_UNEXPECTED;
            FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count         ,
                p_data              =>      x_msg_data
            );

        WHEN OTHERS THEN

             x_return_status := G_RET_UNEXPECTED;

             IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)      OR
               (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
             THEN
                WSM_log_PVT.handle_others(
                  p_module_name        => l_module,
                   p_stmt_num          => l_stmt_num,
                   p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED,
                   p_run_log_level     => l_log_level
                 );
              END IF;

            FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count         ,
                p_data              =>      x_msg_data
            );


    END;

/****************************************************************************
Updates the WO.costed_quantity_completed column from Move form, interface and OA page
****************************************************************************/
    --mes
    Procedure update_costed_qty_compl(
          p_transaction_type        NUMBER
        , p_job_fm_op_seq_num       NUMBER
        , p_job_to_op_seq_num       NUMBER
        , p_wip_entity_id           NUMBER
        , p_fm_intraoperation_step_type NUMBER
        , p_to_intraoperation_step_type NUMBER
        , p_primary_move_qty        NUMBER
        , p_primary_scrap_qty       NUMBER
        , p_scrap_at_op             NUMBER
    )
    IS
        l_costed_quantity_completed NUMBER := 0;
        l_fm_costed_quantity_completed NUMBER := 0;
        l_to_costed_quantity_completed NUMBER := 0;
        l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
        l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module       VARCHAR2(100) := 'wsm.plsql.WSMPLBMI.update_costed_qty_compl';
    l_stmt_num          NUMBER := 0;
    BEGIN
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'Begin procedure update_costed_qty_compl'
        ||';p_transaction_type '
        ||p_transaction_type
        ||';p_job_fm_op_seq_num '
        ||p_job_fm_op_seq_num
        ||';p_job_to_op_seq_num '
        ||p_job_to_op_seq_num
        ||';p_wip_entity_id '
        ||p_wip_entity_id
        ||';p_fm_intraoperation_step_type '
        ||p_fm_intraoperation_step_type
        ||';p_to_intraoperation_step_type '
        ||p_to_intraoperation_step_type
        ||';p_primary_move_qty '
        ||p_primary_move_qty
        ||';p_primary_scrap_qty '
        ||p_primary_scrap_qty
        ||';p_scrap_at_op '
        ||p_scrap_at_op,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;

        IF (p_transaction_type IN (g_move_txn, g_comp_txn)) THEN
            IF (p_job_fm_op_seq_num <> p_job_to_op_seq_num) THEN

                IF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_fm_costed_quantity_completed := 0;
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                END IF;

                IF (l_fm_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) +
                                l_fm_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_fm_op_seq_num;
                END IF;

                IF (l_to_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) +
                                l_to_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_to_op_seq_num;
                END IF;

            ELSE --(l_fm_op_seq_num <> l_job_to_op_seq_num)
                IF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_scrap))
                THEN
                    IF nvl(p_primary_move_qty, 0) > 0 THEN
                        l_costed_quantity_completed := p_primary_move_qty;
                    ELSE
                        l_costed_quantity_completed := p_primary_scrap_qty;
                    END IF;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_scrap))
                THEN
                    IF nvl(p_primary_move_qty, 0) > 0 THEN
                        l_costed_quantity_completed := p_primary_move_qty;
                    ELSE
                        l_costed_quantity_completed := p_primary_scrap_qty;
                    END IF;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_scrap)) THEN
                    l_costed_quantity_completed := 0;
                END IF;

                IF (l_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) + l_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_fm_op_seq_num;
                END IF;
            END IF;
        ELSE --(l_transaction_type IN (g_move_txn, g_comp_txn))
            IF (p_job_fm_op_seq_num <> p_job_to_op_seq_num) THEN

                IF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_queue) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 1)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_tomove)
                AND (p_primary_scrap_qty > 0) AND (p_scrap_at_op = 2)) THEN
                    l_to_costed_quantity_completed := 0;
                    l_fm_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                END IF;

                IF (l_fm_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) -
                                l_fm_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_fm_op_seq_num;
                END IF;

                IF (l_to_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) -
                                l_to_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_to_op_seq_num;
                END IF;

            ELSE --(l_fm_op_seq_num <> l_job_to_op_seq_num)
                IF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := 0;
                ELSIF ((p_fm_intraoperation_step_type = g_run) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_queue)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_scrap) AND (p_to_intraoperation_step_type = g_queue))
                THEN
                    IF nvl(p_primary_move_qty, 0) > 0 THEN
                        l_costed_quantity_completed := p_primary_move_qty;
                    ELSE
                        l_costed_quantity_completed := p_primary_scrap_qty;
                    END IF;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty = 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_tomove) AND (p_to_intraoperation_step_type = g_run)
                AND (p_primary_scrap_qty > 0)) THEN
                    l_costed_quantity_completed := p_primary_move_qty + p_primary_scrap_qty;
                ELSIF ((p_fm_intraoperation_step_type = g_scrap) AND (p_to_intraoperation_step_type = g_run))
                THEN
                    IF nvl(p_primary_move_qty, 0) > 0 THEN
                        l_costed_quantity_completed := p_primary_move_qty;
                    ELSE
                        l_costed_quantity_completed := p_primary_scrap_qty;
                    END IF;
                ELSIF ((p_fm_intraoperation_step_type = g_scrap) AND (p_to_intraoperation_step_type = g_tomove)) THEN
                    l_costed_quantity_completed := 0;
                END IF;

                IF (l_costed_quantity_completed > 0) THEN
                    UPDATE  WIP_OPERATIONS
                    SET     wsm_costed_quantity_completed = nvl(wsm_costed_quantity_completed, 0) - l_costed_quantity_completed
                    WHERE   wip_entity_id = p_wip_entity_id
                    AND     operation_seq_num = p_job_fm_op_seq_num;
                END IF;
            END IF;
        END IF; --(l_transaction_type IN (g_move_txn, g_comp_txn))
    END update_costed_qty_compl;

    Function convert_uom(
    p_time_hours        NUMBER, -- from_quantity
    p_to_uom        VARCHAR2 -- to_unit
    ) RETURN NUMBER IS
        l_uom_rate      NUMBER;
        l_hrUOM     VARCHAR2(3) := fnd_profile.value('BOM:HOUR_UOM_CODE');
        l_hrUOM_class   VARCHAR2(10);
        l_resUOM_class  VARCHAR2(10);
    BEGIN

    select uom_class
    into l_hrUOM_class
    from mtl_units_of_measure
    where uom_code = l_hrUOM;

    select uom_class
    into l_resUOM_class
    from mtl_units_of_measure
    where uom_code = p_to_uom;

        IF (l_hrUOM_class = l_resUOM_class) THEN
        l_uom_rate :=  inv_convert.inv_um_convert(
                0, -- item_id
                NULL, -- precision
                p_time_hours, -- from_quantity
                l_hrUOM, -- from_unit
                p_to_uom, -- to_unit
                NULL, -- from_name
                NULL); -- to_name
    ELSE
        l_uom_rate :=  NULL;
        END IF;

        RETURN l_uom_rate;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END convert_uom;
    --mes end

END WSMPLBMI;


/
