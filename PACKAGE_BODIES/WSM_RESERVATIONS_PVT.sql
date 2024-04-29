--------------------------------------------------------
--  DDL for Package Body WSM_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_RESERVATIONS_PVT" as
/* $Header: WSMVRSVB.pls 120.16 2006/06/21 10:17:28 sisankar noship $ */

/* Package name  */
g_pkg_name 	       VARCHAR2(20) := 'WSM_RESERVATIONS_PVT';

type t_wsm_rsv_v_tbl_type is table of wsm_reservations_v%rowtype index by binary_integer;
type t_wsm_reservations is table of wsm_reservations%rowtype index by binary_integer;
--type r_mtl_rsv_rec_type is record of mtl_reservations%rowtype;
--MP: Sale order changes
l_mtl_rsv_rec 	inv_reservation_global.mtl_maintain_rsv_rec_type;

g_log_level_unexpected 	NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error 	NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error 	NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success 	NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success	        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error	        VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;


Procedure modify_reservations_wlt (	p_txn_header 		IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
					p_starting_jobs_tbl 	IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
					p_resulting_jobs_tbl 	IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
					p_rep_job_index 	IN	   NUMBER,
					p_sj_also_rj_index   	IN 	   NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2 )  IS
l_rsv_old  	inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new  	inv_reservation_global.mtl_reservation_rec_type;
--l_mtl_rsv_rec 	inv_reservations_global.mtl_rsv_tbl_type;
l_wsm_rsv_v_tbl t_wsm_rsv_v_tbl_type;
l_dummy_sn  	inv_reservation_global.serial_number_tbl_type;
l_new_rsv_id   	NUMBER;
l_rsv_exists 	boolean;
l_rsvd_qty	number;
l_rj_index	number;

/* Status variables */
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level	    number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num	    NUMBER;
l_module            CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_RESERVATIONS_PVT.modify_reservations_wlt';
l_param_tbl	    WSM_Log_PVT.param_tbl_type;

l_msg_index	number;
l_quantity_modified  	NUMBER;
l_expected_quantity_uom VARCHAR2(3);
-- Logging variables...

