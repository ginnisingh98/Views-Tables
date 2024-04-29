--------------------------------------------------------
--  DDL for Package IEC_SUBSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SUBSET_PVT" AUTHID CURRENT_USER AS
/* $Header: IECOCSBS.pls 115.13 2003/09/09 23:14:57 alromero noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : DROP_TARGET_GROUP_VIEWS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : For each subset in the specified target group,
--                drop the subset view.
--
--  Parameters  : P_SOURCE_ID            IN     NUMBER                       Required
--                P_TARGET_GROUP_ID      IN     NUMBER                       Required
--                X_RETURN_CODE             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE DROP_TARGET_GROUP_VIEWS
   ( P_SOURCE_ID             IN            NUMBER
   , P_TARGET_GROUP_ID       IN            NUMBER
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : GET_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Returns the subset view name after verifying that the view
--                exists, creating the view if necessary.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_TARGET_GROUP_ID          IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                P_DEFAULT_SUBSET_FLAG      IN     VARCHAR2                     Required
--                P_SOURCE_TYPE_VIEW_NAME    IN     VARCHAR2                     Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
FUNCTION GET_SUBSET_VIEW
   ( P_SOURCE_ID                IN            NUMBER
   , P_TARGET_GROUP_ID          IN            NUMBER
   , P_SUBSET_ID                IN            NUMBER
   , P_DEFAULT_SUBSET_FLAG      IN            VARCHAR2
   , P_SOURCE_TYPE_VIEW_NAME    IN            VARCHAR2
   , X_RETURN_CODE                 OUT NOCOPY VARCHAR2
   )
RETURN VARCHAR2;

-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : CREATE_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Creates a view for the specified subset using
--                the view name provided.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                P_VIEW_NAME                IN     VARCHAR2                     Required
--                P_TARGET_GROUP_ID          IN     NUMBER                       Required
--                P_SOURCE_TYPE_VIEW_NAME    IN     VARCHAR2                     Required
--                P_DEFAULT_SUBSET_FLAG      IN     VARCHAR2                     Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CREATE_SUBSET_VIEW
   ( P_SOURCE_ID             IN            NUMBER
   , P_SUBSET_ID             IN            NUMBER
   , P_VIEW_NAME             IN            VARCHAR2
   , P_TARGET_GROUP_ID       IN            NUMBER
   , P_SOURCE_TYPE_VIEW_NAME IN            VARCHAR2
   , P_DEFAULT_SUBSET_FLAG   IN            VARCHAR2
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : DROP_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Drops the view defined for the specified subset.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE DROP_SUBSET_VIEW
   ( P_SOURCE_ID             IN             NUMBER
   , P_SUBSET_ID             IN             NUMBER
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECREATE_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Recreates the subset view, deleting it first if necessary.
--
--  Parameters  : P_SOURCE_ID           IN            NUMBER   Required
--                P_TARGET_GROUP_ID     IN            NUMBER   Required
--                P_SUBSET_ID           IN            NUMBER   Required
--                X_SUBSET_VIEW_NAME       OUT NOCOPY VARCHAR2 Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE RECREATE_SUBSET_VIEW
   ( P_SOURCE_ID                IN            NUMBER
   , P_TARGET_GROUP_ID          IN            NUMBER
   , P_SUBSET_ID                IN            NUMBER
   , X_SUBSET_VIEW_NAME            OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CREATE_SUBSET_RT_INFO
--  Type        : Public
--  Pre-reqs    : None
--  Function    : If the subset runtime information entries do not
--                already exist, create them.
--
--  Parameters  : P_SUBSET_ID      IN     NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CREATE_SUBSET_RT_INFO
   ( P_SUBSET_ID            IN            NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : SUBSET_TRANSITION
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_SERVER_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER                       Required
--                P_FROM_SUBSETS       IN     NUMBER_TBL_TYPE              Required
--                P_INTO_SUBSETS       IN     NUMBER_TBL_TYPE              Required
--                P_ACTION_TYPE        IN     VARCHAR2                     Required
--                X_NUM_PENDING           OUT NUMBER                       Required
--                X_ACTION_ID             OUT NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE SUBSET_TRANSITION
   ( P_SOURCE_ID          IN            NUMBER
   , P_SERVER_ID          IN            NUMBER
   , P_CAMPAIGN_ID        IN            NUMBER
   , P_SCHEDULE_ID        IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , P_FROM_SUBSETS       IN            SYSTEM.NUMBER_TBL_TYPE
   , P_INTO_SUBSETS       IN            SYSTEM.NUMBER_TBL_TYPE
   , P_ACTION_TYPE        IN            VARCHAR2
   , X_NUM_PENDING           OUT NOCOPY NUMBER
   , X_ACTION_ID             OUT NOCOPY NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CONTINUAL_TRANSITION
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER                       Required
--                X_NUM_REMAINING         OUT NUMBER                       Required
--                X_ACTION_ID             OUT NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CONTINUAL_TRANSITION
   ( P_SOURCE_ID          IN            NUMBER
   , P_CAMPAIGN_ID        IN            NUMBER
   , P_SCHEDULE_ID        IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , X_NUM_REMAINING         OUT NOCOPY NUMBER
   , X_ACTION_ID             OUT NOCOPY NUMBER
   );

END IEC_SUBSET_PVT;

 

/
