--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDERS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDERS_JSP" AS
/* $Header: EAMJOBJB.pls 120.15.12010000.2 2009/08/21 06:36:43 vchidura ship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_WORKORDERS_JSP';
g_debug_sqlerrm VARCHAR2(250);

---------------------------------------------------------------------
--procedure to add existing work orders
------------------------------------------------------

procedure add_exist_work_order(
       p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_record_version_number       IN    NUMBER        := NULL
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN    NUMBER
      ,p_wip_entity_id   IN    NUMBER
      ,p_firm_flag    IN  NUMBER
      ,p_parent_wip_id   IN  NUMBER
      , p_relation_type  IN NUMBER

)
IS
   l_api_name           CONSTANT VARCHAR(30) := 'add_exist_work_order';
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

     l_workorder_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec1 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec2 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec3 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl1  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl2  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl1  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl2  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl1  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl2  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl1  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl2  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl1   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl2   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl1  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl2  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl1   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl2   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_wip_entity_id            NUMBER;
      --Bug3592712: Max length of workorder name is 240 char.
      l_wip_entity_name          VARCHAR2(240);

      l_eam_item_type   NUMBER;
      l_status_type  NUMBER;

      l_wip_entity_updt  NUMBER;

      l_mode NUMBER;  -- 0 for Create and 1 for Update
      l_date_released  DATE;
      l_user_id NUMBER;
      l_responsibility_id NUMBER;
      l_firm   NUMBER;
      l_serial_number_control  NUMBER := 0;
      l_work_name VARCHAR2(240);
      l_parent_work_order_count number:=0;
      l_adjust_parent varchar2(10);
      l_row_count number :=0;

  	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_rec      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec1      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;

	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl3               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;

	l_eam_msg_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_old_rebuild_source  NUMBER;
	l_message_text  varchar2(20);

	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_output_dir  VARCHAR2(512);

	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

BEGIN

     SAVEPOINT add_exist_work_order;

      eam_debug.init_err_stack('eam_workorders_jsp.add_exist_work_order');

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

 /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

      x_return_status := FND_API.G_RET_STS_SUCCESS;


          l_workorder_rec.header_id  := p_wip_entity_id;
          l_workorder_rec.batch_id   := 1;
          l_workorder_rec.return_status := null;

          l_workorder_rec.wip_entity_id :=  p_wip_entity_id;
          l_workorder_rec.organization_id := p_organization_id;



           l_workorder_rec.firm_planned_flag := p_firm_flag;
           l_workorder_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

              -- Set user id and responsibility id so that we can set apps context
              -- before calling any concurrent program
              l_workorder_rec.user_id := l_user_id;
              l_workorder_rec.responsibility_id := l_responsibility_id;


if(p_relation_type=1) then
         l_eam_wo_tbl(1) := l_workorder_rec;
end if;

	l_eam_wo_relations_rec.batch_id  :=  1;
	l_eam_wo_relations_rec.parent_object_id := p_parent_wip_id;
	l_eam_wo_relations_rec.parent_object_type_id := 1;
	l_eam_wo_relations_rec.parent_header_id := p_parent_wip_id;
	l_eam_wo_relations_rec.child_object_type_id := 1;
	l_eam_wo_relations_rec.child_header_id    :=p_wip_entity_id;
	l_eam_wo_relations_rec.child_object_id    :=p_wip_entity_id;
	l_eam_wo_relations_rec.parent_relationship_type  := p_relation_type ;
	l_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

       l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;

       EAM_PROCESS_WO_PUB.l_eam_wo_list.delete; --Added for bug#4563210

         EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
  	         , x_return_status           => x_return_status
  	         , x_msg_count               => x_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'addexistwo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'w'
           );


/*End of update wo ***********/

   if(x_return_status<>'S') then
       ROLLBACK TO add_exist_work_order;
       RAISE  FND_API.G_EXC_ERROR;
    end if;


 EXCEPTION
    WHEN
	FND_API.G_EXC_UNEXPECTED_ERROR  THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO add_exist_work_order;
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.ADD_EXIST_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO add_exist_work_order;
        END IF;

        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.ADD_EXIST_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN -- all dml excpetion
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO add_exist_work_order;
        END IF;

        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.ADD_EXIST_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);


END add_exist_work_order;


procedure validate_cancel(p_wip_entity_id NUMBER)
IS

network_child_job_var varchar2(2):='0';
dependent_rel  varchar2(2):='0';
 wo_released NUMBER;
BEGIN

begin
       begin
	SELECT '1'
	   INTO network_child_job_var
	   FROM dual
	WHERE EXISTS (SELECT '1'
			   FROM wip_discrete_jobs
			 WHERE wip_entity_id IN
			 (
			  SELECT DISTINCT  child_object_id
				FROM eam_wo_relationships
			  WHERE parent_relationship_type =1
				START WITH parent_object_id =    p_wip_entity_id AND parent_relationship_type = 1
				CONNECT BY  parent_object_id  = prior child_object_id   AND parent_relationship_type = 1
			 )
		       AND status_type NOT IN (7)
                     );
      exception
            when NO_DATA_FOUND then
             null;
      end;


      if (network_child_job_var = '1') then  --In the network Work Order is there are child work orders not in cancelled state

            fnd_message.set_name('EAM','EAM_WO_CANCEL_ERR');

            APP_EXCEPTION.RAISE_EXCEPTION;
      else
         begin
          SELECT decode(wdj.status_type,3,1,0)
          INTO wo_released
          FROM WIP_DISCRETE_JOBS wdj
          WHERE wdj.wip_entity_id=p_wip_entity_id;

          SELECT '1'
          INTO dependent_rel
          FROM DUAL
          WHERE EXISTS (SELECT ewr.child_object_id
                        FROM EAM_WO_RELATIONSHIPS ewr,WIP_DISCRETE_JOBS wdj
                        WHERE ewr.parent_object_id=p_wip_entity_id  AND ewr.parent_relationship_type = 2
                        AND wdj.wip_entity_id=ewr.child_object_id AND (wo_released=1 OR wdj.status_type=3)
                        UNION
                        SELECT ewr.parent_object_id
                        FROM EAM_WO_RELATIONSHIPS ewr,WIP_DISCRETE_JOBS wdj
                        WHERE ewr.child_object_id=p_wip_entity_id  AND ewr.parent_relationship_type = 2
                        AND wdj.wip_entity_id=ewr.parent_object_id AND (wo_released=1 OR wdj.status_type=3)
                        );
      exception
 	 when NO_DATA_FOUND then
 		 null;
      end;

          if(dependent_rel='1') then
              fnd_message.set_name('EAM','EAM_WO_CANCEL_DEPENDENCY_ERR');

              APP_EXCEPTION.RAISE_EXCEPTION;
          end if;

       end if;
     exception
      WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
     end;
END validate_cancel;


-------------------------------------------------------------------------
-- a wrapper procedure to the eam_completion.complete_work_order,
-- also check the return status add message to the message list
-- so jsp pages can get them.
-------------------------------------------------------------------------
  procedure Complete_Workorder
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_actual_start_date           IN    DATE
    ,p_actual_end_date             IN    DATE
    ,p_actual_duration             IN    NUMBER
    ,p_transaction_date            IN    DATE
    ,p_transaction_type            IN    NUMBER
    ,p_shutdown_start_date         IN    DATE
    ,p_shutdown_end_date           IN    DATE
    ,p_reconciliation_code         IN    VARCHAR2
    ,p_stored_last_update_date            IN    DATE  -- old update date, for locking only
    ,p_rebuild_jobs                IN    VARCHAR2     := NULL -- holds 'Y' or 'N'
    ,p_subinventory                IN    VARCHAR2     := NULL
	,p_subinv_ctrl                 IN    NUMBER       := NULL
	,p_org_id                      IN    NUMBER       := NULL
	,p_item_id                     IN    NUMBER       := NULL
    ,p_locator_id                  IN    NUMBER       := NULL
	,p_locator_ctrl                IN    NUMBER       := NULL
	,p_locator                     IN    VARCHAR2     := NULL
    ,p_lot                         IN    VARCHAR2     := NULL
    ,p_serial                      IN    VARCHAR2     := NULL
	,p_manual_flag                 IN    VARCHAR2     := NULL
	,p_serial_status               IN    VARCHAR2     := NULL
    ,p_qa_collection_id            IN   NUMBER
    ,p_attribute_category  IN VARCHAR2 := null
    ,p_attribute1          IN VARCHAR2 := null
    ,p_attribute2          IN VARCHAR2 := null
	,p_attribute3          IN VARCHAR2 := null
    ,p_attribute4          IN VARCHAR2 := null
    ,p_attribute5          IN VARCHAR2 := null
    ,p_attribute6          IN VARCHAR2 := null
    ,p_attribute7          IN VARCHAR2 := null
    ,p_attribute8          IN VARCHAR2 := null
    ,p_attribute9          IN VARCHAR2 := null
    ,p_attribute10         IN VARCHAR2 := null
    ,p_attribute11         IN VARCHAR2 := null
    ,p_attribute12         IN VARCHAR2 := null
    ,p_attribute13         IN VARCHAR2 := null
    ,p_attribute14         IN VARCHAR2 := null
    ,p_attribute15         IN VARCHAR2 := null
  ) IS

  l_api_name           CONSTANT VARCHAR(30) := 'Complete_Workorder';
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
  l_err_number               NUMBER;

  l_new_status   NUMBER;
  l_db_status    NUMBER;
  l_db_last_update_date DATE;
  l_org_id       NUMBER;
  l_tran_type    NUMBER;
  l_reconciliation_code VARCHAR2(30);
  l_shutdown_type VARCHAR2(30);
  l_max_compl_op_date  DATE;
  l_min_open_period  DATE;
  l_min_compl_op_date DATE;
  l_max_tran_date DATE;
  l_actual_start_date DATE := p_actual_start_date;
  l_actual_end_date DATE := p_actual_end_date;
  l_actual_duration NUMBER := p_actual_duration;
  l_dummy NUMBER;


  l_subinv   VARCHAR2(80);
  l_locator_ctrl  NUMBER ; -- Holds the Locator Control information
  l_error_flag    NUMBER;
  l_error_mssg    VARCHAR2(250);
  l_item_id       NUMBER;
  l_locator_id    NUMBER;
  l_completion_info NUMBER;
  l_lot_ctrl_code  NUMBER;
  l_lot_number     VARCHAR2(80);


  BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT complete_workorder;
    END IF;

    eam_debug.init_err_stack('eam_workorders_jsp.complete_workorder');

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
      SELECT last_update_date, status_type, shutdown_type
      INTO   l_db_last_update_date, l_db_status , l_shutdown_type
      FROM wip_discrete_jobs
      WHERE wip_entity_id = p_wip_entity_id
      FOR UPDATE;

      IF  l_db_last_update_date <> p_stored_last_update_date THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_STALED_DATA');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( (p_transaction_type = 1 AND l_db_status <> 3) or
           (p_transaction_type = 2 and (l_db_status <> 4 and l_db_status <> 5)) ) THEN -- 5??
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_COMP_WRONG_STATUS');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_NOT_FOUND');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;

    --dgupta: default actual start and end dates from the last completion txn.
    --Note: This is redundant as we are not using the actual start and end for
    --uncompletion anywhere, but keeping for sake of consistency with forms
    if (p_transaction_type =  2) then
      select max(transaction_date) into l_max_tran_date
        from eam_job_completion_txns where transaction_type = 1
        and wip_entity_id = p_wip_entity_id;
      select actual_start_date, actual_end_date into
        l_actual_start_date, l_actual_end_date
        from eam_job_completion_txns where transaction_date = l_max_tran_date
        and wip_entity_id = p_wip_entity_id;
      l_actual_duration := (l_actual_end_date - l_actual_start_date)* 24;
    end if;

    select nvl(min(period_start_date), sysdate+2)
    into l_min_open_period
    from org_acct_periods
    where organization_id = p_org_id
    and open_flag = 'Y';
    /* Fix for bug no: 2695696    */
	 /*Fix for bug 3235163*/
   --Previously the check was for actual_end date.It has been changed to p_transaction_date
          if (p_transaction_date < l_min_open_period) then
      eam_execution_jsp.add_message(p_app_short_name => 'EAM',
        p_msg_name => 'EAM_TRANSACTION_DATE_INVALID');
    end if;
  /*End of fix for bug 3235163*/
	  /* end of fix for bug o:2695696 */

    if (p_transaction_type = 1) then -- added by dgupta
      /* Fix for Bug 2100416 */
      select nvl(max(actual_end_date), sysdate - 200000)
      into l_max_compl_op_date
      from eam_op_completion_txns eoct
      where wip_entity_id = p_wip_entity_id
      --fix for 3543834.added  where clause so that the last completion date will be fetched if the operation is complete
      and transaction_type=1
      and transaction_id = (select max(transaction_id)
                          from eam_op_completion_txns
                          where wip_entity_id = p_wip_entity_id
                                and operation_seq_num = eoct.operation_seq_num
                                );
      /* Fix for bug no:2730242 */
      select nvl(min(actual_start_date), sysdate + 200000)
      into l_min_compl_op_date
      from eam_op_completion_txns eoct
      where wip_entity_id = p_wip_entity_id
      --fix for 3543834.added  where clause so that the last completion date will be fetched if the operation is complete
      and transaction_type=1
      and transaction_id = (select max(transaction_id)
                            from eam_op_completion_txns
                            where wip_entity_id = p_wip_entity_id
                                  and operation_seq_num = eoct.operation_seq_num
                                 );

      if ((p_actual_start_date is not null) and (p_actual_duration is not null)) then
        -- Start Fix for Bug 2165293
        if (p_actual_duration < 0) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_NEGATIVE_DURATION');
        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
        -- End Fix for Bug 2165293

        if (p_actual_end_date > sysdate) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_END_LATER_THAN_TODAY');
        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;



	 -- mmaduska added for bug 3273898
         -- mmaduska added and condition to solve the date time truncation problem

      -- changed conditions for 3543834 so that actual_start_date and actual_end_date will be validated
       if (
          ((p_actual_end_date < l_max_compl_op_date) AND (l_max_compl_op_date - p_actual_end_date >  (0.000011575 * 60 ))) OR
          ((p_actual_start_date > l_min_compl_op_date) AND (p_actual_start_date -  l_min_compl_op_date >  (0.000011575 * 60 )))
	  )then
	  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_COMPL_DATES_INVALID',
	        p_token1=>'MIN_OP_DATE',p_value1=>TO_CHAR(l_min_compl_op_date,'dd-MON-yyyy HH24:MI:SS'),p_token2=>'MAX_OP_DATE'
		,p_value2=>TO_CHAR(l_max_compl_op_date,'dd-MON-yyyy HH24:MI:SS'));
	  x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

