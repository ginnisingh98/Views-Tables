--------------------------------------------------------
--  DDL for Package AHL_UTIL_UC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTIL_UC_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUUCS.pls 120.4 2008/03/11 05:49:46 jaramana ship $ */


---------------------------------------------
-- Define Record Type for Item Associations --
----------------------------------------------
TYPE Instance_Rec_Type IS RECORD (
        ITEM_GROUP_ID                   NUMBER,
        INVENTORY_ITEM_ID               NUMBER,
        INVENTORY_ORG_ID                NUMBER
       );

TYPE Instance_Tbl_Type IS TABLE OF Instance_Rec_Type INDEX BY BINARY_INTEGER;


------------------------------------------------
-- SATHAPLI::Bug# 4328454 fix
-- Define Record Type for Item Associations for
-- API AHL_UTIL_UC_PKG.Check_Invalidate_Instance
------------------------------------------------
TYPE Instance_Rec_Type2 IS RECORD (
        ITEM_GROUP_ID                   NUMBER,
        INVENTORY_ITEM_ID               NUMBER,
        INVENTORY_ORG_ID                NUMBER,
        CONCATENATED_SEGMENTS           VARCHAR2(40),
        REVISION                        VARCHAR2(3),
        INTERCHANGE_TYPE                VARCHAR2(80)
       );

TYPE Instance_Tbl_Type2 IS TABLE OF Instance_Rec_Type2 INDEX BY BINARY_INTEGER;


-- Define matched part-posn record structure.
TYPE matched_rec_type IS RECORD (
                object_id                    NUMBER,
                subject_id                   NUMBER,
                mc_relationship_id           NUMBER,
                csi_ii_relationship_id       NUMBER,
                csi_ii_object_version        NUMBER);


-- Define table for matched part-posn records.
TYPE matched_tbl_type IS TABLE OF matched_rec_type INDEX BY BINARY_INTEGER;

-----------------------------------------------------------
-- Function to get location description for csi instance --
-----------------------------------------------------------
FUNCTION GetCSI_LocationDesc(p_location_id           IN  NUMBER,
                             p_location_type_code    IN  VARCHAR2,
                             p_inventory_org_id      IN  NUMBER,
                             p_subinventory_name     IN  VARCHAR2,
                             p_inventory_locator_id  IN  NUMBER,
                             p_wip_job_id            IN  NUMBER)
RETURN VARCHAR2;

pragma restrict_references (GetCSI_LocationDesc, WNDS,WNPS, RNPS);


------------------------------------------------------
-- Function to get location code for a csi instance --
------------------------------------------------------
FUNCTION GetCSI_LocationCode(p_location_id           IN  NUMBER,
                             p_location_type_code    IN  VARCHAR2)

RETURN VARCHAR2;

pragma restrict_references (GetCSI_LocationCode, WNDS,WNPS, RNPS);


---------------------------------------------------------
-- Procedure to get CSI Transaction ID given the code  --
---------------------------------------------------------
PROCEDURE GetCSI_Transaction_ID(p_txn_code    IN         VARCHAR2,
                                x_txn_type_id OUT NOCOPY NUMBER,
                                x_return_val  OUT NOCOPY BOOLEAN);


----------------------------------------------------------
-- Procedure to get CSI Status ID given the status-name --
----------------------------------------------------------
PROCEDURE GetCSI_Status_ID (p_status_name  IN         VARCHAR2,
                            x_status_id    OUT NOCOPY NUMBER,
                            x_return_val   OUT NOCOPY BOOLEAN);


----------------------------------------------------------
-- Procedure to get CSI Status name given the status-id --
----------------------------------------------------------
PROCEDURE GetCSI_Status_Name (p_status_id      IN         NUMBER,
                              x_status_name    OUT NOCOPY VARCHAR2,
                              x_return_val     OUT NOCOPY BOOLEAN);


