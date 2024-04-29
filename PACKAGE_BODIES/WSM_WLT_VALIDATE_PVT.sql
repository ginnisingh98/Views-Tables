--------------------------------------------------------
--  DDL for Package Body WSM_WLT_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_WLT_VALIDATE_PVT" as
/* $Header: WSMVVLDB.pls 120.28 2006/09/19 07:28:21 nlal noship $ */

-- Package name
g_pkg_name                      VARCHAR2(20) := 'WSM_WLT_VALIDATE_PVT';

--logging variables
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

type t_wip_entity_name_tbl is table of NUMBER index by WIP_ENTITIES.wip_entity_name%TYPE;

-- Derives the routing sequence information...
PROCEDURE routing_seq ( p_job_type              IN              NUMBER,
                        p_org_id                IN              NUMBER,
                        p_item_id               IN              NUMBER,
                        p_alt_rtg               IN OUT NOCOPY   VARCHAR2,
                        p_common_rtg_seq_id     IN OUT NOCOPY   NUMBER,     --VJ: Added
                        p_rtg_ref_id            IN OUT NOCOPY   NUMBER,
                        p_default_subinv        OUT    NOCOPY   VARCHAR2,
                        p_default_loc_id        OUT    NOCOPY   NUMBER,
                        x_rtg_seq_id            OUT    NOCOPY   NUMBER,
                        --x_common_rtg_seq_id   OUT    NOCOPY   NUMBER,       --VJ: Deleted
                        x_return_status         OUT    NOCOPY   VARCHAR2,
                        x_error_msg             OUT    NOCOPY   VARCHAR2,
                        x_error_count           OUT    NOCOPY   NUMBER
                      ) IS


l_rtg_item_id       number;
l_err_code          NUMBER;
-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.routing_seq';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...


BEGIN
    x_return_status     := G_RET_SUCCESS;
    x_error_msg         := NULL;
    x_error_count       := 0;

    l_stmt_num := 10;
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

        l_stmt_num := 15;
        l_param_tbl.delete;

        l_param_tbl(1).paramName := 'p_job_type';
        l_param_tbl(1).paramValue := p_job_type;

        l_param_tbl(2).paramName := 'p_org_id';
        l_param_tbl(2).paramValue := p_org_id;

        l_param_tbl(3).paramName := 'p_item_id';
        l_param_tbl(3).paramValue := p_item_id;

        l_param_tbl(4).paramName := 'p_default_loc_id';
        l_param_tbl(4).paramValue := p_default_loc_id;

        l_param_tbl(5).paramName := 'p_alt_rtg';
        l_param_tbl(5).paramValue := p_alt_rtg;

        l_param_tbl(6).paramName := 'p_rtg_ref_id';
        l_param_tbl(6).paramValue := p_rtg_ref_id;

        l_param_tbl(7).paramName := 'p_default_subinv';
        l_param_tbl(7).paramValue := p_default_subinv;


        WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                  p_param_tbl           => l_param_tbl,
                                  p_fnd_log_level       => l_log_level
                                  );
    END IF;

    if(p_job_type = 1) then     -- std job
        -- ignore p_rtg_ref_id
        p_rtg_ref_id  := null;
        l_rtg_item_id := p_item_id;
    else                        -- non-std job
        if p_rtg_ref_id is null then

            IF g_log_level_error >= l_log_level OR
               FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
            THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NS_RTNG_REF_NULL'   ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
            END IF;
            RAISE FND_API.G_EXC_ERROR;

        end if;
        l_rtg_item_id := p_rtg_ref_id;

    end if;

    -- CZHDBG only creation/std-job is here now
    l_stmt_num := 20;
    IF p_common_rtg_seq_id IS NULL  --VJ: Added
    THEN
        BEGIN
            select bor.routing_sequence_id,
                   bor.completion_subinventory,
                   bor.completion_locator_id
            into   x_rtg_seq_id,
                   p_default_subinv,
                   p_default_loc_id
            from   bom_routing_alternates_v bor
            where  bor.organization_id = p_org_id
            and    bor.assembly_item_id = l_rtg_item_id
            and    NVL(bor.alternate_routing_designator, '##@@')
                        = NVL(p_alt_rtg, '##@@')
            and    bor.routing_type = 1
            and    bor.cfm_routing_flag = 3;
        EXCEPTION
            WHEN no_data_found then
                    IF g_log_level_error >= l_log_level OR
                       FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                    THEN
                            l_msg_tokens.delete;
                            l_msg_tokens(1).TokenName := 'FLD_NAME';
                            IF (p_job_type = 1) THEN     -- std job
                                    l_msg_tokens(1).TokenValue := 'PRIMARY_ITEM_ID/ALTERNATE_ROUTING_DESIGNATOR';
                            ELSE
                                    l_msg_tokens(1).TokenValue := 'ROUTING_REFERENCE_ID/ALTERNATE_ROUTING_DESIGNATOR';
                            END IF;

                            WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                   p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                   p_msg_appl_name      => 'WSM'                    ,
                                                   p_msg_tokens         => l_msg_tokens             ,
                                                   p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                   p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                   p_run_log_level      => l_log_level
                                                  );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
        END;

        l_stmt_num := 30;
        -- Get common routing seq id
        -- No error code is set in find_common_routing... so compare based on x_msg_data..
        wsmputil.find_common_routing( p_routing_sequence_id        => x_rtg_seq_id,
                                      p_common_routing_sequence_id => p_common_rtg_seq_id, --x_common_rtg_seq_id -- VJ: Changed
                                      x_err_code                   => l_err_code,
                                      x_err_msg                    => x_error_msg
                                   );
        if x_error_msg IS NOT NULL then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

    --VJ: Start additions --
    ELSIF p_common_rtg_seq_id IS NOT NULL
    THEN

        BEGIN
            SELECT routing_sequence_id,
                   alternate_routing_designator,
                   completion_subinventory,
                   completion_locator_id
            INTO x_rtg_seq_id,
                 p_alt_rtg,
                 p_default_subinv,
                 p_default_loc_id
            FROM BOM_OPERATIONAL_ROUTINGS
            WHERE common_routing_sequence_id = p_common_rtg_seq_id
            AND organization_id = p_org_id
            AND assembly_item_id = l_rtg_item_id
            AND routing_type = 1
            AND cfm_routing_flag = 3;

        EXCEPTION
            WHEN no_data_found then
                    IF g_log_level_error >= l_log_level OR
                       FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                    THEN
                            l_msg_tokens.delete;
                            l_msg_tokens(1).TokenName := 'FLD_NAME';
                            IF (p_job_type = 1) THEN     -- std job
                                    l_msg_tokens(1).TokenValue := 'PRIMARY_ITEM_ID/COMMON_ROUTING_SEQUENCE_ID';
                            ELSE
                                    l_msg_tokens(1).TokenValue := 'ROUTING_REFERENCE_ID/COMMON_ROUTING_SEQUENCE_ID';
                            END IF;

                            WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                   p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                   p_msg_appl_name      => 'WSM'                    ,
                                                   p_msg_tokens         => l_msg_tokens             ,
                                                   p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                   p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                   p_run_log_level      => l_log_level
                                                  );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
        END;
    END IF; -- end elsif p_common_rtg_seq_id IS NOT NULL
    --VJ: End additions --

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
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
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
                                           p_data       => x_error_msg
                                          );
END routing_seq;


-- Procedure to derive the bom information fields
PROCEDURE bom_seq ( p_job_type              IN              NUMBER,
                    p_org_id                IN              NUMBER,
                    p_item_id               IN              NUMBER,
                    p_alt_bom               IN OUT NOCOPY   VARCHAR2,
                    p_common_bom_seq_id     IN OUT NOCOPY   VARCHAR2,   -- VJ: Added
                    p_bom_ref_id            IN OUT NOCOPY   NUMBER,
                    x_bom_seq_id            OUT    NOCOPY   NUMBER,
                    --x_alt_bom             OUT    NOCOPY   NUMBER,     -- VJ: Deleted
                    --x_common_bom_seq_id   OUT    NOCOPY   NUMBER,     -- VJ: Deleted
                    x_return_status         OUT    NOCOPY   VARCHAR2,
                    x_error_msg             OUT    NOCOPY   VARCHAR2,
                    x_error_count           OUT    NOCOPY   NUMBER
                  ) IS


l_temp_num          number;
l_bom_item_id       number;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.bom_seq';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
    x_return_status     := G_RET_SUCCESS;
    x_error_msg         := NULL;
    x_error_count       := 0;

    l_stmt_num := 10;
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

        l_stmt_num := 15;
        l_param_tbl.delete;

        l_param_tbl(1).paramName := 'p_job_type';
        l_param_tbl(1).paramValue := p_job_type;

        l_param_tbl(2).paramName := 'p_org_id';
        l_param_tbl(2).paramValue := p_org_id;

        l_param_tbl(3).paramName := 'p_item_id';
        l_param_tbl(3).paramValue := p_item_id;

        l_param_tbl(4).paramName := 'p_alt_bom';
        l_param_tbl(4).paramValue := p_alt_bom;

        l_param_tbl(5).paramName := 'p_common_bom_seq_id';
        l_param_tbl(5).paramValue := p_common_bom_seq_id;

        l_param_tbl(6).paramName := 'p_bom_ref_id';
        l_param_tbl(6).paramValue := p_bom_ref_id;

        l_param_tbl(7).paramName := 'x_bom_seq_id';
        l_param_tbl(7).paramValue := x_bom_seq_id;

        WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                  p_param_tbl           => l_param_tbl,
                                  p_fnd_log_level       => l_log_level
                                  );
    END IF;

    l_stmt_num := 20;

    if(p_job_type = 1) then     -- std job
        -- ignore p_bom_ref_id
        p_bom_ref_id  := null;
        l_bom_item_id := p_item_id;
    else -- non-std job
            l_bom_item_id := p_bom_ref_id;
            IF (l_bom_item_id IS NOT NULL) THEN
                   BEGIN
                        SELECT  1
                        INTO    l_temp_num
                        FROM    mtl_system_items_kfv msi
                        WHERE   msi.inventory_item_id = l_bom_item_id
                        AND     msi.organization_id = p_org_id;
                   EXCEPTION
                        WHEN too_many_rows THEN
                                null;
                        WHEN no_data_found THEN
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN
                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'Bom Reference Id';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD'	,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                    END;
            END IF;
    END IF; -- end non-std job

    -- l_bom_item_id can be null for non-std job, cannot be null for std job
    if l_bom_item_id is not null then
             -- Get common_bom_seq_id
             -- if the alternate_bom_designator is NULL, bill_seq_id can have either NULL
             -- when there is no bill defined for the item or the primary bom value. But if
             -- the designator has ALT, then there must be a bill id for the alternate bom.
             if (p_alt_bom is null and
                 p_common_bom_seq_id is null)     --VJ: Added
             then
                        l_stmt_num := 30;
                        begin
                                select  bom.bill_sequence_id,
                                        bom.common_bill_sequence_id
                                into    x_bom_seq_id,
                                        p_common_bom_seq_id --x_common_bom_seq_id   --VJ: Changed
                                from    bom_bill_of_materials bom
                                where   bom.alternate_bom_designator is null
                                and     bom.assembly_item_id = l_bom_item_id
                                and     bom.organization_id = p_org_id;
                        EXCEPTION
                                WHEN no_data_found then
                                        -- this item does not have a primary bill
                                        IF (p_job_type = 1) THEN     -- std job
                                                x_bom_seq_id := null;
                                                p_common_bom_seq_id := null;    --VJ: Changed
                                                --x_common_bom_seq_id := null;  --VJ: Deleted
                                        ELSE    -- non-std job
                                                IF g_log_level_error >= l_log_level OR
                                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                                THEN
                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WIP_BILL_DOES_NOT_EXIST',
                                                                               p_msg_appl_name      => 'WIP'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                END IF;
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;
                        END;

             ELSIF (p_alt_bom is NOT null and p_common_bom_seq_id is null) THEN         --VJ: Added
                        l_stmt_num := 40;
                        BEGIN
                                SELECT  bom.bill_sequence_id,
                                        bom.common_bill_sequence_id
                                INTO    x_bom_seq_id,
                                        p_common_bom_seq_id     --x_common_bom_seq_id   --VJ: Changed
                                FROM    bom_bill_of_materials bom,
                                        bom_alternate_designators bad
                                WHERE   ((bom.alternate_bom_designator is null and
                                          bad.alternate_designator_code is null and
                                          bad.organization_id = -1) or
                                         (bom.alternate_bom_designator
                                            = bad.alternate_designator_code and
                                          bom.organization_id = bad.organization_id))
                                AND     bom.alternate_bom_designator = p_alt_bom
                                AND     bom.assembly_item_id = l_bom_item_id
                                AND     bom.organization_id = p_org_id;
                                -- ST : Bug fix 5107339 : Commented out the validation on bom_alternate_designators.disable_date
                                -- AND     trunc(nvl(bad.disable_date, sysdate + 1)) > trunc(sysdate);
                        EXCEPTION
                                WHEN no_data_found then
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName  := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'ALTERNATE_BOM_DESIGNATOR';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;

             -- VJ : Start Additions --
             ELSIF (p_alt_bom is null and p_common_bom_seq_id is NOT null) THEN
                        l_stmt_num := 50;
                        BEGIN
                                SELECT  bom.bill_sequence_id,
                                        bom.alternate_bom_designator
                                INTO    x_bom_seq_id,
                                        p_alt_bom
                                FROM    bom_bill_of_materials bom
                                WHERE   bom.common_bill_sequence_id = p_common_bom_seq_id
                                AND     bom.assembly_item_id = l_bom_item_id
                                AND     bom.organization_id = p_org_id;

                        EXCEPTION
                                WHEN no_data_found then
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName  := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'COMMON_BOM_SEQUENCE_ID';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
             ELSE --if p_alt_bom is NOT null
                  --   and p_common_bom_seq_id is NOT null
                        l_stmt_num := 60;
                        BEGIN
                                SELECT  1
                                INTO    l_temp_num
                                FROM    bom_bill_of_materials bom
                                WHERE   bom.common_bill_sequence_id = p_common_bom_seq_id
                                AND     bom.alternate_bom_designator = p_alt_bom
                                AND     bom.assembly_item_id = l_bom_item_id
                                AND     bom.organization_id = p_org_id;

                        EXCEPTION
                                WHEN no_data_found then
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName  := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'COMMON_BOM_SEQUENCE_ID';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
             -- VJ : End Additions --
             END IF; -- end (p_alt_bom is null)
    ELSE    -- non-std job without bom reference
             x_bom_seq_id        := null;
             p_common_bom_seq_id := null;   -- x_common_bom_seq_id --VJ: Changed

             IF p_alt_bom IS NOT NULL THEN
                     p_alt_bom := null;  -- ignored
             END IF;
    END IF;

    l_stmt_num := 70;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                p_msg_text          => l_module || ' completed sucessfully',
                                p_stmt_num          => l_stmt_num               ,
                                p_msg_tokens        => l_msg_tokens             ,
                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                p_run_log_level     => l_log_level
                                );
    END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
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
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
                                           p_data       => x_error_msg
                                          );
END;

----------------------------------------------------------------------------------
-- For job creation, wip_entity_id will be ignored, if job_name is NULL, will default
-- Will validate whether the job_name is used or not in the organization
--
-- For job update, wip_entity_id and job_name cannot be NULL together.
-- Wip_entity_id is the driven information, only when wip_entity_id is NULL will
-- job_name be used to get wip_entity_id
-- Will validate the status of the job
--

PROCEDURE wip_entity (    p_load_type             IN              VARCHAR2,  -- C job creation, U job update
                          p_org_id                IN              NUMBER  ,
                          p_wip_entity_id         IN OUT NOCOPY   NUMBER  ,
                          p_job_name              IN OUT NOCOPY   VARCHAR2,
                          x_return_status         OUT    NOCOPY   VARCHAR2,
                          x_error_msg             OUT    NOCOPY   VARCHAR2,
                          x_error_count           OUT    NOCOPY   NUMBER
                     ) is

l_temp_num          number;
l_exists            boolean;
l_job_name_hash     number;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.wip_entity';
l_param_tbl         WSM_Log_PVT.param_tbl_type;

BEGIN

    x_return_status := G_RET_SUCCESS;
    x_error_msg         := NULL;
    x_error_count       := 0;

    l_stmt_num := 10;

    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
        l_stmt_num := 15;

        l_param_tbl.delete;
        l_param_tbl(1).paramName := 'p_org_id';
        l_param_tbl(1).paramValue := p_org_id;

        l_param_tbl(2).paramName := 'p_load_type';
        l_param_tbl(2).paramValue := p_load_type;

        l_param_tbl(3).paramName := 'p_wip_entity_id';
        l_param_tbl(3).paramValue := p_wip_entity_id;

        l_param_tbl(4).paramName := 'p_job_name';
        l_param_tbl(4).paramValue := p_job_name;

        WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                  p_param_tbl           => l_param_tbl,
                                  p_fnd_log_level       => l_log_level
                                  );
    END IF;

    l_stmt_num := 20;

    -- job name should be less than 80 chars
    IF LENGTH(p_job_name) > 80 THEN
        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                       p_msg_name           => 'WSM_JOB_NAME_THIRTY_CHAR',
                                       p_msg_appl_name      => 'WSM',
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_load_type = 'C' then   -- Job creation

        p_wip_entity_id := null; -- Ignore wip_entity_id
        IF p_job_name IS NULL THEN -- Derive Job_Name.
                l_stmt_num := 20;
                SELECT FND_Profile.value('WIP_JOB_PREFIX') || wip_job_number_s.nextval
                INTO   p_job_name
                FROM   dual;
        END IF;

        -- Be sure the provided Job_Name is not already in use.
        l_temp_num := 0;
        BEGIN
               l_stmt_num := 30;
               SELECT 1
               INTO   l_temp_num
               FROM   wip_entities
               WHERE  wip_entity_name = p_job_name
               AND    organization_id = p_org_id;

               IF l_temp_num = 1 then
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WIP_ML_JOB_NAME',
                                                       p_msg_appl_name      => 'WIP',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
               END IF;
        EXCEPTION
            WHEN no_data_found THEN
                 null;

            WHEN OTHERS THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WIP_ML_JOB_NAME',
                                               p_msg_appl_name      => 'WIP',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END;
    END IF; -- Job update

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                p_msg_text          => l_module || ' completed sucessfully',
                                p_stmt_num          => l_stmt_num               ,
                                p_msg_tokens        => l_msg_tokens             ,
                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                p_run_log_level     => l_log_level
                                );
   END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
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
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'            ,
                                           p_count      => x_error_count  ,
                                           p_data       => x_error_msg
                                          );
END wip_entity;

-- Validate the txn header details passed
-- Validate organization, transaction date
Procedure validate_txn_header ( p_wltx_header      IN OUT NOCOPY WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                x_return_status    OUT  NOCOPY  VARCHAR2,
                                x_msg_count        OUT  NOCOPY  NUMBER,
                                x_msg_data         OUT  NOCOPY  VARCHAR2
                                ) IS

     -- Status variables
     l_return_status  VARCHAR2(1);
     l_msg_count      NUMBER;
     l_msg_data       VARCHAR2(2000);

     -- Other locals
     l_dummy                    NUMBER;
     l_txn_org_id               NUMBER;
     l_txn_type                 NUMBER;
     l_err_num                  NUMBER;
     l_err_msg                  VARCHAR2(1000);
     l_acct_period_id           NUMBER;

     l_field_name               VARCHAR2(100);

     -- logging variables
     l_msg_tokens       WSM_log_PVT.token_rec_tbl;
     l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.validate_txn_header';
     l_stmt_num         NUMBER := 0;
BEGIN

    l_stmt_num  := 10;

    x_return_status     := G_RET_SUCCESS;
    x_msg_data          := NULL;
    x_msg_count         := 0;

    -- Log the Procedure entry point....
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered validate_txn_header',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 50;

    -- validate organization_id
    BEGIN

         IF p_wltx_header.organization_id is NULL and p_wltx_header.organization_code is NULL THEN

             -- Both organization code and id cant be NULL
             IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Both Organization_id and organization_code in Split Merge Transactions';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
             END IF;
             RAISE FND_API.G_EXC_ERROR;

         ELSE
            -- If organization code is not NULL then derive ID
            IF p_wltx_header.organization_code  is NULL then

                l_stmt_num := 60;
                l_field_name := 'organization_id';

                -- ST : Performance bug fix 4914162 : Remove the use of org_organization_definitions.
                select organization_code
                into p_wltx_header.organization_code
                -- from org_organization_definitions
                from mtl_parameters
                where (organization_id = p_wltx_header.organization_id );

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => ' Modified the organization_code in the txn header record to : ' || p_wltx_header.organization_code,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;
          ELSE -- p_wltx_header.organization_code  is not NULL
                l_stmt_num := 70;
                l_field_name := 'organization_code';

                -- ST : Performance bug fix 4914162 : Remove the use of org_organization_definitions.
                select organization_id
                into p_wltx_header.organization_id
                -- from org_organization_definitions
                from mtl_parameters
                -- where (organization_name = p_wltx_header.organization_code)
                where organization_code = p_wltx_header.organization_code
                and organization_id = nvl(p_wltx_header.organization_id,organization_id);

                IF( g_log_level_statement   >= l_log_level ) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => ' Modified the organization_id in the txn header record to : ' || p_wltx_header.organization_id,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
           END IF;

           l_stmt_num := 80;

        END IF;

     EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'value for field ' || l_field_name || ' in the txn header record ';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
     END;

     l_stmt_num := 90;

     -- validate transaction_type
     BEGIN
         IF p_wltx_header.transaction_type_id IS NULL THEN

                l_stmt_num := 100;
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Transaction Type in Split Merge Transactions';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
         ELSE --p_wltx_header.transaction_type_id IS NOT NULL

                l_stmt_num := 110;

                select 1
                into l_dummy
                from mfg_lookups mfg
                where mfg.lookup_code = p_wltx_header.transaction_type_id
                and mfg.lookup_type = 'WSM_WIP_LOT_TXN_TYPE';

                l_txn_type := p_wltx_header.transaction_type_id;

                IF( g_log_level_statement   >= l_log_level ) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Valid transaction type'         ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
         END IF;

     EXCEPTION
        WHEN no_data_found then
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := ' value for field transaction_type_id in the txn header record ';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
     END;

     -- validate transaction date
     l_stmt_num := 120;

     IF p_wltx_header.transaction_date IS NULL THEN
                p_wltx_header.transaction_date := SYSDATE;
                IF( g_log_level_statement   >= l_log_level ) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Modified the transaction_date in the txn header record to : ' || p_wltx_header.transaction_date ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

      ELSIF p_wltx_header.transaction_date > SYSDATE THEN
                -- error out...(Transaction date cant be greater than current date)
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'value for the transaction date in the txn header record . Transaction date cannot be greater than current date';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- validate reason_id in wsm_split_merge_txn_interface table
     IF p_wltx_header.reason_id is not null then
         BEGIN
                 l_stmt_num := 130;
                 select 1
                 into l_dummy
                 from mtl_transaction_reasons mtl
                 where mtl.reason_id = p_wltx_header.reason_id
                 and nvl(mtl.disable_date, sysdate+1) > sysdate;

         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'value for field reason_id in the txn header record ';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
          END;
     END IF;

     -- validate acct_period
     BEGIN
        l_stmt_num := 140;
        l_err_num := 0;
        l_err_msg := null;

        -- Invoke the UTIL procedure to check for an open period...
        l_acct_period_id := WSMPUTIL.GET_INV_ACCT_PERIOD(x_err_code        =>  l_err_num,
                                                         x_err_msg         =>  l_err_msg,
                                                         p_organization_id =>  p_wltx_header.organization_id,
                                                         p_date            =>  p_wltx_header.transaction_date);

        l_stmt_num := 150;
        IF (l_err_num <> 0) THEN

                l_stmt_num := 160;
                -- Log the Procedure exit point....
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'WSMPUTIL.GET_INV_ACCT_PERIOD returned failure : ' || l_msg_data ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_ACCT_PERIOD_NOT_OPEN',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        END IF; -- end IF (l_err_num <> 0)
    END;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                p_msg_text          => 'Validation of transaction header success',
                                p_stmt_num          => l_stmt_num               ,
                                p_msg_tokens        => l_msg_tokens             ,
                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                p_run_log_level     => l_log_level
                                );
    END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

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

-- ST : Fix for bug 4351071 --
-- Added this procedure to validate the date information..
-- i)  Txn date >= released_date
-- ii) Txn date > last wip lot txn performed on this job...
Procedure validate_sj_txn_date ( p_txn_date             IN           DATE    ,
                                 p_sj_wip_entity_id     IN           NUMBER  ,
                                 p_sj_wip_entity_name   IN           VARCHAR2,
                                 p_sj_date_released     IN           DATE    ,
                                 x_return_status        OUT  NOCOPY  VARCHAR2,
                                 x_msg_count            OUT  NOCOPY  NUMBER  ,
                                 x_msg_data             OUT  NOCOPY  VARCHAR2
                                ) IS

        l_later_txn_exists NUMBER := 0;

        -- local variable for debug purpose
        l_stmt_num         NUMBER := 0;
        l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
        l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.validate_sj_txn_date';
        l_param_tbl         WSM_Log_PVT.param_tbl_type;