-- if p_actual_start_date is close to l_min_compl_op_date by a min or p_actual_end_date is close to l_max_compl_op_date
		if (p_actual_end_date < l_max_compl_op_date) then
		    l_actual_end_date := l_max_compl_op_date;
       		else
		   l_actual_end_date := p_actual_end_date;
	        end if;

		if(p_actual_start_date > l_min_compl_op_date) then
		    l_actual_start_date := l_min_compl_op_date;
		else
		    l_actual_start_date := p_actual_start_date;
		end if;

        end if;  -- end of if p_actual_start_date is not null ...
      /* End of Fix 2100416*/
    end if;  -- end of if (p_transaction_type = 1 ...
    BEGIN
      l_reconciliation_code := null;
      if( p_reconciliation_code is not null) then
        select mlu.lookup_code
        into l_reconciliation_code
        from mfg_lookups mlu
        where mlu.lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
          and mlu.meaning = p_reconciliation_code;
      end if;
    EXCEPTION WHEN OTHERS THEN
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RECONCILIATION_CODE_INV');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;

    if( p_shutdown_start_date > p_shutdown_end_date) then
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUTDOWN_DATE_BAD');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    end if;

 /* I.  As part of IB changes, Completing to a subinventory is always optional
    II. Even Asset WOs can be completed to subinventory
    III. As part of Transactability changes, an asset may be completed to
         subinventory under the following cases only:
             1) Item is assigned to the current work order org and
             2) If Item is serialized the current status of the item is 4 */


  	  l_completion_info := 0;


	/* Finding out SubInventory is Correct or Not */
	if(p_subinventory IS NOT NULL) then

        if (p_serial is null) then
        begin
        select 1 into l_Dummy from mtl_system_items_b msi
        where msi.inventory_item_id = p_item_id
        and msi.organization_id = p_org_id;

    	exception
       	when no_data_found then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_ITEM_NOT_ASSIGNED');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	end;

        else

         begin
         select 1 into l_Dummy from mtl_serial_numbers msn
         where msn.inventory_item_id = p_item_id
         and msn.serial_number = p_serial
         and msn.current_status = 4;
        exception
         when no_data_found then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_NOT_OUT_OF_STORES');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        end;

        end if;


			select
		  	lot_control_code into l_lot_ctrl_code
			from
		  	mtl_system_items_b
			where
		  	inventory_item_id = p_item_id
		  	and organization_id = p_org_id ;


			Begin
				 if(p_subinv_ctrl is null or p_subinv_ctrl <> 1) then
					 select secondary_inventory_name into l_subinv
					 from mtl_secondary_inventories
					 where
					 secondary_inventory_name = p_subinventory
					 and organization_id = p_org_id
					 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
					 and Asset_inventory = 2;
				 elsif(p_subinv_ctrl = 1) then
					 select secondary_inventory_name into l_subinv
					 from mtl_secondary_inventories
					 where
					 secondary_inventory_name = p_subinventory
					 and organization_id = p_org_id
					 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
					 and Asset_inventory = 2
					 and EXISTS (select secondary_inventory from mtl_item_sub_inventories
										   where secondary_inventory = secondary_inventory_name
										   and  inventory_item_id = p_item_id
										   and organization_id = p_org_id);
				 end if;
			 exception
				  when no_data_found then
					  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RET_MAT_INVALID_SUBINV');
					  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					  return;
			end;
	   end if;

         l_locator_id := p_locator_id;

		/* Finding out Locator ID  from Locator */
		if(p_locator_id IS NULL and p_locator IS NOT NULL) then
		Begin

			 if(p_locator_ctrl is null or p_locator_ctrl <> 1) then
				 select Inventory_Location_ID into l_locator_id
				 from mtl_item_locations_kfv where
				 concatenated_segments = p_locator
				 and subinventory_code = p_subinventory
				 and organization_id   = p_org_id;
			 elsif(p_locator_ctrl = 1) then
				 select Inventory_Location_ID into l_locator_id
				 from mtl_item_locations_kfv where
				 concatenated_segments = p_locator
				 and subinventory_code = p_subinventory
				 and organization_id   = p_org_id
				 and EXISTS (select '1' from mtl_secondary_locators
									  where inventory_item_id = p_item_id
									  and organization_id = p_org_id
									  and secondary_locator = inventory_location_id) ;
			 end if; -- end of inner if
		exception
		 when no_data_found then
	--	  x_error_flag := 1;
	--	  x_error_mssg := 'EAM_RET_MAT_INVALID_LOCATOR';
			  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RET_MAT_INVALID_LOCATOR');
			  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  return;
		end;
		end if;

		/* Check for Locator Control which could be defined
		   at 3 level Organization,Subinventory,Item .
		*/
		 EAM_MTL_TXN_PROCESS.Get_LocatorControl_Code(
							  p_org_id,
							  p_subinventory,
							  p_item_id,
							  27,
							  l_locator_ctrl,
							  l_error_flag,
							  l_error_mssg);

		if(l_error_flag <> 0) then
		 return;
		end if;

		-- if the locator control is Predefined or Dynamic Entry
		if(l_locator_ctrl = 2 or l_locator_ctrl = 3) then
		 if(l_locator_id IS NULL) then
	/*	   l_error_flag := 1;
		   l_error_mssg := 'EAM_RET_MAT_LOCATOR_NEEDED'; */
		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RET_MAT_LOCATOR_NEEDED');
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		   return;
		 end if;
		elsif(l_locator_ctrl = 1) then -- If the locator control is NOControl
		 if(l_locator_id IS NOT NULL) then
	/* 	   l_error_flag := 1;
		   l_error_mssg := 'EAM_RET_MAT_LOCATOR_RESTRICTED'; */
		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_RET_MAT_LOCATOR_RESTRICTED');
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		   return;
		 end if;
		end if; -- end of locator_control checkif

        /* CHECK for lot entry    */
		if(l_lot_ctrl_code = 2) then
            if(p_lot is not null)then
			begin
               select
			    lot_number into l_lot_number
               from
			    mtl_lot_numbers
			   where
			    inventory_item_id = p_item_id
				and organization_id = p_org_id;
            exception
			when NO_DATA_FOUND then
     		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_NO_LOT_NUMBER');
	    	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 		end;
			else
     		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_LOT_NEEDED');
	    	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	end if;
        else
		 if(p_lot is not null) then
   		  eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_LOT_NOT_NEEDED');
    	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 end if;
		end if; -- end of lot entry check

--	end if; -- end of completion_info check

--	end if; -- end of rebuild flag check

	-- ----------------------------------

    -- if validate not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR),
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

    BEGIN
      /* call processing logic */
      eam_completion.complete_work_order(
         x_wip_entity_id => p_wip_entity_id
        ,x_rebuild_jobs => p_rebuild_jobs
        ,x_transaction_type => p_transaction_type
        ,x_transaction_date => sysdate
        ,x_user_id => g_last_updated_by
        ,x_actual_start_date => l_actual_start_date
        ,x_actual_end_date => l_actual_end_date
        ,x_actual_duration => l_actual_duration
        ,x_reconcil_code => l_reconciliation_code
        ,x_shutdown_start_date => p_shutdown_start_date
        ,x_shutdown_end_date => p_shutdown_end_date
        ,x_subinventory => p_subinventory
        ,x_locator_id => p_locator_id
        ,x_lot_number => p_lot
        ,x_serial_number => p_serial
        ,errcode => l_err_number
        ,errmsg => l_err_code
        ,x_qa_collection_id =>p_qa_collection_id
        ,x_attribute_category => p_attribute_category
        ,x_attribute1          => p_attribute1
        ,x_attribute2          => p_attribute2
    	,x_attribute3          => p_attribute3
        ,x_attribute4          => p_attribute4
        ,x_attribute5          => p_attribute5
        ,x_attribute6          => p_attribute6
        ,x_attribute7          => p_attribute7
        ,x_attribute8          => p_attribute8
        ,x_attribute9          => p_attribute9
        ,x_attribute10         => p_attribute10
        ,x_attribute11         => p_attribute11
        ,x_attribute12         => p_attribute12
        ,x_attribute13         => p_attribute13
        ,x_attribute14         => p_attribute14
        ,x_attribute15         => p_attribute15
      );

      IF (l_err_number = 2) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name =>'EAM_WO_NO_UNCOMPLETE' );
          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF (l_err_number > 0 ) THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name =>l_err_code);
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_EXCEPTION',
         p_token1 => 'TEXT', p_value1 => sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;


    -- if DML not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR) ,
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
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.COMPLETE_WORKORDER',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.COMPLETE_WORKORDER',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.COMPLETE_WORKORDER',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END Complete_Workorder;