begin

	l_wsm_rsv_v_tbl.delete;

	-- Have a starting point --
	savepoint start_modify_rsv_wlt;

	l_stmt_num := 10;
	/*  Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_txn_header.organization_id);

	--First query to check if any reservations asscoiated with the starting job from the calling procedure itself--
	--now the reservation processing begins
		l_rsv_old.supply_source_header_id := p_starting_jobs_tbl(p_rep_job_index).wip_entity_id;
		l_rsv_old.inventory_item_id := p_starting_jobs_tbl(p_rep_job_index).primary_item_id;
		l_rsv_old.organization_id := p_starting_jobs_tbl(p_rep_job_index).organization_id;
		l_rsv_old.supply_source_type_id := 5; --MP Sale order changes

	If  p_txn_header.transaction_type_id = WSMPCNST.UPDATE_ASSEMBLY then
		--Write to WIE  'Note: Starting job is reserved against sales order(s). Update Assembly transaction
		--will result in deletion of the starting job reservations
		--Write warning into concurrent log
		fnd_message.set_name('WSM','WSM_RSV_UPD_ASSY');
		l_msg_data := fnd_message.get;
		fnd_file.put_line(fnd_file.log,l_msg_data);

		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count     := 0;
		l_msg_data      := null;

		l_msg_index := fnd_msg_pub.count_msg;

		--MP Delete Changes Start
		BEGIN
			select *
			bulk collect into l_wsm_rsv_v_tbl
			from wsm_reservations_v
			where wip_entity_id = p_starting_jobs_tbl(p_rep_job_index).wip_entity_id;
		EXCEPTION
			when no_data_found then
				return;
		END;
		--MP Delete Changes End
		If l_wsm_rsv_v_tbl.count > 0 then --MP Delete Changes
		For i in l_wsm_rsv_v_tbl.first .. l_wsm_rsv_v_tbl.last loop --MP Delete Changes
		l_rsv_old.reservation_id := l_wsm_rsv_v_tbl(i).reservation_id;
		--log proc entry
		inv_reservation_pub.delete_reservation
		   (
		      p_api_version_number        => 1.0
		    , p_init_msg_lst              => fnd_api.g_true
		    , x_return_status             => l_return_status
		    , x_msg_count                 => l_msg_count
		    , x_msg_data                  => l_msg_data
		    , p_rsv_rec                   => l_rsv_old
		    , p_serial_number             => l_dummy_sn
		    );

		--proc exit
		if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
			/*API failed*/
			WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
			--log that rsv api failed
			IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
				l_msg_tokens.delete;
				WSM_log_PVT.logMessage (p_module_name	    => l_module	,
							p_msg_text	    => 'inv_reservation_pub.delete_reservation failed',
							p_stmt_num	    => l_stmt_num		,
							p_msg_tokens	    => l_msg_tokens		,
							p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
							p_run_log_level	    => l_log_level
							);
			END IF;

			IF l_return_status = fnd_api.g_ret_sts_error THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		end if;
		end loop; --MP Delete Changes
		end if; --MP Delete Changes :End of check on l_wsm_rsv_v_tbl.count > 0
	Elsif p_txn_header.transaction_type_id = WSMPCNST.SPLIT then
		--First query to check if any reservations asscoiated with the starting job in the calling pgm itself--
		--Check if parent job is resulting job.
		--If yes, then check if there is update of assembly.
		--If yes, then write to WIE  'Note: Starting job is reserved against sales order(s).Update Assembly transaction will result in deletion of the starting job reservations'
		--and call inv_reservation_pub.delete_reservation
		--Else, compare starting job's net qty with net qty of same job in resulting jobs.
		--Write to WIE 'Note: New net quantity is less than the starting job's reserved quantity.This transaction will result in reduction in reserved quantity' and Call reduce_reservations( );
		--populate l_rsv_old record with the reservation details of the SJ.
		--populate l_mtl_rsv record with the RJ details for Supply source info and new quantity info.
		--if parent job is not a resulting job, then write to WIE  'Note: Starting job isnot a resulting job.The reservations against sales order(s) for this job will be deleted..

		If (p_sj_also_rj_index is not null) then

			If p_resulting_jobs_tbl(p_sj_also_rj_index).split_has_update_assy = 1 then
				--Write warning into concurrent log
				fnd_message.set_name('WSM','WSM_RSV_UPD_ASSY');
				l_msg_data := fnd_message.get;
				fnd_file.put_line(fnd_file.log,l_msg_data);

				l_return_status := FND_API.G_RET_STS_SUCCESS;
				l_msg_count     := 0;
				l_msg_data      := null;

				l_msg_index := fnd_msg_pub.count_msg;

				--log proc entry
				--MP Delete Changes Start
				BEGIN
					select *
					bulk collect into l_wsm_rsv_v_tbl
					from wsm_reservations_v
					where wip_entity_id = p_starting_jobs_tbl(p_rep_job_index).wip_entity_id;
				EXCEPTION
					when no_data_found then
						return;
				END;
				--MP Delete Changes End
		             --MP Delete Changes
			     If l_wsm_rsv_v_tbl.count > 0 then --MP Delete Changes
		              For i in l_wsm_rsv_v_tbl.first .. l_wsm_rsv_v_tbl.last loop
		              l_rsv_old.reservation_id := l_wsm_rsv_v_tbl(i).reservation_id;
				inv_reservation_pub.delete_reservation
				   (
				      p_api_version_number        => 1.0
				    , p_init_msg_lst              => fnd_api.g_true
				    , x_return_status             => l_return_status
				    , x_msg_count                 => l_msg_count
				    , x_msg_data                  => l_msg_data
				    , p_rsv_rec                   => l_rsv_old
				    , p_serial_number             => l_dummy_sn
				    );

				if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
					--API failed--
					WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
					--log that rsv api failed
					IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
						l_msg_tokens.delete;
						WSM_log_PVT.logMessage (p_module_name	    => l_module	,
									p_msg_text	    => 'inv_reservation_pub.delete_reservation failed',
									p_stmt_num	    => l_stmt_num		,
									p_msg_tokens	    => l_msg_tokens		,
									p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
									p_run_log_level	    => l_log_level
									);
					END IF;

					IF l_return_status = fnd_api.g_ret_sts_error THEN
						RAISE fnd_api.g_exc_error;
					ELSE
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				end if;
				end loop; --MP delete reservations loop
			        end if; --MP Delete Changes :End of check on l_wsm_rsv_v_tbl.count > 0
			--Elsif (p_starting_jobs_tbl(p_starting_jobs_tbl.first).net_quantity > p_resulting_jobs_tbl(p_sj_also_rj_index).net_quantity) then
			ELSE
			   l_rsvd_qty := Wsm_reservations_pvt.check_reservation_quantity(
                                     p_wip_entity_id =>  p_resulting_jobs_tbl(p_sj_also_rj_index).wip_entity_id,
				     P_org_id => p_starting_jobs_tbl(p_rep_job_index).organization_id,
				     P_inventory_item_id => p_starting_jobs_tbl(p_rep_job_index).primary_item_id
				   );
			   IF l_rsvd_qty > p_resulting_jobs_tbl(p_sj_also_rj_index).net_quantity then
				--Write warning into concurrent log
				fnd_message.set_name('WSM','WSM_RSV_SPLIT');
				l_msg_data := fnd_message.get;
				fnd_file.put_line(fnd_file.log,l_msg_data);

				l_mtl_rsv_rec.action := 0;
				l_mtl_rsv_rec.organization_id := p_starting_jobs_tbl(p_starting_jobs_tbl.first).organization_id;
				l_mtl_rsv_rec.inventory_item_id := p_starting_jobs_tbl(p_starting_jobs_tbl.first).primary_item_id;
				l_mtl_rsv_rec.supply_source_type_id := 5;
				l_mtl_rsv_rec.supply_source_header_id := p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_id;
				l_mtl_rsv_rec.supply_source_line_id := null;
				l_mtl_rsv_rec.expected_quantity := p_resulting_jobs_tbl(p_sj_also_rj_index).net_quantity;

				select primary_uom_code
				into l_expected_quantity_uom --l_mtl_rsv_rec.expected_quantity_uom
				from mtl_system_items
				where inventory_item_id =l_mtl_rsv_rec.inventory_item_id-- p_starting_jobs_tbl(p_starting_jobs_tbl.first).primary_item_id
				and organization_id = l_mtl_rsv_rec.organization_id; --p_starting_jobs_tbl(p_starting_jobs_tbl.first).organization_id;


				l_mtl_rsv_rec.expected_quantity_uom := l_expected_quantity_uom;

				l_return_status := FND_API.G_RET_STS_SUCCESS;
				l_msg_count     := 0;
				l_msg_data      := null;

				l_msg_index := fnd_msg_pub.count_msg;
				--log proc entry
				inv_maintain_reservation_pub.reduce_reservation
				(
					   x_return_status            	=> l_return_status
					 , x_msg_count                	=> l_msg_count
					 , x_msg_data                 	=> l_msg_data
					 , x_quantity_modified	  	=> l_quantity_modified
					 , p_api_version_number     	=> 1.0
					 , p_init_msg_lst             	=> fnd_api.g_false
					 , p_mtl_maintain_rsv_rec       => l_mtl_rsv_rec
					 , p_delete_flag		=> 'N'
					 , p_sort_by_criteria		=> null
				 );

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
					--API failed--
					WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
					--log that rsv api failed
					IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
						l_msg_tokens.delete;
						WSM_log_PVT.logMessage (p_module_name	    => l_module	,
									p_msg_text	    => 'inv_reservation_pub.reduce_reservation failed',
									p_stmt_num	    => l_stmt_num		,
									p_msg_tokens	    => l_msg_tokens		,
									p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
									p_run_log_level	    => l_log_level
									);
					END IF;
					IF l_return_status = fnd_api.g_ret_sts_error THEN
						RAISE fnd_api.g_exc_error;
					ELSE
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				END IF;
			    END IF;
			End if;
		Else --parent job not resulting job
			--Write warning into concurrent log
			fnd_message.set_name('WSM','WSM_RSV_SPLIT');
			l_msg_data := fnd_message.get;
			fnd_file.put_line(fnd_file.log,l_msg_data);

			l_return_status := FND_API.G_RET_STS_SUCCESS;
			l_msg_count     := 0;
			l_msg_data      := null;

			l_msg_index := fnd_msg_pub.count_msg;
			--log proc entry
				--MP Delete Changes Start
			BEGIN
				select *
				bulk collect into l_wsm_rsv_v_tbl
				from wsm_reservations_v
				where wip_entity_id = p_starting_jobs_tbl(p_rep_job_index).wip_entity_id;
			EXCEPTION
				when no_data_found then
					return;
			END;
			--MP Delete Changes End
		        --MP Delete Changes
		       If l_wsm_rsv_v_tbl.count > 0 then --MP Delete Changes
		          For i in l_wsm_rsv_v_tbl.first .. l_wsm_rsv_v_tbl.last loop
		          l_rsv_old.reservation_id := l_wsm_rsv_v_tbl(i).reservation_id;
			--log proc entry
			inv_reservation_pub.delete_reservation
			   (
			      p_api_version_number        => 1.0
			    , p_init_msg_lst              => fnd_api.g_true
			    , x_return_status             => l_return_status
			    , x_msg_count                 => l_msg_count
			    , x_msg_data                  => l_msg_data
			    , p_rsv_rec                   => l_rsv_old
			    , p_serial_number             => l_dummy_sn
			    );
			--log return

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
				--API failed--
				WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
				--log that rsv api failed
				IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
					l_msg_tokens.delete;
					WSM_log_PVT.logMessage (p_module_name	    => l_module	,
								p_msg_text	    => 'inv_reservation_pub.delete_reservation failed',
								p_stmt_num	    => l_stmt_num		,
								p_msg_tokens	    => l_msg_tokens		,
								p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
								p_run_log_level	    => l_log_level
								);
				END IF;
				IF l_return_status = fnd_api.g_ret_sts_error THEN
					RAISE fnd_api.g_exc_error;
				ELSE
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;
			end loop; --MP delete reservations loop
			end if; --MP Delete Changes :End of check on l_wsm_rsv_v_tbl.count > 0

		End if;
	Elsif p_txn_header.transaction_type_id = WSMPCNST.MERGE then
		l_rj_index := p_resulting_jobs_tbl.first;
		-- Check if parent rep job is resulting job.
		--If yes, for each job having assembly same as resulting job and reservation exists, call transfer_reservation ( ) to tranfser reservation to the resulting job.
		--Else, for each job having assembly same as resulting job and reservation exists, call transfer_reservation ( ) to transfer reservations to new resulting job.
		--If any starting job has reservation and assembly is different from rep-job,
		--write to WIE 'Note: One or more Starting jobs with an assembly different from that of the representative job are reserved against sales order.
		--Merge transaction will result in deletion of the reservations of these starting jobs.'
		update wip_discrete_jobs
		set    net_quantity = start_quantity
		where  wip_entity_id = p_resulting_jobs_tbl(l_rj_index).wip_entity_id;

		For l_counter in p_starting_jobs_tbl.first.. p_starting_jobs_tbl.last loop

			--If p_sj_also_rj_index is null OR p_sj_also_rj_index <> l_counter then


			If p_sj_also_rj_index is null OR p_rep_job_index <> l_counter then

				l_rsv_exists := check_reservation_exists(p_wip_entity_id	=>	p_starting_jobs_tbl(l_counter).wip_entity_id,
									 p_org_id	 	=>	p_starting_jobs_tbl(l_counter).organization_id ,
									 p_inventory_item_id 	=>	p_starting_jobs_tbl(l_counter).primary_item_id
									 );

				If l_rsv_exists then

					If p_starting_jobs_tbl(l_counter).primary_item_id = p_starting_jobs_tbl(p_rep_job_index).primary_item_id then

						--collect the SO rsv for the SJ from wsm_rsv_v
						BEGIN
							select *
							bulk collect into l_wsm_rsv_v_tbl
							from wsm_reservations_v
							where wip_entity_id = p_starting_jobs_tbl(l_counter).wip_entity_id;
						EXCEPTION
							when no_data_found then
								null;
						END;

						if l_wsm_rsv_v_tbl.count>0 then
							--For each SO rsvn in wsm_reservations_v for p_starting_jobs_tbl (l_counter) loop
							For i in l_wsm_rsv_v_tbl.first .. l_wsm_rsv_v_tbl.last loop

								--old reservation info populated
								l_rsv_old.reservation_id := l_wsm_rsv_v_tbl(i).reservation_id;
								--these might not be needed as reservation_id itself would be sufficient--
								l_rsv_old.supply_source_header_id := p_starting_jobs_tbl(l_counter).wip_entity_id;
								l_rsv_old.supply_source_type_id := inv_reservation_global.g_source_type_wip;
								l_rsv_old.inventory_item_id := p_starting_jobs_tbl(l_counter).primary_item_id;
								l_rsv_old.organization_id := p_starting_jobs_tbl(l_counter).organization_id;

								--Transfer to resulting job;
								--l_rj_index := p_resulting_jobs_tbl.first;
								l_rsv_new.supply_source_header_id := p_resulting_jobs_tbl(l_rj_index).wip_entity_id;
								l_rsv_new.supply_source_type_id := inv_reservation_global.g_source_type_wip;

								l_return_status := FND_API.G_RET_STS_SUCCESS;
								l_msg_count     := 0;
								l_msg_data      := null;

								l_msg_index := fnd_msg_pub.count_msg;

								inv_reservation_pub.transfer_reservation(
								 p_api_version_number        => 1.0
								, p_init_msg_lst              => fnd_api.g_true
								, x_return_status             => l_return_status
								, x_msg_count                 => l_msg_count
								, x_msg_data                  => l_msg_data
								, p_is_transfer_supply        => fnd_api.g_true
								, p_original_rsv_rec          => l_rsv_old --SJ details
								, p_to_rsv_rec                => l_rsv_new --RJ details
								, p_original_serial_number    => l_dummy_sn -- no serial contorl
								, p_to_serial_number          => l_dummy_sn -- no serial control
								, p_validation_flag           => fnd_api.g_true
								, x_to_reservation_id            => l_new_rsv_id
								 );

								--proc exit
								if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
									--API failed--
									WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
									--log that rsv api failed
									IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
										l_msg_tokens.delete;
										WSM_log_PVT.logMessage (p_module_name	    => l_module	,
													p_msg_text	    => 'inv_reservation_pub.transfer_reservation failed',
													p_stmt_num	    => l_stmt_num		,
													p_msg_tokens	    => l_msg_tokens		,
													p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
													p_run_log_level	    => l_log_level
													);
									END IF;
									IF l_return_status = fnd_api.g_ret_sts_error THEN
										RAISE FND_API.G_EXC_ERROR;
									ELSE
										RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
									END IF;
								end if;

							End loop;
						end if;
					Else
						--Write warning into concurrent log
						fnd_message.set_name('WSM','WSM_RSV_MERGE');
						l_msg_data := fnd_message.get;
						fnd_file.put_line(fnd_file.log,l_msg_data);

						l_rsv_old.supply_source_header_id := p_starting_jobs_tbl(l_counter).wip_entity_id;
						l_rsv_old.inventory_item_id := p_starting_jobs_tbl(l_counter).primary_item_id;
						l_rsv_old.organization_id := p_starting_jobs_tbl(l_counter).organization_id;
						l_rsv_old.supply_source_type_id := 5;

						l_return_status := FND_API.G_RET_STS_SUCCESS;
						l_msg_count     := 0;
						l_msg_data      := null;

						l_msg_index := fnd_msg_pub.count_msg;
						--log proc entry
				--MP Delete Changes Start
				                BEGIN
				                	select *
				                	bulk collect into l_wsm_rsv_v_tbl
				                	from wsm_reservations_v
				                	where wip_entity_id = p_starting_jobs_tbl(l_counter).wip_entity_id;
				                EXCEPTION
				                	when no_data_found then
				                		return;
				                END;
				                --MP Delete Changes End
					--MP Delete Changes
				                If l_wsm_rsv_v_tbl.count > 0 then --MP Delete Changes
					        For i in l_wsm_rsv_v_tbl.first .. l_wsm_rsv_v_tbl.last loop
					        l_rsv_old.reservation_id := l_wsm_rsv_v_tbl(i).reservation_id;
						inv_reservation_pub.Delete_reservation    (
						      p_api_version_number        => 1.0
						    , p_init_msg_lst              => fnd_api.g_true
						    , x_return_status             => l_return_status
						    , x_msg_count                 => l_msg_count
						    , x_msg_data                  => l_msg_data
						    , p_rsv_rec                   => l_rsv_old
						    , p_serial_number             => l_dummy_sn
						    );

						--proc exit
						if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
							--API failed--
							WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
							--log that rsv api failed
							IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
								l_msg_tokens.delete;
								WSM_log_PVT.logMessage (p_module_name	    => l_module	,
											p_msg_text	    => 'inv_reservation_pub.reduce_reservation failed',
											p_stmt_num	    => l_stmt_num		,
											p_msg_tokens	    => l_msg_tokens		,
											p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
											p_run_log_level	    => l_log_level
											);
							END IF;
							IF l_return_status = fnd_api.g_ret_sts_error THEN
								RAISE FND_API.G_EXC_ERROR;
							ELSE
								RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
							END IF;
						end if;
						end loop; --MP delete reservations loop
			                        end if; --MP Delete Changes :End of check on l_wsm_rsv_v_tbl.count > 0

					End if;
				End if;
			End if;
		End loop;

		update wip_discrete_jobs
		set    net_quantity = p_resulting_jobs_tbl(l_rj_index).net_quantity
		where  wip_entity_id = p_resulting_jobs_tbl(l_rj_index).wip_entity_id;

		l_rsvd_qty :=  check_reservation_quantity(
                                              p_wip_entity_id	     =>	p_resulting_jobs_tbl(l_rj_index).wip_entity_id,
					      p_org_id	 	     =>	p_resulting_jobs_tbl(l_rj_index).organization_id ,
					      p_inventory_item_id    =>	p_resulting_jobs_tbl(l_rj_index).primary_item_id
					      );
                if l_rsvd_qty > p_resulting_jobs_tbl(l_rj_index).net_quantity THEN
		 l_return_status := FND_API.G_RET_STS_SUCCESS;
                 l_msg_count     := 0;
                 l_msg_data     := null;
                 WSM_RESERVATIONS_PVT.Modify_reservations_jobupdate(
                                                 p_wip_entity_id         => p_resulting_jobs_tbl(l_rj_index).wip_entity_id,
                                                 P_old_net_qty           => l_rsvd_qty, --p_resulting_jobs_tbl(l_rj_index).net_quantity,
                                                 P_new_net_qty           => p_resulting_jobs_tbl(l_rj_index).net_quantity,
                                                 P_inventory_item_id     => p_resulting_jobs_tbl(l_rj_index).primary_item_id,
                                                 P_org_id                => p_txn_header.organization_id,
                                                 P_status_type           => p_resulting_jobs_tbl(l_rj_index).status_type,
                                                 x_return_status         => l_return_status,
                                                 x_msg_count             => l_msg_count,
                                                 x_msg_data              => l_msg_data
                                                 ); --this is to handle the change in net qty if any.
		if l_return_status <> fnd_api.g_ret_sts_success then
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
                 end if;
	       END IF; --Check on reserved quantity > net_quantity
	end if;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
	(   p_encoded		=>      'F'		,
	    p_count             =>      x_msg_count   ,
            p_data              =>      x_msg_data
	);

	x_return_status:=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO start_modify_rsv_wlt;
		x_return_status := G_RET_ERROR;
		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO start_modify_rsv_wlt;
		x_return_status := G_RET_UNEXPECTED;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
	WHEN OTHERS THEN

		 ROLLBACK TO start_modify_rsv_wlt;
		 x_return_status := G_RET_UNEXPECTED;

		 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)		 OR
		   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
		THEN
			WSM_log_PVT.handle_others( p_module_name	    => l_module			,
						   p_stmt_num		    => l_stmt_num		,
						   p_fnd_log_level     	    => G_LOG_LEVEL_UNEXPECTED	,
						   p_run_log_level	    => l_log_level
						 );
		END IF;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
