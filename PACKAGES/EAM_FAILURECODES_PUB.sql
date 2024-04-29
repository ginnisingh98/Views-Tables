--------------------------------------------------------
--  DDL for Package EAM_FAILURECODES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FAILURECODES_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPFCPS.pls 120.0 2006/03/08 07:03:12 sshahid noship $ */
G_FAILURE_CODE     CONSTANT NUMBER := 10;
G_CAUSE_CODE       CONSTANT NUMBER := 20;
G_RESOLUTION_CODE  CONSTANT NUMBER := 30;

TYPE eam_failurecode_rec_type IS RECORD
                                (code_type            NUMBER  ,
                                 code                 VARCHAR2(80)  ,
                                 description          VARCHAR2(2000),
                                 effective_end_date   DATE          ,
                                 stored_last_upd_date DATE);

TYPE eam_combination_rec_type IS RECORD
                     (set_id                 NUMBER      ,
                      set_name               VARCHAR2(80),
                      failure_code           VARCHAR2(80),
                      failure_description    VARCHAR2(2000),
                      cause_code             VARCHAR2(80),
                      cause_description      VARCHAR2(2000),
                      resolution_code        VARCHAR2(80),
                      resolution_description VARCHAR2(2000),
                      effective_end_date     DATE        ,
                      combination_id         NUMBER,
                      stored_last_upd_date   DATE,
                      created_by             NUMBER    ,
                      creation_date          DATE      ,
                      last_update_date       DATE      ,
                      last_updated_by        NUMBER    ,
                      last_update_login      NUMBER);

/**************************************************************************
-- Start of comments
--	API name 	: Create_Code
--	Type		: Public.
--	Function	: Create Failure/Cause/Resolution Code
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_failurecode_rec   IN
--                               EAM_FailureCodes_PUB.eam_failurecode_rec_type
--                        Within p_failurecode_rec, code_type and code are
--                        'Required'. code_type should be one of the lookup
--                        code values seeded for EAM_FAILURE_CODE_TYPE.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Create_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Update_Code
--	Type		: Public.
--	Function	: Update Failure/Cause/Resolution Code
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_failurecode_rec   IN
--                               EAM_FailureCodes_PUB.eam_failurecode_rec_type
--                        Within p_failurecode_rec, code_type and code are
--                        'Required'.code_type should be one of the lookup
--                        code values seeded for EAM_FAILURE_CODE_TYPE.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Update_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Delete_Code
--	Type		: Public.
--	Function	: Delete Failure/Cause/Resolution Code
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_failurecode_rec   IN
--                               EAM_FailureCodes_PUB.eam_failurecode_rec_type
--                        Within p_failurecode_rec, code_type and code are
--                        'Required'.code_type should be one of the lookup
--                        code values seeded for EAM_FAILURE_CODE_TYPE.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Delete_Code
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failurecode_rec IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Create_Combination
--	Type		: Public.
--	Function	: Create a Failure - Cause -Resolution Combination
--                        in the context of a failure set.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_combination_rec   IN
--                         EAM_FailureCodes_PUB.eam_combination_rec_type
--                        Within p_combination_rec, failure_code, cause_code
--                        and resolution_code are 'Required' and either
--                        set_id or set_name is 'Required'.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--                        x_combination_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Create_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2                            ,
          x_combination_id  OUT NOCOPY NUMBER
          );
/**************************************************************************
-- Start of comments
--	API name 	: Update_Combination
--	Type		: Public.
--	Function	: Update a Failure - Cause -Resolution Combination
--                        in the context of a failure set.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_combination_rec   IN
--                         EAM_FailureCodes_PUB.eam_combination_rec_type
--                        Within p_combination_rec, failure_code, cause_code
--                        and resolution_code are 'Required' and either
--                        set_id or set_name is 'Required'.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Update_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2                            ,
          x_combination_id  OUT NOCOPY NUMBER
          );
/**************************************************************************
-- Start of comments
--	API name 	: Delete_Combination
--	Type		: Public.
--	Function	: Delete a Failure - Cause -Resolution Combination
--                        in the context of a failure set.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_combination_rec   IN
--                         EAM_FailureCodes_PUB.eam_combination_rec_type
--                        Within p_combination_rec, failure_code, cause_code
--                        and resolution_code are 'Required' and either
--                        set_id or set_name is 'Required'.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Delete_Combination
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_combination_rec IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
          );
END EAM_FailureCodes_PUB;

 

/