BEGIN

        l_stmt_num := 10;

        x_return_status     := G_RET_SUCCESS;
        x_msg_data          := NULL;
        x_msg_count         := 0;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_param_tbl.delete;

                l_param_tbl(1).paramName := 'p_txn_date';
                l_param_tbl(1).paramValue := p_txn_date;

                l_param_tbl(2).paramName := 'p_sj_wip_entity_id';
                l_param_tbl(2).paramValue := p_sj_wip_entity_id;

                l_param_tbl(3).paramName := 'p_sj_date_released';
                l_param_tbl(3).paramValue := p_sj_date_released;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_stmt_num := 20;
        -- First validate the txn date and the date released..
        IF (p_txn_date < p_sj_date_released) THEN
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'JOB';
                        l_msg_tokens(1).TokenValue := p_sj_wip_entity_name;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                  ,
                                               p_msg_name           => 'WSM_INVALID_TXN_REL_DATE',
                                               p_msg_appl_name      => 'WSM'                     ,
                                               p_msg_tokens         => l_msg_tokens              ,
                                               p_stmt_num           => l_stmt_num                ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR           ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR         ,
                                               p_run_log_level      => l_log_level
                                              );
              END IF;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Next validation is on the max txn date.. should be greater than the last txn performed on the job..
        l_stmt_num := 30;
        BEGIN
                l_later_txn_exists := 0;

                SELECT 1
                INTO   l_later_txn_exists
                FROM   wsm_split_merge_transactions wsmt,
                       wsm_sm_starting_jobs wst
                WHERE  wsmt.transaction_id = wst.transaction_id
                AND    wst.wip_entity_id = p_sj_wip_entity_id
                AND    wsmt.transaction_date > p_txn_date
                AND    rownum = 1;

                -- Error our in this case...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'JOB';
                        l_msg_tokens(1).TokenValue := p_sj_wip_entity_name;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                  ,
                                               p_msg_name           => 'WSM_INVALID_WLT_TXN_DATE',
                                               p_msg_appl_name      => 'WSM'                     ,
                                               p_msg_tokens         => l_msg_tokens              ,
                                               p_stmt_num           => l_stmt_num                ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR           ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR         ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        null;
        END;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

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

END validate_sj_txn_date;

-- derive Validate the starting job info provided by the user
-- Once validation is successful, the non-specified information is filled by the code
Procedure derive_val_st_job_details(    p_txn_org_id                            IN              NUMBER,
                                        p_txn_type                              IN              NUMBER,
                                        -- ST : Added Txn date for bug 4351071
                                        p_txn_date                              IN              DATE,
                                        p_starting_job_rec                      IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                      ) IS

        l_wip_entity_id                 WIP_ENTITIES.wip_entity_id%TYPE                      ;

        -- Cursor to obtain the job specific information
        cursor c_wdj_details_name is
                -- Job specific details
                select  we.wip_entity_id                         ,
                        we.wip_entity_name                       ,
                        wdj.description                          ,
                        wdj.status_type                          ,
                        wdj.primary_item_id                      ,
                        wdj.job_type                             ,
                        wdj.class_code                           ,
                        wdj.date_released                        ,
                        wdj.scheduled_completion_date            ,
                        wdj.scheduled_start_date                 ,
                        wdj.start_quantity                       ,
                        wdj.net_quantity                         ,
                        wdj.bom_reference_id                     ,
                        wdj.routing_reference_id                 ,
                        wdj.common_bom_sequence_id               ,
                        wdj.common_routing_sequence_id           ,
                        wdj.bom_revision                         ,
                        wdj.routing_revision                     ,
                        wdj.bom_revision_date                    ,
                        wdj.routing_revision_date                ,
                        wdj.alternate_bom_designator             ,
                        wdj.alternate_routing_designator         ,
                        wdj.completion_subinventory              ,
                        wdj.completion_locator_id                ,
                        wdj.kanban_card_id                       ,
                        wdj.coproducts_supply                    ,
                        we.organization_id                       ,
                        wdj.serialization_start_op               ,
                        wdj.wip_supply_type
                from wip_discrete_jobs wdj,
                     wip_entities we
                where we.wip_entity_id   = nvl(p_starting_job_rec.wip_entity_id,we.wip_entity_id)
                and   we.wip_entity_name = p_starting_job_rec.wip_entity_name
                and   wdj.wip_entity_id  = we.wip_entity_id
                and   we.organization_id = p_txn_org_id;

        -- Cursor to obtain the job specific information
        cursor c_wdj_details_id is
                -- Job specific details
                select  we.wip_entity_id                         ,
                        we.wip_entity_name                       ,
                        wdj.description                          ,
                        wdj.status_type                          ,
                        wdj.primary_item_id                      ,
                        wdj.job_type                             ,
                        wdj.class_code                           ,
                        wdj.date_released                        ,
                        wdj.scheduled_completion_date            ,
                        wdj.scheduled_start_date                 ,
                        wdj.start_quantity                       ,
                        wdj.net_quantity                         ,
                        wdj.bom_reference_id                     ,
                        wdj.routing_reference_id                 ,
                        wdj.common_bom_sequence_id               ,
                        wdj.common_routing_sequence_id           ,
                        wdj.bom_revision                         ,
                        wdj.routing_revision                     ,
                        wdj.bom_revision_date                    ,
                        wdj.routing_revision_date                ,
                        wdj.alternate_bom_designator             ,
                        wdj.alternate_routing_designator         ,
                        wdj.completion_subinventory              ,
                        wdj.completion_locator_id                ,
                        wdj.kanban_card_id                       ,
                        wdj.coproducts_supply                    ,
                        we.organization_id                       ,
                        wdj.serialization_start_op               ,
                        wdj.wip_supply_type
                from wip_discrete_jobs wdj,
                     wip_entities we
                where wdj.wip_entity_id  = p_starting_job_rec.wip_entity_id
                and   we.wip_entity_name = nvl(p_starting_job_rec.wip_entity_name,we.wip_entity_name)
                and   wdj.wip_entity_id  = we.wip_entity_id
                and   we.organization_id = p_txn_org_id;

        -- This cursor will be used if the current op seq num is provided.
        cursor c_curr_job_info_op is
                select  wo.operation_seq_num,
                        wo.quantity_in_queue,
                        wo.quantity_waiting_to_move,
                        standard_operation_id,
                        operation_sequence_id,
                        department_id,
                        description,
                        nvl(quantity_in_queue,0)+nvl(quantity_waiting_to_move,0) qty_available
                from wip_operations wo
                where wo.organization_id = p_txn_org_id
                and wo.wip_entity_id     = l_wip_entity_id
                and wo.operation_seq_num = p_starting_job_rec.operation_seq_num
                and (nvl(wo.quantity_in_queue,0) > 0 or nvl(wo.quantity_waiting_to_move,0) > 0);

        -- This cursor will be used if the current op seq num is not provided...
        cursor c_curr_job_info is
                select  wo.operation_seq_num,
                        wo.quantity_in_queue,
                        wo.quantity_waiting_to_move,
                        standard_operation_id,
                        operation_sequence_id,
                        department_id,
                        description,
                        nvl(quantity_in_queue,0)+nvl(quantity_waiting_to_move,0) qty_available
                from wip_operations wo
                where wo.organization_id = p_txn_org_id
                and wo.wip_entity_id     = l_wip_entity_id
                and wo.operation_seq_num = operation_seq_num
                and (nvl(wo.quantity_in_queue,0) > 0 or nvl(wo.quantity_waiting_to_move,0) > 0);

        l_wip_entity_name               WIP_ENTITIES.wip_entity_name%TYPE                    ;
        l_description                   WIP_DISCRETE_JOBS.description%TYPE                   ;
        l_status_type                   WIP_DISCRETE_JOBS.status_type%TYPE                   ;
        l_primary_item_id               WIP_DISCRETE_JOBS.primary_item_id%TYPE               ;
        l_job_type                      WIP_DISCRETE_JOBS.job_type%TYPE                      ;
        l_class_code                    WIP_DISCRETE_JOBS.class_code%TYPE                    ;
        l_date_released                 WIP_DISCRETE_JOBS.date_released%TYPE                 ;
        l_scheduled_completion_date     WIP_DISCRETE_JOBS.scheduled_completion_date%TYPE     ;
        l_scheduled_start_date          WIP_DISCRETE_JOBS.scheduled_start_date%TYPE          ;
        l_start_quantity                WIP_DISCRETE_JOBS.start_quantity%TYPE                ;
        l_net_quantity                  WIP_DISCRETE_JOBS.net_quantity%TYPE                  ;
        l_bom_reference_id              WIP_DISCRETE_JOBS.bom_reference_id%TYPE              ;
        l_routing_reference_id          WIP_DISCRETE_JOBS.routing_reference_id%TYPE          ;
        l_common_bom_sequence_id        WIP_DISCRETE_JOBS.common_bom_sequence_id%TYPE        ;
        l_common_routing_sequence_id    WIP_DISCRETE_JOBS.common_routing_sequence_id %TYPE   ;
        l_bom_revision                  WIP_DISCRETE_JOBS.bom_revision%TYPE                  ;
        l_routing_revision              WIP_DISCRETE_JOBS.routing_revision%TYPE              ;
        l_bom_revision_date             WIP_DISCRETE_JOBS.bom_revision_date%TYPE             ;
        l_routing_revision_date         WIP_DISCRETE_JOBS.routing_revision_date%TYPE         ;
        l_alternate_bom_designator      WIP_DISCRETE_JOBS.alternate_bom_designator%TYPE      ;
        l_alternate_routing_designator  WIP_DISCRETE_JOBS.alternate_routing_designator%TYPE  ;
        l_completion_subinventory       WIP_DISCRETE_JOBS.completion_subinventory%TYPE       ;
        l_completion_locator_id         WIP_DISCRETE_JOBS.completion_locator_id%TYPE         ;
        l_kanban_card_id                WIP_DISCRETE_JOBS.kanban_card_id%TYPE                ;
        l_coproducts_supply             WIP_DISCRETE_JOBS.coproducts_supply%TYPE             ;
        l_organization_id               WIP_ENTITIES.organization_id%TYPE                    ;
        l_wip_supply_type               NUMBER                                               ;
        l_serial_track_flag             NUMBER                                               ;

        l_operation_seq_num             NUMBER;
        l_quantity_in_queue             NUMBER;
        l_quantity_waiting_to_move      NUMBER;
        l_standard_operation_id         NUMBER;
        l_operation_sequence_id         NUMBER;
        l_department_id                 NUMBER;
        l_op_description                WIP_OPERATIONS.DESCRIPTION%TYPE;
        l_qty_available                 NUMBER;

        -- Status variables
        l_return_status  VARCHAR2(1);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(2000);

        -- Other locals
        l_qty_in_queue             NUMBER;
        l_qty_to_move              NUMBER;

        l_valid         boolean := false;
        l_field_name    VARCHAR2(100);
        e_invalid_field exception;

        -- local variable for debug purpose
        l_stmt_num         NUMBER := 0;
        l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
        l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_st_job_details';
        l_param_tbl         WSM_Log_PVT.param_tbl_type;

BEGIN
        SAVEPOINT start_def_start_job;

        l_stmt_num := 10;

        x_return_status     := G_RET_SUCCESS;
        x_msg_data          := NULL;
        x_msg_count         := 0;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_stmt_num := 15;
                l_param_tbl.delete;

                l_param_tbl(1).paramName := 'p_txn_org_id';
                l_param_tbl(1).paramValue := p_txn_org_id;

                l_param_tbl(2).paramName := 'p_txn_type';
                l_param_tbl(2).paramValue := p_txn_type;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;
        -- what we'll be doing here is select all the required fields use cursors... and then.... compare....
        -- atleast wip_entity_id/ wip_entity_name is a must.....
        IF p_starting_job_rec.wip_entity_name IS NULL AND p_starting_job_rec.wip_entity_id IS NULL THEN
             -- error out....
             IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Entity id and Entity name';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
              END IF;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 115;
        IF (p_starting_job_rec.wip_entity_name IS NULL) THEN
                l_field_name := ' Wip Entity ID : ' || p_starting_job_rec.wip_entity_id;
                FOR l_wdj_details in c_wdj_details_id LOOP
                        l_valid := true;

                        l_wip_entity_id                 := l_wdj_details.wip_entity_id                ;
                        l_wip_entity_name               := l_wdj_details.wip_entity_name              ;
                        l_description                   := l_wdj_details.description                  ;
                        l_status_type                   := l_wdj_details.status_type                  ;
                        l_primary_item_id               := l_wdj_details.primary_item_id              ;
                        l_job_type                      := l_wdj_details.job_type                     ;
                        l_class_code                    := l_wdj_details.class_code                   ;
                        l_date_released                 := l_wdj_details.date_released                ;
                        l_scheduled_completion_date     := l_wdj_details.scheduled_completion_date    ;
                        l_scheduled_start_date          := l_wdj_details.scheduled_start_date         ;
                        l_start_quantity                := l_wdj_details.start_quantity               ;
                        l_net_quantity                  := l_wdj_details.net_quantity                 ;
                        l_bom_reference_id              := l_wdj_details.bom_reference_id             ;
                        l_routing_reference_id          := l_wdj_details.routing_reference_id         ;
                        l_common_bom_sequence_id        := l_wdj_details.common_bom_sequence_id       ;
                        l_common_routing_sequence_id    := l_wdj_details.common_routing_sequence_id   ;
                        l_bom_revision                  := l_wdj_details.bom_revision                 ;
                        l_routing_revision              := l_wdj_details.routing_revision             ;
                        l_bom_revision_date             := l_wdj_details.bom_revision_date            ;
                        l_routing_revision_date         := l_wdj_details.routing_revision_date        ;
                        l_alternate_bom_designator      := l_wdj_details.alternate_bom_designator     ;
                        l_alternate_routing_designator  := l_wdj_details.alternate_routing_designator ;
                        l_completion_subinventory       := l_wdj_details.completion_subinventory      ;
                        l_completion_locator_id         := l_wdj_details.completion_locator_id        ;
                        l_kanban_card_id                := l_wdj_details.kanban_card_id               ;
                        l_coproducts_supply             := l_wdj_details.coproducts_supply            ;
                        l_organization_id               := l_wdj_details.organization_id              ;
                        l_serial_track_flag             := l_wdj_details.serialization_start_op       ;
                        l_wip_supply_type               := l_wdj_details.wip_supply_type              ;
                END LOOP;
        ELSE   -- (p_starting_job_rec.wip_entity_name IS not null
                l_field_name := 'Wip Entity ID/Wip Entity Name';
                FOR l_wdj_details in c_wdj_details_name LOOP
                        l_valid := true;

                        l_wip_entity_id                 := l_wdj_details.wip_entity_id                ;
                        l_wip_entity_name               := l_wdj_details.wip_entity_name              ;
                        l_description                   := l_wdj_details.description                  ;
                        l_status_type                   := l_wdj_details.status_type                  ;
                        l_primary_item_id               := l_wdj_details.primary_item_id              ;
                        l_job_type                      := l_wdj_details.job_type                     ;
                        l_class_code                    := l_wdj_details.class_code                   ;
                        l_date_released                 := l_wdj_details.date_released                ;
                        l_scheduled_completion_date     := l_wdj_details.scheduled_completion_date    ;
                        l_scheduled_start_date          := l_wdj_details.scheduled_start_date         ;
                        l_start_quantity                := l_wdj_details.start_quantity               ;
                        l_net_quantity                  := l_wdj_details.net_quantity                 ;
                        l_bom_reference_id              := l_wdj_details.bom_reference_id             ;
                        l_routing_reference_id          := l_wdj_details.routing_reference_id         ;
                        l_common_bom_sequence_id        := l_wdj_details.common_bom_sequence_id       ;
                        l_common_routing_sequence_id    := l_wdj_details.common_routing_sequence_id   ;
                        l_bom_revision                  := l_wdj_details.bom_revision                 ;
                        l_routing_revision              := l_wdj_details.routing_revision             ;
                        l_bom_revision_date             := l_wdj_details.bom_revision_date            ;
                        l_routing_revision_date         := l_wdj_details.routing_revision_date        ;
                        l_alternate_bom_designator      := l_wdj_details.alternate_bom_designator     ;
                        l_alternate_routing_designator  := l_wdj_details.alternate_routing_designator ;
                        l_completion_subinventory       := l_wdj_details.completion_subinventory      ;
                        l_completion_locator_id         := l_wdj_details.completion_locator_id        ;
                        l_kanban_card_id                := l_wdj_details.kanban_card_id               ;
                        l_coproducts_supply             := l_wdj_details.coproducts_supply            ;
                        l_organization_id               := l_wdj_details.organization_id              ;
                        l_serial_track_flag             := l_wdj_details.serialization_start_op       ;
                        l_wip_supply_type               := l_wdj_details.wip_supply_type              ;
                END LOOP;
        END IF;
        -- end (p_starting_job_rec.wip_entity_name IS NULL)

        l_stmt_num := 118.1;
        IF l_valid = FALSE THEN
                -- error out...
                raise e_invalid_field;
        END IF;

        -- Currently the below are the Job-related columns that the user can provide through interface...
        --- WIP_ENTITY_ID
        --- OPERATION_SEQ_NUM
        --- INTRAOPERATION_STEP
        --- ROUTING_SEQ_ID
        --- PRIMARY_ITEM_ID
        --- ORGANIZATION_ID

        -- The validation code below is written to validate the above columns...
        -- Add code to validate as and when new columns get exposed to the user to provide more
        -- information about the state of the job prior to a transaction..
        -- Validate the obtained info...
        IF (p_starting_job_rec.primary_item_id IS NOT NULL AND l_primary_item_id <> p_starting_job_rec.primary_item_id)
        THEN
                l_valid := false;
                l_field_name := 'Primary Item Identifier';
                raise e_invalid_field;

        ELSIF (p_starting_job_rec.organization_id IS NOT NULL AND l_organization_id <> p_starting_job_rec.organization_id )
        THEN
                l_valid := false;
                l_field_name := 'Organization Id';
                raise e_invalid_field;
        ELSIF (l_status_type <> WIP_CONSTANTS.RELEASED) THEN
                l_valid := false;
                l_field_name := 'Job Status : Job has to be released to perform WIP Lot Transactions';
                raise e_invalid_field;
        END IF;

        -- ST : Fix for bug 4351071 --
        -- Validate the Txn date information with respect to the job data...
        validate_sj_txn_date (   p_txn_date             => p_txn_date         ,
                                 p_sj_wip_entity_id     => l_wip_entity_id    ,
                                 p_sj_wip_entity_name   => l_wip_entity_name  ,
                                 p_sj_date_released     => l_date_released    ,
                                 x_return_status        => x_return_status    ,
                                 x_msg_count            => x_msg_count        ,
                                 x_msg_data             => x_msg_data
                                );

        IF x_return_status <> G_RET_SUCCESS THEN
                IF x_return_status = G_RET_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;
        -- ST : Fix for bug 4351071 end --

        -- Populate the starting Job record with the obtained information
        p_starting_job_rec.wip_entity_id                  :=  l_wip_entity_id                 ;
        p_starting_job_rec.wip_entity_name                :=  l_wip_entity_name               ;
        p_starting_job_rec.description                    :=  l_description                   ;
        p_starting_job_rec.status_type                    :=  l_status_type                   ;
        p_starting_job_rec.primary_item_id                :=  l_primary_item_id               ;
        p_starting_job_rec.job_type                       :=  l_job_type                      ;
        p_starting_job_rec.class_code                     :=  l_class_code                    ;
        p_starting_job_rec.organization_id                :=  l_organization_id               ;

        -- Date information
        p_starting_job_rec.date_released                  :=  l_date_released                 ;
        p_starting_job_rec.scheduled_completion_date      :=  l_scheduled_completion_date     ;
        p_starting_job_rec.scheduled_start_date           :=  l_scheduled_start_date          ;

        -- Quantity data
        p_starting_job_rec.start_quantity                 :=  l_start_quantity                ;
        p_starting_job_rec.net_quantity                   :=  l_net_quantity                  ;

        -- Bom and routing data
        p_starting_job_rec.bom_reference_id               :=  l_bom_reference_id              ;
        p_starting_job_rec.routing_reference_id           :=  l_routing_reference_id          ;
        p_starting_job_rec.common_bill_sequence_id        :=  l_common_bom_sequence_id        ;
        p_starting_job_rec.common_routing_sequence_id     :=  l_common_routing_sequence_id    ;
        p_starting_job_rec.bom_revision                   :=  l_bom_revision                  ;
        p_starting_job_rec.routing_revision               :=  l_routing_revision              ;
        p_starting_job_rec.bom_revision_date              :=  l_bom_revision_date             ;
        p_starting_job_rec.routing_revision_date          :=  l_routing_revision_date         ;
        p_starting_job_rec.alternate_bom_designator       :=  l_alternate_bom_designator      ;
        p_starting_job_rec.alternate_routing_designator   :=  l_alternate_routing_designator  ;

        -- Subinv information
        p_starting_job_rec.completion_subinventory        :=  l_completion_subinventory       ;
        p_starting_job_rec.completion_locator_id          :=  l_completion_locator_id         ;

        -- Other parameters
        p_starting_job_rec.kanban_card_id                 :=  l_kanban_card_id                ;
        p_starting_job_rec.coproducts_supply              :=  l_coproducts_supply             ;
        p_starting_job_rec.wip_supply_type                :=  l_wip_supply_type               ;
        -- ST : Serial Support Project --
        p_starting_job_rec.serial_track_flag              :=  l_serial_track_flag             ;


        l_stmt_num := 120;
        l_valid := false;
        l_field_name := 'Job Operation Sequence Number';

        -- should validate the current op info.....
        IF (p_starting_job_rec.operation_seq_num IS NULL) THEN

                FOR l_curr_job_info in c_curr_job_info LOOP
                        l_valid := true;
                        l_operation_seq_num             := l_curr_job_info.operation_seq_num            ;
                        l_quantity_in_queue             := l_curr_job_info.quantity_in_queue            ;
                        l_quantity_waiting_to_move      := l_curr_job_info.quantity_waiting_to_move     ;
                        l_standard_operation_id         := l_curr_job_info.standard_operation_id        ;
                        l_operation_sequence_id         := l_curr_job_info.operation_sequence_id        ;
                        l_department_id                 := l_curr_job_info.department_id                ;
                        l_op_description                := l_curr_job_info.description                  ;
                        l_qty_available                 := l_curr_job_info.qty_available                ;
                END LOOP;
        ELSE -- Starting op seq num not null
                FOR l_curr_job_info in c_curr_job_info_op LOOP
                        l_valid := true;
                        l_operation_seq_num             := l_curr_job_info.operation_seq_num            ;
                        l_quantity_in_queue             := l_curr_job_info.quantity_in_queue            ;
                        l_quantity_waiting_to_move      := l_curr_job_info.quantity_waiting_to_move     ;
                        l_standard_operation_id         := l_curr_job_info.standard_operation_id        ;
                        l_operation_sequence_id         := l_curr_job_info.operation_sequence_id        ;
                        l_department_id                 := l_curr_job_info.department_id                ;
                        l_op_description                := l_curr_job_info.description                  ;
                        l_qty_available                 := l_curr_job_info.qty_available                ;
                END LOOP;
        END IF;

        -- Validate the op info....
        IF l_valid = TRUE THEN
                if nvl(l_quantity_in_queue,0) > 0 then
                        -- Validate the current intraperation step provided
                        if nvl(p_starting_job_rec.intraoperation_step,wip_constants.queue) <> wip_constants.queue then
                            l_valid :=false;
                            l_field_name := 'Job Intraoperation Step';
                            raise e_invalid_field;
                        end if;

                        p_starting_job_rec.intraoperation_step := WIP_CONSTANTS.QUEUE;
                elsif nvl(l_quantity_waiting_to_move,0) > 0 then

                        if nvl(p_starting_job_rec.intraoperation_step,wip_constants.tomove) <> wip_constants.tomove then
                            l_valid :=false;
                            l_field_name := 'Job Intraoperation Step';
                            raise e_invalid_field;
                        END IF;
                        p_starting_job_rec.intraoperation_step := WIP_CONSTANTS.TOMOVE;
                END IF;
        ELSE
                RAISE e_invalid_field;
        END IF;

        -- Fill the starting job record with the operation information
        p_starting_job_rec.standard_operation_id       :=  l_standard_operation_id  ;
        p_starting_job_rec.OPERATION_SEQ_ID            :=  l_operation_sequence_id  ;
        p_starting_job_rec.department_id               :=  l_department_id          ;
        p_starting_job_rec.OPERATION_DESCRIPTION       :=  l_op_description         ;
        p_starting_job_rec.quantity_available          :=  l_qty_available          ;
        p_starting_job_rec.operation_seq_num           :=  l_operation_seq_num      ;

        if p_starting_job_rec.standard_operation_id is not null then

             l_stmt_num := 130;
             -- get the standard op code in this case ....
             select operation_code
             into p_starting_job_rec.operation_code
             from bom_standard_operations
             where STANDARD_OPERATION_ID = p_starting_job_rec.standard_operation_id;

        end if;

        if p_txn_type <> WSMPCNST.MERGE THEN

           l_stmt_num := 140;
           p_starting_job_rec.representative_flag := 'Y';
           --'Modified the representative flag to : ' || p_starting_job_rec.representative_flag );

        end if;

        l_stmt_num := 150;

        --  Check for OSP resource.........................................
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Check for OSP resource' ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_stmt_num := 155;
        -- add update BOM also
        IF (p_txn_type in (WSMPCNST.SPLIT,WSMPCNST.UPDATE_ROUTING,WSMPCNST.UPDATE_ASSEMBLY) ) THEN

                 l_stmt_num := 160;
                 -- change the code to call by name
                 IF wip_osp.po_req_exists(p_starting_job_rec.wip_entity_id,
                                          NULL,
                                          p_txn_org_id,
                                          p_starting_job_rec.operation_seq_num,
                                          5
                                          )
                 THEN
                        -- Populate a warning message..........................event
                        IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_OP_PURCHASE_REQ',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_SUCCESS        ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level              ,
                                                       p_wsm_warning        => 1
                                                      );
                         END IF;
                END IF;
        END IF;

        l_stmt_num := 170;
        IF( g_log_level_statement   >= l_log_level ) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                               ,
                                       p_msg_text           => 'Derive validate Starting job success' ,
                                       p_stmt_num           => l_stmt_num                             ,
                                       p_msg_tokens         => l_msg_tokens                           ,
                                       p_fnd_log_level      => g_log_level_statement                  ,
                                       p_run_log_level      => l_log_level
                                      );
        END IF;
        -- the end...