-------------------------------------------------------------------------------
  -- Creating easy work order
  -- insert row into wip_discrete_jobs, wip_entities
  -- create a default operation 10 for the new work order
  -- release the work order and call wip_change_status.release

  --anjgupta	Changes for IB and Transactable Assets Project in R12
  -------------------------------------------------------------------------------
    procedure create_ez_work_order
    (  p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_record_version_number       IN    NUMBER        := NULL
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN    NUMBER
      ,p_asset_number                IN    VARCHAR2  --corresponds to serial number in csi_item_instances
      ,p_asset_group                 IN    VARCHAR2
      ,p_work_order_type             IN    NUMBER        -- data
      ,p_description                 IN    VARCHAR2
      ,p_activity_type               IN    NUMBER
      ,p_activity_cause              IN    NUMBER
      ,p_scheduled_start_date        IN    DATE
      ,p_scheduled_completion_date   IN    DATE
      ,p_owning_department           IN    VARCHAR2
      ,p_priority                    IN    NUMBER
      ,p_request_type           IN NUMBER := 1
      ,p_work_request_number         IN    VARCHAR2
      ,p_work_request_id             IN    NUMBER
      ,x_new_work_order_name         OUT NOCOPY   VARCHAR2
      ,x_new_work_order_id           OUT NOCOPY   NUMBER
      ,p_asset_activity              IN    VARCHAR2
      ,p_project_number              IN    VARCHAR2
      ,p_task_number                 IN    VARCHAR2
      ,p_service_request_number	   IN    VARCHAR2
      ,p_service_request_id	   IN    NUMBER
      ,p_material_issue_by_mo	   IN	 VARCHAR2
      ,p_status_type                 IN    NUMBER
      ,p_mode                        IN    NUMBER
      ,p_wip_entity_name      IN    VARCHAR2
      ,p_user_id                     IN    NUMBER
      ,p_responsibility_id           IN    NUMBER
      ,p_firm                        IN    VARCHAR2
      ,p_activity_source             IN    NUMBER
      ,p_shutdown_type               IN    NUMBER
      ,p_parent_work_order	     IN	   VARCHAR2 DEFAULT NULL
      ,p_sched_parent_wip_entity_id  IN    VARCHAR2 DEFAULT NULL
      ,p_relationship_type      IN    VARCHAR2 DEFAULT NULL
      , p_attribute_category    IN    VARCHAR2   DEFAULT NULL
      , p_attribute1                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute2                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute3                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute4                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute5                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute6                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute7                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute8                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute9                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute10                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute11                   IN    VARCHAR2   DEFAULT NULL
      , p_attribute12                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute13                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute14                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute15                    IN    VARCHAR2   DEFAULT NULL
      , p_failure_id          IN NUMBER			DEFAULT NULL
      , p_failure_date        IN DATE				DEFAULT NULL
      , p_failure_entry_id    IN NUMBER		DEFAULT NULL
      , p_failure_code        IN VARCHAR2		 DEFAULT NULL
      , p_cause_code          IN VARCHAR2		DEFAULT NULL
      , p_resolution_code     IN VARCHAR2		DEFAULT NULL
      , p_failure_comments    IN VARCHAR2		DEFAULT NULL
      , p_failure_code_required     IN VARCHAR2 DEFAULT NULL
      , p_instance_number     IN    VARCHAR2 --corresponds to instance_number in csi_item_instances (for Bug 8667921)
    ) IS

    l_api_name           CONSTANT VARCHAR(30) := 'create_easy_work_order';
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

    l_dept_id                  NUMBER;
    l_asset_group_id           NUMBER;
    l_parent_wip_entity_id     NUMBER;
    l_prefix                   VARCHAR2(30);
    l_eam_class                VARCHAR2(10);
    l_asset_class              VARCHAR2(10);
    l_auto_firm                VARCHAR2(10);

    l_row                      wip_discrete_jobs%ROWTYPE;
    l_entity                   wip_entities%ROWTYPE;
    l_op                       wip_operations%ROWTYPE;

    l_rowid                    VARCHAR2(250);
    l_we_rowid                 VARCHAR2(250);
    l_routing_exists           VARCHAR2(250);

    l_work_request_id          NUMBER;
    l_work_request_number      VARCHAR2(250);
    l_work_request_wip_entity_id NUMBER;
    l_work_request_status      NUMBER;
    l_count                    NUMBER;
    l_min_acct_period_date     DATE;
    l_max_acct_period_date     DATE;

    -- baroy -- variables added for the 'Create EZ WO from asset activity project'
    -- Project Bug#2523149
    l_asset_activity_id        NUMBER;
    l_explode_msg_count        NUMBER;
    l_explode_msg_data         VARCHAR2(250);
    l_explode_ret_stat         VARCHAR2(250);
    l_project_id               NUMBER := null;
    l_task_id                  NUMBER := null;
    l_class_code               VARCHAR2(30);
    l_wdi_default_class        VARCHAR2(10) := '';
    l_wdi_lot_number_def       NUMBER;
    l_wdi_wip_param_ct         NUMBER;
    l_wdi_acct_class_flag      NUMBER := 0;
    l_wdi_disable_date         DATE;
    l_wdi_default_ma           NUMBER;
    l_wdi_default_mva          NUMBER;
    l_wdi_default_moa          NUMBER;
    l_wdi_default_ra           NUMBER;
    l_wdi_default_rva          NUMBER;
    l_wdi_default_opa          NUMBER;
    l_wdi_default_opva         NUMBER;
    l_wdi_default_oa           NUMBER;
    l_wdi_default_ova          NUMBER;
    l_wdi_default_scaa         NUMBER;
    l_wdi_org_locator_control  NUMBER;
    l_wdi_demand_class_mp      VARCHAR2(30);
    l_wdi_mp_calendar_code     VARCHAR2(10);
    l_wdi_mp_exception_set_id  NUMBER;
    l_wdi_project_ref          NUMBER;
    l_wdi_project_control      NUMBER;
    l_wdi_pm_cost_collection   NUMBER;
    l_wdi_primary_cost_method  NUMBER;
    l_wdi_po_creation_time     NUMBER;
    -- baroy
    l_asset_number_wl VARCHAR2(30);


    -- Fields added for accounts (Bug 2217939)
    l_material_account     NUMBER ;
    l_material_overhead_account   NUMBER ;
    l_resource_account    NUMBER ;
    l_outside_processing_account   NUMBER ;
    l_material_variance_account   NUMBER ;
    l_resource_variance_account   NUMBER ;
    l_out_proc_var_account   NUMBER ;
    l_std_cost_adjustment_account  NUMBER ;
    l_overhead_account    NUMBER ;
    l_overhead_variance_account  NUMBER ;

    -- sraval: local service request variables
    l_service_request_id	NUMBER;
    l_service_request_number VARCHAR2(64);
    l_service_association_id NUMBER;

    -- lllin: fields added for maintenance object id, type, and source
    l_maintenance_object_id number;
    l_maintenance_object_type number;
    l_maintenance_object_source number;

    -- Fields added for new Work Order API
      l_workorder_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec1 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec2 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec3 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl1  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl2  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl1  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl2  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl1  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl2  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl1  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl2  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl1   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl2   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl1  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl2  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl1   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl2   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_wip_entity_id            NUMBER;
      --Bug3592712: Max length of workorder name is 240 char.
      l_wip_entity_name          VARCHAR2(240);


      l_eam_item_type   NUMBER;
      l_user_defined_status_type  NUMBER;
      l_status_type  NUMBER;

      l_wip_entity_updt  NUMBER;

      l_mode NUMBER;  -- 0 for Create and 1 for Update
      l_date_released  DATE;
      l_user_id NUMBER;
      l_responsibility_id NUMBER;
      l_firm   NUMBER;
      l_serial_number_control  NUMBER := 0;
      l_work_name VARCHAR2(240);
      l_parent_work_order_count number:=0;
      l_adjust_parent varchar2(10);
      l_row_count number :=0;
      l_start_date Date;
      l_end_date Date;
      /* FA project */
      l_fail_dept_id       NUMBER;
      l_eam_location_id    NUMBER;


	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl2      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_rec1      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec2      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec3      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec4      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;

	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl3               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;

    l_eam_msg_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_old_rebuild_source  NUMBER;
    l_message_text  varchar2(20);

   l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   wip_id NUMBER;
   manual_rebuild_flag varchar2(1);
   constraining_rel number;
   followup_rel number;
   record_count number :=1;
   l_orig_service_request_id  number;
   l_orig_wo_status number;
  asset_status number;
  l_output_dir VARCHAR2(512);
  l_prev_activity_id NUMBER := null;

   /* Added for bug#5284499 Start */
  l_prev_project_id  NUMBER;
  l_prev_task_id     NUMBER;
  /* Added for bug#5284499 End */

	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

/* Added for FA */
l_eam_failure_entry_record eam_process_failure_entry_pub.eam_failure_entry_record_typ ;
l_eam_failure_codes_tbl eam_process_failure_entry_pub.eam_failure_codes_tbl_typ ;
/* End of FA */


    -- Cursor to fetch system status for corresponding user defined status passed to API.
    CURSOR get_system_status IS
	SELECT system_status
	  FROM EAM_WO_STATUSES_V
	 WHERE status_id = p_status_type;

  BEGIN

  --derive the serial_number(l_asset_number_wl) from p_instance_number for the given asset
  --if the serial number is not passed to the API (for Bug 8667921)

  IF(p_asset_number is null and p_instance_number is not null) THEN
     select serial_number into l_asset_number_wl
     from csi_item_instances
     where instance_number = p_instance_number;
  END IF;

--Initialize the message count.This will make check_errors to look in the message stack and display all messages.
     x_msg_count := 0;

         SAVEPOINT create_easy_work_order;

      eam_debug.init_err_stack('eam_workorders_jsp.create_easy_work_order');

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

      -- Assign user defined status passed to API to a local variable
      l_user_defined_status_type := p_status_type;

      -- Fetch corresponding system status for user defined status passed to the API.
      OPEN get_system_status;
      FETCH get_system_status INTO l_status_type;
      CLOSE get_system_status;

      l_mode := p_mode;


/*cboppana-3245839..Aded this code to validate if an asset is deactivated
we should not allow change of status of the workorder from cancelled
to any other status other than closed*/
if(l_mode=1) then
    begin

      select wdj.status_type
      into l_orig_wo_status
      from wip_discrete_jobs wdj,wip_entities we
      where we.wip_entity_id=wdj.wip_entity_id
      and we.organization_id=p_organization_id
      and wdj.organization_id=p_organization_id
      and we.wip_entity_name=p_wip_entity_name;

      if(nvl(p_asset_number,l_asset_number_wl) is not null) then
        select  nvl(cii.active_start_date, sysdate-1),
				nvl(cii.active_start_date, sysdate-1),msikfv.eam_item_type
        into l_start_date, l_end_date, l_eam_item_type
        from csi_item_instances cii, mtl_system_items_b_kfv msikfv, mtl_parameters mp
        where cii.inventory_item_id =msikfv.inventory_item_id
        and cii.last_vld_organization_id =msikfv.organization_id  --Bug 2157979
        and cii.last_vld_organization_id = mp.organization_id
	and mp.maint_organization_id = p_organization_id
        and cii.serial_number = nvl(p_asset_number,l_asset_number_wl)
        and msikfv.CONCATENATED_SEGMENTS = nvl(p_asset_group, msikfv.CONCATENATED_SEGMENTS)
        and rownum = 1;

        if (l_start_date <= sysdate and l_end_date >= sysdate) then
        		asset_status := 3; --active
        else
        		asset_status := 4; --inactive
        end if;

         if((l_eam_item_type=1) and (l_orig_wo_status=7) and (l_status_type in (1,3,6,17)) and (asset_status<>3)) then
           eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_DEACTIVATE_CANNOT_UNCANCEL',
                  p_token1 => 'NAME', p_value1 => p_wip_entity_name);
           x_return_status := FND_API.G_RET_STS_ERROR;
           return;
         end if;
     end if;
    exception
      when others then
        null;
    end;
   end if;


  -- get asset group id and other info needed
  BEGIN

   if (nvl(p_asset_number,l_asset_number_wl) is not null) then
       		select cii.inventory_item_id , eomd.ACCOUNTING_CLASS_CODE,
		   cii.instance_id, msikfv.eam_item_type , eomd.area_id
	       	into l_asset_group_id, l_asset_class, l_maintenance_object_id, l_eam_item_type , l_eam_location_id
       		from csi_item_instances cii, mtl_system_items_b_kfv msikfv,
       		     mtl_parameters mp, eam_org_maint_defaults eomd
	       	where cii.inventory_item_id =msikfv.inventory_item_id
       		and cii.last_vld_organization_id =msikfv.organization_id  --Bug 2157979
	       	and cii.last_vld_organization_id = mp.organization_id
		and mp.maint_organization_id = p_organization_id
       		and cii.serial_number = nvl(p_asset_number,l_asset_number_wl)
	       	and msikfv.CONCATENATED_SEGMENTS = nvl(p_asset_group, msikfv.CONCATENATED_SEGMENTS)
			and eomd.object_type (+) = 50
			and eomd.object_id (+) = cii.instance_id
			and eomd.organization_id (+) = p_organization_id
                 and rownum = 1;

  		l_maintenance_object_type:=3;
	else

		begin
			-- Changes by amondal for New Work Order API
	        select msikfv.inventory_item_id, msikfv.eam_item_type, msikfv.serial_number_control_code
			into l_asset_group_id, l_eam_item_type, l_serial_number_control
        	from mtl_system_items_b_kfv msikfv, mtl_parameters mp
	        where msikfv.organization_id=mp.organization_id
			and mp.maint_organization_id = p_organization_id
			and msikfv.CONCATENATED_SEGMENTS = p_asset_group
			and rownum = 1;

			l_maintenance_object_id:=l_asset_group_id;
	        l_maintenance_object_type:=2;
		exception
			when others then
			eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_ASSET_BAD');
			x_return_status := FND_API.G_RET_STS_ERROR;
		end;
	end if;

	  l_maintenance_object_source:=1;

	 EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_ASSET_BAD');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      -- get owning department id
      --fix for 3396024.

      BEGIN
       IF(p_owning_department IS NOT NULL) THEN
          select department_id
          into l_dept_id
          from bom_departments
          where organization_id = p_organization_id
              and department_code = p_owning_department;
       END IF;
      EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_DEPT_BAD');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

   --if it is a work request
  if(p_request_type=1) then
      -- validate work request
      BEGIN
        l_work_request_id := null;
        l_work_request_number := null;
        -- if only number is provided
        if( p_work_request_id is not null) then
          l_work_request_id := p_work_request_id;
        elsif (p_work_request_number is not null) then
          l_work_request_number := p_work_request_number;
          select count(*), avg(r.work_request_id)
          into l_count, l_work_request_id
          from wip_eam_work_requests r
          where r.work_request_number = p_work_request_number;

          -- unique
          if(l_count > 1) then
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQ_NOTUNIQUE');
            x_return_status := FND_API.G_RET_STS_ERROR;
          elsif (l_count <1) then
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQ_NOTFOUND');
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
        end if;

        -- check request status
        if( x_return_status = FND_API.G_RET_STS_SUCCESS and l_work_request_id is not null) then
          select r.work_request_number, r.wip_entity_id, r.work_request_status_id
          into l_work_request_number, l_work_request_wip_entity_id, l_work_request_status
          from wip_eam_work_requests r
          where r.work_request_id = l_work_request_id for update;

          if(l_work_request_number <> p_work_request_number) then
            -- should not happen
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQ_CONFLICT');
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
          if(l_work_request_wip_entity_id is not null) then
          -- has work order on work request
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQ_WO_EXIST');
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
          if(l_work_request_status <> 3) then
          -- has work order on work request
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQ_STATUS_WRONG');
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
        end if;
      EXCEPTION WHEN OTHERS THEN
        -- only occur if work request not exist, should not happen
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_WQID_NOTFOUND');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
  end if;

 --start of fix for 3396024.  removed the validations and added code to fetch only the parent_wip_entity_id
  if(p_parent_work_order is not null) then
  begin
      SELECT wip_entity_id
       INTO  l_parent_wip_entity_id
       FROM WIP_ENTITIES
       WHERE wip_entity_name=p_parent_work_order
       AND organization_id=p_organization_id;
   exception
	when others then
	       eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_PARENT_WO_BAD');
	        x_return_status := FND_API.G_RET_STS_ERROR;
  end;
  end if;
  --end of fix for 3396024

      -- Validate Asset Activity
      BEGIN
        if p_asset_activity is not null then
          -- See whether it is a valid asset activity

            select inventory_item_id into l_asset_activity_id
              from mtl_system_items_b_kfv
              where concatenated_segments = p_asset_activity
              and eam_item_type = 2
              and organization_id = p_organization_id;
        end if;

      EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_GENERIC_ERROR',
          p_token1 => 'EAM_ERROR', p_value1 => sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;



