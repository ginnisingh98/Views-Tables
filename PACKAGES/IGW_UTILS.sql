--------------------------------------------------------
--  DDL for Package IGW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_UTILS" AUTHID CURRENT_USER AS
--$Header: igwutils.pls 115.13 2002/11/15 00:52:17 ashkumar ship $

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the PROPOSAL_ID for a given PROPOSAL_NUMBER
   */

   PROCEDURE Get_Proposal_Id
   (
      p_context_field   IN VARCHAR2,
      p_check_id_flag   IN VARCHAR2,
      p_proposal_number IN VARCHAR2,
      p_proposal_id     IN NUMBER,
      x_proposal_id     OUT NOCOPY NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the PERSON_ID for a given FULL_NAME
   */

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
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the USER_ID for a given USER_NAME
   */

   PROCEDURE Get_User_Id
   (
      p_check_id_flag  IN VARCHAR2,
      p_user_name      IN VARCHAR2,
      p_user_id        IN NUMBER,
      x_user_id        OUT NOCOPY NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the USER_ID for a given PERSON_FULL_NAME
   */

   PROCEDURE Get_Person_User_Id
   (
      p_context_field    IN VARCHAR2,
      p_check_id_flag    IN VARCHAR2,
      p_person_id        IN NUMBER,
      p_user_id          IN NUMBER,
      x_user_id          OUT NOCOPY NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the SPONSOR_ID for a given SPONSOR_NAME
   */

   PROCEDURE Get_Sponsor_Id
   (
      p_context_field  IN VARCHAR2,
      p_check_id_flag  IN VARCHAR2,
      p_sponsor_name   IN VARCHAR2,
      p_sponsor_id     IN NUMBER,
      x_sponsor_id     OUT NOCOPY NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the ORGANIZATION_ID for a given
   **   ORGANIZATION_NAME
   */

   PROCEDURE Get_Organization_Id
   (
      p_context_field      IN VARCHAR2,
      p_check_id_flag      IN VARCHAR2,
      p_organization_name  IN VARCHAR2,
      p_organization_id    IN NUMBER,
      p_party_id           IN NUMBER default null,
      x_organization_id    OUT NOCOPY NUMBER,
      x_party_id           OUT NOCOPY NUMBER,
      x_return_status      OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the LOOKUP_CODE for a given LOOKUP_TYPE and
   **   MEANING
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
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to verify that the END_DATE is greater than the
   **   START_DATE
   */

   PROCEDURE Check_Date_Validity
   (
      p_context_field  IN VARCHAR2,
      p_start_date     IN DATE,
      p_end_date       IN DATE,
      x_return_status  OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to provide information about the rights of a user on
   **   a given proposal module
   */

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
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to find the SCIENCE_CODE for a given DESCRIPTION
   */

   PROCEDURE Get_Science_Code
   (
      p_check_id_flag IN VARCHAR2,
      p_description   IN VARCHAR2,
      p_science_code  IN VARCHAR2,
      x_science_code  OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to send notifications to a set of persons
   */

   TYPE person_list_type IS TABLE of NUMBER
   INDEX BY binary_integer;

   PROCEDURE Send_Notification
   (
      p_event         IN VARCHAR2,
      p_proposal_id   IN NUMBER,
      p_person_list   IN PERSON_LIST_TYPE,
      x_return_status OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   /*
   **   This API is used to copy proposal
   */


   PROCEDURE Copy_Proposal
   (
      p_old_proposal_id     IN NUMBER,
      p_new_proposal_number IN VARCHAR2,
      p_budget_copy_flag    IN VARCHAR2  := 'N',
      p_narrative_copy_flag IN VARCHAR2  := 'N',
      p_proposal_owner_id   IN NUMBER    := Fnd_Global.User_Id,
      x_new_proposal_id     OUT NOCOPY NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Utils;

 

/
