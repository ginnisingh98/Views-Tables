--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtrss.pls 120.4.12010000.2 2009/09/07 06:32:20 vpalle ship $ */

--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERRITORY_RESOURCE_PVT
--  ---------------------------------------------------
--  PURPOSE
--      Joint task force core territory resource private api's.
--      This package is a private API for inserting territory
--      resources into JTF tables. It contains specification
--      for pl/sql records and tables related to territory
--      resource.
--
--  PROCEDURES:
--       (see below for specification)
--
--  NOTES
--    This package is for PRIVATE USE ONLY use
--
--  HISTORY
--    06/09/99    VNEDUNGA         Created
--    06/09/99    VNEDUNGA         Adding full access column
--                                 to resource record
--    06/08/00    VNEDUNGA         Adding Full access flag
--
--    06/12/00    JDOCHERT         Added function (get_group_name)
--                                 to get the name
--                                 of the group that the resource
--                                 belongs to
--    07/08/00    JDOCHERT         Added default values for flags, for data migration
--
--    09/16/00    VVUYYURU         Added the procedure Copy_Terr_Resources
--
--    09/19/00    JDOCHERT         Added 'validate_terr_rsc_access_UK'
--                                 and 'Transfer_Resource_Territories' procedures
--
--    10/04/00    JDOCHERT         Added get_rs_type_name function
--
--    02/15/01    ARPATEL          Adapted 'Transfer_Resource_Territories' to allow mass updates
--
--    06/26/02    ARPATEL          Adding person_id column to TerrResource_rec_type
--    09/15/05	  mhtran	   added TRANS_ACCESS_CODE
--    End of Comments
--




