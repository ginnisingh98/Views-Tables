--------------------------------------------------------
--  DDL for Package IBC_CITEM_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_WORKFLOW_PVT" AUTHID CURRENT_USER as
/* $Header: ibcciwfs.pls 120.3 2005/10/20 12:27:11 appldev ship $ */
 /*#
   * This is the private API for OCM Content Item Worklow functionality.
   * Some of these methods are exposed as Java APIs in ApprovalManager.class
   * @rep:scope private
   * @rep:product IBC
   * @rep:displayname Oracle Content Manager Content Item Workflow API
   * @rep:category BUSINESS_ENTITY IBC_CITEM_WORKFLOW
   */

  /*#
   *  Procedure to be called from WF to actually perform the approval process.
   *  (Standard WF API) If it's approved succesfully then 'COMPLETE:Y' will be
   *  returned, otherwise 'COMPLETE:N' along with error stack assigned to
   *  'ERROR_MESSAGE_STACK' WF Attribute.
   *  Parameters are the standard for WF callback procedures.
   *
   *  @param itemtype   WF Item Type
   *  @param itemkey    WF Item Key
   *  @param actid      Activity Id
   *  @param funcmode   Function Mode
   *  @param result     WF Result
   *
   *  @rep:displayname approve_citem_version
   *
   */
  PROCEDURE Approve_Citem_Version(
    itemtype                    IN VARCHAR2
    ,itemkey                    IN VARCHAR2
    ,actid                      IN NUMBER
    ,funcmode                   IN VARCHAR2
    ,result                     IN OUT NOCOPY VARCHAR2
  );

  /*#
   *  Fetches all notifications for current user associated to Content
   *  Manager and with the format set by Submit_for_Approval
   *
   *  @param x_citem_version_ids   Table of content item version ids
   *  @param x_wf_item_keys        Table of Workflow Item Keys, these values can
   *                               be used to respond (Approve or Reject)
   *                               notifications calling Respond_Approval_Notification
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname Get_Pending_Approvals
   *
   */
  PROCEDURE Get_Pending_Approvals(
    x_citem_version_ids         OUT NOCOPY jtf_number_table
    ,x_wf_item_keys             OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*#
   *  Fetches all notifications (for current user) associated to Content
   *  Manager and for translation requests
   *
   *  @param x_citem_version_ids   Table of content item version ids
   *  @param x_wf_item_keys        Table of Workflow Item Keys, these values
   *                               can be used to close notifications calling
   *                               close_fyi_notification
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname Get_Pending_Translations
   *
   */
  PROCEDURE Get_Pending_Translations(
    x_citem_version_ids         OUT NOCOPY jtf_number_table
    ,x_wf_item_keys             OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*#
   *  Procedure to be called from WF to process the response for approval
   *  notification request.
   *  It focuses more on REJECTED response to set callback URL
   *  Parameters are the standard for WF callback procedures.
   *
   *  @param itemtype   WF Item Type
   *  @param itemkey    WF Item Key
   *  @param actid      Activity Id
   *  @param funcmode   Function Mode
   *  @param result     WF Result
   *
   *  @rep:displayname Process_Approval_Response
   *
   */
  PROCEDURE Process_Approval_Response(itemtype IN VARCHAR2,
                                      itemkey  IN VARCHAR2,
                                      actid    IN NUMBER,
                                      funcmode IN VARCHAR2,
                                      result   IN OUT NOCOPY VARCHAR2);

  /*#
   *  Determines if translations requests need to be sent.
   *
   *  @param itemtype   WF Item Type
   *  @param itemkey    WF Item Key
   *  @param actid      Activity Id
   *  @param funcmode   Function Mode
   *  @param result     WF Result
   *
   *  @rep:displayname Process_Translations
   *
   */
  PROCEDURE Process_Translations(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2,
                                 actid    IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 result   IN OUT NOCOPY VARCHAR2);

  /*#
   *  Responds approval notification request, and optionally pass
   *  notes/comments to submitter.
   *
   *  @param p_item_type            WF Item Type
   *  @param p_item_key             WF Item Key
   *  @param p_activity             Activity Id
   *  @param p_response             Response to Notification (either Y or N)
   *  @param p_notes_to_submitter   Notes/Comments to Submitter
   *  @param p_commit               standard parm - Commit flag
   *  @param p_api_version          standard parm - API Version
   *  @param p_init_msg_list        standard parm - Initialize message list
   *  @param x_return_status        standard parm - Return Status
   *  @param x_msg_count            standard parm - Message Count
   *  @param x_msg_data             standard parm - Message Data
   *
   *  @rep:displayname Respond_Approval_Notification
   *
   */
  PROCEDURE Respond_Approval_Notification(
    p_item_type                 IN  VARCHAR2 DEFAULT 'IBC_WF'
    ,p_item_key                 IN  VARCHAR2
    ,p_activity                 IN  VARCHAR2 DEFAULT 'IBC_CITEM_APPROVE_NOTIFICATION'
    ,p_response                 IN  VARCHAR2
    ,p_notes_to_submitter       IN  VARCHAR2 DEFAULT NULL
    ,p_commit                   IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count         OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*#
   *  Closes Translation Request from inbox
   *
   *  @param p_item_type            WF Item Type
   *  @param p_item_key             WF Item Key
   *  @param p_commit               standard parm - Commit flag
   *  @param p_api_version          standard parm - API Version
   *  @param p_init_msg_list        standard parm - Initialize message list
   *  @param x_return_status        standard parm - Return Status
   *  @param x_msg_count            standard parm - Message Count
   *  @param x_msg_data             standard parm - Message Data
   *
   *  @rep:displayname Close_Translation_Request
   *
   */
  PROCEDURE Close_Translation_Request(
    p_item_type                 IN  VARCHAR2 DEFAULT 'IBC_WF'
    ,p_item_key                 IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*#
   *  It launches Content Item Approval Workflow process
   *
   *  @param p_citem_ver_id              Content Item Version ID
   *  @param p_notes_to_approver         Comments/Notes send to approver(s)
   *  @param p_priority                  WF Notification priority
   *  @param p_callback_URL              URL Link to be shown in the notification
   *                                     in order to access the content item
   *                                     Some parameters will be replaced in the
   *                                     content (parameters are prefixed with an
   *                                     Ampersand and all uppercase):
   *                                     CITEM_VERSION_ID => Content Item version ID
   *                                     ITEM_TYPE        => WF Item Type
   *                                     ITEM_KEY         => WF Item Key
   *                                     ACTION_MODE      => Action Mode (SUBMITTED,
   *                                                         APPROVED or REJECTED)
   *  @param p_callback_url_description  Description to appear in notification
   *  @param p_language                  Content Item's Language
   *  @param p_commit                    standard parm - Commit flag
   *  @param p_api_version               standard parm - API Version
   *  @param p_init_msg_list             standard parm - Initialize message list
   *  @param px_object_version_number    Object_Version_Number
   *  @param x_wf_item_key               WF Item key
   *  @param x_return_status             standard parm - Return Status
   *  @param x_msg_count                 standard parm - Message Count
   *  @param x_msg_data                  standard parm - Message Data
   *
   *  @rep:displayname Submit_For_Approval
   *
   */
  PROCEDURE Submit_For_Approval(
    p_citem_ver_id              IN  NUMBER
    ,p_notes_to_approver        IN  VARCHAR2 DEFAULT NULL
    ,p_priority                 IN  NUMBER   DEFAULT NULL
    ,p_callback_url             IN  VARCHAR2 DEFAULT NULL
    ,p_callback_url_description IN  VARCHAR2 DEFAULT NULL
    ,p_language                 IN  VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_wf_item_key              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count         OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*#
   *  It launches Content Item Translation Approval Workflow process
   *
   *  @param p_citem_ver_id              Content Item Version ID
   *  @param p_notes_to_approver         Comments/Notes send to approver(s)
   *  @param p_priority                  WF Notification priority
   *  @param p_callback_URL              URL Link to be shown in the notification
   *                                     in order to access the content item
   *                                     Some parameters will be replaced in the
   *                                     content (parameters are prefixed with an
   *                                     Ampersand and all uppercase):
   *                                     CITEM_VERSION_ID => Content Item version ID
   *                                     ITEM_TYPE        => WF Item Type
   *                                     ITEM_KEY         => WF Item Key
   *                                     ACTION_MODE      => Action Mode (SUBMITTED,
   *                                                         APPROVED or REJECTED)
   *  @param p_callback_url_description  Description to appear in notification
   *  @param p_language                  Content Item's Language
   *  @param px_object_version_number    Content Item Object Version Number
   *  @param x_wf_item_key               WF item key
   *  @param p_commit                    standard parm - Commit flag
   *  @param p_api_version               standard parm - API Version
   *  @param p_init_msg_list             standard parm - Initialize message list
   *  @param x_return_status             standard parm - Return Status
   *  @param x_msg_count                 standard parm - Message Count
   *  @param x_msg_data                  standard parm - Message Data
   *
   *  @rep:displayname Submit_For_Trans_Approval
   *
   */
  PROCEDURE Submit_For_Trans_Approval(
     p_citem_ver_id             IN  NUMBER
    ,p_notes_to_approver        IN  VARCHAR2 DEFAULT NULL
    ,p_priority                 IN  NUMBER  DEFAULT NULL
    ,p_callback_url             IN  VARCHAR2 DEFAULT NULL
    ,p_callback_url_description IN  VARCHAR2 DEFAULT NULL
    ,p_language                 IN  VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version              IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list            IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,px_object_version_number   IN  OUT NOCOPY NUMBER
    ,x_wf_item_key              OUT NOCOPY VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    );


  /*#
   *  Procedure to be called from WF to process the response for translation
   *  approval(TA) notification request. It focuses more on REJECTED response
   *  to set callback URL
   *
   *  @param itemtype   WF Item Type
   *  @param itemkey    WF Item Key
   *  @param actid      Activity Id
   *  @param funcmode   Function Mode
   *  @param result     WF Result
   *
   *  @rep:displayname Process_TA_Response
   *
   */
  PROCEDURE Process_TA_Response(itemtype IN VARCHAR2
                               ,itemkey  IN VARCHAR2
                               ,actid    IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,result   IN OUT NOCOPY VARCHAR2
                               );


  /*#
   *  Procedure to be called from WF to actually perform the translation
   *  approval process thru status change API. If it's approved succesfully
   *  then 'COMPLETE:Y' will be returned and callback URL updated, otherwise
   *  'COMPLETE:N' will be returned along with error stack assigned to
   *  'ERROR_MESSAGE_STACK' WF Attribute.
   *
   *  @param itemtype   WF Item Type
   *  @param itemkey    WF Item Key
   *  @param actid      Activity Id
   *  @param funcmode   Function Mode
   *  @param result     WF Result
   *
   *  @rep:displayname Approve_Translation
   *
   */
  PROCEDURE Approve_Translation(itemtype IN VARCHAR2
                               ,itemkey  IN VARCHAR2
                               ,actid    IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,result   IN OUT NOCOPY VARCHAR2
                               );

  /*#
   *  Checks for notifications to be left without approvers.
   *
   *  @return TRUE/FALSE whether notifications are going to be left without
   *          approvers or not.
   *
   *  @rep:displayname Is_Security_OK_For_Dir
   *
   */
  FUNCTION Is_Security_OK_For_Dir(p_directory_node_id IN NUMBER)
  RETURN BOOLEAN;

  /*#
   * PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Notify_Move
   * DESCRIPTION: Procedure to be called from WF and a notification has to be
   *              sent to all users with the Read Item permission that the category
   *              or folder has moved to a new location.
   *  @param p_object_name             Content Object Name
   *  @param p_content_item_id         Content Item ID
   *  @param p_source_dir_node_id      Source Directory ID
   *  @param p_destination_dir_node_id Destination Directory ID
   *
   *  @rep:displayname Notify_Move
   */

  PROCEDURE Notify_Move(p_object_name IN VARCHAR2
                       ,p_content_item_id IN NUMBER
                       ,p_source_dir_node_id  IN NUMBER
                       ,p_destination_dir_node_id IN NUMBER);
  /*#
   * PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Notify_Translator
   * DESCRIPTION: Procedure to be called from WF and a notification has to be
   *              sent to all users with Translate permission when a change is
   *              made to the content item that has translation enabled.
   *  @param p_content_item_id         Content Item ID
   *
   *  @rep:displayname Notify_Translator
   */


  PROCEDURE Notify_Translator(p_content_item_id IN NUMBER);

END IBC_CITEM_WORKFLOW_PVT;

 

/
