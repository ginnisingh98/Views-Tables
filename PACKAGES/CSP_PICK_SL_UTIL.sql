--------------------------------------------------------
--  DDL for Package CSP_PICK_SL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PICK_SL_UTIL" AUTHID CURRENT_USER AS
/* $Header: cspgtsls.pls 115.5 2002/11/26 06:09:09 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_Pick_SL_Util
-- Purpose          : A wrapper to prepare data to call the update, delete and insert procedures of the
--                    csp_pick_serial_lots_PVT.
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ------      ------------------------------------------
-- klou       01/28/00     Created.
--
-- NOTE             :
-- End of Comments

PROCEDURE Validate_And_Write (
       P_Api_Version_Number        IN        NUMBER,
       P_Init_Msg_List             IN        VARCHAR2     := FND_API.G_TRUE,
       P_Commit                    IN        VARCHAR2     := FND_API.G_FALSE,
       p_validation_level          IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_action_code               IN        NUMBER,
       px_PICKLIST_SERIAL_LOT_ID   IN OUT NOCOPY NUMBER,
       p_CREATED_BY                IN NUMBER,
       p_CREATION_DATE             IN DATE,
       p_LAST_UPDATED_BY           IN NUMBER,
       p_LAST_UPDATE_DATE          IN DATE,
       p_LAST_UPDATE_LOGIN         IN NUMBER,
       p_PICKLIST_LINE_ID          IN NUMBER,
       p_ORGANIZATION_ID           IN NUMBER,
       p_INVENTORY_ITEM_ID         IN NUMBER,
       p_QUANTITY                  IN NUMBER,
       p_LOT_NUMBER                IN VARCHAR2,
       p_SERIAL_NUMBER             IN VARCHAR2,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    );

END CSP_Pick_SL_Util;

 

/
