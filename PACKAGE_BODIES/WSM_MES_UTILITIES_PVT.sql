--------------------------------------------------------
--  DDL for Package Body WSM_MES_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_MES_UTILITIES_PVT" AS
/* $Header: WSMMESUB.pls 120.26 2006/08/22 06:46:54 nlal noship $ */
--mes
g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error     NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success   NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error         VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
--mes end

/*
 * Will return a codemask, indicate whether move in, move out, move to next is allowed
 *
 * 2^16 = 65536     move in
 * 2^17 = 131072    move out
 * 2^18 = 262144    move to next op
 */
function move_txn_allowed(
            p_responsibility_id         in number,
            p_wip_entity_id             in number,
            p_org_id                    in number,
            p_job_op_seq_num            in number,
            p_standard_op_id            in number,
            p_intraop_step              in number,
            p_status_type               in number
) return number is

l_char_temp         varchar2(1) := 'E';
l_excluded          number := 2;
l_use_org_settings  number := 0;
l_queue_mandatory   number := 0;
l_run_mandatory     number := 0;
l_to_move_mandatory number := 0;
l_move_in_option    number := 0;
l_move_next_option  number := 0;

-- Logging variables.....
      l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
      l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_MES_UTILITIES_PVT.move_txn_allowed';
      l_param_tbl                             WSM_Log_PVT.param_tbl_type;
      l_error_count                           NUMBER;
      l_return_code                           NUMBER;
      l_error_msg                             VARCHAR2(4000);

begin
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
      l_param_tbl.delete;
      l_param_tbl(1).paramName := 'p_responsibility_id';
      l_param_tbl(1).paramValue := p_responsibility_id;
      l_param_tbl(2).paramName := 'p_wip_entity_id';
      l_param_tbl(2).paramValue := p_wip_entity_id;
      l_param_tbl(3).paramName := 'p_org_id';
      l_param_tbl(3).paramValue := p_org_id;
      l_param_tbl(4).paramName := 'p_job_op_seq_num';
      l_param_tbl(4).paramValue := p_job_op_seq_num;
      l_param_tbl(5).paramName := 'p_standard_op_id';
      l_param_tbl(5).paramValue := p_standard_op_id;
      l_param_tbl(6).paramName := 'p_intraop_step';
      l_param_tbl(6).paramValue := p_intraop_step;
      l_param_tbl(7).paramName := 'p_status_type';
      l_param_tbl(7).paramValue := p_status_type;

      WSM_Log_PVT.logProcParams(
        p_module_name   => l_module,
        p_param_tbl     => l_param_tbl,
        p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
      );
    END IF;

    if (p_job_op_seq_num IS NULL or p_status_type = 6) then
        return 0;    -- No transaction allowed for future operations
    end if;

    -- check if the standard operation has responsibility exclusion
    l_excluded := 2;
    if(p_responsibility_id > 0 and p_standard_op_id IS NOT NULL) then
        begin
            select 1
            into   l_excluded
            from   bom_std_op_resp_exclusions bsore
            where  standard_operation_id = p_standard_op_id
            and    responsibility_id = p_responsibility_id;
        exception
            when too_many_rows then
                l_excluded := 1;
            when others then
                l_excluded := 2;
        end;
    end if;
    if(l_excluded = 1) then
        return 0;    -- No transaction allowed for excluded operations
    end if;


    -- get org setting on move txns

    select NVL(move_in_option, 0),          -- default: optional
           NVL(move_to_next_op_option, 0)   -- default: optional
    into   l_move_in_option,
           l_move_next_option
    from   wsm_parameters wp
    where  organization_id = p_org_id;

    -- check the mandatory steps on standard operation definition
    -- NOTE: data migrated from wsm_operation_details to bso will be yes/no = 1,2
    -- and new data in bso is default null = no while updating std ops form gives yes/no = 0,1
    -- The net effect is yes = 1 and no = 0 or 2 or null.  Best to code as if 1, else
    --
    -- Change for Bugfix 5347555 only use_org_settings default null = yes
    -- Note: we do not need to check bos vs. bso as changes to bso are updated to bos immediately.
    -- however in the future we may need to add a check as in wsm_txn_allowed if routing-level changes become allowed.
    if(p_standard_op_id IS NOT NULL) then
        begin
            select NVL(use_org_settings, 1),        -- default: use org settings
                   NVL(queue_mandatory_flag, 0),    -- default: no
                   NVL(run_mandatory_flag, 0),      -- default: no
                   NVL(to_move_mandatory_flag, 0)   -- default: no
            into   l_use_org_settings,
                   l_queue_mandatory,
                   l_run_mandatory,
                   l_to_move_mandatory
            from   bom_standard_operations bso
            where  standard_operation_id = p_standard_op_id;
        exception
            when others then
                l_use_org_settings  := 1;  -- use org settings if bso had some problem
                l_queue_mandatory   := 0;  -- won't be used
                l_run_mandatory     := 0;  -- won't be used
                l_to_move_mandatory := 0;  -- won't be used
        end;
    /* Bugfix 5450128 use org settings when std_op is null */
    else
    	l_use_org_settings  := 1;  -- use org settings if non std op
    	l_queue_mandatory   := 0;  -- won't be used
    	l_run_mandatory     := 0;  -- won't be used
    	l_to_move_mandatory := 0;  -- won't be used
    end if;

    -- for move in / move out / move to next op
    if(p_intraop_step = 1) then             -- At queue
        if(l_use_org_settings = 1) then     -- use org setting
            if(l_move_in_option = 1) then
                return 65536;
            elsif(l_move_in_option = 2) then
                return 131072;
            else
                return (65536 + 131072);
            end if;
        else
            if(l_run_mandatory = 1) then
                return 65536;
            else
                return (65536 + 131072);
            end if;
        end if;
    elsif(p_intraop_step = 2) then          -- At Running
        return 131072;
    elsif(p_intraop_step = 3) then          -- At ToMove
        return 262144;
    end if;