EXCEPTION
        WHEN e_invalid_field  THEN

                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName  := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := l_field_name;

                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName  := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Job State : Verify Starting Job Information provided';

                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_def_start_job;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO start_def_start_job;

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN OTHERS THEN
                 ROLLBACK TO start_def_start_job;
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

-- derive Validate the starting job info ( overloaded for merge )
-- This procedure wuill invoke the derive_val_st_job_details for each of the starting jobs
Procedure derive_val_st_job_details(    p_txn_org_id                            IN              NUMBER,
                                        p_txn_type                              IN              NUMBER,
                                        -- ST : Added Txn date for bug 4351071
                                        p_txn_date                              IN              DATE,
                                        p_starting_jobs_tbl                     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                        p_rep_job_index                         OUT     NOCOPY  NUMBER,
                                        p_total_avail_quantity                  OUT     NOCOPY  NUMBER,
                                        p_total_net_quantity                    OUT     NOCOPY  NUMBER,
                                        -- Added For serial...
                                        x_job_serial_code                       OUT     NOCOPY  NUMBER,
                                        x_return_status                         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count                             OUT     NOCOPY  NUMBER,
                                        x_msg_data                              OUT     NOCOPY  VARCHAR2
                                      ) IS
     -- Status variables
     l_return_status  VARCHAR2(1);
     l_msg_count      NUMBER;
     l_msg_data       VARCHAR2(2000);

     -- Other locals
     l_wip_entity_name  t_wip_entity_name_tbl;

     l_job_type         NUMBER;
     l_std_op_id        NUMBER;
     l_dept_id          NUMBER;
     l_intraop_step     NUMBER;
     l_serial_track     NUMBER := null;
     l_code             NUMBER;

     -- local variable for logging purpose
     l_stmt_num         NUMBER := 0;
     l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
     l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.DERIVE_VAL_ST_JOB_DETAILS';

     -- Loop Variable
     l_counter          NUMBER;


BEGIN
    -- Have a starting point
    savepoint start_val_start_job_merge;

    l_stmt_num := 10;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log the Procedure entry point....
    if( g_log_level_statement   >= l_log_level ) then
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage(p_module_name        => l_module,
                               p_msg_text           => 'Entering the Derive Validate Starting Job procedure for Merge',
                               p_stmt_num           => l_stmt_num,
                               p_msg_tokens         => l_msg_tokens,
                               p_fnd_log_level      => g_log_level_statement,
                               p_run_log_level      => l_log_level
                              );
    End if;

    l_stmt_num := 60;
    p_rep_job_index := -1;
    p_total_avail_quantity := 0;
    p_total_net_quantity   := 0;

    l_counter := p_starting_jobs_tbl.first;
    -- Just loop on one job and compare the first job with all...
    while l_counter is not null loop

                l_stmt_num := 70;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module,
                                               p_msg_text           => 'Calling WSM_WIP_LOT_TXN_PVT.derive_val_st_job_details ',
                                               p_stmt_num           => l_stmt_num,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                -- Invoke the derive_val_st_job_details for the starting job
                derive_val_st_job_details( p_txn_org_id         => p_txn_org_id,
                                           p_txn_type           => WSMPCNST.MERGE,
                                           -- ST : Added Txn date for bug 4351071
                                           p_txn_date           => p_txn_date,
                                           p_starting_job_rec   => p_starting_jobs_tbl(l_counter),
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data
                                          );

                l_stmt_num := 71;

                if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        l_stmt_num := 72;
                        -- Log the Procedure exit point....
                        if( g_log_level_statement   >= l_log_level ) then

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           =>  'WSM_WIP_LOT_TXN_PVT.derive_val_st_job_details returned failure'        ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;

                        if l_return_status <> G_RET_SUCCESS then
                                IF l_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                end if;


                l_stmt_num := 73;

                -- ST : Serial Support --
                select nvl(serial_number_control_code,1)
                into l_code
                from mtl_system_items msi
                where inventory_item_id = p_starting_jobs_tbl(l_counter).primary_item_id
                and   organization_id = p_txn_org_id;

                IF x_job_serial_code IS NULL THEN
                        x_job_serial_code       := l_code;
                END IF;

                IF x_job_serial_code <> l_code THEN
                        -- error out..
                        -- Cannot merge jobs with different item ctrl...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_MERGE_TXN'  ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- ST : Serial Support --

                -- All the starting jobs should be of same job type, and should
                -- have the quantity at the same standard operation and same intraoperation step.
                -- Store these values from the first job and compare for each of the jobs
                if l_job_type is NULL then
                        l_job_type      := p_starting_jobs_tbl(l_counter).job_type;
                end if;

                if l_std_op_id is NULL and p_starting_jobs_tbl(l_counter).standard_operation_id is NOT NULL then
                        l_std_op_id     := p_starting_jobs_tbl(l_counter).standard_operation_id;
                end if;

                if l_dept_id is NULL then
                        l_dept_id       := p_starting_jobs_tbl(l_counter).department_id;
                end if;

                if l_intraop_step is NULL then
                        l_intraop_step  := p_starting_jobs_tbl(l_counter).intraoperation_step;
                end if;

                -- ST : Serial Support --
                IF l_serial_track IS NULL THEN
                        l_serial_track := nvl(p_starting_jobs_tbl(l_counter).serial_track_flag,-1);
                ELSIF l_serial_track <> nvl(p_starting_jobs_tbl(l_counter).serial_track_flag,-1) THEN
                        -- Error out ... cannot managed serial and non-serial tracked jobs.

                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_TRACK_MERGE',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;

                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- ST : Serial Support --

                -- check for duplicate job name
                If l_wip_entity_name.exists(p_starting_jobs_tbl(l_counter).wip_entity_name) THEN

                        l_stmt_num := 75;
                        --error msg
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_CHECK_STLOT_WHILE_MERGE',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                ELSE
                        l_wip_entity_name(p_starting_jobs_tbl(l_counter).wip_entity_name) := 1;
                END IF;

                -- All the jobs must be of same type
                if p_starting_jobs_tbl(l_counter).job_type <> l_job_type then

                        l_stmt_num := 80;
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_DIFF_JOB_TYP_ST',
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

                -- Merge possible only at standard operation
                IF p_starting_jobs_tbl(l_counter).standard_operation_id is NULL then
                          l_stmt_num := 85;
                          IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_NO_MERGE_AT_NSO',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_stmt_num := 90;
                -- Also check for the std_op_id, dept id checks.....
                IF (l_std_op_id <> nvl(p_starting_jobs_tbl(l_counter).standard_operation_id,-1))
                    OR
                   (l_dept_id <> nvl(p_starting_jobs_tbl(l_counter).department_id,-1))
                   OR
                   (l_intraop_step <> nvl(p_starting_jobs_tbl(l_counter).intraoperation_step,-1))
                THEN
                        l_stmt_num := 100;
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_MERGE_SL_STD_OP_ID',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Store the representative job index...
                if p_starting_jobs_tbl(l_counter).representative_flag = 'Y' THEN
                        IF p_rep_job_index = -1 THEN
                                -- assign the rep job index
                                p_rep_job_index := l_counter;
                        ELSE
                              -- error out .. only one rep job
                              l_stmt_num := 110;
                              IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_REPRESENTATIVE_LOT',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                               END IF;
                               RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;

                p_total_avail_quantity := p_total_avail_quantity + p_starting_jobs_tbl(l_counter).quantity_available;
                p_total_net_quantity   := p_total_net_quantity + p_starting_jobs_tbl(l_counter).net_quantity;

                l_counter := p_starting_jobs_tbl.next(l_counter);
     END LOOP;

     IF p_rep_job_index = -1 THEN

          l_stmt_num := 120;
          -- error out as atleast one rep job needed....log error
          IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                       p_msg_name           => 'WSM_REPRESENTATIVE_LOT',
                                       p_msg_appl_name      => 'WSM',
                                       p_msg_tokens         => l_msg_tokens             ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                       p_run_log_level      => l_log_level
                                      );
          END IF;
          RAISE FND_API.G_EXC_ERROR;

     END IF;

     l_stmt_num := 130;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO start_val_start_job_merge;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO start_val_start_job_merge;
                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
        WHEN OTHERS THEN
                ROLLBACK TO start_val_start_job_merge;
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

-- Default resulting job details from the starting job for appropriate fields depending on txn and also validate the appropriate fields
Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                        p_txn_org_id            IN              NUMBER,
                                        p_transaction_date      IN              DATE,
                                        p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                        p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                        x_return_status         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count             OUT     NOCOPY  NUMBER,
                                        x_msg_data              OUT     NOCOPY  VARCHAR2
                                     ) IS
     -- Status variables
     l_return_status  VARCHAR2(1);
     l_msg_count      NUMBER;
     l_msg_data       VARCHAR2(2000);

     -- Other locals
     l_wip_entity_id    number;
     l_exists           number;
     l_costed_flag      boolean;

     l_start_serial_code        NUMBER;
     l_res_serial_code          NUMBER;

	 l_start_op_seq_id       NUMBER;
	 l_end_op_seq_id         NUMBER;
	 l_error_code            NUMBER;

     -- local variable for logging purpose
     l_stmt_num         NUMBER := 0;
     l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
     l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.DERIVE_VAL_RES_JOB_DETAILS';

     -- G_MISS_NUM and G_MISS_CHAR (now use G_NULL_CHAR and equivalents..
     l_null_num               NUMBER      := FND_API.G_NULL_NUM;
     l_null_char              VARCHAR2(1) := FND_API.G_NULL_CHAR;
     l_null_date              date;
     --e_exception            EXCEPTION;

BEGIN

    -- Have a starting point
    l_stmt_num := 10;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log the Procedure entry point....
    if( g_log_level_statement   >= l_log_level ) then
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                               p_msg_text           =>  'Entering the Default validate resulting Jobs'  ,
                               p_stmt_num           => l_stmt_num               ,
                               p_msg_tokens         => l_msg_tokens,
                               p_fnd_log_level      => g_log_level_statement,
                               p_run_log_level      => l_log_level
                              );
    End if;
    l_stmt_num := 40;

    if p_txn_type = WSMPCNST.UPDATE_ASSEMBLY then

        -- Copy all the non-txn related fields

        -- Job name and description
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info .....
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.status_type                      := p_starting_job_rec.status_type;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- Quantity info
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        -- Date info....
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;
        p_resulting_job_rec.wip_supply_type                  := p_starting_job_rec.wip_supply_type;

        -- Obtain item information....
        derive_val_primary_item (  p_txn_org_id         => p_resulting_job_rec.organization_id,
                                   p_old_item_id        => p_starting_job_rec.primary_item_id,
                                   p_new_item_name      => p_resulting_job_rec.item_name,
                                   p_new_item_id        => p_resulting_job_rec.primary_item_id,
                                   x_return_status      => l_return_status,
                                   x_msg_count          => l_msg_count,
                                   x_msg_data           => l_msg_data
                                );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_primary_item returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if ;

        -- ST : Serial Support --
        select nvl(serial_number_control_code,1)
        into l_start_serial_code
        from mtl_system_items msi
        where inventory_item_id = p_starting_job_rec.primary_item_id
        and   organization_id = p_txn_org_id;

        select nvl(serial_number_control_code,1)
        into l_res_serial_code
        from mtl_system_items msi
        where inventory_item_id = p_resulting_job_rec.primary_item_id
        and   organization_id = p_txn_org_id;

        IF l_start_serial_code <> l_res_serial_code then
                -- error out..
                -- Cannot do an update assembly txn as the serial control code differs for the two items..(of starting and resulting job)
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_UPD_ASSY'   ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- ST : Serial Support --

        -- call derive_val_bom_info
        derive_val_bom_info      ( p_txn_org_id                         => p_resulting_job_rec.organization_id,
                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                   p_rj_primary_item_id                 => p_resulting_job_rec.primary_item_id,
                                   p_rj_bom_reference_item              => p_resulting_job_rec.bom_reference_item,
                                   p_rj_bom_reference_id                => p_resulting_job_rec.bom_reference_id,
                                   p_rj_alternate_bom_desig             => p_resulting_job_rec.alternate_bom_designator,
                                   p_rj_common_bom_seq_id               => p_resulting_job_rec.common_bom_sequence_id,
                                   p_rj_bom_revision                    => p_resulting_job_rec.bom_revision,
                                   p_rj_bom_revision_date               => p_resulting_job_rec.bom_revision_date,
                                   x_return_status                      => l_return_status,
                                   x_msg_count                          => l_msg_count,
                                   x_msg_data                           => l_msg_data
                                  );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_bom_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        -- call derive_val_routing_info
        derive_val_routing_info  ( p_txn_org_id                         => p_resulting_job_rec.organization_id,
                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                   p_rj_primary_item_id                 => p_resulting_job_rec.primary_item_id,
                                   p_rj_rtg_reference_item              => p_resulting_job_rec.routing_reference_item,
                                   p_rj_rtg_reference_id                => p_resulting_job_rec.routing_reference_id,
                                   p_rj_alternate_rtg_desig             => p_resulting_job_rec.alternate_routing_designator,
                                   p_rj_common_rtg_seq_id               => p_resulting_job_rec.common_routing_sequence_id,
                                   p_rj_rtg_revision                    => p_resulting_job_rec.routing_revision,
                                   p_rj_rtg_revision_date               => p_resulting_job_rec.routing_revision_date,
                                   x_return_status                      => l_return_status,
                                   x_msg_count                          => l_msg_count,
                                   x_msg_data                           => l_msg_data
                                  );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_routing_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

		-- call WSMPUTIL.find_routing_start to validate first operation in N/W.
		-- added for bug 5386675.

		wsmputil.find_routing_start (p_routing_sequence_id  => p_resulting_job_rec.common_routing_sequence_id,
									 p_routing_rev_date    	=> p_resulting_job_rec.routing_revision_date,
                                     start_op_seq_id        => l_start_op_seq_id,
									 x_err_code             => l_error_code,
									 x_err_msg              => l_msg_data);

        IF l_error_code < 0 THEN
                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module  ,
                                               p_msg_text           => l_msg_data,
                                               p_stmt_num           => l_stmt_num   ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR   ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

                raise FND_API.G_EXC_ERROR;

        end if;

		-- call WSMPUTIL.find_routing_end to validate last operation in N/W.
		-- added for bug 5386675.

        wsmputil.find_routing_end (p_routing_sequence_id  => p_resulting_job_rec.common_routing_sequence_id,
									 p_routing_rev_date   => p_resulting_job_rec.routing_revision_date,
                                     end_op_seq_id        => l_end_op_seq_id,
									 x_err_code           => l_error_code,
									 x_err_msg            => l_msg_data);

        IF l_error_code < 0 THEN
                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module  ,
                                               p_msg_text           => l_msg_data,
                                               p_stmt_num           => l_stmt_num   ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR  ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

                raise FND_API.G_EXC_ERROR;

        end if;

        -- call for the starting op....
        derive_val_starting_op (  p_txn_org_id                  => p_resulting_job_rec.organization_id,
                                  p_curr_op_seq_id              => p_starting_job_rec.operation_seq_id,
                                  p_curr_op_code                => p_starting_job_rec.operation_code,
                                  p_curr_std_op_id              => p_starting_job_rec.standard_operation_id,
                                  p_curr_intra_op_step          => p_starting_job_rec.intraoperation_step,
                                  p_new_comm_rtg_seq_id         => p_resulting_job_rec.common_routing_sequence_id,
                                  p_new_rtg_rev_date            => p_resulting_job_rec.routing_revision_date ,
                                  p_new_op_seq_num              => p_resulting_job_rec.starting_operation_seq_num,
                                  p_new_op_seq_id               => p_resulting_job_rec.starting_operation_seq_id,
                                  p_new_std_op_id               => p_resulting_job_rec.starting_std_op_id,
                                  p_new_op_seq_code             => p_resulting_job_rec.starting_operation_code,
                                  p_new_dept_id                 => p_resulting_job_rec.department_id,
                                  x_return_status               => l_return_status,
                                  x_msg_count                   => l_msg_count,
                                  x_msg_data                    => l_msg_data
                              );

         IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_starting_op returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        -- Always overwrite the starting intraop step for Update Assy txn..
        p_resulting_job_rec.starting_intraoperation_step     := WIP_CONSTANTS.QUEUE;

        -- Completion subinv derivation....
        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_starting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        l_stmt_num := 50;

    elsif p_txn_type = WSMPCNST.UPDATE_ROUTING then

        -- Job name and description
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info .....
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- Quantity info
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        -- Date info....
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;
        p_resulting_job_rec.wip_supply_type                  := p_starting_job_rec.wip_supply_type;

        -- call derive_val_bom_info
        l_stmt_num := 60;
        derive_val_bom_info (  p_txn_org_id                     => p_txn_org_id,
                               p_sj_job_type                    => p_resulting_job_rec.job_type,
                               p_rj_primary_item_id             => p_resulting_job_rec.primary_item_id,
                               p_rj_bom_reference_item          => p_resulting_job_rec.bom_reference_item,
                               p_rj_bom_reference_id            => p_resulting_job_rec.bom_reference_id,
                               p_rj_alternate_bom_desig         => p_resulting_job_rec.alternate_bom_designator,
                               p_rj_common_bom_seq_id           => p_resulting_job_rec.common_bom_sequence_id,
                               p_rj_bom_revision                => p_resulting_job_rec.bom_revision,
                               p_rj_bom_revision_date           => p_resulting_job_rec.bom_revision_date,
                               x_return_status                  => l_return_status,
                               x_msg_count                      => l_msg_count,
                               x_msg_data                       => l_msg_data
                            );


        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_bom_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        l_stmt_num := 70;
        l_return_status := null;
        l_msg_count     := 0;
        l_msg_data      := null;

        -- call derive_val_routing_info
        derive_val_routing_info  ( p_txn_org_id                         => p_resulting_job_rec.organization_id,
                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                   p_rj_primary_item_id                 => p_resulting_job_rec.primary_item_id,
                                   p_rj_rtg_reference_item              => p_resulting_job_rec.routing_reference_item,
                                   p_rj_rtg_reference_id                => p_resulting_job_rec.routing_reference_id,
                                   p_rj_alternate_rtg_desig             => p_resulting_job_rec.alternate_routing_designator,
                                   p_rj_common_rtg_seq_id               => p_resulting_job_rec.common_routing_sequence_id,
                                   p_rj_rtg_revision                    => p_resulting_job_rec.routing_revision,
                                   p_rj_rtg_revision_date               => p_resulting_job_rec.routing_revision_date,
                                   x_return_status                      => l_return_status,
                                   x_msg_count                          => l_msg_count,
                                   x_msg_data                           => l_msg_data
                                  );
        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_routing_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        -- Atleast one of the routing fields must change.. or else error out..
        if (nvl(p_resulting_job_rec.routing_reference_id,-1) = nvl(p_starting_job_rec.routing_reference_id,-1)) and
           (p_resulting_job_rec.common_routing_sequence_id   = p_starting_job_rec.common_routing_sequence_id) and
           (p_resulting_job_rec.alternate_routing_designator = p_starting_job_rec.alternate_routing_designator) and
           (p_resulting_job_rec.routing_revision             = p_starting_job_rec.routing_revision ) and
           (p_resulting_job_rec.routing_revision_date        = p_starting_job_rec.routing_revision_date)
        then
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name=> l_module,
                                               p_msg_name           => 'WSM_NO_ROUTING_CHANGE',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens,
                                               p_stmt_num           => l_stmt_num,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;

		-- call WSMPUTIL.find_routing_start to validate first operation in N/W.
		-- added for bug 5386675.

		wsmputil.find_routing_start (p_routing_sequence_id  => p_resulting_job_rec.common_routing_sequence_id,
									 p_routing_rev_date    	=> p_resulting_job_rec.routing_revision_date,
                                     start_op_seq_id        => l_start_op_seq_id,
									 x_err_code             => l_error_code,
									 x_err_msg              => l_msg_data);

        IF l_error_code < 0 THEN
                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => l_msg_data,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

                raise FND_API.G_EXC_ERROR;

        end if;

		-- call WSMPUTIL.find_routing_end to validate last operation in N/W.
		-- added for bug 5386675.

        wsmputil.find_routing_end (p_routing_sequence_id  => p_resulting_job_rec.common_routing_sequence_id,
									 p_routing_rev_date   => p_resulting_job_rec.routing_revision_date,
                                     end_op_seq_id        => l_end_op_seq_id,
									 x_err_code           => l_error_code,
									 x_err_msg            => l_msg_data);

        IF l_error_code < 0 THEN
                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => l_msg_data,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;

                raise FND_API.G_EXC_ERROR;

        end if;

		-- call for the starting op....
        derive_val_starting_op (  p_txn_org_id                  => p_resulting_job_rec.organization_id,
                                  p_curr_op_seq_id              => p_starting_job_rec.operation_seq_id,
                                  p_curr_op_code                => p_starting_job_rec.operation_code,
                                  p_curr_std_op_id              => p_starting_job_rec.standard_operation_id,
                                  p_curr_intra_op_step          => p_starting_job_rec.intraoperation_step,
                                  p_new_comm_rtg_seq_id         => p_resulting_job_rec.common_routing_sequence_id,
                                  p_new_rtg_rev_date            => p_resulting_job_rec.routing_revision_date ,
                                  p_new_op_seq_num              => p_resulting_job_rec.starting_operation_seq_num,
                                  p_new_op_seq_id               => p_resulting_job_rec.starting_operation_seq_id,
                                  p_new_std_op_id               => p_resulting_job_rec.starting_std_op_id,
                                  p_new_op_seq_code             => p_resulting_job_rec.starting_operation_code,
                                  p_new_dept_id                 => p_resulting_job_rec.department_id,
                                  x_return_status               => l_return_status,
                                  x_msg_count                   => l_msg_count,
                                  x_msg_data                    => l_msg_data
                              );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_starting_op returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        -- Always overwrite the starting intraop step for Update Rtg txn..
        p_resulting_job_rec.starting_intraoperation_step     := WIP_CONSTANTS.QUEUE;

        -- Completion subinv derivation....
        l_return_status := null;
        l_msg_count     := 0;
        l_msg_data      := null;

        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_starting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

         IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
         END IF;

         -- update routing done.....
         l_stmt_num := 60;

    elsif p_txn_type = WSMPCNST.UPDATE_QUANTITY then

        --  Copy all the non-txn related fields
        --  Job name and description
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info .....
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- BOM details ....
        p_resulting_job_rec.bom_reference_id                 := p_starting_job_rec.bom_reference_id;
        p_resulting_job_rec.common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
        p_resulting_job_rec.bom_revision                     := p_starting_job_rec.bom_revision;
        p_resulting_job_rec.bom_revision_date                := p_starting_job_rec.bom_revision_date;
        p_resulting_job_rec.alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

        -- Routing details
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Starting operation details....
        p_resulting_job_rec.starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
        p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
        p_resulting_job_rec.starting_operation_code          := p_starting_job_rec.operation_code;
        p_resulting_job_rec.starting_std_op_id               := p_starting_job_rec.standard_operation_id;
        p_resulting_job_rec.starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;
        p_resulting_job_rec.department_id                    := p_starting_job_rec.department_id;
        p_resulting_job_rec.department_code                  := p_starting_job_rec.department_code;
        p_resulting_job_rec.operation_description            := p_starting_job_rec.operation_description;

        -- Date info....
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;
        p_resulting_job_rec.wip_supply_type                  := p_starting_job_rec.wip_supply_type;

        if (p_resulting_job_rec.start_quantity is null) then
                -- error out as qty info is needed....
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_QTY_INFO_REQUIRED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        IF (p_resulting_job_rec.start_quantity = l_null_num)    OR
           (p_resulting_job_rec.start_quantity <=0 )            OR
           (p_resulting_job_rec.start_quantity <= p_starting_job_rec.quantity_available)
        then
                -- error out....
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_QUANTITY_GREATER',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;

        -- ST : Serial Support Project --
        select nvl(serial_number_control_code,1)
        into l_start_serial_code
        from mtl_system_items msi
        where inventory_item_id = p_starting_job_rec.primary_item_id
        and   organization_id = p_txn_org_id;
        -- ST : Serial Support Project --

        -- Now comes the net qty funda....
        if (p_resulting_job_rec.net_quantity is null) then
                -- have to derive it,.....
                p_resulting_job_rec.net_quantity := round(( (p_resulting_job_rec.start_quantity/p_starting_job_rec.quantity_available)*p_starting_job_rec.net_quantity ),6);

                if p_resulting_job_rec.net_quantity > p_resulting_job_rec.start_quantity then
                        p_resulting_job_rec.net_quantity := p_resulting_job_rec.start_quantity;
                end if;
                -- ST : Serial Support Project --
                IF l_start_serial_code = 2 THEN
                        p_resulting_job_rec.net_quantity := floor(p_resulting_job_rec.net_quantity);
                END IF;
                -- ST : Serial Support Project --

        elsif (p_resulting_job_rec.net_quantity = l_null_num)   or
              (p_resulting_job_rec.net_quantity < 0 )           or
              (p_resulting_job_rec.net_quantity > p_resulting_job_rec.start_quantity)
        then
              -- error out...
              IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := ' Net Quantity';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
              END IF;
              raise FND_API.G_EXC_ERROR;
        end if;

        IF (l_start_serial_code = 2) AND
           (  p_resulting_job_rec.start_quantity <> floor(p_resulting_job_rec.start_quantity)    OR
              p_resulting_job_rec.net_quantity <> floor(p_resulting_job_rec.net_quantity)
           )
        THEN
                -- error out...-- has to be an integer...
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- ST : Serial Support Project --

        -- account information......
        if (p_resulting_job_rec.BONUS_ACCT_ID is null) then
                -- error out... has to be provided...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'BONUS_ACCT_ID';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                 END IF;
                 raise FND_API.G_EXC_ERROR;
        else
                -- validate the account passed,,,,,
                BEGIN
                       select 1
                       into   l_exists
                       from   gl_code_combinations gcc,
                              -- ST : Performance bug fix 4914162 : Remove the use of org_organization_definitions.
                              -- org_organization_definitions ood
                              hr_organization_information hoi,
                              gl_sets_of_books gsob
                       -- where  p_resulting_job_rec.organization_id = ood.organization_id
                       where  p_resulting_job_rec.organization_id = hoi.organization_id
                       -- and ood.chart_of_accounts_id = gcc.chart_of_accounts_id
                       and    gsob.chart_of_accounts_id = gcc.chart_of_accounts_id
                       and    nvl (p_resulting_job_rec.bonus_acct_id, -1) = gcc.code_combination_id
                       and    gcc.enabled_flag = 'Y'
                       and    p_transaction_date between nvl(gcc.start_date_active, p_transaction_date)
                                                               and nvl(gcc.end_date_active, p_transaction_date)
                       and    gsob.set_of_books_id = TO_NUMBER(DECODE(RTRIM(TRANSLATE(hoi.org_information1,'0123456789',' ')),
                                                                NULL,
                                                                hoi.org_information1,
                                                                -99999))
                       and    hoi.org_information_context || '' = 'Accounting Information';

                EXCEPTION
                        when no_data_found then
                                -- error out.... --
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                         l_msg_tokens(1).TokenName := 'FLD_NAME';
                                         l_msg_tokens(1).TokenValue := 'BONUS_ACCT_ID';
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                             ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;

                END;

        end if;

        -- Completion subinv derivation....
        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        -- update qty is done..... */
        l_stmt_num := 70;

    elsif p_txn_type = WSMPCNST.UPDATE_LOT_NAME then

        -- The only fields that the user can specify is Job name and Description */

        -- Primary info ..... --
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.status_type                      := p_starting_job_rec.status_type;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- BOM details .... --
        p_resulting_job_rec.bom_reference_id                 := p_starting_job_rec.bom_reference_id;
        p_resulting_job_rec.common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
        p_resulting_job_rec.bom_revision                     := p_starting_job_rec.bom_revision;
        p_resulting_job_rec.bom_revision_date                := p_starting_job_rec.bom_revision_date;
        p_resulting_job_rec.alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

        -- Routing details --
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Quantity info --
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        /* Bugfix 5531371 CSI/locator can be updated */
        -- Completion sub inv details.... --
        --p_resulting_job_rec.completion_subinventory          := p_starting_job_rec.completion_subinventory;
        --p_resulting_job_rec.completion_locator_id            := p_starting_job_rec.completion_locator_id;
        /* End Bugfix 5531371 */

        -- Starting operation details....--
        p_resulting_job_rec.starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
        p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
        p_resulting_job_rec.starting_operation_code          := p_starting_job_rec.operation_code;
        p_resulting_job_rec.starting_std_op_id               := p_starting_job_rec.standard_operation_id;
        p_resulting_job_rec.starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;
        p_resulting_job_rec.department_id                    := p_starting_job_rec.department_id;
        p_resulting_job_rec.department_code                  := p_starting_job_rec.department_code;
        p_resulting_job_rec.operation_description            := p_starting_job_rec.operation_description;

        -- Date info....--
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....--
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;
        p_resulting_job_rec.wip_supply_type                  := p_starting_job_rec.wip_supply_type;

        -- Job name and description --
        p_resulting_job_rec.wip_entity_name   :=  nvl(p_resulting_job_rec.wip_entity_name,p_starting_job_rec.wip_entity_name);
        p_resulting_job_rec.description       :=  nvl(p_resulting_job_rec.description,p_starting_job_rec.description);

        if (p_resulting_job_rec.wip_entity_name = l_null_char) OR
           (p_resulting_job_rec.wip_entity_name IS NULL)
        then
                -- error out.... --
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'wip_entity_name';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        -- if the user intends to NULL out the field null it..
        if p_resulting_job_rec.description = l_null_char then
            p_resulting_job_rec.description := null;
        end if;

        -- check if atleast one has changed ..... --
        if (p_resulting_job_rec.wip_entity_name = p_starting_job_rec.wip_entity_name)    and
           (nvl(p_resulting_job_rec.description,'-1') = nvl(p_starting_job_rec.description,'-1'))
        then
                -- error out as atleast one has to change --
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_NO_JOB_CHANGE',
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

        if (p_resulting_job_rec.wip_entity_name <> p_starting_job_rec.wip_entity_name) then
                -- check for the validity of the job name,,, --
                l_wip_entity_id := p_resulting_job_rec.wip_entity_id;
                wip_entity( p_load_type         => 'U',
                            p_org_id            => p_resulting_job_rec.organization_id,
                            p_wip_entity_id     => l_wip_entity_id,
                            p_job_name          => p_resulting_job_rec.wip_entity_name,
                            x_return_status     => l_return_status,
                            x_error_msg         => l_msg_data,
                            x_error_count       => l_msg_count
                          );
                -- add check for the return status...
                if l_return_status <> G_RET_SUCCESS then
                        IF l_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

        /* Start Bugfix 5531371 validate csi/locator updation during upd lot name */
        -- Completion subinv derivation....
        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;
        /* End Bugfix 5531371 */

        -- update lot name complete.....--
         l_stmt_num := 90;

    elsif (p_txn_type = 8) then -- WSMPCNST.UPDATE_COMPL_SUBINV

        -- The only fields that the user can specify is completion subinv. locator, locator id

        -- Job name and description --
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info ..... --
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- BOM details .... --
        p_resulting_job_rec.bom_reference_id                 := p_starting_job_rec.bom_reference_id;
        p_resulting_job_rec.common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
        p_resulting_job_rec.bom_revision                     := p_starting_job_rec.bom_revision;
        p_resulting_job_rec.bom_revision_date                := p_starting_job_rec.bom_revision_date;
        p_resulting_job_rec.alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

        -- Routing details --
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Quantity info --
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        -- Starting operation details....--
        p_resulting_job_rec.starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
        p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
        p_resulting_job_rec.starting_operation_code          := p_starting_job_rec.operation_code;
        p_resulting_job_rec.starting_std_op_id               := p_starting_job_rec.standard_operation_id;
        p_resulting_job_rec.starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;
        p_resulting_job_rec.department_id                    := p_starting_job_rec.department_id;
        p_resulting_job_rec.department_code                  := p_starting_job_rec.department_code;
        p_resulting_job_rec.operation_description            := p_starting_job_rec.operation_description;

        -- Date info....--
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....--
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;

        if (p_resulting_job_rec.completion_subinventory is null)  and
           (p_resulting_job_rec.completion_locator_id is null)   and
           (p_resulting_job_rec.completion_locator is null)
        then
                -- error out,,
                null;
        end if;

        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );


        if (nvl(p_resulting_job_rec.completion_subinventory,'-1') = nvl(p_resulting_job_rec.completion_subinventory,'-1'))   and
           (nvl(p_resulting_job_rec.completion_locator_id,-10) = nvl(p_starting_job_rec.completion_locator_id,-10))
        then
                -- error out..
                null;
        end if;

    ELSIF p_txn_type = 9 THEN --WSMPCNST.UPDATE_STATUS--
        --- copy all fields except for status type...
        -- Job name and description --
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info ..... --
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- BOM details .... --
        p_resulting_job_rec.bom_reference_id                 := p_starting_job_rec.bom_reference_id;
        p_resulting_job_rec.common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
        p_resulting_job_rec.bom_revision                     := p_starting_job_rec.bom_revision;
        p_resulting_job_rec.bom_revision_date                := p_starting_job_rec.bom_revision_date;
        p_resulting_job_rec.alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

        -- Routing details --
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Quantity info --
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        -- Completion sub inv details.... Non Updatable.... --
        p_resulting_job_rec.completion_subinventory          := p_starting_job_rec.completion_subinventory;
        p_resulting_job_rec.completion_locator_id            := p_starting_job_rec.completion_locator_id;

        -- Starting operation details....--
        p_resulting_job_rec.starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
        p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
        p_resulting_job_rec.starting_operation_code          := p_starting_job_rec.operation_code;
        p_resulting_job_rec.starting_std_op_id               := p_starting_job_rec.standard_operation_id;
        p_resulting_job_rec.starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;
        p_resulting_job_rec.department_id                    := p_starting_job_rec.department_id;
        p_resulting_job_rec.department_code                  := p_starting_job_rec.department_code;
        p_resulting_job_rec.operation_description            := p_starting_job_rec.operation_description;

        -- Date info....--
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....--
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;

        -- different status_type values
        --   7 Cancelled
        --   8 Pending Bill Load
        --   9 Failed Bill Load
        --   10 Pending Routing Load
        --   11 Failed Routing Load
        --   12 Closed
        --   13 Pending - Mass Loaded
        --   14 Pending Close
        --   15 Failed Close
        --   1 Unreleased
        --   3 Released
        --   4 Complete
        --   5 Complete - No Charges
        --   6 On Hold

        -- Jobs that are On Hold, Cancelled, Failed To Close will be considered 'released' if they have a non-null date_released field --

        if (p_resulting_job_rec.status_type is null)    or
           (p_resulting_job_rec.status_type = l_null_num)
        then
                -- error out..... --
                null;
        end if;

        if p_resulting_job_rec.status_type = p_starting_job_rec.status_type then
                -- error out.... --
                null;
        end if;

        l_costed_flag := WSM_LBJ_Interface_PVT.discrete_charges_exist(  p_wip_entity_id   => p_resulting_job_rec.wip_entity_id,
                                                                        p_organization_id => p_resulting_job_rec.organization_id,
                                                                        p_check_mode      => 0
                                                                    );

        -- allowed changes.... --
        if p_starting_job_rec.status_type = 3 then
                -- Job is released..... --
                if p_resulting_job_rec.status_type not in (1, 6, 7 ) then
                        -- error out... --
                        null;
                end if;

                if l_costed_flag and p_resulting_job_rec.status_type = 1 then
                        -- error out.... --
                        null;
                end if;

        elsif p_starting_job_rec.status_type = 6 then

                -- Job onhold --
                if p_resulting_job_rec.status_type not in (1,3,7) then
                        -- error out... --
                        null;
                end if;

                -- Now also check based on the date_released.... --
                if (p_resulting_job_rec.status_type in (1,7) and p_starting_job_rec.date_released is null)
                   or
                   (p_resulting_job_rec.status_type=3 and l_costed_flag = false and p_starting_job_rec.date_released is null)
                then
                        -- error out.... --
                        null;
                end if;

        elsif p_starting_job_rec.status_type = 7 then

                -- Job Cancelled --
                if p_resulting_job_rec.status_type not in (1,3,6) then
                        -- error out... --
                        null;
                end if;

                -- Now also check based on the date_released.... --
                if (p_resulting_job_rec.status_type in (1,6) and p_starting_job_rec.date_released is null)
                   or
                   (p_resulting_job_rec.status_type=3 and l_costed_flag = false and p_starting_job_rec.date_released is null)
                then
                        -- error out.... --
                        null;
                end if;

        elsif p_starting_job_rec.status_type = 15 then

                -- Job Failedtoclose --
                if p_resulting_job_rec.status_type not in (1,3,4,6,7) then
                        -- error out... --
                        null;
                end if;

                -- Now also check based on the date_released.... --
                if (p_resulting_job_rec.status_type in (1,6,7) and p_starting_job_rec.date_released is null)
                   or
                   (p_resulting_job_rec.status_type=3 and l_costed_flag = false and p_starting_job_rec.date_released is null)
                then
                        -- error out.... --
                        null;
                end if;

        else
                -- error out,..... --
                null;
        end if;

    elsif p_txn_type = 10  then -- WSMPCNST.UPDATE_BOM*

        --  this section is incomplete... will update it at the end.... --

        -- copy all fields except for bom related ...
        -- Job name and description --
        p_resulting_job_rec.wip_entity_name   :=  p_starting_job_rec.wip_entity_name;
        p_resulting_job_rec.description       :=  p_starting_job_rec.description;

        -- Primary info ..... --
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;

        -- Routing details --
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Quantity info --
        p_resulting_job_rec.start_quantity                   := p_starting_job_rec.start_quantity;
        p_resulting_job_rec.net_quantity                     := p_starting_job_rec.net_quantity;

        -- Date info....
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....
        p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;



        if (p_resulting_job_rec.bom_reference_id         = l_null_num ) and
           (p_resulting_job_rec.bom_reference_item       = l_null_char) and
           (p_resulting_job_rec.common_bom_sequence_id   = l_null_num)  and
           (p_resulting_job_rec.bom_revision             = l_null_char) and
           (p_resulting_job_rec.bom_revision_date        = l_null_date) and
           (p_resulting_job_rec.alternate_bom_designator = l_null_char)
        then
                -- user wants to detach the BOM....
                null;
        else

                -- call derive_val_BOM procedure
                derive_val_bom_info ( p_txn_org_id                      => p_resulting_job_rec.organization_id,
                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                   p_rj_primary_item_id                 => p_resulting_job_rec.primary_item_id,
                                   p_rj_bom_reference_item              => p_resulting_job_rec.bom_reference_item,
                                   p_rj_bom_reference_id                => p_resulting_job_rec.bom_reference_id,
                                   p_rj_alternate_bom_desig             => p_resulting_job_rec.alternate_bom_designator,
                                   p_rj_common_bom_seq_id               => p_resulting_job_rec.common_bom_sequence_id,
                                   p_rj_bom_revision                    => p_resulting_job_rec.bom_revision,
                                   p_rj_bom_revision_date               => p_resulting_job_rec.bom_revision_date,
                                   x_return_status                      => l_return_status,
                                   x_msg_count                          => l_msg_count,
                                   x_msg_data                           => l_msg_data
                                  );

                if (nvl(p_resulting_job_rec.bom_reference_id,-1)                      = nvl(p_resulting_job_rec.bom_reference_id,-1)) and
                   (nvl(p_resulting_job_rec.common_bom_sequence_id,-1)                = nvl(p_resulting_job_rec.common_bom_sequence_id,-1)  ) and
                   (nvl(p_resulting_job_rec.alternate_bom_designator,'-1')            = nvl(p_resulting_job_rec.alternate_bom_designator,'-1')) and
                   (nvl(p_resulting_job_rec.bom_revision,'-1')                        = nvl(p_resulting_job_rec.bom_revision,'-1') ) and
                   (nvl(p_resulting_job_rec.bom_revision_date,l_null_date)            = nvl(p_resulting_job_rec.bom_revision_date,l_null_date))
                then
                        -- error out....
                        null;
                end if;

                p_resulting_job_rec.starting_operation_seq_num       := null;
                p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
                p_resulting_job_rec.starting_operation_code          := null;
                p_resulting_job_rec.starting_std_op_id               := null;
                p_resulting_job_rec.department_id                    := null;
                p_resulting_job_rec.department_code                  := null;
                p_resulting_job_rec.operation_description            := null;

                p_resulting_job_rec.starting_operation_seq_id := p_starting_job_rec.operation_seq_id;

                -- call for the starting op....
                derive_val_starting_op (  p_txn_org_id                  => p_resulting_job_rec.organization_id,
                                          p_curr_op_seq_id              => p_starting_job_rec.operation_seq_id,
                                          p_curr_op_code                => p_starting_job_rec.operation_code,
                                          p_curr_std_op_id              => p_starting_job_rec.standard_operation_id,
                                          p_curr_intra_op_step          => p_starting_job_rec.intraoperation_step,
                                          p_new_comm_rtg_seq_id         => p_resulting_job_rec.common_routing_sequence_id,
                                          p_new_rtg_rev_date            => p_resulting_job_rec.routing_revision_date ,
                                          p_new_op_seq_num              => p_resulting_job_rec.starting_operation_seq_num,
                                          p_new_op_seq_id               => p_resulting_job_rec.starting_operation_seq_id,
                                          p_new_std_op_id               => p_resulting_job_rec.starting_std_op_id,
                                          p_new_op_seq_code             => p_resulting_job_rec.starting_operation_code,
                                          p_new_dept_id                 => p_resulting_job_rec.department_id,
                                          x_return_status               => l_return_status,
                                          x_msg_count                   => l_msg_count,
                                          x_msg_data                    => l_msg_data
                                      );

                -- Completion subinv derivation....
                derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                         p_old_rtg_seq_id                       => p_starting_job_rec.common_routing_sequence_id,
                                         p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                         p_organization_id                      => p_resulting_job_rec.organization_id,
                                         p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                         p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                         p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                         -- ST : Bug fix 5094555 start
                                         p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                         p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                         -- ST : Bug fix 5094555 end
                                         p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                         p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                         p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                         x_return_status                        => l_return_status,
                                         x_msg_count                            => l_msg_count,
                                         x_msg_data                             => l_msg_data
                                      );
        end if;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get ( p_encoded   => 'F'          ,
                                            p_count     => x_msg_count  ,
                                            p_data      => x_msg_data
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
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
                                           p_data       => x_msg_data
                                          );