---------------------------------------------------------------------
-- Procedure to get extended attribute ID given the attribute code --
---------------------------------------------------------------------
PROCEDURE GetCSI_Attribute_ID (p_attribute_code  IN         VARCHAR2,
                               x_attribute_id    OUT NOCOPY NUMBER,
                               x_return_val      OUT NOCOPY BOOLEAN);


---------------------------------------------------------------------
-- Procedure to get extended attribute value given the attribute code --
---------------------------------------------------------------------
PROCEDURE GetCSI_Attribute_Value (p_csi_instance_id       IN  NUMBER,
                                  p_attribute_code        IN  VARCHAR2,
                                  x_attribute_value       OUT NOCOPY VARCHAR2,
                                  x_attribute_value_id    OUT NOCOPY NUMBER,
                                  x_object_version_number OUT NOCOPY NUMBER,
                                  x_return_val            OUT NOCOPY BOOLEAN);


------------------------------------------------
-- Procedure to validate csi_item_instance_id --
------------------------------------------------
PROCEDURE ValidateCSI_Item_Instance(p_instance_id         IN         NUMBER,
                                    x_status_name         OUT NOCOPY VARCHAR2,
                                    x_location_type_code  OUT NOCOPY VARCHAR2,
                                    x_return_val          OUT NOCOPY BOOLEAN);

------------------------------------------------------------------------
-- Procedure to return lookup meaning given the code from CSI_Lookups --
------------------------------------------------------------------------
PROCEDURE Convert_To_CSIMeaning (p_lookup_type     IN   VARCHAR2,
                                 p_lookup_code     IN   VARCHAR2,
                                 x_lookup_meaning  OUT  NOCOPY VARCHAR2,
                                 x_return_val      OUT  NOCOPY BOOLEAN);


----------------------------------------------------
-- Procedure to check existence of a relationship --
-- and if found, returns the position_ref_code    --
----------------------------------------------------
Procedure ValidateMC_Relationship(p_relationship_id   IN   NUMBER,
                                  x_position_ref_code OUT  NOCOPY VARCHAR2,
                                  x_return_val        OUT  NOCOPY BOOLEAN);



------------------------------------------------------------------------------
-- Procedure to validate if an inventory item can be assigned to a position --
-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Added p_ignore_quant_vald parameter to allow the quantity checks to be ignored when called from Production.
------------------------------------------------------------------------------
PROCEDURE Validate_for_Position(p_mc_relationship_id   IN   NUMBER,
                                p_Inventory_id         IN   NUMBER,
                                p_Organization_id      IN   NUMBER,
                                p_quantity             IN   NUMBER,
                                p_revision             IN   VARCHAR2,
                                p_uom_code             IN   VARCHAR2,
                                p_position_ref_meaning IN   VARCHAR2,
                                p_ignore_quant_vald    IN   VARCHAR2 := 'N',
                                x_item_assoc_id        OUT  NOCOPY NUMBER);


-------------------------------------------------------
-- Procedure to check if item assigned to a position --
-------------------------------------------------------
PROCEDURE Check_Position_Assigned (p_csi_item_instance_id   IN  NUMBER,
                                   p_mc_relationship_id     IN  NUMBER,
                                   x_subject_id             OUT NOCOPY NUMBER,
                                   x_return_val             OUT NOCOPY BOOLEAN);

-----------------------------------------------------------------------
-- Function will validate if an item is valid for a position or not. --
-- It is designed mainly to be used in SQL and views definitions.    --
-- IT WILL IMPLICITLY INITIALIZE THE ERROR MESSAGE STACK.            --
-- This will call Validate_for_Position procedure and will return :  --
--   ahl_item_associations.item_association_id that has been matched --
--   else if no record matched, it will return 0(zero).              --
-- OBSOLETED 10/24/2002.
-----------------------------------------------------------------------
FUNCTION  Validate_Alternate_Item (p_mc_relationship_id   IN   NUMBER,
                                   p_Inventory_id         IN   NUMBER,
                                   p_Organization_id      IN   NUMBER,
                                   p_quantity             IN   NUMBER,
                                   p_revision             IN   VARCHAR2,
                                   p_uom_code             IN   VARCHAR2) RETURN NUMBER;