exception
    when others then
        return 0;
end move_txn_allowed;


/*
 * Will return 1 if allowed, 0 otherwise
 *
 * p_transaction_type:
 *
 * 2^0  = 1             View Job Operation
 * 2^1  = 2             View Plan Details
 * 2^2  = 4             View Lot Traveler
 * 2^3  = 8             View Blank Lot Traveler
 * 2^4  = 16            Split Job
 * 2^5  = 32            Merge Jobs
 * 2^6  = 64            Update Assembly
 * 2^7  = 128           Update Routing
 * 2^8  = 256           Update Lot Name
 * 2^9  = 512           Update Quantity
 * 2^10 = 1024          Transact Materials
 * 2^11 = 2048          Jump To Operation
 * 2^12 = 4096          Undo Move
 * 2^15 = 32768         Change component during backflush
 * 2^16 = 65536         Move In
 * 2^17 = 131072        Move Out
 * 2^18 = 262144        Move To Next Op
 */
procedure wsm_transaction_allowed(
            p_transaction_type          in number,
            p_responsibility_id         in number,
            p_wip_entity_id             in number,
            p_org_id                    in number,
            p_job_op_seq_num            in number,
            p_standard_op_id            in number,
            p_intraop_step              in number,
            p_status_type               in number,
            x_allowed                   out nocopy number,
            x_error_msg_name            out nocopy varchar2
) is

l_excluded                  number;
l_txn_id                    number;
l_undo_source_code          varchar2(60);
l_charge_jump_from_queue    number;
l_txn_allowed               number;
l_wip_run_enabled_flag      number;
l_wip_to_move_enabled_flag  number;
l_routing_op_seq_num        number;
l_wsm_move_in               number;
l_wsm_move_to_next_op       number;
l_op_use_org_settings       number;
l_op_to_move_mandatory_flag   number;
l_op_run_mandatory_flag     number;
l_max_op_seq_num            number;
l_org_allow_undo            number;    -- variable added for bug 5205280
l_internal_copy_type        number;    -- added for bugfix 5441529
l_max_move_txn_date         date;      -- bugfix 5471833
l_max_wlt_txn_date          date;      -- bugfix 5471833

-- Logging variables.....
l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_MES_UTILITIES_PVT.wsm_transaction_allowed';
l_param_tbl                             WSM_Log_PVT.param_tbl_type;
l_error_count                           NUMBER;
l_return_code                           NUMBER;
l_error_msg                             VARCHAR2(4000);