--*******************************************************
--    Start of Comments
---------------------------------------------------------
--        Territory Resource Record: TerrResource_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--        TERR_RSC_ID                Database sequence
--        LAST_UPDATE_DATE           Part of std who columns
--        LAST_UPDATED_BY            Part of std who columns
--        CREATION_DATE              Part of std who columns
--        CREATED_BY                 Part of std who columns
--        LAST_UPDATE_LOGIN          Part of std who columns
--        TERR_ID                    Territory associated with resource
--        RESOURCE_ID                resource id
--        GROUP_ID                   group id
--        RESOURCE_TYPE              resource type, eg:SALES
--        ROLE                       role
--        PRIMARY_CONTACT_FLAG       Is this resource a primary contact
--        ORG_ID                     Organization Id
--		  TRANS_ACCESS_CODE			 access type
--    Defaults:
--    Note:
--
-- End of Comments

  TYPE TerrResource_rec_type     IS RECORD
    (
      TERR_RSC_ID                NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE           DATE         , -- := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY            NUMBER       , -- := FND_API.G_MISS_NUM,
      CREATION_DATE              DATE         , -- := FND_API.G_MISS_DATE,
      CREATED_BY                 NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN          NUMBER       , -- := FND_API.G_MISS_NUM,
      TERR_ID                    NUMBER       , -- := FND_API.G_MISS_NUM,
      RESOURCE_ID                NUMBER       , -- := FND_API.G_MISS_NUM,
      GROUP_ID                   NUMBER       , -- := FND_API.G_MISS_NUM,
      RESOURCE_TYPE              VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      ROLE                       VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      PRIMARY_CONTACT_FLAG       VARCHAR2(1)  := 'N', -- := FND_API.G_MISS_CHAR,
      START_DATE_ACTIVE          DATE         , -- := FND_API.G_MISS_DATE,
      END_DATE_ACTIVE            DATE         , -- := FND_API.G_MISS_DATE
      FULL_ACCESS_FLAG           VARCHAR2(01) := 'N', -- := FND_API.G_MISS_CHAR,
      ORG_ID                     NUMBER,         -- := FND_API.G_MISS_NUM,
      PERSON_ID                  NUMBER,
      -- Adding the attribute columns as fix for bug 7168485.
      ATTRIBUTE_CATEGORY         VARCHAR2(30),
      ATTRIBUTE1                 VARCHAR2(150),
      ATTRIBUTE2                 VARCHAR2(150),
      ATTRIBUTE3                 VARCHAR2(150),
      ATTRIBUTE4                 VARCHAR2(150),
      ATTRIBUTE5                 VARCHAR2(150),
      ATTRIBUTE6                 VARCHAR2(150),
      ATTRIBUTE7                 VARCHAR2(150),
      ATTRIBUTE8                 VARCHAR2(150),
      ATTRIBUTE9                 VARCHAR2(150),
      ATTRIBUTE10                VARCHAR2(150),
      ATTRIBUTE11                VARCHAR2(150),
      ATTRIBUTE12                VARCHAR2(150),
      ATTRIBUTE13                VARCHAR2(150),
      ATTRIBUTE14                VARCHAR2(150),
      ATTRIBUTE15                VARCHAR2(150)

    );

  TYPE TerrResource_rec_type_wflex     IS RECORD
    (
      TERR_RSC_ID                NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE           DATE         , -- := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY            NUMBER       , -- := FND_API.G_MISS_NUM,
      CREATION_DATE              DATE         , -- := FND_API.G_MISS_DATE,
      CREATED_BY                 NUMBER       , -- := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN          NUMBER       , -- := FND_API.G_MISS_NUM,
      TERR_ID                    NUMBER       , -- := FND_API.G_MISS_NUM,
      RESOURCE_ID                NUMBER       , -- := FND_API.G_MISS_NUM,
      GROUP_ID                   NUMBER       , -- := FND_API.G_MISS_NUM,
      RESOURCE_TYPE              VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      ROLE                       VARCHAR2(60) , -- := FND_API.G_MISS_CHAR,
      PRIMARY_CONTACT_FLAG       VARCHAR2(1)  := 'N', -- := FND_API.G_MISS_CHAR,
      START_DATE_ACTIVE          DATE         , -- := FND_API.G_MISS_DATE,
      END_DATE_ACTIVE            DATE         , -- := FND_API.G_MISS_DATE
      FULL_ACCESS_FLAG           VARCHAR2(01) := 'N', -- := FND_API.G_MISS_CHAR,
      ORG_ID                     NUMBER,         -- := FND_API.G_MISS_NUM,
      PERSON_ID                  NUMBER,
      ATTRIBUTE_CATEGORY         VARCHAR2(30),
      ATTRIBUTE1                 VARCHAR2(150),
      ATTRIBUTE2                 VARCHAR2(150),
      ATTRIBUTE3                 VARCHAR2(150),
      ATTRIBUTE4                 VARCHAR2(150),
      ATTRIBUTE5                 VARCHAR2(150),
      ATTRIBUTE6                 VARCHAR2(150),
      ATTRIBUTE7                 VARCHAR2(150),
      ATTRIBUTE8                 VARCHAR2(150),
      ATTRIBUTE9                 VARCHAR2(150),
      ATTRIBUTE10                VARCHAR2(150),
      ATTRIBUTE11                VARCHAR2(150),
      ATTRIBUTE12                VARCHAR2(150),
      ATTRIBUTE13                VARCHAR2(150),
      ATTRIBUTE14                VARCHAR2(150),
      ATTRIBUTE15                VARCHAR2(150)
    );

  G_MISS_TERRRESOURCE_REC        TerrResource_rec_type;
  G_MISS_TERRRESOURCE_REC_WFLEX  TerrResource_rec_type_wflex;

  TYPE TerrResource_tbl_type     IS TABLE OF   TerrResource_rec_type
                                 INDEX BY BINARY_INTEGER;
  TYPE TerrResource_tbl_type_wflex    IS TABLE OF   TerrResource_rec_type_wflex
                                 INDEX BY BINARY_INTEGER;

  G_MISS_TERRRESOURCE_TBL        TerrResource_tbl_type;
  G_MISS_TERRRESOURCE_TBL_WFLEX  TerrResource_tbl_type_wflex;




