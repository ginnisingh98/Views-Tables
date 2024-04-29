--------------------------------------------------------
--  DDL for Package PV_PG_NOTIF_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_NOTIF_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvpnus.pls 115.13 2003/12/01 19:17:59 pukken ship $ */

------------------------------------------------------------------------------
-- HISTORY
--    20-SEP-2002   rdsharma  Created
--    11-NOV-2002   SVEERAVE  Since the package pv_pgp_notif_pvt is changed to
--                            pv_ge_party_notif_pvt, all the references are changed
--                            accordingly. Since pv_ge_party_notifications table
--                            is changd to have partner_id column instead of partner_party_id
--                            set_pgp_notif procedure is changed to capture partner_id
--    11-NOV-2002   SVEERAVE  get_Notification_Body function is added.
--    04-AUG-2003   SVEERAVE  Added set_msg_doc for bug# 3072153.
--    10/18/2003    pukken    Added new procedure Send_Workflow_Notification to send the notifications
------------------------------------------------------------------------------

g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
g_pv_lookups  CONSTANT VARCHAR2(12) :=  'FND_LOOKUPS';

resource_locked EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);

TYPE user_notify_rec_type is RECORD
(
    USER_ID             NUMBER,
    USER_NAME           VARCHAR2(360),
    USER_RESOURCE_ID    NUMBER
);

g_miss_user_notify_rec_type user_notify_rec_type;
TYPE user_notify_rec_tbl_type IS TABLE OF user_notify_rec_type INDEX BY BINARY_INTEGER;

TYPE mbrship_chng_rec_type is RECORD
(
    ID                      NUMBER,
    PARTNER_ID              NUMBER,
    RESOURCE_ID      NUMBER,
    NOTIF_TYPE              VARCHAR2(240),
    MESSAGE_SUBJ            VARCHAR2(240),
    MESSAGE_BODY        VARCHAR2(2000)
);

g_miss_mbrship_chng_rec_type mbrship_chng_rec_type;

/*============================================================================*/
-- Start of Comments
-- PROCEDURE
--    get_enrl_requests_details
--
-- PURPOSE
--    This procedure will return enrollment request details
--    from PV_PG_ENRL_REQUESTS table for a given enrl_requests_id
-- Called By
-- NOTES
-- End of Comments
/*============================================================================*/
PROCEDURE get_enrl_requests_details(
    p_enrl_request_id       IN NUMBER,
    x_req_submission_date   OUT NOCOPY DATE,
    x_partner_program_id    OUT NOCOPY NUMBER,
    x_partner_program       OUT NOCOPY VARCHAR2,
    x_enrollment_duration   OUT NOCOPY VARCHAR2,
    x_enrollment_type       OUT NOCOPY VARCHAR2,
    x_req_resource_id       OUT NOCOPY NUMBER,
    x_prtnr_vndr_relship_id OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
);

/*============================================================================*/
-- Start of Comments
-- PROCEDURE
--    get_requestor_details
--
-- PURPOSE
--    This procedure will return enrollment requestor details from
--    JTF_RS_RESOURCE_EXTNS table for a given resource_id
-- Called By
-- NOTES
-- End of Comments
/*============================================================================*/
PROCEDURE get_requestor_details(
    p_req_resource_id  IN NUMBER,
    x_user_id               OUT NOCOPY NUMBER,
    x_source_name           OUT NOCOPY VARCHAR2,
    x_user_name             OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
);

/*============================================================================*/
-- Start of Comments
-- PROCEDURE
--    get_prtnr_vendor_details
--
-- PURPOSE
--    This procedure will return partner and vendor details
--    for a given relationship_id  between Partner and the Vendor
-- Called By
-- NOTES
-- End of Comments
/*============================================================================*/
PROCEDURE get_prtnr_vendor_details(
    p_enrl_request_id       IN NUMBER,
    x_vendor_party_id       OUT NOCOPY NUMBER,
    x_vendor_name           OUT NOCOPY VARCHAR2,
    x_partner_party_id      OUT NOCOPY NUMBER,
    x_partner_comp_name     OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
);