begin
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
      l_param_tbl.delete;
      l_param_tbl(1).paramName := 'p_transaction_type';
      l_param_tbl(1).paramValue := p_transaction_type;
      l_param_tbl(2).paramName := 'p_responsibility_id';
      l_param_tbl(2).paramValue := p_responsibility_id;
      l_param_tbl(3).paramName := 'p_wip_entity_id';
      l_param_tbl(3).paramValue := p_wip_entity_id;
      l_param_tbl(4).paramName := 'p_org_id';
      l_param_tbl(4).paramValue := p_org_id;
      l_param_tbl(5).paramName := 'p_job_op_seq_num';
      l_param_tbl(5).paramValue := p_job_op_seq_num;
      l_param_tbl(6).paramName := 'p_standard_op_id';
      l_param_tbl(6).paramValue := p_standard_op_id;
      l_param_tbl(7).paramName := 'p_intraop_step';
      l_param_tbl(7).paramValue := p_intraop_step;
      l_param_tbl(8).paramName := 'p_status_type';
      l_param_tbl(8).paramValue := p_status_type;

      WSM_Log_PVT.logProcParams(
        p_module_name   => l_module,
        p_param_tbl     => l_param_tbl,
        p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
      );
    END IF;

    /* Bugfix 5441529 cannot transact on jobs which failed upgrade */
    /* internal_copy_type = 0 if succeeded, 3 if failed */
    begin
    	select nvl(internal_copy_type,0)
    	into l_internal_copy_type
    	from wsm_lot_based_jobs
    	where wip_entity_id = p_wip_entity_id;

    exception
     	when no_data_found then
            l_internal_copy_type := 3;
        when others then
            l_internal_copy_type := 3;
    end;

    if (l_internal_copy_type = 3) then
        x_allowed := 0;
        x_error_msg_name := 'WSM_NO_VALID_COPY';
        return;
    end if;
    /* End Bugfix 5441529 */

    if(p_transaction_type not in (1, 2, 4, 8)) then --skip validation for view job op, plan details, traveler
        -- check future operation
        if (p_job_op_seq_num IS NULL ) then
            x_allowed := 0;    -- No transaction allowed for future operations
            x_error_msg_name := 'WSM_NO_TXN_FUTURE_OPERATION';
            return;
        end if;

	--check for job status other than released or completed
	if (p_status_type NOT IN (3, 4)) then
            x_allowed := 0;    -- No transaction allowed for job status other than released or completed
            x_error_msg_name := 'WSM_MES_TXN_ONLY_REL_COMPL_JOB';
            return;
	end if;

	--check completed op or completed job
        if (((p_intraop_step IS NULL) OR (p_intraop_step IS NOT NULL AND p_intraop_step = -1)) AND
            (p_transaction_type NOT IN (1024, 4096)) ) then
            x_allowed := 0;    -- No transaction allowed for completed jobs or ops except return, txn material
            x_error_msg_name := 'WSM_COMP_RETURN_TXN_MAT_ONLY';
            return;
        end if;

    end if;  --if(p_transaction_type not in (1, 2, 4, 8))

    if(p_transaction_type not in (1, 4, 8)) then --skip validations for view job op, traveler

        -- start bugfix 5225744
        if ((p_transaction_type = 32) AND (p_standard_op_id IS NULL)) then
           x_allowed := 0;  --cannot merge at non-std op
           x_error_msg_name := 'WSM_MES_NO_NONSTD_OP_MERGE';
           return;
        end if;
        -- end bugfix 5225744

        -- check intra-op step running
        if(p_intraop_step = 2) then
            if(p_transaction_type in (16, 32, 64, 128, 256, 512, 2048)) then
                x_allowed := 0;    -- No transaction allowed at run for WLT and Jump
                x_error_msg_name := 'WSM_TXN_NOT_ALLOWED_IN_RUN';
                return;
            end if;
        end if;

        if(p_transaction_type = 4096) then

           -- bug 5205280 begin addition
           -- check to see if undo is allowed in the organization as set in the WSM organization parameters

           select allow_backward_move_flag
           into l_org_allow_undo
           from   wsm_parameters wp
           where  organization_id = p_org_id;

           if ( l_org_allow_undo <> 1) then
               x_allowed := 0;
               x_error_msg_name := 'WSM_UNDO_NOT_ENABLED';
               return;
           end if;

           -- bug 5205280 end of additions

            l_txn_id := NULL;
            select max(transaction_id)
            into   l_txn_id
            from   wip_move_transactions
            where  organization_id = p_org_id
            and    wip_entity_id = p_wip_entity_id
            and    wsm_undo_txn_id IS NULL;

            if(l_txn_id IS NULL) then
                x_allowed := 0;    -- No move to be undone
                x_error_msg_name := 'WSM_NO_MOVE_TXNS';
                return;
            else
                select  source_code
                into    l_undo_source_code
                from    wip_move_transactions
                where   transaction_id = l_txn_id;
            end if;

            if ((l_undo_source_code IS NULL) OR
                (l_undo_source_code NOT IN (
                'move in oa page',
                'move out oa page',
                'jump oa page',
                'move to next op oa page')))
            then
                x_allowed := 0;
                x_error_msg_name := 'WSM_MES_UNDO_FORMSINTERFACE_OA';
                return;
            end if;

            if ((p_intraop_step IS NULL) OR (p_intraop_step IS NOT NULL AND p_intraop_step = -1)) then --completed op
                --job needs to be completed and job op should be max
                select max(operation_seq_num)
                into   l_max_op_seq_num
                from   wip_operations
                where  wip_entity_id = p_wip_entity_id;

                if (l_max_op_seq_num <> p_job_op_seq_num AND p_status_type <> 4) then
                    x_allowed := 0;
		    x_error_msg_name := 'WSM_MES_UNDO_NOT_ALLOWED';
                    return;
                end if;
            end if;

            /* Bugfix 5471833 if last txn performed was WLT then cannot undo */
            l_max_move_txn_date :=null;
            l_max_wlt_txn_date :=null;

            begin
              select max(transaction_date)
              into l_max_move_txn_date
              from wip_move_transactions
              where  organization_id = p_org_id
              and    wip_entity_id = p_wip_entity_id
              and    wsm_undo_txn_id IS NULL;
            exception
              when no_data_found then
                 l_max_move_txn_date :=null;
            end;

            begin
              select max(wsmt.transaction_date)
	      into   l_max_wlt_txn_date
	      FROM   wsm_split_merge_transactions wsmt,
	             wsm_sm_starting_jobs wssj
	      WHERE  wsmt.transaction_id = wssj.transaction_id
	      AND    wssj.wip_entity_id = p_wip_entity_id;
            exception
              when no_data_found then
                 l_max_wlt_txn_date :=null;
            end;

            if (l_max_wlt_txn_date is not null AND
                ((l_max_move_txn_date is null) OR
                 (l_max_move_txn_date is not null and l_max_move_txn_date < l_max_wlt_txn_date))) then
                x_allowed := 0;
                x_error_msg_name := 'WSM_MES_NO_UNDO_AFTER_WLT';
                return;
            end if;
            /* End Bugfix 5471833 */

        end if; --if(p_transaction_type = 4096)

        -- check jump
        if(p_transaction_type = 2048) then

            l_charge_jump_from_queue := 2;
            select charge_jump_from_queue
            into   l_charge_jump_from_queue
            from   wsm_parameters
            where  organization_id = p_org_id;

            if(l_charge_jump_from_queue = 1 and p_intraop_step = 1) then
                x_allowed := 0;
                x_error_msg_name := 'WSM_MES_JUMP_QUEUE_CHG_OP';
                return;
            end if;
        end if;

        -- check operation responsibility exclusion
        l_excluded := 0;
        if(p_responsibility_id > 0 and p_standard_op_id IS NOT NULL and p_transaction_type<>2) then
            begin
                select 1
                into   l_excluded
                from   bom_std_op_resp_exclusions bsore
                where  standard_operation_id = p_standard_op_id
                and    responsibility_id = p_responsibility_id;
            exception
                when too_many_rows then
                    l_excluded := 1;
                when others then
                    l_excluded := 0;
            end;
        end if;
        if(l_excluded = 1) then
            x_allowed := 0;    -- No txn allowed where curr resp is excluded at current std op
            x_error_msg_name := 'WSM_TXN_OPERATION_EXCLUDED';
            return;
        end if;

        -- check responsibility settings
        l_txn_allowed := p_transaction_type;
        if ( (p_responsibility_id > 0) AND (p_transaction_type NOT IN (65536, 131072, 262144)) ) then
            begin
                select bitand(code_mask, p_transaction_type)
                into   l_txn_allowed
                from   wsm_responsibility_settings wrs
                where  responsibility_id = p_responsibility_id;
            exception
                when others then
                    null;
            end;
        end if;
        if(l_txn_allowed = 0) then
            x_allowed := 0;    -- No transaction based on responsibility settings
            x_error_msg_name := 'WSM_TXN_NOT_ALLOWED_RESP';
            return;
        end if;

        --Validations for Move In, Move Out, Move To Next Op
        if (p_transaction_type IN (65536, 131072, 262144)) then

            begin
                SELECT current_rtg_op_seq_num
                INTO l_routing_op_seq_num
                FROM wsm_lot_based_jobs
                WHERE wip_entity_id = p_wip_entity_id;
            exception
                when no_data_found then
                    l_routing_op_seq_num := null;
            end;

            --Bug 4914167:SQL id 15041164:WIP_PARAMETERS_V is replaced
            --with wvis to fix share memory violations.
            --SELECT  run_enabled_flag, to_move_enabled_flag
            SELECT   DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,2,1,0)),0,2,1),
                     DECODE(SUM(DECODE(WVIS.STEP_LOOKUP_TYPE,3,
                     DECODE(WVIS.RECORD_CREATOR,'USER',1,0),0)),0,2,1)
            INTO    l_wip_run_enabled_flag, l_wip_to_move_enabled_flag
            --FROM    WIP_PARAMETERS_V
            FROM    WIP_VALID_INTRAOPERATION_STEPS WVIS
            WHERE   organization_id = p_org_id;

            -- Optional = 0, Always = 1, Never = 2
            SELECT  nvl(move_in_option, 0), nvl(move_to_next_op_option, 0) --bugfix 5336838 changed from default 2 to 0
            INTO    l_wsm_move_in, l_wsm_move_to_next_op
            FROM    WSM_PARAMETERS
            WHERE   organization_id = p_org_id;

            -- NOTE: data migrated from wsm_operation_details to bso will be yes/no = 1,2
	    -- and new data in bso is default null = no while updating std ops form gives yes/no = 0,1
	    -- The net effect is yes = 1 and no = 0 or 2 or null.  Best to code as if 1, else
	    --
	    -- Change for Bugfix 5347555 use_org_settings default null = yes
	    -- Note: we do not really need a check on bos vs. bso because bso changes are updated to bos immediately.
	    -- however leaving this as-is as we may support routing-level changes in the future; move_txn_allowed would need to be changed.
            begin
              IF (l_routing_op_seq_num IS NOT NULL) THEN
                SELECT  nvl(BOS.use_org_settings, 1), nvl(BOS.run_mandatory_flag, 0), nvl(BOS.to_move_mandatory_flag, 0)
                INTO    l_op_use_org_settings, l_op_run_mandatory_flag, l_op_to_move_mandatory_flag
                FROM    BOM_OPERATION_SEQUENCES BOS, WIP_OPERATIONS WO
                WHERE   WO.wip_entity_id            = p_wip_entity_id
                AND     WO.operation_seq_num        = p_job_op_seq_num
                AND     BOS.operation_sequence_id   = WO.operation_sequence_id;
              ELSE
                SELECT  nvl(BSO.use_org_settings, 1), nvl(BSO.run_mandatory_flag, 0), nvl(BSO.to_move_mandatory_flag, 0)
                INTO    l_op_use_org_settings, l_op_run_mandatory_flag, l_op_to_move_mandatory_flag
                FROM    BOM_STANDARD_OPERATIONS BSO, WIP_OPERATIONS WO
                WHERE   WO.wip_entity_id            = p_wip_entity_id
                AND     WO.operation_seq_num        = p_job_op_seq_num
                AND     BSO.standard_operation_id   = WO.standard_operation_id
                AND     BSO.organization_id         = WO.organization_id;
              END IF;--IF (l_routing_op_seq_num IS NOT NULL)
            exception
              when others then
                l_op_use_org_settings := 1;  --use org settings if op_seq or std_op is not found
                l_op_run_mandatory_flag := 0;  --this won't be used if use_org_settings = 1
                l_op_to_move_mandatory_flag := 0;  --this won't be used if use_org_settings = 1
            end;

            --move to next op: check when no valid next routing op can be found
            IF (p_transaction_type = 262144 AND l_routing_op_seq_num IS NULL) THEN --jumped
                l_excluded := 1;
            ELSIF (p_transaction_type = 262144 AND l_routing_op_seq_num IS NOT NULL) THEN --check routing refreshed and rtg op now lost
                begin
                    SELECT 0
                    INTO l_excluded
                    FROM wsm_copy_op_networks
                    WHERE wip_entity_id = p_wip_entity_id
                    AND (from_op_seq_num = l_routing_op_seq_num
                    OR to_op_seq_num = l_routing_op_seq_num);
                exception
                    when no_data_found then
                        l_excluded := 1;
                    when too_many_rows then
                        l_excluded := 0;
                    when others then
                        l_excluded := 0;
                end;
            ELSE
                l_excluded := 0;
            END IF;

            if(l_excluded = 1) then
                x_allowed := 0;    -- Txn not allowed if jumped or if routing refreshed and rtg op now lost
                x_error_msg_name := 'WSM_MES_NEXT_RTG_OP_NOT_FOUND';
                return;
            end if;

            --check if wip_parameters settings conflict with wsm_parameter settings
            IF (l_wip_run_enabled_flag = 2 AND p_transaction_type = 65536) THEN --bugfix 5336838 limit error to Move In txn
               IF l_op_use_org_settings = 1 THEN
                   IF (l_wsm_move_in = 1 OR l_wsm_move_in = 0)THEN  --bugfix 5336838 both Always and Optional will error out
                        x_allowed := 0;
                        x_error_msg_name := 'WSM_MES_WIP_RUN_DIS_WSM_MV_IN';
                        return;
                   END IF;
               ELSE
                   /* IF l_op_run_mandatory_flag = 1 THEN */ --bugfix 5336838 both Mandatory and Optional will error out
                        x_allowed := 0;
                        x_error_msg_name := 'WSM_MES_WIP_RUN_DIS_BOS_MV_IN';
                        return;
                   /* END IF; */
               END IF;
            END IF;--IF l_wip_run_enabled_flag = 2

            IF (l_wip_to_move_enabled_flag = 2 AND p_transaction_type = 131072) THEN --bugfix 5336838 limit error to Move Out txn
                IF l_op_use_org_settings = 1 THEN
                    IF l_wsm_move_to_next_op = 1 THEN
                        x_allowed := 0;
                        x_error_msg_name := 'WSM_MES_WIP_WSM_MOVE';
                        return;
                    END IF;
                ELSE
                    IF l_op_to_move_mandatory_flag = 1 THEN
                        x_allowed := 0;
                        x_error_msg_name := 'WSM_MES_WIP_BOS_MOVE';
                        return;
                    END IF;
                END IF;
            END IF;--IF l_wip_to_move_enabled_flag = 2
        end if; --if (p_transaction_type IN (65536, 131072, 262144))
    end if; --if(p_transaction_type not in (1, 4, 8))

    x_allowed        := 1;
    x_error_msg_name := null;

