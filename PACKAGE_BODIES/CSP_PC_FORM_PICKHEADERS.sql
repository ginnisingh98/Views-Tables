--------------------------------------------------------
--  DDL for Package Body CSP_PC_FORM_PICKHEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PC_FORM_PICKHEADERS" AS
/*$Header: cspgtphb.pls 120.0 2005/05/25 11:31:02 appldev noship $*/
-- Start of Comments
-- Package name     : CSP_PC_FORM_PICKHEADERS
-- Purpose          : A wrapper to prepare data to call the update, delete and insert procedures of the
--                    CSP_picklist_header_PVT.
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ------      ------------------------------------------
-- klou       02/09/00     Add standrd messages.
-- klou       01/12/00     Replace change AS_UTILITY call with JTF_PLSQL_API.
-- klou       17/12/99     Create.
--
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PC_FORM_PICKHEADERS';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtphb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Validate_And_Write (
       P_Api_Version_Number        IN        NUMBER,
       P_Init_Msg_List             IN        VARCHAR2     := FND_API.G_FALSE,
       P_Commit                    IN        VARCHAR2     := FND_API.G_FALSE,
       p_validation_level          IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_action_code               IN        NUMBER,
       px_picklist_header_id       IN OUT NOCOPY    NUMBER,
       p_CREATED_BY                IN      NUMBER := FND_API.G_MISS_NUM,
       p_CREATION_DATE             IN      DATE := FND_API.G_MISS_DATE,
       p_LAST_UPDATED_BY           IN      NUMBER := FND_API.G_MISS_NUM,
       p_LAST_UPDATE_DATE          IN      DATE := FND_API.G_MISS_DATE,
       p_LAST_UPDATE_LOGIN         IN      NUMBER := FND_API.G_MISS_NUM,
       p_ORGANIZATION_ID           IN      NUMBER := FND_API.G_MISS_NUM,
       p_PICKLIST_NUMBER           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_PICKLIST_STATUS           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_DATE_CREATED              IN      DATE := FND_API.G_MISS_DATE,
       p_DATE_CONFIRMED            IN      DATE := FND_API.G_MISS_DATE,
       p_ATTRIBUTE_CATEGORY        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE1                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE2                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE3                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE4                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE5                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE6                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE7                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE8                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE9                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE10               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE11               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE12               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE13               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE14               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
       p_ATTRIBUTE15               IN      VARCHAR2,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    )
 IS
    l_api_version_number        CONSTANT NUMBER  := 1.0;
    l_api_name                  CONSTANT VARCHAR2(20) := 'Validate_And_Write';
    l_msg_data                  VARCHAR2(300);
    l_check_existence           NUMBER := 0;
    l_check_var                 VARCHAR2(30);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER  := 0;
    l_picklist_header_id        NUMBER;
    l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
    -- for inserting data, the validation_level should be none
    -- because we do not want to call the core apps standard validations.
    l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_creation_date             DATE := p_creation_date;
    l_last_update_date          DATE := p_last_update_date;
    l_PICK_HEADER_Rec           CSP_PICKLIST_HEADER_PVT.PICK_HEADER_Rec_Type;
    EXCP_USER_DEFINED           EXCEPTION;
    l_created_by                NUMBER := p_created_by;
    l_last_update_login         NUMBER := p_last_update_login;
    l_last_updated_by           NUMBER := p_last_updated_by;
    Cursor l_Get_Creation_Date_Csr Is
       Select creation_date
       From csp_picklist_headers
       Where picklist_header_id = px_PICKLIST_HEADER_ID;