----------------------------------------------------------------------------------
-- Procedure to match the parts sub-tree(starting with p_csi_item_instance_id) --
-- with the master config tree (starting with p_mc_relationship_id)            --
-- If the tree matches, x_match_flag returns true else it returns false. The   --
-- error messages are written to the error stack.                              --
----------------------------------------------------------------------------------
/*  comment out by Jerry on 09/16/2004 for bug 3893965
PROCEDURE Match_Tree_Components (p_csi_item_instance_id  IN         NUMBER,
                                 p_mc_relationship_id    IN         NUMBER,
                                 x_match_part_posn_tbl   OUT NOCOPY AHL_UTIL_UC_PKG.matched_tbl_type,
                                 x_match_flag            OUT NOCOPY BOOLEAN);

*/
--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Invalidate_Instance
--  Type            : Private
--  Function        : Removes the reference to an Instance that has been deleted
--                    or referenced from an Item Group.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Invalidate_Instance parameters :
--  p_instance_table    IN  Instance_Tbl_Type
--              A table of inv item id, inv org id and item_group_id
--
--  History:
--      06/03/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Invalidate_Instance(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_instance_tbl          IN  Instance_Tbl_Type
);

-- Function to get the Status (Meaning) of a Unit Configuration
-- This function considers if the unit is installed in another unit, if it is expired etc.
-- It returns the concatenation of the status with the active status if the status
-- ic Complete or Incomplete
FUNCTION Get_UC_Status(p_uc_header_id IN NUMBER)
RETURN VARCHAR2;

-- Added by Jerry on 03/29/2005 in order for fixing a VWP bug 4251688(Siberian)
-- Function to get the Status (code) of a Unit Configuration
-- This function considers if the unit is installed in another unit, if it is expired etc.
-- This function is similar to the previous one but this one returns code instead of
-- meaning. It doesn't check the active status.
FUNCTION Get_UC_Status_code(p_uc_header_id IN NUMBER)
RETURN VARCHAR2;

-- Define Procedure copy_uc_header_to_history --
-- This common utility API is used to copy a UC header to history table whenever this UC is just newly created
-- or updated
PROCEDURE copy_uc_header_to_history (
  p_uc_header_id          IN  NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2
);
--  Start of Comments  --
--
--  Procedure name  : copy_uc_header_to_history
--  Type            :
--  Function        : to copy a UC header to UC header history table.
--  Pre-reqs        :
--
--  migrate_uc_tree parameters :
--  p_uc_header_id     IN NUMBER  Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments  --

-- Define Procedure get_root_uc_attr --
-- This common utility is used to get the root UC's basic attributes for this particular UC
PROCEDURE get_root_uc_attr(
  p_uc_header_id          IN  NUMBER,
  x_uc_header_id          OUT NOCOPY NUMBER,
  x_instance_id           OUT NOCOPY NUMBER,
  x_uc_status_code        OUT NOCOPY VARCHAR2,
  x_active_uc_status_code OUT NOCOPY VARCHAR2,
  x_uc_header_ovn         OUT NOCOPY NUMBER);

--  Start of Comments  --
--
--  Procedure name  : get_root_uc_status_code
--  Type            :
--  Function        : to get the root UC's basic attributes for this particular UC
--  Pre-reqs        :
--
--  migrate_uc_tree parameters :
--  p_uc_header_id     IN NUMBER  Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments  --

-- Define Function extra_node --
-- This common utility is used to check whether a given instance is an extra node
FUNCTION extra_node(p_instance_id IN NUMBER, p_top_instance_id NUMBER) RETURN BOOLEAN;

