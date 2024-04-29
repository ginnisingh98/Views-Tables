--------------------------------------------------------
--  DDL for Package PV_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ASSIGNMENT_PUB" AUTHID CURRENT_USER as
/* $Header: pvxasgns.pls 120.5 2006/05/12 10:38:13 dhii noship $ */
/*#
 * This is the public interface that contains procedures that process both
 *  opportunity routing and partner and channel manager responses to routing assignments.
 *  Specifically, the interface contains procedures that handle the following opportunity assignment tasks:
 *  assignment of an opportunity to one or more partners; channel manager approval or rejection of an assignment;
 *  partner acceptance or rejection of an assignment; partner abandonment of an accepted assignment;
 *  and channel manager withdrawal of an assignment
 * @rep:scope public
 * @rep:product PV
 * @rep:displayname Opportunity Assignment
 * @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY PV_OPPORTUNITY
 */

-- Start of Comments

-- Package name     : PV_ASSIGNMENT_PUB
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--

-- person resource category

g_resource_party            CONSTANT VARCHAR2(30) := 'PARTY';
g_resource_employee         CONSTANT VARCHAR2(30) := 'EMPLOYEE';

-- organization type

g_vendor_org                CONSTANT VARCHAR2(30) := 'VENDOR';
g_external_org              CONSTANT VARCHAR2(30) := 'EXTERNAL';

-- assignment access codes

g_assign_access_view             CONSTANT VARCHAR2(20) := 'VIEW';
g_assign_access_update           CONSTANT VARCHAR2(20) := 'UPDATE';
g_assign_access_none             CONSTANT VARCHAR2(20) := 'NO_ACCESS';

-- Assignment statuses

 g_la_status_assigned            CONSTANT varchar2(20) := 'ASSIGNED';
 g_la_status_cm_rejected         CONSTANT varchar2(20) := 'CM_REJECTED';
 g_la_status_cm_added            CONSTANT varchar2(20) := 'CM_ADDED';
 g_la_status_cm_add_app_for_pt   CONSTANT varchar2(20) := 'CM_ADD_APP_FOR_PT';
 g_la_status_cm_approved         CONSTANT varchar2(20) := 'CM_APPROVED';
 g_la_status_cm_bypassed         CONSTANT varchar2(20) := 'CM_BYPASSED';
 g_la_status_cm_timeout          CONSTANT varchar2(20) := 'CM_TIMEOUT';
 g_la_status_cm_app_for_pt       CONSTANT varchar2(20) := 'CM_APP_FOR_PT';
 g_la_status_match_withdrawn     CONSTANT varchar2(20) := 'MATCH_WITHDRAWN';  -- to be added in code

 g_la_status_pt_created          CONSTANT varchar2(20) := 'PT_CREATED';
 g_la_status_pt_approved         CONSTANT varchar2(20) := 'PT_APPROVED';
 g_la_status_pt_rejected         CONSTANT varchar2(20) := 'PT_REJECTED';
 g_la_status_pt_timeout          CONSTANT varchar2(20) := 'PT_TIMEOUT';
 g_la_status_offer_withdrawn     CONSTANT varchar2(20) := 'OFFER_WITHDRAWN';  -- to be added in code
 g_la_status_lost_chance         CONSTANT varchar2(20) := 'LOST_CHANCE';
 g_la_status_pt_abandoned        CONSTANT varchar2(20) := 'PT_ABANDONED';
 -- vansub:rivendell
 g_la_status_active_withdrawn    CONSTANT varchar2(20) := 'ACTIVE_WITHDRAWN';
 -- vansub:rivendell

-- Assignment source types

 g_la_src_type_matching         CONSTANT varchar2(20) := 'MATCHING';


-- routing statuses

g_r_status_active                CONSTANT varchar2(20) := 'ACTIVE';
g_r_status_matched               CONSTANT varchar2(20) := 'MATCHED';
g_r_status_offered               CONSTANT varchar2(20) := 'OFFERED';
g_r_status_recycled              CONSTANT varchar2(20) := 'RECYCLED';
g_r_status_unassigned            CONSTANT varchar2(20) := 'UNASSIGNED';
g_r_status_withdrawn             CONSTANT varchar2(20) := 'WITHDRAWN';
g_r_status_abandoned             CONSTANT varchar2(20) := 'ABANDONED';
g_r_status_failed_auto           CONSTANT varchar2(20) := 'FAILED_AUTO_ASSIGN';


