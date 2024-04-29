--------------------------------------------------------
--  DDL for Package Body CS_COST_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COST_DETAILS_PUB" AS
/* $Header: csxpcstb.pls 120.1 2008/01/18 07:02:28 bkanimoz noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):='CS_Cost_Details_PUB' ;


/**************************************************
Public Procedure Body Create_Cost_Details
**************************************************/

PROCEDURE Create_cost_details
	(
	p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
	p_commit IN VARCHAR2              := FND_API.G_FALSE,
	p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_object_version_number OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	x_cost_id OUT NOCOPY NUMBER,
	p_resp_appl_id IN NUMBER          := FND_GLOBAL.RESP_APPL_ID,
	p_resp_id IN NUMBER               := FND_GLOBAL.RESP_ID,
	p_user_id IN NUMBER               := FND_GLOBAL.USER_ID,
	p_login_id IN NUMBER              := NULL,
	p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
	p_Cost_Rec IN Cost_Rec_Type       :=G_MISS_COST_REC

	) IS


	l_api_name CONSTANT VARCHAR2(30)      :='Create_Cost_Details`' ;
	l_api_name_full CONSTANT VARCHAR2(61) := G_PKG_NAME ||'.'|| l_api_name ;
	l_log_module    CONSTANT VARCHAR2(255):='csxpcstb.pls.'|| l_api_name_full ||'.';
	l_api_version   CONSTANT NUMBER       :=1.0 ;
	l_resp_appl_id  NUMBER                := p_resp_appl_id;
	l_resp_id       NUMBER                := p_resp_id;
	l_user_id       NUMBER                := p_user_id;
	l_login_id      NUMBER                := p_login_id;
	l_return_status VARCHAR2(1) ;
	l_Cost_Rec      Cost_Rec_Type ;


BEGIN

	--  Standard Start of API Savepoint

	IF FND_API.To_Boolean(p_transaction_control) THEN
	SAVEPOINT Create_Cost_Details_PUB ;
	END IF ;

	-- Standard Call to check API compatibility
	IF NOT FND_API.Compatible_API_Call( l_api_version,
										p_api_version,
										l_api_name,
										G_PKG_NAME) THEN

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF ;

	-- Initialize the message list  if p_msg_list is set to TRUE

	IF FND_API.To_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize ;
	END IF ;

	-- Initialize the API Return Success to True
	x_return_status := FND_API.G_RET_STS_SUCCESS ;



	----------------------- FND Logging -----------------------------------
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'start',
	'Inside '|| L_API_NAME_FULL ||', called with parameters below:'
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_api_version:'|| p_api_version
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_init_msg_list:'|| p_init_msg_list
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_commit:'|| p_commit
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_validation_level:'|| p_validation_level
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_resp_appl_id:'|| p_resp_appl_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_resp_id:'|| p_resp_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_user_id:'|| p_user_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_login_id:'|| p_login_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_transaction_control:'|| p_transaction_control
	);

	-- --------------------------------------------------------------------------
	-- This procedure Logs the Cost record paramters.
	-- --------------------------------------------------------------------------
	Log_Cost_Rec_Parameters
	( p_cost_rec_in => p_cost_rec);


	END IF;

	--Convert the IN Parameters from FND_API.G_MISS_XXXX to NULL
	--if no calue is passed then return NULL otherwise return the value passed

	-- TO_NULL (p_cost_Rec, l_cost_Rec) ;  --do this in the cost pvt api



	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE,
	'Before calling the Costing Private API'
	);
	END IF;

	--call to the costing private api
	CS_COST_DETAILS_PVT.CREATE_COST_DETAILS
	(
	p_api_version            =>1.0,
	p_init_msg_list          => p_init_msg_list ,
	p_commit                 => p_commit ,
	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
	x_return_status          => l_return_status,
	x_msg_count              => x_msg_count,
	x_object_version_number  => x_object_version_number,
	x_msg_data               => x_msg_data,
	x_cost_id                => x_cost_id,
	p_resp_appl_id           => l_resp_appl_id,
	p_resp_id                => l_resp_id,
	p_user_id                => l_user_id,
	p_login_id               => l_login_id,
	p_transaction_control    => p_transaction_control,
	p_Cost_Rec               => p_cost_rec ,
	p_cost_creation_override =>'N'
	);



	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After calling the costing Private API '||l_return_status
	);
	END IF;



	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--standard Check of p_commit bharahti
	IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK ;
	END IF ;

	--Standard call to get  message count and if count is 1 , get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;


	--Begin Exception Handling

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN


	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Create_Cost_Details_PUB;
	END IF ;

	x_return_status := FND_API.G_RET_STS_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Create_Cost_Details_PUB;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;
	WHEN OTHERS THEN


	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Create_Cost_Details_PUB ;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	END IF ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

END Create_cost_details;

/**************************************************
Public Procedure Body Update_Cost_Details
**************************************************/


