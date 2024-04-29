--------------------------------------------------------
--  DDL for Package Body WSMPJUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPJUPD" AS
/* $Header: WSMJUPDB.pls 120.42.12010000.2 2009/05/15 18:50:30 sisankar ship $ */

g_user_id                  number;
g_user_login_id            number;
g_program_appl_id          number;
g_request_id               number;
g_program_id               number;
g_translated_meaning       varchar2(240);

/* Package name  */
g_pkg_name                      VARCHAR2(20) := 'WSMPJUPD';

/*logging variables*/

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

g_ret_success       varchar2(1)    := FND_API.G_RET_STS_SUCCESS;
g_ret_error         varchar2(1)    := FND_API.G_RET_STS_ERROR;
g_ret_unexpected    varchar2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;


type t_number           is table of number index by binary_integer;
type t_job_name_tbl     is table of number index by wip_entities.wip_entity_name%type;

-- MES secondary qty changes
type t_wsm_job_sec_qty_tbl is table of wsm_job_secondary_quantities%rowtype index by binary_integer;
type t_wsm_sj_sec_qty_tbl is table of wsm_sj_secondary_quantities%rowtype index by binary_integer;
type t_wsm_rj_sec_qty_tbl is table of wsm_rj_secondary_quantities%rowtype index by binary_integer;
type t_wsm_op_sec_qty_tbl is table of wsm_op_secondary_quantities%rowtype index by binary_integer;

type t_we_id_tbl is table of wip_entities.wip_entity_id%type index by binary_integer;
type t_cur_qty_tbl is table of wsm_job_secondary_quantities.current_quantity%type index by binary_integer;
type t_cur_uom_tbl is table of wsm_job_secondary_quantities.uom_code%type index by binary_integer;
-- End MES secondary qty changes

-- MES copy tables changes
type t_wsm_op_reason_codes_tbl is table of wsm_op_reason_codes%rowtype index by binary_integer;
--type t_wsm_subst_comp_tbl is table of wsm_substitute_components%rowtype index by binary_integer;
type t_wsm_copy_requirement_ops_tbl is table of wsm_copy_requirement_ops%rowtype index by binary_integer;
-- End MES copy tables changes

-- start...
Procedure  process_mes_info  (   p_secondary_qty_tbl            IN      WSM_WIP_LOT_TXN_PVT.WSM_JOB_SECONDARY_QTY_TBL_TYPE,
                                 p_wltx_header                  IN      WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                 p_wltx_starting_jobs_tbl       IN      WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                 p_wltx_resulting_jobs_tbl      IN      WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                 p_sj_also_rj_index             IN      NUMBER,
                                 p_rep_job_index                IN      NUMBER,
                                 x_return_status                OUT     NOCOPY  VARCHAR2,
                                 x_msg_count                    OUT     NOCOPY  NUMBER,
                                 x_error_msg                    OUT     NOCOPY  VARCHAR2
                             )
IS

l_sj_rj_wip_entity_id           NUMBER          ;
l_sj_rj_wip_entity_name         VARCHAR2(2000)  ;
l_sj_rj_inventory_item_id       NUMBER          ;

-- l_sj_rj_sec_qty_tbl             WSM_WIP_LOT_TXN_PVT.wsm_job_secondary_qty_tbl_type;

l_sj_we_id_tbl                  t_we_id_tbl ;
l_sj_rj_sec_qty_exists          NUMBER;

l_cur_qty_tbl                   t_cur_qty_tbl;
l_cur_uom_tbl                   t_cur_uom_tbl;
l_wip_entity_id_tbl             t_number;

l_job_name_tbl                  t_job_name_tbl;

l_wsm_job_sec_qty_tbl           t_wsm_job_sec_qty_tbl;
l_wsm_op_sec_qty_tbl            t_wsm_op_sec_qty_tbl;
l_wsm_sj_sec_qty_tbl            t_wsm_sj_sec_qty_tbl;
l_wsm_rj_sec_qty_tbl            t_wsm_rj_sec_qty_tbl;

l_rj_op_reason_codes_tbl        t_wsm_op_reason_codes_tbl;
l_sj_op_reason_codes_tbl        t_wsm_op_reason_codes_tbl;

l_job_qty_tbl                   t_wsm_job_sec_qty_tbl;

l_sj_tbl_counter                number;
l_rj_tbl_counter                number;
l_op_tbl_counter                number;

l_counter                       number;
l_index                         number;
-- Logging variables.....
l_msg_tokens                    WSM_Log_PVT.token_rec_tbl;
l_log_level                     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num                      NUMBER;
l_module                        VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.process_mes_info';
l_param_tbl                     WSM_Log_PVT.param_tbl_type;

BEGIN

        savepoint start_secondary_quantities;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                  l_stmt_num := 5;
                  l_param_tbl.delete;
                  l_param_tbl(1).paramName := 'p_sj_also_rj_index';
                  l_param_tbl(1).paramValue := p_sj_also_rj_index;

                  l_param_tbl(2).paramName := 'p_rep_job_index';
                  l_param_tbl(2).paramValue := p_rep_job_index;

                  WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                            p_param_tbl           => l_param_tbl,
                                            p_fnd_log_level       => l_log_level
                                            );
        END IF;

        l_stmt_num := 8;
        -- If the starting job is also the resulting job, store the starting job information..
        -- or is it that the resulting job info is needed...
        IF p_sj_also_rj_index IS NOT NULL THEN
                l_sj_rj_wip_entity_id           := p_wltx_resulting_jobs_tbl(p_sj_also_rj_index).wip_entity_id;
                l_sj_rj_wip_entity_name         := p_wltx_resulting_jobs_tbl(p_sj_also_rj_index).wip_entity_name;
                l_sj_rj_inventory_item_id       := p_wltx_resulting_jobs_tbl(p_sj_also_rj_index).primary_item_id;
        END IF;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'l_sj_rj_wip_entity_id      '  ||  l_sj_rj_wip_entity_id        ||
                                                               'l_sj_rj_wip_entity_name    '  ||  l_sj_rj_wip_entity_name      ||
                                                               'l_sj_rj_inventory_item_id  '  ||  l_sj_rj_inventory_item_id    ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_wsm_sj_sec_qty_tbl.delete;
        l_sj_we_id_tbl.delete;
        l_job_qty_tbl.delete;

        l_stmt_num := 10;
        --*****************************Insert SJ sec qty info into history table**************************
        -- First store SJ sec qty info in wsm_sj_secondary_quantities.The following steps followed for this:
        -- 1. Query wsm_job_secondary_quantities table to get the SJ data into l_job_qty_tbl
        -- 2. Now use this to populate fields in l_wsm_sj_sec_qty_tbl having rowtype same as wsm_sj_secondary_quantities
        --    in order to do bulk insert later on
        -- 3. Bulk insert in wsm_sj_secondary_quantities

        l_counter := p_wltx_starting_jobs_tbl.first;
        l_sj_tbl_counter := 1;
        while l_counter is not null loop
                --store SJ WE_ids in a local table for later use
                l_sj_we_id_tbl(l_counter) := p_wltx_starting_jobs_tbl(l_counter).wip_entity_id;

                -- Query wsm_job_secondary_quantities table to get the SJ data into l_job_qty_tbl
                select *
                bulk collect into l_job_qty_tbl
                from wsm_job_secondary_quantities
                where wip_entity_id = p_wltx_starting_jobs_tbl(l_counter).wip_entity_id
                and currently_active= 1;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Current Secondary quantitites Count :  ' || l_job_qty_tbl.count,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;
                l_stmt_num := 20;

                -- now populate the local pl/sql table
                if l_job_qty_tbl.count > 0 then
                        l_index := l_job_qty_tbl.first;
                        while l_index is not null loop
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).wip_entity_id     := l_job_qty_tbl(l_index).wip_entity_id;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).uom_code          := l_job_qty_tbl(l_index).uom_code;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).quantity          := l_job_qty_tbl(l_index).current_quantity;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).organization_id   := l_job_qty_tbl(l_index).organization_id;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).transaction_id    := p_wltx_header.transaction_id;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).last_update_date  := sysdate;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).last_update_login := fnd_global.login_id;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).last_updated_by   := fnd_global.user_id;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).creation_date     := sysdate;
                                l_wsm_sj_sec_qty_tbl(l_sj_tbl_counter).created_by        := fnd_global.user_id;

                                l_sj_tbl_counter := l_sj_tbl_counter+1;
                                l_index := l_job_qty_tbl.next(l_index);
                        end loop;
                end if;

                l_counter := p_wltx_starting_jobs_tbl.next(l_counter);
        end loop;

        -- bulk insert in wsm_sj_secondary_quantities
        if l_wsm_sj_sec_qty_tbl.count > 0 then
                forall i in indices of l_wsm_sj_sec_qty_tbl
                        insert into wsm_sj_secondary_quantities
                        values l_wsm_sj_sec_qty_tbl(i);
        end if;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Population of Histroy information for Starting Jobs done.',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        --********* End Insert SJ sec qty info into history table******************--

        l_stmt_num := 40;

        ----- Handle Secondary qty information passed for Split,Merge,Upd Assy and Update Qty transaction-------------------------------------
        IF p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE,WSMPCNST.UPDATE_ASSEMBLY,WSMPCNST.UPDATE_QUANTITY) then

                -- For all the new resulting jobs (non-SpUA jobs)
                    -- bulk insert data into wsm_op_secondary_quantities by reading from wsm_job_secondary_quantities
                    --Assumes that the wsm_job_secondary_quantities is already populated in lbj build_header_info proc
                IF p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE) then
                        l_op_tbl_counter := 1;

                        l_stmt_num := 50;
                        l_counter := p_wltx_resulting_jobs_tbl.first;

                        -- get the secondary qty info from base table into local pl/sql table
                        while l_counter is not null loop
                                l_job_name_tbl(p_wltx_resulting_jobs_tbl(l_counter).wip_entity_name) := p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id;

                                l_job_qty_tbl.delete;
                                -- ST : Sec. UOM Fix : Added the nvl clause
                                IF (l_counter <> nvl(p_sj_also_rj_index,-1)) and
                                   not (p_wltx_header.transaction_type_id = WSMPCNST.SPLIT and
                                        p_wltx_resulting_jobs_tbl(l_counter).split_has_update_assy = 1
                                        )
                                THEN
                                        select *
                                        bulk collect
                                        into l_job_qty_tbl
                                        from wsm_job_secondary_quantities
                                        where wip_entity_id = p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id
                                        and currently_active = 1;

                                        -- now populate the local pl/sql table with rowtype same as wsm_op_secondary_quantities
                                        -- so as to do bulk insert

                                        if l_job_qty_tbl.count > 0 then
                                                l_index := l_job_qty_tbl.first;
                                                while l_index is not null loop

                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).wip_entity_id    :=      l_job_qty_tbl(l_index).wip_entity_id;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).uom_code         :=      l_job_qty_tbl(l_index).uom_code;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).Operation_seq_num:=      p_wltx_resulting_jobs_tbl(l_counter).starting_operation_seq_num;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).move_in_quantity :=      null;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).move_out_quantity:=      null;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).organization_id  :=      l_job_qty_tbl(l_index).organization_id;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).last_update_date :=      sysdate;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).last_update_login:=      fnd_global.login_id;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).last_updated_by  :=      fnd_global.user_id;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).creation_date    :=      sysdate;
                                                        l_wsm_op_sec_qty_tbl(l_op_tbl_counter).created_by       :=      fnd_global.user_id;

                                                        l_op_tbl_counter := l_op_tbl_counter+1;
                                                        l_index := l_job_qty_tbl.next(l_index);
                                                end loop;
                                        end if;
                                END IF;
                                l_counter := p_wltx_resulting_jobs_tbl.next(l_counter);
                        end loop;

                        -- bulk insert into wsm_op_secondary_quantities
                        if l_wsm_op_sec_qty_tbl.count > 0 then
                                forall i in indices of l_wsm_op_sec_qty_tbl
                                        insert into wsm_op_secondary_quantities
                                        values l_wsm_op_sec_qty_tbl(i);
                        end if;
                ELSE
                        l_job_name_tbl(p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).wip_entity_name) :=
                                                p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).wip_entity_id;
                END IF;

                -- Insertion of wsm_op_secondary_quantities for non-SpUA new resulting jobs over
                l_stmt_num := 60;
                l_sj_rj_sec_qty_exists := 0;
                IF p_secondary_qty_tbl.count > 0  then

                        l_index := p_secondary_qty_tbl.first;
                        l_stmt_num := 70;
                        while l_index is not null loop
                                IF (p_secondary_qty_tbl(l_index).wip_entity_name = nvl(l_sj_rj_wip_entity_name,'&&&&&*****')) and
                                   (l_sj_rj_sec_qty_exists = 0)
                                THEN
                                        -- This indicates that secondary qty information has been
                                        -- provided for the starting job which is also a resulting job..
                                        l_sj_rj_sec_qty_exists := 1;
                                END IF;
                                l_cur_qty_tbl(l_index) := p_secondary_qty_tbl(l_index).current_quantity;
                                l_cur_uom_tbl(l_index) := p_secondary_qty_tbl(l_index).uom_code;
                                l_wip_entity_id_tbl(l_index) := l_job_name_tbl(p_secondary_qty_tbl(l_index).wip_entity_name);

                                l_index := p_secondary_qty_tbl.next(l_index);
                        END LOOP;
                END IF;

                l_stmt_num := 80;
                -- For a resulting job with change of assembly and for a job after update assembly transaction
                -- The secondary qty UOMs not present for the new assembly have to be obsoleted
                -- Insert new UOMs for the new assembly...which are not present in the old assembly
                -- this part handles SpUA for SJ as RJ and UA
                IF ( p_wltx_header.transaction_type_id = WSMPCNST.SPLIT and p_sj_also_rj_index is not NULL and
                     p_wltx_resulting_jobs_tbl(p_sj_also_rj_index).split_has_update_assy = 1
                   )
                   OR
                   (p_wltx_header.transaction_type_id = WSMPCNST.UPDATE_ASSEMBLY)
                THEN
                        l_stmt_num := 80.1;
                        -- obsolete Old UOMs no longer valid in new assy
                         update wsm_job_secondary_quantities
                         set currently_active =2,
                             current_quantity=null
                         where wip_entity_id = l_sj_rj_wip_entity_id
                         AND   uom_code not in (select uom_code
                                                from wsm_secondary_uoms
                                                where inventory_item_id =l_sj_rj_inventory_item_id);

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Updated ' || SQL%ROWCOUNT || ' rows to be inactive in job secondary quantities',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        -- ST : Bug fix 5046332 : Added the below update to change the active flag of UOMs
                        -- currently inactive but are present in the new item
                        l_stmt_num := 80.2;
                        -- Enable old UOMs to be valid if present in new assy
                        update wsm_job_secondary_quantities
                        set currently_active = 1,
                            current_quantity= null
                        where wip_entity_id = l_sj_rj_wip_entity_id
                        AND   uom_code in (select uom_code
                                            from wsm_secondary_uoms
                                            where inventory_item_id =l_sj_rj_inventory_item_id)
                        AND currently_active = 2;  --Bugfix 4765660, left out of fix for 5046332

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Updated ' || SQL%ROWCOUNT || ' rows to be active in job secondary quantities',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;
                        -- ST : Bug fix 5046332 : End --

                        --Insert new UOMs skeletal info into the base table by reading from wsm_secondary_uoms
                        insert into wsm_job_secondary_quantities
                         (wip_entity_id
                          ,organization_id
                          ,uom_code
                          ,start_quantity
                          ,current_quantity
                          ,currently_active
                          ,last_update_date
                          ,last_updated_by
                          ,last_update_login
                          ,creation_date
                          ,created_by
                          )
                          (select
                          l_sj_rj_wip_entity_id,
                          organization_id,
                          uom_code,
                          null,
                          null,
                          1,
                          sysdate,
                          fnd_global.user_id,
                          fnd_global.login_id,
                          sysdate,
                          fnd_global.user_id
                          from wsm_secondary_uoms
                          where inventory_item_id = l_sj_rj_inventory_item_id -- (resulting job's item id..)
                          -- ST : Bug Fix 5046332 : Commenting out the below condition ---
                          -- and uom_code not in (select uom_code
                          --                      from wsm_secondary_uoms
                          --                      where inventory_item_id= p_wltx_starting_jobs_tbl(p_rep_job_index).primary_item_id)
                          --                      -- ST : Sec. UOM Fix : Use the starting rep jobs's item id --
                          -- ST : Bug Fix 5046332 : Added the below condition ---
                          and uom_code not in (select uom_code
                                               from wsm_job_secondary_quantities
                                               where wip_entity_id = l_sj_rj_wip_entity_id)
                          -- ST : Bug Fix 5046332 : End --
                        );

                        IF( g_log_level_statement   >= l_log_level ) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Inserted ' || SQL%ROWCOUNT || ' new rows in in job secondary quantities tables',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                END IF;

                -- For a starting job also present as a resulting job, NULL out the current qty information if nothing is passed..
                -- Demo Issue Fix : Retain the old information for the starting job
                -- IF  (p_wltx_header.transaction_type_id IN (WSMPCNST.SPLIT,WSMPCNST.MERGE)) and
                --     (p_sj_also_rj_index is not NULL)                                       and
                --     (l_sj_rj_sec_qty_exists = 0)
                -- THEN
                --         -- User hasnt provided secondary qty information...
                --         Update wsm_job_secondary_quantities wjsq
                --         set current_quantity = null
                --         where wjsq.wip_entity_id = l_sj_rj_wip_entity_id
                --         and currently_active = 1;
                -- END IF;

                 -- Now do the updation for all the resulting jobs...
                 IF p_secondary_qty_tbl.count <> 0 THEN
                        forall i in indices of p_secondary_qty_tbl
                                update wsm_job_secondary_quantities
                                set   current_quantity = l_cur_qty_tbl(i)
                                where wip_entity_id = l_wip_entity_id_tbl(i)
                                and uom_code = l_cur_uom_tbl(i);
                END IF;
        END IF;
        ----- End : Handle Split,Merge,Upd Assy --------------------------------------

        l_stmt_num := 90;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing for Split Merge, Update Assembly Done',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_stmt_num := 120;
        -- In case of Merge and Split,
        -- then need to set the cur_qty = null and cur_active = N for Starting Jobs not present as a Resulting job
        IF p_wltx_header.transaction_type_id IN (WSMPCNST.SPLIT,WSMPCNST.MERGE) THEN
                forall i in indices of l_sj_we_id_tbl
                      update wsm_job_secondary_quantities
                      set currently_active = 2,
                          current_quantity=null
                      where wip_entity_id = l_sj_we_id_tbl(i)
                      and   wip_entity_id <> nvl(l_sj_rj_wip_entity_id,0);
                      --If sj is rj(means l_sj_rj_wip_entity_id is not null),
                      --it shouldnt be updated.
        END IF;

        -- Here handle the Reason code for SPLIT and MERGE transaction..
        If p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE) then

                select *
                bulk collect
                into l_sj_op_reason_codes_tbl
                from wsm_op_reason_codes
                where operation_seq_num = p_wltx_starting_jobs_tbl(p_rep_job_index).operation_seq_num
                and wip_entity_id = p_wltx_starting_jobs_tbl(p_rep_job_index).wip_entity_id;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Starting Job Reason codes count : ' || l_sj_op_reason_codes_tbl.count,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                l_rj_op_reason_codes_tbl.delete;
                l_counter    := p_wltx_resulting_jobs_tbl.first;
                l_rj_tbl_counter := 1;

                -- forall the no-SpUA resulting jobs (not present also as a starting job, create the reason code information in PL/SQL tables)
                -- and do a bulk insert at the end
                while l_counter IS NOT NULL and l_sj_op_reason_codes_tbl.count > 0 LOOP

                        IF ( p_wltx_header.transaction_type_id = WSMPCNST.MERGE OR
                             ( p_wltx_header.transaction_type_id = WSMPCNST.SPLIT AND p_wltx_resulting_jobs_tbl(l_counter).split_has_update_assy <> 1)
                             ) AND
                             ( l_counter <> nvl(p_sj_also_rj_index,-1) )
                             -- Resulting Job shouldnt be a starting job
                        THEN
                                l_index := l_sj_op_reason_codes_tbl.first;
                                WHILE l_index is not NULL LOOP
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).wip_entity_id        := p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).OPERATION_SEQ_NUM    := l_sj_op_reason_codes_tbl(l_index).operation_seq_num;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).code_type            := l_sj_op_reason_codes_tbl(l_index).code_type;

            				l_rj_op_reason_codes_tbl(l_rj_tbl_counter).reason_code          := l_sj_op_reason_codes_tbl(l_index).reason_code;
					-- Bug 5458450 Reason Code quantity should not be propagated to child jobs.Commented out next line

                                        -- l_rj_op_reason_codes_tbl(l_rj_tbl_counter).quantity             := p_wltx_resulting_jobs_tbl(l_counter).start_quantity;

                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).Created_by           := fnd_global.user_id;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).Last_update_date     := sysdate;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).Last_updated_by      := fnd_global.user_id;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).Creation_date        := sysdate;
                                        l_rj_op_reason_codes_tbl(l_rj_tbl_counter).Last_updated_login   := fnd_global.login_id;

                                        l_rj_tbl_counter := l_rj_tbl_counter + 1;
                                        l_index := l_sj_op_reason_codes_tbl.next(l_index);
                                END LOOP;
                        END IF;
                        l_counter := p_wltx_resulting_jobs_tbl.next(l_counter);
                END LOOP;

                -- Bulk insert now...
                IF l_rj_op_reason_codes_tbl.count > 0 then
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Resulting Jobs Reason codes count : ' || l_rj_op_reason_codes_tbl.count,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;
                        forall i in indices of l_rj_op_reason_codes_tbl
                                insert into wsm_op_reason_codes
                                values l_rj_op_reason_codes_tbl(i);

                END IF;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Processing Reason codes for non-SpUA and Merge resulting Jobs done',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;
        END IF;

        -- Back to Secondary Quantities processing for Jobs with New Operation.....
        -- now handle bonus.Insert skeletal data in both job level and op level tables as for job
        -- we are calling option 1 code so LBJ proc wont insert elementary sec qty data

        -- Call the WSMOPRNB procedure for BONUS,UPDATE_ASSEMBLY, SpUA and UPDATE_ROUTING transactions
        -- to fill in data from the WSM_JOB_SECONDARY_QUANTITIES into ... WSM_OP_SECONDARY_QUANTITIES
        IF p_wltx_header.transaction_type_id IN (WSMPCNST.BONUS,WSMPCNST.UPDATE_ASSEMBLY,WSMPCNST.UPDATE_ROUTING,WSMPCNST.SPLIT) THEN
                l_counter := p_wltx_resulting_jobs_tbl.first;
                while l_counter IS NOT NULL LOOP
                        IF (p_wltx_header.transaction_type_id <> WSMPCNST.SPLIT) OR
                           (p_wltx_header.transaction_type_id = WSMPCNST.SPLIT and p_wltx_resulting_jobs_tbl(l_counter).split_has_update_assy = 1)
                        THEN
                                l_stmt_num := 130;
                                -- In case of bonus we'll have to create the skeletal data and then invoke the OPRNB code
                                IF p_wltx_header.transaction_type_id = WSMPCNST.BONUS THEN
                                        insert into wsm_job_secondary_quantities
                                        ( wip_entity_id
                                          ,organization_id
                                          ,uom_code
                                          ,start_quantity
                                          ,current_quantity
                                          ,currently_active
                                          ,last_update_date
                                          ,last_updated_by
                                          ,last_update_login
                                          ,creation_date
                                          ,created_by
                                          )
                                        (select
                                          p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id,
                                          p_wltx_resulting_jobs_tbl(l_counter).organization_id,
                                          uom_code,
                                          null,
                                          null,
                                          1,
                                          sysdate,
                                          fnd_global.user_id,
                                          fnd_global.login_id,
                                          sysdate,
                                          fnd_global.user_id
                                          from wsm_secondary_uoms
                                          where inventory_item_id = p_wltx_resulting_jobs_tbl(l_counter).primary_item_id
                                        );

                                        if( g_log_level_statement   >= l_log_level ) then
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Inserted ' || SQL%ROWCOUNT || ' new rows in in job secondary quantities tables for bonus',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_log_level      => g_log_level_statement,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        End if;

                                END IF;

                                l_stmt_num := 130;
                                -- Invoke the OPRNB code now.
                                WSMPOPRN.copy_to_op_mes_info  ( p_wip_entity_id       => p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id              ,
                                                                p_to_job_op_seq_num   => p_wltx_resulting_jobs_tbl(l_counter).job_operation_seq_num      ,
                                                                p_to_rtg_op_seq_num   => p_wltx_resulting_jobs_tbl(l_counter).starting_operation_seq_num ,
                                                                p_txn_quantity        => p_wltx_resulting_jobs_tbl(l_counter).start_quantity             ,
                                                                p_user                => fnd_global.user_id                                              ,
                                                                p_login               => fnd_global.login_id                                             ,
                                                                x_return_status       => x_return_status                                                 ,
                                                                x_msg_count           => x_msg_count                                                     ,
                                                                x_msg_data            => x_error_msg
                                                              );
                                -- Once this call is over the data for the new operation would be copied...
                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSE
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;
                        END IF;
                        l_counter := p_wltx_resulting_jobs_tbl.next(l_counter);
                END LOOP;
        end if;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing Secondary Qty and Reason codes for SpUA Split and Upd Assy and Upd Rtg Jobs done',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        -- ST : Sec. UOM Fix : Moved this to the end.. Populate history information once every thing is done..
        --History info for resulting job.
        l_stmt_num := 140;
        l_wsm_rj_sec_qty_tbl.delete;
        l_job_qty_tbl.delete;
        l_rj_tbl_counter := 1;

        l_counter := p_wltx_resulting_jobs_tbl.first;
        while l_counter is not null loop

                select *
                bulk collect into l_job_qty_tbl
                from wsm_job_secondary_quantities
                where wip_entity_id = p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id
                and currently_active= 1;

                -- now populate the local pl/sql table
                if l_job_qty_tbl.count > 0 then
                        l_index := l_job_qty_tbl.first;
                        while l_index is not null loop

                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).wip_entity_id     := l_job_qty_tbl(l_index).wip_entity_id;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).uom_code          := l_job_qty_tbl(l_index).uom_code;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).quantity          := l_job_qty_tbl(l_index).current_quantity;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).organization_id   := l_job_qty_tbl(l_index).organization_id;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).transaction_id    := p_wltx_header.transaction_id;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).last_update_date  := sysdate;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).last_update_login := fnd_global.login_id;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).last_updated_by   := fnd_global.user_id;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).creation_date     := sysdate;
                                l_wsm_rj_sec_qty_tbl(l_rj_tbl_counter).created_by        := fnd_global.user_id;

                                l_rj_tbl_counter := l_rj_tbl_counter+1;
                                l_index := l_job_qty_tbl.next(l_index);
                        end loop;
                end if;
                l_counter := p_wltx_resulting_jobs_tbl.next(l_counter);
        end loop;

        if l_wsm_rj_sec_qty_tbl.count > 0 then
                forall i in indices of l_wsm_rj_sec_qty_tbl
                        insert into wsm_rj_secondary_quantities
                        values l_wsm_rj_sec_qty_tbl(i);
        end if;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'History Information for Resulting Jobs Done',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_secondary_quantities;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO start_secondary_quantities;
                x_return_status := G_RET_UNEXPECTED;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );
        WHEN OTHERS THEN

                ROLLBACK TO start_secondary_quantities;
                x_return_status := G_RET_UNEXPECTED;

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );
END;