--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory Resource out Record: TerrResource_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--       TERR_RSC_ID                   Territory resource id
--       RETURN_STATUS                 Status
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


  TYPE TerrResource_out_rec_type   IS RECORD
    (
      TERR_RSC_ID                  NUMBER        := FND_API.G_MISS_NUM,
      RETURN_STATUS                VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

  G_MISS_TERRRESOURCE_OUT_REC      TerrResource_out_rec_type;


  TYPE TerrResource_out_tbl_type   IS TABLE OF   TerrResource_out_rec_type
                                   INDEX BY BINARY_INTEGER;

  G_MISS_TERRRESOURCE_OUT_TBL      TerrResource_out_tbl_type;




---------------------------------------------------------
--  Territory Resource Record: TerrRsc_Access_type
-- ------------------------------------------------------
--    Parameters:
--
--    Required:
--        TERR_RSC_ID                Database sequence
--        LAST_UPDATE_DATE           Part of std who columns
--        LAST_UPDATED_BY            Part of std who columns
--        CREATION_DATE              Part of std who columns
--        CREATED_BY                 Part of std who columns
--        LAST_UPDATE_LOGIN          Part of std who columns
--        TERR_RSC_ID                Territory resource id
--        ACCESS_TYPE                Resource acces eg: ACCOUNT/LEADS
--        ORG_ID                     NUMBER        := FND_API.G_MISS_NUM
--		  TRANS_ACCESS_CODE			 access type
--    Defaults:
--    Note:
--
-- End of Comments


  TYPE TerrRsc_Access_Rec_type     IS RECORD
    (
      TERR_RSC_ACCESS_ID           NUMBER        , --:= FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE             DATE          , --:= FND_API.G_MISS_DATE,
      LAST_UPDATED_BY              NUMBER        , --:= FND_API.G_MISS_NUM,
      CREATION_DATE                DATE          , --:= FND_API.G_MISS_DATE,
      CREATED_BY                   NUMBER        , --:= FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN            NUMBER        , --:= FND_API.G_MISS_NUM,
      TERR_RSC_ID                  NUMBER        , --:= FND_API.G_MISS_NUM,
      ACCESS_TYPE                  VARCHAR2(30)  , --:= FND_API.G_MISS_CHAR,
      ORG_ID                       NUMBER        , --:= FND_API.G_MISS_NUM,
      QUALIFIER_TBL_INDEX          NUMBER        ,  --:= FND_API.G_MISS_NUM
	  TRANS_ACCESS_CODE			   VARCHAR2(15)
    );


  G_MISS_TERRRSC_ACCESS_REC        TerrRsc_Access_Rec_type;

  TYPE TerrRsc_Access_tbl_type     IS TABLE OF   TerrRsc_Access_rec_type
                                   INDEX BY BINARY_INTEGER;

  G_MISS_TERRRSC_ACCESS_TBL        TerrRsc_Access_tbl_type;




--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--    Territory Resource access out Record: TerrResource_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--       TERR_RSC_ID                   Territory resource id
--       RETURN_STATUS                 Status
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


  TYPE TerrRsc_Access_Out_rec_type     IS RECORD
    (
      TERR_RSC_ACCESS_ID               NUMBER        := FND_API.G_MISS_NUM,
      RETURN_STATUS                    VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

  G_MISS_TERRRSC_ACCESS_OUT_REC        TerrRsc_Access_Out_rec_type;


  TYPE   TerrRsc_Access_out_tbl_type   IS TABLE OF   TerrRsc_Access_Out_rec_type
                                       INDEX BY BINARY_INTEGER;

  G_MISS_TERRRSC_ACCESS_OUT_TBL        TerrRsc_Access_out_tbl_type;





--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrResource
--    Type      : PUBLIC
--    Function  : To create Territory Resources - which will insert
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Create_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsC_Access_out_tbl_type
    );

  PROCEDURE Create_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type_wflex := G_MISS_TERRRESOURCE_TBL_WFLEX,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsC_Access_out_tbl_type
    );




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Resource
--    Type      : PUBLIC
--    Function  : To delete resources associated with
--                Territories
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_TerrRsc_Id               NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--      p_validation_level         NUMBER                           FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name             Data Type
--      X_Return_Status            VARCHAR2(1)
--      X_Msg_Count                NUMBER
--      X_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict
--
--    End of Comments
--

  PROCEDURE Delete_Terr_Resource
    (
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status           OUT NOCOPY VARCHAR2,
      X_Msg_Count               OUT NOCOPY NUMBER,
      X_Msg_Data                OUT NOCOPY VARCHAR2,
      p_TerrRsc_Id              IN  NUMBER
    );




--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_TerrResource
--    Type      : PUBLIC
--    Function  : To Update Territory Resources - which will update
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Update_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type
    );





--    ***************************************************
--    API name  : Create_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories resource
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Rec                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Rec             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Create_Terr_Resource
    (
      P_TerrRsc_Rec        IN  TerrResource_Rec_type,
      p_Api_Version_Number IN  NUMBER,
      p_Init_Msg_List      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit             IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level   IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status      OUT NOCOPY VARCHAR2,
      x_Msg_Count          OUT NOCOPY NUMBER,
      x_Msg_Data           OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Rec    OUT NOCOPY TerrResource_out_Rec_type
    );


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories Resources
--
--    Pre-reqs  :
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Tbl                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Tbl             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--

  PROCEDURE Create_Terr_Resource
    (
      P_TerrRsc_Tbl        IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_Api_Version_Number IN  NUMBER,
      p_Init_Msg_List      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit             IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level   IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status      OUT NOCOPY VARCHAR2,
      x_Msg_Count          OUT NOCOPY NUMBER,
      x_Msg_Data           OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Tbl    OUT NOCOPY TerrResource_out_tbl_type
    );