if(p_request_type = 2) then
      -- sraval: Validate Service Request
      BEGIN
      	l_service_request_number := null;
      	l_service_request_id := null;

      	-- if user enters service request direcly without selecting from LOV
      	if (p_service_request_id is null and p_service_request_number is not null) then
      		select incident_id
      		into l_service_request_id
      		from cs_incidents_all_b
      		where incident_number = p_service_request_number;

          elsif (p_service_request_id is not null) then
         		l_service_request_id := p_service_request_id;

      	end if;
      EXCEPTION WHEN OTHERS THEN
      	eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_BAD_SERVICE_REQUEST');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
end if;

      -- Project and task validation
      BEGIN

        if p_project_number is null and p_task_number is not null then
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_PROJECT_REQUIRED');
          x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

	 -- set profile values to be used by PJM Views. Bug#4384541
	fnd_profile.put('MFG_ORGANIZATION_ID',p_organization_id );

        if p_project_number is not null and p_task_number is null then
          select count(*) into l_count
            from pjm_projects_v ppv,
            pjm_project_parameters ppp
            where ppv.project_id = ppp.project_id
            and ppp.organization_id = p_organization_id
            and ppv.project_number = p_project_number
            and rownum <= 1;
          if l_count <> 1 then
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_BAD_PROJECT');
            x_return_status := FND_API.G_RET_STS_ERROR;
          else
            select ppv.project_id into l_project_id
              from pjm_projects_v ppv,
              pjm_project_parameters ppp
              where ppv.project_id = ppp.project_id
              and ppp.organization_id = p_organization_id
              and ppv.project_number = p_project_number;
          end if;
        end if;

	/* Bug # 4862404 : Removed the validation for project_id and task_id as we
	   calling WO API */

      EXCEPTION WHEN OTHERS THEN
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_GENERIC_ERROR',
          p_token1 => 'EAM_ERROR', p_value1 => SQLERRM);
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      -- Check Validation Errors

      -- if validate not passed then raise error
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
             eam_execution_jsp.Get_Messages
               (p_encoded  => FND_API.G_FALSE,
                p_msg_index => 1,
                p_msg_count => l_msg_count,
                p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR) ,
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

      -- End of check for Validation Errors

      -- Code Added for Status Type
     BEGIN

      l_mode                 := p_mode;
      l_wip_entity_name := p_wip_entity_name;
      -- l_user_id              := p_user_id;
      -- l_responsibility_id    := p_responsibility_id;
      l_user_id := fnd_global.user_id;
      l_responsibility_id := fnd_global.resp_id;

      if p_firm = '1' then
       l_firm                 := to_number(p_firm);
      else
       l_firm := 2;
      end if;

	/* Start of FA project code */
/* Commented this code as this is not the right place to capture Failure Information.
Added the code accordingtly while creating easy work orders

l_fail_dept_id := l_dept_id ;

	IF(p_failure_code_required IS NOT NULL) THEN
		l_eam_failure_entry_record.failure_id   := p_failure_id;
		l_eam_failure_entry_record.failure_date := p_failure_date;
		l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		l_eam_failure_codes_tbl(1).comments         := p_failure_comments;

		IF(l_mode =  1)  THEN -- if updating work order
			l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
			l_eam_failure_entry_record.source_type := 1;
			l_eam_failure_entry_record.source_id := l_workorder_rec.wip_entity_id;
			l_eam_failure_entry_record.object_type := l_workorder_rec.maintenance_object_type;
			l_eam_failure_entry_record.object_id := l_workorder_rec.maintenance_object_id;
			l_eam_failure_entry_record.maint_organization_id := l_workorder_rec.organization_id;
			l_eam_failure_entry_record.current_organization_id := l_workorder_rec.organization_id;
			l_eam_failure_entry_record.department_id := l_fail_dept_id;
			l_eam_failure_entry_record.area_id := l_eam_location_id;

			l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;

			IF (l_eam_failure_entry_record.failure_date IS NULL) THEN
				l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
			END IF;

			IF (l_eam_failure_codes_tbl(1).failure_code IS NULL) THEN
				l_eam_failure_codes_tbl(1).failure_code := FND_API.G_MISS_CHAR;
			END IF;

			IF (l_eam_failure_codes_tbl(1).cause_code IS NULL) THEN
				l_eam_failure_codes_tbl(1).cause_code := FND_API.G_MISS_CHAR;
			END IF;

			IF (l_eam_failure_codes_tbl(1).resolution_code IS NULL) THEN
				l_eam_failure_codes_tbl(1).resolution_code := FND_API.G_MISS_CHAR;
			END IF;

			IF (l_eam_failure_codes_tbl(1).comments IS NULL) THEN
				l_eam_failure_codes_tbl(1).comments := FND_API.G_MISS_CHAR;
			END IF;

			IF (l_eam_failure_entry_record.failure_id IS NOT NULL ) THEN
				l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
			ELSE
				IF (l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE) THEN
					l_eam_failure_entry_record.transaction_type := NULL;
				ELSE
					l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
				END IF;
			END IF;

			IF (l_eam_failure_codes_tbl(1).failure_entry_id IS NOT NULL) THEN
				l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				l_workorder_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
			ELSE
				IF ( NOT ( (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR)
					AND (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR)
					AND (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR)
					AND (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR)
				     ) ) THEN
					l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
					IF (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR) THEN
						l_eam_failure_codes_tbl(1).failure_code := NULL;
					END IF;
					IF (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR) THEN
						l_eam_failure_codes_tbl(1).cause_code := NULL;
					END IF;
					IF (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR) THEN
						l_eam_failure_codes_tbl(1).resolution_code := NULL;
					END IF;
					IF (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR) THEN
						l_eam_failure_codes_tbl(1).comments := NULL;
					END IF;

					l_workorder_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
				ELSE
					l_eam_failure_codes_tbl.delete;
					l_workorder_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;
				END IF;
			END IF;
			l_workorder_rec.eam_failure_entry_record := l_eam_failure_entry_record;
		ELSE    -- work order is getting created

			l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
			l_eam_failure_entry_record.source_type := 1;
			l_eam_failure_entry_record.source_id := l_workorder_rec.wip_entity_id;
			l_eam_failure_entry_record.object_type := l_workorder_rec.maintenance_object_type;
			l_eam_failure_entry_record.object_id := l_workorder_rec.maintenance_object_id;
			l_eam_failure_entry_record.maint_organization_id := l_workorder_rec.organization_id;
			l_eam_failure_entry_record.current_organization_id := l_workorder_rec.organization_id;
			l_eam_failure_entry_record.department_id := l_fail_dept_id;
			l_eam_failure_entry_record.area_id := l_eam_location_id;

			IF (l_eam_failure_entry_record.failure_date IS NULL) THEN
				l_eam_failure_entry_record.transaction_type := NULL;
			END IF;
			l_workorder_rec.eam_failure_entry_record := l_eam_failure_entry_record;

			l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
			IF ( NOT ( l_eam_failure_codes_tbl(1).failure_code IS NULL
				AND l_eam_failure_codes_tbl(1).cause_code IS NULL
				AND l_eam_failure_codes_tbl(1).resolution_code IS NULL
				AND l_eam_failure_codes_tbl(1).comments IS NULL)
				) THEN
				l_workorder_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
			ELSE
				l_eam_failure_codes_tbl.delete;
				l_workorder_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;
			END IF;
		END IF; -- end of work order mode check

   END IF;   --end of check for failure data passed
*/
	 /* End of FA code */


 if (l_mode = 1) then   -- Update of Work Order API

      begin
       /*Bug#4425025 - have date_released as null if its null to enable defaulting in EAM_WO_DEFAULT_PVT*/

        /* select we.wip_entity_id, nvl(wdj.date_released,sysdate),wdj.parent_wip_entity_id,wdj.manual_rebuild_flag */
	 select we.wip_entity_id,wdj.date_released,wdj.parent_wip_entity_id,wdj.manual_rebuild_flag
          into l_wip_entity_updt, l_date_released,l_old_rebuild_source,manual_rebuild_flag
          from wip_entities we, wip_discrete_jobs wdj
          where we.wip_entity_name = l_wip_entity_name
          and we.organization_id = p_organization_id
          and we.organization_id = wdj.organization_id
          and we.wip_entity_id = wdj.wip_entity_id;

          EXCEPTION WHEN OTHERS THEN
                eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_GENERIC_ERROR',
                  p_token1 => 'EAM_ERROR', p_value1 => SQLERRM);
                x_return_status := FND_API.G_RET_STS_ERROR;
     end;


      BEGIN
      -- Start of Call to Work Order PL/SQL API

               l_workorder_rec.header_id  := 1;
               l_workorder_rec.batch_id   := 1;
              l_workorder_rec.return_status := null;
              l_workorder_rec.wip_entity_name := l_wip_entity_name;
              l_workorder_rec.wip_entity_id := l_wip_entity_updt;
              l_workorder_rec.organization_id := p_organization_id;
              l_workorder_rec.description := p_description;

              if (l_eam_item_type <>3) then
                l_workorder_rec.asset_number := nvl(p_asset_number,l_asset_number_wl);
                l_workorder_rec.asset_group_id := l_asset_group_id;
                l_workorder_rec.rebuild_serial_number := null;
                l_workorder_rec.rebuild_item_id := null;
              else
                l_workorder_rec.rebuild_serial_number := nvl(p_asset_number,l_asset_number_wl);
                l_workorder_rec.rebuild_item_id := l_asset_group_id;
		  if(l_parent_wip_entity_id is not null) then
			l_workorder_rec.parent_wip_entity_id := l_parent_wip_entity_id;
	          end if;
                l_workorder_rec.asset_number := null;
                l_workorder_rec.asset_group_id := null;

              end if;


              l_workorder_rec.firm_planned_flag := l_firm;
              -- Code change for Bug 3454269
              l_workorder_rec.requested_start_date := p_scheduled_start_date;
              -- Code change for Bug 3454269
              -- l_workorder_rec.due_date := p_scheduled_start_date;
              l_workorder_rec.owning_department := l_dept_id;
              l_workorder_rec.scheduled_start_date := p_scheduled_start_date;
              l_workorder_rec.scheduled_completion_date := p_scheduled_completion_date;
              l_workorder_rec.status_type := l_status_type;
	      l_workorder_rec.user_defined_status_id := l_user_defined_status_type;
              l_workorder_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
              l_workorder_rec.maintenance_object_id := l_maintenance_object_id;
      	      l_workorder_rec.maintenance_object_type := l_maintenance_object_type;
      	      l_workorder_rec.maintenance_object_source := l_maintenance_object_source;
      	      l_workorder_rec.asset_activity_id := l_asset_activity_id;
	      l_workorder_rec.attribute_category := p_attribute_category;    --Flex field columns
              l_workorder_rec.attribute1 := p_attribute1;
              l_workorder_rec.attribute2 := p_attribute2;
              l_workorder_rec.attribute3 := p_attribute3;
              l_workorder_rec.attribute4 := p_attribute4;
              l_workorder_rec.attribute5 := p_attribute5;
              l_workorder_rec.attribute6 := p_attribute6;
              l_workorder_rec.attribute7 := p_attribute7;
              l_workorder_rec.attribute8 := p_attribute8;
              l_workorder_rec.attribute9 := p_attribute9;
              l_workorder_rec.attribute10 := p_attribute10;
              l_workorder_rec.attribute11 := p_attribute11;
              l_workorder_rec.attribute12 := p_attribute12;
              l_workorder_rec.attribute13 := p_attribute13;
              l_workorder_rec.attribute14 := p_attribute14;
              l_workorder_rec.attribute15 := p_attribute15;


             -- # 3436679   code added to prevent the defaulting of the asset activity if user removes it while updating work order

	       BEGIN
		select primary_item_id,project_id,task_id  into l_prev_activity_id,l_prev_project_id,l_prev_task_id
		from wip_discrete_jobs
		where wip_entity_id = l_workorder_rec.wip_entity_id
		and organization_id = l_workorder_rec.organization_id;

		EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		  null;
		end;

		 IF l_prev_activity_id is not null and l_asset_activity_id is null THEN
			l_workorder_rec.asset_activity_id  := FND_API.G_MISS_NUM;
		ELSE
			l_workorder_rec.asset_activity_id := l_asset_activity_id;
		END IF;

		    /* Added for bug#5346446 Start */
              IF l_prev_project_id is not null AND l_project_id is null THEN
                 l_workorder_rec.project_id := FND_API.G_MISS_NUM;
              ELSE
                 l_workorder_rec.project_id := l_project_id;
              END IF;

              IF l_prev_task_id is not null AND l_task_id is null THEN
                 l_workorder_rec.task_id := FND_API.G_MISS_NUM;
              ELSE
                 l_workorder_rec.task_id := l_task_id;
              END IF;
              /* Added for bug#5346446 End */


      	      l_workorder_rec.activity_type := to_char(p_activity_type);
      	      l_workorder_rec.activity_cause := to_char(p_activity_cause);
      	      l_workorder_rec.activity_source := to_char(p_activity_source);
      	      l_workorder_rec.shutdown_type:=to_char(p_shutdown_type);
      	      l_workorder_rec.work_order_type := to_char(p_work_order_type);
              l_workorder_rec.priority := p_priority;
              l_workorder_rec.project_id := l_project_id;
              l_workorder_rec.task_id := l_task_id;
              l_workorder_rec.material_issue_by_mo := p_material_issue_by_mo;

              -- Set user id and responsibility id so that we can set apps context
              -- before calling any concurrent program
              l_workorder_rec.user_id := l_user_id;
              l_workorder_rec.responsibility_id := l_responsibility_id;

              if (l_status_type = 3) then -- Set Date Released to be sysdate, if you want to
                                          -- Release the work order now
                l_workorder_rec.date_released := l_date_released;
              end if;


         l_eam_wo_tbl(1) := l_workorder_rec;


  if((l_eam_item_type =3) and (manual_rebuild_flag='Y'))then

