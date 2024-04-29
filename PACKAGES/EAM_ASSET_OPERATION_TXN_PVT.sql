--------------------------------------------------------
--  DDL for Package EAM_ASSET_OPERATION_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_OPERATION_TXN_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVACHS.pls 120.3 2005/08/03 05:59:58 ksiddhar noship $ */
/*
 * This package is used for the ASSET CHECKIN/CHECKOUT transaction logging AND validation .
 * It defines procedures which take quality collection plans and meter readings as input
 * during checkin/checkoutand perform the respective operations.
 *
 */



-- This function returns the employeeid  who checked-in the instance for the last transaction

FUNCTION get_created_by
		(
	p_instance_id		 IN	number
		)
	return number;


-- This procedure commits the transaction details into eam_asset_operation_txn

PROCEDURE insert_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_commit			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_comments			IN		varchar2	:= NULL,
	p_qa_collection_id		IN		number		:= NULL,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	p_eam_ops_quality_tbl		IN		eam_asset_operation_txn_pub.eam_quality_tbl_type,
        p_meter_reading_rec_tbl		IN		eam_asset_operation_txn_pub.meter_reading_rec_tbl_type,
        p_counter_properties_tbl	IN		eam_asset_operation_txn_pub.Ctr_Property_readings_Tbl,
	p_attribute_category		IN		varchar2	:= NULL,
	p_attribute1			IN		varchar2	:= NULL,
	p_attribute2			IN		varchar2	:= NULL,
	p_attribute3			IN		varchar2	:= NULL,
	p_attribute4			IN		varchar2	:= NULL,
	p_attribute5			IN		varchar2	:= NULL,
	p_attribute6			IN		varchar2	:= NULL,
	p_attribute7			IN		varchar2	:= NULL,
	p_attribute8			IN		varchar2	:= NULL,
	p_attribute9			IN		varchar2	:= NULL,
	p_attribute10			IN		varchar2	:= NULL,
	p_attribute11			IN		varchar2	:= NULL,
	p_attribute12			IN		varchar2	:= NULL,
	p_attribute13			IN		varchar2	:= NULL,
	p_attribute14			IN		varchar2	:= NULL,
	p_attribute15			IN		varchar2	:= NULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
);

-- This procedure validates the transaction details

PROCEDURE validate_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2

);


--This procedure accepts the transaction details from CheckIn/CheckOut UI

PROCEDURE process_checkinout_txn(

	p_api_version			IN		number		:= 1.0,
	p_init_msg_list			IN		varchar2	:= fnd_api.g_false,
	p_commit			IN		varchar2	:= fnd_api.g_false,
	p_validation_level		IN		number		:= fnd_api.g_valid_level_full,
	p_txn_date			IN		date		:= sysdate,
	p_txn_type			IN		number,
	p_instance_id			IN		number,
	p_comments			IN		varchar2	:= NULL,
	p_qa_collection_id		IN		number		:= NULL,
	p_operable_flag			IN		number,
	p_employee_id			IN		number,
	p_attribute_category		IN		varchar2	:= NULL,
	p_attribute1			IN		varchar2	:= NULL,
	p_attribute2			IN		varchar2	:= NULL,
	p_attribute3			IN		varchar2	:= NULL,
	p_attribute4			IN		varchar2	:= NULL,
	p_attribute5			IN		varchar2	:= NULL,
	p_attribute6			IN		varchar2	:= NULL,
	p_attribute7			IN		varchar2	:= NULL,
	p_attribute8			IN		varchar2	:= NULL,
	p_attribute9			IN		varchar2	:= NULL,
	p_attribute10			IN		varchar2	:= NULL,
	p_attribute11			IN		varchar2	:= NULL,
	p_attribute12			IN		varchar2	:= NULL,
	p_attribute13			IN		varchar2	:= NULL,
	p_attribute14			IN		varchar2	:= NULL,
	p_attribute15			IN		varchar2	:= NULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
);

-- This Procedure calls the quality api to insert quality plans

PROCEDURE insert_quality_plans
(

        p_eam_ops_quality_tbl		IN		eam_asset_operation_txn_pub.eam_quality_tbl_type,
	p_instance_id			IN		number,
	p_txn_date			IN		date,
	p_comments			IN		varchar2,
	p_operable_flag			IN		number,
	p_organization_id		IN		number,
	p_employee_id			IN		number,
	p_asset_group_id		IN		number,
        p_asset_number			IN		varchar2,
	p_asset_instance_number		IN		varchar2,
	p_txn_number			IN		number,
        x_return_status			OUT NOCOPY	varchar2,
        x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2
);


-- This Procedure calls the meter reading api to insert meter readings

PROCEDURE insert_meter_readings
(
        p_eam_meter_reading_tbl		IN		eam_asset_operation_txn_pub.meter_reading_rec_tbl_type,
        p_counter_properties_tbl	IN		eam_asset_operation_txn_pub.Ctr_Property_readings_Tbl,
	p_instance_id			IN		number,
	p_txn_id			IN		number,
        x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2

);



END EAM_ASSET_OPERATION_TXN_PVT;

 

/
