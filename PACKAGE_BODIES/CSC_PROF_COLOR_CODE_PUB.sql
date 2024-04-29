--------------------------------------------------------
--  DDL for Package Body CSC_PROF_COLOR_CODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_COLOR_CODE_PUB" as
/* $Header: cscppccb.pls 115.6 2002/11/29 04:21:54 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_COLOR_CODE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_COLOR_CODE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscppccb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public PROF_COLOR_CODE record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private PROF_COLOR_CODErecord is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- End of Comments

PROCEDURE Convert_pub_to_pvt_Rec (
         P_prof_color_rec     IN    prof_color_Rec_Type  := G_MISS_prof_color_rec_type_REC,
         x_pvt_prof_color_rec     OUT NOCOPY    CSC_PROF_COLOR_CODE_PVT.prof_color_Rec_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
BEGIN
    x_pvt_prof_color_rec.COLOR_CODE := P_prof_color_rec.COLOR_CODE;
    x_pvt_prof_color_rec.RATING_CODE := P_prof_color_rec.RATING_CODE;
    x_pvt_prof_color_rec.LAST_UPDATE_DATE := P_prof_color_rec.LAST_UPDATE_DATE;
    x_pvt_prof_color_rec.LAST_UPDATED_BY := P_prof_color_rec.LAST_UPDATED_BY;
    x_pvt_prof_color_rec.CREATION_DATE := P_prof_color_rec.CREATION_DATE;
    x_pvt_prof_color_rec.CREATED_BY := P_prof_color_rec.CREATED_BY;
    x_pvt_prof_color_rec.LAST_UPDATE_LOGIN := P_prof_color_rec.LAST_UPDATE_LOGIN;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
END Convert_pub_to_pvt_Rec;

PROCEDURE Convert_Columns_to_Rec (
       p_COLOR_CODE                      VARCHAR2 DEFAULT NULL,
       p_RATING_CODE                     VARCHAR2,
       p_LAST_UPDATE_DATE                DATE,
       p_LAST_UPDATED_BY                 NUMBER,
       p_CREATION_DATE                   DATE,
       p_CREATED_BY                      NUMBER,
       p_LAST_UPDATE_LOGIN               NUMBER,
       x_prof_color_rec     OUT NOCOPY    prof_color_Rec_Type
    )
  IS
BEGIN

    x_prof_color_rec.COLOR_CODE := p_COLOR_CODE;
    x_prof_color_rec.RATING_CODE := p_RATING_CODE;
    x_prof_color_rec.created_by := p_created_by;
    x_prof_color_rec.creation_date := p_creation_date;
    x_prof_color_rec.last_updated_by := p_last_updated_by;
    x_prof_color_rec.last_update_date := p_last_update_date;
    x_prof_color_rec.last_update_login := p_last_update_login;

END Convert_Columns_to_Rec;

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    px_COLOR_CODE                IN OUT NOCOPY    VARCHAR2 ,
    p_RATING_CODE                     VARCHAR2,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_CREATION_DATE                   DATE,
    p_CREATED_BY                      NUMBER,
    p_LAST_UPDATE_LOGIN               NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_prof_color_rec prof_color_Rec_Type;
BEGIN
  Convert_Columns_to_Rec (
    p_RATING_CODE=> p_RATING_CODE   ,
    p_LAST_UPDATE_DATE =>p_LAST_UPDATE_DATE ,
    P_LAST_UPDATED_BY=>p_LAST_UPDATED_BY  ,
    p_CREATION_DATE=>p_CREATION_DATE    ,
    p_CREATED_BY=>p_CREATED_BY       ,
    p_LAST_UPDATE_LOGIN=>p_LAST_UPDATE_LOGIN ,
    x_prof_color_rec=>l_prof_color_rec );

  Create_prof_color_code(
    P_Api_Version_Number    => P_Api_Version_Number,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    P_prof_color_rec => l_prof_color_rec,
    PX_COLOR_CODE     		=> PX_COLOR_CODE,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data   );

END Create_prof_color_code;

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    px_COLOR_CODE     IN OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_prof_color_code';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_prof_color_rec    CSC_PROF_COLOR_CODE_PVT.prof_color_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROF_COLOR_CODE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
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



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

	Convert_pub_to_pvt_Rec (
           P_prof_color_rec       =>  p_prof_color_rec,
           x_pvt_prof_color_rec     =>  l_pvt_prof_color_rec
	);


      CSC_prof_color_code_PVT.Create_prof_color_code(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_prof_color_rec  =>  l_pvt_prof_color_rec ,
      PX_COLOR_CODE     => px_COLOR_CODE,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
End Create_prof_color_code;


PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_COLOR_CODE                      VARCHAR2,
    p_RATING_CODE                     VARCHAR2,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_CREATION_DATE                   DATE,
    p_CREATED_BY                      NUMBER,
    p_LAST_UPDATE_LOGIN               NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

IS
 l_prof_color_rec prof_color_Rec_Type;
BEGIN

 Convert_Columns_to_Rec (
       p_COLOR_CODE    ,
       p_RATING_CODE   ,
       p_LAST_UPDATE_DATE ,
       p_LAST_UPDATED_BY  ,
       p_CREATION_DATE    ,
       p_CREATED_BY       ,
       p_LAST_UPDATE_LOGIN ,
       l_prof_color_rec );

 Update_prof_color_code(
    P_Api_Version_Number    => P_Api_Version_Number,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    P_prof_color_rec   => l_prof_color_rec,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data   );


END Update_prof_color_code;


PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_prof_color_code';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_prof_color_rec  CSC_PROF_COLOR_CODE_PVT.prof_color_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROF_COLOR_CODE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
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



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

	Convert_pub_to_pvt_Rec (
           P_prof_color_rec       =>  p_prof_color_rec,
           x_pvt_prof_color_rec     =>  l_pvt_prof_color_rec
	);


    CSC_prof_color_code_PVT.Update_prof_color_code(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_prof_color_rec  =>  l_pvt_prof_color_rec ,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;


End Update_prof_color_code;

End CSC_PROF_COLOR_CODE_PUB;

/
