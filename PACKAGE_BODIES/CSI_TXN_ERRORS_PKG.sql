--------------------------------------------------------
--  DDL for Package Body CSI_TXN_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TXN_ERRORS_PKG" AS
/* $Header: csittxeb.pls 115.18 2003/11/14 19:58:43 epajaril ship $ */
-- start of comments
-- package name     : csi_txn_errors_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments


g_pkg_name CONSTANT VARCHAR2(30):= 'csi_txn_errors_pkg';
g_file_name CONSTANT VARCHAR2(12) := 'csittxeb.pls';

PROCEDURE insert_row(
          px_transaction_error_id   IN OUT NOCOPY  NUMBER  ,
          p_transaction_id                  NUMBER  ,
          p_message_id                      NUMBER  ,
          p_error_text                      VARCHAR2,
          p_source_type                     VARCHAR2,
          p_source_id                       NUMBER  ,
          p_processed_flag                  VARCHAR2,
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER  ,
          p_transaction_type_id             NUMBER  ,
          p_source_group_ref                VARCHAR2,
          p_source_group_ref_id             NUMBER  ,
          p_source_header_ref               VARCHAR2,
          p_source_header_ref_id            NUMBER  ,
          p_source_line_ref                 VARCHAR2,
          p_source_line_ref_id              NUMBER  ,
          p_source_dist_ref_id1             NUMBER  ,
          p_source_dist_ref_id2             NUMBER  ,
          p_inv_material_transaction_id     NUMBER  ,
	  p_error_stage			    VARCHAR2,
	  p_message_string		    VARCHAR2,
          p_instance_id                     NUMBER,
          p_inventory_item_id               NUMBER,
          p_serial_number                   VARCHAR2,
          p_lot_number                      VARCHAR2,
          p_transaction_error_date          DATE,
          p_src_serial_num_ctrl_code        NUMBER,
          p_src_location_ctrl_code          NUMBER,
          p_src_lot_ctrl_code               NUMBER,
          p_src_rev_qty_ctrl_code           NUMBER,
          p_dst_serial_num_ctrl_code        NUMBER,
          p_dst_location_ctrl_code          NUMBER,
          p_dst_lot_ctrl_code               NUMBER,
          p_dst_rev_qty_ctrl_code           NUMBER,
          p_comms_nl_trackable_flag         VARCHAR2)

 is
   CURSOR c2 IS SELECT csi_txn_errors_s.nextval FROM sys.dual;
   v_transaction_error_date  DATE;
BEGIN
   IF (px_transaction_error_id IS NULL) OR (px_transaction_error_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_transaction_error_id;
       CLOSE c2;
   END IF;

   IF ((p_transaction_error_date = FND_API.G_MISS_DATE) OR
       (p_transaction_error_date IS NULL))
   THEN
       v_transaction_error_date := SYSDATE;
   END IF;

   INSERT INTO csi_txn_errors(
           transaction_error_id,
           transaction_id,
           message_id,
           error_text,
           source_type,
           source_id,
           processed_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           transaction_type_id ,
           source_group_ref    ,
           source_group_ref_id ,
           source_header_ref ,
           source_header_ref_id  ,
           source_line_ref ,
           source_line_ref_id  ,
           source_dist_ref_id1 ,
           source_dist_ref_id2 ,
           inv_material_transaction_id,
	   error_stage,
           message_string,
           instance_id,
           inventory_item_id,
           serial_number,
           lot_number,
           transaction_error_date,
           src_serial_num_ctrl_code,
           src_location_ctrl_code,
           src_lot_ctrl_code,
           src_rev_qty_ctrl_code,
           dst_serial_num_ctrl_code,
           dst_location_ctrl_code,
           dst_lot_ctrl_code,
           dst_rev_qty_ctrl_code,
           comms_nl_trackable_flag)
   VALUES (px_transaction_error_id,
           decode( p_transaction_id, fnd_api.g_miss_num, NULL, p_transaction_id),
           decode( p_message_id, fnd_api.g_miss_num, NULL, p_message_id),
           decode( p_error_text, fnd_api.g_miss_char, NULL, p_error_text),
           decode( p_source_type, fnd_api.g_miss_char, NULL, p_source_type),
           decode( p_source_id, fnd_api.g_miss_num, NULL, p_source_id),
           decode( p_processed_flag, fnd_api.g_miss_char, NULL, p_processed_flag),
           decode( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
           decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
           decode( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
           decode( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           decode( p_object_version_number, fnd_api.g_miss_num, NULL, p_object_version_number),
           decode( p_transaction_type_id, fnd_api.g_miss_num , NULL, p_transaction_type_id),
           decode( p_source_group_ref, fnd_api.g_miss_char, NULL, p_source_group_ref),
           decode( p_source_group_ref_id, fnd_api.g_miss_num , NULL, p_source_group_ref_id),
           decode( p_source_header_ref, fnd_api.g_miss_char, NULL, p_source_header_ref),
           decode( p_source_header_ref_id, fnd_api.g_miss_num, NULL, p_source_header_ref_id),
           decode( p_source_line_ref, fnd_api.g_miss_char, NULL, p_source_line_ref),
           decode( p_source_line_ref_id, fnd_api.g_miss_num ,NULL, p_source_line_ref_id),
           decode( p_source_dist_ref_id1, fnd_api.g_miss_num ,NULL, p_source_dist_ref_id1),
           decode( p_source_dist_ref_id2, fnd_api.g_miss_num , NULL, p_source_dist_ref_id2),
           decode( p_inv_material_transaction_id, fnd_api.g_miss_num ,NULL,p_inv_material_transaction_id),
           decode( p_error_stage, fnd_api.g_miss_char ,NULL,p_error_stage),
           decode( p_message_string, fnd_api.g_miss_char ,NULL,p_message_string),
           decode( p_instance_id, fnd_api.g_miss_num , NULL, p_instance_id),
           decode( p_inventory_item_id, fnd_api.g_miss_num , NULL, p_inventory_item_id),
           decode( p_serial_number, fnd_api.g_miss_char ,NULL,p_serial_number),
           decode( p_lot_number, fnd_api.g_miss_char ,NULL,p_lot_number),
           decode( p_transaction_error_date,fnd_api.g_miss_date, v_transaction_error_date, p_transaction_error_date),
           decode( p_src_serial_num_ctrl_code, fnd_api.g_miss_num , NULL, p_src_serial_num_ctrl_code),
           decode( p_src_location_ctrl_code, fnd_api.g_miss_num , NULL, p_src_location_ctrl_code),
           decode( p_src_lot_ctrl_code, fnd_api.g_miss_num , NULL, p_src_lot_ctrl_code),
           decode( p_src_rev_qty_ctrl_code, fnd_api.g_miss_num , NULL, p_src_rev_qty_ctrl_code),
           decode( p_dst_serial_num_ctrl_code, fnd_api.g_miss_num , NULL, p_dst_serial_num_ctrl_code),
           decode( p_dst_location_ctrl_code, fnd_api.g_miss_num , NULL, p_dst_location_ctrl_code),
           decode( p_dst_lot_ctrl_code, fnd_api.g_miss_num , NULL, p_dst_lot_ctrl_code),
           decode( p_dst_rev_qty_ctrl_code, fnd_api.g_miss_num , NULL, p_dst_rev_qty_ctrl_code),
           decode( p_comms_nl_trackable_flag, fnd_api.g_miss_char ,NULL,p_comms_nl_trackable_flag)
 );

           -- commit;

END insert_row;


END csi_txn_errors_pkg;

/
