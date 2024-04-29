--------------------------------------------------------
--  DDL for Package CSP_PC_FORM_PICKHEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PC_FORM_PICKHEADERS" AUTHID CURRENT_USER AS
/* $Header: cspgtphs.pls 115.8 2002/11/26 06:46:50 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PC_FORM_PICKHEADERS
-- Purpose          : A wrapper to prepare data to call the update, delete and insert procedures of the
--                    CSP_picklist_header_PVT.
-- History          :
--  17-Dec-99, klou.
--
-- NOTE             :
-- End of Comments


PROCEDURE Validate_And_Write (
       P_Api_Version_Number      IN        NUMBER,
       P_Init_Msg_List           IN        VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN        VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_action_code             IN        NUMBER,
       px_picklist_header_id       IN  OUT NOCOPY    NUMBER,
       p_CREATED_BY                IN      NUMBER := FND_API.G_MISS_NUM,
       p_CREATION_DATE             IN      DATE := FND_API.G_MISS_DATE,
       p_LAST_UPDATED_BY           IN      NUMBER := FND_API.G_MISS_NUM,
       p_LAST_UPDATE_DATE          IN      DATE := FND_API.G_MISS_DATE,
       p_LAST_UPDATE_LOGIN         IN      NUMBER := FND_API.G_MISS_NUM,
       p_ORGANIZATION_ID           IN      NUMBER := FND_API.G_MISS_NUM,
       p_PICKLIST_NUMBER           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_PICKLIST_STATUS           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_DATE_CREATED              IN      DATE := FND_API.G_MISS_DATE,
       p_DATE_CONFIRMED            IN      DATE := FND_API.G_MISS_DATE,
       p_ATTRIBUTE_CATEGORY        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE1                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE2                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE3                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE4                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE5                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE6                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE7                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE8                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE9                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE10               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE11               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE12               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE13               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE14               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE15               IN      VARCHAR2,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    );

END CSP_PC_FORM_PICKHEADERS;

 

/
