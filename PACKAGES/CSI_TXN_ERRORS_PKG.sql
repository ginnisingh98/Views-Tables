--------------------------------------------------------
--  DDL for Package CSI_TXN_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TXN_ERRORS_PKG" AUTHID CURRENT_USER AS
/* $Header: csittxes.pls 115.17 2003/09/05 00:04:43 sguthiva ship $ */
-- start of comments
-- package name     : csi_txn_errors_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments

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
	  p_message_string                  VARCHAR2,
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
          p_comms_nl_trackable_flag         VARCHAR2);
END csi_txn_errors_pkg;

 

/
