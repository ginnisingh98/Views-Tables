--------------------------------------------------------
--  DDL for Package EAM_ASSET_OPERATION_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_OPERATION_TXN_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPACHS.pls 120.2 2005/08/03 05:56:33 ksiddhar noship $ */
/*
--      API name        : EAM_ASSET_OPERATION_TXN_PUB
--      Type            : Public
--      Pre-reqs        : None.
*/



G_PKG_NAME         CONSTANT VARCHAR2(30):='EAM_ASSET_OPERATION_TXN_PUB';

TYPE eam_quality_rec_type is RECORD
(
       batch_id				number,
       row_id				number,
       instance_id			number,
       organization_id			number,
       plan_id				number,
       spec_id				number,
       p_enable_flag			number,
       element_id			number,
       element_value			varchar2(2000),
       element_validation_flag		varchar2(100),
       transaction_number		number,
       collection_id			number,
       occurrence			number,
       return_status			varchar2(1),
       transaction_type			number
);


TYPE eam_quality_tbl_type IS TABLE OF eam_quality_rec_type
	INDEX BY BINARY_INTEGER;

TYPE Ctr_Property_Readings_Rec IS RECORD
(
	counter_id		number :=null,
	counter_property_id     number,
	property_value          varchar2(240),
	value_timestamp         date,
	attribute_category      varchar2(30),
	attribute1              varchar2(150),
	attribute2              varchar2(150),
	attribute3              varchar2(150),
	attribute4              varchar2(150),
	attribute5              varchar2(150),
	attribute6              varchar2(150),
	attribute7              varchar2(150),
	attribute8              varchar2(150),
	attribute9              varchar2(150),
	attribute10             varchar2(150),
	attribute11             varchar2(150),
	attribute12             varchar2(150),
	attribute13             varchar2(150),
	attribute14             varchar2(150),
	attribute15             varchar2(150),
	migrated_flag           VARCHAR2(1)
);

TYPE Ctr_Property_readings_Tbl IS TABLE OF Ctr_Property_Readings_Rec
          INDEX BY BINARY_INTEGER;

TYPE meter_reading_rec_type is RECORD
(
       meter_id				number	:=null,
       meter_reading_id			number,
       current_reading			number,
       current_reading_date		date,
       reset_flag			varchar2(1),
       description			varchar2(100),
       wip_entity_id			number,
       check_in_out_type		number,
       instance_id			number,
       source_line_id			number,
       source_code			varchar2(30),
       wo_entry_fake_flag		varchar2(1),
       adjustment_type			varchar2(30),
       adjustment_reading		number,
       net_reading			number,
       reset_reason                     varchar2(255),
       attribute_category		varchar2(30),
       attribute1			varchar2(150),
       attribute2			varchar2(150),
       attribute3			varchar2(150),
       attribute4			varchar2(150),
       attribute5			varchar2(150),
       attribute6			varchar2(150),
       attribute7			varchar2(150),
       attribute8			varchar2(150),
       attribute9			varchar2(150),
       attribute10			varchar2(150),
       attribute11			varchar2(150),
       attribute12			varchar2(150),
       attribute13			varchar2(150),
       attribute14			varchar2(150),
       attribute15			varchar2(150),
       attribute16			varchar2(150),
       attribute17			varchar2(150),
       attribute18			varchar2(150),
       attribute19			varchar2(150),
       attribute20			varchar2(150),
       attribute21			varchar2(150),
       attribute22			varchar2(150),
       attribute23			varchar2(150),
       attribute24			varchar2(150),
       attribute25			varchar2(150),
       attribute26			varchar2(150),
       attribute27			varchar2(150),
       attribute28			varchar2(150),
       attribute29			varchar2(150),
       attribute30			varchar2(150),
       value_before_reset		number,
       p_ignore_warnings		varchar2(1)


 );


TYPE meter_reading_rec_tbl_type IS TABLE OF EAM_ASSET_OPERATION_TXN_PUB.meter_reading_rec_type
	INDEX BY BINARY_INTEGER;








/*
This procedure is used to insert records in to EAM_ASSET_OPERATION_TXN table.
--      Parameters      :
--      IN              :
--			P_API_VERSION  Version of the API
--		        P_INIT_MSG_LIST Flag to indicate initialization of message list
--			P_COMMIT Flag to indicate whether API should commit changes
--		        P_VALIDATION_LEVEL Validation Level of the API
--                      P_TXN_DATE indicates transaction date of the Checkin/Checkout Transaction
--			P_TXN_TYPE indicates the Type of the Transaction(Checkin or Checkout)
--			P_INSTANCE_ID Asset id identifier of the asset or rebuildable.
--		        P_COMMENTS To log additional information / Remarks about the transaction.
--			P_QA_COLLECTION_ID quality collection plan identifier to identify collection results entered for current transaction.
--			P_OPERABLE_FLAG Status of the Asset or Rebuildable at the time Of Transaction.
--			P_EMPLOYEE_ID Employee Identifier for whom the transaction has been carried.
--			P_EAM_OPS_QUALITY_TBL Quality Plan record table capturing the quality collection plan results entered for current transaction.
--			P_METER_READING_REC_TBL Meter Reading record table capturing the meter readings entered for current transaction.
--			P_COUNTER_PROPERTIES_TBL Counter/Meter Properties table capturing the counter/meter properties of meters for current transaction.
--      OUT             :
--		        X_RETURN_STATUS Return status of the procedure call
--                      X_MSG_COUNT Count of the return messages that API returns
--                      X_MSG_DATA The collection of the messages
 */

PROCEDURE process_checkinout_txn
(
        p_api_version			IN		number		:=1.0,
        p_init_msg_list			IN		varchar2	:=fnd_api.g_false,
        p_commit			IN		varchar2	:=fnd_api.g_false,
        p_validation_level		IN		number		:=fnd_api.g_valid_level_full,
        p_txn_date			IN		date		:=sysdate,
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




PROCEDURE PRINT_LOG(info varchar2);


END EAM_ASSET_OPERATION_TXN_PUB;

 

/