end wsm_transaction_allowed;

/*
 * Will return 1 if job status changed, 0 otherwise
 */
function wsm_job_changed(
            p_wip_entity_id             in number,
            p_job_op_seq_num            in number,
            p_intraop_step              in number,
            p_status_type               in number,
            p_quantity                  in number,
            p_job_name                  in varchar2
) return number is

l_job_op_seq_num            number;
l_intraop_step              number;
l_status_type               number;
l_quantity                  number;
l_job_name                  varchar2(100);

-- Logging variables.....
l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_MES_UTILITIES_PVT.wsm_job_changed';
l_param_tbl                             WSM_Log_PVT.param_tbl_type;
l_error_count                           NUMBER;
l_return_code                           NUMBER;
l_error_msg                             VARCHAR2(4000);

begin
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
          l_param_tbl.delete;
          l_param_tbl(1).paramName := 'p_wip_entity_id';
          l_param_tbl(1).paramValue := p_wip_entity_id;
          l_param_tbl(2).paramName := 'p_job_op_seq_num';
          l_param_tbl(2).paramValue := p_job_op_seq_num;
          l_param_tbl(3).paramName := 'p_intraop_step';
          l_param_tbl(3).paramValue := p_intraop_step;
          l_param_tbl(4).paramName := 'p_status_type';
          l_param_tbl(4).paramValue := p_status_type;
          l_param_tbl(5).paramName := 'p_quantity';
          l_param_tbl(5).paramValue := p_quantity;
          l_param_tbl(6).paramName := 'p_job_name';
          l_param_tbl(6).paramValue := p_job_name;

          WSM_Log_PVT.logProcParams(
            p_module_name   => l_module,
            p_param_tbl     => l_param_tbl,
            p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
          );
    END IF;

    if ((p_job_op_seq_num IS NULL ) OR
        ((p_intraop_step IS NULL) OR (p_intraop_step IS NOT NULL AND p_intraop_step = -1))) then
        return 0;  --skip job state check for future and completed job ops
    end if;

    select  we.wip_entity_name               job_name,
            wo.operation_seq_num             job_op_seq_num,
            wo.quantity_in_queue
          + wo.quantity_running
          + wo.quantity_waiting_to_move      assembly_quantity,
            wdj.status_type                  status_type,
            case when wo.quantity_in_queue>0 then 1
                 when wo.quantity_running>0 then 2
                 when wo.quantity_waiting_to_move>0 then 3
                 else null end               intraop_step_code
    into    l_job_name,
            l_job_op_seq_num,
            l_quantity,
            l_status_type,
            l_intraop_step
    from    wip_discrete_jobs                WDJ,
            wip_entities                     WE,
            wip_operations                   WO
    where   WE.entity_type            in (5, 8)
    and     WDJ.wip_entity_id         = we.wip_entity_id
    and     WDJ.organization_id       = we.organization_id
    and     WDJ.status_type           in (3, 6)
    and     WO.wip_entity_id          = WDJ.wip_entity_id
    and     WO.organization_id        = WDJ.organization_id
    and     wo.quantity_in_queue
          + wo.quantity_running
          + wo.quantity_waiting_to_move > 0
    and     WDJ.WIP_ENTITY_ID         = p_wip_entity_id;

    if(l_job_name = p_job_name and
       l_job_op_seq_num = p_job_op_seq_num and
       l_quantity = p_quantity and
       l_status_type = p_status_type and
       l_intraop_step = p_intraop_step) then
        return 0;
    else
        return 1;
    end if;