/*Delink child from the old rebuild source and attach to the new rebuild source */


           if(((l_old_rebuild_source  is not null)  and (l_parent_wip_entity_id is null))
   		 or ((l_old_rebuild_source is null )  and  (l_parent_wip_entity_id is not null))
  		  or (l_old_rebuild_source  <> l_parent_wip_entity_id)
   	     )then


    if(l_old_rebuild_source is not null) then

----If constraining relationship exists with rebuild source delete it
     select count(*)
     into constraining_rel
     from eam_wo_relationships
     where parent_object_id=l_old_rebuild_source
     and child_object_id=l_wip_entity_updt
     and parent_relationship_type=1;

   if(constraining_rel=1) then
     l_eam_wo_relations_rec1.batch_id  :=  1;
     l_eam_wo_relations_rec1.parent_object_id := l_old_rebuild_source;
     l_eam_wo_relations_rec1.parent_object_type_id := 1;
     l_eam_wo_relations_rec1.parent_header_id := l_old_rebuild_source;
     l_eam_wo_relations_rec1.child_object_type_id := 1;
     l_eam_wo_relations_rec1.child_header_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec1.child_object_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec1.parent_relationship_type  := 1;
     l_eam_wo_relations_rec1.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec1;
          record_count := record_count+1;

     end if;


   ----If followup relationship exists with rebuild source delete it


     select count(*)
     into followup_rel
     from eam_wo_relationships
     where parent_object_id=l_old_rebuild_source
     and child_object_id=l_wip_entity_updt
     and parent_relationship_type=4;

   if(followup_rel=1) then

     l_eam_wo_relations_rec2.batch_id  :=  1;
     l_eam_wo_relations_rec2.parent_object_id := l_old_rebuild_source;
     l_eam_wo_relations_rec2.parent_object_type_id := 1;
     l_eam_wo_relations_rec2.parent_header_id := l_old_rebuild_source;
     l_eam_wo_relations_rec2.child_object_type_id := 1;
     l_eam_wo_relations_rec2.child_header_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec2.child_object_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec2.parent_relationship_type  := 4;
     l_eam_wo_relations_rec2.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec2;
          record_count := record_count+1;

    end if;

   end if;


  if(l_parent_wip_entity_id is not null) then

--create a constraining relationship with the new rebuild source
     l_eam_wo_relations_rec3.batch_id  :=  1;
     l_eam_wo_relations_rec3.parent_object_id := l_parent_wip_entity_id;
     l_eam_wo_relations_rec3.parent_object_type_id := 1;
     l_eam_wo_relations_rec3.parent_header_id := l_parent_wip_entity_id;
     l_eam_wo_relations_rec3.child_object_type_id := 1;
     l_eam_wo_relations_rec3.child_header_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec3.child_object_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec3.parent_relationship_type  := 1;
     l_eam_wo_relations_rec3.adjust_parent   := FND_API.G_FALSE;
     l_eam_wo_relations_rec3.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

          l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec3;
          record_count := record_count+1;


--create a followup relationship with the new rebuild source

     l_eam_wo_relations_rec4.batch_id  :=  1;
     l_eam_wo_relations_rec4.parent_object_id := l_parent_wip_entity_id;
     l_eam_wo_relations_rec4.parent_object_type_id := 1;
     l_eam_wo_relations_rec4.parent_header_id := l_parent_wip_entity_id;
     l_eam_wo_relations_rec4.child_object_type_id := 1;
     l_eam_wo_relations_rec4.child_header_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec4.child_object_id    :=l_wip_entity_updt;
     l_eam_wo_relations_rec4.parent_relationship_type  := 4;
     l_eam_wo_relations_rec4.adjust_parent   := FND_API.G_FALSE;
     l_eam_wo_relations_rec4.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

          l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec4;
          record_count := record_count+1;

    end if;  ---End of adding rel to new rebuild source
end if;--End of delinking and attaching
end if;
   EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'updatewoss.log'
  	         , p_output_dir              =>l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'w'
           );

   l_workorder_rec1 :=  l_eam_wo_tbl1(1);

       x_return_status := l_return_status;
        x_msg_count   := l_msg_count;

/*End of update wo ***********/
   if(x_return_status<>'S') then
       ROLLBACK TO create_easy_work_order;
       RAISE  FND_API.G_EXC_ERROR;
    end if;

    EXCEPTION WHEN OTHERS THEN
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_GENERIC_ERROR',
              p_token1 => 'EAM_ERROR', p_value1 => SQLERRM);
            x_return_status := FND_API.G_RET_STS_ERROR;
      END;


BEGIN
--if service request
  if(p_request_type=2) then

      	-- if service request is specified then insert into eam_wo_service_association
      	if (l_service_request_id is not null) then
      		select eam_wo_service_association_s.nextval
      		into l_service_association_id
      		from dual;

--Assign only one service request to a work order

                select count(*)
                into l_row_count
                from eam_wo_service_association
                where  wip_entity_id = l_wip_entity_updt
		and  (enable_flag IS NULL OR enable_flag = 'Y');   -- Fix for 3773450

             if(l_row_count=0) then

      		insert into eam_wo_service_association
      		(
      	   		wo_service_entity_assoc_id
      	   		,maintenance_organization_id
      	   		,wip_entity_id
      	   		,service_request_id
      	   		,last_update_date
      	   		,last_updated_by
      	   		,creation_date
      	   		,created_by
      	   		,last_update_login
			,enable_flag			-- Fix for Bug 3773450
      		)
      		values
      		(
      	  	 	l_service_association_id
      	  	 	,p_organization_id
      	  		,l_wip_entity_updt
      	   		,l_service_request_id
      	   		,sysdate
        	   		,FND_GLOBAL.user_id
        	   		,sysdate
        	   		,FND_GLOBAL.user_id
        	   		,FND_GLOBAL.LOGIN_ID
				,'Y'

      		);

           else
               if(l_row_count=1) then
                 select  service_request_id
                 into l_orig_service_request_id
                 from eam_wo_service_association
                 where maintenance_organization_id=p_organization_id
                 and wip_entity_id=l_wip_entity_updt
		 and (enable_flag IS NULL OR enable_flag='Y');    -- Fix for Bug 3773450

                 if(l_orig_service_request_id<>l_service_request_id) then
                      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_SERVICE_REQUEST_EXISTS');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                 end if;
               end if;

           end if;
      	end if;

else
   if(p_request_type=1) then
      -- update work request if exist
      if( l_work_request_id is not null) then
        update wip_eam_work_requests r
        set r.work_request_status_id = 4
         , r.wip_entity_id = l_workorder_rec1.wip_entity_id
         , r.last_update_date = sysdate
         , r.last_updated_by = FND_GLOBAL.user_id
        where r.work_request_id = l_work_request_id;
      end if;
    end if;
end if;
EXCEPTION
      	WHEN OTHERS THEN
 	      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_BAD_SERVICE_REQUEST');
    		x_return_status := FND_API.G_RET_STS_ERROR;

END;

     IF FND_API.TO_BOOLEAN(P_COMMIT)
      THEN
        COMMIT WORK;
      END IF;


else  -- End of Update Work Order, Start of Create Work Order


      -------------------------------------------------------------
      -- DML here
       --create new work order

      BEGIN
          -- Start of Call to Work Order PL/SQL API
/*cboppana-Changed for Work Order Linking project  */
          l_workorder_rec.header_id  := 1;
          l_workorder_rec.batch_id   := 1;
          l_workorder_rec.return_status := null;
          l_workorder_rec.wip_entity_name := p_wip_entity_name;
          l_workorder_rec.wip_entity_id := null;
          l_workorder_rec.organization_id := p_organization_id;
          l_workorder_rec.description := p_description;
	  l_workorder_rec.attribute_category := p_attribute_category;    --Flex field columns
          l_workorder_rec.attribute1 := p_attribute1;
          l_workorder_rec.attribute2 := p_attribute2;
          l_workorder_rec.attribute3 := p_attribute3;
          l_workorder_rec.attribute4 := p_attribute4;
          l_workorder_rec.attribute5 := p_attribute5;
          l_workorder_rec.attribute6 := p_attribute6;
          l_workorder_rec.attribute7 := p_attribute7;
          l_workorder_rec.attribute8 := p_attribute8;
          l_workorder_rec.attribute9 := p_attribute9;
          l_workorder_rec.attribute10 := p_attribute10;
          l_workorder_rec.attribute11 := p_attribute11;
          l_workorder_rec.attribute12 := p_attribute12;
          l_workorder_rec.attribute13 := p_attribute13;
          l_workorder_rec.attribute14 := p_attribute14;
          l_workorder_rec.attribute15 := p_attribute15;


          if (l_eam_item_type <>3) then
            l_workorder_rec.asset_number := nvl(p_asset_number,l_asset_number_wl);
            l_workorder_rec.asset_group_id := l_asset_group_id;
            l_workorder_rec.rebuild_serial_number := null;
            l_workorder_rec.rebuild_item_id := null;
          else
            l_workorder_rec.rebuild_serial_number := nvl(p_asset_number,l_asset_number_wl);
            l_workorder_rec.rebuild_item_id := l_asset_group_id;
	    if(l_parent_wip_entity_id is not null) then
	         l_workorder_rec.parent_wip_entity_id := l_parent_wip_entity_id;

/*cboppana --Add this work order as a constraining child of the rebuild source */
                 l_eam_wo_relations_rec1.batch_id  :=  1;
  		 l_eam_wo_relations_rec1.parent_object_id := l_parent_wip_entity_id;
   		l_eam_wo_relations_rec1.parent_object_type_id := 1;
    		l_eam_wo_relations_rec1.parent_header_id := l_parent_wip_entity_id;
   		l_eam_wo_relations_rec1.child_object_type_id := 1;
   		l_eam_wo_relations_rec1.child_header_id    :=1;
     		l_eam_wo_relations_rec1.child_object_id    :=1;
		l_eam_wo_relations_rec1.parent_relationship_type  := 1;
                l_eam_wo_relations_rec1.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

                 l_eam_wo_relations_rec2.batch_id  :=  1;
  		 l_eam_wo_relations_rec2.parent_object_id := l_parent_wip_entity_id;
   		l_eam_wo_relations_rec2.parent_object_type_id := 1;
    		l_eam_wo_relations_rec2.parent_header_id := l_parent_wip_entity_id;
   		l_eam_wo_relations_rec2.child_object_type_id := 1;
   		l_eam_wo_relations_rec2.child_header_id    :=1;
     		l_eam_wo_relations_rec2.child_object_id    :=1;
		l_eam_wo_relations_rec2.parent_relationship_type  := 4;
                l_eam_wo_relations_rec2.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

         l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec1;
         l_eam_wo_relations_tbl(2) := l_eam_wo_relations_rec2;
           end if;
     --End of rebuild source
            l_workorder_rec.manual_rebuild_flag := 'Y';
            l_workorder_rec.asset_number := null;
            l_workorder_rec.asset_group_id := null;
          end if;

          l_workorder_rec.job_quantity := 1;
          l_workorder_rec.requested_start_date := p_scheduled_start_date;
          l_workorder_rec.owning_department := l_dept_id;
          l_workorder_rec.firm_planned_flag := l_firm;
          l_workorder_rec.scheduled_start_date := p_scheduled_start_date;
          l_workorder_rec.scheduled_completion_date := p_scheduled_completion_date;
          l_workorder_rec.status_type := l_status_type;
	  l_workorder_rec.user_defined_status_id := l_user_defined_status_type;
          l_workorder_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_workorder_rec.wip_supply_type := wip_constants.based_on_bom;
          l_workorder_rec.maintenance_object_id := l_maintenance_object_id;
  	  l_workorder_rec.maintenance_object_type := l_maintenance_object_type;
  	  l_workorder_rec.maintenance_object_source := l_maintenance_object_source;
  	  l_workorder_rec.asset_activity_id := l_asset_activity_id;
  	  l_workorder_rec.activity_type := to_char(p_activity_type);
  	  l_workorder_rec.activity_cause := to_char(p_activity_cause);
      	  l_workorder_rec.activity_source := to_char(p_activity_source);
      	  l_workorder_rec.shutdown_type := to_char(p_shutdown_type);
  	  l_workorder_rec.work_order_type := to_char(p_work_order_type);
          l_workorder_rec.priority := p_priority;
          l_workorder_rec.project_id := l_project_id;
          l_workorder_rec.task_id := l_task_id;
          l_workorder_rec.material_issue_by_mo := p_material_issue_by_mo;

	  /*Bug#4425025 - have date_released as null to enable defaulting in EAM_WO_DEFAULT_PVT*/
	  /* if (l_status_type = 3) then -- Set Date Released to be sysdate, if you want to
                                      -- Release the work order now
  	    l_workorder_rec.date_released := sysdate;
          end if;
	  */

          -- Set user id and responsibility id so that we can set apps context
          -- before calling any concurrent program
  	  l_workorder_rec.user_id := l_user_id;
          l_workorder_rec.responsibility_id := fnd_global.resp_id;