-- workflow statuses

g_wf_status_open                 CONSTANT varchar2(20) := 'OPEN';
g_wf_status_closed               CONSTANT varchar2(20) := 'CLOSED';


-- updateAssignment action modes

g_asgn_action_status_update      CONSTANT varchar2(20) := 'STATUS_UPDATE';
g_asgn_action_move_to_log        CONSTANT varchar2(20) := 'MOVE_TO_LOG';


-- updateAccess access type

G_CM_ACCESS                      CONSTANT NUMBER     := 1;
G_PT_ACCESS                      CONSTANT NUMBER     := 2;
G_PT_ORG_ACCESS                  CONSTANT NUMBER     := 3;


-- updateAccess access action

G_ADD_ACCESS                     CONSTANT NUMBER     := 1;
G_REMOVE_ACCESS                  CONSTANT NUMBER     := 2;


-- timeout types

g_matched_timeout                CONSTANT VARCHAR2(30) := 'MATCHED_TIMEOUT';
g_offered_timeout                CONSTANT VARCHAR2(30) := 'OFFERED_TIMEOUT';


-- notification types

g_notify_type_matched_to         CONSTANT VARCHAR2(30) := 'MATCHED_TO';
g_notify_type_offered_to         CONSTANT VARCHAR2(30) := 'OFFERED_TO';
g_notify_type_ptcr_fyi           CONSTANT VARCHAR2(30) := 'PTCR_FYI';
g_notify_type_behalf_of          CONSTANT VARCHAR2(30) := 'BEHALF_OF';
g_notify_type_abandoned_by       CONSTANT VARCHAR2(30) := 'ABANDONED_BY';
 -- vansub:rivendell
g_notify_type_withdrawn_by       CONSTANT VARCHAR2(30) := 'WITHDRAWN_BY';
 -- vansub:rivendell


-- pl/sql types

type g_number_table_type    is TABLE of number;
type g_varchar_table_type   is TABLE of varchar2(50);
type g_date_table_type      is TABLE of DATE;

type g_ref_cursor_type      is REF CURSOR;




