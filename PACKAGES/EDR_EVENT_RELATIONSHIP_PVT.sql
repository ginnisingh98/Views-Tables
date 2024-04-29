--------------------------------------------------------
--  DDL for Package EDR_EVENT_RELATIONSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_EVENT_RELATIONSHIP_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVRELS.pls 120.0.12000000.1 2007/01/18 05:56:42 appldev ship $*/

/* Global Constants */
G_PKG_NAME            CONSTANT            varchar2(30) := 'EDR_EVENT_RELATIONSHIP_PVT';

-- Start of comments
-- API name             : STORE_INTER_EVENT
-- Type                 : Private.
-- Function             : Validates the realtionship data in current session context
--                        then calls local API to store Relationship data to the databse
--                        in an autonomous manner.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_inter_event_tbl      IN INTER_EVENT_TBL_TYPE Required
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :Due to its autonomous nature this is a private api used by
--                        the ERES team to do internal processing only
--
-- End of comments

PROCEDURE STORE_INTER_EVENT
( p_api_version             IN                     NUMBER               ,
  p_init_msg_list           IN                     VARCHAR2
                                   default FND_API.G_FALSE		,
  x_return_status           OUT NOCOPY             VARCHAR2             ,
  x_msg_count               OUT NOCOPY             NUMBER               ,
  x_msg_data                OUT NOCOPY             VARCHAR2             ,
  p_inter_event_tbl         IN
                              EDR_EVENT_RELATIONSHIP_PUB.INTER_EVENT_TBL_TYPE
);

-- Bug 3667036: Start
-- Start of comments
-- API name             : ESTABLISH_RELATIONSHIP
-- Type                 : Private.
-- Function             : Create a relationship between the specified set of parent and child erecords
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : PARENT_CHILD_RECORD  IN  PARENT_CHILD_TBL: The table of parent-child erecord data
-- OUT                  : None
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments

PROCEDURE ESTABLISH_RELATIONSHIP
(
 PARENT_CHILD_RECORD IN PARENT_CHILD_TBL
);

-- Start of comments
-- API name             : VALIDATE_PARENT
-- Type                 : Private.
-- Function             : This API validated the parent e-record details.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_PARENT_EVENT_NAME IN VARCHAR2: The parent event name
--                      : P_PARENT_EVENT_KEY IN VARCHAR2: The parent event key
--                      : P_PARENT_ERECORD_ID IN NUMBER: The parent e-record ID
-- OUT                  : None
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments

PROCEDURE VALIDATE_PARENT(P_PARENT_EVENT_NAME IN VARCHAR2,
                          P_PARENT_EVENT_KEY  IN VARCHAR2,
                  				P_PARENT_ERECORD_ID IN NUMBER
                          );

-- Start of comments
-- API name             : VALIDATE_CHILDREN
-- Type                 : Private.
-- Function             : This API validated the child e-record ids used in inter event.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_CHILD_ERECORD_IDS IN FND_TABLE_OF_VARCHAR2_255: This holds the array of child e-record
--                                                                          ids.
--                        P_PARENT_EVENT_NAME IN VARCHAR2: This holds the parent event name.
-- OUT                  : None
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments
PROCEDURE VALIDATE_CHILDREN(P_CHILD_ERECORD_IDS IN FND_TABLE_OF_VARCHAR2_255,
                            P_PARENT_EVENT_NAME IN VARCHAR2
                           );


-- Bug 3667036: End


--Bug 4122622: Start
-- Start of comments
-- API name             : VALIDATE_CHILDREN
-- Type                 : Private.
-- Function             : This is a wrapper over the existing validate_children procedure.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_CHILD_ERECORD_IDS EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE: This holds the array of child e-record ids.
--                        P_PARENT_EVENT_NAME IN VARCHAR2: This holds the parent event name.
-- OUT                  : None
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments
PROCEDURE VALIDATE_CHILDREN(P_CHILD_ERECORD_IDS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE,
                            P_PARENT_EVENT_NAME IN VARCHAR2);
--Bug 4122622: End


end EDR_EVENT_RELATIONSHIP_PVT;

 

/
