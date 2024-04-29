--------------------------------------------------------
--  DDL for Package EAM_OP_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OP_COMP" AUTHID CURRENT_USER AS
/* $Header: EAMOCMPS.pls 115.8 2004/04/05 10:58:25 cboppana ship $  */


PROCEDURE op_comp (
	x_err_code			OUT NOCOPY	NUMBER,
	x_err_msg			OUT NOCOPY	VARCHAR2,

	p_wip_entity_id 		IN 	NUMBER,
	p_operation_seq_num 		IN 	NUMBER,
	p_transaction_type 		IN 	NUMBER,
	p_transaction_date		IN	DATE,
	p_actual_start_date		IN	DATE,
	p_actual_end_date		IN	DATE,
	p_actual_duration		IN	NUMBER,
	p_shutdown_start_date		IN	DATE,
	p_shutdown_end_date		IN	DATE,
	p_reconciliation_code		IN	VARCHAR2,
	p_attribute_category		IN	VARCHAR2	:= NULL,
	p_attribute1			IN	VARCHAR2	:= NULL,
	p_attribute2			IN	VARCHAR2	:= NULL,
	p_attribute3			IN	VARCHAR2	:= NULL,
	p_attribute4			IN	VARCHAR2	:= NULL,
	p_attribute5			IN	VARCHAR2	:= NULL,
	p_attribute6			IN	VARCHAR2	:= NULL,
	p_attribute7			IN	VARCHAR2	:= NULL,
	p_attribute8			IN	VARCHAR2	:= NULL,
	p_attribute9			IN	VARCHAR2	:= NULL,
	p_attribute10			IN	VARCHAR2	:= NULL,
	p_attribute11			IN	VARCHAR2	:= NULL,
	p_attribute12			IN	VARCHAR2	:= NULL,
	p_attribute13			IN	VARCHAR2	:= NULL,
	p_attribute14			IN	VARCHAR2	:= NULL,
	p_attribute15			IN	VARCHAR2	:= NULL,
    p_qa_collection_id              IN      NUMBER DEFAULT NULL,
    p_vendor_id             IN  NUMBER      := NULL,
    p_vendor_site_id        IN  NUMBER      := NULL,
	p_vendor_contact_id     IN  NUMBER      := NULL,
	p_reason_id             IN  NUMBER      := NULL,
	p_reference             IN  VARCHAR2    := NULL
);

PROCEDURE get_op_defaults
      (p_wip_entity_id                IN   NUMBER,
       p_tx_type                      IN   NUMBER,
       p_operation_seq_num            IN   NUMBER,
       x_start_date                   out NOCOPY date,
       x_end_date                     out NOCOPY date,
       x_return_status                out NOCOPY varchar2,
       x_msg_data                      out NOCOPY varchar2
       );

END eam_op_comp;


 

/
