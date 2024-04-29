--------------------------------------------------------
--  DDL for Package GML_OPM_ROI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OPM_ROI_GRP" AUTHID CURRENT_USER AS
/* $Header: GMLGROIS.pls 115.5 2004/06/03 20:18:55 mchandak ship $*/

TYPE opm_record_type IS RECORD
 (receipt_source_code		rcv_transactions_interface.receipt_source_code%TYPE,
  to_organization_id		rcv_transactions_interface.to_organization_id%TYPE,
  item_num			rcv_transactions_interface.item_num%TYPE,
  item_id			rcv_transactions_interface.item_id%TYPE,
  unit_of_measure		rcv_transactions_interface.unit_of_measure%TYPE,
  secondary_unit_of_measure	rcv_transactions_interface.secondary_unit_of_measure%TYPE,
  secondary_uom_code		rcv_transactions_interface.secondary_uom_code%TYPE,
  quantity			rcv_transactions_interface.quantity%TYPE,
  secondary_quantity		rcv_transactions_interface.secondary_quantity%TYPE,
  qc_grade			rcv_transactions_interface.qc_grade%TYPE,
  transaction_type		rcv_transactions_interface.transaction_type%TYPE,
  destination_type_code		rcv_transactions_interface.destination_type_code%TYPE,
  locator_id			rcv_transactions_interface.locator_id%TYPE,
  header_interface_id		rcv_transactions_interface.header_interface_id%TYPE,
  group_id			rcv_transactions_interface.group_id%TYPE,
  primary_quantity		rcv_transactions_interface.primary_quantity%TYPE,
  from_locator_id		rcv_transactions_interface.from_locator_id%TYPE,
  rti_id			NUMBER,
  error_record			rcv_shipment_object_sv.ErrorRecType);


TYPE lot_attributes_rec_type IS RECORD
(item_no	 VARCHAR2(32),
 opm_item_id 	 NUMBER,
 lot_id		 NUMBER,
 lot_no  	 VARCHAR2(32),
 sublot_no  	 VARCHAR2(32),
 expiration_date DATE,
 reason_code	 VARCHAR2(4),
 new_lot	 VARCHAR2(1));

g_default_lot		VARCHAR2(32);
g_moved_diff_stat	NUMBER(2);


PROCEDURE validate_opm_parameters(x_opm_record	IN OUT NOCOPY gml_opm_roi_grp.opm_record_type);

PROCEDURE validate_opm_lot( p_api_version	 	IN  NUMBER,
			    p_init_msg_lst	 	IN  VARCHAR2 := FND_API.G_FALSE,
			    p_mtlt_rowid	 	IN  ROWID,
			    p_new_lot		 	IN  VARCHAR2,
			    p_opm_item_id	 	IN  NUMBER,
			    p_item_no		 	IN  VARCHAR2,
			    p_lots_specified_on_parent	IN  VARCHAR2,
			    p_lot_id			IN  NUMBER,
			    p_parent_txn_type	 	IN  VARCHAR2 DEFAULT NULL,
			    p_grand_parent_txn_type	IN  VARCHAR2 DEFAULT NULL,
			    x_return_status      	OUT NOCOPY VARCHAR2,
			    x_msg_data           	OUT NOCOPY VARCHAR2,
			    x_msg_count          	OUT NOCOPY NUMBER) ;

END GML_OPM_ROI_GRP;

 

/
