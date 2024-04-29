--------------------------------------------------------
--  DDL for Package Body JTF_QUALIFIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_QUALIFIER_PUB" AS
/* $Header: jtfptrqb.pls 120.0 2005/06/02 18:20:52 appldev ship $ */

--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_QUALIFIER_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting, updating and deleting
--      qualifier related information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--
--    End of Comments

G_PKG_NAME    CONSTANT VARCHAR2(30):='JTF_QUALIFIER_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12):='jtfptrqb.pls';



--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Create_Qualifier
--    Type      : PUBLIC
--    Function  : To create qualifiers
--
--    Pre-reqs  : None
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                Default
--      p_api_version          NUMBER
--      P_Seed_Qual_Rec        Seed_Qual_Rec_Type       G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        Qual_Usgs_All_Rec_Type   G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                Default
--      P_Init_Msg_List        VARCHAR2                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                 FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seeded_Qual_Id       NUMBER
--      x_Qual_Usgs_Id         NUMBER
--
--    Version:
--              Initial version 1.0
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Qualifier
(p_Api_Version         IN    NUMBER,
   --                                                   commented out eihsu 11/04
 p_Init_Msg_List       IN    VARCHAR2 ,-- := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 ,-- := FND_API.G_FALSE,
 x_return_status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
   --                                                   commented out eihsu 11/04
 p_Seed_Qual_Rec       IN    Seed_Qual_Rec_Type        ,-- := G_MISS_SEED_QUAL_REC,
 p_Qual_Usgs_Rec       IN    Qual_Usgs_All_Rec_Type    ,-- := G_MISS_QUAL_USGS_ALL_REC,
 x_Seed_Qual_Rec       OUT NOCOPY   Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   Qual_Usgs_All_Out_Rec_Type
)
IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Create_Qualifier';
   l_api_version   CONSTANT NUMBER := 1.0;
   l_return_status VARCHAR2(1);

BEGIN
    ----plsdbg.put('QUALPUB.CREATE_QUALIFIER: BEGIN _______________________________');

    -- Standard Start of API savepoint;
    SAVEPOINT CREATE_QUALIFIER_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                             l_api_version,
                             p_api_version           ,
                             l_api_name,
                             G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qual API: Start');
        FND_MSG_PUB.Add;
    END IF;

    -------------------------------------------------------------------------------------------------------
    -- Start of API body.
    -------------------------------------------------------------------------------------------------------

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

     ----plsdbg.put('QUALPUB.CREATE_QUALIFIER: calling PRIVATE.Create_Qualifier ');

    -- All of the values have been converted, so call the Create_Qualifier Private API
    JTF_QUALIFIER_PVT.Create_Qualifier ( p_api_version         => 1.0,
                                         p_Init_Msg_List       => FND_API.G_FALSE,
                                         p_Commit              => FND_API.G_FALSE,
                                         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                         x_Return_Status       => l_return_status,
                                         x_Msg_Count           => x_msg_count,
                                         x_Msg_Data            => x_msg_data,
                                         p_Seed_Qual_Rec       => p_seed_qual_rec,
                                         p_Qual_Usgs_Rec       => p_qual_usgs_rec,
                                         x_Seed_Qual_Rec       => x_seed_qual_rec,
                                         x_Qual_Usgs_Rec       => x_qual_usgs_rec);

    --dbms_output.put_line('After calling private JTF_QUALIFIER_PVT.Create_Qualifier ');

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* save return status */
    x_return_status := l_return_status;

    -------------------------------------------------------------------------------------------------------
    -- End of API body.
    -------------------------------------------------------------------------------------------------------

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qualifier API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (   p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );
----plsdbg.put('QUALPUB.CREATE_QUALIFIER: END');


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO CREATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO CREATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );


    WHEN OTHERS THEN
         ROLLBACK TO CREATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Create_Qualifier;



--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Update_Qualifier
--    Type      : PUBLIC
--    Function  : To update existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type            Default
--      p_api_version          NUMBER
--      P_Seed_Qual_Rec        Seed_Qual_Rec_Type
--      p_Qual_Usgs_Rec        Qual_Usgs_All_Rec_Type
--
--      Optional
--      Parameter Name         Data Type            Default
--      P_Init_Msg_List        VARCHAR2             FND_API.G_FALSE
--      P_Commit               VARCHAR2             FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type
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
 p_Init_Msg_List       IN    VARCHAR2, -- 2372550: JDOCHERT : 05/1402 -- := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2, -- 2372550: JDOCHERT : 05/1402 -- := FND_API.G_FALSE,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seed_Qual_Rec       IN    Seed_Qual_Rec_Type,
 p_Qual_Usgs_Rec       IN    Qual_Usgs_All_Rec_Type,
 x_Seed_Qual_Rec       OUT NOCOPY   Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   Qual_Usgs_All_Out_Rec_Type
  )
IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Update_Qualifier';
   l_api_version   CONSTANT NUMBER := 1.0;
   l_return_status VARCHAR2(1);


