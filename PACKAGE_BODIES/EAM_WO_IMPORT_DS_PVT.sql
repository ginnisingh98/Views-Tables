--------------------------------------------------------
--  DDL for Package Body EAM_WO_IMPORT_DS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_IMPORT_DS_PVT" as
/* $Header: EAMVDSIB.pls 120.0 2005/06/08 02:56:21 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDSIB.pls
--
--  DESCRIPTION
--  Package Body for importing Work Order from Interface Tables for
--  Detailed Scheduling Project
--  NOTES
--
--  HISTORY
--
-- 23-SEP-2004    Milind Maduskar     Initial Creation
***************************************************************************/
g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_WO_IMPORT_DS_PVT';

-- Start of comments
-- API name    : log_network_error_messages
-- Type        :  Private.
-- Function    : This procedure will mark all the work orders in hierarchy as invalid
-- Pre-reqs    : None.
-- Parameters  :
-- IN
--	           p_group_id	              IN NUMBER
--						        Required Group Identifier
--	           p_top_wip_entity_id        IN NUMBER
--							Required Top wip entity id of the work order in hierarchy
--	           p_validate_fail            IN BOOLEAN
--							Required Will have value of 'TRUE' if this procedure is called because Validate_Structure
--							returned error.
--		                                        Will have value of 'FALSE' if this procedure is called because l_relationship_errors= TRUE.
--							(Update for one of work order in hierarchy has failed.Hence fail entired hierarchy)
--                 p_wo_relationship_exc_tbl  IN EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
--							Required Table containing list of exception messages
--
-- Initial version  1.0
--
-- End of comments

PROCEDURE log_network_error_messages(p_group_id NUMBER,
				     p_top_wip_entity_id NUMBER,
				     p_validate_fail BOOLEAN,
				     p_wo_relationship_exc_tbl EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
				     )
IS
	temp_err_mesg			VARCHAR2(4000);

	PRAGMA  AUTONOMOUS_TRANSACTION;
	BEGIN

	IF p_validate_fail THEN
		-- Validate_Structure failed .Fail entire structure with status 3
                UPDATE EAM_WORK_ORDER_IMPORT
                   SET process_status = 3,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login  = fnd_global.login_id
                 WHERE group_id = p_group_id
                   AND wip_entity_id IN (SELECT wip_entity_id
                                           FROM EAM_WORK_ORDER_IMPORT
                                          WHERE top_wip_entity_id= p_top_wip_entity_id);

	ELSE
		-- Update for One work order in hierarchy has failed.Fail entire structure with status 3
		-- Since some work orders has errored out,they will be in status 4 Hence only pick up
		-- those work orders which in status 2
                 UPDATE EAM_WORK_ORDER_IMPORT
                    SET process_status = 3,
                        last_update_date = sysdate,
                        last_updated_by  = fnd_global.user_id,
                        last_update_login  = fnd_global.login_id
                  WHERE group_id = p_group_id
                    AND wip_entity_id in (SELECT wip_entity_id
                                            FROM EAM_WORK_ORDER_IMPORT
                                           WHERE top_wip_entity_id= p_top_wip_entity_id
                                             AND process_status =2);
	END IF;

	IF p_validate_fail THEN
			fnd_file.put_line(FND_FILE.LOG,'Status Relationship Error .Structure failed while updating work order hierarchy with parent work order ' || p_top_wip_entity_id);
			fnd_file.put_line(FND_FILE.LOG,'Error Stack: ');
			IF p_wo_relationship_exc_tbl.count > 0 THEN
				FOR work_rel_counter IN  p_wo_relationship_exc_tbl.FIRST..p_wo_relationship_exc_tbl.LAST LOOP
				     INSERT INTO EAM_WORK_ORDER_IMPORT_ERRORS(
					header_id ,
					group_id ,
					row_id ,
					error_message ,
					last_update_date ,
					last_updated_by ,
					creation_date ,
					created_by ,
					last_update_login
					)
				   VALUES(
					p_top_wip_entity_id,
					p_group_id,
					1,
					p_wo_relationship_exc_tbl(work_rel_counter),
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id
				   );
				fnd_file.put_line(FND_FILE.LOG,p_wo_relationship_exc_tbl(work_rel_counter));
				END LOOP;
			END IF;
			fnd_file.put_line(FND_FILE.LOG,'Hence Marking following workorders under hierarchy as failed :');
			FOR log_counter IN (SELECT wip_entity_id
		     			      FROM EAM_WORK_ORDER_IMPORT
  				             WHERE group_id = p_group_id
					       AND top_wip_entity_id=p_top_wip_entity_id
					    )
			LOOP
			   fnd_file.put_line(FND_FILE.LOG,'Status Relationship Error for work order --' || log_counter.wip_entity_id);
			END LOOP;

	ELSE	-- Validate structure has not failed.Error occured before calling validate structure

		fnd_file.put_line(FND_FILE.LOG,'Status Relationship Error .Structure failed while updating the one of work order under the hierarchy with parent work order ' || p_top_wip_entity_id);
		fnd_file.put_line(FND_FILE.LOG,'Error Stack :' || temp_err_mesg);
		fnd_file.put_line(FND_FILE.LOG,'Hence Marking following workorders under hierarchy as failed :');
		FOR log_counter IN ( SELECT wip_entity_id
                                       FROM EAM_WORK_ORDER_IMPORT
                                      WHERE group_id = p_group_id
                                        AND top_wip_entity_id=p_top_wip_entity_id
                                    )
			LOOP
				fnd_file.put_line(FND_FILE.LOG,'Status Relationship Error for work order --' || log_counter.wip_entity_id);
			END LOOP;
	END IF;

	COMMIT;
END log_network_error_messages;

-- Start of comments
-- API name   : log_error_messages
-- Type       : Private.
-- Function   : In EAM_WORK_ORDER_IMPORT_ERRORS, inserts a row for each error message retrieved from work order API
--	        message stack. Update the column RETURN_STATUS of the import with the API return_status,
--              also update RETURN_STATUS in all child tables with the return status got from the output child
--              records such as the ones for operations, resources etc. Update the WHO columns like LAST_UPDATE_DATE,
--              LAST_UPDATED_BY, LAST_UPDATE_LOGIN whenever any update is done to any import table record
-- Pre-reqs   :  None.
-- Parameters :
-- IN         :
--               l_return_status     IN VARCHAR2 Required
--							 Status returned by work order api.This can be 'E'/'U'
--               l_group_id          IN NUMBER Required
--							Group Id
--               p_wo_rec            IN EAM_WORK_ORDER_IMPORT%ROWTYPE
--							Required Work Order Record fetched from cursor
--               p_eam_op_tbl        IN EAM_PROCESS_WO_PUB.eam_op_tbl_type Required
--							Operation out table from work order api
--               p_eam_res_tbl       IN EAM_PROCESS_WO_PUB.eam_res_tbl_type Required
--							Resource out table from work order api
--               p_eam_res_inst_tbl  IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type Required
--							Resource Instance out table from work order api
--               p_eam_res_usage_tbl IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type Required
--							Resource Usage out table from work order api
--               p_eam_mat_req_tbl   IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type Required
--							Material out table from work order api
--
-- Initial version  1.0
--
-- End of comments

