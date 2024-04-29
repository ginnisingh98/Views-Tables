--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_DETAILS_PUB" AS
/* $Header: csxpestb.pls 120.7.12010000.3 2010/04/14 08:03:21 rgandhi ship $ */


-- Global Variables
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Charge_Details_PUB' ;


--local Procedures and Functions

FUNCTION  Check_For_Miss ( p_param  IN  NUMBER ) RETURN NUMBER ;
FUNCTION  Check_For_Miss ( p_param  IN  VARCHAR2 ) RETURN VARCHAR2 ;
FUNCTION  Check_For_Miss ( p_param  IN  DATE ) RETURN DATE ;

PROCEDURE TO_NULL(p_charges_rec_in  IN         Charges_Rec_Type,
                  p_charges_rec_out OUT NOCOPY Charges_Rec_Type);


/**************************************************
Public Procedure Body Create_Charge_Details
**************************************************/

PROCEDURE Create_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2 := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_estimate_detail_id       OUT NOCOPY NUMBER,
        x_line_number              OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER   := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER   := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER   := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER   := NULL,
        p_transaction_control      IN         VARCHAR2 := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC
  ) IS

  x_cost_id           NUMBER;

BEGIN

   Create_Charge_Details(
        p_api_version              => p_api_version,
        p_init_msg_list            => p_init_msg_list,
        p_commit                   => p_commit,
        p_validation_level         => p_validation_level,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_object_version_number    => x_object_version_number,
        x_msg_data                 => x_msg_data,
        x_estimate_detail_id       => x_estimate_detail_id,
        x_line_number              => x_line_number,
        p_resp_appl_id             => p_resp_appl_id,
        p_resp_id                  => p_resp_id,
        p_user_id                  => p_user_id,
        p_login_id                 => p_login_id,
        p_transaction_control      => p_transaction_control,
        p_Charges_Rec              => p_Charges_Rec,
	p_create_cost_detail       => 'N',
	x_cost_id		   => x_cost_id
	);

END;


PROCEDURE Create_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2 := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_estimate_detail_id       OUT NOCOPY NUMBER,
        x_line_number              OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER   := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER   := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER   := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER   := NULL,
        p_transaction_control      IN         VARCHAR2 := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC,
	p_create_cost_detail       IN         VARCHAR2 ,--Costing
	x_cost_id		   OUT NOCOPY NUMBER    --Costing
  ) IS

  l_api_name       CONSTANT  VARCHAR2(30)    := 'Create_Charge_Details' ;
  l_api_name_full  CONSTANT  VARCHAR2(61)    := G_PKG_NAME || '.' || l_api_name ;
  l_log_module     CONSTANT VARCHAR2(255)    := 'csxpestb.plsql.' || l_api_name_full || '.';
  l_api_version    CONSTANT  NUMBER          := 1.0 ;
  l_resp_appl_id             NUMBER          := p_resp_appl_id;
  l_resp_id                  NUMBER          := p_resp_id;
  l_user_id                  NUMBER          := p_user_id;
  l_login_id                 NUMBER          := p_login_id;
  l_return_status            VARCHAR2(1) ;
  l_Charges_Rec              Charges_Rec_Type ;

  l_cost_rec                 cs_cost_details_pub.cost_rec_type;--Costing


BEGIN

  --  Standard Start of API Savepoint
  IF FND_API.To_Boolean( p_transaction_control ) THEN
    SAVEPOINT   Create_Charge_Details_PUB ;
  END IF ;

  -- Standard Call to check API compatibility
  IF NOT FND_API.Compatible_API_Call(   l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  -- Initialize the message list  if p_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)   THEN
    FND_MSG_PUB.initialize ;
  END IF ;

  -- Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );

   FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_create_cost_detail:' || p_create_cost_detail
    );
 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    Log_Charges_Rec_Parameters
    ( p_Charges_Rec             =>  p_Charges_Rec
    );

  END IF;

  --Convert the IN Parameters from FND_API.G_MISS_XXXX to NULL
  TO_NULL (p_Charges_Rec, l_Charges_Rec) ;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN

      FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
        'Before calling Create Charge Details PVT API:'||'l_return_status :'||l_return_status
       );
  END IF ;


BEGIN

  --Call the private API Create_Charge_Details
  CS_Charge_Details_PVT.Create_Charge_Details
          (
                p_api_version           =>  1.0 ,
                p_init_msg_list         =>  FND_API.G_FALSE ,
                p_commit                =>  p_commit ,
                p_validation_level      =>  p_validation_level,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  x_msg_count,
                x_object_version_number =>  x_object_version_number,
                x_estimate_detail_id    =>  x_estimate_detail_id,
                x_line_number           =>  x_line_number,
                x_msg_data              =>  x_msg_data,
                p_resp_appl_id          =>  l_resp_appl_id,
                p_resp_id               =>  l_resp_id,
                p_user_id               =>  l_user_id,
                p_login_id              =>  l_login_id,
                p_transaction_control   =>  p_transaction_control,
                p_est_detail_rec        =>  l_charges_rec
           ) ;


	  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	      RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  --End of API Body
	  --standard Check of p_commit
	  IF FND_API.To_Boolean( p_commit ) THEN
	    COMMIT WORK ;
	  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN

    FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
        'After calling Create Charge Details PVT API:'||'l_return_status :'||l_return_status
       );
  END IF ;


  --Begin Exception Handling

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
  WHEN OTHERS THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_Details_PUB ;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level
    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;


END;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
        'Before  calling Create Cost Details PVT API:'||'l_return_status :'||l_return_status||'x_estimate_detail_id : '||x_estimate_detail_id
       );
   END IF ;
--Added by bkanimoz on 15-dec-2007 for Service Costing
--start

--Create Cost record only if charge line has been successfully created.

BEGIN

IF l_return_status = FND_API.G_RET_STS_SUCCESS
and p_create_cost_detail ='Y'
and x_estimate_detail_id IS NOT NULL
THEN

	  IF FND_API.To_Boolean( p_transaction_control ) THEN
--iF there are any errors in the costing api then rollback will happen to this point
	    SAVEPOINT   Create_Charge_Cost_Details_PUB ;

	  END IF ;

       	  l_cost_rec.estimate_detail_id  := x_estimate_detail_id;
	  l_cost_rec.transaction_date    := sysdate;

--call the costing PVT api with NO Validation ,since the data has already been validated by the charge api


	CS_COST_DETAILS_PVT.CREATE_COST_DETAILS
		  (
			p_api_version           =>  1.0 ,
			p_init_msg_list         =>  p_init_msg_list,
			p_commit                =>  p_commit ,
			p_validation_level      =>  FND_API.G_VALID_LEVEL_NONE,
			x_return_status         =>  l_return_status,
			x_msg_count             =>  x_msg_count,
			x_object_version_number =>  x_object_version_number,
			x_msg_data              =>  x_msg_data,
			x_cost_id               =>  x_cost_id,
			p_resp_appl_id          =>  l_resp_appl_id,
			p_resp_id               =>  l_resp_id,
			p_user_id               =>  l_user_id,
			p_login_id              =>  l_login_id,
			p_transaction_control   =>  p_transaction_control,
			p_Cost_Rec              =>  l_cost_rec
	     );


			 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
			      RAISE FND_API.G_EXC_ERROR;
			  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			  END IF;

			  --End of API Body
			  --standard Check of p_commit
			  IF FND_API.To_Boolean( p_commit ) THEN
			    COMMIT WORK ;
			  END IF ;

			  --Standard call to get  message count and if count is 1 , get message info
			  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
						    p_data  => x_msg_data,
						    p_encoded => FND_API.G_FALSE) ;

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN

	 FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'After  calling Create Cost Details PVT API:'||'l_return_status :'||l_return_status
	    );
      END IF ;