/*#
* This procedure processes the assignment of opportunities to partners.
* This procedure is used when opportunity assignment is fully automated without user interaction,
*  and when a user initiates the assignment and uses a matching rule to identify partners or performs a
*  manual partner search. The procedure contains parameters that identify the assignment type
*  (for example, SERIAL or JOINT), whether or not channel manager approval is required,
*  the partners to whom the opportunity will be assigned, and the rule used for automatic matching (if in use).
* @param p_api_version_number Version of the API
* @param p_init_msg_list Indicator whether to initialize the message stack
* @param p_commit Indicator whether to commit within the program
* @param p_validation_level Indicator of FND validation levels
* @param p_entity Specifies the entity values are OPPORTUNITY or LEAD
* @param p_lead_id Opportunity ID
* @param p_creating_username User Name of the person initiating the assignment
* @param p_assignment_type Type of assignment values are SINGLE, SERIAL, JOINT or BROADCAST
* @param p_bypass_cm_ok_flag Flag to bypass channel manager approval for assignment
* @param p_partner_id_tbl List of partners whom the opportunity will be assigned
* @param p_rank_tbl List of rankings of partner
* @param p_partner_source_tbl List of sources through partner got into the system,values
*                             are MATCHING, SALESTEAM, TAP or CAMPAIGN
* @param p_process_rule_id Rule ID if it is a automatic matching
* @param x_return_status Status of the program
* @param x_msg_count Number of the messages returned by the program
* @param x_msg_data Return message by the program
* @rep:displayname Create Assignment
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/

procedure CreateAssignment (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity              IN  VARCHAR2,
   p_lead_id             in  NUMBER,
   p_creating_username   IN  VARCHAR2,
   p_assignment_type     in  VARCHAR2,
   p_bypass_cm_ok_flag   in  VARCHAR2,
   p_partner_id_tbl      in  JTF_NUMBER_TABLE,
   p_rank_tbl            in  JTF_NUMBER_TABLE,
   p_partner_source_tbl  in  JTF_VARCHAR2_TABLE_100,
   p_process_rule_id     in  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

/*#
* This procedure processes a channel manager's response to partner opportunity assignment
* and it is used when channel manager approval of opportunity assignment is required.
* @param p_api_version_number Version of the API
* @param p_init_msg_list Indicator whether to initialize the message stack
* @param p_commit Indicator whether to commit within the program
* @param p_validation_level Indicator of FND validation levels
* @param p_entity Specifies the entity values are OPPORTUNITY or LEAD
* @param p_user_name User Name of the Channel Manager Approving the Assignment
* @param p_lead_id Opportunity ID
* @param p_partyTbl List of partners whom the opportunity will be assigned
* @param p_rank_tbl List of rankings of partner
* @param p_statusTbl Channel Manager Response values are Approve, Reject , Approve on behalf of partner
* @param x_return_status Status of the program
* @param x_msg_count Number of the messages returned by the program
* @param x_msg_data Return message by the program
* @rep:displayname Create Assignment
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/
procedure process_match_response (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity              IN  VARCHAR2,
   p_user_name           IN  VARCHAR2,
   p_lead_id             IN  NUMBER,
   p_partyTbl            in  JTF_NUMBER_TABLE,
   p_rank_Tbl            in  JTF_NUMBER_TABLE,
   p_statusTbl           in  JTF_VARCHAR2_TABLE_100, -- CM_APPROVED,CM_REJECTED,CM_ADDED,NOACTION
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

/*#
* This procedure processes the partner's response to the opportunity assignment.
*
* @param p_api_version_number Version of the API
* @param p_init_msg_list Indicator whether to initialize the message stack
* @param p_commit Indicator whether to commit within the program
* @param p_validation_level Indicator of FND validation levels
* @param p_entity Specifies the entity, values are OPPORTUNITY or LEAD
* @param p_lead_id Opportunity ID
* @param p_partner_id Partner ID
* @param p_user_name User name of of partner
* @param p_pt_response Partner Response such as Approve/Reject
* @param p_reason_code Reason Code if partner is rejecting the assignment
* @param x_return_status Status of the program
* @param x_msg_count Number of the messages returned by the program
* @param x_msg_data Return message by the program
* @rep:displayname Create Assignment
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/
procedure PROCESS_OFFER_RESPONSE (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              IN  VARCHAR2
   ,p_lead_id             IN  number
   ,p_partner_id          IN  number
   ,p_user_name           IN  VARCHAR2
   ,p_pt_response         IN  varchar2
   ,p_reason_code         IN  varchar2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);

/*#
* This procedure is used when a channel manager withdraws an opportunity assignment from a partner.
* A channel manager can withdraw an opportunity either before or after a partner has accepted the opportunity.
* @param p_api_version_number Version of the API
* @param p_init_msg_list Indicator whether to initialize the message stack
* @param p_commit Indicator whether to commit within the program
* @param p_validation_level Indicator of FND validation levels
* @param p_entity Specifies the entity ,values are OPPORTUNITY or LEAD
* @param p_lead_id Opportunity ID
* @param p_user_name User Name of the Channel Manager withdrawing the Assignment
* @param x_return_status Status of the program
* @param x_msg_count Number of the messages returned by the program
* @param x_msg_data Return message by the program
* @rep:displayname Create Assignment
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/

procedure WITHDRAW_ASSIGNMENT (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              IN  VARCHAR2
   ,p_lead_id             IN  NUMBER
   ,p_user_name           IN  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);


/*#
* This procedure is used when a partner abandons an opportunity.
* A partner can abandon an opportunity only if it first accepted an opportunity.
* @param p_api_version_number Version of the API
* @param p_init_msg_list Indicator whether to initialize the message stack
* @param p_commit Indicator whether to commit within the program
* @param p_validation_level Indicator of FND validation levels
* @param p_entity Specifies the entity, values are OPPORTUNITY or LEAD
* @param p_lead_id Opportunity ID
* @param p_user_name User Name of the partner abandoning the Assignment
* @param p_reason_code Reason for abandoning
* @param x_return_status Status of the program
* @param x_msg_count Number of the messages returned by the program
* @param x_msg_data Return message by the program
* @rep:displayname Create Assignment
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/

procedure ABANDON_ASSIGNMENT (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              in  VARCHAR2
   ,p_lead_id             IN  NUMBER
   ,p_user_name           IN  VARCHAR2
   ,p_reason_code         IN  varchar2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);




End PV_ASSIGNMENT_PUB;

 

/
