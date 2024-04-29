--------------------------------------------------------
--  DDL for Package FPA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_SECURITY_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVSECS.pls 120.4 2005/09/01 07:44:01 appldev noship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'FPA_SECURITY_PVT';
--G_PORTF_ROLE_LIST_TYPE    CONSTANT VARCHAR2(200) := 'PROJECT_ADMINISTRATORS';

G_PORTFOLIO         CONSTANT VARCHAR2(80)     := 'PJP_PORTFOLIO';
G_PORTFOLIO_SET_ALL     CONSTANT VARCHAR2(80) := 'PJP_PORTFOLIO_SET';

G_VIEW_PORTFOLIO        CONSTANT VARCHAR2(80) := 'FPA_SEC_VIEW_PORTFOLIO';
G_UPDATE_PORTFOLIO      CONSTANT VARCHAR2(80) := 'FPA_SEC_UPDATE_PORTFOLIO';
G_MAINTAIN_PC           CONSTANT VARCHAR2(80) := 'FPA_SEC_MAINTAIN_PC';
G_COLLECT_PROJECT       CONSTANT VARCHAR2(80) := 'FPA_SEC_COLLECT_PROJECT';
G_DEVELOP_SCENARIO      CONSTANT VARCHAR2(80) := 'FPA_SEC_DEVELOP_SCENARIO';
G_APPROVE_PC            CONSTANT VARCHAR2(80) := 'FPA_SEC_APPROVE_PC';


G_OWNER                 CONSTANT VARCHAR2(200) := 'PORTFOLIO_OWNER';
G_ANALYST               CONSTANT VARCHAR2(200) := 'PORTFOLIO_ANALYST';
G_APPROVER              CONSTANT VARCHAR2(200) := 'PORTFOLIO_APPROVER';

/* ***********************************************************************
Desc: Call to check previlege on a portfolio
parameters: previlege checked for current fnd user for default p_person_id
return: 'T' for has grant, 'F' for no grant,
        'E' for exception and 'U' for unexpected error.
***************************************************************************/

FUNCTION Check_User_Previlege
(
   p_privilege      IN  VARCHAR2 DEFAULT  G_VIEW_PORTFOLIO,
   p_object_name    IN  VARCHAR2 DEFAULT G_PORTFOLIO,
   p_object_id      IN  NUMBER,
   p_person_id      IN  NUMBER DEFAULT NULL) RETURN VARCHAR2;


FUNCTION Check_Privilege
(
   p_privilege      IN  VARCHAR2 DEFAULT  G_VIEW_PORTFOLIO,
   p_object_name    IN  VARCHAR2 DEFAULT G_PORTFOLIO,
   p_object_id      IN  NUMBER,
   p_person_id      IN  NUMBER DEFAULT NULL) RETURN VARCHAR2;

/* ***********************************************************************
Desc:
parameters:
***************************************************************************/

FUNCTION Get_Owner
(p_portfolio_id   IN  NUMBER) RETURN NUMBER;

FUNCTION Get_Role_Id
(p_project_role   IN  PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_TYPE%TYPE DEFAULT G_OWNER)
RETURN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE;

/* ***************************************************************
Desc: Call to grant access to an User for a given Role.
parameters: p_object_id -> portfolio id
          p_object_type - > PJP_PORTFOLIO
          p_project_role_id - > role id from LOV 'Role'
          p_party_id -> person_id -> per_all_people_f.person_id.
          x_portfolio_party_id -> create portfolio party instance id
***************************************************************** */

PROCEDURE Create_Portfolio_User
(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_object_id             IN PA_PROJECT_PARTIES.OBJECT_ID%TYPE,
  p_instance_set_name     IN VARCHAR2 DEFAULT G_PORTFOLIO_SET_ALL,
  p_project_role_id       IN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE,
  p_party_id              IN NUMBER,
  p_start_date_active     IN DATE,
  p_end_date_active       IN DATE,
  x_portfolio_party_id    OUT NOCOPY PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);


/* ***************************************************************
Desc: Call to update both or either user/role.
parameters:
      p_portfolio_party_id -> pa_project_parties.project_party_id,
          p_project_role_id - > new role id from LOV 'Role' for update.
          p_party_id -> new hz_parties.party_id from LOV 'Name' for update.
***************************************************************** */

PROCEDURE Update_Portfolio_User
(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_portfolio_party_id    IN PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  p_project_role_id       IN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE,
  p_start_date_active     IN DATE,
  p_end_date_active       IN DATE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);

/* ***************************************************************
Desc:
parameters:
***************************************************************** */

PROCEDURE Update_Portfolio_Owner
(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  p_portfolio_id          IN NUMBER,
  p_person_id             IN NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);


/* ***************************************************************
Desc: Call to update both or either user/role.
parameters:
      p_portfolio_party_id -> pa_project_parties.project_party_id.
***************************************************************** */

PROCEDURE Delete_Portfolio_User
(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_portfolio_party_id    IN PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  p_instance_set_name     IN VARCHAR2 DEFAULT G_PORTFOLIO_SET_ALL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);


END FPA_SECURITY_PVT;

 

/