exception
    when no_data_found then -- completed job, no current op
        if(p_status_type = 6) then
            return 0;
        else
            return 1;
        end if;
    when others then
        return 1;
end wsm_job_changed;



/*
 * find corrent job operations for that is with a give resource / instance
 */
function get_current_job_op (
        p_organization_id               in number,
        p_department_id                 in number,
        p_resource_id                   in number,
        p_instance_id                   in number,
        p_serial_number                 in varchar2) return varchar2
is
l_job_name          wip_entities.wip_entity_name%type;
l_wip_entity_id     number;
l_op_seq_num        number;
l_rtg_op_seq_num    number;
l_status_type       number;

begin

    if(p_instance_id IS NULL) then
        select
                we.wip_entity_name,
                wdj.wip_entity_id,
                wo.operation_seq_num,
                wdj.status_type,
                wlbj.current_rtg_op_seq_num
        into    l_job_name,
                l_wip_entity_id,
                l_op_seq_num,
                l_status_type,
                l_rtg_op_seq_num
        from    wip_discrete_jobs                WDJ,
                wip_entities                     WE,
                wip_operations                   WO,
                wip_operation_resources          WOR,
                wsm_lot_based_jobs               WLBJ
        where   WE.entity_type            in (5, 8)
        and     WDJ.wip_entity_id         = we.wip_entity_id
        and     WDJ.organization_id       = we.organization_id
        and     WDJ.status_type           in (3, 6)
        and     WO.wip_entity_id          = WDJ.wip_entity_id
        and     WO.organization_id        = WDJ.organization_id
        and     WO.operation_seq_num      = WOR.operation_seq_num
        and     WO.wip_entity_id          = WOR.wip_entity_id
        and     WO.organization_id        = WOR.organization_id
        and     WO.quantity_in_queue
              + WO.quantity_running
              + WO.quantity_waiting_to_move <> 0
        and    not exists (
                 select BDRI.instance_id
                 from   BOM_DEPT_RES_INSTANCES    BDRI
                 where  BDRI.department_id = WO.department_id
                 and    BDRI.resource_id   = WOR.resource_id
                 and    rownum = 1
               )
        and    WDJ.organization_id = p_organization_id
        and    WO.department_id = p_department_id
        and    WOR.resource_id = p_resource_id
        and    WE.wip_entity_id = WLBJ.wip_entity_id
        and    WE.organization_id = WLBJ.organization_id;

    else

        select
                we.wip_entity_name,
                wdj.wip_entity_id,
                wo.operation_seq_num,
                wdj.status_type,
                wlbj.current_rtg_op_seq_num
        into    l_job_name,
                l_wip_entity_id,
                l_op_seq_num,
                l_status_type,
                l_rtg_op_seq_num
        from    wip_discrete_jobs                WDJ,
                wip_entities                     WE,
                wip_operations                   WO,
                wip_operation_resources          WOR,
                wip_op_resource_instances        WORI,
                wsm_lot_based_jobs               WLBJ
        where   WE.entity_type            in (5, 8)
        and     WDJ.wip_entity_id         = we.wip_entity_id
        and     WDJ.organization_id       = we.organization_id
        and     WDJ.status_type           in (3, 6)
        and     WO.wip_entity_id          = WDJ.wip_entity_id
        and     WO.organization_id        = WDJ.organization_id
        and     WO.operation_seq_num      = WOR.operation_seq_num
        and     WO.wip_entity_id          = WOR.wip_entity_id
        and     WO.organization_id        = WOR.organization_id
        and     WOR.wip_entity_id         = WORI.wip_entity_id
        and     WOR.operation_seq_num     = WORI.operation_seq_num
        and     WOR.resource_seq_num      = WORI.resource_seq_num
        and     WO.quantity_in_queue
              + WO.quantity_running
              + WO.quantity_waiting_to_move <> 0
        and    WDJ.organization_id = p_organization_id
        and    WO.department_id = p_department_id
        and    WOR.resource_id = p_resource_id
        and    WORI.instance_id = p_instance_id
        and    WORI.serial_number = p_serial_number
        and    WE.wip_entity_id = WLBJ.wip_entity_id
        and    WE.organization_id = WLBJ.organization_id;

    end if;

    return l_job_name || '|!@$%^&*|' || l_wip_entity_id || '|!@$%^&*|' || l_op_seq_num || '|!@$%^&*|' || l_rtg_op_seq_num || '|!@$%^&*|' || l_status_type;