END;

-- Default resulting job details for merge txn --
Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                        p_txn_org_id            IN              NUMBER,
                                        p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                        p_job_quantity          IN              NUMBER,
                                        p_job_net_quantity      IN              NUMBER,
                                        -- ST : Serial Support : Added the below parameter..
                                        p_job_serial_code       IN              NUMBER,
                                        p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                        x_return_status         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count             OUT     NOCOPY  NUMBER,
                                        x_msg_data              OUT     NOCOPY  VARCHAR2
                                    ) is

l_return_status         varchar2(1);
l_msg_count             number;
l_msg_data              varchar2(2000);
--logging variables--
l_module           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_res_job_details';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;

l_null_char             varchar2(10)  := FND_API.G_NULL_CHAR;

begin
        l_stmt_num := 10;
        if p_txn_type <> WSMPCNST.MERGE then
                --error out... --
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Transaction Type not Merge';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        -- Primary info ..... --
        p_resulting_job_rec.wip_entity_id                    := p_starting_job_rec.wip_entity_id;
        p_resulting_job_rec.status_type                      := p_starting_job_rec.status_type;
        p_resulting_job_rec.item_name                        := p_starting_job_rec.item_name;
        p_resulting_job_rec.primary_item_id                  := p_starting_job_rec.primary_item_id;
        p_resulting_job_rec.class_code                       := p_starting_job_rec.class_code;
        p_resulting_job_rec.job_type                         := p_starting_job_rec.job_type;
        p_resulting_job_rec.organization_id                  := p_starting_job_rec.organization_id;
        p_resulting_job_rec.organization_code                := p_starting_job_rec.organization_code;
        p_resulting_job_rec.wip_supply_type                  := p_starting_job_rec.wip_supply_type;

        -- BOM details .... --
        p_resulting_job_rec.bom_reference_id                 := p_starting_job_rec.bom_reference_id;
        p_resulting_job_rec.common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
        p_resulting_job_rec.bom_revision                     := p_starting_job_rec.bom_revision;
        p_resulting_job_rec.bom_revision_date                := p_starting_job_rec.bom_revision_date;
        p_resulting_job_rec.alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

        -- Routing details --
        p_resulting_job_rec.routing_reference_id             := p_starting_job_rec.routing_reference_id;
        p_resulting_job_rec.common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
        p_resulting_job_rec.routing_revision                 := p_starting_job_rec.routing_revision;
        p_resulting_job_rec.routing_revision_date            := p_starting_job_rec.routing_revision_date;
        p_resulting_job_rec.alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

        -- Starting operation details....--
        p_resulting_job_rec.starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
        p_resulting_job_rec.starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
        p_resulting_job_rec.starting_operation_code          := p_starting_job_rec.operation_code;
        p_resulting_job_rec.starting_std_op_id               := p_starting_job_rec.standard_operation_id;
        p_resulting_job_rec.starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;
        p_resulting_job_rec.department_id                    := p_starting_job_rec.department_id;
        p_resulting_job_rec.department_code                  := p_starting_job_rec.department_code;
        p_resulting_job_rec.operation_description            := p_starting_job_rec.operation_description;

        -- Date info....--
        p_resulting_job_rec.scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
        p_resulting_job_rec.scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

        -- Other parameters....--
        -- ST : Commenting out for bug 5122500 --
        -- p_resulting_job_rec.coproducts_supply                := p_starting_job_rec.coproducts_supply;

        -- Job name and description --
        p_resulting_job_rec.wip_entity_name   :=  nvl(p_resulting_job_rec.wip_entity_name,p_starting_job_rec.wip_entity_name);
        p_resulting_job_rec.description       :=  nvl(p_resulting_job_rec.description,p_starting_job_rec.description);

        if (p_resulting_job_rec.wip_entity_name = l_null_char)
        then
                -- error out.... --
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'wip_entity_name';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        -- description....... --
        if p_resulting_job_rec.description = l_null_char then
                p_resulting_job_rec.description := null;
        end if;

        l_stmt_num := 20;
        if (p_resulting_job_rec.wip_entity_name <> p_starting_job_rec.wip_entity_name) then

                -- Validate the Job name...
                wip_entity(p_load_type         => 'C',
                           p_org_id            => p_resulting_job_rec.organization_id,
                           p_wip_entity_id     => p_resulting_job_rec.wip_entity_id,   -- will make it null....
                           p_job_name          => p_resulting_job_rec.wip_entity_name,
                           x_return_status     => l_return_status,
                           x_error_msg         => l_msg_data,
                           x_error_count       => l_msg_count
                          );
                p_resulting_job_rec.wip_entity_id := null;

                if l_return_status <> G_RET_SUCCESS then
                        IF l_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

        l_stmt_num := 21;
        -- ST : Fix for bug 5122500 start --
        --  Co products supply start --
        IF p_resulting_job_rec.wip_entity_name = p_starting_job_rec.wip_entity_name THEN

                IF p_resulting_job_rec.coproducts_supply IS NULL THEN
                        p_resulting_job_rec.coproducts_supply := p_starting_job_rec.coproducts_supply;
                END IF;

        ELSE -- new job.....---
                IF p_resulting_job_rec.coproducts_supply IS NULL THEN
                        -- Query up the co-products supply..... --
                        SELECT decode(coproducts_supply_default, NULL, 2
                                        , coproducts_supply_default)
                        INTO  p_resulting_job_rec.coproducts_supply
                        FROM  wsm_parameters
                        WHERE organization_id = p_txn_org_id;
                END IF;
        END IF;

        l_stmt_num := 25;
        IF NVL(p_resulting_job_rec.coproducts_supply,0) NOT IN(1,2) THEN
                --error out.... --
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenName := 'CoProducts Supply';

                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        END IF;
        ---  Co products supply end --
        -- ST : Fix for bug 5122500 end --

        l_stmt_num := 30;
        -- quantity stuff... --
        p_resulting_job_rec.start_quantity     := p_job_quantity;
        --Bug 5375741: Before defaulting the net quantity,user supplied value should be validated.
        --p_resulting_job_rec.net_quantity       := nvl(p_resulting_job_rec.net_quantity,p_job_net_quantity);

        if p_resulting_job_rec.net_quantity > p_resulting_job_rec.start_quantity then
                -- error out,.,,,, --
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_NET_QTY_MORE_START_QTY',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;
        --Bug 5375741: If user has not supplied net quantity,default it to total net qty of the starting jobs.
        --If total net quantity is greater than available qty of the resulting job,default net qty to
        --available quantity.
        p_resulting_job_rec.net_quantity       := nvl(p_resulting_job_rec.net_quantity,p_job_net_quantity);
        if  p_resulting_job_rec.net_quantity > p_resulting_job_rec.start_quantity then
            p_resulting_job_rec.net_quantity := p_resulting_job_rec.start_quantity;
        end if;

        -- ST : Serial Support Project --
        IF p_job_serial_code = 2 AND
           (p_resulting_job_rec.net_quantity <> floor(p_resulting_job_rec.net_quantity))
        THEN
                -- error out...
                -- has to be an integer...
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- ST : Serial Support Project --

        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_resulting_job_rec.organization_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                 p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

        IF l_return_status <> G_RET_SUCCESS THEN
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
exception
        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
END;



-- Default resulting job details from the starting job for appropriate fields depending on txn ( overloaded for split) --
Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                        p_txn_org_id            IN              NUMBER,
                                        p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                        p_resulting_jobs_tbl    IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                        x_return_status         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count             OUT     NOCOPY  NUMBER,
                                        x_msg_data              OUT     NOCOPY  VARCHAR2
                                    ) is

l_return_status         varchar2(1);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_module_name           VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_res_job_details';
l_null_char             varchar2(10)  := FND_API.G_NULL_CHAR;

l_counter               number;
l_job_name_tbl          t_wip_entity_name_tbl;

l_total_quantity        number := 0;
l_coproducts_supply     number;
l_start_serial_code     NUMBER;
l_res_serial_code       NUMBER;

l_start_op_seq_id       NUMBER;
l_end_op_seq_id         NUMBER;
l_error_code            NUMBER;

-- Variable indicating the index of the starting job is also a resulting job.. --
l_start_as_result   NUMBER := -1;

--logging variables --
l_module              VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_res_job_details';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;