--    start of comments
--    ***************************************************
--    API name  : Create_Resource_Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_REC
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Create_Resource_Access
    (
      p_TerrRsc_Id                  NUMBER,
      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type         := G_MISS_TERRRSC_ACCESS_REC,
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Rec      OUT NOCOPY TerrRsc_Access_out_rec_type
    );





--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Resource _Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_REC
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--    End of Comments
--

  PROCEDURE Create_Resource_Access
    (
      p_TerrRsc_Id                  NUMBER,
      P_TerrRsc_Access_Tbl          TerrRsc_Access_Tbl_type   := G_MISS_TERRRSC_ACCESS_TBL,
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_Tbl_type
    );




--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrResource
--   Type    :  PRIVATE
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        IN   NUMBER,
--     P_Init_Msg_List             IN   VARCHAR2     := FND_API.G_FALSE
--     P_Commit                    IN   VARCHAR2     := FND_API.G_FALSE
--     P_TerrRsc_Id                IN   NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--

  PROCEDURE Delete_TerrResource
    (
      P_Api_Version_Number         IN   NUMBER,
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_TerrRsc_Id                 IN   NUMBER,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  VARCHAR2,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrRsc_Access
--   Type    :  PRIVATE
--   Pre-Req :
--   Parameters:
--    IN
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           := FND_API.G_FALSE
--     P_Commit                    VARCHAR2           := FND_API.G_FALSE
--     P_TerrRsc_Access_Id         NUMBER
--
--     Optional:
--
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--

  PROCEDURE  Delete_TerrRsc_Access
    (
      P_Api_Version_Number         IN   NUMBER,
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_TerrRsc_Access_Id          IN   NUMBER,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  VARCHAR2,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );




--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Resource
--    Type      : PRIVATE
--    Function  : To update Territories resource
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Rec                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Rec             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Update_Terr_Resource
    (
      P_TerrRsc_Rec         IN  TerrResource_Rec_type,
      p_Api_Version_Number  IN  NUMBER,
      p_Init_Msg_List       IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit              IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level    IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status       OUT NOCOPY VARCHAR2,
      x_Msg_Count           OUT NOCOPY NUMBER,
      x_Msg_Data            OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Rec     OUT NOCOPY TerrResource_out_Rec_type
    );




--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories qualifier
--
--    Pre-reqs  :
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Tbl                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Tbl             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--

  PROCEDURE Update_Terr_Resource
    (
      P_TerrRsc_Tbl         IN  TerrResource_tbl_type := G_MISS_TERRRESOURCE_TBL,
      p_Api_Version_Number  IN  NUMBER,
      p_Init_Msg_List       IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit              IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level    IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status       OUT NOCOPY VARCHAR2,
      x_Msg_Count           OUT NOCOPY NUMBER,
      x_Msg_Data            OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Tbl     OUT NOCOPY TerrResource_out_tbl_type
    );





--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Resource_Access
--    Type      : PUBLIC
--    Function  : To Update Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_REC
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Update_Resource_Access
    (
      P_TerrRsc_Access_Rec      TerrRsc_Access_rec_type   := G_MISS_TERRRSC_ACCESS_REC,
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status           OUT NOCOPY VARCHAR2,
      x_Msg_Count               OUT NOCOPY NUMBER,
      x_Msg_Data                OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Rec  OUT NOCOPY TerrRsc_Access_out_rec_type
    );





--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Resource _Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--    End of Comments
--

  PROCEDURE Update_Resource_Access
    (
      P_TerrRsc_Access_Tbl      TerrRsc_Access_Tbl_type   := G_MISS_TERRRSC_ACCESS_TBL,
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status           OUT NOCOPY VARCHAR2,
      x_Msg_Count               OUT NOCOPY NUMBER,
      x_Msg_Data                OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Tbl  OUT NOCOPY TerrRsc_Access_out_Tbl_type
    );





--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Validate_TerrResource_Data
--    Type      : PUBLIC
--    Function  : Validate Territory Resources
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Validate_TerrResource_Data
    (
      p_TerrRsc_Tbl         IN  TerrResource_tbl_type,
      p_TerrRsc_Access_Tbl  IN  TerrRsc_Access_tbl_type,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_Return_Status       OUT NOCOPY VARCHAR2
    );


---------------------------------------------------------------------
--             Validate Territory Resource
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Resource and Resource_Type is specified
--         Make sure the Territory Id is valid
---------------------------------------------------------------------
  PROCEDURE Validate_Terr_Rsc
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Rec                 IN  TerrResource_Rec_type
    );


