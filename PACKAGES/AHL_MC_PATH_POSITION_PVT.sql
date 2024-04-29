--------------------------------------------------------
--  DDL for Package AHL_MC_PATH_POSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_PATH_POSITION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPOSS.pls 120.3 2008/02/29 07:53:40 sathapli ship $ */


---------------------------------
-- Define Record Type for Node --
---------------------------------
TYPE Path_Position_Rec_Type IS RECORD (
        PATH_POSITION_ID    NUMBER,
    OBJECT_VERSION_NUMBER   NUMBER,
    LAST_UPDATE_DATE    DATE,
    LAST_UPDATED_BY     NUMBER(15)  ,
    CREATION_DATE       DATE        ,
    CREATED_BY      NUMBER(15)  ,
    LAST_UPDATE_LOGIN   NUMBER(15),
    SEQUENCE        NUMBER         ,
    MC_ID           NUMBER         ,
    -- MC_NAME and MC_REVISION added by SATHAPLI on Feb 28, 2008 for bug 6845738
    MC_NAME             VARCHAR2(80),
    MC_REVISION         VARCHAR2(30),
    VERSION_NUMBER      NUMBER         ,
    POSITION_KEY        NUMBER         ,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)
        );


---------------------------------
-- Define Table Type for Node --
---------------------------------

TYPE Path_Position_Tbl_Type IS TABLE OF Path_Position_Rec_Type INDEX BY BINARY_INTEGER;


------------------------
-- Declare Procedures --
------------------------
--------------------------------
-- Start of Comments --
--  Procedure name    : Create_Position_ID
--  Type        : Private
--  Function    : API to create the new path position or if matches
--    existing one, return the existing path_position_id
--  Pre-reqs    :
--  Parameters  :
--
--  Create_Position_ID Parameters:
--   p_path_position_tbl IN   AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type Required
--   p_position_ref_meaning      IN VARCHAR2 Optional. Position ref for the path
--       p_position_ref_code  IN VARCHAR2 Optional, create based on pos
--             ref code. Used for copying positions.
--       x_position_id      OUT NUMBER. The created position or the
--             existing position id if there is a match.
--
--  End of Comments.

PROCEDURE Create_Position_ID (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_path_position_tbl   IN       AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
    p_position_ref_meaning  IN      VARCHAR2,
    p_position_ref_code  IN         VARCHAR2,
    x_position_id     OUT  NOCOPY    NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Instance_To_Positions
--  Type        : Private
--  Function    : Writes a list of positions that maps to instance
--     into AHL_APPLICABLE_INSTANCES
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Instance_To_Positions Parameters:
--       p_csi_item_instance_id  IN NUMBER  Required. instance for the path
--
--  End of Comments.

PROCEDURE Map_Instance_To_Positions (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_item_instance_id   IN         NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Position_To_Instance
--  Type        : Private
--  Function    : Writes a list of instances that maps to position path
--into AHL_APPLICABLE_INSTANCES
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Position_To_Instances Parameters:
--       p_position_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Map_Position_To_Instances (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id        IN            NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Instance_To_Pos_id
--  Type        : Private
--  Function    : For an instance map the position path and return
--     version specific path_pos_id. Reverse of the Get_Pos_Instance function
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Instance_To_Pos_id Parameters:
--       p_csi_item_instance_id  IN NUMBER  Required. instance for the pos
--       p_relationship_id IN NUMBER Optional. Used for empty position
--       x_path_position_id   OUT NUMBER  the existing or new path pos id
--
--  End of Comments.

PROCEDURE Map_Instance_To_Pos_ID (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_item_instance_id   IN         NUMBER,
    p_relationship_id        IN   NUMBER := FND_API.G_MISS_NUM,
    x_path_position_id    OUT NOCOPY  NUMBER);

----------------------------
-- Start of Comments --
--  Procedure name    : Get_Pos_Instance
--  Type        : Private
--  Function    : Returns the instance that maps to position path
--  Pre-reqs    :
--  Parameters  :
--
--  Get_Pos_Instance Parameters:
--       p_position_id      IN  NUMBER  Required
--       p_csi_item_instance_id  IN NUMBER  Required starting instance
--
--      x_item_instance_id the instance that the position_id + instance maps to
--            Returns the parent instance_id if the position is empty
--      x_relationship_id  returns the position relationship id for empty positions
--      x_lowest_uc_csi_id returns the leaf level UC id
--      x_mapping_status OUT VARCHAR2 Returns either NA (Not applicable),
--         EMPTY (Empty position) or MATCH (if matching instance found)
--  End of Comments.
PROCEDURE Get_Pos_Instance (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id        IN            NUMBER,
    p_csi_item_instance_id   IN         NUMBER,
    x_parent_instance_id  OUT NOCOPY   NUMBER,
    x_item_instance_id   OUT  NOCOPY    NUMBER,
    x_relationship_id   OUT NOCOPY NUMBER,
    x_lowest_uc_csi_id       OUT NOCOPY     NUMBER,
    x_mapping_status     OUT  NOCOPY     VARCHAR2);

-----------------------------
-- Start of Comments --
--  Procedure name    : Get_Pos_Instance
--  Type        : Private
--  Function    : Returns the instance that maps to position path
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Position_To_Instances Parameters:
--       p_position_id      IN  NUMBER  Required
--       p_csi_item_instance_id  IN NUMBER  Required starting instance
--
--     x_item_instance_id the instance that the position_id + instance maps to
--     x_lowest_uc_csi_id returns the leaf level UC id
--      x_mapping_status OUT VARCHAR2 Returns either NA (Not applicable),
--         EMPTY (Empty position) or MATCH (if matching instance found)
--  End of Comments.

PROCEDURE Get_Pos_Instance (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id        IN            NUMBER,
    p_csi_item_instance_id   IN         NUMBER,
    x_item_instance_id   OUT  NOCOPY    NUMBER,
    x_lowest_uc_csi_id       OUT NOCOPY     NUMBER,
    x_mapping_status     OUT  NOCOPY     VARCHAR2);


-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Positions_For_MC
--  Type        : Private
--  Function    : Copies all path positions for 1 MC to another MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Positions_For_MC Parameters:
--       p_from_mc_header_id      IN  NUMBER  Required
--   p_to_mc_header_id    IN NUMBER   Required
--
--  End of Comments.

PROCEDURE Copy_Positions_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
   p_from_mc_header_id        IN           NUMBER,
    p_to_mc_header_id         IN           NUMBER);


-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Position
--  Type        : Private
--  Function    : Copies 1 path positions to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Position
--       p_position_id      IN  NUMBER  Required
--   p_to_mc_header_id    IN NUMBER   Required
--   x_positioN_id       OUT NUMBER
--
--  End of Comments.

PROCEDURE Copy_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
   p_position_id          IN           NUMBER,
    p_to_mc_header_id         IN           NUMBER,
    x_position_id         OUT  NOCOPY    NUMBER);

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Positions_For_MC
--  Type        : Private
--  Function    : Deletes the Positions corresponding to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Positions_For_MC Parameters:
--       p_mc_header_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Positions_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_mc_header_id    IN           NUMBER);


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_by_id
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_position_id IN NUMBER the path position id
--       p_code_flag IN VARHCAR2 If Equal to FND_API.G_TRUE, then return
-- pos ref code, else return pos ref meaning. Default to False.
--
FUNCTION get_posref_by_id(
   p_path_position_ID    IN  NUMBER,
   p_code_flag           IN  VARCHAR2 := FND_API.G_FALSE)
