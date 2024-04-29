--------------------------------------------------------
--  DDL for Package Body CSP_TO_FORM_MOHEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TO_FORM_MOHEADERS" AS
/*$Header: cspgtmhb.pls 115.21 2002/11/26 06:53:45 hhaugeru ship $*/
-- Start of Comments
-- Package name     : CSP_TO_FORM_MOMEAHDERS_B
-- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
--                    the prviate API in the CSP_MOVEORDER_HEADERS_PVT package.
-- History          : 11/17/1999, Created by Vernon Lou
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_TO_FORM_MOHEADERS';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtmhb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Validate_And_Write (
      P_Api_Version_Number           IN   NUMBER,
      P_Init_Msg_List                IN   VARCHAR2 := FND_API.G_FALSE,
      P_Commit                       IN   VARCHAR2 := FND_API.G_FALSE,
      p_validation_level             IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
      p_header_id                    IN   NUMBER   := FND_API.G_MISS_NUM,
      p_created_by                   IN   NUMBER   := FND_API.G_MISS_NUM,
      p_creation_date                IN   DATE     := FND_API.G_MISS_DATE,
      p_last_updated_by              IN   NUMBER   := FND_API.G_MISS_NUM,
      p_last_update_date             IN   DATE     := FND_API.G_MISS_DATE,
      p_last_update_login            IN   NUMBER   := FND_API.G_MISS_NUM,
      p_carrier                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_shipment_method              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_autoreceipt_flag             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute_category           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute1                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute2                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute3                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute4                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute5                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute6                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute7                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute8                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute9                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute10                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute11                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute12                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute13                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute14                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_attribute15                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
      p_location_id                  IN   NUMBER := FND_API.G_MISS_NUM,
      p_party_site_id                IN   NUMBER,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  NUMBER,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
     )
IS
    l_moheader_rec CSP_ORDERHEADERS_PVT.MOH_Rec_Type;
    l_header_id NUMBER := p_header_id;

    l_api_version_number        CONSTANT NUMBER  := 1.0;
    l_api_name                  CONSTANT VARCHAR2(50) := 'Validate_And_Write';
    l_msg_data                  VARCHAR2(300);
    l_check_existence           NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER  := 0;
    l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_pkg_api_name              CONSTANT VARCHAR2(80) := G_PKG_NAME ||'.'||l_api_name;
    l_carrier                   VARCHAR2(25);
    EXCP_USER_DEFINED           EXCEPTION;

    l_creation_date             DATE := p_creation_date;
    l_last_update_date          DATE := p_last_update_date;
    l_created_by                NUMBER := p_created_by;
    l_last_update_login         NUMBER := p_last_update_login;
    l_last_updated_by           NUMBER := p_last_updated_by;
    Cursor l_Get_Creation_Date_Csr Is
      Select creation_date
      From csp_moveorder_headers
      Where header_id = p_header_id;
    Cursor l_Get_Header_ID_Csr IS
      Select header_id
      From csp_moveorder_headers
      Where header_id = p_header_id;