end;

Procedure modify_reservations_move (	p_wip_entity_id 	IN 	   NUMBER,
					P_inventory_item_id  	IN 	   NUMBER,
					P_org_id 		IN         NUMBER,
					P_txn_type 		IN 	   NUMBER,
					P_net_qty 		IN 	   NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2)
is
l_rsv_old  		inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new 		inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn  		inv_reservation_global.serial_number_tbl_type;
--l_mtl_rsv_rec 	inv_reservations_global.mtl_rsv_tbl_type;
l_wsm_rsvn_tbl		t_wsm_reservations;

l_new_rsv_id    	NUMBER;
l_quantity_modified  	NUMBER;

/* Status variables */
l_return_status  	VARCHAR2(1);
l_msg_count      	NUMBER;
l_msg_data       	VARCHAR2(2000);

l_rsvd_qty 		NUMBER := -1;
l_reservation_quantity	NUMBER := -1;

l_status_type   NUMBER;  -- Added for bug 5286219

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level	    number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num	    NUMBER;
l_module            CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_ITEM_PVT.ProcA';
l_param_tbl	    WSM_Log_PVT.param_tbl_type;

l_msg_index	    number;
-- Logging variables...


begin
/*First query to check if any reservations asscoiated with the starting job in the calling pgm itself by calling the function check_reservation_exists*/
/*Call this proc only if txn_type not in (1,4),ie,normal move or undo. */
	l_wsm_rsvn_tbl.delete;

	/* Have a starting point*/
	savepoint start_modify_rsv_move;

	l_stmt_num := 10;
	/*  Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/*have this call wherever wsm_reservations_v is used*/
	--MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_org_id);

	l_rsv_new.supply_source_header_id := p_wip_entity_id;
	--l_rsv_new.inventory_item_id :=p_inventory_item_id;
	--l_rsv_new.organization_id := p_org_id;

	If p_txn_type = 2 then --completion txn

		--Insert the reservations for this job in the WSM_RESERVATIONS table.Before that check if the reserved qty against the job is more than what exactly the job has at completion.If that is the case,reduce reservations associated with the job.

		l_rsvd_qty := check_reservation_quantity(p_wip_entity_id 	=> p_wip_entity_id,
							P_org_id 		=> p_org_id,
							P_inventory_item_id 	=> p_inventory_item_id
							) ;
		If l_rsvd_qty > p_net_qty then
			fnd_message.set_name('WSM','WSM_NET_QTY_LOW');
			l_msg_data := fnd_message.get;
			fnd_file.put_line(fnd_file.log,l_msg_data);

			l_mtl_rsv_rec.action := 0;
			l_mtl_rsv_rec.organization_id := p_org_id;
			l_mtl_rsv_rec.inventory_item_id := p_inventory_item_id;
			l_mtl_rsv_rec.supply_source_type_id := 5;
			l_mtl_rsv_rec.supply_source_header_id := p_wip_entity_id;
			l_mtl_rsv_rec.supply_source_line_id := null;
			l_mtl_rsv_rec.expected_quantity := p_net_qty;

			select primary_uom_code
		        into l_mtl_rsv_rec.expected_quantity_uom
		        from mtl_system_items
		        where inventory_item_id =l_mtl_rsv_rec.inventory_item_id
		        and organization_id = l_mtl_rsv_rec.organization_id;

			l_return_status := FND_API.G_RET_STS_SUCCESS;
			l_msg_count     := 0;
			l_msg_data      := null;

			l_msg_index := fnd_msg_pub.count_msg;

			--inv_reservation_pub.reduce_reservations (
			--					x_return_status            	=> l_return_status
			--					, x_msg_count                	=>l_msg_count
			--					, x_msg_data                 	=>l_msg_data
			--					, x_quantity_modified	  	=> l_quantity_modified
			--					, p_api_version_number     	=>1.0
			--					, p_init_msg_lst             	=>fnd_api.g_false
			--					, p_mtl_rsv_rec                 =>l_mtl_rsv_rec
			--					, delete_flag			=>'N'
			--					);
			--
			--proc exit
			inv_maintain_reservation_pub.reduce_reservation
				(
					   x_return_status            	=> l_return_status
					 , x_msg_count                	=> l_msg_count
					 , x_msg_data                 	=> l_msg_data
					 , x_quantity_modified	  	=> l_quantity_modified
					 , p_api_version_number     	=> 1.0
					 , p_init_msg_lst             	=> fnd_api.g_false
					 , p_mtl_maintain_rsv_rec       => l_mtl_rsv_rec
					 , p_delete_flag		=> 'N'
					 , p_sort_by_criteria		=> null
				 );
			if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
				/*API failed*/
				WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
				--log that rsv api failed
				IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
					l_msg_tokens.delete;
					WSM_log_PVT.logMessage (p_module_name	    => l_module	,
								p_msg_text	    => 'inv_reservation_pub.reduce_reservation failed',
								p_stmt_num	    => l_stmt_num		,
								p_msg_tokens	    => l_msg_tokens		,
								p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
								p_run_log_level	    => l_log_level
								);
				END IF;
				IF l_return_status = fnd_api.g_ret_sts_error THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSE
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			end if;

		End if;

		INSERT INTO wsm_reservations (
				Wip_entity_id,
				Reservation_id,
				Demand_source_header_id,
				Demand_source_line_id,
				Reserved_qty)
		(select wip_entity_id,
			reservation_id,
			demand_source_header_id,
			demand_source_line_id,
			primary_quantity
		from wsm_reservations_v
		where wip_entity_id= p_wip_entity_id
		and organization_id = p_org_id
		and inventory_item_id = p_inventory_item_id
		);

	Elsif p_txn_type = 3 then --return transaction

		--Check if entries exist for this job in WSM_RESERVATIONS table. If yes, go to nxt step. Else, return.
		BEGIN
			select *
			bulk collect into l_wsm_rsvn_tbl
			from wsm_reservations
			where wip_entity_id = p_wip_entity_id;

		EXCEPTION
			when no_data_found then
				return;
		END;
		--If (entry exists in WSM_RESERVATIONS for this job) then
		If l_wsm_rsvn_tbl.count > 0  then

		--Check if demand exists by querying the mtl_reservations table. If yes, then query the corresponding demand and supply details from history table and call create_reservations( ) to create them again against the job.

		-- Added for Bug 5286219. Temporarily changing the status type of the job to
		-- Released status so that reservation can be transferred from inventory back to LBJ.

		BEGIN
			select status_type
			into l_status_type
			from wip_discrete_jobs
			where wip_entity_id = p_wip_entity_id
			and organization_id = p_org_id;

			update wip_discrete_jobs
			set status_type = 3
			where wip_entity_id = p_wip_entity_id
			and organization_id = p_org_id;
		EXCEPTION
			when no_data_found then
				return;
		END;

			--For each SO reservation against the job in WSM_RESERVATIONS loop
			For j in l_wsm_rsvn_tbl.first .. l_wsm_rsvn_tbl.last loop

				BEGIN
					select primary_reservation_quantity
					into l_reservation_quantity
					from mtl_reservations
					where reservation_id = l_wsm_rsvn_tbl(j).reservation_id;
				EXCEPTION
					when no_data_found then
						l_reservation_quantity := -1;
				END;

				If l_reservation_quantity <> -1 then
				--Transfer_reservation to job A with l_rsv_new.reservation_qty = min (mtl_reservations.reservation_qty, wsm_reservations.reserved_qty)
				--Call the API as below.

					--populate l_rsv_old record with reservation details against the inventory for this SO from mtl_reservations.
					l_rsv_old.reservation_id := l_wsm_rsvn_tbl(j).reservation_id;

					--populate l_rsv_new record with changed reservation details against this job for this SO from wsm_reservations.
					l_rsv_new.supply_source_header_id := p_wip_entity_id;
					l_rsv_new.supply_source_type_id := 5;
					l_rsv_new.subinventory_code := null;
					l_rsv_new.locator_id := null;
					l_rsv_new.lot_number := NULL;
					l_rsv_new.primary_reservation_quantity :=l_wsm_rsvn_tbl(j).Reserved_qty;
					IF l_reservation_quantity < l_rsv_new.primary_reservation_quantity THEN
					    l_rsv_new.primary_reservation_quantity := l_reservation_quantity;
					END IF;

					l_return_status := FND_API.G_RET_STS_SUCCESS;
					l_msg_count     := 0;
					l_msg_data      := null;

					l_msg_index := fnd_msg_pub.count_msg;

					inv_reservation_pub.transfer_reservation( p_api_version_number        => 1.0
										, p_init_msg_lst              => fnd_api.g_true
										, x_return_status             => l_return_status
										, x_msg_count                 => l_msg_count
										, x_msg_data                  => l_msg_data
										, p_is_transfer_supply        => fnd_api.g_true
										, p_original_rsv_rec          => l_rsv_old
										, p_to_rsv_rec                => l_rsv_new
										, p_original_serial_number    => l_dummy_sn -- no serial contorl
										, p_to_serial_number          => l_dummy_sn -- no serial control
										, p_validation_flag           => fnd_api.g_true
										, x_to_reservation_id            => l_new_rsv_id
										 );

					 --proc exit
					 if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
						/*API failed*/
						WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
						--log that rsv api failed
						IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
							l_msg_tokens.delete;
							WSM_log_PVT.logMessage (p_module_name	    => l_module	,
										p_msg_text	    => 'inv_reservation_pub.transfer_reservation failed',
										p_stmt_num	    => l_stmt_num		,
										p_msg_tokens	    => l_msg_tokens		,
										p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
										p_run_log_level	    => l_log_level
										);
						END IF;
						IF l_return_status = fnd_api.g_ret_sts_error THEN
							RAISE FND_API.G_EXC_ERROR;
						ELSE
							RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
						END IF;
					 END IF;

				END IF;
			END LOOP;

			-- Added for Bug 5286219. Restoring back the status type of the job to original
			-- status before it was updated to Released for trf the reservation.

			update wip_discrete_jobs
			set status_type = l_status_type
			where wip_entity_id = p_wip_entity_id
			and organization_id = p_org_id;

		end if;
			/*now delete the rows corresponding to this job in wsm_reservations*/
			delete from wsm_reservations
			where wip_entity_id = p_wip_entity_id;
	end if;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
	(   p_encoded		=>      'F'		,
	    p_count             =>      x_msg_count   ,
            p_data              =>      x_msg_data
	);

	x_return_status:=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO start_modify_rsv_move;
		x_return_status := G_RET_ERROR;
		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO start_modify_rsv_move;
		x_return_status := G_RET_UNEXPECTED;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
	WHEN OTHERS THEN

		 ROLLBACK TO start_modify_rsv_move;
		 x_return_status := G_RET_UNEXPECTED;

		 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)		 OR
		   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
		THEN
			WSM_log_PVT.handle_others( p_module_name	    => l_module			,
						   p_stmt_num		    => l_stmt_num		,
						   p_fnd_log_level     	    => G_LOG_LEVEL_UNEXPECTED	,
						   p_run_log_level	    => l_log_level
						 );
		END IF;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