END IF;


  --Begin Exception Handling for the cost section


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_cost_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_cost_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
  WHEN OTHERS THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Create_Charge_cost_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level
    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

END  ;


END  Create_Charge_Details;   -- End of Procedure Create Charge Details

--This is added for backward compatibility

PROCEDURE Update_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        p_resp_appl_id             IN         NUMBER           := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER           := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER           := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC

       ) AS
BEGIN

Update_Charge_Details
(
       p_api_version              => p_api_version,
       p_init_msg_list            => p_init_msg_list,
       p_commit                   => p_commit,
       p_validation_level         => p_validation_level,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_object_version_number    => x_object_version_number,
       x_msg_data                 => x_msg_data,
       p_resp_appl_id             => p_resp_appl_id,
       p_resp_id                  => p_resp_id,
       p_user_id                  => p_user_id,
       p_login_id                 => p_login_id,
       p_transaction_control      => p_transaction_control,
       p_Charges_Rec              => p_Charges_Rec,
       p_update_cost_detail       => 'N'
);

END;




/**************************************************
Public Procedure Body Update_Charge_Details
**************************************************/

 PROCEDURE Update_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
      --x_estimate_detail_id       OUT NOCOPY NUMBER,
      --x_line_number              OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER           := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER           := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER           := FND_GLOBAL.USER_ID,
      --p_login_id                 IN         NUMBER           := FND_API.G_MISS_NUM,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC,
	p_update_cost_detail       IN         VARCHAR2		--service costing

       ) AS

  l_api_name       CONSTANT  VARCHAR2(30) := 'Update_Charge_Details' ;
  l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
  l_log_module     CONSTANT VARCHAR2(255) := 'csxpestb.plsql.' || l_api_name_full || '.';
  l_api_version    CONSTANT  NUMBER       := 1.0 ;
  l_resp_appl_id             NUMBER       := p_resp_appl_id;
  l_resp_id                  NUMBER       := p_resp_id ;
  l_user_id                  NUMBER       := p_user_id ;
  l_login_id                 NUMBER       := p_login_id ;
  l_charges_rec              Charges_Rec_Type;
   l_cost_rec                 cs_cost_details_pub.cost_rec_type;--bkc
     -- l_cost_id			NUMBER;
  l_return_status            VARCHAR2(1) ;

BEGIN

  --  Standard Start of API Savepoint
  IF FND_API.To_Boolean( p_transaction_control ) THEN
    SAVEPOINT   Update_Charge_Details_PUB ;
  END IF ;

  --Standard Call to check API compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME    )THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --   Initialize the message list  if p_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)   THEN
    FND_MSG_PUB.initialize ;
  END IF ;


  --Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );

     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_update_cost_detail: ' || p_update_cost_detail
    );
 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    Log_Charges_Rec_Parameters
    ( p_Charges_Rec             =>  p_Charges_Rec
    );

  END IF;

  --Resolve Bug # 3078244

  --Convert the IN Parameters from FND_API.G_MISS_XXXX to NULL
  --TO_NULL (p_Charges_Rec, l_Charges_Rec) ;


 BEGIN
  -- Call the PVT API for the update
  CS_Charge_Details_PVT.Update_Charge_Details
             (
                p_api_version             =>  1.0 ,
                p_init_msg_list           =>  FND_API.G_FALSE ,
                p_commit                  =>  p_commit ,
                p_validation_level        =>  p_validation_level,
                x_return_status           =>  l_return_status               ,
                x_msg_count               =>  x_msg_count ,
                x_object_version_number   =>  x_object_version_number,
                x_msg_data                =>  x_msg_data ,
                p_resp_appl_id            =>  l_resp_appl_id ,
                p_resp_id                 =>  l_resp_id ,
                p_user_id                 =>  l_user_id ,
                p_login_id                =>  l_login_id ,
                p_transaction_control     =>  p_transaction_control ,
                p_EST_DETAIL_rec          =>  p_Charges_Rec
                ) ;

	  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  --End of API Body
	  --Standard Check of p_commit
	  IF FND_API.To_Boolean( p_commit ) THEN
	    COMMIT WORK ;
	  END IF ;

	  --Standard call to get  message count and if count is 1 , get message info
	  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
				    p_data => x_msg_data) ;

  --Begin Exception Handling

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Update_Charge_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                            p_data    => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Update_Charge_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
  WHEN OTHERS THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Update_Charge_Details_PUB;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level
    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
END ;

--added by bkanimoz on 15-dec-2007 for service costing
--start

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
         'Before call To cost Update Pvt API ' ||'l_return_status :'||l_return_status||'p_Charges_Rec.estimate_Detail_id :'||p_Charges_Rec.estimate_Detail_id
       );
  END IF ;


BEGIN
--Update Cost record only if charge line has been successfully updated

IF l_return_status =FND_API.G_RET_STS_SUCCESS
and p_update_cost_detail ='Y'
and p_Charges_Rec.estimate_Detail_id  IS NOT NULL then

	 --  Standard Start of API Savepoint
	  IF FND_API.To_Boolean( p_transaction_control ) THEN
	    SAVEPOINT   Update_Charge_Cost_Details_PUB ;
	  END IF ;



	 l_cost_rec.estimate_detail_id  :=p_Charges_Rec.estimate_Detail_id;
	-- l_cost_rec.source_code:='SR';

	l_cost_rec.estimate_detail_id := p_Charges_Rec.estimate_Detail_id;
	l_cost_rec.transaction_date   := sysdate;

--call the costing PVT api with NO Validation ,since the data has already been validated by the charge api

CS_COST_DETAILS_PVT.UPDATE_COST_DETAILS
             (
                p_api_version           =>  1.0 ,
                p_init_msg_list         =>  p_init_msg_list ,
                p_commit                =>  p_commit ,
                p_validation_level      =>  FND_API.G_VALID_LEVEL_NONE,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  x_msg_count,
                x_object_version_number =>  x_object_version_number,
                x_msg_data              =>  x_msg_data,
                p_resp_appl_id          =>  l_resp_appl_id,
                p_resp_id               =>  l_resp_id,
                p_user_id               =>  l_user_id,
                p_login_id              =>  l_login_id,
                p_transaction_control   =>  p_transaction_control,
                p_Cost_Rec              =>  l_cost_rec
         );


			 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
			      RAISE FND_API.G_EXC_ERROR;
			  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			  END IF;

			  --End of API Body
			  --standard Check of p_commit
			  IF FND_API.To_Boolean( p_commit ) THEN
			    COMMIT WORK ;
			  END IF ;

			  --Standard call to get  message count and if count is 1 , get message info
			  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
						    p_data  => x_msg_data,
						    p_encoded => FND_API.G_FALSE) ;
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
         'After call To cost Update Pvt API ' ||'l_return_status :'||l_return_status
       );
  END IF ;


END IF;

 EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	    IF FND_API.To_Boolean( p_transaction_control ) THEN
	      ROLLBACK TO  Update_Charge_Cost_Details_PUB;
	    END IF ;

	  x_return_status :=  FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
				    p_data    => x_msg_data,
				    p_encoded => FND_API.G_FALSE) ;


	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF FND_API.To_Boolean( p_transaction_control ) THEN
	      ROLLBACK TO  Update_Charge_Cost_Details_PUB;
	    END IF ;

	  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
				    p_data  => x_msg_data,
				    p_encoded => FND_API.G_FALSE) ;
	  WHEN OTHERS THEN
	    IF FND_API.To_Boolean( p_transaction_control ) THEN
	      ROLLBACK TO  Update_Charge_Cost_Details_PUB;
	    END IF ;

	  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

	  IF FND_MSG_PUB.Check_Msg_Level
	    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	  END IF ;

	  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
				    p_data  => x_msg_data,
				    p_encoded => FND_API.G_FALSE) ;




END;
--end;


