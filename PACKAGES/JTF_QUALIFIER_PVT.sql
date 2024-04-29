--------------------------------------------------------
--  DDL for Package JTF_QUALIFIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_QUALIFIER_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtrqs.pls 120.0 2005/06/02 18:22:57 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_QUALIFIER_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager private api's.
--      This package is a private API for inserting, updating and deleting
--      qualifier related information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Private territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is available for private use only.
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--
--    End of Comments


/* Insert seeded qualifier record into database */
PROCEDURE Create_Seed_Qual_Record
            ( p_seed_qual_rec       IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type,
              x_seed_qual_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type );

/* Update seeded qualifier record in database */
PROCEDURE Update_Seed_Qual_Record
            ( p_seed_qual_rec       IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type,
              x_seed_qual_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type );

/* Delete seeded qualifier record from database */
PROCEDURE Delete_Seed_Qual_Record
            ( p_seeded_qual_id  IN  NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 );


/* Insert qualifier usage record into database */
PROCEDURE Create_Qual_Usgs_Record
            ( p_seed_qual_id        IN  NUMBER,
              p_qual_usgs_rec       IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
              x_qual_usgs_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type);

/* Update qualifier usage record in database */
PROCEDURE Update_Qual_Usgs_Record
            ( p_qual_usgs_rec       IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
              x_qual_usgs_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type);

/* Delete qualifier usage record from database */
PROCEDURE Delete_Qual_Usgs_Record
            ( p_qual_usg_id     IN  NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 );

/* Check if qualifier is used by any territories for qualifier disabling purposes */
PROCEDURE Check_Qualifier_Usage
            ( l_qual_usg_id IN  NUMBER,
              l_qualifier_used OUT NOCOPY VARCHAR2 );


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Create_Qualifier
--    Type      : PRIVATE
--    Function  : To create qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                                Default
--      P_Init_Msg_List        VARCHAR2                                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                                 FND_API.G_FALSE
--      p_validation_level     VARCHAR2                                 FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type                                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seeded_Qual_Id       NUMBER
--      x_Qual_Usgs_Id         NUMBER
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
--                                      commented eihsu 11/4
 p_Seed_Qual_Rec       IN    JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     ,--:= JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC,
 p_Qual_Usgs_Rec       IN    JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type ,--:= JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC,
 x_Seed_Qual_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Update_Qualifier
--    Type      : PRIVATE
--    Function  : To update existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                                Default
--      P_Init_Msg_List        VARCHAR2                                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                                 FND_API.G_FALSE
--      p_validation_level     VARCHAR2                                 FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type                                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seed_Qual_Rec        Seed_Qual_Out_Rec_Type,
--      x_Qual_Usgs_Rec        Qual_Usgs_All_Out_Rec_Type);
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seed_Qual_Rec       IN    JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type         := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC,
 p_Qual_Usgs_Rec       IN    JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type     := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC,
 x_Seed_Qual_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type);




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier
--    Type      : PRIVATE
--    Function  : To delete an existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type            Default
--      p_api_version          NUMBER
--      p_Seeded_Qual_Id       NUMBER               FND_API.G_MISS_NUM
--      p_Qual_Usgs_Id         NUMBER               FND_API.G_MISS_NUM
--
--      Optional
--      Parameter Name         Data Type            Default
--      P_Init_Msg_List        VARCHAR2             FND_API.G_FALSE
--      P_Commit               VARCHAR2             FND_API.G_FALSE
--      p_validation_level     VARCHAR2             FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type            Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Delete_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seeded_Qual_Id      IN    NUMBER   := FND_API.G_MISS_NUM,
 p_Qual_Usg_Id         IN    NUMBER   := FND_API.G_MISS_NUM);


END JTF_QUALIFIER_PVT;  -- Package Specification JTF_QUALIFIER_PVT

 

/
