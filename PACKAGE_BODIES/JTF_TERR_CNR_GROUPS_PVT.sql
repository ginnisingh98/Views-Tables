--------------------------------------------------------
--  DDL for Package Body JTF_TERR_CNR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_CNR_GROUPS_PVT" AS
/* $Header: jtfvcngb.pls 120.0 2005/06/02 18:22:07 appldev ship $ */

--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_CNR_GROUPS_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory resource private api's.
--      This package is a private API for inserting CNR groups
--      into JTF tables. It contains specification
--      for pl/sql records and tables related to territory
--      resource.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for PRIVATE USE ONLY use
--
--    HISTORY
--      01/29/01   ARPATEL         Created
--      05/18/01   ARPATEL         Added table handlers for JTF_TERR_CNR_GROUP_VALUES.
--      04/25/02   ARPATEL         Removed references to security_group_id bug#2269867.

--     End of Comments




-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
    G_PKG_NAME        CONSTANT VARCHAR2(30):='JTF_TERR_CNR_GROUPS_PVT';
    G_FILE_NAME       CONSTANT VARCHAR2(12):='jtftrcng.pls';



--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To create territory CNR's.
--
--    Pre-reqs  :
--    Notes:
--
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
    )
  IS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Terr_Cnr_Group';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_DML_Operation              CONSTANT VARCHAR2(30) := 'INSERT';
      l_return_status              VARCHAR2(1);
      l_Res_Counter                NUMBER;
      l_Res_Access_Counter         NUMBER;
      l_Terr_cnr_group_rec         Terr_cnr_group_rec_type;
      l_Terr_cnr_group_out_rec     Terr_cnr_group_out_rec_type;
      l_rowid                      ROWID;
      l_terr_cnr_group_Id          NUMBER;

  --
  BEGIN
      --dbms_output.put_line('Create_Terr_Cnr_Group PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CNR_GROUP_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate CNR group parameters
      -- ******************************************************************

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_CNR_GROUP_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;

        -- Invoke validation procedures
        Validate_Cnr_Group_Value_Rec(p_init_msg_list        => FND_API.G_FALSE,
                                     x_return_status        => x_return_status,
                                     x_msg_count            => x_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_DML_Operation        => l_DML_Operation,
                                     p_Terr_cnr_group_rec   => p_Terr_cnr_group_rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

          JTF_TERR_CNR_GROUPS_PKG.Insert_Row(
                               x_rowid                  => l_rowid,
                               x_CNR_GROUP_ID           => l_terr_cnr_group_Id,
                               x_LAST_UPDATED_BY        => p_Terr_cnr_group_rec.LAST_UPDATED_BY,
                               x_LAST_UPDATE_DATE       => p_Terr_cnr_group_rec.LAST_UPDATE_DATE,
                               x_CREATED_BY             => p_Terr_cnr_group_rec.CREATED_BY,
                               x_CREATION_DATE          => p_Terr_cnr_group_rec.CREATION_DATE,
                               x_LAST_UPDATE_LOGIN      => p_Terr_cnr_group_rec.LAST_UPDATE_LOGIN,
                               x_NAME                   => p_Terr_cnr_group_rec.NAME,
                               x_DESCRIPTION            => p_Terr_cnr_group_rec.DESCRIPTION,
                               x_ATTRIBUTE_CATEGORY     => p_Terr_cnr_group_rec.ATTRIBUTE_CATEGORY,
                               x_ATTRIBUTE1             => p_Terr_cnr_group_rec.ATTRIBUTE1,
                               x_ATTRIBUTE2             => p_Terr_cnr_group_rec.ATTRIBUTE2,
                               x_ATTRIBUTE3             => p_Terr_cnr_group_rec.ATTRIBUTE3,
                               x_ATTRIBUTE4             => p_Terr_cnr_group_rec.ATTRIBUTE4,
                               x_ATTRIBUTE5             => p_Terr_cnr_group_rec.ATTRIBUTE5,
                               x_ATTRIBUTE6             => p_Terr_cnr_group_rec.ATTRIBUTE6,
                               x_ATTRIBUTE7             => p_Terr_cnr_group_rec.ATTRIBUTE7,
                               x_ATTRIBUTE8             => p_Terr_cnr_group_rec.ATTRIBUTE8,
                               x_ATTRIBUTE9             => p_Terr_cnr_group_rec.ATTRIBUTE9,
                               x_ATTRIBUTE10            => p_Terr_cnr_group_rec.ATTRIBUTE10,
                               x_ATTRIBUTE11            => p_Terr_cnr_group_rec.ATTRIBUTE11,
                               x_ATTRIBUTE12            => p_Terr_cnr_group_rec.ATTRIBUTE12,
                               x_ATTRIBUTE13            => p_Terr_cnr_group_rec.ATTRIBUTE13,
                               x_ATTRIBUTE14            => p_Terr_cnr_group_rec.ATTRIBUTE14,
                               x_ATTRIBUTE15            => p_Terr_cnr_group_rec.ATTRIBUTE15);

      -- l_terr_cnr_group_Id := p_Terr_cnr_group_rec.CNR_GROUP_ID;

      -- set cnr_group_id for later use
      x_Terr_cnr_group_out_rec.cnr_group_id := l_terr_cnr_group_Id;
      --l_Terr_cnr_group_out_rec.cnr_group_id := l_terr_cnr_group_Id;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Create_Terr_Cnr_Group PVT: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_Terr_Cnr_Group PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_CNR_GROUP_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Create_Terr_Cnr_Group PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Create_Terr_Cnr_Group PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Create_Terr_Cnr_Group ' || sqlerrm);
         END IF;
  --
  END Create_Terr_Cnr_Group;




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To delete CNR groups
--
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
      p_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status           OUT NOCOPY VARCHAR2,
      X_Msg_Count               OUT NOCOPY NUMBER,
      X_Msg_Data                OUT NOCOPY VARCHAR2,
      p_Terr_cnr_group_rec      IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC
    )
  AS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Terr_Cnr_Group';
  l_api_version_number        CONSTANT NUMBER       := 1.0;
  l_DML_Operation             CONSTANT VARCHAR2(30) := 'DELETE';
  l_return_status             VARCHAR2(1);

  BEGIN
  --
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CNR_GROUP_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      --
      -- ******************************************************************
      -- Validate CNR group parameters
      -- ******************************************************************
      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_CNR_GROUP_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;

        -- Invoke validation procedures
        Validate_Cnr_Group_Value_Rec(p_init_msg_list        => FND_API.G_FALSE,
                                     x_return_status        => x_return_status,
                                     x_msg_count            => x_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_DML_Operation        => l_DML_Operation,
                                     p_Terr_cnr_group_rec   => p_Terr_cnr_group_rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      JTF_TERR_CNR_GROUPS_PKG.Delete_Row(
                  x_CNR_GROUP_ID => p_Terr_cnr_group_rec.cnr_group_id
      );

      delete
      from JTF_TERR_CNR_GROUP_VALUES jt
      where jt.cnr_group_id = p_Terr_cnr_group_rec.cnr_group_id;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO DELETE_CNR_GROUP_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO DELETE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         ROLLBACK TO DELETE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
  --
  END Delete_Terr_Cnr_Group;




--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Cnr_Group
--    Type      : PUBLIC
--    Function  : To Update CNR groups.
--
--    Pre-reqs  :
--    Notes:
--
--
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
    )
  AS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Terr_Cnr_Group';
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_DML_Operation             CONSTANT VARCHAR2(30) := 'UPDATE';
      l_return_status             VARCHAR2(1);
      l_rowid                     ROWID;
      l_terr_cnr_group_Id         NUMBER := p_Terr_cnr_group_rec.CNR_GROUP_ID;

  BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CNR_GROUP_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;


      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate CNR group parameters
      -- ******************************************************************
      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_CNR_GROUP_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;

        -- Invoke validation procedures
        Validate_Cnr_Group_Value_Rec(p_init_msg_list        => FND_API.G_FALSE,
                                     x_return_status        => x_return_status,
                                     x_msg_count            => x_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_DML_Operation        => l_DML_Operation,
                                     p_Terr_cnr_group_rec   => p_Terr_cnr_group_rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

         --dbms_output.put_line('before update_row call' );

         JTF_TERR_CNR_GROUPS_PKG.Update_Row(
                  x_Rowid               => l_rowid,
                  x_CNR_GROUP_ID        => l_terr_cnr_group_Id,
                  x_LAST_UPDATED_BY     => p_Terr_cnr_group_rec.LAST_UPDATED_BY,
                  x_LAST_UPDATE_DATE    => p_Terr_cnr_group_rec.LAST_UPDATE_DATE,
                  x_CREATED_BY          => p_Terr_cnr_group_rec.CREATED_BY,
                  x_CREATION_DATE       => p_Terr_cnr_group_rec.CREATION_DATE,
                  x_LAST_UPDATE_LOGIN   => p_Terr_cnr_group_rec.LAST_UPDATE_LOGIN,
                  x_NAME                => p_Terr_cnr_group_rec.NAME,
                  x_DESCRIPTION         => p_Terr_cnr_group_rec.DESCRIPTION,
                  x_ATTRIBUTE_CATEGORY  => p_Terr_cnr_group_rec.ATTRIBUTE_CATEGORY,
                  x_ATTRIBUTE1          => p_Terr_cnr_group_rec.ATTRIBUTE1,
                  x_ATTRIBUTE2          => p_Terr_cnr_group_rec.ATTRIBUTE2,
                  x_ATTRIBUTE3          => p_Terr_cnr_group_rec.ATTRIBUTE3,
                  x_ATTRIBUTE4          => p_Terr_cnr_group_rec.ATTRIBUTE4,
                  x_ATTRIBUTE5          => p_Terr_cnr_group_rec.ATTRIBUTE5,
                  x_ATTRIBUTE6          => p_Terr_cnr_group_rec.ATTRIBUTE6,
                  x_ATTRIBUTE7          => p_Terr_cnr_group_rec.ATTRIBUTE7,
                  x_ATTRIBUTE8          => p_Terr_cnr_group_rec.ATTRIBUTE8,
                  x_ATTRIBUTE9          => p_Terr_cnr_group_rec.ATTRIBUTE9,
                  x_ATTRIBUTE10         => p_Terr_cnr_group_rec.ATTRIBUTE10,
                  x_ATTRIBUTE11         => p_Terr_cnr_group_rec.ATTRIBUTE11,
                  x_ATTRIBUTE12         => p_Terr_cnr_group_rec.ATTRIBUTE12,
                  x_ATTRIBUTE13         => p_Terr_cnr_group_rec.ATTRIBUTE13,
                  x_ATTRIBUTE14         => p_Terr_cnr_group_rec.ATTRIBUTE14,
                  x_ATTRIBUTE15         => p_Terr_cnr_group_rec.ATTRIBUTE15
        );
            --dbms_output.put_line('after update_row call' );

     -- set cnr_group_id for later use
      x_Terr_cnr_group_out_rec.cnr_group_id := l_terr_cnr_group_Id;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
  --
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO UPDATE_CNR_GROUP_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO UPDATE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         ROLLBACK TO UPDATE_CNR_GROUP_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
  --
  END Update_Terr_Cnr_Group;

---------------------------------------------------------------------
--          Validate the CNR group Values passed in
---------------------------------------------------------------------
-- Columns Validated
--         Make sure the values are in the right columns as per the
--         qualifer setup
--         Eg:
--               If the qualifer, diplay_type    = 'CHAR' and
--                                col1_data_type =  'NUMBER'
--               then make sure the ID is passed in LOW_VALUE_CHAR_ID
--
--
---------------------------------------------------------------------
PROCEDURE Validate_Cnr_Group_Value_Rec
  (p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_DML_Operation               IN  VARCHAR2,
   p_Terr_cnr_group_rec          IN  Terr_cnr_group_rec_type     := G_MISS_TERR_CNR_GROUP_REC)
AS
   l_display_type       VARCHAR2(30);
   l_qual_col1_datatype VARCHAR2(30);
   l_convert_to_id_flag VARCHAR2(01);
   l_cnr_child_num      NUMBER;
   l_cnr_group_num      NUMBER;
   l_cnr_qual_defined   NUMBER;

   CURSOR c_cnrgroupname IS
           select 1
            from JTF_TERR_CNR_GROUPS jtcg
            where jtcg.NAME = p_Terr_cnr_group_rec.NAME
              and rownum < 2;

   CURSOR c_cnrgroupid IS
           select 1
            from JTF_TERR_VALUES_ALL jtva
            where jtva.CNR_GROUP_ID = p_Terr_cnr_group_rec.CNR_GROUP_ID
              and rownum < 2;

   CURSOR c_cnrgroupname_update IS
           select 1
            from JTF_TERR_CNR_GROUPS jtcg
            where jtcg.NAME = p_Terr_cnr_group_rec.NAME
              and jtcg.CNR_GROUP_ID <> p_Terr_cnr_group_rec.CNR_GROUP_ID
              and rownum < 2;

   CURSOR c_qualifier_defined IS
           select 1
            from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
            where jtq.qual_usg_id = -1102
              and jtv.terr_qual_id = jtq.terr_qual_id
              and jtv.low_value_char_id = p_Terr_cnr_group_rec.CNR_GROUP_ID
              and rownum < 2;
BEGIN
    --dbms_output.put_line('Validate_Cnr_Group_Value_Rec: - cnr_group_id');

    -- Initialize the status to success
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_DML_Operation = 'DELETE' ) THEN
            --dbms_output.put_line('DELETE');
            OPEN c_qualifier_defined;
                FETCH c_qualifier_defined INTO l_cnr_qual_defined;

                OPEN c_cnrgroupid;
                FETCH c_cnrgroupid INTO l_cnr_child_num;

                IF (c_cnrgroupid%FOUND) OR (c_qualifier_defined%FOUND) THEN
                  --dbms_output.put_line('c_cnrgroupid%FOUND');
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_CNR_HAS_FKREL');
                       FND_MESSAGE.Set_Token('COL_NAME', 'CNR_GROUP_ID' );
                       FND_MSG_PUB.ADD;
                    END IF;
                  x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
            CLOSE c_cnrgroupid;


  ELSIF (p_DML_Operation IN ('INSERT','UPDATE')) THEN
            --dbms_output.put_line('INSERT,UPDATE');
    --Check created by
    IF ( p_Terr_cnr_group_rec.CREATED_BY is NULL OR
         p_Terr_cnr_group_rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check creation date
    If ( p_Terr_cnr_group_rec.CREATION_DATE is NULL OR
         p_Terr_cnr_group_rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Validate last updated by
    IF  ( p_Terr_cnr_group_rec.LAST_UPDATED_BY is NULL OR
          p_Terr_cnr_group_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_Terr_cnr_group_rec.LAST_UPDATE_DATE IS NULL OR
         p_Terr_cnr_group_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_Terr_cnr_group_rec.LAST_UPDATE_LOGIN  is NULL OR
         p_Terr_cnr_group_rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check CNR group name
    If ( p_Terr_cnr_group_rec.NAME  is NULL OR
         p_Terr_cnr_group_rec.NAME  = FND_API.G_MISS_CHAR )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'NAME' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    IF ( p_DML_Operation = 'INSERT' ) THEN
            --dbms_output.put_line('INSERT CHECK AT END');
    --Check for duplicate CNR group name
            OPEN c_cnrgroupname;
                FETCH c_cnrgroupname INTO l_cnr_group_num;

                IF c_cnrgroupname%FOUND THEN
                  --dbms_output.put_line('c_cnrgroupname%FOUND');
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_CNR_DUPLICATE_NAME');
                       FND_MESSAGE.Set_Token('COL_NAME', 'NAME' );
                       FND_MSG_PUB.ADD;
                    END IF;
                  x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
            CLOSE c_cnrgroupname;

            --dbms_output.put_line('c_cnrgroupname CURSOR CALL');


    ELSIF ( p_DML_Operation = 'UPDATE' ) THEN
            --dbms_output.put_line('first update check');
    --Check CNR group Id
       If ( p_Terr_cnr_group_rec.CNR_GROUP_ID is NULL OR
            p_Terr_cnr_group_rec.CNR_GROUP_ID = FND_API.G_MISS_NUM )  THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
             FND_MESSAGE.Set_Token('COL_NAME', 'CNR_GROUP_ID' );
             FND_MSG_PUB.ADD;
          END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
            --dbms_output.put_line('UPDATE CHECK AT END');

            OPEN c_cnrgroupname_update;
                FETCH c_cnrgroupname_update INTO l_cnr_group_num;

                IF c_cnrgroupname_update%FOUND THEN
                  --dbms_output.put_line('c_cnrgroupname_update%FOUND');
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_CNR_DUPLICATE_NAME');
                       FND_MESSAGE.Set_Token('COL_NAME', 'NAME' );
                       FND_MSG_PUB.ADD;
                    END IF;
                  x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
            CLOSE c_cnrgroupname_update;

    END IF;

  END IF;
    --
    --dbms_output.put_line('BEFORE COUNT and GET');
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
    --dbms_output.put_line('AFTER COUNT and GET');

EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Cnr_Group_Value_Rec: FND_API.G_EXC_ERROR');
         x_return_status                    := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Cnr_Group_Value_Rec: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Cnr_Group_Value_Rec: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

  End Validate_Cnr_Group_Value_Rec;

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
    ) AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Terr_Cnr_Values';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_DML_Operation              CONSTANT VARCHAR2(30) := 'INSERT';
      l_return_status              VARCHAR2(1);
      l_Terr_cnr_values_rec        Terr_cnr_values_rec_type;
      l_Terr_cnr_values_out_rec    Terr_cnr_values_out_rec_type;
      l_rowid                      ROWID;
      l_terr_cnr_group_value_Id    NUMBER;

  --
  BEGIN
      --dbms_output.put_line('Create_Terr_Cnr_Values PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CNR_VALUES_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_CNR_VALUES_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;

          JTF_TERR_CNR_GROUP_VALUES_PKG.Insert_Row(
                               x_rowid                  => l_rowid,
                               x_CNR_GROUP_VALUE_ID     => l_terr_cnr_group_value_Id,
                               x_LAST_UPDATED_BY        => p_Terr_cnr_values_rec.LAST_UPDATED_BY,
                               x_LAST_UPDATE_DATE       => p_Terr_cnr_values_rec.LAST_UPDATE_DATE,
                               x_CREATED_BY             => p_Terr_cnr_values_rec.CREATED_BY,
                               x_CREATION_DATE          => p_Terr_cnr_values_rec.CREATION_DATE,
                               x_LAST_UPDATE_LOGIN      => p_Terr_cnr_values_rec.LAST_UPDATE_LOGIN,
                               x_CNR_GROUP_ID           => p_Terr_cnr_values_rec.CNR_GROUP_ID,
                               x_COMPARISON_OPERATOR    => p_Terr_cnr_values_rec.COMPARISON_OPERATOR,
                               x_LOW_VALUE_CHAR         => p_Terr_cnr_values_rec.LOW_VALUE_CHAR,
                               x_HIGH_VALUE_CHAR        => p_Terr_cnr_values_rec.HIGH_VALUE_CHAR,
                               x_START_DATE_ACTIVE      => p_Terr_cnr_values_rec.START_DATE_ACTIVE,
                               x_END_DATE_ACTIVE        => p_Terr_cnr_values_rec.END_DATE_ACTIVE,
                               x_ORG_ID                 => p_Terr_cnr_values_rec.ORG_ID
                               );

      -- set cnr_group_value_id for later use
      x_Terr_cnr_values_out_rec.cnr_group_value_id := l_terr_cnr_group_value_Id;


      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Create_Terr_Cnr_Values PVT: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_Terr_Cnr_Values PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_CNR_VALUES_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Create_Terr_Cnr_Values PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_CNR_VALUES_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Create_Terr_Cnr_Values PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_CNR_VALUES_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Create_Terr_Cnr_Group ' || sqlerrm);
         END IF;
  --

  End Create_Terr_Cnr_Value;

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
    ) AS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Terr_Cnr_Value';
  l_api_version_number        CONSTANT NUMBER       := 1.0;
  l_DML_Operation             CONSTANT VARCHAR2(30) := 'DELETE';
  l_return_status             VARCHAR2(1);

  BEGIN
  --
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CNR_VALUE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
            JTF_TERR_CNR_GROUP_VALUES_PKG.Delete_Row(
                  x_CNR_GROUP_VALUE_ID => p_Terr_cnr_values_rec.cnr_group_value_id
      );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO DELETE_CNR_VALUE_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO DELETE_CNR_VALUE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         ROLLBACK TO DELETE_CNR_VALUE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
  --

  End Delete_Terr_Cnr_Value;

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
    ) AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Terr_Cnr_Values';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_DML_Operation              CONSTANT VARCHAR2(30) := 'UPDATE';
      l_return_status              VARCHAR2(1);
      l_Terr_cnr_values_rec        Terr_cnr_values_rec_type;
      l_Terr_cnr_values_out_rec    Terr_cnr_values_out_rec_type;
      l_rowid                      ROWID;
      l_terr_cnr_group_value_Id    NUMBER := p_Terr_cnr_values_rec.CNR_GROUP_VALUE_ID;

  --
  BEGIN
      --dbms_output.put_line('Update_Terr_Cnr_Values PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CNR_VALUES_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_CNR_VALUES_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Cnr_Group_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;

          JTF_TERR_CNR_GROUP_VALUES_PKG.Update_Row(
                               x_rowid                  => l_rowid,
                               x_CNR_GROUP_VALUE_ID     => l_terr_cnr_group_value_Id,
                               x_LAST_UPDATED_BY        => p_Terr_cnr_values_rec.LAST_UPDATED_BY,
                               x_LAST_UPDATE_DATE       => p_Terr_cnr_values_rec.LAST_UPDATE_DATE,
                               x_CREATED_BY             => p_Terr_cnr_values_rec.CREATED_BY,
                               x_CREATION_DATE          => p_Terr_cnr_values_rec.CREATION_DATE,
                               x_LAST_UPDATE_LOGIN      => p_Terr_cnr_values_rec.LAST_UPDATE_LOGIN,
                               x_CNR_GROUP_ID           => p_Terr_cnr_values_rec.CNR_GROUP_ID,
                               x_COMPARISON_OPERATOR    => p_Terr_cnr_values_rec.COMPARISON_OPERATOR,
                               x_LOW_VALUE_CHAR         => p_Terr_cnr_values_rec.LOW_VALUE_CHAR,
                               x_HIGH_VALUE_CHAR        => p_Terr_cnr_values_rec.HIGH_VALUE_CHAR,
                               x_START_DATE_ACTIVE      => p_Terr_cnr_values_rec.START_DATE_ACTIVE,
                               x_END_DATE_ACTIVE        => p_Terr_cnr_values_rec.END_DATE_ACTIVE,
                               x_ORG_ID                 => p_Terr_cnr_values_rec.ORG_ID
                               );

      -- set cnr_group_value_id for later use
      x_Terr_cnr_values_out_rec.cnr_group_value_id := l_terr_cnr_group_value_Id;


      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Update_Terr_Cnr_Values PVT: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Update_Terr_Cnr_Values PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO UPDATE_CNR_VALUES_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Update_Terr_Cnr_Values PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO UPDATE_CNR_VALUES_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Update_Terr_Cnr_Values PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO UPDATE_CNR_VALUES_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Update_Terr_Cnr_Group ' || sqlerrm);
         END IF;
  --
  End Update_Terr_Cnr_Value;


END JTF_TERR_CNR_GROUPS_PVT;

/
