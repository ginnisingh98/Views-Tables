--------------------------------------------------------
--  DDL for Package Body EAM_IMPORT_WORKORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_IMPORT_WORKORDERS" AS
/* $Header: EAMIMPWB.pls 120.3.12010000.6 2009/10/30 13:46:37 srkotika ship $ */


   /*********************************************************
    Wrapper procedure on top of WO API.This is used to update valid imported workorders and its related entities
    ************************************************/
PROCEDURE import_workorders
(
      p_commit                      IN    VARCHAR2      := FND_API.G_FALSE,
      p_eam_wo_tbl		IN			EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
      p_eam_wo_relations_tbl     IN            EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
      p_eam_op_tbl               IN                    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
      p_eam_res_tbl              IN                   EAM_PROCESS_WO_PUB.eam_res_tbl_type,
      p_eam_res_inst_tbl     IN			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
      p_eam_res_usage_tbl      IN              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_eam_mat_req_tbl         IN                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type,
      p_eam_direct_items_tbl    IN             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type,
      p_eam_request_tbl           IN              EAM_PROCESS_WO_PUB.eam_request_tbl_type,
      p_eam_wo_comp_tbl		 IN		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type,
      p_eam_meter_reading_tbl   IN		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type,
      p_eam_counter_prop_tbl    IN	 EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type,
      p_eam_wo_comp_rebuild_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type,
      p_eam_wo_comp_mr_read_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type,
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
)
IS
      l_eam_wo_tbl					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_wo_tbl_p			EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_wo_rec					EAM_PROCESS_WO_PUB.eam_wo_rec_type;

      l_eam_op_tbl          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_res_tbl					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_inst_tbl    EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;

      l_eam_op_tbl_p          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_res_tbl_p					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_inst_tbl_p    EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;

      l_eam_op_rec               EAM_PROCESS_WO_PUB.eam_op_rec_type;
      l_eam_res_rec              EAM_PROCESS_WO_PUB.eam_res_rec_type;
      l_eam_res_inst_rec         EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;

      l_eam_op_network_tbl		   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_sub_res_tbl				   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_op_comp_tbl				   EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_wo_comp_tbl				   EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_comp_rec				   EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;

      l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_wo_quality_tbl				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		  l_eam_meter_reading_tbl    EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		  l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
		  l_eam_wo_comp_rebuild_tbl  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		  l_eam_wo_comp_mr_read_tbl  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		  l_eam_request_tbl          EAM_PROCESS_WO_PUB.eam_request_tbl_type;

      l_eam_wo_relations_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
      l_eam_wo_rec_out					EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_wo_tbl_out					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_op_tbl_out					EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl_out				EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl_out					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_usage_tbl_out				EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl_out				EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl_out				EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl_out				EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl_out			EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_wo_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_quality_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
      l_eam_meter_reading_tbl_out			EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
      l_eam_counter_prop_tbl_out			EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
      l_eam_wo_comp_rebuild_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
      l_eam_wo_comp_mr_read_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
      l_eam_op_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_request_tbl_out				EAM_PROCESS_WO_PUB.eam_request_tbl_type;
      l_eam_wo_comp_rec_out				EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;

     l_wip_entity_id            NUMBER;
     l_asset_serial_number      VARCHAR2(30);  /*bug 892512*/
     l_op_index                 NUMBER :=1;
     l_res_index                NUMBER :=1;
     l_res_inst_index                NUMBER :=1;

     l_return_status     VARCHAR2(1);
	   l_msg_count         NUMBER;
     l_output_dir                      VARCHAR2(512);

