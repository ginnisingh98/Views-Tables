--------------------------------------------------------
--  DDL for Package EGO_GROUP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_GROUP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOPGWFS.pls 115.3 2003/09/19 10:53:35 srajapar noship $ */

 TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------
-- 1. Start_Add_Group_Member_Process
----------------------------------------------------------------------------
  PROCEDURE Start_Add_Group_Member_Process
  (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  );

    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Start_Add_Group_Member_Process
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Starts the workflow process to Add Group Member.
    --
    -- Parameters:
    --     IN    : p_group_id           IN  NUMBER   (Required)
    --             Group Id
    --
    --     IN    : p_group_name         IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_member_id          IN  NUMBER   (Required)
    --             Member Id
    --
    --     IN    : p_member_name        IN  VARCHAR2 (Required)
    --             Member Name
    --             used to set the Workflow item attribute
    --     IN    : p_name_value_pairs   IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by : Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             EGOGROUP workflow item type
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 2. Start_Rem_Group_Member_Process
----------------------------------------------------------------------------

  PROCEDURE Start_Rem_Group_Member_Process
  (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Start_Rem_Group_Member_Process
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Starts the workflow process to Remove Group Member.
    --
    -- Parameters:
    --     IN    : p_group_id           IN  NUMBER   (Required)
    --             Group Id
    --
    --     IN    : p_group_name         IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_member_id          IN  NUMBER   (Required)
    --             Member Id
    --
    --     IN    : p_member_name        IN  VARCHAR2 (Required)
    --             Member Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_name_value_pairs   IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by : Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             EGOGROUP workflow item type
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 4. Start_Delete_Group_Process
----------------------------------------------------------------------------
  PROCEDURE Start_Delete_Group_Process
  (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  );

    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Start_Delete_Group_Process
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Starts the workflow process to Delete Group.
    --
    --
    -- Parameters:
    --     IN    : p_group_id      IN  NUMBER   (Required)
    --             Group Id
    --
    --     IN    : p_group_name    IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_name_value_pairs         IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by :
    --             IPD_DM_FND_PUB.Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             IPDGROUP workflow item type
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 5. Start_Unsub_Owner_Notf_Process
----------------------------------------------------------------------------
  PROCEDURE Start_Unsub_Owner_Notf_Process
  (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
   );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Start_Unsub_Owner_Notf_Process
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Starts the workflow process to Remove Group Member.
    --
    --
    -- Parameters:
    --     IN    : p_group_id      IN  NUMBER   (Required)
    --             Group Id
    --
    --     IN    : p_group_name    IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_member_id        IN  NUMBER   (Required)
    --             Member Id
    --
    --     IN    : p_member_name    IN  VARCHAR2 (Required)
    --             Member Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_name_value_pairs         IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by :
    --             IPD_DM_FND_PUB.Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             IPDGROUP workflow item type
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 6. Start_Subsc_Owner_Notf_Process
----------------------------------------------------------------------------
  PROCEDURE Start_Subsc_Owner_Notf_Process
  (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
   );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Start_Subsc_Owner_Notf_Process
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Starts the workflow process to Remove Group Member.
    --
    --
    -- Parameters:
    --     IN    : p_group_id      IN  NUMBER   (Required)
    --             Group Id
    --
    --     IN    : p_group_name    IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_member_id        IN  NUMBER   (Required)
    --             Member Id
    --
    --     IN    : p_member_name    IN  VARCHAR2 (Required)
    --             Member Name
    --             used to set the Workflow item attribute
    --
    --     IN    : p_name_value_pairs         IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by :
    --             IPD_DM_FND_PUB.Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             IPDGROUP workflow item type
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 7. Add_Group_Member
----------------------------------------------------------------------------
  PROCEDURE Add_Group_Member
  (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Adds the group member (called after 'Approval' from
    --             the owner of the group)
    --
    -- Parameters:
    --     IN    : p_item_type      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : p_item_key      IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : p_actid      IN  NUMBER (Required)
    --             action
    --
    --     IN    : p_funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :
    --             x_result OUT VARCHAR2
    --             Status of  the workflow activity.
    --             x_result can be 'COMPLETE','WAITING','ERROR','NOTIFIED','SUSPENDED','DEFERRED' .
    --
    --
    -- called from:
    --     Workflow - ADD_GROUP_MEMBER function
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 8. Remove_Group_Member
----------------------------------------------------------------------------
  PROCEDURE Remove_Group_Member
  (
    p_item_type IN VARCHAR2,
    p_item_key  IN VARCHAR2,
    p_actid     IN NUMBER,
    p_funcmode  IN VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Remove_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Removes the group member (called after 'Approval' from
    --             the owner of the group)
    --
    --
    -- Parameters:
    --     IN    : p_item_type      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : p_item_key      IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : p_actid      IN  NUMBER (Required)
    --             action
    --
    --     IN    : p_funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :
    --             x_result OUT VARCHAR2
    --             Status of  the workflow activity.
    --             x_result can be 'COMPLETE','WAITING','ERROR','NOTIFIED','SUSPENDED','DEFERRED' .
    --
    --
    -- called from:
    --     Workflow - REMOVE_GROUP_MEMBER function
    --
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 9. Delete_Group
----------------------------------------------------------------------------
  PROCEDURE Delete_Group
  (
    p_item_type IN VARCHAR2,
    p_item_key  IN VARCHAR2,
    p_actid     IN NUMBER,
    p_funcmode  IN VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Delete_Group
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Deletes a group
    --
    --
    -- Parameters:
    --     IN    : p_item_type      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : p_item_key      IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : p_actid      IN  NUMBER (Required)
    --             action
    --
    --     IN    : p_funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :
    --             x_result OUT VARCHAR2
    --             Status of  the workflow activity.
    --             x_result can be 'COMPLETE','WAITING','ERROR','NOTIFIED','SUSPENDED','DEFERRED' .
    --
    --
    -- called from:
    --     Workflow - DELETE_GROUP function
    --
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 10. Group_Del_Ntf_All_Members
----------------------------------------------------------------------------
PROCEDURE Group_Del_Ntf_All_Members
(
  p_item_type IN VARCHAR2,
  p_item_key  IN VARCHAR2,
  p_actid     IN NUMBER,
  p_funcmode  IN VARCHAR2,
  x_result    OUT NOCOPY VARCHAR2
);
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Group_Del_Ntf_All_Members
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Notifies all members of a group
    --
    --
    --
    -- Parameters:
    --     IN    : p_item_type      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : p_item_key      IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : p_actid      IN  NUMBER (Required)
    --             action
    --
    --     IN    : p_funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :
    --             x_result OUT VARCHAR2
    --             Status of  the workflow activity.
    --             x_result can be 'COMPLETE','WAITING','ERROR','NOTIFIED','SUSPENDED','DEFERRED' .
    --
    --
    -- called from:
    --     Workflow - GROUP_DEL_NTF_ALL_MEMBERS function
    --
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 11. Add_GrpMem_Approval_Req_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Approval_Req_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_GrpMem_Approval_Req_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      22-JUL-2002  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 12. Add_GrpMem_Reject_Msg_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Reject_Msg_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_GrpMem_Reject_Msg_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 13. Add_GrpMem_Approval_Msg_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Approval_Msg_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_GrpMem_Approval_Msg_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 14. Unsub_Member_Owner_FYI_Doc
----------------------------------------------------------------------------
  PROCEDURE Unsub_Member_Owner_FYI_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Unsub_Member_Owner_FYI_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 15. Unsub_Member_Conf_Mem_Doc
----------------------------------------------------------------------------
  PROCEDURE Unsub_Member_Conf_Mem_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );

    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Unsub_Member_Conf_Mem_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 16. Del_Grp_Admin_Notif_Doc
----------------------------------------------------------------------------
  PROCEDURE Del_Grp_Admin_Notif_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Del_Grp_Admin_Notif_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 17. Del_Grp_Mem_Notif_Doc
----------------------------------------------------------------------------
  PROCEDURE Del_Grp_Mem_Notif_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Del_Grp_Mem_Notif_Doc
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Prepares Message Document
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    --
    -- Parameters:
    --     IN    : document_id      IN  VARCHAR2 (Required)
    --             document id
    --
    --     IN    : display_type     IN  VARCHAR2 (Required)
    --             display type is either 'text/html' or 'text/plain'
    --
    --     OUT   :
    --           : document          IN  VARCHAR2 (Required)
    --
    --           : document_type      IN  VARCHAR2 (Required)
    --            document type is either 'text/html' or 'text/plain'
    --
    -- called from:
    --     Workflow - SUBSCRIPTION_REQUEST function
    --
    -- HISTORY
    --      01-SEP-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 18. Get_Responder_Name
----------------------------------------------------------------------------
  PROCEDURE Get_Responder_name
  (itemtype    IN  VARCHAR2  ,
   itemkey     IN  VARCHAR2  ,
   actid       IN  NUMBER   ,
   funcmode    IN  VARCHAR2  ,
   resultout   OUT NOCOPY VARCHAR2
  );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Get_Responder_name
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Get the responder's name and store the same in
    --             WF Attribute
    --
    -- Parameters:
    --     IN    : itemtype      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : itemkey       IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : actid         IN  NUMBER (Required)
    --             action
    --
    --     IN    : funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :  resultout     OUT VARCHAR2
    --             Status of  the workflow activity.
    --
    --
    -- called from:
    --     Workflow - processes
    --
    -- HISTORY
    --      13-FEB-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  : Created as a part of BUG 3096076
    --
    -- END OF comments
    ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 19. Create_Grp_Admin_WF_Role
----------------------------------------------------------------------------
  PROCEDURE create_grp_admin_wf_role
      (itemtype    IN  VARCHAR2  ,
       itemkey     IN  VARCHAR2  ,
       actid	   IN  NUMBER   ,
       funcmode    IN  VARCHAR2  ,
       resultout   OUT NOCOPY VARCHAR2
       );
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : create_wf_role
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Crates a dynamic role of the group administrators
    --
    -- Parameters:
    --     IN    : itemtype      IN  VARCHAR2 (Required)
    --             Item type of the workflow
    --
    --     IN    : itemkey       IN  VARCHAR2 (Required)
    --             Item key of the workflow
    --
    --     IN    : actid         IN  NUMBER (Required)
    --             action
    --
    --     IN    : funcmode      IN  VARCHAR2 (Required)
    --             function mode
    --
    --     OUT  :  resultout     OUT VARCHAR2
    --             Status of  the workflow activity.
    --
    --
    -- called from:
    --     Workflow - processes
    --
    -- HISTORY
    --      13-FEB-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

END EGO_GROUP_WF_PKG;

 

/