/*============================================================================*/
-- Start of Comments
-- PROCEDURE
--    get_membership_details
--
-- PURPOSE
--    This procedure will return all the membership details for a
--    partner user enrolled for a program for a given membership_id
-- Called By
-- NOTES
-- End of Comments
/*============================================================================*/
PROCEDURE get_membership_details(
    p_membership_id         IN NUMBER,
    x_req_submission_date   OUT NOCOPY DATE,
    x_partner_program_id    OUT NOCOPY NUMBER,
    x_partner_program       OUT NOCOPY VARCHAR2,
    x_enrl_request_id       OUT NOCOPY NUMBER,
    x_enrollment_start_date OUT NOCOPY DATE,
    x_enrollment_end_date   OUT NOCOPY DATE,
    x_req_resource_id       OUT NOCOPY NUMBER,
    x_prtnr_vndr_relship_id OUT NOCOPY NUMBER,
    x_enrollment_type       OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
);
/*============================================================================*/
-- Start of Comments
-- NAME
--   Get_Users_List
--
-- PURPOSE
--   This Procedure will be return all the users for a given partner Vendor
--   relationship id and the requestor resourse id.
--
-- Called By
-- NOTES
-- End of Comments

/*============================================================================*/

PROCEDURE get_users_list
   (  p_partner_id          IN     NUMBER,
      x_user_notify_rec_tbl OUT NOCOPY    user_notify_rec_tbl_type ,
      x_user_count          OUT NOCOPY    NUMBER,
      x_return_status       OUT NOCOPY    VARCHAR2
);

/*============================================================================*/
-- Start of Comments
-- NAME
--   Get_Resource_Role
--
-- PURPOSE
--   This Procedure will be return the workflow user role for
--   the resourceid sent
-- Called By
-- NOTES
-- End of Comments

/*============================================================================*/

PROCEDURE get_resource_role
   (  p_resource_id        IN     NUMBER,
      x_role_name          OUT NOCOPY    VARCHAR2,
      x_role_display_name  OUT NOCOPY    VARCHAR2 ,
      x_return_status      OUT NOCOPY    VARCHAR2
);

/*============================================================================
-- Start of Comments
-- NAME
--   Get_Notification_Name
--
-- PURPOSE
--   This Procedure will be return the Notification name by slecting the
--   meaning  for
--   the resourceid sent
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

FUNCTION get_Notification_Name( p_notif_code    IN    VARCHAR2 )
RETURN VARCHAR2;

/*============================================================================
-- Start of Comments
-- NAME
--   Check_Notif_Rule_Active
--
-- PURPOSE
--   This Procedure will return the ACTIVE_FLAG value for the Notification
--   rule set for the given Program Id and Notification Type.
--
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

FUNCTION check_Notif_Rule_Active( p_program_id    IN    NUMBER ,
				  p_notif_type	  IN	VARCHAR2 )
RETURN VARCHAR2;

/*============================================================================*/
-- Start of Comments
-- NAME
--   Validate_Enrl_Requests
--
-- PURPOSE
--   This procedure validate the ENRL_REQUEST_ID or REQUESTOR_RESOURCE_ID
--
-- Called By
--
-- NOTES
--
-- End of Comments

/*============================================================================*/
PROCEDURE Validate_Enrl_Requests (
    p_item_id        IN  NUMBER ,
    p_item_name         IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2
);

/*============================================================================*/
-- Start of Comments
-- NAME
--   Set_Pgp_Notif
--
-- PURPOSE
--   This procedure set the proper values in pgp_notif_rec, before calling the
--  Create_Pgp_Notif procedure.
--
-- Called By
--
-- NOTES
--
-- End of Comments

/*============================================================================*/
PROCEDURE Set_Pgp_Notif (
    p_notif_id         IN   NUMBER,
    p_object_version   IN   NUMBER,
    p_partner_id IN   NUMBER,
    p_user_id          IN   NUMBER,
    p_arc_notif_for_entity_code IN VARCHAR2,
    p_notif_for_entity_id  IN   NUMBER,
    p_notif_type_code   IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2 ,
    x_pgp_notif_rec     OUT NOCOPY pv_ge_party_notif_pvt.pgp_notif_rec_type
);