/************** Commenting out due to few discrepancies in the code...
Reason code information is handled if the process_mes_info
PROCEDURE copy_wsm_op_reason_codes (    p_wltx_header                   IN           WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_jobs_tbl        IN           WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                        p_wltx_resulting_jobs_tbl       IN           WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                        p_rep_job_index                 IN           NUMBER,
                                        p_sj_also_rj_index              IN           NUMBER,
                                        x_return_status                 OUT          NOCOPY     VARCHAR2,
                                        x_msg_count                     OUT          NOCOPY     NUMBER,
                                        x_error_msg                     OUT          NOCOPY     VARCHAR2)
IS

l_sj_we_id                      NUMBER ;
l_wsm_op_reason_codes_tbl       t_wsm_op_reason_codes_tbl;

l_counter       number;
g_code_type_bonus             CONSTANT NUMBER := 1 ;
g_code_type_scrap             CONSTANT NUMBER := 2 ;

-- Logging variables.....
l_msg_tokens    WSM_Log_PVT.token_rec_tbl;
l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num      NUMBER;
l_module        VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.copy_wsm_op_reason_codes';

BEGIN

        savepoint start_copy_wsm_op_reason_codes;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 10;

        if p_sj_also_rj_index is null then
                l_counter := p_wltx_starting_jobs_tbl.first;
                l_sj_we_id := p_wltx_starting_jobs_tbl(l_counter).wip_entity_id;
        else
                l_sj_we_id := p_wltx_resulting_jobs_tbl(p_sj_also_rj_index).wip_entity_id;
        end if;

        l_stmt_num := 20;
        If p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE) then
              for i in p_wltx_resulting_jobs_tbl.first .. p_wltx_resulting_jobs_tbl.last loop
                   if p_wltx_resulting_jobs_tbl(i).split_has_update_assy <>1 then
                        l_wsm_op_reason_codes_tbl.delete;
                        BEGIN
                                select *
                                bulk collect into l_wsm_op_reason_codes_tbl
                                from wsm_op_reason_codes
                                where operation_seq_num = p_wltx_resulting_jobs_tbl(i).starting_operation_seq_num
                                and wip_entity_id = l_sj_we_id
                                and p_wltx_resulting_jobs_tbl(i).wip_entity_id <> l_sj_we_id;
                        EXCEPTION
                                when no_data_found then
                                        null;
                        END;
                        if l_wsm_op_reason_codes_tbl.count > 0 then
                                for j in l_wsm_op_reason_codes_tbl.first .. l_wsm_op_reason_codes_tbl.last loop
                                        l_wsm_op_reason_codes_tbl(j).wip_entity_id      := p_wltx_resulting_jobs_tbl(i).wip_entity_id;
                                        l_wsm_op_reason_codes_tbl(j).Created_by         := fnd_global.user_id;
                                        l_wsm_op_reason_codes_tbl(j).Last_update_date   := sysdate;
                                        l_wsm_op_reason_codes_tbl(j).Last_updated_by    := fnd_global.user_id;
                                        l_wsm_op_reason_codes_tbl(j).Creation_date      := sysdate;
                                        l_wsm_op_reason_codes_tbl(j).Last_updated_login := fnd_global.login_id;
                                end loop;
                        end if;
                        if l_wsm_op_reason_codes_tbl.count > 0 then
                                forall k in l_wsm_op_reason_codes_tbl.first .. l_wsm_op_reason_codes_tbl.last
                                        insert into wsm_op_reason_codes
                                        values l_wsm_op_reason_codes_tbl(k);
                        end if;
                   end if;
              end loop;
        end if;

        l_stmt_num := 30;
        -- This will be handled by the call to OPRNB.copy_mes procedure in the secondary_quantities procedure..
        if p_wltx_header.transaction_type_id = WSMPCNST.BONUS then
                --query bom_standard_operations child table and populate reason codes for the new op.;
                l_counter := p_wltx_resulting_jobs_tbl.first;
                        insert into wsm_op_reason_codes
                        (Organization_id,
                         Wip_entity_id   ,
                         Operation_seq_num,
                         Code_Type       ,
                         Reason_Code     ,
                         Quantity        ,
                         Created_by      ,
                         Last_update_date,
                         Last_updated_by ,
                         Creation_date   ,
                         Last_updated_login
                        )
                        (select
                         p_wltx_resulting_jobs_tbl(l_counter).organization_id,
                         p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id,
                         bsobc.sequence_number,
                         1,
                         bsobc.bonus_code,
                         null,
                         fnd_global.user_id,
                         sysdate,
                         fnd_global.user_id,
                         sysdate,
                         fnd_global.login_id
                         from bom_std_op_bonus_codes bsobc
                         where sequence_number = p_wltx_resulting_jobs_tbl(l_counter).starting_operation_seq_num
                         and STANDARD_OPERATION_ID = p_wltx_resulting_jobs_tbl(l_counter).starting_std_op_id
                        );

                        insert into wsm_op_reason_codes
                        (Organization_id,
                         Wip_entity_id   ,
                         Operation_seq_num,
                         Code_Type       ,
                         Reason_Code     ,
                         Quantity        ,
                         Created_by      ,
                         Last_update_date,
                         Last_updated_by ,
                         Creation_date   ,
                         Last_updated_login
                        )
                        (select
                         p_wltx_resulting_jobs_tbl(l_counter).organization_id,
                         p_wltx_resulting_jobs_tbl(l_counter).wip_entity_id,
                         bsosc.sequence_num,
                         2,
                         bsosc.scrap_code,
                         null,
                         fnd_global.user_id,
                         sysdate,
                         fnd_global.user_id,
                         sysdate,
                         fnd_global.login_id
                         from bom_std_op_scrap_codes bsosc
                         where sequence_num = p_wltx_resulting_jobs_tbl(l_counter).starting_operation_seq_num
                         and STANDARD_OPERATION_ID = p_wltx_resulting_jobs_tbl(l_counter).starting_std_op_id
                        );
        end if;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO start_copy_wsm_op_reason_codes;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_copy_wsm_op_reason_codes;

                x_return_status := G_RET_UNEXPECTED;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );
        WHEN OTHERS THEN

                ROLLBACK TO start_copy_wsm_op_reason_codes;

                x_return_status := G_RET_UNEXPECTED;
                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;
                FND_MSG_PUB.Count_And_Get ( p_encoded    => 'F'          ,
                                            p_count      => x_msg_count  ,
                                            p_data       => x_error_msg
                                          );
END ;
*************************************************************/
/*** Commenting out : Descoped..
PROCEDURE copy_wsm_substitute_components (      p_wltx_header                   IN      WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                                p_wltx_starting_jobs_tbl        IN      WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                                p_wltx_resulting_jobs_tbl       IN      WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                                p_rep_job_index                 IN      NUMBER,
                                                x_return_status                 OUT     NOCOPY  VARCHAR2,
                                                x_msg_count                     OUT     NOCOPY  NUMBER,
                                                x_error_msg                     OUT     NOCOPY  VARCHAR2)
IS


    l_sj_we_id      NUMBER := p_wltx_starting_jobs_tbl(p_wltx_starting_jobs_tbl.first).wip_entity_id;

    l_wsm_copy_requirement_ops_tbl          t_wsm_copy_requirement_ops_tbl;
    l_wsm_subst_comp_tbl                    t_wsm_subst_comp_tbl;

    l_counter NUMBER;

    -- Logging variables.....
    l_msg_tokens                WSM_Log_PVT.token_rec_tbl;
    l_log_level                 number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num                  NUMBER;
    l_module                    VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.copy_wsm_substitute_components';


BEGIN
        savepoint start_copy_wsm_subst_comp;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 10;

        If p_wltx_starting_jobs_tbl(p_rep_job_index).intraoperation_step = 1 then
                If p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE,WSMPCNST.BONUS) then
                        --Copy parents substitute components info to new child jobs.For parent jobs,it shld be already populated.
                        for i in p_wltx_resulting_jobs_tbl.first .. p_wltx_resulting_jobs_tbl.last loop
                           if p_wltx_resulting_jobs_tbl (i).split_has_update_assy <>1 then
                                BEGIN
                                        select *
                                        bulk collect into l_wsm_copy_requirement_ops_tbl
                                        from wsm_copy_requirement_ops
                                        where wip_entity_id = p_wltx_resulting_jobs_tbl(i).wip_entity_id
                                        and recommended = 'N'
                                        and operation_seq_num = p_wltx_resulting_jobs_tbl(i).starting_operation_seq_num
                                        and  wip_entity_id <> nvl(l_sj_we_id,-1);
                                EXCEPTION
                                        when no_data_found then
                                                null;
                                END;

                                l_wsm_subst_comp_tbl.delete;

                                if l_wsm_copy_requirement_ops_tbl.count>0 then
                                        for j in l_wsm_copy_requirement_ops_tbl.first .. l_wsm_copy_requirement_ops_tbl.last loop
                                                l_wsm_subst_comp_tbl(j).WIP_ENTITY_ID           :=      l_wsm_copy_requirement_ops_tbl(j).WIP_ENTITY_ID;
                                                l_wsm_subst_comp_tbl(j).OPERATION_SEQ_NUM               :=      l_wsm_copy_requirement_ops_tbl(j).OPERATION_SEQ_NUM      ;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_ITEM_ID            :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_ITEM_ID         ;
                                                l_wsm_subst_comp_tbl(j).PRIMARY_COMPONENT_ID         :=      l_wsm_copy_requirement_ops_tbl(j).PRIMARY_COMPONENT_ID      ;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_SEQUENCE_ID        :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_SEQUENCE_ID     ;
                                                l_wsm_subst_comp_tbl(j).DATE_REQUIRED                :=      l_wsm_copy_requirement_ops_tbl(j).RECO_DATE_REQUIRED        ;
                                                l_wsm_subst_comp_tbl(j).BILL_SEQUENCE_ID             :=      l_wsm_copy_requirement_ops_tbl(j).BILL_SEQUENCE_ID          ;
                                                l_wsm_subst_comp_tbl(j).DEPARTMENT_ID                :=      l_wsm_copy_requirement_ops_tbl(j).DEPARTMENT_ID             ;
                                                l_wsm_subst_comp_tbl(j).ORGANIZATION_ID              :=      l_wsm_copy_requirement_ops_tbl(j).ORGANIZATION_ID           ;
                                                l_wsm_subst_comp_tbl(j).WIP_SUPPLY_TYPE              :=      l_wsm_copy_requirement_ops_tbl(j).WIP_SUPPLY_TYPE           ;
                                                l_wsm_subst_comp_tbl(j).SUPPLY_SUBINVENTORY          :=      l_wsm_copy_requirement_ops_tbl(j).SUPPLY_SUBINVENTORY       ;
                                                l_wsm_subst_comp_tbl(j).SUPPLY_LOCATOR_ID            :=      l_wsm_copy_requirement_ops_tbl(j).SUPPLY_LOCATOR_ID         ;
                                                l_wsm_subst_comp_tbl(j).QUANTITY_PER_ASSEMBLY        :=      l_wsm_copy_requirement_ops_tbl(j).QUANTITY_PER_ASSEMBLY     ;
                                                l_wsm_subst_comp_tbl(j).BILL_QUANTITY_PER_ASSEMBLY   :=      l_wsm_copy_requirement_ops_tbl(j).BILL_QUANTITY_PER_ASSEMBLY;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_YIELD_FACTOR       :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_YIELD_FACTOR    ;
                                                l_wsm_subst_comp_tbl(j).EFFECTIVITY_DATE             :=      l_wsm_copy_requirement_ops_tbl(j).EFFECTIVITY_DATE          ;
                                                l_wsm_subst_comp_tbl(j).DISABLE_DATE                 :=      l_wsm_copy_requirement_ops_tbl(j).DISABLE_DATE              ;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_PRIORITY           :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_PRIORITY        ;
                                                l_wsm_subst_comp_tbl(j).PARENT_BILL_SEQ_ID           :=      l_wsm_copy_requirement_ops_tbl(j).PARENT_BILL_SEQ_ID        ;
                                                l_wsm_subst_comp_tbl(j).ITEM_NUM                     :=      l_wsm_copy_requirement_ops_tbl(j).ITEM_NUM                  ;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_REMARKS            :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_REMARKS         ;
                                                l_wsm_subst_comp_tbl(j).CHANGE_NOTICE                :=      l_wsm_copy_requirement_ops_tbl(j).CHANGE_NOTICE             ;
                                                l_wsm_subst_comp_tbl(j).IMPLEMENTATION_DATE          :=      l_wsm_copy_requirement_ops_tbl(j).IMPLEMENTATION_DATE       ;
                                                l_wsm_subst_comp_tbl(j).PLANNING_FACTOR              :=      l_wsm_copy_requirement_ops_tbl(j).PLANNING_FACTOR           ;
                                                l_wsm_subst_comp_tbl(j).QUANTITY_RELATED             :=      l_wsm_copy_requirement_ops_tbl(j).QUANTITY_RELATED          ;
                                                l_wsm_subst_comp_tbl(j).SO_BASIS                     :=      l_wsm_copy_requirement_ops_tbl(j).SO_BASIS                  ;
                                                l_wsm_subst_comp_tbl(j).OPTIONAL                     :=      l_wsm_copy_requirement_ops_tbl(j).OPTIONAL                  ;
                                                l_wsm_subst_comp_tbl(j).MUTUALLY_EXCLUSIVE_OPTIONS   :=      l_wsm_copy_requirement_ops_tbl(j).MUTUALLY_EXCLUSIVE_OPTIONS;
                                                l_wsm_subst_comp_tbl(j).INCLUDE_IN_COST_ROLLUP       :=      l_wsm_copy_requirement_ops_tbl(j).INCLUDE_IN_COST_ROLLUP    ;
                                                l_wsm_subst_comp_tbl(j).CHECK_ATP                    :=      l_wsm_copy_requirement_ops_tbl(j).CHECK_ATP                 ;
                                                l_wsm_subst_comp_tbl(j).SHIPPING_ALLOWED             :=      l_wsm_copy_requirement_ops_tbl(j).SHIPPING_ALLOWED          ;
                                                l_wsm_subst_comp_tbl(j).REQUIRED_TO_SHIP             :=      l_wsm_copy_requirement_ops_tbl(j).REQUIRED_TO_SHIP          ;
                                                l_wsm_subst_comp_tbl(j).REQUIRED_FOR_REVENUE         :=      l_wsm_copy_requirement_ops_tbl(j).REQUIRED_FOR_REVENUE      ;
                                                l_wsm_subst_comp_tbl(j).INCLUDE_ON_SHIP_DOCS         :=      l_wsm_copy_requirement_ops_tbl(j).INCLUDE_ON_SHIP_DOCS      ;
                                                l_wsm_subst_comp_tbl(j).LOW_QUANTITY                 :=      l_wsm_copy_requirement_ops_tbl(j).LOW_QUANTITY              ;
                                                l_wsm_subst_comp_tbl(j).HIGH_QUANTITY                :=      l_wsm_copy_requirement_ops_tbl(j).HIGH_QUANTITY             ;
                                                l_wsm_subst_comp_tbl(j).ACD_TYPE                     :=      l_wsm_copy_requirement_ops_tbl(j).ACD_TYPE                  ;
                                                l_wsm_subst_comp_tbl(j).OLD_COMPONENT_SEQUENCE_ID    :=      l_wsm_copy_requirement_ops_tbl(j).OLD_COMPONENT_SEQUENCE_ID;
                                                l_wsm_subst_comp_tbl(j).OPERATION_LEAD_TIME_PERCENT  :=      l_wsm_copy_requirement_ops_tbl(j).OPERATION_LEAD_TIME_PERCENT;
                                                l_wsm_subst_comp_tbl(j).REVISED_ITEM_SEQUENCE_ID     :=      l_wsm_copy_requirement_ops_tbl(j).REVISED_ITEM_SEQUENCE_ID  ;
                                                l_wsm_subst_comp_tbl(j).BOM_ITEM_TYPE                :=      l_wsm_copy_requirement_ops_tbl(j).BOM_ITEM_TYPE             ;
                                                l_wsm_subst_comp_tbl(j).FROM_END_ITEM_UNIT_NUMBER    :=      l_wsm_copy_requirement_ops_tbl(j).FROM_END_ITEM_UNIT_NUMBER ;
                                                l_wsm_subst_comp_tbl(j).TO_END_ITEM_UNIT_NUMBER      :=      l_wsm_copy_requirement_ops_tbl(j).TO_END_ITEM_UNIT_NUMBER   ;
                                                l_wsm_subst_comp_tbl(j).ECO_FOR_PRODUCTION           :=      l_wsm_copy_requirement_ops_tbl(j).ECO_FOR_PRODUCTION        ;
                                                l_wsm_subst_comp_tbl(j).ENFORCE_INT_REQUIREMENTS     :=      l_wsm_copy_requirement_ops_tbl(j).ENFORCE_INT_REQUIREMENTS  ;
                                                l_wsm_subst_comp_tbl(j).DELETE_GROUP_NAME            :=      l_wsm_copy_requirement_ops_tbl(j).DELETE_GROUP_NAME         ;
                                                l_wsm_subst_comp_tbl(j).DG_DESCRIPTION               :=      l_wsm_copy_requirement_ops_tbl(j).DG_DESCRIPTION            ;
                                                l_wsm_subst_comp_tbl(j).OPTIONAL_ON_MODEL            :=      l_wsm_copy_requirement_ops_tbl(j).OPTIONAL_ON_MODEL         ;
                                                l_wsm_subst_comp_tbl(j).MODEL_COMP_SEQ_ID            :=      l_wsm_copy_requirement_ops_tbl(j).MODEL_COMP_SEQ_ID         ;
                                                l_wsm_subst_comp_tbl(j).PLAN_LEVEL                   :=      l_wsm_copy_requirement_ops_tbl(j).PLAN_LEVEL                ;
                                                l_wsm_subst_comp_tbl(j).AUTO_REQUEST_MATERIAL        :=      l_wsm_copy_requirement_ops_tbl(j).AUTO_REQUEST_MATERIAL     ;
                                                l_wsm_subst_comp_tbl(j).COMPONENT_ITEM_REVISION_ID   :=      l_wsm_copy_requirement_ops_tbl(j).COMPONENT_ITEM_REVISION_ID;
                                                l_wsm_subst_comp_tbl(j).FROM_BILL_REVISION_ID        :=      l_wsm_copy_requirement_ops_tbl(j).FROM_BILL_REVISION_ID     ;
                                                l_wsm_subst_comp_tbl(j).TO_BILL_REVISION_ID          :=      l_wsm_copy_requirement_ops_tbl(j).TO_BILL_REVISION_ID       ;
                                                l_wsm_subst_comp_tbl(j).PICK_COMPONENTS              :=      l_wsm_copy_requirement_ops_tbl(j).PICK_COMPONENTS           ;
                                                l_wsm_subst_comp_tbl(j).INCLUDE_ON_BILL_DOCS         :=      l_wsm_copy_requirement_ops_tbl(j).INCLUDE_ON_BILL_DOCS      ;
                                                l_wsm_subst_comp_tbl(j).COST_FACTOR                  :=      l_wsm_copy_requirement_ops_tbl(j).COST_FACTOR               ;
                                                l_wsm_subst_comp_tbl(j).LAST_UPDATE_DATE             :=      l_wsm_copy_requirement_ops_tbl(j).LAST_UPDATE_DATE          ;
                                                l_wsm_subst_comp_tbl(j).LAST_UPDATED_BY              :=      l_wsm_copy_requirement_ops_tbl(j).LAST_UPDATED_BY           ;
                                                l_wsm_subst_comp_tbl(j).LAST_UPDATED_LOGIN            :=      l_wsm_copy_requirement_ops_tbl(j).LAST_UPDATE_LOGIN         ;
                                                l_wsm_subst_comp_tbl(j).CREATION_DATE                :=      l_wsm_copy_requirement_ops_tbl(j).CREATION_DATE             ;
                                                l_wsm_subst_comp_tbl(j).CREATED_BY                   :=      l_wsm_copy_requirement_ops_tbl(j).CREATED_BY                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE_CATEGORY           :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE_CATEGORY        ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE1                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE1                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE2                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE2                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE3                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE3                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE4                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE4                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE5                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE5                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE6                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE6                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE7                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE7                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE8                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE8                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE9                   :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE9                ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE10                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE10               ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE11                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE11               ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE12                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE12               ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE13                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE13               ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE14                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE14               ;
                                                l_wsm_subst_comp_tbl(j).ATTRIBUTE15                  :=      l_wsm_copy_requirement_ops_tbl(j).ATTRIBUTE15               ;
                                                l_wsm_subst_comp_tbl(j).ORIGINAL_SYSTEM_REFERENCE    :=      l_wsm_copy_requirement_ops_tbl(j).ORIGINAL_SYSTEM_REFERENCE ;
                                        end loop;
                                end if;

                                if l_wsm_subst_comp_tbl.count>0 then
                                        forall k in l_wsm_subst_comp_tbl.first .. l_wsm_subst_comp_tbl.last
                                                insert into WSM_SUBSTITUTE_COMPONENTS
                                                values l_wsm_subst_comp_tbl(k);
                                end if;

                            end if;
                        end loop;
                end if;
        end if;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO start_copy_wsm_subst_comp;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_error_msg   ,
                                           p_data       => x_msg_count
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_copy_wsm_subst_comp;

                x_return_status := G_RET_UNEXPECTED;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_error_msg   ,
                                           p_data       => x_msg_count
                                          );
        WHEN OTHERS THEN

                ROLLBACK TO start_copy_wsm_subst_comp;

                x_return_status := G_RET_UNEXPECTED;
                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_error_msg   ,
                                           p_data       => x_msg_count
                                          );

END;
*/

PROCEDURE GET_JOB_CURR_OP_INFO(p_wip_entity_id      IN NUMBER,
                               p_op_seq_num         OUT NOCOPY NUMBER,
                               p_op_seq_id          OUT NOCOPY NUMBER,
                               p_std_op_id          OUT NOCOPY NUMBER,
                               p_intra_op           OUT NOCOPY NUMBER,
                               p_dept_id            OUT NOCOPY NUMBER,
                               p_op_qty             OUT NOCOPY NUMBER,
                               p_op_start_date      OUT NOCOPY DATE,
                               p_op_completion_date OUT NOCOPY DATE,
                               x_err_code           OUT NOCOPY NUMBER,
                               x_err_buf            OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER)
IS

    l_qty_Q             NUMBER;
    l_qty_RUN           NUMBER;
    l_qty_TM            NUMBER;

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.GET_JOB_CURR_OP_INFO';


BEGIN

    p_op_qty := 0;

    l_stmt_num := 10;

    SELECT max(operation_seq_num)
    INTO   p_op_seq_num
    FROM   wip_operations
    WHERE  wip_entity_id = p_wip_entity_id
    AND   ((quantity_in_queue <> 0
            OR quantity_running <> 0
            OR quantity_waiting_to_move <> 0)
          OR (quantity_in_queue = 0
              and quantity_running = 0
              and quantity_waiting_to_move = 0
              and quantity_scrapped = quantity_completed -- this picks up te max op seq, if only scraps at ops
              and quantity_completed > 0));

    l_stmt_num := 20;

    SELECT operation_sequence_id,
           standard_operation_id,
           department_id,
           quantity_in_queue,
           quantity_running,
           quantity_waiting_to_move,
           first_unit_start_date,
           last_unit_completion_date
    INTO   p_op_seq_id,
           p_std_op_id,
           p_dept_id,
           l_qty_Q,
           l_qty_RUN,
           l_qty_TM,
           p_op_start_date,
           p_op_completion_date
    FROM   wip_operations
    WHERE  wip_entity_id = p_wip_entity_id
    AND    operation_seq_num = p_op_seq_num;


    IF l_qty_Q > 0 THEN
        p_intra_op := 1;
        p_op_qty := l_qty_Q;
    ELSIF l_qty_TM > 0 THEN
        p_intra_op := 3;
        p_op_qty := l_qty_TM;
    ELSIF l_qty_RUN > 0 THEN
        x_err_code := -1;
        x_err_buf := 'WSMPJUPD.GET_JOB_CURR_OP_INFO('||to_char(l_stmt_num)||'): Incorrect job status for this transaction';

        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => x_err_buf                ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_ERROR;

    ELSIF (l_qty_Q = 0) AND (l_qty_RUN = 0) AND (l_qty_TM = 0) THEN
        p_intra_op := 5;
    ELSE
        x_err_code := -1;
        x_err_buf := 'WSMPJUPD.GET_JOB_CURR_OP_INFO('||to_char(l_stmt_num)||'): Incorrect job status for this transaction';

        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => x_err_buf                ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_ERROR;

    END IF;

    l_stmt_num := 30;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_err_code := -1;
                x_err_buf := 'WSMPJUPD.GET_JOB_CURR_OP_INFO('||to_char(l_stmt_num)||'): Incorrect job status for this transaction';

        WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_buf := 'WSMPJUPD.GET_JOB_CURR_OP_INFO('||to_char(l_stmt_num)||'): '||substrb(sqlerrm,1,1000);

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                               p_stmt_num               => l_stmt_num               ,
                                               p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                               p_run_log_level          => l_log_level
                                             );
                END IF;

END GET_JOB_CURR_OP_INFO;
-- end ......


/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WO_FA
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WO_FA(p_txn_id           IN NUMBER,
                             p_txn_org_id       IN NUMBER,
                             p_new_rj_we_id_tbl IN t_number,
                             p_new_rj_qty_tbl   IN t_number,
                             p_rep_we_id        IN NUMBER,
                             p_curr_op_seq_num  IN NUMBER,
                             p_curr_op_seq_id   IN NUMBER,
                             p_txn_job_intraop  IN NUMBER,
                             x_err_code         OUT NOCOPY NUMBER,
                             x_err_buf          OUT NOCOPY VARCHAR2)
IS

   l_op_seq_id_tbl      t_number;
   l_op_seq_num_tbl     t_number;

   l_counter1           number;
   l_counter2           number;
   l_counter            number;

   -- Logging variables.....
   l_msg_tokens         WSM_Log_PVT.token_rec_tbl;
   l_log_level          number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_stmt_num           NUMBER;
   l_module             VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.COPY_REP_JOB_WO_FA';