END  Update_Charge_Details;   -- End of Procedure Update Charge Details


--This is added for backward compatibility

Procedure  Delete_Charge_Details
(
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
             p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
             p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 := FND_API.G_TRUE,
             p_estimate_detail_id   IN         NUMBER   := NULL
)
AS

BEGIN

 Delete_Charge_Details
 (

       p_api_version              => p_api_version,
       p_init_msg_list            => p_init_msg_list,
       p_commit                   => p_commit,
       p_validation_level         => p_validation_level,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       p_transaction_control      => p_transaction_control,
       p_estimate_detail_id 	  => p_estimate_detail_id,
       p_delete_cost_detail       => 'N'

);

END;

/**************************************************
Public Procedure Body Delete_Charge_Details
**************************************************/

Procedure  Delete_Charge_Details
(
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
             p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
             p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 := FND_API.G_TRUE,
             p_estimate_detail_id   IN         NUMBER   := NULL,
	     p_delete_cost_detail       IN         VARCHAR2--new parameter for service costing
)  AS

l_api_name       CONSTANT  VARCHAR2(30)     := 'Delete_Charge_Details' ;
l_api_name_full  CONSTANT  VARCHAR2(61)     := G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(255)     := 'csxpestb.plsql.' || l_api_name_full || '.';
l_api_version    CONSTANT  NUMBER           := 1.0 ;

l_resp_appl_id          NUMBER  ;
l_resp_id               NUMBER  ;
l_user_id               NUMBER  ;
l_login_id              NUMBER  ;
l_return_status         VARCHAR2(1) ;

l_estimate_detail_id    NUMBER := p_estimate_detail_id ;
l_cost_id		NUMBER;

BEGIN

  -- Standard Start of API Savepoint
  IF FND_API.To_Boolean( p_transaction_control ) THEN
    SAVEPOINT   Delete_Charge_Details_PUB ;
  END IF ;

  -- Standard Call to check API compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  -- Initialize the message list  if p_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)   THEN
    FND_MSG_PUB.initialize ;
  END IF ;


  -- Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_estimate_detail_id:' || p_estimate_detail_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_delete_cost_detail:' || p_delete_cost_detail
    );
  END IF;

  --need to call pvt API
  BEGIN
    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
        FND_LOG.String
          ( FND_LOG.level_procedure , L_LOG_MODULE || ''
            , 'Before callin Charges Delete Pvt API'
          );
    END IF ;

  CS_CHARGE_DETAILS_PVT.DELETE_CHARGE_DETAILS
          (
             p_api_version          => 1.0 ,
             p_init_msg_list        => FND_API.G_FALSE,
             p_commit               => p_commit,
             p_validation_level     => p_validation_level,
             x_return_status        => l_return_status,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data,
             p_transaction_control  => p_transaction_control,
             p_estimate_detail_id   => p_estimate_detail_id
	  ) ;

	  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  --   End of API Body
	  --   Standard Check of p_commit
	  IF FND_API.To_Boolean( p_commit ) THEN
	    COMMIT WORK ;
	  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                            p_data => x_msg_data) ;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
     FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'After callin Charges Delete Pvt API: '||l_return_status||x_msg_data
       );
  END IF ;
EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Details_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Details_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN OTHERS THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Details_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;
END;
--added by bkanimoz on 15-dec-2007 for service costing
--start



BEGIN
--If charge line has been deleted successfully then call the costing api to delete the cost record



IF l_return_status = FND_API.G_RET_STS_SUCCESS then
	  -- Standard Start of API Savepoint
	  IF FND_API.To_Boolean( p_transaction_control ) THEN
	    SAVEPOINT   Delete_Charge_Cost_Details_PUB ;
	  END IF ;

		  begin
			select cost_id
			into l_cost_id
			from cs_cost_details csd
			where csd.estimate_Detail_id =  p_estimate_detail_id;
		exception
		when no_data_found then
		    l_cost_id:=null;
		 when others then
		    l_cost_id:=null;
		end;
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
      FND_LOG.String
        ( FND_LOG.level_procedure ,
          L_LOG_MODULE || '',
          'l_cost_id' ||l_cost_id
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'Before callin Cost Delete Pvt API:l_cost_id :  '||l_cost_id
        );
  END IF ;
if l_cost_id is not null then
	CS_COST_DETAILS_PVT.DELETE_COST_DETAILS
	(
		 p_api_version         => 1.0 ,
		 p_init_msg_list       => p_init_msg_list,
		 p_commit              => p_commit,
		 p_validation_level    => FND_API.G_VALID_LEVEL_NONE,
		 x_return_status       => l_return_status,
		 x_msg_count           => x_msg_count,
		 x_msg_data            => x_msg_data,
		 p_transaction_control => p_transaction_control,
		 p_cost_id	       => l_cost_id
	 );

          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;


end if;


  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
     FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'After callin Cost Delete Pvt API:l_cost_id :  '||l_return_status
       );
  END IF ;

END IF;
  --Begin Exception Handling

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Cost_Details_PUB ;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Cost_Details_PUB ;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN OTHERS THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Delete_Charge_Cost_Details_PUB ;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;
END;

END  Delete_Charge_Details;   -- End of Procedure Delete Charge Details


/**************************************************
Public Procedure Body Copy_Estimate
**************************************************/

Procedure  Copy_Estimate(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL,
        x_estimate_detail_id  OUT NOCOPY NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2)  AS

l_api_name       CONSTANT  VARCHAR2(30)     := 'Copy_Estimate' ;
l_api_name_full  CONSTANT  VARCHAR2(61)     :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(255)     := 'csxpestb.plsql.' || l_api_name_full || '.';
l_api_version    CONSTANT  NUMBER           :=  1.0 ;

l_return_status         VARCHAR2(1) ;

BEGIN

  --DBMS_OUTPUT.PUT_LINE('in Public API');

  -- Standard Start of API Savepoint
  IF FND_API.To_Boolean( p_transaction_control ) THEN
    SAVEPOINT   Copy_Estimates_PUB ;
  END IF ;

  -- Standard Call to check API compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  -- Initialize the message list  if p_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)   THEN
    FND_MSG_PUB.initialize ;
  END IF ;


  -- Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_estimate_detail_id:' || p_estimate_detail_id
    );
  END IF;

  --need to call pvt API

  --DBMS_OUTPUT.PUT_LINE('Call Private API');

  CS_Charge_Details_PVT.Copy_Estimate(
        p_api_version         => l_api_version,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_transaction_control => FND_API.G_FALSE,
        p_estimate_detail_id  => p_estimate_detail_id,
        x_estimate_detail_id  => x_estimate_detail_id,
        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data) ;


  --DBMS_OUTPUT.PUT_LINE('return status is '||l_return_status);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  --   End of API Body
  --   Standard Check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK ;
  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                            p_data => x_msg_data) ;

  --Begin Exception Handling

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Copy_Estimates_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Copy_Estimates_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

      WHEN OTHERS THEN
        IF FND_API.To_Boolean( p_transaction_control ) THEN
          ROLLBACK TO Copy_Estimates_PUB;
        END IF ;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF ;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

END  Copy_Estimate;   -- End of Procedure Copy_Estimate

