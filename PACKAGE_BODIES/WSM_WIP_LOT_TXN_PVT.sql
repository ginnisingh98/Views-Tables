--------------------------------------------------------
--  DDL for Package Body WSM_WIP_LOT_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_WIP_LOT_TXN_PVT" as
/* $Header: WSMVWIPB.pls 120.7 2006/08/03 23:48:01 nlal noship $ */

/* Package name  */
g_pkg_name             VARCHAR2(20) := 'WSM_WIP_LOT_TXN_PVT';

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

-- This procedure is added to log the transaction related data..(serial Numbers data is left out..)
Procedure Log_transaction_data ( p_txn_header_rec         IN            WLTX_TRANSACTIONS_REC_TYPE                      ,
                                 p_starting_jobs_tbl      IN            WLTX_STARTING_JOBS_TBL_TYPE                     ,
                                 p_resulting_jobs_tbl     IN            WLTX_RESULTING_JOBS_TBL_TYPE                    ,
                                 p_secondary_qty_tbl      IN            WSM_JOB_SECONDARY_QTY_TBL_TYPE                  ,
                                 x_return_status          OUT    NOCOPY VARCHAR2                                        ,
                                 x_msg_count              OUT    NOCOPY NUMBER                                          ,
                                 x_error_msg              OUT    NOCOPY VARCHAR2
                               )

