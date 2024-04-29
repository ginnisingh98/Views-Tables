--------------------------------------------------------
--  DDL for Package CSD_TO_FORM_REPAIR_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_TO_FORM_REPAIR_HISTORY" AUTHID CURRENT_USER as
/* $Header: csdgdrhs.pls 115.8 2002/11/08 20:20:15 swai ship $ */
-- Start of Comments
-- Package name     : CSD_TO_FORM_REPAIR_HISTORY_B
-- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
--                    the prviate API in the CSP_MOVEORDER_HEADERS_PVT package.
-- History          : 11/17/1999, Created by Vernon Lou
-- NOTE             :
-- End of Comments


PROCEDURE Validate_And_Write (
      P_Api_Version_Number           IN   NUMBER,
      P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
      px_REPAIR_HISTORY_ID   OUT NOCOPY NUMBER ,
      p_OBJECT_VERSION_NUMBER    in NUMBER            := FND_API.G_MISS_NUM,
      p_REQUEST_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_APPLICATION_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_UPDATE_DATE    in DATE            := FND_API.G_MISS_DATE,
      p_CREATED_BY    in NUMBER                   := FND_API.G_MISS_NUM,
      p_CREATION_DATE   in  DATE                  := FND_API.G_MISS_DATE,
      p_LAST_UPDATED_BY   in  NUMBER     :=  FND_API.G_MISS_NUM,
      p_LAST_UPDATE_DATE    in DATE     :=  FND_API.G_MISS_DATE,
      p_REPAIR_LINE_ID    in NUMBER := FND_API.G_MISS_NUM,
      p_EVENT_CODE    in VARCHAR2,
      p_EVENT_DATE    in DATE,
      p_QUANTITY    in NUMBER    := FND_API.G_MISS_NUM,
      p_PARAMN1    in NUMBER    := FND_API.G_MISS_NUM,
      p_PARAMN2    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN3    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN4    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN5    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN6    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN7    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN8    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN9    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN10   in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMC1    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC2    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC3    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC4    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC5    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC6    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC7    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC8    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC9    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC10   in  VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMD1    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD2    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD3    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD4    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD5    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD6    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD7    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD8    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD9    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD10   in  DATE  := FND_API.G_MISS_DATE,
      p_ATTRIBUTE_CATEGORY    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE1    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE2    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE3    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE4    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE5    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE6    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE7    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE8    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE9    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE10    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE11    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE12    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE13    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE14    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE15    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_LAST_UPDATE_LOGIN    in NUMBER  := FND_API.G_MISS_CHAR,
      X_Return_Status              OUT NOCOPY  VARCHAR2  ,
      X_Msg_Count                  OUT NOCOPY  NUMBER ,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
     );
END CSD_TO_FORM_REPAIR_HISTORY;

 

/
