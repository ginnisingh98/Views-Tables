--------------------------------------------------------
--  DDL for Package EGO_ITEM_AML_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_AML_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOITAMS.pls 115.8 2004/07/01 06:08:33 srajapar noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOITAMS.pls';

G_RET_STS_SUCCESS       CONSTANT  VARCHAR2(1)
                                     := FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR		CONSTANT  VARCHAR2(1)
                                     := FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR	CONSTANT  VARCHAR2(1)
                                     := FND_API.g_RET_STS_UNEXP_ERROR; --'U'
G_EGO_SHORT_YES          CONSTANT  VARCHAR2(1)   := 'Y';
G_EGO_SHORT_NO           CONSTANT  VARCHAR2(1)   := 'N';

-- =============================================================================
--                               Public Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:	          Check CM Existance
--
--  Type:               Public
--
--  Description:        To check whether ENG product is installed
--                      Returns 'S' if ENG is installed and active
--                      Returns 'E' in all other cases
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

FUNCTION Check_CM_Existance RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--  API Name:	          Implement_AML_Changes
--
--  Type:               Public
--
--  Description:        To Implement the AML Changes
--                      find the corresponding records in EGO_MFG_PART_NUM_CHGS
--                      and implement the same onto MTL_MFG_PART_NUMBERS
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

Procedure Implement_AML_Changes (
    p_api_version        IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2,
    p_commit             IN   VARCHAR2,
    p_change_id          IN   NUMBER,
    p_change_line_id     IN   NUMBER,
    x_return_status      OUT  NOCOPY VARCHAR2,
    x_msg_count          OUT  NOCOPY NUMBER,
    x_msg_data           OUT  NOCOPY VARCHAR2
  );

-- -----------------------------------------------------------------------------
--  API Name:	          Delete_AML_Pending_Changes
--
--  Type:               Public
--
--  Description:        To delete the pending change from EGO_MFG_PART_NUM_CHGS
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

Procedure Delete_AML_Pending_Changes
  (p_api_version          IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2
  ,p_commit               IN  VARCHAR2
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_mfg_part_num         IN  VARCHAR2
  ,p_change_id            IN  NUMBER
  ,p_change_line_id       IN  NUMBER
  ,p_acd_type             IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_msg_count           OUT  NOCOPY VARCHAR2
  ,x_msg_data            OUT  NOCOPY VARCHAR2
  );

-- -----------------------------------------------------------------------------
--  API Name:	          Check AML Policy Allowed
--
--  Type:               Public
--
--  Description:        To check whether the AML Changes are allowed
--                      on the given item in the reqd organization
--                      returns the status in x_return_status
--                      Returns 'Y' if the Policy is allowed
--                      Returns 'N' in all other cases
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

Procedure Check_AML_Policy_Allowed
  (p_api_version          IN  NUMBER
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_catalog_category_id  IN  NUMBER
  ,p_lifecycle_id         IN  NUMBER
  ,p_lifecycle_phase_id   IN  NUMBER
  ,p_allowable_policy     IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_policy_name         OUT  NOCOPY VARCHAR2
  ,x_item_number         OUT  NOCOPY VARCHAR2
  ,x_org_name            OUT  NOCOPY VARCHAR2
  );


-- -----------------------------------------------------------------------------
--  API Name:	         Check AML Privilege
--
--  Type:               Public
--
--  Description:        To check whether the user has the specified privilege
--                      on the given item in the reqd organization
--                      Returns 'Y' if the item can be edited
--                      Returns 'N' in all other cases
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

Function Check_No_AML_Priv
  (p_api_version          IN  NUMBER
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_privilege_name       IN  VARCHAR2
  ,p_party_id             IN  NUMBER  DEFAULT NULL
  ,p_user_id              IN  NUMBER  DEFAULT NULL
  ) RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--  API Name:	          Check_No_MFG_Associations
--
--  Type:	      	      Public
--
--  Description:        To check if any associations exist on the manufacturer
--                      Returns 'Y' if no associations exist
--                      Returns 'N' in all other cases
--                      The message_name changes for EGO and INV
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------
PROCEDURE Check_No_MFG_Associations
  (p_api_version          IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_manufacturer_name    IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_message_name        OUT  NOCOPY VARCHAR2
  ,x_message_text        OUT  NOCOPY VARCHAR2
  );


END EGO_ITEM_AML_PUB;


 

/