/*============================================================================
-- Start of comments
--	API name 	: send_thnkyou_notif
--	Type		: Private.
--	Function	: This API compiles and sends the Thank you notification to a
--                partner, once the partner user successfully enrolled to a
--                partner program.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_enrl_request_id      IN NUMBER    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				.
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/

PROCEDURE send_thnkyou_notif(
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_enrl_request_id   IN  NUMBER
 );

/*============================================================================
-- Start of comments
--	API name 	: send_welcome_notif
--	Type		: Private.
--	Function	: This API compiles and sends the Welcome Notification to a
--                partner, once the partner user's  enrollment request is
--                approved by the approver.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_membership_id        IN NUMBER    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_welcome_notif (
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	:= 	FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_membership_id     IN  NUMBER
 );

/*============================================================================
-- Start of comments
--	API name 	: send_rejection_notif
--	Type		: Private.
--	Function	: This API compiles and sends the rejection notification to a
--                partner, once the partner user's enrollment request for a
--                partner program is rejected by the approver.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_enrl_request_id      IN NUMBER    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/

PROCEDURE send_rejection_notif (
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	:= 	FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_enrl_request_id   IN  NUMBER
 );

/*============================================================================
-- Start of comments
--	API name 	: send_cntrct_notrcvd_notif
--	Type		: Private.
--	Function	: This API compiles and sends the 'Signed Contract is not received'
--                notification to a partner, when there signed copy of contract is
--                not received by the vendor, which is required for approval the
--                enrollment request.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_enrl_request_id      IN NUMBER    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/

PROCEDURE send_cntrct_notrcvd_notif (
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	:= 	FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_enrl_request_id   IN  NUMBER
 );

/*============================================================================
-- Start of comments
--	API name 	: send_mbrship_exp_notif
--	Type		: Private.
--	Function	: This API compiles and sends the 'Membership Expiry' Notification
--                to a partner, once the partner user's  enrollment is going to
--                expire in near future.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_membership_id        IN NUMBER    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/
 PROCEDURE send_mbrship_exp_notif (
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	:= 	FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_membership_id     IN  NUMBER
 );

 /*============================================================================
-- Start of comments
--	API name 	: send_membership_chng_notif
--	Type		: Private.
--	Function	: This API compiles and sends the 'Upgrade Membership level'
--                Notification to all the selected partners, from one membership
--                level to another within a program.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version          IN NUMBER	Required
--				p_init_msg_list        IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit               IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level     IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_mbr_upgrade_rec      IN
--                  PV_PG_NOTIF_UTILITY_PVT.mbrship_upg_rec_type    Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				x_notif_id          OUT NUMBER
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
============================================================================*/
 PROCEDURE send_mbrship_chng_notif (
    p_api_version       IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  NUMBER	:= 	FND_API.G_VALID_LEVEL_FULL	,
	x_return_status	 OUT NOCOPY VARCHAR2 ,
	x_msg_count		 OUT NOCOPY NUMBER ,
	x_msg_data		 OUT NOCOPY VARCHAR2 ,
    p_mbrship_chng_rec  IN  PV_PG_NOTIF_UTILITY_PVT.mbrship_chng_rec_type
 );

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    send_ini_rmdr_notif
--
-- PURPOSE
--  This procedure send the initial or a reminder notification.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE send_ini_rmdr_notif(
    ITEMTYPE    IN  VARCHAR2,
    ITEMKEY     IN  VARCHAR2,
    ACTID 		IN  NUMBER,
    FUNCMODE    IN  VARCHAR2,
    RESULTOUT   OUT NOCOPY VARCHAR2
) ;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    check_for_rmdr_notif
--
-- PURPOSE
--  This procedure checks, whether, is there any need to send a reminder notification
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/