begin
        l_stmt_num := 10;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered derive_val_res_job_details for split'   ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        if p_txn_type <> WSMPCNST.SPLIT then
                -- error out....--
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Transaction Type Not Split';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 20;
        -- Query up the co-products supply..... --
        SELECT decode(coproducts_supply_default, NULL, 2
                    , coproducts_supply_default)
        INTO  l_coproducts_supply
        FROM  wsm_parameters
        WHERE organization_id = p_txn_org_id;
        l_stmt_num := 25;

        -- ST : Serial Support Project --
        select nvl(serial_number_control_code,1)
        into l_start_serial_code
        from mtl_system_items msi
        where inventory_item_id = p_starting_job_rec.primary_item_id
        and   organization_id = p_txn_org_id;
        -- ST : Serial Support Project --

        l_stmt_num := 30;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Before loop on resulting jobs'  ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        -- loop on the resulting records,,,, --
        l_counter := p_resulting_jobs_tbl.first;
        while l_counter is not null loop

                -- Job name / ID start
                if (p_resulting_jobs_tbl(l_counter).wip_entity_id is null) and
                   (p_resulting_jobs_tbl(l_counter).wip_entity_name is null)
                then
                        -- error out..... as both cant be NULL--
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'Entity id and name ';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_NULL_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 40;
                if p_resulting_jobs_tbl(l_counter).wip_entity_name is not null then

                        if p_resulting_jobs_tbl(l_counter).wip_entity_name = p_starting_job_rec.wip_entity_name then
                                p_resulting_jobs_tbl(l_counter).wip_entity_id := p_starting_job_rec.wip_entity_id;
                        else
                                -- validate the job name .....
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_msg_count     := 0;
                                l_msg_data      := null;

                                wip_entity(p_load_type         => 'C',
                                           p_org_id            => p_txn_org_id,
                                           p_wip_entity_id     => p_resulting_jobs_tbl(l_counter).wip_entity_id,
                                           p_job_name          => p_resulting_jobs_tbl(l_counter).wip_entity_name,
                                           x_return_status     => l_return_status,
                                           x_error_msg         => l_msg_data,
                                           x_error_count       => l_msg_count
                                           );
                                if l_return_status <> G_RET_SUCCESS then
                                        IF l_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                        end if;
                else -- wip entity id is not null

                        if p_resulting_jobs_tbl(l_counter).wip_entity_id = p_starting_job_rec.wip_entity_id then
                                -- copy the job name ....
                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Copying job name'       ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                p_resulting_jobs_tbl(l_counter).wip_entity_name := p_starting_job_rec.wip_entity_name;
                        else
                                -- error out....
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_SJ_AS_RJ',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;

                l_stmt_num := 50;
                IF p_resulting_jobs_tbl(l_counter).wip_entity_id = p_starting_job_rec.wip_entity_id THEN
                        -- time to assign the flag.....
                        IF l_start_as_result = -1 THEN

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Assign l_start_as_result=1'     ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                l_start_as_result := 1;
                        ELSE
                                -- error out,,,,,
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_SJ_AS_RJ_ONCE',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                        END IF;
                END IF;

                l_stmt_num := 60;
                -- check for duplicate job name
                If l_job_name_tbl.exists(p_resulting_jobs_tbl(l_counter).wip_entity_name) THEN
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_DUPLICATE_RJ_NAME',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                else
                        l_job_name_tbl(p_resulting_jobs_tbl(l_counter).wip_entity_name) := 1;
                end if;
                -- Job name / ID end

                -- ST : Fix for bug 5131059 : description....... --
                p_resulting_jobs_tbl(l_counter).description := nvl(p_resulting_jobs_tbl(l_counter).description,p_starting_job_rec.description);
                if p_resulting_jobs_tbl(l_counter).description = l_null_char then
                        p_resulting_jobs_tbl(l_counter).description := null;
                end if;

                -- Quantity start--
                l_stmt_num := 70;
                if (p_resulting_jobs_tbl(l_counter).start_quantity is null) or
                   (p_resulting_jobs_tbl(l_counter).start_quantity <= 0)
                then
                        -- error out....--
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'start_quantity';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_NULL_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;

                -- ST : Serial Support Project --
                IF (l_start_serial_code = 2) and
                   (p_resulting_jobs_tbl(l_counter).start_quantity <> floor(p_resulting_jobs_tbl(l_counter).start_quantity))
                THEN
                        -- error out...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- ST : Serial Support Project --

                l_stmt_num := 80;
                if (l_total_quantity + p_resulting_jobs_tbl(l_counter).start_quantity) > p_starting_job_rec.quantity_available then
                        -- error out..... --
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_SUM_RESULT_START_MORE',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 90;
                l_total_quantity := l_total_quantity + p_resulting_jobs_tbl(l_counter).start_quantity;

                if p_resulting_jobs_tbl(l_counter).net_quantity is null then
                        --use the !!!logic!!! --
                        p_resulting_jobs_tbl(l_counter).net_quantity := round(( (p_resulting_jobs_tbl(l_counter).start_quantity/p_starting_job_rec.quantity_available)*p_starting_job_rec.net_quantity ),6);

                        if p_resulting_jobs_tbl(l_counter).net_quantity > p_resulting_jobs_tbl(l_counter).start_quantity then
                                p_resulting_jobs_tbl(l_counter).net_quantity := p_resulting_jobs_tbl(l_counter).start_quantity;
                        end if;

                        -- ST : Serial Support Project --
                        IF l_start_serial_code = 2 THEN
                                p_resulting_jobs_tbl(l_counter).net_quantity := floor(p_resulting_jobs_tbl(l_counter).net_quantity);
                        END IF;
                        -- ST : Serial Support Project --

                else
                        if -- (p_resulting_jobs_tbl(l_counter).net_quantity = l_null_num) or
                           (p_resulting_jobs_tbl(l_counter).net_quantity < 0 ) or
                           (p_resulting_jobs_tbl(l_counter).net_quantity > p_resulting_jobs_tbl(l_counter).start_quantity)
                        then
                                -- error out... --
                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'net_quantity';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                        -- ST : Serial Support Project --
                        -- ST : Fix for bug 5199646 -- replaced start_quantity with net_quantity in the belwo check --
                        -- Typo error --
                        IF (l_start_serial_code = 2) and
                           (p_resulting_jobs_tbl(l_counter).net_quantity <> floor(p_resulting_jobs_tbl(l_counter).net_quantity))
                        THEN
                                -- error out...
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        -- ST : Serial Support Project --

                end if;
                ---Quantity end --

                --  Co products supply start --
                if p_resulting_jobs_tbl(l_counter).wip_entity_name = p_starting_job_rec.wip_entity_name then

                        if p_resulting_jobs_tbl(l_counter).coproducts_supply is null then
                                p_resulting_jobs_tbl(l_counter).coproducts_supply := p_starting_job_rec.coproducts_supply;
                        end if;

                else -- new job.....---
                        if p_resulting_jobs_tbl(l_counter).coproducts_supply is null then
                                p_resulting_jobs_tbl(l_counter).coproducts_supply := l_coproducts_supply;
                        end if;
                end if;

                if NVL(p_resulting_jobs_tbl(l_counter).coproducts_supply,0) not in(1,2) then
                        --error out.... --
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenName := 'CoProducts Supply';

                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;
                ---  Co products supply end --

                -- check the split has update assy flag.........--
                l_stmt_num := 100;
                p_resulting_jobs_tbl(l_counter).split_has_update_assy := nvl(p_resulting_jobs_tbl(l_counter).split_has_update_assy,0);
                if p_resulting_jobs_tbl(l_counter).split_has_update_assy not in (0,1) then
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenName := 'Split_has_update_assembly';

                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;
                -- check the split has update assy flag....--

                -- Now get the common fields..... --
                p_resulting_jobs_tbl(l_counter).status_type                     := p_starting_job_rec.status_type;
                p_resulting_jobs_tbl(l_counter).class_code                      := p_starting_job_rec.class_code;
                p_resulting_jobs_tbl(l_counter).job_type                        := p_starting_job_rec.job_type;
                p_resulting_jobs_tbl(l_counter).organization_id                 := p_starting_job_rec.organization_id;
                p_resulting_jobs_tbl(l_counter).organization_code               := p_starting_job_rec.organization_code;
                p_resulting_jobs_tbl(l_counter).wip_supply_type                 := p_starting_job_rec.wip_supply_type;

                p_resulting_jobs_tbl(l_counter).scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
                p_resulting_jobs_tbl(l_counter).scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

                -- Now fork based on split has update assy flag.
                l_stmt_num := 110;
                if p_resulting_jobs_tbl(l_counter).split_has_update_assy = 0 then
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'no update of assembly '         ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;
                        -- Copy all colums except for start qty, net qty and completion subinv and coproducts supply --

                        -- Primary info .....
                        p_resulting_jobs_tbl(l_counter).item_name                        := p_starting_job_rec.item_name;
                        p_resulting_jobs_tbl(l_counter).primary_item_id                  := p_starting_job_rec.primary_item_id;
                        p_resulting_jobs_tbl(l_counter).class_code                       := p_starting_job_rec.class_code;

                        -- BOM details ....
                        p_resulting_jobs_tbl(l_counter).bom_reference_id                 := p_starting_job_rec.bom_reference_id;
                        p_resulting_jobs_tbl(l_counter).common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
                        p_resulting_jobs_tbl(l_counter).bom_revision                     := p_starting_job_rec.bom_revision;
                        p_resulting_jobs_tbl(l_counter).bom_revision_date                := p_starting_job_rec.bom_revision_date;
                        p_resulting_jobs_tbl(l_counter).alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

                        -- Routing details
                        p_resulting_jobs_tbl(l_counter).routing_reference_id             := p_starting_job_rec.routing_reference_id;
                        p_resulting_jobs_tbl(l_counter).common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
                        p_resulting_jobs_tbl(l_counter).routing_revision                 := p_starting_job_rec.routing_revision;
                        p_resulting_jobs_tbl(l_counter).routing_revision_date            := p_starting_job_rec.routing_revision_date;
                        p_resulting_jobs_tbl(l_counter).alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

                        -- Starting operation details....
                        p_resulting_jobs_tbl(l_counter).starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
                        p_resulting_jobs_tbl(l_counter).starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
                        p_resulting_jobs_tbl(l_counter).starting_operation_code          := p_starting_job_rec.operation_code;
                        p_resulting_jobs_tbl(l_counter).starting_std_op_id               := p_starting_job_rec.standard_operation_id;
                        p_resulting_jobs_tbl(l_counter).starting_operation_seq_id        := p_starting_job_rec.operation_seq_id;

                        p_resulting_jobs_tbl(l_counter).department_id                    := p_starting_job_rec.department_id;
                        p_resulting_jobs_tbl(l_counter).department_code                  := p_starting_job_rec.department_code;
                        p_resulting_jobs_tbl(l_counter).operation_description            := p_starting_job_rec.operation_description;


                else
                        -- Update of assembly .....
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'There is update of assembly '           ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        derive_val_primary_item (  p_txn_org_id         => p_resulting_jobs_tbl(l_counter).organization_id,
                                                   p_old_item_id        => p_starting_job_rec.primary_item_id,
                                                   p_new_item_name      => p_resulting_jobs_tbl(l_counter).item_name,
                                                   p_new_item_id        => p_resulting_jobs_tbl(l_counter).primary_item_id,
                                                   x_return_status      => l_return_status,
                                                   x_msg_count          => l_msg_count,
                                                   x_msg_data           => l_msg_data
                                                );
                        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                                if( g_log_level_statement   >= l_log_level ) then

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_primary_item returned failure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                IF l_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        END IF ;

                        -- ST : Serial Support Project --
                        select nvl(serial_number_control_code,1)
                        into l_res_serial_code
                        from mtl_system_items msi
                        where inventory_item_id = p_resulting_jobs_tbl(l_counter).primary_item_id
                        and   organization_id = p_txn_org_id;

                        IF l_res_serial_code <> l_start_serial_code then
                                -- error out...
                                -- cannot do a update from non-serial to serial or vice versa....

                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_UPD_ASSY'   ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        -- ST : Serial Support Project --

                        l_stmt_num := 120;
                        -- call derive_val_bom_info
                        derive_val_bom_info      ( p_txn_org_id                         => p_resulting_jobs_tbl(l_counter).organization_id,
                                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                                   p_rj_primary_item_id                 => p_resulting_jobs_tbl(l_counter).primary_item_id,
                                                   p_rj_bom_reference_item              => p_resulting_jobs_tbl(l_counter).bom_reference_item,
                                                   p_rj_bom_reference_id                => p_resulting_jobs_tbl(l_counter).bom_reference_id,
                                                   p_rj_alternate_bom_desig             => p_resulting_jobs_tbl(l_counter).alternate_bom_designator,
                                                   p_rj_common_bom_seq_id               => p_resulting_jobs_tbl(l_counter).common_bom_sequence_id,
                                                   p_rj_bom_revision                    => p_resulting_jobs_tbl(l_counter).bom_revision,
                                                   p_rj_bom_revision_date               => p_resulting_jobs_tbl(l_counter).bom_revision_date,
                                                   x_return_status                      => l_return_status,
                                                   x_msg_count                          => l_msg_count,
                                                   x_msg_data                           => l_msg_data
                                                  );

                        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                                if( g_log_level_statement   >= l_log_level ) then

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_bom_info returned failure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                IF l_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if ;

                        l_stmt_num := 130;

                        -- call derive_val_routing_info
                        derive_val_routing_info  ( p_txn_org_id                         => p_resulting_jobs_tbl(l_counter).organization_id,
                                                   p_sj_job_type                        => p_starting_job_rec.job_type,
                                                   p_rj_primary_item_id                 => p_resulting_jobs_tbl(l_counter).primary_item_id,
                                                   p_rj_rtg_reference_item              => p_resulting_jobs_tbl(l_counter).routing_reference_item,
                                                   p_rj_rtg_reference_id                => p_resulting_jobs_tbl(l_counter).routing_reference_id,
                                                   p_rj_alternate_rtg_desig             => p_resulting_jobs_tbl(l_counter).alternate_routing_designator,
                                                   p_rj_common_rtg_seq_id               => p_resulting_jobs_tbl(l_counter).common_routing_sequence_id,
                                                   p_rj_rtg_revision                    => p_resulting_jobs_tbl(l_counter).routing_revision,
                                                   p_rj_rtg_revision_date               => p_resulting_jobs_tbl(l_counter).routing_revision_date,
                                                   x_return_status                      => l_return_status,
                                                   x_msg_count                          => l_msg_count,
                                                   x_msg_data                           => l_msg_data
                                                  );

                        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                                if( g_log_level_statement   >= l_log_level ) then

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_routing_info returned failure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                IF l_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if ;

						l_stmt_num := 135;
						-- call WSMPUTIL.find_routing_start to validate first operation in N/W.
		                -- added for bug 5386675.

		                wsmputil.find_routing_start (p_routing_sequence_id  => p_resulting_jobs_tbl(l_counter).common_routing_sequence_id,
									                 p_routing_rev_date    	=> p_resulting_jobs_tbl(l_counter).routing_revision_date,
                                                     start_op_seq_id        => l_start_op_seq_id,
									                 x_err_code             => l_error_code,
									                 x_err_msg              => l_msg_data);

                        IF l_error_code < 0 THEN
                                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module     ,
                                                               p_msg_text           => l_msg_data,
                                                               p_stmt_num           => l_stmt_num    ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR    ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR  ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;

                        raise FND_API.G_EXC_ERROR;

                        end if;

		                -- call WSMPUTIL.find_routing_end to validate last operation in N/W.
		                -- added for bug 5386675.

                        wsmputil.find_routing_end (p_routing_sequence_id  => p_resulting_jobs_tbl(l_counter).common_routing_sequence_id,
									               p_routing_rev_date     => p_resulting_jobs_tbl(l_counter).routing_revision_date,
                                                   end_op_seq_id          => l_end_op_seq_id,
									               x_err_code             => l_error_code,
									               x_err_msg              => l_msg_data);

                        IF l_error_code < 0 THEN
                                IF( G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module    ,
                                                               p_msg_text           => l_msg_data,
                                                               p_stmt_num           => l_stmt_num   ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR  ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR   ,
                                                               p_run_log_level      => l_log_level
                                                              );
                        END IF;

                        raise FND_API.G_EXC_ERROR;

                        end if;

                        l_stmt_num := 140;
                        derive_val_starting_op (  p_txn_org_id                  => p_resulting_jobs_tbl(l_counter).organization_id,
                                                  p_curr_op_seq_id              => p_starting_job_rec.operation_seq_id,
                                                  p_curr_op_code                => p_starting_job_rec.operation_code,
                                                  p_curr_std_op_id              => p_starting_job_rec.standard_operation_id,
                                                  p_curr_intra_op_step          => p_starting_job_rec.intraoperation_step,
                                                  p_new_comm_rtg_seq_id         => p_resulting_jobs_tbl(l_counter).common_routing_sequence_id,
                                                  p_new_rtg_rev_date            => p_resulting_jobs_tbl(l_counter).routing_revision_date ,
                                                  p_new_op_seq_num              => p_resulting_jobs_tbl(l_counter).starting_operation_seq_num,
                                                  p_new_op_seq_id               => p_resulting_jobs_tbl(l_counter).starting_operation_seq_id,
                                                  p_new_std_op_id               => p_resulting_jobs_tbl(l_counter).starting_std_op_id,
                                                  p_new_op_seq_code             => p_resulting_jobs_tbl(l_counter).starting_operation_code,
                                                  p_new_dept_id                 => p_resulting_jobs_tbl(l_counter).department_id,
                                                  x_return_status               => l_return_status,
                                                  x_msg_count                   => l_msg_count,
                                                  x_msg_data                    => l_msg_data
                                              );
                        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                                if( g_log_level_statement   >= l_log_level ) then

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'derive_val_starting_op returned failure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                IF l_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if ;

                        -- Always overwrite the starting intraop step for Split and Update Assy txn..
                        p_resulting_jobs_tbl(l_counter).starting_intraoperation_step     := WIP_CONSTANTS.QUEUE;

                end if; -- End Check on Split and Update Flag

                l_stmt_num := 150;

                -- Completion subinv derivation....
                derive_val_compl_subinv( p_job_type                             => p_resulting_jobs_tbl(l_counter).job_type,
                                         p_old_rtg_seq_id                       => p_starting_job_rec.common_routing_sequence_id,
                                         p_new_rtg_seq_id                       => p_resulting_jobs_tbl(l_counter).common_routing_sequence_id,
                                         p_organization_id                      => p_resulting_jobs_tbl(l_counter).organization_id,
                                         p_primary_item_id                      => p_resulting_jobs_tbl(l_counter).primary_item_id,
                                         p_sj_completion_subinventory           => p_starting_job_rec.completion_subinventory,
                                         p_sj_completion_locator_id             => p_starting_job_rec.completion_locator_id,
                                         -- ST : Bug fix 5094555 start
                                         p_rj_alt_rtg_designator                => p_resulting_jobs_tbl(l_counter).alternate_routing_designator,
                                         p_rj_rtg_reference_item_id             => p_resulting_jobs_tbl(l_counter).routing_reference_id,
                                         -- ST : Bug fix 5094555 end
                                         p_rj_completion_subinventory           => p_resulting_jobs_tbl(l_counter).completion_subinventory,
                                         p_rj_completion_locator_id             => p_resulting_jobs_tbl(l_counter).completion_locator_id,
                                         p_rj_completion_locator                => p_resulting_jobs_tbl(l_counter).completion_locator,
                                         x_return_status                        => l_return_status,
                                         x_msg_count                            => l_msg_count,
                                         x_msg_data                             => l_msg_data
                                      );

                if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                        if( g_log_level_statement   >= l_log_level ) then

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'derive_val_compl_subinv returned failure',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        IF l_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if ;
                l_counter := p_resulting_jobs_tbl.next(l_counter);

        end loop;

        /* Bugfix 5438722 Validate that there isn't just one resulting job with all the available quantity */

        if (l_total_quantity = p_starting_job_rec.quantity_available) and (p_resulting_jobs_tbl.count = 1) then
        	-- error out...
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
		l_msg_tokens.delete;
		WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
				       p_msg_name           => 'WSM_ONE_RES_JOB_HAS_FULL_QTY',
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

        /* End Bugfix 5438722 */

        l_stmt_num := 165;
        -- check if all available qty utilised.......
        if l_total_quantity < p_starting_job_rec.quantity_available then
                -- Either create.... a new record or modify the parent if it exists.....
                if l_start_as_result = -1 then
                        if p_resulting_jobs_tbl.count < 1 then
                                -- error out...
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
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

                        l_counter := p_resulting_jobs_tbl.last + 1;
                        l_stmt_num := 170;
                        -- Indicates that parent record is not a resulting record.... create one for it....
                        -- Primary info .....
                        p_resulting_jobs_tbl(l_counter).wip_entity_id                    := p_starting_job_rec.wip_entity_id;
                        p_resulting_jobs_tbl(l_counter).wip_entity_name                  := p_starting_job_rec.wip_entity_name;
                        p_resulting_jobs_tbl(l_counter).item_name                        := p_starting_job_rec.item_name;
                        p_resulting_jobs_tbl(l_counter).primary_item_id                  := p_starting_job_rec.primary_item_id;
                        p_resulting_jobs_tbl(l_counter).class_code                       := p_starting_job_rec.class_code;
                        p_resulting_jobs_tbl(l_counter).job_type                         := p_starting_job_rec.job_type;
                        p_resulting_jobs_tbl(l_counter).organization_id                  := p_starting_job_rec.organization_id;
                        p_resulting_jobs_tbl(l_counter).organization_code                := p_starting_job_rec.organization_code;
                        p_resulting_jobs_tbl(l_counter).description                      := p_starting_job_rec.description;

                        -- BOM details ....
                        p_resulting_jobs_tbl(l_counter).bom_reference_id                 := p_starting_job_rec.bom_reference_id;
                        p_resulting_jobs_tbl(l_counter).common_bom_sequence_id           := p_starting_job_rec.common_bill_sequence_id;
                        p_resulting_jobs_tbl(l_counter).bom_revision                     := p_starting_job_rec.bom_revision;
                        p_resulting_jobs_tbl(l_counter).bom_revision_date                := p_starting_job_rec.bom_revision_date;
                        p_resulting_jobs_tbl(l_counter).alternate_bom_designator         := p_starting_job_rec.alternate_bom_designator;

                        -- Routing details
                        p_resulting_jobs_tbl(l_counter).routing_reference_id             := p_starting_job_rec.routing_reference_id;
                        p_resulting_jobs_tbl(l_counter).common_routing_sequence_id       := p_starting_job_rec.common_routing_sequence_id;
                        p_resulting_jobs_tbl(l_counter).routing_revision                 := p_starting_job_rec.routing_revision;
                        p_resulting_jobs_tbl(l_counter).routing_revision_date            := p_starting_job_rec.routing_revision_date;
                        p_resulting_jobs_tbl(l_counter).alternate_routing_designator     := p_starting_job_rec.alternate_routing_designator;

                        -- Completion sub inv details.... Non Updatable....
                        p_resulting_jobs_tbl(l_counter).completion_subinventory          := p_starting_job_rec.completion_subinventory;
                        p_resulting_jobs_tbl(l_counter).completion_locator_id            := p_starting_job_rec.completion_locator_id;

                        -- Starting operation details....
                        p_resulting_jobs_tbl(l_counter).starting_operation_seq_num       := p_starting_job_rec.operation_seq_num;
                        p_resulting_jobs_tbl(l_counter).starting_intraoperation_step     := p_starting_job_rec.intraoperation_step;
                        p_resulting_jobs_tbl(l_counter).starting_operation_code          := p_starting_job_rec.operation_code;
                        p_resulting_jobs_tbl(l_counter).starting_std_op_id               := p_starting_job_rec.standard_operation_id;
                        p_resulting_jobs_tbl(l_counter).department_id                    := p_starting_job_rec.department_id;
                        p_resulting_jobs_tbl(l_counter).department_code                  := p_starting_job_rec.department_code;
                        p_resulting_jobs_tbl(l_counter).operation_description            := p_starting_job_rec.operation_description;

                        -- Date info....
                        p_resulting_jobs_tbl(l_counter).scheduled_start_date             := p_starting_job_rec.scheduled_start_date;
                        p_resulting_jobs_tbl(l_counter).scheduled_completion_date        := p_starting_job_rec.scheduled_completion_date;

                        -- Other parameters....
                        p_resulting_jobs_tbl(l_counter).coproducts_supply                := p_starting_job_rec.coproducts_supply;

                        -- Quantity info
                        p_resulting_jobs_tbl(l_counter).start_quantity :=  ( p_starting_job_rec.quantity_available - l_total_quantity );

                        -- logic to derive the net quantity....
                        p_resulting_jobs_tbl(l_counter).net_quantity := round(( (p_resulting_jobs_tbl(l_counter).start_quantity/p_starting_job_rec.quantity_available)*p_starting_job_rec.net_quantity ),6);

                        if p_resulting_jobs_tbl(l_counter).net_quantity > p_resulting_jobs_tbl(l_counter).start_quantity then
                                p_resulting_jobs_tbl(l_counter).net_quantity := p_resulting_jobs_tbl(l_counter).start_quantity;
                        end if;

                        -- ST : Serial Support Project --
                        IF l_start_serial_code = 2 THEN
                                p_resulting_jobs_tbl(l_counter).net_quantity := floor(p_resulting_jobs_tbl(l_counter).net_quantity);
                        END IF;
                        -- ST : Serial Support Project --

                        -- ST : Fix for bug 5211424 : default
                        p_resulting_jobs_tbl(l_counter).split_has_update_assy := 0;
                ELSE
                        -- parent record is also a part of the resulting jobs bunch....
                        IF p_resulting_jobs_tbl.count <= 1 THEN
                                -- error out...
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_SJ_AS_RJ_ONCE',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        p_resulting_jobs_tbl(l_start_as_result).start_quantity := p_resulting_jobs_tbl(l_start_as_result).start_quantity + ( p_starting_job_rec.quantity_available - l_total_quantity );

                        -- logic to derive the net quantity....
                        p_resulting_jobs_tbl(l_start_as_result).net_quantity := round(( (p_resulting_jobs_tbl(l_start_as_result).start_quantity/p_starting_job_rec.quantity_available)*p_starting_job_rec.net_quantity ),6);

                        IF p_resulting_jobs_tbl(l_start_as_result).net_quantity > p_resulting_jobs_tbl(l_start_as_result).start_quantity then
                                p_resulting_jobs_tbl(l_start_as_result).net_quantity := p_resulting_jobs_tbl(l_start_as_result).start_quantity;
                        END IF;

                        -- ST : Serial Support Project --
                        IF l_start_serial_code = 2 THEN
                                p_resulting_jobs_tbl(l_counter).net_quantity := floor(p_resulting_jobs_tbl(l_counter).net_quantity);
                        END IF;
                        -- ST : Serial Support Project --
                END IF;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

