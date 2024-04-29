--------------------------------------------------------
--  DDL for Package PV_PRGM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpaps.pls 120.1 2005/09/12 15:52:27 saarumug noship $*/

   -- PROCEDURE
   --   Notify_requestor_FYI
   --
   -- PURPOSE
   --   Generate the Requisition Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2002        pukken      CREATION
   --   12/04/2002  SVEERAVE  added Process_errored_requests that will
   --                               be called from conc. request.
   -- NOTE        :
   -- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
   --                          All rights reserved.
   -----------------------------------------------------------------
   PROCEDURE notify_requestor_fyi(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of Approval
   --
   -- PURPOSE
   --   Generate the Approval Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2002        pukken        CREATION
   ----------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_approval(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of rejection
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2002        pukken        CREATION
   -------------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_rejection(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of rejection
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2002        pukken        CREATION


   PROCEDURE notify_approval_required(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   notify_appr_req_reminder
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2002        pukken        CREATION


   PROCEDURE notify_appr_req_reminder(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   set_parprgm_activity_details
   --
   --
   -- PURPOSE
   --   This Procedure will set all the item attribute details
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   02/20/2002        pukken        CREATION
   -- End of Comments
   --------------------------------------------------------------------
   PROCEDURE set_parprgm_activity_details(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --  update_parprogram_status
   --
   --
   -- PURPOSE
   --   This Procedure will update the status
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   02/20/2002        pukken        CREATION
   -- End of Comments
   --------------------------------------------------------------------
 PROCEDURE update_parprogram_status(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);


   -- PROCEDURE
   --  submit_enrollment_for_approval
   --
   --
   -- PURPOSE
   --   This Procedure will submit the enrollment to the approver by calling OAM API
   --   and sends FYI notification to the approver
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   --
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   09/16/2002        pukken        CREATION
   -- End of Comments


 PROCEDURE submit_enrl_req_for_approval(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,enrl_request_id              IN   NUMBER
     ,entity_code                  IN   VARCHAR2
     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );


  --------------------------------------------------------------------------
   -- FUNCTION
   --   isPartnerType
   --
   -- PURPOSE
   --   Checks whether the partner is of partner type passed in
   -- IN
   --   enrollment_request_id NUMBER
   --   partner_type         VARCHAR
   -- OUT
   --   ame_util.booleanAttributeTrue if exists
   --   ame_util.booleanAttributeFalse if not exists
   -- USED BY
   --   Program Approval API, and Activate API.
   -- HISTORY
   --   12/13/2002                CREATION
   --------------------------------------------------------------------------
FUNCTION isPartnerType(p_partner_id IN NUMBER,p_partner_type IN VARCHAR2)
RETURN VARCHAR2;


PROCEDURE update_enrl_req_status(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,enrl_request_id              IN   NUMBER
     ,entity_code                  IN   VARCHAR2
     ,approvalStatus               IN   VARCHAR2
     ,start_date                   IN   DATE
     ,end_date                     IN   DATE
     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2);


PROCEDURE getstart_and_end_date(
       p_api_version_number         IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,enrl_request_id   IN NUMBER
      ,x_start_date      OUT NOCOPY DATE
      ,x_end_date        OUT NOCOPY DATE
      ,x_return_status   OUT NOCOPY  VARCHAR2
      ,x_msg_count       OUT NOCOPY  NUMBER
      ,x_msg_data        OUT NOCOPY  VARCHAR2 );


PROCEDURE check_approved (
       itemtype  IN     VARCHAR2
      ,itemkey   IN     VARCHAR2
      ,actid     IN     NUMBER
      ,funcmode  IN     VARCHAR2
      ,resultout    OUT NOCOPY   VARCHAR2
      );

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Process_errored_requests
   --
   -- PURPOSE
   --   Process the enrollment requests which are errored while finding next
   --   approver in OAM. This will be called by concurrent program.
   -- IN
   --   std. conc. request parameters.
   --   ERRBUF
   --   RETCODE
   -- OUT
   -- USED BY
   --   Concurrent program
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------
PROCEDURE Process_errored_requests(
  ERRBUF                OUT NOCOPY VARCHAR2,
  RETCODE               OUT NOCOPY VARCHAR2 );

PROCEDURE terminate_downgrade_memb(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_membership_id              IN   NUMBER
   ,p_event_code                 IN   VARCHAR2-- pass 'TERMINATED' or 'DOWNGRADED' depending on the event
   ,p_status_reason_code         IN   VARCHAR2
   ,p_comments                   IN   VARCHAR2 DEFAULT NULL
   ,p_program_id_downgraded_to   IN   NUMBER   --programid into which the partner is downgraded to.
   ,p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
   ,p_new_memb_id                OUT NOCOPY  NUMBER
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
);

 --------------------------------------------------------------------------
   -- PROCEDURE
   --   Create_Default_Membership
   --
   -- PURPOSE
   --     Create membership into a default program . This is called when new partner is created
   -- IN
   --   p_partner_id - partner_id of the partner
   --   p_requestor_resource_id- resource_id of the user who's performing the action
   -- USED BY
   --   User Management while creating new partner
   -- HISTORY
   --   05-June-2003        pukken        CREATION
   --------------------------------------------------------------------------
PROCEDURE Create_Default_Membership (
      p_api_version_number   IN   NUMBER
     ,p_init_msg_list               IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                        IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,p_partner_id                       IN   NUMBER
     ,p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
);

PROCEDURE send_notifications
(
   p_api_version_number           IN   NUMBER
   , p_init_msg_list              IN   VARCHAR2  := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2  := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id                 IN   NUMBER
   , p_enrl_request_id            IN   NUMBER    -- enrollment request id
   , p_memb_type                  IN   VARCHAR2  -- member type of the partner
   , p_enrq_status                IN   VARCHAR2  -- enrollment_status pass 'AWAITING_APPROVAL' incase submitting for approval
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
);

END pv_prgm_approval_pvt;

 

/
