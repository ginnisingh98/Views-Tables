--------------------------------------------------------
--  DDL for Package Body EAM_FAILURESETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FAILURESETS_PUB" AS
/* $Header: EAMPFSPB.pls 120.0 2006/03/08 07:13:11 sshahid noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_FailureSets_PUB';

PROCEDURE Create_FailureSet
       (p_api_version      IN  NUMBER                                     ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_failureset_rec   IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2                            ,
        x_failureset_id    OUT NOCOPY NUMBER
       )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Create_FailureSet';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_failure_set_id      NUMBER;

BEGIN
    -- API savepoint
    SAVEPOINT Create_FailureSet_PUB;

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
    EAM_FailureSets_PVT.Setup_FailureSet
           (p_api_version      ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'C'             ,
            p_failureset_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data         ,
            l_failure_set_id
            );

    x_failureset_id := l_failure_set_id;

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO Create_FailureSet_PUB;
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
END Create_FailureSet;


PROCEDURE Update_FailureSet
       (p_api_version      IN  NUMBER                                     ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_failureset_rec   IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2                            ,
        x_failureset_id    OUT NOCOPY NUMBER
       )
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Update_FailureSet';
l_api_version         CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;
l_failure_set_id      NUMBER;

BEGIN
    -- API savepoint
    SAVEPOINT Update_FailureSet_PUB;

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
    EAM_FailureSets_PVT.Setup_FailureSet
           (p_api_version      ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'U'             ,
            p_failureset_rec   ,
            x_return_status    ,
            x_msg_count        ,
            x_msg_data         ,
            l_failure_set_id
            );

    x_failureset_id := l_failure_set_id;

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK TO Update_FailureSet_PUB;
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
END Update_FailureSet;

PROCEDURE Create_Association
       (p_api_version      IN  NUMBER                                         ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2
       )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Create_Association';
l_api_version   CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Create_Association_PUB;

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
    EAM_FailureSets_PVT.Setup_SetAssociation
           (p_api_version      ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'C'            ,
            p_association_rec  ,
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
		ROLLBACK TO Create_Association_PUB;
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
END Create_Association;

PROCEDURE Update_Association
       (p_api_version      IN  NUMBER                                         ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2
       )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Update_Association';
l_api_version   CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Update_Association_PUB;

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
    EAM_FailureSets_PVT.Setup_SetAssociation
           (p_api_version      ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'U'            ,
            p_association_rec  ,
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
		ROLLBACK TO Update_Association_PUB;
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
END Update_Association;

PROCEDURE Delete_Association
       (p_api_version      IN  NUMBER                                         ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2
       )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Association';
l_api_version   CONSTANT NUMBER       := 1.0;
l_validation_level    NUMBER := FND_API.G_VALID_LEVEL_FULL;

BEGIN
    -- API savepoint
    SAVEPOINT Delete_Association_PUB;

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
    EAM_FailureSets_PVT.Setup_SetAssociation
           (p_api_version      ,
            p_init_msg_list    ,
            p_commit           ,
            l_validation_level ,
            'D'            ,
            p_association_rec  ,
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
		ROLLBACK TO Delete_Association_PUB;
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
END Delete_Association;

END EAM_FailureSets_PUB;

/
