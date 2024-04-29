--------------------------------------------------------
--  DDL for Package AHL_UC_POS_NECES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_POS_NECES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVNECS.pls 120.1 2007/12/21 13:30:26 sathapli ship $ */


-----------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : List_Extra_Nodes
--  Type        	: Private
--  Function    	: List all the nodes in the unit configuration which are extra.
--                    i.e. with no corresponding position reference
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  List_Extra_Nodes parameters :
--  p_uc_header_id    	IN  NUMBER
--   			The header id of the unit configuration
--  p_csi_instance_id   IN  NUMBER
--   			If header id is null, then use p_csi_instance_id
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit has extra nodes or not.
-- p_x_error_table        IN OUT AHL_UC_POS_NECES_PVT.Error_Tbl_Type
--                      An output table with the list of all the extra nodes.
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE List_Extra_Nodes(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_csi_instance_id       IN NUMBER,
  p_x_error_table         IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Extra_Nodes
--  Type        	: Private
--  Function    	: Checks if there are any extra nodes in a unit configuration.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  check_extra_nodes parameters :
--  p_uc_header_id    	IN  Required
--   			The header id of the unit configuration
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit configuration
--                      has any extra nodes and returns 'T' ot 'F' accordingly.
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Extra_Nodes(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_evaluation_status     OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : List_Missing_Positions
--  Type        	: Private
--  Function    	: List all the mandatory positions that dont have instances mapped to it.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  list_missing_positions parameters :
--  p_uc_header_id    	IN  NUMBER
--   			The header id of the unit configuration
--  p_csi_instance_id   IN  NUMBER
--   			If header id is null, then use p_csi_instance_id
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit has any
--     missing positions
--  p_x_error_table   IN OUT lists all the error messages in a table.
--
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE List_Missing_Positions(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_csi_instance_id       IN NUMBER,
  p_x_error_table         IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Missing_Positions
--  Type        	: Private
--  Function    	:  checks if the unit config has any mandatory
--                    positions with no instances installed.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  list_missing_positions parameters :
--  p_uc_header_id    	IN  Required
--   			The header id of the unit configuration
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit configuration
--                      has any missing positions and returns 'T' ot 'F' accordingly.
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Missing_Positions(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_evaluation_status     OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name      : Validate_Position_Quantities
--  Type                : Private
--  Function            : This procedure was added for the FP OGMA Issue 105 to support Non Serialized Items.
--                        It validates the instance quantity against the position/item group.
--                        If there is a Quantity type rule at the Parent position, the floor validation
--                        is not done (Only ceiling validation is done). Since in this case the Rule
--                        overrides and obviates any need for Quantity validation and validating quantity
--                        based on position may actually contradict the rule.
--
--  Pre-reqs
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Validate_Position_Quantities Parameters :
--  p_uc_header_id                      IN      NUMBER     Conditionally Required
--                   The header id of the unit configuration. Not required if p_csi_instance_id is given.
--  p_csi_instance_id                   IN      NUMBER     Conditionally Required
--                   The instance where the Quantity needs to be checked.  Not required if p_uc_header_id is given.
--  x_evaluation_status                 OUT     VARCHAR2   The flag which indicates whether the unit has any Quantity mismatch.
--  p_x_error_table                     IN OUT  AHL_UC_POS_NECES_PVT.Error_Tbl_Type
--                   The output table with the list of Quantity based validation failures
--
--  History:
--    05-Dec-2007       SATHAPLI       Created
--
--  Version:
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Validate_Position_Quantities(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_TRUE,
  p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_uc_header_id          IN            NUMBER,
  p_csi_instance_id       IN            NUMBER,
  p_x_error_table         IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY    VARCHAR2);

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name      : Check_Position_Quantities
--  Type                : Private
--  Function            : This procedure was added for the FP OGMA Issue 105 to support Non Serialized Items.
--                        It checks the instance quantity against the position/item group.
--                        If there is a Quantity type rule at the Parent position, the floor check
--                        is not done (Only ceiling check is done). Since in this case the Rule
--                        overrides and obviates any need for Quantity check and checking quantity
--                        based on position may actually contradict the rule.
--
--  Pre-reqs
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Check_Position_Quantities Parameters :
--  p_uc_header_id                      IN      NUMBER                      Required
--                   The header id of the unit configuration.
--  x_evaluation_status                 OUT     VARCHAR2   The OUT flag which indicates whether the unit has any Quantity mismatch.
--
--  History:
--    05-Dec-2007       SATHAPLI       Created
--
--  Version:
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Position_Quantities(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_TRUE,
  p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_uc_header_id          IN            NUMBER,
  x_evaluation_status     OUT NOCOPY    VARCHAR2);

END AHL_UC_POS_NECES_PVT; -- Package spec

/