PROCEDURE Update_Cost_Details
	(
	p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
	p_commit IN VARCHAR2              := FND_API.G_FALSE,
	p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_object_version_number OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	p_resp_appl_id IN NUMBER          := FND_GLOBAL.RESP_APPL_ID,
	p_resp_id IN NUMBER               := FND_GLOBAL.RESP_ID,
	p_user_id IN NUMBER               := FND_GLOBAL.USER_ID,
	p_login_id IN NUMBER              := NULL,
	p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
	p_Cost_Rec IN Cost_Rec_Type       :=G_MISS_COST_REC

	) IS

	l_api_name CONSTANT VARCHAR2(30)      :='Update_Cost_Details' ;
	l_api_name_full CONSTANT VARCHAR2(61) := G_PKG_NAME ||'.'|| l_api_name ;
	l_log_module    CONSTANT VARCHAR2(255):='csxpcstb.pls.'|| l_api_name_full ||'.';
	l_api_version   CONSTANT NUMBER       :=1.0 ;

	l_resp_appl_id  NUMBER ;
	l_resp_id       NUMBER ;
	l_user_id       NUMBER ;
	l_login_id      NUMBER ;
	l_return_status VARCHAR2(1) ;


	l_cost_estimate_detail_id NUMBER;
	l_cost_id                 NUMBER;



BEGIN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	SAVEPOINT update_cost_details_pub ;
	END IF ;

	--Standard Call to check API compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version,
									p_api_version,
									l_api_name,
									G_PKG_NAME )THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF ;

	--   Initialize the message list  if p_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize ;
	END IF ;


	--Initialize the API Return Success to True
	x_return_status := FND_API.G_RET_STS_SUCCESS ;


	----------------------- FND Logging -----------------------------------
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'start',
	'Inside '|| L_API_NAME_FULL ||', called with parameters below:'
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_api_version:'|| p_api_version
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_init_msg_list:'|| p_init_msg_list
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_commit:'|| p_commit
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_validation_level:'|| p_validation_level
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_resp_appl_id:'|| p_resp_appl_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_resp_id:'|| p_resp_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_user_id:'|| p_user_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_login_id:'|| p_login_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_transaction_control:'|| p_transaction_control
	);

	-- --------------------------------------------------------------------------
	-- This procedure Logs the charges record paramters.
	-- --------------------------------------------------------------------------
	Log_Cost_Rec_Parameters
	( p_cost_rec_in => p_Cost_rec
	);

	END IF;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'BEfore calling the costing Private API '||l_return_status
	);
	END IF;

	--call to the costing private api
	CS_COST_DETAILS_PVT.UPDATE_COST_DETAILS
	(
	p_api_version          =>1.0,
	p_init_msg_list        => p_init_msg_list,
	p_commit               => p_commit ,
	p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	x_return_status        => l_return_status,
	x_msg_count            => x_msg_count,
	x_object_version_number=> x_object_version_number,
	x_msg_data             => x_msg_data,
	p_resp_appl_id         => l_resp_appl_id,
	p_resp_id              => l_resp_id,
	p_user_id              => l_user_id,
	p_login_id             => l_login_id,
	p_transaction_control  => p_transaction_control,
	p_Cost_Rec             => p_cost_rec
	);


	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;



	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After calling the costing Private API '||l_return_status
	);
	END IF;


	--standard Check of p_commit
	IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK ;
	END IF ;

	--Standard call to get  message count and if count is 1 , get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'After calling the update_cost_details'||l_return_status
	);
	END IF;
	--Begin Exception Handling

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO update_cost_details_pub;
	END IF ;

	x_return_status := FND_API.G_RET_STS_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO update_cost_details_pub;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;
	WHEN OTHERS THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO update_cost_details_pub;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	END IF ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

END Update_Cost_Details;


/**************************************************
Public Procedure Body Delete_Cost_Details
**************************************************/
PROCEDURE Delete_Cost_details
	(
	p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
	p_commit IN VARCHAR2              := FND_API.G_FALSE,
	p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
	p_cost_id IN NUMBER               := NULL
	) IS

	l_api_name CONSTANT VARCHAR2(30)      :='Delete_Cost_Details Public API' ;
	l_api_name_full CONSTANT VARCHAR2(61) := G_PKG_NAME ||'.'|| l_api_name ;
	l_log_module    CONSTANT VARCHAR2(255):='csxpcstb.sql.'|| l_api_name_full ||'.';
	l_api_version   CONSTANT NUMBER       :=1.0 ;

	l_resp_appl_id  NUMBER ;
	l_resp_id       NUMBER ;
	l_user_id       NUMBER ;
	l_login_id      NUMBER ;
	l_return_status VARCHAR2(1) ;



