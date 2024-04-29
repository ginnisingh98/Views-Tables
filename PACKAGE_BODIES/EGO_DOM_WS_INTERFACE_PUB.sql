--------------------------------------------------------
--  DDL for Package Body EGO_DOM_WS_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DOM_WS_INTERFACE_PUB" AS
/*$Header: EGOPITFB.pls 120.2 2005/10/25 09:26:56 dedatta noship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------
   G_PKG_NAME                CONSTANT  VARCHAR2(30) := 'EGO_DOM_WS_INTERFACE_PUB';
   G_CURRENT_USER_ID                   NUMBER       :=  FND_GLOBAL.USER_ID;
   G_CURRENT_LOGIN_ID                  NUMBER       :=  FND_GLOBAL.LOGIN_ID;

-- ---------------------------------------------------------------------
   -- For debugging purposes.
   PROCEDURE mdebug (msg IN varchar2) IS
     BEGIN
       --dd_debug('EGO_DOM_WS_INTERFACE_PUB ' || msg);
       null;
     END mdebug;
-- ---------------------------------------------------------------------

----------------------------------------------------------------------------
-- A. Add_OFO_Group_Member
----------------------------------------------------------------------------

procedure Add_OFO_Group_Member (
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2,
   p_commit		IN	VARCHAR2,
   p_group_id      	IN	NUMBER,
   p_member_id      	IN	NUMBER,
   x_return_status	OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT	NOCOPY NUMBER,
   x_msg_data		OUT	NOCOPY VARCHAR2
   ) IS
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

  l_api_name VARCHAR2(20) := 'Add_OFO_Group_Member';
  p_return_status VARCHAR2(20) ;
  p_msg_count NUMBER;
  p_msg_data VARCHAR2(3000);
  BEGIN
    --
    --
    mdebug('  ADD_OFO_GROUP_MEMBER:  Tracing....' );
    -- Standard Start of API savepoint
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

        EXECUTE IMMEDIATE      'BEGIN DOM_WS_INTERFACE_PUB.Add_OFO_Group_Member( :1,:2,:3,:4,:5,:6,:7,:8); END; '
	USING IN p_api_version,
              IN p_init_msg_list ,
              IN p_commit,
              IN p_group_id,
              IN p_member_id,
              OUT p_return_status,
              OUT p_msg_count,
              OUT p_msg_data;


      x_return_status := FND_API.G_RET_STS_SUCCESS;

      mdebug('  ADD_OFO_GROUP_MEMBER:  Tracing....' || x_return_status);
      FND_MSG_PUB.Count_And_Get
        (  	p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
      EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 mdebug('. Add_OFO_Group_Member :  Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  	p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF 	FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                        (	G_PKG_NAME,
                            l_api_name
                    );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (  	p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );
            mdebug ( 'Add_OFO_Group_Member ' || SQLERRM);
END Add_OFO_Group_Member;

END EGO_DOM_WS_INTERFACE_PUB;

/