BEGIN

    l_stmt_num := 10;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Inside COPY_REP_JOB_WO_FA : New Jobs count ' || p_new_rj_we_id_tbl.count
                                                                || ' ' || p_curr_op_seq_num || ' ' || p_rep_we_id,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
    END IF;

    forall l_job_counter in indices of p_new_rj_we_id_tbl
        INSERT INTO WIP_OPERATIONS
            (wip_entity_id,
             operation_seq_num,
             organization_id,
             repetitive_schedule_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             operation_sequence_id,
             standard_operation_id,
             department_id,
             description,
             scheduled_quantity,
             quantity_in_queue,
             quantity_running,
             quantity_waiting_to_move,
             quantity_rejected,
             quantity_scrapped,
             quantity_completed,
             wsm_costed_quantity_completed,
             first_unit_start_date,
             first_unit_completion_date,
             last_unit_start_date,
             last_unit_completion_date,
             previous_operation_seq_num,
             next_operation_seq_num,
             count_point_type,
             backflush_flag,
             minimum_transfer_quantity,
             date_last_moved,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             operation_yield_enabled,
             operation_yield,
             previous_operation_seq_id,
             skip_flag, -- Added for I_PROJECT: JUMP_ENH
             disable_date, -- bug 2931071
             wsm_op_seq_num -- Added to fix bug 3452913
            )
            (
             select
             p_new_rj_we_id_tbl(l_job_counter),
             wo.operation_seq_num,
             wo.organization_id,
             wo.repetitive_schedule_id,
             wo.last_update_date,
             wo.last_updated_by,
             wo.creation_date,
             wo.created_by,
             wo.last_update_login,
             wo.request_id,
             wo.program_application_id,
             wo.program_id,
             wo.program_update_date,
             wo.operation_sequence_id,
             wo.standard_operation_id,
             wo.department_id,
             wo.description,
             -- ST : Added for bug fix 4619823 (Found in UT)
             -- (Update Scheduled qty only in case of Current op + Queue)
             decode(wo.operation_seq_num, p_curr_op_seq_num,
                                          decode(p_txn_job_intraop,1,p_new_rj_qty_tbl(l_job_counter) ,0),
                                          0),
                                          --scheduled qty behavior change as part of MES, also updated in CHANGE_QUANTITY procedure
             decode(wo.quantity_in_queue, 0, 0, p_new_rj_qty_tbl(l_job_counter)),
             wo.quantity_running,
             decode(wo.quantity_waiting_to_move, 0, 0, p_new_rj_qty_tbl(l_job_counter)),
             0, --reject
             0, --scrap
             0, --qty_completed
--           decode(wo.quantity_completed, 0, 0, p_new_rj_qty_tbl(l_job_counter)),
--           decode(wo.quantity_waiting_to_move, 0, 0, p_new_rj_qty_tbl(l_job_counter)), --Fixed bug #2790626
             decode(wo.operation_seq_num, p_curr_op_seq_num,
                                          decode(wo.quantity_waiting_to_move, 0, 0, p_new_rj_qty_tbl(l_job_counter)),
                                          decode(wo.wsm_costed_quantity_completed, 0, 0, p_new_rj_qty_tbl(l_job_counter))),
                                          --wsm_costed_qty_completed (MES change)
             wo.first_unit_start_date,
             wo.first_unit_completion_date,
             wo.last_unit_start_date,
             wo.last_unit_completion_date,
             wo.previous_operation_seq_num,
             wo.next_operation_seq_num,
             wo.count_point_type,
             wo.backflush_flag,
             wo.minimum_transfer_quantity,
             wo.date_last_moved,
             wo.attribute_category,
             wo.attribute1,
             wo.attribute2,
             wo.attribute3,
             wo.attribute4,
             wo.attribute5,
             wo.attribute6,
             wo.attribute7,
             wo.attribute8,

             wo.attribute9,
             wo.attribute10,
             wo.attribute11,
             wo.attribute12,
             wo.attribute13,
             wo.attribute14,
             wo.attribute15,
             wo.operation_yield_enabled,
             wo.operation_yield,
             wo.previous_operation_seq_id,
             wo.skip_flag, -- Added for I_PROJECT: JUMP_ENH
             wo.disable_date, -- bug 2931071
             wo.wsm_op_seq_num -- Added to fix bug 3452913.
             from wip_operations wo
             where wo.wip_entity_id = p_rep_we_id
             AND   wo.operation_seq_num <= p_curr_op_seq_num
             );

   -- Added this stmt to fix bug #2680429--
   -- This resets the pre and next op_seq_num since copying from only past ops
   -- may not set these fields correctly for this new job
   -- forall l_job_counter in p_new_rj_we_id_tbl.first..p_new_rj_we_id_tbl.last
   forall l_job_counter in indices of p_new_rj_we_id_tbl

        UPDATE  wip_operations wo
        SET     wo.previous_operation_seq_num =(SELECT      max(operation_seq_num)
                                                FROM        wip_operations
                                                WHERE       wip_entity_id = p_new_rj_we_id_tbl(l_job_counter)
                                                AND         operation_seq_num < wo.operation_seq_num
                                                ),
                wo.next_operation_seq_num =  (SELECT      min(operation_seq_num)
                                              FROM        wip_operations
                                              WHERE       wip_entity_id = p_new_rj_we_id_tbl(l_job_counter)
                                              AND         operation_seq_num > wo.operation_seq_num
                                             )
        WHERE   wo.wip_entity_id = p_new_rj_we_id_tbl(l_job_counter);
   --
   l_stmt_num := 20;

   select operation_sequence_id,
          operation_seq_num
   bulk collect into l_op_seq_id_tbl,l_op_seq_num_tbl
   from  wip_operations wo
   where wip_entity_id =  p_rep_we_id
   AND   wo.operation_seq_num <= p_curr_op_seq_num;

   l_stmt_num := 30;
   if p_new_rj_we_id_tbl.count > 0 then
           l_counter := p_new_rj_we_id_tbl.first;
           while l_counter is not null loop

                --Start: Fix for bug #4990745--
                l_stmt_num := 40;
                -- Copy job header level attachments
                FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
                    (x_from_entity_name      => 'WSM_LOTBASED_JOBS',
                    x_from_pk1_value         => to_char(p_txn_org_id),
                    x_from_pk2_value         => to_char(p_rep_we_id),
                    x_to_entity_name         => 'WSM_LOTBASED_JOBS',
                    x_to_pk1_value           => to_char(p_txn_org_id),
                    x_to_pk2_value           => to_char(p_new_rj_we_id_tbl(l_counter)),
                    x_created_by             => g_user_id,
                    x_last_update_login      => g_user_login_id,
                    x_program_application_id => g_program_appl_id,
                    x_program_id             => g_program_id,
                    x_request_id             => g_request_id
                   );
                l_stmt_num := 50;
                --End: Fix for bug #4990745--

                l_counter1 := l_op_seq_id_tbl.first;
                l_counter2 := l_op_seq_num_tbl.first;

                while (l_counter1 is not null) and
                      (l_counter2 is not null)
                loop
                   l_stmt_num := 60;
                   FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(x_from_entity_name       => 'BOM_OPERATION_SEQUENCES',
                                                                x_from_pk1_value         => to_char(l_op_seq_num_tbl(l_counter1)),
                                                                x_to_entity_name         => 'WSM_LOT_BASED_OPERATIONS',
                                                                x_to_pk1_value           => to_char(p_new_rj_we_id_tbl(l_counter)),
                                                                x_to_pk2_value           => to_char(l_op_seq_id_tbl(l_counter2)),
                                                                x_to_pk3_value           => to_char(p_txn_org_id),
                                                                x_created_by             => g_user_id,
                                                                x_last_update_login      => g_user_login_id,
                                                                x_program_application_id => g_program_appl_id,
                                                                x_program_id             => g_program_id,
                                                                x_request_id             => g_request_id
                                                               );
                  l_stmt_num := 70;
                  l_counter1 := l_op_seq_id_tbl.next(l_counter1);
                  l_counter2 := l_op_seq_num_tbl.next(l_counter2);

                end loop;
                l_counter := p_new_rj_we_id_tbl.next(l_counter);
        END LOOP;
   end if;
   l_stmt_num := 80;
   x_err_code := 0;
   x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WO_FA('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


END COPY_REP_JOB_WO_FA;


/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WOR
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WOR(p_txn_id             IN NUMBER,
                           p_new_rj_we_id_tbl   IN t_number,
                           p_rep_we_id          IN NUMBER,
                           p_curr_op_seq_num    IN NUMBER,
                           x_err_code           OUT NOCOPY NUMBER,
                           x_err_buf            OUT NOCOPY VARCHAR2)
IS

    -- Logging variables.....
    l_msg_tokens    WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.COPY_REP_JOB_WOR';

BEGIN

    forall l_job_counter in indices of p_new_rj_we_id_tbl
        INSERT INTO WIP_OPERATION_RESOURCES
                           (wip_entity_id,
                            operation_seq_num,
                            resource_seq_num,
                            organization_id,
                            repetitive_schedule_id,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            request_id,
                            program_application_id,
                            program_id,
                            program_update_date,
                            resource_id,
                            uom_code,
                            basis_type,
                            usage_rate_or_amount,
                            activity_ID,
                            scheduled_flag,
                            assigned_units,
                            autocharge_type,
                            standard_rate_flag,
                            applied_resource_units,
                            applied_resource_value,
                            start_date,
                            completion_date,
                            attribute_category,
                            attribute1,
                            attribute2,
                            attribute3,
                            attribute4,
                            attribute5,
                            attribute6,
                            attribute7,
                            attribute8,
                            attribute9,
                            attribute10,
                            attribute11,
                            attribute12,
                            attribute13,
                            attribute14,
                            attribute15,
                            schedule_seq_num,
                            substitute_group_num,
                            principle_flag,
                            setup_id      ,
                            -- ST : Detailed Scheduling --
                            maximum_assigned_units      ,
                            firm_flag                   ,
                            parent_resource_seq
                            -- ST : Detailed Scheduling --
                            )
                            (
                            select
                            p_new_rj_we_id_tbl(l_job_counter),
                            wor.operation_seq_num,
                            wor.resource_seq_num,
                            wor.organization_id,
                            wor.repetitive_schedule_id,
                            wor.last_update_date,
                            wor.last_updated_by,
                            wor.creation_date,
                            wor.created_by,
                            wor.last_update_login,
                            wor.request_id,
                            wor.program_application_id,
                            wor.program_id,
                            wor.program_update_date,
                            wor.resource_id,
                            wor.uom_code,
                            wor.basis_type,
                            wor.usage_rate_or_amount,
                            wor.activity_id,
                            wor.scheduled_flag,
                            wor.assigned_units,
                            wor.autocharge_type,
                            wor.standard_rate_flag,
                            0,  --applied_resource_units
                            0,  --applied_resource_value
                            wor.start_date,
                            wor.completion_date,
                            wor.attribute_category,
                            wor.attribute1,
                            wor.attribute2,
                            wor.attribute3,
                            wor.attribute4,
                            wor.attribute5,
                            wor.attribute6,
                            wor.attribute7,
                            wor.attribute8,
                            wor.attribute9,
                            wor.attribute10,
                            wor.attribute11,
                            wor.attribute12,
                            wor.attribute13,
                            wor.attribute14,
                            wor.attribute15,
                            wor.schedule_seq_num,
                            wor.substitute_group_num,
                            wor.principle_flag,
                            wor.setup_id      ,
                            -- ST : Detailed Scheduling --
                            wor.maximum_assigned_units          ,
                            0                                   ,
                            wor.parent_resource_seq
                            -- ST : Detailed Scheduling --
                            from wip_operation_resources wor
                            WHERE  wor.wip_entity_id = p_rep_we_id
                            AND    wor.operation_seq_num <= p_curr_op_seq_num
                         );

    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WOR('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


END COPY_REP_JOB_WOR;


--Start: Additions for APS-WLT--
/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WSOR
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WSOR(p_txn_id            IN NUMBER,
                           p_new_rj_we_id_tbl   IN t_number,
                           p_rep_we_id          IN NUMBER,
                           p_curr_op_seq_num    IN NUMBER,
                           x_err_code           OUT NOCOPY NUMBER,
                           x_err_buf            OUT NOCOPY VARCHAR2)
IS

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.COPY_REP_JOB_WSOR';
BEGIN


    l_stmt_num := 20;

    forall l_job_counter in indices of p_new_rj_we_id_tbl
        INSERT INTO WIP_SUB_OPERATION_RESOURCES
               (wip_entity_id,
                operation_seq_num,
                resource_seq_num,
                organization_id,
                repetitive_schedule_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                resource_id,
                uom_code,
                basis_type,
                usage_rate_or_amount,
                activity_ID,
                scheduled_flag,
                assigned_units,
                maximum_assigned_units, -- ST : Detailed Scheduling --
                autocharge_type,
                standard_rate_flag,
                applied_resource_units,
                applied_resource_value,
                start_date,
                completion_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                relieved_res_completion_units,
                relieved_res_scrap_units,
                relieved_res_completion_value,
                relieved_res_scrap_value,
                relieved_variance_value,
                temp_relieved_value,
                relieved_res_final_comp_units,
                department_id,
                phantom_flag,
                phantom_op_seq_num,
                phantom_item_id,
                schedule_seq_num,
                substitute_group_num,
                replacement_group_num,
                principle_flag,
                setup_id
                ) (
                select
                p_new_rj_we_id_tbl(l_job_counter),
                wsor.operation_seq_num,
                wsor.resource_seq_num,
                wsor.organization_id,
                wsor.repetitive_schedule_id,
                wsor.last_update_date,
                wsor.last_updated_by,
                wsor.creation_date,
                wsor.created_by,
                wsor.last_update_login,
                wsor.request_id,
                wsor.program_application_id,
                wsor.program_id,
                wsor.program_update_date,
                wsor.resource_id,
                wsor.uom_code,
                wsor.basis_type,
                wsor.usage_rate_or_amount,
                wsor.activity_id,
                wsor.scheduled_flag,
                wsor.assigned_units,
                wsor.maximum_assigned_units, -- ST : Detailed Scheduling --
                wsor.autocharge_type,
                wsor.standard_rate_flag,
                0,  --applied_resource_units
                0,  --applied_resource_value
                wsor.start_date,
                wsor.completion_date,
                wsor.attribute_category,
                wsor.attribute1,
                wsor.attribute2,
                wsor.attribute3,
                wsor.attribute4,
                wsor.attribute5,
                wsor.attribute6,
                wsor.attribute7,
                wsor.attribute8,
                wsor.attribute9,
                wsor.attribute10,
                wsor.attribute11,
                wsor.attribute12,
                wsor.attribute13,
                wsor.attribute14,
                wsor.attribute15,
                wsor.relieved_res_completion_units,
                wsor.relieved_res_scrap_units,
                wsor.relieved_res_completion_value,
                wsor.relieved_res_scrap_value,
                wsor.relieved_variance_value,
                wsor.temp_relieved_value,
                wsor.relieved_res_final_comp_units,
                wsor.department_id,
                wsor.phantom_flag,
                wsor.phantom_op_seq_num,
                wsor.phantom_item_id,
                wsor.schedule_seq_num,
                wsor.substitute_group_num,
                wsor.replacement_group_num,
                wsor.principle_flag,
                wsor.setup_id
                from wip_sub_operation_resources wsor
                WHERE  wsor.wip_entity_id = p_rep_we_id
                AND    wsor.operation_seq_num <= p_curr_op_seq_num);

    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WSOR('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


END COPY_REP_JOB_WSOR;
--End: Additions for APS-WLT--

/* ST : Detailed Scheduling start */

/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WORI                                     |
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WORI(p_txn_id            IN NUMBER,
                           p_new_rj_we_id_tbl   IN t_number,
                           p_rep_we_id          IN NUMBER,
                           p_curr_op_seq_num    IN NUMBER,
                           x_err_code           OUT NOCOPY NUMBER,
                           x_err_buf            OUT NOCOPY VARCHAR2
                           )
IS

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.COPY_REP_JOB_WORI';


BEGIN
        l_stmt_num := 30;

        forall l_job_counter in indices of p_new_rj_we_id_tbl

                INSERT INTO WIP_OP_RESOURCE_INSTANCES
                           (   WIP_ENTITY_ID ,
                                OPERATION_SEQ_NUM,
                                RESOURCE_SEQ_NUM ,
                                ORGANIZATION_ID ,
                                LAST_UPDATE_DATE ,
                                LAST_UPDATED_BY ,
                                CREATION_DATE,
                                CREATED_BY ,
                                LAST_UPDATE_LOGIN,
                                INSTANCE_ID ,
                                SERIAL_NUMBER,
                                START_DATE ,
                                COMPLETION_DATE,
                                BATCH_ID
                            )
                            (
                             select
                                p_new_rj_we_id_tbl(l_job_counter),
                                wori.OPERATION_SEQ_NUM,
                                wori.RESOURCE_SEQ_NUM ,
                                wori.ORGANIZATION_ID ,
                                wori.LAST_UPDATE_DATE ,
                                wori.LAST_UPDATED_BY ,
                                wori.CREATION_DATE,
                                wori.CREATED_BY ,
                                wori.LAST_UPDATE_LOGIN,
                                wori.INSTANCE_ID ,
                                wori.SERIAL_NUMBER,
                                wori.START_DATE ,
                                wori.COMPLETION_DATE,
                                wori.BATCH_ID
                             FROM
                                wip_op_resource_instances wori
                             WHERE
                                wori.wip_entity_id = p_rep_we_id
                                AND wori.operation_seq_num <= p_curr_op_seq_num
                             );
    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;
EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WORI('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


END ;

/* ST : Detailed Scheduling end */

/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WRO
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WRO(p_txn_id             IN              NUMBER,
                           p_new_rj_we_id_tbl   IN              t_number,
                           p_new_rj_qty_tbl     IN              t_number,
                           p_rep_we_id          IN              NUMBER,
                           p_curr_op_seq_num    IN              NUMBER,
                           p_txn_intraop_step   IN              NUMBER,
                           x_err_code           OUT NOCOPY      NUMBER,
                           x_err_buf            OUT NOCOPY      VARCHAR2)
IS

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.COPY_REP_JOB_WRO';
BEGIN


    l_stmt_num := 20;

    -- related bugs : 3453210
    -- Start NL Bugfix 3453210: Set required qty to zero if it's for an obsolete operation
    -- Checkin 115.114 is original fix.  In 115.115, added a check to make sure we don't do
    --- this for phantom component rows, i.e. where op_seq_num is less than zero.

    forall l_job_counter in indices of p_new_rj_we_id_tbl
        INSERT INTO WIP_REQUIREMENT_OPERATIONS
        (       inventory_item_id,
                organization_id,
                wip_entity_id,
                operation_seq_num,
                repetitive_schedule_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                component_sequence_id,
                wip_supply_type,
                basis_type,        --LBM enh
                date_required,
                required_quantity,
                quantity_issued,
                quantity_per_assembly,
                component_yield_factor,--R12:Comp Shrinkage project
                supply_subinventory,
                supply_locator_id,
                mrp_net_flag,
                comments,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
                department_id
            )
            (
            select
                wro.inventory_item_id,
                wro.organization_id,
                p_new_rj_we_id_tbl(l_job_counter),
                wro.operation_seq_num,
                wro.repetitive_schedule_id,
                wro.last_update_date,
                wro.last_updated_by,
                wro.creation_date,
                wro.created_by,
                wro.last_update_login,
                wro.component_sequence_id,
                wro.wip_supply_type,
                wro.basis_type,       --LBM enh
                wro.date_required,
                -- ST : Added the below for bug fix : 4619823
                (case
                 when (wro.operation_seq_num = p_curr_op_seq_num)
                 then decode(p_txn_intraop_step,
                             WIP_CONSTANTS.QUEUE,
                                       ROUND( ( (wro.quantity_per_assembly/nvl(wro.component_yield_factor,1))                                                        --LBM enh
                                                *
                                                decode(p_new_rj_qty_tbl(l_job_counter),
                                                       0, 0,
                                                       decode(wro.basis_type,
                                                              2, 1,
                                                              p_new_rj_qty_tbl(l_job_counter)
                                                              )
                                                      )
                                               )
                                               , 6
                                             ),    --LBM enh
                             WIP_CONSTANTS.TOMOVE,0)
                 else
                      0
                 end
                ),
                -- ST : Added the below for bug fix : 4619823
                -- ST : Commented out the below for bug fix : 4619823
                -- (case when (wro.operation_seq_num>=0 and wo.count_point_type = 3 and wo.scheduled_quantity = 0)
                --       then
                --            0
                --       else
                --            ROUND((wro.quantity_per_assembly/nvl(wro.component_yield_factor,1))                                                        --LBM enh
                --               * decode(p_new_rj_qty_tbl(l_job_counter), 0, 0, decode(wro.basis_type, 2, 1, p_new_rj_qty_tbl(l_job_counter))), 6)    --LBM enh
                -- end),
                -- ST : Commented out the below for bug fix : 4619823
                0, --quantity_issued,
                wro.quantity_per_assembly,
                nvl(wro.component_yield_factor,1),--R12:Comp Shrinkage project
                wro.supply_subinventory,
                wro.supply_locator_id,
                wro.mrp_net_flag,
                wro.comments,
                wro.attribute_category,
                wro.attribute1,
                wro.attribute2,
                wro.attribute3,
                wro.attribute4,
                wro.attribute5,
                wro.attribute6,
                wro.attribute7,
                wro.attribute8,
                wro.attribute9,
                wro.attribute10,
                wro.attribute11,
                wro.attribute12,
                wro.attribute13,
                wro.attribute14,
                wro.attribute15,
                wro.segment1,
                wro.segment2,
                wro.segment3,
                wro.segment4,
                wro.segment5,
                wro.segment6,
                wro.segment7,
                wro.segment8,
                wro.segment9,
                wro.segment10,
                wro.segment11,
                wro.segment12,
                wro.segment13,
                wro.segment14,
                wro.segment15,
                wro.segment16,
                wro.segment17,
                wro.segment18,
                wro.segment19,
                wro.segment20,
                wro.department_id

            from wip_requirement_operations wro
                 , wip_operations wo
            WHERE  wro.wip_entity_id = p_rep_we_id
            AND    wro.operation_seq_num <= p_curr_op_seq_num
            AND    wro.operation_seq_num >= 0-p_curr_op_seq_num  --To take care of phantoms bug #2681370
            and    wo.wip_entity_id  = p_rep_we_id
            and    wo.operation_seq_num = wro.operation_seq_num
          );

    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WRO('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;

END COPY_REP_JOB_WRO;
-- end...

-- start....
/*-------------------------------------------------------------+
| Name : COPY_REP_JOB_WOY
---------------------------------------------------------------*/

PROCEDURE COPY_REP_JOB_WOY(p_txn_id                     IN              NUMBER,
                           p_new_rj_we_id_tbl           IN              t_number,
                           p_rep_we_id                  IN              NUMBER,
                           p_curr_op_seq_num            IN              NUMBER,
                           x_err_code                   OUT NOCOPY      NUMBER,
                           x_err_buf                    OUT NOCOPY      VARCHAR2
                          )
IS

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.COPY_REP_JOB_WOY';
BEGIN

    l_stmt_num := 20;

    forall l_job_counter in indices of p_new_rj_we_id_tbl
        INSERT INTO WIP_OPERATION_YIELDS
            (wip_entity_id,
             operation_seq_num,
             organization_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             scrap_account,
             est_scrap_absorb_account,
             status
            )
            (
             select
             p_new_rj_we_id_tbl(l_job_counter),
             woy.operation_seq_num,
             woy.organization_id,
             woy.last_update_date,
             woy.last_updated_by,
             woy.creation_date,
             woy.created_by,
             woy.last_update_login,
             woy.request_id,
             woy.program_application_id,
             woy.program_id,
             woy.program_update_date,
             woy.scrap_account,
             woy.est_scrap_absorb_account,
             NULL
             from wip_operation_yields woy
             WHERE  wip_entity_id = p_rep_we_id
             AND    operation_seq_num <= p_curr_op_seq_num
             );

    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.COPY_REP_JOB_WOY('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;

END COPY_REP_JOB_WOY;
-- end..


/*-------------------------------------------------------------+
| Name : CHANGE_QUANTITY
---------------------------------------------------------------*/
-- Updates following quantity columns
-- WDJ: start_quantity, net_quantity
-- WO : quantity_in_queue, quantity_waiting_to_move, scheduled_quantity, quantity_completed
-- WRO: required_quantity
/*
This procedure will be called for split/merge to update the starting jobs and also for Update quantity transaction...


Parameters : p_txn_id                   :       Transaction id
             p_txn_type                 :       transaction type
             p_wip_entity_id_tbl        :       Table of Wip entity ids of the starting jobs...
             p_new_job_qty_tbl          :       New job qty tbl... will be 0 for the completely merged/split jobs
             p_new_net_qty_tbl          :       Net quantity ... will be 0 for the completely merged/split jobs
             p_txn_job_op_seq_tbl       :       table of operation seq num of the job
             p_txn_job_intraop          :       intraop step....

             p_sj_st_qty_tbl            :      table of Old start qty of the starting jobs...
             p_sj_avail_qty_tbl         :      table of  Old start_quantity - quantity_scrapped of the starting jobs
             p_sj_scrap_qty_tbl         :      table of quantity_scrapped
*/

PROCEDURE CHANGE_QUANTITY(p_txn_id              IN              NUMBER,
                          p_txn_type            IN              NUMBER,
                          p_wip_entity_id_tbl   IN              t_number,
                          p_new_job_qty_tbl     IN              t_number,
                          p_new_net_qty_tbl     IN              t_number, -- User given/defaulted Bug# 3181486 - Net Planned Qty
                          p_txn_job_op_seq_tbl  IN              t_number,
                          p_txn_job_intraop     IN              NUMBER, -- will be number as only one intraop is possible..

                          p_sj_st_qty_tbl       IN              t_number,
                          p_sj_avail_qty_tbl    IN              t_number,
                          p_sj_scrap_qty_tbl    IN              t_number,

                          x_err_code            OUT NOCOPY      NUMBER,
                          x_err_buf             OUT NOCOPY      VARCHAR2
                         )
IS

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.CHANGE_QUANTITY';
    --Bug 5254440: Added the parameter p_op_seq_num.
    cursor c_job_wo(p_wip_entity_id number,p_op_seq_num NUMBER) is select quantity_in_queue + quantity_running + quantity_completed total_quantity,
                                               operation_seq_num
                                               from wip_operations wo
                                               where wo.wip_entity_id = p_wip_entity_id
                                               and   wo.operation_seq_num = p_op_seq_num;
BEGIN

    l_stmt_num := 10;
    -- Related Bugs : 3181486 , 2674320 */

    --Set the WDJ.start_quantity for all Split/Merge/Update Quantity Transactions----------------------------


    forall l_job_counter in indices of p_wip_entity_id_tbl
        UPDATE wip_discrete_jobs
        SET    start_quantity = (p_sj_st_qty_tbl(l_job_counter) - p_sj_avail_qty_tbl(l_job_counter) + p_new_job_qty_tbl(l_job_counter)),
               net_quantity = nvl(p_new_net_qty_tbl(l_job_counter), 0)
        WHERE  wip_entity_id = p_wip_entity_id_tbl(l_job_counter);

    l_stmt_num := 40;

    -- Update WO using the new qty
    forall l_job_counter in indices of p_wip_entity_id_tbl
            UPDATE wip_operations
            SET    quantity_in_queue = decode(quantity_in_queue, 0, 0, p_new_job_qty_tbl(l_job_counter)),
                   quantity_waiting_to_move = decode(quantity_waiting_to_move, 0, 0, p_new_job_qty_tbl(l_job_counter))
            WHERE  wip_entity_id = p_wip_entity_id_tbl(l_job_counter)
            AND    operation_seq_num = p_txn_job_op_seq_tbl(l_job_counter);

    l_stmt_num := 50;
    if p_txn_job_intraop = 1 then  --check added as part of MES actual qty changes(AH)
            forall l_job_counter in indices of p_wip_entity_id_tbl
                    UPDATE wip_operations wo
                    -- ST : Added for bug fix 4619823 (Found in UT)
                    -- SET    scheduled_quantity = (scheduled_quantity - p_sj_avail_qty_tbl(l_job_counter) + p_new_job_qty_tbl(l_job_counter))
                    SET    scheduled_quantity = (nvl(quantity_scrapped,0) + quantity_in_queue)
                    WHERE  wip_entity_id = p_wip_entity_id_tbl(l_job_counter)
                    -- ST : Added for bug fix 4619823...
                    -- Should update the current operation only...
                    AND    operation_seq_num = p_txn_job_op_seq_tbl(l_job_counter);
    end if;

    l_stmt_num := 60;

    forall l_job_counter in indices of p_wip_entity_id_tbl
            UPDATE wip_operations wo
            SET    wsm_costed_quantity_completed = decode(wo.count_point_type,3,0,  --changed to costed qty completed as part of MES actual qty changes(AH)
                                               wsm_costed_quantity_completed - p_sj_avail_qty_tbl(l_job_counter) + p_new_job_qty_tbl(l_job_counter))
            WHERE  wip_entity_id = p_wip_entity_id_tbl(l_job_counter)
            AND    ( (p_txn_job_intraop = WIP_CONSTANTS.QUEUE
                      AND operation_seq_num < p_txn_job_op_seq_tbl(l_job_counter))
                    OR
                     (p_txn_job_intraop = WIP_CONSTANTS.TOMOVE
                      AND operation_seq_num <= p_txn_job_op_seq_tbl(l_job_counter))
                   );

    -- Update WRO using the new qty
    l_stmt_num := 70;

    -- related bugs 2682597
    -- ST : Added for bug fix 4619823 --
    if p_txn_job_intraop = 1 then
        for l_job_counter in p_wip_entity_id_tbl.first..p_wip_entity_id_tbl.last loop
                --LBM enh: Changed the expression for required quantity
                --Bug 5254440: Value passed for the parameter p_op_seq_num.
                for l_job_wo_rec in c_job_wo(p_wip_entity_id_tbl(l_job_counter),p_txn_job_op_seq_tbl(l_job_counter)) loop
                        UPDATE wip_requirement_operations wro
                        SET    required_quantity = ROUND( (wro.quantity_per_assembly/nvl(wro.component_yield_factor,1)
                                                           * decode(l_job_wo_rec.total_quantity
                                                                    , 0,0
                                                                    , decode(wro.basis_type,
                                                                             2,1,
                                                                             (l_job_wo_rec.total_quantity)
                                                                             -- ST : Added for bug fix 4619823 (Found in UT)
                                                                             -- nvl(wro.quantity_relieved,0)) -- Or is it Quantity_completed.
                                                                             )
                                                                    )
                                                           ),6)
                        WHERE  wro.wip_entity_id = p_wip_entity_id_tbl(l_job_counter)
                        and  nvl(abs(wro.quantity_issued),0) >= nvl(abs(wro.quantity_relieved),0) -- Added abs() on quantity_issued for bug 6053122(fp for 5843039)
                        -- ST : Commenting out for bug fix 4619823
                        -- Actual Quantity Changes : Should update the current operation only
                        -- and    ( (wro.operation_seq_num = l_job_wo_rec.operation_seq_num)
                        --         or
                        --         (wro.operation_seq_num = 0-l_job_wo_rec.operation_seq_num)
                        --         )
                        -- ST : Added for bug fix 4619823...
                        -- Should update the current operation only...
                        AND  operation_seq_num = p_txn_job_op_seq_tbl(l_job_counter);
                end loop;
        end loop;
        -- To take care of phantoms bug #2681370
        -- End fix for bug #2682597--
    END IF;
    l_stmt_num := 90;

    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.CHANGE_QUANTITY('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;

END CHANGE_QUANTITY;
--- end ...

/*-------------------------------------------------------------+
| Name : handle_kanban_sub_loc_change
---------------------------------------------------------------*/
/*
-- if user has changes sub/loc during a wip lot txn, and the job has kanban ref
-- dereference the job.
-- this returns 0 if subinv/locator are the same, else return 1

*/
function handle_kanban_sub_loc_change(  p_wip_entity_id                         IN  number,
                                        p_kanban_card_id                        IN  number,
                                        p_wssj_completion_subinventory          IN  varchar2,
                                        p_wssj_completion_locator_id            IN  number,
                                        p_wsrj_completion_subinventory          IN  varchar2,
                                        p_wsrj_completion_locator_id            IN  number,
                                        x_err_code                              OUT NOCOPY number,
                                        x_err_msg                               OUT NOCOPY varchar2
                                      )
                                      return number
IS

    l_sub_loc_change_flag  number;
    l_ret_status           varchar2(1);

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.handle_kanban_sub_loc_change';

begin

    l_stmt_num := 10;

    l_sub_loc_change_flag := 0;

    if p_kanban_card_id is not null then

        l_stmt_num := 20;

        if (p_wssj_completion_subinventory = p_wsrj_completion_subinventory) AND
             --Bug 5344676:Following statement causes the supply status of the Kanban to be
             --exception if the locator id is null.
             --(nvl(p_wssj_completion_locator_id,-999) = nvl(p_wsrj_completion_locator_id,-1))
             (nvl(p_wssj_completion_locator_id,-1) = nvl(p_wsrj_completion_locator_id,-1))
        then
                l_sub_loc_change_flag := 0;
        else
                l_sub_loc_change_flag := 1;

                l_stmt_num := 30;

                INV_Kanban_PVT.Update_Card_Supply_Status (X_Return_Status => l_ret_status,
                                                          p_Kanban_Card_Id => p_kanban_card_id,
                                                          p_Supply_Status => INV_Kanban_PVT.G_Supply_Status_Exception
                                                     );

                if ( l_ret_status <> fnd_api.g_ret_sts_success ) then
                    x_err_code := -1;
                    fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');

                    fnd_message.set_token('STATUS',g_translated_meaning);
                    x_err_msg := fnd_message.get;

                    return -99;

             end if;

             l_stmt_num := 40;

        end if;

    end if; -- kanban card is not null

    return l_sub_loc_change_flag;

EXCEPTION

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPJUPD.handle_kanban_sub_loc_change('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


        return -99;

end handle_kanban_sub_loc_change;
-- abbkanban end


/*-------------------------------------------------------------+
| Name : UPDATE_QTY_ISSUED
---------------------------------------------------------------*/
/*
-- This procedure is called only for Split/Merge/Update Quantity transactions
Parameters :
p_txn_id                :       Transaction id
p_txn_type              :       Transaction type...
p_rep_we_id             :       Wip entity id of the representative starting job...
p_rep_op_seq_num        :       Job Operation  seq num of the rep. starting job...
p_rep_avail_qty         :       Available qty of the rep. starting job...
p_new_rep_job_qty       :       New qty of the rep. starting job ( will be non-zero if the starting job is also a resulting job....)
p_non_rep_sj_we_id_tbl  :       Table containing the wip_entity_id of the non-representative starting jobs..
p_new_rj_we_id_tbl      :       Table containing the wip_entity_id of the new resulting  jobs..
*/
PROCEDURE UPDATE_QTY_ISSUED(p_txn_id                    IN              NUMBER,
                            p_txn_type                  IN              NUMBER,
                            p_rep_we_id                 IN              NUMBER,
                            p_rep_op_seq_num            IN              NUMBER,
                            p_rep_avail_qty             IN              NUMBER,
                            p_rep_new_job_qty           IN              NUMBER,
                            p_txn_job_intraop           IN              NUMBER,
                            p_non_rep_sj_we_id_tbl      IN              t_number,
                            p_new_rj_we_id_tbl          IN              t_number,
                            p_new_rj_start_qty          IN              t_number,
                            x_err_code                  OUT NOCOPY      NUMBER,
                            x_err_buf                   OUT NOCOPY      VARCHAR2
                           )
IS

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.UPDATE_QTY_ISSUED';
BEGIN

    l_stmt_num := 10;
    x_err_code := 0;

    IF p_txn_type IN (WSMPCNST.SPLIT, WSMPCNST.MERGE) THEN
        --This has been added to improve performance
        -- as such the following stmts wont update anything for Upd Qty
        l_stmt_num := 20;

        -- Update the non-representative starting jobs
        /*** MES Actual Qty changes(Change description)  --AH****/
        --The calculation for quantity_issued would remain unchanged for the parent job if
        --it is at ToMove as per the new behavior and also as costing has fixed the bug 2120717.
        -- The calculation of qty_issued will change as below at Queue due to MES
        /*** End MES Actual Qty changes(Change description) ****/

        if p_txn_type = WSMPCNST.MERGE and
           p_txn_job_intraop = 1 -- ST : Added for bug fix : 4619823 --
        then

            forall l_job_counter in indices of p_non_rep_sj_we_id_tbl

               	-- Added abs() on quantity_issued for bug 6053122(fp for 5843039)


		UPDATE wip_requirement_operations wro
                -- ST : Commenting out the below for bug fix : 4619823 --
                --SET    wro.quantity_issued = decode(p_txn_job_intraop,1,round(NVL(wro.quantity_relieved, 0), 6)
                --                                                     ,3,wro.quantity_issued
                --                                   )
                -- ST : Added the below for bug fix : 4619823 --
                SET    wro.quantity_issued = round(NVL(wro.quantity_relieved, 0), 6)
                WHERE  wro.wip_entity_id = p_non_rep_sj_we_id_tbl(l_job_counter)
                AND    nvl(abs(wro.quantity_issued), 0) >= nvl(abs(wro.quantity_relieved), 0)
                -- ST : Added the below for bug fix : 4619823 --
                -- Should be updating only the op at which the TXN took place...
                -- That Op will be the MAX Non-Obsoleted Operation
                AND    wro.operation_seq_num = (select max(operation_seq_num)
                                               from   wip_operations wo
                                               where  wo.wip_entity_id     = p_non_rep_sj_we_id_tbl(l_job_counter)
                                               and    wo.count_point_type  <> 3);
                -- If there is a PUSH comp and the whole qty is scrapped, qty_rel > qty_iss
                -- ST : Commenting out the below for bug fix : 4619823 --
                -- AND    not exists (select 'obsolete operation'
                --                    from   wip_operations wo
                --                    where  wo.wip_entity_id     = wro.wip_entity_id
                --                    and    wo.organization_id   = wro.organization_id
                --                    and    wo.operation_seq_num = wro.operation_seq_num
                --                    and    wo.count_point_type  = 3);

                --Start deletions to fix bug #2901741--
                --Deleted the following, since this fix is incorrect--
                --Start adding condition to fix bug #2664909--
                --    AND    wro.inventory_item_id IN (select inventory_item_id
                --                   from   wip_requirement_operations
                --                   where  wip_entity_id = l_rep_we_id
                --                   and    operation_seq_num = wro.operation_seq_num)
                --End adding condition to fix bug #2664909--
                --Deleted the following, since if A(ops 10,20) and B(ops 10,20,30,40) are merged into A,
                --requirements for op 30,40 in job B are not set to 0.
                --This was initially inherited from costing
                --    AND    operation_seq_num <= l_op_seq_num;
                --End deletions to fix bug #2901741--

        end if;

        l_stmt_num := 30;

        -- Update the non-matching resulting jobs i.e. new jobs (during split and merge)
        -- related bugs ... : 3086120
        IF p_txn_job_intraop = 1 THEN
                forall l_job_counter in indices of p_new_rj_we_id_tbl

                      	-- Added abs() on quantity_issued for bug 6053122(fp for 5843039)

			UPDATE wip_requirement_operations wro
                        -- ST : Commenting for bug fix 4619823
                        -- SET    wro.quantity_issued =  decode(p_txn_job_intraop,1,(SELECT round(decode(sign(nvl(wro1.quantity_issued, 0) - nvl(wro1.quantity_relieved, 0)), 1, 1, 0)
                        --                                                           *(nvl(wro1.quantity_issued,0) - nvl(wro1.quantity_relieved, 0))
                        --                                                           * p_new_rj_start_qty(l_job_counter)/p_rep_avail_qty, 6)
                        --                                                        FROM   wip_requirement_operations wro1
                        --                                                        WHERE  wro1.wip_entity_id     = p_rep_we_id
                        --                                                        AND    wro1.inventory_item_id = wro.inventory_item_id
                        --                                                        AND    wro1.organization_id   = wro.organization_id
                        --                                                        AND    wro1.operation_seq_num = wro.operation_seq_num
                        --                                                        AND    p_new_rj_we_id_tbl(l_job_counter) = wro.wip_entity_id),
                        --                                                      3,0)
                        -- ST : Commenting for bug fix 4619823 --
                        -- ST : Added the below for bug fix 4619823 --
                        SET    wro.quantity_issued =  (SELECT round(decode(sign(nvl(abs(wro1.quantity_issued), 0) - nvl(abs(wro1.quantity_relieved), 0)), 1, 1, 0)
                                                             *(nvl(wro1.quantity_issued,0) - nvl(wro1.quantity_relieved, 0))
                                                             * p_new_rj_start_qty(l_job_counter)/p_rep_avail_qty, 6)
                                                          FROM   wip_requirement_operations wro1
                                                          WHERE  wro1.wip_entity_id     = p_rep_we_id
                                                          AND    wro1.inventory_item_id = wro.inventory_item_id
                                                          AND    wro1.organization_id   = wro.organization_id
                                                          AND    wro1.operation_seq_num = wro.operation_seq_num
                                                          AND    p_new_rj_we_id_tbl(l_job_counter) = wro.wip_entity_id)
                        WHERE  wro.wip_entity_id = p_new_rj_we_id_tbl(l_job_counter)
                        and    wro.operation_seq_num = p_rep_op_seq_num
                        AND    not exists (select 'obsolete operation'
                                           from   wip_operations wo
                                           where  wo.wip_entity_id     = wro.wip_entity_id
                                           and    wo.organization_id   = wro.organization_id
                                           and    wo.operation_seq_num = wro.operation_seq_num
                                           and    wo.count_point_type  = 3);

                --Start deletions to fix bug #2901741--
                --The following condition is not required, since in Rep Job, there wont be any ops > l_op_seq_num
                --This was initially inherited from costing
                --    AND    operation_seq_num <= l_op_seq_num;
                --End deletions to fix bug #2901741--
        END IF;
    END IF;

    -- Related bugs : 2901741
    -- For representative job
    -- Things will change only in case of Queue...
    -- ST : Added the IF clause for bug fix 4619823
    IF p_txn_job_intraop = 1 THEN

	    	-- Added abs() on quantity_issued for bug 6053122(fp for 5843039)

	    UPDATE wip_requirement_operations wro
            -- ST : Commenting for bug fix 4619823
            --        SET    wro.quantity_issued =  decode(p_txn_job_intraop,1,round( (decode(sign(nvl(wro.quantity_issued, 0) - nvl(wro.quantity_relieved, 0)),
            --                                                                             1, 1
            --                                                                             , 0)
            --                                                                       *(nvl(wro.quantity_issued,0) - nvl(wro.quantity_relieved, 0))
            --                                                                       * p_rep_new_job_qty/p_rep_avail_qty
            --                                                                       + nvl(wro.quantity_relieved, 0)
            --                                                                      ), 6)
            --                                                             -- What for 3..?
            --                                                             ,3,wro.quantity_issued
            --                                                             )
            -- ST : Added the below for bug fix 4619823
            SET    wro.quantity_issued =  round((decode(sign(nvl(abs(wro.quantity_issued), 0) - nvl(abs(wro.quantity_relieved), 0)),
                                                         1, 1
                                                         , 0)
                                                         *(nvl(wro.quantity_issued,0) - nvl(wro.quantity_relieved, 0))
                                                         * p_rep_new_job_qty/p_rep_avail_qty
                                                         + nvl(wro.quantity_relieved, 0)
                                                ), 6)
            WHERE  wro.wip_entity_id = p_rep_we_id
            AND    nvl(abs(wro.quantity_issued),0) >= NVL(abs(wro.quantity_relieved), 0) -- Added to fix bug #2797647
            AND    not exists (select 'obsolete operation'
                               from   wip_operations wo
                               where  wo.wip_entity_id     = wro.wip_entity_id
                               and    wo.organization_id   = wro.organization_id
                               and    wo.operation_seq_num = wro.operation_seq_num
                               and    wo.count_point_type  = 3)
            -- AND   operation_seq_num <= p_rep_op_seq_num;
            AND   operation_seq_num = p_rep_op_seq_num;
            -- ST : Added for bug fix 4619823 (Found in UT)
            -- Should update only for the current operation
    END IF;

    -- Added this back to fix bug #3180781,
    -- since this should really be the opseq of job under consideration
    -- and not that of the rep job.
    --This fixes both issues 3180781 and 2901741


    --Start deletions to fix bug #2901741--
    --The following condition is not required, since in Rep Job, there wont be any ops > l_op_seq_num
    --This was initially inherited from costing
    --    AND    operation_seq_num <= l_op_seq_num;
    --End deletions to fix bug #2901741--

    l_stmt_num := 50;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSMPJUPD.UPDATE_QTY_ISSUED('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;

END UPDATE_QTY_ISSUED;

/*-----------------------------------------------------------------+
| Name : CREATE_WSOR_WLBJ_RECORDS
|        This procedure creates entries in WSOR and WLBJ tables
|            -- If p_only_wo_op_seq is not null, -- irrelevant will never be called with null
|               for this parameter,....
-------------------------------------------------------------------*/

PROCEDURE CREATE_WSOR_WLBJ_RECORDS(p_wip_entity_id         IN  NUMBER,
                                   p_org_id                IN  NUMBER,
                                   p_only_wo_op_seq        IN  NUMBER,
                                   p_last_update_date      IN  DATE,
                                   p_last_updated_by       IN  NUMBER,
                                   p_last_update_login     IN  NUMBER,
                                   p_creation_date         IN  DATE,
                                   p_created_by            IN  NUMBER,
                                   p_request_id            IN  NUMBER,
                                   p_program_app_id        IN  NUMBER,
                                   p_program_id            IN  NUMBER,
                                   p_program_update_date   IN  DATE,
                                   x_err_code              OUT NOCOPY NUMBER,
                                   x_err_buf               OUT NOCOPY VARCHAR2)
IS
    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.CREATE_WSOR_WLBJ_RECORDS';

BEGIN
    l_stmt_num := 10;

    -- Related bugs : 3313454
    INSERT INTO WIP_SUB_OPERATION_RESOURCES
            (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             SUBSTITUTE_GROUP_NUM,
             REPLACEMENT_GROUP_NUM,
             START_DATE,
             COMPLETION_DATE,
             RESOURCE_ID,
             ACTIVITY_ID,
             STANDARD_RATE_FLAG,
             ASSIGNED_UNITS,
             MAXIMUM_ASSIGNED_UNITS, -- ST : Detailed Scheduling --
             USAGE_RATE_OR_AMOUNT,
             UOM_CODE,
             BASIS_TYPE,
             SCHEDULED_FLAG,
             AUTOCHARGE_TYPE,
             SCHEDULE_SEQ_NUM,
             PRINCIPLE_FLAG,
             SETUP_ID,
             DEPARTMENT_ID,
             PHANTOM_FLAG,
             PHANTOM_OP_SEQ_NUM,
             PHANTOM_ITEM_ID,
             applied_resource_units,
             applied_resource_value,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
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
             ATTRIBUTE15
            )
    SELECT  wo.WIP_ENTITY_ID,
            wo.OPERATION_SEQ_NUM,
            rownum +  (SELECT nvl(max(resource_seq_num), 10)
                      FROM   WIP_OPERATION_RESOURCES
                      WHERE  wip_entity_id = p_wip_entity_id
                      AND    OPERATION_SEQ_NUM = wo.OPERATION_SEQ_NUM),
            wo.ORGANIZATION_ID,
            bsor.SUBSTITUTE_GROUP_NUM,
            bsor.REPLACEMENT_GROUP_NUM,
            wo.first_unit_start_date, --START_DATE
            wo.first_unit_completion_date, --COMPLETION_DATE
            bsor.RESOURCE_ID,
            bsor.ACTIVITY_ID,
            bsor.STANDARD_RATE_FLAG,
            bsor.ASSIGNED_UNITS,
            bsor.assigned_units, -- ST : Detailed Scheduling --
            bsor.USAGE_RATE_OR_AMOUNT,
            br.UNIT_OF_MEASURE,
            bsor.BASIS_TYPE,
            bsor.SCHEDULE_FLAG,
            bsor.AUTOCHARGE_TYPE,
            bsor.SCHEDULE_SEQ_NUM,
            bsor.PRINCIPLE_FLAG,
            bsor.SETUP_ID,
            NULL, --DEPARTMENT_ID
            NULL, --PHANTOM_FLAG
            NULL, --PHANTOM_OP_SEQ_NUM
            NULL, --PHANTOM_ITEM_ID
            0,    --applied_resource_units
            0,    --applied_resource_value
            p_last_update_date,
            p_last_updated_by,
            p_last_update_login,
            p_creation_date,
            p_created_by,
            p_request_id,
            p_program_app_id,
            p_program_id,
            p_program_update_date,
            bsor.ATTRIBUTE_CATEGORY,
            bsor.ATTRIBUTE1,
            bsor.ATTRIBUTE2,
            bsor.ATTRIBUTE3,
            bsor.ATTRIBUTE4,
            bsor.ATTRIBUTE5,
            bsor.ATTRIBUTE6,
            bsor.ATTRIBUTE7,
            bsor.ATTRIBUTE8,
            bsor.ATTRIBUTE9,
            bsor.ATTRIBUTE10,
            bsor.ATTRIBUTE11,
            bsor.ATTRIBUTE12,
            bsor.ATTRIBUTE13,
            bsor.ATTRIBUTE14,
            bsor.ATTRIBUTE15
    FROM    BOM_RESOURCES br,
            BOM_OPERATION_RESOURCES bor,
            BOM_SUB_OPERATION_RESOURCES bsor,
            WIP_OPERATIONS wo
    WHERE   wo.WIP_ENTITY_ID = p_wip_entity_id
    AND     wo.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
    AND     nvl(p_only_wo_op_seq, WO.operation_seq_num) = WO.operation_seq_num
    AND     bor.OPERATION_SEQUENCE_ID = bsor.OPERATION_SEQUENCE_ID
    AND     bor.SUBSTITUTE_GROUP_NUM = bsor.SUBSTITUTE_GROUP_NUM
    AND     bsor.RESOURCE_ID = br.RESOURCE_ID
    AND     br.ORGANIZATION_ID = wo.ORGANIZATION_ID;
    --End Bugfix 3313454

    l_stmt_num := 20;

    x_err_code := 0;
    x_err_buf  := null;
EXCEPTION
    WHEN others THEN
        x_err_code := SQLCODE;
        x_err_buf := 'CREATE_WSOR_WLBJ_RECORDS('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;


END CREATE_WSOR_WLBJ_RECORDS;

/* main procedure ................. */

/*-------------------------------------------------------------+
| Name : CHANGE_ROUTING
---------------------------------------------------------------*/

PROCEDURE CHANGE_ROUTING (p_txn_id                      IN NUMBER,
                          p_wip_entity_id               IN NUMBER,
                          p_org_id                      IN NUMBER,
                          p_rj_job_rec                  IN WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                          p_new_op_added                OUT NOCOPY NUMBER,
                          x_err_code                    OUT NOCOPY NUMBER,
                          x_err_buf                     OUT NOCOPY VARCHAR2)
IS
    l_job_op_seq_num        NUMBER;
    l_job_max_op_seq_num    NUMBER;
    l_job_op_seq_id         NUMBER;
    l_job_std_op_id         NUMBER;
    l_job_intra_op      NUMBER;
    l_job_dept_id       NUMBER;
    l_job_qty           NUMBER;
    l_job_op_start_dt   DATE;
    l_job_op_comp_dt    DATE;


    l_charges_exist             NUMBER;
    l_manually_added_comp       NUMBER;
    l_issued_material           NUMBER;
    l_manually_added_resource   NUMBER;
    l_issued_resource           NUMBER;

    l_wsm_param_seq_incr    NUMBER;

    l_op_seq_num        NUMBER;     -- Added for APS-WLT --
    l_fnd_err_msg       VARCHAR2(2000);
    x_msg_count         number;
    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.CHANGE_ROUTING';


BEGIN

    l_stmt_num := 10;

    p_new_op_added := NULL; -- Added for APS-WLT--

    SELECT nvl(op_seq_num_increment, 10)
    INTO   l_wsm_param_seq_incr
    FROM   wsm_parameters
    WHERE  organization_id = p_org_id;

    l_stmt_num := 20;

    if( g_log_level_statement   >= l_log_level ) then
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                               p_msg_text           =>  'Entered procedure CHANGE_ROUTING',
                               p_stmt_num           => l_stmt_num               ,
                                p_msg_tokens        => l_msg_tokens,
                               p_fnd_log_level      => g_log_level_statement,
                               p_run_log_level      => l_log_level
                              );
    End if;

    x_err_code := 0;
    x_err_buf  := null;

    GET_JOB_CURR_OP_INFO(p_wip_entity_id        => p_wip_entity_id,
                         p_op_seq_num           => l_job_op_seq_num,
                         p_op_seq_id            => l_job_op_seq_id,
                         p_std_op_id            => l_job_std_op_id,
                         p_intra_op             => l_job_intra_op,
                         p_dept_id              => l_job_dept_id,
                         p_op_qty               => l_job_qty,
                         p_op_start_date        => l_job_op_start_dt,
                         p_op_completion_date   => l_job_op_comp_dt,
                         x_err_code             => x_err_code,
                         x_err_buf              => x_err_buf,
                         x_msg_count            => x_msg_count
                         );


    IF (x_err_code <> 0) THEN
        IF G_LOG_LEVEL_STATEMENT >= l_log_level THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'GET_JOB_CURR_OP_INFO returned failure',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
         END IF;
         RAISE FND_API.G_EXC_ERROR;

    END IF;

    l_stmt_num := 30;
    l_op_seq_num := p_rj_job_rec.STARTING_OPERATION_SEQ_NUM;

    IF (l_job_intra_op = WIP_CONSTANTS.QUEUE) THEN

        l_stmt_num := 40;
        x_err_code := 0;
        x_err_buf  := null;

        WSMPUTIL.check_charges_exist (p_wip_entity_id                   => p_wip_entity_id,
                                      p_organization_id                 => p_org_id,
                                      p_op_seq_num                      => l_job_op_seq_num,
                                      p_op_seq_id                       => l_job_op_seq_id,
                                      p_charges_exist                   => l_charges_exist,
                                      p_manually_added_comp             => l_manually_added_comp,
                                      p_issued_material                 => l_issued_material,
                                      p_manually_added_resource         => l_manually_added_resource,
                                      p_issued_resource                 => l_issued_resource,
                                      x_error_code                      => x_err_code,
                                      x_error_msg                       => x_err_buf
                                     );



        IF (x_err_code <> 0) THEN
            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => x_err_buf                ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_charges_exist = 1) THEN
            IF ((l_manually_added_resource = 1) OR (l_issued_resource = 1)) THEN
                  fnd_message.set_name('WSM', 'WSM_MANUAL_CHARGES_EXIST');
                  fnd_message.set_token('ELEMENT', 'Resources');
                  l_fnd_err_msg := FND_MESSAGE.GET;

                  IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'ELEMENT';
                        l_msg_tokens(1).TokenValue := 'Resources';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_MANUAL_CHARGES_EXIST',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                  END IF;

            END IF;

            IF ((l_manually_added_comp = 1) OR (l_issued_material = 1)) THEN
                fnd_message.set_name('WSM', 'WSM_MANUAL_CHARGES_EXIST');
                fnd_message.set_token('ELEMENT', 'Materials');
                l_fnd_err_msg := FND_MESSAGE.GET;

                IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'ELEMENT';
                        l_msg_tokens(1).TokenValue := 'Materials';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_MANUAL_CHARGES_EXIST',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

            END IF;

            IF (l_manually_added_comp = 2) THEN
                fnd_message.set_name('WSM','WSM_PHANTOM_COMPONENTS_EXIST');
                l_fnd_err_msg := FND_MESSAGE.GET;

                IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_PHANTOM_COMPONENTS_EXIST',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

            END IF;
        END IF;

        l_stmt_num := 50;

        --=== START: OBSOLETE THE OPERATIONS ===--
        UPDATE  WIP_OPERATIONS
        SET     COUNT_POINT_TYPE        = 3,
                SCHEDULED_QUANTITY      = 0,
                QUANTITY_IN_QUEUE       = 0,
                LAST_UPDATE_DATE        = SYSDATE,
                LAST_UPDATED_BY         = g_user_id,
                LAST_UPDATE_LOGIN       = g_user_login_id,
                REQUEST_ID              = g_request_id,
                PROGRAM_APPLICATION_ID  = g_program_appl_id,
                PROGRAM_ID              = g_program_id,
                PROGRAM_UPDATE_DATE     = SYSDATE,
                DISABLE_DATE            = SYSDATE -- bug 2931071
        WHERE   WIP_ENTITY_ID   = p_wip_entity_id
        AND     ORGANIZATION_ID = p_org_id
        AND     OPERATION_SEQ_NUM >= l_job_op_seq_num;

        l_stmt_num := 55;

        -- Start Additions to fix bug #2682612--
        UPDATE  WIP_REQUIREMENT_OPERATIONS
        SET     required_quantity = 0
        WHERE   WIP_ENTITY_ID   = p_wip_entity_id
        AND     ORGANIZATION_ID = p_org_id
        AND     (OPERATION_SEQ_NUM >= l_job_op_seq_num
                OR
                OPERATION_SEQ_NUM <= 0-l_job_op_seq_num
                );

        l_stmt_num := 60;

        UPDATE  WIP_OPERATION_RESOURCES
        SET     autocharge_type = 2
        WHERE   WIP_ENTITY_ID = p_wip_entity_id
        AND     ORGANIZATION_ID = p_org_id
        AND     OPERATION_SEQ_NUM >= l_job_op_seq_num;

        -- End Additions to fix bug #2682612--

        --=== END: OBSOLETE THE OPERATIONS ===--
        -- Start : Additions for APS-WLT--

    ELSIF (l_job_intra_op = WIP_CONSTANTS.TOMOVE) THEN
        l_stmt_num := 61;

        l_job_op_start_dt := l_job_op_comp_dt; --Bug 3318382

        IF (l_op_seq_num IS NULL) THEN
              -- Starting op may not be provided
              -- for Option A, if the job is at TM
            return;
        ELSE -- If starting operation is provided
            l_stmt_num := 62;

            UPDATE  WIP_OPERATIONS
            SET     QUANTITY_WAITING_TO_MOVE    = 0,
                    LAST_UPDATE_DATE            = SYSDATE,
                    LAST_UPDATED_BY             = g_user_id,
                    LAST_UPDATE_LOGIN           = g_user_login_id,
                    REQUEST_ID                  = g_request_id,
                    PROGRAM_APPLICATION_ID      = g_program_appl_id,
                    PROGRAM_ID                  = g_program_id,
                    PROGRAM_UPDATE_DATE         = SYSDATE
            WHERE   WIP_ENTITY_ID = p_wip_entity_id
            AND     ORGANIZATION_ID = p_org_id
            AND     OPERATION_SEQ_NUM = l_job_op_seq_num;
        END IF;

    END IF;
    -- End : Additions for APS-WLT--
    l_stmt_num := 65;

    --Add target op with new bom/rtg info into WO, WOR, WRO, WOY, fnd_attach as prev_op + incr

    l_stmt_num := 80;

    SELECT max(operation_seq_num)
    INTO   l_job_max_op_seq_num
    FROM   wip_operations
    WHERE  wip_entity_id = p_wip_entity_id;

    p_new_op_added := l_job_max_op_seq_num + l_wsm_param_seq_incr;

    l_stmt_num := 85;

    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSMPLBJI.insert_procedure :' ||p_rj_job_rec.starting_operation_seq_id,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    x_err_code := 0;
    x_err_buf  := null;

    WSMPLBJI.insert_procedure
                            (p_seq_id                     => p_rj_job_rec.starting_operation_seq_id,
                             p_job_seq_num                => p_new_op_added,
                             p_common_routing_sequence_id => p_rj_job_rec.common_routing_sequence_id,
                             p_supply_type                => p_rj_job_rec.wip_supply_type,
                             p_wip_entity_id              => p_wip_entity_id,
                             p_organization_id            => p_org_id,
                             p_quantity                   => p_rj_job_rec.start_quantity,
                             p_job_type                   => p_rj_job_rec.job_type,
                             p_bom_reference_id           => p_rj_job_rec.bom_reference_id,
                             p_rtg_reference_id           => p_rj_job_rec.routing_reference_id,
                             p_assembly_item_id           => p_rj_job_rec.primary_item_id,
                             p_alt_bom_designator         => p_rj_job_rec.alternate_bom_designator,
                             p_alt_rtg_designator         => p_rj_job_rec.alternate_routing_designator,
                             --Bug 3318382 p_fusd                       => l_sch_st_dt,
                             --Bug 3318382 p_lucd                       => l_sch_comp_dt,
                             --Bug 3318382
                             p_fusd                       => l_job_op_start_dt,
                             --Bug 3318382
                             p_lucd                       => l_job_op_comp_dt,

                             p_rtg_revision_date          => p_rj_job_rec.routing_revision_date,
                             p_bom_revision_date          => p_rj_job_rec.bom_revision_date,
                             p_last_updt_date             => sysdate,
                             p_last_updt_by               => g_user_id,
                             p_creation_date              => sysdate,
                             p_created_by                 => g_user_id,
                             p_last_updt_login            => g_user_login_id,
                             p_request_id                 => g_request_id,
                             p_program_application_id     => g_program_appl_id,
                             p_program_id                 => g_program_id,
                             p_prog_updt_date             => sysdate,
                             p_error_code                 => x_err_code,
                             p_error_msg                  => x_err_buf
                            );

    IF (x_err_code <> 0) THEN

        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returned failure from WSMPLBJI.insert_procedure.Error:'|| x_err_buf,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Start : Additions to fix bug 3452913 --
    UPDATE  wip_operations
    SET     wsm_op_seq_num = l_op_seq_num
    WHERE   wip_entity_id = p_wip_entity_id
    AND     operation_seq_num = p_new_op_added;
    -- End : Additions to fix bug 3452913 --

    l_stmt_num := 90;

    --Start : Additions for APS-WLT--
    IF (WSMPJUPD.g_copy_mode = 0) THEN
        null;
    ELSE
         l_stmt_num := 92;
        -- Create WSOR table records --
        x_err_code := 0;
        x_err_buf  := null;

        CREATE_WSOR_WLBJ_RECORDS(   p_wip_entity_id         => p_wip_entity_id,
                                    p_org_id                => p_org_id,
                                    p_only_wo_op_seq        => p_new_op_added, -- Create only this record
                                    p_last_update_date      => sysdate,
                                    p_last_updated_by       => g_user_id,
                                    p_last_update_login     => g_user_login_id,
                                    p_creation_date         => sysdate,
                                    p_created_by            => g_user_id,
                                    p_request_id            => g_request_id,
                                    p_program_app_id        => g_program_appl_id,
                                    p_program_id            => g_program_id,
                                    p_program_update_date   => sysdate,
                                    x_err_code              => x_err_code,
                                    x_err_buf               => x_err_buf
                                );


        IF (x_err_code <> 0) THEN
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Returned failure from CREATE_WSOR_WLBJ_RECORDS',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSE

            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Created WSOR records for new job with id='||p_wip_entity_id,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

        END IF;

    END IF; --WSMPJUPD.g_copy_mode
    --End : Additions for APS-WLT--

    l_stmt_num := 95;

    --Update the previous and next op seq nums
    UPDATE  WIP_OPERATIONS WO
    SET     WO.PREVIOUS_OPERATION_SEQ_NUM = (SELECT MAX(OPERATION_SEQ_NUM)
                                             FROM WIP_OPERATIONS
                                             WHERE WIP_ENTITY_ID = p_wip_entity_id
                                             AND OPERATION_SEQ_NUM < WO.OPERATION_SEQ_NUM),
            WO.NEXT_OPERATION_SEQ_NUM =     (SELECT MIN(OPERATION_SEQ_NUM)
                                             FROM WIP_OPERATIONS
                                             WHERE WIP_ENTITY_ID = p_wip_entity_id
                                             AND OPERATION_SEQ_NUM > WO.OPERATION_SEQ_NUM)
    WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id;

    l_stmt_num := 100;

    --Set qty in Queue of the target operation
    UPDATE WIP_OPERATIONS
    SET    quantity_in_queue = l_job_qty
    WHERE  wip_entity_id = p_wip_entity_id
    AND    operation_seq_num = p_new_op_added;


    l_stmt_num := 110;
    x_err_code := 0;
    x_err_buf := NULL;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CHANGE_ROUTING('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
                FND_MSG_PUB.Count_And_Get ( p_encoded     => 'F',
                                            p_count       => x_msg_count ,
                                            p_data        => x_err_buf
                                          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CHANGE_ROUTING('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
                FND_MSG_PUB.Count_And_Get ( p_encoded     => 'F',
                                            p_count       => x_msg_count ,
                                            p_data        => x_err_buf
                                          );
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.CHANGE_ROUTING('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;
END CHANGE_ROUTING;
-- end ..............


/*-----------------------------------------------------------------+
| Name : UPDATE_ASSEMBLY_OR_ROUTING
-------------------------------------------------------------------*/


--SpUA begin:  Moved Update Assembly/Routing code from Process_Wip_Lot_Txns here.
--             To be used by Split and Update Assy, Update Assy, Update Routing txns.

PROCEDURE UPDATE_ASSEMBLY_OR_ROUTING(p_txn_id                   IN NUMBER,
                                     p_txn_type_id              IN NUMBER,
                                     p_job_kanban_card_id       IN NUMBER,     --abbKanban
                                     p_po_creation_time         IN NUMBER,     --osp
                                     p_request_id               IN NUMBER,     --osp
                                     p_sj_compl_subinventory    IN VARCHAR2,
                                     p_sj_compl_locator_id      IN NUMBER,
                                     p_rj_job_rec               IN OUT NOCOPY WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                     x_err_code                 OUT NOCOPY NUMBER,
                                     x_err_buf                  OUT NOCOPY VARCHAR2,
                                     x_msg_count                OUT NOCOPY NUMBER)

IS

    l_txn_type_id           NUMBER;
    l_org_id                NUMBER;
    l_wip_entity_id         NUMBER;
    l_new_op_added          NUMBER;
    l_po_creation_time      NUMBER;         --osp
    l_request_id            NUMBER;         --osp
    l_job_kanban_card_id    NUMBER;         --abbKanban
    l_kanban_card_id        NUMBER;         --abbKanban
    l_sub_loc_change        NUMBER;         --abbKanban
    l_return_status         VARCHAR2(1);    --abbKanban
    translated_meaning      VARCHAR2(240);  --abbkanban
    l_rtg_op_seq_num        NUMBER;

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.UPDATE_ASSEMBLY_OR_ROUTING';

BEGIN

    l_txn_type_id            := p_txn_type_id;
    l_org_id                 := p_rj_job_rec.organization_id;
    l_wip_entity_id      := p_rj_job_rec.wip_entity_id;
    l_job_kanban_card_id := p_job_kanban_card_id;
    l_po_creation_time       := p_po_creation_time;
    l_request_id             := p_request_id;

    -- SpUA :    l_wip_entity_id is resulting job wip_id for Split and Update Assy
    --           and for other transactions, it is starting job wip_id -- this is obvious.. comeon...
    --

    IF l_txn_type_id = WSMPCNST.UPDATE_ROUTING THEN
        l_stmt_num := 190;

        if l_job_kanban_card_id is not null then

                l_sub_loc_change := handle_kanban_sub_loc_change(  p_wip_entity_id                      => p_rj_job_rec.wip_entity_id,
                                                                   p_kanban_card_id                     => l_job_kanban_card_id,
                                                                   p_wssj_completion_subinventory       => p_sj_compl_subinventory,
                                                                   p_wssj_completion_locator_id         => p_sj_compl_locator_id,
                                                                   p_wsrj_completion_subinventory       => p_rj_job_rec.completion_subinventory,
                                                                   p_wsrj_completion_locator_id         => p_rj_job_rec.completion_locator_id,
                                                                   x_err_code                           => x_err_code,
                                                                   x_err_msg                            => x_err_buf
                                                                );

                IF (x_err_code <> 0) THEN
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Handle_kanban_sub_loc_change returned error: ' || x_err_buf,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                END IF;

                -- indicates that the compl. subinv has changed hence remove the link to the kanban card id...
                if l_sub_loc_change <> 0 then
                        l_job_kanban_card_id := null;
                end if;
        end if;

        UPDATE  wip_discrete_jobs wdj
        SET     routing_reference_id            = p_rj_job_rec.routing_reference_id,
                alternate_routing_designator    = p_rj_job_rec.alternate_routing_designator,
                common_routing_sequence_id      = p_rj_job_rec.common_routing_sequence_id,
                routing_revision                = p_rj_job_rec.routing_revision,
                routing_revision_date           = p_rj_job_rec.routing_revision_date,
                completion_subinventory         = p_rj_job_rec.completion_subinventory,
                completion_locator_id           = p_rj_job_rec.completion_locator_id,
                kanban_card_id                  = l_job_kanban_card_id,
                -- ST : Fix for bug 5254137 : Update the BOM Info as well for Update Rtg as Bom data can be changed during upd rtg..
               --Bug 5491020:bom_reference_id is updated by  p_rj_job_rec.bom_reference_id
                bom_reference_id                = p_rj_job_rec.bom_reference_id, --routing_reference_id,
                alternate_bom_designator        = p_rj_job_rec.alternate_bom_designator,
                common_bom_sequence_id          = p_rj_job_rec.common_bom_sequence_id,
                bom_revision                    = p_rj_job_rec.bom_revision,
                bom_revision_date               = p_rj_job_rec.bom_revision_date,
                -- ST : Fix for bug 5254137 end --
                last_update_date                = sysdate,
                last_updated_by                 = g_user_id
        WHERE   wdj.wip_entity_id = l_wip_entity_id;

    --SpUA: add Split
    ELSIF l_txn_type_id IN (WSMPCNST.UPDATE_ASSEMBLY, WSMPCNST.SPLIT) THEN

        l_stmt_num := 200;

        -- abbKanban begin
        l_stmt_num := 203;


        if l_job_kanban_card_id is not null then

            l_return_status := null;

            INV_Kanban_PVT.Update_Card_Supply_Status(X_Return_Status    => l_return_status,
                                                     p_Kanban_Card_Id   => l_job_kanban_card_id,
                                                     p_Supply_Status    => INV_Kanban_PVT.G_Supply_Status_Exception
                                                     );

            if ( l_return_status <> fnd_api.g_ret_sts_success ) then
                x_err_code := -1;
                fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');

                fnd_message.set_token('STATUS',g_translated_meaning);
                x_err_buf := fnd_message.get;

                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'STATUS';
                                        l_msg_tokens(1).TokenValue := g_translated_meaning;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
               END IF;
               RAISE FND_API.G_EXC_ERROR;

           end if;

            l_job_kanban_card_id := null;

            l_stmt_num := 207;

        end if; -- kanban_card_id not null


        UPDATE  wip_discrete_jobs wdj
        SET      primary_item_id                = p_rj_job_rec.primary_item_id,
                 kanban_card_id                 = l_job_kanban_card_id,
                 routing_reference_id           = p_rj_job_rec.routing_reference_id,
                 alternate_routing_designator   = p_rj_job_rec.alternate_routing_designator,
                 common_routing_sequence_id     = p_rj_job_rec.common_routing_sequence_id,
                 routing_revision               = p_rj_job_rec.routing_revision,
                 routing_revision_date          = p_rj_job_rec.routing_revision_date,
                 completion_subinventory        = p_rj_job_rec.completion_subinventory,
                 completion_locator_id          = p_rj_job_rec.completion_locator_id,
               --Bug 5491020:bom_reference_id is updated by  p_rj_job_rec.bom_reference_id
                 bom_reference_id               = p_rj_job_rec.bom_reference_id, --routing_reference_id,
                 alternate_bom_designator       = p_rj_job_rec.alternate_bom_designator,
                 common_bom_sequence_id         = p_rj_job_rec.common_bom_sequence_id,
                 bom_revision                   = p_rj_job_rec.bom_revision,
                 bom_revision_date              = p_rj_job_rec.bom_revision_date,
                 last_update_date               = sysdate,
                 last_updated_by                = g_user_id
        WHERE   wdj.wip_entity_id = l_wip_entity_id;

        -- ST : Fix for bug 5122653 --
        -- Update the details in WIP_ENTITIES as well...
        UPDATE wip_entities
        SET primary_item_id = p_rj_job_rec.primary_item_id
        WHERE wip_entity_id = l_wip_entity_id;
        -- ST : Fix for bug 5122653 end --

    END IF;

    l_stmt_num := 210;
    CHANGE_ROUTING (p_txn_id                    => p_txn_id,
                    p_wip_entity_id             => l_wip_entity_id,
                    p_org_id                    => l_org_id,
                    p_rj_job_rec                => p_rj_job_rec,
                    p_new_op_added              => l_new_op_added,
                    x_err_code                  => x_err_code,
                    x_err_buf                   => x_err_buf
                    );

    IF (x_err_code <> 0) THEN
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'CHANGE_ROUTING returned error:'||x_err_buf,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSE

        IF (l_new_op_added IS NOT NULL) THEN    -- Added condition check for APS-WLT --
                 if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Added new operation sequence '||l_new_op_added||' to the job',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                 End if;
        END IF;
   END IF;

   l_stmt_num := 220;
   p_rj_job_rec.job_operation_seq_num := l_new_op_added;

   BEGIN
        -- Obtain the op seq num...
        SELECT operation_seq_num
        into   l_rtg_op_seq_num
        from   bom_operation_sequences
        where  operation_sequence_id = p_rj_job_rec.starting_operation_seq_id;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_rtg_op_seq_num := null;
   END;

   -- Update the WSM_LOT_BASED_JOBS table...
   update wsm_lot_based_jobs
   set    current_rtg_op_seq_num = l_rtg_op_seq_num,
          current_job_op_seq_num = l_new_op_added
   where wip_entity_id = l_wip_entity_id;

   --osp
   IF (WSMPUTIL.check_osp_operation(p_wip_entity_id      => l_wip_entity_id,
                                    p_operation_seq_num  => l_new_op_added,
                                    p_organization_id    => l_org_id))
   THEN

        WSMPJUPD.g_osp_exists := 1;

        if (l_po_creation_time <>  WIP_CONSTANTS.MANUAL_CREATION) then
            --if l_request_id is null means online processing so launch import req
            -- (i.e) not from the Interface
            --Bug 5263262: During online processing l_request_id will be
            ---1.Hence check on -1 is also included in the if condition below.
            if (l_request_id is null or l_request_id = -1) then
                l_stmt_num := 223;
                wip_osp.create_requisition( P_Wip_Entity_Id             =>  l_wip_entity_id,
                                            P_Organization_Id           => l_org_id,
                                            P_Repetitive_Schedule_Id    => null,
                                            P_Operation_Seq_Num         => l_new_op_added,
                                            P_Resource_Seq_Num          => null,
                                            P_Run_ReqImport             => WIP_CONSTANTS.YES);
            else
                l_stmt_num := 227;
                wip_osp.create_requisition( P_Wip_Entity_Id             =>  l_wip_entity_id,
                                            P_Organization_Id           => l_org_id,
                                            P_Repetitive_Schedule_Id    => null,
                                            P_Operation_Seq_Num         => l_new_op_added,
                                            P_Resource_Seq_Num          => null,
                                            P_Run_ReqImport             => WIP_CONSTANTS.NO);
            end if;
        end if;

    END IF;
    --WSMPUTIL.check_osp_operation
    --osp end

    x_err_code := 0;
    x_err_buf := null;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_err_code      := -1;
                x_err_buf       := ' WSMPJUPD.UPDATE_ASSEMBLY_OR_ROUTING('||l_stmt_num||'): '||x_err_buf;
                FND_MSG_PUB.Count_And_Get (p_encoded              =>      'F',
                                           p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_err_code      := -1;
                x_err_buf       := ' WSMPJUPD.UPDATE_ASSEMBLY_OR_ROUTING('||l_stmt_num||'): '||x_err_buf;
                FND_MSG_PUB.Count_And_Get ( p_encoded             =>      'F',
                                            p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );
        WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.UPDATE_ASSEMBLY_OR_ROUTING('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                               p_stmt_num               => l_stmt_num               ,
                                               p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                               p_run_log_level          => l_log_level
                                             );
                END IF;

END UPDATE_ASSEMBLY_OR_ROUTING;
/*EA SpUA*/


Procedure Insert_MMT_record ( p_txn_id                          IN NUMBER,
                              p_txn_org_id                      IN NUMBER,
                              p_txn_date                        IN DATE,
                              p_txn_type_id                     IN NUMBER,
                              p_sj_wip_entity_id                IN NUMBER,
                              p_sj_wip_entity_name              IN VARCHAR2,
                              p_sj_avail_quantity               IN NUMBER,
                              p_rj_wip_entity_id                IN NUMBER,
                              p_rj_wip_entity_name              IN VARCHAR2,
                              p_rj_start_quantity               IN NUMBER,
                              p_sj_item_id                      IN number,
                              p_sj_op_seq_num                   IN number,
                              x_return_status                   OUT NOCOPY VARCHAR2,
                              x_msg_count                       OUT NOCOPY NUMBER,
                              x_msg_data                        OUT NOCOPY VARCHAR2
                             ) is

    l_wms_org           mtl_parameters.wms_enabled_flag%type;
    l_def_cost_grp_id   mtl_parameters.default_cost_group_id%type;

    l_acct_period_id    number;

    l_err_code          number;
    l_err_buf           varchar2(2000);

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMJUPDB.Insert_MMT_record';


begin
        l_stmt_num := 10;
        --Start additions to fix bug #2828376--
        SELECT wms_enabled_flag,
               default_cost_group_id
        INTO   l_wms_org,
               l_def_cost_grp_id
        FROM   mtl_parameters
        WHERE  organization_id = p_txn_org_id;
        --End additions to fix bug #2828376--

        l_stmt_num := 20;
        l_err_code := 0;
        l_err_buf  := null;

        l_acct_period_id := WSMPUTIL.GET_INV_ACCT_PERIOD(l_err_code,
                                                         l_err_buf,
                                                         p_txn_org_id,
                                                         p_txn_date);
        --End NL BugFix 3126650

        IF (l_err_code <> 0) THEN
                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSMPUTIL.GET_INV_ACCT_PERIOD returned error:' || l_err_buf,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 30;

        INSERT INTO mtl_material_transactions
                (TRANSACTION_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 ORGANIZATION_ID,
                 TRANSACTION_TYPE_ID,
                 INVENTORY_ITEM_ID,
                 TRANSACTION_ACTION_ID,
                 TRANSACTION_SOURCE_TYPE_ID,
                 TRANSACTION_SOURCE_ID,
                 TRANSACTION_SOURCE_NAME,
                 TRANSACTION_QUANTITY,
                 PRIMARY_QUANTITY,
                 TRANSACTION_UOM,
                 TRANSACTION_DATE,
                 SOURCE_LINE_ID,
                 OPERATION_SEQ_NUM,
                 ACCT_PERIOD_ID,
                 COSTED_FLAG,
                 COST_GROUP_ID  --VJ: Added to fix bug #2828376
            )
        SELECT  mtl_material_transactions_s.nextval,
                sysdate,
                g_USER_ID,
                g_user_LOGIN_ID,
                sysdate,
                g_USER_ID,
                g_REQUEST_ID,
                g_program_appl_id,
                g_PROGRAM_ID,
                sysdate,
                p_txn_org_id,
                MTT.transaction_type_id,
                -- Start : Changes as required by CST for SpUA --
                p_sj_item_id,
                -- End : Changes as required by CST for SpUA --
                decode(p_txn_type_id, WSMPCNST.SPLIT, 40,
                                      WSMPCNST.MERGE, 41,
                                      WSMPCNST.BONUS, 42,
                                      WSMPCNST.UPDATE_QUANTITY, 43,
                                      0),
                MTT.transaction_source_type_id,
                decode(p_txn_type_id, WSMPCNST.SPLIT, p_sj_wip_entity_id, p_rj_wip_entity_id),
                decode(p_txn_type_id, WSMPCNST.SPLIT, p_sj_wip_entity_name, p_rj_wip_entity_name),
                decode(p_txn_type_id, WSMPCNST.SPLIT, p_sj_avail_quantity, p_rj_start_quantity),
                decode(p_txn_type_id, WSMPCNST.SPLIT, p_sj_avail_quantity, p_rj_start_quantity),
                MSI.primary_uom_code,
                p_txn_date,
                p_txn_id,
                p_sj_op_seq_num,
                OAP.acct_period_id,
                'N',
                decode(l_wms_org, 'Y', l_def_cost_grp_id, NULL)     --VJ: Added to fix bug #2828376
        FROM    mtl_system_items               MSI,
                org_acct_periods               OAP,
                mtl_transaction_types          MTT
        -- Start : Changes as required by CST for SpUA --
        WHERE   p_sj_item_id = MSI.inventory_item_id
        AND     p_txn_org_id         = MSI.organization_id
        -- End : Changes as required by CST for SpUA --
        AND     p_txn_org_id = OAP.organization_id
        AND     trunc(p_txn_date) between period_start_date and schedule_close_date
                    -- Fixed bug #2828278
                    -- Added trunc above: sch_close_date doesnt have timestamp so a problem for end of month
        AND     MTT.transaction_action_id IN(decode(p_txn_type_id, WSMPCNST.SPLIT, 40,
                                                                   WSMPCNST.MERGE, 41,
                                                                   WSMPCNST.BONUS, 42,
                                                                   WSMPCNST.UPDATE_QUANTITY, 43,
                                                                   0)
                                             )
        AND     MTT.transaction_source_type_id = 5;

        --Start additions to fix bug #3048394--
        IF (SQL%ROWCOUNT <> 1) THEN

            IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'ELEMENT';
                                        l_msg_tokens(1).TokenValue := 'mtl_material_transactions';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INS_TBL_FAILED',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
             END IF;

        end if;

        /* set the return status to succes... */
        x_return_status := fnd_api.g_ret_sts_success;

exception
        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get ( p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_msg_data
                                          );
        when others then
                /* handle it... */
                x_return_status := fnd_api.g_ret_sts_error;
                                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => SUBSTRB('Unexpected Error : SQLCODE '|| SQLCODE  ||' : SQLERRM : '|| SQLERRM, 1, 2000),
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED   ,
                                                p_run_log_level     => l_log_level
                                                );

                END IF;

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                               p_stmt_num               => l_stmt_num               ,
                                               p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                               p_run_log_level          => l_log_level
                                             );
                END IF;

end;

/* have to work on this procedure.... */

/*------------------------------------------------------------------+
| Name : CREATE_COPIES_OR_SET_COPY_DATA                             |
|        This procedure is called from the form and interface       |
|        NOT a private procedure                                    |
-------------------------------------------------------------------*/

PROCEDURE CREATE_COPIES_OR_SET_COPY_DATA (p_txn_id                      IN  NUMBER,
                                          p_txn_type_id                 IN  NUMBER,
                                          p_copy_mode                   IN  NUMBER,
                                          p_rep_sj_index                IN  NUMBER,
                                          p_sj_as_rj_index              IN  NUMBER,
                                          p_wltx_starting_jobs_tbl      IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                          p_wltx_resulting_jobs_tbl     IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                          x_err_code                    OUT NOCOPY NUMBER,
                                          x_err_buf                     OUT NOCOPY VARCHAR2,
                                          x_msg_count                   OUT NOCOPY NUMBER)
IS
    l_res_rtg_item_id           NUMBER; -- Fix for bug #3347947
    l_res_bill_item_id          NUMBER; -- Fix for bug #3347947

    l_res_bill_seq_id           NUMBER; -- Fix for bug #3286849

    l_new_job_int_copy_type     NUMBER;
    l_rep_job_par_we_id         NUMBER;

    l_rj_counter        NUMBER;
    l_sj_counter        NUMBER;
    l_rep_wip_entity_id NUMBER;

    -- Logging variables.....
    l_msg_tokens    WSM_Log_PVT.token_rec_tbl;
    l_log_level     number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num      NUMBER;
    l_module        VARCHAR2(100) := 'wsm.plsql.WSMPJUPDB.CREATE_COPIES_OR_SET_COPY_DATA';
    -- Logging variables...
    l_phantom_exists NUMBER;
BEGIN

    l_stmt_num := 10;

    -- IF (g_debug = 'Y') THEN
    --     fnd_file.put_line(fnd_file.log, 'In CREATE_COPIES_OR_SET_COPY_DATA '||
    --                 'for p_txn_id='||p_txn_id||
    --                 ' p_txn_type_id='||p_txn_type_id||
    --                 ' p_copy_mode='||p_copy_mode);
    -- END IF;


    IF (p_txn_type_id IN (WSMPCNST.BONUS,
                           WSMPCNST.UPDATE_ASSEMBLY, WSMPCNST.UPDATE_ROUTING)) THEN

        l_stmt_num := 11;

        IF (p_copy_mode = 1) THEN -- Make copies after each transaction

            l_stmt_num := 20;

            l_rj_counter   :=  p_wltx_resulting_jobs_tbl.first;

            if p_wltx_resulting_jobs_tbl(l_rj_counter).job_type = WIP_CONSTANTS.STANDARD then
                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(l_rj_counter).primary_item_id;
                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(l_rj_counter).primary_item_id;
            else
                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(l_rj_counter).routing_reference_id;
                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(l_rj_counter).bom_reference_id;
            end if;


            l_res_bill_seq_id := WSMPUTIL.GET_JOB_BOM_SEQ_ID(p_wltx_resulting_jobs_tbl(l_rj_counter).wip_entity_id);
             --OPTII-PERF:Find if phantom exists or not.
             BEGIN
                    select 1 into l_phantom_exists
                    from  bom_inventory_components
                    where bill_sequence_id = p_wltx_resulting_jobs_tbl(l_rj_counter).common_bom_sequence_id
                    and  p_wltx_resulting_jobs_tbl(l_rj_counter).bom_revision_date between effectivity_date and
                               nvl(disable_date,p_wltx_resulting_jobs_tbl(l_rj_counter).bom_revision_date+1)
                    and   wip_supply_type = 6
                    and   rownum = 1;

                    l_phantom_exists := 1;
             EXCEPTION
                    WHEN OTHERS THEN
                        l_phantom_exists := 2;
             END;

            -- related bugs : 3348704, 3347947 , 3286849 , 3303267
            WSM_JobCopies_PVT.Create_JobCopies  -- Call #1
                   (x_err_buf              => x_err_buf,
                    x_err_code             => x_err_code,
                    p_wip_entity_id        => p_wltx_resulting_jobs_tbl(l_rj_counter).wip_entity_id,
                    p_org_id               => p_wltx_resulting_jobs_tbl(l_rj_counter).organization_id,
                    p_primary_item_id      => p_wltx_resulting_jobs_tbl(l_rj_counter).primary_item_id,
                    p_routing_item_id      => l_res_rtg_item_id,-- Fix for bug #3347947
                    p_alt_rtg_desig        => p_wltx_resulting_jobs_tbl(l_rj_counter).alternate_routing_designator,-- Fix for bug #3347947
                    p_rtg_seq_id           => NULL, -- Will be NULL till reqd for some functionality
                    p_common_rtg_seq_id    => p_wltx_resulting_jobs_tbl(l_rj_counter).common_routing_sequence_id,
                    p_rtg_rev_date         => p_wltx_resulting_jobs_tbl(l_rj_counter).routing_revision_date,
                    p_bill_item_id         => l_res_bill_item_id, -- Fix for bug #3347947
                    p_alt_bom_desig        => p_wltx_resulting_jobs_tbl(l_rj_counter).alternate_bom_designator,
                    p_bill_seq_id          => l_res_bill_seq_id, -- Fix for bug #3286849
                    p_common_bill_seq_id   => p_wltx_resulting_jobs_tbl(l_rj_counter).common_bom_sequence_id,
                    p_bom_rev_date         => p_wltx_resulting_jobs_tbl(l_rj_counter).bom_revision_date,
                    p_wip_supply_type      => p_wltx_resulting_jobs_tbl(l_rj_counter).wip_supply_type,
                    p_last_update_date     => sysdate,
                    p_last_updated_by      => g_USER_ID,
                    p_last_update_login    => g_user_LOGIN_ID,
                    p_creation_date        => sysdate,
                    p_created_by           => g_USER_ID,
                    p_request_id           => g_REQUEST_ID,
                    p_program_app_id       => g_program_appl_id,
                    p_program_id           => g_PROGRAM_ID,
                    p_program_update_date  => sysdate,
                    p_inf_sch_flag         => 'Y',
                    p_inf_sch_mode         => NULL, -- Create_JobCopies to figure out
                    p_inf_sch_date         => NULL,  --Bug #3348704    l_inf_sch_date
                     --OPTII-PERF:Following parameters are added
                    p_charges_exist        => 1,
                    p_phantom_exists       => l_phantom_exists
                   );


            -- Fixed bug #3303267 : Checked the return value based on changed error codes
            -- IF (x_err_code <> 0) THEN
            IF (x_err_code = 0) OR
               (x_err_code IS NULL) OR -- No error
               (x_err_code = -1)    -- Warning
            THEN
                x_err_code := 0;    -- Fix for bug #3421662 --
            ELSE
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned error:' || x_err_buf,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned success',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

       ELSIF (p_copy_mode = 2) THEN -- Make copies at end (for interface ONLY)
            l_stmt_num := 30;

            l_rj_counter   :=  p_wltx_resulting_jobs_tbl.first;

            UPDATE  wsm_lot_based_jobs
            SET     internal_copy_type = 2
            WHERE   wip_entity_id = p_wltx_resulting_jobs_tbl(l_rj_counter).wip_entity_id;

           if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Set internal_copy_type = 2 for we_id=',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
            End if;

        END IF; --(p_copy_mode)

    ELSIF (p_txn_type_id IN (WSMPCNST.SPLIT, WSMPCNST.MERGE)) THEN

        l_stmt_num := 40;

        l_rep_wip_entity_id := p_wltx_starting_jobs_tbl(p_rep_sj_index).wip_entity_id;

        -- for interface copy purpose....
        SELECT  nvl(internal_copy_type, 0),
                copy_parent_wip_entity_id
        INTO    l_new_job_int_copy_type,
                l_rep_job_par_we_id
        FROM    wsm_lot_based_jobs
        WHERE   wip_entity_id = l_rep_wip_entity_id;
        -- for interface copy purpose.... end

        IF (l_new_job_int_copy_type < 1) THEN
                l_new_job_int_copy_type := 1;
        END IF;

        l_stmt_num := 50;

        for l_job_counter in p_wltx_resulting_jobs_tbl.first..p_wltx_resulting_jobs_tbl.last loop

            l_stmt_num := 55;

            if p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id <> l_rep_wip_entity_id then

                    l_stmt_num := 58;

                    -- ST : Bug fix 5092009
                    -- Adding NVL as for Merge it can be NULL
                    IF (nvl(p_wltx_resulting_jobs_tbl(l_job_counter).split_has_update_assy,0) = 0) THEN -- No assembly change

                        l_stmt_num := 59;

                        IF (p_copy_mode = 1) THEN -- Make copies after each transaction
                            l_stmt_num := 60;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'new we_id :'||p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id||
                                                                                        'rep_job_we_id :'||l_rep_wip_entity_id,
                                                               p_stmt_num           => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                            WSM_JobCopies_PVT.Create_RepJobCopies
                                      (x_err_buf              => x_err_buf,
                                       x_err_code             => x_err_code,
                                       p_rep_wip_entity_id    => l_rep_wip_entity_id,
                                       p_new_wip_entity_id    => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id,
                                       p_last_update_date     => sysdate,
                                       p_last_updated_by      => g_USER_ID,
                                       p_last_update_login    => g_user_LOGIN_ID,
                                       p_creation_date        => sysdate,
                                       p_created_by           => g_USER_ID,
                                       p_request_id           => g_REQUEST_ID,
                                       p_program_app_id       => g_program_appl_id,
                                       p_program_id           => g_PROGRAM_ID,
                                       p_program_update_date  => sysdate,
                                       p_inf_sch_flag         => 'Y',
                                       p_inf_sch_mode         => NULL,
                                       p_inf_sch_date         => NULL
                                      );

                            IF (x_err_code <> 0) THEN
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_RepJobCopies returned error:' || x_err_buf,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            l_stmt_num := 70;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_RepJobCopies returned success',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                        ELSIF (p_copy_mode = 2) THEN -- Make copies at end (for interface ONLY)

                            l_stmt_num := 80;

                            UPDATE  wsm_lot_based_jobs
                            SET     internal_copy_type = l_new_job_int_copy_type
                            WHERE   wip_entity_id = p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Set internal_copy_type = '||l_new_job_int_copy_type||' for we_id=',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                            IF (l_new_job_int_copy_type = 1) THEN -- If current job's copy_type = 1

                                l_stmt_num := 100;

                                UPDATE  wsm_lot_based_jobs
                                SET     copy_parent_wip_entity_id =  nvl(l_rep_job_par_we_id, l_rep_wip_entity_id)
                                WHERE   wip_entity_id = p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Set copy_parent_wip_entity_id = '||nvl(l_rep_job_par_we_id, l_rep_wip_entity_id)||' for we_id=',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                            END IF;

                        END IF; --(p_copy_mode)

                    ELSIF (p_wltx_resulting_jobs_tbl(l_job_counter).split_has_update_assy = 1) THEN -- Assembly has changed

                        l_stmt_num := 108;

                        IF (p_copy_mode = 1) THEN -- Make copies after each transaction
                            l_stmt_num := 110;

                            if p_wltx_resulting_jobs_tbl(l_job_counter).job_type = WIP_CONSTANTS.STANDARD then
                                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id;
                                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id;
                            else
                                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(l_job_counter).routing_reference_id;
                                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(l_job_counter).bom_reference_id;
                            end if;

                            l_res_bill_seq_id := WSMPUTIL.GET_JOB_BOM_SEQ_ID(p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id);
                            --OPTII-PERF
                            BEGIN
                                      select 1 into l_phantom_exists
                                      from  bom_inventory_components
                                      where bill_sequence_id = p_wltx_resulting_jobs_tbl(l_job_counter).common_bom_sequence_id
                                      and  p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision_date between effectivity_date and
                                                 nvl(disable_date,p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision_date+1)
                                      and   wip_supply_type = 6
                                      and   rownum = 1;

                                      l_phantom_exists := 1;
                            EXCEPTION
                                      WHEN OTHERS THEN
                                           l_phantom_exists := 2;
                            END;

                            WSM_JobCopies_PVT.Create_JobCopies  -- Call #2
                                    (x_err_buf              => x_err_buf,
                                     x_err_code             => x_err_code,
                                     p_wip_entity_id        => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id,
                                     p_org_id               => p_wltx_resulting_jobs_tbl(l_job_counter).organization_id,
                                     p_primary_item_id      => p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id,

                                     p_routing_item_id      => l_res_rtg_item_id,-- Fix for bug #3347947
                                     p_alt_rtg_desig        => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_routing_designator,-- Fix for bug #3347947
                                     p_rtg_seq_id           => NULL, -- Will be NULL till reqd for some functionality
                                     p_common_rtg_seq_id    => p_wltx_resulting_jobs_tbl(l_job_counter).common_routing_sequence_id,
                                     p_rtg_rev_date         => p_wltx_resulting_jobs_tbl(l_job_counter).routing_revision_date,
                                     p_bill_item_id         => l_res_bill_item_id, -- Fix for bug #3347947
                                     p_alt_bom_desig        => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_bom_designator,
                                     p_bill_seq_id          => l_res_bill_seq_id,-- Fix for bug #3286849
                                     p_common_bill_seq_id   => p_wltx_resulting_jobs_tbl(l_job_counter).common_bom_sequence_id,
                                     p_bom_rev_date         => p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision_date,
                                     p_wip_supply_type      => p_wltx_resulting_jobs_tbl(l_job_counter).wip_supply_type,
                                     p_last_update_date     => sysdate,
                                     p_last_updated_by      => g_USER_ID,
                                     p_last_update_login    => g_user_LOGIN_ID,
                                     p_creation_date        => sysdate,
                                     p_created_by           => g_USER_ID,
                                     p_request_id           => g_REQUEST_ID,
                                     p_program_app_id       => g_program_appl_id,
                                     p_program_id           => g_PROGRAM_ID,
                                     p_program_update_date  => sysdate,
                                     p_inf_sch_flag         => 'Y',
                                     p_inf_sch_mode         => NULL, -- Create_JobCopies to figure out
                                     p_inf_sch_date         => NULL, --Bug #3348704    c_sm_new_jobs_rec.inf_sch_date
                                     --OPTII-PERF:Following parameters are added
                                     p_charges_exist        => 1,
                                     p_phantom_exists       => l_phantom_exists
                                    );

                            -- Fixed bug #3303267 : Checked the return value based on changed error codes
                            -- IF (x_err_code <> 0) THEN
                            IF (x_err_code = 0) OR
                               (x_err_code IS NULL) OR -- No error
                               (x_err_code = -1)    -- Warning
                            THEN
                                x_err_code := 0;    -- Fix for bug #3421662 --
                            ELSE
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned error:' || x_err_buf,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned success',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                        ELSIF (p_copy_mode = 2) THEN -- Make copies at end (for interface ONLY)

                            l_stmt_num := 120;

                            UPDATE  wsm_lot_based_jobs
                            SET     internal_copy_type = 2
                            WHERE   wip_entity_id = p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Set internal_copy_type = 2 for we_id=',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                        END IF; --(p_copy_mode)

                    END IF;
            end if; -- check if not a starting job...

        END LOOP;

        IF (p_txn_type_id = WSMPCNST.SPLIT) THEN

            l_stmt_num := 130;

            if p_sj_as_rj_index is not null then
                l_stmt_num := 135;

                IF (p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).split_has_update_assy = 1) THEN

                        l_stmt_num := 138;

                        IF (p_copy_mode = 1) THEN -- Make copies after each transaction
                            l_stmt_num := 140;

                            if p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).job_type = WIP_CONSTANTS.STANDARD then
                                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).primary_item_id;
                                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).primary_item_id;
                            else
                                l_res_rtg_item_id := p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).routing_reference_id;
                                l_res_bill_item_id := p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).bom_reference_id;
                            end if;

                            l_res_bill_seq_id := WSMPUTIL.GET_JOB_BOM_SEQ_ID(p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).wip_entity_id);
                             --OPTII-PERF:Find l_phantom_exists
                            BEGIN
                                      select 1 into l_phantom_exists
                                      from  bom_inventory_components
                                      where bill_sequence_id = p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).common_bom_sequence_id
                                      and  p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).bom_revision_date between effectivity_date and
                                                 nvl(disable_date,p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).bom_revision_date+1)
                                      and   wip_supply_type = 6
                                      and   rownum = 1;

                                      l_phantom_exists := 1;
                            EXCEPTION
                                      WHEN OTHERS THEN
                                           l_phantom_exists := 2;
                            end;
                            WSM_JobCopies_PVT.Create_JobCopies  -- Call #3
                                    (x_err_buf              => x_err_buf,
                                     x_err_code             => x_err_code,
                                     p_wip_entity_id        => l_rep_wip_entity_id,
                                     p_org_id               => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).organization_id,
                                     p_primary_item_id      => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).primary_item_id,
                                     p_routing_item_id      => l_res_rtg_item_id, -- Fix bug #3347947
                                     p_alt_rtg_desig        => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).alternate_routing_designator, -- Fix bug #3347947
                                     p_rtg_seq_id           => NULL,-- Will be NULL till reqd for some functionality
                                     p_common_rtg_seq_id    => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).common_routing_sequence_id,
                                     p_rtg_rev_date         => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).routing_revision_date,
                                     p_bill_item_id         => l_res_bill_item_id, -- Fix bug #3347947
                                     p_alt_bom_desig        => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).alternate_bom_designator,
                                     p_bill_seq_id          => l_res_bill_seq_id, -- Fix bug #3347947
                                     p_common_bill_seq_id   => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).common_bom_sequence_id,
                                     p_bom_rev_date         => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).bom_revision_date,
                                     p_wip_supply_type      => p_wltx_resulting_jobs_tbl(p_sj_as_rj_index).wip_supply_type,
                                     p_last_update_date     => sysdate,
                                     p_last_updated_by      => g_USER_ID,
                                     p_last_update_login    => g_user_LOGIN_ID,
                                     p_creation_date        => sysdate,
                                     p_created_by           => g_USER_ID,
                                     p_request_id           => g_REQUEST_ID,
                                     p_program_app_id       => g_program_appl_id,
                                     p_program_id           => g_PROGRAM_ID,
                                     p_program_update_date  => sysdate,
                                     p_inf_sch_flag         => 'Y',
                                     p_inf_sch_mode         => NULL, -- Create_JobCopies to figure out
                                     p_inf_sch_date         => NULL, --Bug #3348704    l_inf_sch_date
                                      --OPTII-PERF:Following parameters are added
                                     p_charges_exist        => 1,
                                     p_phantom_exists       => l_phantom_exists
                                    );

                            -- Fixed bug #3303267 : Checked the return value based on changed error codes
                            -- IF (x_err_code <> 0) THEN
                            IF (x_err_code = 0) OR
                               (x_err_code IS NULL) OR -- No error
                               (x_err_code = -1)    -- Warning
                            THEN
                                x_err_code := 0;    -- Fix for bug #3421662 --
                            ELSE
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned error:' || x_err_buf,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned success',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                        ELSIF (p_copy_mode = 2) THEN -- Make copies at end (for interface ONLY)
                            l_stmt_num := 150;

                            UPDATE  wsm_lot_based_jobs
                            SET     internal_copy_type = 2
                            WHERE   wip_entity_id = l_rep_wip_entity_id;

                            if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Set internal_copy_type = 2 for we_id='||l_rep_wip_entity_id,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                            End if;

                        END IF; --(p_copy_mode)

                    END IF;

              end if;

         END IF;

    END IF; --(p_txn_type_id)

    l_stmt_num := 160;
    x_err_code := 0;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CREATE_COPIES_OR_SET_COPY_DATA('||l_stmt_num||'): '||x_err_buf;

                FND_MSG_PUB.Count_And_Get (p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CREATE_COPIES_OR_SET_COPY_DATA('||l_stmt_num||'): '||x_err_buf;

                FND_MSG_PUB.Count_And_Get ( p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );


        WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CREATE_COPIES_OR_SET_COPY_DATA('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                               p_stmt_num               => l_stmt_num               ,
                                               p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                               p_run_log_level          => l_log_level
                                             );
                END IF;

END CREATE_COPIES_OR_SET_COPY_DATA;
/* have to work on this procedure..... */


/*-----------------------------------------------------------------+
| Name : CALL_INF_SCH_OR_SET_SCH_DATA
|        This procedure calls the Infinite Scheduler
|        or sets data in wsm_lot_based_jobs table the Inf.Scheduler
-------------------------------------------------------------------*/

PROCEDURE CALL_INF_SCH_OR_SET_SCH_DATA (p_txn_id    IN  NUMBER,
                                        p_copy_mode IN  NUMBER,
                                        p_org_id    IN  NUMBER,
                                        p_par_we_id IN  NUMBER,
                                        x_err_code  OUT NOCOPY NUMBER,
                                        x_err_buf   OUT NOCOPY VARCHAR2)
IS
    l_schedule_mode             NUMBER;

    l_job_op_seq_num            NUMBER;
    l_job_op_seq_id             NUMBER;
    l_job_std_op_id             NUMBER;
    l_job_intra_op              NUMBER;
    l_job_dept_id               NUMBER;
    l_job_qty                   NUMBER;
    l_job_op_start_dt           DATE;
    l_job_op_comp_dt            DATE;
    l_returnStatus              VARCHAR2(1);
    x_msg_count                 number;
    -- Logging variables.....
    l_msg_tokens                WSM_Log_PVT.token_rec_tbl;
    l_log_level                 number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num                  NUMBER;
    l_module                    VARCHAR2(100) := 'wsm.plsql.WSMPJUPDB.CALL_INF_SCH_OR_SET_SCH_DATA';
    -- Logging variables...

BEGIN

    l_stmt_num := 10;

    -- ST : Fix for bug 5181364
    -- Changed the scheduling path to forwards scheduling instead of midpoint forward
    SELECT  decode(on_rec_path, 'Y', WIP_CONSTANTS.FORWARDS, WIP_CONSTANTS.CURRENT_OP)
    INTO    l_schedule_mode
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_par_we_id;

    l_stmt_num := 30;

    GET_JOB_CURR_OP_INFO(p_wip_entity_id        => p_par_we_id,
                         p_op_seq_num           => l_job_op_seq_num,
                         p_op_seq_id            => l_job_op_seq_id,
                         p_std_op_id            => l_job_std_op_id,
                         p_intra_op             => l_job_intra_op,
                         p_dept_id              => l_job_dept_id,
                         p_op_qty               => l_job_qty,
                         p_op_start_date        => l_job_op_start_dt,
                         p_op_completion_date   => l_job_op_comp_dt,
                         x_err_code             => x_err_code,
                         x_err_buf              => x_err_buf,
                         x_msg_count            => x_msg_count
                         );

    IF (x_err_code <> 0) THEN
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'GET_JOB_CURR_OP_INFO returned error:' || x_err_buf,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                       );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_stmt_num := 40;

    IF (p_copy_mode = 1) THEN -- Make copies after each transaction

        l_stmt_num := 50;

        WSM_infinite_scheduler_PVT.schedule
                (
                 p_initMsgList   => FND_API.g_true,
                 p_endDebug      => FND_API.g_true,
                 p_orgID         => p_org_id,
                 p_wipEntityID   => p_par_we_id,
                 p_scheduleMode  => l_schedule_mode,
                 p_startDate     => l_job_op_start_dt,
                 p_endDate       => NULL,
                 p_opSeqNum      => 0-l_job_op_seq_num,
                 p_resSeqNum     => NULL,
                 x_returnStatus  => l_returnStatus,
                 x_errorMsg      => x_err_buf
                );

        IF(l_returnStatus <> FND_API.G_RET_STS_SUCCESS) THEN
            x_err_code := -1;
            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'WSM_infinite_scheduler_PVT.schedule returned error:' || x_err_buf,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                       );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            x_err_code := 0;
        END IF;

    ELSIF (p_copy_mode = 2) THEN -- Make copies at end (for interface ONLY)

        l_stmt_num := 60;

        UPDATE  wsm_lot_based_jobs
        SET     infinite_schedule = 'Y'
        WHERE   wip_entity_id = p_par_we_id;

    END IF; --p_copy_mode

    l_stmt_num := 70;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CALL_INF_SCH_OR_SET_SCH_DATA('||l_stmt_num||'): '||x_err_buf;
                /*
                FND_MSG_PUB.Count_And_Get (p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );
                */
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_err_code := SQLCODE;
                x_err_buf := ' WSMPJUPD.CALL_INF_SCH_OR_SET_SCH_DATA('||l_stmt_num||'): '||x_err_buf;
                /*
                FND_MSG_PUB.Count_And_Get ( p_encoded => 'F',
                                            p_count => x_msg_count ,
                                            p_data => x_err_buf
                                          );
                */
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := ' WSMPJUPD.CALL_INF_SCH_OR_SET_SCH_DATA('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);

        IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
           (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
        THEN
            WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                       p_stmt_num               => l_stmt_num               ,
                                       p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                       p_run_log_level          => l_log_level
                                     );
        END IF;

