--------------------------------------------------------
--  DDL for Package Body EAM_OPERATIONS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OPERATIONS_JSP" AS
/* $Header: EAMOPSJB.pls 120.9.12010000.2 2011/06/29 10:44:13 vpasupur ship $
   $Author: vpasupur $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'eam_operations_jsp';
g_debug_sqlerrm VARCHAR2(250);
g_shutdown_type VARCHAR2(30) := EAM_CONSTANTS.G_SHUTDOWN_TYPE;
g_supply_type VARCHAR2(30) := EAM_CONSTANTS.G_SUPPLY_TYPE;


-------------------------------------------------------------------------
-- Procedure to check whether the handover operation is being
-- conducted properly or not
-- Bug fix # 2113203 - baroy
-- Bug 3133704 - removed l_completed_yn and merged the 2 sql's
-------------------------------------------------------------------------
  procedure handover_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                  OUT NOCOPY NUMBER
  ) IS

    l_op_complete_count NUMBER;

    BEGIN
      x_return_stat := 1;
  -- Bug  3133704
   SELECT count(operation_completed) into l_op_complete_count
   FROM wip_operation_networks won, wip_operations wo
   WHERE won.wip_entity_id = p_wip_entity_id
   AND won.next_operation =  p_operation_sequence_number
   AND won.organization_id =  p_organization_id
   AND wo.wip_entity_id =  p_wip_entity_id
   AND wo.operation_seq_num = won.prior_operation
   AND wo.organization_id = p_organization_id
   AND nvl(wo.operation_completed,'N')='N' ;

   IF l_op_complete_count > 0 THEN
      x_return_stat := 0;
   END IF;


  END handover_validate;

-- removed procedure charge_resource_validate

-------------------------------------------------------------------------
-- Procedure to check whether the assign employee operation is being
-- conducted on a completed or uncompleted operation
-- Bug fix # 2113203 - baroy
-------------------------------------------------------------------------
  procedure assign_employee_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                 OUT NOCOPY NUMBER
  ) IS

    l_complete_yn    VARCHAR2(1);

    BEGIN
    select operation_completed
      into l_complete_yn
      from wip_operations where
      wip_entity_id = p_wip_entity_id and
      operation_seq_num = p_operation_sequence_number and
      organization_id = p_organization_id;

    IF nvl(upper(l_complete_yn),'N') = 'Y' THEN
      x_return_stat := 0;  -- operation should not be allowed to charge resource/employee
                         -- as it is already completed
    ELSE
      x_return_stat := 1;  -- operation can be allowed to charge resource/employee
    END IF;
  END assign_employee_validate;


-------------------------------------------------------------------------
-- Procedure to check whether the operation uncompletion/completion
-- is being conducted properly or not
-- Bug fix # 2113203 - baroy
-------------------------------------------------------------------------
  procedure complete_uncomplete_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                  OUT NOCOPY NUMBER
  ) IS

    l_completed_yn VARCHAR2(1);
    l_cur_completed_yn VARCHAR2(1);


    BEGIN
      x_return_stat := 1;

      select operation_completed
        into l_cur_completed_yn
        from wip_operations where
        wip_entity_id = p_wip_entity_id and
        operation_seq_num = p_operation_sequence_number and
        organization_id = p_organization_id;

      IF( nvl(upper(l_cur_completed_yn),'N') = 'Y') THEN
        -- operation being contemplated by user is a uncomplete op. Hence check whether
        -- all next ops are uncomplet or not
        FOR cur_operation_record IN (select next_operation from wip_operation_networks where
                                       wip_entity_id = p_wip_entity_id and
                                       prior_operation = p_operation_sequence_number and
                                       organization_id = p_organization_id) LOOP

          SELECT operation_completed INTO
            l_completed_yn from wip_operations where
            wip_entity_id = p_wip_entity_id and
            operation_seq_num = cur_operation_record.next_operation and
            organization_id = p_organization_id;

          IF nvl(upper(l_completed_yn),'N') = 'Y' THEN
            x_return_stat := 2; -- some next ops are complete
                                -- error msg : uncomplete them first.
          END IF;
        END LOOP;
      ELSIF( nvl(upper(l_cur_completed_yn),'N') = 'N') THEN
        -- operation being contemplated by user is a complete op. Hence check whether
        -- all previous ops have been completed or not
        FOR cur_operation_record IN (select prior_operation from wip_operation_networks where
                                       wip_entity_id = p_wip_entity_id and
                                       next_operation = p_operation_sequence_number and
                                       organization_id = p_organization_id) LOOP

          SELECT operation_completed INTO
            l_completed_yn from wip_operations where
            wip_entity_id = p_wip_entity_id and
            operation_seq_num = cur_operation_record.prior_operation and
            organization_id = p_organization_id;

          IF nvl(upper(l_completed_yn),'N') = 'N' THEN
            x_return_stat := 3; -- some previous ops are still uncomplete
                                -- error msg : complete them first.
          END IF;
        END LOOP;

      ELSE
        -- Proceed to operation completion/uncompletion page
        x_return_stat := 1;
      END IF;

  END complete_uncomplete_validate;


--------------------------------------------------------------------------
-- A wrapper to the operation completion logic, cache the return status
-- and convert it the the message that can be accepted by JSP pages
--------------------------------------------------------------------------
  procedure complete_operation
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_operation_seq_num           IN    NUMBER
    ,p_actual_start_date           IN    DATE
    ,p_actual_end_date             IN    DATE
    ,p_actual_duration             IN    NUMBER
    ,p_transaction_date            IN    DATE
    ,p_transaction_type            IN    NUMBER
    ,p_shutdown_start_date         IN    DATE
    ,p_shutdown_end_date           IN    DATE
    ,p_reconciliation_code         IN    VARCHAR2
    ,p_stored_last_update_date     IN    DATE  -- old update date, for locking only
    ,p_qa_collection_id            IN    NUMBER
    ,p_vendor_id                   IN   NUMBER      := NULL
    ,p_vendor_site_id              IN   NUMBER      := NULL
    ,p_vendor_contact_id           IN   NUMBER      := NULL
    ,p_reason_id                   IN   NUMBER      := NULL
    ,p_reference                   IN   VARCHAR2    := NULL
    ,p_attribute_category	   IN	VARCHAR2    := NULL
    ,p_attribute1		   IN	VARCHAR2    := NULL
    ,p_attribute2                  IN   VARCHAR2    := NULL
    ,p_attribute3                  IN   VARCHAR2    := NULL
    ,p_attribute4                  IN   VARCHAR2    := NULL
    ,p_attribute5                  IN   VARCHAR2    := NULL
    ,p_attribute6                  IN   VARCHAR2    := NULL
    ,p_attribute7                  IN   VARCHAR2    := NULL
    ,p_attribute8                  IN   VARCHAR2    := NULL
    ,p_attribute9                  IN   VARCHAR2    := NULL
    ,p_attribute10                 IN   VARCHAR2    := NULL
    ,p_attribute11                 IN   VARCHAR2    := NULL
    ,p_attribute12                 IN   VARCHAR2    := NULL
    ,p_attribute13                 IN   VARCHAR2    := NULL
    ,p_attribute14                 IN   VARCHAR2    := NULL
    ,p_attribute15                 IN   VARCHAR2    := NULL
  ) IS

  l_api_name           CONSTANT VARCHAR(30) := 'complete_operation';
  l_api_version        CONSTANT NUMBER      := 1.0;
  l_return_status            VARCHAR2(250);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_err_code                 NUMBER;
  l_err_msg                  VARCHAR2(250);
  l_err_stage                VARCHAR2(250);
  l_err_stack                VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_new_status   VARCHAR2(30);
  l_db_status    VARCHAR2(30);
  l_db_last_update_date DATE;
  l_transaction  NUMBER;
  l_actual_end_date  DATE;
  l_reconciliation_code VARCHAR2(30);
  l_shutdown_type VARCHAR2(30);
  l_open_acct_per_date DATE;

	l_act_st_date DATE;
	l_act_end_date DATE;
	l_act_duration NUMBER;



  BEGIN
       SAVEPOINT complete_workorder;

	l_act_st_date  :=p_actual_start_date;
	l_act_end_date :=p_actual_end_date;
	l_act_duration :=p_actual_duration;



    eam_debug.init_err_stack('eam_operations_jsp.complete_operation');

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if data is stale or not
    -- using last_update_date as indicator
    BEGIN
      SELECT last_update_date, operation_completed, shutdown_type
      INTO   l_db_last_update_date, l_db_status, l_shutdown_type
      FROM wip_operations
      WHERE wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation_seq_num
      FOR UPDATE;

       IF p_transaction_type = 2 THEN
           select actual_start_date ,actual_end_date ,actual_duration
           into l_act_st_date ,l_act_end_date,l_act_duration
           from eam_op_completion_txns
           where
            wip_entity_id      = p_wip_entity_id      and
            operation_seq_num  = p_operation_seq_num   and
            transaction_type = 1 and
            last_update_date = (select max(last_update_date)
                                 from eam_op_completion_txns
                                where wip_entity_id  = p_wip_entity_id and
                                      operation_seq_num  = p_operation_seq_num and
                                      transaction_type = 1);

       END IF;


      IF  l_db_last_update_date <> p_stored_last_update_date THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_STALED_DATA');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF ( (p_transaction_type = 1 AND l_db_status = 'Y') or
           (p_transaction_type = 2 and nvl(l_db_status,'N') = 'N' )) THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_STALED_DATA');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF ( not( p_shutdown_start_date is null and p_shutdown_end_date is null) and
           ( p_shutdown_start_date is null or p_shutdown_end_date is null) ) THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUTDOWN_DATE_MISS');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
--changed the following if condition as part of bug 5476770
	  IF ( p_shutdown_start_date is not null and p_shutdown_end_date is not null and
			p_shutdown_end_date > sysdate ) THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUTDOWN_DATE_IN_FUTURE');
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_shutdown_start_date is not null and p_shutdown_end_date is not null and
           p_shutdown_start_date > p_shutdown_end_date ) THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUTDOWN_DATE_BAD');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
--end of change for bug 5476770
      IF (l_act_duration  < 0) THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_COMP_DURATION_BAD');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN	-- Bug 3133704 .changed WHEN OTHERS to WHEN NO_DATA_FOUND
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_OP_NOT_FOUND');
      x_return_status := FND_API.G_RET_STS_ERROR;
    END;


     /* Fix for Bug 2100416 */

        select nvl(min(period_start_date), sysdate+1)
        into l_open_acct_per_date
        from org_acct_periods
        where organization_id = (select organization_id from wip_discrete_jobs where wip_entity_id = p_wip_entity_id)
        and open_flag = 'Y';

        if (l_act_st_date  is not null) and (l_act_duration  is not null) then
           if (l_act_end_date  > sysdate) then
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_END_LATER_THAN_TODAY');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           end if;
           /* The following line is commented out for bug no:2728447 */
--           if (p_actual_start_date < l_open_acct_per_date) then
   /*Fix for bug 3235163*/
   --Previously end date was checked with closed period.Changed that to check transaction_date
           if (p_transaction_date < l_open_acct_per_date) then
             eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_TRANSACTION_DATE_INVALID');
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           end if;
  /*End of fix for bug 3235163*/
        end if;

    /* End of Fix 2100416 */

    BEGIN
      l_reconciliation_code := null;
      if( p_reconciliation_code is not null) then
        select ml.lookup_code
        into l_reconciliation_code
        from mfg_lookups ml			-- Fix for Bug 3509465
        where ml.lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
          and ml.meaning = p_reconciliation_code;
      end if;
    EXCEPTION WHEN NO_DATA_FOUND THEN  -- Bug 3133704,changed OTHERS to NO_DATA_FOUND
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RECONCILIATION_CODE_INV');
      x_return_status := FND_API.G_RET_STS_ERROR; --Bug .
    END;

    -- if validate not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => l_msg_data,    -- removed g_miss_char
          p_data      => l_data,
          p_msg_index_out => l_msg_index_out);
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
    ELSE
       x_msg_count  := l_msg_count;
    END IF;

    IF l_msg_count > 0 THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -------------------------------------------
    -- how to compute date by interval, how many hours a day???
    l_actual_end_date := l_act_st_date + (l_act_duration/24);

   begin
   eam_op_comp.op_comp(
--     p_api_version         => p_api_version,
--     p_init_msg_list       => p_init_msg_list,
--     p_commit              => p_commit,
--     p_validation_level    => p_validation_level,
--     p_validation_only     => p_validate_only,
--     p_record_version_number => p_record_version_number,
--     x_return_status       => x_return_status,
--     x_msg_count           => x_msg_count,
--     x_msg_data            => x_msg_data,
     x_err_code            => l_err_code,
     x_err_msg             => l_err_msg,
     p_wip_entity_id       => p_wip_entity_id,
     p_operation_seq_num   => p_operation_seq_num,
     p_transaction_type    => p_transaction_type,
     p_transaction_date    => p_transaction_date,
     p_actual_start_date   => l_act_st_date,
     p_actual_end_date     => l_actual_end_date,
     p_actual_duration     =>  l_act_duration,
     p_shutdown_start_date => p_shutdown_start_date,
     p_shutdown_end_date   => p_shutdown_end_date,
     p_reconciliation_code => l_reconciliation_code,
     p_qa_collection_id    => p_qa_collection_id,
	 p_vendor_id           => p_vendor_id,
     p_vendor_site_id      => p_vendor_site_id,
	 p_vendor_contact_id   => p_vendor_contact_id,
	 p_reason_id           => p_reason_id,
	 p_reference           => p_reference,
	 p_attribute_category  => p_attribute_category,
	 p_attribute1		   => p_attribute1,
	 p_attribute2		   => p_attribute2,
	 p_attribute3		   => p_attribute3,
	 p_attribute4		   => p_attribute4,
	 p_attribute5		   => p_attribute5,
	 p_attribute6		   => p_attribute6,
	 p_attribute7		   => p_attribute7,
	 p_attribute8		   => p_attribute8,
	 p_attribute9		   => p_attribute9,
	 p_attribute10		   => p_attribute10,
	 p_attribute11		   => p_attribute11,
	 p_attribute12		   => p_attribute12,
	 p_attribute13		   => p_attribute13,
	 p_attribute14		   => p_attribute14,
	 p_attribute15		   => p_attribute15
   );
   exception when others then
     fnd_msg_pub.add;
   end;

   if( l_err_code >0) then
--      add_message(p_app_short_name => 'EAM', p_msg_name => l_err_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   end if;

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => l_msg_data,       -- removed g_miss_char
          p_data      => l_data,
          p_msg_index_out => l_msg_index_out);
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
    ELSE
       x_msg_count  := l_msg_count;
    END IF;

    IF l_msg_count > 0 THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
      COMMIT WORK;
    END IF;

  EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       ROLLBACK TO complete_workorder;


    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.complete_operation',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO complete_workorder;


    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.complete_operation',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
       ROLLBACK TO complete_workorder;


    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.complete_operation',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END complete_operation;

------------------------------------------------------------------------------------
-- performing operation handover for jsp pages
-- use the column last_update_date for optimistic locking
------------------------------------------------------------------------------------
   procedure operation_handover
    (  p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_record_version_number       IN    NUMBER        := NULL
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_wip_entity_id               IN    NUMBER        -- data
      ,p_old_op_seq_num              IN    NUMBER
      ,p_new_op_seq_num              IN    NUMBER
      ,p_description                 IN    VARCHAR2
      ,p_assigned_department         IN    VARCHAR2
      ,p_start_date                  IN    DATE
      ,p_completion_date             IN    DATE
      ,p_shutdown_type               IN    NUMBER
      ,p_stored_last_update_date     IN    DATE -- old update date, for locking only
      ,p_duration                    IN    NUMBER
      ,p_reconciliation_value        IN    VARCHAR2
     ) IS

    l_api_name           CONSTANT VARCHAR(30) := 'operation_handover';
    l_api_version        CONSTANT NUMBER      := 1.0;
    l_return_status            VARCHAR2(250);
    l_error_msg_code           VARCHAR2(250);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(250);
    l_err_code                 VARCHAR2(250);
    l_err_stage                VARCHAR2(250);
    l_err_stack                VARCHAR2(250);
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;

    l_db_last_update_date DATE;
    l_actual_start_date  DATE;
    l_actual_end_date  DATE;
    l_completed  VARCHAR2(30);
    l_count      NUMBER;
    l_department_id NUMBER;
    x_row_id VARCHAR2(250);
    l_org_id NUMBER;
    l_old_dept_id NUMBER;
    l_transaction_id number;
    l_old_op_duration number;
    l_new_op_completion_date date;
    TYPE OpCurType IS REF CURSOR RETURN wip_operations%ROWTYPE;
    opCur OpCurType;
    opRow wip_operations%ROWTYPE;

    /* added for calling WO API */

        l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
        l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	 l_output_dir  VARCHAR2(512);

    BEGIN
         SAVEPOINT operation_handover;


      eam_debug.init_err_stack('eam_operations_jsp.operation_handover');

     IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.TO_BOOLEAN(p_init_msg_list)
      THEN
         FND_MSG_PUB.initialize;
      END IF;

  EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -----------------------------------------------------------------
      -- validation
      -- check if data is stale or not
      -- using last_update_date as indicator
     BEGIN
        SELECT
             last_update_date
            ,operation_completed
            ,first_unit_start_date
            ,last_unit_completion_date
            ,organization_id  --
            ,department_id
        INTO
             l_db_last_update_date
            ,l_completed
            ,l_actual_start_date
            ,l_actual_end_date
            ,l_org_id
            ,l_old_dept_id
        FROM wip_operations
        WHERE
            wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_old_op_seq_num
        FOR UPDATE;


        -- checking stuff
        IF  l_db_last_update_date <> nvl(p_stored_last_update_date, l_db_last_update_date) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_OP_STALED_DATA');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        IF ( nvl(l_completed, 'N') = 'Y' ) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_CANT_STATUS_Y');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_start_date > p_completion_date) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DATE_BAD');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        select count(*)
        into l_count from wip_operations
        where wip_entity_id = p_wip_entity_id and operation_seq_num = p_new_op_seq_num;
        IF( l_count > 0 ) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_OP_EXISTED');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

