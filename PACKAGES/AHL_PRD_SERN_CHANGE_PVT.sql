--------------------------------------------------------
--  DDL for Package AHL_PRD_SERN_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_SERN_CHANGE_PVT" AUTHID CURRENT_USER AS
  /* $Header: AHLVSNCS.pls 120.2 2008/03/05 23:29:59 adivenka ship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

TYPE Sernum_Change_Rec_Type IS RECORD (
          WORKORDER_ID              NUMBER           ,
          JOB_NUMBER                VARCHAR2(80)     ,
          ITEM_NUMBER               VARCHAR2(40)     ,
          NEW_ITEM_NUMBER           VARCHAR2(40)     ,
          NEW_LOT_NUMBER            VARCHAR2(30)     ,
          NEW_ITEM_REV_NUMBER       VARCHAR2(3)      ,
          OSP_LINE_ID               NUMBER           ,
          INSTANCE_ID               NUMBER           ,
          CURRENT_SERIAL_NUMBER     VARCHAR2(30)     ,
          CURRENT_SERAIL_TAG        VARCHAR2(80)     ,
          NEW_SERIAL_NUMBER         VARCHAR2(30)     ,
          NEW_SERIAL_TAG_CODE       VARCHAR2(30)     ,
          NEW_SERIAL_TAG_MEAN       VARCHAR2(80)
          );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Sernum_Change_Tbl_Type IS TABLE OF Sernum_Change_Rec_Type INDEX BY BINARY_INTEGER;

-- Function to Get Serial Tag Code
FUNCTION get_serialtag_code
(
  p_instance_id    IN NUMBER
) RETURN VARCHAR2;
--Function to get Serial Tag Meaning
FUNCTION get_serialtag_meaning
(
   p_instance_id  IN NUMBER
) RETURN VARCHAR2;

-- Start of Comments --
--  Procedure name    : Process_Serialnum_Change
--  Type        : Private
--  Function    :
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Serialnum_Change Parameters :
--  p_serialnum_change_rec              IN        Serialnum_Change_Rec_Type, Required
--  Adithya added the x_warning_msg_tbl parameter: Bug# 6723950
--  x_warning_msg_tbl                   OUT       ahl_uc_validation_pub.error_tbl_type
--         List of Part number change attributes
PROCEDURE Process_Serialnum_Change (
    p_api_version           IN               NUMBER,
    p_init_msg_list         IN               VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN               VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_serialnum_change_rec  IN             Sernum_Change_Rec_Type,
    x_return_status         OUT  NOCOPY      VARCHAR2,
    x_msg_count             OUT  NOCOPY      NUMBER,
    x_msg_data              OUT  NOCOPY      VARCHAR2,
    --Adithya added the x_warning_msg_tbl parameter: Bug# 6683990
    x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

END AHL_PRD_SERN_CHANGE_PVT;

/