END CALL_INF_SCH_OR_SET_SCH_DATA;
/* end..... */

PROCEDURE PROCESS_LOTS (p_copy_qa                       IN                      VARCHAR2,
                        p_txn_org_id                    IN                      NUMBER,
                        p_rep_job_index                 IN                      NUMBER,
                        p_wltx_header                   IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                        p_wltx_starting_jobs_tbl        IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                        p_wltx_resulting_jobs_tbl       IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                        p_secondary_qty_tbl             IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                        -- p_txn_id                     OUT     NOCOPY          NUMBER, /* i dont think this is needed,,,, */
                        x_return_status                 OUT     NOCOPY          VARCHAR2,
                        x_msg_count                     OUT     NOCOPY          NUMBER,
                        x_error_msg                     OUT     NOCOPY          VARCHAR2
                       ) is

   l_new_rj_we_id_tbl   t_number;
   l_new_rj_qty_tbl     t_number;

   l_sj_we_id_tbl       t_number;
   l_sj_old_st_qty_tbl  t_number;
   l_sj_new_qty_tbl     t_number;
   l_sj_new_net_qty_tbl t_number;
   l_sj_op_seq_tbl      t_number;
   l_sj_scrap_qty_tbl   t_number;
   l_sj_avail_qty_tbl   t_number;

   l_job_intraop_step   number;

   l_rep_new_qty        number;
   l_non_rep_sj_tbl     t_number; -- table to store the wip_entity_id of the non-rep starting jobs...

   l_sj_also_rj_index   number;
   l_rep_sj_index       number;
   l_rj_index           number;
   l_bonus_job_st_op_seq number;
   l_bonus_rtg_st_op_seq number;
   l_acct_period_id     number;

   l_profile_value      number;
   l_po_creation_time   wip_parameters.po_creation_time%type;

   --MES columns
   l_current_rtg_op_seq_num     number;
   l_current_job_op_seq_num     number;
   --End MES columns

   --SO LBJ Rsvn add
   l_rsv_exists         boolean;
   --End SO LBJ Rsvn add

   l_err_code           number;
   l_err_buf            varchar2(2000);

   l_txn_status         number;
   l_txn_costed         number;

   l_rj_kanban_card_id  number;
   l_po_request_id      number;

   l_new_we_id          number;
   l_sub_loc_change     number;
   l_ret_status         varchar2(1);
   l_new_name           wip_entities.wip_entity_name%type;
   l_dup_job_name       wip_entities.wip_entity_name%type;

   l_job_counter        NUMBER;

   l_sj_gen_object_id   wip_entities.gen_object_id%type;
   l_rj_gen_object_id   wip_entities.gen_object_id%type;

   l_kanban_card_id     wip_discrete_jobs.kanban_card_id%type;

   l_msg_count          number;
   l_msg_data           varchar2(2000);

   /*logging variables*/
   l_stmt_num           number := 0;
   l_msg_tokens         WSM_log_PVT.token_rec_tbl;
   l_log_level          number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_module             VARCHAR2(100) := 'wsm.plsql.WSMPJUPD.process_lots';
   l_schedule_group_id  NUMBER;