--  Bug 3133704 . removed count for department_code within an org. For a given org id , dept code is unique.
          select department_id
          into l_department_id
          from bom_departments
          where organization_id = l_org_id
            and department_code like p_assigned_department;
          if(l_department_id = l_old_dept_id) then
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DEPT_SAME');
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;


      EXCEPTION WHEN NO_DATA_FOUND THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_OP_NOT_FOUND');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;

      -- if validate not passed then raise error
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
         eam_execution_jsp.Get_Messages
           (p_encoded  => FND_API.G_FALSE,
            p_msg_index => 1,
            p_msg_count => l_msg_count,
            p_msg_data  => l_msg_data,   -- removed g_miss_char
            p_data      => l_data,
            p_msg_index_out => l_msg_index_out);
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
      ELSE
         x_msg_count  := l_msg_count;
      END IF;

      IF l_msg_count > 0 THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      ---------------------------------------------------
      -- prepare for DML


      -----------------------------------
      -- DML goes here

      -- keep the data before complete the op, use it to create new op
      select *
        into opRow
        from wip_operations
        where wip_entity_id = p_wip_entity_id
          and operation_seq_num = p_old_op_seq_num;

      if l_actual_start_date <= sysdate then --added by akalaval for bug 4162307

          l_old_op_duration := (sysdate - l_actual_start_date)*24;

      complete_operation(
        x_return_status => x_return_status
       ,x_msg_count =>  x_msg_count
       ,x_msg_data =>  x_msg_data
       ,p_wip_entity_id => p_wip_entity_id
       ,p_operation_seq_num => p_old_op_seq_num
       ,p_actual_start_date => l_actual_start_date
       ,p_actual_end_date => sysdate
       ,p_actual_duration => l_old_op_duration
       ,p_transaction_date => sysdate
       ,p_transaction_type => 1
       ,p_shutdown_start_date => null
       ,p_shutdown_end_date => null
       ,p_reconciliation_code => p_reconciliation_value
       ,p_stored_last_update_date => p_stored_last_update_date
      );

      else --condition added for handling operation completion in case of
           --operation start date is in future

      complete_operation(
        x_return_status => x_return_status
       ,x_msg_count =>  x_msg_count
       ,x_msg_data =>  x_msg_data
       ,p_wip_entity_id => p_wip_entity_id
       ,p_operation_seq_num => p_old_op_seq_num
       ,p_actual_start_date => sysdate
       ,p_actual_end_date => sysdate
       ,p_actual_duration => 0
       ,p_transaction_date => sysdate
       ,p_transaction_type => 1
       ,p_shutdown_start_date => null
       ,p_shutdown_end_date => null
       ,p_reconciliation_code => p_reconciliation_value
       ,p_stored_last_update_date => p_stored_last_update_date
      );

      end if;

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN


	select max(transaction_id) into l_transaction_id
	from eam_op_completion_txns
	where wip_entity_id = p_wip_entity_id
	and operation_seq_num = p_old_op_seq_num;

	update eam_op_completion_txns
	set handover_operation_seq_num = p_new_op_seq_num
	where wip_entity_id = p_wip_entity_id
	and operation_seq_num = p_old_op_seq_num
	and transaction_id = l_transaction_id;

        l_new_op_completion_date := (p_start_date + p_duration/24);
        -- create new operation
        opRow.Operation_Seq_Num := p_new_op_seq_num;
        opRow.Last_Update_Date := sysdate;
        opRow.Last_Updated_By := g_last_updated_by;
        opRow.Last_Update_Login := g_last_update_login;
        opRow.Creation_Date := sysdate;
        opRow.Created_By := g_created_by;
        opRow.Department_Id := l_department_id;
        opRow.Description := p_description;
        opRow.First_Unit_Start_Date := p_start_date;
        opRow.First_Unit_Completion_Date := l_new_op_completion_date;
        opRow.Last_Unit_Start_Date := p_start_date;
        opRow.Last_Unit_Completion_Date := l_new_op_completion_date;

        if ((p_shutdown_type is not null) and (p_shutdown_type <> -1)) then
        opRow.Shutdown_Type := p_shutdown_type;
        end if;

        opRow.Operation_Sequence_Id := null;

         l_eam_op_rec.wip_entity_id := opRow.Wip_Entity_Id;
         l_eam_op_rec.operation_seq_num := opRow.Operation_Seq_Num;
         l_eam_op_rec.organization_id := opRow.Organization_Id;
         l_eam_op_rec.operation_sequence_id := opRow.Operation_Sequence_Id;
         l_eam_op_rec.standard_operation_id := opRow.Standard_Operation_Id;
         l_eam_op_rec.department_id := opRow.Department_Id;
         l_eam_op_rec.description := opRow.Description;
         l_eam_op_rec.start_date := opRow.First_Unit_Start_Date;
         l_eam_op_rec.completion_date := opRow.Last_Unit_Completion_Date;
         l_eam_op_rec.count_point_type := opRow.Count_Point_Type;
         l_eam_op_rec.backflush_flag := opRow.Backflush_Flag;
         l_eam_op_rec.minimum_transfer_quantity := opRow.Minimum_Transfer_Quantity;
         l_eam_op_rec.attribute_category := opRow.Attribute_Category;
         l_eam_op_rec.attribute1 := opRow.Attribute1;
         l_eam_op_rec.attribute2 := opRow.Attribute2;
         l_eam_op_rec.attribute3 := opRow.Attribute3;
         l_eam_op_rec.attribute4 := opRow.Attribute4;
         l_eam_op_rec.attribute5 := opRow.Attribute5;
         l_eam_op_rec.attribute6 := opRow.Attribute6;
         l_eam_op_rec.attribute7 := opRow.Attribute7;
         l_eam_op_rec.attribute8 := opRow.Attribute8;
         l_eam_op_rec.attribute9 := opRow.Attribute9;
         l_eam_op_rec.attribute10 := opRow.Attribute10;
         l_eam_op_rec.attribute11 := opRow.Attribute11;
         l_eam_op_rec.attribute12 := opRow.Attribute12;
         l_eam_op_rec.attribute13 := opRow.Attribute13;
         l_eam_op_rec.attribute14 := opRow.Attribute14;
         l_eam_op_rec.attribute15 := opRow.Attribute15;
         l_eam_op_rec.long_description := opRow.Long_Description;
         l_eam_op_rec.shutdown_type := opRow.Shutdown_Type;




       l_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;


       l_eam_op_tbl(1) := l_eam_op_rec ;


				 EAM_PROCESS_WO_PUB.Process_WO
	  		         ( p_bo_identifier           => 'EAM'
	  		         , p_init_msg_list           => TRUE
	  		         , p_api_version_number      => 1.0
	                         , p_commit                  => 'N'
	  		         , p_eam_wo_rec              => l_eam_wo_rec
	  		         , p_eam_op_tbl              => l_eam_op_tbl
	  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
	  		         , p_eam_res_tbl             => l_eam_res_tbl
	  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
	  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
	  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
	                         , p_eam_direct_items_tbl    => l_eam_di_tbl
				 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
				 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
				 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
				 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
				 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
				 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
				 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
				 , p_eam_request_tbl         =>	l_eam_request_tbl
	  		         , x_eam_wo_rec              => l_out_eam_wo_rec
	  		         , x_eam_op_tbl              => l_out_eam_op_tbl
	  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
	  		         , x_eam_res_tbl             => l_out_eam_res_tbl
	  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
	  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
	  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
	  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
	                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
				 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
				 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
				 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
				 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
				 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
				 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
				 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
				 , x_eam_request_tbl         => l_out_eam_request_tbl
	  		         , x_return_status           => x_return_status
	  		         , x_msg_count               => x_msg_count
	  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
	  		         , p_debug_filename          => 'ophandover.log'
	  		         , p_output_dir              => l_output_dir
	                         , p_debug_file_mode         => 'w'
	                       );

        -- copy network relations
        copy_operation_network(
           p_wip_entity_id => p_wip_entity_id
          ,p_old_op_seq_num => p_old_op_seq_num
          ,p_new_op_seq_num => p_new_op_seq_num
          ,p_operation_start_date => p_start_date
          ,p_operation_completion_date => p_completion_date
          ,x_return_status => x_return_status
        );
      END IF;

      -- check error
      l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count = 1 THEN
         eam_execution_jsp.Get_Messages
           (p_encoded  => FND_API.G_FALSE,
            p_msg_index => 1,
            p_msg_count => l_msg_count,
            p_msg_data  => l_msg_data,
            p_data      => l_data,
            p_msg_index_out => l_msg_index_out);
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
      ELSE
         x_msg_count  := l_msg_count;
      END IF;

      IF l_msg_count > 0 THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;


      IF FND_API.TO_BOOLEAN(P_COMMIT)
      THEN
        COMMIT WORK;
      END IF;

    EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK TO operation_handover;

      FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover',
      p_procedure_name => EAM_DEBUG.G_err_stack);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO operation_handover;


      FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover',
      p_procedure_name => EAM_DEBUG.G_err_stack);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO operation_handover;


      FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover',
      p_procedure_name => EAM_DEBUG.G_err_stack);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      g_debug_sqlerrm := SQLERRM;

  END operation_handover;


-----------------------------------------------------------------------------------------
-- copy the operation network data for the new operation
-----------------------------------------------------------------------------------------

   procedure copy_operation_network
    (
       p_wip_entity_id               IN    NUMBER        -- data
      ,p_old_op_seq_num              IN    NUMBER
      ,p_new_op_seq_num              IN    NUMBER
      ,p_operation_start_date        IN    DATE
      ,p_operation_completion_date   IN    DATE
      ,x_return_status               OUT NOCOPY   VARCHAR2
    ) IS

    l_actual_end_date  DATE;
    l_completed  VARCHAR2(30);
    l_actual_start_date  DATE;


-- cursor to copy: xxx-> newop

      CURSOR nxtOpCur  IS
      SELECT prior_operation
              ,next_operation
              ,wip_entity_id
              ,organization_id
              ,created_by
              ,creation_date
              ,last_updated_by
              ,last_update_date
              ,last_update_login
              ,attribute_category
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
             FROM wip_operation_networks
             WHERE wip_entity_id =  p_wip_entity_id
             AND next_operation =  p_old_op_seq_num;

      -- cursor to copy new op --> xxx


      CURSOR prvOpCur  IS
      SELECT prior_operation
              ,next_operation
              ,wip_entity_id
              ,organization_id
              ,created_by
              ,creation_date
              ,last_updated_by
              ,last_update_date
              ,last_update_login
              ,attribute_category
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
             FROM wip_operation_networks
             WHERE wip_entity_id =  p_wip_entity_id
             AND prior_operation =  p_old_op_seq_num;




    BEGIN
      -- copy: xxx-> newop

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FOR nxtOpCurVar IN nxtOpCur LOOP


        BEGIN

		IF (nxtOpCurVar.prior_operation IS NOT NULL) THEN

			SELECT
			     last_unit_completion_date,
			     operation_completed
			INTO
			     l_actual_end_date,
			     l_completed
			FROM wip_operations
			WHERE
			    wip_entity_id = p_wip_entity_id
			AND operation_seq_num = nxtOpCurVar.prior_operation;

		END IF;

		IF (p_operation_start_date < l_actual_end_date) THEN
		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_INV_START_DATE');
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		END IF;

		IF NVL(l_completed,'N') = 'N' THEN
		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INVALID_COMPLETE_OP2');
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		END IF;


        EXCEPTION WHEN  NO_DATA_FOUND THEN  -- Bug 3133704, others -> no_data_found
           eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_OP_NOTFOUND');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

			nxtOpCurVar.next_operation  := p_new_op_seq_num;
			nxtOpCurVar.last_updated_by := FND_GLOBAL.user_id;
			nxtOpCurVar.last_update_login := FND_GLOBAL.user_id;
			nxtOpCurVar.created_by := FND_GLOBAL.user_id;
			nxtOpCurVar.last_update_date := sysdate;
			nxtOpCurVar.creation_date := sysdate;

			INSERT INTO wip_operation_networks
			(  prior_operation
			  ,next_operation
			  ,wip_entity_id
			  ,organization_id
			  ,created_by
			  ,creation_date
			  ,last_updated_by
			  ,last_update_date
			  ,last_update_login
			  ,attribute_category
			  ,attribute1
			  ,attribute2
			  ,attribute3
			  ,attribute4
			  ,attribute5
			  ,attribute6
			  ,attribute7
			  ,attribute8
			  ,attribute9
			  ,attribute10
			  ,attribute11
			  ,attribute12
			  ,attribute13
			  ,attribute14
			  ,attribute15
			) VALUES
			(  nxtOpCurVar.prior_operation
			  ,p_new_op_seq_num
			  ,nxtOpCurVar.wip_entity_id
			  ,nxtOpCurVar.organization_id
			  ,nxtOpCurVar.created_by
			  ,nxtOpCurVar.creation_date
			  ,nxtOpCurVar.last_updated_by
			  ,nxtOpCurVar.last_update_date
			  ,nxtOpCurVar.last_update_login
			  ,nxtOpCurVar.attribute_category
			  ,nxtOpCurVar.attribute1
			  ,nxtOpCurVar.attribute2
			  ,nxtOpCurVar.attribute3
			  ,nxtOpCurVar.attribute4
			  ,nxtOpCurVar.attribute5
			  ,nxtOpCurVar.attribute6
			  ,nxtOpCurVar.attribute7
			  ,nxtOpCurVar.attribute8
			  ,nxtOpCurVar.attribute9
			  ,nxtOpCurVar.attribute10
			  ,nxtOpCurVar.attribute11
			  ,nxtOpCurVar.attribute12
			  ,nxtOpCurVar.attribute13
			  ,nxtOpCurVar.attribute14
			  ,nxtOpCurVar.attribute15
			);
           END IF; -- end of check for x_return_status

      END LOOP;   -- end loop for nxtOpCurVar


      -- copy new op --> xxx

      FOR prvOpCurVar IN prvOpCur LOOP


        BEGIN

		IF (prvOpCurVar.next_operation IS NOT NULL) THEN

			SELECT
			     operation_completed
			    ,first_unit_start_date
			INTO
			     l_completed
			    ,l_actual_start_date
			FROM wip_operations
			WHERE
			    wip_entity_id = p_wip_entity_id
			AND operation_seq_num = prvOpCurVar.next_operation;

		END IF;

		IF (NVL(l_completed, 'N' ) = 'Y') THEN
			eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INVALID_COMPLETE_OP1');
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		IF (l_actual_start_date < p_operation_completion_date ) THEN
			eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_INV_END_DATE');
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

        EXCEPTION WHEN  NO_DATA_FOUND THEN  -- Bug 3133704, others -> no_data_found
	   eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_OP_NOTFOUND');
           x_return_status := FND_API.G_RET_STS_ERROR;
        END;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

			prvOpCurVar.prior_operation  := p_new_op_seq_num;
			prvOpCurVar.Last_Updated_By := FND_GLOBAL.user_id;
			prvOpCurVar.Last_Update_Login := FND_GLOBAL.user_id;
			prvOpCurVar.Created_By := FND_GLOBAL.user_id;
			prvOpCurVar.Last_Update_Date := sysdate;
			prvOpCurVar.Creation_Date := sysdate;


			INSERT INTO wip_operation_networks
			(  prior_operation
			  ,next_operation
			  ,wip_entity_id
			  ,organization_id
			  ,created_by
			  ,creation_date
			  ,last_updated_by
			  ,last_update_date
			  ,last_update_login
			  ,attribute_category
			  ,attribute1
			  ,attribute2
			  ,attribute3
			  ,attribute4
			  ,attribute5
			  ,attribute6
			  ,attribute7
			  ,attribute8
			  ,attribute9
			  ,attribute10
			  ,attribute11
			  ,attribute12
			  ,attribute13
			  ,attribute14
			  ,attribute15
			) VALUES
			(  p_new_op_seq_num
			  ,prvOpCurVar.next_operation
			  ,prvOpCurVar.wip_entity_id
			  ,prvOpCurVar.organization_id
			  ,prvOpCurVar.created_by
			  ,prvOpCurVar.creation_date
			  ,prvOpCurVar.last_updated_by
			  ,prvOpCurVar.last_update_date
			  ,prvOpCurVar.last_update_login
			  ,prvOpCurVar.attribute_category
			  ,prvOpCurVar.attribute1
			  ,prvOpCurVar.attribute2
			  ,prvOpCurVar.attribute3
			  ,prvOpCurVar.attribute4
			  ,prvOpCurVar.attribute5
			  ,prvOpCurVar.attribute6
			  ,prvOpCurVar.attribute7
			  ,prvOpCurVar.attribute8
			  ,prvOpCurVar.attribute9
			  ,prvOpCurVar.attribute10
			  ,prvOpCurVar.attribute11
			  ,prvOpCurVar.attribute12
			  ,prvOpCurVar.attribute13
			  ,prvOpCurVar.attribute14
			  ,prvOpCurVar.attribute15
			);

	END IF; -- end of check for x_return_status

      END LOOP;  -- end loop for prvOpCurVar


    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE FND_API.G_EXC_ERROR;
  END copy_operation_network;


