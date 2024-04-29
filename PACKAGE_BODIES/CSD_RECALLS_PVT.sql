--------------------------------------------------------
--  DDL for Package Body CSD_RECALLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RECALLS_PVT" AS
/* $Header: csdvrclb.pls 120.0.12010000.10 2010/06/24 06:04:37 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_RECALLS_PVT
-- Purpose          : This package will contain all the procedure and functions used by the Recalls.
--		      Usage of this package is strictly confined to Oracle Depot Repair Development.
--
-- History          : 24/03/2010, Created by Sudheer Bhat
-- NOTE             :
-- End of Comments

-- logging globals.
G_LEVEL_PROCEDURE NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_RUNTIME_LEVEL   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_RET_STS_SUCCESS VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
-- Cache to hold the default bill to and ship to use id's for an customer.
-- this prevents re-executing SQL over and over again.
g_csd_shipto_billto_cache csd_shipto_billto_tbl;

g_sr_params_cached BOOLEAN := FALSE;
g_sr_urgency  NUMBER;
g_sr_severity NUMBER;
g_sr_owner    NUMBER;
g_sr_summary  VARCHAR2(240);
g_sr_status   NUMBER;
g_sr_owner_type VARCHAR2(80) := FND_PROFILE.value('CS_SR_DEFAULT_OWNER_TYPE');

g_ro_attribs_cached BOOLEAN := FALSE;
g_auto_process_rma VARCHAR2(1);
g_business_process_id NUMBER;
g_repair_mode         VARCHAR2(10);

g_bill_details_cached BOOLEAN := FALSE;
g_bill_id 	  		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
g_alt_bill 			JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
g_routing_id  		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
g_alt_routing 		JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
g_completion_subinv JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
g_completion_locid	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
g_sc_id				NUMBER;
g_upgrade_item_id   NUMBER;
g_job_prefix        VARCHAR2(30) := fnd_profile.value('CSD_DEFAULT_JOB_PREFIX');

-- Private procedures.
/****************************************************************************************/
/* Procedure Name: process_post_wip_massload.                                           */
/* Description: Creates the records in the repair history and csd repair job xref       */
/*		tables for the processing group id specified. The program will look for the		*/
/*      wip jobs created for the repair line id as specified in the recall lines   		*/
/*      table. 																	 		*/
/*-- History: 26/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/

PROCEDURE process_post_wip_massload (p_rec_group_id IN NUMBER,p_req_group_id IN NUMBER);

PROCEDURE process_post_wip_massload (p_rec_group_id IN NUMBER,p_req_group_id IN NUMBER)
IS

l_post_wipml_tbl post_wipml_tbl;
x_return_status 	VARCHAR2(1);
x_msg_count			NUMBER;
x_msg_data			VARCHAR2(2000);
x_job_xref_id		NUMBER;
l_user_id 			NUMBER := fnd_global.user_id;
l_rep_hist_id		NUMBER;
l_operation_seq_num	NUMBER;
l_department_id		NUMBER;
l_supply_subinventory VARCHAR2(30);
l_op_dtls_tbl  		CSD_HV_WIP_JOB_PVT.OP_DTLS_TBL_TYPE;
l_mtl_txn_dtls_tbl  CSD_HV_WIP_JOB_PVT.MTL_TXN_DTLS_TBL_TYPE;
x_op_created		VARCHAR2(1);
lc_api_name    		CONSTANT VARCHAR2(60) := 'CSD.PLSQL.CSD_RECALLS_PVT.PROCESS_POST_WIP_MASSLOAD';
l_default_ro_item   VARCHAR2(1);

BEGIN

	SAVEPOINT process_post_wip_massload;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Begin PROCESS_POST_WIP_MASSLOAD API');
	END IF;

	SELECT crl.repair_line_id,
	  wdj.wip_entity_id,
	  wdj.organization_id,
	  wdj.start_quantity,
	  wdj.primary_item_id,
	  crl.inventory_item_id,
	  crl.serial_number,
	  msi.primary_uom_code,
	  we.wip_entity_name,
	  csc.name,
	  csc.service_code_id,
	  cii.quantity
	BULK COLLECT INTO l_post_wipml_tbl
	FROM csd_recall_lines crl,
	  wip_entities we,
	  wip_discrete_jobs wdj,
	  csd_service_codes_tl csc,
	  mtl_system_items_b msi,
	  csi_item_instances cii
	WHERE crl.processing_group_id = p_rec_group_id
	AND crl.repair_line_id        = wdj.source_line_id
	AND NVL(g_upgrade_item_id,crl.inventory_item_id) = wdj.primary_item_id
	AND wdj.wip_entity_id         = we.wip_entity_id
	AND csc.service_code_id       = g_sc_id
	AND csc.language              = userenv('lang')
	AND msi.organization_id       = wdj.organization_id
	AND msi.inventory_item_id     = crl.inventory_item_id
	AND crl.instance_id           = cii.instance_id;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'After bulk collect, count = '||l_post_wipml_tbl.COUNT);
	END IF;

	IF l_post_wipml_tbl.COUNT = 0
	THEN
		RETURN;
	END IF;

	-- call csd_to_form_repair_job_xref.validate_and_write in loop.
	FOR i IN 1 ..l_post_wipml_tbl.COUNT
	LOOP
		csd_to_form_repair_job_xref.validate_and_write(
				p_api_version_number 	=> 1.0,
				p_init_msg_list 		=> fnd_api.g_false,
				p_commit 				=> fnd_api.g_false,
				p_validation_level 		=> NULL,
				p_action_code 			=> 0,
				px_repair_job_xref_id 	=> x_job_xref_id,
				p_created_by 			=> l_user_id,
				p_creation_date 		=> SYSDATE,
				p_last_updated_by 		=> l_user_id,
				p_last_update_date 		=> SYSDATE,
				p_last_update_login 	=> l_user_id,
				p_repair_line_id 		=> l_post_wipml_tbl(i).repair_line_id,
				p_wip_entity_id 		=> l_post_wipml_tbl(i).wip_entity_id,
				p_group_id 				=> p_req_group_id,
				p_organization_id 		=> l_post_wipml_tbl(i).organization_id,
				p_quantity 				=> l_post_wipml_tbl(i).quantity,
				p_inventory_item_id 	=> l_post_wipml_tbl(i).inventory_item_id,
				p_item_revision			=> NULL,
				p_object_version_number => NULL,
				p_attribute_category 	=> NULL,
				p_attribute1			=> NULL,
				p_attribute2 			=> NULL,
				p_attribute3 			=> NULL,
				p_attribute4 			=> NULL,
				p_attribute5 			=> NULL,
				p_attribute6 			=> NULL,
				p_attribute7 			=> NULL,
				p_attribute8 			=> NULL,
				p_attribute9 			=> NULL,
				p_attribute10			=> NULL,
				p_attribute11		 	=> NULL,
				p_attribute12 			=> NULL,
				p_attribute13 			=> NULL,
				p_attribute14 			=> NULL,
				p_attribute15 			=> NULL,
				p_quantity_completed 	=> NULL,
				p_job_name  			=> l_post_wipml_tbl(i).job_name,
				p_source_type_code  	=> l_post_wipml_tbl(i).service_code,
				p_source_id1  			=> l_post_wipml_tbl(i).service_code_id,
				p_ro_service_code_id  	=> l_post_wipml_tbl(i).service_code_id,
				x_return_status 		=> x_return_status,
				x_msg_count 			=> x_msg_count,
				x_msg_data 				=> x_msg_data);
		IF x_return_status <> g_ret_sts_success
		THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		csd_to_form_repair_history.validate_and_write(
				p_api_version_number 	=> 1.0,
				p_init_msg_list 		=> fnd_api.g_false,
				p_commit 				=> fnd_api.g_false,
				p_validation_level 		=> NULL,
				p_action_code 			=> 0,
				px_repair_history_id 	=> l_rep_hist_id,
				p_OBJECT_VERSION_NUMBER => NULL,
				p_request_id 			=> NULL,
				p_program_id 			=> NULL,
				p_program_application_id => NULL,
				p_program_update_date 	=> NULL,
				p_created_by 			=> l_user_id,
				p_creation_date 		=> SYSDATE,
				p_last_updated_by 		=> l_user_id,
				p_last_update_date 		=> SYSDATE,
				p_repair_line_id 		=> l_post_wipml_tbl(i).repair_line_id,
				p_event_code 			=> 'JS',
				p_event_date 			=> SYSDATE,
				p_quantity 				=> l_post_wipml_tbl(i).quantity,
				p_paramn1 				=> l_post_wipml_tbl(i).wip_entity_id,
				p_paramn2 				=> l_post_wipml_tbl(i).organization_id,
				p_paramn3 				=> NULL,
				p_paramn4 				=> NULL,
				p_paramn5 				=> l_post_wipml_tbl(i).quantity,
				p_paramn6 				=> NULL,
				p_paramn8 				=> NULL,
				p_paramn9 				=> NULL,
				p_paramn10				=> NULL,
				p_paramc1 				=> l_post_wipml_tbl(i).job_name,
				p_paramc2 				=> NULL,
				p_paramc3 				=> NULL,
				p_paramc4 				=> NULL,
				p_paramc5 				=> NULL,
				p_paramc6 				=> NULL,
				p_paramc7 				=> NULL,
				p_paramc8 				=> NULL,
				p_paramc9 				=> NULL,
				p_paramc10				=> NULL,
				p_paramd1 				=> NULL ,
				p_paramd2 				=> NULL ,
				p_paramd3 				=> NULL ,
				p_paramd4 				=> NULL ,
				p_paramd5 				=> SYSDATE,
				p_paramd6 				=> NULL ,
				p_paramd7 				=> NULL ,
				p_paramd8 				=> NULL ,
				p_paramd9 				=> NULL ,
				p_paramd10				=> NULL ,
				p_attribute_category 	=> NULL ,
				p_attribute1 			=> NULL ,
				p_attribute2 			=> NULL ,
				p_attribute3 			=> NULL ,
				p_attribute4 			=> NULL ,
				p_attribute5 			=> NULL ,
				p_attribute6 			=> NULL ,
				p_attribute7 			=> NULL ,
				p_attribute8 			=> NULL ,
				p_attribute9 			=> NULL ,
				p_attribute10 			=> NULL ,
				p_attribute11 			=> NULL ,
				p_attribute12 			=> NULL ,
				p_attribute13 			=> NULL ,
				p_attribute14 			=> NULL ,
				p_attribute15 			=> NULL ,
				p_last_update_login  	=> l_user_id,
				x_return_status 		=> x_return_status,
				x_msg_count 			=> x_msg_count,
				x_msg_data 				=> x_msg_data);

		IF x_return_status <> g_ret_sts_success
		THEN
			RAISE fnd_api.g_exc_error;
		END IF;

	l_default_ro_item := nvl(FND_PROFILE.VALUE('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'), 'N');

	IF g_upgrade_item_id IS NOT NULL OR l_default_ro_item = 'Y'
	THEN
		-- check if the operation exists.
		BEGIN
			IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Begin upgrade item processing');
			END IF;

			BEGIN
				SELECT MIN(operation_seq_num)
				INTO l_operation_seq_num
				FROM wip_operations
				WHERE wip_entity_id = l_post_wipml_tbl(i).wip_entity_id;
			EXCEPTION
				WHEN no_data_found THEN
					l_operation_seq_num := 0;
			END;

			IF l_operation_seq_num = 0
			THEN
				-- create new operation.
				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'No operations found, proceeding to create one.');
				END IF;
				IF l_department_id IS NULL
				THEN
					SELECT department_id, supply_subinventory
					INTO   l_department_id, l_supply_subinventory
					FROM csd_recall_parameters
					WHERE organization_id = fnd_profile.value('CSD_DEF_REP_INV_ORG');
				END IF;

				l_op_dtls_tbl(1).new_row 		:= 'Y';
				l_op_dtls_tbl(1).wip_entity_id	:= l_post_wipml_tbl(i).wip_entity_id;
				l_op_dtls_tbl(1).organization_id:= l_post_wipml_tbl(i).organization_id;
				l_op_dtls_tbl(1).operation_seq_num := 10;
				l_op_dtls_tbl(1).backflush_flag    := 2;
				l_op_dtls_tbl(1).count_point_type  := 1;
				l_op_dtls_tbl(1).first_unit_completion_date := sysdate;
				l_op_dtls_tbl(1).first_unit_start_date      := sysdate;
				l_op_dtls_tbl(1).last_unit_completion_date  := sysdate;
				l_op_dtls_tbl(1).last_unit_start_date       := sysdate;
				l_op_dtls_tbl(1).minimum_transfer_quantity  := 0;

				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_OP_DTLS');
				END IF;

				CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_OP_DTLS
				(
					p_api_version_number => 1.0,
					p_init_msg_list      => fnd_api.g_false,
					p_Commit             => fnd_api.g_false,
					p_validation_level   => 100,
					x_return_status      => x_return_status,
					x_msg_count          => x_msg_count,
					x_msg_data           => x_msg_data,
					p_op_dtls_tbl        => l_op_dtls_tbl
				);

				l_mtl_txn_dtls_tbl(i).new_row				 := 'Y';
				l_mtl_txn_dtls_tbl(i).operation_seq_num      := l_op_dtls_tbl(1).operation_seq_num;
				l_mtl_txn_dtls_tbl(i).wip_entity_id          := l_post_wipml_tbl(i).wip_entity_id;
				l_mtl_txn_dtls_tbl(i).organization_id        := l_post_wipml_tbl(i).organization_id;
				l_mtl_txn_dtls_tbl(i).inventory_item_id      := l_post_wipml_tbl(i).recall_inventory_id;
				l_mtl_txn_dtls_tbl(i).transaction_quantity   := l_post_wipml_tbl(i).transaction_qty;
				l_mtl_txn_dtls_tbl(i).supply_subinventory    := l_supply_subinventory;

			ELSE
				IF l_supply_subinventory IS NULL
				THEN
					SELECT department_id, supply_subinventory
					INTO   l_department_id, l_supply_subinventory
					FROM csd_recall_parameters
					WHERE organization_id = fnd_profile.value('CSD_DEF_REP_INV_ORG');
				END IF;

				l_mtl_txn_dtls_tbl(i).new_row				 := 'Y';
				l_mtl_txn_dtls_tbl(i).operation_seq_num      := l_operation_seq_num;
				l_mtl_txn_dtls_tbl(i).wip_entity_id          := l_post_wipml_tbl(i).wip_entity_id;
				l_mtl_txn_dtls_tbl(i).organization_id        := l_post_wipml_tbl(i).organization_id;
				l_mtl_txn_dtls_tbl(i).inventory_item_id      := l_post_wipml_tbl(i).recall_inventory_id;
				l_mtl_txn_dtls_tbl(i).transaction_quantity   := l_post_wipml_tbl(i).transaction_qty;
				l_mtl_txn_dtls_tbl(i).supply_subinventory    := l_supply_subinventory;
			END IF;
			EXCEPTION
				WHEN no_data_found THEN
					IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
						   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'No data found error. Missing default dept or default supply subinventory');
					END IF;
			END;
	END IF;
	END LOOP;

	 -- call the hvr save mtl_transactions API.
	 CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS
	 (
	 	p_api_version_number => 1.0,
		p_init_msg_list      => fnd_api.g_false,
		p_Commit             => fnd_api.g_false,
		p_validation_level   => 100,
		x_return_status      => x_return_status,
		x_msg_count          => x_msg_count,
		x_msg_data           => x_msg_data,
		p_mtl_txn_dtls_tbl   => l_mtl_txn_dtls_tbl,
		x_op_created		 => x_op_created
	);

EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		ROLLBACK TO process_post_wip_massload;

	WHEN OTHERS THEN
		ROLLBACK TO process_post_wip_massload;
		RAISE;
END process_post_wip_massload;

/****************************************************************************************/
/* Procedure Name: Generate_Recall_Work.                                                */
/* Description: Receives a set of recall lines for which the recall work needs to       */
/*		be generated along with SR, RO and WIP params if any. Prepares these    		*/
/*      recall lines for concurrent processing and launches the CP to create    		*/
/*      recall work.Returns the concurrent program Id to the caller if success  		*/
/*		else an appropriate error message is returned.                          		*/
/*-- History: 24/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/

PROCEDURE GENERATE_RECALL_WORK (p_api_version 		IN NUMBER,
							p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
							p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
							p_recall_line_ids       IN JTF_NUMBER_TABLE,
							p_sr_type_id            IN NUMBER,
							p_ro_type_id            IN NUMBER DEFAULT NULL,
							p_service_code_id       IN NUMBER DEFAULT NULL,
							p_wip_accounting_class  IN VARCHAR2 DEFAULT NULL,
							p_upgrade_item_id       IN VARCHAR2 DEFAULT NULL,
							p_wip_inv_org_id        IN NUMBER DEFAULT NULL,
							p_recall_number         IN VARCHAR2,
							x_request_id            OUT NOCOPY NUMBER,
							x_msg_count             OUT NOCOPY NUMBER,
							x_msg_data              OUT NOCOPY VARCHAR2,
							x_return_status         OUT NOCOPY VARCHAR2)
IS

-- local constants.
lc_api_version CONSTANT NUMBER := 1.0;
lc_api_name    CONSTANT VARCHAR2(60) := 'CSD.PLSQL.CSD_RECALLS_PVT.GENERATE_RECALL_WORK';
l_counter      NUMBER := 0;
l_group_id     NUMBER;

BEGIN

	SAVEPOINT GENERATE_RECALL_WORK;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Begin GENERATE_RECALL_WORK API');
	END IF;

	-- standard check for API compatibility.
	IF NOT Fnd_Api.Compatible_API_Call
				(lc_api_version,
				 p_api_version,
				 lc_api_name,
				 G_PKG_NAME)
	THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF Fnd_Api.to_Boolean(p_init_msg_list)
	THEN
		Fnd_Msg_Pub.initialize;
	END IF;

	-- log api params.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_sr_type_id = '||p_sr_type_id);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_ro_type_id = '||p_ro_type_id);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_service_code_id = '||p_service_code_id);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_wip_accounting_class = '||p_wip_accounting_class);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_upgrade_item_id = '||p_upgrade_item_id);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_wip_inv_org_id = '||p_wip_inv_org_id);
		fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'p_recall_number = '||p_recall_number);
		FOR l_counter IN 1 ..p_recall_line_ids.COUNT
		LOOP
			fnd_log.string(G_LEVEL_PROCEDURE,lc_api_name,'recall_line_id'||l_counter||' = '||p_recall_line_ids(l_counter));
		END LOOP;
	END IF;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
		       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Update the recall lines as processing');
	END IF;

	SELECT csd_recall_lines_group_s1.NEXTVAL INTO l_group_id FROM dual;

	-- update the selected recall line id's as processing flag = 'Y';
	UPDATE CSD_RECALL_LINES crl SET processing_flag = 'Y', processing_group_id = l_group_id
		WHERE crl.recall_line_id IN (SELECT * FROM TABLE(CAST(p_recall_line_ids as JTF_NUMBER_TABLE)))
		AND   nvl(crl.processing_flag,'N') = 'N';

	COMMIT;

	-- submit the concurrent request.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
		       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Before launching the CP');
	END IF;

	x_request_id := fnd_request.submit_request(application => 'CSD',
											   program     => 'CSDRCLWK',
											   description => null,
											   argument1   => l_group_id,
											   argument2   => p_sr_type_id,
											   argument3   => p_ro_type_id,
											   argument4   => p_service_code_id,
											   argument5   => p_wip_accounting_class,
											   argument6   => p_upgrade_item_id,
											   argument7   => p_wip_inv_org_id );
	IF (x_request_id IS NULL OR x_request_id <= 0)
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL)
		THEN
			Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Error in launching CP');
		END IF;

		UPDATE CSD_RECALL_LINES crl SET processing_flag = 'N'
			WHERE crl.recall_line_id IN (SELECT * FROM TABLE(CAST(p_recall_line_ids as JTF_NUMBER_TABLE)))
			AND   nvl(crl.processing_flag,'N') = 'Y'
			AND   crl.processing_group_id = l_group_id;

		COMMIT;
		--  to do.
		-- add a message.
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	COMMIT;
EXCEPTION
	WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Unexpected error, could not submit the request');
		END IF;
		-- to do. get the fnd messages.
	WHEN OTHERS THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'WHEN OTHERS '||SQLERRM);
		END IF;
		RAISE;
END GENERATE_RECALL_WORK;

/****************************************************************************************/
/* Procedure Name: process_recall_work.                                                 */
/* Description: This is the concurrent wrapper to process a set of recall lines.        */
/*		Generates SR, RO and WIP jobs based on the params being passed. Logs    		*/
/*		all the error messages to error log, and will generate a report of all  		*/
/*		all the successful recall lines. Updates the csd_recall_lines table     		*/
/*		with the SR id, RO line id and wip entity id when done with the         		*/
/*		processing. Once done, will reset the processing_flag to N						*/
/* -- History: 24/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/

PROCEDURE PROCESS_RECALL_WORK (errbuf 		   			OUT NOCOPY VARCHAR2,
                               retcode 		   			OUT NOCOPY VARCHAR2,
							   p_group_id	     		IN NUMBER,
							   p_sr_type_id        		IN NUMBER,
							   p_ro_type_id        		IN NUMBER DEFAULT NULL,
							   p_service_code_id   		IN NUMBER DEFAULT NULL,
							   p_wip_accounting_class	IN VARCHAR2 DEFAULT NULL,
							   p_upgrade_item_id        IN NUMBER,
							   p_wip_inv_org_id     	IN NUMBER )
IS

lc_api_name 			CONSTANT VARCHAR2(60) := 'CSD.PLSQL.CP.CSD_RECALLS_PVT.CSD_RECALLS_PVT';
l_csd_recall_lines_tbl  csd_recall_lines_tbl;
l_create_ro_flag 		BOOLEAN := FALSE;
l_create_job_flag 		BOOLEAN := FALSE;
l_index  				NUMBER;
l_service_request_rec   csd_process_pvt.service_request_rec := csd_process_util.sr_rec;
l_sr_notes_tbl 			cs_servicerequest_pub.notes_table;
l_repln_rec				csd_repairs_pub.repln_rec_type;
l_create_ro_flag 		BOOLEAN := FALSE;
l_ent_contracts         oks_entitlements_pub.get_contop_tbl;
l_calc_resptime_flag    VARCHAR2(1)    := 'Y';
l_server_tz_id 			NUMBER;
l_contract_pl_id 		NUMBER;
l_profile_pl_id 		NUMBER;
l_currency_code 		VARCHAR2(5);
l_job_header_tbl		job_header_tbl;
l_job_index 			NUMBER;
l_job_header_index 		NUMBER := 1;
l_group_id				NUMBER := 0;
l_req_group_id 			NUMBER;
l_rec_group_id			NUMBER;
x_incident_id 			NUMBER;
x_incident_number 		VARCHAR2(30);
x_return_status         VARCHAR2(1);
x_msg_data				VARCHAR2(2000);
x_msg_count				NUMBER;
x_repair_line_id        NUMBER;
x_repair_number			VARCHAR2(30);
x_job_name 				VARCHAR2(30);
x_request_id 			NUMBER;
l_temp 					VARCHAR2(200);
l_job_status			NUMBER := 0;


CURSOR eligible_lines IS
SELECT crl.recall_line_id,
	   crl.instance_id,
	   crl.owner_account_id,
	   crl.owner_party_id,
	   crl.inventory_item_id,
	   crl.revision,
	   crl.serial_number,
	   crl.lot_number,
	   crl.incident_id,
	   crl.repair_line_id,
	   crl.wip_entity_id,
	   cii.unit_of_measure,
	   cii.quantity
FROM csd_recall_lines crl,csi_item_instances cii
WHERE crl.processing_group_id = p_group_id
AND   crl.processing_flag = 'Y'
AND   crl.instance_id = cii.instance_id;

BEGIN
	IF fnd_conc_global.request_data IS NOT NULL
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Post wip mass load');
		END IF;
		l_rec_group_id := TO_NUMBER(SUBSTR(fnd_conc_global.request_data,0,INSTR(fnd_conc_global.request_data,',')-1));
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Step1');
		END IF;
		l_temp 		   := SUBSTR(fnd_conc_global.request_data,INSTR(fnd_conc_global.request_data,',')+1);
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Step2');
		END IF;
		l_req_group_id := TO_NUMBER(SUBSTR(l_temp,0,INSTR(l_temp,',')-1));
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Step3');
		END IF;
		l_temp 		   := SUBSTR(l_temp,INSTR(l_temp,',')+1);

		g_sc_id		   := TO_NUMBER(SUBSTR(l_temp,0,INSTR(l_temp,',')-1));
		g_upgrade_item_id := TO_NUMBER(SUBSTR(l_temp,INSTR(l_temp,',')+1));

		process_post_wip_massload(l_rec_group_id,l_req_group_id);

		UPDATE csd_recall_lines SET processing_flag = 'N'
			WHERE processing_group_id = l_rec_group_id;

		RETURN;
	END IF;

	SAVEPOINT PROCESS_RECALL_WORK;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Begin PROCESS_RECALL_WORK API');
	END IF;

	OPEN eligible_lines;
	FETCH eligible_lines BULK COLLECT INTO l_csd_recall_lines_tbl;
	CLOSE eligible_lines;
-- processing logic.
-- for all the recall lines, determine what all needs to be created.
-- till RO creation, we have to go row by row.
-- for the wip job creation, we will insert all the eligible records into the interface table
-- and call wip mass load just once.

	FOR l_index  IN 1 ..l_csd_recall_lines_tbl.COUNT
	LOOP
		IF l_csd_recall_lines_tbl(l_index).incident_id IS NULL
		THEN
			-- get the bill to site use id and ship to site use id.
			IF g_csd_shipto_billto_cache.EXISTS(l_csd_recall_lines_tbl(l_index).owner_party_id)
			THEN
				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting the bill to and ship to site from cache');
				END IF;
				l_service_request_rec.bill_to_site_use_id :=
							g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).bill_to_site_use_id;
				l_service_request_rec.ship_to_site_use_id :=
							g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).ship_to_site_use_id;
				l_service_request_rec.caller_type		  :=
							g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).caller_type;
			ELSE
				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting bill to and ship to site.');
				END IF;
				SELECT hpu.party_site_use_id,
				   hpu1.party_site_use_id
				INTO g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).bill_to_site_use_id,
					 g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).ship_to_site_use_id
				FROM hz_party_sites hps,
					hz_party_site_uses hpu,
				    hz_party_sites hps1,
				    hz_party_site_uses hpu1
				WHERE hps.party_id = l_csd_recall_lines_tbl(l_index).owner_party_id
				AND hps.party_site_id = hpu.party_site_id
				AND hpu.site_use_type = 'BILL_TO'
				AND hpu.primary_per_type = 'Y'
				AND hps1.party_id = l_csd_recall_lines_tbl(l_index).owner_party_id
				AND hps1.party_site_id = hpu1.party_site_id
				AND hpu1.site_use_type = 'SHIP_TO'
				AND hpu1.primary_per_type = 'Y'
				AND rownum < 2;

				l_service_request_rec.bill_to_site_use_id :=
											g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).bill_to_site_use_id;
				l_service_request_rec.ship_to_site_use_id :=
											g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).ship_to_site_use_id;

				SELECT party_type
				INTO g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).caller_type
				FROM hz_parties
				WHERE party_id = l_csd_recall_lines_tbl(l_index).owner_party_id;

				l_service_request_rec.caller_type		  :=
											g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).caller_type;
			END IF;

			-- Get other SR defaults.
			l_service_request_rec.type_id 				:= p_sr_type_id;
			l_service_request_rec.resource_type 		:= g_sr_owner_type;
			l_service_request_rec.sr_creation_channel 	:= 'PHONE';
			l_service_request_rec.request_date          := sysdate;
			l_service_request_rec.customer_id			:= l_csd_recall_lines_tbl(l_index).owner_party_id;
			l_service_request_rec.account_id			:= l_csd_recall_lines_tbl(l_index).owner_account_id;
			l_service_request_rec.customer_number       := null;
			l_service_request_rec.customer_product_id   := null;
			l_service_request_rec.cp_ref_number         := null;
			l_service_request_rec.inv_item_revision     := null;
			l_service_request_rec.inventory_item_id     := null;
			l_service_request_rec.inventory_org_id      := null;
			l_service_request_rec.current_serial_number := null;
			l_service_request_rec.original_order_number := null;
			l_service_request_rec.purchase_order_num    := null;
			l_service_request_rec.problem_code          := null;
			l_service_request_rec.exp_resolution_date   := null;
			l_service_request_rec.contract_id           := null;
			l_service_request_rec.cust_po_number        := null;
			l_service_request_rec.cp_revision_id        := null;
			l_service_request_rec.sr_contact_point_id   := null;
			l_service_request_rec.party_id              := null;
			l_service_request_rec.contact_point_id      := null;
			l_service_request_rec.contact_point_type    := null;
			l_service_request_rec.primary_flag          := null;
			l_service_request_rec.contact_type          := null;
			l_service_request_rec.owner_group_id        := NULL;
			l_service_request_rec.publish_flag          := '';

			IF g_sr_params_cached
			THEN
				l_service_request_rec.status_id   := g_sr_status;
				l_service_request_rec.severity_id := g_sr_severity;
				l_service_request_rec.urgency_id  := g_sr_urgency;
				l_service_request_rec.owner_id    := g_sr_owner;
				l_service_request_rec.summary	  := g_sr_summary;
			ELSE
				SELECT sr_status,
					   sr_severity,
					   sr_urgency,
					   sr_owner,
					   sr_summary
				INTO   g_sr_status,
					   g_sr_severity,
					   g_sr_urgency,
					   g_sr_owner,
					   g_sr_summary
				FROM   csd_recall_parameters
				WHERE  organization_id = FND_PROFILE.VALUE('CSD_DEF_REP_INV_ORG');

				l_service_request_rec.status_id   := g_sr_status;
				l_service_request_rec.severity_id := g_sr_severity;
				l_service_request_rec.urgency_id  := g_sr_urgency;
				l_service_request_rec.owner_id    := g_sr_owner;
				l_service_request_rec.summary	  := g_sr_summary;
				g_sr_params_cached 				  := true;
			END IF;

			IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Before calling CSD_PROCESS_PVT.process_service_request');
			END IF;

			-- call service request API.
			CSD_PROCESS_PVT.process_service_request
				( p_api_version          => 1.0,
				  p_commit               => fnd_api.g_false,
				  p_init_msg_list        => fnd_api.g_true,
				  p_validation_level     => fnd_api.g_valid_level_full,
				  p_action               => 'CREATE',
				  p_incident_id          => NULL,
				  p_service_request_rec  => l_service_request_rec,
				  p_notes_tbl            => l_sr_notes_tbl,
				  x_incident_id          => x_incident_id,
				  x_incident_number      => x_incident_number,
				  x_return_status        => x_return_status,
				  x_msg_count            => x_msg_count,
				  x_msg_data             => x_msg_data
				);
			IF NOT G_RET_STS_SUCCESS = x_return_status
			THEN
				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Error in CSD_PROCESS_PVT.process_service_request '||x_msg_data);
				END IF;
				RAISE fnd_api.g_exc_error;
			END IF;
			l_csd_recall_lines_tbl(l_index).incident_id := x_incident_id;

			UPDATE csd_recall_lines SET incident_id = x_incident_id
				WHERE recall_line_id = l_csd_recall_lines_tbl(l_index).recall_line_id;
		END IF;

		-- check if RO creation is required.
		IF l_csd_recall_lines_tbl(l_index).repair_line_id IS NULL AND p_ro_type_id IS NOT NULL
		THEN
			-- get the repair attributes.
			-- get the Pricelist.
			-- prepare the rec and create RO.
			IF NOT g_ro_attribs_cached
			THEN
				SELECT auto_process_rma,
					   business_process_id,
					   repair_mode
				INTO   g_auto_process_rma,
					   g_business_process_id,
					   g_repair_mode
				FROM   csd_repair_types_b
				WHERE  repair_type_id = p_ro_type_id;
			END IF;

			-- get the contract
			fnd_profile.get('SERVER_TIMEZONE_ID', l_server_tz_id);

			-- bug#9808614. if bill to and ship to are not yet cached, do so.
			IF NOT g_csd_shipto_billto_cache.EXISTS(l_csd_recall_lines_tbl(l_index).owner_party_id)
			THEN
				SELECT hpu.party_site_use_id,
				   hpu1.party_site_use_id
				INTO g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).bill_to_site_use_id,
					 g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).ship_to_site_use_id
				FROM hz_party_sites hps,
					hz_party_site_uses hpu,
				    hz_party_sites hps1,
				    hz_party_site_uses hpu1
				WHERE hps.party_id = l_csd_recall_lines_tbl(l_index).owner_party_id
				AND hps.party_site_id = hpu.party_site_id
				AND hpu.site_use_type = 'BILL_TO'
				AND hpu.primary_per_type = 'Y'
				AND hps1.party_id = l_csd_recall_lines_tbl(l_index).owner_party_id
				AND hps1.party_site_id = hpu1.party_site_id
				AND hpu1.site_use_type = 'SHIP_TO'
				AND hpu1.primary_per_type = 'Y'
				AND rownum < 2;
			END IF;

			IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling csd_repairs_util.get_entitlements for contract info');
			END IF;

			csd_repairs_util.get_entitlements(
					  p_api_version_number  => 1.0,
					  p_init_msg_list       => fnd_api.g_false,
					  p_commit              => fnd_api.g_false,
					  p_contract_number     => null,
					  p_service_line_id     => null,
					  p_customer_id         => l_csd_recall_lines_tbl(l_index).owner_party_id ,
					  p_site_id             => g_csd_shipto_billto_cache(l_csd_recall_lines_tbl(l_index).owner_party_id).ship_to_site_use_id,
					  p_customer_account_id => l_csd_recall_lines_tbl(l_index).owner_account_id,
					  p_system_id           => null,
					  p_inventory_item_id   => l_csd_recall_lines_tbl(l_index).inventory_item_id,
					  p_customer_product_id => l_csd_recall_lines_tbl(l_index).instance_id,
					  p_request_date        =>  trunc(sysdate),
					  p_validate_flag       => 'Y',
					  p_business_process_id => g_business_process_id,
					  p_severity_id         => g_sr_severity,
					  p_time_zone_id        => l_server_tz_id,
					  P_CALC_RESPTIME_FLAG  => l_calc_resptime_flag,
					  x_ent_contracts       => l_ent_contracts,
					  x_return_status       => x_return_status,
					  x_msg_count           => x_msg_count,
					  x_msg_data            => x_msg_data);

			IF l_ent_contracts.COUNT = 0
			THEN
				l_repln_rec.contract_line_id := null;
			ELSE
				l_repln_rec.contract_line_id := l_ent_contracts(1).service_line_id;
			END IF;

			-- get the pricelist and currency.

			csd_process_util.get_ro_default_curr_pl(
					  p_api_version          => 1.0,
				 	  p_init_msg_list        => fnd_api.g_false,
				      p_incident_id          => x_incident_id,
				 	  p_repair_type_id     	 => p_ro_type_id,
				 	  p_ro_contract_line_id  => l_repln_rec.contract_line_id,
				 	  x_contract_pl_id       => l_contract_pl_id,
				 	  x_profile_pl_id        => l_profile_pl_id,
				 	  x_currency_code        => l_currency_code,
				 	  x_return_status        => x_return_status,
				 	  x_msg_count            => x_msg_count,
	 				  x_msg_data             => x_msg_data );

	 		IF l_contract_pl_id IS NOT NULL
	 		THEN
	 			l_repln_rec.price_list_header_id := l_contract_pl_id;
	 		ELSE
	 			l_repln_rec.price_list_header_id := l_profile_pl_id;
	 		END IF;

	 		l_repln_rec.currency_code := l_currency_code;

	 		-- set below attributes as g_miss_*. So that defaulting engine can act in the
	 		-- PVT API.
	 		l_repln_rec.inventory_org_id 	:= fnd_api.g_miss_num;
	 		l_repln_rec.resource_group 		:= fnd_api.g_miss_num;
	 		l_repln_rec.ro_priority_code 	:= fnd_api.g_miss_char;
	 		l_repln_rec.resource_id 		:= fnd_api.g_miss_num;

	 		l_repln_rec.incident_id			:= NVL(x_incident_id,l_csd_recall_lines_tbl(l_index).incident_id);
			l_repln_rec.customer_product_id := l_csd_recall_lines_tbl(l_index).instance_id;
			l_repln_rec.auto_process_rma 	:= g_auto_process_rma;
			l_repln_rec.approval_required_flag := 'Y';
			l_repln_rec.repair_type_id   	:= p_ro_type_id;
			l_repln_rec.repair_group_id     := null;
			l_repln_rec.repair_mode    		:= g_repair_mode;
    		l_repln_rec.status 				:= 'O';
    		l_repln_rec.inventory_item_id   := l_csd_recall_lines_tbl(l_index).inventory_item_id;
    		l_repln_rec.item_revision 		:= l_csd_recall_lines_tbl(l_index).revision;
    		l_repln_rec.serial_number		:= l_csd_recall_lines_tbl(l_index).serial_number;
    		l_repln_rec.quantity			:= l_csd_recall_lines_tbl(l_index).quantity;
    		l_repln_rec.unit_of_measure		:= l_csd_recall_lines_tbl(l_index).uom_code;

    		-- we dont try to default the resolve by date. The create repair order public has an
    		-- issue when resolve by date is not passed.
    		l_repln_rec.resolve_by_date		:= null;
    		x_repair_line_id := null;

    		-- call create repair order PVT API.
			IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
				   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling Create_Repair_Order for creating RO');
			END IF;
			CSD_REPAIRS_PVT.Create_Repair_Order(
					  p_api_version_number => 1.0,
			     	  p_commit             => fnd_api.g_false,
			   		  p_init_msg_list      => fnd_api.g_true,
			   		  p_validation_level   => fnd_api.g_valid_level_full,
			   		  p_repair_line_id     => x_repair_line_id,
			   		  p_Repln_Rec          => l_repln_rec,
			   		  x_repair_line_id     => x_repair_line_id,
			   		  x_repair_number      => x_repair_number,
			   		  x_return_status      => x_return_status,
			   		  x_msg_count          => x_msg_count,
			   		  x_msg_data           => x_msg_data );

			IF NOT G_RET_STS_SUCCESS = x_return_status
			THEN
				IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Error in Create_Repair_Order '||x_msg_data);
				END IF;
				RAISE fnd_api.g_exc_error;
			END IF;

			l_csd_recall_lines_tbl(l_index).repair_line_id := x_repair_line_id;

			UPDATE csd_recall_lines SET repair_line_id = x_repair_line_id
				WHERE recall_line_id = l_csd_recall_lines_tbl(l_index).recall_line_id;
		END IF;

		-- default logistics lines.
		csd_process_pvt.create_default_prod_txn
			(p_api_version      => 1.0,
			p_commit           => fnd_api.g_false,
			p_init_msg_list    => fnd_api.g_true,
			p_validation_level => fnd_api.g_valid_level_full,
			p_repair_line_id   => x_repair_line_id,
			x_return_status    => x_return_status,
			x_msg_count        => x_msg_count,
			x_msg_data         => x_msg_data);
		-- we wont check for the status of the logistics lines here. Even if the auto creation fails, we create all
		-- other possible entities. The logistics lines can be manually entered in later.
		-- WIP job creation

		IF l_csd_recall_lines_tbl(l_index).repair_line_id IS NOT NULL AND p_service_code_id IS NOT NULL
		THEN
			IF l_job_status = 0 THEN
				SELECT wip_job_status
				INTO l_job_status
				FROM csd_recall_parameters
				WHERE organization_id = FND_PROFILE.VALUE('CSD_DEF_REP_INV_ORG');
			END IF;
			-- find the bill and route from the service code provided.
			-- prepare the job attributes.
			IF NOT g_bill_details_cached
			THEN
				SELECT bom.assembly_item_id bom_reference_id,
				  bom.alternate_bom_designator,
				  bor.assembly_item_id routing_reference_id,
				  bor.alternate_routing_designator,
				  bor.completion_subinventory,
				  bor. completion_locator_id
				BULK COLLECT INTO
				  g_bill_id,
				  g_alt_bill,
				  g_routing_id,
				  g_alt_routing,
				  g_completion_subinv,
				  g_completion_locid
				FROM csd_sc_work_entities cscwe,
				  bom_bill_of_materials bom ,
				  bom_operational_routings bor
				WHERE cscwe.service_code_id     = p_service_code_id
				AND cscwe.work_entity_type_code = 'BOM'
				AND cscwe.work_entity_id3       = fnd_profile.value('csd_def_rep_inv_org')
				AND cscwe.work_entity_id1       = bom.bill_sequence_id (+)
				AND cscwe.work_entity_id2       = bor.routing_sequence_id (+);

				g_bill_details_cached := TRUE;
				g_sc_id				  := p_service_code_id;

			END IF;

			--l_job_header_index := l_job_header_index + 1;
			IF g_bill_id.COUNT = 0
			THEN
				l_job_header_tbl(l_job_header_index).source_code 		:= 'DEPOT_REPAIR';
				l_job_header_tbl(l_job_header_index).source_line_id 	:= l_csd_recall_lines_tbl(l_index).repair_line_id;
				l_job_header_tbl(l_job_header_index).organization_id	:= NVL(p_wip_inv_org_id,fnd_profile.value('csd_def_rep_inv_org'));
				l_job_header_tbl(l_job_header_index).status_type		:= NVL(l_job_status,1);
				l_job_header_tbl(l_job_header_index).load_type			:= 4;
				l_job_header_tbl(l_job_header_index).process_phase		:= 2;
				l_job_header_tbl(l_job_header_index).process_status		:= 1;
				l_job_header_tbl(l_job_header_index).creation_date 		:= SYSDATE;
				l_job_header_tbl(l_job_header_index).last_update_date 	:= SYSDATE;
				l_job_header_tbl(l_job_header_index).created_by 		:= fnd_global.user_id;
				l_job_header_tbl(l_job_header_index).last_updated_by 	:= fnd_global.user_id;
				l_job_header_tbl(l_job_header_index).last_update_login 	:= fnd_global.login_id;
				l_job_header_tbl(l_job_header_index).primary_item_id	:= NVL(p_upgrade_item_id,l_csd_recall_lines_tbl(l_index).inventory_item_id);
				l_job_header_tbl(l_job_header_index).start_quantity		:= l_csd_recall_lines_tbl(l_index).quantity;
				l_job_header_tbl(l_job_header_index).first_unit_start_date := sysdate;
				l_job_header_tbl(l_job_header_index).last_unit_completion_date := sysdate + 1;

				CSD_WIP_JOB_PVT.generate_job_name(g_job_prefix,l_job_header_tbl(l_job_header_index).organization_id,x_job_name);
				l_job_header_tbl(l_job_header_index).job_name              := x_job_name;
				l_job_header_tbl(l_job_header_index).class_code			   := p_wip_accounting_class;

				IF l_group_id = 0
				THEN
					SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;
				END IF;
				l_job_header_tbl(l_job_header_index).group_id 			   := l_group_id;
				l_job_header_index := l_job_header_index + 1; -- bug#9754933

			ELSE
				FOR l_job_index IN 1 ..g_bill_id.COUNT
				LOOP
					l_job_header_tbl(l_job_header_index).source_code 		:= 'DEPOT_REPAIR';
					l_job_header_tbl(l_job_header_index).source_line_id 	:= l_csd_recall_lines_tbl(l_index).repair_line_id;
					l_job_header_tbl(l_job_header_index).organization_id	:= NVL(p_wip_inv_org_id,fnd_profile.value('csd_def_rep_inv_org'));
					l_job_header_tbl(l_job_header_index).status_type		:= NVL(l_job_status,1);
					l_job_header_tbl(l_job_header_index).load_type			:= 4;
					l_job_header_tbl(l_job_header_index).process_phase		:= 2;
					l_job_header_tbl(l_job_header_index).process_status		:= 1;
					l_job_header_tbl(l_job_header_index).creation_date 		:= SYSDATE;
					l_job_header_tbl(l_job_header_index).last_update_date 	:= SYSDATE;
					l_job_header_tbl(l_job_header_index).created_by 		:= fnd_global.user_id;
					l_job_header_tbl(l_job_header_index).last_updated_by 	:= fnd_global.user_id;
					l_job_header_tbl(l_job_header_index).last_update_login 	:= fnd_global.login_id;
					l_job_header_tbl(l_job_header_index).primary_item_id	:= NVL(p_upgrade_item_id,l_csd_recall_lines_tbl(l_index).inventory_item_id);
					l_job_header_tbl(l_job_header_index).start_quantity		:= l_csd_recall_lines_tbl(l_index).quantity;
					l_job_header_tbl(l_job_header_index).routing_reference_id := g_routing_id(l_job_index);
					l_job_header_tbl(l_job_header_index).bom_reference_id	:= g_bill_id(l_job_index);
					l_job_header_tbl(l_job_header_index).alternate_routing_designator := g_alt_routing(l_job_index);
					l_job_header_tbl(l_job_header_index).alternate_bom_designator := g_alt_bill(l_job_index);
					l_job_header_tbl(l_job_header_index).completion_subinventory := g_completion_subinv(l_job_index);
					l_job_header_tbl(l_job_header_index).completion_locator_id := g_completion_locid(l_job_index);
					l_job_header_tbl(l_job_header_index).first_unit_start_date := sysdate;

					CSD_WIP_JOB_PVT.generate_job_name(g_job_prefix,l_job_header_tbl(l_job_header_index).organization_id,x_job_name);
					l_job_header_tbl(l_job_header_index).job_name              := x_job_name;
					l_job_header_tbl(l_job_header_index).class_code			   := p_wip_accounting_class;

					IF l_group_id = 0
					THEN
						SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;
					END IF;
					l_job_header_tbl(l_job_header_index).group_id 			   := l_group_id;
					l_job_header_index := l_job_header_index + 1;
				END LOOP;
			END IF;
		END IF;

	END LOOP;

	IF l_job_header_tbl.COUNT = 0
	THEN
		-- clean up the processing_flag value. No more processing to be done as part of this program.
		UPDATE csd_recall_lines SET processing_flag = 'N'
			WHERE processing_group_id = p_group_id;
		COMMIT WORK;
		RETURN;
	END IF;
	-- insert the job header rec into wip_job_schedule_interface_table and call the CP.
	FORALL j IN 1 ..l_job_header_tbl.COUNT
		INSERT INTO wip_job_schedule_interface VALUES l_job_header_tbl(j);

	COMMIT WORK;
	-- submit wip mass load as child request for the entire group.
	x_request_id := fnd_request.submit_request (
     							application 	=> 	'WIP',
                  				program 		=> 	'WICMLP',
                  				description 	=> 	NULL,
                  				start_time 		=> 	NULL,
                  				sub_request 	=> 	TRUE,
                  				argument1 		=> 	TO_CHAR(l_group_id),
                  				argument2 		=> 	0,
                  				argument3 		=> 	NULL );

	fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
	   								request_data => TO_CHAR(p_group_id)||','||TO_CHAR(l_group_id)||','||TO_CHAR(p_service_code_id)||','||TO_CHAR(p_upgrade_item_id));


EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Exc error '||x_msg_data);
		END IF;
		errbuf := x_msg_data;
		retcode := 2;
		ROLLBACK TO PROCESS_RECALL_WORK;
		-- clean up the processing flag.
		UPDATE csd_recall_lines SET processing_flag = 'N'
			WHERE processing_group_id = p_group_id;
		COMMIT;
	WHEN OTHERS THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
					   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'When Others '||SQLERRM);
		END IF;
		ROLLBACK TO PROCESS_RECALL_WORK;
		errbuf := x_msg_data;
		retcode := 2;
		-- clean up the processing flag.
		UPDATE csd_recall_lines SET processing_flag = 'N'
					WHERE processing_group_id = p_group_id;
		COMMIT;
		RAISE;

END PROCESS_RECALL_WORK;

/****************************************************************************************/
/* Procedure Name: refresh_recall_metrics												*/
/* Description: Refreshes the recall metrics for the recall number if passed, else      */
/* 				refreshes the metrics for all the open recalls. This program runs as    */
/*				concurrent program.													    */
/* -- History: 30/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/
PROCEDURE REFRESH_RECALL_METRICS(errbuf 		   			OUT NOCOPY VARCHAR2,
                               	 retcode 		   			OUT NOCOPY VARCHAR2,
                               	 p_recall_number			IN VARCHAR2 DEFAULT NULL )
IS
l_exists 					NUMBER;
l_metric_ids 				JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_accumulated_cost 			JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_wip_jobs_with_costs 		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_wip_jobs_without_costs 	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_remaining_cost         	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_gen_num_tbl				JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_recall_numbers			JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_recall_numbers_temp       JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
BEGIN
	-- check if the line exists for the recall number if passed else we will bring the metrics
	-- table in synch with all the recalls.
	IF p_recall_number IS NOT NULL
	THEN
		l_metric_ids.EXTEND;
		BEGIN
			SELECT metric_id
			INTO l_metric_ids(1)
			FROM csd_recall_metrics
			WHERE recall_number = p_recall_number;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				l_metric_ids(1) := -1;
		END;
		IF l_metric_ids(1) = -1
		THEN
			INSERT INTO csd_recall_metrics(metric_id,recall_number) values(csd_recall_metrics_s1.NEXTVAL,p_recall_number)
				RETURNING metric_id INTO l_metric_ids(1);
		END IF;
	ELSE
		INSERT INTO csd_recall_metrics(metric_id,recall_number)
				(SELECT csd_recall_metrics_s1.NEXTVAL,recall_number
					FROM csd_recall_headers_b,csd_recall_statuses_b crs
					WHERE recall_flow_status_id =  crs.status_id
					AND   crs.status_code <> 'C'
					AND NOT EXISTS ( SELECT 'exists'
										FROM csd_recall_metrics crm
										WHERE crm.recall_number = recall_number )
					AND recall_id in (SELECT MAX(recall_id) FROM csd_recall_headers_b
                                  			GROUP BY recall_number ));

    	SELECT DISTINCT metric_id
    	BULK COLLECT INTO l_metric_ids
    	FROM csd_recall_metrics crm,
    		 csd_recall_headers_b crh,
    		 csd_recall_statuses_b crs
        WHERE crh.recall_number = crm.recall_number
        AND	  crh.recall_flow_status_id = crs.status_id
        AND   crs.status_code <> 'C'
        AND   crm.metric_id NOT IN (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)));
	END IF;

	-- number of units recalled.
	SELECT crh.recall_number,SUM(cii.quantity)
	BULK COLLECT INTO l_recall_numbers,l_gen_num_tbl
	FROM csd_recall_metrics crm,
		 csd_recall_headers_b crh,
		 csd_recall_lines crl,
		 csi_item_instances cii
	WHERE crm.metric_id IN (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
	AND   crm.recall_number = crh.recall_number
	AND   crh.recall_id     = crl.recall_id
	AND   crl.instance_id   = cii.instance_id
	GROUP BY crh.recall_number;

	--dbms_output.put_line('first bulk collect');

	FORALL i IN 1 ..l_recall_numbers.COUNT
		UPDATE csd_recall_metrics SET recalled_units = l_gen_num_tbl(i)
			WHERE recall_number = l_recall_numbers(i);

	--dbms_output.put_line('after for all update');

	SELECT crh.recall_number, COUNT(DISTINCT crl.owner_party_id)
	BULK COLLECT INTO l_recall_numbers,l_gen_num_tbl
	FROM csd_recall_metrics crm,
		 csd_recall_headers_b crh,
		 csd_recall_lines crl
	WHERE crm.metric_id IN (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
	AND   crm.recall_number = crh.recall_number
	AND   crh.recall_id     = crl.recall_id
	GROUP BY crh.recall_number;

	--dbms_output.put_line('2nd bulk collect');
	-- number of customers impacted.
	FORALL i IN 1 ..l_recall_numbers.COUNT
		UPDATE csd_recall_metrics SET customers_impacted = l_gen_num_tbl(i)
			WHERE recall_number = l_recall_numbers(i);

	--dbms_output.put_line('after for all update');

	SELECT crh.recall_number,
			SUM(wpb.tl_resource_in+pl_resource_in+tl_overhead_in+pl_material_in+pl_material_overhead_in+pl_overhead_in)
	BULK COLLECT INTO l_recall_numbers, l_accumulated_cost
	FROM csd_recall_metrics crm,
		csd_recall_headers_b crh,
	  	csd_recall_lines crl,
	  	csd_repair_job_xref crj,
	  	wip_period_balances wpb
	WHERE crm.metric_id IN
			  (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
	AND crm.recall_number = crh.recall_number
	AND crh.recall_id       = crl.recall_id
	AND crl.repair_line_id  = crj.repair_line_id
	AND crj.wip_entity_id   = wpb.wip_entity_id
	GROUP BY crh.recall_number
	ORDER BY crh.recall_number;

	--dbms_output.put_line('3rd bulk collect');

	FORALL i IN 1 ..l_recall_numbers.COUNT
		UPDATE csd_recall_metrics SET accumulated_costs = l_accumulated_cost(i)
			WHERE recall_number = l_recall_numbers(i);

	-- WIP jobs which have not been costed yet.Take the sum of remaining quantity.
	SELECT recall_number,
	  SUM(QUANTITY)
	BULK COLLECT INTO l_recall_numbers, l_wip_jobs_without_costs
	FROM
	  (SELECT crh.recall_number,
	    SUM(crj.quantity) quantity
	  FROM csd_recall_metrics crm,
	    csd_recall_headers_b crh,
	    csd_recall_lines crl,
	    csd_repair_job_xref crj
	  WHERE crm.metric_id IN
	    (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)) )
	  AND crm.recall_number  = crh.recall_number
	  AND crh.recall_id      = crl.recall_id
	  AND crl.repair_line_id = crj.repair_line_id
	  AND NOT EXISTS
	    (SELECT 'exists'
	    FROM wip_period_balances wpb,
	    	 wip_discrete_jobs wdj
	    WHERE wpb.wip_entity_id = crj.wip_entity_id
	    AND   wpb.wip_entity_id = wdj.wip_entity_id
	    AND   wdj.status_type NOT IN (7,12,4,5)
	    GROUP BY wpb.wip_entity_id
	    HAVING SUM(tl_resource_in+pl_resource_in+tl_overhead_in+pl_material_in+pl_material_overhead_in+pl_overhead_in) > 0
	    )
	  GROUP BY crh.recall_number

	UNION ALL

	SELECT crh.recall_number,
	  SUM(cii.quantity) quantity
	FROM csd_recall_metrics crm,
	    csd_recall_headers_b crh,
	    csd_recall_lines crl,
	    csi_item_instances cii,
	    cs_incidents_all_b sr,
	  	cs_incident_statuses_b cis
	  WHERE crm.metric_id IN
	    (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
	  AND crm.recall_number = crh.recall_number
	  AND crh.recall_id     = crl.recall_id
	  AND crl.instance_id   = cii.instance_id
	  AND crl.incident_id  IS NOT NULL
	  AND crl.incident_id   = sr.incident_id
	  AND sr.incident_status_id = cis.incident_status_id
	  AND cis.status_code  <> 'CLOSED'
	  AND NOT EXISTS
	    (SELECT 'exists'
	    FROM csd_repairs cr,
	      csd_repair_job_xref crj1
	    WHERE cr.incident_id  = crl.incident_id
	    AND cr.repair_line_id = crj1.repair_line_id
	    )
	  GROUP BY crh.recall_number
	  )
	GROUP BY recall_number
	ORDER BY recall_number;

	--dbms_output.put_line('4th bulk collect');
	-- find out the number of units considered for accrued cost calculation.
	l_recall_numbers_temp := l_recall_numbers;
	SELECT crh.recall_number, SUM(crj.quantity)
	BULK COLLECT INTO l_recall_numbers,l_wip_jobs_with_costs
	FROM csd_recall_headers_b crh,
		 csd_recall_lines crl,
		 csd_repair_job_xref crj
	WHERE crh.recall_number IN
			( SELECT * FROM TABLE(CAST(l_recall_numbers_temp AS JTF_VARCHAR2_TABLE_100)))
	AND  crh.recall_id = crl.recall_id
	AND  crl.repair_line_id = crj.repair_line_id
	AND EXISTS (
		SELECT 'exists'
		FROM wip_period_balances
		WHERE wip_entity_id = crj.wip_entity_id
		GROUP BY wip_entity_id
    	HAVING SUM(tl_resource_in+pl_resource_in+tl_overhead_in+pl_material_in+pl_material_overhead_in+pl_overhead_in) > 0)
    GROUP BY crh.recall_number
    ORDER BY crh.recall_number;

	-- update the actual cost, and estimated cost remaining.
	FORALL i IN 1 ..l_recall_numbers.COUNT
		UPDATE csd_recall_metrics SET remaining_cost = (l_wip_jobs_without_costs(i) * (accumulated_costs/l_wip_jobs_with_costs(i)))
			WHERE recall_number = l_recall_numbers(i);

	-- remediated units.

	SELECT crh.recall_number,
	  	   SUM(cii.quantity)
	BULK COLLECT INTO l_recall_numbers,l_gen_num_tbl
	FROM csd_recall_metrics crm,
	  	csd_recall_headers_b crh,
	  	csd_recall_lines crl,
	  	cs_incidents_all_b sr,
	  	cs_incident_statuses_b cis,
	  	csi_item_instances cii
	WHERE crm.metric_id IN
	  (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
	AND crm.recall_number     = crh.recall_number
	AND crh.recall_id         = crl.recall_id
	AND crl.incident_id       = sr.incident_id
	AND sr.incident_status_id = cis.incident_status_id
	AND cis.status_code       = 'CLOSED'
	AND crl.instance_id       = cii.instance_id
	GROUP BY crh.recall_number;

	IF l_recall_numbers.COUNT = 0 OR l_recall_numbers.COUNT < l_metric_ids.COUNT
	THEN
		FORALL i IN 1 ..l_metric_ids.COUNT
			UPDATE csd_recall_metrics SET remediated_units = 0
				WHERE metric_id = l_metric_ids(i)
				AND recall_number NOT IN
						(SELECT * FROM TABLE(CAST(l_recall_numbers AS JTF_VARCHAR2_TABLE_100))) ;
	END IF;

	IF l_recall_numbers.COUNT > 0
	THEN
		FORALL i IN 1 ..l_recall_numbers.COUNT
			UPDATE csd_recall_metrics SET remediated_units = l_gen_num_tbl(i)
				WHERE recall_number = l_recall_numbers(i);
	END IF;
	-- un - remediated units.

	FORALL i IN 1 ..l_metric_ids.COUNT
		UPDATE csd_recall_metrics SET un_remediated_units = (recalled_units-nvl(remediated_units,0))
			WHERE metric_id = l_metric_ids(i);

	-- remediated custoemers.

	SELECT recall_number, COUNT(party_id)
	BULK COLLECT INTO l_recall_numbers,l_gen_num_tbl
	FROM (
		SELECT crh.recall_number,
			   COUNT(crl.owner_party_id) party_id
		FROM csd_recall_metrics crm,
			csd_recall_headers_b crh,
			csd_recall_lines crl,
			cs_incidents_all_b sr,
			cs_incident_statuses_b cis
		WHERE crm.metric_id IN
			  (SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
			AND crm.recall_number     = crh.recall_number
			AND crh.recall_id         = crl.recall_id
			AND crl.incident_id       = sr.incident_id
			AND sr.incident_status_id = cis.incident_status_id
			AND cis.status_code       = 'CLOSED'
			AND NOT EXISTS
					(SELECT  'exists'
					  FROM csd_recall_headers_b crh1,
						csd_recall_lines crl1,
						cs_incidents_all_b sr1,
						cs_incident_statuses_b cis1,
						csd_recall_metrics crm1
					  WHERE crm1.metric_id IN
									(SELECT * FROM TABLE(CAST(l_metric_ids AS JTF_NUMBER_TABLE)))
						AND crm1.recall_number = crh1.recall_number
						AND crh1.recall_id = crl1.recall_id
						AND crl1.owner_party_id = crl.owner_party_id
						AND crl1.incident_id = sr1.incident_id
						AND sr1.incident_status_id = cis1.incident_status_id
						AND cis1.status_code <> 'CLOSED'
			)
		GROUP BY crh.recall_number,crl.owner_party_id
	) GROUP BY recall_number;

	IF l_recall_numbers.COUNT = 0 OR l_recall_numbers.COUNT < l_metric_ids.COUNT
	THEN
		FORALL i IN 1 ..l_metric_ids.COUNT
			UPDATE csd_recall_metrics SET customers_remediated = 0
				WHERE metric_id = l_metric_ids(i)
				AND recall_number NOT IN
						(SELECT * FROM TABLE(CAST(l_recall_numbers AS JTF_VARCHAR2_TABLE_100))) ;
	END IF;

	IF l_recall_numbers.COUNT <> 0
	THEN
		FORALL i IN 1 ..l_recall_numbers.COUNT
			UPDATE csd_recall_metrics SET customers_remediated = NVL(l_gen_num_tbl(i),0)
				WHERE recall_number = l_recall_numbers(i);
	END IF;

	-- customers un remediated. also update the WHO columns.
	FORALL i IN 1 ..l_metric_ids.COUNT
		UPDATE csd_recall_metrics SET customers_un_remediated = (customers_impacted-nvl(customers_remediated,0)),
									last_update_date = sysdate,
								    last_updated_by = fnd_global.user_id,
									last_update_login = fnd_global.user_id,
									object_version_number = object_version_number+1
			WHERE metric_id = l_metric_ids(i);

EXCEPTION
	WHEN OTHERS THEN
		retcode := 2;
		errbuf  := 'Errored';
		--dbms_output.put_line(SQLERRM);
		RAISE;

END REFRESH_RECALL_METRICS;

END CSD_RECALLS_PVT;

/
