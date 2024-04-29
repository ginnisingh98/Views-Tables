--------------------------------------------------------
--  DDL for Package EAM_FAILURECODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FAILURECODES_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVFCPS.pls 120.0 2006/03/08 07:09:45 sshahid noship $ */

/**************************************************************************
-- Start of comments
--	API name 	: Setup_Code
--	Type		: Private.
--	Function	: Create or Update or Delete Failure/Cause/Resolution Code
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                   	  p_validation_level IN NUMBER
--                               Default = FND_API.G_VALID_LEVEL_FULL
--                        p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create
--                            'U' for update
--                            'D' for delete
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
PROCEDURE Setup_Code
         (p_api_version      IN  NUMBER                                     ,
          p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN  NUMBER	  := FND_API.G_VALID_LEVEL_FULL     ,
          p_mode             IN  VARCHAR2                                   ,
          p_failurecode_rec  IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status    OUT NOCOPY VARCHAR2                            ,
          x_msg_count        OUT NOCOPY NUMBER                              ,
          x_msg_data         OUT NOCOPY VARCHAR2
         );

/**************************************************************************
-- Start of comments
--	API name 	: Setup_Combination
--	Type		: Private.
--	Function	: Create or update or delete a
--                        Failure - Cause -Resolution Combination
--                        in the context of a failure set.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                   	  p_validation_level IN NUMBER
--                               Default = FND_API.G_VALID_LEVEL_FULL
--                        p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create
--                            'U' for update
--                            'D' for delete
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
PROCEDURE Setup_Combination
         (p_api_version      IN  NUMBER                                     ,
          p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN  NUMBER	  := FND_API.G_VALID_LEVEL_FULL     ,
          p_mode             IN VARCHAR2                                    ,
          p_combination_rec  IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
          x_return_status    OUT NOCOPY VARCHAR2                            ,
          x_msg_count        OUT NOCOPY NUMBER                              ,
          x_msg_data         OUT NOCOPY VARCHAR2                            ,
          x_combination_id   OUT NOCOPY NUMBER
          );
/**************************************************************************
-- Start of comments
--	API name 	: Copy_FailureSet
--	Type		: Private.
--	Function	: Copy
--                        Failure - Cause -Resolution Combinations
--                        from a source failure set to destination
--                        failure set.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                   	  p_validation_level IN NUMBER
--                               Default = FND_API.G_VALID_LEVEL_FULL
--                        p_source_set_id   IN NUMBER
--                        p_destination_set_id IN NUMBER
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Copy_FailureSet
         (p_api_version        IN  NUMBER                                     ,
          p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit             IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN  NUMBER	  := FND_API.G_VALID_LEVEL_FULL       ,
          p_source_set_id      IN NUMBER                                      ,
          p_destination_set_id IN NUMBER                                      ,
          x_return_status      OUT NOCOPY VARCHAR2                            ,
          x_msg_count          OUT NOCOPY NUMBER                              ,
          x_msg_data           OUT NOCOPY VARCHAR2
          );
/**************************************************************************
-- Start of comments
--	API name 	: Setup_Code_JSP
--	Type		: Private.
--	Function	: Wrapper call to Setup_Code_JSP from OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create
--                            'U' for update
--                            'D' for delete
--                          code_type            IN NUMBER
--                          code                 IN VARCHAR2
--                          description          IN VARCHAR2
--                          effective_end_date   IN DATE
--                          stored_last_upd_date IN DATE
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_Code_JSP
         (p_mode                 IN VARCHAR2,
          p_code_type            IN NUMBER  ,
          p_code                 IN VARCHAR2,
          p_description          IN VARCHAR2,
          p_effective_end_date   IN DATE    ,
          p_stored_last_upd_date IN DATE    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Setup_Combination_JSP
--	Type		: Private.
--	Function	: Wrapper call to Setup_Combination from OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:  p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create
--                            'U' for update
--                            'D' for delete
--                        set_name               IN VARCHAR2
--                        failure_code           IN VARCHAR2
--                        failure_description    IN VARCHAR2
--                        cause_code             IN VARCHAR2
--                        cause_description      IN VARCHAR2
--                        resolution_code        IN VARCHAR2
--                        resolution_description IN VARCHAR2
--                        effective_end_date     IN DATE
--                        combination_id         IN NUMBER
--                        stored_last_upd_date   IN DATE
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--                        x_combination_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_Combination_JSP
         (p_mode             	   IN VARCHAR2  ,
	  p_set_id                 IN NUMBER    ,
	  p_set_name               IN VARCHAR2  ,
	  p_failure_code           IN VARCHAR2  ,
	  p_failure_description    IN VARCHAR2  ,
	  p_cause_code             IN VARCHAR2  ,
	  p_cause_description      IN VARCHAR2  ,
	  p_resolution_code        IN VARCHAR2  ,
	  p_resolution_description IN VARCHAR2  ,
	  p_effective_end_date     IN DATE      ,
	  p_combination_id         IN NUMBER    ,
	  p_stored_last_upd_date   IN DATE 	,
          p_created_by             IN NUMBER    ,
          p_creation_date          IN DATE      ,
          p_last_update_date       IN DATE      ,
          p_last_updated_by        IN NUMBER    ,
          p_last_update_login      IN NUMBER    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2,
          x_combination_id   OUT NOCOPY NUMBER
          );
/**************************************************************************
-- Start of comments
--	API name 	: Lock_Code_JSP
--	Type		: Private.
--	Function	: To lock a failure code row - called from OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create
--                            'U' for update
--                            'D' for delete
--                          code_type            IN NUMBER
--                          code                 IN VARCHAR2
--                          description          IN VARCHAR2
--                          effective_end_date   IN DATE
--                          stored_last_upd_date IN DATE
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Lock_Code_JSP
         (p_code_type         IN NUMBER  ,
          p_code              IN VARCHAR2,
          p_last_update_date     IN DATE    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Lock_Combination_JSP
--	Type		: Private.
--	Function	: To lock a failure code combinations row - called from
--                        OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_combination_id         IN NUMBER
--                        p_last_upd_date   IN DATE
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		          Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Lock_Combination_JSP
         (p_combination_id  IN NUMBER    ,
	  p_last_update_date   IN DATE 	 ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
          );
END EAM_FailureCodes_PVT;

 

/