---------------------------------------------------------------------------------------
-- handover the selected resources of one operation
---------------------------------------------------------------------------------------
  procedure operation_handover_resource
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_old_op_seq_num              IN    NUMBER
    ,p_resource_seq_num            IN    NUMBER
    ,p_new_op_seq_num              IN    NUMBER
    ,p_department                  IN    VARCHAR2
    ,p_start_date                  IN    DATE
    ,p_duration                    IN    NUMBER
    ,p_new_op_start_date           IN    DATE
    ,p_new_op_end_date             IN    DATE
    ,p_employee_id		   IN    NUMBER       -- instance id
    ,p_complete_rollback	   IN	 VARCHAR2      := FND_API.G_FALSE -- Added parameter to handle rollback for Mobile Handover Page.
  ) IS

  curRow wip_operation_resources%ROWTYPE;
  newRow wip_operation_resources%ROWTYPE;

  l_api_name           CONSTANT VARCHAR(30) := 'operation_handover_resource';
  l_api_version        CONSTANT NUMBER      := 1.0;
  l_return_status            VARCHAR2(250);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_department_id     NUMBER;
  l_quantity_open     NUMBER;
  l_start_quantity    NUMBER;
  l_num_non_compatible_resources NUMBER;
  l_duration  NUMBER;
  l_new_op_seq_num  NUMBER;
  l_resource_id     VARCHAR2(20);
  l_dept            NUMBER;
  l_res_valid       NUMBER;
  l_inst_valid      NUMBER;
  l_employee_name   VARCHAR2(165);

    /* added for calling WO API */

        l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_rec  EAM_PROCESS_WO_PUB.eam_res_rec_type;
        l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_res_inst_rec  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
        l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	 l_output_dir  VARCHAR2(512);

  BEGIN

       SAVEPOINT operation_handover_resource;

    eam_debug.init_err_stack('eam_operations_jsp.operation_handover_resource');

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;

  EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- validation
    if(p_duration <0) then
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DURATION');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    else
     l_duration := trunc(p_duration * 60 * 60, 0) / ( 24 * 60 * 60);
    end if;

   /* Fix for Bug 2108778 */
       -- Validate the new operation
       begin
       select operation_seq_num
       into l_new_op_seq_num
       from wip_operations
       where wip_entity_id = p_wip_entity_id
       and operation_seq_num = p_new_op_seq_num;
       Exception when others then
         eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_OP_NOTFOUND');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       END;
    /* Fix for Bug 2108778 */

    begin
     l_dept :=null;
     select resource_id into l_resource_id
     from wip_operation_resources
     where wip_entity_id = p_wip_entity_id
     and operation_seq_num = p_old_op_seq_num
     and resource_seq_num = p_resource_seq_num;

     select bd.department_id into l_dept
     from bom_department_resources bdr,bom_departments bd
     where bd.department_id = bdr.department_id
     and resource_id = l_resource_id
     and bd.department_id in (select department_id
                             from bom_departments
                             where department_code=p_department);
     if(l_dept=null) then
	  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DEPT_INVALID'
          ,p_token1 => 'RESOURCE_SEQ_NUM', p_value1 => p_resource_seq_num ,p_token2 => 'DEPARTMENT',p_value2 =>p_department);
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
    end;

    -- get the resource
    BEGIN
      select *
      into curRow
      from wip_operation_resources r
      where r.wip_entity_id = p_wip_entity_id
        and r.operation_seq_num = p_old_op_seq_num
        and r.resource_seq_num = p_resource_seq_num;

      select quantity_open
        into l_quantity_open
        from wip_operation_resources_v v
        where v.wip_entity_id = curRow.Wip_Entity_Id
          and v.operation_seq_num = curRow.Operation_Seq_Num
          and v.resource_seq_num = curRow.Resource_Seq_Num;

       IF l_quantity_open < 0 THEN
        l_quantity_open := 0;
       END IF ;

    Exception when others then
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_RSRC_NOTFOUND'
         ,p_token1 => 'RESOURCE_SEQ_NUM', p_value1 => p_resource_seq_num);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


      END;


    if( curRow.Wip_Entity_Id is not null) then
      BEGIN
        select department_id
        into l_department_id
        from bom_departments bd
        where bd.department_code like p_department
          and bd.organization_id = curRow.Organization_Id
          and nvl(bd.disable_date, sysdate) >= sysdate;


      Exception when others then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DEPT_INV'
         ,p_token1 => 'RESOURCE_SEQ_NUM', p_value1 => p_resource_seq_num
         ,p_token2 => 'ERR', p_value2 =>  SQLERRM );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;


      -- verify that resource can be handover to that department
      if (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
        select count(*)
        into l_num_non_compatible_resources
        from wip_operation_resources wor
        where wor.wip_entity_id = p_wip_entity_id
          and wor.operation_seq_num = p_old_op_seq_num
          and wor.resource_seq_num = p_resource_seq_num
          and wor.resource_id not in (
            select bdr.resource_id
            from bom_department_resources bdr
            where bdr.department_id = l_department_id
          );
        if( l_num_non_compatible_resources >0) then
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_DEPT_NOTOK'
         ,p_token1 => 'RESOURCE_SEQ_NUM', p_value1 => p_resource_seq_num);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        end if;
      end if;
   end if;

   -- get start quantity
   select start_quantity
   into l_start_quantity
   from wip_discrete_jobs wdj
   where wdj.wip_entity_id = p_wip_entity_id;

   if(l_start_quantity <> 1 ) then
     eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_S_QUANTITY_INV');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   end if;


   if( x_return_status = FND_API.G_RET_STS_SUCCESS) then
     BEGIN

	     SELECT 1 INTO l_res_valid
	     FROM wip_operation_resources
	     WHERE wip_entity_id = p_wip_entity_id
	     AND operation_seq_num = p_new_op_seq_num
	     AND resource_seq_num = p_resource_seq_num;

     EXCEPTION WHEN NO_DATA_FOUND THEN
	      l_res_valid := 0;
     END;

     BEGIN

             SELECT 1 INTO l_inst_valid
	     FROM wip_op_resource_instances
	     WHERE wip_entity_id = p_wip_entity_id
	     AND operation_seq_num = p_new_op_seq_num
	     AND resource_seq_num = p_resource_seq_num
             AND instance_id = p_employee_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN
              l_inst_valid := 0;
     END;

     -- copy row
     newRow := curRow;
     newRow.Operation_Seq_Num := p_new_op_seq_num;
     newRow.Start_Date := p_start_date;
     newRow.Completion_Date := p_start_date + l_duration;
     newRow.Department_Id := l_department_id;
     newRow.Usage_Rate_Or_Amount := nvl(l_quantity_open, 0) / l_start_quantity;
     newRow.Applied_Resource_Units := 0;
     newRow.Applied_Resource_Value := 0;

     -- row who
     newRow.Last_Update_Date := sysdate;
     newRow.Creation_Date := sysdate;
     newRow.Last_Updated_By := g_last_updated_by;
     newRow.Last_Update_Login := g_last_updated_by;
     newRow.Created_By := g_last_updated_by;


	BEGIN

		IF l_res_valid <> 1 THEN

			l_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
			l_eam_res_rec.wip_entity_id := newRow.Wip_Entity_Id;
			l_eam_res_rec.operation_seq_num := newRow.Operation_Seq_Num;
			l_eam_res_rec.organization_id := newRow.Organization_Id;
			l_eam_res_rec.resource_seq_num := newRow.resource_seq_num;
			l_eam_res_rec.resource_id := newRow.resource_id;
			l_eam_res_rec.uom_code := newRow.uom_code;
			l_eam_res_rec.basis_type := newRow.basis_type;
			l_eam_res_rec.usage_rate_or_amount := newRow.usage_rate_or_amount;
			l_eam_res_rec.activity_id := newRow.activity_id;
			l_eam_res_rec.scheduled_flag := newRow.scheduled_flag;
			l_eam_res_rec.firm_flag := newRow.firm_flag;
			l_eam_res_rec.assigned_units := newRow.assigned_units;
			l_eam_res_rec.maximum_assigned_units := newRow.maximum_assigned_units;
			l_eam_res_rec.autocharge_type := newRow.autocharge_type;
			l_eam_res_rec.standard_rate_flag := newRow.standard_rate_flag;
			l_eam_res_rec.applied_resource_units := newRow.applied_resource_units;
			l_eam_res_rec.applied_resource_value := newRow.applied_resource_value;
			l_eam_res_rec.start_date := newRow.start_date;
			l_eam_res_rec.completion_date := newRow.completion_date;
			l_eam_res_rec.schedule_seq_num := newRow.schedule_seq_num;
			l_eam_res_rec.substitute_group_num := newRow.substitute_group_num;
			l_eam_res_rec.attribute_category := newRow.attribute_category;
			l_eam_res_rec.department_id := newRow.department_id;
			l_eam_res_rec.attribute1 := newRow.Attribute1;
			l_eam_res_rec.attribute2 := newRow.Attribute2;
			l_eam_res_rec.attribute3 := newRow.Attribute3;
			l_eam_res_rec.attribute4 := newRow.Attribute4;
			l_eam_res_rec.attribute5 := newRow.Attribute5;
			l_eam_res_rec.Attribute6 := newRow.Attribute6;
			l_eam_res_rec.Attribute7 := newRow.Attribute7;
			l_eam_res_rec.Attribute8 := newRow.Attribute8;
			l_eam_res_rec.Attribute9 := newRow.Attribute9;
			l_eam_res_rec.Attribute10 := newRow.Attribute10;
			l_eam_res_rec.attribute11 := newRow.Attribute11;
			l_eam_res_rec.attribute12 := newRow.Attribute12;
			l_eam_res_rec.attribute13 := newRow.Attribute13;
			l_eam_res_rec.attribute14 := newRow.Attribute14;
			l_eam_res_rec.attribute15 := newRow.Attribute15;


			l_eam_res_tbl(1) := l_eam_res_rec ;

			IF l_inst_valid <> 1 THEN

				IF p_employee_id IS NOT NULL THEN

					l_eam_res_inst_rec.transaction_type		:=  EAM_PROCESS_WO_PUB.G_OPR_CREATE ;
					l_eam_res_inst_rec.wip_entity_id			:= p_wip_entity_id ;
					l_eam_res_inst_rec.organization_id		:= newRow.organization_id   ;
					l_eam_res_inst_rec.operation_seq_num	:= p_new_op_seq_num ;
					l_eam_res_inst_rec.resource_seq_num         := p_resource_seq_num ;
					l_eam_res_inst_rec.instance_id			:= p_employee_id ;
					l_eam_res_inst_rec.serial_number                := NULL ;
					l_eam_res_inst_rec.start_date			:= p_start_date ;
					l_eam_res_inst_rec.completion_date		:= (p_start_date+l_duration) ;

					l_eam_res_inst_tbl(1) := l_eam_res_inst_rec ;

				END IF;  -- end of p_employee_id

			ELSE
				SELECT full_name
				INTO l_employee_name
				FROM per_all_people_f papf,bom_resource_employees bre
				WHERE bre.instance_id  = p_employee_id
				and papf.person_id = bre.person_id
				and( trunc(sysdate) between papf.effective_start_date
				and papf.effective_end_date);

				eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RI_ALREADY_EXISTS'
				,p_token1 => 'INSTANCE_NAME', p_value1 => l_employee_name);
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;    -- end of l_inst_valid check

			EAM_PROCESS_WO_PUB.Process_WO
			( p_bo_identifier           => 'EAM'
			, p_init_msg_list           => TRUE
			, p_api_version_number      => 1.0
			, p_commit                  => 'N'
			, p_eam_wo_rec              => l_eam_wo_rec
			, p_eam_op_tbl              => l_eam_op_tbl
			, p_eam_op_network_tbl      => l_eam_op_network_tbl
			, p_eam_res_tbl             => l_eam_res_tbl
			, p_eam_res_inst_tbl        => l_eam_res_inst_tbl
			, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
			, p_eam_res_usage_tbl       => l_eam_res_usage_tbl
			, p_eam_mat_req_tbl         => l_eam_mat_req_tbl
			, p_eam_direct_items_tbl    => l_eam_di_tbl
			, p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			, p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			, p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			, p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			, p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			, p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			, p_eam_request_tbl         =>	l_eam_request_tbl
			, x_eam_wo_rec              => l_out_eam_wo_rec
			, x_eam_op_tbl              => l_out_eam_op_tbl
			, x_eam_op_network_tbl      => l_out_eam_op_network_tbl
			, x_eam_res_tbl             => l_out_eam_res_tbl
			, x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
			, x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
			, x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
			, x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
			, x_eam_direct_items_tbl    => l_out_eam_di_tbl
			, x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			, x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			, x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			, x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			, x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			, x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			, x_eam_request_tbl         => l_out_eam_request_tbl
			, x_return_status           => x_return_status
			, x_msg_count               => x_msg_count
			, p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
			, p_debug_filename          => 'opreshandover.log'
			, p_output_dir              => l_output_dir
			, p_debug_file_mode         => 'w'
			);

		END IF ; -- end of l_res_valid check



	EXCEPTION WHEN OTHERS THEN
	eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_HANDOVER_EXCEPTION'
	,p_token1 => 'RESOURCE_SEQ_NUM', p_value1 => p_resource_seq_num
	,p_token2 => 'ERR_MSG', p_value2 => SQLERRM);
	END;

  end if;

    -- check error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => l_msg_data,      -- removed g_miss_char
          p_data      => l_data,
          p_msg_index_out => l_msg_index_out);
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
    ELSE
       x_msg_count  := l_msg_count;
    END IF;

    IF l_msg_count > 0 THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
      COMMIT WORK;
    END IF;

  EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
	IF FND_API.TO_BOOLEAN(p_complete_rollback)
	THEN
		ROLLBACK; -- Complete rollback for Mobile Handover Page
	ELSE
		ROLLBACK TO operation_handover_resource; -- Method rollback for Desktop HandoverPage.
	END IF;
    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover_resource',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
	IF FND_API.TO_BOOLEAN(p_complete_rollback)
	THEN
		ROLLBACK; -- Complete rollback for Mobile Handover Page
	ELSE
		ROLLBACK TO operation_handover_resource; -- Method rollback for Desktop HandoverPage.
	END IF;
    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover_resource',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
	IF FND_API.TO_BOOLEAN(p_complete_rollback)
	THEN
		ROLLBACK; -- Complete rollback for Mobile Handover Page
	ELSE
		ROLLBACK TO operation_handover_resource; -- Method rollback for Desktop HandoverPage.
	END IF;
    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_operations_jsp.operation_handover_resource',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END operation_handover_resource;


  --  Procedure to validate all fields entered through the Add Resource JSP

  procedure validate_insert (p_wip_entity_id      IN       NUMBER
                             ,p_operation_seq_num  IN       NUMBER
                             ,p_department_code    IN       VARCHAR2
                             ,p_organization_id    IN       NUMBER
                             ,p_resource_code      IN       VARCHAR2
                             ,p_uom_code           IN       VARCHAR2
                             ,p_usage_rate         IN       NUMBER
                             ,p_assigned_units     IN       NUMBER
                             ,p_start_date         IN       DATE
                             ,p_end_date           IN       DATE
                             ,p_activity           IN       VARCHAR2
                             ,x_uom_status         OUT NOCOPY      NUMBER
                             ,x_operation_status   OUT NOCOPY      NUMBER
                             ,x_department_status  OUT NOCOPY      NUMBER
                             ,x_res_status         OUT NOCOPY      NUMBER
                             ,x_usage_status       OUT NOCOPY      NUMBER
                             ,x_assigned_units     OUT NOCOPY      NUMBER
                             ,x_assigned           OUT NOCOPY      NUMBER
                             ,x_dates              OUT NOCOPY      NUMBER
                             ,x_activity           OUT NOCOPY      NUMBER)  IS

              l_res_code  varchar2(80);
              l_uom       varchar2(30);
              l_invalid_uom  number := 0;
              l_invalid_resource number := 0;
              l_stmt_num number := 0;
              l_invalid_usage number := 0;
              l_operation_seq_num  number := 0;
              l_department_code varchar2(80);
              l_invalid_operation number := 0;
              l_invalid_department number := 0;
              l_invalid_assgned_units  number := 0;
              l_assigned    number := 0;
              l_invalid_dates number := 0;
              l_activities  varchar2(80);
              l_invalid_activity  number := 0;
              l_capacity_units  number := 0;

              resource_exists number := 1;
              uom_exists number := 1;
              operation_exists  number := 1;
              department_exists  number := 1;
              activity_exists number := 1;
              TYPE CUR_TYP is ref cursor;

          --    c_res_cur                               CUR_TYP;
           --   c_oper_cur                              CUR_TYP;
           --   c_act_cur				    CUR_TYP;



       CURSOR c_res_cur IS    --rhshriva
                 select res.resource_code,
                         res.unit_of_measure
                  from cst_activities cst, mtl_uom_conversions muc, bom_resources res, bom_department_resources bdr
                  where nvl(res.disable_date,sysdate+2) > sysdate
                  and res.resource_id = bdr.resource_id
                  and res.default_activity_id = cst.activity_id(+)
                  and (cst.organization_id = res.organization_id or cst.organization_id is null)
                  and nvl(cst.disable_date(+), sysdate+2) > sysdate
                  and res.unit_of_measure = muc.uom_code
                  and muc.inventory_item_id = 0
                  and res.organization_id = p_organization_id
                  and department_id = (select department_id
                                       from wip_operations
                                       where wip_entity_id =  p_wip_entity_id
                                       and operation_seq_num = p_operation_seq_num);



       CURSOR c_oper_cur IS  --rhshriva
	select wo.operation_seq_num, bd.department_code
	 from wip_operations wo, bom_departments bd
	 where bd.department_id = wo.department_id
	 and bd.organization_id = wo.organization_id
	 and wo.organization_id = p_organization_id
         and wo.wip_entity_id = p_wip_entity_id;


     CURSOR c_act_cur IS  --rhshriva
	 select activity
	      from cst_activities
	      where nvl(disable_date, sysdate + 2) > sysdate and
	    (organization_id is null or organization_id = p_organization_id ) ;

    BEGIN
              -- Check for Usage Rate
