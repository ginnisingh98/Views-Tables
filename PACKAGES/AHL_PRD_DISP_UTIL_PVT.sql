--------------------------------------------------------
--  DDL for Package AHL_PRD_DISP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISP_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDIUS.pls 120.2 2008/01/29 14:05:24 sathapli ship $ */

---------------------------------
-- Define Record Type for Node --
---------------------------------
TYPE Disp_Type_Rec_Type IS RECORD (
      	CODE        VARCHAR2(30),
        MEANING       VARCHAR2(80));

TYPE Disp_Type_Tbl_Type IS TABLE OF Disp_Type_Rec_Type
   INDEX BY BINARY_INTEGER;

-- Start of Comments  --
-- Define Record Type for the filter structure in disposition overview page --
TYPE disp_filter_rec_type IS RECORD (
  path_position_id            NUMBER,
  path_position_ref           VARCHAR2(80),
  item_group_id               NUMBER,
  item_group_name             VARCHAR2(80),
  inv_item_id                 NUMBER,
  item_number                 VARCHAR2(40),
  condition_id                NUMBER,
  condition_code              VARCHAR2(80), --Actually not code, but meaning
  item_type_code              VARCHAR2(30),
  item_type                   VARCHAR2(80), --May not be used
  immediate_disp_code         VARCHAR2(30),
  immediate_disp              VARCHAR2(80), --May not be used
  secondary_disp_code         VARCHAR2(30),
  secondary_disp              VARCHAR2(80), --May not be used
  disp_status_code            VARCHAR2(30),
  disp_status                 VARCHAR2(80)); --May not be used
-- Define Record Type for the disposition list in disposition overview page --
TYPE disp_list_rec_type IS RECORD (
  disposition_id             NUMBER,
  part_change_id             NUMBER,
  path_position_id           NUMBER,
  path_position_ref          VARCHAR2(80),
  item_group_id              NUMBER,
  item_group_name            VARCHAR2(80),
  immediate_disp_code        VARCHAR2(30),
  immediate_disp             VARCHAR2(80),
  secondary_disp_code        VARCHAR2(30),
  secondary_disp             VARCHAR2(80),
  disp_status_code           VARCHAR2(30),
  disp_status                VARCHAR2(80),
  condition_id               NUMBER,
  condition_code             VARCHAR2(80),
  off_inv_item_id            NUMBER,
  off_item_number            VARCHAR2(120), --very rarely it will contains item_group_name
  off_instance_id            NUMBER,
  off_instance_number        VARCHAR2(30),
  off_serial_number          VARCHAR2(30),
  off_lot_number             MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
  off_quantity               NUMBER,
  off_uom                    VARCHAR2(3),
  on_inv_item_id             NUMBER,
  on_item_number             VARCHAR2(40),
  on_instance_id             NUMBER,
  on_instance_number         VARCHAR2(30),
  on_serial_number           VARCHAR2(30),
  on_lot_number              MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
  on_quantity                NUMBER,
  on_uom                     VARCHAR2(3));

-- Define Table Type for the disposition list in disposition overview page --
TYPE disp_list_tbl_type IS TABLE OF disp_list_rec_type INDEX BY BINARY_INTEGER;

-- Define procedure get_disposition_list
-- Procedure name: get_disposition_list
-- Type: Private
-- Function: API to get all dispositions for a job. This API is used  to replace the
--           disposition view which is too complicated to build
-- Pre-reqs:
--
-- Parameters:
--   p_workorder_id    IN NUMBER Required, to identify the job
--   p_start_row       IN NUMBER specify the start row to populate into search result table
--   p_rows_per_page   IN NUMBER specify the number of row to be populated in the search result table
--   p_disp_filter_rec IN disp_filter_rec_type, to store the record structure with which
--                        to restrict the disposition list result
--   x_results_count   OUT NUMBER, row count from the query, this number can be more than the
--                        number of row in search result table
--   x_disp_list_tbl   OUT disp_list_tbl_type, to store the disposition list result
-- Version: Initial Version   1.0
--
-- End of Comments  --