IS

    -- Logging variables.....
    l_log_level                 number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_msg_tokens                WSM_log_PVT.token_rec_tbl;
    l_stmt_num                  NUMBER;
    l_module                    VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.Log_transaction_data';

    -- This assumption is based that each individual column to be logged doesnt exceed 3900 chars... (that's the max...)
    type t_log_message_tbl IS table OF varchar2(3900) index by binary_integer;

    --  MESSAGE_TEXT column in FND_LOG_MESSAGES is 4000 characters long..
    --  WSM_Log_PVT adds the date information in the start,,, so leave 50 characters for that
    --  Effective length we would use is 3900
    l_message_length            NUMBER := 3900;
    l_log_message               VARCHAR2(3900);

    l_message_tbl               t_log_message_tbl;
    l_counter                   NUMBER;
    l_index                     NUMBER;

BEGIN
        l_stmt_num      := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_msg_count     := 0;

        if( g_log_level_statement   >= l_log_level ) then

                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered Log_transaction_data procedure',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );

                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => '------> Transaction Header Information <---------',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
                l_message_tbl.delete;

                l_message_tbl(l_message_tbl.count+1) := 'Transaction Type ['        || p_txn_header_rec.transaction_type_id || '] ';
                l_message_tbl(l_message_tbl.count+1) := 'Transaction Date ['        || to_char(p_txn_header_rec.transaction_date,'DD-MON-YYYY HH24:MI:SS') ||  '] ';
                l_message_tbl(l_message_tbl.count+1) := 'Transaction Reference ['   || p_txn_header_rec.transaction_reference || '] ' ;
                l_message_tbl(l_message_tbl.count+1) := 'Reason_id ['               || p_txn_header_rec.reason_id           || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Transaction_id ['          || p_txn_header_rec.transaction_id      || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Employee_id ['             || p_txn_header_rec.employee_id         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Organization_code ['       || p_txn_header_rec.organization_code   || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Organization_id ['         || p_txn_header_rec.organization_id     || '] '   ;
                -- l_message_tbl(l_message_tbl.count+1) := 'Error_message ['           || p_txn_header_rec.error_message       || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute_category ['      || p_txn_header_rec.attribute_category  || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute1 ['              || p_txn_header_rec.attribute1          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute2 ['              || p_txn_header_rec.attribute2          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute3 ['              || p_txn_header_rec.attribute3          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute4 ['              || p_txn_header_rec.attribute4          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute5 ['              || p_txn_header_rec.attribute5          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute6 ['              || p_txn_header_rec.attribute6          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute7 ['              || p_txn_header_rec.attribute7          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute8 ['              || p_txn_header_rec.attribute8          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute9 ['              || p_txn_header_rec.attribute9          || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute10 ['             || p_txn_header_rec.attribute10         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute11 ['             || p_txn_header_rec.attribute11         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute12 ['             || p_txn_header_rec.attribute12         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute13 ['             || p_txn_header_rec.attribute13         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute14 ['             || p_txn_header_rec.attribute14         || '] '   ;
                l_message_tbl(l_message_tbl.count+1) := 'Attribute15 ['             || p_txn_header_rec.attribute15         || '] '   ;

                l_counter := l_message_tbl.first;
                l_log_message := null;

                while l_counter is not null loop

                        IF length(l_log_message || l_message_tbl(l_counter)) > 3900 THEN
                                -- Log the data in l_log_message...
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_log_message            ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_log_level      => g_log_level_statement    ,
                                                       p_run_log_level      => l_log_level
                                                      );
                                l_log_message := null;
                        END IF;

                        l_log_message := l_log_message || l_message_tbl(l_counter);
                        l_counter     := l_message_tbl.next(l_counter);

                end loop;

                -- Log the remainder data..
                IF l_log_message IS NOT NULL THEN
                        -- Log the data in l_log_message...
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => l_log_message            ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_log_level      => g_log_level_statement    ,
                                               p_run_log_level      => l_log_level
                                              );

                END IF;

                l_log_message := null;
                l_stmt_num      := 20;
                -- Log the starting jobs data....
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => '=========------> Starting Jobs Information <---------============',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_log_level      => g_log_level_statement    ,
                                       p_run_log_level      => l_log_level
                                      );
                l_index := p_starting_jobs_tbl.first;

                while l_index is not null loop

                        l_message_tbl.delete;

                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity id ['               || p_starting_jobs_tbl(l_index).wip_entity_id                                               || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity name ['             || p_starting_jobs_tbl(l_index).wip_entity_name                                             || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Job type ['                    || p_starting_jobs_tbl(l_index).job_type                                                    || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Status type ['                 || p_starting_jobs_tbl(l_index).status_type                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Description ['                 || p_starting_jobs_tbl(l_index).description                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Representative flag ['         || p_starting_jobs_tbl(l_index).representative_flag                                         || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Serial track flag ['           || p_starting_jobs_tbl(l_index).serial_track_flag                                           || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Class code ['                  || p_starting_jobs_tbl(l_index).class_code                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Demand class ['                || p_starting_jobs_tbl(l_index).demand_class                                                || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Organization code ['           || p_starting_jobs_tbl(l_index).organization_code                                           || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Primary item id ['             || p_starting_jobs_tbl(l_index).primary_item_id                                             || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Item name ['                   || p_starting_jobs_tbl(l_index).item_name                                                   || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Organization id ['             || p_starting_jobs_tbl(l_index).organization_id                                             || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Intraoperation step ['         || p_starting_jobs_tbl(l_index).intraoperation_step                                         || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Operation seq num ['           || p_starting_jobs_tbl(l_index).operation_seq_num                                           || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Operation code ['              || p_starting_jobs_tbl(l_index).operation_code                                              || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Operation description ['       || p_starting_jobs_tbl(l_index).operation_description                                       || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Operation seq id ['            || p_starting_jobs_tbl(l_index).operation_seq_id                                            || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Standard operation id ['       || p_starting_jobs_tbl(l_index).standard_operation_id                                       || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Department id ['               || p_starting_jobs_tbl(l_index).department_id                                               || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Department code ['             || p_starting_jobs_tbl(l_index).department_code                                             || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Start quantity ['              || p_starting_jobs_tbl(l_index).start_quantity                                              || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Quantity available ['          || p_starting_jobs_tbl(l_index).quantity_available                                          || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Net quantity ['                || p_starting_jobs_tbl(l_index).net_quantity                                                || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Routing reference id ['        || p_starting_jobs_tbl(l_index).routing_reference_id                                        || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Bom reference id ['            || p_starting_jobs_tbl(l_index).bom_reference_id                                            || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Common bill sequence id ['     || p_starting_jobs_tbl(l_index).common_bill_sequence_id                                     || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Bom revision ['                || p_starting_jobs_tbl(l_index).bom_revision                                                || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Bom revision date ['           || to_char(p_starting_jobs_tbl(l_index).bom_revision_date,'DD-MON-YYYY HH24:MI:SS')         || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Alternate bom designator ['    || p_starting_jobs_tbl(l_index).alternate_bom_designator                                    || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Alternate routing designator ['|| p_starting_jobs_tbl(l_index).alternate_routing_designator                                || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Common routing sequence id ['  || p_starting_jobs_tbl(l_index).common_routing_sequence_id                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Routing revision ['            || p_starting_jobs_tbl(l_index).routing_revision                                            || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Routing revision date ['       || to_char(p_starting_jobs_tbl(l_index).routing_revision_date,'DD-MON-YYYY HH24:MI:SS')     || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Completion subinventory ['     || p_starting_jobs_tbl(l_index).completion_subinventory                                     || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Completion locator id ['       || p_starting_jobs_tbl(l_index).completion_locator_id                                       || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Completion locator ['          || p_starting_jobs_tbl(l_index).completion_locator                                          || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Date released ['               || p_starting_jobs_tbl(l_index).date_released                                               || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Scheduled start date ['        || to_char(p_starting_jobs_tbl(l_index).scheduled_start_date,'DD-MON-YYYY HH24:MI:SS')      || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Scheduled completion date ['   || to_char(p_starting_jobs_tbl(l_index).scheduled_completion_date,'DD-MON-YYYY HH24:MI:SS') || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Coproducts supply ['           || p_starting_jobs_tbl(l_index).coproducts_supply                                           || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Kanban card id ['              || p_starting_jobs_tbl(l_index).kanban_card_id                                              || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Wip supply type ['             || p_starting_jobs_tbl(l_index).wip_supply_type                                             || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute category ['          || p_starting_jobs_tbl(l_index).attribute_category                                          || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute1 ['                  || p_starting_jobs_tbl(l_index).attribute1                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute2 ['                  || p_starting_jobs_tbl(l_index).attribute2                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute3 ['                  || p_starting_jobs_tbl(l_index).attribute3                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute4 ['                  || p_starting_jobs_tbl(l_index).attribute4                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute5 ['                  || p_starting_jobs_tbl(l_index).attribute5                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute6 ['                  || p_starting_jobs_tbl(l_index).attribute6                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute7 ['                  || p_starting_jobs_tbl(l_index).attribute7                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute8 ['                  || p_starting_jobs_tbl(l_index).attribute8                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute9 ['                  || p_starting_jobs_tbl(l_index).attribute9                                                  || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute10 ['                 || p_starting_jobs_tbl(l_index).attribute10                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute11 ['                 || p_starting_jobs_tbl(l_index).attribute11                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute12 ['                 || p_starting_jobs_tbl(l_index).attribute12                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute13 ['                 || p_starting_jobs_tbl(l_index).attribute13                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute14 ['                 || p_starting_jobs_tbl(l_index).attribute14                                                 || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute15 ['                 || p_starting_jobs_tbl(l_index).attribute15                                                 || '] ';

                        --
                        l_counter := l_message_tbl.first;
                        l_log_message := null;

                        while l_counter is not null loop

                                IF length(l_log_message || l_message_tbl(l_counter)) > 3900 THEN
                                        -- Log the data in l_log_message...
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => l_log_message            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_log_level      => g_log_level_statement    ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                        l_log_message := null;
                                END IF;

                                l_log_message := l_log_message || l_message_tbl(l_counter);
                                l_counter     := l_message_tbl.next(l_counter);

                        end loop;

                        -- Log the remainder data..
                        IF l_log_message IS NOT NULL THEN
                                -- Log the data in l_log_message...
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_log_message            ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_log_level      => g_log_level_statement    ,
                                                       p_run_log_level      => l_log_level
                                                      );

                        END IF;

                        l_index := p_starting_jobs_tbl.next(l_index);
                end loop;

                l_stmt_num      := 30;
                -- Log the starting jobs data....
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => '=========------> Resulting Jobs Information <---------============',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_log_level      => g_log_level_statement    ,
                                       p_run_log_level      => l_log_level
                                      );

                l_index := p_resulting_jobs_tbl.first;

                while l_index is not null loop

                        l_message_tbl.delete;

                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity name ['              || p_resulting_jobs_tbl(l_index).wip_entity_name                 || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity id ['                || p_resulting_jobs_tbl(l_index).wip_entity_id                   || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Description ['                  || p_resulting_jobs_tbl(l_index).description                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Job type ['                     || p_resulting_jobs_tbl(l_index).job_type                        || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Status type ['                  || p_resulting_jobs_tbl(l_index).status_type                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'wip supply type ['              || p_resulting_jobs_tbl(l_index).wip_supply_type                 || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Organization id ['              || p_resulting_jobs_tbl(l_index).organization_id                 || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Organization code ['            || p_resulting_jobs_tbl(l_index).organization_code               || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Item name ['                    || p_resulting_jobs_tbl(l_index).item_name                       || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Primary item id ['              || p_resulting_jobs_tbl(l_index).primary_item_id                 || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Class code ['                   || p_resulting_jobs_tbl(l_index).class_code                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Bom reference item ['           || p_resulting_jobs_tbl(l_index).bom_reference_item              || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Bom reference id ['             || p_resulting_jobs_tbl(l_index).bom_reference_id                || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Routing reference item ['       || p_resulting_jobs_tbl(l_index).routing_reference_item          || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Routing reference id ['         || p_resulting_jobs_tbl(l_index).routing_reference_id            || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Common bom sequence id ['       || p_resulting_jobs_tbl(l_index).common_bom_sequence_id          || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Common routing sequence id ['   || p_resulting_jobs_tbl(l_index).common_routing_sequence_id      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Bom revision ['                 || p_resulting_jobs_tbl(l_index).bom_revision                    || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Routing revision ['             || p_resulting_jobs_tbl(l_index).routing_revision                || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Bom revision date ['            || to_char(p_resulting_jobs_tbl(l_index).bom_revision_date,'DD-MON-YYYY HH24:MI:SS')               || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Routing revision date ['        || to_char(p_resulting_jobs_tbl(l_index).routing_revision_date,'DD-MON-YYYY HH24:MI:SS')            || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Alternate bom designator ['     || p_resulting_jobs_tbl(l_index).alternate_bom_designator        || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Alternate routing designator [' || p_resulting_jobs_tbl(l_index).alternate_routing_designator    || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Start quantity ['               || p_resulting_jobs_tbl(l_index).start_quantity                  || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Net quantity ['                 || p_resulting_jobs_tbl(l_index).net_quantity                    || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Starting operation seq num ['   || p_resulting_jobs_tbl(l_index).starting_operation_seq_num      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Starting intraoperation step [' || p_resulting_jobs_tbl(l_index).starting_intraoperation_step    || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Starting operation code ['      || p_resulting_jobs_tbl(l_index).starting_operation_code         || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Starting operation seq id ['    || p_resulting_jobs_tbl(l_index).starting_operation_seq_id       || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Starting std op id ['           || p_resulting_jobs_tbl(l_index).starting_std_op_id              || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Department id ['                || p_resulting_jobs_tbl(l_index).department_id                   || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Department code ['              || p_resulting_jobs_tbl(l_index).department_code                 || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Operation description ['        || p_resulting_jobs_tbl(l_index).operation_description           || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Job operation seq num ['        || p_resulting_jobs_tbl(l_index).job_operation_seq_num           || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Split has update assy ['        || p_resulting_jobs_tbl(l_index).split_has_update_assy           || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Completion subinventory ['      || p_resulting_jobs_tbl(l_index).completion_subinventory         || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Completion locator id ['        || p_resulting_jobs_tbl(l_index).completion_locator_id           || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Completion locator ['           || p_resulting_jobs_tbl(l_index).completion_locator              || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Scheduled start date ['         || to_char(p_resulting_jobs_tbl(l_index).scheduled_start_date,'DD-MON-YYYY HH24:MI:SS')             || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Scheduled completion date ['    || to_char(p_resulting_jobs_tbl(l_index).scheduled_completion_date,'DD-MON-YYYY HH24:MI:SS')        || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Bonus acct id ['                || p_resulting_jobs_tbl(l_index).bonus_acct_id                   || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Coproducts supply ['            || p_resulting_jobs_tbl(l_index).coproducts_supply               || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Kanban card id ['               || p_resulting_jobs_tbl(l_index).kanban_card_id                  || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute category ['           || p_resulting_jobs_tbl(l_index).attribute_category              || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute1 ['                   || p_resulting_jobs_tbl(l_index).attribute1                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute2 ['                   || p_resulting_jobs_tbl(l_index).attribute2                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute3 ['                   || p_resulting_jobs_tbl(l_index).attribute3                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute4 ['                   || p_resulting_jobs_tbl(l_index).attribute4                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute5 ['                   || p_resulting_jobs_tbl(l_index).attribute5                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute6 ['                   || p_resulting_jobs_tbl(l_index).attribute6                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute7 ['                   || p_resulting_jobs_tbl(l_index).attribute7                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute8 ['                   || p_resulting_jobs_tbl(l_index).attribute8                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute9 ['                   || p_resulting_jobs_tbl(l_index).attribute9                      || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute10 ['                  || p_resulting_jobs_tbl(l_index).attribute10                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute11 ['                  || p_resulting_jobs_tbl(l_index).attribute11                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute12 ['                  || p_resulting_jobs_tbl(l_index).attribute12                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute13 ['                  || p_resulting_jobs_tbl(l_index).attribute13                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute14 ['                  || p_resulting_jobs_tbl(l_index).attribute14                     || '] ' ;
                        l_message_tbl(l_message_tbl.count+1) := 'Attribute15 ['                  || p_resulting_jobs_tbl(l_index).attribute15                     || '] ' ;

                        l_counter := l_message_tbl.first;
                        l_log_message := null;

                        while l_counter is not null loop

                                IF length(l_log_message || l_message_tbl(l_counter)) > 3900 THEN
                                        -- Log the data in l_log_message...
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => l_log_message            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_log_level      => g_log_level_statement    ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                        l_log_message := null;
                                END IF;

                                l_log_message := l_log_message || l_message_tbl(l_counter);
                                l_counter     := l_message_tbl.next(l_counter);

                        end loop;

                        -- Log the remainder data..
                        IF l_log_message IS NOT NULL THEN
                                -- Log the data in l_log_message...
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_log_message            ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_log_level      => g_log_level_statement    ,
                                                       p_run_log_level      => l_log_level
                                                      );

                        END IF;

                        l_index := p_resulting_jobs_tbl.next(l_index);
                end loop;
                l_stmt_num      := 40;
                -- Log the starting jobs data....
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => '=========------> Secondary quantities Information <---------============',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_log_level      => g_log_level_statement    ,
                                       p_run_log_level      => l_log_level
                                      );

                l_index := p_secondary_qty_tbl.first;

                while l_index is not null loop

                        l_message_tbl.delete;

                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity id ['        || p_secondary_qty_tbl(l_index).wip_entity_id      || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Wip entity name ['      || p_secondary_qty_tbl(l_index).wip_entity_name    || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Organization id ['      || p_secondary_qty_tbl(l_index).organization_id    || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Uom code ['             || p_secondary_qty_tbl(l_index).uom_code           || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Current quantity ['     || p_secondary_qty_tbl(l_index).current_quantity   || '] ';
                        l_message_tbl(l_message_tbl.count+1) := 'Currently active ['     || p_secondary_qty_tbl(l_index).currently_active   || '] ';

                        l_counter := l_message_tbl.first;
                        l_log_message := null;

                        while l_counter is not null loop

                                IF length(l_log_message || l_message_tbl(l_counter)) > 3900 THEN
                                        -- Log the data in l_log_message...
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => l_log_message            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_log_level      => g_log_level_statement    ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                        l_log_message := null;
                                END IF;

                                l_log_message := l_log_message || l_message_tbl(l_counter);
                                l_counter     := l_message_tbl.next(l_counter);

                        end loop;

                        -- Log the remainder data..
                        IF l_log_message IS NOT NULL THEN
                                -- Log the data in l_log_message...
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_log_message            ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_log_level      => g_log_level_statement    ,
                                                       p_run_log_level      => l_log_level
                                                      );

                        END IF;

                        l_index := p_secondary_qty_tbl.next(l_index);
                end loop;

                -- Log the data in l_log_message...
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Sucessfully logged the transaction data',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_log_level      => g_log_level_statement    ,
                                       p_run_log_level      => l_log_level
                                      );

        END IF;

EXCEPTION
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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_msg_count   ,
                                           p_data       => x_error_msg

                                          );
END Log_transaction_data;

-- OverLoaded procedure created for the bug 5263262 with an additional parameter p_invoke_req_worker...
-- The old procedure will call the new one with NULL passed..
PROCEDURE invoke_txn_API (    p_api_version          IN                 NUMBER                                          ,
                              p_commit               IN                 VARCHAR2                                        ,
                              p_validation_level     IN                 NUMBER                                          ,
                              p_init_msg_list        IN                 VARCHAR2        DEFAULT NULL                    ,
                              p_calling_mode         IN                 NUMBER                                          ,
                              p_txn_header_rec       IN                 WLTX_TRANSACTIONS_REC_TYPE                      ,
                              p_starting_jobs_tbl    IN                 WLTX_STARTING_JOBS_TBL_TYPE                     ,
                              p_resulting_jobs_tbl   IN                 WLTX_RESULTING_JOBS_TBL_TYPE                    ,
                              P_wsm_serial_num_tbl   IN                 WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL       ,
                              p_secondary_qty_tbl    IN                 WSM_JOB_SECONDARY_QTY_TBL_TYPE                  ,
                              x_return_status        OUT    NOCOPY      VARCHAR2                                        ,
                              x_msg_count            OUT    NOCOPY      NUMBER                                          ,
                              x_error_msg            OUT    NOCOPY      VARCHAR2
                            )

IS

BEGIN
        invoke_txn_API( p_api_version         => p_api_version         ,
                        p_commit              => p_commit              ,
                        p_validation_level    => p_validation_level    ,
                        p_init_msg_list       => p_init_msg_list       ,
                        p_calling_mode        => p_calling_mode        ,
                        p_txn_header_rec      => p_txn_header_rec      ,
                        p_starting_jobs_tbl   => p_starting_jobs_tbl   ,
                        p_resulting_jobs_tbl  => p_resulting_jobs_tbl  ,
                        P_wsm_serial_num_tbl  => P_wsm_serial_num_tbl  ,
                        p_secondary_qty_tbl   => p_secondary_qty_tbl   ,
                        -- ST : Added for bug  5263262
                        p_invoke_req_worker   => NULL                  ,
                        x_return_status       => x_return_status       ,
                        x_msg_count           => x_msg_count           ,
                        x_error_msg           => x_error_msg
                      );
END;

PROCEDURE invoke_txn_API (    p_api_version          IN                 NUMBER                          ,
                              p_commit               IN                 VARCHAR2                        ,
                              p_validation_level     IN                 NUMBER                          ,
                              p_init_msg_list        IN                 VARCHAR2        DEFAULT NULL    ,
                              p_calling_mode         IN                 NUMBER                          ,
                              p_txn_header_rec       IN                 WLTX_TRANSACTIONS_REC_TYPE      ,
                              p_starting_jobs_tbl    IN                 WLTX_STARTING_JOBS_TBL_TYPE     ,
                              p_resulting_jobs_tbl   IN                 WLTX_RESULTING_JOBS_TBL_TYPE    ,
                              P_wsm_serial_num_tbl   IN                 WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL,
                              p_secondary_qty_tbl    IN                 WSM_JOB_SECONDARY_QTY_TBL_TYPE           ,
                              -- ST : Added for bug 5263262
                              p_invoke_req_worker    IN                 NUMBER                                   ,
                              x_return_status        OUT    NOCOPY      VARCHAR2                                 ,
                              x_msg_count            OUT    NOCOPY      NUMBER                                   ,
                              x_error_msg            OUT    NOCOPY      VARCHAR2
                            )
IS
     l_txn_header_rec           WLTX_TRANSACTIONS_REC_TYPE;
     l_starting_jobs_tbl        WLTX_STARTING_JOBS_TBL_TYPE;
     l_resulting_jobs_tbl       WLTX_RESULTING_JOBS_TBL_TYPE;
     l_wsm_serial_num_tbl       WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL;
     l_secondary_qty_tbl        WSM_JOB_SECONDARY_QTY_TBL_TYPE;
     l_poreq_request_id         NUMBER;
     l_index                    NUMBER;

     l_wltx_resulting_job_rec   WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE; --ADD AH

    -- Logging variables.....
    l_msg_tokens                WSM_Log_PVT.token_rec_tbl;
    l_log_level                 NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num                  NUMBER;
    l_module                    VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.invoke_txn_API';

     e_validation_error         EXCEPTION;
begin
        l_stmt_num := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_msg_count     := 0;

        /*assign the input data into local tables*/
        l_txn_header_rec        := p_txn_header_rec     ;
        l_starting_jobs_tbl     := p_starting_jobs_tbl  ;
        l_resulting_jobs_tbl    := p_resulting_jobs_tbl ;
        l_wsm_serial_num_tbl    := P_wsm_serial_num_tbl ;
        l_secondary_qty_tbl     := p_secondary_qty_tbl  ;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered Invoke Txn API procedure',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );

                -- Log the transaction data...
                Log_transaction_data (  p_txn_header_rec        => p_txn_header_rec     ,
                                        p_starting_jobs_tbl     => p_starting_jobs_tbl  ,
                                        p_resulting_jobs_tbl    => p_resulting_jobs_tbl ,
                                        p_secondary_qty_tbl     => p_secondary_qty_tbl  ,
                                        x_return_status         => x_return_status      ,
                                        x_msg_count             => x_msg_count          ,
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

        if l_txn_header_rec.transaction_type_id = WSMPCNST.SPLIT then

                /*..... invoke split.. but also do the following checks...
                i) Only one starting job...
                ii) Atleast one resulting job....
                */
                l_stmt_num := 12;
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module,
                                               p_msg_text           => 'Txn type Split',
                                               p_stmt_num           => l_stmt_num,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                l_stmt_num := 15;

                if l_starting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_START_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                end if;

                if l_resulting_jobs_tbl.count <1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 25;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Before calling SPLIT TXN procedure',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;


                SPLIT_TXN(   p_api_version                              => 1.0,
                             p_commit                                   => FND_API.G_FALSE,
                             p_init_msg_list                            => FND_API.G_TRUE,
                             p_validation_level                         => 0,
                             p_calling_mode                             => p_calling_mode,
                             p_wltx_header                              => l_txn_header_rec,
                             p_wltx_starting_job_rec                    => l_starting_jobs_tbl(l_starting_jobs_tbl.first),
                             p_wltx_resulting_jobs_tbl                  => l_resulting_jobs_tbl,
                             p_wltx_secondary_qty_tbl                   => l_secondary_qty_tbl,
                             x_return_status                            => x_return_status,
                             x_msg_count                                => x_msg_count,
                             x_msg_data                                 => x_error_msg
                         );

                l_stmt_num := 30;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module,
                                               p_msg_text           =>'Returned from SPLIT TXN procedure.Return status:'|| x_return_status,
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;


                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
                l_stmt_num := 55;

        /* Is it Merge ?? If yes, go ahead */
        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.MERGE then

                l_stmt_num := 60;

                if l_starting_jobs_tbl.count < 2 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'No. of SJs cannot be less than 2 in case of Merge',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                end if;

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 70;

                MERGE_TXN  (    p_api_version                           => 1.0,
                                p_commit                                => FND_API.G_FALSE,
                                p_init_msg_list                         => FND_API.G_TRUE,
                                p_validation_level                      => 0,
                                p_calling_mode                          => p_calling_mode,
                                p_wltx_header                           => l_txn_header_rec,
                                p_wltx_starting_jobs_tbl                => l_starting_jobs_tbl,
                                p_wltx_resulting_job_rec                => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                p_wltx_secondary_qty_tbl                => l_secondary_qty_tbl,
                                x_return_status                         => x_return_status,
                                x_msg_count                             => x_msg_count,
                                x_msg_data                              => x_error_msg
                        );

             /* if not success return error.... */ --Start AH
             --log proc exit

               if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           =>  'Merge API Failed',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                end if; --End AH

        /* Is it Update Assembly ?? If yes, go ahead */
        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.UPDATE_ASSEMBLY then

                if l_starting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_START_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                UPDATE_ASSEMBLY_TXN (   p_api_version                           => 1.0,
                                        p_commit                                => FND_API.G_FALSE,
                                        p_init_msg_list                         => FND_API.G_TRUE,
                                        p_validation_level                      => 0,
                                        p_calling_mode                          => p_calling_mode,
                                        p_wltx_header                           => l_txn_header_rec,
                                        p_wltx_starting_job_rec                 => l_starting_jobs_tbl(l_starting_jobs_tbl.first),
                                        p_wltx_resulting_job_rec                => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                        p_wltx_secondary_qty_tbl                => l_secondary_qty_tbl,
                                        x_return_status                         => x_return_status,
                                        x_msg_count                             => x_msg_count,
                                        x_msg_data                              => x_error_msg
                                        );

                /* if not success return error.... */  --Start AH
                --log exit to fnd_log

                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Update Assembly Txn procedure failed.'          ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;

                         if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                end if;  --End AH

        /* Is it Update Routing ?? If yes, go ahead */
        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.UPDATE_ROUTING then

                if l_starting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_START_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                UPDATE_ROUTING_TXN(     p_api_version                           => 1.0,
                                        p_commit                                => FND_API.G_FALSE,
                                        p_init_msg_list                         => FND_API.G_TRUE,
                                        p_validation_level                      => 0,
                                         p_calling_mode                         => p_calling_mode,
                                        p_wltx_header                           => l_txn_header_rec,
                                        p_wltx_starting_job_rec                 => l_starting_jobs_tbl(l_starting_jobs_tbl.first),
                                        p_wltx_resulting_job_rec                => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                        p_wltx_secondary_qty_tbl                => l_secondary_qty_tbl,
                                        x_return_status                         => x_return_status,
                                        x_msg_count                             => x_msg_count,
                                        x_msg_data                              => x_error_msg
                                  );

                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Update Routing Txn procedure failed.',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;

                         if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                         end if;

                end if;  --End AH

        /* Is it Update Qty ?? If yes, go ahead */
        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.UPDATE_QUANTITY then

                if l_starting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_START_LOT_REQUIRED',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                UPDATE_QUANTITY_TXN(    p_api_version                           => 1.0,
                                        p_commit                                => FND_API.G_FALSE,
                                        p_init_msg_list                         => FND_API.G_TRUE,
                                        p_validation_level                      => 0,
                                        p_calling_mode                          => p_calling_mode,
                                        p_wltx_header                           => l_txn_header_rec,
                                        p_wltx_starting_job_rec                 => l_starting_jobs_tbl(l_starting_jobs_tbl.first),
                                        p_wltx_resulting_job_rec                => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                        p_wltx_secondary_qty_tbl                => l_secondary_qty_tbl,
                                        x_return_status                         => x_return_status,
                                        x_msg_count                             => x_msg_count,
                                        x_msg_data                              => x_error_msg
                                                       );


                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                /* Bugfix 5352389 Changed p_fnd_log_level from ERROR to STATEMENT */
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Update Quantity Txn procedure failed.',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_STATEMENT        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;

                         if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                         end if;
                end if;  --End AH

        /* Is it Update Lot Name ?? If yes, go ahead */
        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.UPDATE_LOT_NAME then

                if l_starting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_START_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                UPDATE_LOTNAME_TXN(  p_api_version                      => 1.0,
                                 p_commit                               => FND_API.G_FALSE,
                                 p_init_msg_list                        => FND_API.G_TRUE,
                                 p_validation_level                     => 0,
                                 p_calling_mode                         => p_calling_mode,
                                 p_wltx_header                          => l_txn_header_rec,
                                 p_wltx_starting_job_rec                => l_starting_jobs_tbl(l_starting_jobs_tbl.first),
                                 p_wltx_resulting_job_rec               => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                 p_wltx_secondary_qty_tbl               => l_secondary_qty_tbl,
                                 x_return_status                        => x_return_status,
                                 x_msg_count                            => x_msg_count,
                                 x_msg_data                             => x_error_msg
                              );


                    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Update Lot Name Txn procedure failed.',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;


                         if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                         end if;

                    end if;  --End AH

        elsif l_txn_header_rec.transaction_type_id = WSMPCNST.BONUS then

                if l_resulting_jobs_tbl.count <> 1 then
                        /* error out... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_RESULT_LOT_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                BONUS_TXN     (  p_api_version                  => 1.0,
                                 p_commit                       => FND_API.G_FALSE,
                                 p_init_msg_list                => FND_API.G_TRUE,
                                 p_validation_level             => 0,
                                 p_calling_mode                 => p_calling_mode,
                                 p_wltx_header                  => l_txn_header_rec,
                                 p_wltx_resulting_job_rec       => l_resulting_jobs_tbl(l_resulting_jobs_tbl.first),
                                 p_wltx_secondary_qty_tbl       => l_secondary_qty_tbl,
                                 x_return_status                => x_return_status,
                                 x_msg_count                    => x_msg_count,
                                 x_msg_data                     => x_error_msg
                              );


                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        /* Txn errored....*/
                        /* Log the Procedure exit point.... */
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Bonus Txn procedure failed.',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;


                         if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                         end if;

                end if;  --End AH

        ELSE
                /* error out.... */
                null;
        end if;

        -- ST : Commenting out the check on return status.. not required..
        if p_calling_mode <> 2 then

                WSM_WLT_VALIDATE_PVT.insert_txn_data (   p_transaction_id               => l_txn_header_rec.transaction_id,
                                                         p_wltx_header                  => l_txn_header_rec,
                                                         p_wltx_starting_jobs_tbl       => l_starting_jobs_tbl,
                                                         p_wltx_resulting_jobs_tbl      => l_resulting_jobs_tbl,
                                                         x_return_status                => x_return_status,
                                                         x_msg_count                    => x_msg_count,
                                                         x_msg_data                     => x_error_msg
                                                      );

                if x_return_status <> fnd_api.g_ret_sts_success then
                        --log error
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_WLT_VALIDATE_PVT.insert_txn_data failed',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;

        -- Calling mode = 2 Indicates  forms
        elsif p_calling_mode = 2 then

                l_index := l_resulting_jobs_tbl.first;

                while l_index is not null loop
                        update wsm_sm_resulting_jobs
                        set    wip_entity_id = l_resulting_jobs_tbl(l_index).wip_entity_id,
                               job_operation_seq_num = l_resulting_jobs_tbl(l_index).job_operation_seq_num
                        where  transaction_id = l_txn_header_rec.transaction_id
                        and    wip_entity_name = l_resulting_jobs_tbl(l_index).wip_entity_name;

                        l_index := l_resulting_jobs_tbl.next(l_index);
                end loop;

        end if;

        -- Invoke the WIP Lot Transaction Serial Processor...
        WSM_Serial_Support_PVT.WLT_serial_processor     ( p_calling_mode        => p_calling_mode                           ,
                                                          p_wlt_txn_type        => l_txn_header_rec.transaction_type_id     ,
                                                          p_organization_id     => l_txn_header_rec.organization_id         ,
                                                          p_txn_id              => l_txn_header_rec.transaction_id          ,
                                                          p_starting_jobs_tbl   => l_starting_jobs_tbl                      ,
                                                          p_resulting_jobs_tbl  => l_resulting_jobs_tbl                     ,
                                                          p_serial_num_tbl      => l_wsm_serial_num_tbl                     ,
                                                          x_return_status       => x_return_status                          ,
                                                          x_error_msg           => x_error_msg                              ,
                                                          x_error_count         => x_msg_count
                                                        );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returned sucessfully from WSM_Serial_Support_PVT.WLT_serial_processor',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        --Bug 5263262:Req import was not invoked because of
        --incorrect check on l_request_id in WSMPJUPD.This has been fixed and
        --hence the following fix is not needed.
        -- Invoke the Req Processor if needed (for forms and MES)
        -- ST : Fix for bug 5263262 : Invoke the worker for MES, forms..
        -- For interface it will be done in a single shot in WSMPLOAD
        --IF nvl(p_invoke_req_worker,1) = 1 AND WSMPJUPD.g_osp_exists = 1 THEN
         --       l_poreq_request_id := fnd_request.submit_request('PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, 'ITEM',
          --                                                           NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
           --                                                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            --                                                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
             --                                                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
              --                                                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               --                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                --                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 --                                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  --                                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   --                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                    --                                                ) ;
               -- if( g_log_level_statement   >= l_log_level ) then
                --        l_msg_tokens.delete;
                 --       WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                  --                             p_msg_text           => 'Concurrent Request : ' || l_poreq_request_id || ' for Requisition Import Submitted',
                   --                            p_stmt_num           => l_stmt_num               ,
                    --                           p_msg_tokens         => l_msg_tokens,
                     --                          p_fnd_log_level      => g_log_level_statement,
                      --                         p_run_log_level      => l_log_level
                       --                       );
                --End if;
        --END IF;
        -- ST : Fix for bug 5263262 End --

        FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                   p_count      => x_msg_count   ,
                                   p_data       => x_error_msg
                                  );

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Invoke Txn API completed sucessfully',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_msg_count   ,
                                           p_data       => x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_msg_count   ,
                                           p_data       => x_error_msg

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'           ,
                                           p_count      => x_msg_count   ,
                                           p_data       => x_error_msg

                                          );
END;

/* API for Split transaction.... */
PROCEDURE SPLIT_TXN  (  p_api_version                           IN              NUMBER,
                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                        p_calling_mode                          IN              NUMBER,
                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                        p_wltx_resulting_jobs_tbl               IN OUT  NOCOPY  WLTX_RESULTING_JOBS_TBL_TYPE,
                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                        x_msg_count                             OUT     NOCOPY  NUMBER,
                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                    )  IS


     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'SPLIT_TXN';


     /* Other locals */
     l_txn_id         NUMBER;
     i                NUMBER;

     /* Have to create a table.... for the starting job */
     l_wltx_starting_jobs_tbl  WLTX_STARTING_JOBS_TBL_TYPE;

     -- Logging variables.....
     l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
     l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_stmt_num         NUMBER;
     l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.SPLIT_TXN';
     -- Logging variables...

BEGIN

    /* Have a starting point */
    savepoint start_split_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;

    /* Log the Procedure entry point.... */
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered Split Txn procedure'            ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 20;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
    end if;

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
          IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Split Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    /* logginng .... */
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'API compatibility succeeded'            ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    if p_calling_mode <> 2 then --if Interface /MES then do the validations

            l_stmt_num := 50;

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.validate_txn_header (  p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

          if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details ( p_txn_type            => p_wltx_header.transaction_type_id,
                                                             p_txn_org_id          => p_wltx_header.organization_id,
                                                             -- ST : Added for bug fix 4351071
                                                             p_txn_date            => p_wltx_header.transaction_date,
                                                             p_starting_job_rec    => p_wltx_starting_job_rec,
                                                             x_return_status       => x_return_status,
                                                             x_msg_count           => x_msg_count,
                                                             x_msg_data            => x_msg_data
                                                          );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;


         if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

        /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

             /* This validates the main job details...... */

             WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(    p_txn_org_id           => p_wltx_header.organization_id,
                                                                 p_txn_type             => p_wltx_header.transaction_type_id,
                                                                 p_starting_job_rec     => p_wltx_starting_job_rec,
                                                                 p_resulting_jobs_tbl   => p_wltx_resulting_jobs_tbl,
                                                                 x_return_status        => x_return_status,
                                                                 x_msg_count            => x_msg_count,
                                                                 x_msg_data             => x_msg_data
                                                           );

           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

          if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        /* Bugfix 5438722 Changed p_fnd_log_level from ERROR to STATEMENT */
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'||x_return_status,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_STATEMENT        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;
           /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           /* Validation and default completed....*/
   end if; --Validation for interface/MES ended

   l_stmt_num := 120;

   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_wltx_starting_jobs_tbl(1) := (p_wltx_starting_job_rec);

   /* call Process lots now....*/
   WSMPJUPD.PROCESS_LOTS (p_copy_qa                     => null,
                          p_txn_org_id                  => p_wltx_header.organization_id,
                          p_rep_job_index               => l_wltx_starting_jobs_tbl.first,
                          p_wltx_header                 => p_wltx_header,
                          p_wltx_starting_jobs_tbl      => l_wltx_starting_jobs_tbl,
                          p_wltx_resulting_jobs_tbl     => p_wltx_resulting_jobs_tbl,
                          p_secondary_qty_tbl           => p_wltx_secondary_qty_tbl,
                          x_return_status               => x_return_status,
                          x_msg_count                   => x_msg_count,
                          x_error_msg                   => x_msg_data
                       );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
  end if;

  -- Assign back...
  p_wltx_starting_job_rec := l_wltx_starting_jobs_tbl(1);

  /* Log the Procedure exit point.... */
  if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the Wip Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;

        COMMIT;
        /* Log the Procedure exit point.... */
        --'WIp Lot Transaction ... Commit complete')
           if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
           End if;
    END IF;


EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_split_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

                -- remove this later...

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_split_txn;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
                -- remove this later...

        WHEN OTHERS THEN

                ROLLBACK TO start_split_txn;

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
                                           p_data       => x_msg_data
                                          );

END;


/* API for Merge transaction.... */
PROCEDURE MERGE_TXN  (          p_api_version                           IN              NUMBER,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_calling_mode                          IN              NUMBER,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_jobs_tbl                IN OUT  NOCOPY  WLTX_STARTING_JOBS_TBL_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                        ) IS


     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'MERGE_TXN';


     /* Other locals */
     l_txn_id               NUMBER;
     l_rep_job_index        NUMBER;
     l_total_avail_quantity NUMBER := 0; --Add AH
     l_total_net_quantity   NUMBER := 0; --Add AH
     i                      NUMBER;
     l_job_serial_code      NUMBER;

     /* Have to create a table.... for the starting job */
     l_wltx_starting_jobs_tbl  WLTX_STARTING_JOBS_TBL_TYPE;
     l_wltx_rep_job_rec  WLTX_STARTING_JOBS_REC_TYPE; --Add AH

     -- Logging variables.....
     l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
     l_log_level            number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

     l_stmt_num     NUMBER;
     l_module       VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.MERGE_TXN';
     -- Logging variables...

     /* Have to create a table.... for the starting job */
     l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN
    /* Have a starting point */
    savepoint start_merge_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;

    /* Log the Procedure entry point.... */
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Entering the Merge_Txn API'    ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

      /* W'll log the parameter values as and where they get modified....*/
      /* Log the standard api parameters.... */
    l_stmt_num := 20;

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
        --'FND_MSG_PUB Message Table Initialized'
    end if;

    /* Log the Procedure entry point.... */
    --'Calling FND_API.Compatible_API_Call');

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
          IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Merge Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
   /* lgging -proc level */
   --'API compatibility success ');

    if p_calling_mode <> 2 then
            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;
            WSM_WLT_VALIDATE_PVT.validate_txn_header (   p_wltx_header     => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */
             /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
             End if;

         if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

            /* Log the Procedure exit point....event level */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */
            /* Log the Procedure entry point.... proc level*/
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details(     p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_txn_type              => p_wltx_header.transaction_type_id,
                                                                -- ST : Added for bug fix 4351071
                                                                p_txn_date              => p_wltx_header.transaction_date,
                                                                p_starting_jobs_tbl     => p_wltx_starting_jobs_tbl,
                                                                p_rep_job_index         => l_rep_job_index,
                                                                p_total_avail_quantity  => l_total_avail_quantity,
                                                                p_total_net_quantity    => l_total_net_quantity,
                                                                -- ST : Serial Support Project Added for serial...
                                                                x_job_serial_code       => l_job_serial_code,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                          );

            /* Log the Procedure exit point....proc level,stmt level*/
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point....proc level */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

             /* This validates the main job details.....specific to merge.... */
             /* Before calling derive validate for resulting jobs,assign the representative job details to a local pl/sql record*/
             l_wltx_rep_job_rec := p_wltx_starting_jobs_tbl(l_rep_job_index);  --Is this the expected way? (AH)

             WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(   p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_starting_job_rec      => l_wltx_rep_job_rec,
                                                                p_job_quantity          => l_total_avail_quantity,
                                                                p_job_net_quantity      => l_total_net_quantity,
                                                                p_job_serial_code       => l_job_serial_code,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                            );


           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

           /* Log the Procedure exit point.... */
          if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           /* Validation and default completed....*/
   else
        for l_counter in p_wltx_starting_jobs_tbl.first .. p_wltx_starting_jobs_tbl.last loop
                if p_wltx_starting_jobs_tbl(l_counter).REPRESENTATIVE_FLAG = 'Y' then
                        l_rep_job_index := l_counter;
                end if;
        end loop;
   end if ; --end of validation procs for I/f or MES

   l_stmt_num := 120;

   /* Log the Procedure entry point....proc entry */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;
   WSMPJUPD.PROCESS_LOTS (p_copy_qa                             => null,
                          p_txn_org_id                          => p_wltx_header.organization_id,
                          p_rep_job_index                       => l_rep_job_index,
                          p_wltx_header                         => p_wltx_header,
                          p_wltx_starting_jobs_tbl              => p_wltx_starting_jobs_tbl,
                          p_wltx_resulting_jobs_tbl             => l_wltx_resulting_jobs_tbl,
                          p_secondary_qty_tbl                   => p_wltx_secondary_qty_tbl,
                          x_return_status                       => x_return_status,
                          x_msg_count                           => x_msg_count,
                          x_error_msg                           => x_msg_data
                         );

   /* Log the Procedure exit point....proc exit */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
  end if;

  -- Assign back ....
  p_wltx_resulting_job_rec      := l_wltx_resulting_jobs_tbl(1) ;

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;

   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point.... */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
        End if;
   END IF;


EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_merge_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.merge_txn : ' || l_stmt_num ||  ' Error : ');

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_merge_txn;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'        ,
                                           p_count      => x_msg_count,
                                           p_data       => x_msg_data
                                          );
                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.merge_txn : ' || l_stmt_num ||  ' Unexp error : ');

        WHEN OTHERS THEN

                ROLLBACK TO start_merge_txn;

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
                                           p_data       => x_msg_data
                                          );
                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.merge_txn : ' || l_stmt_num ||  ' Other error : ' || SQLCODE || ' : ' || substrb(SQLERRM,1,1000) );
END;

/* API for Update Assembly transaction.... */
Procedure UPDATE_ASSEMBLY_TXN (         p_api_version                           IN              NUMBER,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                        p_calling_mode                          IN              NUMBER,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                        p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                     )  IS

     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'UPDATE_ASSEMBLY_TXN';


     /* Other locals */
     l_txn_id         NUMBER;

      -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.UPDATE_ASSEMBLY_TXN';

     /* Have to create a table.... for the starting and resulting job */
     l_wltx_starting_jobs_tbl   WLTX_STARTING_JOBS_TBL_TYPE;
     l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN
    /* Have a starting point */
    savepoint start_upd_assy_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;

     /* Log the Procedure entry point.... */
    /* Logging into the FND_MSG_PUB will be to the level of G_MSG_LVL_SUCCESS
       G_MSG_LVL_DEBUG_HIGH  , G_MSG_LVL_DEBUG_MEDIUM ,G_MSG_LVL_DEBUG_LOW not considered as of now...
    */

    --'Entering the Update Assembly Txn API');

      /* W'll log the parameter values as and where they get modified....*/
      /* Log the standard api parameters.... */

    l_stmt_num := 20;

    /* Log the Procedure entry point....proc level */
    --'Calling FND_API.to_Boolean');

    /* Initialize message list if p_init_msg_list is set to TRUE. */
     /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN

        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
        --'FND_MSG_PUB Message Table Initialized');
    end if;

    /* FND_MSG_PUB logginng .... */
    --'Inside Update_Assembly_Txn API ' );


    /* Log the Procedure entry point....proc */
    --'Calling FND_API.Compatible_API_Call');


    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Upd Assy Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    /*proc level logging*/
    --API compatibility success ');
    /*event lvl logging*/
    --API compatibility success ');

    /* FND_MSG_PUB logginng .... */
    --' API compatibility success ' );

    if p_calling_mode <> 2 then

            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point....proc level */
             if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           WSM_WLT_VALIDATE_PVT.validate_txn_header (   p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

           /* End header Validation */
           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */
            /* Log the Procedure entry point....proc lvl */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details(     p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_txn_type              => p_wltx_header.transaction_type_id,
                                                                -- ST : Added for bug fix 4351071
                                                                p_txn_date                 => p_wltx_header.transaction_date,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                          );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point....proc lvl */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            /* This validates the main job details.....for non-merge and non-split txns.... */

            WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(    p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_transaction_date      => SYSDATE,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                           );

           /* Log the Procedure exit point....proc lvl */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

   end if; --End of validation procs
   l_stmt_num := 120;

   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_starting_jobs_tbl(1)  := p_wltx_starting_job_rec;
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;

   WSMPJUPD.PROCESS_LOTS( p_copy_qa                     => null,
                          p_txn_org_id                  => p_wltx_header.organization_id,
                          p_rep_job_index               => l_wltx_starting_jobs_tbl.first,
                          p_wltx_header                 => p_wltx_header,
                          p_wltx_starting_jobs_tbl      => l_wltx_starting_jobs_tbl,
                          p_wltx_resulting_jobs_tbl     => l_wltx_resulting_jobs_tbl,
                          p_secondary_qty_tbl           => p_wltx_secondary_qty_tbl,
                          x_return_status               => x_return_status,
                          x_msg_count                   => x_msg_count,
                          x_error_msg                   => x_msg_data
                         );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
  end if;

  -- Assign back ....
  p_wltx_starting_job_rec       := l_wltx_starting_jobs_tbl(1)  ;
  p_wltx_resulting_job_rec      := l_wltx_resulting_jobs_tbl(1) ;

  /* Log the Procedure exit point.... */
  if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;


   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point....event */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
        End if;

   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_upd_assy_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.update_assembly_txn : ' || l_stmt_num ||  ' Error : ');

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_upd_assy_txn;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.update_assembly_txn : ' || l_stmt_num ||  ' Un Exp Error : ');
        WHEN OTHERS THEN

                ROLLBACK TO start_upd_assy_txn;

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
                                           p_data       => x_msg_data
                                          );
                fnd_file.put_line(fnd_file.log,' WSM_WIP_LOT_TXN_PVT.update_assembly_txn : ' || l_stmt_num ||  ' Other Error : ');
END;

/* API for Update Routing transaction.... */
Procedure UPDATE_ROUTING_TXN (  p_api_version                           IN              NUMBER,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_calling_mode                          IN              NUMBER,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                                ) IS


     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'UPDATE_ROUTING_TXN';


     /* Other locals */
     l_txn_id         NUMBER;

     -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.UPDATE_ROUTING_TXN';

     /* Have to create a table.... for the starting job */
     l_wltx_starting_jobs_tbl   WLTX_STARTING_JOBS_TBL_TYPE;
     l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN

    /* Have a starting point */
    savepoint start_upd_rtg_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;


         /* Log the Procedure entry point.... */
    /* Logging into the FND_MSG_PUB will be to the level of G_MSG_LVL_SUCCESS
       G_MSG_LVL_DEBUG_HIGH  , G_MSG_LVL_DEBUG_MEDIUM ,G_MSG_LVL_DEBUG_LOW not considered as of now...
    */
    /*proc level*/
   --'Entering the Update Routing Txn API');

      /* W'll log the parameter values as and where they get modified....*/
      /* Log the standard api parameters.... */

    l_stmt_num := 20;

    /* Log the Procedure entry point.... */
    --'Calling FND_API.to_Boolean');

    /* Initialize message list if p_init_msg_list is set to TRUE. */
     /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN

        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
        --'FND_MSG_PUB Message Table Initialized');

    end if;

    /* FND_MSG_PUB logginng .... */
    --'Inside Update_Routing_Txn API ' );

    /* Log the Procedure entry point.... proc*/
   --'Calling FND_API.Compatible_API_Call');

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Incompatible API called for Upd Routing Txn',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    /*proc lelvel logginh*/
    --'API compatibility success ');

    /*event lelvel logginh*/
    --'API compatibility success ');

    /* FND_MSG_PUB logginng .... */
    -- API compatibility success ' );
    if p_calling_mode <> 2 then
            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point....proc */
             if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

            WSM_WLT_VALIDATE_PVT.validate_txn_header (  p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */
            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */
            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details(     p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_txn_type              => p_wltx_header.transaction_type_id,
                                                                -- ST : Added for bug fix 4351071
                                                                p_txn_date              => p_wltx_header.transaction_date,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                          );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
           end if;

           /* Log the Procedure exit point....event */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            /* This validates the main job details.....for non-merge and non-split txns.... */

            WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(    p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_transaction_date      => SYSDATE,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                           );

           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           /*stmt lvl*/

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
          end if;

          /* Log the Procedure exit point.... event*/
          if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

   end if; --end of validation procs

   l_stmt_num := 120;

   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_starting_jobs_tbl(1) := p_wltx_starting_job_rec;
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;

   WSMPJUPD.PROCESS_LOTS( p_copy_qa                     => null,
                          p_txn_org_id                  => p_wltx_header.organization_id,
                          p_rep_job_index               => l_wltx_starting_jobs_tbl.first,
                          p_wltx_header                 => p_wltx_header,
                          p_wltx_starting_jobs_tbl      => l_wltx_starting_jobs_tbl,
                          p_wltx_resulting_jobs_tbl     => l_wltx_resulting_jobs_tbl,
                          p_secondary_qty_tbl           => p_wltx_secondary_qty_tbl,
                          x_return_status               => x_return_status,
                          x_msg_count                   =>   x_msg_count,
                          x_error_msg                   =>   x_msg_data
                        );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        /* Txn errored....*/
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;
  end if;

  -- Assign back ....
  p_wltx_starting_job_rec       := l_wltx_starting_jobs_tbl(1)  ;
  p_wltx_resulting_job_rec      := l_wltx_resulting_jobs_tbl(1) ;

  /* Log the Procedure exit point.... event*/
  if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point....event */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
         End if;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_upd_rtg_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO start_upd_rtg_txn;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN OTHERS THEN

                ROLLBACK TO start_upd_rtg_txn;

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
                                           p_data       => x_msg_data
                                          );
END;

/* API for Update Quantity transaction.... */
Procedure UPDATE_QUANTITY_TXN ( p_api_version                           IN              NUMBER,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_calling_mode                          IN              NUMBER,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                                )  IS
/* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'UPDATE_QUANTITY_TXN';



     /* Other locals */
     l_txn_id         NUMBER;

     -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WIP_LOT_TXN_PVT.UPDATE_QUANTITY_TXN';

     /* Have to create a table.... for the starting job */
     l_wltx_starting_jobs_tbl   WLTX_STARTING_JOBS_TBL_TYPE;
     l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN

    /* Have a starting point */
    savepoint start_upd_qty_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;


         /* Log the Procedure entry point.... */
    /* Logging into the FND_MSG_PUB will be to the level of G_MSG_LVL_SUCCESS
       G_MSG_LVL_DEBUG_HIGH  , G_MSG_LVL_DEBUG_MEDIUM ,G_MSG_LVL_DEBUG_LOW not considered as of now...
    */
    /*stmt lvl*/
    --'Entering the Update Quantity Txn API');

      /* W'll log the parameter values as and where they get modified....*/
      /* Log the standard api parameters.... */

    l_stmt_num := 20;

    /* Log the Procedure entry point....proc */
    --Calling FND_API.to_Boolean');

    /* Initialize message list if p_init_msg_list is set to TRUE. */
     /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN

        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
        --'FND_MSG_PUB Message Table Initialized');
    end if;

    /* FND_MSG_PUB logginng .... */
    --'Inside Update_Quantity_Txn API ' );

    /* Log the Procedure entry point.... */
   --'Calling FND_API.Compatible_API_Call');

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Upd Qty Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    /*proc level*/
    --'API compatibility success ');
    /*event level*/
   --'API compatibility success ');

    /* FND_MSG_PUB logginng .... */
    --' API compatibility success ' );

    if P_calling_mode <> 2 then

            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */


            /* Log the Procedure entry point....proc level */
             if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.validate_txn_header (  p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */
            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */
            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details(     p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_txn_type              => p_wltx_header.transaction_type_id,
                                                                -- ST : Added for bug fix 4351071
                                                                p_txn_date              => p_wltx_header.transaction_date,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                          );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if (g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
             End if;

             /* This validates the main job details.....for non-merge and non-split txns.... */

             WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(   p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_transaction_date      => SYSDATE,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                           );

           /* Log the Procedure exit point.... */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        /* Bugfix 5352389 changed fnd_log_level from ERROR to STATEMENT */
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_STATEMENT        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
           end if;

           /* Log the Procedure exit point....event */
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;
    end if ; --end of validation procs

   /* Validation and default completed....*/
   /*now call process lots*/

   l_stmt_num := 120;

   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_starting_jobs_tbl(1) := p_wltx_starting_job_rec;
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;

   WSMPJUPD.PROCESS_LOTS ( p_copy_qa                    => null,
                           p_txn_org_id                 => p_wltx_header.organization_id,
                           p_rep_job_index              => l_wltx_starting_jobs_tbl.first,
                           p_wltx_header                => p_wltx_header,
                           p_wltx_starting_jobs_tbl     => l_wltx_starting_jobs_tbl,
                           p_wltx_resulting_jobs_tbl    => l_wltx_resulting_jobs_tbl,
                           p_secondary_qty_tbl          => p_wltx_secondary_qty_tbl,
                           x_return_status              => x_return_status,
                           x_msg_count                  =>   x_msg_count,
                           x_error_msg                  =>   x_msg_data
                         );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        /* Txn errored....*/
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;
   end if;

    -- Assign back ....
  p_wltx_starting_job_rec       := l_wltx_starting_jobs_tbl(1)  ;
  p_wltx_resulting_job_rec      := l_wltx_resulting_jobs_tbl(1) ;

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point....event */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
        End if;

   END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_upd_qty_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


                ROLLBACK TO start_upd_qty_txn;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
        WHEN OTHERS THEN

                ROLLBACK TO start_upd_qty_txn;

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
                                           p_data       => x_msg_data
                                          );
END;

/* API for Update Lot name transaction.... */
Procedure UPDATE_LOTNAME_TXN (  p_api_version                           IN              NUMBER,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_calling_mode                          IN              NUMBER,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                            )  IS
     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'UPDATE_LOTNAME_TXN';


     /* Other locals */
     l_txn_id         NUMBER;

      -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) :='wsm.plsql.WSM_WIP_LOT_TXN_PVT.UPDATE_LOTNAME_TXN';

     /* Have to create a table.... for the starting job */
     l_wltx_starting_jobs_tbl   WLTX_STARTING_JOBS_TBL_TYPE;
     l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN

    /* Have a starting point */
    savepoint start_upd_lotname_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;


   /* Log the Procedure entry point.... */
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Entering the Update Lotname Txn API',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 20;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN

        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Message Table Initialized',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
    end if;

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
           /* Incompatible versions...*/
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Upd Lotname Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    if p_calling_mode <> 2 then

            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

            WSM_WLT_VALIDATE_PVT.validate_txn_header (  p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */
            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 60;

            /* Here we actually call the code to default the job details... */
            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            WSM_WLT_VALIDATE_PVT.derive_val_st_job_details(     p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_txn_type              => p_wltx_header.transaction_type_id,
                                                                -- ST : Added for bug fix 4351071
                                                                p_txn_date              => p_wltx_header.transaction_date,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                          );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.default_starting_job_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_st_job_details failed.'              ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Defaulting the starting job details ... Success  ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
             End if;

             /* This validates the main job details.....for non-merge and non-split txns.... */

             WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(   p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_transaction_date      => SYSDATE,
                                                                p_starting_job_rec      => p_wltx_starting_job_rec,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                           );

             /* Log the Procedure exit point.... */
             if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
           end if;

           /* Log the Procedure exit point.... event*/
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

    end if ; --end of validation procs

   /* Validation and default completed....*/
   /*now call process lots*/

   l_stmt_num := 120;


   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_starting_jobs_tbl(1) := p_wltx_starting_job_rec;
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;

   WSMPJUPD.PROCESS_LOTS ( p_copy_qa                    => null,
                           p_txn_org_id                 => p_wltx_header.organization_id,
                           p_rep_job_index              => l_wltx_starting_jobs_tbl.first,
                           p_wltx_header                => p_wltx_header,
                           p_wltx_starting_jobs_tbl     => l_wltx_starting_jobs_tbl,
                           p_wltx_resulting_jobs_tbl    => l_wltx_resulting_jobs_tbl,
                           p_secondary_qty_tbl          => p_wltx_secondary_qty_tbl,
                           x_return_status              => x_return_status,
                           x_msg_count                  => x_msg_count,
                           x_error_msg                  => x_msg_data
                         );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                 if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
  end if;

  -- Assign back ....
  p_wltx_starting_job_rec       := l_wltx_starting_jobs_tbl(1)  ;
  p_wltx_resulting_job_rec      := l_wltx_resulting_jobs_tbl(1) ;

   /* Log the Procedure exit point.... event*/
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point....event */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
        End if;

   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_upd_lotname_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN OTHERS THEN

                ROLLBACK TO start_upd_lotname_txn;

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
                                           p_data       => x_msg_data
                                          );
END;


/* API for BONUS transaction.... */
Procedure BONUS_TXN (           p_api_version                           IN              NUMBER,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_calling_mode                          IN              NUMBER,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                p_wltx_secondary_qty_tbl                IN OUT  NOCOPY  WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                    )  IS

     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name       VARCHAR2(20) := 'BONUS_TXN';


     /* Other locals */
     l_txn_id         NUMBER;

      -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) :='wsm.plsql.WSM_WIP_LOT_TXN_PVT.BONUS_TXN';

    l_wltx_starting_job_rec     WLTX_STARTING_JOBS_REC_TYPE;

    /* Have to create a table.... for the starting job */
    l_wltx_starting_jobs_tbl   WLTX_STARTING_JOBS_TBL_TYPE;
    l_wltx_resulting_jobs_tbl  WLTX_RESULTING_JOBS_TBL_TYPE;

BEGIN

    /* Have a starting point */
    savepoint start_bonus_txn;

    l_stmt_num := 10;
    /*  Initialize API return status to success */
    x_return_status     := G_RET_SUCCESS;
    x_msg_count         := NULL;
    x_msg_data          := 0;


   /* Log the Procedure entry point.... */
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entering the Bonus Txn API',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 20;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        l_stmt_num := 30;
        FND_MSG_PUB.initialize;
        /* Message list enabled....-- EVENT */
    end if;

    l_stmt_num := 40;

    /* Check for the API compatibilty */
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        g_pkg_name,
                                        l_api_name
                                        )
    THEN
          /* Incompatible versions...*/
           IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Incompatible API called for Bonus Txn',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    if p_calling_mode <> 2 then

            l_stmt_num := 50; --Start AH

            /* Txn Header Validation....................  */

            /* Log the Procedure entry point.... */
             if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Calling WSM_WLT_VALIDATE_PVT.validate_txn_details',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
             End if;

            WSM_WLT_VALIDATE_PVT.validate_txn_header (  p_wltx_header      => p_wltx_header,
                                                        x_return_status    => x_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data
                                                     );

            /* End header Validation */
            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           =>  'Returning from  WSM_WLT_VALIDATE_PVT.validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'validate_txn_header failed.'            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
            end if;

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validated the Transaction Header Information .... Success '             ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            l_stmt_num := 70;

            /* Log the Procedure entry point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WSM_WLT_VALIDATE_PVT.validate_resulting_job ',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

             /* This validates the main job details.....for bonus txns.... */

             WSM_WLT_VALIDATE_PVT.derive_val_res_job_details(   p_txn_type              => p_wltx_header.transaction_type_id,
                                                                p_txn_org_id            => p_wltx_header.organization_id,
                                                                p_transaction_date      => SYSDATE,
                                                                p_resulting_job_rec     => p_wltx_resulting_job_rec,
                                                                x_return_status         => x_return_status,
                                                                x_msg_count             => x_msg_count,
                                                                x_msg_data              => x_msg_data
                                                           );

            /* Log the Procedure exit point.... */
            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WSM_WLT_VALIDATE_PVT.validate_resulting_job',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_res_job_details failed.'             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
           end if;

           /* Log the Procedure exit point.... event*/
           if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Validation of the resulting jobs details ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
           End if;

    end if ; --end of validation procs

   /* Validation and default completed....*/
   /*now call process lots*/

   l_stmt_num := 120;

   /* Log the Procedure entry point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Calling WWSMPJUPD.PROCESS_LOTS : Transaction Id : ' || l_txn_id ,
                                       p_stmt_num           => l_stmt_num,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   /* call Process lots now....*/
   l_wltx_resulting_jobs_tbl(1) := p_wltx_resulting_job_rec;

   WSMPJUPD.PROCESS_LOTS (      p_copy_qa                       => null,
                                p_txn_org_id                    => p_wltx_header.organization_id,
                                p_rep_job_index                 => l_wltx_starting_jobs_tbl.first,
                                p_wltx_header                   => p_wltx_header,
                                p_wltx_starting_jobs_tbl        => l_wltx_starting_jobs_tbl,
                                p_wltx_resulting_jobs_tbl       => l_wltx_resulting_jobs_tbl,
                                p_secondary_qty_tbl             => p_wltx_secondary_qty_tbl,
                                x_return_status                 => x_return_status,
                                x_msg_count                     => x_msg_count,
                                x_error_msg                     => x_msg_data
                          );

   /* Log the Procedure exit point.... */
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Returning from  WWSMPJUPD.PROCESS_LOTS',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                /* Txn errored....*/
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'PROCESS_LOTS failed.'           ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                 END IF;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
   end if;

   -- Assign back ....
   p_wltx_resulting_job_rec     := l_wltx_resulting_jobs_tbl(1) ;


   /* Log the Procedure exit point.... event*/
   if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Processing of the WIp Lot Transaction ... Success',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
   End if;

   l_stmt_num := 130;
   /* Standard check of p_commit. */
   IF FND_API.To_Boolean( p_commit ) THEN
        l_stmt_num := 140;
        COMMIT;
        /* Log the Procedure exit point....event */
        if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Wip Lot Transaction ... Commit complete',
                                               p_stmt_num           => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
        End if;

   END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_bonus_txn;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN OTHERS THEN

                ROLLBACK TO start_bonus_txn;

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
                                           p_data       => x_msg_data
                                          );
END;

/* APIS not coded start */
PROCEDURE UPDATE_BOM     (      p_api_version                           IN              VARCHAR2,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                               )  IS

BEGIN

  null;

END;

PROCEDURE UPDATE_STATUS     (   p_api_version                           IN              VARCHAR2,
                                p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                               )  IS

BEGIN

  null;

END;


PROCEDURE UPDATE_COMP_SUBINV_LOC(       p_api_version                           IN              VARCHAR2,
                                        p_commit                                IN              VARCHAR2        DEFAULT NULL,
                                        p_init_msg_list                         IN              VARCHAR2        DEFAULT NULL,
                                        p_validation_level                      IN              NUMBER          DEFAULT NULL,
                                        p_wltx_header                           IN OUT  NOCOPY  WLTX_TRANSACTIONS_REC_TYPE,
                                        p_wltx_starting_job_rec                 IN OUT  NOCOPY  WLTX_STARTING_JOBS_REC_TYPE,
                                        p_wltx_resulting_job_rec                IN OUT  NOCOPY  WLTX_RESULTING_JOBS_REC_TYPE,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                )   IS

BEGIN

  null;

END;

/* APIS not coded end */

end WSM_WIP_LOT_TXN_PVT;

/