end;

Procedure modify_reservations_jobupdate (p_wip_entity_id 	IN         NUMBER,
					P_old_net_qty 		IN 	   NUMBER ,
					P_new_net_qty 		IN 	   NUMBER,
					P_inventory_item_id 	IN 	   NUMBER,
					P_org_id 		IN 	   NUMBER,
					P_status_type 		IN         NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2)
is
l_rsv  			inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn  		inv_reservation_global.serial_number_tbl_type;
--l_mtl_rsv_rec 		inv_reservations_global.mtl_rsv_tbl_type;

l_rsv_id   		NUMBER;
l_rsv_exists 		number := 0;
l_expected_quantity_uom varchar2(3);
l_quantity_modified     number;

/* Status variables */
l_return_status  	VARCHAR2(1);
l_msg_count      	NUMBER;
l_msg_data       	VARCHAR2(2000);

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level	    number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num	    NUMBER;
l_module            CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSM_RESERVATIONS_PVT.modify_reservations_jobupdate';
l_param_tbl	    WSM_Log_PVT.param_tbl_type;

l_msg_index	    number;
-- Logging variables...


begin
/*First query to check if any reservations asscoiated with the starting job in the calling pgm itself*/

	/* Have a starting point*/
	savepoint start_modify_rsv_jobupdate;

	l_stmt_num := 10;
	/*  Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/*have this call wherever wsm_reservations_v is used*/
	--MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_org_id);

	l_rsv.supply_source_header_id := p_wip_entity_id;
	l_rsv.inventory_item_id :=p_inventory_item_id;
	l_rsv.organization_id := p_org_id;
	l_rsv.supply_source_type_id := 5;
	-- If condition Modified for bug 5290496
	If p_new_net_qty < p_old_net_qty and p_status_type <> 7 and p_new_net_qty <>0 then
		-- In case of interface,Write to WIE 'Note: Available quantity of the job is below the net quantity.'
		fnd_message.set_name('WSM','WSM_NET_QTY_LOW');
		l_msg_data := fnd_message.get;
		fnd_file.put_line(fnd_file.log,l_msg_data);

		--l_mtl_rsv_rec.action := 1;
		--l_mtl_rsv_rec.organization_id := p_org_id;
		--l_mtl_rsv_rec.inventory_item_id := p_inventory_item_id;
		--l_mtl_rsv_rec.supply_source_type_id := 5;
		--l_mtl_rsv_rec.supply_source_header_id := p_wip_entity_id;
		--l_mtl_rsv_rec.supply_source_line_id := null;
		--l_mtl_rsv_rec.expected_quantity := p_new_net_qty;

		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count     := 0;
		l_msg_data      := null;

		l_msg_index := fnd_msg_pub.count_msg;

		--inv_reservation_pub.reduce_reservations (
		--					x_return_status            	=> l_return_status
		--					, x_msg_count                	=>l_msg_count
		--					, x_msg_data                 	=>l_msg_data
		--					, x_quantity_modified	  	=> l_quantity_modified
		--					, p_api_version_number     	=>1.0
		--					, p_init_msg_lst             	=>fnd_api.g_false
		--					, p_mtl_rsv_rec                 =>l_mtl_rsv_rec
		--					, delete_flag			=> 'N'
		--					);
		--proc exit

		l_mtl_rsv_rec.action := 0;
		l_mtl_rsv_rec.organization_id := p_org_id;
		l_mtl_rsv_rec.inventory_item_id := p_inventory_item_id;
		l_mtl_rsv_rec.supply_source_type_id := 5;
		l_mtl_rsv_rec.supply_source_header_id := p_wip_entity_id;
		l_mtl_rsv_rec.supply_source_line_id := null;
		l_mtl_rsv_rec.expected_quantity := p_new_net_qty;

		select primary_uom_code
		into l_expected_quantity_uom --l_mtl_rsv_rec.expected_quantity_uom
		from mtl_system_items
		where inventory_item_id =l_mtl_rsv_rec.inventory_item_id
		and organization_id = l_mtl_rsv_rec.organization_id;


		l_mtl_rsv_rec.expected_quantity_uom := l_expected_quantity_uom;

		l_return_status := FND_API.G_RET_STS_SUCCESS;
			l_msg_count     := 0;
			l_msg_data      := null;

			l_msg_index := fnd_msg_pub.count_msg;
		inv_maintain_reservation_pub.reduce_reservation
				(
				   x_return_status            	=> l_return_status
				 , x_msg_count                	=> l_msg_count
				 , x_msg_data                 	=> l_msg_data
				 , x_quantity_modified	  	=> l_quantity_modified
				 , p_api_version_number     	=> 1.0
				 , p_init_msg_lst             	=> fnd_api.g_false
				 , p_mtl_maintain_rsv_rec       => l_mtl_rsv_rec
				 , p_delete_flag		=> 'N'
				 , p_sort_by_criteria		=> null
				 );
		if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
			/*API failed*/
			WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
			--log that rsv api failed
			IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
				l_msg_tokens.delete;
				WSM_log_PVT.logMessage (p_module_name	    => l_module	,
							p_msg_text	    => 'inv_reservation_pub.reduce_reservation failed',
							p_stmt_num	    => l_stmt_num		,
							p_msg_tokens	    => l_msg_tokens		,
							p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
							p_run_log_level	    => l_log_level
							);
			END IF;
			IF l_return_status = fnd_api.g_ret_sts_error THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		end if;
	Elsif p_status_type = 7 then
		--In case of interface, Write to WIE 'Note: Job is reserved against sales order(s). Cancelling the job will result in deletion of Job's reservations.'
		fnd_message.set_name('WSM','WSM_RSV_JOB_CANCEL');
		l_msg_data := fnd_message.get;
		fnd_file.put_line(fnd_file.log,l_msg_data);

		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count     := 0;
		l_msg_data      := null;

		l_msg_index := fnd_msg_pub.count_msg;

		--log proc entry

        -- START: Adding for bug fix 5347562.
		-- For deleting reservations we need to use reduce reservation with p_delete_flag = 'Y'

		l_mtl_rsv_rec.action := 0;
		l_mtl_rsv_rec.organization_id := p_org_id;
		l_mtl_rsv_rec.inventory_item_id := p_inventory_item_id;
		l_mtl_rsv_rec.supply_source_type_id := 5;
		l_mtl_rsv_rec.supply_source_header_id := p_wip_entity_id;
		l_mtl_rsv_rec.supply_source_line_id := null;
		l_mtl_rsv_rec.expected_quantity := p_new_net_qty;

		inv_maintain_reservation_pub.reduce_reservation
				(
				   x_return_status            	=> l_return_status
				 , x_msg_count                	=> l_msg_count
				 , x_msg_data                 	=> l_msg_data
				 , x_quantity_modified	  	    => l_quantity_modified
				 , p_api_version_number     	=> 1.0
				 , p_init_msg_lst             	=> fnd_api.g_false
				 , p_mtl_maintain_rsv_rec       => l_mtl_rsv_rec
				 , p_delete_flag		        => 'Y'
				 , p_sort_by_criteria		    => null
				 );
	    -- END: Adding for bug fix 5347562.
		-- Commenting call to delete_reservation API for bug 5347562.
	/*	inv_reservation_pub.delete_reservation
		   (
		      p_api_version_number        => 1.0
		    , p_init_msg_lst              => fnd_api.g_true
		    , x_return_status             => l_return_status
		    , x_msg_count                 => l_msg_count
		    , x_msg_data                  => l_msg_data
		    , p_rsv_rec                   => l_rsv
		    , p_serial_number             => l_dummy_sn
		    );  */

		--proc exit
		if l_return_status <> FND_API.G_RET_STS_SUCCESS  then
			/*API failed*/
			WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
			--log that rsv api failed
			IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
				l_msg_tokens.delete;
				WSM_log_PVT.logMessage (p_module_name	    => l_module	,
							p_msg_text	    => 'inv_maintain_reservation_pub.reduce_reservation',
							p_stmt_num	    => l_stmt_num		,
							p_msg_tokens	    => l_msg_tokens		,
							p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
							p_run_log_level	    => l_log_level
							);
			END IF;
			IF l_return_status = fnd_api.g_ret_sts_error THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		end if;
	elsif p_new_net_qty =0 and p_status_type <> 7 then -- Added for bug 5290496: START
	    -- In case of interface,Write to WIE 'Note: Available quantity of the job is below the net quantity.'
		fnd_message.set_name('WSM','WSM_NET_QTY_LOW');
		l_msg_data := fnd_message.get;
		fnd_file.put_line(fnd_file.log,l_msg_data);
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count     := 0;
		l_msg_data      := null;

		l_msg_index := fnd_msg_pub.count_msg;
		-- Commenting call to delete_reservation API for bug 5347562.
		/*
		inv_reservation_pub.delete_reservation
		   (
		      p_api_version_number        => 1.0
		    , p_init_msg_lst              => fnd_api.g_true
		    , x_return_status             => l_return_status
		    , x_msg_count                 => l_msg_count
		    , x_msg_data                  => l_msg_data
		    , p_rsv_rec                   => l_rsv
		    , p_serial_number             => l_dummy_sn
		    );  */

		-- START: Adding for bug fix 5347562.
		-- For deleting reservations we need to use reduce reservation with p_delete_flag = 'Y'

        l_mtl_rsv_rec.action := 0;
		l_mtl_rsv_rec.organization_id := p_org_id;
		l_mtl_rsv_rec.inventory_item_id := p_inventory_item_id;
		l_mtl_rsv_rec.supply_source_type_id := 5;
		l_mtl_rsv_rec.supply_source_header_id := p_wip_entity_id;
		l_mtl_rsv_rec.supply_source_line_id := null;
		l_mtl_rsv_rec.expected_quantity := p_new_net_qty;

		inv_maintain_reservation_pub.reduce_reservation
				(
				   x_return_status            	=> l_return_status
				 , x_msg_count                	=> l_msg_count
				 , x_msg_data                 	=> l_msg_data
				 , x_quantity_modified	  	    => l_quantity_modified
				 , p_api_version_number     	=> 1.0
				 , p_init_msg_lst             	=> fnd_api.g_false
				 , p_mtl_maintain_rsv_rec       => l_mtl_rsv_rec
				 , p_delete_flag		        => 'Y'
				 , p_sort_by_criteria		    => null
				 );
		-- END: Adding for bug fix 5347562.
		if l_return_status <> FND_API.G_RET_STS_SUCCESS  then /*API failed*/
			WSM_log_PVT.update_errtbl(l_msg_index,l_msg_count);
			--log that rsv api failed
			IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
				l_msg_tokens.delete;
				WSM_log_PVT.logMessage (p_module_name	    => l_module	,
							p_msg_text	    => 'inv_maintain_reservation_pub.reduce_reservation',
							p_stmt_num	    => l_stmt_num		,
							p_msg_tokens	    => l_msg_tokens		,
							p_fnd_log_level     => G_LOG_LEVEL_STATEMENT	,
							p_run_log_level	    => l_log_level
							);
			END IF;
			IF l_return_status = fnd_api.g_ret_sts_error THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		end if;     -- Added for bug 5290496: END
	end if;


	x_return_status:= FND_API.G_RET_STS_SUCCESS;