BEGIN

    l_stmt_num  := 10;
    g_user_id                   := FND_GLOBAL.USER_ID;
    g_user_login_id             := FND_GLOBAL.LOGIN_ID;
    g_program_appl_id           := FND_GLOBAL.PROG_APPL_ID;
    g_request_id                := FND_GLOBAL.CONC_REQUEST_ID;
    g_program_id                := FND_GLOBAL.CONC_PROGRAM_ID;

    x_return_status := g_ret_success;

    if( g_log_level_statement   >= l_log_level ) then
                -- Log the transaction data...
                WSM_WIP_LOT_TXN_PVT.Log_transaction_data (  p_txn_header_rec        => p_wltx_header             ,
                                                            p_starting_jobs_tbl     => p_wltx_starting_jobs_tbl  ,
                                                            p_resulting_jobs_tbl    => p_wltx_resulting_jobs_tbl ,
                                                            p_secondary_qty_tbl     => p_secondary_qty_tbl       ,
                                                            x_return_status         => x_return_status           ,
                                                            x_msg_count             => x_msg_count               ,
                                                            x_error_msg             => x_error_msg
                                                          );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
    End if;

    l_profile_value := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(p_txn_org_id); -- This returns the Profile value

    l_stmt_num  := 20;

    select meaning
    into g_translated_meaning
    from mfg_lookups
    where lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
    and lookup_code = 7
    and upper(enabled_flag) = 'Y';

    l_stmt_num  := 30;

    IF (l_profile_value = 2) THEN   -- Dont make copies
        WSMPJUPD.g_copy_mode := 0;
    ELSE
        IF (WSMPJUPD.g_copy_mode IS NULL) THEN  -- Called through the form
            WSMPJUPD.g_copy_mode := 1;  -- For form, make copies immediately
        END IF;
    END IF;

    l_stmt_num  := 40;

    -- get the po creation type...
    SELECT po_creation_time
    INTO   l_po_creation_time
    FROM   wip_parameters
    WHERE  organization_id = p_txn_org_id;

    if p_wltx_header.transaction_id is null then
        select wsm_split_merge_transactions_s.nextval
        into p_wltx_header.transaction_id
        from dual;
    end if;

    l_stmt_num  := 50;
    -- for based on each transaction type...
    if p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.MERGE) then

        l_stmt_num      := 55;
        -- do the split processing....
        l_non_rep_sj_tbl.delete;

        -- loop on the jobs....
        if p_wltx_header.transaction_type_id = WSMPCNST.SPLIT then
                l_rep_sj_index := p_wltx_starting_jobs_tbl.first;
        elsif p_rep_job_index is not null then
                l_rep_sj_index := p_rep_job_index;
        else
                -- rep job index not passed...
                l_job_counter := p_wltx_starting_jobs_tbl.first;
                while l_job_counter is not null loop
                        if p_wltx_starting_jobs_tbl(l_job_counter).representative_flag = 'Y' then
                                l_rep_sj_index := l_job_counter;
                                exit;
                        end if;
                end loop;
        end if;

        select schedule_group_id
        into l_schedule_group_id
        from wip_discrete_jobs
        where wip_entity_id = p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;

        l_sj_also_rj_index := null;

        l_stmt_num      := 60;

        l_job_counter := p_wltx_resulting_jobs_tbl.first;

        while l_job_counter is not null loop
        -- for l_job_counter in p_wltx_resulting_jobs_tbl.first..p_wltx_resulting_jobs_tbl.last loop

                l_stmt_num      := 61;

                if p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name = p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_name then
                        l_stmt_num      := 62;
                        -- indicates the starting job is also a resulting job...
                        p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id := p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;
                        l_sj_also_rj_index := l_job_counter;
                else
                        l_stmt_num      := 63;

                        -- else indicates that the job is a new job...
                        IF (WSMPJUPD.g_copy_mode = 0) THEN -- No copies to be made
                            -- Added condition for APS-WLT

                                -------------------- Related Bugs for this piece of code.... ----------------------------
                                --  3698595
                                -- -------------------- Related Bugs for this piece of code.... -------------------------
                                l_stmt_num      := 65;

                                l_err_code := 0;
                                l_err_buf  := null;
                                --remove this

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           =>  'Calling WSMPLBJI.build_lbji_info procedure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                 End if;

                                -- Create Job Header ONLY
                                WSMPLBJI.build_lbji_info
                                    (p_routing_seq_id          => p_wltx_resulting_jobs_tbl(l_job_counter).common_routing_sequence_id,
                                     p_common_bill_sequence_id => p_wltx_resulting_jobs_tbl(l_job_counter).common_bom_sequence_id,
                                     p_explode_header_detail   => 2, --This creates header only (WE, WDJ, WPB)
                                     p_status_type             => WIP_CONSTANTS.RELEASED,
                                     p_class_code              => p_wltx_starting_jobs_tbl(l_rep_sj_index).class_code,
                                     p_org                     => p_wltx_starting_jobs_tbl(l_rep_sj_index).organization_id,
                                     p_wip_entity_id           => l_new_we_id, -- this is returned by the API
                                     p_last_updt_date          => sysdate,
                                     p_last_updt_by            => g_user_id,
                                     p_creation_date           => sysdate,
                                     p_created_by              => g_user_id,
                                     p_last_updt_login         => g_user_login_id,
                                     p_request_id              => g_request_id,
                                     p_program_application_id  => g_program_appl_id,
                                     p_program_id              => g_program_id,
                                     p_prog_updt_date          => sysdate,
                                     p_source_line_id          => NULL,
                                     p_source_code             => NULL,
                                     p_description             => p_wltx_resulting_jobs_tbl(l_job_counter).description,
                                     p_item                    => p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id,
                                     p_job_type                => p_wltx_resulting_jobs_tbl(l_job_counter).job_type,
                                     p_bom_reference_id        => p_wltx_resulting_jobs_tbl(l_job_counter).bom_reference_id,
                                     p_routing_reference_id    => p_wltx_resulting_jobs_tbl(l_job_counter).routing_reference_id,
                                     p_firm_planned_flag       => 2,
                                     p_wip_supply_type         => p_wltx_resulting_jobs_tbl(l_job_counter).wip_supply_type,
                                     p_fusd                    => p_wltx_resulting_jobs_tbl(l_job_counter).scheduled_start_date,
                                     p_lucd                    => p_wltx_resulting_jobs_tbl(l_job_counter).scheduled_completion_date,
                                     p_start_quantity          => p_wltx_resulting_jobs_tbl(l_job_counter).start_quantity,
                                     p_net_quantity            => p_wltx_resulting_jobs_tbl(l_job_counter).net_quantity,
                                     p_coproducts_supply       => p_wltx_resulting_jobs_tbl(l_job_counter).coproducts_supply,
                                     p_bom_revision            => p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision,
                                     p_routing_revision        => p_wltx_resulting_jobs_tbl(l_job_counter).routing_revision,
                                     p_bom_revision_date       => p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision_date,
                                     p_routing_revision_date   => p_wltx_resulting_jobs_tbl(l_job_counter).routing_revision_date,
                                     p_lot_number              => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name,
                                     p_alt_bom_designator      => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_bom_designator,
                                     p_alt_routing_designator  => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_routing_designator,
                                     p_priority                => NULL,
                                     p_due_date                => NULL,

                                     p_attribute_category      => p_wltx_resulting_jobs_tbl(l_job_counter).attribute_category,
                                     p_attribute1              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute1,
                                     p_attribute2              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute2,
                                     p_attribute3              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute3,
                                     p_attribute4              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute4,
                                     p_attribute5              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute5,
                                     p_attribute6              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute6,
                                     p_attribute7              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute7,
                                     p_attribute8              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute8,
                                     p_attribute9              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute9,
                                     p_attribute10             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute10,
                                     p_attribute11             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute11,
                                     p_attribute12             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute12,
                                     p_attribute13             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute13,
                                     p_attribute14             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute14,
                                     p_attribute15             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute15,

                                     p_job_name                => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name,
                                     p_completion_subinventory => p_wltx_resulting_jobs_tbl(l_job_counter).completion_subinventory,
                                     p_completion_locator_id   => p_wltx_resulting_jobs_tbl(l_job_counter).completion_locator_id,
                                     p_demand_class            => p_wltx_starting_jobs_tbl(l_rep_sj_index).demand_class,
                                     p_project_id              => NULL,
                                     p_task_id                 => NULL,
                                     p_schedule_group_id       => NULL,
                                     p_build_sequence          => NULL,
                                     p_line_id                 => NULL,
                                     p_kanban_card_id          => NULL,
                                     p_overcompl_tol_type      => NULL,
                                     p_overcompl_tol_value     => NULL,
                                     p_end_item_unit_number    => NULL,
                                     p_rtg_op_seq_num          => p_wltx_resulting_jobs_tbl(l_job_counter).starting_operation_seq_num,
                                     p_src_client_server       => 1,
                                     p_po_creation_time        => l_po_creation_time,
                                     p_date_released           => p_wltx_header.transaction_date, --bug 4101117
                                     p_error_code              => l_err_code,
                                     p_error_msg               => l_err_buf
                                 );

                                l_stmt_num      := 70;

                                IF (l_err_code <> 0) THEN

                                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           =>  'Returned failure from WSMPLBJI.build_lbji_info procedure'      ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                    END IF;
                                    RAISE FND_API.G_EXC_ERROR;
                                ELSE
                                    -- success... now the program would have returned the id ....
                                    if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           =>  'Returned successfully from WSMPLBJI.build_lbji_info procedure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                    End if;
                                    p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id := l_new_we_id;
                                END IF;

                        --Start : Additions for APS-WLT--
                        ELSIF (WSMPJUPD.g_copy_mode <> 0) THEN  -- Copies are to be made i.e. Option C
                                                                    -- Make copies immediately or at the end

                                l_stmt_num      := 75;
                                -------------------- Related Bugs for this piece of code.... ---------------------------
                                --  3698595
                                -------------------- Related Bugs for this piece of code.... ------------------------
                                l_err_code := 0;
                                l_err_buf  := null;

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           =>  'Calling WSM_lbj_interface_PVT.build_job_header_info',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                 End if;

                                -- Create Job Header ONLY
                                WSM_lbj_interface_PVT.build_job_header_info
                                       (p_common_routing_sequence_id=> p_wltx_resulting_jobs_tbl(l_job_counter).common_routing_sequence_id,
                                        p_common_bill_sequence_id   => p_wltx_resulting_jobs_tbl(l_job_counter).common_bom_sequence_id,
                                        p_status_type               => WIP_CONSTANTS.RELEASED,
                                        p_class_code                => p_wltx_starting_jobs_tbl(l_rep_sj_index).class_code,
                                        p_org_id                    => p_wltx_starting_jobs_tbl(l_rep_sj_index).organization_id,
                                        p_wip_entity_id             => l_new_we_id, -- this is returned by the API
                                        p_last_updt_date            => sysdate,
                                        p_last_updt_by              => g_user_id,
                                        p_creation_date             => sysdate,
                                        p_created_by                => g_user_id,
                                        p_last_updt_login           => g_user_login_id,
                                        p_request_id                => g_request_id,
                                        p_program_appl_id           => g_program_appl_id,
                                        p_program_id                => g_program_id,
                                        p_prog_updt_date            => sysdate,
                                        p_source_line_id            => NULL,
                                        p_source_code               => NULL,
                                        p_description               => p_wltx_resulting_jobs_tbl(l_job_counter).description,
                                        p_item                      => p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id,
                                        p_job_type                  => p_wltx_resulting_jobs_tbl(l_job_counter).job_type,
                                        p_bom_reference_id          => p_wltx_resulting_jobs_tbl(l_job_counter).bom_reference_id,
                                        p_routing_reference_id      => p_wltx_resulting_jobs_tbl(l_job_counter).routing_reference_id,
                                        p_firm_planned_flag         => 2,
                                        p_wip_supply_type           => p_wltx_resulting_jobs_tbl(l_job_counter).wip_supply_type,
                                        p_job_scheduled_start_date  => p_wltx_resulting_jobs_tbl(l_job_counter).scheduled_start_date,
                                        p_job_scheduled_compl_date  => p_wltx_resulting_jobs_tbl(l_job_counter).scheduled_completion_date,
                                        p_start_quantity            => p_wltx_resulting_jobs_tbl(l_job_counter).start_quantity,
                                        p_net_quantity              => p_wltx_resulting_jobs_tbl(l_job_counter).net_quantity,
                                        p_coproducts_supply         => p_wltx_resulting_jobs_tbl(l_job_counter).coproducts_supply,
                                        p_bom_revision              => p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision,
                                        p_routing_revision          => p_wltx_resulting_jobs_tbl(l_job_counter).routing_revision,
                                        p_bom_revision_date         => p_wltx_resulting_jobs_tbl(l_job_counter).bom_revision_date,
                                        p_routing_revision_date     => p_wltx_resulting_jobs_tbl(l_job_counter).routing_revision_date,
                                        p_lot_number                => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name,
                                        p_alt_bom_designator        => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_bom_designator,
                                        p_alt_routing_designator    => p_wltx_resulting_jobs_tbl(l_job_counter).alternate_routing_designator,
                                        p_priority                  => NULL,
                                        p_due_date                  => NULL,

                                        p_attribute_category      => p_wltx_resulting_jobs_tbl(l_job_counter).attribute_category,
                                        p_attribute1              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute1,
                                        p_attribute2              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute2,
                                        p_attribute3              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute3,
                                        p_attribute4              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute4,
                                        p_attribute5              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute5,
                                        p_attribute6              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute6,
                                        p_attribute7              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute7,
                                        p_attribute8              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute8,
                                        p_attribute9              => p_wltx_resulting_jobs_tbl(l_job_counter).attribute9,
                                        p_attribute10             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute10,
                                        p_attribute11             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute11,
                                        p_attribute12             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute12,
                                        p_attribute13             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute13,
                                        p_attribute14             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute14,
                                        p_attribute15             => p_wltx_resulting_jobs_tbl(l_job_counter).attribute15,

                                        p_job_name                  => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name,
                                        p_completion_subinventory   => p_wltx_resulting_jobs_tbl(l_job_counter).completion_subinventory,
                                        p_completion_locator_id     => p_wltx_resulting_jobs_tbl(l_job_counter).completion_locator_id,
                                        p_demand_class              => p_wltx_starting_jobs_tbl(l_rep_sj_index).demand_class,
                                        p_project_id                => NULL,
                                        p_task_id                   => NULL,
                                        p_schedule_group_id         => l_schedule_group_id,
                                        p_build_sequence            => NULL,
                                        p_line_id                   => NULL,
                                        p_kanban_card_id            => NULL,
                                        p_overcompl_tol_type        => NULL,
                                        p_overcompl_tol_value       => NULL,
                                        p_end_item_unit_number      => NULL,
                                        p_src_client_server         => 1,
                                        p_po_creation_time          => l_po_creation_time,
                                        p_date_released             => p_wltx_header.transaction_date, --bug 4101117
                                        p_error_code                => l_err_code,
                                        p_error_msg                 => l_err_buf
                                );

                                l_stmt_num  := 80;

                                IF (l_err_code <> 0) THEN
                                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           =>  'Returned failure from WSM_lbj_interface_PVT.build_job_header_info'||l_err_buf,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;

                                ELSE
                                    -- success... now the program would have returned the id ....
                                    if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           =>  'Returned success from WSM_lbj_interface_PVT.build_job_header_info',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                    End if;

                                    p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id := l_new_we_id;
                                END IF;

                        END IF; --WSMPJUPD.g_copy_mode

                        l_stmt_num  := 85;

                        l_new_rj_we_id_tbl(l_job_counter) := p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;
                        l_new_rj_qty_tbl(l_job_counter)   := p_wltx_resulting_jobs_tbl(l_job_counter).start_quantity;

                        -- Kanban stuff for Merge Txn....
                        if p_wltx_header.transaction_type_id = WSMPCNST.merge then
                                -- here take care of the following case
                                --         A*
                                --           \
                                --            |-- C
                                --           /
                                --         B
                                -- where A is the representative lot and has a kanban reference. In this case, C will inherit
                                -- the kanban reference of A, provided that the completion subinventory of A and C are the same.

                                l_kanban_card_id := p_wltx_starting_jobs_tbl(l_rep_sj_index).kanban_card_id;
                                p_wltx_resulting_jobs_tbl(l_job_counter).kanban_card_id := null;

                                if l_kanban_card_id is not null then
                                    if ( (p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_subinventory = p_wltx_resulting_jobs_tbl(l_job_counter).completion_subinventory)
                                          AND
                                          (nvl(p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_locator_id,-999) = nvl(p_wltx_resulting_jobs_tbl(l_job_counter).completion_locator_id,-999))
                                       )
                                    then

                                        l_stmt_num := 53;
                                        -- this means this kanban_card_id is inherited by resulting job, while examining the starting jobs
                                        -- do not set the kanban card to Exception just because the qties of the starting jobs have become 0
                                         if( g_log_level_statement   >= l_log_level ) then
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           =>  'Calling INV_Kanban_PVT.Update_Card_Supply_Status',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_log_level      => g_log_level_statement,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                         End if;

                                        INV_Kanban_PVT.Update_Card_Supply_Status( X_Return_Status       => l_ret_status,
                                                                                  p_Kanban_Card_Id      => l_kanban_card_id,
                                                                                  p_Supply_Status       => INV_Kanban_PVT.G_Supply_Status_InProcess,
                                                                                  p_Document_type       => inv_kanban_pvt.G_Doc_type_lot_job,
                                                                                  p_Document_Header_Id  => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id,
                                                                                  p_Document_detail_Id  => '',
                                                                                  p_replenish_quantity  => p_wltx_resulting_jobs_tbl(l_job_counter).start_quantity
                                                                                );

                                        if ( l_ret_status <> fnd_api.g_ret_sts_success ) then
                                            IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                        l_msg_tokens.delete;
                                                        l_msg_tokens(1).TokenName := 'STATUS';
                                                        l_msg_tokens(1).TokenValue := g_translated_meaning;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                                               p_msg_appl_name      => 'WSM'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                             END IF;

                                             RAISE FND_API.G_EXC_ERROR;

                                        end if;

                                        p_wltx_resulting_jobs_tbl(l_job_counter).kanban_card_id := l_kanban_card_id;

                                    end if;
                                end if;

                                update wip_discrete_jobs
                                set     completion_subinventory  = p_wltx_resulting_jobs_tbl(l_job_counter).completion_subinventory,
                                        completion_locator_id    = p_wltx_resulting_jobs_tbl(l_job_counter).completion_locator_id,
                                        kanban_card_id           = p_wltx_resulting_jobs_tbl(l_job_counter).kanban_card_id
                                where wip_entity_id = p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;

                        end if;
                end if;  -- check for starting job also as a resulting job

                l_job_counter := p_wltx_resulting_jobs_tbl.next(l_job_counter);
        end loop;

        l_stmt_num  := 90;

        --Copy the job details from the representative parent lot into the child job--
        --The details are copied for all ops till the current op.--
        --i.e. If say, the job has moved into 30Q, and undone back to 20Q and a split is done here--
        --only ops 10 and 20 should get copied to the resulting jobs, since 30's cnt_pt is still 1--
        --Also any manual issues at op 30 should remain with original job--
        --That is, any manual issues at an op after the curr op, should not be proportionated. --

        l_stmt_num := 220;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling COPY_REP_JOB_WO_FA ' || p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        l_err_code := 0;
        l_err_buf  := null;

        -- Related bugs : 3142153
        COPY_REP_JOB_WO_FA(   p_txn_id                  => null,
                              p_txn_org_id              => p_txn_org_id,
                              p_new_rj_we_id_tbl        => l_new_rj_we_id_tbl,
                              p_new_rj_qty_tbl          => l_new_rj_qty_tbl,
                              p_rep_we_id               => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                              p_curr_op_seq_num         => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                              p_curr_op_seq_id          => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_id,
                              p_txn_job_intraop         => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,
                              x_err_code                => l_err_code,
                              x_err_buf                 => l_err_buf
                          );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Returned failure from COPY_REP_JOB_WO_FA',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_stmt_num := 230;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling COPY_REP_JOB_WOR ',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        l_err_code := 0;
        l_err_buf  := null;

        -- Related bugs : 3142153
        COPY_REP_JOB_WOR (  p_txn_id            => null,
                            p_new_rj_we_id_tbl  => l_new_rj_we_id_tbl,
                            p_rep_we_id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                            p_curr_op_seq_num   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                            x_err_code          => l_err_code,
                            x_err_buf           => l_err_buf);

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Returned failure from COPY_REP_JOB_WOR',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Related bugs : 3142153
        l_stmt_num := 240;

        l_err_code := 0;
        l_err_buf  := null;

        --Start: Additions for APS-WLT--
        IF (WSMPJUPD.g_copy_mode = 0) THEN
                null;
        ELSE    -- Copies are to be made i.e. Option C
                -- Make copies immediately or at the end
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           =>  'Calling COPY_REP_JOB_WSOR ',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                COPY_REP_JOB_WSOR(      p_txn_id            => null,
                                        p_new_rj_we_id_tbl  => l_new_rj_we_id_tbl,
                                        p_rep_we_id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                        p_curr_op_seq_num   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                                        x_err_code          => l_err_code,
                                        x_err_buf           => l_err_buf
                                 );

                IF (l_err_code <> 0) THEN
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Returned failure from COPY_REP_JOB_WSOR',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;

        --End: Additions for APS-WLT--

        /* ST : Detailed Scheduling start */
        l_stmt_num := 78;
        l_err_code := 0;
        l_err_buf  := null;

        COPY_REP_JOB_WORI( p_txn_id                 => null,
                           p_new_rj_we_id_tbl       => l_new_rj_we_id_tbl,
                           p_rep_we_id              => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                           p_curr_op_seq_num        => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num, -- Fix for bug #3142153
                           x_err_code               => l_err_code,
                           x_err_buf                => l_err_buf
                         );
         IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module ,
                                               p_msg_text           => 'Returned failure from COPY_REP_JOB_WORI',
                                               p_stmt_num           => l_stmt_num,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR,
                                               p_run_log_level      => l_log_level
                                              );
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
        /* ST : Detailed Scheduling end */

        l_stmt_num := 250;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module,
                                       p_msg_text           => 'Calling COPY_REP_JOB_WRO',
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_err_code := 0;
        l_err_buf  := null;

        -- Related bugs : 3142153
        COPY_REP_JOB_WRO( p_txn_id            => null,
                          p_new_rj_we_id_tbl  => l_new_rj_we_id_tbl,
                          p_new_rj_qty_tbl    => l_new_rj_qty_tbl,
                          p_rep_we_id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                          p_curr_op_seq_num   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                          p_txn_intraop_step  => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,
                          x_err_code          => l_err_code,
                          x_err_buf           => l_err_buf
                        );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Returned failure from COPY_REP_JOB_WRO',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_stmt_num := 260;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling COPY_REP_JOB_WOY ',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        l_err_code := 0;
        l_err_buf  := null;
        -- Related bugs : 3142153

        COPY_REP_JOB_WOY( p_txn_id            => null,
                          p_new_rj_we_id_tbl  => l_new_rj_we_id_tbl,
                          p_rep_we_id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                          p_curr_op_seq_num   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                          x_err_code          => l_err_code,
                          x_err_buf           => l_err_buf
                        );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Returned failure from COPY_REP_JOB_WOY',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- ok now process the starting jobs...
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  ' processing the starting jobs...',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_job_counter :=  p_wltx_starting_jobs_tbl.first;
        --Bug 5362019:Initialize l_rep_new_qty
        l_rep_new_qty := 0;

        while l_job_counter is not null loop
        -- for l_job_counter in p_wltx_starting_jobs_tbl.first..p_wltx_starting_jobs_tbl.last loop

                if (l_job_counter = l_rep_sj_index)
                    and
                   (l_sj_also_rj_index is not null)
                then -- indicates that the starting job is also a resulting job
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           =>  'Representative Starting Job ' || p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_name
                                                                                || ' is also a resulting job..'
                                                                                || ' Starting Job index(l_job_counter) : ' || l_job_counter
                                                                                || ' Resulting Job index(l_sj_also_rj_index) : ' || l_sj_also_rj_index,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;
                        -- related bugs : 3181486
                        l_stmt_num  := 95;

                        l_rep_new_qty   := p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).start_quantity;

                        -- we can directly call change_quantity here as only one starting job is possible...
                        l_sj_we_id_tbl(l_job_counter)            := p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;
                        l_sj_old_st_qty_tbl(l_job_counter)       := p_wltx_starting_jobs_tbl(l_job_counter).start_quantity;
                        l_sj_new_qty_tbl(l_job_counter)          := p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).start_quantity;
                        l_sj_new_net_qty_tbl(l_job_counter)      := p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).net_quantity;
                        l_sj_op_seq_tbl(l_job_counter)           := p_wltx_starting_jobs_tbl(l_job_counter).operation_seq_num;
                        l_sj_scrap_qty_tbl(l_job_counter)        := p_wltx_starting_jobs_tbl(l_job_counter).start_quantity - p_wltx_starting_jobs_tbl(l_job_counter).quantity_available;
                        l_sj_avail_qty_tbl(l_job_counter)        := p_wltx_starting_jobs_tbl(l_job_counter).quantity_available;

                        l_err_code := 0;
                        l_err_buf  := null;

                        l_stmt_num  := 100;

                        l_kanban_card_id := p_wltx_starting_jobs_tbl(l_job_counter).kanban_card_id;

                        -- nw comes the Kanban card id and the completion subinv. updation part....
                        -- if the starting job has a kanban and if SpUA then exception...
                        if l_kanban_card_id is not null then

                                l_stmt_num  := 115;

                                if p_wltx_header.transaction_type_id = WSMPCNST.SPLIT and p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).split_has_update_assy = 1 then

                                        l_stmt_num  := 120;
                                        if( g_log_level_statement   >= l_log_level ) then
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           =>  ' Calling INV_Kanban_PVT.Update_Card_Supply_Status...',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_log_level      => g_log_level_statement,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        End if;

                                         -- SpUA .. so remove it...
                                         INV_Kanban_PVT.Update_Card_Supply_Status (   X_Return_Status  => l_ret_status,
                                                                                      p_Kanban_Card_Id => p_wltx_starting_jobs_tbl(l_rep_sj_index).kanban_card_id,
                                                                                      p_Supply_Status  => INV_Kanban_PVT.G_Supply_Status_Exception
                                                                                 );

                                         if ( l_ret_status <> fnd_api.g_ret_sts_success ) then

                                                    IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                                l_msg_tokens.delete;
                                                                l_msg_tokens(1).TokenName := 'STATUS';
                                                                l_msg_tokens(1).TokenValue := g_translated_meaning;
                                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                                       p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                                       p_run_log_level      => l_log_level
                                                                                      );
                                                      END IF;
                                                      RAISE FND_API.G_EXC_ERROR;

                                         end if;

                                         l_stmt_num  := 125;
                                         l_kanban_card_id := null;
                                else
                                        -- now check if the resulting job has changed
                                        if( g_log_level_statement   >= l_log_level ) then
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           =>  ' Calling handle_kanban_sub_loc_change...',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_log_level      => g_log_level_statement,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        End if;

                                        l_err_code := 0;
                                        l_err_buf  := null;

                                        l_sub_loc_change := handle_kanban_sub_loc_change(  p_wip_entity_id                      => p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id,
                                                                                           p_kanban_card_id                     => p_wltx_starting_jobs_tbl(l_job_counter).kanban_card_id,
                                                                                           p_wssj_completion_subinventory       => p_wltx_starting_jobs_tbl(l_job_counter).completion_subinventory,
                                                                                           p_wssj_completion_locator_id         => p_wltx_starting_jobs_tbl(l_job_counter).completion_locator_id,
                                                                                           p_wsrj_completion_subinventory       => p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).completion_subinventory,
                                                                                           p_wsrj_completion_locator_id         => p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).completion_locator_id,
                                                                                           x_err_code                           => l_err_code,
                                                                                           x_err_msg                            => l_err_buf
                                                                                        );

                                        IF (l_err_code <> 0) THEN
                                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_text           => 'Returned failure from handle_kanban_sub_loc_change',
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_msg_tokens         => l_msg_tokens,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                  END IF;
                                                  RAISE FND_API.G_EXC_ERROR;
                                        END IF;

                                        -- indicates that the compl. subinv has changed hence remove the link to the kanban card id...
                                        if l_sub_loc_change <> 0 then
                                                l_kanban_card_id := null;
                                        end if;

                                        if l_sub_loc_change = 0 then -- reflect the updated quantity in the card

                                                l_stmt_num := 147;
                                                if( g_log_level_statement   >= l_log_level ) then
                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_text           =>  ' Calling INV_Kanban_PVT.Update_Card_Supply_Status...',
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_msg_tokens         => l_msg_tokens,
                                                                               p_fnd_log_level      => g_log_level_statement,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                End if;


                                                INV_Kanban_PVT.Update_Card_Supply_Status(  x_return_status              => l_ret_Status,
                                                                                           p_Kanban_Card_Id             => l_kanban_card_id,
                                                                                           p_Supply_Status              => INV_Kanban_PVT.G_Supply_Status_InProcess,
                                                                                           p_Document_type              => inv_kanban_pvt.G_Doc_type_lot_job,
                                                                                           p_Document_Header_Id         => p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id,
                                                                                           p_Document_detail_Id         => '',
                                                                                           p_replenish_quantity         => p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).start_quantity
                                                                                         );

                                                if ( l_ret_Status <> fnd_api.g_ret_sts_success ) then
                                                     IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                                l_msg_tokens.delete;
                                                                l_msg_tokens(1).TokenName := 'STATUS';
                                                                l_msg_tokens(1).TokenValue := g_translated_meaning;
                                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                                       p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                                       p_run_log_level      => l_log_level
                                                                                      );
                                                      END IF;
                                                      RAISE FND_API.G_EXC_ERROR;

                                                end if;

                                                l_stmt_num := 150;
                                        end if;
                                end if;
                        end if;

                        l_stmt_num := 155;

                        p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).kanban_card_id := l_kanban_card_id;

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           =>  'Updating the completion subinv and the kanban card id ...',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        -- update the completion subinv and the kanban card id ....
                        UPDATE wip_discrete_jobs
                        SET     completion_subinventory  = p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).completion_subinventory,
                                completion_locator_id    = p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).completion_locator_id  ,
                                kanban_card_id           = p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).kanban_card_id         ,
                                -- ST : Fix for bug 5122500
                                coproducts_supply        = p_wltx_resulting_jobs_tbl(l_sj_also_rj_index).coproducts_supply
                        WHERE wip_entity_id = p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;

                        l_stmt_num := 158;

                else    -- starting job is has been completely merged/split or a non-representative job...

                        l_stmt_num := 160;
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           =>  'starting job has been completely merged/split or a non-representative job... ',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        --Bug 5362019: l_rep_new_qty should not be reset.Its not applicable when
                        --             starting job is has been completely merged/split or a non-representative job.
                        --l_rep_new_qty  := 0;
                        --Bug 5362019: Populate the table l_non_rep_sj_tbl if the current job is not a representative job
                        if (l_job_counter <> l_rep_sj_index) then
                            l_non_rep_sj_tbl(l_job_counter) := p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;
                        end if;
                        --Bug 5362019: End of changes
                        -- related bugs : 3181486
                        -- we can directly call change_quantity here as only one starting job is possible...
                        l_sj_we_id_tbl(l_job_counter)            := p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;
                        l_sj_old_st_qty_tbl(l_job_counter)       := p_wltx_starting_jobs_tbl(l_job_counter).start_quantity;
                        l_sj_new_qty_tbl(l_job_counter)          := 0;
                        l_sj_new_net_qty_tbl(l_job_counter)      := 0;
                        l_sj_op_seq_tbl(l_job_counter)           := p_wltx_starting_jobs_tbl(l_job_counter).operation_seq_num;
                        l_sj_scrap_qty_tbl(l_job_counter)        := p_wltx_starting_jobs_tbl(l_job_counter).start_quantity - p_wltx_starting_jobs_tbl(l_job_counter).quantity_available;
                        l_sj_avail_qty_tbl(l_job_counter)        := p_wltx_starting_jobs_tbl(l_job_counter).quantity_available;

                        l_stmt_num := 165;

                        l_kanban_card_id := p_wltx_starting_jobs_tbl(l_job_counter).kanban_card_id;

                        -- kanban comes into picture... delete the link...
                        if l_kanban_card_id is not null then

                                l_stmt_num := 175;

                                -- In case of split straight forward....
                                -- In case of Merge check if the resulting job has kanban or not..

                                if (p_wltx_header.transaction_type_id = WSMPCNST.SPLIT) or
                                   --Bug 5344612:Case of p_wltx_resulting_jobs_tbl.kanban_card_id being null is handled.
                                    p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).kanban_card_id IS NULL or
                                    (p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).kanban_card_id IS NOT NULL AND
                                   p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).kanban_card_id <> l_kanban_card_id)
                                then

                                        INV_Kanban_PVT.Update_Card_Supply_Status  ( x_return_status  => l_ret_status,
                                                                                    p_Kanban_Card_Id => p_wltx_starting_jobs_tbl(l_job_counter).kanban_card_id,
                                                                                    p_Supply_Status  => INV_Kanban_PVT.G_Supply_Status_Exception
                                                                                   );

                                        if ( l_ret_Status <> fnd_api.g_ret_sts_success ) then
                                                    IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                                l_msg_tokens.delete;
                                                                l_msg_tokens(1).TokenName := 'STATUS';
                                                                l_msg_tokens(1).TokenValue := g_translated_meaning;
                                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                                       p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                                       p_run_log_level      => l_log_level
                                                                                      );
                                                      END IF;
                                                      RAISE FND_API.G_EXC_ERROR;
                                        end if;

                                        l_stmt_num := 137;
                                        --Bug 5344676:Commented out the following line
                                       -- l_kanban_card_id := null;
                                end if;
                                --Bug 5344676:Kanban card is should be null even if the Kanban status is not set to exception.
                                l_kanban_card_id := null;
                        end if;

                        l_stmt_num := 180;

                        -- change the status of the job...
                        -- Related bugs : 2974419
                        UPDATE  wip_discrete_jobs
                        SET     STATUS_TYPE             = 4
                                ,kanban_card_id         = l_kanban_card_id
                                ,date_completed         = sysdate
                                ,last_updated_by        = g_user_id
                                ,last_update_date       = sysdate
                                ,last_update_login      = g_user_login_id
                                ,program_application_id = g_program_appl_id
                                ,program_id             = g_PROGRAM_ID
                                ,program_update_date    = sysdate
                                ,request_id             = g_REQUEST_ID
                        WHERE   wip_entity_id = p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;

                        l_stmt_num := 190;

                        l_new_name := WSMPOPRN.update_job_name ( p_wip_entity_id => p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id,
                                                                 p_subinventory  => p_wltx_starting_jobs_tbl(l_job_counter).completion_subinventory,
                                                                 p_org_id        => p_wltx_starting_jobs_tbl(l_job_counter).organization_id,
                                                                 p_txn_type      => 2,   -- COMPLETION
                                                                 p_update_flag   => TRUE,
                                                                 p_dup_job_name  => l_dup_job_name,
                                                                 x_error_code    => l_err_code,
                                                                 x_error_msg     => l_err_buf
                                                                );

                        if l_err_code <> 0 then
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        /* Start bugfix 5738550 Use hardcoded text only if API call did not return message */
                                        if l_err_buf is null then
                                          l_err_buf := 'Returned failure from WSMPOPRN.update_job_name';
                                        end if;
                                        /* End bugfix 5738550 */
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => l_err_buf                , /* Bugfix 5738550 removed hardcoding */
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        else
                                -- success.. got the new name for the job ...
                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSMPOPRN.update_job_name success.Got new job name',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;
                        end if;
                        l_stmt_num := 200;

                end if;

                l_job_counter := p_wltx_starting_jobs_tbl.next(l_job_counter);

        end loop;


        l_stmt_num := 210;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling CHANGE_QUANTITY',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_err_code := 0;
        l_err_buf  := null;

        -- change the quantity
        CHANGE_QUANTITY( p_txn_id                => null,
                         p_txn_type              => p_wltx_header.transaction_type_id,
                         p_wip_entity_id_tbl     => l_sj_we_id_tbl,
                         p_new_job_qty_tbl       => l_sj_new_qty_tbl,
                         p_new_net_qty_tbl       => l_sj_new_net_qty_tbl,

                         p_txn_job_op_seq_tbl    => l_sj_op_seq_tbl,
                         p_txn_job_intraop       => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,

                         p_sj_st_qty_tbl         => l_sj_old_st_qty_tbl,
                         p_sj_avail_qty_tbl      => l_sj_avail_qty_tbl,
                         p_sj_scrap_qty_tbl      => l_sj_scrap_qty_tbl,

                         x_err_code              => l_err_code,
                         x_err_buf               => l_err_buf
                        );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'CHANGE_QUANTITY returned failure'               ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 270;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling UPDATE_QTY_ISSUED',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_err_code := 0;
        l_err_buf  := null;

        UPDATE_QTY_ISSUED(p_txn_id                      => null,
                          p_txn_type                    => p_wltx_header.transaction_type_id,
                          p_rep_we_id                   => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                          p_rep_op_seq_num              => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                          p_rep_avail_qty               => p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available,
                          p_rep_new_job_qty             => l_rep_new_qty,
                          p_txn_job_intraop             => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,
                          p_non_rep_sj_we_id_tbl        => l_non_rep_sj_tbl,
                          p_new_rj_we_id_tbl            => l_new_rj_we_id_tbl,
                          p_new_rj_start_qty            => l_new_rj_qty_tbl,
                          x_err_code                    => l_err_code,
                          x_err_buf                     => l_err_buf
                         );

        if l_err_code <> 0 then
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'UPDATE_QTY_ISSUED returned failure'             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 280;

        -- loop on the resulting jobs for split has update assembly...
        if p_wltx_header.transaction_type_id = WSMPCNST.SPLIT then

                l_job_counter := p_wltx_resulting_jobs_tbl.first;
                while l_job_counter is not null loop
                -- for l_job_counter in p_wltx_resulting_jobs_tbl.first..p_wltx_resulting_jobs_tbl.last loop
                        if p_wltx_resulting_jobs_tbl(l_job_counter).split_has_update_assy = 1 then

                                l_stmt_num := 290;
                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Calling UPDATE_ASSEMBLY_OR_ROUTING',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                l_stmt_num := 281;
                                l_err_code := 0;
                                l_err_buf  := null;

                                -- SpUA code....
                                UPDATE_ASSEMBLY_OR_ROUTING( p_txn_id                    => null,
                                                            p_txn_type_id               => WSMPCNST.SPLIT,
                                                            -- p_rep_wip_entity_id      => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id,
                                                            p_job_kanban_card_id        => null, -- no need already handled within the code.. .....
                                                            p_po_creation_time          => l_po_creation_time,
                                                            p_sj_compl_subinventory     => p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_subinventory,
                                                            p_sj_compl_locator_id       => p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_locator_id,
                                                            p_rj_job_rec                => p_wltx_resulting_jobs_tbl(l_job_counter),
                                                            p_request_id                => g_request_id,
                                                            x_err_code                  => l_err_code,
                                                            x_err_buf                   => l_err_buf ,
                                                            x_msg_count                 => x_msg_count
                                                          );

                                IF (l_err_code <> 0) THEN
                                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'UPDATE_ASSEMBLY_OR_ROUTING returned failure'            ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                        end if;

                        l_job_counter := p_wltx_resulting_jobs_tbl.next(l_job_counter);
                end loop;
        end if;

        l_stmt_num := 282;
        --Update the new columns in WLBJ as part of MES
        l_current_job_op_seq_num := p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num;

        BEGIN
                select operation_seq_num
                into l_current_rtg_op_seq_num
                from bom_operation_sequences
                where operation_sequence_id = p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_id ;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        -- Will reach here when the job lies at an op outside the
                        -- routing
                        l_current_rtg_op_seq_num := null;
        END;

        l_stmt_num := 283;
        forall i in indices of l_new_rj_we_id_tbl
                update wsm_lot_based_jobs
                set CURRENT_RTG_OP_SEQ_NUM = l_current_rtg_op_seq_num,
                    CURRENT_JOB_OP_SEQ_NUM = l_current_job_op_seq_num
                where wip_entity_id = l_new_rj_we_id_tbl(i)
                and CURRENT_RTG_OP_SEQ_NUM is null
                and CURRENT_JOB_OP_SEQ_NUM is null;

        ----End Update the new columns in WLBJ as part of MES

        -- Start : Additions for APS-WLT --
        l_stmt_num := 295;


        IF (WSMPJUPD.g_copy_mode = 0) THEN
                null; -- no copies
        ELSE
                l_stmt_num := 296;

                l_err_code := 0;
                l_err_buf  := null;

                CREATE_COPIES_OR_SET_COPY_DATA (p_txn_id                        => null,
                                                p_txn_type_id                   => p_wltx_header.transaction_type_id,
                                                p_copy_mode                     => WSMPJUPD.g_copy_mode,
                                                p_rep_sj_index                  => l_rep_sj_index,
                                                p_sj_as_rj_index                => l_sj_also_rj_index,
                                                p_wltx_starting_jobs_tbl        => p_wltx_starting_jobs_tbl,
                                                p_wltx_resulting_jobs_tbl       => p_wltx_resulting_jobs_tbl,
                                                x_err_code                      => l_err_code,
                                                x_err_buf                       => l_err_buf,
                                                x_msg_count                     => x_msg_count
                                               );


                IF (l_err_code <> 0) THEN
                            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'CREATE_COPIES_OR_SET_COPY_DATA returned '||l_err_code,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                           END IF;
                        RAISE FND_API.G_EXC_ERROR;  --x_err_code has errcode, x_err_buf has the error message
                END IF;

                -- New Jobs in Split/Merge, jobs undergoing SPUA and jobs involved in Upd Rtg/Assly
                -- have already been either Infinite Scheduled or the data has been set for them
                -- in the above call CREATE_COPIES_OR_SET_COPY_DATA, which
                -- calls Create_JobCopies / Create_RepJobCopies
                -- The remaining jobs (parent rep jobs in Sp/Merge and jobs in UpdQty)
                -- are taken care of now

                l_stmt_num := 300;

                IF l_sj_also_rj_index is not null then

                        l_stmt_num := 310;

                        l_err_code := 0;
                        l_err_buf  := null;

                        CALL_INF_SCH_OR_SET_SCH_DATA(  p_txn_id         => null,
                                                       p_copy_mode      => WSMPJUPD.g_copy_mode,
                                                       p_org_id         => p_txn_org_id,
                                                       p_par_we_id      => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                       x_err_code       => l_err_code,
                                                       x_err_buf        => l_err_buf
                                                     );

                        IF (l_err_code <> 0) THEN
                             -- error out...
                                 IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => ' CALL_INF_SCH_OR_SET_SCH_DATA returned '||l_err_code,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                 END IF;
                                 RAISE FND_API.G_EXC_ERROR;
                        END IF;

                END IF;

        END IF;

        -- ST : Sec. UOM Fix : Moved the call to process MES information below the call to update_assembly_routing
        l_stmt_num := 320;
        process_mes_info    ( p_secondary_qty_tbl               => p_secondary_qty_tbl,
                               p_wltx_header                    => p_wltx_header,
                               p_wltx_starting_jobs_tbl         => p_wltx_starting_jobs_tbl,
                               p_wltx_resulting_jobs_tbl        => p_wltx_resulting_jobs_tbl,
                               p_sj_also_rj_index               => l_sj_also_rj_index,
                               p_rep_job_index                  => l_rep_sj_index,
                               x_return_status                  => x_return_status  ,
                               x_msg_count                      => x_msg_count      ,
                               x_error_msg                      => x_error_msg
                            );
        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSE
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        l_stmt_num := 330;
        -- Geneology differs for split and merge...
        if p_wltx_header.transaction_type_id = WSMPCNST.SPLIT then

                l_stmt_num := 340;

                -- for geneology purpose.... get the gen obj id
                select gen_object_id
                into l_sj_gen_object_id
                from wip_entities we
                where we.wip_entity_id = p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;

                for l_job_counter in p_wltx_resulting_jobs_tbl.first..p_wltx_resulting_jobs_tbl.last loop

                        l_stmt_num := 345;

                        -- get the gen object id of the resulting jobs ...
                        select gen_object_id
                        into l_rj_gen_object_id
                        from wip_entities we
                        where we.wip_entity_id = p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id;
                        --Bug 5387828:Genealogy should be created only when the starting job is diff from
                        --resulting job.
                        if l_sj_gen_object_id <> l_rj_gen_object_id then
                        l_ret_status := 'E'; -- fnd error status...

                        l_stmt_num := 350;

                        inv_genealogy_pub.insert_genealogy( p_api_version             =>1.0,

                                                            p_object_type             =>5,
                                                            p_object_id               =>l_sj_gen_object_id,
                                                            p_object_number           =>p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_name,
                                                            p_inventory_item_id       =>p_wltx_starting_jobs_tbl(l_rep_sj_index).primary_item_id,
                                                            p_org_id                  =>p_wltx_starting_jobs_tbl(l_rep_sj_index).organization_id,

                                                            p_parent_object_type      => 5,
                                                            p_parent_object_id        => l_rj_gen_object_id,
                                                            p_parent_object_number    => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_name,
                                                            p_parent_inventory_item_id=> p_wltx_resulting_jobs_tbl(l_job_counter).primary_item_id,
                                                            p_parent_org_id           => p_wltx_resulting_jobs_tbl(l_job_counter).organization_id,

                                                            p_genealogy_origin        => 3,  -- for WIP parent
                                                            p_genealogy_type          => 4,  -- for WIP/Inv Split/Merge/Translate
                                                            p_origin_txn_id           => p_wltx_header.transaction_id,

                                                            x_return_status           =>l_ret_status,
                                                            x_msg_count               =>l_msg_count,
                                                            x_msg_data                =>l_msg_data
                                                            );
                        end if;
                        if l_sj_gen_object_id = l_rj_gen_object_id then
                            l_ret_status := 'S';
                        end if;
                        l_stmt_num := 360;
                        IF (l_ret_status = 'S') THEN
                            if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'inv_genealogy_pub.insert_genealogy returned success',
                                                       p_stmt_num           => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                            End if;

                        ELSE

                            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'inv_genealogy_pub.insert_genealogy failed',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                            END IF;


                            l_stmt_num := 370;
                            IF (l_msg_count = 1)  THEN
                                l_err_code := -1;
                                l_err_buf := 'Error in inv_genealogy_pub.insert_genealogy: '||l_msg_data;

                            ELSE
                                FOR i IN 1..l_msg_count LOOP
                                    l_err_code := -1;
                                    l_err_buf := fnd_msg_pub.get;

                                END LOOP;

                                l_err_buf := 'Multiple errors in inv_genealogy_pub.insert_genealogy - populated in the log file';

                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                end loop;
        else
                -- Merge...

                l_stmt_num := 371;

                l_rj_index := p_wltx_resulting_jobs_tbl.first;

                -- for geneology purpose.... get the gen obj id
                select gen_object_id
                into l_rj_gen_object_id
                from wip_entities we
                where we.wip_entity_id = p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id;

                for l_job_counter in p_wltx_starting_jobs_tbl.first..p_wltx_starting_jobs_tbl.last loop

                        l_stmt_num := 372;

                        -- get the gen object id of the resulting jobs ...
                        select gen_object_id
                        into l_sj_gen_object_id
                        from wip_entities we
                        where we.wip_entity_id = p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_id;

						--Bug 5367218:START. Genealogy should be created only when the resulting job is not
                        -- among one of the starting jobs.
                        if l_sj_gen_object_id <> l_rj_gen_object_id then
                        l_ret_status := 'E'; -- fnd error status...

                        l_stmt_num := 373;

                        inv_genealogy_pub.insert_genealogy( p_api_version             =>1.0,

                                                            p_object_type             =>5,
                                                            p_object_id               =>l_sj_gen_object_id,
                                                            p_object_number           =>p_wltx_starting_jobs_tbl(l_job_counter).wip_entity_name,
                                                            p_inventory_item_id       =>p_wltx_starting_jobs_tbl(l_job_counter).primary_item_id,
                                                            p_org_id                  =>p_wltx_starting_jobs_tbl(l_job_counter).organization_id,

                                                            p_parent_object_type      => 5,
                                                            p_parent_object_id        => l_rj_gen_object_id,
                                                            p_parent_object_number    => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).wip_entity_name,
                                                            p_parent_inventory_item_id=> p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).primary_item_id,
                                                            p_parent_org_id           => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).organization_id,

                                                            p_genealogy_origin        => 3,  -- for WIP parent
                                                            p_genealogy_type          => 4,  -- for WIP/Inv Split/Merge/Translate
                                                            p_origin_txn_id           => p_wltx_header.transaction_id,

                                                            x_return_status           =>l_ret_status,
                                                            x_msg_count               =>l_msg_count,
                                                            x_msg_data                =>l_msg_data
                                                            );
						end if;

                        if l_sj_gen_object_id = l_rj_gen_object_id then
                            l_ret_status := 'S';
                        end if;
						--Bug 5367218:END.
                        l_stmt_num := 374;
                        IF (l_ret_status = 'S') THEN
                            if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'inv_genealogy_pub.insert_genealogy returned success',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                            End if;
                        ELSE
                            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'inv_genealogy_pub.insert_genealogy failed',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                            END IF;

                            l_stmt_num := 375;
                            IF (l_msg_count = 1)  THEN
                                l_err_code := -1;
                                l_err_buf := 'Error in inv_genealogy_pub.insert_genealogy: '||l_msg_data;
                            ELSE
                                FOR i IN 1..l_msg_count LOOP
                                    l_err_code := -1;
                                    l_err_buf := fnd_msg_pub.get;
                                END LOOP;

                                l_err_buf := 'Multiple errors in inv_genealogy_pub.insert_genealogy - populated in the log file';

                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                end loop;

        end if;

        l_stmt_num := 380;

        Insert_MMT_record (   p_txn_id                          => p_wltx_header.transaction_id,
                              p_txn_org_id                      => p_txn_org_id,
                              p_txn_date                        => p_wltx_header.transaction_date,--sysdate, --l_txn_date,
                              p_txn_type_id                     => p_wltx_header.transaction_type_id,
                              p_sj_wip_entity_id                => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                              p_sj_wip_entity_name              => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_name,
                              p_sj_avail_quantity               => p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available,
                              p_rj_wip_entity_id                => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).wip_entity_id,
                              p_rj_wip_entity_name              => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).wip_entity_name,
                              p_rj_start_quantity               => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first).start_quantity,
                              p_sj_item_id                      => p_wltx_starting_jobs_tbl(l_rep_sj_index).primary_item_id,
                              p_sj_op_seq_num                   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                              x_return_status                   => l_ret_status,
                              x_msg_count                       => l_msg_count,
                              x_msg_data                        => l_msg_data
                          );

        l_stmt_num := 390;

        if l_ret_status <> fnd_api.g_ret_sts_success then
                -- error out...
                l_stmt_num := 395;
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Insert_MMT_record failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 400;


        l_txn_status := WIP_CONSTANTS.COMPLETED;
        l_txn_costed := WIP_CONSTANTS.pending;

  elsif p_wltx_header.transaction_type_id in (WSMPCNST.UPDATE_ASSEMBLY,WSMPCNST.UPDATE_ROUTING) then

        l_stmt_num := 500;
        l_err_code := 0;
        l_err_buf  := null;

        UPDATE_ASSEMBLY_OR_ROUTING( p_txn_id                    => null,
                                    p_txn_type_id               => p_wltx_header.transaction_type_id,
                                    -- p_rep_wip_entity_id      => p_wltx_resulting_jobs_tbl(l_job_counter).wip_entity_id,
                                    p_job_kanban_card_id        => p_wltx_starting_jobs_tbl(p_wltx_starting_jobs_tbl.first).kanban_card_id,
                                    p_po_creation_time          => l_po_creation_time,
                                    p_sj_compl_subinventory     => p_wltx_starting_jobs_tbl(p_wltx_starting_jobs_tbl.first).completion_subinventory,
                                    p_sj_compl_locator_id       => p_wltx_starting_jobs_tbl(p_wltx_starting_jobs_tbl.first).completion_locator_id,
                                    p_rj_job_rec                => p_wltx_resulting_jobs_tbl(p_wltx_resulting_jobs_tbl.first),
                                    p_request_id                => g_request_id,
                                    x_err_code                  => l_err_code,
                                    x_err_buf                   => l_err_buf ,
                                    x_msg_count                 => x_msg_count
                                  );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'UPDATE_ASSEMBLY_OR_ROUTING failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 510;
        l_err_code := 0;
        l_err_buf  := null;

        CREATE_COPIES_OR_SET_COPY_DATA (p_txn_id                        => null,
                                        p_txn_type_id                   => p_wltx_header.transaction_type_id,
                                        p_copy_mode                     => WSMPJUPD.g_copy_mode,
                                        p_rep_sj_index                  => p_wltx_starting_jobs_tbl.first,
                                        p_sj_as_rj_index                => p_wltx_resulting_jobs_tbl.first,
                                        p_wltx_starting_jobs_tbl        => p_wltx_starting_jobs_tbl,
                                        p_wltx_resulting_jobs_tbl       => p_wltx_resulting_jobs_tbl,
                                        x_err_code                      => l_err_code,
                                        x_err_buf                       => l_err_buf,
                                        x_msg_count                     => x_msg_count
                                        );
        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'CREATE_COPIES_OR_SET_COPY_DATA failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        process_mes_info (  p_secondary_qty_tbl         => p_secondary_qty_tbl,
                            p_wltx_header               => p_wltx_header,
                            p_wltx_starting_jobs_tbl    => p_wltx_starting_jobs_tbl,
                            p_wltx_resulting_jobs_tbl   => p_wltx_resulting_jobs_tbl,
                            p_sj_also_rj_index          => p_wltx_resulting_jobs_tbl.first,
                            p_rep_job_index             => p_wltx_starting_jobs_tbl.first,
                            x_return_status             => x_return_status  ,
                            x_msg_count                 => x_msg_count      ,
                            x_error_msg                 => x_error_msg
                         );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSE
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        l_txn_status := WIP_CONSTANTS.COMPLETED;
        l_txn_costed := WIP_CONSTANTS.COMPLETED;


    elsif p_wltx_header.transaction_type_id = WSMPCNST.UPDATE_QUANTITY then

        l_stmt_num := 520;
        l_err_code := 0;
        l_err_buf  := null;

        l_rep_sj_index := p_wltx_starting_jobs_tbl.first;
        l_rj_index := p_wltx_resulting_jobs_tbl.first;

        l_sj_we_id_tbl(l_rep_sj_index)            := p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;
        l_sj_new_qty_tbl(l_rep_sj_index)          := p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity;
        l_sj_new_net_qty_tbl(l_rep_sj_index)      := p_wltx_resulting_jobs_tbl(l_rj_index).net_quantity;
        l_sj_op_seq_tbl(l_rep_sj_index)           := p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num;

        l_sj_old_st_qty_tbl(l_rep_sj_index)       := p_wltx_starting_jobs_tbl(l_rep_sj_index).start_quantity;
        l_sj_avail_qty_tbl(l_rep_sj_index)        := p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available;
        l_sj_scrap_qty_tbl(l_rep_sj_index)        := p_wltx_starting_jobs_tbl(l_rep_sj_index).start_quantity - p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available;

        -- change the quantity
        CHANGE_QUANTITY(  p_txn_id                => null,
                          p_txn_type              => WSMPCNST.UPDATE_QUANTITY,
                          p_wip_entity_id_tbl     => l_sj_we_id_tbl,
                          p_new_job_qty_tbl       => l_sj_new_qty_tbl,
                          p_new_net_qty_tbl       => l_sj_new_net_qty_tbl,

                          p_txn_job_op_seq_tbl    => l_sj_op_seq_tbl,
                          p_txn_job_intraop       => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,

                          p_sj_st_qty_tbl         => l_sj_old_st_qty_tbl,
                          p_sj_avail_qty_tbl      => l_sj_avail_qty_tbl,
                          p_sj_scrap_qty_tbl      => l_sj_scrap_qty_tbl,

                          x_err_code              => l_err_code,
                          x_err_buf               => l_err_buf
                        );

        IF (l_err_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'CHANGE_QUANTITY failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- end processing the starting jobs....
        l_stmt_num := 530;
        l_err_code := 0;
        l_err_buf  := null;

        -- no no no-rep jobs for update qty...
        l_non_rep_sj_tbl.delete;
        l_new_rj_we_id_tbl.delete;
        l_new_rj_qty_tbl.delete;

        UPDATE_QTY_ISSUED(p_txn_id                      => null,
                          p_txn_type                    => WSMPCNST.UPDATE_QUANTITY,
                          p_rep_we_id                   => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                          p_rep_op_seq_num              => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                          p_rep_avail_qty               => p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available,
                          p_rep_new_job_qty             => p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity,
                          p_txn_job_intraop             => p_wltx_starting_jobs_tbl(l_rep_sj_index).intraoperation_step,
                          p_non_rep_sj_we_id_tbl        => l_non_rep_sj_tbl,
                          p_new_rj_we_id_tbl            => l_new_rj_we_id_tbl,
                          p_new_rj_start_qty            => l_new_rj_qty_tbl,
                          x_err_code                    => l_err_code,
                          x_err_buf                     => l_err_buf
                         );

        if l_err_code <> 0 then
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'UPDATE_QTY_ISSUED failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_kanban_card_id := p_wltx_starting_jobs_tbl(l_rep_sj_index).kanban_card_id;

        -- nw comes the Kanban card id and the completion subinv. updation part....
        -- if the starting job has a
        if l_kanban_card_id is not null then

                l_stmt_num  := 115;

                -- now check if the resulting job has changed
                l_err_code := 0;
                l_err_buf  := null;

                l_sub_loc_change := handle_kanban_sub_loc_change(  p_wip_entity_id                      => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                                   p_kanban_card_id                     => p_wltx_starting_jobs_tbl(l_rep_sj_index).kanban_card_id,
                                                                   p_wssj_completion_subinventory       => p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_subinventory,
                                                                   p_wssj_completion_locator_id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).completion_locator_id,
                                                                   p_wsrj_completion_subinventory       => p_wltx_resulting_jobs_tbl(l_rj_index).completion_subinventory,
                                                                   p_wsrj_completion_locator_id         => p_wltx_resulting_jobs_tbl(l_rj_index).completion_locator_id,
                                                                   x_err_code                           => l_err_code,
                                                                   x_err_msg                            => l_err_buf
                                                                );

                IF (l_err_code <> 0) THEN
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'handle_kanban_sub_loc_change failed',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- indicates that the compl. subinv has changed hence remove the link to the kanban card id...
                if l_sub_loc_change <> 0 then
                        l_kanban_card_id := null;
                end if;

                if l_sub_loc_change = 0 then -- reflect the updated quantity in the card

                        l_stmt_num := 147;

                        INV_Kanban_PVT.Update_Card_Supply_Status(  x_return_status              => l_ret_Status,
                                                                   p_Kanban_Card_Id             => l_kanban_card_id,
                                                                   p_Supply_Status              => INV_Kanban_PVT.G_Supply_Status_InProcess,
                                                                   p_Document_type              => inv_kanban_pvt.G_Doc_type_lot_job,
                                                                   p_Document_Header_Id         => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                                   p_Document_detail_Id         => '',
                                                                   p_replenish_quantity         => p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity
                                                                 );

                        if ( l_ret_Status <> fnd_api.g_ret_sts_success ) then

                                --x_err_code := -1;
                                fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');
                                fnd_message.set_token('STATUS',g_translated_meaning);
                                --x_err_buf := fnd_message.get;
                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'STATUS';
                                        l_msg_tokens(1).TokenValue := g_translated_meaning;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_KNBN_CARD_STS_FAIL',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;

                        end if;

                        l_stmt_num := 150;
                end if;

        end if;

        l_stmt_num := 155;

        -- update the completion subinv and the kanban card id ....
        update wip_discrete_jobs
        SET     completion_subinventory  = p_wltx_resulting_jobs_tbl(l_rj_index).completion_subinventory,
                completion_locator_id    = p_wltx_resulting_jobs_tbl(l_rj_index).completion_locator_id,
                kanban_card_id           = l_kanban_card_id
        where wip_entity_id = p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;

        l_stmt_num := 158;

        IF (WSMPUTIL.check_osp_operation(p_wip_entity_id        => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                         p_operation_seq_num    => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                                         p_organization_id      => p_wltx_starting_jobs_tbl(l_rep_sj_index).organization_id
                                         )
           )
        THEN

                  WSMPJUPD.g_osp_exists := 1;

                  if (l_po_creation_time <>  WIP_CONSTANTS.MANUAL_CREATION) then

                      l_stmt_num := 253;

                      wip_osp.create_additional_req (  P_Wip_Entity_Id          => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                       P_Organization_id        => p_wltx_starting_jobs_tbl(l_rep_sj_index).organization_id,
                                                       P_Repetitive_Schedule_Id => null,
                                                       P_Added_Quantity         => (p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity-p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available),
                                                       P_Op_Seq                 => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num
                                                    );

                      --if l_request_id is null means online processing so launch import req

                      if (g_request_id is null) then

                          l_po_request_id := fnd_request.submit_request('PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, 'ITEM',
                                                                      NULL,'N', 'Y', chr(0), NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                                                                    );
                          -- submitted : l_po_request_id

                      end if;
                  end if;
        END IF;
        --osp end

        -- call to infinite schedule....
        IF (WSMPJUPD.g_copy_mode = 0) THEN
                null; -- no copies
        ELSE
                l_stmt_num := 540;
                l_err_code := 0;
                l_err_buf  := null;

                CALL_INF_SCH_OR_SET_SCH_DATA(  p_txn_id         => null,
                                               p_copy_mode      => WSMPJUPD.g_copy_mode,
                                               p_org_id         => p_txn_org_id,
                                               p_par_we_id      => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                               x_err_code       => l_err_code,
                                               x_err_buf        => l_err_buf
                                             );

                IF (l_err_code <> 0) THEN
                     -- error out...
                     IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'CALL_INF_SCH_OR_SET_SCH_DATA returned failure:'||l_err_code,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
        end if;

        l_stmt_num := 590;

        process_mes_info ( p_secondary_qty_tbl          => p_secondary_qty_tbl,
                           p_wltx_header                => p_wltx_header,
                           p_wltx_starting_jobs_tbl     => p_wltx_starting_jobs_tbl,
                           p_wltx_resulting_jobs_tbl    => p_wltx_resulting_jobs_tbl,
                           p_sj_also_rj_index           => p_wltx_resulting_jobs_tbl.first,
                           p_rep_job_index              => p_wltx_starting_jobs_tbl.first,
                           x_return_status              => x_return_status  ,
                           x_msg_count                  => x_msg_count      ,
                           x_error_msg                  => x_error_msg
                         );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSE
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        -- p_txn_id should be known here....
        -- call to insert MMT....
        l_ret_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data := null;

        Insert_MMT_record (   p_txn_id                          => p_wltx_header.transaction_id,
                              p_txn_org_id                      => p_txn_org_id,
                              p_txn_date                        => sysdate, --l_txn_date, /* has to be txn date... */
                              p_txn_type_id                     => WSMPCNST.update_quantity,
                              p_sj_wip_entity_id                => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                              p_sj_wip_entity_name              => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_name,
                              p_sj_avail_quantity               => p_wltx_starting_jobs_tbl(l_rep_sj_index).quantity_available,
                              p_rj_wip_entity_id                => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id,
                              p_rj_wip_entity_name              => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
                              p_rj_start_quantity               => p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity,
                              p_sj_item_id                      => p_wltx_starting_jobs_tbl(l_rep_sj_index).primary_item_id,
                              p_sj_op_seq_num                   => p_wltx_starting_jobs_tbl(l_rep_sj_index).operation_seq_num,
                              x_return_status                   => l_ret_status,
                              x_msg_count                       => l_msg_count,
                              x_msg_data                        => l_msg_data
                          );

        l_stmt_num := 390;

        if l_ret_status <> fnd_api.g_ret_sts_success then
                -- error out...
                l_stmt_num := 395;
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Insert_MMT_record failed',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 400;


        l_txn_status := WIP_CONSTANTS.COMPLETED;
        l_txn_costed := WIP_CONSTANTS.pending;

    elsif p_wltx_header.transaction_type_id = WSMPCNST.UPDATE_LOT_NAME then

        l_stmt_num := 550;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Transaction type is Update Lotname:',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_rep_sj_index := p_wltx_starting_jobs_tbl.first;
        l_rj_index := p_wltx_resulting_jobs_tbl.first;

        if p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id is null then

                if p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id is not null then
                        p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id := p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id;
                else
                        select wip_entity_id
                        into p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id
                        from wip_entities
                        where wip_entity_name like p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_name;
                end if;
        end if;

        l_stmt_num := 560;

        update wip_discrete_jobs
        set    lot_number       = p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
               description      = p_wltx_resulting_jobs_tbl(l_rj_index).description,
               /* Start Bugfix 5531371 csi/loc is updatable in upd lot name */
               completion_subinventory = p_wltx_resulting_jobs_tbl(l_rj_index).completion_subinventory,
               completion_locator_id = p_wltx_resulting_jobs_tbl(l_rj_index).completion_locator_id
               /* End Bugfix 5531371*/
        where  wip_entity_id    = p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id;

        l_stmt_num := 570;

        update wip_entities
        set    wip_entity_name  = p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
               description      = p_wltx_resulting_jobs_tbl(l_rj_index).description
        where  wip_entity_id    = p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id;

        l_txn_status := WIP_CONSTANTS.COMPLETED;
        l_txn_costed := WIP_CONSTANTS.COMPLETED;

  elsif p_wltx_header.transaction_type_id = WSMPCNST.BONUS then
        if  p_wltx_resulting_jobs_tbl.count > 0 then
                l_rj_index := p_wltx_resulting_jobs_tbl.first;
        else
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        end if;

        l_bonus_rtg_st_op_seq := p_wltx_resulting_jobs_tbl(l_rj_index).starting_operation_seq_num;

        l_stmt_num      := 55;
        l_err_code := 0;
        l_err_buf  := null;
        --remove this
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSMPLBJI.build_lbji_info procedure'||p_wltx_resulting_jobs_tbl(l_rj_index).class_code,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

                -- Create Job Header ONLY
        WSMPLBJI.build_lbji_info
                    (p_routing_seq_id          => p_wltx_resulting_jobs_tbl(l_rj_index).common_routing_sequence_id,
                     p_common_bill_sequence_id => p_wltx_resulting_jobs_tbl(l_rj_index).common_bom_sequence_id,
                     p_explode_header_detail   => null,
                     p_status_type             => WIP_CONSTANTS.RELEASED,
                     p_class_code              => p_wltx_resulting_jobs_tbl(l_rj_index).class_code,
                     p_org                     => p_wltx_resulting_jobs_tbl(l_rj_index).organization_id,
                     p_wip_entity_id           => l_new_we_id, -- this is returned by the API
                     p_last_updt_date          => sysdate,
                     p_last_updt_by            => g_user_id,
                     p_creation_date           => sysdate,
                     p_created_by              => g_user_id,
                     p_last_updt_login         => g_user_login_id,
                     p_request_id              => g_request_id,
                     p_program_application_id  => g_program_appl_id,
                     p_program_id              => g_program_id,
                     p_prog_updt_date          => sysdate,
                     p_source_line_id          => NULL,
                     p_source_code             => NULL,
                     p_description             => p_wltx_resulting_jobs_tbl(l_rj_index).description,
                     p_item                    => p_wltx_resulting_jobs_tbl(l_rj_index).primary_item_id,
                     p_job_type                => p_wltx_resulting_jobs_tbl(l_rj_index).job_type,
                     p_bom_reference_id        => p_wltx_resulting_jobs_tbl(l_rj_index).bom_reference_id,
                     p_routing_reference_id    => p_wltx_resulting_jobs_tbl(l_rj_index).routing_reference_id,
                     p_firm_planned_flag       => 2,
                     p_wip_supply_type         => p_wltx_resulting_jobs_tbl(l_rj_index).wip_supply_type,
                     p_fusd                    => p_wltx_resulting_jobs_tbl(l_rj_index).scheduled_start_date,
                     p_lucd                    => p_wltx_resulting_jobs_tbl(l_rj_index).scheduled_completion_date,
                     p_start_quantity          => p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity,
                     p_net_quantity            => p_wltx_resulting_jobs_tbl(l_rj_index).net_quantity,
                     p_coproducts_supply       => p_wltx_resulting_jobs_tbl(l_rj_index).coproducts_supply,
                     p_bom_revision            => p_wltx_resulting_jobs_tbl(l_rj_index).bom_revision,
                     p_routing_revision        => p_wltx_resulting_jobs_tbl(l_rj_index).routing_revision,
                     p_bom_revision_date       => p_wltx_resulting_jobs_tbl(l_rj_index).bom_revision_date,
                     p_routing_revision_date   => p_wltx_resulting_jobs_tbl(l_rj_index).routing_revision_date,
                     p_lot_number              => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
                     p_alt_bom_designator      => p_wltx_resulting_jobs_tbl(l_rj_index).alternate_bom_designator,
                     p_alt_routing_designator  => p_wltx_resulting_jobs_tbl(l_rj_index).alternate_routing_designator,
                     p_priority                => NULL,
                     p_due_date                => NULL,

                     p_attribute_category      => p_wltx_resulting_jobs_tbl(l_rj_index).attribute_category,
                     p_attribute1              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute1,
                     p_attribute2              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute2,
                     p_attribute3              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute3,
                     p_attribute4              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute4,
                     p_attribute5              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute5,
                     p_attribute6              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute6,
                     p_attribute7              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute7,
                     p_attribute8              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute8,
                     p_attribute9              => p_wltx_resulting_jobs_tbl(l_rj_index).attribute9,
                     p_attribute10             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute10,
                     p_attribute11             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute11,
                     p_attribute12             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute12,
                     p_attribute13             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute13,
                     p_attribute14             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute14,
                     p_attribute15             => p_wltx_resulting_jobs_tbl(l_rj_index).attribute15,

                     p_job_name                => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
                     p_completion_subinventory => p_wltx_resulting_jobs_tbl(l_rj_index).completion_subinventory,
                     p_completion_locator_id   => p_wltx_resulting_jobs_tbl(l_rj_index).completion_locator_id,
                     p_demand_class            => null,
                     p_project_id              => NULL,
                     p_task_id                 => NULL,
                     p_schedule_group_id       => NULL,
                     p_build_sequence          => NULL,
                     p_line_id                 => NULL,
                     p_kanban_card_id          => NULL,
                     p_overcompl_tol_type      => NULL,
                     p_overcompl_tol_value     => NULL,
                     p_end_item_unit_number    => NULL,
                     p_rtg_op_seq_num          => p_wltx_resulting_jobs_tbl(l_rj_index).starting_operation_seq_num,
                     p_src_client_server       => 1,
                     p_po_creation_time        => l_po_creation_time,
                     p_date_released           => p_wltx_header.transaction_date, --bug 4101117
                     p_error_code              => l_err_code,
                     p_error_msg               => l_err_buf
                 );

        l_stmt_num      := 70;

        IF (l_err_code <> 0) THEN
            --remove this
            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           =>  'Returned failure from WSMPLBJI.build_lbji_info procedure'||l_err_buf,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- success... now the program would have returned the id ....
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returned successfully from WSMPLBJI.build_lbji_info procedure',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;
            p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id := l_new_we_id;
        END IF;


        /*call creat wsor_wlbj_records*/
        l_stmt_num      := 80;
        l_err_code := 0;
        l_err_buf  := null;

        CREATE_WSOR_WLBJ_RECORDS(   p_wip_entity_id         => l_new_we_id,
                                    p_org_id                => p_wltx_resulting_jobs_tbl(l_rj_index).organization_id,
                                    p_only_wo_op_seq        => p_wltx_resulting_jobs_tbl(l_rj_index).starting_operation_seq_num, -- Create only this record
                                    p_last_update_date      => sysdate,
                                    p_last_updated_by       => g_user_id,
                                    p_last_update_login     => g_user_login_id,
                                    p_creation_date         => sysdate,
                                    p_created_by            => g_user_id,
                                    p_request_id            => g_request_id,
                                    p_program_app_id        => g_program_appl_id,
                                    p_program_id            => g_program_id,
                                    p_program_update_date   => sysdate,
                                    x_err_code              => l_err_code,
                                    x_err_buf               => l_err_buf
                                );


        IF (l_err_code <> 0) THEN
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Returned failure from CREATE_WSOR_WLBJ_RECORDS',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        ELSE
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Created WSOR records for new job with id='||l_new_we_id,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;
        END IF;

        l_stmt_num      := 90;

        /* assign the job seq num*/
        SELECT max(operation_seq_num)
        INTO   l_bonus_job_st_op_seq
        FROM   wip_operations
        WHERE  wip_entity_id = l_new_we_id;

        p_wltx_resulting_jobs_tbl(l_rj_index).job_operation_seq_num := l_bonus_job_st_op_seq;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Updated the job seq num in resulting job record : ' || l_bonus_job_st_op_seq,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_stmt_num      := 100;
        UPDATE  wip_operations
        SET     wsm_op_seq_num = l_bonus_rtg_st_op_seq
        WHERE   wip_entity_id = l_new_we_id
        AND     operation_seq_num = l_bonus_job_st_op_seq;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Updated the op seq num in wip_operations',
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        /*insert into WLBJ here as not handled in new CREATE_WSOR_WLBJ_RECORDS,the new MES columns are also handled here*/
        l_stmt_num:=105;

       INSERT into WSM_LOT_BASED_JOBS
              (WIP_ENTITY_ID,
               ORGANIZATION_ID,
               ON_REC_PATH,
               INTERNAL_COPY_TYPE,
               COPY_PARENT_WIP_ENTITY_ID,
               INFINITE_SCHEDULE,
               CURRENT_JOB_OP_SEQ_NUM, --MES add
               CURRENT_RTG_OP_SEQ_NUM, --MES add
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE
              )
          VALUES
              (p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id,
               p_wltx_resulting_jobs_tbl(l_rj_index).organization_id,
               'Y',   -- ON_REC_PATH
               0,
               NULL,  -- COPY_PARENT_WIP_ENTITY_ID
               NULL,  -- INFINITE_SCHEDULE
               p_wltx_resulting_jobs_tbl(l_rj_index).job_operation_seq_num,
               p_wltx_resulting_jobs_tbl(l_rj_index).starting_operation_seq_num,
               sysdate,
               g_user_id,
               g_user_login_id,
               sysdate,
               g_user_id,
               g_request_id,
               g_program_appl_id,
               g_program_id,
               sysdate
              );

        l_stmt_num      := 110;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Checking for open a/c period',
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        /*check for open accounting period*/
        l_stmt_num      := 120;
        l_acct_period_id := -1;
        l_err_code := -1;
        l_err_buf := null;

        l_acct_period_id := WSMPUTIL.GET_INV_ACCT_PERIOD(l_err_code, l_err_buf, p_wltx_resulting_jobs_tbl(l_rj_index).organization_id, p_wltx_header.transaction_date);

        IF (l_err_code <> 0) THEN
                /*error out*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Accounting Period not open',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num      := 130;
        l_ret_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_count     := 0;
        l_msg_data      := null;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Inserting MMT record',
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        Insert_MMT_record (   p_txn_id                          => p_wltx_header.transaction_id,
                              p_txn_org_id                      => p_wltx_resulting_jobs_tbl(l_rj_index).organization_id,
                              p_txn_date                        => p_wltx_header.transaction_date,--sysdate, --l_txn_date,
                              p_txn_type_id                     => p_wltx_header.transaction_type_id,
                              p_sj_wip_entity_id                => null,
                              p_sj_wip_entity_name              => null,
                              p_sj_avail_quantity               => null,
                              p_rj_wip_entity_id                => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_id,
                              p_rj_wip_entity_name              => p_wltx_resulting_jobs_tbl(l_rj_index).wip_entity_name,
                              p_rj_start_quantity               => p_wltx_resulting_jobs_tbl(l_rj_index).start_quantity,
                              p_sj_item_id                      => p_wltx_resulting_jobs_tbl(l_rj_index).primary_item_id,
                              p_sj_op_seq_num                   => p_wltx_resulting_jobs_tbl(l_rj_index).starting_operation_seq_num,
                              x_return_status                   => l_ret_status,
                              x_msg_count                       => l_msg_count,
                              x_msg_data                        => l_msg_data
                          );
        if l_ret_status <> fnd_api.g_ret_sts_success then
                -- error out...
                l_stmt_num := 395;
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Insert_MMT_record failed:'||l_msg_data,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 140;
        l_err_code := 0;
        l_err_buf  := null;

        CREATE_COPIES_OR_SET_COPY_DATA (p_txn_id                        => null,
                                        p_txn_type_id                   => p_wltx_header.transaction_type_id,
                                        p_copy_mode                     => WSMPJUPD.g_copy_mode,
                                        p_rep_sj_index                  => null,
                                        p_sj_as_rj_index                => l_rj_index,
                                        p_wltx_starting_jobs_tbl        => p_wltx_starting_jobs_tbl,
                                        p_wltx_resulting_jobs_tbl       => p_wltx_resulting_jobs_tbl,
                                        x_err_code                      => l_err_code,
                                        x_err_buf                       => l_err_buf,
                                        x_msg_count                     => x_msg_count
                                       );

        IF (l_err_code <> 0) THEN
                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'CREATE_COPIES_OR_SET_COPY_DATA returned failure ' || l_err_buf,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;  --x_err_code has errcode, x_err_buf has the error message
        END IF;

        -- Begin MES changes
        -- Commented out due to insufficient data in sec qty table due to which txns r failing-to be uncommented

        l_stmt_num := 150;

        process_mes_info (     p_secondary_qty_tbl              => p_secondary_qty_tbl,
                               p_wltx_header                    => p_wltx_header,
                               p_wltx_starting_jobs_tbl         => p_wltx_starting_jobs_tbl,
                               p_wltx_resulting_jobs_tbl        => p_wltx_resulting_jobs_tbl,
                               p_sj_also_rj_index               => null,
                               p_rep_job_index                  => null,
                               x_return_status                  => x_return_status  ,
                               x_msg_count                      => x_msg_count      ,
                               x_error_msg                      => x_error_msg
                          );
        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSE
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        -- End MES changes--
        l_stmt_num := 400;

        l_txn_status := WIP_CONSTANTS.COMPLETED;
        l_txn_costed := WIP_CONSTANTS.pending;

    else
        -- error out....
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Invalid Txn type',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
        END IF;
        raise FND_API.G_EXC_ERROR;
    end if;


    l_stmt_num := 500;
    --Start Sales Order LBJ Reservation Changes -- (Commented out as waiting for INV Changes
    If p_wltx_header.transaction_type_id in (WSMPCNST.SPLIT,WSMPCNST.UPDATE_ASSEMBLY,
                 WSMPCNST.UPDATE_QUANTITY,WSMPCNST.UPDATE_ROUTING,WSMPCNST.UPDATE_LOT_NAME) then
        l_rep_sj_index := p_wltx_starting_jobs_tbl.first;
        l_rsv_exists := WSM_RESERVATIONS_PVT.check_reservation_exists(p_wip_entity_id      => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                                      P_org_id             => p_wltx_header.organization_id,
                                                                      P_inventory_item_id  => p_wltx_starting_jobs_tbl(l_rep_sj_index).primary_item_id
                                                                      ) ;
        If l_rsv_exists then
              l_stmt_num := 510;
              If p_wltx_header.transaction_type_id in (WSMPCNST.UPDATE_QUANTITY,WSMPCNST.UPDATE_ROUTING,WSMPCNST.UPDATE_LOT_NAME) then
                     l_rj_index := p_wltx_resulting_jobs_tbl.first;
                     l_stmt_num := 520;
                     l_ret_status := FND_API.G_RET_STS_SUCCESS;
                     l_msg_count     := 0;
                     l_msg_data     := null;
                     WSM_RESERVATIONS_PVT.Modify_reservations_jobupdate(p_wip_entity_id              => p_wltx_starting_jobs_tbl(l_rep_sj_index).wip_entity_id,
                                                     P_old_net_qty           => p_wltx_starting_jobs_tbl(l_rep_sj_index).net_quantity,
                                                     P_new_net_qty           => p_wltx_resulting_jobs_tbl(l_rj_index).net_quantity,
                                                     P_inventory_item_id     => p_wltx_starting_jobs_tbl(l_rep_sj_index).primary_item_id,
                                                     P_org_id                => p_wltx_header.organization_id,
                                                     P_status_type           => p_wltx_resulting_jobs_tbl(l_rj_index).status_type,
                                                     x_return_status         => l_ret_status,
                                                     x_msg_count             => l_msg_count,
                                                     x_msg_data              => l_msg_data
                                                     ); --this is to handle the change in net qty if any.

                     if l_ret_status <> fnd_api.g_ret_sts_success then
                             -- error out...

                             if( g_log_level_statement   >= l_log_level ) then

                                             l_msg_tokens.delete;
                                             WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                    p_msg_text           => 'WSM_RESERVATIONS_PVT.Modify_reservations_jobupdate failed:'||l_msg_data,
                                                                    p_stmt_num           => l_stmt_num               ,
                                                                    p_msg_tokens         => l_msg_tokens,
                                                                    p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                    p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                    p_run_log_level      => l_log_level
                                                                   );
                             END IF;
                             RAISE FND_API.G_EXC_ERROR;
                    END IF;
              Else
                     --Split,SpUA and Update Assembly transaction
                     l_stmt_num      := 530;
                     l_ret_status    := FND_API.G_RET_STS_SUCCESS;
                     l_msg_count     := 0;
                     l_msg_data      := null;
                     WSM_RESERVATIONS_PVT.modify_reservations_wlt (
                                             p_txn_header            => p_wltx_header,
                                             p_starting_jobs_tbl     => p_wltx_starting_jobs_tbl,
                                             p_resulting_jobs_tbl    => p_wltx_resulting_jobs_tbl,
                                             p_rep_job_index         => 1,--l_ rep_job_index,
                                             p_sj_also_rj_index      => l_sj_also_rj_index,
                                              x_return_status         => l_ret_status,
                                              x_msg_count             => l_msg_count,
                                              x_msg_data              => l_msg_data) ;
                      if l_ret_status <> fnd_api.g_ret_sts_success then
                              -- error out...
                              if( g_log_level_statement   >= l_log_level ) then

                                              l_msg_tokens.delete;
                                              WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                     p_msg_text           => 'WSM_RESERVATIONS_PVT.modify_reservations_wlt failed:'||l_msg_data,
                                                                     p_stmt_num           => l_stmt_num               ,
                                                                     p_msg_tokens         => l_msg_tokens,
                                                                     p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                     p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                     p_run_log_level      => l_log_level
                                                                    );
                              END IF;
                              --To be reverted
                              RAISE FND_API.G_EXC_ERROR;
                      end if;
              End if;
         End if;
    elsif p_wltx_header.transaction_type_id in (WSMPCNST.MERGE) then
             l_stmt_num      := 540;
             l_ret_status    := FND_API.G_RET_STS_SUCCESS;
             l_msg_count     := 0;
             l_msg_data      := null;
             WSM_RESERVATIONS_PVT.modify_reservations_wlt (
                                                     p_txn_header            => p_wltx_header,
                                                     p_starting_jobs_tbl     => p_wltx_starting_jobs_tbl,
                                                     p_resulting_jobs_tbl    => p_wltx_resulting_jobs_tbl,
                                                     p_rep_job_index         => l_rep_sj_index,
                                                     p_sj_also_rj_index      => l_sj_also_rj_index,
                                                     x_return_status         => l_ret_status,
                                                     x_msg_count             => l_msg_count,
                                                     x_msg_data              => l_msg_data) ;
                     if l_ret_status <> fnd_api.g_ret_sts_success then
                             -- error out...
                             l_stmt_num := 200;
                             if( g_log_level_statement   >= l_log_level ) then

                                             l_msg_tokens.delete;
                                             WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                    p_msg_text           => 'WSM_RESERVATIONS_PVT.modify_reservations_wlt failed:'||l_msg_data,
                                                                    p_stmt_num           => l_stmt_num               ,
                                                                    p_msg_tokens         => l_msg_tokens,
                                                                    p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                    p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                    p_run_log_level      => l_log_level
                                                                   );
                             END IF;
                             --To be reverted
                             --RAISE FND_API.G_EXC_ERROR;
                     end if;
     End if;
     --End Sales Order LBJ Reservation Changes--

    -- to take care of phantoms...
    DELETE FROM BOM_EXPLOSION_TEMP
    WHERE GROUP_ID = WSMPWROT.EXPLOSION_GROUP_ID;

    WSMPWROT.EXPLOSION_GROUP_ID := NULL;
    WSMPWROT.USE_PHANTOM_ROUTINGS := NULL;
    -- end to take care of phantoms--

EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get ( p_encoded => 'F'       ,
                                            p_count => x_msg_count ,
                                            p_data => x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                               p_stmt_num               => l_stmt_num               ,
                                               p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                               p_run_log_level          => l_log_level
                                             );
                END IF;

                FND_MSG_PUB.Count_And_Get ( p_encoded => 'F'       ,
                                            p_count => x_msg_count ,
                                            p_data => x_error_msg
                                          );
        WHEN OTHERS THEN

                  x_return_status := G_RET_UNEXPECTED;

                  IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                     (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                  THEN
                          WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                     p_stmt_num               => l_stmt_num               ,
                                                     p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                     p_run_log_level          => l_log_level
                                                   );
                  END IF;

                  FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                             p_count      => x_msg_count  ,
                                             p_data       => x_error_msg
                                            );

end PROCESS_LOTS;

END WSMPJUPD;

/