/* Commenting out the validation as this is already present in WO API */
              -- Check for Resource

              open c_res_cur ;
               l_stmt_num := 10;

               loop

               fetch c_res_cur into l_res_code, l_uom;
               exit when c_res_cur % NOTFOUND;

               l_stmt_num := 20;

               -- Check for resource_code and uom validation

               if (p_resource_code = l_res_code) then
                       resource_exists := 0 ;
               end if;

               if (p_uom_code = l_uom) then
  	             uom_exists := 0;
                end if;


                end loop;

                close c_res_cur;


  	      if (uom_exists = 1) then
  	      	 l_invalid_uom := 1;
  	      end if;

  	      if (resource_exists = 1) then
  	         l_invalid_resource := 1;
  	      end if;

  	     x_uom_status := l_invalid_uom;

  	     x_res_status := l_invalid_resource;

-- Bug 3133704 changed when_others
    EXCEPTION WHEN NO_DATA_FOUND THEN
          raise FND_API.G_EXC_ERROR;

    END validate_insert;


  -- Insert into WIP_OPERATION_RESOURCES from Add Resources JSP

    procedure insert_into_wor(  p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_operation_seq_num  IN       NUMBER
                  ,p_organization_id    IN       NUMBER
                  ,p_usage_rate   IN       NUMBER
                  ,p_resource_code      IN       VARCHAR2
                  ,p_uom_code           IN       VARCHAR2
  		,p_resource_seq_num   IN NUMBER
                  ,p_dept_code          IN VARCHAR2
  		,p_assigned_units     IN NUMBER
  		,p_basis              IN NUMBER
                  ,p_scheduled_flag     IN NUMBER
  		,p_charge_type        IN NUMBER
  		,p_schedule_sequence  IN NUMBER
  		,p_std_rate           IN VARCHAR2
  		,p_start_date         IN DATE
  		,p_end_date           IN DATE
  		,p_activity           IN VARCHAR2
		,p_mod		      IN VARCHAR2
  		,x_update_status      OUT NOCOPY      NUMBER
                  ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2)  IS

     l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wor';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

    l_resource_id             NUMBER;
    l_update_status          NUMBER := 1;
    l_activity_id            NUMBER;
    l_usage_rate      NUMBER := 0;
    l_stmt_num       NUMBER;

    -- baroy
    l_old_scheduled_flag    number;
    l_old_schedule_sequence number;
    l_old_start_date        date;
    l_old_end_date          date;
    l_old_usage_rate        number;
    l_old_uom_code          varchar2(3);
    l_old_assigned_units    number;
    l_call_scheduler        number := 0;
    -- baroy

    l_res_seq_exists      NUMBER := 0;


    /* added for calling WO API */

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_res_rec  EAM_PROCESS_WO_PUB.eam_res_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


   l_output_dir   VARCHAR2(512);
    BEGIN

  EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


                  -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_insert_into_wor_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;
                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
                   -- API body

    -- Check for Usage Rate

    if(p_usage_rate is not null) then
      l_usage_rate := p_usage_rate;
    else
      l_usage_rate := 0;
    end if;


    -- Derive Resource Id from Resource Code

      begin

      select resource_id
      into   l_resource_id
     from bom_resources
     where resource_code = p_resource_code
     and organization_id = p_organization_id;

      exception
  	when others then
  	  null;
      end;

    if (p_activity is not null) then

    begin
    select activity_id
    into l_activity_id
  from cst_activities
  where activity = p_activity
  and organization_id = organization_id;

  exception
     when others then
      null;
    end;
end if;
	if (p_mod='UPDATE') then
                        -- first query up the old resource for use in scheduling decision.
                        select scheduled_flag, schedule_seq_num,
                          start_date, completion_date, usage_rate_or_amount, uom_code, assigned_units
                          into l_old_scheduled_flag, l_old_schedule_sequence, l_old_start_date
                          , l_old_end_date, l_old_usage_rate, l_old_uom_code, l_old_assigned_units
                          from wip_operation_resources
                          where wip_entity_id = p_wip_entity_id
                          and operation_seq_num = p_operation_seq_num
                          and resource_seq_num = p_resource_seq_num
                          and organization_id = p_organization_id;
                        if p_scheduled_flag = 1 and (
                             l_old_scheduled_flag    <> p_scheduled_flag
                          or l_old_schedule_sequence <> p_schedule_sequence
                          or l_old_start_date        <> p_start_date
                          or l_old_end_date          <> p_end_date
                          or l_old_usage_rate        <> p_usage_rate
                          or l_old_uom_code          <> p_uom_code
                          or l_old_assigned_units    <> p_assigned_units)
                        then
                          l_call_scheduler := 1;
                        end if;

			l_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
			l_eam_res_rec.wip_entity_id :=  p_wip_entity_id;
                        l_eam_res_rec.organization_id := p_organization_id;
			l_eam_res_rec.operation_seq_num :=  p_operation_seq_num;
			l_eam_res_rec.resource_seq_num :=  p_resource_seq_num;
			l_eam_res_rec.resource_id := l_resource_id;
			l_eam_res_rec.uom_code := p_uom_code;
			l_eam_res_rec.basis_type := p_basis;
			l_eam_res_rec.usage_rate_or_amount := p_usage_rate;
			l_eam_res_rec.activity_id := l_activity_id;
			l_eam_res_rec.scheduled_flag := p_scheduled_flag;
			l_eam_res_rec.assigned_units := p_assigned_units;
			l_eam_res_rec.autocharge_type := p_charge_type;
			if ( p_std_rate = 'Y') then
			     l_eam_res_rec.standard_rate_flag := 1;
		        else
			     l_eam_res_rec.standard_rate_flag := 2;
			end if;
			l_eam_res_rec.start_date := p_start_date;
			l_eam_res_rec.completion_date := p_end_date;
                        l_eam_res_rec.schedule_seq_num := p_schedule_sequence;

			l_eam_res_tbl(1) := l_eam_res_rec ;


			EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl         =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl     => l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'updatewor.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

			l_update_status := 0;

	elsif (p_mod='INSERT') then
                        -- first find out whether we will need to call the
                        -- scheduler finally
                        if p_scheduled_flag = 1 then
                          l_call_scheduler := 1;
                        end if;


		        l_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
			l_eam_res_rec.wip_entity_id :=  p_wip_entity_id;
                        l_eam_res_rec.organization_id := p_organization_id;
			l_eam_res_rec.operation_seq_num :=  p_operation_seq_num;
			l_eam_res_rec.resource_seq_num :=  p_resource_seq_num;
			l_eam_res_rec.resource_id := l_resource_id;
			l_eam_res_rec.uom_code := p_uom_code;
			l_eam_res_rec.basis_type := p_basis;
			l_eam_res_rec.usage_rate_or_amount := p_usage_rate;
			l_eam_res_rec.activity_id := l_activity_id;
			l_eam_res_rec.scheduled_flag := p_scheduled_flag;
			l_eam_res_rec.assigned_units := p_assigned_units;
			l_eam_res_rec.autocharge_type := p_charge_type;
			if ( p_std_rate = 'Y') then
			     l_eam_res_rec.standard_rate_flag := 1;
		        else
			     l_eam_res_rec.standard_rate_flag := 2;
			end if;
			l_eam_res_rec.start_date := p_start_date;
			l_eam_res_rec.completion_date := p_end_date;
                        l_eam_res_rec.schedule_seq_num := p_schedule_sequence;

			l_eam_res_tbl(1) := l_eam_res_rec ;


			 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl         =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'insertwor.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );


	else
		x_return_status :='MODE_DOES_NOT_EXIST';
	end if;-- end of insertion and updation
	x_update_status := l_update_status;


         -- End of API body.
                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
		       and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;

		   IF(x_return_status <> 'S') THEN   --added for 3817679
		       ROLLBACK TO get_insert_into_wor_pvt;
		   END IF;


                   l_stmt_num    := 999;
                   -- Standard call to get message count and if count is 1, get message info.
                   fnd_msg_pub.count_and_get(
                      p_count => x_msg_count
                     ,p_data => x_msg_data);
                EXCEPTION
                   WHEN fnd_api.g_exc_error THEN
                      ROLLBACK TO get_insert_into_wor_pvt;
                      x_return_status := fnd_api.g_ret_sts_error;
                      fnd_msg_pub.count_and_get(
             --            p_encoded => FND_API.g_false
                         p_count => x_msg_count
                        ,p_data => x_msg_data);

                   WHEN fnd_api.g_exc_unexpected_error THEN
                      ROLLBACK TO get_insert_into_wor_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);

                   WHEN OTHERS THEN
                      ROLLBACK TO get_insert_into_wor_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      IF fnd_msg_pub.check_msg_level(
                            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                      END IF;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);



  END insert_into_wor;




   -- API to validate entries in Material Page

    PROCEDURE material_validate (
            p_organization_id      IN       NUMBER
           ,p_wip_entity_id        IN       NUMBER
           ,p_description          IN       VARCHAR2
           ,p_uom                  IN       VARCHAR2
           ,p_concatenated_segments IN      VARCHAR2
  	     ,p_operation_seq_num     IN      VARCHAR2
  	     ,p_department_code       IN      VARCHAR2
  	     ,p_supply                IN      VARCHAR2
           ,p_subinventory_code     IN      VARCHAR2
           ,p_locator               IN      VARCHAR2
  	     ,x_invalid_asset		  OUT NOCOPY     NUMBER
  	     ,x_invalid_description     OUT NOCOPY     NUMBER
  	     ,x_invalid_uom             OUT NOCOPY     NUMBER
  	     ,x_invalid_subinventory    OUT NOCOPY     NUMBER
    	     ,x_invalid_locator         OUT NOCOPY     NUMBER
  	     ,x_invalid_department      OUT NOCOPY     NUMBER
  	     ,x_invalid_operation       OUT NOCOPY     NUMBER
  	     ,x_invalid_supply          OUT NOCOPY     NUMBER
           )

         IS

           l_concatenated_segments   VARCHAR2(2000);
           l_organization_id         NUMBER;
  	     l_description             VARCHAR2(240);
           l_uom                     VARCHAR2(30);
  	     l_operation_seq_num       NUMBER;
  	     l_department_code         VARCHAR2(80);
  	     l_supply                  VARCHAR2(80);
  	     l_subinventory 	   VARCHAR2(80);
           l_on_hand_quantity        NUMBER;
  	     l_locator                 VARCHAR2(2000);
           l_stmt_num                NUMBER:= 0;

           invalid_uom               NUMBER := 0;
           invalid_description       NUMBER := 0;
  	     invalid_asset             NUMBER := 0;
           material_exists           NUMBER := 1;
  	     description_exists        NUMBER := 1;
  	     uom_exists                NUMBER := 1;

           subinventory_exists       NUMBER := 1;
           locator_exists            NUMBER := 1;
  	     invalid_subinventory      NUMBER := 0;
           invalid_locator           NUMBER := 0;

  	     invalid_department        NUMBER := 0;
  	     invalid_operation         NUMBER := 0;
  	     operation_exists          NUMBER := 1;
  	     department_exists         NUMBER := 1;

  	     supply_exists             NUMBER := 1;
           invalid_supply            NUMBER := 0;
           constant_yes          VARCHAR2(1) := 'Y';
           constant_supply_type    VARCHAR2(30) := 'WIP_SUPPLY';



            TYPE CUR_TYP is ref cursor;

           CURSOR c_supply_cur IS  --rhshriva
	    select meaning
	    from mfg_lookups
	    where lookup_type = g_supply_type
	     and (lookup_code = 1 or  lookup_code = 4) ;

	 CURSOR c_subinv_cur IS  --rhshriva
	 select msinv.secondary_inventory_name,
			     SUM(moq.transaction_quantity) on_hand_quantity

	      from mtl_secondary_inventories msinv, mtl_onhand_quantities moq
	      where  moq.organization_id=msinv.organization_id
		      and nvl(msinv.disable_date, sysdate+2) > sysdate
		     and moq.subinventory_code = msinv.secondary_inventory_name
		     and msinv.organization_id = p_organization_id
		     and moq.inventory_item_id = (select inventory_item_id from mtl_system_items_kfv
		     where organization_id = p_organization_id
		     and concatenated_segments =p_concatenated_segments)
	      group by msinv.secondary_inventory_name, moq.inventory_item_id, msinv.organization_id, msinv.description, msinv.locator_type
		     order by msinv.secondary_inventory_name;


           CURSOR  c_locator_cur  IS   --rhshriva
           select concatenated_segments
            from mtl_item_locations_kfv
            where (disable_date > sysdate or disable_date is null)
            and organization_id = p_organization_id
            and subinventory_code = p_subinventory_code ;




           BEGIN

            -- API body

            l_organization_id := p_organization_id;

            l_stmt_num := 60;

  	if (material_exists = 1) then

           invalid_asset := 1;

  	end if;

  	if (description_exists = 1) then

  	   invalid_description := 1;

          end if;

  	if (uom_exists = 1) then

  	    invalid_uom := 1;

  	end if;


          l_stmt_num := 70;


       -- Check whether the operation is valid and matches with assigned department
       /* Commenting out the validation on  department as it is present in WO API */
  	   l_stmt_num := 80;

       -- Check Supply Type
       /* Commenting out the validation on supply type as it is present in WO API */
       l_stmt_num := 90;


       -- Check for Subinventory
  	 if (p_subinventory_code is not null) then

            open c_subinv_cur ;
           l_stmt_num := 95;

           loop
           fetch c_subinv_cur into l_subinventory, l_on_hand_quantity;
           EXIT WHEN c_subinv_cur%NOTFOUND;

  		if (l_subinventory = p_subinventory_code) then
  			subinventory_exists := 0;
  	        end if;

           end loop;
           close c_subinv_cur;

           if (subinventory_exists = 1) then
              invalid_subinventory := 1;
           end if;

          end if ;  -- end of p_subinventory not null

  	 l_stmt_num := 100;


           -- Check for Locator


  	if (p_locator is not null) then

           open c_locator_cur ;
  	  l_stmt_num := 105;

            loop
            fetch c_locator_cur into l_concatenated_segments;
            EXIT WHEN c_locator_cur%NOTFOUND;


                  if (l_concatenated_segments = p_locator) then

  	            locator_exists := 0;

  	        end if;

            end loop;
            close c_locator_cur;

            if (locator_exists = 1) then

               invalid_locator := 1;

            end if;

  	end if;  -- end of check for p_locator



           l_stmt_num := 110;

           x_invalid_asset  := invalid_asset;
  	     x_invalid_description  := invalid_description;
  	     x_invalid_uom     := invalid_uom;
  	     x_invalid_subinventory := invalid_subinventory;
    	     x_invalid_locator  := invalid_locator;
  	     x_invalid_department := invalid_department;
  	     x_invalid_operation := invalid_operation;
  	     x_invalid_supply := invalid_supply;


         END material_validate;



         --- Insert into WRO


   PROCEDURE insert_into_wro(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
  		,p_concatenated_segments  IN   VARCHAR2
  	 	,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
   		,p_supply             	IN     VARCHAR2
  		,p_required_date        IN     DATE
  		,p_quantity            IN      NUMBER
  		,p_comments            IN      VARCHAR2
  		,p_supply_subinventory  IN     VARCHAR2
  		,p_locator 		IN     VARCHAR2
  		,p_mrp_net_flag         IN     VARCHAR2
  		,p_material_release     IN     VARCHAR2
  		,x_invalid_update_operation  OUT NOCOPY  NUMBER
  		,x_invalid_update_department OUT NOCOPY  NUMBER
  		,x_invalid_update_description OUT NOCOPY NUMBER
                          ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                  ,x_update_status        OUT NOCOPY   NUMBER
				  ,p_supply_code          IN     NUMBER :=NULL
  				  ,p_one_step_issue       IN   varchar2:=fnd_api.g_false
				  ,p_released_quantity     IN    NUMBER := NULL)

                IS
                   l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wro';
                   l_api_version    CONSTANT NUMBER       := 1.0;
                   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  		   l_stmt_num                   NUMBER;
  		   l_wip_entity_id              NUMBER;
  		   l_inventory_item_id          NUMBER;
  		   l_department_id              NUMBER;
  		   l_supply                     NUMBER;
  		   l_locator                    NUMBER;
  		   l_mrp_net_flag               NUMBER;
  		   l_material_release           VARCHAR2(1);
  		   l_material_exists            NUMBER := 0;
                   l_existing_operation         NUMBER;
                   l_existing_department        NUMBER;
                   l_existing_description       VARCHAR2(240);
                   l_req_qty                    NUMBER := 0;
                   l_status_type                NUMBER := 0;
                   l_material_issue_by_mo       VARCHAR2(1);
                   l_auto_request_material      VARCHAR2(1);
  		   invalid_update_operation     NUMBER := 0;
                   invalid_update_department    NUMBER := 0;
  		   invalid_update_description   NUMBER := 0;
                   l_update_status              NUMBER := 0;
                   l_return_status              NUMBER := 0;
                   l_msg_count                  NUMBER := 0;
                   l_msg_data                   VARCHAR2(2000) ;
                   l_return_status1             VARCHAR2(30) ;
		   l_material_issue_by_mo_temp       VARCHAR2(1) ;
				   l_wo_changed                 BOOLEAN := FALSE;



		   l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
                   l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
		   l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
                   l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
                   l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
                   l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
                   l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
                   l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
                   l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
                   l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		   l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		   l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		   l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		   l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		   l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		   l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		   l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		   l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
                   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
                   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
                   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
                   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
                   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
                   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
                   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
                   l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		   l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		   l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		   l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		   l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		   l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		   l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		   l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		   l_output_dir   VARCHAR2(512);

           BEGIN
                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_insert_into_wro_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;
                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
                   -- API body

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


  	l_wip_entity_id := p_wip_entity_id ;

          -- Get Inventory Item Id
          select inventory_item_id
          into l_inventory_item_id
          from mtl_system_items_kfv
          where concatenated_segments = p_concatenated_segments
          and organization_id = p_organization_id;

          begin

  	select 1, wro.operation_seq_num,wro.department_id,msikfv.description
          into l_material_exists, l_existing_operation, l_existing_department, l_existing_description
          from wip_requirement_operations wro, mtl_system_items_kfv msikfv
          where wro.inventory_item_id = l_inventory_item_id
          and  wro.organization_id = p_organization_id
  	and  wro.wip_entity_id = p_wip_entity_id
          and  wro.organization_id = msikfv.organization_id
	  and wro.operation_seq_num = p_operation_seq_num
  	and  wro.inventory_item_id = msikfv.inventory_item_id;

  	exception
  	when others then
  	  null;
  	end;

          -- Get Department Id
          select department_id
          into l_department_id
  	from wip_operations
  	where wip_entity_id = l_wip_entity_id
          and operation_seq_num = p_operation_seq_num
  	and organization_id = p_organization_id;

         -- Get Supply TYpe
       if(p_supply is not null) then
          select lookup_code
  	      into l_supply
          from mfg_lookups
          where lookup_type = g_supply_type
          and meaning = p_supply;
        else
		  l_supply := p_supply_code;
		end if;
  	-- Get Locator Id
          if (p_locator is not null) then

  	select inventory_location_id
          into l_locator
  	from mtl_item_locations_kfv
  	where organization_id = p_organization_id
  	and concatenated_segments = p_locator
  	and subinventory_code = p_supply_subinventory ;

  	end if;
  	-- Get MRP Net Flag

  	if (p_mrp_net_flag is not null) then
             l_mrp_net_flag := 1;
  	else
  	  l_mrp_net_flag := 2;
  	end if;

  	if (p_material_release is null) then
  	  l_material_release := 'N';
        else
          if upper(p_material_release) = 'ON' then
            l_material_release := 'Y';
          else
            l_material_release := 'N';
          end if;
  	end if;

