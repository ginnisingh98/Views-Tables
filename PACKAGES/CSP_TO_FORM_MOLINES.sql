--------------------------------------------------------
--  DDL for Package CSP_TO_FORM_MOLINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TO_FORM_MOLINES" AUTHID CURRENT_USER AS
/* $Header: cspgtmls.pls 115.8 2002/11/26 06:50:33 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_TO_FORM_MOLINES
-- Purpose          : A wrapper to prepare data to call the CSP_ORDERLINES_PVT.Create_orderlines.
-- History
--  18-Nov-1999: Created by Vernon Lou
--  03-Dev-1999: Modified because of change of schema by Vernon Lou.
--               Removed fields: p_address, p_service_request_number, p_mtl15_line_id, p_total_shipped.
--               Added fields: p_incident_id
-- NOTE             :
-- End of Comments


PROCEDURE Validate_and_Write(
          P_Api_Version_Number      IN        NUMBER,
          P_Init_Msg_List           IN        VARCHAR2     := FND_API.G_FALSE,
          P_Commit                  IN        VARCHAR2     := FND_API.G_FALSE,
          p_validation_level        IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_action_code             IN        NUMBER,
          P_line_id                 IN        NUMBER := FND_API.G_MISS_NUM,
          p_CREATED_BY              IN        NUMBER := FND_API.G_MISS_NUM,
          p_CREATION_DATE           IN        DATE := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY         IN        NUMBER := FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE        IN        DATE := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_LOGIN      IN        NUMBER := FND_API.G_MISS_NUM,
          p_HEADER_ID               IN        NUMBER := FND_API.G_MISS_NUM,
          p_CUSTOMER_PO             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_INCIDENT_ID             IN      NUMBER := FND_API.G_MISS_NUM,
          p_TASK_ID                 IN        NUMBER := FND_API.G_MISS_NUM,
          p_TASK_ASSIGNMENT_ID      IN        NUMBER := FND_API.G_MISS_NUM,
          p_COMMENTS                IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY      IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          X_Return_Status           OUT NOCOPY       VARCHAR2,
          X_Msg_Count               OUT NOCOPY       NUMBER,
          X_Msg_Data                OUT NOCOPY       VARCHAR2
    );

END CSP_TO_FORM_MOLINES;

 

/