BEGIN

   /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

    l_eam_wo_tbl := p_eam_wo_tbl;

    l_eam_op_tbl       := p_eam_op_tbl;
    l_eam_res_tbl      := p_eam_res_tbl;
    l_eam_res_inst_tbl := p_eam_res_inst_tbl;


    IF l_eam_wo_tbl.COUNT > 0 THEN
			FOR J IN l_eam_wo_tbl.FIRST..l_eam_wo_tbl.LAST LOOP
      SAVEPOINT   import_workorders;
             l_eam_wo_rec := l_eam_wo_tbl(J);

             l_op_index := 1;
             l_res_index := 1;
             l_res_inst_index := 1;


        l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
        l_eam_wo_rec.batch_id := 1;
        l_eam_wo_rec.header_id := 1;

         l_wip_entity_id :=  l_eam_wo_rec.wip_entity_id;
         l_eam_wo_rec.attribute15 := NULL;  -- this att was made to import for diverting the flow from rossetta api, remove this after adding a new var in l_eam_wo_rec

          /*bug 8925120 l_eam_wo_rec.asset_number has instance number pushed from primavera, change it to (msn)serial_number*/
         SELECT asset_number INTO l_asset_serial_number FROM wip_discrete_jobs
         WHERE wip_entity_id= l_wip_entity_id AND organization_id=l_eam_wo_rec.organization_id;

         l_eam_wo_rec.asset_number := l_asset_serial_number;
        /*bug 8925120 end */


        l_eam_wo_tbl_p(1) := l_eam_wo_rec;  -- tsp
        --g_eam_wo_tbl0(1) := g_eam_wo_rec1;



       IF(l_eam_op_tbl.Count>0) THEN
         IF(l_eam_op_tbl_p.Count >0) THEN
           l_eam_op_tbl_p.delete(l_eam_op_tbl_p.FIRST,l_eam_op_tbl_p.last); -- remove all prev job's elements
         END IF;
        FOR O IN l_eam_op_tbl.FIRST..l_eam_op_tbl.LAST LOOP
            l_eam_op_rec := l_eam_op_tbl(O);
          IF(l_eam_op_rec.WIP_ENTITY_ID = l_wip_entity_id)  THEN
          l_eam_op_rec.TRANSACTION_TYPE := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
            l_eam_op_tbl_p(l_op_index) := l_eam_op_rec; --tsp
            l_op_index := l_op_index+1;
          END IF;
        END LOOP;
       END IF;

      IF(l_eam_res_tbl.Count >0) THEN
        IF(l_eam_res_tbl_p.Count > 0)THEN
          l_eam_res_tbl_p.delete(l_eam_res_tbl_p.first,l_eam_res_tbl_p.last); -- remove all prev job's elements
        END IF;
        FOR R IN l_eam_res_tbl.FIRST..l_eam_res_tbl.LAST LOOP
           l_eam_res_rec := l_eam_res_tbl(R);
         IF(l_eam_res_rec.WIP_ENTITY_ID = l_wip_entity_id)  THEN
         l_eam_res_rec.TRANSACTION_TYPE := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
            l_eam_res_tbl_p(l_res_index) := l_eam_res_rec;
            l_res_index := l_res_index+1;
         END IF;
        END LOOP;
       END IF;

       IF(l_eam_res_inst_tbl.Count>0) THEN
        IF(l_eam_res_inst_tbl_p.Count > 0) THEN
          l_eam_res_inst_tbl_p.delete(l_eam_res_inst_tbl_p.first,l_eam_res_inst_tbl_p.last); -- remove all prev job's elements
        END IF;

        FOR I IN l_eam_res_inst_tbl.FIRST..l_eam_res_inst_tbl.LAST LOOP
            l_eam_res_inst_rec := l_eam_res_inst_tbl(I);
         IF(l_eam_res_inst_rec.WIP_ENTITY_ID = l_wip_entity_id)  THEN
         /* l_eam_res_inst_rec.TRANSACTION_TYPE := EAM_PROCESS_WO_PVT.G_OPR_SYNC; /*modified for primavera*/

            l_eam_res_inst_tbl_p(l_res_inst_index) := l_eam_res_inst_rec;
            l_res_inst_index := l_res_inst_index+1;
         END IF;
        END LOOP;
       END IF;

        x_wip_entity_id := NULL;
    EAM_PROCESS_WO_PUB.PROCESS_WO(
		  p_bo_identifier			=>'EAM'
		, p_api_version_number    => 1.0
		, p_init_msg_list			=>  TRUE
		, p_eam_wo_rec			    => l_eam_wo_rec
		, p_eam_op_tbl			   => l_eam_op_tbl_p
		, p_eam_op_network_tbl     => l_eam_op_network_tbl
		, p_eam_res_tbl                   => l_eam_res_tbl_p
		, p_eam_res_inst_tbl          => l_eam_res_inst_tbl_p
		, p_eam_res_usage_tbl     => p_eam_res_usage_tbl
		, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		, p_eam_mat_req_tbl          => p_eam_mat_req_tbl
		, p_eam_direct_items_tbl    => p_eam_direct_items_tbl
		, p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     =>    p_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl   => p_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl            => l_eam_op_comp_tbl
		, p_eam_request_tbl            => p_eam_request_tbl
		, x_eam_wo_rec	               => l_eam_wo_rec_out
		, x_eam_op_tbl                 => l_eam_op_tbl_out
		, x_eam_op_network_tbl         => l_eam_op_network_tbl_out
		, x_eam_res_tbl                => l_eam_res_tbl_out
		, x_eam_res_usage_tbl          => l_eam_res_usage_tbl_out
		, x_eam_res_inst_tbl           => l_eam_res_inst_tbl_out
		, x_eam_sub_res_tbl            => l_eam_sub_res_tbl_out
		, x_eam_mat_req_tbl           => l_eam_mat_req_tbl_out
		, x_eam_direct_items_tbl     => l_eam_direct_items_tbl_out
		, x_eam_wo_comp_rec         => l_eam_wo_comp_rec_out
		, x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_out
		, x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_out
		, x_eam_counter_prop_tbl        =>  l_eam_counter_prop_tbl_out
		, x_eam_wo_comp_rebuild_tbl    =>  l_eam_wo_comp_rebuild_tbl_out
		, x_eam_wo_comp_mr_read_tbl    => l_eam_wo_comp_mr_read_tbl_out
		, x_eam_op_comp_tbl	 => l_eam_op_comp_tbl_out
		, x_eam_request_tbl	 => l_eam_request_tbl_out
		, x_return_status	 => x_return_status
		, x_msg_count		 => x_msg_count
		, p_commit			=> 'N'
		, p_debug			=> NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		, p_output_dir			=> l_output_dir
		, p_debug_filename		=> 'createupdatewo.log'
		, p_debug_file_mode		=> 'W'
		);

  IF(x_return_status='S') THEN
		IF p_commit = FND_API.G_TRUE THEN
			COMMIT WORK;
		end if;
		IF(l_eam_wo_tbl_out IS NOT NULL AND l_eam_wo_tbl_out.COUNT>0) THEN
			x_wip_entity_id := l_eam_wo_tbl_out(l_eam_wo_tbl_out.FIRST).wip_entity_id;
                ELSIF(l_eam_wo_rec_out.wip_entity_id IS NOT NULL) THEN
                        x_wip_entity_id := l_eam_wo_rec_out.wip_entity_id;
		END IF;
	END IF;

	IF(x_return_status <> 'S') THEN
     	     ROLLBACK TO import_workorders;
	END IF;

 END LOOP;
 END IF;

END import_workorders;

END eam_import_workorders;


/
