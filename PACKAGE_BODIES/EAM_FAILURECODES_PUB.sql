--------------------------------------------------------
--  DDL for Package Body EAM_FAILURECODES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FAILURECODES_PUB" AS
/* $Header: EAMPFCPB.pls 120.0 2006/03/08 07:06:59 sshahid noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_FailureCodes_PUB';

PROCEDURE Create_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Create_Code';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Create_Code_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Code
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'C'             ,
            p_failurecode_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data
            );

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Create_Code_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Create_Code;

PROCEDURE Update_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Update_Code';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Update_Code_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Code
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'U'             ,
            p_failurecode_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data
            );

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Update_Code_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Update_Code;

PROCEDURE Delete_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Code';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Delete_Code_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Code
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'D'             ,
            p_failurecode_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data
            );

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Delete_Code_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Delete_Code;

PROCEDURE Create_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2,
          x_combination_id  OUT NOCOPY NUMBER
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Create_Combination';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_combination_id      NUMBER;
l_combination_rec  EAM_FailureCodes_PUB.eam_combination_rec_type;

BEGIN
    -- API savepoint
    SAVEPOINT Create_Combination_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- populate combination rec
       l_combination_rec.set_id                := p_combination_rec.set_id;
       l_combination_rec.set_name              := p_combination_rec.set_name;
       l_combination_rec.failure_code          := p_combination_rec.failure_code;
       l_combination_rec.failure_description   := p_combination_rec.failure_description;
       l_combination_rec.cause_code            := p_combination_rec.cause_code;
       l_combination_rec.cause_description     := p_combination_rec.cause_description;
       l_combination_rec.resolution_code       := p_combination_rec.resolution_code;
       l_combination_rec.resolution_description:= p_combination_rec.resolution_description;
       l_combination_rec.effective_end_date    := p_combination_rec.effective_end_date;
       l_combination_rec.combination_id        := p_combination_rec.combination_id;
       l_combination_rec.stored_last_upd_date  := p_combination_rec.stored_last_upd_date;
       l_combination_rec.created_by             := fnd_global.user_id;
       l_combination_rec.creation_date          := sysdate;
       l_combination_rec.last_update_date       := sysdate;
       l_combination_rec.last_updated_by        := fnd_global.user_id;
       l_combination_rec.last_update_login      := p_combination_rec.last_update_login;
    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Combination
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'C'             ,
            l_combination_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data        ,
            l_combination_id);
    x_combination_id := l_combination_id;
    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Create_Combination_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Create_Combination;

PROCEDURE Update_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2,
          x_combination_id  OUT NOCOPY NUMBER
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Update_Combination';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_combination_id      NUMBER;
l_combination_rec  EAM_FailureCodes_PUB.eam_combination_rec_type;
BEGIN
    -- API savepoint
    SAVEPOINT Update_Combination_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- populate combination rec
       l_combination_rec.set_id                := p_combination_rec.set_id;
       l_combination_rec.set_name              := p_combination_rec.set_name;
       l_combination_rec.failure_code          := p_combination_rec.failure_code;
       l_combination_rec.failure_description   := p_combination_rec.failure_description;
       l_combination_rec.cause_code            := p_combination_rec.cause_code;
       l_combination_rec.cause_description     := p_combination_rec.cause_description;
       l_combination_rec.resolution_code       := p_combination_rec.resolution_code;
       l_combination_rec.resolution_description:= p_combination_rec.resolution_description;
       l_combination_rec.effective_end_date    := p_combination_rec.effective_end_date;
       l_combination_rec.combination_id        := p_combination_rec.combination_id;
       l_combination_rec.stored_last_upd_date  := p_combination_rec.stored_last_upd_date;
       l_combination_rec.created_by             := fnd_global.user_id;
       l_combination_rec.creation_date          := sysdate;
       l_combination_rec.last_update_date       := sysdate;
       l_combination_rec.last_updated_by        := fnd_global.user_id;
       l_combination_rec.last_update_login      := p_combination_rec.last_update_login;
    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Combination
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'U'             ,
            l_combination_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data         ,
            l_combination_id);
    x_combination_id := l_combination_id;
    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Update_Combination_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Update_Combination;

PROCEDURE Delete_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Combination';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_combination_id      NUMBER;

BEGIN
    -- API savepoint
    SAVEPOINT Delete_Combination_PUB;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call PVT API
    EAM_FailureCodes_PVT.Setup_Combination
           (1.0     ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'D'             ,
            p_combination_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data ,
            l_combination_id);

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Delete_Combination_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Delete_Combination;

END EAM_FailureCodes_PUB;

/