RETURN VARCHAR2;  -- Position Ref Code

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_by_path
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_position_path_tbl IN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type Required
--       p_code_flag IN VARHCAR2 If Equal to FND_API.G_TRUE, then return
-- pos ref code, else return pos ref meaning. Default to False.
--
FUNCTION get_posref_by_path(
   p_path_position_tbl   IN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
   p_code_flag           IN VARCHAR2 := FND_API.G_FALSE
)
RETURN VARCHAR2;  -- Position Ref Code

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_for_uc
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_uc_header_id IN NUMBER UNIT CONFIG header id
--       p_relationship_id IN NUMBER position of subunit
--
FUNCTION get_posref_for_uc(
   p_uc_header_id        IN NUMBER,
   p_relationship_id     IN NUMBER
)
RETURN VARCHAR2;  -- Position Ref Meaning

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_encoded_path
--  Type        : Private
--  Function    : Fetches the position path encoding based on input
--  Pre-reqs    :
--  Parameters  :
--
--  get_encoded_path Parameters:
--       p_parent_path IN VARCHAR2. encoded parent position path
--       p_mc_id       IN NUMBER.
--       p_ver_num     IN NUMBER.
--       p_position_key IN NUMBER.
--       p_subconfig_flag IN BOOLEAN indicates whether this is new subconfig
--
FUNCTION get_encoded_path(
   p_parent_path    IN VARCHAR2,
   p_mc_id          IN NUMBER,
   p_ver_num        IN NUMBER,
   p_position_key   IN NUMBER,
   p_subconfig_flag IN VARCHAR2
)
RETURN VARCHAR2;  -- New encoded path

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: check_pos_ref_path
--  Type        : Private
--  Function    :
-- Check that the path from instance to to instance has position ref each step
-- and that position ref is not null for all relnships.
--  Pre-reqs    :
--  Parameters  : p_from_csi_id NUMBER the from instance id
--                p_to_csi_id NUMBER the instance id that it reaches
--
--
FUNCTION check_pos_ref_path(
   p_from_csi_id    IN NUMBER,
   p_to_csi_id      IN NUMBER)
RETURN BOOLEAN;

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: check_pos_ref_path_char
--  Type        : Private
--  Function    : Calls private function Check_pos_ref_path and returns
--                value as 'T' for Boolean TRUE and
--                'F' for Boolean False.
--  Pre-reqs    :
--  Parameters  : p_from_csi_id NUMBER the from instance id
--                p_to_csi_id NUMBER the instance id that it reaches
--
--
FUNCTION check_pos_ref_path_char(
   p_from_csi_id    IN NUMBER,
   p_to_csi_id      IN NUMBER)
RETURN VARCHAR2;


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: encode
--  Type        : Private
--  Function    :
-- Encodes the path position for the path position id
--  Pre-reqs    :
--  Parameters  : p_path_position_tbl path position information
--

FUNCTION Encode(
     p_path_position_tbl   IN  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
) RETURN VARCHAR2;


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: Is_Position_Serial_Controlled
--  Type         : Private
--  Function     : Cretaed for FP OGMA Issue# 105 - Non-Serialized Item Maintenance.
--                 Checks whether a position accepts a serialized item instance or not.
--                 Returns 'Y' if item group attached to the position has first associated item as serialized.
--                 Returns 'N' otherwise.
--  Pre-reqs     :
--  Parameters   : p_relationship_id  NUMBER relationship id
--                 p_path_position_id NUMBER path posiiton id
--
--                 If relationship id is passed, it will be taken to determine the result.
--                 Position id will be used only when relationship id is NULL.
--

FUNCTION Is_Position_Serial_Controlled(
    p_relationship_id    IN    NUMBER,
    p_path_position_id   IN    NUMBER
) RETURN VARCHAR2;

End AHL_MC_PATH_POSITION_PVT;

/