PROCEDURE get_disposition_list(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_workorder_id          IN  NUMBER,
  p_start_row             IN  NUMBER,
  p_rows_per_page         IN  NUMBER,
  p_disp_filter_rec       IN  disp_filter_rec_type,
  x_results_count         OUT NOCOPY NUMBER,
  x_disp_list_tbl         OUT NOCOPY disp_list_tbl_type);

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Get_Part_Change_Disposition
--  Type        : Private
--  Function    : Fetch the disposition for part change UI
--  Pre-reqs    :
--  Parameters  : p_parent_instance_id: parent csi item instance_id
--                p_workorder_id: workorder_id
--                p_unit_config_header_id: top unit header id
--                p_relationship_id: position for installation/removal
--                x_disposition_rec: returning disposition record
--                x_imm_disp_type_tbl: returning immediate disposition type
--                x_sec_disp_type_tbl: returning secondary dispositions
--
--                SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
--                p_instance_id: Added to support IB Trees. Pass the instance id to get the disposition for the given instance.
--
--
--  End of Comments.

PROCEDURE Get_Part_Change_Disposition (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_workorder_id          IN NUMBER,
    --p_unit_config_header_id IN NUMBER, replaced by p_workorder_id by Jerry on 09/20/04
    p_parent_instance_id    IN NUMBER,
    p_relationship_id       IN NUMBER,
    p_instance_id           IN NUMBER,
    x_disposition_rec     OUT NOCOPY AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    x_imm_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type,
    x_sec_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type);
-- Start of Comments --
--  Procedure name    : Create_Disp_Mtl_Requirement
--  Type              : Public
--  Function          : Public API to create a Material requirements for a Disposition.
--                      If the disposition has neither an item nor a Position Path, an
--                      exception is raised. If the disposition is for a position that is
--                      empty, this API gets the item group for the position and picks one
--                      item from the item group and creates a material requirement for that item.
--                      If the requirement was created successfully, a message is returned
--                      via x_msg_data indicating the item, the quantity and the UOM of the
--                      requirement created.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Create_Disp_Mtl_Requirement Parameters:
--      p_disposition_id                IN      NUMBER       Required
--         The Id of disposition for which to create the material requirement.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Disp_Mtl_Requirement (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2,
    p_disposition_id      IN           NUMBER
);

------------------------
-- Start of Comments --
--  Procedure name    : Get_Available_Disp_Types
--  Type        : Private
--  Function    : Fetch the available disposition types for given disposition
--  Pre-reqs    :
--  Parameters  : p_disposition_id: The disposition id to fetch against
--                x_imm_disp_type_tbl: returning immediate disposition type
--                x_sec_disp_type_tbl: returning secondary dispositions
--
--
--  End of Comments.

PROCEDURE Get_Available_Disp_Types (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_disposition_id        IN NUMBER,
    x_imm_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type,
    x_sec_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type);


-- Start of Comments --
--  Procedure name    : Create_SR_Disp_Link
--  Type              : Private
--  Function          : Private API to create a SR Link between the Disposition
--                      and the new SR object
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Create_SR_Disp_Link Parameters:
--      p_disposition_id                IN      NUMBER       Required
--      p_service_request_id            IN      Number       Required
--         The Id of disposition for which to create the material requirement.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_SR_Disp_Link (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2,
    p_service_request_id  IN           NUMBER,
    p_disposition_id      IN           NUMBER,
    x_link_id             OUT NOCOPY  NUMBER
);

-- Function to determine if the incident specified is the
-- primary Non Conformance for the disposition specified.
-- If it is the primary NC, 'Y' is returned.
-- If not, 'N' is returned.
-- 'N' is returned in case of any invalid inputs also.
FUNCTION Get_Primary_SR_Flag(p_disposition_id IN NUMBER,
                             p_incident_id    IN NUMBER)
RETURN VARCHAR2;

-- Function to get the Unit Config Header Id from the workorder Id
-- Tries to get the instance from the Workorder's Visit Task First.
-- If not possible, gets the instance from the Visit.
-- This instance is matched against top nodes of UCs and the matching
-- UC's header id is returned.
-- If no match is found, null is returned.
FUNCTION Get_WO_Unit_Id(p_workorder_id IN NUMBER)
RETURN NUMBER;

-- Function added by Jerry on 01/05/2005 for fixing bug 4093642
-- If the installation part change occurrs after the disposition was termindated,
-- then even if the removal part change against which the disposition was created,
-- is linked with this installation part change id, then this kind of link doesn't
-- make sense and we should break it
FUNCTION install_part_change_valid(p_disposition_id IN NUMBER)
RETURN VARCHAR2;

End AHL_PRD_DISP_UTIL_PVT;

/