PROCEDURE check_for_rmdr_notif(
    ITEMTYPE    IN  VARCHAR2,
    ITEMKEY     IN  VARCHAR2,
    ACTID 		IN  NUMBER,
    FUNCMODE    IN  VARCHAR2,
    RESULTOUT   OUT NOCOPY VARCHAR2
) ;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    Prtnr_Prgm_Enrl_notif
--
-- PURPOSE
--  This procedure is called from the Concurrent Request program for sending the
--  Membership Expiry notification.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
Procedure Prtnr_Prgm_Enrl_notif(
        ERRBUF  OUT NOCOPY     varchar2,
        RETCODE OUT NOCOPY     varchar2);

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    Expire_Memberships
--
-- PURPOSE
--  This procedure updates the membership status either to EXPIRE or RENEW based
--  on the status criteria.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE Expire_Memberships(
        ERRBUF  OUT NOCOPY     VARCHAR2,
        RETCODE OUT NOCOPY     VARCHAR2 );


   --------------------------------------------------------------------------
   -- PROCEDURE
   --   get_Notification_Body
   --
   -- PURPOSE
   --   Gets Notification Body in HTML from Workflow.
   -- IN
   --   notification_id NUMBER
   -- OUT
   --   Notification body in HTML
   -- USED BY
   --   Notifications Detail screen from partner portal
   -- HISTORY
   --   12/05/2002        sveerave        CREATION
   --------------------------------------------------------------------------
FUNCTION get_Notification_Body(p_notif_id IN  number)
RETURN VARCHAR2;


   --------------------------------------------------------------------------
   -- PROCEDURE
   --   set_msg_doc
   --
   -- PURPOSE
   --   Sets Message Document for PL/SQL Document.
   -- IN -- as per PL/SQL Notification Document stadards
   --   document_id     IN       VARCHAR2
   --   display_type    IN       VARCHAR2
   --
   -- OUT
   --   document        IN OUT NOCOPY   VARCHAR2
   --   document_type   IN OUT NOCOPY   VARCHAR2   -- USED BY

   -- HISTORY
   --   08/04/2003        sveerave        CREATION
   --------------------------------------------------------------------------

  PROCEDURE set_msg_doc (
        document_id     IN       VARCHAR2
      , display_type    IN       VARCHAR2
      , document        IN OUT NOCOPY   VARCHAR2
      , document_type   IN OUT NOCOPY   VARCHAR2
  );

PROCEDURE Send_Workflow_Notification
(
   p_api_version_number    IN  NUMBER
   , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_context_id          IN  NUMBER   -- context_id ( this could be partner_id, vendor id , depending on who is sending the notifictaion
   , p_context_code        IN  VARCHAR2 -- who is senting the notification validated against pv_entity_notif_category
   , p_target_ctgry        IN  VARCHAR  -- to whom the notification be sent 'PARTNER', 'VAD', 'GLOBAL', 'SUBSIDIARY' --validated against pv_entity_notif_category
   , p_target_ctgry_pt_id  IN  NUMBER   -- pass partner_id of the partner to whom notifiction needs to be sent,
   , p_notif_event_code    IN  VARCHAR  -- the event due to which this is being called validated against PV_NOTIFICATION_EVENT_TYPE
   , p_entity_id           IN  NUMBER   -- if the notification is related to program enrollment pass enrl_request_id. else pass corressponfing entity ids depending on what entity you are sending the notification for
   , p_entity_code         IN  VARCHAR2 -- pass 'ENRQ' for enrollment related, PARTNER for partner related like member type change, INVITE incase of inviations related. validated against PV_ENTITY_TYPE
   , p_wait_time           IN  NUMBER   -- wait time in days after which the reminder needs to be sent pass zero if no reminder is to be sent
   , x_return_status       OUT NOCOPY  VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
);

PROCEDURE log_action
(
   itemtype     IN     VARCHAR2
   , itemkey    IN     VARCHAR2
   , actid      IN     NUMBER
   , funcmode   IN     VARCHAR2
   , resultout  OUT NOCOPY   VARCHAR2
);


PROCEDURE set_event_code
(
   itemtype  IN     VARCHAR2
   , itemkey   IN     VARCHAR2
   , actid     IN     NUMBER
   , funcmode  IN     VARCHAR2
   , resultout    OUT NOCOPY   VARCHAR2
);


PROCEDURE Send_Invitations
(
   p_api_version_number    IN  NUMBER
   , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id          IN  NUMBER
   , p_invite_header_id    IN  NUMBER
   , p_from_program_id     IN  NUMBER  DEFAULT NULL
   , p_notif_event_code    IN  VARCHAR2
   , p_discount_value      IN  VARCHAR2
   , p_discount_unit       IN  VARCHAR2
   , p_currency            IN  VARCHAR2
   , p_end_date            IN  DATE
   , x_return_status       OUT NOCOPY  VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
);


END PV_PG_NOTIF_UTILITY_PVT;

 

/
