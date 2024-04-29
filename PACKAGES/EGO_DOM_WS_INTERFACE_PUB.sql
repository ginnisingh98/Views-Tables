--------------------------------------------------------
--  DDL for Package EGO_DOM_WS_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DOM_WS_INTERFACE_PUB" AUTHID CURRENT_USER AS
/*$Header: EGOPITFS.pls 120.0 2005/07/11 23:02:46 dedatta noship $ */

----------------------------------------------------------------------------
-- 1. Add_OFO_Group_Member
----------------------------------------------------------------------------
PROCEDURE Add_OFO_Group_Member (
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2,
   p_commit		IN	VARCHAR2,
   p_group_id      	IN	NUMBER,
   p_member_id      	IN	NUMBER,
   x_return_status	OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT	NOCOPY NUMBER,
   x_msg_data		OUT	NOCOPY VARCHAR2
   );
   ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_OFO_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Add a member to the corresponding OFO Group.
    --
    --
    -- Parameters:
    --     IN    : p_api_version		IN  NUMBER	(required)
    --			API Version of this procedure
    --             p_init_msg_level	IN  VARCHAR2	(optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the message stack needs to be cleared
    --             p_commit		IN  VARCHAR2	(optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the data should be committed
    --             p_group_id		IN  NUMBER	(required)
    --			Group to which the member is being added
    --			Eg., A Group
    --             p_member_id	IN  VARCHAR2	(required)
    --			Member which is to be added
    --			Eg., PERSON
    --
    --     OUT   : x_return_status	OUT  NUMBER
    --			Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count		OUT  NUMBER
    --			number of messages in the message list
    --             x_msg_data		OUT  VARCHAR2
    --			  if number of messages is 1, then this parameter
    --			contains the message itself
    --
    -- Called From:
    --    ego_party_pub.add_group_member
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
   ------------------------------------------------------------------------


END EGO_DOM_WS_INTERFACE_PUB;

 

/