/* Added for bug #5453280 */
IF (p_failure_code_required IS NOT NULL) THEN

		       l_eam_failure_entry_record.failure_id   := p_failure_id;
		       l_eam_failure_entry_record.failure_date := p_failure_date;

		       l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		       l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		       l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		       l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		       l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		       l_eam_failure_codes_tbl(1).comments         := p_failure_comments;

		      l_fail_dept_id  := l_workorder_rec.owning_department;

	l_workorder_rec.failure_code_required := p_failure_code_required;

	l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
	l_eam_failure_entry_record.source_type := 1;
	l_eam_failure_entry_record.source_id := l_workorder_rec.wip_entity_id;
	l_eam_failure_entry_record.object_type := l_workorder_rec.maintenance_object_type;
	l_eam_failure_entry_record.object_id := l_workorder_rec.maintenance_object_id;
	l_eam_failure_entry_record.maint_organization_id := l_workorder_rec.organization_id;
	l_eam_failure_entry_record.current_organization_id := l_workorder_rec.organization_id;
	l_eam_failure_entry_record.department_id := l_fail_dept_id;
	l_eam_failure_entry_record.area_id := l_eam_location_id;

	if(l_eam_failure_entry_record.failure_date is null) then
	  l_eam_failure_entry_record.transaction_type :=null;
	end if;
	l_workorder_rec.eam_failure_entry_record := l_eam_failure_entry_record;

	l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
	if( not( l_eam_failure_codes_tbl(1).failure_code is null
		 and l_eam_failure_codes_tbl(1).cause_code is null
		 and l_eam_failure_codes_tbl(1).resolution_code is null
		 and l_eam_failure_codes_tbl(1).comments is null
		)
	    ) then
				l_workorder_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
	else
				l_eam_failure_codes_tbl.delete;
				l_workorder_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;
	end if;

End if; -- end of check for failure code required
/* End of change for bug #5453280 */

           l_eam_wo_tbl(1) := l_workorder_rec;

	    EAM_PROCESS_WO_PUB.l_eam_wo_list.delete; --Added for bug#4563210

           EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl
		, p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'createwoss.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'w'
           );

         l_workorder_rec1 :=  l_eam_wo_tbl1(1);

          x_return_status := l_return_status;
          -- End of Call to Work Order PL/SQL API

          EXCEPTION WHEN OTHERS THEN
            eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_GENERIC_ERROR',
              p_token1 => 'EAM_ERROR', p_value1 => SQLERRM);
            x_return_status := FND_API.G_RET_STS_ERROR;
      END;

    x_return_status := l_return_status;
    x_msg_count := FND_MSG_PUB.count_msg;

   if(x_return_status<>'S') then
       ROLLBACK TO create_easy_work_order;
       RAISE  FND_API.G_EXC_ERROR;
    end if;

 -- assign out parameters
      x_new_work_order_name := l_workorder_rec1.wip_entity_name;
      x_new_work_order_id := l_workorder_rec1.wip_entity_id;



BEGIN
 if(p_request_type=2) then

      	-- if service request is specified then insert into eam_wo_service_association
      	if (l_service_request_id is not null) then
      		select eam_wo_service_association_s.nextval
      		into l_service_association_id
      		from dual;

      		insert into eam_wo_service_association
      		(
      	   		wo_service_entity_assoc_id
      	   		,maintenance_organization_id
      	   		,wip_entity_id
      	   		,service_request_id
      	   		,last_update_date
      	   		,last_updated_by
      	   		,creation_date
      	   		,created_by
      	   		,last_update_login
			,enable_flag		-- Fix for Bug 3773450
      		)
      		values
      		(
      	  	 	l_service_association_id
      	  	 	,p_organization_id
      	  		,x_new_work_order_id
      	   		,l_service_request_id
      	   		,sysdate
        	   		,FND_GLOBAL.user_id
        	   		,sysdate
        	   		,FND_GLOBAL.user_id
        	   		,FND_GLOBAL.LOGIN_ID
				,'Y'		-- Fix for Bug 3773450

      		);
      	end if;
else
  if(p_request_type=1) then
      -- update work request if exist
      if( l_work_request_id is not null) then
        update wip_eam_work_requests r
        set r.work_request_status_id = 4
         , r.wip_entity_id = l_workorder_rec1.wip_entity_id
         , r.last_update_date = sysdate
         , r.last_updated_by = FND_GLOBAL.user_id
        where r.work_request_id = l_work_request_id;
      end if;
  end if;
end if;
EXCEPTION
      	WHEN OTHERS THEN
  	      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_EZWO_BAD_SERVICE_REQUEST');
        	x_return_status := FND_API.G_RET_STS_ERROR;

END;

       IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
          COMMIT WORK;
       END IF;



      if(p_sched_parent_wip_entity_id is not null)  then


           SAVEPOINT create_relationship;


		l_eam_wo_relations_rec3.batch_id  :=  1;
  		l_eam_wo_relations_rec3.parent_object_id := p_sched_parent_wip_entity_id;
    		l_eam_wo_relations_rec3.parent_object_type_id := 1;
     		l_eam_wo_relations_rec3.parent_header_id := p_sched_parent_wip_entity_id;
     		l_eam_wo_relations_rec3.child_object_type_id := 1;
     		l_eam_wo_relations_rec3.child_header_id    :=x_new_work_order_id;
     		l_eam_wo_relations_rec3.child_object_id    :=x_new_work_order_id;
     		l_eam_wo_relations_rec3.parent_relationship_type  := to_number(p_relationship_type);
     		l_eam_wo_relations_rec3.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

      		l_eam_wo_relations_tbl2(1) := l_eam_wo_relations_rec3;



               EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl2
                 , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl2
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'createrelss.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'w'
              );

          x_return_status := l_return_status;
          x_msg_count := FND_MSG_PUB.count_msg;

         if(x_return_status<>'S') then
              ROLLBACK TO create_relationship;
              RAISE  FND_API.G_EXC_ERROR;
         end if;

      end if;--End of creating relationship

      IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
          COMMIT WORK;
      END IF;