exception
    when too_many_rows then
        return 'MultipleJobs';
    when others then
        return null;
end get_current_job_op;


/*
 * Bugfix 5356648 OSP warnings.  Check for po reqs and orders.
 *
 * Will return 1 if po reqs/orders exist, 0 otherwise
 *
 * p_transaction_type:
 *
 * 2^4  = 16            Split Job
 * 2^5  = 32            Merge Jobs
 * 2^6  = 64            Update Assembly
 * 2^7  = 128           Update Routing
 * 2^11 = 2048          Jump To Operation
 * 2^12 = 4096          Undo Move
 */
function check_po_req_exists(
	p_txn_type			in number,
	p_wip_entity_id			in number
) return number is

l_charge_jump_from_queue    number;

l_job_op_seq_num            number;
l_org_id                    number;

-- Logging variables.....
l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_MES_UTILITIES_PVT.check_po_req_exists';
l_param_tbl                             WSM_Log_PVT.param_tbl_type;

begin
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
          l_param_tbl.delete;
          l_param_tbl(1).paramName := 'p_wip_entity_id';
          l_param_tbl(1).paramValue := p_wip_entity_id;
          l_param_tbl(2).paramName := 'p_txn_type';
          l_param_tbl(2).paramValue := p_txn_type;

          WSM_Log_PVT.logProcParams(
            p_module_name   => l_module,
            p_param_tbl     => l_param_tbl,
            p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
          );
    END IF;

    select organization_id,
           current_job_op_seq_num
    into l_org_id,
         l_job_op_seq_num
    from wsm_lot_based_jobs
    where wip_entity_id = p_wip_entity_id;

    IF (p_txn_type IN (16,32,64,128,2048,4096)) THEN

    	IF wip_osp.po_req_exists(p_wip_entity_id, NULL, l_org_id, l_job_op_seq_num, 5) THEN

	    if (p_txn_type = 2048) then /* Jump */

	        SELECT nvl(charge_jump_from_queue,2)
                INTO   l_charge_jump_from_queue
                FROM   wsm_parameters
                WHERE  organization_id = l_org_id;

	        if (l_charge_jump_from_queue = 2) then
	             return 1; /* Charge Jump From Queue = No and po reqs or headers exist */
	        else
	             return 0; /* Charge Jump From Queue = Yes even if po reqs or headers exist */
	        end if;

	    else /* Split, Merge, Upd Rtg, Upd Assy, Undo */
	        return 1;

	    end if;

	ELSE /* no po reqs or headers exist */
	    return 0;

        END IF;

    ELSE /* called for any other txn */
    	return 0;
    END IF;