/**************************************************
Private Procedure Body TO_NULL
**************************************************/

 PROCEDURE TO_NULL(p_charges_rec_in             IN Charges_Rec_Type,
                   p_charges_rec_out OUT NOCOPY Charges_Rec_Type) IS
 BEGIN
  p_charges_rec_out.estimate_detail_id          := Check_For_Miss(p_charges_rec_in.estimate_detail_id) ;
  p_charges_rec_out.incident_id                 := Check_For_Miss(p_charges_rec_in.incident_id ) ;
  p_charges_rec_out.charge_line_type            := Check_For_Miss(p_charges_rec_in.charge_line_type);
  p_charges_rec_out.line_number                 := Check_For_Miss(p_charges_rec_in.line_number );
  p_charges_rec_out.business_process_id         := Check_For_Miss(p_charges_rec_in.business_process_id ) ;
  p_charges_rec_out.transaction_type_id         := Check_For_Miss(p_charges_rec_in.transaction_type_id);
  p_charges_rec_out.inventory_item_id_in        := Check_For_Miss(p_charges_rec_in.inventory_item_id_in ) ;
  p_charges_rec_out.item_revision               := Check_For_Miss(p_charges_rec_in.item_revision ) ;
  p_charges_rec_out.billing_flag                := Check_For_Miss(p_charges_rec_in.billing_flag);
  p_charges_rec_out.txn_billing_type_id         := Check_For_Miss(p_charges_rec_in.txn_billing_type_id ) ;
  p_charges_rec_out.unit_of_measure_code        := Check_For_Miss(p_charges_rec_in.unit_of_measure_code ) ;
  p_charges_rec_out.quantity_required           := Check_For_Miss(p_charges_rec_in.quantity_required ) ;
  p_charges_rec_out.return_reason_code          := Check_For_Miss(p_charges_rec_in.return_reason_code ) ;
  p_charges_rec_out.customer_product_id         := Check_For_Miss(p_charges_rec_in.customer_product_id ) ;
  p_charges_rec_out.serial_number               := Check_For_Miss(p_charges_rec_in.serial_number ) ;
  p_charges_rec_out.installed_cp_return_by_date := Check_For_Miss(p_charges_rec_in.installed_cp_return_by_date ) ;
  p_charges_rec_out.new_cp_return_by_date       := Check_For_Miss(p_charges_rec_in.new_cp_return_by_date ) ;
  p_charges_rec_out.sold_to_party_id            := Check_For_Miss(p_charges_rec_in.sold_to_party_id);
  p_charges_rec_out.bill_to_party_id            := Check_For_Miss(p_charges_rec_in.bill_to_party_id);
  p_charges_rec_out.bill_to_account_id          := Check_For_Miss(p_charges_rec_in.bill_to_account_id);
  p_charges_rec_out.bill_to_contact_id          := Check_For_Miss(p_charges_rec_in.bill_to_contact_id);
  p_charges_rec_out.invoice_to_org_id           := Check_For_Miss(p_charges_rec_in.invoice_to_org_id ) ;
  p_charges_rec_out.ship_to_party_id            := Check_For_Miss(p_charges_rec_in.ship_to_party_id);
  p_charges_rec_out.ship_to_account_id          := Check_For_Miss(p_charges_rec_in.ship_to_account_id);
  p_charges_rec_out.ship_to_contact_id          := Check_For_Miss(p_charges_rec_in.ship_to_contact_id);
  p_charges_rec_out.contract_line_id            := Check_For_Miss(p_charges_rec_in.contract_line_id);
  p_charges_rec_out.rate_type_code              := Check_For_Miss(p_charges_rec_in.rate_type_code);
  p_charges_rec_out.contract_id                 := Check_For_Miss(p_charges_rec_in.contract_id ) ;
  p_charges_rec_out.ship_to_org_id              := Check_For_Miss(p_charges_rec_in.ship_to_org_id ) ;
  p_charges_rec_out.coverage_id                 := Check_For_Miss(p_charges_rec_in.coverage_id ) ;
  p_charges_rec_out.coverage_txn_group_id       := Check_For_Miss(p_charges_rec_in.coverage_txn_group_id ) ;
  p_charges_rec_out.coverage_bill_rate_id       := Check_For_Miss(p_charges_rec_in.coverage_bill_rate_id ) ;
  p_charges_rec_out.coverage_billing_type_id    := Check_For_Miss(p_charges_rec_in.coverage_billing_type_id );
  p_charges_rec_out.price_list_id               := Check_For_Miss(p_charges_rec_in.price_list_id ) ;
  p_charges_rec_out.currency_code               := Check_For_Miss(p_charges_rec_in.currency_code ) ;
  p_charges_rec_out.purchase_order_num          := Check_For_Miss(p_charges_rec_in.purchase_order_num ) ;
  p_charges_rec_out.list_price                  := Check_For_Miss(p_charges_rec_in.list_price);
  p_charges_rec_out.con_pct_over_list_price     := Check_For_Miss(p_charges_rec_in.con_pct_over_list_price );
  p_charges_rec_out.selling_price               := Check_For_Miss(p_charges_rec_in.selling_price ) ;
  p_charges_rec_out.contract_discount_amount    := Check_For_Miss(p_charges_rec_in.contract_discount_amount);
  p_charges_rec_out.apply_contract_discount     := Check_For_Miss(p_charges_rec_in.apply_contract_discount );
  p_charges_rec_out.after_warranty_cost         := Check_For_Miss(p_charges_rec_in.after_warranty_cost ) ;
  p_charges_rec_out.transaction_inventory_org   := Check_For_Miss(p_charges_rec_in.transaction_inventory_org);
  p_charges_rec_out.transaction_sub_inventory   := Check_For_Miss(p_charges_rec_in.transaction_sub_inventory);
  p_charges_rec_out.rollup_flag                 := Check_For_Miss(p_charges_rec_in.rollup_flag ) ;
  p_charges_rec_out.add_to_order_flag           := Check_For_Miss(p_charges_rec_in.add_to_order_flag ) ;
  p_charges_rec_out.order_header_id             := Check_For_Miss(p_charges_rec_in.order_header_id ) ;
  p_charges_rec_out.interface_to_oe_flag        := Check_For_Miss(p_charges_rec_in.interface_to_oe_flag ) ;
  p_charges_rec_out.no_charge_flag              := Check_For_Miss(p_charges_rec_in.no_charge_flag ) ;
  p_charges_rec_out.line_category_code          := Check_For_Miss(p_charges_rec_in.line_category_code ) ;
  p_charges_rec_out.line_type_id                := Check_For_Miss(p_charges_rec_in.line_type_id );
  p_charges_rec_out.order_line_id               := Check_For_Miss(p_charges_rec_in.order_line_id );
  p_charges_rec_out.conversion_rate             := Check_For_Miss(p_charges_rec_in.conversion_rate );
  p_charges_rec_out.conversion_type_code        := Check_For_Miss(p_charges_rec_in.conversion_type_code );
  p_charges_rec_out.conversion_rate_date        := Check_For_Miss(p_charges_rec_in.conversion_rate_date );
  p_charges_rec_out.original_source_id          := Check_For_Miss(p_charges_rec_in.original_source_id ) ;
  p_charges_rec_out.original_source_code        := Check_For_Miss(p_charges_rec_in.original_source_code) ;
  p_charges_rec_out.source_id                   := Check_For_Miss(p_charges_rec_in.source_id ) ;
  p_charges_rec_out.source_code                 := Check_For_Miss(p_charges_rec_in.source_code) ;
  p_charges_rec_out.activity_start_time         := Check_For_Miss(p_charges_rec_in.activity_start_time);
  p_charges_rec_out.activity_end_time           := Check_For_Miss(p_charges_rec_in.activity_end_time);
  p_charges_rec_out.generated_by_bca_engine     := Check_For_Miss(p_charges_rec_in.generated_by_bca_engine);
  p_charges_rec_out.org_id                      := Check_For_Miss(p_charges_rec_in.org_id);
  p_charges_rec_out.submit_restriction_message  := Check_For_Miss(p_charges_rec_in.submit_restriction_message);
  p_charges_rec_out.submit_error_message        := Check_For_Miss(p_charges_rec_in.submit_error_message);
  p_charges_rec_out.submit_from_system          := Check_For_Miss(p_charges_rec_in.submit_from_system);
  p_charges_rec_out.line_submitted_flag         := Check_For_Miss(p_charges_rec_in.line_submitted_flag);
  p_charges_rec_out.context                     := Check_For_Miss(p_charges_rec_in.context) ;
  p_charges_rec_out.attribute1                  := Check_For_Miss(p_charges_rec_in.attribute1) ;
  p_charges_rec_out.attribute2                  := Check_For_Miss(p_charges_rec_in.attribute2) ;
  p_charges_rec_out.attribute3                  := Check_For_Miss(p_charges_rec_in.attribute3) ;
  p_charges_rec_out.attribute4                  := Check_For_Miss(p_charges_rec_in.attribute4) ;
  p_charges_rec_out.attribute5                  := Check_For_Miss(p_charges_rec_in.attribute5) ;
  p_charges_rec_out.attribute6                  := Check_For_Miss(p_charges_rec_in.attribute6) ;
  p_charges_rec_out.attribute7                  := Check_For_Miss(p_charges_rec_in.attribute7) ;
  p_charges_rec_out.attribute8                  := Check_For_Miss(p_charges_rec_in.attribute8) ;
  p_charges_rec_out.attribute9                  := Check_For_Miss(p_charges_rec_in.attribute9) ;
  p_charges_rec_out.attribute10                 := Check_For_Miss(p_charges_rec_in.attribute10) ;
  p_charges_rec_out.attribute11                 := Check_For_Miss(p_charges_rec_in.attribute11) ;
  p_charges_rec_out.attribute12                 := Check_For_Miss(p_charges_rec_in.attribute12) ;
  p_charges_rec_out.attribute13                 := Check_For_Miss(p_charges_rec_in.attribute13) ;
  p_charges_rec_out.attribute14                 := Check_For_Miss(p_charges_rec_in.attribute14) ;
  p_charges_rec_out.attribute15                 := Check_For_Miss(p_charges_rec_in.attribute15) ;
  p_charges_rec_out.pricing_context             := Check_For_Miss(p_charges_rec_in.pricing_context) ;
  p_charges_rec_out.pricing_attribute1          := Check_For_Miss(p_charges_rec_in.pricing_attribute1) ;
  p_charges_rec_out.pricing_attribute2          := Check_For_Miss(p_charges_rec_in.pricing_attribute2) ;
  p_charges_rec_out.pricing_attribute3          := Check_For_Miss(p_charges_rec_in.pricing_attribute3) ;
  p_charges_rec_out.pricing_attribute4          := Check_For_Miss(p_charges_rec_in.pricing_attribute4) ;
  p_charges_rec_out.pricing_attribute5          := Check_For_Miss(p_charges_rec_in.pricing_attribute5) ;
  p_charges_rec_out.pricing_attribute6          := Check_For_Miss(p_charges_rec_in.pricing_attribute6) ;
  p_charges_rec_out.pricing_attribute7          := Check_For_Miss(p_charges_rec_in.pricing_attribute7) ;
  p_charges_rec_out.pricing_attribute8          := Check_For_Miss(p_charges_rec_in.pricing_attribute8) ;
  p_charges_rec_out.pricing_attribute9          := Check_For_Miss(p_charges_rec_in.pricing_attribute9) ;
  p_charges_rec_out.pricing_attribute10         := Check_For_Miss(p_charges_rec_in.pricing_attribute10) ;
  p_charges_rec_out.pricing_attribute11         := Check_For_Miss(p_charges_rec_in.pricing_attribute11) ;
  p_charges_rec_out.pricing_attribute12         := Check_For_Miss(p_charges_rec_in.pricing_attribute12) ;
  p_charges_rec_out.pricing_attribute13         := Check_For_Miss(p_charges_rec_in.pricing_attribute13) ;
  p_charges_rec_out.pricing_attribute14         := Check_For_Miss(p_charges_rec_in.pricing_attribute14) ;
  p_charges_rec_out.pricing_attribute15         := Check_For_Miss(p_charges_rec_in.pricing_attribute15) ;
  p_charges_rec_out.pricing_attribute16         := Check_For_Miss(p_charges_rec_in.pricing_attribute16) ;
  p_charges_rec_out.pricing_attribute17         := Check_For_Miss(p_charges_rec_in.pricing_attribute17) ;
  p_charges_rec_out.pricing_attribute18         := Check_For_Miss(p_charges_rec_in.pricing_attribute18) ;
  p_charges_rec_out.pricing_attribute19         := Check_For_Miss(p_charges_rec_in.pricing_attribute19) ;
  p_charges_rec_out.pricing_attribute20         := Check_For_Miss(p_charges_rec_in.pricing_attribute20) ;
  p_charges_rec_out.pricing_attribute21         := Check_For_Miss(p_charges_rec_in.pricing_attribute21) ;
  p_charges_rec_out.pricing_attribute22         := Check_For_Miss(p_charges_rec_in.pricing_attribute22) ;
  p_charges_rec_out.pricing_attribute23         := Check_For_Miss(p_charges_rec_in.pricing_attribute23) ;
  p_charges_rec_out.pricing_attribute24         := Check_For_Miss(p_charges_rec_in.pricing_attribute24) ;
  p_charges_rec_out.pricing_attribute25         := Check_For_Miss(p_charges_rec_in.pricing_attribute25) ;
  p_charges_rec_out.pricing_attribute26         := Check_For_Miss(p_charges_rec_in.pricing_attribute26) ;
  p_charges_rec_out.pricing_attribute27         := Check_For_Miss(p_charges_rec_in.pricing_attribute27) ;
  p_charges_rec_out.pricing_attribute28         := Check_For_Miss(p_charges_rec_in.pricing_attribute28) ;
  p_charges_rec_out.pricing_attribute29         := Check_For_Miss(p_charges_rec_in.pricing_attribute29) ;
  p_charges_rec_out.pricing_attribute30         := Check_For_Miss(p_charges_rec_in.pricing_attribute30) ;
  p_charges_rec_out.pricing_attribute31         := Check_For_Miss(p_charges_rec_in.pricing_attribute31) ;
  p_charges_rec_out.pricing_attribute32         := Check_For_Miss(p_charges_rec_in.pricing_attribute32) ;
  p_charges_rec_out.pricing_attribute33         := Check_For_Miss(p_charges_rec_in.pricing_attribute33) ;
  p_charges_rec_out.pricing_attribute34         := Check_For_Miss(p_charges_rec_in.pricing_attribute34) ;
  p_charges_rec_out.pricing_attribute35         := Check_For_Miss(p_charges_rec_in.pricing_attribute35) ;
  p_charges_rec_out.pricing_attribute36         := Check_For_Miss(p_charges_rec_in.pricing_attribute36) ;
  p_charges_rec_out.pricing_attribute37         := Check_For_Miss(p_charges_rec_in.pricing_attribute37) ;
  p_charges_rec_out.pricing_attribute38         := Check_For_Miss(p_charges_rec_in.pricing_attribute38) ;
  p_charges_rec_out.pricing_attribute39         := Check_For_Miss(p_charges_rec_in.pricing_attribute39) ;
  p_charges_rec_out.pricing_attribute40         := Check_For_Miss(p_charges_rec_in.pricing_attribute40) ;
  p_charges_rec_out.pricing_attribute41         := Check_For_Miss(p_charges_rec_in.pricing_attribute41) ;
  p_charges_rec_out.pricing_attribute42         := Check_For_Miss(p_charges_rec_in.pricing_attribute42) ;
  p_charges_rec_out.pricing_attribute43         := Check_For_Miss(p_charges_rec_in.pricing_attribute43) ;
  p_charges_rec_out.pricing_attribute44         := Check_For_Miss(p_charges_rec_in.pricing_attribute44) ;
  p_charges_rec_out.pricing_attribute45         := Check_For_Miss(p_charges_rec_in.pricing_attribute45) ;
  p_charges_rec_out.pricing_attribute46         := Check_For_Miss(p_charges_rec_in.pricing_attribute46) ;
  p_charges_rec_out.pricing_attribute47         := Check_For_Miss(p_charges_rec_in.pricing_attribute47) ;
  p_charges_rec_out.pricing_attribute48         := Check_For_Miss(p_charges_rec_in.pricing_attribute48) ;
  p_charges_rec_out.pricing_attribute49         := Check_For_Miss(p_charges_rec_in.pricing_attribute49) ;
  p_charges_rec_out.pricing_attribute50         := Check_For_Miss(p_charges_rec_in.pricing_attribute50) ;
  p_charges_rec_out.pricing_attribute51         := Check_For_Miss(p_charges_rec_in.pricing_attribute51) ;
  p_charges_rec_out.pricing_attribute52         := Check_For_Miss(p_charges_rec_in.pricing_attribute52) ;
  p_charges_rec_out.pricing_attribute53         := Check_For_Miss(p_charges_rec_in.pricing_attribute53) ;
  p_charges_rec_out.pricing_attribute54         := Check_For_Miss(p_charges_rec_in.pricing_attribute54) ;
  p_charges_rec_out.pricing_attribute55         := Check_For_Miss(p_charges_rec_in.pricing_attribute55) ;
  p_charges_rec_out.pricing_attribute56         := Check_For_Miss(p_charges_rec_in.pricing_attribute56) ;
  p_charges_rec_out.pricing_attribute57         := Check_For_Miss(p_charges_rec_in.pricing_attribute57) ;
  p_charges_rec_out.pricing_attribute58         := Check_For_Miss(p_charges_rec_in.pricing_attribute58) ;
  p_charges_rec_out.pricing_attribute59         := Check_For_Miss(p_charges_rec_in.pricing_attribute59) ;
  p_charges_rec_out.pricing_attribute60         := Check_For_Miss(p_charges_rec_in.pricing_attribute60) ;
  p_charges_rec_out.pricing_attribute61         := Check_For_Miss(p_charges_rec_in.pricing_attribute61) ;
  p_charges_rec_out.pricing_attribute62         := Check_For_Miss(p_charges_rec_in.pricing_attribute62) ;
  p_charges_rec_out.pricing_attribute63         := Check_For_Miss(p_charges_rec_in.pricing_attribute63) ;
  p_charges_rec_out.pricing_attribute64         := Check_For_Miss(p_charges_rec_in.pricing_attribute64) ;
  p_charges_rec_out.pricing_attribute65         := Check_For_Miss(p_charges_rec_in.pricing_attribute65) ;
  p_charges_rec_out.pricing_attribute66         := Check_For_Miss(p_charges_rec_in.pricing_attribute66) ;
  p_charges_rec_out.pricing_attribute67         := Check_For_Miss(p_charges_rec_in.pricing_attribute67) ;
  p_charges_rec_out.pricing_attribute68         := Check_For_Miss(p_charges_rec_in.pricing_attribute68) ;
  p_charges_rec_out.pricing_attribute69         := Check_For_Miss(p_charges_rec_in.pricing_attribute69) ;
  p_charges_rec_out.pricing_attribute70         := Check_For_Miss(p_charges_rec_in.pricing_attribute70) ;
  p_charges_rec_out.pricing_attribute71         := Check_For_Miss(p_charges_rec_in.pricing_attribute71) ;
  p_charges_rec_out.pricing_attribute72         := Check_For_Miss(p_charges_rec_in.pricing_attribute72) ;
  p_charges_rec_out.pricing_attribute73         := Check_For_Miss(p_charges_rec_in.pricing_attribute73) ;
  p_charges_rec_out.pricing_attribute74         := Check_For_Miss(p_charges_rec_in.pricing_attribute74) ;
  p_charges_rec_out.pricing_attribute75         := Check_For_Miss(p_charges_rec_in.pricing_attribute75) ;
  p_charges_rec_out.pricing_attribute76         := Check_For_Miss(p_charges_rec_in.pricing_attribute76) ;
  p_charges_rec_out.pricing_attribute77         := Check_For_Miss(p_charges_rec_in.pricing_attribute77) ;
  p_charges_rec_out.pricing_attribute78         := Check_For_Miss(p_charges_rec_in.pricing_attribute78) ;
  p_charges_rec_out.pricing_attribute79         := Check_For_Miss(p_charges_rec_in.pricing_attribute79) ;
  p_charges_rec_out.pricing_attribute80         := Check_For_Miss(p_charges_rec_in.pricing_attribute80) ;
  p_charges_rec_out.pricing_attribute81         := Check_For_Miss(p_charges_rec_in.pricing_attribute81) ;
  p_charges_rec_out.pricing_attribute82         := Check_For_Miss(p_charges_rec_in.pricing_attribute82) ;
  p_charges_rec_out.pricing_attribute83         := Check_For_Miss(p_charges_rec_in.pricing_attribute83) ;
  p_charges_rec_out.pricing_attribute84         := Check_For_Miss(p_charges_rec_in.pricing_attribute84) ;
  p_charges_rec_out.pricing_attribute85         := Check_For_Miss(p_charges_rec_in.pricing_attribute85) ;
  p_charges_rec_out.pricing_attribute86         := Check_For_Miss(p_charges_rec_in.pricing_attribute86) ;
  p_charges_rec_out.pricing_attribute87         := Check_For_Miss(p_charges_rec_in.pricing_attribute87) ;
  p_charges_rec_out.pricing_attribute88         := Check_For_Miss(p_charges_rec_in.pricing_attribute88) ;
  p_charges_rec_out.pricing_attribute89         := Check_For_Miss(p_charges_rec_in.pricing_attribute89) ;
  p_charges_rec_out.pricing_attribute90         := Check_For_Miss(p_charges_rec_in.pricing_attribute90) ;
  p_charges_rec_out.pricing_attribute91         := Check_For_Miss(p_charges_rec_in.pricing_attribute91) ;
  p_charges_rec_out.pricing_attribute92         := Check_For_Miss(p_charges_rec_in.pricing_attribute92) ;
  p_charges_rec_out.pricing_attribute93         := Check_For_Miss(p_charges_rec_in.pricing_attribute93) ;
  p_charges_rec_out.pricing_attribute94         := Check_For_Miss(p_charges_rec_in.pricing_attribute94) ;
  p_charges_rec_out.pricing_attribute95         := Check_For_Miss(p_charges_rec_in.pricing_attribute95) ;
  p_charges_rec_out.pricing_attribute96         := Check_For_Miss(p_charges_rec_in.pricing_attribute96) ;
  p_charges_rec_out.pricing_attribute97         := Check_For_Miss(p_charges_rec_in.pricing_attribute97) ;
  p_charges_rec_out.pricing_attribute98         := Check_For_Miss(p_charges_rec_in.pricing_attribute98) ;
  p_charges_rec_out.pricing_attribute99         := Check_For_Miss(p_charges_rec_in.pricing_attribute99) ;
  p_charges_rec_out.pricing_attribute100        := Check_For_Miss(p_charges_rec_in.pricing_attribute100);

  --obsoleted columns/columns not used/Columns left for backward compatibility
  p_charges_rec_out.original_source_number      := Check_For_Miss(p_charges_rec_in.original_source_number );
  p_charges_rec_out.source_number               := Check_For_Miss(p_charges_rec_in.source_number );
  p_charges_rec_out.reference_number            := Check_For_Miss(p_charges_rec_in.reference_number );
  p_charges_rec_out.original_system_reference   := Check_For_Miss(p_charges_rec_in.original_system_reference );
  p_charges_rec_out.inventory_item_id_out       := Check_For_Miss(p_charges_rec_in.inventory_item_id_out );
  p_charges_rec_out.serial_number_out           := Check_For_Miss(p_charges_rec_in.serial_number_out );
  p_charges_rec_out.exception_coverage_used      := Check_For_Miss(p_charges_rec_in.exception_coverage_used );
  /*Credit Card 9358401 */
  p_charges_rec_out.instrument_payment_use_id   := p_charges_rec_in.instrument_payment_use_id ;