-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
	(   p_encoded		=>      'F'		,
	    p_count             =>      x_msg_count   ,
            p_data              =>      x_msg_data
	);

	x_return_status:=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO start_modify_rsv_jobupdate;
		x_return_status := G_RET_ERROR;
		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO start_modify_rsv_jobupdate;
		x_return_status := G_RET_UNEXPECTED;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
	WHEN OTHERS THEN

		 ROLLBACK TO start_modify_rsv_jobupdate;
		 x_return_status := G_RET_UNEXPECTED;

		 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)		 OR
		   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
		THEN
			WSM_log_PVT.handle_others( p_module_name	    => l_module			,
						   p_stmt_num		    => l_stmt_num		,
						   p_fnd_log_level     	    => G_LOG_LEVEL_UNEXPECTED	,
						   p_run_log_level	    => l_log_level
						 );
		END IF;

		FND_MSG_PUB.Count_And_Get (   p_encoded		  =>      'F'			,
					      p_count             =>      x_msg_count         ,
					      p_data              =>      x_msg_data
					  );
end;

Function check_reservation_quantity (p_wip_entity_id IN NUMBER,
					P_org_id IN NUMBER,
					P_inventory_item_id IN NUMBER
					)
Return NUMBER
is
L_rsvd_qty number :=0;