BEGIN
    SAVEPOINT Validate_And_Write_PUB;
      IF fnd_api.to_boolean(P_Init_Msg_List) THEN
          -- initialize message list
            FND_MSG_PUB.initialize;
      END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF nvl(p_action_code, fnd_api.g_miss_num) NOT IN (0, 1, 2) THEN
         fnd_message.set_name ('INV', 'INV-INVALID ACTION');
         fnd_message.set_token ('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
         fnd_msg_pub.add;
         RAISE EXCP_USER_DEFINED;
    END IF;

    IF p_action_code = 0  THEN
          IF nvl(px_picklist_header_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              -- check whethter the px_picklist_header_id already exists.
              BEGIN
                  SELECT picklist_header_id INTO l_check_existence
                  FROM CSP_PICKLIST_HEADERS
                  WHERE picklist_header_id = px_picklist_header_id
                  AND organization_id = p_organization_id;

                  fnd_message.set_name ('CSP', 'CSP_DUPLICATE_RECORD');
                  fnd_msg_pub.add;
                 -- l_msg_data := 'Header ID '||px_picklist_header_id||' already exists. It is not allowed to create a new record again with this ID.';
                  RAISE EXCP_USER_DEFINED;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN  -- This is what we want!
                      NULL;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'px_picklist_header_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'CSP_PICKLIST_HEADERS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
          END IF;

          -- Validate the status against the lookup codes.
          IF nvl(p_PICKLIST_STATUS, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                  FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                  FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_picklist_status', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
          ELSE
              BEGIN
                  select distinct lookup_code into l_check_var
                  from fnd_lookups
                  where lookup_type = 'CSP_PICKLIST_STATUS'
                  and lookup_code = p_PICKLIST_STATUS;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('CSP', 'CSP_INVALID_PICK_STATUS');
                      fnd_message.set_token('PICKLIST_STATUS', p_PICKLIST_STATUS, FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'px_picklist_status', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'FND_LOOKUPS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
               END;
           END IF;

        --validation of organization_id
          IF nvl(p_organization_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          ELSE
                    BEGIN
                        select organization_id into l_check_existence
                        from mtl_parameters
                        where organization_id = p_organization_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                             FND_MSG_PUB.ADD;
                             RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_organization_id', FALSE);
                            fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                            fnd_message.set_token('TABLE', 'ORG_ORGANIZATION_DEFINITIONS', FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                   END;
          END IF;

      -- check creation_date and last_update_date
         IF nvl(l_creation_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_creation_date := sysdate;
         END IF;

         IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
         END IF;

         IF nvl(l_created_by, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_created_by := g_user_id;
         END IF;

         IF nvl(l_last_update_login, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_last_update_login := g_login_id;
         END IF;

         IF nvl(l_last_updated_by, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              l_last_updated_by := g_user_id;
         END IF;


     ELSIF p_action_code = 1 THEN
          -- Picklist header id is required for update.
          -- We do need to take care the case which the user updates the picklist_header_id to a record
          -- which already exists because the picklist_header_id is a primary key.
          IF nvl(px_picklist_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_header_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          ELSE
              BEGIN
                  select picklist_header_id into l_check_existence
                  from csp_picklist_headers
                  where picklist_header_id = px_picklist_header_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('CSP', 'CSP_INVALID_PICKLIST_HEADER');
                      fnd_message.set_token ('HEADER_ID', to_char(px_picklist_header_id), FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'px_picklist_header_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'CSP_PICKLIST_HEADERS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
          END IF;

          -- Validate the status against the lookup codes.
          IF nvl(p_PICKLIST_STATUS, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
              BEGIN
                  select distinct lookup_code into l_check_var
                  from fnd_lookups
                  where lookup_type = 'CSP_PICKLIST_STATUS'
                  and lookup_code = p_PICKLIST_STATUS;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('CSP', 'CSP_INVALID_PICK_STATUS');
                      fnd_message.set_token('PICKLIST_STATUS', p_PICKLIST_STATUS, FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'px_picklist_status', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'FND_LOOKUPS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
               END;
          END IF;

        --validation of organization_id
          IF nvl(p_organization_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                BEGIN
                    select organization_id into l_check_existence
                    from mtl_parameters
                    where organization_id = p_organization_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                         FND_MSG_PUB.ADD;
                         RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_organization_id', FALSE);
                        fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'MTL_PARAMETERS', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
               END;
          END IF;

        -- validate the creation_date
          IF nvl(l_creation_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              Open l_Get_Creation_Date_Csr;
              Fetch l_Get_Creation_Date_Csr into l_creation_date;
              If l_Get_Creation_Date_Csr%NOTFOUND Then
                  Close l_Get_Creation_Date_Csr;
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_cretaion_date', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_PICKLIST_HEADERS', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              End if;
              Close l_Get_Creation_Date_Csr;
           End if;

           IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
           END IF;

      ELSE  -- p_action_code = 2
           IF nvl(px_picklist_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
              FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_picklist_header_id', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
           ELSE
              BEGIN
                  select picklist_header_id/0 into l_check_existence
                  from csp_picklist_headers
                  where picklist_header_id = px_picklist_header_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('CSP', 'CSP_INVALID_PICKLIST_HEADER');
                      fnd_message.set_token ('HEADER_ID', to_char(px_picklist_header_id), FALSE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'px_picklist_header_id', FALSE);
                      fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'CSP_PICKLIST_HEADERS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
          END IF;

      END IF;

 -- Construct the record to call the CSP_picklist_header_PVT insert, update and delete operation
            l_pick_header_rec.picklist_header_id             := px_picklist_header_id;
            l_pick_header_rec.CREATED_BY                      := nvl(l_CREATED_BY, fnd_api.g_miss_num);
            l_pick_header_rec.CREATION_DATE                   := l_CREATION_DATE;
            l_pick_header_rec.LAST_UPDATED_BY                 := nvl(l_LAST_UPDATED_BY, fnd_api.g_miss_num);
            l_pick_header_rec.LAST_UPDATE_DATE                := l_LAST_UPDATE_DATE;
            l_pick_header_rec.LAST_UPDATE_LOGIN               := l_LAST_UPDATE_LOGIN;
            l_pick_header_rec.ORGANIZATION_ID                 := nvl(p_ORGANIZATION_ID, fnd_api.g_miss_num);
            l_pick_header_rec.PICKLIST_NUMBER                 := p_PICKLIST_NUMBER;
            l_pick_header_rec.PICKLIST_STATUS                 := nvl(p_PICKLIST_STATUS, fnd_api.g_miss_char);
            l_pick_header_rec.DATE_CREATED                    := p_DATE_CREATED;
            l_pick_header_rec.DATE_CONFIRMED                  := p_DATE_CONFIRMED;
            l_pick_header_rec.ATTRIBUTE_CATEGORY              := p_ATTRIBUTE_CATEGORY;
            l_pick_header_rec.ATTRIBUTE1                      := p_ATTRIBUTE1;
            l_pick_header_rec.ATTRIBUTE2                      := p_ATTRIBUTE2;
            l_pick_header_rec.ATTRIBUTE3                      := p_ATTRIBUTE3;
            l_pick_header_rec.ATTRIBUTE4                      := p_ATTRIBUTE4;
            l_pick_header_rec.ATTRIBUTE5                      := p_ATTRIBUTE5;
            l_pick_header_rec.ATTRIBUTE6                      := p_ATTRIBUTE6;
            l_pick_header_rec.ATTRIBUTE7                      := p_ATTRIBUTE7;
            l_pick_header_rec.ATTRIBUTE8                      := p_ATTRIBUTE8;
            l_pick_header_rec.ATTRIBUTE9                      := p_ATTRIBUTE9;
            l_pick_header_rec.ATTRIBUTE10                     := p_ATTRIBUTE10;
            l_pick_header_rec.ATTRIBUTE11                     := p_ATTRIBUTE11;
            l_pick_header_rec.ATTRIBUTE12                     := p_ATTRIBUTE12;
            l_pick_header_rec.ATTRIBUTE13                     := p_ATTRIBUTE13;
            l_pick_header_rec.ATTRIBUTE14                     := p_ATTRIBUTE14;
            l_pick_header_rec.ATTRIBUTE15                     := p_ATTRIBUTE15;

        -- call different operations based on the p_action_code
        IF p_action_code = 0 THEN
                -- call create procedure
                CSP_PICKLIST_HEADER_PVT.Create_picklist_header(
                    P_Api_Version_Number         => P_Api_Version_Number,
                    P_Init_Msg_List              => P_Init_Msg_List,
                    P_Commit                     => l_Commit,
                    p_validation_level           => l_validation_level,
                    P_PICK_HEADER_Rec            => l_PICK_HEADER_Rec,
                    X_picklist_header_id         => l_picklist_header_id,
                    X_Return_Status              => l_Return_Status,
                    X_Msg_Count                  => l_Msg_Count,
                    X_Msg_Data                   => l_Msg_Data
                    );

        ELSIF p_action_code = 1 THEN
               -- call update procedure
               CSP_PICKLIST_HEADER_PVT.Update_picklist_header(
                    P_Api_Version_Number         => P_Api_Version_Number,
                    P_Init_Msg_List              => P_Init_Msg_List,
                    P_Commit                     => l_Commit,
                    p_validation_level           => l_validation_level,
                    P_PICK_HEADER_Rec            => l_PICK_HEADER_Rec,
                    X_Return_Status              => l_Return_Status,
                    X_Msg_Count                  => l_Msg_Count,
                    X_Msg_Data                   => l_Msg_Data
                    );

        ELSE
            -- call delete procedure
            CSP_PICKLIST_HEADER_PVT.Delete_picklist_header(
                    P_Api_Version_Number         => P_Api_Version_Number,
                    P_Init_Msg_List              => P_Init_Msg_List,
                    P_Commit                     => l_Commit,
                    p_validation_level           => l_validation_level,
                    P_PICK_HEADER_Rec            => l_PICK_HEADER_Rec,
                    X_Return_Status              => l_Return_Status,
                    X_Msg_Count                  => l_Msg_Count,
                    X_Msg_Data                   => l_Msg_Data
                    );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_return_status :=  FND_API.G_RET_STS_SUCCESS;
        px_picklist_header_id := l_picklist_header_id;
        IF fnd_api.to_boolean(p_commit) THEN
            commit work;
        END IF;

EXCEPTION
          WHEN EXCP_USER_DEFINED THEN
              Rollback to Validate_And_Write_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);

              --for debugging purpose
              --x_msg_data := l_msg_data;

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
                  Rollback to Validate_And_Write_PUB;
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                  fnd_message.set_token ('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                  fnd_message.set_token ('SQLERRM', sqlerrm, FALSE);
                  fnd_msg_pub.add;
                  fnd_msg_pub.count_and_get
                 ( p_count => x_msg_count
                 , p_data  => x_msg_data);
                  x_return_status := fnd_api.g_ret_sts_error;

END Validate_And_Write;

END CSP_PC_FORM_PICKHEADERS;

/