---------------------------------------------------------------------
--             Validate Territory Resource Access record
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a TERR_RSC_ID is valid
--         Make sure the ACCESS_TYPE is valid
---------------------------------------------------------------------
  PROCEDURE Validate_Terr_Rsc_Access
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Id                  IN  NUMBER,
      p_TerrRsc_Access_Rec          IN  TerrRsc_Access_Rec_type
    );



  FUNCTION  BuildRuleExpression
    (
      p_Terr_Id      NUMBER,
      p_qual_type_id NUMBER
    ) return VARCHAR2;


  FUNCTION  Get_Expression_Interest_Type
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2;


  FUNCTION  Get_Expression_NUMERIC
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2;


  FUNCTION  Get_Expression_CURRENCY
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2;


  FUNCTION  Get_Expression_CHAR
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2;


  FUNCTION  Get_Expression_Competence
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2;



-- Function used in JTF_TERR_RESOURCES_V to return
-- the group_name for the group_id of a resource
  FUNCTION get_group_name
    (
      p_group_id  NUMBER
    ) RETURN VARCHAR2;


/* 10/12/00 JDOCHERT */
  -- Function used in views to return
  -- the resource name
  FUNCTION get_resource_name  ( p_resource_id    NUMBER
                              , p_resource_type  VARCHAR2) RETURN VARCHAR2;


/* 10/04/00 JDOCHERT */
  -- Function used in views to return
  -- the resource type name for the resource type code
  -- of a resource
  FUNCTION get_rs_type_name  (p_rs_type_code  VARCHAR2)
  RETURN VARCHAR2;


/* procedure to check that UK constraint is not
** being violated on JTF_TERR_RSC_ALL table
** -- jdochert 09/09
*/
PROCEDURE validate_terr_rsc_access_UK(
               p_Terr_Rsc_Id             IN  NUMBER,
               p_Access_Type             IN  VARCHAR2,
               p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2 );


/* 09/16/00    VVUYYURU */
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Copy_Terr_Resources
--    Type      : PUBLIC
--    Function  : Copy Territory Resources and Resource Access
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          IN  NUMBER,
--      p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
--      p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
--      p_source_terr_id              NUMBER
--      p_dest_terr_id                NUMBER
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2
--      x_msg_count                   NUMBER
--      x_msg_data                    VARCHAR2
--    Notes:
--
--
--    End of Comments
--
  PROCEDURE Copy_Terr_Resources (
      p_Api_Version_Number  IN  NUMBER,
      p_Init_Msg_List       IN  VARCHAR2     := FND_API.G_FALSE,
      p_Commit              IN  VARCHAR2     := FND_API.G_FALSE,
      p_validation_level    IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_source_terr_id      IN  NUMBER,
      p_dest_terr_id        IN  NUMBER,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    );


/* 09/19/00 JDOCHERT */

TYPE Terr_Ids_Tbl_Type IS TABLE OF NUMBER
                          INDEX BY BINARY_INTEGER;
G_MISS_TERRID_TBL   Terr_Ids_Tbl_Type;
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Transfer_Resource_Territories
--    Type      : PUBLIC
--    Function  : Transfer one Resource's Territories to another resource
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          IN  NUMBER,
--      p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
--      p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
--      p_source_resource_rec         TerrResource_Rec_type
--      p_p_dest_resource_recd        TerrResource_Rec_type
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2
--      x_msg_count                   NUMBER
--      x_msg_data                    VARCHAR2
--    Notes:
--
--
--    End of Comments
--
  PROCEDURE Transfer_Resource_Territories
    (
      p_Api_Version_Number       IN  NUMBER,
      p_Init_Msg_List            IN  VARCHAR2     := FND_API.G_FALSE,
      p_Commit                   IN  VARCHAR2     := FND_API.G_FALSE,
      p_validation_level         IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_source_resource_rec      IN  TerrResource_Rec_type,
      p_dest_resource_rec        IN  TerrResource_Rec_type,
      p_all_terr_flag            IN  VARCHAR2     := 'Y',
      p_terr_ids_tbl             IN  Terr_Ids_Tbl_Type := G_MISS_TERRID_TBL,
      p_replace_flag             IN  VARCHAR2     := 'Y',
      p_add_flag                 IN  VARCHAR2     := 'N',
      p_delete_flag              IN  VARCHAR2     := 'Y',
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
    );


-- Package spec
END JTF_TERRITORY_RESOURCE_PVT;


/