end if;   -- End of Create Work Order

    IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
          COMMIT WORK;
      END IF;

   EXCEPTION WHEN OTHERS THEN -- all dml excpetion
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_EXCEPTION'
        , p_token1 => 'TEXT', p_value1 => SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
         eam_execution_jsp.Get_Messages
           (p_encoded  => FND_API.G_FALSE,
            p_msg_index => 1,
            p_msg_count => l_msg_count,
            p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR) ,
            p_data      => l_data,
            p_msg_index_out => l_msg_index_out);
            x_msg_count :=  l_msg_count;
            x_msg_data  := l_msg_data;
      ELSE
         x_msg_count  :=  l_msg_count;
      END IF;
    END;  -- dml


 EXCEPTION
    WHEN
	FND_API.G_EXC_UNEXPECTED_ERROR  THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO create_easy_work_order;
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.CREATE_EASY_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO create_easy_work_order;
        END IF;

        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.CREATE_EASY_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN -- all dml excpetion
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO create_easy_work_order;
        END IF;

        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'eam_workorders_jsp.CREATE_EASY_WORK_ORDER',
        p_procedure_name => EAM_DEBUG.G_err_stack);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end create_ez_work_order;





  -----------------------------------------------------------------------------------
  -- update work order, not involved in changes that could invoke transaction
  -----------------------------------------------------------------------------------
  procedure update_work_order
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER
    ,p_description                 IN    VARCHAR2
    ,p_owning_department           IN    VARCHAR2
    ,p_priority                    IN    NUMBER
    ,p_shutdown_type               IN    VARCHAR2
    ,p_activity_type               IN    VARCHAR2
    ,p_activity_cause              IN    VARCHAR2
    ,p_firm_planned_flag           IN    NUMBER
    ,p_notification_required       IN    VARCHAR2
    ,p_tagout_required             IN    VARCHAR2
    ,p_scheduled_start_date        IN    DATE
    ,p_stored_last_update_date     IN    DATE
   ) IS
  l_api_name           CONSTANT VARCHAR(30) := 'update_work_order';
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
  l_err_number               NUMBER;

  l_new_status   NUMBER;
  l_db_status    NUMBER;
  l_db_last_update_date DATE;

  l_org_id        NUMBER;
  l_dept_id       NUMBER;
  l_shift         NUMBER;
  l_duration      NUMBER;

  BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT complete_workorder;
    END IF;

    eam_debug.init_err_stack('eam_workorders_jsp.update_work_order');

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
      SELECT last_update_date, status_type, organization_id
        , scheduled_completion_date - scheduled_start_date
        , p_scheduled_start_date - scheduled_start_date
      INTO   l_db_last_update_date, l_db_status , l_org_id , l_duration , l_shift
      FROM wip_discrete_jobs
      WHERE wip_entity_id = p_wip_entity_id
      FOR UPDATE;

      IF  l_db_last_update_date <> p_stored_last_update_date THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_STALED_DATA');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_NOT_FOUND');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    BEGIN
      select department_id
      into l_dept_id
      from bom_departments
      where organization_id = l_org_id
        and department_code = p_owning_department;

    EXCEPTION WHEN OTHERS THEN
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_DEPT_NOT_FOUND');
      x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    if( p_firm_planned_flag = 1) then
      if(p_scheduled_start_date is null) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_UPDATE_DATE_MISS');
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
    end if;

    -- if validate not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR) ,
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

    -- call processing logic
    BEGIN
      update wip_discrete_jobs j
      set j.description = p_description
        , j.activity_type = p_activity_type
        , j.activity_cause = p_activity_cause
        , j.owning_department = l_dept_id
        , j.priority = p_priority
        , j.shutdown_type = p_shutdown_type
        , j.firm_planned_flag = p_firm_planned_flag
        , j.notification_required = p_notification_required
        , j.tagout_required = p_tagout_required
        , j.last_update_date = sysdate
        , j.last_updated_by = g_last_updated_by
        , j.last_update_login = g_last_update_login
      where j.wip_entity_id = p_wip_entity_id;

      if( p_firm_planned_flag = 1 and l_shift <> 0) then -- firm
        -- update work order start and completion date
        update wip_discrete_jobs j
        set j.scheduled_start_date = p_scheduled_start_date
          , j.scheduled_completion_date = j.scheduled_completion_date + l_shift
        where j.wip_entity_id = p_wip_entity_id;

        -- shift operation dates
        update wip_operations op
          set op.first_unit_start_date = op.first_unit_start_date + l_shift
            , op.last_unit_start_date = op.last_unit_start_date + l_shift
            , op.first_unit_completion_date = op.first_unit_completion_date + l_shift
            , op.last_unit_completion_date = op.last_unit_completion_date + l_shift
            , op.last_update_date = sysdate
            , op.last_updated_by = g_last_updated_by
            , op.last_update_login = g_last_update_login
        where op.wip_entity_id = p_wip_entity_id;

        -- shift resources dates
        update wip_operation_resources wor
          set wor.start_date = wor.start_date + l_shift
            , wor.completion_date = wor.completion_date + l_shift
            , wor.last_update_date = sysdate
            , wor.last_updated_by = g_last_updated_by
            , wor.last_update_login = g_last_update_login
        where wor.wip_entity_id = p_wip_entity_id;
      end if;
    EXCEPTION WHEN OTHERS THEN
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_EXCEPTION'
          ,p_token1 => 'TEXT', p_value1 => SQLERRM);
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    -- if DML not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR) ,
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
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.update_work_order',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.update_work_order',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO complete_workorder;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_WORKORDERS_JSP.update_work_order',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_work_order;

  procedure get_completion_defaults (
     p_wip_entity_id in number
    ,p_tx_type in number
    ,p_sched_start_date in date
    ,p_sched_end_date in date
    ,x_start_date out NOCOPY date
    ,x_end_date out NOCOPY date
    ,x_return_status out NOCOPY varchar2
    ,x_msg_count out NOCOPY number
    ,x_msg_data out NOCOPY varchar2
   ) is
    l_api_name constant varchar2(30) := 'get_completion_defaults';
    l_max_op_end_date date := null;
    l_min_op_start_date date := null;
    l_sched_start_date date := null;
    l_sched_end_date date := null;

  begin
    eam_debug.init_err_stack('eam_workorders_jsp.' || l_api_name);

    --initialize so at sysdate is returned when 1) no completed operations exist
    -- 2) some other error takes place
    x_start_date := sysdate;
    x_end_date := sysdate;
    if (p_tx_type =  1) then --completion
      x_msg_data := 'Completion: ';
      if (p_sched_start_date is not null AND p_sched_end_date is not null) then
        l_sched_start_date := p_sched_start_date;
        l_sched_end_date := p_sched_end_date;
      else
        select scheduled_start_date, scheduled_completion_date
        into l_sched_start_date, l_sched_end_date
        from wip_discrete_jobs
        where wip_entity_id = p_wip_entity_id;
      end if;
      x_start_date := l_sched_start_date;
      x_end_date   := l_sched_end_date;   --fixed for #2429880.
      begin
      --fix for 3543834.changed queries to fetch correct data
      select max(actual_end_date)
      into l_max_op_end_date
      from eam_op_completion_txns eoct
      where wip_entity_id = p_wip_entity_id
      and transaction_type=1
      and transaction_id = (select max(transaction_id)
                          from eam_op_completion_txns
                          where wip_entity_id = p_wip_entity_id
                                and operation_seq_num = eoct.operation_seq_num
                                );

      select min(actual_start_date)
      into l_min_op_start_date
      from eam_op_completion_txns eoct
      where wip_entity_id = p_wip_entity_id
      and transaction_type=1
      and transaction_id = (select max(transaction_id)
                            from eam_op_completion_txns
                            where wip_entity_id = p_wip_entity_id
                                  and operation_seq_num = eoct.operation_seq_num
                                  );

        if (l_max_op_end_date is not null and l_min_op_start_date is not null) then
          x_start_date := l_min_op_start_date;
          x_end_date := l_max_op_end_date;
        end if;

        exception
          when others then
            x_msg_data := x_msg_data || 'No completed operations exist: ';
      end;
    end if; -- of p_tx_type = 1
    if (p_tx_type =  2) then --uncompletion
      x_msg_data := x_msg_data || 'Uncompletion: ';
      select actual_start_date, actual_end_date into
        x_start_date, x_end_date
        from eam_job_completion_txns
        where wip_entity_id = p_wip_entity_id
        and transaction_date = (
          select max(transaction_date)
          from eam_job_completion_txns where transaction_type = 1
          and wip_entity_id = p_wip_entity_id);
    end if;

    IF(x_start_date > SYSDATE) THEN
        x_start_date := SYSDATE;
	x_end_date   :=  SYSDATE;
   ELSIF (x_end_date > SYSDATE) THEN
         x_end_date   :=  SYSDATE;
   END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data := x_msg_data ||
     'x_start_date = ' || to_char(x_start_date, 'MMM-DD-YYYY HH24:MI:SS')
     || ', x_end_date = ' || to_char(x_end_date, 'MMM-DD-YYYY HH24:MI:SS')
     || ', l_max_op_end_date=' || to_char(l_max_op_end_date, 'MMM-DD-YYYY HH24:MI:SS')
     || ', l_sched_start_date=' || to_char(l_sched_start_date, 'MMM-DD-YYYY HH24:MI:SS')
     || ', l_sched_end_date=' || to_char(l_sched_end_date, 'MMM-DD-YYYY HH24:MI:SS');
  exception
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := x_msg_data || ' UNEXPECTED ERROR: ' || SQLERRM;
      eam_debug.init_err_stack('Exception has occured in ' || l_api_name);
  end get_completion_defaults;


    procedure Add_WorkOrder_Dependency (
      p_api_version                  IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_organization_id             IN    NUMBER
      ,p_prior_object_id	     IN	   NUMBER
      ,p_prior_object_type_id	     IN	   NUMBER
      ,p_next_object_id 	     IN	   NUMBER
      ,p_next_object_type_id	     IN	   NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     ) is

	l_api_name constant varchar2(30) := 'Add_WorkOrder_Dependency';
	l_api_version  CONSTANT NUMBER   := 1.0;
	l_msg_data VARCHAR2(10000) ;
	l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                 NUMBER;
	l_message_text               VARCHAR2(1000);

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_wo_tbl_1              EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_relations_tbl_1    EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_op_tbl_1              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl_1      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl_1             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl_1        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl_1         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_mat_req_tbl_1         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_direct_items_tbl_1    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

	l_eam_wo_relations_rec     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	 l_output_dir VARCHAR2(512);


	begin

	 IF p_commit = FND_API.G_TRUE THEN
	       SAVEPOINT CREATE_DEPENDENT_WORK_ORDER;
	 END IF;

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

	IF p_prior_object_id = 0000 OR p_next_object_id = 0000 THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_NOT_ENOUGH_VALUES');
	      	return;
	END IF;

  EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

       l_eam_wo_relations_rec.BATCH_ID                     :=1;
       l_eam_wo_relations_rec.WO_RELATIONSHIP_ID           :=null;
       l_eam_wo_relations_rec.PARENT_OBJECT_ID             :=p_prior_object_id;
       l_eam_wo_relations_rec.PARENT_OBJECT_TYPE_ID        :=1;
       l_eam_wo_relations_rec.PARENT_HEADER_ID             :=1;
       l_eam_wo_relations_rec.CHILD_OBJECT_ID              :=p_next_object_id;
       l_eam_wo_relations_rec.CHILD_OBJECT_TYPE_ID         :=1;
       l_eam_wo_relations_rec.CHILD_HEADER_ID              :=2;
       l_eam_wo_relations_rec.PARENT_RELATIONSHIP_TYPE     :=2;
       l_eam_wo_relations_rec.RELATIONSHIP_STATUS          :=null;
       l_eam_wo_relations_rec.TOP_LEVEL_OBJECT_ID          :=null;
       l_eam_wo_relations_rec.TOP_LEVEL_OBJECT_TYPE_ID     :=1;
       l_eam_wo_relations_rec.TOP_LEVEL_HEADER_ID          :=1;
       l_eam_wo_relations_rec.RETURN_STATUS                :=null;
       l_eam_wo_relations_rec.TRANSACTION_TYPE             :=EAM_PROCESS_WO_PUB.G_OPR_CREATE;

       l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;




       EAM_PROCESS_WO_PUB.l_eam_wo_list.delete; --Added for bug#4563210


     EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO
        (  p_bo_identifier => 'EAM'
         , p_api_version_number=>  1.0
         , p_init_msg_list =>  TRUE
         , p_eam_wo_relations_tbl =>   l_eam_wo_relations_tbl
         , p_eam_wo_tbl           =>   l_eam_wo_tbl
         , p_eam_op_tbl           =>   l_eam_op_tbl
         , p_eam_op_network_tbl   =>   l_eam_op_network_tbl
         , p_eam_res_tbl          =>   l_eam_res_tbl
         , p_eam_res_inst_tbl     =>   l_eam_res_inst_tbl
         , p_eam_sub_res_tbl      =>   l_eam_sub_res_tbl
	 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , p_eam_mat_req_tbl      =>   l_eam_mat_req_tbl
	 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl
	 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	, p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_wo_tbl           =>   l_eam_wo_tbl_1
         , x_eam_wo_relations_tbl =>   l_eam_wo_relations_tbl_1
         , x_eam_op_tbl           =>   l_eam_op_tbl_1
         , x_eam_op_network_tbl   =>   l_eam_op_network_tbl_1
         , x_eam_res_tbl          =>   l_eam_res_tbl_1
         , x_eam_res_inst_tbl     =>   l_eam_res_inst_tbl_1
         , x_eam_sub_res_tbl      =>   l_eam_sub_res_tbl_1
	 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , x_eam_mat_req_tbl      =>   l_eam_mat_req_tbl
	 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1
	  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
	 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
	 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
	 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
	 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
	 , x_eam_request_tbl          => l_out_eam_request_tbl
         , x_return_status        =>   l_return_status
         , x_msg_count            =>   l_msg_count
       --   , x_error_msg_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
         , p_commit               =>   FND_API.G_TRUE
        , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	, p_debug_filename          => 'adddepen.log'
        , p_output_dir              => l_output_dir
         , p_debug_file_mode         => 'W'
       );


	l_msg_count := FND_MSG_PUB.count_msg;
	x_return_status := l_return_status;
	x_msg_count := l_msg_count;


      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF p_commit = FND_API.G_TRUE THEN
	          ROLLBACK TO CREATE_DEPENDENT_WORK_ORDER;
         END IF;
        fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => l_message_text,
                    p_msg_index_out => l_msg_count);
           fnd_message.set_name('EAM','EAM_ERROR_UPDATE_WO');

           fnd_message.set_token(token => 'MESG',
             value => l_message_text,
             translate => FALSE);
             APP_EXCEPTION.RAISE_EXCEPTION;

      END IF;

      IF p_commit = FND_API.G_TRUE THEN
         COMMIT WORK;
     end if;

    EXCEPTION

          when others then
	 IF p_commit = FND_API.G_TRUE THEN
		  ROLLBACK TO CREATE_DEPENDENT_WORK_ORDER;
         END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            return;


end Add_WorkOrder_Dependency;


  procedure Delete_WorkOrder_Dependency (
      p_api_version                 IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_organization_id             IN    NUMBER
      ,p_prior_object_id	     IN	   NUMBER
      ,p_prior_object_type_id	     IN	   NUMBER
      ,p_next_object_id 	     IN	   NUMBER
      ,p_next_object_type_id	     IN	   NUMBER
      ,p_relationship_type           IN NUMBER := 2
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     ) is

	l_api_name constant varchar2(30) := 'Delete_WorkOrder_Dependency';
	l_api_version  CONSTANT NUMBER   := 1.0;

	-- All in parameters
	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	-- All Out parateres
	l_out_eam_wo_tbl              EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_out_eam_wo_relations_tbl    EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_out_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_out_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_out_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_out_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_out_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_out_eam_mat_req_tbl         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl_1    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_relations_rec     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;

	l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                 NUMBER;
	l_message_text               VARCHAR2(1000);
	l_output_dir VARCHAR2(512);
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

	begin

	 IF p_commit = FND_API.G_TRUE THEN
	       SAVEPOINT DELETE_DEPENDEND_WORK_ORDER;
	 END IF;

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

	    l_eam_wo_relations_rec.BATCH_ID                     :=1;
	    l_eam_wo_relations_rec.WO_RELATIONSHIP_ID           :=null;
	    l_eam_wo_relations_rec.PARENT_OBJECT_ID             :=p_prior_object_id;
	    l_eam_wo_relations_rec.PARENT_OBJECT_TYPE_ID        :=p_prior_object_type_id;
	    l_eam_wo_relations_rec.PARENT_HEADER_ID             :=1;
	    l_eam_wo_relations_rec.CHILD_OBJECT_ID              :=p_next_object_id;
	    l_eam_wo_relations_rec.CHILD_OBJECT_TYPE_ID         :=p_next_object_type_id;
	    l_eam_wo_relations_rec.CHILD_HEADER_ID              :=2;
	    l_eam_wo_relations_rec.PARENT_RELATIONSHIP_TYPE     :=p_relationship_type;
	    l_eam_wo_relations_rec.RELATIONSHIP_STATUS          :=null;
	    l_eam_wo_relations_rec.TOP_LEVEL_OBJECT_ID          :=null;
	    l_eam_wo_relations_rec.TOP_LEVEL_OBJECT_TYPE_ID     :=1;
	    l_eam_wo_relations_rec.TOP_LEVEL_HEADER_ID          :=1;
	    l_eam_wo_relations_rec.RETURN_STATUS                :=null;
	    l_eam_wo_relations_rec.TRANSACTION_TYPE             :=EAM_PROCESS_WO_PUB.G_OPR_DELETE;


	    l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;

	eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
		 ( p_bo_identifier           => 'EAM'
		 , p_init_msg_list           => TRUE
		 , p_api_version_number      => 1.0
		 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
		 , p_eam_wo_tbl              => l_eam_wo_tbl
		 , p_eam_op_tbl              => l_eam_op_tbl
		 , p_eam_op_network_tbl      => l_eam_op_network_tbl
		 , p_eam_res_tbl             => l_eam_res_tbl
		 , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
		 , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
	 	 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
		 , x_eam_wo_tbl              => l_out_eam_wo_tbl
		 , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
		 , x_eam_op_tbl              => l_out_eam_op_tbl
		 , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
		 , x_eam_res_tbl             => l_out_eam_res_tbl
		 , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
		 , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
		 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
		, x_return_status        =>   l_return_status
	         , x_msg_count            =>   l_msg_count
	      -- , x_error_msg_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
	         , p_commit               =>   p_commit
           , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
    	  , p_debug_filename          => 'deldepen.log'
          , p_output_dir              => l_output_dir
          , p_debug_file_mode         => 'W'
	         );


		l_msg_count := FND_MSG_PUB.count_msg;
		x_return_status := l_return_status;
		x_msg_count := l_msg_count;

	 IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		  IF p_commit = FND_API.G_TRUE THEN
			  ROLLBACK TO DELETE_DEPENDEND_WORK_ORDER;
		  END IF;

		    fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
			    p_encoded   => 'F',
	                    p_data      => l_message_text,
		            p_msg_index_out => l_msg_count);
	           fnd_message.set_name('EAM','EAM_ERROR_UPDATE_WO');

		   fnd_message.set_token(token => 'MESG',
		       value => l_message_text,
		       translate => FALSE);

	          APP_EXCEPTION.RAISE_EXCEPTION;
        ELSE
	  IF FND_API.TO_BOOLEAN(p_commit)THEN
  	   COMMIT WORK;
          END IF;
        END IF;


      EXCEPTION

          when others then
	 IF p_commit = FND_API.G_TRUE THEN
		  ROLLBACK TO DELETE_DEPENDEND_WORK_ORDER;
        END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            return;