/* To avoid the material allocation from the WO API
** for OneStep Issue page since allocation api will
** be called seperatly.
*/
if(p_one_step_issue = fnd_api.g_true) then
  l_wo_changed := TRUE;
   select material_issue_by_mo into l_material_issue_by_mo_temp
     from wip_discrete_jobs
     where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
   update wip_discrete_jobs set material_issue_by_mo='N'
   where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
end if; -- end of p_one_step_issue check


        IF (l_material_exists = 1) THEN

  	   if (l_existing_operation <> p_operation_seq_num) then
  		invalid_update_operation := 1;
             end if;

  	    if (l_existing_department <> l_department_id ) then
  		invalid_update_department := 1;
             end if;

             if (l_existing_description <> p_description) then
  		invalid_update_description := 1;
  	     end if;


  	    if ((invalid_update_operation = 0) and (invalid_update_department = 0)
               and (invalid_update_description = 0)) then

	        l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := l_inventory_item_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
		l_eam_mat_req_rec.wip_supply_type := l_supply;
		l_eam_mat_req_rec.date_required := p_required_date;
		l_eam_mat_req_rec.required_quantity := p_quantity;
		l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
                l_eam_mat_req_rec.supply_locator_id := l_locator;
		l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
		l_eam_mat_req_rec.comments := p_comments;


    		l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl     => l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'updatewro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
                 l_update_status := 1;


           end if;

      ELSE

         -- If entry does not exists in WIP_REQUIREMENT_OPERATIONS then place a new
         -- entry into WIP_REQUIREMENT_OPERATIONS

		l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := l_inventory_item_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
		l_eam_mat_req_rec.wip_supply_type := l_supply;
		l_eam_mat_req_rec.date_required := p_required_date;
		l_eam_mat_req_rec.required_quantity := p_quantity;
		l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
                l_eam_mat_req_rec.supply_locator_id := l_locator;
		l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
		l_eam_mat_req_rec.comments := p_comments;
	        l_eam_mat_req_rec.released_quantity   := p_released_quantity;

    		l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;


		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'insertwro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );



     END IF ;  -- Material does not exist

 /* To check whether the WDJ table was changed before call to WO API */
  if(l_wo_changed = true) then
   update wip_discrete_jobs set material_issue_by_mo=l_material_issue_by_mo_temp
   where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
  end if; -- end of l_wo_changed check

      x_invalid_update_operation  := invalid_update_operation ;
      x_invalid_update_department := invalid_update_department;
      x_invalid_update_description  := invalid_update_description;
      x_update_status := l_update_status;


                   -- End of API body.
                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
		       and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;

		   IF(x_return_status <> 'S') THEN
		        ROLLBACK TO get_insert_into_wro_pvt;
		   END IF;

                   l_stmt_num    := 999;
                   -- Standard call to get message count and if count is 1, get message info.
                   fnd_msg_pub.count_and_get(
                      p_count => x_msg_count
                     ,p_data => x_msg_data);
                EXCEPTION
                   WHEN fnd_api.g_exc_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_error;
                      fnd_msg_pub.count_and_get(
             --            p_encoded => FND_API.g_false
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN fnd_api.g_exc_unexpected_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN OTHERS THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      IF fnd_msg_pub.check_msg_level(
                            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                      END IF;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);


    END insert_into_wro;

	 --Start of bug 12631479
	 --This procedure is not called in R12.This was added to maintain dual check in between R12->R12.1
   PROCEDURE insert_into_wro(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
  		,p_concatenated_segments  IN   VARCHAR2
  	 	,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
   		,p_supply             	IN     VARCHAR2
  		,p_required_date        IN     DATE
  		,p_quantity            IN      NUMBER
  		,p_comments            IN      VARCHAR2
  		,p_supply_subinventory  IN     VARCHAR2
  		,p_locator 		IN     VARCHAR2
  		,p_mrp_net_flag         IN     VARCHAR2
  		,p_material_release     IN     VARCHAR2
  		,x_invalid_update_operation  OUT NOCOPY  NUMBER
  		,x_invalid_update_department OUT NOCOPY  NUMBER
  		,x_invalid_update_description OUT NOCOPY NUMBER
                          ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                  ,x_update_status        OUT NOCOPY   NUMBER
				  ,p_supply_code          IN     NUMBER :=NULL
  				  ,p_one_step_issue       IN   varchar2:=fnd_api.g_false
				  ,p_released_quantity     IN    NUMBER := NULL
          ,p_attribute_category IN VARCHAR2
          ,p_attribute1 IN VARCHAR2
          ,p_attribute2 IN VARCHAR2
          ,p_attribute3 IN VARCHAR2
          ,p_attribute4 IN VARCHAR2
          ,p_attribute5 IN VARCHAR2
          ,p_attribute6 IN VARCHAR2
          ,p_attribute7 IN VARCHAR2
          ,p_attribute8 IN VARCHAR2
          ,p_attribute9 IN VARCHAR2
          ,p_attribute10 IN VARCHAR2
          ,p_attribute11 IN VARCHAR2
          ,p_attribute12 IN VARCHAR2
          ,p_attribute13 IN VARCHAR2
          ,p_attribute14 IN VARCHAR2
          ,p_attribute15 IN VARCHAR2


          )

                IS
                   l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wro';
                   l_api_version    CONSTANT NUMBER       := 1.0;
                   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  		   l_stmt_num                   NUMBER;
  		   l_wip_entity_id              NUMBER;
  		   l_inventory_item_id          NUMBER;
  		   l_department_id              NUMBER;
  		   l_supply                     NUMBER;
  		   l_locator                    NUMBER;
  		   l_mrp_net_flag               NUMBER;
  		   l_material_release           VARCHAR2(1);
  		   l_material_exists            NUMBER := 0;
                   l_existing_operation         NUMBER;
                   l_existing_department        NUMBER;
                   l_existing_description       VARCHAR2(240);
                   l_req_qty                    NUMBER := 0;
                   l_status_type                NUMBER := 0;
                   l_material_issue_by_mo       VARCHAR2(1);
                   l_auto_request_material      VARCHAR2(1);
  		   invalid_update_operation     NUMBER := 0;
                   invalid_update_department    NUMBER := 0;
  		   invalid_update_description   NUMBER := 0;
                   l_update_status              NUMBER := 0;
                   l_return_status              NUMBER := 0;
                   l_msg_count                  NUMBER := 0;
                   l_msg_data                   VARCHAR2(2000) ;
                   l_return_status1             VARCHAR2(30) ;
		   l_material_issue_by_mo_temp       VARCHAR2(1) ;
				   l_wo_changed                 BOOLEAN := FALSE;



		   l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
                   l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
		   l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
                   l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
                   l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
                   l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
                   l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
                   l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
                   l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
                   l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		   l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		   l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		   l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		   l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		   l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		   l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		   l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		   l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
                   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
                   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
                   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
                   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
                   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
                   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
                   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
                   l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		   l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		   l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		   l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		   l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		   l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		   l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		   l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		   l_output_dir   VARCHAR2(512);

           BEGIN

                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_insert_into_wro_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;
                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
                   -- API body

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


  	l_wip_entity_id := p_wip_entity_id ;

          -- Get Inventory Item Id
          select inventory_item_id
          into l_inventory_item_id
          from mtl_system_items_kfv
          where concatenated_segments = p_concatenated_segments
          and organization_id = p_organization_id;

          begin

  	select 1, wro.operation_seq_num,wro.department_id,msikfv.description
          into l_material_exists, l_existing_operation, l_existing_department, l_existing_description
          from wip_requirement_operations wro, mtl_system_items_kfv msikfv
          where wro.inventory_item_id = l_inventory_item_id
          and  wro.organization_id = p_organization_id
  	and  wro.wip_entity_id = p_wip_entity_id
          and  wro.organization_id = msikfv.organization_id
	  and wro.operation_seq_num = p_operation_seq_num
  	and  wro.inventory_item_id = msikfv.inventory_item_id;

  	exception
  	when others then
  	  null;
  	end;

          -- Get Department Id
          select department_id
          into l_department_id
  	from wip_operations
  	where wip_entity_id = l_wip_entity_id
          and operation_seq_num = p_operation_seq_num
  	and organization_id = p_organization_id;

         -- Get Supply TYpe
       if(p_supply is not null) then
          select lookup_code
  	      into l_supply
          from mfg_lookups
          where lookup_type = g_supply_type
          and meaning = p_supply;
        else
		  l_supply := p_supply_code;
		end if;
  	-- Get Locator Id
          if (p_locator is not null) then

  	select inventory_location_id
          into l_locator
  	from mtl_item_locations_kfv
  	where organization_id = p_organization_id
  	and concatenated_segments = p_locator
  	and subinventory_code = p_supply_subinventory ;

  	end if;
  	-- Get MRP Net Flag

  	if (p_mrp_net_flag is not null) then
             l_mrp_net_flag := 1;
  	else
  	  l_mrp_net_flag := 2;
  	end if;

  	if (p_material_release is null) then
  	  l_material_release := 'N';
        else
          if upper(p_material_release) = 'ON' then
            l_material_release := 'Y';
          else
            l_material_release := 'N';
          end if;
  	end if;

/* To avoid the material allocation from the WO API
** for OneStep Issue page since allocation api will
** be called seperatly.
*/
if(p_one_step_issue = fnd_api.g_true) then
  l_wo_changed := TRUE;
   select material_issue_by_mo into l_material_issue_by_mo_temp
     from wip_discrete_jobs
     where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
   update wip_discrete_jobs set material_issue_by_mo='N'
   where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
end if; -- end of p_one_step_issue check


        IF (l_material_exists = 1) THEN

  	   if (l_existing_operation <> p_operation_seq_num) then
  		invalid_update_operation := 1;
             end if;

  	    if (l_existing_department <> l_department_id ) then
  		invalid_update_department := 1;
             end if;

             if (l_existing_description <> p_description) then
  		invalid_update_description := 1;
  	     end if;

  	    if ((invalid_update_operation = 0) and (invalid_update_department = 0)
               and (invalid_update_description = 0)) then

	        l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := l_inventory_item_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
		l_eam_mat_req_rec.wip_supply_type := l_supply;
		l_eam_mat_req_rec.date_required := p_required_date;
		l_eam_mat_req_rec.required_quantity := p_quantity;
		l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
                l_eam_mat_req_rec.supply_locator_id := l_locator;
		l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
		l_eam_mat_req_rec.comments := p_comments;
    l_eam_mat_req_rec.attribute_category:=p_attribute_category;
    l_eam_mat_req_rec.attribute1:=p_attribute1;
    l_eam_mat_req_rec.attribute2:=p_attribute2;
    l_eam_mat_req_rec.attribute3:=p_attribute3;
    l_eam_mat_req_rec.attribute4:=p_attribute4;
    l_eam_mat_req_rec.attribute5:=p_attribute5;
    l_eam_mat_req_rec.attribute6:=p_attribute6;
    l_eam_mat_req_rec.attribute7:=p_attribute7;
    l_eam_mat_req_rec.attribute8:=p_attribute8;
    l_eam_mat_req_rec.attribute9:=p_attribute9;
    l_eam_mat_req_rec.attribute10:=p_attribute10;
    l_eam_mat_req_rec.attribute11:=p_attribute11;
    l_eam_mat_req_rec.attribute12:=p_attribute12;
    l_eam_mat_req_rec.attribute13:=p_attribute13;
    l_eam_mat_req_rec.attribute14:=p_attribute14;
    l_eam_mat_req_rec.attribute15:=p_attribute15;


    		l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl     => l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'updatewro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
                 l_update_status := 1;


           end if;

      ELSE

         -- If entry does not exists in WIP_REQUIREMENT_OPERATIONS then place a new
         -- entry into WIP_REQUIREMENT_OPERATIONS

		l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := l_inventory_item_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
		l_eam_mat_req_rec.wip_supply_type := l_supply;
		l_eam_mat_req_rec.date_required := p_required_date;
		l_eam_mat_req_rec.required_quantity := p_quantity;
		l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
                l_eam_mat_req_rec.supply_locator_id := l_locator;
		l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
		l_eam_mat_req_rec.comments := p_comments;
    l_eam_mat_req_rec.released_quantity   := p_released_quantity;


    l_eam_mat_req_rec.attribute_category:=p_attribute_category;
    l_eam_mat_req_rec.attribute1:=p_attribute1;
    l_eam_mat_req_rec.attribute2:=p_attribute2;
    l_eam_mat_req_rec.attribute3:=p_attribute3;
    l_eam_mat_req_rec.attribute4:=p_attribute4;
    l_eam_mat_req_rec.attribute5:=p_attribute5;
    l_eam_mat_req_rec.attribute6:=p_attribute6;
    l_eam_mat_req_rec.attribute7:=p_attribute7;
    l_eam_mat_req_rec.attribute8:=p_attribute8;
    l_eam_mat_req_rec.attribute9:=p_attribute9;
    l_eam_mat_req_rec.attribute10:=p_attribute10;
    l_eam_mat_req_rec.attribute11:=p_attribute11;
    l_eam_mat_req_rec.attribute12:=p_attribute12;
    l_eam_mat_req_rec.attribute13:=p_attribute13;
    l_eam_mat_req_rec.attribute14:=p_attribute14;
    l_eam_mat_req_rec.attribute15:=p_attribute15;

    l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;



		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'insertwro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );



     END IF ;  -- Material does not exist

 /* To check whether the WDJ table was changed before call to WO API */
  if(l_wo_changed = true) then
   update wip_discrete_jobs set material_issue_by_mo=l_material_issue_by_mo_temp
   where
     wip_entity_id = p_wip_entity_id and
	 organization_id = p_organization_id;
  end if; -- end of l_wo_changed check

      x_invalid_update_operation  := invalid_update_operation ;
      x_invalid_update_department := invalid_update_department;
      x_invalid_update_description  := invalid_update_description;
      x_update_status := l_update_status;


                   -- End of API body.
                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
		       and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;

		   IF(x_return_status <> 'S') THEN
		        ROLLBACK TO get_insert_into_wro_pvt;
		   END IF;

                   l_stmt_num    := 999;
                   -- Standard call to get message count and if count is 1, get message info.
                   fnd_msg_pub.count_and_get(
                      p_count => x_msg_count
                     ,p_data => x_msg_data);
                EXCEPTION
                   WHEN fnd_api.g_exc_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_error;
                      fnd_msg_pub.count_and_get(
             --            p_encoded => FND_API.g_false
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN fnd_api.g_exc_unexpected_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN OTHERS THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      IF fnd_msg_pub.check_msg_level(
                            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                      END IF;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);


    END insert_into_wro;
  --End of bug 12631479


   PROCEDURE delete_resources (
            p_api_version        IN       NUMBER
  	   ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  	   ,p_commit             IN       VARCHAR2 := fnd_api.g_false
           ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
           ,p_wip_entity_id      IN       NUMBER
           ,p_operation_seq_num  IN       NUMBER
           ,p_resource_seq_num   IN       NUMBER
           ,x_return_status      OUT NOCOPY      VARCHAR2
           ,x_msg_count          OUT NOCOPY      NUMBER
           ,x_msg_data           OUT NOCOPY      VARCHAR2)  IS


         l_api_name       CONSTANT VARCHAR2(30) := 'delete_resources';
  	 l_api_version    CONSTANT NUMBER       := 1.0;
  	 l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  	   l_stmt_num       NUMBER;
           l_wip_entity_id  NUMBER;
           l_operation_seq_num  NUMBER;
           l_resource_seq_num   NUMBER;
           l_organization_id    NUMBER;
           l_resource_id        NUMBER;
           l_applied_units      NUMBER;
           l_exists             NUMBER := 0;
           l_msg_count                NUMBER;
           l_msg_data                 VARCHAR2(250);
           l_data                     VARCHAR2(250);
    	  l_msg_index_out            NUMBER;

           l_validate_st        NUMBER := 0;


	   /* added for calling WO API */

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_res_rec  EAM_PROCESS_WO_PUB.eam_res_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_output_dir   VARCHAR2(512);

   BEGIN
                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_delete_resources_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;

                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
    -- API body

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    l_wip_entity_id := p_wip_entity_id;
    l_operation_seq_num := p_operation_seq_num;
    l_resource_seq_num := p_resource_seq_num;
    if ((l_wip_entity_id is not null) AND (l_operation_seq_num is not null) and (l_resource_seq_num is not null)) then

      begin

      select organization_id, resource_id
      into l_organization_id, l_resource_id
      from wip_operation_resources
      where wip_entity_id = l_wip_entity_id
      and operation_seq_num = l_operation_seq_num
      and resource_seq_num = l_resource_seq_num;

      exception
      when others then
      null;
      end;

   end if;


   if (( l_resource_id is not null) AND (l_resource_seq_num is not null) AND (l_operation_seq_num is not null)) then

        --check if there are any instances attached to the resource
        select count(*)
        into  l_exists
        from wip_op_resource_instances
        where wip_entity_id     = l_wip_entity_id and
              operation_seq_num = l_operation_seq_num and
              resource_seq_num  = l_resource_seq_num;

        if(l_exists <> 0) then

          l_validate_st := 1;
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INSTANCES_EXIST');
          x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

   end if;  -- End of l_resource_id is not null ........

    -- if validate not passed then raise error
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count = 1 THEN

          eam_execution_jsp.Get_Messages
            (p_encoded  => FND_API.G_FALSE,
             p_msg_index => 1,
             p_msg_count => l_msg_count,
             p_msg_data  => l_msg_data,
             p_data      => l_data,
             p_msg_index_out => l_msg_index_out);
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
       ELSE
          x_msg_count  := l_msg_count;
       END IF;

       IF l_msg_count > 0 THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;



   -- Perform delete if all the validations have passed

  if (l_validate_st = 0) then
        l_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
        l_eam_res_rec.wip_entity_id :=  p_wip_entity_id;
        l_eam_res_rec.organization_id := l_organization_id;
	l_eam_res_rec.operation_seq_num :=  p_operation_seq_num;
	l_eam_res_rec.resource_seq_num :=  p_resource_seq_num;
	l_eam_res_rec.resource_id := l_resource_id;

	l_eam_res_tbl(1) := l_eam_res_rec ;

                    EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delwor.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

   end if;



    -- End of API body.
                     -- Standard check of p_commit.
                     IF fnd_api.to_boolean(p_commit)
		          and x_return_status = 'S' THEN
                        COMMIT WORK;
                     END IF;

		     IF(x_return_status <> 'S') THEN
		         ROLLBACK TO get_delete_resources_pvt;
		     END IF;

                     l_stmt_num    := 999;

                     -- Standard call to get message count and if count is 1, get message info.
                     fnd_msg_pub.count_and_get(
                        p_count => x_msg_count
                       ,p_data => x_msg_data);

                  EXCEPTION
                     WHEN fnd_api.g_exc_error THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_msg_pub.count_and_get(
               --            p_encoded => FND_API.g_false
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

                     WHEN fnd_api.g_exc_unexpected_error THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_unexp_error;

                        fnd_msg_pub.count_and_get(
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

                     WHEN OTHERS THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_unexp_error;
                        IF fnd_msg_pub.check_msg_level(
                              fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                        END IF;

                        fnd_msg_pub.count_and_get(
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

      END delete_resources;


   --------------------------------------------------------------------------
    -- Procedure to validate department
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------

procedure validate_dept (   p_wip_entity_id		 IN       NUMBER
                           ,p_operation_seq_num		 IN       NUMBER
			   ,p_organization_id		 IN       NUMBER
                           ,p_department_code	         IN       VARCHAR2
			   ,x_department_id		 OUT NOCOPY      NUMBER
                           ,x_return_status	         OUT NOCOPY      NUMBER)  IS

	l_department_id    NUMBER := null;
	l_return_status    NUMBER := 0;

BEGIN

SELECT department_id
  INTO l_department_id
  FROM BOM_DEPARTMENTS bd
 WHERE bd.organization_id = p_organization_id
   AND department_code = p_department_code
   AND NVL (bd.disable_date, sysdate+2) > sysdate
   AND NOT EXISTS
   (
   SELECT '1'
     FROM WIP_OPERATION_RESOURCES wor
    WHERE wor.organization_id = p_organization_id
      AND wor.wip_entity_id = p_wip_entity_id
      AND wor.operation_seq_num = p_operation_seq_num
      AND wor.resource_id not in
      (
	SELECT bdr.resource_id
	FROM BOM_DEPARTMENT_RESOURCES bdr
	WHERE bdr.department_id = bd.department_id
      )
    );

  x_return_status := l_return_status;
  x_department_id := l_department_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_return_status := 1;
        x_return_status := l_return_status ;
	x_department_id := null;

END validate_dept;


    --------------------------------------------------------------------------
    -- Procedure to validate shutdown type
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------

procedure validate_shutdown_type (   p_meaning                   IN       VARCHAR2
				    ,x_lookup_code		 OUT NOCOPY      NUMBER
				    ,x_return_status	         OUT NOCOPY      NUMBER)  IS

	l_meaning	   VARCHAR2(80);
	l_lookup_code      NUMBER := 0;
	l_return_status    NUMBER := 0;

BEGIN

SELECT lookup_code
  INTO l_lookup_code
  FROM MFG_LOOKUPS
 WHERE lookup_type = g_shutdown_type
   AND meaning     = p_meaning ;

  x_return_status := l_return_status;
  x_lookup_code   := l_lookup_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_return_status := 1;
        x_return_status := l_return_status ;
	x_lookup_code   := null;

END validate_shutdown_type;



    --------------------------------------------------------------------------
    -- Procedure to validate standard operation
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------

procedure validate_std_operation (   p_organization_id		 IN       NUMBER
				    ,p_operation_code		 IN       VARCHAR2
				    ,x_standard_operation_id	 OUT NOCOPY      NUMBER
				    ,x_department_id		 OUT NOCOPY      NUMBER
				    ,x_shutdown_type             OUT NOCOPY      VARCHAR2
				    ,x_return_status	         OUT NOCOPY      NUMBER)  IS

	l_standard_operation_id  NUMBER := null;
	l_department_id		 NUMBER := null;
	l_shutdown_type		 VARCHAR2(10);
	l_return_status		 NUMBER := 0;

BEGIN

SELECT bdp.department_id, bso.standard_operation_id,
       bso.shutdown_type
  INTO l_department_id, l_standard_operation_id,
       l_shutdown_type
  FROM BOM_DEPARTMENTS bdp,
       BOM_STANDARD_OPERATIONS bso
 WHERE bso.organization_id = p_organization_id
   AND bso.operation_code = p_operation_code
   AND bso.line_id IS NULL
   AND NVL ( bso.operation_type, 1) = 1
   AND bdp.organization_id = p_organization_id
   AND bso.department_id = bdp.department_id
   AND NVL ( bdp.disable_date, sysdate + 2) > sysdate ;

   x_return_status	   := l_return_status;
   x_department_id	   := l_department_id;
   x_standard_operation_id := l_standard_operation_id;
   x_shutdown_type	   := l_shutdown_type;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_return_status		:= 1;
        x_return_status		:= l_return_status ;
	x_department_id         := null;
        x_standard_operation_id := null;
        x_shutdown_type	        := null;
END validate_std_operation;

    --------------------------------------------------------------------------
    -- Procedure to add an operation to a work order
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
procedure insert_into_wo (  p_wip_entity_id		 IN       NUMBER
                           ,p_operation_seq_num		 IN       NUMBER
                           ,p_standard_operation_id	 IN	  NUMBER
			   ,p_organization_id		 IN       NUMBER
                           ,p_description		 IN       VARCHAR2
                           ,p_department_id	         IN       NUMBER
                           ,p_shutdown_type		 IN       VARCHAR2
			   ,p_first_unit_start_date	 IN	  VARCHAR2
			   ,p_last_unit_completion_date  IN       VARCHAR2
			   ,p_duration			 IN       NUMBER
			   ,p_long_description           IN       VARCHAR2 := null
                           ,x_return_status	         OUT NOCOPY      NUMBER
			   ,x_msg_count                    OUT NOCOPY      NUMBER )  IS


     l_return_status              VARCHAR2(1);
     x_row_id			  VARCHAR2(250);
     l_first_unit_start_date      DATE := SYSDATE;
     l_last_unit_completion_date  DATE := SYSDATE;
     l_duration			  NUMBER := 0;



     /* Added for WO API */

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_output_dir  VARCHAR2(512);
    invalid_autochrg_exp      EXCEPTION;

    CURSOR chk_autocharge IS
	  SELECT 1
	  FROM  bom_standard_operations bso,
	        bom_std_op_resources bsor
	  WHERE bso.standard_operation_id = bsor.standard_operation_id
	  AND   bsor.standard_operation_id = p_standard_operation_id
	  AND   bso.organization_id = p_organization_id
	  AND   bsor.autocharge_type NOT IN (2,3);

  BEGIN
       -- Fix for Bug 3582756
       SAVEPOINT label_insert_into_wo;

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    IF (p_first_unit_start_date is NOT NULL AND p_last_unit_completion_date is NOT NULL) THEN
      l_first_unit_start_date		:= to_date(p_first_unit_start_date,'YYYY/MM/DD HH24:MI:SS'); --,WIP_CONSTANTS.DATETIME_FMT);
      l_last_unit_completion_date	:= to_date(p_last_unit_completion_date,'YYYY/MM/DD HH24:MI:SS'); --,WIP_CONSTANTS.DATETIME_FMT);
    ELSIF ( p_last_unit_completion_date is NULL) THEN
      l_duration			:= p_duration/24;
      l_first_unit_start_date	        := to_date(p_first_unit_start_date,'YYYY/MM/DD HH24:MI:SS'); --,WIP_CONSTANTS.DATETIME_FMT);
      l_last_unit_completion_date	:= l_first_unit_start_date + l_duration;
    ELSIF ( p_first_unit_start_date is NULL) THEN
      l_duration			:= p_duration/24;
      l_last_unit_completion_date       := to_date(p_last_unit_completion_date,'YYYY/MM/DD HH24:MI:SS'); --,WIP_CONSTANTS.DATETIME_FMT);
      l_first_unit_start_date		:= l_last_unit_completion_date + l_duration;
    END IF ; /* end if of duration check if */
        l_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
	l_eam_op_rec.wip_entity_id := p_wip_entity_id;
	l_eam_op_rec.organization_id := p_organization_id;
	l_eam_op_rec.operation_seq_num := p_operation_seq_num;
	l_eam_op_rec.description := p_description;
	l_eam_op_rec.long_description := p_long_description;
	l_eam_op_rec.shutdown_type := p_shutdown_type;
	l_eam_op_rec.start_date := l_first_unit_start_date;
	l_eam_op_rec.completion_date := l_last_unit_completion_date;
	if ( nvl(p_standard_operation_id,0)= 0 ) then -- added OR clause for bug#3541316
             l_eam_op_rec.standard_operation_id := null ;
        else  -- added else clause for bug#3518663
	    l_eam_op_rec.standard_operation_id := p_standard_operation_id;
	end if;
        l_eam_op_rec.department_id := p_department_id;

	l_eam_op_tbl(1) := l_eam_op_rec ;

	 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'insertwo.log'
  		         , p_output_dir              =>l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

	IF ( l_return_status = 'S' ) THEN
	     x_return_status := 0 ;
	     COMMIT;
	ELSE
	     x_return_status := 1 ;
	     ROLLBACK TO label_insert_into_wo;	-- Fix for 3582756
	END IF;

  EXCEPTION
    WHEN invalid_autochrg_exp THEN
	l_return_status := 3;
	x_return_status := l_return_status;
        ROLLBACK TO label_insert_into_wo;	-- Fix for 3823415
    WHEN DUP_VAL_ON_INDEX THEN
	l_return_status := 2;
	x_return_status := l_return_status;
        ROLLBACK TO label_insert_into_wo;	-- Fix for 3582756
    WHEN OTHERS THEN
       l_return_status := 1;
       x_return_status := l_return_status ;
       ROLLBACK TO label_insert_into_wo;	-- Fix for 3582756

  END insert_into_wo;
    --------------------------------------------------------------------------
    -- Procedure to update operations in wip_operations
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
procedure update_wo ( p_wip_entity_id		   IN       NUMBER
                     ,p_operation_seq_num	   IN       NUMBER
		     ,p_organization_id		   IN       NUMBER
                     ,p_description		   IN       VARCHAR2
                     ,p_shutdown_type		   IN       VARCHAR2
		     ,p_first_unit_start_date	   IN	    VARCHAR2
	             ,p_last_unit_completion_date  IN       VARCHAR2
		     ,p_duration		   IN       NUMBER
		     ,p_long_description           IN       VARCHAR2 := null
		     ,x_return_status              OUT NOCOPY      NUMBER
		     ,x_msg_count                  OUT NOCOPY      NUMBER )  IS

     l_return_status              VARCHAR2(1);
     l_first_unit_start_date      DATE := SYSDATE;
     l_last_unit_completion_date  DATE := SYSDATE;
     l_duration			  NUMBER := 0;


     -- baroy
     l_call_scheduler number := 0;


     /* Added for WO API */

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

  l_output_dir   VARCHAR2(512);
BEGIN
SAVEPOINT UPDATE_WO;

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    IF (p_first_unit_start_date is NOT NULL AND p_last_unit_completion_date is NOT NULL) THEN
      l_first_unit_start_date		:= to_date(p_first_unit_start_date,'YYYY/MM/DD HH24:MI:SS'); -- ,WIP_CONSTANTS.DATETIME_FMT);
      l_last_unit_completion_date	:= to_date(p_last_unit_completion_date,'YYYY/MM/DD HH24:MI:SS'); -- ,WIP_CONSTANTS.DATETIME_FMT);
    ELSIF ( p_last_unit_completion_date is NULL) THEN
      l_duration			:= p_duration/24;
      l_first_unit_start_date	        := to_date(p_first_unit_start_date,'YYYY/MM/DD HH24:MI:SS'); -- ,WIP_CONSTANTS.DATETIME_FMT);
      l_last_unit_completion_date	:= l_first_unit_start_date + l_duration;
    ELSIF ( p_first_unit_start_date is NULL) THEN
      l_duration			:= p_duration/24;
      l_last_unit_completion_date       := to_date(p_last_unit_completion_date,'YYYY/MM/DD HH24:MI:SS'); --,WIP_CONSTANTS.DATETIME_FMT);
      l_first_unit_start_date		:= l_last_unit_completion_date + l_duration;
    END IF ; /* end if of duration check if */

    l_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
	l_eam_op_rec.wip_entity_id := p_wip_entity_id;
	l_eam_op_rec.operation_seq_num := p_operation_seq_num;
	l_eam_op_rec.description := p_description;
	l_eam_op_rec.long_description := p_long_description;
	l_eam_op_rec.shutdown_type := p_shutdown_type;
	l_eam_op_rec.start_date := l_first_unit_start_date;
	l_eam_op_rec.completion_date := l_last_unit_completion_date;
	l_eam_op_rec.organization_id := p_organization_id;

	l_eam_op_tbl(1) := l_eam_op_rec ;


	 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
		 	 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'updatewo.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

	IF ( l_return_status = 'S' ) THEN
           x_return_status := 0 ;
	   COMMIT;  -- Fix for Bug 3521871
	ELSE
	   ROLLBACK TO UPDATE_WO;
	   x_return_status := 1 ;
	END IF;