BEGIN
	/*have this call wherever wsm_reservations_v is used*/
	--MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_org_id);
	BEGIN

		-- modified the SQL to have primary quantity instead of reservation qty.
		Select sum (primary_quantity)
		into l_rsvd_qty
		from wsm_reservations_v
		where wip_entity_id = p_wip_entity_id
		and organization_id = p_org_id
		and inventory_item_id = p_inventory_item_id;
	EXCEPTION
		when no_data_found then
			Return L_rsvd_qty;
	END;

	Return l_rsvd_qty;
end check_reservation_quantity;


Function check_reservation_exists (p_wip_entity_id IN NUMBER,
					P_org_id IN NUMBER,
					P_inventory_item_id IN NUMBER
				)
Return BOOLEAN
is

l_rsv_exists number := 0 ;

BEGIN
	/*have this call wherever wsm_reservations_v is used*/
	--MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_org_id);
	BEGIN
		select 1 into l_rsv_exists
		from wsm_reservations_v
		where wip_entity_id = p_wip_entity_id
		and organization_id = p_org_id
		and inventory_item_id = p_inventory_item_id
		and rownum = 1;
	EXCEPTION
		when no_data_found then
			Return false;
	END;

	If l_rsv_exists = 1 then
		Return true;
	Else
		Return false;
	end if;
end check_reservation_exists;

end WSM_RESERVATIONS_PVT;

/
