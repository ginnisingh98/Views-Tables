--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_LINES_PUB" as
/* $Header: cscpplnb.pls 115.12 2002/11/25 12:34:05 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_LINES_PUB
-- Purpose          : Public package to insert, update and delete records from
--                    CSC_PLAN_LINES table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-21-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 11-25-2002	bhroy		FND_API defaults removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_PLAN_LINES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpplnb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public PLAN_LINES record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private PLAN_LINESrecord is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- 1. IDs take precedence over values. If both are present for a field, ID is used,
--    the value based parameter is ignored and a warning message is created.
-- 2. This is automatically generated procedure, it converts public record type to
--    private record type for all attributes.
--
-- End of Comments
PROCEDURE CONVERT_CSC_PLAN_LINES(
         P_CSC_PLAN_LINES_Rec        IN   CSC_plan_lines_PUB.CSC_PLAN_LINES_Rec_Type,
         x_pvt_CSC_PLAN_LINES_rec    OUT NOCOPY  CSC_plan_lines_PVT.CSC_PLAN_LINES_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type        = X_Lookup_Type
--          AND    nls_upper(meaning) = nls_upper(X_Meaning);

l_any_errors       BOOLEAN   := FALSE;

BEGIN
   -- As of now there are no values to be converted into Ids. So just converts a
   -- public record type into a private record type.

    x_pvt_CSC_PLAN_LINES_rec.LINE_ID := P_CSC_PLAN_LINES_Rec.LINE_ID;
    x_pvt_CSC_PLAN_LINES_rec.PLAN_ID := P_CSC_PLAN_LINES_Rec.PLAN_ID;
    x_pvt_CSC_PLAN_LINES_rec.CONDITION_ID := P_CSC_PLAN_LINES_Rec.CONDITION_ID;
    x_pvt_CSC_PLAN_LINES_rec.CREATION_DATE := P_CSC_PLAN_LINES_Rec.CREATION_DATE;
    x_pvt_CSC_PLAN_LINES_rec.LAST_UPDATE_DATE := P_CSC_PLAN_LINES_Rec.LAST_UPDATE_DATE;
    x_pvt_CSC_PLAN_LINES_rec.CREATED_BY := P_CSC_PLAN_LINES_Rec.CREATED_BY;
    x_pvt_CSC_PLAN_LINES_rec.LAST_UPDATED_BY := P_CSC_PLAN_LINES_Rec.LAST_UPDATED_BY;
    x_pvt_CSC_PLAN_LINES_rec.LAST_UPDATE_LOGIN := P_CSC_PLAN_LINES_Rec.LAST_UPDATE_LOGIN;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE1 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE1;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE2 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE2;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE3 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE3;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE4 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE4;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE5 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE5;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE6 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE6;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE7 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE7;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE8 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE8;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE9 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE9;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE10 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE10;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE11 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE11;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE12 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE12;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE13 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE13;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE14 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE14;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE15 := P_CSC_PLAN_LINES_Rec.ATTRIBUTE15;
    x_pvt_CSC_PLAN_LINES_rec.ATTRIBUTE_CATEGORY := P_CSC_PLAN_LINES_Rec.ATTRIBUTE_CATEGORY;
    x_pvt_CSC_PLAN_LINES_rec.OBJECT_VERSION_NUMBER := P_CSC_PLAN_LINES_Rec.OBJECT_VERSION_NUMBER;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END CONVERT_CSC_PLAN_LINES;


PROCEDURE convert_columns_to_rec_type(
    P_ROW_ID                     IN   ROWID ,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE ,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER ,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER ,
    P_ATTRIBUTE1                 IN   VARCHAR2 ,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    x_csc_plan_lines_rec         OUT NOCOPY  CSC_PLAN_LINES_REC_TYPE)
IS
BEGIN
   x_csc_plan_lines_rec.ROW_ID                := P_ROW_ID;
   x_csc_plan_lines_rec.LINE_ID               := P_LINE_ID;
   x_csc_plan_lines_rec.PLAN_ID               := P_PLAN_ID ;
   x_csc_plan_lines_rec.CONDITION_ID          := P_CONDITION_ID ;
   x_csc_plan_lines_rec.CREATION_DATE         := P_CREATION_DATE ;
   x_csc_plan_lines_rec.LAST_UPDATE_DATE      := P_LAST_UPDATE_DATE ;
   x_csc_plan_lines_rec.CREATED_BY            := P_CREATED_BY ;
   x_csc_plan_lines_rec.LAST_UPDATED_BY       := P_LAST_UPDATED_BY ;
   x_csc_plan_lines_rec.LAST_UPDATE_LOGIN     := P_LAST_UPDATE_LOGIN ;
   x_csc_plan_lines_rec.ATTRIBUTE1            := P_ATTRIBUTE1 ;
   x_csc_plan_lines_rec.ATTRIBUTE2            := P_ATTRIBUTE2 ;
   x_csc_plan_lines_rec.ATTRIBUTE3            := P_ATTRIBUTE3 ;
   x_csc_plan_lines_rec.ATTRIBUTE4            := P_ATTRIBUTE4 ;
   x_csc_plan_lines_rec.ATTRIBUTE5            := P_ATTRIBUTE5 ;
   x_csc_plan_lines_rec.ATTRIBUTE6            := P_ATTRIBUTE6 ;
   x_csc_plan_lines_rec.ATTRIBUTE7            := P_ATTRIBUTE7 ;
   x_csc_plan_lines_rec.ATTRIBUTE8            := P_ATTRIBUTE8 ;
   x_csc_plan_lines_rec.ATTRIBUTE9            := P_ATTRIBUTE9 ;
   x_csc_plan_lines_rec.ATTRIBUTE10           := P_ATTRIBUTE10 ;
   x_csc_plan_lines_rec.ATTRIBUTE11           := P_ATTRIBUTE11 ;
   x_csc_plan_lines_rec.ATTRIBUTE12           := P_ATTRIBUTE12 ;
   x_csc_plan_lines_rec.ATTRIBUTE13           := P_ATTRIBUTE13 ;
   x_csc_plan_lines_rec.ATTRIBUTE14           := P_ATTRIBUTE14 ;
   x_csc_plan_lines_rec.ATTRIBUTE15           := P_ATTRIBUTE15 ;
   x_csc_plan_lines_rec.ATTRIBUTE_CATEGORY    := P_ATTRIBUTE_CATEGORY ;
   x_csc_plan_lines_rec.OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER ;

END convert_columns_to_rec_type;


/* Overloaded procedure to take a detailed parameter list instead of a
   record type parameter */

PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_ROW_ID                     IN   ROWID ,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE ,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER ,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2 ,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    X_LINE_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_csc_plan_lines_rec       CSC_PLAN_LINES_PUB.CSC_PLAN_LINES_REC_TYPE;

BEGIN
   CONVERT_COLUMNS_TO_REC_TYPE(
      P_ROW_ID                => p_row_id,
      P_LINE_ID               => p_line_id,
      P_PLAN_ID               => p_plan_id,
      P_CONDITION_ID          => p_condition_id,
      P_CREATION_DATE         => p_creation_date,
      P_LAST_UPDATE_DATE      => p_last_update_date,
      P_CREATED_BY            => p_created_by,
      P_LAST_UPDATED_BY       => p_last_updated_by,
      P_LAST_UPDATE_LOGIN     => p_last_update_login,
      P_ATTRIBUTE1            => p_attribute1,
      P_ATTRIBUTE2            => p_attribute2,
      P_ATTRIBUTE3            => p_attribute3,
      P_ATTRIBUTE4            => p_attribute4,
      P_ATTRIBUTE5            => p_attribute5,
      P_ATTRIBUTE6            => p_attribute6,
      P_ATTRIBUTE7            => p_attribute7,
      P_ATTRIBUTE8            => p_attribute8,
      P_ATTRIBUTE9            => p_attribute8,
      P_ATTRIBUTE10           => p_attribute9,
      P_ATTRIBUTE11           => p_attribute10,
      P_ATTRIBUTE12           => p_attribute11,
      P_ATTRIBUTE13           => p_attribute12,
      P_ATTRIBUTE14           => p_attribute13,
      P_ATTRIBUTE15           => p_attribute14,
      P_ATTRIBUTE_CATEGORY    => p_attribute15,
      P_OBJECT_VERSION_NUMBER => p_object_version_number,
      x_csc_plan_lines_rec    => l_csc_plan_lines_rec);

-- issue a call to the create_plan_lines proc. that accepts record_type parameters.

   Create_plan_lines(
      P_Api_Version_Number    => p_api_version_number,
      P_Init_Msg_List         => p_init_msg_list,
      P_Commit                => p_commit,
      P_CSC_PLAN_LINES_Rec    => l_csc_plan_lines_rec,
      X_LINE_ID               => x_line_id,
      X_OBJECT_VERSION_NUMBER => x_object_version_number,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data );

END  Create_plan_lines; /* overloaded procedure */


PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_LINE_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Create_plan_lines';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_PLAN_LINES_rec  CSC_PLAN_LINES_PVT.CSC_PLAN_LINES_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PLAN_LINES_PUB;

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

      -- Convert the values to ids
      CONVERT_CSC_PLAN_LINES (
            p_CSC_PLAN_LINES_rec       =>  p_CSC_PLAN_LINES_rec,
            x_pvt_CSC_PLAN_LINES_rec   =>  l_pvt_CSC_PLAN_LINES_rec);

    -- Calling Private package: Create_PLAN_LINES
    -- Hint: Primary key needs to be returned

      CSC_PLAN_LINES_PVT.Create_plan_lines(
         P_Api_Version_Number         => 1,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => FND_API.G_FALSE,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         P_CSC_PLAN_LINES_Rec         => l_pvt_CSC_PLAN_LINES_Rec ,
         X_LINE_ID                    => x_LINE_ID,
         X_OBJECT_VERSION_NUMBER      => x_OBJECT_VERSION_NUMBER,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

End Create_plan_lines;


/* Overloaded procedure to take a detailed parameter list instead of a
   record type parameter */

PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_ROW_ID                     IN   ROWID,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS

   l_csc_plan_lines_rec       CSC_PLAN_LINES_PUB.CSC_PLAN_LINES_REC_TYPE;

BEGIN
   CONVERT_COLUMNS_TO_REC_TYPE(
      P_ROW_ID                => p_row_id,
      P_LINE_ID               => p_line_id,
      P_PLAN_ID               => p_plan_id,
      P_CONDITION_ID          => p_condition_id,
      P_CREATION_DATE         => p_creation_date,
      P_LAST_UPDATE_DATE      => p_last_update_date,
      P_CREATED_BY            => p_created_by,
      P_LAST_UPDATED_BY       => p_last_updated_by,
      P_LAST_UPDATE_LOGIN     => p_last_update_login,
      P_ATTRIBUTE1            => p_attribute1,
      P_ATTRIBUTE2            => p_attribute2,
      P_ATTRIBUTE3            => p_attribute3,
      P_ATTRIBUTE4            => p_attribute4,
      P_ATTRIBUTE5            => p_attribute5,
      P_ATTRIBUTE6            => p_attribute6,
      P_ATTRIBUTE7            => p_attribute7,
      P_ATTRIBUTE8            => p_attribute8,
      P_ATTRIBUTE9            => p_attribute8,
      P_ATTRIBUTE10           => p_attribute9,
      P_ATTRIBUTE11           => p_attribute10,
      P_ATTRIBUTE12           => p_attribute11,
      P_ATTRIBUTE13           => p_attribute12,
      P_ATTRIBUTE14           => p_attribute13,
      P_ATTRIBUTE15           => p_attribute14,
      P_ATTRIBUTE_CATEGORY    => p_attribute15,
      P_OBJECT_VERSION_NUMBER => p_object_version_number,
      x_csc_plan_lines_rec    => l_csc_plan_lines_rec);

-- issue a call to the create_plan_lines proc. that accepts record_type parameters.

   Update_plan_lines(
      P_Api_Version_Number    => p_api_version_number,
      P_Init_Msg_List         => p_init_msg_list,
      P_Commit                => p_commit,
      P_CSC_PLAN_LINES_Rec    => l_csc_plan_lines_rec,
      X_OBJECT_VERSION_NUMBER => x_object_version_number,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data );

END  update_plan_lines;  /* end of overloaded update */


PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_plan_lines';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_PLAN_LINES_rec  CSC_PLAN_LINES_PVT.CSC_PLAN_LINES_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PLAN_LINES_PUB;

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

      -- Convert the values to ids
      CONVERT_CSC_PLAN_LINES (
            p_CSC_PLAN_LINES_rec       =>  p_CSC_PLAN_LINES_rec,
            x_pvt_CSC_PLAN_LINES_rec   =>  l_pvt_CSC_PLAN_LINES_rec);

      -- Call private API to perform validations and the update.
      CSC_plan_lines_PVT.Update_plan_lines(
         P_Api_Version_Number         => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => p_commit,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         P_CSC_PLAN_LINES_Rec         => l_pvt_CSC_PLAN_LINES_Rec ,
         X_OBJECT_VERSION_NUMBER      => x_object_version_number,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

End Update_plan_lines;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER  ,
    P_LINE_ID                    IN   NUMBER  ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_plan_lines';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_PLAN_LINES_rec  CSC_PLAN_LINES_PVT.CSC_PLAN_LINES_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PLAN_LINES_PUB;

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

      CSC_plan_lines_PVT.Delete_plan_lines(
         P_Api_Version_Number         => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => p_commit,
	    P_PLAN_ID                    => p_plan_id,
         P_LINE_ID                    => p_line_id,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

End Delete_plan_lines;

End CSC_PLAN_LINES_PUB;

/