PROCEDURE log_error_messages(p_return_status	 VARCHAR2,
			     p_group_id	 	 NUMBER,
			     p_wo_rec		 EAM_WORK_ORDER_IMPORT%ROWTYPE,
			     p_eam_op_tbl	 EAM_PROCESS_WO_PUB.eam_op_tbl_type,
			     p_eam_res_tbl	 EAM_PROCESS_WO_PUB.eam_res_tbl_type,
			     p_eam_res_inst_tbl	 EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
			     p_eam_res_usage_tbl EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
			     p_eam_mat_req_tbl	 EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
			     )
IS
	l_msg_count			NUMBER;
	msg_index			NUMBER;
	temp_err_mesg			VARCHAR2(4000);

	PRAGMA  AUTONOMOUS_TRANSACTION;
	BEGIN

                UPDATE EAM_WORK_ORDER_IMPORT
                   SET process_status = 4 ,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login  = fnd_global.login_id
                 WHERE group_id = p_group_id
                   AND wip_entity_id = p_wo_rec.wip_entity_id;

			-- get the error messages from the work order api exception stack and insert
			-- into EAM_WORK_ORDER_IMPORT_ERRORS

			l_msg_count := fnd_msg_pub.count_msg;
			IF(l_msg_count>0) THEN
				 msg_index := l_msg_count;
				 FOR i IN 1..l_msg_count LOOP
					 fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
					    p_encoded   => 'F',
					    p_data      => temp_err_mesg,
					    p_msg_index_out => msg_index);

					INSERT INTO EAM_WORK_ORDER_IMPORT_ERRORS(
						header_id ,
						group_id ,
						row_id ,
						error_message ,
						last_update_date ,
						last_updated_by ,
						creation_date ,
						created_by ,
						last_update_login
						)
					VALUES(
						p_wo_rec.header_id,
						p_wo_rec.group_id,
						p_wo_rec.row_id,
						temp_err_mesg,
						sysdate,
						fnd_global.user_id,
						sysdate,
						fnd_global.user_id,
						fnd_global.login_id
					      );

				 END LOOP;
			END IF; -- end if for l_msg_count>0
			fnd_file.put_line(FND_FILE.LOG,'Status Error for work order --' || p_wo_rec.wip_entity_id);
			fnd_file.put_line(FND_FILE.LOG,'Error Stack --' || temp_err_mesg);


			-- Following code loops through the out tables from work order API and updates the status
			-- of corresponding  import tables.It also updates the who columns

			FOR counter_res_ins IN 1..p_eam_res_inst_tbl.count LOOP
                                UPDATE EAM_RESOURCE_INSTANCE_IMPORT
                                   SET return_status = p_eam_res_inst_tbl(counter_res_ins).return_status,
                                       last_update_date = sysdate,
                                       last_updated_by  = fnd_global.user_id,
                                       last_update_login  = fnd_global.login_id
                                 WHERE group_id = p_group_id
                                   AND wip_entity_id = p_eam_res_inst_tbl(counter_res_ins).wip_entity_id
                                   AND (instance_id = p_eam_res_inst_tbl(counter_res_ins).instance_id OR instance_id IS NULL)
                                   AND (serial_number = p_eam_res_inst_tbl(counter_res_ins).serial_number OR serial_number IS NULL);
			END LOOP;

			FOR counter_res_usg IN 1..p_eam_res_usage_tbl.count LOOP
                                UPDATE EAM_RESOURCE_USAGE_IMPORT
                                   SET return_status = p_eam_res_usage_tbl(counter_res_usg).return_status,
                                       last_update_date = sysdate,
                                       last_updated_by  = fnd_global.user_id,
                                       last_update_login  = fnd_global.login_id
                                 WHERE group_id = p_group_id
                                   AND wip_entity_id = p_eam_res_usage_tbl(counter_res_usg).wip_entity_id
                                   AND resource_seq_num = p_eam_res_usage_tbl(counter_res_usg).resource_seq_num;
			END LOOP;

			FOR counter_res IN 1..p_eam_res_tbl.count LOOP
                                UPDATE EAM_RESOURCE_IMPORT
                                   SET return_status = p_eam_res_tbl(counter_res).return_status,
                                       last_update_date = sysdate,
                                       last_updated_by  = fnd_global.user_id,
                                       last_update_login  = fnd_global.login_id
                                 WHERE group_id = p_group_id
                                   AND wip_entity_id = p_eam_res_tbl(counter_res).wip_entity_id
                                   AND resource_seq_num = p_eam_res_tbl(counter_res).resource_seq_num;
			END LOOP;

			FOR counter_mat IN 1..p_eam_mat_req_tbl.count LOOP
                                UPDATE EAM_MATERIAL_IMPORT
                                   SET return_status = p_eam_mat_req_tbl(counter_mat).return_status,
                                       last_update_date = sysdate,
                                       last_updated_by  = fnd_global.user_id,
                                       last_update_login  = fnd_global.login_id
                                 WHERE group_id = p_group_id
                                   AND wip_entity_id = p_eam_mat_req_tbl(counter_mat).wip_entity_id
                                   AND inventory_item_id = p_eam_mat_req_tbl(counter_mat).inventory_item_id;
			END LOOP;

			FOR counter_op IN 1..p_eam_op_tbl.count LOOP
                                UPDATE EAM_OPERATION_IMPORT
                                   SET return_status = p_eam_op_tbl(counter_op).return_status,
                                       last_update_date = sysdate,
                                       last_updated_by  = fnd_global.user_id,
                                       last_update_login  = fnd_global.login_id
                                 WHERE group_id = p_group_id
                                   AND wip_entity_id = p_eam_op_tbl(counter_op).wip_entity_id
                                   AND operation_seq_num = p_eam_op_tbl(counter_op).operation_seq_num;
                        END LOOP;

                        UPDATE EAM_WORK_ORDER_IMPORT
                           SET return_status = p_return_status,
                               last_update_date = sysdate,
                               last_updated_by  = fnd_global.user_id,
                               last_update_login  = fnd_global.login_id
                         WHERE group_id = p_group_id
                           AND wip_entity_id = p_wo_rec.wip_entity_id;
                 COMMIT;