exception

        WHEN FND_API.G_EXC_ERROR THEN

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

                 FND_MSG_PUB.Count_And_Get (p_encoded   => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

END derive_val_res_job_details;


-- Default resulting job details for bonus txn
PROCEDURE derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                        p_txn_org_id            IN              NUMBER,
                                        p_transaction_date      IN              DATE,
                                        p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                        x_return_status         OUT     NOCOPY  VARCHAR2,
                                        x_msg_count             OUT     NOCOPY  NUMBER  ,
                                        x_msg_data              OUT     NOCOPY  VARCHAR2
                                    )
IS

l_class_code                    WIP_ACCOUNTING_CLASSES.CLASS_CODE%TYPE;
l_class_type			WIP_ACCOUNTING_CLASSES.CLASS_TYPE%TYPE; -- Bug 5487991  Added
l_dummy                         NUMBER;
l_est_scrap_account             NUMBER;
l_est_scrap_var_account         NUMBER;
l_serial_control                NUMBER;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

l_err_code              NUMBER;
l_err_msg               VARCHAR2(2000);
l_null_char             VARCHAR2(1) := FND_API.G_NULL_CHAR;

-- logging variables
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_res_job_details';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;

BEGIN

        l_stmt_num := 10;

        if p_txn_type <> WSMPCNST.BONUS then
                -- error out...
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Transaction Type not bonus',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 20;
        -- Default the job type to be Standard
        if p_resulting_job_rec.job_type is null then
                p_resulting_job_rec.job_type := WIP_CONSTANTS.STANDARD;

     -- Bug 5487991 added elsif condition to validate the job_type is either 1 or 3
     -- these are two valid values for lot based jobs

	elsif ( p_resulting_job_rec.job_type <> 1 and p_resulting_job_rec.job_type <> 3 ) then

   		IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Job Type';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

     -- Bug 5487991 end of code addition for this fix

        end if;

        -- Deafult the BOM supply type..
        if p_resulting_job_rec.wip_supply_type is null then
                p_resulting_job_rec.wip_supply_type := WIP_CONSTANTS.BASED_ON_BOM;
        end if;

        -- Default the organization info..
        if p_resulting_job_rec.organization_id is null then
                p_resulting_job_rec.organization_id := p_txn_org_id;
        end if;

        -- ST : Fix for bug 5131059 : description....... --
        if p_resulting_job_rec.description = l_null_char then
               p_resulting_job_rec.description := null;
        end if;

        -- check the wip entity name for existence....
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module ,
                                       p_msg_text           => 'Checking the wip_entity_name for existence',
                                       p_stmt_num           => l_stmt_num,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        END IF;

        BEGIN
                l_stmt_num := 30;
                IF p_resulting_job_rec.wip_entity_name is null then
                        -- error out as it is mandatory......
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'wip_entity_name';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_NULL_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                ELSE
                        l_stmt_num := 40;
                        -- check if already existing job name
                        select 1
                        into l_dummy
                        from  wip_entities WE
                        where WE.wip_entity_name = p_resulting_job_rec.wip_entity_name
                        and   WE.organization_id = p_txn_org_id;

                        if l_dummy=1 then
                                -- error out as duplicate job....
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_DUPLICATE_ENT_NAME',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                    END IF;
        EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      null;
        END;

        -- call derive val primary item
        l_stmt_num := 50;
        derive_val_primary_item (  p_txn_org_id         => p_txn_org_id                       ,
                                   p_old_item_id        => null                               ,
                                   p_new_item_name      => p_resulting_job_rec.item_name      ,
                                   p_new_item_id        => p_resulting_job_rec.primary_item_id,
                                   x_return_status      => l_return_status,
                                   x_msg_count          => l_msg_count,
                                   x_msg_data           => l_msg_data
                                );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_primary_item returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;

        select nvl(serial_number_control_code,1)
        into   l_serial_control
        from   mtl_system_items
        where  inventory_item_id = p_resulting_job_rec.primary_item_id
        and    organization_id   = p_resulting_job_rec.organization_id;

        -- Quantity check .....
        -- ST : Fix for bug 5218598 : Added the nvl clause --
        if nvl(p_resulting_job_rec.start_quantity,0) <= 0 then
                -- error out...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'start_quantity';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        elsif p_resulting_job_rec.net_quantity is NULL then
                -- default the net quantity
                p_resulting_job_rec.net_quantity := round(p_resulting_job_rec.start_quantity,6);

        elsif (  p_resulting_job_rec.net_quantity is not null) and
              ( (p_resulting_job_rec.net_quantity > p_resulting_job_rec.start_quantity) or
                (p_resulting_job_rec.net_quantity < 0)
              )
        then
                -- error out...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Net quantity';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        -- Validate for serial --
        if (l_serial_control = 2) AND
           ( (floor(p_resulting_job_rec.net_quantity) <> p_resulting_job_rec.net_quantity) OR
             (floor(p_resulting_job_rec.start_quantity) <> p_resulting_job_rec.start_quantity)
           )
        then
                -- error out..
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;
        -- end validate for serial --

        -- Start date completion date defaulting to be handled...
        if p_resulting_job_rec.scheduled_start_date is null and p_resulting_job_rec.scheduled_completion_date is null then
                -- error out...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'Both scheduled_start_date and scheduled_end_date';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_NULL_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        else
                -- Obtain the scheduled completion date information
                if p_resulting_job_rec.scheduled_completion_date is null then
                        p_resulting_job_rec.scheduled_completion_date := WSMPUTIL.GET_SCHEDULED_DATE( p_organization_id   => p_resulting_job_rec.organization_id,
                                                                                                      p_primary_item_id   => p_resulting_job_rec.primary_item_id,
                                                                                                      p_schedule_method   => 'F',
                                                                                                      p_input_date        => p_resulting_job_rec.scheduled_start_date,
                                                                                                      p_quantity          => p_resulting_job_rec.start_quantity,
                                                                                                      x_err_code          => l_err_code,
                                                                                                      x_err_msg           => l_err_msg);

                elsif p_resulting_job_rec.scheduled_start_date is null then
                        p_resulting_job_rec.scheduled_completion_date := WSMPUTIL.GET_SCHEDULED_DATE( p_organization_id   => p_resulting_job_rec.organization_id,
                                                                                                      p_primary_item_id   => p_resulting_job_rec.primary_item_id,
                                                                                                      p_schedule_method   => 'B',
                                                                                                      p_input_date        => p_resulting_job_rec.scheduled_completion_date,
                                                                                                      p_quantity          => p_resulting_job_rec.start_quantity,
                                                                                                      x_err_code          => l_err_code,
                                                                                                      x_err_msg           => l_err_msg);

                end if;
        end if;

        if p_resulting_job_rec.scheduled_start_date > p_resulting_job_rec.scheduled_completion_date then
                -- error out.....
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_DATES',
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


        -- check the account .......
        l_stmt_num := 60;
        BEGIN
               select 1
               into   l_dummy
               from   gl_code_combinations gcc,
                      -- ST : Performance bug fix 4914162 : Remove the use of org_organization_definitions.
                      -- org_organization_definitions ood
                      hr_organization_information hoi,
                      gl_sets_of_books gsob
               -- where  p_txn_org_id = ood.organization_id
               where  p_txn_org_id = hoi.organization_id
               -- and    ood.chart_of_accounts_id = gcc.chart_of_accounts_id
               and    gsob.chart_of_accounts_id = gcc.chart_of_accounts_id
               and    nvl (p_resulting_job_rec.bonus_acct_id, -1) = gcc.code_combination_id
               and    gcc.enabled_flag = 'Y'
               and    p_transaction_date between nvl(gcc.start_date_active, p_transaction_date)
                                                     and nvl(gcc.end_date_active, p_transaction_date)
               and    gsob.set_of_books_id = TO_NUMBER(DECODE(RTRIM(TRANSLATE(hoi.org_information1,'0123456789',' ')),
                                                                NULL,
                                                                hoi.org_information1,
                                                                -99999))
               and    hoi.org_information_context || '' = 'Accounting Information';

        EXCEPTION
                WHEN NO_DATA_FOUND then
                         -- error out....
                         IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                 l_msg_tokens(1).TokenName := 'FLD_NAME';
                                 l_msg_tokens(1).TokenValue := 'BONUS_ACCT_ID';
                                WSM_log_PVT.logMessage(p_module_name=> l_module                         ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
        END;

        -- call derive_val_bom_info
        l_stmt_num := 70;
        derive_val_bom_info      (       p_txn_org_id                   => p_txn_org_id,
                                         p_sj_job_type                  => p_resulting_job_rec.job_type,
                                         p_rj_primary_item_id           => p_resulting_job_rec.primary_item_id,
                                         p_rj_bom_reference_item        => p_resulting_job_rec.bom_reference_item,
                                         p_rj_bom_reference_id          => p_resulting_job_rec.bom_reference_id,
                                         p_rj_alternate_bom_desig       => p_resulting_job_rec.alternate_bom_designator,
                                         p_rj_common_bom_seq_id         => p_resulting_job_rec.common_bom_sequence_id,
                                         p_rj_bom_revision              => p_resulting_job_rec.bom_revision,
                                         p_rj_bom_revision_date         => p_resulting_job_rec.bom_revision_date,
                                         x_return_status                => l_return_status,
                                         x_msg_count                    => l_msg_count,
                                         x_msg_data                     => l_msg_data
                                );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_bom_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if ;

        -- call derive_val_routing_info
        l_stmt_num := 80;
        derive_val_routing_info  ( p_txn_org_id                         => p_txn_org_id,
                                   p_sj_job_type                        => p_resulting_job_rec.job_type,
                                   p_rj_primary_item_id                 => p_resulting_job_rec.primary_item_id,
                                   p_rj_rtg_reference_item              => p_resulting_job_rec.routing_reference_item,
                                   p_rj_rtg_reference_id                => p_resulting_job_rec.routing_reference_id,
                                   p_rj_alternate_rtg_desig             => p_resulting_job_rec.alternate_routing_designator,
                                   p_rj_common_rtg_seq_id               => p_resulting_job_rec.common_routing_sequence_id,
                                   p_rj_rtg_revision                    => p_resulting_job_rec.routing_revision,
                                   p_rj_rtg_revision_date               => p_resulting_job_rec.routing_revision_date,
                                   x_return_status                      => l_return_status,
                                   x_msg_count                          => l_msg_count,
                                   x_msg_data                           => l_msg_data
                                  );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_routing_info returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if ;

        l_stmt_num := 90;
        -- If the starting intraop step isnt specified, default to QUEUE
        p_resulting_job_rec.starting_intraoperation_step := nvl(p_resulting_job_rec.starting_intraoperation_step,WIP_CONSTANTS.QUEUE);

        IF p_resulting_job_rec.starting_intraoperation_step <> 1 THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'intraoperation step for bonus';

                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- validate network
        validate_network(       p_txn_org_id            => p_txn_org_id,
                                p_rtg_seq_id            => p_resulting_job_rec.common_routing_sequence_id,
                                p_revision_date         => p_resulting_job_rec.routing_revision_date,
                                p_start_op_seq_num      => p_resulting_job_rec.starting_operation_seq_num,
                                p_start_op_seq_id       => p_resulting_job_rec.starting_operation_seq_id,
                                p_start_op_seq_code     => p_resulting_job_rec.starting_operation_code,
                                p_dept_id               => p_resulting_job_rec.department_id,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data
                        );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'validate_network returned failure'||l_msg_data,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if ;

        -- Subinv derivation...
        l_stmt_num := 100;
        derive_val_compl_subinv( p_job_type                             => p_resulting_job_rec.job_type,
                                 p_old_rtg_seq_id                       => null,
                                 p_new_rtg_seq_id                       => p_resulting_job_rec.common_routing_sequence_id,
                                 p_organization_id                      => p_txn_org_id,
                                 p_primary_item_id                      => p_resulting_job_rec.primary_item_id,
                                 p_sj_completion_subinventory           => null,
                                 p_sj_completion_locator_id             => null,
                                 -- ST : Bug fix 5094555 start
                                 p_rj_alt_rtg_designator                => p_resulting_job_rec.alternate_routing_designator,
                                 p_rj_rtg_reference_item_id             => p_resulting_job_rec.routing_reference_id,
                                 -- ST : Bug fix 5094555 end
                                 p_rj_completion_subinventory           => p_resulting_job_rec.completion_subinventory,
                                 p_rj_completion_locator_id             => p_resulting_job_rec.completion_locator_id,
                                 p_rj_completion_locator                => p_resulting_job_rec.completion_locator,
                                 x_return_status                        => l_return_status,
                                 x_msg_count                            => l_msg_count,
                                 x_msg_data                             => l_msg_data
                              );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
                if( g_log_level_statement   >= l_log_level ) then

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'derive_val_compl_subinv returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                IF l_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if ;

        -- class code check .....dependent on the subinventory....
        l_stmt_num := 110;
        BEGIN
                if p_resulting_job_rec.class_code is null then
                      l_class_code := WSMPUTIL.GET_DEF_ACCT_CLASS_CODE(  p_txn_org_id,
                                                                         p_resulting_job_rec.primary_item_id,
                                                                         p_resulting_job_rec.completion_subinventory,
                                                                         l_err_code,
                                                                         l_err_msg
                                                                       );

                      IF (l_err_code <> 0) THEN
                                -- error out ........
                                l_stmt_num := 120;
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_CLASS_CODE',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      IF l_class_code IS NULL THEN
                               -- error out....
                               l_stmt_num := 130;
                               IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_CLASS_CODE',
                                                               p_msg_appl_name      => 'WSM',
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;

                      END IF;

                      p_resulting_job_rec.class_code := l_class_code;

                      l_stmt_num := 135;
                      -- IF Estimated Scrap account is enabled... check accounts of the defaulted class code....
                      IF wsmputil.WSM_ESA_ENABLED( p_wip_entity_id => NULL,
                                                   err_code       => l_err_code,
                                                   err_msg        => l_err_msg,
                                                   p_org_id       => p_txn_org_id,
                                                   p_job_type     => p_resulting_job_rec.job_type
                                                 ) = 1
                      THEN
                            l_stmt_num := 140;
                            select est_scrap_account,
                                   est_scrap_var_account
                            into   l_est_scrap_account,
                                   l_est_scrap_var_account
                            from   wip_accounting_classes
                            where  class_code = p_resulting_job_rec.class_code
                            and    organization_id = p_txn_org_id;


                            IF l_est_scrap_account IS NULL OR l_est_scrap_var_account IS NULL THEN
                                     -- error out ...
                                     IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                                       p_msg_name           => 'WSM_NO_WAC_SCRAP_ACC',
                                                                       p_msg_appl_name      => 'WSM',
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                     END IF;
                                     RAISE FND_API.G_EXC_ERROR;
                            END IF;

                      END IF;


              /* Bug 5487991 Commented out the following check as this is taken care of in the code
                 added below as part of this fix

 		ELSE
                      -- validate if such a class code exists or not.....
                      select 1
                      into   l_dummy
                      from   wip_accounting_classes
                      where  class_code = p_resulting_job_rec.class_code
                      and    organization_id = p_txn_org_id;                 */

                 END IF;

            --  Bug 5487991 Added the following check to ensure that class code is of correct type
            --  for standard and non standard bonus jobs.

  l_stmt_num := 150;

		SELECT class_type
		INTO l_class_type
		FROM wip_accounting_classes
		WHERE class_code = p_resulting_job_rec.class_code
		AND organization_id = p_txn_org_id;

  l_stmt_num := 160;

		IF ((p_resulting_job_rec.job_type = 1 and l_class_type <> 5 ) OR
                    (p_resulting_job_rec.job_type = 3 and l_class_type <> 7 ))
 		THEN

			l_stmt_num := 170;
    			IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_CLASS_CODE',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
		END IF;

  l_stmt_num := 150;
  	--  Bug 5487991 end addition of code for this fix


         EXCEPTION
                 WHEN NO_DATA_FOUND then
                       -- handle ....
                       IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_CLASS_CODE',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
         END;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

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

                 FND_MSG_PUB.Count_And_Get (p_encoded   => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
END derive_val_res_job_details;


-- routing procedure.....
Procedure derive_val_routing_info (p_txn_org_id                         IN              NUMBER,
                                   p_sj_job_type                        IN              NUMBER,
                                   p_rj_primary_item_id                 IN              NUMBER,
                                   p_rj_rtg_reference_item              IN              VARCHAR2,
                                   p_rj_rtg_reference_id                IN OUT NOCOPY   NUMBER,
                                   p_rj_alternate_rtg_desig             IN OUT NOCOPY   VARCHAR2,
                                   p_rj_common_rtg_seq_id               IN OUT NOCOPY   NUMBER,
                                   p_rj_rtg_revision                    IN OUT NOCOPY   VARCHAR2,
                                   p_rj_rtg_revision_date               IN OUT NOCOPY   DATE,
                                   x_return_status                      OUT    NOCOPY   varchar2,
                                   x_msg_count                          OUT    NOCOPY   NUMBER,
                                   x_msg_data                           OUT    NOCOPY   VARCHAR2
                                 ) is

l_rtg_revision          WIP_DISCRETE_JOBS.ROUTING_REVISION%TYPE; --varchar2(10); -- ST : Changed
l_null_char             VARCHAR2(10) := FND_API.G_NULL_CHAR;

l_rj_compl_subinv       WIP_DISCRETE_JOBS.completion_subinventory%TYPE; -- VARCHAR2(1000); -- ST : Changed
l_rj_loc_id             NUMBER;
l_rj_rtg_seq_id         NUMBER;
l_rj_common_rtg_seq_id  NUMBER;
l_return_status         VARCHAR2(1);
l_msg_data              VARCHAR2(1000);
l_msg_count             NUMBER;
l_item_id               NUMBER;
l_row_exists            NUMBER := 0; -- ST : Added for bug 5218479 --
l_error_out             NUMBER := 0; -- ST : Added for bug 5218479 --
e_invalid_revision      exception;   -- ST : Added for bug 5218479 --

-- ST : Added for bug 5218479
-- This is done b'cos the call to wip_revisions.*** procedures throw an app_exception
-- app_exception is nothing but raise_application_error(-20001,<text......>
-- So this has to be handled as a function error and not as an unexpected error...
PRAGMA EXCEPTION_INIT(e_invalid_revision,-20001);

-- logging variables
l_module              VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_routing_info';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;
l_param_tbl         WSM_Log_PVT.param_tbl_type;

begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 10;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_stmt_num := 15;
                l_param_tbl.delete;

                l_param_tbl(1).paramName := 'p_txn_org_id';
                l_param_tbl(1).paramValue := p_txn_org_id;

                l_param_tbl(2).paramName := 'p_sj_job_type';
                l_param_tbl(2).paramValue := p_sj_job_type;

                l_param_tbl(3).paramName := 'p_rj_primary_item_id';
                l_param_tbl(3).paramValue := p_rj_primary_item_id;

                l_param_tbl(4).paramName := 'p_rj_rtg_reference_item';
                l_param_tbl(4).paramValue := p_rj_rtg_reference_item;

                l_param_tbl(5).paramName := 'p_rj_rtg_reference_id';
                l_param_tbl(5).paramValue := p_rj_rtg_reference_id;

                l_param_tbl(6).paramName := 'p_rj_alternate_rtg_desig';
                l_param_tbl(6).paramValue := p_rj_alternate_rtg_desig;

                l_param_tbl(7).paramName := 'p_rj_common_rtg_seq_id';
                l_param_tbl(7).paramValue := p_rj_common_rtg_seq_id;

                l_param_tbl(8).paramName := 'p_rj_rtg_revision_date';
                l_param_tbl(8).paramValue := p_rj_rtg_revision_date;

                l_param_tbl(9).paramName := 'p_rj_rtg_revision';
                l_param_tbl(9).paramValue := p_rj_rtg_revision;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        if p_sj_job_type = WIP_CONSTANTS.NONSTANDARD then
                -- if both null then copy from the starting....
                if p_rj_rtg_reference_id is null and p_rj_rtg_reference_item is null then
                        --p_rj_rtg_reference_id := p_sj_rtg_reference_id; (AH)
                        --error out as user has to specify some info...(AH)
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'For NSJ,Both rtg_reference_id and rtg_reference_item ';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_NULL_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                else
                        -- cross validate......
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Cross validate routing_info',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;

                        BEGIN
                                -- ST : Bug fix 4914162 : Added an IF clause
                                IF p_rj_rtg_reference_id IS NOT NULL THEN
                                        select inventory_item_id
                                        into p_rj_rtg_reference_id
                                        from mtl_system_items_kfv
                                        where inventory_item_id = p_rj_rtg_reference_id
                                        and   concatenated_segments = nvl(p_rj_rtg_reference_item,concatenated_segments)
                                        and   organization_id   =  p_txn_org_id;
                                ELSE
                                        select inventory_item_id
                                        into p_rj_rtg_reference_id
                                        from mtl_system_items_kfv
                                        where concatenated_segments = p_rj_rtg_reference_item
                                        and   organization_id   =  p_txn_org_id;
                                END IF;

                        EXCEPTION
                                WHEN no_data_found THEN
                                        -- error out...
                                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'value for rotuing reference item/routing reference id';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                         END IF;
                                         RAISE FND_API.G_EXC_ERROR;
                        END;
                END IF;

        end if;

        -- ST : Fix for bug 5218479 --
        l_stmt_num := 19;

        -- Check if a OSFM routing
        l_row_exists := 0;
        IF p_sj_job_type = wip_constants.nonstandard THEN
             l_item_id := p_rj_rtg_reference_id;
        ELSE
            l_item_id := p_rj_primary_item_id;
        END IF;

        select count(1)
        into l_row_exists
        from bom_operational_routings bor
        where bor.assembly_item_id= l_item_id
        and   bor.organization_id= p_txn_org_id
        and   bor.routing_type = 1
        and   bor.cfm_routing_flag = 3
        and   rownum < 2;

        IF l_row_exists = 0 THEN
                -- error out as no network routing exists...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NO_WSM_ROUTING'     ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        END IF;
        -- ST : Fix for bug 5218479 end --

        l_stmt_num := 20;
        IF p_rj_rtg_revision_date IS NULL THEN

                IF p_rj_rtg_revision IS NULL THEN
                        -- yes..... assign rtg_revision_date to job start date or sysdate
                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'assign rtg_revision_date to job start date or sysdate',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        p_rj_rtg_revision_date := sysdate;

                END IF;

                if p_sj_job_type = wip_constants.nonstandard THEN
                        l_item_id := p_rj_rtg_reference_id;
                ELSE
                        l_item_id := p_rj_primary_item_id;
                END IF;

                -- ST : Fix for bug 5218479 : Added the BEGIN clause --
                l_error_out := 0;
                BEGIN
                        -- call wip_revisions
                        wip_revisions.routing_revision(p_organization_id =>  p_txn_org_id,
                                                       p_item_id         =>  l_item_id,
                                                       p_revision        =>  p_rj_rtg_revision,
                                                       p_revision_date   =>  p_rj_rtg_revision_date,
                                                       p_start_date      =>  p_rj_rtg_revision_date
                                                  );

                        IF( g_log_level_statement   >= l_log_level ) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'return from wip_revisions.routing_revision',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                EXCEPTION
                        WHEN e_invalid_revision THEN
                                l_error_out := 1;
                END;
                -- ST : Fix for bug 5218479 : end --
        ELSE  -- revision date is not null
                l_rtg_revision := null;

                IF p_sj_job_type = wip_constants.nonstandard THEN
                        l_item_id := p_rj_rtg_reference_id;
                ELSE
                        l_item_id := p_rj_primary_item_id;
                END IF;

                -- ST : Fix for bug 5218479 : Added the BEGIN clause --
                l_error_out := 0;
                l_stmt_num := 30;
                BEGIN

                        wip_revisions.routing_revision( p_organization_id =>  p_txn_org_id,
                                                        p_item_id         =>  l_item_id,
                                                        p_revision        =>  l_rtg_revision,
                                                        p_revision_date   =>  p_rj_rtg_revision_date,
                                                        p_start_date      =>  p_rj_rtg_revision_date
                                                      );

                        p_rj_rtg_revision := nvl(p_rj_rtg_revision,l_rtg_revision);

                        IF l_rtg_revision <> p_rj_rtg_revision THEN
                                l_error_out := 1;
                        END IF;
                EXCEPTION
                        WHEN e_invalid_revision THEN
                                l_error_out := 1;
                END;
                -- ST : Fix for bug 5218479 end --
        END IF;

        -- ST : Fix for bug 5218479 : Moved the erroring out code outside (so that it's common)
        l_stmt_num := 35;
        IF l_error_out = 1 THEN
                -- error out...
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'value for rotuing revision/routing revision date';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- ST : Fix for bug 5218479 end --

        -- call routing_seq procedure to validate the routing fields...
        l_stmt_num := 40;
        routing_seq(p_job_type              => p_sj_job_type,
                    p_org_id                => p_txn_org_id,
                    p_item_id               => p_rj_primary_item_id,
                    p_alt_rtg               => p_rj_alternate_rtg_desig,
                    p_common_rtg_seq_id     => p_rj_common_rtg_seq_id, --l_rj_common_rtg_seq_id,
                    p_rtg_ref_id            => p_rj_rtg_reference_id,
                    p_default_subinv        => l_rj_compl_subinv,
                    p_default_loc_id        => l_rj_loc_id,
                    x_rtg_seq_id            => l_rj_rtg_seq_id,
                    x_return_status         => l_return_status,
                    x_error_msg             => l_msg_data,
                    x_error_count           => l_msg_count
                   );

        if l_return_status <> fnd_api.g_ret_sts_success then
                -- error our...........
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Procedure routing_seq returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 50;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

exception

        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
END derive_val_routing_info;


-- BOM procedure......
Procedure derive_val_bom_info  (   p_txn_org_id                         IN              NUMBER,
                                   p_sj_job_type                        IN              NUMBER,
                                   p_rj_primary_item_id                 IN              NUMBER,
                                   p_rj_bom_reference_item              IN OUT NOCOPY   VARCHAR2,
                                   p_rj_bom_reference_id                IN OUT NOCOPY   NUMBER,
                                   p_rj_alternate_bom_desig             IN OUT NOCOPY   VARCHAR2,
                                   p_rj_common_bom_seq_id               IN OUT NOCOPY   NUMBER,
                                   p_rj_bom_revision                    IN OUT NOCOPY   VARCHAR2,
                                   p_rj_bom_revision_date               IN OUT NOCOPY   DATE,
                                   x_return_status                      OUT    NOCOPY   varchar2,
                                   x_msg_count                          OUT    NOCOPY   NUMBER,
                                   x_msg_data                           OUT    NOCOPY   VARCHAR2
                            ) is

l_null_char            VARCHAR2(10) := FND_API.G_NULL_CHAR;
l_null_num             NUMBER       := FND_API.G_NULL_NUM;
l_null_date            DATE         := FND_API.G_NULL_DATE;

l_bom_seq_id           NUMBER;
l_common_bom_seq_id    NUMBER;
l_return_status        VARCHAR2(1);
l_msg_data             VARCHAR2(1000);
l_msg_count            NUMBER;
l_item_id              NUMBER;
l_bom_revision         WIP_DISCRETE_JOBS.BOM_REVISION%TYPE; -- VARCHAR2(10); --ST : Changed
l_error_out             NUMBER := 0; -- ST : Added for bug 5218479 --
e_invalid_revision      exception;   -- ST : Added for bug 5218479 --

-- ST : Added for bug 5218479
-- This is done b'cos the call to wip_revisions.*** procedures throw an app_exception
-- app_exception is nothing but raise_application_error(-20001,<text......>
-- So this has to be handled as a function error and not as an unexpected error...
PRAGMA EXCEPTION_INIT(e_invalid_revision,-20001);

-- logging variables
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_bom_info';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;
l_param_tbl         WSM_Log_PVT.param_tbl_type;

begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_stmt_num := 10;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_stmt_num := 15;
                l_param_tbl.delete;

                l_param_tbl(1).paramName := 'p_txn_org_id';
                l_param_tbl(1).paramValue := p_txn_org_id;

                l_param_tbl(2).paramName := 'p_sj_job_type';
                l_param_tbl(2).paramValue := p_sj_job_type;

                l_param_tbl(3).paramName := 'p_rj_primary_item_id';
                l_param_tbl(3).paramValue := p_rj_primary_item_id;

                l_param_tbl(4).paramName := 'p_rj_bom_reference_item';
                l_param_tbl(4).paramValue := p_rj_bom_reference_item;

                l_param_tbl(5).paramName := 'p_rj_bom_reference_id';
                l_param_tbl(5).paramValue := p_rj_bom_reference_id;

                l_param_tbl(6).paramName := 'p_rj_alternate_bom_desig';
                l_param_tbl(6).paramValue := p_rj_alternate_bom_desig;

                l_param_tbl(7).paramName := 'p_rj_common_bom_seq_id';
                l_param_tbl(7).paramValue := p_rj_common_bom_seq_id;

                l_param_tbl(8).paramName := 'p_rj_bom_revision_date';
                l_param_tbl(8).paramValue := p_rj_bom_revision_date;

                l_param_tbl(9).paramName := 'p_rj_bom_revision';
                l_param_tbl(9).paramValue := p_rj_bom_revision;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_stmt_num := 18;

        IF -- ST : Fix for bug 5101841 Commenting the below statement for Standard job.
           -- Standard Jobs will always have a BOM
           -- (  (p_sj_job_type = WIP_CONSTANTS.STANDARD) AND
           --    (p_rj_alternate_bom_desig IS NULL) AND
           --    (p_rj_common_bom_seq_id   IS NULL) AND
           --    (p_rj_bom_revision        IS NULL) AND
           --    (p_rj_bom_revision_date   IS NULL)
           -- )
           -- OR
           (  (p_sj_job_type = WIP_CONSTANTS.NONSTANDARD) and
              (p_rj_bom_reference_id    IS NULL) and
              (p_rj_bom_reference_item  IS NULL)
           )
        then
                --- the user intends to detach the BOM.. cool.. so null out all the columns BOM
                p_rj_bom_reference_id           := NULL;
                p_rj_bom_reference_item         := NULL;
                p_rj_alternate_bom_desig        := NULL;
                p_rj_common_bom_seq_id          := NULL;
                p_rj_bom_revision               := NULL;
                p_rj_bom_revision_date          := NULL;
                return;
        end if;

        l_stmt_num := 20;

        if p_sj_job_type = WIP_CONSTANTS.NONSTANDARD then
                -- if both null then copy from the starting....
                if p_rj_bom_reference_id is null and p_rj_bom_reference_item is null then
                        --p_rj_bom_reference_id := p_sj_bom_reference_id; (AH)
                        --error out as user has to specify some info...(AH)
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'BOM_REFERENCE_ID in resulting jobs';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_NULL_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                ELSE
                        -- cross validate......
                        BEGIN
                                -- ST : Bug fix 4914162 : Added an IF clause
                                IF p_rj_bom_reference_id IS NOT NULL THEN
                                        select inventory_item_id
                                        into p_rj_bom_reference_id
                                        from mtl_system_items_kfv
                                        where inventory_item_id = p_rj_bom_reference_id
                                        and   concatenated_segments = nvl(p_rj_bom_reference_item,concatenated_segments)
                                        and   organization_id   =  p_txn_org_id;
                                ELSE
                                        select inventory_item_id
                                        into p_rj_bom_reference_id
                                        from mtl_system_items_kfv
                                        where concatenated_segments = p_rj_bom_reference_item
                                        and   organization_id   =  p_txn_org_id;
                                END IF;

                        EXCEPTION
                                WHEN no_data_found then
                                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'BOM REFERENCE ITEM/BOM REFERENCE ID in resulting jobs';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;

                        END;
                END IF;

        END IF;

        l_stmt_num := 30;
        -- ST : Added for bug 5218479 --
        l_error_out := 0;

        if p_rj_bom_revision_date is null then

                if p_rj_bom_revision is null then
                        -- yes..... assign bom_revision_date to job start date or sysdate
                        p_rj_bom_revision_date := sysdate;
                end if;

                if p_sj_job_type = wip_constants.nonstandard then
                        l_item_id := p_rj_bom_reference_id;
                else
                        l_item_id := p_rj_primary_item_id;
                end if;

                -- ST : Fix for bug 5218479 start : Added the BEGIN clause --
                BEGIN
                        -- call wip_revisions
                        wip_revisions.bom_revision(    p_organization_id =>  p_txn_org_id,
                                                       p_item_id         =>  l_item_id,
                                                       p_revision        =>  p_rj_bom_revision,
                                                       p_revision_date   =>  p_rj_bom_revision_date,
                                                       p_start_date      =>  p_rj_bom_revision_date
                                                  );
                EXCEPTION
                        WHEN e_invalid_revision THEN
                                l_error_out := 1;
                END ;
                -- ST : Fix for bug 5218479 end --

        else    -- revision date is not null
                l_bom_revision := null;

                if p_sj_job_type = wip_constants.nonstandard then
                        l_item_id := p_rj_bom_reference_id;
                else
                        l_item_id := p_rj_primary_item_id;
                end if;

                -- ST : Fix for bug 5218479 : Added BEGIN clause --
                BEGIN
                        wip_revisions.bom_revision( p_organization_id =>  p_txn_org_id,
                                                    p_item_id         =>  l_item_id,
                                                    p_revision        =>  l_bom_revision,
                                                    p_revision_date   =>  p_rj_bom_revision_date,
                                                    p_start_date      =>  p_rj_bom_revision_date
                                                 );

                        p_rj_bom_revision := nvl(p_rj_bom_revision,l_bom_revision);

                        IF l_bom_revision <> p_rj_bom_revision THEN
                                l_error_out := 1;
                        END IF;

                EXCEPTION
                        WHEN e_invalid_revision THEN
                                l_error_out := 1;
                END;
                -- ST : Fix for bug 5218479 : end --

        end if;

        -- ST : Fix for bug 5218479 --
        IF l_error_out = 1 THEN
                -- error out...
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'value for bom_revision';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
        END IF;
        -- ST : Fix for bug 5218479 end..

        l_stmt_num := 40;
        -- call bom_seq
        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := null;

        bom_seq  (  p_job_type              => p_sj_job_type ,   -- 1 std job, 3 or otherwise non-std
                    p_org_id                => p_txn_org_id,
                    p_item_id               => p_rj_primary_item_id,
                    p_alt_bom               => p_rj_alternate_bom_desig,
                    p_common_bom_seq_id     => p_rj_common_bom_seq_id,
                    p_bom_ref_id            => p_rj_bom_reference_id,
                    x_bom_seq_id            => l_bom_seq_id,
                    x_return_status         => l_return_status,
                    x_error_msg             => l_msg_data,
                    x_error_count           => l_msg_count
                );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Procedure bom_seq returned failure',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 50;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

exception
        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
end derive_val_bom_info;

-- Validate the completion subinventory details....
Procedure derive_val_compl_subinv( p_job_type                           IN              NUMBER,
                                   -- added for the call to LBJ procedure....
                                   p_old_rtg_seq_id                     IN              NUMBER,
                                   p_new_rtg_seq_id                     IN              NUMBER,
                                   p_organization_id                    IN              NUMBER,
                                   p_primary_item_id                    IN              NUMBER,
                                   p_sj_completion_subinventory         IN              VARCHAR2,
                                   p_sj_completion_locator_id           IN              NUMBER,
                                   p_rj_alt_rtg_designator              IN              VARCHAR2,       -- Added for the bug 5094555
                                   p_rj_rtg_reference_item_id           IN              NUMBER,         -- Added for the bug 5094555
                                   p_rj_completion_subinventory         IN  OUT NOCOPY  VARCHAR2,
                                   p_rj_completion_locator_id           IN  OUT NOCOPY  NUMBER,
                                   p_rj_completion_locator              IN  OUT NOCOPY  VARCHAR2,
                                   x_return_status                      OUT     NOCOPY  VARCHAR2,
                                   x_msg_count                          OUT     NOCOPY  NUMBER,
                                   x_msg_data                           OUT     NOCOPY  VARCHAR2
                               ) is

l_completion_subinventory       BOM_OPERATIONAL_ROUTINGS.COMPLETION_SUBINVENTORY%type;
l_completion_locator_id         number;

l_sub_loc_control               number;
l_org_loc_control               number;
l_restrict_loc_code             number;
l_item_loc_control              number;
l_temp_boolean                  boolean := true;
l_rtg_item_id                   NUMBER;

--- logging variables
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_compl_subinv';
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_stmt_num          NUMBER := 0;
l_param_tbl         WSM_Log_PVT.param_tbl_type;

begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_stmt_num := 10;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_stmt_num := 15;
                l_param_tbl.delete;

                l_param_tbl(1).paramName := 'p_job_type';
                l_param_tbl(1).paramValue := p_job_type;

                l_param_tbl(2).paramName := 'p_old_rtg_seq_id';
                l_param_tbl(2).paramValue := p_old_rtg_seq_id;

                l_param_tbl(3).paramName := 'p_new_rtg_seq_id';
                l_param_tbl(3).paramValue := p_new_rtg_seq_id;

                l_param_tbl(4).paramName := 'p_organization_id';
                l_param_tbl(4).paramValue := p_organization_id;

                l_param_tbl(5).paramName := 'p_primary_item_id';
                l_param_tbl(5).paramValue := p_primary_item_id;

                l_param_tbl(6).paramName := 'p_sj_completion_subinventory';
                l_param_tbl(6).paramValue := p_sj_completion_subinventory;

                l_param_tbl(7).paramName := 'p_sj_completion_locator_id';
                l_param_tbl(7).paramValue := p_sj_completion_locator_id;

                l_param_tbl(8).paramName := 'p_rj_alt_rtg_designator';
                l_param_tbl(8).paramValue := p_rj_alt_rtg_designator;

                l_param_tbl(9).paramName := 'p_rj_completion_subinventory';
                l_param_tbl(9).paramValue := p_rj_completion_subinventory;

                l_param_tbl(10).paramName := 'p_rj_completion_locator_id';
                l_param_tbl(10).paramValue := p_rj_completion_locator_id;

                l_param_tbl(11).paramName := 'p_rj_completion_locator';
                l_param_tbl(11).paramValue := p_rj_completion_locator;

                l_param_tbl(12).paramName := 'p_rj_rtg_reference_item_id';
                l_param_tbl(12).paramValue := p_rj_rtg_reference_item_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_stmt_num := 20;
        IF p_job_type = WIP_CONSTANTS.STANDARD THEN
                l_rtg_item_id := p_primary_item_id;
        ELSE
                l_rtg_item_id := p_rj_rtg_reference_item_id;
        END IF;

        -- If no change in routing..
        IF p_old_rtg_seq_id = p_new_rtg_seq_id THEN

                p_rj_completion_subinventory := nvl(p_rj_completion_subinventory,p_sj_completion_subinventory);

                IF p_rj_completion_locator IS NULL THEN
                       --Bug 5380799: Completion locator should be defaulted from starting job only when
                       --completion subinventory in the resulting job is same as that of starting job.
                        if p_rj_completion_subinventory = p_sj_completion_subinventory then
                           p_rj_completion_locator_id := nvl(p_rj_completion_locator_id,p_sj_completion_locator_id);
                        end if;--Bug 5380799:End of check on completion subinventory.
                ELSE
                        l_stmt_num := 30;
                        BEGIN
                                SELECT inventory_location_id
                                INTO p_rj_completion_locator_id
                                FROM mtl_item_locations_kfv
                                WHERE inventory_item_id = l_rtg_item_id -- p_primary_item_id
                                AND   organization_id   = p_organization_id
                                AND   subinventory_code = p_rj_completion_subinventory
                                AND   concatenated_segments =  nvl(p_rj_completion_locator,concatenated_segments);

                        EXCEPTION
                                WHEN no_data_found THEN
                                        -- error out....
                                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'value for completion subinventory';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                END IF;
        ELSE   -- p_old_rtg_seq_id <> p_new_rtg_seq_id
                l_stmt_num := 40;
                BEGIN

                        select bor.completion_subinventory, bor.completion_locator_id
                        into l_completion_subinventory,l_completion_locator_id
                        from bom_operational_routings bor
                        where bor.organization_id = p_organization_id
                        and   bor.common_routing_sequence_id = p_new_rtg_seq_id
                        -- ST : Fix for bug 5094555 start --
                        and   nvl(bor.alternate_routing_designator,'@@@@****') = nvl(p_rj_alt_rtg_designator,'@@@@****')
                        and   organization_id = p_organization_id
                        and   assembly_item_id = l_rtg_item_id; -- p_primary_item_id;
                        -- ST : Fix for bug 5094555 end --

                EXCEPTION
                        when no_data_found then
                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'or no matching value for completion subinventory';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                end;

                p_rj_completion_subinventory := nvl(p_rj_completion_subinventory,l_completion_subinventory);

                IF p_rj_completion_locator IS NULL THEN
                       --Bug 5380799: Completion locator should be defaulted from routing details only when
                       --completion subinventory in the resulting job is same as that in routing details.
                        IF p_rj_completion_subinventory = l_completion_subinventory THEN
                           p_rj_completion_locator_id := nvl(p_rj_completion_locator_id,l_completion_locator_id);
                        END IF;--Bug 5380799:End of check on completion subinventory.
                ELSE
                        l_stmt_num := 50;
                        BEGIN
                                select inventory_location_id
                                into p_rj_completion_locator_id
                                from mtl_item_locations_kfv
                                where inventory_item_id = l_rtg_item_id -- p_primary_item_id
                                and   organization_id   = p_organization_id
                                and   subinventory_code = p_rj_completion_subinventory
                                and   concatenated_segments =  p_rj_completion_locator;

                        EXCEPTION
                                WHEN no_data_found THEN
                                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'Completion locator id.';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                END IF;
        END IF;

        l_stmt_num := 60;
        -- call the LBJ code to validate.....
        --Bug 5380799:Locator id should be validated even if the locator id is null
        --if (p_rj_completion_locator_id is not null ) then
                  -- Validate locator id (std job creation)
                BEGIN
                        SELECT  nvl(msi.locator_type, 1),
                                mp.stock_locator_control_code,
                                ms.restrict_locators_code,
                                ms.location_control_code
                        into    l_sub_loc_control,
                                l_org_loc_control,
                                l_restrict_loc_code,
                                l_item_loc_control
                        from    mtl_system_items ms,
                                mtl_secondary_inventories msi,
                                mtl_parameters mp
                        where   mp.organization_id = p_organization_id
                        and     ms.organization_id = p_organization_id
                        and     ms.inventory_item_id = l_rtg_item_id -- p_primary_item_id
                        and     msi.secondary_inventory_name = p_rj_completion_subinventory
                        and     msi.organization_id = p_organization_id;

                exception
                    when NO_DATA_FOUND then
                        -- error out..
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'Completion locator.';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                end;
                l_stmt_num := 70;
                begin
                        WIP_LOCATOR.validate (  p_organization_id,
                                                l_rtg_item_id    ,   -- p_primary_item_id,
                                                p_rj_completion_subinventory,
                                                l_org_loc_control,
                                                l_sub_loc_control,
                                                l_item_loc_control,
                                                l_restrict_loc_code,
                                                NULL, NULL, NULL, NULL,
                                                p_rj_completion_locator_id,
                                                p_rj_completion_locator,
                                                l_temp_boolean
                                             );
                exception
                        when NO_DATA_FOUND then
                                l_temp_boolean := FALSE;
                end;
                l_stmt_num := 80;
                if not l_temp_boolean then
                     IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'COMPLETION_LOCATOR_ID';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    RETURN;
                END IF;
        --END IF; --Bug 5380799:Locator id validation is called even if the locator id is null.

        x_return_status := FND_API.G_RET_STS_SUCCESS;
exception

        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
end derive_val_compl_subinv;

-- Procedure to derive/validate the starting operation information....
Procedure derive_val_starting_op (  p_txn_org_id                IN              NUMBER,
                                    p_curr_op_seq_id            IN              NUMBER,
                                    p_curr_op_code              IN              VARCHAR2,
                                    p_curr_std_op_id            IN              NUMBER,
                                    p_curr_intra_op_step        IN              NUMBER,
                                    p_new_comm_rtg_seq_id       IN              NUMBER,
                                    p_new_rtg_rev_date          IN              DATE,
                                    p_new_op_seq_num            IN OUT NOCOPY   NUMBER,
                                    p_new_op_seq_id             IN OUT NOCOPY   NUMBER,
                                    p_new_std_op_id             IN OUT NOCOPY   NUMBER,
                                    p_new_op_seq_code           IN OUT NOCOPY   VARCHAR2,
                                    p_new_dept_id               IN OUT NOCOPY   NUMBER,
                                    x_return_status             OUT    NOCOPY   varchar2,
                                    x_msg_count                 OUT    NOCOPY   NUMBER,
                                    x_msg_data                  OUT    NOCOPY   VARCHAR2
                                  ) is

l_op_is_std             number;
l_op_rptd_time          number;
l_err_code              number;
l_err_msg               varchar2(2000);

l_operation_code        BOM_STANDARD_OPERATIONS.OPERATION_CODE%type;
l_op_rptd_times         number;

-- logging variables
l_stmt_num          number:=0;
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_starting_op';

begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- currently not supported for option 'a' : assumption it is not supported
        l_stmt_num :=10;
        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered derive_val_starting_op' ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        if p_new_op_seq_num is null and p_new_op_seq_id is null then

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'p_new_op_seq_num and p_new_op_seq_id is null',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                if p_curr_intra_op_step = WIP_CONSTANTS.QUEUE then
                        l_stmt_num :=20;

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Calling WSMPUTIL.operation_is_standard_repeats',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        -- logic goes here.....
                        l_err_code      := 0;
                        l_err_msg       := null;
                        WSMPUTIL.operation_is_standard_repeats  ( p_routing_sequence_id   => p_new_comm_rtg_seq_id,
                                                                  p_routing_revision_date => p_new_rtg_rev_date,
                                                                  p_standard_operation_id => p_curr_std_op_id,
                                                                  p_operation_code        => p_curr_op_code,
                                                                  p_organization_id       => p_txn_org_id,
                                                                  p_op_is_std_op          => l_op_is_std,
                                                                  p_op_repeated_times     => l_op_rptd_times,
                                                                  x_err_code              => l_err_code,
                                                                  x_err_msg               => l_err_msg);

                        if l_err_code <> 0 then
                                -- error out....
                                if( g_log_level_statement   >= l_log_level ) then

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           =>  'WSMPUTIL.operation_is_standard_repeats returned failure',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                        end if;

                        if l_op_rptd_times = 1 then  -- Found a match
                                l_stmt_num :=30;
                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Found match in resulting routing',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                BEGIN
                                        SELECT bos.operation_seq_num,
                                               bso.operation_code,
                                               bos.operation_sequence_id,
                                               bos.standard_operation_id,
                                               BD.department_id
                                        into   p_new_op_seq_num,
                                               l_operation_code,
                                               p_new_op_seq_id,
                                               p_new_std_op_id,
                                               p_new_dept_id
                                        FROM   bom_standard_operations BSO,
                                               bom_operation_sequences BOS,
                                               bom_departments BD
                                        WHERE  BOS.routing_sequence_id   = p_new_comm_rtg_seq_id
                                        AND    BSO.standard_operation_id = BOS.standard_operation_id
                                        AND    BSO.standard_operation_id = p_curr_std_op_id
                                        AND    BD.department_id          = BOS.department_id
                                        AND    BD.department_id          = nvl(p_new_dept_id,BD.department_id)
                                        AND    p_new_rtg_rev_date between BOS.effectivity_date and nvl(BOS.disable_date, p_new_rtg_rev_date+1);

                                        if p_new_op_seq_code is null then
                                                p_new_op_seq_code := l_operation_code;
                                        elsif nvl(p_new_op_seq_code,'$$&&') <> nvl(l_operation_code,'$$&&') then
                                                --  ST : Fix for bug 5116062 : Added an outer NVL clause
                                                -- error out.... wrong op_code...
                                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                        l_msg_tokens.delete;
                                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                        l_msg_tokens(1).TokenValue := 'value for operation code';
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                                               p_msg_appl_name      => 'WSM'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                END IF;
                                                raise FND_API.G_EXC_ERROR;
                                        end if;

                                EXCEPTION
                                        when no_data_found then
                                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                                        l_msg_tokens.delete;
                                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                        l_msg_tokens(1).TokenValue := 'Starting operation information';
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                                               p_msg_appl_name      => 'WSM'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                END IF;
                                                raise FND_API.G_EXC_ERROR;
                                END;

                        elsif l_op_rptd_times > 1 then
                                l_stmt_num :=40;
                                -- have to error out... repeated in the target ....
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_JOB_AT_REPEATED_OP',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                        else
                                l_stmt_num :=50;
                                -- no match found....
                                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_NO_CURRENT_STDOP_TGTRTG',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                        end if;

                else
                        l_stmt_num :=60;
                        -- error out as for ToMove have to provide the starting op...
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_START_OP_REQD',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                end if;
        else
                -- logic .....
                l_stmt_num :=70;
                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'p_new_op_seq_num and p_new_op_seq_id is not null',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                BEGIN
                        if p_new_std_op_id is null and p_new_op_seq_code is null then

                                l_stmt_num :=80;

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'p_new_std_op_id and p_new_op_seq_code is null',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                -- might be a non-standard...
                                SELECT bos.operation_seq_num,
                                       bso.operation_code,
                                       bos.operation_sequence_id,
                                       bos.standard_operation_id,
                                       BD.department_id
                                into   p_new_op_seq_num,
                                       p_new_op_seq_code,
                                       p_new_op_seq_id,
                                       p_new_std_op_id,
                                       p_new_dept_id
                                FROM   bom_standard_operations BSO,
                                       bom_operation_sequences BOS,
                                       bom_departments BD
                                WHERE  BOS.routing_sequence_id   = p_new_comm_rtg_seq_id
                                AND    BOS.operation_seq_num     = nvl(p_new_op_seq_num,BOS.operation_seq_num)
                                AND    BOS.operation_sequence_id = nvl(p_new_op_seq_id,BOS.operation_sequence_id)
                                AND    BOS.standard_operation_id = BSO.standard_operation_id (+)
                                AND    nvl(p_new_std_op_id,BOS.standard_operation_id) = BSO.standard_operation_id (+)
                                AND    BD.department_id          = BOS.department_id
                                AND    BD.department_id          = nvl(p_new_dept_id,BD.department_id)
                                AND    p_new_rtg_rev_date between BOS.effectivity_date and nvl(BOS.disable_date, p_new_rtg_rev_date+1);

                        else
                                l_stmt_num :=90;

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'p_new_std_op_id and p_new_op_seq_code is not null',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                SELECT bos.operation_seq_num,
                                       bso.operation_code,
                                       bos.operation_sequence_id,
                                       bos.standard_operation_id,
                                       BD.department_id
                                into   p_new_op_seq_num,
                                       p_new_op_seq_code,
                                       p_new_op_seq_id,
                                       p_new_std_op_id,
                                       p_new_dept_id
                                FROM   bom_standard_operations BSO,
                                       bom_operation_sequences BOS,
                                       bom_departments BD
                                WHERE  BOS.routing_sequence_id   = p_new_comm_rtg_seq_id
                                AND    BOS.operation_seq_num     = nvl(p_new_op_seq_num,BOS.operation_seq_num)
                                AND    BOS.operation_sequence_id = nvl(p_new_op_seq_id,BOS.operation_sequence_id)
                                AND    BOS.standard_operation_id = BSO.standard_operation_id
                                AND    BSO.standard_operation_id = nvl(p_new_std_op_id,BSO.standard_operation_id)
                                -- ST : Fix for bug 5116062 : Added an outer NVL clause
                                AND    nvl(BSO.operation_code,'$$&&') = nvl(nvl(p_new_op_seq_code,BSO.operation_code),'$$&&')
                                AND    BD.department_id          = BOS.department_id
                                AND    BD.department_id          = nvl(p_new_dept_id,BD.department_id)
                                AND    p_new_rtg_rev_date between BOS.effectivity_date and nvl(BOS.disable_date, p_new_rtg_rev_date+1);

                        end if;

                EXCEPTION
                        when no_data_found then
                                -- error out....
                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'start operation information';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                END;
        end if;

        -- check for PO_MOVE....
        l_err_code := 0;
        If  WSMPUTIL.CHECK_PO_MOVE( p_sequence_id      => p_new_op_seq_id       ,
                                    p_sequence_id_type => 'O'                   ,
                                    p_routing_rev_date => p_new_rtg_rev_date    ,
                                    x_err_code         => l_err_code            ,
                                    x_err_msg          => l_err_msg)
        THEN
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_OP_PO_MOVE',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                raise FND_API.G_EXC_ERROR;
        END IF;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'End of derive_val_starting_op',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

exception

        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
end derive_val_starting_op;

-- Procedure derive/validate the item information
Procedure derive_val_primary_item (  p_txn_org_id       IN              NUMBER,
                                     p_old_item_id      IN              NUMBER,
                                     p_new_item_name    IN              VARCHAR2,
                                     p_new_item_id      IN OUT NOCOPY   NUMBER,
                                     x_return_status    OUT NOCOPY      varchar2,
                                     x_msg_count        OUT NOCOPY      NUMBER,
                                     x_msg_data         OUT NOCOPY      VARCHAR2
                                  ) is
l_lot_control_code              NUMBER;
l_serial_number_control_code    NUMBER;

-- logging variables
l_stmt_num          number:=0;
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.derive_val_primary_item';

begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num   := 10;
        IF p_new_item_name IS NULL AND p_new_item_id IS NULL THEN
                -- error out.... .
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'p_new_item_name and  p_new_item_id ';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NULL_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
              END IF;

             RAISE FND_API.G_EXC_ERROR;

        end if;

        l_stmt_num   := 20;
        BEGIN
                -- ST : Bug fix 4914162 : Added an IF clause
                IF p_new_item_id IS NOT NULL THEN
                        SELECT inventory_item_id,LOT_CONTROL_CODE,SERIAL_NUMBER_CONTROL_CODE
                        INTO p_new_item_id,
                             l_lot_control_code,
                             l_serial_number_control_code
                        from mtl_system_items_kfv
                        where inventory_item_id = p_new_item_id
                        and concatenated_segments = nvl(p_new_item_name,concatenated_segments)
                        and organization_id = p_txn_org_id;
                ELSE
                        SELECT inventory_item_id,LOT_CONTROL_CODE,SERIAL_NUMBER_CONTROL_CODE
                        INTO p_new_item_id,
                             l_lot_control_code,
                             l_serial_number_control_code
                        from mtl_system_items_kfv
                        where concatenated_segments = p_new_item_name
                        and organization_id = p_txn_org_id;
                END IF;
        EXCEPTION
                WHEN no_data_found THEN
                        -- Invalid item name / item id combo.... error out
                        IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'value for item name / item_id specified ';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
        END;

        l_stmt_num   := 30;
        IF p_new_item_id = p_old_item_id then
                -- error out....
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Assembly cannot be same';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num   := 40;
        if l_lot_control_code <> 2 OR (l_serial_number_control_code NOT IN(1,2))then
                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN

                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'value for lot_control_code/serial_control_code';
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        end if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

exception

        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
end derive_val_primary_item;

-- Inserts the data into the base tables...
Procedure insert_txn_data (p_transaction_id             IN              NUMBER,
                           p_wltx_header                IN              WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                           p_wltx_starting_jobs_tbl     IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                           p_wltx_resulting_jobs_tbl    IN              WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                           x_return_status              OUT     NOCOPY  VARCHAR2,
                           x_msg_count                  OUT     NOCOPY  NUMBER,
                           x_msg_data                   OUT     NOCOPY  VARCHAR2
                          ) IS

     -- Status variables
     l_return_status  VARCHAR2(1);
     l_msg_count      NUMBER;
     l_msg_data       VARCHAR2(2000);

     -- local variable for logging purpose
     l_stmt_num         NUMBER := 0;
     l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
     l_log_level            number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_module       VARCHAR2(100) := 'wsm.plsql.WSM_WLT_VALIDATE_PVT.insert_txn_data';

     -- Loop Variable --
     l_counter          NUMBER := 0;

     -- Starting and resulting jobs records
     l_starting_job_rec  WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE;
     l_resulting_job_rec WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE;


BEGIN
    -- Have a starting point
    savepoint start_insert_txn_data;

    l_stmt_num := 10;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log the Procedure entry point....
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entering the Insert Txn Data procedure to insert into the base tables',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 20;

        -- Start insert into WSMT table
        INSERT INTO wsm_split_merge_transactions(
               TRANSACTION_ID,
               TRANSACTION_TYPE_ID,
               ORGANIZATION_ID,
               INTERNAL_GROUP_ID,
               REASON_ID,
               TRANSACTION_DATE,
               TRANSACTION_REFERENCE,
               STATUS,
               SUSPENSE_ACCT_ID,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN,
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
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID ,
               PROGRAM_UPDATE_DATE,
               EMPLOYEE_ID        ,  --Added for MES
               COSTED
       )
          VALUES
              (
               p_TRANSACTION_ID,
               p_wltx_header.transaction_type_id,
               p_wltx_header.ORGANIZATION_ID,
               WSMPLOAD.G_GROUP_ID,
               p_wltx_header.REASON_ID,
               p_wltx_header.TRANSACTION_DATE,
               p_wltx_header.TRANSACTION_REFERENCE,
               WIP_CONSTANTS.COMPLETED,
               null,--p_wltx_header.SUSPENSE_ACCT_ID,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               p_wltx_header.ATTRIBUTE_CATEGORY,
               p_wltx_header.ATTRIBUTE1,
               p_wltx_header.ATTRIBUTE2,
               p_wltx_header.ATTRIBUTE3,
               p_wltx_header.ATTRIBUTE4,
               p_wltx_header.ATTRIBUTE5,
               p_wltx_header.ATTRIBUTE6,
               p_wltx_header.ATTRIBUTE7,
               p_wltx_header.ATTRIBUTE8,
               p_wltx_header.ATTRIBUTE9,
               p_wltx_header.ATTRIBUTE10,
               p_wltx_header.ATTRIBUTE11,
               p_wltx_header.ATTRIBUTE12,
               p_wltx_header.ATTRIBUTE13,
               p_wltx_header.ATTRIBUTE14,
               p_wltx_header.ATTRIBUTE15,
               FND_GLOBAL.CONC_REQUEST_ID,
               FND_GLOBAL.PROG_APPL_ID,
               FND_GLOBAL.CONC_PROGRAM_ID,
               sysdate,
               p_wltx_header.EMPLOYEE_ID ,--Added for MES
               decode(p_wltx_header.transaction_type_id,3,WIP_CONSTANTS.COMPLETED,
                                                        5,WIP_CONSTANTS.COMPLETED,
                                                        7,WIP_CONSTANTS.COMPLETED,
                                                        WIP_CONSTANTS.PENDING
                    )
               );

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Inserted Txn Header Data into the wsm_split_merge_transactions',
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
       End if;

        l_stmt_num := 30;
        -- Start insert into starting lots base table
        l_counter := p_wltx_starting_jobs_tbl.first;

    while l_counter is not null loop

         l_starting_job_rec := p_wltx_starting_jobs_tbl(l_counter);

         INSERT INTO wsm_sm_starting_jobs(
               TRANSACTION_ID,
               WIP_ENTITY_ID,
               INTERNAL_GROUP_ID,
               PRIMARY_ITEM_ID,
               OPERATION_SEQ_NUM,
               INTRAOPERATION_STEP,
               JOB_START_QUANTITY,
               AVAILABLE_QUANTITY,
               REPRESENTATIVE_FLAG,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN,
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
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               WIP_ENTITY_NAME,
               NET_QUANTITY,
               ROUTING_SEQ_ID,
               ROUTING_REFERENCE_ID,
               BOM_REFERENCE_ID,
               ORGANIZATION_ID,
               DESCRIPTION,
               COMPLETION_SUBINVENTORY,
               COMPLETION_LOCATOR_ID,
               BILL_SEQUENCE_ID,
               DEPARTMENT_ID,
               OPERATION_SEQUENCE_ID,
               BOM_REVISION,
               BOM_REVISION_DATE,
               ROUTING_REVISION,
               ROUTING_REVISION_DATE,
               SCHEDULED_START_DATE,
               SCHEDULED_COMPLETION_DATE,
               COPRODUCTS_SUPPLY)
           VALUES
              (
               p_TRANSACTION_ID,
               l_starting_job_rec.WIP_ENTITY_ID,
               WSMPLOAD.G_GROUP_ID,
               l_starting_job_rec.PRIMARY_ITEM_ID,
               l_starting_job_rec.OPERATION_SEQ_NUM,
               l_starting_job_rec.INTRAOPERATION_STEP,
               l_starting_job_rec.START_QUANTITY,
               l_starting_job_rec.QUANTITY_available,
               l_starting_job_rec.REPRESENTATIVE_FLAG,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               l_starting_job_rec.ATTRIBUTE_CATEGORY,
               l_starting_job_rec.ATTRIBUTE1,
               l_starting_job_rec.ATTRIBUTE2,
               l_starting_job_rec.ATTRIBUTE3,
               l_starting_job_rec.ATTRIBUTE4,
               l_starting_job_rec.ATTRIBUTE5,
               l_starting_job_rec.ATTRIBUTE6,
               l_starting_job_rec.ATTRIBUTE7,
               l_starting_job_rec.ATTRIBUTE8,
               l_starting_job_rec.ATTRIBUTE9,
               l_starting_job_rec.ATTRIBUTE10,
               l_starting_job_rec.ATTRIBUTE11,
               l_starting_job_rec.ATTRIBUTE12,
               l_starting_job_rec.ATTRIBUTE13,
               l_starting_job_rec.ATTRIBUTE14,
               l_starting_job_rec.ATTRIBUTE15,
               fnd_global.conc_REQUEST_ID,
               FND_GLOBAL.PROG_APPL_ID,
               FND_GLOBAL.CONC_PROGRAM_ID,
               sysdate,
               l_starting_job_rec.WIP_ENTITY_NAME,
               l_starting_job_rec.NET_QUANTITY,
               l_starting_job_rec.COMMON_ROUTING_SEQUENCE_ID,
               l_starting_job_rec.ROUTING_REFERENCE_ID,
               l_starting_job_rec.BOM_REFERENCE_ID,
               l_starting_job_rec.ORGANIZATION_ID,
               l_starting_job_rec.DESCRIPTION,
               l_starting_job_rec.COMPLETION_SUBINVENTORY,
               l_starting_job_rec.COMPLETION_LOCATOR_ID,
               l_starting_job_rec.COMMON_BILL_SEQUENCE_ID,
               l_starting_job_rec.DEPARTMENT_ID,
               l_starting_job_rec.OPERATION_SEQ_ID,
               l_starting_job_rec.BOM_REVISION,
               l_starting_job_rec.BOM_REVISION_DATE,
               l_starting_job_rec.ROUTING_REVISION,
               l_starting_job_rec.ROUTING_REVISION_DATE,
               l_starting_job_rec.SCHEDULED_START_DATE,
               l_starting_job_rec.SCHEDULED_COMPLETION_DATE,
               l_starting_job_rec.COPRODUCTS_SUPPLY
              );
               l_counter := p_wltx_starting_jobs_tbl.next(l_counter);
    end loop;
    if( g_log_level_statement   >= l_log_level ) then
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                               p_msg_text           => 'Inserted '||SQL%ROWCOUNT||' records with transaction id:'|| p_wltx_header.transaction_id ,
                               p_stmt_num           => l_stmt_num,
                                p_msg_tokens        => l_msg_tokens,
                               p_fnd_log_level      => g_log_level_statement,
                               p_run_log_level      => l_log_level
                              );
    End if;

    l_stmt_num := 40;

    -- Start insert into resulting lots base table
    l_counter := p_wltx_resulting_jobs_tbl.first;
    while l_counter is not null loop

        l_resulting_job_rec := p_wltx_resulting_jobs_tbl(l_counter);

        INSERT INTO wsm_sm_resulting_jobs(
               TRANSACTION_ID,
               WIP_ENTITY_NAME,
               WIP_ENTITY_ID,
               DESCRIPTION,
               INTERNAL_GROUP_ID,
               PRIMARY_ITEM_ID,
               CLASS_CODE,
               BONUS_ACCT_ID,
               START_QUANTITY,
               NET_QUANTITY,
               BOM_REFERENCE_ID,
               ROUTING_REFERENCE_ID,
               COMMON_BOM_SEQUENCE_ID,
               COMMON_ROUTING_SEQUENCE_ID,
               BOM_REVISION,
               BOM_REVISION_DATE,
               ROUTING_REVISION_DATE,
               ROUTING_REVISION,
               ALTERNATE_BOM_DESIGNATOR,
               ALTERNATE_ROUTING_DESIGNATOR,
               COPRODUCTS_SUPPLY,
               COMPLETION_LOCATOR_ID,
               COMPLETION_SUBINVENTORY,
               STARTING_OPERATION_CODE,
               STARTING_STD_OP_ID,
               STARTING_OPERATION_SEQ_NUM,
               STARTING_INTRAOPERATION_STEP,
               SCHEDULED_START_DATE,
               SCHEDULED_COMPLETION_DATE,
               DEMAND_CLASS,
               FORWARD_OP_OPTION,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN,
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
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               JOB_TYPE,
               ORGANIZATION_ID,
               SPLIT_HAS_UPDATE_ASSY,
               JOB_OPERATION_SEQ_NUM)
        VALUES
              (
               p_TRANSACTION_ID,
               l_resulting_job_rec.WIP_ENTITY_NAME,
               l_resulting_job_rec.WIP_ENTITY_ID,
               l_resulting_job_rec.DESCRIPTION,
               WSMPLOAD.G_GROUP_ID,
               l_resulting_job_rec.PRIMARY_ITEM_ID,
               l_resulting_job_rec.CLASS_CODE,
               l_resulting_job_rec.BONUS_ACCT_ID,
               l_resulting_job_rec.START_QUANTITY,
               l_resulting_job_rec.NET_QUANTITY,
               l_resulting_job_rec.BOM_REFERENCE_ID,
               l_resulting_job_rec.ROUTING_REFERENCE_ID,
               l_resulting_job_rec.COMMON_BOM_SEQUENCE_ID,
               l_resulting_job_rec.COMMON_ROUTING_SEQUENCE_ID,
               l_resulting_job_rec.BOM_REVISION,
               l_resulting_job_rec.BOM_REVISION_DATE,
               l_resulting_job_rec.ROUTING_REVISION_DATE,
               l_resulting_job_rec.ROUTING_REVISION,
               l_resulting_job_rec.ALTERNATE_BOM_DESIGNATOR,
               l_resulting_job_rec.ALTERNATE_ROUTING_DESIGNATOR,
               l_resulting_job_rec.COPRODUCTS_SUPPLY,
               l_resulting_job_rec.COMPLETION_LOCATOR_ID,
               l_resulting_job_rec.COMPLETION_SUBINVENTORY,
               l_resulting_job_rec.STARTING_OPERATION_CODE,
               l_resulting_job_rec.STARTING_STD_OP_ID,
               l_resulting_job_rec.STARTING_OPERATION_SEQ_NUM,
               l_resulting_job_rec.STARTING_INTRAOPERATION_STEP,
               l_resulting_job_rec.SCHEDULED_START_DATE,
               l_resulting_job_rec.SCHEDULED_COMPLETION_DATE,
               null, -- l_resulting_job_rec.DEMAND_CLASS,
               null,--l_resulting_job_rec.FORWARD_OP_OPTION,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               l_resulting_job_rec.ATTRIBUTE_CATEGORY,
               l_resulting_job_rec.ATTRIBUTE1,
               l_resulting_job_rec.ATTRIBUTE2,
               l_resulting_job_rec.ATTRIBUTE3,
               l_resulting_job_rec.ATTRIBUTE4,
               l_resulting_job_rec.ATTRIBUTE5,
               l_resulting_job_rec.ATTRIBUTE6,
               l_resulting_job_rec.ATTRIBUTE7,
               l_resulting_job_rec.ATTRIBUTE8,
               l_resulting_job_rec.ATTRIBUTE9,
               l_resulting_job_rec.ATTRIBUTE10,
               l_resulting_job_rec.ATTRIBUTE11,
               l_resulting_job_rec.ATTRIBUTE12,
               l_resulting_job_rec.ATTRIBUTE13,
               l_resulting_job_rec.ATTRIBUTE14,
               l_resulting_job_rec.ATTRIBUTE15,
               fnd_global.conc_REQUEST_ID,
               FND_GLOBAL.PROG_APPL_ID,
               FND_GLOBAL.CONC_PROGRAM_ID,
               sysdate,
               l_resulting_job_rec.JOB_TYPE,
               l_resulting_job_rec.ORGANIZATION_ID,
               l_resulting_job_rec.SPLIT_HAS_UPDATE_ASSY,
               l_resulting_job_rec.job_operation_seq_num
              );

              l_counter := p_wltx_resulting_jobs_tbl.next(l_counter);
      END LOOP;

      if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Inserted '||SQL%ROWCOUNT||'records with transaction id:'|| p_wltx_header.transaction_id ,
                                       p_stmt_num           => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
      End if;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );

END;

-- procedure specific to bonus...
Procedure validate_network(     p_txn_org_id            IN              NUMBER  ,
                                p_rtg_seq_id            IN              NUMBER  ,
                                p_revision_date         IN              DATE    ,
                                p_start_op_seq_num      IN OUT NOCOPY   NUMBER  ,
                                p_start_op_seq_id       IN OUT NOCOPY   NUMBER  ,
                                p_start_op_seq_code     IN OUT NOCOPY   VARCHAR2,
                                p_dept_id               IN OUT NOCOPY   NUMBER  ,
                                x_return_status         OUT NOCOPY      VARCHAR2,
                                x_msg_count             OUT NOCOPY      NUMBER  ,
                                x_msg_data              OUT NOCOPY      VARCHAR2
                          )
IS

l_err_code              number;
l_err_msg               varchar2(2000);

l_end_op_seq_id         number;
l_start_op_seq_id       number;

l_flag                  number;
l_primary               number;

-- Logging variables.....
l_msg_tokens            WSM_Log_PVT.token_rec_tbl;
l_log_level             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num              NUMBER;
l_module                VARCHAR2(100) :='wsm.plsql.WSM_WLT_VALIDATE_PVT.validate_network';
BEGIN
        x_return_status := G_RET_SUCCESS;
        l_stmt_num := 10;
        l_err_code := 0;
        l_err_msg  := null;

        WSMPUTIL.find_routing_start (p_routing_sequence_id => p_rtg_seq_id,
                                     p_routing_rev_date    => p_revision_date,
                                     start_op_seq_id       => l_start_op_seq_id,
                                     x_err_code            => l_err_code,
                                     x_err_msg             => l_err_msg);

        if l_err_code <> 0 then
             if( g_log_level_statement   >= l_log_level ) then

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSMPUTIL.find_routing_start returned failure:'||l_err_msg,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
              END IF;
              RAISE FND_API.G_EXC_ERROR;
        end if;

        --Bug 5395091: Get replacement op seq id for the starting op seq id determined above.
        l_start_op_seq_id := WSMPUTIL.replacement_op_seq_id(l_start_op_seq_id,p_revision_date);

        l_stmt_num := 20;
        l_err_code := 0;
        l_err_msg  := null;

        WSMPUTIL.find_routing_end (    p_routing_sequence_id => p_rtg_seq_id,
                                       p_routing_rev_date    => p_revision_date,
                                       end_op_seq_id         => l_end_op_seq_id,
                                       x_err_code            => l_err_code,
                                       x_err_msg             => l_err_msg);

        if l_err_code <> 0 then
              if( g_log_level_statement   >= l_log_level ) then

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSMPUTIL.find_routing_end returned failure:'||l_err_msg,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
              END IF;
              RAISE FND_API.G_EXC_ERROR;
        end if;
        --Bug 5395091: Get replacement op seq id for the end op seq id determined above.
        l_end_op_seq_id := WSMPUTIL.replacement_op_seq_id(l_end_op_seq_id,p_revision_date);

        l_stmt_num := 30;
        if p_start_op_seq_num IS null and p_start_op_seq_id IS null and p_start_op_seq_code IS null then
                select bos.OPERATION_SEQ_NUM ,
                       bos.OPERATION_SEQUENCE_ID ,
                       bso.OPERATION_CODE
                into p_start_op_seq_num,
                     p_start_op_seq_id,
                     p_start_op_seq_code
                from bom_operation_sequences BOS,
                     bom_standard_operations BSO
                where bos.OPERATION_SEQUENCE_ID = l_start_op_seq_id
                and BOS.routing_sequence_id     = p_rtg_seq_id
                and BSO.standard_operation_id  (+)   = BOS.standard_operation_id
                and p_revision_date between BOS.effectivity_date and nvl(BOS.disable_date, p_revision_date+1);
        else
                l_stmt_num := 40;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Start Op Seq Num : ' || p_start_op_seq_num ||
                                                                       ' Routing seq Id  : ' || p_rtg_seq_id       ||
                                                                       ' p_start_op_seq_id : ' || p_start_op_seq_id ||
                                                                       ' p_start_op_seq_code : ' || p_start_op_seq_code ||
                                                                       ' Revision Date   : ' || p_revision_date,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                BEGIN
                        select 1
                        into l_flag
                        from bom_operation_sequences BOS,
                             bom_standard_operations BSO
                        where bos.OPERATION_SEQ_NUM = nvl(p_start_op_seq_num,bos.OPERATION_SEQ_NUM)
                        and bos.OPERATION_SEQUENCE_ID = nvl(p_start_op_seq_id,bos.OPERATION_SEQUENCE_ID)
                        -- ST : Fix for bug 5116062 : Added an outer NVL clause
                        and nvl(bso.OPERATION_CODE,'$$&&') = nvl(nvl(p_start_op_seq_code,bso.OPERATION_CODE),'$$&&')
                        and bos.routing_sequence_id = p_rtg_seq_id
                        and BSO.standard_operation_id  (+)   = BOS.standard_operation_id
                        and p_revision_date between BOS.effectivity_date and nvl(BOS.disable_date, p_revision_date+1);
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR) THEN
                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'starting_operation';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FIELD',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                END;

                -- Is it a primary path..... .
                BEGIN
                        l_stmt_num := 50;
                        select 1
                        into l_primary
                        from dual
                        where 1 in (    select 1
                                        from    bom_operation_networks  bon,
                                                bom_operation_sequences bos
                                        where   bon.transition_type = 1 -- Primary
                                        and     nvl(bon.disable_date, sysdate+1) > p_revision_date  -- or is it sysdate
                                        -- Start : Fix for bug 4494368/4576184 --
                                        --and     WSMPUTIL.replacement_op_seq_id(bon.from_op_seq_id,
                                        --                                       p_revision_date) = bos.operation_sequence_id
                                        and     bon.from_op_seq_id = bos.operation_sequence_id
                                        and     p_revision_date between bos.effectivity_date and nvl(bos.disable_date, p_revision_date+1)
                                        -- End : Fix for bug 4494368/4576184 --
                                        and     bos.routing_sequence_id = p_rtg_seq_id
                                        and     bos.operation_seq_num = p_start_op_seq_num

                                        UNION

                                        select  1
                                        from    bom_operation_networks  bon,
                                                bom_operation_sequences bos
                                        -- Start : Fix for bug 4494368/4576184 --
                                        --where   WSMPUTIL.replacement_op_seq_id(bon.to_op_seq_id,
                                        --                                       p_revision_date) = bos.operation_sequence_id
                                        where   bon.to_op_seq_id = bos.operation_sequence_id
                                        and     p_revision_date between bos.effectivity_date and nvl(bos.disable_date, p_revision_date+1)
                                        -- End : Fix for bug 4494368/4576184 --
                                        and bos.routing_sequence_id = p_rtg_seq_id
                                        and bos.operation_seq_num = p_start_op_seq_num
                                        and bon.to_op_seq_id not in ( select bon1.from_op_seq_id
                                                                      from   bom_operation_networks bon1,
                                                                             bom_operation_sequences bos1
                                                                       where  WSMPUTIL.replacement_op_seq_id (
                                                                                          bon1.from_op_seq_id,
                                                                                          p_revision_date) = bos1.operation_sequence_id
                                                                      and    bos1.routing_sequence_id = p_rtg_seq_id)
                                 );

                EXCEPTION
                         WHEN NO_DATA_FOUND then
                                   -- not on the primary path....
                                   IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                                       p_msg_name           => 'WSM_OPRN_NOT_PRIMARY',
                                                       p_msg_appl_name      => 'WSM',
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                                   END IF;
                                   RAISE FND_API.G_EXC_ERROR;
                END;

                -- Checks if primary path exists till the start....
                l_stmt_num := 60;
                IF (WSMPUTIL.primary_path_is_effective_till( p_routing_sequence_id       => p_rtg_seq_id,
                                                             p_routing_rev_date          => p_revision_date,
                                                             p_start_op_seq_id           => p_start_op_seq_id,
                                                             p_op_seq_num                => p_start_op_seq_num,
                                                             x_err_code                  => l_err_code,
                                                             x_err_msg                   => l_err_msg
                                                            )
                                                        = 0)
                THEN
                       -- Disabled primary path.............
                       IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name=> l_module                 ,
                                               p_msg_name           => 'WSM_PRIMARY_PATH_DISABLED',
                                               p_msg_appl_name      => 'WSM',
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
               END IF;
        END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
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

                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_msg_data
                                          );
END;
end WSM_WLT_VALIDATE_PVT;

/
