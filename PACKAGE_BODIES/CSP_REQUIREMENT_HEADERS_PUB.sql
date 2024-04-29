--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_PUB" AS
/* $Header: cspprqhb.pls 120.0.12010000.3 2011/04/22 00:10:45 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_Requirement_Headers_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Requirement_Headers_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspprqhb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public Requirement_Headers record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private Requirement_Headers record is returned for the private
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
--    Developer must manually add conversion logic to the attributes.
--
-- End of Comments
PROCEDURE Convert_RQH_Values_To_Ids(
         P_RQH_Rec        IN   CSP_requirement_headers_PUB.RQH_Rec_Type,
         x_pvt_RQH_rec    OUT  NOCOPY   CSP_requirement_headers_PVT.Requirement_Header_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
   CURSOR C_Get_Task_Id(X_Task_Number VARCHAR2) IS
          SELECT task_id
          FROM   jtf_Tasks_b
          WHERE  task_number = x_Task_Number;
l_any_errors       BOOLEAN   := FALSE;
l_task_id           Number;
EXCP_USER_DEFINED EXCEPTION;
BEGIN

  If(p_rqh_rec.task_id is NOT NULL and p_rqh_rec.task_id <> FND_API.G_MISS_NUM)
  THEN
       x_pvt_rqh_rec.task_id := p_rqh_rec.task_id;
  ELSIF(p_rqh_rec.task_number is NOT NULL and p_rqh_rec.task_number <> FND_API.G_MISS_CHAR)
  THEN
       OPEN C_Get_Task_Id(P_RQH_Rec.task_number);
       FETCH C_Get_Task_Id INTO l_task_id;

       IF C_Get_Task_Id%NOTFOUND THEN
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TASK_INVALID_TASK_NUMBER');
         FND_MESSAGE.SET_TOKEN ('P_TASK_NUMBER', P_RQH_Rec.task_number, FALSE);
         FND_MSG_PUB.ADD;
         RAISE EXCP_USER_DEFINED;
       END IF;
       CLOSE C_Get_Task_Id;
       x_pvt_rqh_rec.task_id := l_task_id;
  ELSE
        x_pvt_rqh_rec.task_id := nvl(p_RQH_Rec.task_id, NULL);
  END IF;


  -- Now copy the rest of the columns to the private record
  -- Hint: We provide copy all columns to the private record.
  --       Developer should delete those fields which are used by Value-Id conversion above
    -- Hint: Developer should remove some of the following statements because of inconsistent column name between table and view.

    x_pvt_RQH_rec.REQUIREMENT_HEADER_ID := P_RQH_Rec.REQUIREMENT_HEADER_ID;
    x_pvt_RQH_rec.CREATED_BY := P_RQH_Rec.CREATED_BY;
    x_pvt_RQH_rec.CREATION_DATE := P_RQH_Rec.CREATION_DATE;
    x_pvt_RQH_rec.LAST_UPDATED_BY := P_RQH_Rec.LAST_UPDATED_BY;
    x_pvt_RQH_rec.LAST_UPDATE_DATE := P_RQH_Rec.LAST_UPDATE_DATE;
    x_pvt_RQH_rec.LAST_UPDATE_LOGIN := P_RQH_Rec.LAST_UPDATE_LOGIN;
    x_pvt_RQH_rec.OPEN_REQUIREMENT := P_RQH_Rec.OPEN_REQUIREMENT;
    x_pvt_RQH_rec.ADDRESS_TYPE := P_RQH_Rec.ADDRESS_TYPE;
    x_pvt_RQH_rec.SHIP_TO_LOCATION_ID := P_RQH_Rec.SHIP_TO_LOCATION_ID;
    x_pvt_RQH_rec.TIMEZONE_ID := P_RQH_Rec.TIMEZONE_ID;
  --  x_pvt_RQH_rec.TASK_ID := P_RQH_Rec.TASK_ID;
    x_pvt_RQH_rec.TASK_ASSIGNMENT_ID := P_RQH_Rec.TASK_ASSIGNMENT_ID;
    x_pvt_RQH_rec.RESOURCE_TYPE := P_RQH_Rec.RESOURCE_TYPE;
    x_pvt_RQH_rec.RESOURCE_ID := P_RQH_Rec.RESOURCE_ID;
    x_pvt_RQH_rec.SHIPPING_METHOD_CODE := P_RQH_Rec.SHIPPING_METHOD_CODE;
    x_pvt_RQH_rec.NEED_BY_DATE := P_RQH_Rec.NEED_BY_DATE;
    x_pvt_RQH_rec.DESTINATION_ORGANIZATION_ID := P_RQH_Rec.DESTINATION_ORGANIZATION_ID;
    x_pvt_RQH_rec.ORDER_TYPE_ID := P_RQH_Rec.ORDER_TYPE_ID;
    x_pvt_RQH_rec.PARTS_DEFINED := P_RQH_Rec.PARTS_DEFINED;
    x_pvt_RQH_rec.ATTRIBUTE_CATEGORY := P_RQH_Rec.ATTRIBUTE_CATEGORY;
    x_pvt_RQH_rec.ATTRIBUTE1 := P_RQH_Rec.ATTRIBUTE1;
    x_pvt_RQH_rec.ATTRIBUTE2 := P_RQH_Rec.ATTRIBUTE2;
    x_pvt_RQH_rec.ATTRIBUTE3 := P_RQH_Rec.ATTRIBUTE3;
    x_pvt_RQH_rec.ATTRIBUTE4 := P_RQH_Rec.ATTRIBUTE4;
    x_pvt_RQH_rec.ATTRIBUTE5 := P_RQH_Rec.ATTRIBUTE5;
    x_pvt_RQH_rec.ATTRIBUTE6 := P_RQH_Rec.ATTRIBUTE6;
    x_pvt_RQH_rec.ATTRIBUTE7 := P_RQH_Rec.ATTRIBUTE7;
    x_pvt_RQH_rec.ATTRIBUTE8 := P_RQH_Rec.ATTRIBUTE8;
    x_pvt_RQH_rec.ATTRIBUTE9 := P_RQH_Rec.ATTRIBUTE9;
    x_pvt_RQH_rec.ATTRIBUTE10 := P_RQH_Rec.ATTRIBUTE10;
    x_pvt_RQH_rec.ATTRIBUTE11 := P_RQH_Rec.ATTRIBUTE11;
    x_pvt_RQH_rec.ATTRIBUTE12 := P_RQH_Rec.ATTRIBUTE12;
    x_pvt_RQH_rec.ATTRIBUTE13 := P_RQH_Rec.ATTRIBUTE13;
    x_pvt_RQH_rec.ATTRIBUTE14 := P_RQH_Rec.ATTRIBUTE14;
    x_pvt_RQH_rec.ATTRIBUTE15 := P_RQH_Rec.ATTRIBUTE15;
    x_pvt_RQH_rec.DESTINATION_SUBINVENTORY := P_RQH_Rec.DESTINATION_SUBINVENTORY;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_RQH_Values_To_Ids;

PROCEDURE Validate_Requirement_Header(l_pvt_RQH_rec CSP_REQUIREMENT_HEADERS_PVT.Requirement_Header_Rec_Type) IS
l_count  NUMBER;
EXCP_USER_DEFINED EXCEPTION;
BEGIN
  IF (l_pvt_RQH_rec.address_type IS NOT NULL
      AND l_pvt_RQH_rec.address_type <> FND_API.G_MISS_CHAR
      AND l_pvt_RQH_rec.address_type NOT IN ('R', 'T', 'C', 'S')) THEN
    FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_ADDRESS_TYPE');
    FND_MSG_PUB.ADD;
    RAISE EXCP_USER_DEFINED;
  END IF;
  IF (l_pvt_RQH_Rec.ship_to_location_id IS NOT NULL
       AND l_pvt_RQH_rec.ship_to_location_id <> FND_API.G_MISS_NUM) THEN
    BEGIN
      SELECT count(location_id)
      INTO l_count
      FROM hr_locations
      WHERE location_id = l_pvt_RQH_Rec.ship_to_location_id;
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('PAY', 'HR_52034_DPF_LOCATION_EXIST');
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.task_id IS NOT NULL
      AND l_pvt_RQH_rec.task_id <> FND_API.G_MISS_NUM) THEN
    BEGIN
      SELECT count(task_id)
      INTO l_count
      FROM jtf_Tasks_b
      WHERE task_id = l_pvt_RQH_Rec.task_id;
      IF (l_count <= 0) THEN
          FND_MESSAGE.SET_NAME ('JTF', 'JTF_TASK_INVALID_TASK_ID');
          FND_MESSAGE.SET_TOKEN ('P_TASK_ID', l_pvt_RQH_rec.task_id, FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.task_assignment_id IS NOT NULL
      AND l_pvt_RQH_rec.task_assignment_id <> FND_API.G_MISS_NUM) THEN
    BEGIN
      SELECT count(task_assignment_id)
      INTO l_count
      FROM jtf_Task_assignments
      WHERE task_assignment_id = l_pvt_RQH_Rec.task_assignment_id;
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('JTF', 'JTF_TASK_INV_TK_ASS');
        FND_MESSAGE.SET_TOKEN ('P_TASK_ASSIGNMENT_ID', l_pvt_RQH_rec.task_assignment_id, FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.resource_type IS NOT NULL
      AND l_pvt_RQH_rec.resource_type <> FND_API.G_MISS_CHAR) THEN
    BEGIN
      SELECT count(jov.object_code)
      INTO l_count
      FROM   jtf_objects_vl jov,
             jtf_object_usages jou
      WHERE trunc(sysdate) between trunc(nvl(jov.start_date_active,sysdate))
               and trunc(nvl(jov.end_date_active,sysdate))
      AND  jou.object_code = jov.object_code
      AND  jou.object_user_code = 'RESOURCES'
      AND  jov.object_code = l_pvt_RQH_rec.resource_type;
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('JTF', 'JTF_AM_INVALID_RESOURCE_TYPE');
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.resource_id IS NOT NULL
      AND l_pvt_RQH_rec.resource_id <> FND_API.G_MISS_NUM) THEN
    BEGIN
      SELECT count(resource_id)
      INTO l_count
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_pvt_RQH_rec.resource_id
      AND ( end_date_active is null OR
		    trunc(end_date_active) >= trunc(sysdate));
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('JTF', 'JTF_TASK_INV_RES_ID');
        FND_MESSAGE.SET_TOKEN ('P_RESOURCE_ID',  l_pvt_RQH_rec.resource_id, FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.destination_organization_id IS NOT NULL
      AND l_pvt_RQH_rec.destination_organization_id <> FND_API.G_MISS_NUM) THEN
    BEGIN
      SELECT count(organization_id)
      INTO l_count
      FROM mtl_parameters
      WHERE organization_id = l_pvt_RQH_rec.destination_organization_id;
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('INV', 'INV_ENTER_VALID_TOORG');
        --FND_MESSAGE.SET_TOKEN ('PARAMETER', 'DESTINATION_ORGANIZATION', FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.destination_subinventory IS NOT NULL
      AND l_pvt_RQH_rec.destination_subinventory <> FND_API.G_MISS_CHAR) THEN
    BEGIN
      SELECT count(secondary_inventory_name)
      INTO l_count
      FROM mtl_secondary_inventories
      WHERE organization_id = nvl(l_pvt_RQH_rec.destination_organization_id, organization_id)
      AND secondary_inventory_name = l_pvt_RQH_rec.destination_subinventory;
      IF (l_count <= 0) THEN
        FND_MESSAGE.SET_NAME ('INV', 'INV-NO SUBINVENTORY RECORD');
        FND_MESSAGE.SET_TOKEN ('SUBINV', l_pvt_RQH_rec.destination_subinventory, FALSE);
        FND_MESSAGE.SET_TOKEN ('ORG', l_pvt_RQH_rec.destination_organization_id, FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END IF;
    EXCEPTION
      when no_Data_found then
        null;
    END;
  END IF;
  IF (l_pvt_RQH_Rec.need_by_date IS NOT NULL
      AND l_pvt_RQH_rec.need_by_date <> FND_API.G_MISS_DATE
      AND trunc(l_pvt_RQH_rec.need_By_date) < trunc(sysdate)) THEN
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_NEED_BY_DATE');
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
  END IF;
END;

PROCEDURE Create_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN   RQH_Rec_Type  := G_MISS_RQH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REQUIREMENT_HEADER_ID      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_requirement_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQH_rec             CSP_Requirement_Headers_PVT.Requirement_Header_Rec_Type;
l_requirement_header_id   NUMBER;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Requirement_Headers_PUB;

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


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_RQH_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RQH_Values_To_Ids (
            p_RQH_rec       =>  p_RQH_rec,
            x_pvt_RQH_rec   =>  l_pvt_RQH_rec
      );

      Validate_Requirement_Header(l_pvt_RQH_rec);

    -- Calling Private package: Create_Packlist_Headers
    -- Hint: Primary key needs to be returned
      CSP_requirement_headers_PVT.Create_requirement_headers(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_REQUIREMENT_HEADER_Rec     => l_pvt_RQH_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_REQUIREMENT_HEADER_ID      => l_REQUIREMENT_HEADER_ID,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_requirement_header_id := l_requirement_header_id;
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_requirement_headers;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN   RQH_Rec_Type := G_MISS_RQH_REC,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_requirement_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQH_rec             CSP_Requirement_Headers_PVT.Requirement_Header_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Packlist_Headers_PUB;

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

      -- Convert the values to ids
      --
      Convert_RQH_Values_To_Ids (
            p_RQH_rec       =>  p_RQH_rec,
            x_pvt_RQH_rec   =>  l_pvt_RQH_rec
      );

    Validate_Requirement_Header(l_pvt_RQH_rec);

    CSP_requirement_headers_PVT.Update_requirement_headers(
        P_Api_Version_Number         => 1.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => p_commit,
        P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
        P_Requirement_Header_Rec     =>  l_pvt_RQH_Rec ,
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


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_requirement_headers;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN   RQH_Rec_Type,
    X_Return_Status              OUT  NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY  NUMBER,
    X_Msg_Data                   OUT  NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_requirement_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQH_rec             CSP_Requirement_Headers_PVT.Requirement_Header_Rec_Type;
I                         NUMBER;
CURSOR rqmt_lines_cur(p_rqmt_header_id NUMBER) IS
  SELECT REQUIREMENT_LINE_ID
 /*        CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         REQUIREMENT_HEADER_ID,
         INVENTORY_ITEM_ID,
         UOM_CODE,
         REQUIRED_QUANTITY,
         SHIP_COMPLETE_FLAG,
         LIKELIHOOD,
         REVISION,
         SOURCE_ORGANIZATION_ID,
         SOURCE_SUBINVENTORY,
         ORDERED_QUANTITY,
         ORDER_LINE_ID,
         RESERVATION_ID,
         LOCAL_RESERVATION_ID,
         ORDER_BY_DATE ,
         ARRIVAL_DATE,
         ITEM_SCRATCHPAD,
         SHIPPING_METHOD_CODE,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         SECURITY_GROUP_ID,
         SOURCED_FROM
 */
     FROM csp_requirement_lines
     WHERE requirement_header_id = p_rqmt_header_id;
 l_RQL_TBL                 CSP_Requirement_lines_PUB.RQL_Tbl_Type;
 l_RQL_Rec                 CSP_Requirement_lines_PUB.RQL_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Requirement_Headers_PUB;

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


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_RQH_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RQH_Values_To_Ids (
            p_RQH_rec       =>  p_RQH_rec,
            x_pvt_RQH_rec   =>  l_pvt_RQH_rec
      );

    -- Delete all requirement lines for this header
    -- before deleting the header
    OPEN rqmt_lines_cur(P_RQH_Rec.requirement_header_id);
    I := 1;
    LOOP
      FETCH rqmt_lines_cur INTO l_RQL_Rec.requirement_line_id;
      EXIT WHEN rqmt_lines_cur%NOTFOUND;
      l_RQL_TBL(I) := l_RQL_rec;
      I := I + 1;
    END LOOP;

    IF (l_RQL_TBL.COUNT > 0) THEN
      CSP_requirement_lines_pub.Delete_requirement_lines(
        P_Api_Version_Number         => 1.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => p_commit,
        P_RQL_TBL                    => l_RQL_TBL,
        X_Return_Status              => x_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    CSP_requirement_headers_PVT.Delete_requirement_headers(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Header_Rec     => l_pvt_RQH_Rec,
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

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_requirement_headers;

END CSP_REQUIREMENT_HEADERS_PUB;

/
