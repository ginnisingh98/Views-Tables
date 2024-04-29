--------------------------------------------------------
--  DDL for Package Body IGW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_UTILS" AS
--$Header: igwutilb.pls 120.9 2005/09/12 21:04:25 vmedikon ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_UTILS';

   ---------------------------------------------------------------------------

   PROCEDURE Get_Proposal_Id
   (
      p_context_field     IN VARCHAR2,
      p_check_id_flag     IN VARCHAR2,
      p_proposal_number   IN VARCHAR2,
      p_proposal_id       IN NUMBER,
      x_proposal_id       OUT NOCOPY NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Proposal_Id';

     --Possible values for p_context_field
     /* PROPOSAL_ID, ORIGINAL_PROPOSAL_ID */

   BEGIN
     null;

   END Get_Proposal_id;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Person_Id
   (
      p_context_field  IN VARCHAR2,
      p_check_id_flag  IN VARCHAR2,
      p_full_name      IN VARCHAR2,
      p_person_id      IN NUMBER,
      p_party_id       IN NUMBER,
      x_person_id      OUT NOCOPY NUMBER,
      x_party_id       OUT NOCOPY NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Person_Id';

     --Possible values for p_context_field
     /* PERSON_ID, PROPOSAL_MANAGER_ID, SIGNING_OFFICIAL_ID, ADMIN_OFFICIAL_ID, MANAGER_ID */
     /* variable person_id is carrying both party_id and person_id in the following program */

   BEGIN
     null;

   END Get_Person_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Get_User_Id
   (
      p_check_id_flag  IN VARCHAR2,
      p_user_name      IN VARCHAR2,
      p_user_id        IN NUMBER,
      x_user_id        OUT NOCOPY NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_User_Id';

   BEGIN

     null;

   END Get_User_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Person_User_Id
   (
      p_context_field    IN VARCHAR2,
      p_check_id_flag    IN VARCHAR2,
      p_person_id        IN NUMBER,
      p_user_id          IN NUMBER,
      x_user_id          OUT NOCOPY NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Person_User_Id';

   BEGIN

     null;

   END Get_Person_User_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Sponsor_Id
   (
      p_context_field  IN VARCHAR2,
      p_check_id_flag  IN VARCHAR2,
      p_sponsor_name   IN VARCHAR2,
      p_sponsor_id     IN NUMBER,
      x_sponsor_id     OUT NOCOPY NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Sponsor_Id';

     --Possible values for p_context_field
     /* SPONSOR_ID, ORIGINAL_SPONSOR_ID */

   BEGIN

     null;

   END Get_Sponsor_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Organization_Id
   (
      p_context_field     IN VARCHAR2,
      p_check_id_flag     IN VARCHAR2,
      p_organization_name IN VARCHAR2,
      p_organization_id   IN NUMBER,
      p_party_id          IN NUMBER,
      x_organization_id   OUT NOCOPY NUMBER,
      x_party_id          OUT NOCOPY NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Organization_Id';

     --Possible values for p_context_field
     /* LEAD_ORGANIZATION_ID, SUBMITTING_ORGANIZATION_ID, PERFORMING_ORG_ID, PROJECT_LOCATION, PERSON_ORGANIZATION_ID */
     /* variable p_organization is carrying both party_id and organization_id in the following program */
   BEGIN

    null;

   END Get_Organization_Id;

   ---------------------------------------------------------------------------

   /*
   **
   **   Possible values for p_context_field :
   **
   **   PROPOSAL_ROLE_CODE, ACTIVITY_TYPE_CODE, PROPOSAL_TYPE_CODE,
   **   PROPOSAL_STATUS_CODE, NOTICE_OF_OPPORTUNITY_CODE, DEADLINE_TYPE_CODE,
   **   APPOINTMENT_TYPE_CODE, PERIOD_TYPE_CODE, LOCATION_CODE,
   **   SPONSOR_ACTION_CODE, ABSTRACT_TYPE_CODE, SPECIAL_REVIEW_CODE,
   **   SPECIAL_REVIEW_TYPE, REVIEW_APPROVAL_TYPE, BUDGET_STATUS_CODE, DISTRIBUTION_METHOD_CODE
   **
   */

   PROCEDURE Get_Lookup_Code
   (
      p_context_field   IN VARCHAR2,
      p_check_id_flag   IN VARCHAR2,
      p_lookup_type     IN VARCHAR2,
      p_lookup_meaning  IN VARCHAR2,
      p_lookup_code     IN VARCHAR2,
      x_lookup_code     OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Lookup_Code';

     --Possible values for p_context_field
     /* PROPOSAL_ROLE_CODE, ACTIVITY_TYPE_CODE, PROPOSAL_TYPE_CODE, PROPOSAL_STATUS_CODE,
        NOTICE_OF_OPPORTUNITY_CODE, DEADLINE_TYPE_CODE, APPOINTMENT_TYPE_CODE, PERIOD_TYPE_CODE,
        LOCATION_CODE, BUDGET_CATEGORY_CODE */

   BEGIN

     null;

   END Get_Lookup_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Check_Date_Validity
   (
      p_context_field  IN VARCHAR2,
      p_start_date     IN DATE,
      p_end_date       IN DATE,
      x_return_status  OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Lookup_Code';

     --Possible values for p_context_field
     /* PROPOSAL_DATE, ORIGINAL_PROPOSAL_DATE, BUDGET_PERIOD_DATE, BUDGET_LINE_DATE, BUDGET_PERSONNEL_DATE, AWARD_BUDGET */

   BEGIN

   null;

   END Check_Date_Validity;

   ---------------------------------------------------------------------------

   PROCEDURE Check_Rights
   (
      p_proposal_id           IN NUMBER,
      x_modify_general        OUT NOCOPY VARCHAR2,
      x_modify_budget         OUT NOCOPY VARCHAR2,
      x_modify_narrative      OUT NOCOPY VARCHAR2,
      x_modify_checklist      OUT NOCOPY VARCHAR2,
      x_modify_approval       OUT NOCOPY VARCHAR2,
      x_modify_sponsor_action OUT NOCOPY VARCHAR2,
      x_modify_award          OUT NOCOPY VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Check_Rights';
      l_user_id              NUMBER       := Fnd_Global.User_Id;
      l_proposal_status      VARCHAR2(30);

   BEGIN

   null;

   END Check_Rights;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Science_Code
   (
      p_check_id_flag IN VARCHAR2,
      p_description   IN VARCHAR2,
      p_science_code  IN VARCHAR2,
      x_science_code  OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Science_Code';

   BEGIN
     null;

   END Get_Science_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Send_Notification
   (
      p_event         IN VARCHAR2,
      p_proposal_id   IN NUMBER,
      p_person_list   IN PERSON_LIST_TYPE,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30)  := 'Send_Notification';

      l_itemtype               VARCHAR2(30)  := 'PROP_APP';
      l_process                VARCHAR2(30)  := 'SEND_NOTIFICATION_TO_MEMBERS';
      l_itemkey                VARCHAR2(30);
      l_role_name              VARCHAR2(30);
      l_role_display_name      VARCHAR2(80);
      l_proposal_number        VARCHAR2(30);
      l_proposal_title         VARCHAR2(250);
      l_proposal_manager_name  VARCHAR2(301);
      l_sponsor_name           VARCHAR2(50);
      l_proposal_type_desc     VARCHAR2(80);
      l_deadline_date          DATE;
      l_lead_organization_name 	hr_all_organization_units.NAME%TYPE;
      l_proposal_owner_name    VARCHAR2(240);
      l_sender_name            VARCHAR2(240);
      l_user_name              VARCHAR2(100);
      l_message_name           VARCHAR2(30);


      PROCEDURE Create_Role IS
      BEGIN
        null;

      END Create_Role;


      PROCEDURE Populate_Attributes IS
      BEGIN

        null;

      END Populate_Attributes;

   BEGIN

    null;

   EXCEPTION

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Send_Notification;

   ---------------------------------------------------------------------------

   PROCEDURE Copy_Proposal
   (
      p_old_proposal_id     IN NUMBER,
      p_new_proposal_number IN VARCHAR2,
      p_budget_copy_flag    IN VARCHAR2,
      p_narrative_copy_flag IN VARCHAR2,
      p_proposal_owner_id   IN NUMBER,
      x_new_proposal_id     OUT NOCOPY NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

      l_api_name       CONSTANT VARCHAR2(30) := 'Copy_Proposal';

      l_old_proposal_number     VARCHAR2(30);
      l_new_proposal_number     VARCHAR2(30) := p_new_proposal_number;
      l_budget_version_id       NUMBER;

      l_proposal_numbering_method VARCHAR2(10);

      CURSOR c1 IS
      SELECT next_automatic_proposal_number
      FROM   igw_implementations;

      l_count_proposal_number   NUMBER;

   BEGIN

     null;

   END Copy_Proposal;

   ---------------------------------------------------------------------------

END Igw_Utils;

/
