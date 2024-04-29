--------------------------------------------------------
--  DDL for Package DOM_WS_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_WS_INTERFACE_PUB" AUTHID CURRENT_USER AS
/*$Header: DOMPITFS.pls 120.6 2006/07/03 16:07:06 ysireesh noship $ */

----------------------------------------------------------------------------
-- 1. Add_OFO_Group_Member
----------------------------------------------------------------------------
PROCEDURE Add_OFO_Group_Member (
   p_api_version  IN  NUMBER,
   p_init_msg_list  IN  VARCHAR2,
   p_commit   IN  VARCHAR2,
   p_group_id       IN  NUMBER,
   p_member_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count    OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2
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
    --     IN    : p_api_version    IN  NUMBER  (required)
    --      API Version of this procedure
    --             p_init_msg_level IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the message stack needs to be cleared
    --             p_commit   IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the data should be committed
    --             p_group_id   IN  NUMBER  (required)
    --      Group to which the member is being added
    --      Eg., A Group
    --             p_member_id  IN  VARCHAR2  (required)
    --      Member which is to be added
    --      Eg., PERSON
    --
    --     OUT   : x_return_status  OUT  NUMBER
    --      Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count    OUT  NUMBER
    --      number of messages in the message list
    --             x_msg_data   OUT  VARCHAR2
    --        if number of messages is 1, then this parameter
    --      contains the message itself
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



procedure Update_Files_Document_Status (
   p_api_version        IN  NUMBER,
   p_service_url        IN  VARCHAR2,
   p_document_id        IN  NUMBER,
   p_status             IN  VARCHAR2,
   p_login_user_name    IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Update_Files_Document_Status
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update_Files_Document_Status
    --
    --
    -- Parameters:
    --     IN    : p_api_version    IN  NUMBER  (required)
    --      API Version of this procedure
    --      p_service_url   IN  VARCHAR2  (required)
    --        Service url of the repository
    --        Eg., 'http://stadm65.us.oracle.com/content/ws'
    --      p_document_id IN  NUMBER  (required)
    --        document id of the reposotiry. It is the dm_document_id from fnd_documents table.
    --      p_status
    --        the lookup code for the Approval/Reject status
    --        Eg., APPROVED, REJECTED
    --      p_login_user_name
    --        Login user to connect to files repository
    --
    --     OUT   : x_return_status  OUT  NUMBER
    --      Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count    OUT  NUMBER
    --      number of messages in the message list
    --             x_msg_data   OUT  VARCHAR2
    --        if number of messages is 1, then this parameter
    --      contains the message itself
    --
    -- Called From:
    --    DOM_ATTACHMENT_UTIL_PKG.Change_Status
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

procedure Grant_Attachments_OCSRole (
   p_api_version      IN  NUMBER,
   p_service_url        IN  VARCHAR2,
   p_family_id        IN  NUMBER,
   p_role             IN  VARCHAR2,
   p_user_name          IN  VARCHAR2,
   p_user_login         IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   ) ;

procedure Remove_Attachments_OCSRole (
   p_api_version      IN  NUMBER,
   p_service_url        IN  VARCHAR2,
   p_family_id        IN  NUMBER,
   p_role             IN  VARCHAR2,
   p_user_name          IN  VARCHAR2,
   p_user_login         IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   ) ;


END DOM_WS_INTERFACE_PUB;

 

/