EXCEPTION

WHEN OTHERS THEN
    ROLLBACK TO UPDATE_WO;
    l_return_status := 4;
    x_return_status := l_return_status;

END update_wo;

-- ------------------------------------------------------------------------
-- Validation API for new link between operaions in
-- Dependency definitions
-- ------------------------------------------------------------------------

Procedure validate_new_link(p_from_operation IN NUMBER,
                             p_to_operation     IN NUMBER,
                             p_dep_direction    IN NUMBER,
                             p_wip_entity_id    IN NUMBER,
							 p_sche_start_date  IN DATE,
							 p_sche_end_date    IN DATE,
                             x_error_flag     OUT NOCOPY VARCHAR2,
                             x_error_mssg  OUT NOCOPY VARCHAR2
							 ) IS
l_to_scheduled_start_date       DATE;
l_to_scheduled_end_date        DATE;
l_to_operation_completed        VARCHAR2(1);
l_from_scheduled_start_date   DATE;
l_from_scheduled_end_date    DATE;
l_from_operation_completed        VARCHAR2(1);
l_op_already_available            NUMBER;
l_loop_available NUMBER :=0 ;
l_available_value NUMBER := 0;
l_restrict_date_change NUMBER := 0;
Begin

l_op_already_available := 0;
x_error_flag := FND_API.G_RET_STS_SUCCESS;
x_error_mssg := '';