--  Start of Comments  --
--
--  Procedure name  : extra_node
--  Type            :
--  Function        : to check whether a given instance is an extra node
--  Pre-reqs        :
--
--  migrate_uc_tree parameters :
--  p_instance_id     IN NUMBER  Required
--  p_top_instance_id IN NUMBER  Required, the instance_id of the top node in which p_instance_id
--                               is installed
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments  --

-- Define Function item_match --
-- This common utility is used to check whether a given item can be assigned to
-- a given position in MC
FUNCTION item_match(p_mc_relationship_id   IN   NUMBER,
                    p_inventory_item_id    IN   NUMBER,
                    p_organization_id      IN   NUMBER,
                    p_revision             IN   VARCHAR2,
                    p_quantity             IN   NUMBER,
                    p_uom_code             IN   VARCHAR2)
RETURN BOOLEAN;
--  Start of Comments  --
--
--  Procedure name  : extra_node
--  Type            :
--  Function        : to check whether a given instance is an extra node
--  Pre-reqs        :
--
--  migrate_uc_tree parameters :
--  p_mc_relationship_id     IN NUMBER  Required
--  p_inventory_item_id      IN NUMBER  Required
--  p_organization_id        IN NUMBER  Required
--  p_quantity               IN NUMBER  Required
--  p_uom_code               IN NUMBER  Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments  --

-- Define procedure get_parent_uc_header --
-- This common utility is used to get the parent uc_header_id and parent instance_id
-- for a given instance_id. This procedure always returns the parent uc_header_id and
-- the instance_id of the parent_uc_header_id (not necessary to be the immediated parent
-- instance_id of itself). If the given instance happens to be a standalone unit instance,
-- then both the return variables will be null.
PROCEDURE get_parent_uc_header(p_instance_id           IN  NUMBER,
                               x_parent_uc_header_id   OUT NOCOPY NUMBER,
                               x_parent_uc_instance_id OUT NOCOPY NUMBER);
--  Start of Comments  --
--
--  Procedure name  : get_parent_uc_header
--  Type            :
--  Function        : to get the parent uc_header_id for a given instance_id
--  Pre-reqs        :
--
--  get_parent_uc_header parameters :
--  p_instance_id            IN NUMBER  Required
--  x_parent_uc_header_id    OUT NUMBER
--  x_parent_uc_instance_id  OUT NUMBER
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments  --

------------------------------------------------------
-- Function to map an instance id to a relationship id
------------------------------------------------------
FUNCTION Map_Instance_to_RelID(p_csi_ii_id           IN  NUMBER)
RETURN NUMBER;

-- Define procedure get_unit_name --
-- This common utility is used to get the root unit name for a given instance_id
-- The unit name is the highest standalone UC name to which the instance_id belongs.
-- IF the instance happens to be the root unit instance, then return the unit name
-- of itself
FUNCTION get_unit_name(p_instance_id  IN  NUMBER) RETURN VARCHAR2;
--  Start of Comments  --
--
--  Procedure name: get_unit_name
--  Type:
--  Function: to get the root unit name for a given instance_id
--  Pre-reqs:
--
--  Parameters:
--    p_instance_id     IN NUMBER  Required
--
--  Version:
--    Initial Version   1.0
--
--  End of Comments  --

-- Define procedure get_uc_header_id --
-- This common utility is used to get the root uc_header_id for a given instance_id
-- The uc_header_id is the highest standalone unit to which the instance belongs.
-- IF the instance happens to be the root unit instance, then return the uc_header_id
-- of itself
FUNCTION get_uc_header_id(p_instance_id  IN  NUMBER) RETURN NUMBER;
--  Start of Comments  --
--
--  Procedure name: get_uc_header_id
--  Type:
--  Function: to get the root uc_header_id for a given instance_id
--  Pre-reqs:
--
--  Parameters:
--    p_instance_id     IN NUMBER  Required
--
--  Version:
--    Initial Version   1.0
--
--  End of Comments  --

