--------------------------------------------------------
--  DDL for Package AP_PARTYMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PARTYMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: apgsmrgs.pls 120.0 2005/07/29 22:59:57 atsingh noship $ */

-- Start of comments
--    API name 	   : Veto_PartySiteMerge
--    Type	   : Group.
--    Function	   :
--    Pre-reqs	   : None.
--    Parameters   :
--	IN	   :
--
--
--
--
--
--
--		     parameter1
--		     parameter2
--				.
--				.
--	OUT	   : x_return_status	 OUT    VARCHAR2(1)
--
--	             parameter1
--		     parameter2
--				.
--				.
--	Version	   : Current version	1.0
--				Changed....
--			  previous version	1.0
--				Changed....
--			  .
--			  .
--			  previous version	1.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--      Status complete except for comments in the spec.
-- End of comments

Procedure Veto_PartySiteMerge (
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    );


-- Start of comments
--    API name 	   : Veto_PartyMerge
--    Type	   : Group.
--    Function	   :
--    Pre-reqs	   : None.
--    Parameters   :
--	IN	   :
--
--
--
--
--
--
--		     parameter1
--		     parameter2
--				.
--				.
--	OUT	   : x_return_status	 OUT    VARCHAR2(1)
--
--	             parameter1
--		     parameter2
--				.
--				.
--	Version	   : Current version	1.0
--				Changed....
--			  previous version	1.0
--				Changed....
--			  .
--			  .
--			  previous version	1.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--      Status complete except for comments in the spec.
-- End of comments


Procedure Veto_PartyMerge (
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    );


-- Start of comments
--    API name     : Update_PerPartyid
--    Type         : Group.
--    Function     :
--    Pre-reqs     : None.
--    Parameters   :
--      IN         :
--
--
--
--
--
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      OUT        : x_return_status     OUT    VARCHAR2(1)
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      Version    : Current version    1.0
--                              Changed....
--                        previous version      1.0
--                              Changed....
--                        .
--                        .
--                        previous version      1.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments

Procedure Update_PerPartyid(
             p_Entity_name        IN     VARCHAR2,
             p_from_id            IN     NUMBER,
             p_to_id              IN     NUMBER,
             p_From_Fk_id         IN     NUMBER,
             p_To_Fk_id           IN     NUMBER,
             p_Parent_Entity_name IN     VARCHAR2,
             p_batch_id           IN     NUMBER,
             p_Batch_Party_id     IN     NUMBER,
             x_return_status      IN OUT NOCOPY VARCHAR2  );


-- Start of comments
--    API name     : Update_RelPartyid
--    Type         : Group.
--    Function     :
--    Pre-reqs     : None.
--    Parameters   :
--      IN         :
--
--
--
--
--
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      OUT        : x_return_status     OUT    VARCHAR2(1)
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      Version    : Current version    1.0
--                              Changed....
--                        previous version      1.0
--                              Changed....
--                        .
--                        .
--                        previous version      1.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments

Procedure Update_RelPartyid(
             p_Entity_name        IN     VARCHAR2,
             p_from_id            IN     NUMBER,
             p_to_id              IN     NUMBER,
             p_From_Fk_id         IN     NUMBER,
             p_To_Fk_id           IN     NUMBER,
             p_Parent_Entity_name IN     VARCHAR2,
             p_batch_id           IN     NUMBER,
             p_Batch_Party_id     IN     NUMBER,
             x_return_status      IN OUT NOCOPY VARCHAR2  );


-- Start of comments
--    API name     : Update_PartySiteid
--    Type         : Group.
--    Function     :
--    Pre-reqs     : None.
--    Parameters   :
--      IN         :
--
--
--
--
--
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      OUT        : x_return_status     OUT    VARCHAR2(1)
--
--                   parameter1
--                   parameter2
--                              .
--                              .
--      Version    : Current version    1.0
--                              Changed....
--                        previous version      1.0
--                              Changed....
--                        .
--                        .
--                        previous version      1.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments

Procedure Update_PartySiteid(
             p_Entity_name        IN     VARCHAR2,
             p_from_id            IN     NUMBER,
             p_to_id              IN     NUMBER,
             p_From_Fk_id         IN     NUMBER,
             p_To_Fk_id           IN     NUMBER,
             p_Parent_Entity_name IN     VARCHAR2,
             p_batch_id           IN     NUMBER,
             p_Batch_Party_id     IN     NUMBER,
             x_return_status      IN OUT NOCOPY VARCHAR2  );

END;


 

/