BEGIN
    ----plsdbg.put('QUALPUB.UPDATE_QUALIFIER: BEGIN _______________________________');
    ----plsdbg.put('Received input include the following');
    ----plsdbg.put('p_Seed_Qual_Rec.Name: '|| p_Seed_Qual_Rec.Name);
    ----plsdbg.put('p_Seed_Qual_Rec.Description: '|| p_Seed_Qual_Rec.Description);
    ----plsdbg.put('p_Seed_Qual_Rec.Seeded_Qual_Id: '|| p_Seed_Qual_Rec.Seeded_Qual_Id);
    ----plsdbg.put('p_Qual_Usgs_Rec.Qual_Usg_Id: '|| p_Qual_Usgs_Rec.Qual_Usg_Id);


    -- Standard Start of API savepoint;
    SAVEPOINT UPDATE_QUALIFIER_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                             l_api_version,
                             p_api_version           ,
                             l_api_name,
                             G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qual API: Start');
        FND_MSG_PUB.Add;
    END IF;

    -------------------------------------------------------------------------------------------------------
    -- Start of API body.
    -------------------------------------------------------------------------------------------------------

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    ----plsdbg.put('QUALPUB.UPDATE_QUAL: Calling Update Qual in PVT package');

    -- All of the values have been converted, so call the Create_Qualifier Private API
    JTF_QUALIFIER_PVT.Update_Qualifier ( p_api_version         => 1.0,
                                         p_Init_Msg_List       => FND_API.G_FALSE,
                                         p_Commit              => FND_API.G_FALSE,
                                         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                         x_Return_Status       => l_return_status,
                                         x_Msg_Count           => x_msg_count,
                                         x_Msg_Data            => x_msg_data,
                                         p_Seed_Qual_Rec       => p_seed_qual_rec,
                                         p_Qual_Usgs_Rec       => p_qual_usgs_rec,
                                         x_Seed_Qual_Rec       => x_seed_qual_rec,
                                         x_Qual_Usgs_Rec       => x_qual_usgs_rec);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* save return status */
    x_return_status := l_return_status;

    ----plsdbg.put('QUALPUB.UPDATE_QUAL: END - l_return_status: ' || l_return_status);

    -------------------------------------------------------------------------------------------------------
    -- End of API body.
    -------------------------------------------------------------------------------------------------------

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qualifier API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (   p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO UPDATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO UPDATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );


    WHEN OTHERS THEN
         ROLLBACK TO UPDATE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Update_Qualifier;



--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier
--    Type      : PUBLIC
--    Function  : To delete an existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type            Default
--      p_api_version          NUMBER
--      P_Seeded_Qual_Id       NUMBER
--      p_Qual_Usgs_Id         NUMBER
--
--      Optional
--      Parameter Name         Data Type            Default
--      P_Init_Msg_List        VARCHAR2             FND_API.G_FALSE
--      P_Commit               VARCHAR2             FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type
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
 p_Init_Msg_List       IN    VARCHAR2, -- 2372550: JDOCHERT : 05/1402 -- := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2, -- 2372550: JDOCHERT : 05/1402 -- := FND_API.G_FALSE,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seeded_Qual_Id      IN    NUMBER,
 p_Qual_Usg_Id         IN    NUMBER
  )
IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Qualifier';
   l_api_version   CONSTANT NUMBER := 1.0;
   l_return_status VARCHAR2(1);


BEGIN
----plsdbg.put('QUALPUB.DELETE_QUALIFIER: BEGIN');
    -- Standard Start of API savepoint;
    SAVEPOINT DELETE_QUALIFIER_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                             l_api_version,
                             p_api_version           ,
                             l_api_name,
                             G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qual API: Start');
        FND_MSG_PUB.Add;
    END IF;

    -------------------------------------------------------------------------------------------------------
    -- Start of API body.
    -------------------------------------------------------------------------------------------------------

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;


    -- All of the values have been converted, so call the Create_Qualifier Private API
    JTF_QUALIFIER_PVT.Delete_Qualifier ( p_api_version         => 1.0,
                                         p_Init_Msg_List       => FND_API.G_FALSE,
                                         p_Commit              => FND_API.G_FALSE,
                                         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                         x_Return_Status       => l_return_status,
                                         x_Msg_Count           => x_msg_count,
                                         x_Msg_Data            => x_msg_data,
                                         p_Seeded_Qual_Id      => p_seeded_qual_id,
                                         p_Qual_Usg_Id         => p_qual_usg_id);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* save return status */
    x_return_status := l_return_status;

    ----plsdbg.put('QUALPUB.DELETE_QUALIFIER: END - l_return_status: ' || l_return_status);

    -------------------------------------------------------------------------------------------------------
    -- End of API body.
    -------------------------------------------------------------------------------------------------------

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Pub Qualifier API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (   p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO DELETE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO DELETE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );


    WHEN OTHERS THEN
         ROLLBACK TO DELETE_QUALIFIER_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Delete_Qualifier;


END JTF_QUALIFIER_PUB;  -- Package Body JTF_QUALIFIER_PUB

/