-- Define function get_sub_unit_name --
-- This common utility is used to get the sub unit name for a given instance_id
-- The unit name is the lowest sub UC name to which the instance_id belongs.
-- IF the instance happens to be the sub unit instance, then return the sub unit name
-- of itself
FUNCTION get_sub_unit_name(p_instance_id  IN  NUMBER) RETURN VARCHAR2;
--  Start of Comments  --
--
--  Procedure name: get_sub_unit_name
--  Type:
--  Function: to get the lowerest sub unit name for a given instance_id
--  Pre-reqs:
--
--  Parameters:
--    p_instance_id     IN NUMBER  Required
--
--  Version:
--    Initial Version   1.0
--
--  End of Comments  --

-- Define function get_sub_uc_header_id --
-- This common utility is used to get the sub uc_header_id  for a given instance_id
-- The uc_header_id is the lowest sub uc_header_id to which the instance_id belongs.
-- IF the instance happens to be the sub unit instance, then return the sub uc_header_id
-- of itself
FUNCTION get_sub_uc_header_id(p_instance_id  IN  NUMBER) RETURN VARCHAR2;
--  Start of Comments  --
--
--  Procedure name: get_sub_uc_header_id
--  Type:
--  Function: to get the lowerest sub uc_header_id of a given instance_id
--  Pre-reqs:
--
--  Parameters:
--    p_instance_id     IN NUMBER  Required
--
--  Version:
--    Initial Version   1.0
--
--  End of Comments  --

--  ACL :: Added for R12 changes.
FUNCTION IS_UNIT_QUARANTINED(p_unit_header_id IN NUMBER, p_instance_id IN NUMBER) RETURN VARCHAR2;
--  Start of Comments  --
--
--  Procedure name: IS_UNIT_QUARANTINED
--  Type:
--  Function: This API will return FND_API.G_TRUE if a UC is in Quarantine or Deactivate
--            Quarantine Status
--
--  Parameters:
--    p_unit_header_id  IN NUMBER
--    p_instance_id     IN NUMBER
--
--  Version:
--    Initial Version   1.0
--
--  End of Comments  --

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Invalidate_Instance
--  Type            : Private
--  Function        : Validates the updation of interchange_type_code in an item group
--                    against active UCs where the item is installed.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version                IN      NUMBER     Required
--      p_init_msg_list              IN      VARCHAR2   Default  FND_API.G_TRUE
--      p_commit                     IN      VARCHAR2   Default  FND_API.G_FALSE
--      p_validation_level           IN      NUMBER     Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status              OUT     VARCHAR2   Required
--      x_msg_count                  OUT     NUMBER     Required
--      x_msg_data                   OUT     VARCHAR2   Required
--
--  Check_Invalidate_Instance parameters :
--      p_instance_table             IN      Instance_Tbl_Type2
--      A table of inv item id, inv org id, item_group_id, item name, item rev and
--      item interchange type
--
--  History:
--      07-JUN-06       SATHAPLI       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Invalidate_Instance
          (
            p_api_version           IN  NUMBER,
            P_INIT_MSG_LIST         IN  VARCHAR2  := FND_API.G_TRUE,
            p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
            p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
            p_instance_tbl          IN  Instance_Tbl_Type2,
            p_operator              IN  VARCHAR2,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2
          );

-- Added by jaramana on March 10, 2008 for fixing the Bug 6723950 (FP of 6720010)
-- This API will validate if the instance can become the new item through part change.
-- p_instance_id can be currently in an IB Tree or UC or it may be a stand alone instance.
-- It may also be the root node of a unit.
-- The return value x_matches_flag will be FND_API.G_TRUE or FND_API.G_FALSE.
PROCEDURE Item_Matches_Instance_Pos(p_inventory_item_id  IN NUMBER,
                                    p_item_revision      IN VARCHAR2 default NULL,
                                    p_instance_id        IN NUMBER,
                                    x_matches_flag       OUT NOCOPY VARCHAR2);

END AHL_UTIL_UC_PKG;

/