END TO_NULL ;

/**************************************************
 Procedure Body Log_Charges_Rec_Parameters
 This Procedure is used for Logging the charges record paramters.
**************************************************/

PROCEDURE Log_Charges_Rec_Parameters
( p_Charges_Rec              IN         Charges_Rec_Type
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Log_Charges_Rec_Parameters';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' estimate_detail_id                  	 :' || p_Charges_Rec.estimate_detail_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' incident_id                         	 :' || p_Charges_Rec.incident_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' charge_line_type                    	 :' || p_Charges_Rec.charge_line_type
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' line_number                         	 :' || p_Charges_Rec.line_number
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' business_process_id                 	 :' || p_Charges_Rec.business_process_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' transaction_type_id                 	 :' || p_Charges_Rec.transaction_type_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' inventory_item_id_in                	 :' || p_Charges_Rec.inventory_item_id_in
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' item_revision                       	 :' || p_Charges_Rec.item_revision
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' billing_flag                        	 :' || p_Charges_Rec.billing_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' txn_billing_type_id                 	 :' || p_Charges_Rec.txn_billing_type_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' unit_of_measure_code                	 :' || p_Charges_Rec.unit_of_measure_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' quantity_required                   	 :' || p_Charges_Rec.quantity_required
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' return_reason_code                  	 :' || p_Charges_Rec.return_reason_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' customer_product_id                 	 :' || p_Charges_Rec.customer_product_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' serial_number                       	 :' || p_Charges_Rec.serial_number
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' installed_cp_return_by_date         	 :' || p_Charges_Rec.installed_cp_return_by_date
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' new_cp_return_by_date               	 :' || p_Charges_Rec.new_cp_return_by_date
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' sold_to_party_id                    	 :' || p_Charges_Rec.sold_to_party_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' bill_to_party_id                    	 :' || p_Charges_Rec.bill_to_party_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' bill_to_account_id                  	 :' || p_Charges_Rec.bill_to_account_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' bill_to_contact_id                  	 :' || p_Charges_Rec.bill_to_contact_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' invoice_to_org_id                   	 :' || p_Charges_Rec.invoice_to_org_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' ship_to_party_id                    	 :' || p_Charges_Rec.ship_to_party_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' ship_to_account_id                  	 :' || p_Charges_Rec.ship_to_account_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' ship_to_contact_id                  	 :' || p_Charges_Rec.ship_to_contact_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' ship_to_org_id                      	 :' || p_Charges_Rec.ship_to_org_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' contract_line_id                    	 :' || p_Charges_Rec.contract_line_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' rate_type_code                      	 :' || p_Charges_Rec.rate_type_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' contract_id                         	 :' || p_Charges_Rec.contract_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' coverage_id                         	 :' || p_Charges_Rec.coverage_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' coverage_txn_group_id               	 :' || p_Charges_Rec.coverage_txn_group_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' coverage_bill_rate_id               	 :' || p_Charges_Rec.coverage_bill_rate_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' coverage_billing_type_id            	 :' || p_Charges_Rec.coverage_billing_type_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' price_list_id                       	 :' || p_Charges_Rec.price_list_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' currency_code                       	 :' || p_Charges_Rec.currency_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' purchase_order_num                  	 :' || p_Charges_Rec.purchase_order_num
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' list_price                          	 :' || p_Charges_Rec.list_price
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' con_pct_over_list_price             	 :' || p_Charges_Rec.con_pct_over_list_price
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' selling_price                       	 :' || p_Charges_Rec.selling_price
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' contract_discount_amount            	 :' || p_Charges_Rec.contract_discount_amount
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' apply_contract_discount             	 :' || p_Charges_Rec.apply_contract_discount
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' after_warranty_cost                 	 :' || p_Charges_Rec.after_warranty_cost
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' transaction_inventory_org           	 :' || p_Charges_Rec.transaction_inventory_org
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' transaction_sub_inventory           	 :' || p_Charges_Rec.transaction_sub_inventory
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' rollup_flag                         	 :' || p_Charges_Rec.rollup_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' add_to_order_flag                   	 :' || p_Charges_Rec.add_to_order_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' order_header_id                     	 :' || p_Charges_Rec.order_header_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' interface_to_oe_flag                	 :' || p_Charges_Rec.interface_to_oe_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' no_charge_flag                      	 :' || p_Charges_Rec.no_charge_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' line_category_code                  	 :' || p_Charges_Rec.line_category_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' line_type_id                        	 :' || p_Charges_Rec.line_type_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' order_line_id                       	 :' || p_Charges_Rec.order_line_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' conversion_rate                     	 :' || p_Charges_Rec.conversion_rate
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' conversion_type_code                	 :' || p_Charges_Rec.conversion_type_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' conversion_rate_date                	 :' || p_Charges_Rec.conversion_rate_date
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' original_source_id                  	 :' || p_Charges_Rec.original_source_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' original_source_code                	 :' || p_Charges_Rec.original_source_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' source_id                           	 :' || p_Charges_Rec.source_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' source_code                         	 :' || p_Charges_Rec.source_code
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' org_id                              	 :' || p_Charges_Rec.org_id
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' submit_restriction_message          	 :' || p_Charges_Rec.submit_restriction_message
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' submit_error_message                	 :' || p_Charges_Rec.submit_error_message
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' submit_from_system              	 :' || p_Charges_Rec.submit_from_system
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' line_submitted_flag                 	 :' || p_Charges_Rec.line_submitted_flag
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' activity_start_time                 	 :' || p_Charges_Rec.activity_start_time
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' activity_end_time                   	 :' || p_Charges_Rec.activity_end_time
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' generated_by_bca_engine             	 :' || p_Charges_Rec.generated_by_bca_engine
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute1                          	 :' || p_Charges_Rec.attribute1
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute2                          	 :' || p_Charges_Rec.attribute2
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute3                          	 :' || p_Charges_Rec.attribute3
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute4                          	 :' || p_Charges_Rec.attribute4
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute5                          	 :' || p_Charges_Rec.attribute5
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute6                          	 :' || p_Charges_Rec.attribute6
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute7                          	 :' || p_Charges_Rec.attribute7
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute8                          	 :' || p_Charges_Rec.attribute8
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute9                          	 :' || p_Charges_Rec.attribute9
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute10                         	 :' || p_Charges_Rec.attribute10
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute11                         	 :' || p_Charges_Rec.attribute11
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute12                         	 :' || p_Charges_Rec.attribute12
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute13                         	 :' || p_Charges_Rec.attribute13
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute14                         	 :' || p_Charges_Rec.attribute14
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' attribute15                         	 :' || p_Charges_Rec.attribute15
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' context                             	 :' || p_Charges_Rec.context
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_context                     	 :' || p_Charges_Rec.pricing_context
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute1                  	 :' || p_Charges_Rec.pricing_attribute1
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute2                  	 :' || p_Charges_Rec.pricing_attribute2
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute3                  	 :' || p_Charges_Rec.pricing_attribute3
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute4                  	 :' || p_Charges_Rec.pricing_attribute4
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute5                  	 :' || p_Charges_Rec.pricing_attribute5
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute6                  	 :' || p_Charges_Rec.pricing_attribute6
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute7                  	 :' || p_Charges_Rec.pricing_attribute7
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute8                  	 :' || p_Charges_Rec.pricing_attribute8
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute9                  	 :' || p_Charges_Rec.pricing_attribute9
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute10                 	 :' || p_Charges_Rec.pricing_attribute10
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute11                 	 :' || p_Charges_Rec.pricing_attribute11
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute12                 	 :' || p_Charges_Rec.pricing_attribute12
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute13                 	 :' || p_Charges_Rec.pricing_attribute13
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute14                 	 :' || p_Charges_Rec.pricing_attribute14
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute15                 	 :' || p_Charges_Rec.pricing_attribute15
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute16                 	 :' || p_Charges_Rec.pricing_attribute16
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute17                 	 :' || p_Charges_Rec.pricing_attribute17
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute18                 	 :' || p_Charges_Rec.pricing_attribute18
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute19                 	 :' || p_Charges_Rec.pricing_attribute19
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute20                 	 :' || p_Charges_Rec.pricing_attribute20
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute21                 	 :' || p_Charges_Rec.pricing_attribute21
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute22                 	 :' || p_Charges_Rec.pricing_attribute22
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute23                 	 :' || p_Charges_Rec.pricing_attribute23
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute24                 	 :' || p_Charges_Rec.pricing_attribute24
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute25                 	 :' || p_Charges_Rec.pricing_attribute25
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute26                 	 :' || p_Charges_Rec.pricing_attribute26
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute27                 	 :' || p_Charges_Rec.pricing_attribute27
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute28                 	 :' || p_Charges_Rec.pricing_attribute28
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute29                 	 :' || p_Charges_Rec.pricing_attribute29
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute30                 	 :' || p_Charges_Rec.pricing_attribute30
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute31                 	 :' || p_Charges_Rec.pricing_attribute31
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute32                 	 :' || p_Charges_Rec.pricing_attribute32
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute33                 	 :' || p_Charges_Rec.pricing_attribute33
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute34                 	 :' || p_Charges_Rec.pricing_attribute34
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute35                 	 :' || p_Charges_Rec.pricing_attribute35
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute36                 	 :' || p_Charges_Rec.pricing_attribute36
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute37                 	 :' || p_Charges_Rec.pricing_attribute37
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute38                 	 :' || p_Charges_Rec.pricing_attribute38
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute39                 	 :' || p_Charges_Rec.pricing_attribute39
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute40                 	 :' || p_Charges_Rec.pricing_attribute40
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute41                 	 :' || p_Charges_Rec.pricing_attribute41
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute42                 	 :' || p_Charges_Rec.pricing_attribute42
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute43                 	 :' || p_Charges_Rec.pricing_attribute43
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute44                 	 :' || p_Charges_Rec.pricing_attribute44
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute45                 	 :' || p_Charges_Rec.pricing_attribute45
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute46                 	 :' || p_Charges_Rec.pricing_attribute46
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute47                 	 :' || p_Charges_Rec.pricing_attribute47
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute48                 	 :' || p_Charges_Rec.pricing_attribute48
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute49                 	 :' || p_Charges_Rec.pricing_attribute49
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute50                 	 :' || p_Charges_Rec.pricing_attribute50
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute51                 	 :' || p_Charges_Rec.pricing_attribute51
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute52                 	 :' || p_Charges_Rec.pricing_attribute52
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute53                 	 :' || p_Charges_Rec.pricing_attribute53
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute54                 	 :' || p_Charges_Rec.pricing_attribute54
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute55                 	 :' || p_Charges_Rec.pricing_attribute55
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute56                 	 :' || p_Charges_Rec.pricing_attribute56
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute57                 	 :' || p_Charges_Rec.pricing_attribute57
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute58                 	 :' || p_Charges_Rec.pricing_attribute58
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute59                 	 :' || p_Charges_Rec.pricing_attribute59
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute60                 	 :' || p_Charges_Rec.pricing_attribute60
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute61                 	 :' || p_Charges_Rec.pricing_attribute61
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute62                 	 :' || p_Charges_Rec.pricing_attribute62
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute63                 	 :' || p_Charges_Rec.pricing_attribute63
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute64                 	 :' || p_Charges_Rec.pricing_attribute64
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute65                 	 :' || p_Charges_Rec.pricing_attribute65
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute66                 	 :' || p_Charges_Rec.pricing_attribute66
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute67                 	 :' || p_Charges_Rec.pricing_attribute67
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute68                 	 :' || p_Charges_Rec.pricing_attribute68
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute69                 	 :' || p_Charges_Rec.pricing_attribute69
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute70                 	 :' || p_Charges_Rec.pricing_attribute70
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute71                 	 :' || p_Charges_Rec.pricing_attribute71
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute72                 	 :' || p_Charges_Rec.pricing_attribute72
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute73                 	 :' || p_Charges_Rec.pricing_attribute73
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute74                 	 :' || p_Charges_Rec.pricing_attribute74
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute75                 	 :' || p_Charges_Rec.pricing_attribute75
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute76                 	 :' || p_Charges_Rec.pricing_attribute76
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute77                 	 :' || p_Charges_Rec.pricing_attribute77
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute78                 	 :' || p_Charges_Rec.pricing_attribute78
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute79                 	 :' || p_Charges_Rec.pricing_attribute79
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute80                 	 :' || p_Charges_Rec.pricing_attribute80
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute81                 	 :' || p_Charges_Rec.pricing_attribute81
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute82                 	 :' || p_Charges_Rec.pricing_attribute82
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute83                 	 :' || p_Charges_Rec.pricing_attribute83
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute84                 	 :' || p_Charges_Rec.pricing_attribute84
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute85                 	 :' || p_Charges_Rec.pricing_attribute85
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute86                 	 :' || p_Charges_Rec.pricing_attribute86
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute87                 	 :' || p_Charges_Rec.pricing_attribute87
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute88                 	 :' || p_Charges_Rec.pricing_attribute88
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute89                 	 :' || p_Charges_Rec.pricing_attribute89
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute90                 	 :' || p_Charges_Rec.pricing_attribute90
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute91                 	 :' || p_Charges_Rec.pricing_attribute91
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute92                 	 :' || p_Charges_Rec.pricing_attribute92
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute93                 	 :' || p_Charges_Rec.pricing_attribute93
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute94                 	 :' || p_Charges_Rec.pricing_attribute94
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute95                 	 :' || p_Charges_Rec.pricing_attribute95
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute96                 	 :' || p_Charges_Rec.pricing_attribute96
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute97                 	 :' || p_Charges_Rec.pricing_attribute97
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute98                 	 :' || p_Charges_Rec.pricing_attribute98
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute99                 	 :' || p_Charges_Rec.pricing_attribute99
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' pricing_attribute100                	 :' || p_Charges_Rec.pricing_attribute100
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' original_source_number            	 :' || p_Charges_Rec.original_source_number
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' source_number                     	 :' || p_Charges_Rec.source_number
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' reference_number                  	 :' || p_Charges_Rec.reference_number
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' original_system_reference         	 :' || p_Charges_Rec.original_system_reference
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' inventory_item_id_out             	 :' || p_Charges_Rec.inventory_item_id_out
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' serial_number_out                	 :' || p_Charges_Rec.serial_number_out
  );
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' exception_coverage_used          	 :' || p_Charges_Rec.exception_coverage_used
  );
  /* Credit Card 9358401 */
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  ,' instrument_payment_use_id assignment id          	 :' ||
                                     p_Charges_Rec.instrument_payment_use_id
  );
  END IF ;

END Log_Charges_Rec_Parameters;

/*************************************************
Function Implementations
**************************************************/
FUNCTION  Check_For_Miss ( p_param  IN  NUMBER ) RETURN NUMBER IS
BEGIN
  IF p_param = FND_API.G_MISS_NUM THEN
     RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;


FUNCTION  Check_For_Miss ( p_param  IN  VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  IF p_param = FND_API.G_MISS_CHAR THEN
     RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;


FUNCTION  Check_For_Miss ( p_param  IN  DATE ) RETURN DATE IS
BEGIN
  IF p_param = FND_API.G_MISS_DATE THEN
     RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;

END CS_Charge_Details_PUB;

/
