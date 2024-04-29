--------------------------------------------------------
--  DDL for Package EAM_FAILURESETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FAILURESETS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVFSPS.pls 120.0 2006/03/08 07:15:39 sshahid noship $ */
/**************************************************************************
-- Start of comments
--	API name 	: Setup_FailureSet
--	Type		: Private.
--	Function	: Create/Update Failure Set with failure set
--                        information passed to this API.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_validation_level IN NUMBER
--                               Default = FND_API.G_VALID_LEVEL_FULL
--                        p_mode             IN VARCHAR2 Required
--                           Possible Values  for p_mode
--                            'C' for create failure set
--                            'U' for update failure set
--                        p_failure_set_rec  IN
--                            EAM_FailureSets_PUB.eam_failureset_rec_type
--                        Within p_failure_set_rec, set_name column
--                        is 'Required' while calling this API in create mode
--                        and either set_name or set_id should have a value
--                        in update mode..
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id    OUT  NUMBER
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_FailureSet
         (p_api_version      IN  NUMBER                                     ,
          p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL     ,
          p_mode             IN  VARCHAR2                                   ,
          p_failureset_rec   IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
          x_return_status    OUT NOCOPY VARCHAR2                            ,
          x_msg_count        OUT NOCOPY NUMBER                              ,
          x_msg_data         OUT NOCOPY VARCHAR2                            ,
          x_failureset_id    OUT NOCOPY NUMBER
         );

/**************************************************************************
-- Start of comments
--	API name 	: Setup_SetAssociation
--	Type		: Private.
--	Function	: Create/Update/Delete association of Failure Set
--                        with Asset Group/Rebuildable
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
--                            'C' for create association
--                            'U' for update association
--                            'D' for delete association
--                        p_set_association_rec  IN
                            EAM_FailureSets_PUB.eam_set_association_rec_type
--                        Within p_set_association_rec,either set id or
--                        set_name column should have a value and
--                        inventory_item_id is 'Required'.
--                        is 'Required' while calling this API.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_SetAssociation
    (p_api_version      IN  NUMBER                                          ,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                     ,
     p_commit           IN  VARCHAR2 := FND_API.G_FALSE                     ,
     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL          ,
     p_mode             IN  VARCHAR2                                        ,
     p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
     x_return_status    OUT NOCOPY VARCHAR2                                 ,
     x_msg_count        OUT NOCOPY NUMBER                                   ,
     x_msg_data         OUT NOCOPY VARCHAR2
    );

/**************************************************************************
-- Start of comments
--	API name 	: Setup_FailureSet_JSP
--	Type		: Private.
--	Function	: Wrapper to call Setup_FailureSet() from OA Fwk.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:   p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create failure set
--                            'U' for update failure set
--                    p_set_name             VARCHAR2
--                    p_description          VARCHAR2
--                    p_effective_end_date   DATE
--                    p_set_id               NUMBER
--                    p_stored_last_upd_date DATE
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                        x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id    OUT  NUMBER
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_FailureSet_JSP
         (p_mode                 IN  VARCHAR2   ,
          p_set_name             IN  VARCHAR2   ,
          p_description          IN  VARCHAR2   ,
          p_effective_end_date   IN DATE        ,
          p_set_id               IN NUMBER      ,
          p_stored_last_upd_date IN DATE        ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2,
          x_failureset_id    OUT NOCOPY NUMBER
         );

/**************************************************************************
-- Start of comments
--	API name 	: Setup_SetAssociation_JSP
--	Type		: Private.
--	Function	: Wrapper call to Setup_SetAssociation from OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:  p_mode             IN VARCHAR2 Required
--                         Possible Values  for p_mode
--                            'C' for create association
--                            'U' for update association
--                            'D' for delete association
--			   p_set_id                NUMBER
--                         p_set_name              VARCHAR2(80)
--                         p_inventory_item_id     NUMBER
--                         p_failure_code_required VARCHAR2(1)
--                         p_effective_end_date    DATE
--                         p_stored_last_upd_date  DATE
--	OUT		:  x_return_status    OUT  VARCHAR2(1)
--                         x_msg_count        OUT  NUMBER
--			   x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Setup_SetAssociation_JSP
    (p_mode                   IN  VARCHAR2 ,
     p_set_id                 IN NUMBER    ,
     p_set_name               IN VARCHAR2  ,
     p_inventory_item_id      IN NUMBER    ,
     p_failure_code_required  IN VARCHAR2  ,
     p_effective_end_date     IN DATE      ,
     p_stored_last_upd_date   IN DATE      ,
     p_created_by             IN NUMBER    ,
     p_creation_date          IN DATE      ,
     p_last_update_date       IN DATE      ,
     p_last_updated_by        IN NUMBER    ,
     p_last_update_login      IN NUMBER    ,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER  ,
     x_msg_data         OUT NOCOPY VARCHAR2
    );

/**************************************************************************
-- Start of comments
--	API name 	: Lock_SetAssociation_JSP
--	Type		: Private.
--	Function	: To lock a failure set association row - called from
--                        OA Fwk
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:  p_set_id		IN	NUMBER,
--			   p_item_id		IN	NUMBER
--                         p_last_update_date	IN	DATE
--	OUT		:  x_return_status    OUT  VARCHAR2(1)
--                         x_msg_count        OUT  NUMBER
--			   x_msg_data         OUT  VARCHAR2(2000)
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Lock_SetAssociation_JSP
    (p_set_id		IN	NUMBER,
     p_item_id		IN	NUMBER,
     p_last_update_date	IN	DATE  ,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER  ,
     x_msg_data         OUT NOCOPY VARCHAR2
     );

END EAM_FailureSets_PVT;

 

/