BEGIN
    savepoint Validate_And_Write_PUB;

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


    -- check p_action_code
    IF p_action_code not in (0, 1, 2) THEN
          fnd_message.set_name('INV', 'INV-INVALID ACTION');
          fnd_message.set_token('ROUTINE', l_api_name, FALSE);
          fnd_msg_pub.add;
          RAISE EXCP_USER_DEFINED;
    END IF;

    IF p_action_code = 0 THEN
        -- For inserting, we need to validate the header_id and the carrier.
        IF nvl(p_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_header_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            -- First we need to validate whether the given header_id already exists in the csp_moveorder_headers.
            OPEN l_Get_Header_ID_Csr;
            FETCH l_Get_Header_ID_Csr INTO l_check_existence;
            IF l_Get_Header_ID_Csr%NOTFOUND THEN
             -- Now, validate whether the given header_id exists in the mtl_txn_request_headers table.
                BEGIN
                    SELECT header_id INTO l_check_existence
                    FROM mtl_txn_request_headers
                    WHERE header_id = p_header_id;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_MOVEORDER');
                      FND_MESSAGE.SET_TOKEN('HEADER_ID', to_char(p_header_id), FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_header_id', FALSE);
                      fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                      fnd_message.set_token('TABLE', 'MTL_TXN_REQUEST_HEADERS', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;

                END;
            ELSE
                fnd_message.set_name ('CSP', 'CSP_DUPLICATE_RECORD');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
            END IF;
            CLOSE l_Get_Header_ID_Csr;

         END IF;

        IF nvl(p_carrier, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
            -- Validate whether the p_carrier exists.
            BEGIN
                SELECT distinct freight_code INTO l_carrier
                FROM org_freight_tl
                WHERE freight_code = p_carrier
                AND organization_id = (SELECT organization_id FROM mtl_txn_request_headers
                                       WHERE header_id = p_header_id);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_CARRIER');
                    FND_MESSAGE.SET_TOKEN('CARRIER_CODE', p_carrier, FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_carrier', FALSE);
                  fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'ORG_FREIGHT_TL', FALSE);
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
        IF nvl(p_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_header_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            -- Validate whether the given header_id exists in the mtl_txn_request_headers table.
            BEGIN
                SELECT header_id INTO l_check_existence
                FROM csp_moveorder_headers
                WHERE header_id = p_header_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_MOVEORDER');
                  FND_MESSAGE.SET_TOKEN('HEADER_ID', to_char(p_header_id), FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_header_id', FALSE);
                  fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'CSP_MOVEORDER_HEADERS', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;

            END;
         END IF;

         IF nvl(p_carrier, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
            -- Validate whether the p_carrier exists.
            BEGIN
                SELECT distinct freight_code INTO l_carrier
                FROM org_freight_tl
                WHERE freight_code = p_carrier
                AND organization_id = (SELECT organization_id FROM mtl_txn_request_headers
                                       WHERE header_id = p_header_id);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_CARRIER');
                    FND_MESSAGE.SET_TOKEN('CARRIER_CODE', p_carrier, FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_carrier', FALSE);
                  fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'ORG_FREIGHT_TL', FALSE);
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
                    fnd_message.set_token('TABLE', 'CSP_MOVEORDER_HEADERS', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              End if;
              Close l_Get_Creation_Date_Csr;
          END IF;

          IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
          END IF;
  ELSE -- p_action_code = 2
        IF nvl(p_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_header_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            -- Validate whether the given header_id exists in the mtl_txn_request_headers table.
            BEGIN
                SELECT header_id INTO l_check_existence
                FROM csp_moveorder_headers
                WHERE header_id = p_header_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_MOVEORDER');
                  FND_MESSAGE.SET_TOKEN('HEADER_ID', to_char(p_header_id), FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                  fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                  fnd_message.set_token('ERR_FIELD', 'p_header_id', FALSE);
                  fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                  fnd_message.set_token('TABLE', 'CSP_MOVEORDER_HEADERS', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;

            END;
         END IF;
   END IF;


    -- construct the move_over_headers record
        l_moheader_rec.header_id            := p_header_id;
        l_moheader_rec.created_by           := nvl(l_created_by, fnd_api.g_miss_num);
        l_moheader_rec.creation_date        := nvl(l_creation_date, fnd_api.g_miss_date);
        l_moheader_rec.last_updated_by      := nvl(l_last_updated_by, fnd_api.g_miss_num);
        l_moheader_rec.last_update_date     := nvl(l_last_update_date, fnd_api.g_miss_date);
        l_moheader_rec.last_update_login    := l_last_update_login;
        l_moheader_rec.carrier              := p_carrier;
        l_moheader_rec.shipment_method      := p_shipment_method;
        l_moheader_rec.autoreceipt_flag     := nvl(p_autoreceipt_flag, fnd_api.g_miss_char);
        l_moheader_rec.attribute_category   := p_attribute_category;
        l_moheader_rec.attribute1           := p_attribute1;
        l_moheader_rec.attribute2           := p_attribute2;
        l_moheader_rec.attribute3           := p_attribute3;
        l_moheader_rec.attribute4           := p_attribute4;
        l_moheader_rec.attribute5           := p_attribute5;
        l_moheader_rec.attribute6           := p_attribute6;
        l_moheader_rec.attribute7           := p_attribute7;
        l_moheader_rec.attribute8           := p_attribute8;
        l_moheader_rec.attribute9           := p_attribute9;
        l_moheader_rec.attribute10          := p_attribute10;
        l_moheader_rec.attribute11          := p_attribute11;
        l_moheader_rec.attribute12          := p_attribute12;
        l_moheader_rec.attribute13          := p_attribute13;
        l_moheader_rec.attribute14          := p_attribute14;
        l_moheader_rec.attribute15          := p_attribute15;
        l_moheader_rec.location_id          := p_location_id;
        l_moheader_rec.party_site_id        := p_party_site_id;

     if p_action_code = 0 then
        -- call the private insert (create) procedure
         CSP_ORDERHEADERS_PVT.Create_orderheaders(
             P_Api_Version_Number    => p_api_version_number,
             P_Init_Msg_List         => p_init_msg_list,
             P_Commit                => l_commit,
             p_validation_level      => l_validation_level,
             P_MOH_Rec               => l_moheader_rec,
             X_HEADER_ID             => l_header_id,
             X_Return_Status         => l_return_status,
             X_Msg_Count             => l_msg_count,
             X_Msg_Data              => l_msg_data
             );

    elsif p_action_code = 1 then
        -- call the private update procedure
        CSP_ORDERHEADERS_PVT.Update_orderheaders(
             P_Api_Version_Number    => p_api_version_number,
             P_Init_Msg_List         => p_init_msg_list,
             P_Commit                => l_commit,
             p_validation_level      => l_validation_level,
             P_Identity_Salesforce_Id => null,
             P_MOH_Rec               => l_moheader_rec,
             X_Return_Status         => l_return_status,
             X_Msg_Count             => l_msg_count,
             X_Msg_Data              => l_msg_data);

    else
      -- call the private delete procedure
       CSP_ORDERHEADERS_PVT.Delete_orderheaders(
             P_Api_Version_Number    => p_api_version_number,
             P_Init_Msg_List         => p_init_msg_list,
             P_Commit                => l_commit,
             p_validation_level      => l_validation_level,
             P_Identity_Salesforce_Id => null,
             P_MOH_Rec               => l_moheader_rec,
             X_Return_Status         => l_return_status,
             X_Msg_Count             => l_msg_count,
             X_Msg_Data              => l_msg_data);
      end if;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

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
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END Validate_And_Write;

END CSP_TO_FORM_MOHEADERS;

/
