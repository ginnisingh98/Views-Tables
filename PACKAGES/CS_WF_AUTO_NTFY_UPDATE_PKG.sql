--------------------------------------------------------
--  DDL for Package CS_WF_AUTO_NTFY_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WF_AUTO_NTFY_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: cswfauts.pls 120.1 2006/02/06 18:53:22 spusegao noship $ */


  PROCEDURE Check_Rules_For_Event( itemtype   IN  VARCHAR2,
                                   itemkey    IN  VARCHAR2,
                                   actid      IN  NUMBER,
                                   funmode    IN  VARCHAR2,
                                   result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Check_Notification_Rules( itemtype   IN  VARCHAR2,
                                   itemkey    IN  VARCHAR2,
                                   actid      IN  NUMBER,
                                   funmode    IN  VARCHAR2,
                                   result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Get_Recipients_To_Notify( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Set_Notification_Details( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE All_Recipients_Notified( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Verify_Notify_Rules_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Check_Status_Rules( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Get_Links_For_Rule( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Execute_Rules_Per_SR( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Verify_Update_Valid( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Update_SR( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Set_Notify_Error( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Verify_All_Links_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Verify_Update_Rules_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Get_Request_Attributes( itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funmode         VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );

  -- Release 11.5.10
  PROCEDURE Create_Contact_Interaction( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );

  PROCEDURE All_Interactions_Created( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 );


  PROCEDURE Get_Fnd_User_Role
    ( p_fnd_user_id       IN      NUMBER,
      x_role_name         OUT     NOCOPY VARCHAR2,
      x_role_display_name OUT     NOCOPY VARCHAR2 );


  PROCEDURE Create_Interaction_Activity(
                        p_api_revision  IN      NUMBER,
                        p_init_msg_list IN      VARCHAR2  := FND_API.G_FALSE,
                        p_commit        IN      VARCHAR2  := FND_API.G_FALSE,
                        p_incident_id   IN      NUMBER,
                        p_incident_number       IN VARCHAR2 DEFAULT NULL,
                        p_party_id      IN      NUMBER,
                        p_user_id       IN      NUMBER,
                        p_resp_appl_id  IN      NUMBER,
                        p_resp_id       IN      NUMBER,
                        p_login_id      IN      NUMBER,
                        x_return_status OUT     NOCOPY  VARCHAR2,
                        x_resource_id   OUT     NOCOPY  NUMBER,
                        x_resource_type OUT     NOCOPY  VARCHAR2,
                        x_msg_count     OUT     NOCOPY  NUMBER,
                        x_msg_data      OUT     NOCOPY  VARCHAR2);

  PROCEDURE Prepare_HTML_Notification
              ( itemtype   IN  VARCHAR2,
                itemkey    IN  VARCHAR2,
                actid      IN  NUMBER,
                funmode    IN  VARCHAR2,
                result     OUT NOCOPY VARCHAR2 );

  PROCEDURE Are_All_HTML_Recips_Notified
              ( itemtype   IN  VARCHAR2,
                itemkey    IN  VARCHAR2,
                actid      IN  NUMBER,
                funmode    IN  VARCHAR2,
                result     OUT NOCOPY VARCHAR2 ) ;

END CS_WF_AUTO_NTFY_UPDATE_PKG;

 

/
