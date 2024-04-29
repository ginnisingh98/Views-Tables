--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_OPERATION_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_OPERATION_TXN_PUB" AS
/* $Header: EAMPACHB.pls 120.1 2005/07/04 09:53:43 ksiddhar noship $ */
/*
--Start of comments
--      API name        : EAM_ASSET_OPERATION_TXN_PUB
--      Type            : Public
--      Function        : Insert and validation of the checkin/checkout transaction data
--      Pre-reqs        : None.
*/

/* This procedure inserts a record in the eam_asset_operation_txn table after validation

--      Parameters      :
--      IN              :
--                              p_txn_date			date on which the transaction is being performed
--                              p_txn_type			transaction type which can either be checkin or checkout
--                              p_instance_id			Asset Number identification number
--                              p_comments			comments entered by the user during the transaction
--				p_qa_collection_id		quality collection id to identify the results entered during the transaction
--				p_operable_flag			operable status of the asset(1 or 2)
--                              p_employee_id			employee who actually is performing the transaction
--                              p_eam_ops_quality_tbl		plsql table of quality collection results entered during the transaction
--                              p_meter_reading_rec_tbl		plsql table of meter reading entries made during the transaction
--                              p_counter_properties_tbl	plsql table of counter properties entered during the transaction
--
--
--      out             :       x_return_status    return status
--                              x_msg_count        count of error messages
--                              x_msg_data         error message data
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
--
-- End of comments

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
    )
IS


	l_api_name                      constant	 varchar2(30)		:='EAM_ASSET_OPERATION_TXN_PUB';
	l_api_version                   constant	 number                 := 1.0;
	g_pkg_name			constant	varchar2(30)		:='EAM_ASSET_OPERATION_TXN_PUB';



BEGIN


/* Standard Start of API savepoint */

	SAVEPOINT EAM_ASSET_OPERATION_TXN_PUB;

/* Standard call to check for call compatibility. */
IF NOT
FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
)

THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/* Initialize message list if p_init_msg_list is set to TRUE. */
IF FND_API.to_Boolean( p_init_msg_list )
THEN
FND_MSG_PUB.initialize;
END IF;

/* Initialize API return status to success */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* API body */


--Call insert_txn of private api




EAM_ASSET_OPERATION_TXN_PVT.insert_txn(
				p_txn_date			=>	p_txn_date,
				p_txn_type			=>	p_txn_type,
				p_instance_id			=>	p_instance_id,
				p_comments			=>	p_comments,
				p_qa_collection_id		=>	p_qa_collection_id,
				p_operable_flag			=>	p_operable_flag,
				p_employee_id			=>	p_employee_id,
				p_eam_ops_quality_tbl		=>	p_eam_ops_quality_tbl,
				p_meter_reading_rec_tbl		=>	p_meter_reading_rec_tbl,
				p_counter_properties_tbl	=>	p_counter_properties_tbl,
				p_attribute_category		=>	p_attribute_category,
				p_attribute1			=>	p_attribute1,
				p_attribute2			=>	p_attribute2,
				p_attribute3			=>	p_attribute3,
				p_attribute4			=>	p_attribute4,
				p_attribute5			=>	p_attribute5,
				p_attribute6			=>	p_attribute6,
				p_attribute7			=>	p_attribute7,
				p_attribute8			=>	p_attribute8,
				p_attribute9			=>	p_attribute9,
				p_attribute10			=>	p_attribute10,
				p_attribute11			=>	p_attribute11,
				p_attribute12			=>	p_attribute12,
				p_attribute13			=>	p_attribute13,
				p_attribute14			=>	p_attribute14,
				p_attribute15			=>	p_attribute15,
				x_return_status			=>	x_return_status,
				x_msg_count			=>	x_msg_count,
				x_msg_data			=>	x_msg_data
				);


IF x_return_status <> fnd_api.g_ret_sts_success THEN
		ROLLBACK TO EAM_ASSET_OPERATION_TXN_PUB;
		RETURN;
		END IF;
/* Standard check of p_commit. */

IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.

FND_MSG_PUB.GET
(       p_msg_index_out         =>      x_msg_count ,
	p_data                  =>      x_msg_data
);

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO EAM_ASSET_OPERATION_TXN_PUB;
x_return_status := FND_API.G_RET_STS_ERROR ;

FND_MSG_PUB.Get
(       p_msg_index_out            =>      x_msg_count ,
        p_data                     =>      x_msg_data
);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO EAM_ASSET_OPERATION_TXN_PUB;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
FND_MSG_PUB.get
(          p_msg_index_out      =>      x_msg_count ,
	   p_data               =>      x_msg_data
);

WHEN OTHERS THEN
ROLLBACK TO EAM_ASSET_OPERATION_TXN_PUB;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level
(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
THEN
FND_MSG_PUB.Add_Exc_Msg
(
l_api_name,
g_pkg_name
);
END IF;

FND_MSG_PUB.get
(          p_msg_index_out      =>      x_msg_count ,
           p_data               =>      x_msg_data
);

END process_checkinout_txn;


PROCEDURE print_log(info varchar2) is

PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN
	/*
	if (g_sr_no is null or g_sr_no<0) then
	g_sr_no := 0;
	end if;

	g_sr_no := g_sr_no+1;

	INSERT into temp_isetup_api(msg,sr_no)
	VALUES (info,g_sr_no);

	commit;
	*/
	FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END print_log;

END EAM_ASSET_OPERATION_TXN_PUB;

/