exception
    when others then
        return 0;
end check_po_req_exists;

--Bug 5409116:Function get_share_from_dept is added.
function get_share_from_dept(
        p_department_id                 in number,
        p_resource_id                   in number) return number IS

      l_share_from_dept  NUMBER;
-- Logging variables.....
      l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
      l_log_level        number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_module           CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_MES_UTILITIES_PVT.get_share_from_dept';
      l_param_tbl        WSM_Log_PVT.param_tbl_type;
      l_error_count      NUMBER;
      l_return_code      NUMBER;
      l_error_msg        VARCHAR2(4000);

begin
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
      l_param_tbl.delete;
      l_param_tbl(1).paramName := 'p_department_id';
      l_param_tbl(1).paramValue := p_department_id;
      l_param_tbl(1).paramName := 'p_resource_id';
      l_param_tbl(1).paramValue := p_resource_id;

       WSM_Log_PVT.logProcParams(
        p_module_name   => l_module,
        p_param_tbl     => l_param_tbl,
        p_fnd_log_level => G_LOG_LEVEL_PROCEDURE
      );
    END IF;

    begin
       select SHARE_FROM_DEPT_ID
       into   l_share_from_dept
       from   BOM_DEPARTMENT_RESOURCES
       where  department_id = p_department_id
       and    resource_id   = p_resource_id
       and    SHARE_FROM_DEPT_ID IS NOT NULL;
    exception
       when others then
          l_share_from_dept := p_department_id;
    end;

    return(l_share_from_dept);
end get_share_from_dept;

END;

/