end Delete_WorkOrder_Dependency;

   -- Start of comments
   -- API name    : create_cost_hierarchy_pvt
   -- Type     :  Private.
   -- Function : Creates the costing hierarchy from the scheduling hierarchy.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER
   --          p_init_msg_list    IN VARCHAR2 Default = FND_API.G_TRUE
   --          p_commit           IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER Default = FND_API.G_VALID_LEVEL_FULL
   --          p_top_level_object_id IN VARCHAR2
   -- OUT      x_return_status      OUT NOCOPY  NUMBER
   --          x_msg_count	    OUT	NOCOPY NUMBER
   --          x_msg_data           OUT	NOCOPY VARCHAR2
   -- Notes    : The procedure gets the entire work hierarchy for the required top_level_object_id.
   --          It then passes the child workorder and the parent Work order to the Process_Master_Child_WO
   --          in the EAM_PROCESS_WO_PUB, to generate the costing relationship between the 2 workorders
   --
   -- End of comments
 procedure create_cost_hierarchy_pvt(
        p_api_version           IN NUMBER :=1.0  ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_TRUE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
        p_wip_entity_id IN VARCHAR2,
	p_org_id IN VARCHAR2,
        x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2
   )
IS
   --Bug3545056: Import hierarchy only under the workorder.
   CURSOR c_work_hierarchy IS
     SELECT child_object_id,
            parent_object_id,
	    PARENT_RELATIONSHIP_TYPE
      FROM  EAM_WO_RELATIONSHIPS
      WHERE parent_relationship_type = 1
      START WITH parent_object_id = p_wip_entity_id
         AND parent_relationship_type = 1
      CONNECT BY parent_object_id = PRIOR child_object_id
         AND parent_relationship_type = 1;

    l_workorder_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec1 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec2 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_workorder_rec3 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl1  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_tbl2  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl1  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_op_network_tbl2  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl1  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_tbl2  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl1  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_res_inst_tbl2  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl1   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_sub_res_tbl2   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl1  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_usage_tbl2  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl1   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_tbl2   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_wip_entity_id            NUMBER;
      --Bug3592712: Max length of workorder name is 240 char.
      l_wip_entity_name          VARCHAR2(240);

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_rec      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec1      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;

	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl3               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;

	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

       l_eam_msg_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
       l_old_rebuild_source  NUMBER;

   l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

  l_parent_id   NUMBER;
  l_child_wip_id  NUMBER;

  l_api_name       CONSTANT VARCHAR2(30) := 'create_cost_hierarchy_pvt';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
  l_parent_object_id NUMBER := null;
  l_output_dir VARCHAR2(512);


BEGIN
   SAVEPOINT create_cost_hierarchy;

   IF NOT FND_API.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.g_ret_sts_success;

   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

   FOR c_hierarchy_row IN c_work_hierarchy
   LOOP
     BEGIN
       -- Delete any parent for the current work order having type 3 relationship, to create the new one.


       SELECT parent_object_id INTO l_parent_object_id
       FROM EAM_WO_RELATIONSHIPS
       WHERE parent_relationship_type = 3
       AND child_object_id = c_hierarchy_row.child_object_id;



       -- Delete the record if exists. The child WO cannot have more than 1 parent.
       EAM_WORKORDERS_JSP.Delete_WorkOrder_Dependency (
	     p_commit  => FND_API.G_TRUE
	     ,p_prior_object_type_id => 1
	     ,p_next_object_type_id => 1
	     ,p_organization_id  => p_org_id
	     ,p_prior_object_id  => l_parent_object_id
	     ,p_next_object_id => c_hierarchy_row.child_object_id
	     ,p_relationship_type    => 3
	     ,x_return_status   => x_return_status
	    ,x_msg_count => x_msg_count
	    ,x_msg_data => x_msg_data
	     );


	 IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     /* Create a new relationship between the parent and the child workorder taken from the scheduling hierarchy. */
	       l_parent_id := c_hierarchy_row.parent_object_id ;
	       l_child_wip_id := c_hierarchy_row.child_object_id ;
	       l_eam_wo_relations_rec.batch_id  :=  1;
	       l_eam_wo_relations_rec.parent_object_id :=  l_parent_id;
	       l_eam_wo_relations_rec.parent_object_type_id := 1;
	       l_eam_wo_relations_rec.parent_header_id :=  l_parent_id;
	       l_eam_wo_relations_rec.child_object_type_id := 1;
	       l_eam_wo_relations_rec.child_header_id    :=l_child_wip_id;
	       l_eam_wo_relations_rec.child_object_id    :=l_child_wip_id;
	       l_eam_wo_relations_rec.parent_relationship_type  := 3;
	       l_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

	       l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;

               EAM_PROCESS_WO_PUB.Process_Master_Child_WO(
		  p_bo_identifier           => 'EAM'
		 , p_init_msg_list           => TRUE
		 , p_api_version_number      => 1.0
		 , p_eam_wo_tbl              => l_eam_wo_tbl2
		 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
		 , p_eam_op_tbl              => l_eam_op_tbl
		 , p_eam_op_network_tbl      => l_eam_op_network_tbl
		 , p_eam_res_tbl             => l_eam_res_tbl
		 , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
		 , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
		 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
		 , x_eam_wo_tbl              => l_eam_wo_tbl1
		 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
		 , x_eam_op_tbl              => l_eam_op_tbl1
		 , x_eam_op_network_tbl      => l_eam_op_network_tbl1
		 , x_eam_res_tbl             => l_eam_res_tbl1
		 , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
		 , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
		 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
		 , x_return_status           => x_return_status
		 , x_msg_count               => x_msg_count
		 , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		 , p_debug_filename          => 'deletecosthier.log'
		 , p_output_dir              => l_output_dir
		 , p_commit                  => p_commit
		 , p_debug_file_mode         => 'A'
		);

	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
	ELSE
	   -- if there is any exception then rollback and come out of the procedure.
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     EXCEPTION
        -- If there is no parent with type '3' for the workorder, then simply create a new relationship.
        WHEN NO_DATA_FOUND THEN


               -- create the new parent child costing relationship if it does not exist.
	       l_parent_id := c_hierarchy_row.parent_object_id ;
	       l_child_wip_id := c_hierarchy_row.child_object_id ;
	       l_eam_wo_relations_rec.batch_id  :=  1;
	       l_eam_wo_relations_rec.parent_object_id :=  l_parent_id;
	       l_eam_wo_relations_rec.parent_object_type_id := 1;
	       l_eam_wo_relations_rec.parent_header_id :=  l_parent_id;
	       l_eam_wo_relations_rec.child_object_type_id := 1;
	       l_eam_wo_relations_rec.child_header_id    :=l_child_wip_id;
	       l_eam_wo_relations_rec.child_object_id    :=l_child_wip_id;
	       l_eam_wo_relations_rec.parent_relationship_type  := 3;
	       l_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

	       l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;
	       EAM_PROCESS_WO_PUB.Process_Master_Child_WO(
		  p_bo_identifier           => 'EAM'
		 , p_init_msg_list           => TRUE
		 , p_api_version_number      => 1.0
		 , p_eam_wo_tbl              => l_eam_wo_tbl2
		 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
		 , p_eam_op_tbl              => l_eam_op_tbl
		 , p_eam_op_network_tbl      => l_eam_op_network_tbl
		 , p_eam_res_tbl             => l_eam_res_tbl
		 , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
		 , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		, p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
		 , x_eam_wo_tbl              => l_eam_wo_tbl1
		 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
		 , x_eam_op_tbl              => l_eam_op_tbl1
		 , x_eam_op_network_tbl      => l_eam_op_network_tbl1
		 , x_eam_res_tbl             => l_eam_res_tbl1
		 , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
		 , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
		 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		, x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
		, x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		, x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		, x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		, x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		, x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		, x_eam_request_tbl          => l_out_eam_request_tbl
		 , x_return_status           => x_return_status
		 , x_msg_count               => x_msg_count
		 , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		 , p_debug_filename          =>'createcosthier.log'
		 , p_output_dir              => l_output_dir
		 , p_commit                  => p_commit
		 , p_debug_file_mode         => 'A'
		);

	     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
       WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
   END LOOP;



   IF ((FND_API.TO_BOOLEAN(p_commit)) AND (x_return_status = FND_API.G_RET_STS_SUCCESS)) THEN
          COMMIT WORK;
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
        ROLLBACK TO create_cost_hierarchy;
        FND_MSG_PUB.add_exc_msg( p_pkg_name => l_full_name,
                                 p_procedure_name => l_api_name);
     WHEN OTHERS THEN
       ROLLBACK TO create_cost_hierarchy;
       FND_MSG_PUB.add_exc_msg( p_pkg_name => l_full_name,
                                p_procedure_name => l_api_name);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END create_cost_hierarchy_pvt;

   -- Start of comments
   -- API name    : resize_wo_edit_hierarchy_pvt
   -- Type     :  Private.
   -- Function : Insert the hierarchy into the CST_EAM_HIERARCHY_SNAPSHOT table.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER
   --          p_init_msg_list    IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER Default = FND_API.G_VALID_LEVEL_FULL
   --          p_object_id        IN NUMBER
   --          p_object_type_id   IN NUMBER
   --          p_schedule_start_date IN DATE
   --          p_schedule_end_date   IN DATE
   --          p_requested_start_date IN DATE := NULL
   --	       p_requested_due_date IN DATE := NULL
   --          p_duration_for_shifting IN NUMBER
   --          p_firm IN NUMBER
   -- OUT      x_return_status      OUT NOCOPY  NUMBER
   --          x_msg_count	    OUT	NOCOPY NUMBER
   --          x_msg_data           OUT	NOCOPY VARCHAR2
   -- Notes    : The procedure sees if the dates being passed are >= current date.
   --          Consider only schedule start and end date if schedule start date,end date and duration
   --          is entered.If any 2 is given calculate the other and pass the Start Date and End Date
   --          to the API to resize the workorder.
   --
   -- End of comments

/*Bug3521886: Pass requested start date and due date*/
 PROCEDURE resize_wo_hierarchy_pvt(
	p_api_version           IN NUMBER   ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_TRUE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 	p_object_id 	IN NUMBER,
	p_object_type_id IN NUMBER,
	p_schedule_start_date 	IN DATE,
	p_schedule_end_date 	IN DATE,
	p_duration_for_shifting	IN NUMBER,
        p_requested_start_date IN DATE := NULL ,
	p_requested_due_date IN DATE := NULL,
	p_firm IN NUMBER,
	p_org_id IN VARCHAR2,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2
   ) IS

   l_schedule_start_date DATE := p_schedule_start_date;
   l_schedule_end_date DATE := p_schedule_end_date;
   l_api_name VARCHAR2(100) := 'resize_wo_hierarchy_pvt';
   l_msg_data VARCHAR2(10000) ;
   l_api_version NUMBER := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT resize_wo_hierarchy_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
         ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.g_ret_sts_success;

      -- API body
     IF (p_schedule_end_date IS NULL) THEN
       l_schedule_end_date := p_schedule_start_date + (p_duration_for_shifting / 24);
     ELSIF  (l_schedule_start_date IS NULL) THEN
       l_schedule_start_date := p_schedule_end_date - (p_duration_for_shifting / 24);
     END IF;

     -- Call the API to
     EAM_WO_NETWORK_DEFAULT_PVT.Resize_WO(
		p_api_version => 1.0 ,
		p_object_id => p_object_id,
		p_object_type_id => 1,
		p_start_date => l_schedule_start_date,
		p_completion_date => l_schedule_end_date,
     /*Bug3521886: Pass requested start date and due date*/
		p_required_start_date => p_requested_start_date,
		p_required_due_date => p_requested_due_date,
		p_org_id  => p_org_id,
		p_firm    => p_firm ,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);
      -- End of API body
      IF (x_return_status = FND_API.g_ret_sts_success) THEN
        IF FND_API.TO_BOOLEAN(p_commit)THEN
  	   COMMIT WORK;
        END IF;
      END IF;


      FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);
       IF x_msg_count > 0 THEN
	    FOR indexCount IN 1 ..x_msg_count
	    LOOP
	      l_msg_data := FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
	     -- DBMS_OUTPUT.PUT_LINE(indexCount ||'-'||l_msg_data);
	    END LOOP;
	  END IF;

   EXCEPTION
      WHEN OTHERS THEN
	ROLLBACK TO resize_wo_hierarchy_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;



 END resize_wo_hierarchy_pvt;
end EAM_WORKORDERS_JSP;

/
