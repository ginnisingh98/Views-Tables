--------------------------------------------------------
--  DDL for Package CSP_PC_FORM_PICKLINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PC_FORM_PICKLINES" AUTHID CURRENT_USER AS
/* $Header: cspgtpls.pls 115.6 2002/11/26 06:44:30 hhaugeru ship $ */
-- Start of Comments

-- Start of comments
--
-- API name	: CSP_PC_FORM_PICKLINES
-- Type 	: Type of API (Eg. Public, simple entity)
-- Purpose	: Wrapper for the picklist lines private procedure which calls table handlers
--
-- Modification History
-- Date        Userid    Comments
-- ---------   ------    ------------------------------------------
--
-- Note : Useful information goes here
--        And here
-- End of comments

  PROCEDURE Validate_And_Write
   (      P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
          px_PICKLIST_LINE_ID            IN OUT NOCOPY NUMBER,
          p_CREATED_BY                   IN   NUMBER  := FND_API.G_MISS_NUM,
          p_CREATION_DATE                IN   DATE    := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY              IN   NUMBER  := FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE             IN   DATE    := FND_API.G_MISS_DATE,
          p_LAST_UPDATE_LOGIN            IN   NUMBER  := FND_API.G_MISS_NUM,
          p_PICKLIST_LINE_NUMBER         IN   NUMBER  := FND_API.G_MISS_NUM,
          p_picklist_header_id           IN   NUMBER  := FND_API.G_MISS_NUM,
          p_LINE_ID                      IN   NUMBER  := FND_API.G_MISS_NUM,
          p_INVENTORY_ITEM_ID            IN   NUMBER  := FND_API.G_MISS_NUM,
          p_UOM_CODE                     IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_REVISION                     IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_QUANTITY_PICKED              IN   NUMBER    := FND_API.G_MISS_NUM,
          p_TRANSACTION_TEMP_ID          IN   NUMBER    := FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY           IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                   IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2);

END; -- Package spec

 

/
