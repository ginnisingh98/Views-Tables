--------------------------------------------------------
--  DDL for Package WMS_WIP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WIP_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: WMSWIPIS.pls 120.0.12010000.1 2008/07/28 18:38:27 appldev ship $ */


/* Used to update move order line
 */

PROCEDURE Update_MO_Line
  (p_lpn_id 				  IN NUMBER,
   p_wms_process_flag 			  IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2,
   x_msg_count                            OUT   NOCOPY NUMBER,
   x_msg_data                             OUT   NOCOPY VARCHAR2);

/* Backflush API to copy WIP data to inventory tables
 */

PROCEDURE Backflush
  (p_header_id 				  IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2,
   x_msg_count                            OUT   NOCOPY NUMBER,
   x_msg_data                             OUT   NOCOPY VARCHAR2);

PROCEDURE Capture_serial_atts
  (p_ref_id		IN	NUMBER,
   p_temp_id		IN	NUMBER,
   p_last_update_date	IN	DATE,
   p_last_updated_by	IN	NUMBER,
   p_creation_date	IN	DATE,
   p_created_by		IN	NUMBER,
   p_fm_serial_number	IN	VARCHAR2,
   p_to_serial_number	IN	VARCHAR2,
   p_serial_temp_id	IN	NUMBER,
   p_serial_flag	IN	NUMBER);

PROCEDURE Capture_lot_atts
  (p_ref_id		IN	NUMBER,
   p_temp_id		IN	NUMBER,
   p_lot		IN	VARCHAR2);

PROCEDURE Update_serial
( p_header_id		            IN NUMBER,
  p_serial_number                      IN VARCHAR2,
  x_return_status                        OUT   NOCOPY VARCHAR2,
  x_msg_count                            OUT   NOCOPY NUMBER,
  x_msg_data                             OUT   NOCOPY VARCHAR2);

PROCEDURE Insert_lot
( p_header_id		            IN NUMBER,
  p_lot_number                      IN VARCHAR2,
  x_return_status                        OUT   NOCOPY VARCHAR2,
  x_msg_count                            OUT   NOCOPY NUMBER,
  x_msg_data                             OUT   NOCOPY VARCHAR2);

PROCEDURE Perform_lot_validations(
	p_item_id	IN NUMBER,
	p_org_id	IN NUMBER,
	p_lot_number	IN VARCHAR2,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT   NOCOPY NUMBER,
	x_msg_data	OUT   NOCOPY VARCHAR2);

PROCEDURE post_completion
  (p_item_id            IN  NUMBER,
   p_org_id             IN  NUMBER,
   p_fm_serial_number   IN  VARCHAR2,
   p_to_serial_number   IN  VARCHAR2,
   p_quantity           IN  NUMBER,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   );

PROCEDURE get_wip_job_info
  (p_temp_id            IN  NUMBER,
   p_wip_entity_type    IN  NUMBER,
   x_job                OUT NOCOPY VARCHAR2,
   x_line               OUT NOCOPY VARCHAR2,
   x_dept               OUT NOCOPY VARCHAR2,
   x_operation_seq_num  OUT NOCOPY NUMBER,
   x_start_date         OUT NOCOPY DATE,
   x_schedule           OUT NOCOPY VARCHAR2,
   x_assembly           OUT NOCOPY VARCHAR2,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   );

PROCEDURE get_wip_info_for_putaway
  (p_temp_id            IN  NUMBER,
   x_wip_entity_type    OUT  NOCOPY NUMBER,
   x_job                OUT NOCOPY VARCHAR2,
   x_line               OUT NOCOPY VARCHAR2,
   x_dept               OUT NOCOPY VARCHAR2,
   x_operation_seq_num  OUT NOCOPY NUMBER,
   x_start_date         OUT NOCOPY DATE,
   x_schedule           OUT NOCOPY VARCHAR2,
   x_assembly           OUT NOCOPY VARCHAR2,
   x_wip_entity_id      OUT  NOCOPY NUMBER,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   );

PROCEDURE unallocate_material
  (p_wip_entity_id          IN NUMBER,
   p_operation_seq_num      IN NUMBER,
   p_inventory_item_id      IN NUMBER,
   p_repetitive_schedule_id IN NUMBER := NULL,
   p_primary_quantity       IN NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_data              OUT  NOCOPY VARCHAR2
   );



PROCEDURE transfer_Reservation
  (
    P_HEADER_ID            IN NUMBER,
    P_SUBINVENTORY_CODE    IN VARCHAR2,
    P_LOCATOR_ID           IN NUMBER,
    X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY NUMBER,
    X_ERR_MSG              OUT NOCOPY VARCHAR2,
    p_temp_id              IN  NUMBER);

PROCEDURE mydebug(msg in varchar2);

PROCEDURE update_mmtt_for_wip
( p_transaction_temp_id     IN  NUMBER
, p_wip_entity_id           IN  NUMBER
, p_operation_seq_num       IN  NUMBER
, p_repetitive_schedule_id  IN  NUMBER  DEFAULT NULL
, p_transaction_type_id     IN  NUMBER
);

-- Bug 2747945 : Added business flow code to the call to the wip processor.
PROCEDURE wip_processor
  (p_txn_hdr_id     IN  NUMBER,
   p_business_flow_code IN  NUMBER DEFAULT NULL,
   x_return_status  OUT NOCOPY VARCHAR2);


END WMS_WIP_Integration;


/
