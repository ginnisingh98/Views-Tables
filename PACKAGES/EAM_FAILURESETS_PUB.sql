--------------------------------------------------------
--  DDL for Package EAM_FAILURESETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FAILURESETS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPFSPS.pls 120.0 2006/03/08 07:20:14 sshahid noship $ */
TYPE eam_failureset_rec_type IS RECORD
                                (set_name             VARCHAR2(80)  ,
                                 description          VARCHAR2(240) ,
                                 effective_end_date   DATE          ,
                                 set_id               NUMBER        ,
                                 stored_last_upd_date DATE);

TYPE eam_set_association_rec_type IS RECORD
                                (set_id                NUMBER        ,
                                 set_name              VARCHAR2(80)  ,
                                 inventory_item_id     NUMBER        ,
                                 failure_code_required VARCHAR2(1)   ,
                                 effective_end_date    DATE          ,
                                 stored_last_upd_date  DATE          ,
                                 created_by             NUMBER       ,
                                 creation_date          DATE         ,
                                 last_update_date       DATE         ,
                                 last_updated_by        NUMBER       ,
                                 last_update_login      NUMBER);

/**************************************************************************
-- Start of comments
--	API name 	: Create_FailureSet
--	Type		: Public.
--	Function	: Create Failure Set with failure set
--                        information passed to this API.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                       Default = FND_API.G_FALSE
--                  p_failureset_rec   IN
--                          EAM_FailureSets_PUB.eam_failureset_rec_type
--                  Within p_failure_set_rec, set_name column
--                  is 'Required'
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                  x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Create_FailureSet
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failureset_rec  IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2                            ,
          x_failureset_id   OUT NOCOPY NUMBER
         );

/**************************************************************************
-- Start of comments
--	API name 	: Update_FailureSet
--	Type		: Public.
--	Function	: Update Failure Set with failure set
--                        information passed to this API.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                          Default = FND_API.G_FALSE
--                  p_failureset_rec   IN
--                          EAM_FailureSets_PUB.eam_failureset_rec_type
--                  Within p_failure_set_rec, either set_name or
--                  set_id should have a value in update mode.
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                  x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id    OUT  NUMBER
--	Version	: Current version	1.0.
--		        Initial version 1.0
-- End of comments
***************************************************************************/
PROCEDURE Update_FailureSet
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_failureset_rec  IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2                            ,
          x_failureset_id   OUT NOCOPY NUMBER
         );
/**************************************************************************
-- Start of comments
--	API name 	: Create_Association
--	Type		: Public.
--	Function	: Create Failure Set association with asset group/
                          rebuildable
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                  p_association_rec  IN
--                          EAM_FailureSets_PUB.eam_set_association_rec_type
--                  Within p_association_rec, set_id or set_name column
--                  is 'Required' and inventory_item_id (of the asset group
--                  or rebuildable item) is 'Required'
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                  x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Create_Association
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_association_rec IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Update_Association
--	Type		: Public.
--	Function	: Update Failure Set association with asset group/
                          rebuildable - failure required flag
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                  p_association_rec  IN
--                          EAM_FailureSets_PUB.eam_set_association_rec_type
--                  Within p_association_rec, set_id or set_name column
--                  is 'Required' and inventory_item_id (of the asset group
--                  or rebuildable item) is 'Required'
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                  x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Update_Association
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_association_rec IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
/**************************************************************************
-- Start of comments
--	API name 	: Delete_Association
--	Type		: Public.
--	Function	: Delete Failure Set association with asset group/
                          rebuildable
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                  p_association_rec  IN
--                          EAM_FailureSets_PUB.eam_set_association_rec_type
--                  Within p_association_rec, set_id or set_name column
--                  is 'Required' and inventory_item_id (of the asset group
--                  or rebuildable item) is 'Required'
--	OUT		: x_return_status    OUT  VARCHAR2(1)
--                  x_msg_count        OUT  NUMBER
--			  x_msg_data         OUT  VARCHAR2(2000)
--			  x_failureset_id   OUT  NUMBER
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/
PROCEDURE Delete_Association
         (p_api_version     IN  NUMBER                                     ,
          p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit          IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
          x_return_status   OUT NOCOPY VARCHAR2                            ,
          x_msg_count       OUT NOCOPY NUMBER                              ,
          x_msg_data        OUT NOCOPY VARCHAR2
         );
END EAM_FailureSets_PUB;

 

/
