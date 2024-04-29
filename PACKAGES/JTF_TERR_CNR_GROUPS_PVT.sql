--------------------------------------------------------
--  DDL for Package JTF_TERR_CNR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_CNR_GROUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcngs.pls 120.0 2005/06/02 18:22:08 appldev ship $ */

--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERR_CNR_GROUPS_PVT
--  ---------------------------------------------------
--  PURPOSE
--      Joint task force core territory CNR GROUPS private api's.
--      This package is a private API for inserting customer name
--      range (CNR) groups into JTF tables. It contains specification
--      for pl/sql records.
--
--  PROCEDURES:
--
--
--  NOTES
--    This package is for PRIVATE USE ONLY
--
--  HISTORY
--    01/29/01    ARPATEL         Created
--    05/16/01    ARPATEL         Added Record types: Terr_cnr_values_rec_type and Terr_cnr_values_out_rec_type
--                                Added API's for JTF_TERR_CNR_GROUP_VALUES.
--    04/25/02    ARPATEL         Removed security_group_id references.
--
--    End of Comments
--

  TYPE Terr_cnr_group_rec_type     IS RECORD
    (
      CNR_GROUP_ID               NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE           DATE         , -- := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY            NUMBER       , -- := FND_API.G_MISS_NUM,
      CREATION_DATE              DATE         , -- := FND_API.G_MISS_DATE,
      CREATED_BY                 NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN          NUMBER       , -- := FND_API.G_MISS_NUM,
      NAME                       VARCHAR2(255), -- := FND_API.G_MISS_CHAR,
      DESCRIPTION                VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE_CATEGORY         VARCHAR2(30) , -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE1                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                 VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                VARCHAR2(150), -- := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                VARCHAR2(150)  -- := FND_API.G_MISS_CHAR
    );

  G_MISS_TERR_CNR_GROUP_REC        Terr_cnr_group_rec_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory Resource out Record: Terr_cnr_group_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--       CNR_GROUP_ID                  Customer name group id
--       RETURN_STATUS                 Status
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


  TYPE Terr_cnr_group_out_rec_type   IS RECORD
    (
      CNR_GROUP_ID                 NUMBER,        --:= FND_API.G_MISS_NUM,
      RETURN_STATUS                VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

  G_MISS_TERR_CNR_GROUP_OUT_REC      Terr_cnr_group_out_rec_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory Resource in Record: Terr_cnr_group_values_rec_type
--    -----------------------------------------------------------
-- End of Comments

  TYPE Terr_cnr_values_rec_type     IS RECORD
    (
      CNR_GROUP_VALUE_ID         NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE           DATE         , -- := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY            NUMBER       , -- := FND_API.G_MISS_NUM,
      CREATION_DATE              DATE         , -- := FND_API.G_MISS_DATE,
      CREATED_BY                 NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN          NUMBER       , -- := FND_API.G_MISS_NUM,
      CNR_GROUP_ID               NUMBER       , -- := FND_API.G_MISS_NUM,
      COMPARISON_OPERATOR        VARCHAR2(30) , -- := FND_API.G_MISS_CHAR,
      LOW_VALUE_CHAR             VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      HIGH_VALUE_CHAR            VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      START_DATE_ACTIVE          DATE         , -- := FND_API.G_MISS_DATE,
      END_DATE_ACTIVE            DATE         , -- := FND_API.G_MISS_DATE,
      ORG_ID                     NUMBER         -- := FND_API.G_MISS_NUM
    );

    G_MISS_TERR_CNR_VALUES_REC        Terr_cnr_values_rec_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory Resource out Record: Terr_cnr_group_values_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--       CNR_GROUP_ID                  Customer name range group value id
--       RETURN_STATUS                 Status
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


  TYPE Terr_cnr_values_out_rec_type   IS RECORD
    (
      CNR_GROUP_VALUE_ID          NUMBER,       --:= FND_API.G_MISS_NUM,
      RETURN_STATUS                VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

  G_MISS_TERR_CNR_VALUES_OUT_REC      Terr_cnr_values_out_rec_type;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To create CNR groupings.
--
--    Pre-reqs  :
--
--    End of Comments
--

  PROCEDURE Create_Terr_Cnr_Group
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_Terr_cnr_group_rec          IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC,
      x_Terr_cnr_group_out_rec      OUT NOCOPY Terr_cnr_group_out_rec_type
    );

  PROCEDURE Create_Terr_Cnr_Value
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_Terr_cnr_values_rec         IN  Terr_cnr_values_rec_type    := G_MISS_TERR_CNR_VALUES_REC,
      x_Terr_cnr_values_out_rec     OUT NOCOPY Terr_cnr_values_out_rec_type
    );




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To delete CNR groups
--
--    Pre-reqs  :
--    Notes:
--          Rules for deletion have to be very strict
--
--    End of Comments
--

  PROCEDURE Delete_Terr_Cnr_Group
    (
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status           OUT NOCOPY VARCHAR2,
      X_Msg_Count               OUT NOCOPY NUMBER,
      X_Msg_Data                OUT NOCOPY VARCHAR2,
      p_Terr_cnr_group_rec      IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC
    );

  PROCEDURE Delete_Terr_Cnr_Value
    (
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status           OUT NOCOPY VARCHAR2,
      X_Msg_Count               OUT NOCOPY NUMBER,
      X_Msg_Data                OUT NOCOPY VARCHAR2,
      p_Terr_cnr_values_rec     IN  Terr_cnr_values_rec_type    := G_MISS_TERR_CNR_VALUES_REC
    );




--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To Update customer name range groupings.
--
--    Pre-reqs  :
--    End of Comments
--

  PROCEDURE Update_Terr_Cnr_Group
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_Terr_cnr_group_rec          IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC,
      x_Terr_cnr_group_out_rec      OUT NOCOPY Terr_cnr_group_out_rec_type
    );

  PROCEDURE Update_Terr_Cnr_Value
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_Terr_cnr_values_rec         IN  Terr_cnr_values_rec_type    := G_MISS_TERR_CNR_VALUES_REC,
      x_Terr_cnr_values_out_rec     OUT NOCOPY Terr_cnr_values_out_rec_type
    );



--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Validate_Cnr_Group_Value_Rec
--    Type      : PUBLIC
--    Function  : To Validate CNR group values.
--
--    Pre-reqs  :
--    End of Comments
--

    PROCEDURE Validate_Cnr_Group_Value_Rec
  (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_DML_Operation               IN  VARCHAR2,
      p_Terr_cnr_group_rec          IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC
    );

-- Package spec
END JTF_TERR_CNR_GROUPS_PVT;

 

/