--check for the availability of all the values
if(p_dep_direction is null or p_from_operation is null or
   p_to_operation is null or p_sche_start_date is null or
   p_sche_end_date is null) then
 x_error_flag := FND_API.G_RET_STS_ERROR;
 x_error_mssg := 'EAM_NOT_ENOUGH_VALUES';
 return;
end if;

-- check for from and to operation
if(p_from_operation = p_to_operation) then
 x_error_flag := FND_API.G_RET_STS_ERROR;
 x_error_mssg := 'EAM_FROM_TO_OPERATION_EQUAL';
 return;
end if;

if(p_sche_end_date < p_sche_start_date) then
 x_error_flag := FND_API.G_RET_STS_ERROR;
 x_error_mssg := 'EAM_START_LESS_END_DATE';
 return;
end if;

-- initialize scheduled dates of from and to operations .
Begin
select
first_unit_start_date ,
last_unit_completion_date,
operation_completed
into
l_from_scheduled_start_date,
l_from_scheduled_end_date,
l_from_operation_completed
from
wip_operations
where
wip_entity_id = p_wip_entity_id and
operation_seq_num = p_from_operation ;
Exception
when NO_DATA_FOUND then
 x_error_flag := FND_API.G_RET_STS_ERROR;
 x_error_mssg := 'EAM_FROM_OPERATION_NOT_FOUND';
 return;
End; -- end of

Begin
select
first_unit_start_date ,
last_unit_completion_date,
operation_completed
into
l_to_scheduled_start_date,
l_to_scheduled_end_date,
l_to_operation_completed
from
wip_operations
where
wip_entity_id = p_wip_entity_id and
operation_seq_num = p_to_operation ;
Exception
when NO_DATA_FOUND then
 x_error_flag := FND_API.G_RET_STS_ERROR;
 x_error_mssg := 'EAM_TO_OPERATION_NOT_FOUND';
 return;
End; -- end of

-- check for the scheduled atart/end date updation
if(p_dep_direction = 1) then
  if(p_sche_start_date <> l_from_scheduled_start_date or
	 p_sche_end_date <> l_from_scheduled_end_date) then

    -- check Prior/Next Operation conflict with the modified Start and End Date .
	select
    count(*) into l_restrict_date_change
    from
    dual
    where
    exists
    (select '1' from eam_prior_operations_v
     where next_operation = p_from_operation
     and schedule_end_date > p_sche_start_date
	 and wip_entity_id  = p_wip_entity_id);

     if(l_restrict_date_change = 0) then
	 select count(*) into l_restrict_date_change
     from dual
	 where
	 exists
	 (select '1' from eam_next_operations_v
	  where prior_operation =  p_from_operation
	  and schedule_start_date < p_sche_end_date
	  and wip_entity_id  = p_wip_entity_id);
	  end if;


	if(l_restrict_date_change > 0) then
	  x_error_flag := FND_API.G_RET_STS_ERROR;
	  x_error_mssg := 'EAM_SCHEDULED_DATE_CHANGE';
     return;
    elsif(l_restrict_date_change = 0) then
	  update wip_operations
	  set
	  first_unit_start_date = p_sche_start_date,
	  last_unit_start_date = p_sche_start_date,
	  first_unit_completion_date = p_sche_end_date,
	  last_unit_completion_date  = p_sche_end_date
	  where
	  wip_entity_id = p_wip_entity_id and
	  operation_seq_num = p_from_operation ;
	  l_from_scheduled_start_date := p_sche_start_date ;
	  l_from_scheduled_end_date   := p_sche_end_date;
    end if;
   end if; -- end of date check
elsif(p_dep_direction = 2) then
  if(p_sche_start_date <> l_to_scheduled_start_date or
	 p_sche_end_date <> l_to_scheduled_end_date) then

    -- check Prior/Next Operation conflict with the modified Start and End Date .
	select
    count(*) into l_restrict_date_change
    from
    dual
    where
    exists
    (select '1' from eam_prior_operations_v
     where next_operation = p_to_operation
     and schedule_end_date > p_sche_start_date
	 and wip_entity_id  = p_wip_entity_id);

     if(l_restrict_date_change = 0) then
	 select count(*) into l_restrict_date_change
	 from dual
	 where
	 exists
	 (select '1' from eam_next_operations_v
	  where prior_operation =  p_to_operation
	  and schedule_start_date < p_sche_start_date
	  and wip_entity_id  = p_wip_entity_id);
	  end if;

	if(l_restrict_date_change > 0) then
     x_error_flag := FND_API.G_RET_STS_ERROR;
     x_error_mssg := 'EAM_SCHEDULED_DATE_CHANGE';
     return;
    elsif(l_restrict_date_change = 0) then
	  update wip_operations
	  set
	  first_unit_start_date = p_sche_start_date,
	  last_unit_start_date = p_sche_start_date,
	  first_unit_completion_date = p_sche_end_date,
	  last_unit_completion_date  = p_sche_end_date
	  where
	  wip_entity_id = p_wip_entity_id and
	  operation_seq_num = p_to_operation ;
       l_to_scheduled_start_date := p_sche_start_date ;
	   l_to_scheduled_end_date   := p_sche_end_date;
    end if;
  end if; --  end of date check
end if;-- end of dep_direction check if


-- check for the scheduled completion and start date of from and to operation respectively
if (l_to_scheduled_start_date < l_from_scheduled_end_date ) then
  x_error_flag := FND_API.G_RET_STS_ERROR;
  x_error_mssg :=  'EAM_DEP_OP_START_DATE_INVALID';
  return;
end if;

-- check for loop in the dependency network
select count(1) into l_loop_available
from dual
where
p_from_operation in (select next_operation
                                from (select * from wip_operation_networks
                                         where next_operation <> p_to_operation and
                                          wip_entity_id = p_wip_entity_id)
                                start with prior_operation = p_to_operation
                                connect by prior_operation = prior next_operation) ;

if(l_loop_available <> 0) then
  x_error_flag := FND_API.G_RET_STS_ERROR;
  x_error_mssg := 'EAM_OPMDF_OP_DEP_LOOP';
end if;

End validate_new_link;


  Procedure create_new_link(              p_from_operation IN NUMBER,
                                          p_to_operation     IN NUMBER,
                                          p_dep_direction    IN NUMBER,
                                          p_wip_entity_id    IN NUMBER,
                                          p_organization_id  IN NUMBER,
                                          p_user_id            IN NUMBER,
										  p_sche_start_date   IN DATE,
										  p_sche_end_date     IN DATE,
                                          x_error_flag     OUT NOCOPY VARCHAR2,
                                          x_error_mssg  OUT NOCOPY VARCHAR2 ) IS

/* Added for implementing the WO API */

     l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
     l_eam_op_network_rec EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
     l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
     l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
     l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
     l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
     l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
     l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
     l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
     l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
     l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
     l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
     l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
     l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
     l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
     l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
     l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
     l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
   l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
   l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
   l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
   l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
   l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
   l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
   l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

l_mssg_token_tbl_type EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_return_status VARCHAR2(240);
l_data VARCHAR2(2000);
l_mssg_index_out NUMBER;
l_mssg_index NUMBER;
l_mssg_data VARCHAR2(250);
l_msg_count NUMBER := 0;
l_output_dir  VARCHAR2(512);
Begin

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


x_error_flag := FND_API.G_RET_STS_SUCCESS;
x_error_mssg := '';

-- validate  the link
validate_new_link(
                         p_from_operation,
                         p_to_operation     ,
                         p_dep_direction    ,
                         p_wip_entity_id    ,
						 p_sche_start_date,
						 p_sche_end_date,
                         x_error_flag     ,
                         x_error_mssg  ) ;

if(x_error_flag <> FND_API.G_RET_STS_SUCCESS) then
 FND_MSG_PUB.Initialize;
 eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => x_error_mssg);
 eam_execution_jsp.Get_Messages(
          p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => 1,
	  p_msg_data => l_mssg_data,
          p_data      => l_data,
          p_msg_index_out => l_mssg_index_out);
-- fnd_message.set_name('EAM',x_error_mssg);
 x_error_mssg := l_data;
 return;
end if;

SAVEPOINT add_op_network;

-- initializing the structure of dependency network
l_eam_op_network_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
l_eam_op_network_rec.wip_entity_id := p_wip_entity_id;
l_eam_op_network_rec.organization_id := p_organization_id;
l_eam_op_network_rec.prior_operation := p_from_operation;
l_eam_op_network_rec.next_operation :=  p_to_operation;

l_eam_op_network_tbl(1) := l_eam_op_network_rec ;

   EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_error_flag
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'createopdep.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

             IF(x_error_flag <> 'S') THEN
	         ROLLBACK TO add_op_network;
	     END IF;

End create_new_link;


PROCEDURE delete_link(p_from_operation IN NUMBER,
                                          p_to_operation     IN NUMBER,
                                          p_dep_direction    IN NUMBER,
                                          p_wip_entity_id    IN NUMBER,
                                          p_organization_id  IN NUMBER,
                                          p_user_id            IN NUMBER,
                                          x_error_flag     OUT NOCOPY VARCHAR2,
                                          x_error_mssg  OUT NOCOPY VARCHAR2 ) IS

    /* Added for implementing WO API */
     l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
     l_eam_op_network_rec EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
     l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
     l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
     l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
     l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
     l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
     l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
     l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
     l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
     l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
     l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
     l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
     l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
     l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
     l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
     l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
     l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
   l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
   l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
   l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
   l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
   l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
   l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
   l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

l_mssg_token_tbl_type EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_return_status VARCHAR2(240);
l_data VARCHAR2(2000);
l_mssg_index_out NUMBER;
l_mssg_data VARCHAR2(250);
l_msg_count NUMBER := 0;
l_output_dir VARCHAR2(512);
Begin

 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


x_error_flag := FND_API.G_RET_STS_SUCCESS;
x_error_mssg := '';

-- initializing the structure of dependency network
l_eam_op_network_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_DELETE;
l_eam_op_network_rec.wip_entity_id := p_wip_entity_id;
l_eam_op_network_rec.organization_id := p_organization_id;
l_eam_op_network_rec.prior_operation := p_from_operation;
l_eam_op_network_rec.next_operation :=  p_to_operation;

