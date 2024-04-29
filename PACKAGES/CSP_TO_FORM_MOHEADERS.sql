--------------------------------------------------------
--  DDL for Package CSP_TO_FORM_MOHEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TO_FORM_MOHEADERS" AUTHID CURRENT_USER AS
/*$Header: cspgtmhs.pls 115.19 2002/11/26 06:51:46 hhaugeru ship $*/
-- Start of Comments
-- Package name     : CSP_TO_FORM_MOMEAHDERS_B
-- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
--                    the prviate API in the CSP_MOVEORDER_HEADERS_PVT package.
-- History          : 11/17/1999, Created by Vernon Lou
-- NOTE             :
-- End of Comments


PROCEDURE Validate_And_Write(
      P_Api_Version_Number           IN   NUMBER,
      P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
      p_header_id                    IN   NUMBER := FND_API.G_MISS_NUM,
      p_created_by                   IN  NUMBER  := FND_API.G_MISS_NUM,
      p_creation_date                IN  DATE    := FND_API.G_MISS_DATE,
      p_last_updated_by              IN  NUMBER  := FND_API.G_MISS_NUM,
      p_last_update_date             IN  DATE    := FND_API.G_MISS_DATE,
      p_last_update_login            IN  NUMBER  := FND_API.G_MISS_NUM,
      p_carrier                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_shipment_method              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_autoreceipt_flag             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute_category           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute1                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute2                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute3                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute4                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute5                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute6                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute7                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute8                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute9                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute10                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute11                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute12                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute13                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute14                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute15                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_location_id                  IN   NUMBER   := FND_API.G_MISS_NUM,
      p_party_site_id                IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  NUMBER,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
      );
END CSP_TO_FORM_MOHEADERS;

 

/