BEGIN
	-- Standard Start of API Savepoint
	IF FND_API.To_Boolean( p_transaction_control ) THEN
	SAVEPOINT Delete_Cost_Details_PUB ;
	END IF ;

	-- Standard Call to check API compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version,
									p_api_version,
									l_api_name,
									G_PKG_NAME ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF ;

	-- Initialize the message list  if p_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize ;
	END IF ;


	-- Initialize the API Return Success to True
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	----------------------- FND Logging -----------------------------------
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'start',
	'Inside '|| L_API_NAME_FULL ||', called with parameters below:'
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_api_version:'|| p_api_version
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_init_msg_list:'|| p_init_msg_list
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_commit:'|| p_commit
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_validation_level:'|| p_validation_level
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_transaction_control:'|| p_transaction_control
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'p_cost_id'|| p_cost_id
	);


	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'Before  calling the costing Private API '||l_return_status
	);
	END IF;


	--call to the costing private api
	CS_COST_DETAILS_PVT.DELETE_COST_DETAILS
	(
	p_api_version         =>1.0,
	p_init_msg_list       => p_init_msg_list,
	p_commit              => p_commit,
	p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
	x_return_status       => l_return_status,
	x_msg_count           => x_msg_count,
	x_msg_data            => x_msg_data,
	p_transaction_control => p_transaction_control,
	p_cost_id             => p_cost_id
	);

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After calling the costing Private API '||l_return_status
	);
	END IF;

	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

	RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--standard Check of p_commit
	IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT ;
	END IF ;

	--Standard call to get  message count and if count is 1 , get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE ||'',
	'After calling the Delete_cost_details'||l_return_status
	);
	END IF;



	--Begin Exception Handling

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Delete_Cost_Details_PUB;
	END IF ;

	x_return_status := FND_API.G_RET_STS_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Delete_Cost_Details_PUB;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;
	WHEN OTHERS THEN

	IF FND_API.To_Boolean( p_transaction_control ) THEN
	ROLLBACK TO Delete_Cost_Details_PUB;
	END IF ;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	END IF ;

	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
							p_data    => x_msg_data,
							p_encoded => FND_API.G_FALSE) ;


END Delete_Cost_details;



/**************************************************
Procedure Body Log_Cost_Rec_Parameters
This Procedure is used for Logging the cost record paramters.
**************************************************/

PROCEDURE Log_Cost_Rec_Parameters
	(
	p_Cost_Rec_in IN cost_rec_type
	) IS
	l_api_name      CONSTANT VARCHAR2(30) :='Log_Cost_Rec_Parameters';
	l_api_name_full CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
	l_log_module    CONSTANT VARCHAR2(255):='csxpcstb.pls.'|| l_api_name_full ||'.';
BEGIN

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' cost_id                  	 :'|| p_cost_rec_in.estimate_detail_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' estimate_detail_id                  	 :'|| p_cost_rec_in.estimate_detail_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' incident_id                         	 :'|| p_cost_rec_in.incident_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' charge_line_type                    	 :'|| p_cost_rec_in.charge_line_type
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' txn_billing_type_id                 	 :'|| p_cost_rec_in.txn_billing_type_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' transaction_type_id                 	 :'|| p_cost_rec_in.transaction_type_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' inventory_item_id                	 :'|| p_cost_rec_in.inventory_item_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' unit_of_measure_code                       	 :'|| p_cost_rec_in.unit_of_measure_code
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' currency_code                        	 :'|| p_cost_rec_in.currency_code
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' source_id                         	 :'|| p_cost_rec_in.source_id
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' source_code                        	 :'|| p_cost_rec_in.source_code
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' source_id                         	 :'|| p_cost_rec_in.source_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' org_id                           	 :'|| p_cost_rec_in.org_id
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' inventory_org_id                         	 :'|| p_cost_rec_in.inventory_org_id
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' extended_cost                          	 :'|| p_cost_rec_in.extended_cost
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute1                         	 :'|| p_cost_rec_in.attribute1
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute2                         	 :'|| p_cost_rec_in.attribute2
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute3                         	 :'|| p_cost_rec_in.attribute3
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute4                         	 :'|| p_cost_rec_in.attribute4
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute5                         	 :'|| p_cost_rec_in.attribute5
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute6                         	 :'|| p_cost_rec_in.attribute6
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute7                         	 :'|| p_cost_rec_in.attribute7
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute8                         	 :'|| p_cost_rec_in.attribute8
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute9                         	 :'|| p_cost_rec_in.attribute9
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute10                         	 :'|| p_cost_rec_in.attribute10
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute11                        	 :'|| p_cost_rec_in.attribute11
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute12                         	 :'|| p_cost_rec_in.attribute12
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute13                         	 :'|| p_cost_rec_in.attribute13
	);

	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute14                        	 :'|| p_cost_rec_in.attribute14
	);
	FND_LOG.String
	( FND_LOG.level_procedure , l_log_module ||'',
	' attribute15                         	 :'|| p_cost_rec_in.attribute15
	);

	END IF;

END Log_Cost_Rec_Parameters;

END CS_Cost_Details_PUB;
--end of the package


/