l_eam_op_network_tbl(1) := l_eam_op_network_rec ;

SAVEPOINT delete_op_network;

     EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_error_flag
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delopdep.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

      IF(x_error_flag='S') THEN
        COMMIT;
      END IF;

      IF(x_error_flag <> 'S') THEN
          ROLLBACK TO delete_op_network;
      END IF;

End delete_link;



procedure schedule_workorders ( p_organization_id  IN NUMBER,
                                p_wip_entity_id    IN NUMBER
                              ) IS

  l_organization_id  NUMBER;
  l_wip_entity_id   NUMBER;
  l_status_type  NUMBER;
  l_use_finite_scheduler  NUMBER;
  l_material_constrained  NUMBER;
  l_horizon_length  NUMBER;
  l_firm  NUMBER;
  l_date                  VARCHAR2(100);
  l_user_id  NUMBER;
  l_responsibility_id  NUMBER;
  l_request_id  NUMBER;
  l_final_status NUMBER;
  l_start_date DATE;
  l_completion_date DATE;
  l_err_text  VARCHAR2(240) ;
  l_return_status VARCHAR2(30) := 'S';
  l_first_unit_start_date      DATE := SYSDATE;
  l_last_unit_completion_date  DATE := SYSDATE;

begin

  l_organization_id := p_organization_id;
  l_wip_entity_id := p_wip_entity_id;

  select status_type , nvl(firm_planned_flag,2), scheduled_start_date,
    scheduled_completion_date
  into l_status_type, l_firm, l_start_date, l_completion_date
  from wip_discrete_jobs
  where wip_entity_id = l_wip_entity_id
    and organization_id = l_organization_id;

  -- Get WPS Parameters

  IF(WPS_COMMON.Get_Install_Status = 'I') THEN
                     WPS_COMMON.GetParameters(
                     P_Org_Id               => l_organization_id,
                     X_Use_Finite_Scheduler => l_use_finite_scheduler,
                     X_Material_Constrained => l_material_constrained,
                     X_Horizon_Length       => l_horizon_length);
  ELSE
                     l_use_finite_scheduler := 2;
                     l_material_constrained := 2;
                     l_horizon_length := 0;
  END IF;


  IF (l_status_type in (1,3,6,17) ) then

    -- baroy
    -- Finite scheduler has been decommisioned for 11.5.10
    -- Hence commenting out this code. Also, hardcode the value
    -- of the l_use_finite_scheduler flag

    l_use_finite_scheduler := 2;

    if ((l_status_type = 3) and (l_use_finite_scheduler = 1) and (l_firm = 2) ) then

      null;

    else
          SAVEPOINT schedule_wo_pvt;

      EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                  (  p_organization_id               => l_organization_id
                  ,  p_wip_entity_id                 =>  l_wip_entity_id
                  ,  p_start_date                    =>  l_start_date
                  ,  p_completion_date               => l_completion_date
                  ,  p_validation_level              =>  null
                  ,  p_commit                        =>  'N'
                  ,  x_error_message                 =>  l_err_text
                  ,  x_return_status                 =>  l_return_status
            );
             IF(l_err_text <> 'S') THEN
	          ROLLBACK TO schedule_wo_pvt;
              END IF;

    end if;

  END IF;

END schedule_workorders;

/*-------------------------------------------------------------------------
-- API for geting the operation_seq_num and the department_code
-- for the wip_entity_id.Added for the bug 2762202
-------------------------------------------------------------------------*/
PROCEDURE count_op_seq_num(p_organization_id  IN NUMBER,
                           p_wip_entity_id    IN NUMBER,
                           op_seq_num        OUT NOCOPY   NUMBER,
			   op_dept_code      OUT NOCOPY   VARCHAR2,
		           op_count          OUT NOCOPY   NUMBER,
                           l_return_status   OUT NOCOPY   VARCHAR2,
                           l_msg_data        OUT NOCOPY   VARCHAR2,
                           l_msg_count       OUT NOCOPY   NUMBER)
                           IS
 l_op_count       NUMBER;
 l_op_dept_code   VARCHAR2(240);
 l_op_seq_num     NUMBER;
BEGIN

  SELECT count(operation_seq_num)
    INTO  l_op_count
    FROM  wip_operations
   WHERE wip_entity_id = p_wip_entity_id and
         organization_id = p_organization_id;
   op_count := l_op_count;

   if (l_op_count = 1 ) then
      SELECT wo.operation_seq_num, bd.department_code
        INTO  op_seq_num, op_dept_code
        FROM  wip_operations wo, bom_departments bd
       WHERE  wo.wip_entity_id = p_wip_entity_id and
              wo.organization_id = p_organization_id and
              wo.organization_id = bd.organization_id and
              wo.department_id = bd.department_id;
   end if;

END count_op_seq_num;
/*-------------------------------------------------------------------------
-- API for geting the operation_seq_num,the department_code and start/end dates
-- for a given wip entity id. Added for bug#3544893
-------------------------------------------------------------------------*/
PROCEDURE default_operation (p_organization_id    IN NUMBER,
                             p_wip_entity_id      IN NUMBER,
                             x_op_seq_num         OUT NOCOPY   NUMBER,
			     x_op_dept_code	  OUT NOCOPY   VARCHAR2,
		             x_op_count           OUT NOCOPY   NUMBER,
			     x_op_start_date      OUT NOCOPY DATE,
			     x_op_end_date        OUT NOCOPY DATE,
                             x_return_status      OUT NOCOPY   VARCHAR2,
                             x_msg_data           OUT NOCOPY   VARCHAR2,
                             x_msg_count          OUT NOCOPY   NUMBER)
                           IS
 l_op_count       NUMBER;
 l_op_dept_code   VARCHAR2(240);
 l_op_seq_num     NUMBER;
 l_op_start_date   DATE;
 l_op_end_date     DATE;
BEGIN

  SELECT count(operation_seq_num)
    INTO  l_op_count
    FROM  wip_operations
   WHERE wip_entity_id = p_wip_entity_id and
         organization_id = p_organization_id;
   x_op_count := l_op_count;

   if (l_op_count = 1 ) then
      SELECT wo.operation_seq_num, wo.first_unit_start_date, wo.last_unit_completion_date, bd.department_code
        INTO  x_op_seq_num, x_op_start_date, x_op_end_date, x_op_dept_code
        FROM  wip_operations wo, bom_departments bd
        WHERE  wo.wip_entity_id = p_wip_entity_id and
               wo.organization_id = p_organization_id and
               wo.organization_id = bd.organization_id and
               wo.department_id = bd.department_id;
   end if;

END default_operation;


/* ------------------------------------------------------------------------
   API for checking whether the resources associated with a work order and
   an operation are available in the department chosen.
 --------------------------------------------------------------------------*/
  procedure handover_department_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_seq_num		  IN NUMBER,
    p_department                  IN VARCHAR2,
    p_organization_id		  IN NUMBER,
    p_resource_code               IN VARCHAR2,
    x_return_status               OUT NOCOPY NUMBER
  ) IS

    l_count			  NUMBER;
    l_department_id                NUMBER;
    l_resource_id                 NUMBER;

    BEGIN
     x_return_status := 0;
     l_resource_id   := 0;

    SELECT department_id
    INTO l_department_id
    FROM bom_departments
    WHERE department_code like p_department
    AND organization_id = p_organization_id;

    -- get resources  available in the assigned department
     IF(p_resource_code IS NOT NULL) THEN
      SELECT bdr.resource_id
      INTO l_resource_id
      FROM bom_department_resources bdr , bom_resources br
      WHERE bdr.department_id = l_department_id
      AND bdr.resource_id = br.resource_id
      AND br.resource_code like p_resource_code
      AND br.organization_id = p_organization_id;

      IF (l_resource_id=0) THEN
       x_return_status := 0;
      END IF;
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        x_return_status := 1;
	return ;

   END handover_department_validate;

  /* API to check if operation can be deleted from self service side */

   procedure check_op_deletion
  ( p_wip_entity_id               IN NUMBER,
    p_operation_seq_num		  IN NUMBER,
    x_return_status               OUT NOCOPY NUMBER
  ) IS
    l_wip_entity_id		  NUMBER;
    l_operation_seq_num           NUMBER;
    l_count_routing               NUMBER;
    l_count_mat                   NUMBER;
    l_count_di                    NUMBER;
    l_count_res                   NUMBER;
    l_completed 	          varchar2(10);

    BEGIN
      -- Check whether there are material requirements or resource requirements
      -- or operation has been completed

     l_wip_entity_id := p_wip_entity_id;
     l_operation_seq_num := p_operation_seq_num;

    select count(*)
      into l_count_routing
      from wip_operation_networks
    where wip_entity_id = l_wip_entity_id and ( prior_operation  = p_operation_seq_num or next_operation   = p_operation_seq_num);

     select count(*)
       into l_count_mat
       from wip_requirement_operations
     where wip_entity_id = l_wip_entity_id
        and operation_seq_num = l_operation_seq_num;

    select count(*)
       into l_count_di
     from wip_eam_direct_items
    where wip_entity_id = l_wip_entity_id
    and operation_seq_num         = l_operation_seq_num
    and rownum =1;

    select count(*)
      into l_count_res
     from wip_operation_resources
    where wip_entity_id = l_wip_entity_id
    and operation_seq_num = l_operation_seq_num;

    begin
     select operation_completed
     into l_completed
      from wip_operations
     where wip_entity_id = l_wip_entity_id
       and operation_seq_num = l_operation_seq_num;
    exception
     when others then
       null;
    end;

   if l_count_routing >0 or l_count_mat > 0 or l_count_res > 0 or l_count_di > 0 or nvl(l_completed, 'N') = 'Y' then
    x_return_status := 1;
    else
     x_return_status := 0;
  end if;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        x_return_status := 1;
	return ;
   END check_op_deletion;


  /* API to delete operation from self service side */

    procedure delete_operation (
      p_api_version                  IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_organization_id             IN    NUMBER
      ,p_wip_entity_id   	     IN	   NUMBER
      ,p_operation_seq_num	     IN	   NUMBER
      ,p_department_id  	     IN	   NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     ) is

	l_api_name constant varchar2(30) := 'Delete_Operations';
	l_api_version  CONSTANT NUMBER   := 1.0;
	l_msg_data VARCHAR2(10000) ;
	l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                 NUMBER;
	l_message_text               VARCHAR2(1000);

        l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
        l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_output_dir  VARCHAR2(512);
	begin

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


	       SAVEPOINT DELETE_OPERATION_JSP;


	 IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
					       p_api_version,
					       l_api_name,
					       g_pkg_name)
	 THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

        IF FND_API.TO_BOOLEAN(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;


       l_eam_op_rec.WIP_ENTITY_ID             :=p_wip_entity_id;
       l_eam_op_rec.ORGANIZATION_ID           :=p_organization_id;
       l_eam_op_rec.OPERATION_SEQ_NUM         :=p_operation_seq_num;
       l_eam_op_rec.DEPARTMENT_ID             :=p_department_id;
       l_eam_op_rec.TRANSACTION_TYPE          :=EAM_PROCESS_WO_PUB.G_OPR_DELETE;

       l_eam_op_tbl(1) := l_eam_op_rec;

          EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delop.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

	l_msg_count := FND_MSG_PUB.count_msg;
	x_return_status := l_return_status;
	x_msg_count := l_msg_count;

    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	          ROLLBACK TO DELETE_OPERATION_JSP;
        fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => l_message_text,
                    p_msg_index_out => l_msg_count);
           fnd_message.set_name('EAM','EAM_ERROR_UPDATE_WO');

           fnd_message.set_token(token => 'MESG',
             value => l_message_text,
             translate => FALSE);
             APP_EXCEPTION.RAISE_EXCEPTION;

		x_msg_data := 'Error ';
      END IF;

      IF p_commit = FND_API.G_TRUE THEN
         COMMIT WORK;
     end if;
    EXCEPTION

         when others then
		  ROLLBACK TO DELETE_OPERATION_JSP;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            return;


end delete_operation;

/*---------------------------------------------------------------------------
   API for updating/deleting material used in one step issue page
  -----------------------------------------------------------------------------*/

 PROCEDURE update_wro
            (
	       p_commit            IN  VARCHAR2 := FND_API.G_FALSE
	      ,p_organization_id             IN    NUMBER
	      ,p_wip_entity_id   	     IN	   NUMBER
	      ,p_operation_seq_num	     IN	   NUMBER
	      ,p_inventory_item_id          IN    NUMBER
	      ,p_update                     IN  NUMBER
	      ,p_required_qty               IN  NUMBER
	      ,x_return_status               OUT NOCOPY   VARCHAR2
	      ,x_msg_count                   OUT NOCOPY   NUMBER
	      ,x_msg_data                    OUT NOCOPY   VARCHAR2
	      )
 IS
                 l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
		l_eam_mat_req_rec   EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
		l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		l_output_dir  VARCHAR2(512);
 BEGIN
     SAVEPOINT update_wro;

    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


     IF(p_update=1) THEN                  --update wro
		l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := p_inventory_item_id;
		l_eam_mat_req_rec.required_quantity := p_required_qty;

    		l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => FALSE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl         =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'onestepwro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
     ELSE        --delete from wro
                l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := p_inventory_item_id;

    		l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

		 EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => FALSE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
		 	 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl         =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'onestepwro.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
     END IF;

		 IF(x_return_status <>'S') THEN
		      ROLLBACK TO update_wro;
		 END IF;

                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
		       and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;


   EXCEPTION
	   WHEN OTHERS THEN
	      ROLLBACK TO update_wro;
	      x_return_status := fnd_api.g_ret_sts_unexp_error;

 END update_wro;

   PROCEDURE delete_instance (
            p_api_version        IN       NUMBER
  	   ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  	   ,p_commit             IN       VARCHAR2 := fnd_api.g_false
           ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
           ,p_wip_entity_id      IN       NUMBER
           ,p_organization_id      IN       NUMBER
           ,p_operation_seq_num  IN       NUMBER
           ,p_resource_seq_num   IN       NUMBER
           ,p_instance_id	   IN       NUMBER
           ,x_return_status      OUT NOCOPY      VARCHAR2
           ,x_msg_count          OUT NOCOPY      NUMBER
           ,x_msg_data           OUT NOCOPY      VARCHAR2)  IS


         l_api_name       CONSTANT VARCHAR2(30) := 'delete_instance';
  	 l_api_version    CONSTANT NUMBER       := 1.0;
  	 l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  	   l_stmt_num       NUMBER;
           l_msg_count                NUMBER;
           l_msg_data                 VARCHAR2(250);
           l_data                     VARCHAR2(250);
    	  l_msg_index_out            NUMBER;


	   /* added for calling WO API */

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_res_inst_rec  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_output_dir   VARCHAR2(512);

   BEGIN
                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT delete_instance_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;

                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
    -- API body

	 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);



        l_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
        l_eam_res_inst_rec.wip_entity_id :=  p_wip_entity_id;
        l_eam_res_inst_rec.organization_id := p_organization_id;
	l_eam_res_inst_rec.operation_seq_num :=  p_operation_seq_num;
	l_eam_res_inst_rec.resource_seq_num :=  p_resource_seq_num;
	l_eam_res_inst_rec.instance_id := p_instance_id;

	l_eam_res_inst_tbl(1) := l_eam_res_inst_rec ;

                    EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
			 , p_eam_request_tbl        =>	l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl      =>	l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delwor.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );


    -- End of API body.
                     -- Standard check of p_commit.
                     IF fnd_api.to_boolean(p_commit)
		          and x_return_status = 'S' THEN
                        COMMIT WORK;
                     END IF;

		     IF(x_return_status <> 'S') THEN
		         ROLLBACK TO delete_instance_pvt;
		     END IF;

                     l_stmt_num    := 999;

                     -- Standard call to get message count and if count is 1, get message info.
                     fnd_msg_pub.count_and_get(
                        p_count => x_msg_count
                       ,p_data => x_msg_data);

                  EXCEPTION
                     WHEN fnd_api.g_exc_error THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_msg_pub.count_and_get(
               --            p_encoded => FND_API.g_false
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

                     WHEN fnd_api.g_exc_unexpected_error THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_unexp_error;

                        fnd_msg_pub.count_and_get(
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

                     WHEN OTHERS THEN
                        ROLLBACK TO get_delete_resources_pvt;
                        x_return_status := fnd_api.g_ret_sts_unexp_error;
                        IF fnd_msg_pub.check_msg_level(
                              fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                        END IF;

                        fnd_msg_pub.count_and_get(
                           p_count => x_msg_count
                          ,p_data => x_msg_data);

      END delete_instance;

end eam_operations_jsp;

/