END;

   -- Start of comments
   -- API name    : IMPORT_WORKORDER
   -- Type        : Private.
   -- Pre-reqs    : None.
   -- Function    : This is a concurrent program.It reads the data from interface tables and updates correponding entries
   --               in WIP tables.It logs the error into the error table.The log file of the concurrent program gives
   --               the details of work order that has been imported sucessfully and the work orders that has errored
   --               out while importing.
   -- Parameters  :
   -- IN          :
   --                  P_GROUP_ID IN NUMBER Required
   --				Is a mandatory parameter.Its an id to process a group of records together.
   -- OUT
   --                  errbuf OUT NOCOPY VARCHAR2 mandatory out parameters for the concurrent program.
   --                  retcode OUT NOCOPY NUMBER mandatory out parameters for the concurrent program.
   --		       Initial version 	1.0
   -- End of comments

PROCEDURE IMPORT_WORKORDER(
  errbuf                      OUT NOCOPY     VARCHAR2,
  retcode                     OUT NOCOPY     NUMBER,
  P_GROUP_ID		      IN	     NUMBER)
  IS

        l_top_wip_entity_id		NUMBER;
        l_old_top_wip_entity_id		NUMBER;
        l_entering_rel_structure	BOOLEAN:=false;
        l_exiting_rel_structure		BOOLEAN:=false;
        l_standalone			BOOLEAN:=false;
        l_last_record			BOOLEAN:=false;
        l_relationship_errors		BOOLEAN:=false;
        l_group_id			NUMBER;

        l_output_dir			VARCHAR2(255);
        l_return_status			VARCHAR2(1);
        l_msg_count			NUMBER;

        l_eam_wo_rec			EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl			EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl			EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl		EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl		EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl		EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl         		EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
        l_eam_wo_quality_tbl		EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_eam_meter_reading_tbl		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_wo_comp_rebuild_tbl	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_eam_wo_comp_mr_read_tbl	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_eam_op_comp_tbl		EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl		EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_out_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl		EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl		EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl		EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl		EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
        l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_eam_op_rec			EAM_PROCESS_WO_PUB.eam_op_rec_type;
        l_eam_res_rec			EAM_PROCESS_WO_PUB.eam_res_rec_type;
        l_eam_res_inst_rec		EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
        l_eam_res_usage_rec		EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;
        l_eam_mat_req_rec		EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;

        l_operation_index		NUMBER;
        l_material_index		NUMBER;
        l_resource_index		NUMBER;
        l_resource_usage_index		NUMBER;
        l_resource_instance_index	NUMBER;
        l_conc_status			BOOLEAN;
        l_error_message			VARCHAR2(4000);

        TYPE l_import_wo_records IS REF CURSOR RETURN EAM_WORK_ORDER_IMPORT%ROWTYPE;
        l_import_wo		        l_import_wo_records;
        l_import_wo_record		EAM_WORK_ORDER_IMPORT%ROWTYPE;

        l_wo_relationship_exc_tbl       EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;

        l_msg_data			VARCHAR2(4000);

  CURSOR import_wo_oper_cur (l_group_id NUMBER,l_wip_entity_id NUMBER) IS
  SELECT *
            FROM EAM_OPERATION_IMPORT EOI
           WHERE eoi.group_id        = l_group_id
             AND eoi.wip_entity_id   = l_wip_entity_id;

          CURSOR import_wo_material_cur (l_group_id NUMBER,l_wip_entity_id NUMBER) IS
          SELECT *
            FROM EAM_MATERIAL_IMPORT EMI
           WHERE emi.group_id        = l_group_id
             AND emi.wip_entity_id   = l_wip_entity_id;

          CURSOR import_wo_resource_cur (l_p_group_id NUMBER,l_wip_entity_id NUMBER) IS
          SELECT *
            FROM EAM_RESOURCE_IMPORT ERI
           WHERE eri.group_id        = l_group_id
             AND eri.wip_entity_id   = l_wip_entity_id;

           CURSOR import_wo_resource_usage_cur (l_group_id NUMBER,l_wip_entity_id NUMBER) IS
           SELECT *
             FROM EAM_RESOURCE_USAGE_IMPORT ERUI
            WHERE erui.group_id        = l_group_id
              AND erui.wip_entity_id   = l_wip_entity_id;

           CURSOR import_wo_res_instance_cur (l_group_id NUMBER,l_wip_entity_id NUMBER) IS
           SELECT *
             FROM EAM_RESOURCE_INSTANCE_IMPORT ERIM
            WHERE erim.group_id        = l_group_id
              AND erim.wip_entity_id   = l_wip_entity_id;

    BEGIN

	fnd_file.put_line(FND_FILE.LOG,'-----------START OF WORK ORDER IMPORT CONCURRENT PROGRAM-----------');

	retcode:=0;
	l_error_message :='No error message ';
	l_group_id:= P_GROUP_ID;

	-- Update the status of work order from Pending to Running
        UPDATE EAM_WORK_ORDER_IMPORT
           SET process_status   = 2
         WHERE group_id         = l_group_id
           AND process_status   = 1 ;

	-- Clear out any previously errored rows which are resubmitted
        DELETE EAM_WORK_ORDER_IMPORT_ERRORS
         WHERE header_id IN (
                              SELECT wip_entity_id
                                FROM EAM_WORK_ORDER_IMPORT
                               WHERE group_id   = l_group_id
                                 AND process_status =2
                             );

	-- Update the rows and set the value of top_wip_entity_id
         UPDATE  EAM_WORK_ORDER_IMPORT ewoi
            SET top_wip_entity_id = (
                                     SELECT distinct wsr.top_level_object_id
                                       FROM WIP_SCHED_RELATIONSHIPS wsr
                                      WHERE wsr.relationship_type =1
                                        AND (ewoi.wip_entity_id = wsr.child_object_id OR   ewoi.wip_entity_id = wsr.parent_object_id)
                                    )
         WHERE process_status = 2;

       /* get output directory path from database */
       EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);
       COMMIT;

       -- Open Cursor
       IF NOT l_import_wo%ISOPEN THEN
              OPEN l_import_wo FOR
            SELECT *
              FROM EAM_WORK_ORDER_IMPORT
             WHERE group_id        = l_group_id
               AND process_status = 2
          ORDER BY top_wip_entity_id ASC;
       END IF;

       LOOP
	BEGIN
       	FETCH l_import_wo INTO
	        l_import_wo_record;

         IF l_import_wo%NOTFOUND THEN
		l_last_record:=TRUE;
		l_top_wip_entity_id:=null;
         END IF ;

	-- Delete tables befor calling work order api
        l_eam_op_tbl.delete;
        l_eam_op_network_tbl.delete;
        l_eam_res_tbl.delete;
        l_eam_res_inst_tbl.delete;
        l_eam_sub_res_tbl.delete;
        l_eam_res_usage_tbl.delete;
        l_eam_mat_req_tbl.delete;
        l_eam_di_tbl.delete;
	l_eam_wo_quality_tbl.delete;
	l_eam_meter_reading_tbl.delete;
	l_eam_wo_comp_rebuild_tbl.delete;
	l_eam_wo_comp_mr_read_tbl.delete;
	l_eam_op_comp_tbl.delete;
	l_eam_request_tbl.delete;
        l_out_eam_op_tbl.delete;
        l_out_eam_op_network_tbl.delete;
        l_out_eam_res_tbl.delete;
        l_out_eam_res_inst_tbl.delete;
        l_out_eam_sub_res_tbl.delete;
        l_out_eam_res_usage_tbl.delete;
        l_out_eam_mat_req_tbl.delete;
	l_out_eam_di_tbl.delete;
	l_out_eam_wo_quality_tbl.delete;
	l_out_eam_meter_reading_tbl.delete;
	l_out_eam_wo_comp_rebuild_tbl.delete;
	l_out_eam_wo_comp_mr_read_tbl.delete;
	l_out_eam_op_comp_tbl.delete;
	l_out_eam_request_tbl.delete;
	l_out_eam_counter_prop_tbl.delete;

	 IF l_last_record = FALSE THEN
		l_top_wip_entity_id :=l_import_wo_record.top_wip_entity_id;

		IF l_top_wip_entity_id IS NULL THEN
			l_standalone :=TRUE;
		END IF;

		IF (l_top_wip_entity_id IS NOT NULL AND l_old_top_wip_entity_id IS NULL) OR
			(l_top_wip_entity_id <> l_old_top_wip_entity_id) THEN
				l_entering_rel_structure :=TRUE;
		ELSE
				l_entering_rel_structure :=FALSE;
		END IF;
	 END IF;

	 IF (l_old_top_wip_entity_id IS NOT NULL AND l_top_wip_entity_id IS NULL) OR
		(l_top_wip_entity_id <> l_old_top_wip_entity_id) THEN
		l_exiting_rel_structure := TRUE;
	 ELSE
		l_exiting_rel_structure := FALSE;
	 END IF;

	 IF l_exiting_rel_structure = TRUE THEN

		IF l_relationship_errors = TRUE THEN
			ROLLBACK TO EAM_REL_STRUCTURE_START;
			l_wo_relationship_exc_tbl.delete;
			log_network_error_messages(l_group_id,l_old_top_wip_entity_id,false,l_wo_relationship_exc_tbl);

		ELSE
			l_wo_relationship_exc_tbl.delete;
			EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
				(
				p_api_version                   => 1.0,
				p_init_msg_list                 => FND_API.G_FALSE,
				p_commit                        => FND_API.G_FALSE,
				p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

				p_work_object_id                => l_old_top_wip_entity_id,
				p_work_object_type_id           => 1,
				p_exception_logging             => 'Y',

				p_validate_status		=> 'Y',
				p_output_errors			=> 'Y',

				x_return_status                 => l_return_status,
				x_msg_count                     => l_msg_count,
				x_msg_data                      => l_msg_data,
				x_wo_relationship_exc_tbl       => l_wo_relationship_exc_tbl
			);

			IF l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				log_network_error_messages(l_group_id,l_old_top_wip_entity_id,true,l_wo_relationship_exc_tbl);
				ROLLBACK TO EAM_REL_STRUCTURE_START;
			ELSE
				-- if it succedds we need to purge data
				-- Purge this import record and associated records from the child tables.

                                FOR log_counter IN ( SELECT wip_entity_id
                                                       FROM EAM_WORK_ORDER_IMPORT
                                                      WHERE group_id = l_group_id
                                                        AND top_wip_entity_id = l_old_top_wip_entity_id) LOOP
                                                           fnd_file.put_line(FND_FILE.LOG,'Status Sucess for work order --' || log_counter.wip_entity_id);
                                END LOOP;

                                DELETE
                                  FROM EAM_RESOURCE_INSTANCE_IMPORT
                                 WHERE group_id = l_group_id
                                   AND wip_entity_id IN (
                                                           SELECT wip_entity_id
                                                             FROM EAM_WORK_ORDER_IMPORT
                                                            WHERE group_id = l_group_id
                                                              AND top_wip_entity_id = l_old_top_wip_entity_id
                                                         );

                                DELETE
                                  FROM EAM_RESOURCE_USAGE_IMPORT
                                 WHERE group_id = l_group_id
                                   AND wip_entity_id IN (
                                                           SELECT wip_entity_id
                                                             FROM EAM_WORK_ORDER_IMPORT
                                                            WHERE group_id = l_group_id
                                                              AND top_wip_entity_id = l_old_top_wip_entity_id
						      );

                                DELETE
                                  FROM EAM_RESOURCE_IMPORT
                                 WHERE group_id = l_group_id
                                   AND wip_entity_id IN (
                                                           SELECT wip_entity_id
                                                             FROM EAM_WORK_ORDER_IMPORT
                                                            WHERE group_id = l_group_id
                                                              AND top_wip_entity_id = l_old_top_wip_entity_id
						      );

                                DELETE
                                  FROM EAM_MATERIAL_IMPORT
                                 WHERE group_id = l_group_id
                                   AND wip_entity_id IN (
                                                           SELECT wip_entity_id
                                                             FROM EAM_WORK_ORDER_IMPORT
                                                            WHERE group_id = l_group_id
                                                              AND top_wip_entity_id = l_old_top_wip_entity_id
                                                        );

                                DELETE
                                  FROM EAM_OPERATION_IMPORT
                                 WHERE group_id = l_group_id
                                   AND wip_entity_id IN (
                                                           SELECT wip_entity_id
                                                             FROM EAM_WORK_ORDER_IMPORT
                                                            WHERE group_id = l_group_id
                                                              AND top_wip_entity_id = l_old_top_wip_entity_id
                                                         );

                                DELETE
                                  FROM EAM_WORK_ORDER_IMPORT
                                 WHERE group_id = l_group_id
                                   AND   top_wip_entity_id = l_old_top_wip_entity_id;

				COMMIT;
			END IF;
		END IF;
	END IF;

	IF l_entering_rel_structure = TRUE THEN
			SAVEPOINT EAM_REL_STRUCTURE_START;
			l_relationship_errors := FALSE;
	END IF;

	IF l_last_record THEN
		COMMIT;
		EXIT;
	END IF;

	l_old_top_wip_entity_id:=l_top_wip_entity_id;

	SAVEPOINT EAM_WORK_ORDER_START;

          l_eam_wo_rec.header_id                     :=l_import_wo_record.header_id;
          l_eam_wo_rec.batch_id                      :=l_import_wo_record.group_id;
          l_eam_wo_rec.row_id                        :=l_import_wo_record.row_id;
          l_eam_wo_rec.wip_entity_name               :=l_import_wo_record.wip_entity_name;
          l_eam_wo_rec.wip_entity_id                 :=l_import_wo_record.wip_entity_id;
          l_eam_wo_rec.organization_id               :=l_import_wo_record.organization_id;
          l_eam_wo_rec.description                   :=l_import_wo_record.description;
          l_eam_wo_rec.asset_number                  :=l_import_wo_record.asset_number;
          l_eam_wo_rec.asset_group_id                :=l_import_wo_record.asset_group_id;
          l_eam_wo_rec.rebuild_item_id               :=l_import_wo_record.rebuild_item_id;
          l_eam_wo_rec.rebuild_serial_number         :=l_import_wo_record.rebuild_serial_number;
          l_eam_wo_rec.maintenance_object_id         :=l_import_wo_record.maintenance_object_id;
          l_eam_wo_rec.maintenance_object_type       :=l_import_wo_record.maintenance_object_type;
          l_eam_wo_rec.maintenance_object_source     :=l_import_wo_record.maintenance_object_source;
          l_eam_wo_rec.class_code                    :=l_import_wo_record.class_code;
          l_eam_wo_rec.asset_activity_id             :=l_import_wo_record.asset_activity_id;
          l_eam_wo_rec.activity_type                 :=l_import_wo_record.activity_type;
          l_eam_wo_rec.activity_cause                :=l_import_wo_record.activity_cause;
          l_eam_wo_rec.activity_source               :=l_import_wo_record.activity_source;
          l_eam_wo_rec.work_order_type               :=l_import_wo_record.work_order_type;
          l_eam_wo_rec.status_type                   :=l_import_wo_record.status_type;
          l_eam_wo_rec.job_quantity                  :=l_import_wo_record.job_quantity;
          l_eam_wo_rec.date_released                 :=l_import_wo_record.date_released;
          l_eam_wo_rec.owning_department             :=l_import_wo_record.owning_department;
          l_eam_wo_rec.priority                      :=l_import_wo_record.priority;
          l_eam_wo_rec.requested_start_date          :=l_import_wo_record.requested_start_date;
          l_eam_wo_rec.due_date                      :=l_import_wo_record.due_date;
          l_eam_wo_rec.shutdown_type                 :=l_import_wo_record.shutdown_type;
          l_eam_wo_rec.firm_planned_flag             :=l_import_wo_record.firm_planned_flag;
          l_eam_wo_rec.notification_required         :=l_import_wo_record.notification_required;
          l_eam_wo_rec.tagout_required               :=l_import_wo_record.tagout_required;
          l_eam_wo_rec.plan_maintenance              :=l_import_wo_record.plan_maintenance;
          l_eam_wo_rec.project_id                    :=l_import_wo_record.project_id;
          l_eam_wo_rec.task_id                       :=l_import_wo_record.task_id;
          l_eam_wo_rec.end_item_unit_number          :=l_import_wo_record.end_item_unit_number;
          l_eam_wo_rec.schedule_group_id             :=l_import_wo_record.schedule_group_id;
          l_eam_wo_rec.bom_revision_date             :=l_import_wo_record.bom_revision_date;
          l_eam_wo_rec.routing_revision_date         :=l_import_wo_record.routing_revision_date;
          l_eam_wo_rec.alternate_routing_designator  :=l_import_wo_record.alternate_routing_designator;
          l_eam_wo_rec.alternate_bom_designator      :=l_import_wo_record.alternate_bom_designator;
          l_eam_wo_rec.routing_revision              :=l_import_wo_record.routing_revision;
          l_eam_wo_rec.bom_revision                  :=l_import_wo_record.bom_revision;
          l_eam_wo_rec.parent_wip_entity_id          :=l_import_wo_record.parent_wip_entity_id;
          l_eam_wo_rec.manual_rebuild_flag           :=l_import_wo_record.manual_rebuild_flag;
          l_eam_wo_rec.pm_schedule_id                :=l_import_wo_record.pm_schedule_id;
          l_eam_wo_rec.wip_supply_type               :=l_import_wo_record.wip_supply_type;
          l_eam_wo_rec.material_account              :=l_import_wo_record.material_account;
          l_eam_wo_rec.material_overhead_account     :=l_import_wo_record.material_overhead_account;
          l_eam_wo_rec.resource_account              :=l_import_wo_record.resource_account;
          l_eam_wo_rec.outside_processing_account    :=l_import_wo_record.outside_processing_account;
          l_eam_wo_rec.material_variance_account     :=l_import_wo_record.material_variance_account;
          l_eam_wo_rec.resource_variance_account     :=l_import_wo_record.resource_variance_account;
          l_eam_wo_rec.outside_proc_variance_account :=l_import_wo_record.outside_proc_variance_account;
          l_eam_wo_rec.std_cost_adjustment_account   :=l_import_wo_record.std_cost_adjustment_account;
          l_eam_wo_rec.overhead_account              :=l_import_wo_record.overhead_account;
          l_eam_wo_rec.overhead_variance_account     :=l_import_wo_record.overhead_variance_account;
          l_eam_wo_rec.scheduled_start_date          :=l_import_wo_record.scheduled_start_date;
          l_eam_wo_rec.scheduled_completion_date     :=l_import_wo_record.scheduled_completion_date;
          l_eam_wo_rec.common_bom_sequence_id        :=l_import_wo_record.common_bom_sequence_id;
          l_eam_wo_rec.common_routing_sequence_id    :=l_import_wo_record.common_routing_sequence_id;
          l_eam_wo_rec.po_creation_time              :=l_import_wo_record.po_creation_time;
          l_eam_wo_rec.gen_object_id                 :=l_import_wo_record.gen_object_id;
          l_eam_wo_rec.attribute_category            :=l_import_wo_record.attribute_category;
          l_eam_wo_rec.attribute1                    :=l_import_wo_record.attribute1;
          l_eam_wo_rec.attribute2                    :=l_import_wo_record.attribute2;
          l_eam_wo_rec.attribute3                    :=l_import_wo_record.attribute3;
          l_eam_wo_rec.attribute4                    :=l_import_wo_record.attribute4;
          l_eam_wo_rec.attribute5                    :=l_import_wo_record.attribute5;
          l_eam_wo_rec.attribute6                    :=l_import_wo_record.attribute6;
          l_eam_wo_rec.attribute7                    :=l_import_wo_record.attribute7;
          l_eam_wo_rec.attribute8                    :=l_import_wo_record.attribute8;
          l_eam_wo_rec.attribute9                    :=l_import_wo_record.attribute9;
          l_eam_wo_rec.attribute10                   :=l_import_wo_record.attribute10;
          l_eam_wo_rec.attribute11                   :=l_import_wo_record.attribute11;
          l_eam_wo_rec.attribute12                   :=l_import_wo_record.attribute12;
          l_eam_wo_rec.attribute13                   :=l_import_wo_record.attribute13;
          l_eam_wo_rec.attribute14                   :=l_import_wo_record.attribute14;
          l_eam_wo_rec.attribute15                   :=l_import_wo_record.attribute15;
          l_eam_wo_rec.material_issue_by_mo          :=l_import_wo_record.material_issue_by_mo;
          l_eam_wo_rec.issue_zero_cost_flag          :=l_import_wo_record.issue_zero_cost_flag;
          l_eam_wo_rec.user_id                       :=l_import_wo_record.user_id;
          l_eam_wo_rec.responsibility_id             :=l_import_wo_record.responsibility_id;
          l_eam_wo_rec.request_id                    :=l_import_wo_record.request_id;
          l_eam_wo_rec.program_id                    :=l_import_wo_record.program_id;
          l_eam_wo_rec.program_application_id        :=l_import_wo_record.program_application_id;
          l_eam_wo_rec.source_line_id                :=l_import_wo_record.source_line_id;
          l_eam_wo_rec.source_code                   :=l_import_wo_record.source_code;
          l_eam_wo_rec.validate_structure            :='Y';
          l_eam_wo_rec.ds_scheduled_flag             :='Y';
          l_eam_wo_rec.return_status                 :=l_import_wo_record.return_status;
          l_eam_wo_rec.transaction_type              :=l_import_wo_record.transaction_type;

          l_operation_index := 1;

   FOR l_wo_op IN import_wo_oper_cur (l_group_id,l_eam_wo_rec.wip_entity_id)
    LOOP
          l_eam_op_rec.header_id                     :=l_wo_op.header_id;
          l_eam_op_rec.batch_id                      :=l_wo_op.group_id;
          l_eam_op_rec.row_id                        :=l_wo_op.row_id;
          l_eam_op_rec.wip_entity_id                 :=l_wo_op.wip_entity_id;
          l_eam_op_rec.organization_id               :=l_wo_op.organization_id;
          l_eam_op_rec.operation_seq_num             :=l_wo_op.operation_seq_num;
          l_eam_op_rec.standard_operation_id         :=l_wo_op.standard_operation_id;
          l_eam_op_rec.department_id                 :=l_wo_op.department_id;
          l_eam_op_rec.operation_sequence_id         :=l_wo_op.operation_sequence_id;
          l_eam_op_rec.description                   :=l_wo_op.description;
          l_eam_op_rec.minimum_transfer_quantity     :=l_wo_op.minimum_transfer_quantity;
          l_eam_op_rec.count_point_type              :=l_wo_op.count_point_type;
          l_eam_op_rec.backflush_flag                :=l_wo_op.backflush_flag;
          l_eam_op_rec.shutdown_type                 :=l_wo_op.shutdown_type;
          l_eam_op_rec.start_date                    :=l_wo_op.start_date;
          l_eam_op_rec.completion_date               :=l_wo_op.completion_date;
          l_eam_op_rec.attribute_category            :=l_wo_op.attribute_category;
          l_eam_op_rec.attribute1                    :=l_wo_op.attribute1;
          l_eam_op_rec.attribute2                    :=l_wo_op.attribute2;
          l_eam_op_rec.attribute3                    :=l_wo_op.attribute3;
          l_eam_op_rec.attribute4                    :=l_wo_op.attribute4;
          l_eam_op_rec.attribute5                    :=l_wo_op.attribute5;
          l_eam_op_rec.attribute6                    :=l_wo_op.attribute6;
          l_eam_op_rec.attribute7                    :=l_wo_op.attribute7;
          l_eam_op_rec.attribute8                    :=l_wo_op.attribute8;
          l_eam_op_rec.attribute9                    :=l_wo_op.attribute9;
          l_eam_op_rec.attribute10                   :=l_wo_op.attribute10;
          l_eam_op_rec.attribute11                   :=l_wo_op.attribute11;
          l_eam_op_rec.attribute12                   :=l_wo_op.attribute12;
          l_eam_op_rec.attribute13                   :=l_wo_op.attribute13;
          l_eam_op_rec.attribute14                   :=l_wo_op.attribute14;
          l_eam_op_rec.attribute15                   :=l_wo_op.attribute15;
          l_eam_op_rec.long_description              :=l_wo_op.long_description;
          l_eam_op_rec.request_id                    :=l_eam_wo_rec.request_id;
          l_eam_op_rec.program_application_id        :=l_eam_wo_rec.program_application_id;
          l_eam_op_rec.program_id                    :=l_eam_wo_rec.program_id;
          l_eam_op_rec.return_status                 :=l_wo_op.return_status;
          l_eam_op_rec.transaction_type              :=l_wo_op.transaction_type;

          l_eam_op_tbl(l_operation_index) := l_eam_op_rec;
          l_operation_index := l_operation_index + 1;

    END LOOP;

	l_material_index := 1;

	FOR l_wo_mat IN import_wo_material_cur (l_group_id,l_eam_wo_rec.wip_entity_id)
    LOOP
	  l_eam_mat_req_rec.header_id                 :=l_wo_mat.header_id;
	  l_eam_mat_req_rec.batch_id		      :=l_wo_mat.group_id;
	  l_eam_mat_req_rec.row_id		      :=l_wo_mat.row_id;
	  l_eam_mat_req_rec.wip_entity_id	      :=l_wo_mat.wip_entity_id;
	  l_eam_mat_req_rec.organization_id	      :=l_wo_mat.organization_id;
	  l_eam_mat_req_rec.operation_seq_num	      :=l_wo_mat.operation_seq_num;
	  l_eam_mat_req_rec.inventory_item_id	      :=l_wo_mat.inventory_item_id;
	  l_eam_mat_req_rec.quantity_per_assembly     :=l_wo_mat.quantity_per_assembly;
	  l_eam_mat_req_rec.department_id             :=l_wo_mat.department_id;
	  l_eam_mat_req_rec.wip_supply_type           :=l_wo_mat.wip_supply_type;
	  l_eam_mat_req_rec.date_required             :=l_wo_mat.date_required;
	  l_eam_mat_req_rec.required_quantity         :=l_wo_mat.required_quantity;
	  l_eam_mat_req_rec.requested_quantity        :=l_wo_mat.requested_quantity;
	  l_eam_mat_req_rec.released_quantity         :=l_wo_mat.released_quantity;
	  l_eam_mat_req_rec.quantity_issued           :=l_wo_mat.quantity_issued;
	  l_eam_mat_req_rec.supply_subinventory       :=l_wo_mat.supply_subinventory;
	  l_eam_mat_req_rec.supply_locator_id         :=l_wo_mat.supply_locator_id;
	  l_eam_mat_req_rec.mrp_net_flag              :=l_wo_mat.mrp_net_flag;
	  l_eam_mat_req_rec.mps_required_quantity     :=l_wo_mat.mps_required_quantity;
	  l_eam_mat_req_rec.mps_date_required         :=l_wo_mat.mps_date_required;
	  l_eam_mat_req_rec.component_sequence_id     :=l_wo_mat.component_sequence_id;
	  l_eam_mat_req_rec.comments                  :=l_wo_mat.comments;
	  l_eam_mat_req_rec.attribute_category        :=l_wo_mat.attribute_category;
	  l_eam_mat_req_rec.attribute1                :=l_wo_mat.attribute1;
	  l_eam_mat_req_rec.attribute2                :=l_wo_mat.attribute2;
	  l_eam_mat_req_rec.attribute3                :=l_wo_mat.attribute3;
	  l_eam_mat_req_rec.attribute4                :=l_wo_mat.attribute4;
	  l_eam_mat_req_rec.attribute5                :=l_wo_mat.attribute5;
	  l_eam_mat_req_rec.attribute6                :=l_wo_mat.attribute6;
	  l_eam_mat_req_rec.attribute7                :=l_wo_mat.attribute7;
	  l_eam_mat_req_rec.attribute8                :=l_wo_mat.attribute8;
	  l_eam_mat_req_rec.attribute9                :=l_wo_mat.attribute9;
	  l_eam_mat_req_rec.attribute10               :=l_wo_mat.attribute10;
	  l_eam_mat_req_rec.attribute11               :=l_wo_mat.attribute11;
	  l_eam_mat_req_rec.attribute12               :=l_wo_mat.attribute12;
	  l_eam_mat_req_rec.attribute13               :=l_wo_mat.attribute13;
	  l_eam_mat_req_rec.attribute14               :=l_wo_mat.attribute14;
	  l_eam_mat_req_rec.attribute15               :=l_wo_mat.attribute15;
	  l_eam_mat_req_rec.auto_request_material     :=l_wo_mat.auto_request_material;
	  l_eam_mat_req_rec.suggested_vendor_name     :=l_wo_mat.suggested_vendor_name;
	  l_eam_mat_req_rec.vendor_id                 :=l_wo_mat.vendor_id;
	  l_eam_mat_req_rec.unit_price                :=l_wo_mat.unit_price;
	  l_eam_mat_req_rec.request_id                :=l_eam_wo_rec.request_id;
	  l_eam_mat_req_rec.program_application_id    :=l_eam_wo_rec.program_application_id;
	  l_eam_mat_req_rec.program_id                :=l_eam_wo_rec.program_id;
	  l_eam_mat_req_rec.return_status             :=l_wo_mat.return_status;
	  l_eam_mat_req_rec.transaction_type          :=l_wo_mat.transaction_type;

	  l_eam_mat_req_tbl(l_material_index) := l_eam_mat_req_rec;
 	  l_material_index := l_material_index + 1;
    END LOOP;

	l_resource_index :=1;
	FOR l_wo_res IN import_wo_resource_cur (l_group_id,l_eam_wo_rec.wip_entity_id)
    LOOP
	  l_eam_res_rec.header_id		      :=l_wo_res.header_id;
	  l_eam_res_rec.batch_id                      :=l_wo_res.group_id;
	  l_eam_res_rec.row_id                        :=l_wo_res.row_id;
	  l_eam_res_rec.wip_entity_id                 :=l_wo_res.wip_entity_id;
	  l_eam_res_rec.organization_id               :=l_wo_res.organization_id;
	  l_eam_res_rec.operation_seq_num             :=l_wo_res.operation_seq_num;
	  l_eam_res_rec.resource_seq_num              :=l_wo_res.resource_seq_num;
	  l_eam_res_rec.resource_id                   :=l_wo_res.resource_id;
	  l_eam_res_rec.uom_code                      :=l_wo_res.uom_code;
	  l_eam_res_rec.basis_type                    :=l_wo_res.basis_type;
	  l_eam_res_rec.usage_rate_or_amount          :=l_wo_res.usage_rate_or_amount;
	  l_eam_res_rec.activity_id                   :=l_wo_res.activity_id;
	  l_eam_res_rec.scheduled_flag                :=l_wo_res.scheduled_flag;
  	  l_eam_res_rec.firm_flag		      :=l_wo_res.firm_flag;
	  l_eam_res_rec.assigned_units                :=l_wo_res.assigned_units;
 	  l_eam_res_rec.maximum_assigned_units        :=l_wo_res.max_assigned_units;
	  l_eam_res_rec.autocharge_type               :=l_wo_res.autocharge_type;
	  l_eam_res_rec.standard_rate_flag            :=l_wo_res.standard_rate_flag;
	  l_eam_res_rec.applied_resource_units        :=l_wo_res.applied_resource_units;
	  l_eam_res_rec.applied_resource_value        :=l_wo_res.applied_resource_value;
	  l_eam_res_rec.start_date                    :=l_wo_res.start_date;
	  l_eam_res_rec.completion_date               :=l_wo_res.completion_date;
	  l_eam_res_rec.schedule_seq_num              :=l_wo_res.schedule_seq_num;
	  l_eam_res_rec.substitute_group_num          :=l_wo_res.substitute_group_num;
	  l_eam_res_rec.replacement_group_num         :=l_wo_res.replacement_group_num;
	  l_eam_res_rec.attribute_category            :=l_wo_res.attribute_category;
	  l_eam_res_rec.attribute1                    :=l_wo_res.attribute1;
	  l_eam_res_rec.attribute2                    :=l_wo_res.attribute2;
	  l_eam_res_rec.attribute3                    :=l_wo_res.attribute3;
	  l_eam_res_rec.attribute4                    :=l_wo_res.attribute4;
	  l_eam_res_rec.attribute5                    :=l_wo_res.attribute5;
	  l_eam_res_rec.attribute6                    :=l_wo_res.attribute6;
	  l_eam_res_rec.attribute7                    :=l_wo_res.attribute7;
	  l_eam_res_rec.attribute8                    :=l_wo_res.attribute8;
	  l_eam_res_rec.attribute9                    :=l_wo_res.attribute9;
	  l_eam_res_rec.attribute10                   :=l_wo_res.attribute10;
	  l_eam_res_rec.attribute11                   :=l_wo_res.attribute11;
	  l_eam_res_rec.attribute12                   :=l_wo_res.attribute12;
	  l_eam_res_rec.attribute13                   :=l_wo_res.attribute13;
	  l_eam_res_rec.attribute14                   :=l_wo_res.attribute14;
	  l_eam_res_rec.attribute15                   :=l_wo_res.attribute15;
	  l_eam_res_rec.department_id                 :=l_wo_res.department_id;
	  l_eam_res_rec.request_id                    :=l_eam_wo_rec.request_id;
	  l_eam_res_rec.program_application_id        :=l_eam_wo_rec.program_application_id;
	  l_eam_res_rec.program_id                    :=l_eam_wo_rec.program_id;
	  l_eam_res_rec.return_status                 :=l_wo_res.return_status;
	  l_eam_res_rec.transaction_type              :=l_wo_res.transaction_type;

	  l_eam_res_tbl(l_resource_index) := l_eam_res_rec;
 	  l_resource_index := l_resource_index + 1;
    END LOOP;

	l_resource_usage_index :=1;
	FOR l_wo_res_usage IN import_wo_resource_usage_cur (l_group_id,l_eam_wo_rec.wip_entity_id)
    LOOP
	  l_eam_res_usage_rec.header_id		      :=l_wo_res_usage.header_id;
	  l_eam_res_usage_rec.batch_id                :=l_wo_res_usage.group_id;
	  l_eam_res_usage_rec.row_id                  :=l_wo_res_usage.row_id;
	  l_eam_res_usage_rec.wip_entity_id           :=l_wo_res_usage.wip_entity_id;
	  l_eam_res_usage_rec.operation_seq_num       :=l_wo_res_usage.operation_seq_num;
	  l_eam_res_usage_rec.resource_seq_num        :=l_wo_res_usage.resource_seq_num;
	  l_eam_res_usage_rec.organization_id         :=l_wo_res_usage.organization_id;
	  l_eam_res_usage_rec.start_date              :=l_wo_res_usage.start_date;
	  l_eam_res_usage_rec.completion_date         :=l_wo_res_usage.completion_date;
	  l_eam_res_usage_rec.assigned_units          :=l_wo_res_usage.assigned_units;
	  l_eam_res_usage_rec.request_id              :=l_eam_wo_rec.request_id;
	  l_eam_res_usage_rec.program_application_id  :=l_eam_wo_rec.program_application_id;
	  l_eam_res_usage_rec.program_id              :=l_eam_wo_rec.program_id;
	  l_eam_res_usage_rec.instance_id             :=l_wo_res_usage.instance_id;
	  l_eam_res_usage_rec.serial_number           :=l_wo_res_usage.serial_number;
	  l_eam_res_usage_rec.return_status           :=l_wo_res_usage.return_status;
	  l_eam_res_usage_rec.transaction_type        :=l_wo_res_usage.transaction_type;

	  l_eam_res_usage_tbl(l_resource_usage_index) := l_eam_res_usage_rec;
 	  l_resource_usage_index := l_resource_usage_index + 1;
    END LOOP;


	l_resource_instance_index :=1;
	FOR l_wo_res_instance IN import_wo_res_instance_cur (l_group_id,l_eam_wo_rec.wip_entity_id)
    LOOP
	  l_eam_res_inst_rec.header_id		      :=l_wo_res_instance.header_id;
	  l_eam_res_inst_rec.batch_id                 :=l_wo_res_instance.group_id;
 	  l_eam_res_inst_rec.row_id		      :=l_wo_res_instance.row_id;
 	  l_eam_res_inst_rec.wip_entity_id	      :=l_wo_res_instance.wip_entity_id;
 	  l_eam_res_inst_rec.organization_id	      :=l_wo_res_instance.organization_id;
 	  l_eam_res_inst_rec.operation_seq_num	      :=l_wo_res_instance.operation_seq_num;
 	  l_eam_res_inst_rec.resource_seq_num	      :=l_wo_res_instance.resource_seq_num;
 	  l_eam_res_inst_rec.instance_id	      :=l_wo_res_instance.instance_id;
 	  l_eam_res_inst_rec.serial_number	      :=l_wo_res_instance.serial_number;
 	  l_eam_res_inst_rec.start_date		      :=l_wo_res_instance.start_date;
 	  l_eam_res_inst_rec.completion_date	      :=l_wo_res_instance.completion_date;
 	  l_eam_res_inst_rec.top_level_batch_id	      :=l_wo_res_instance.top_level_batch_id;
 	  l_eam_res_inst_rec.return_status	      :=l_wo_res_instance.return_status;
 	  l_eam_res_inst_rec.transaction_type	      :=l_wo_res_instance.transaction_type;

	  l_eam_res_inst_tbl(l_resource_instance_index) := l_eam_res_inst_rec;
 	  l_resource_instance_index := l_resource_instance_index + 1;
    END LOOP;

	EAM_PROCESS_WO_PUB.Process_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
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
	 , p_eam_request_tbl         => l_eam_request_tbl
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
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => 'N'
         , p_debug_filename          => 'EAMVDSIB.log'
	 , p_debug_file_mode	     => 'W'
         , p_output_dir              => l_output_dir
         );

	IF(l_return_status <> 'S') THEN

		-- set the error logic code
		 ROLLBACK TO EAM_WORK_ORDER_START;

		-- Call procedure for logging and setting the appropriate error messages
		log_error_messages(l_return_status,l_group_id,l_import_wo_record,l_out_eam_op_tbl,l_out_eam_res_tbl,l_out_eam_res_inst_tbl,l_out_eam_res_usage_tbl,l_out_eam_mat_req_tbl);

		IF l_standalone = FALSE THEN
			l_relationship_errors := TRUE;
		END IF;

	ELSE  -- Work Order API Returned Suceess

		IF (l_return_status = 'S' AND l_standalone = TRUE) THEN
			-- For stand alone workorders if work order API returns sucess then
			-- Purge all the data from import table and all associated child tables

			fnd_file.put_line(FND_FILE.LOG,'Status Sucess for work order --' || l_import_wo_record.wip_entity_id);

                        DELETE
                          FROM EAM_RESOURCE_INSTANCE_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;

                        DELETE
                          FROM EAM_RESOURCE_USAGE_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;

                        DELETE
                          FROM EAM_RESOURCE_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;

                        DELETE
                          FROM EAM_MATERIAL_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;

                        DELETE
                          FROM EAM_OPERATION_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;

                        DELETE
                          FROM EAM_WORK_ORDER_IMPORT
                         WHERE group_id = l_group_id
                           AND wip_entity_id = l_import_wo_record.wip_entity_id;


			COMMIT;
		END IF;

	END IF; -- End if of error check

	EXCEPTION WHEN OTHERS THEN
		l_error_message := 'UNEXPECTED ERROR IN OUTER BLOCK: ' || SQLERRM;
		fnd_file.put_line(FND_FILE.LOG,'Status Error.Unexpected error occured while processing work order ' || l_error_message);
	END;

    END LOOP;

     CLOSE l_import_wo;
     	-- setting completion text for concurrent program
	l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);

	fnd_file.put_line(FND_FILE.LOG,'------------END OF WORK ORDER IMPORT CONCURRENT PROGRAM-----------');

  END import_workorder;
END EAM_WO_IMPORT_DS_PVT;

/
