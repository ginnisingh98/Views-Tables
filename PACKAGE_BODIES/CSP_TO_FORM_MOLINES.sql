--------------------------------------------------------
--  DDL for Package Body CSP_TO_FORM_MOLINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TO_FORM_MOLINES" AS
/* $Header: cspgtmlb.pls 115.14 2002/11/26 06:51:27 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_TO_FORM_MOLINES
-- Purpose          : A wrapper to prepare data to call the CSP_ORDERLINES_PVT.Create_orderlines.
-- History
--  18-Nov-1999: klou
--  03-Dev-1999: Modified because of change of schema by Vernon Lou.
--               Removed fields: p_address, p_service_request_number, p_mtl15_line_id, p_total_shipped.
--               Added fields: p_incident_id
--
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_TO_FORM_MOLINES';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtmlb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Validate_and_Write(
          P_Api_Version_Number      IN        NUMBER,
          P_Init_Msg_List           IN        VARCHAR2     := FND_API.G_FALSE,
          P_Commit                  IN        VARCHAR2     := FND_API.G_FALSE,
          p_validation_level        IN        NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_action_code             IN        NUMBER,
          P_line_id                 IN        NUMBER := FND_API.G_MISS_NUM,
          p_CREATED_BY              IN        NUMBER := FND_API.G_MISS_NUM,
          p_CREATION_DATE           IN        DATE := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY         IN        NUMBER := FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE        IN        DATE := FND_API.G_MISS_DATE,
          p_LAST_UPDATED_LOGIN      IN        NUMBER := FND_API.G_MISS_NUM,
          p_HEADER_ID               IN        NUMBER := FND_API.G_MISS_NUM,
          p_CUSTOMER_PO             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_INCIDENT_ID             IN        NUMBER := FND_API.G_MISS_NUM,
          p_TASK_ID                 IN        NUMBER := FND_API.G_MISS_NUM,
          p_TASK_ASSIGNMENT_ID      IN        NUMBER := FND_API.G_MISS_NUM,
          p_COMMENTS                IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY      IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9              IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15             IN        VARCHAR2 := FND_API.G_MISS_CHAR,
          X_Return_Status           OUT NOCOPY       VARCHAR2,
          X_Msg_Count               OUT NOCOPY       NUMBER,
          X_Msg_Data                OUT NOCOPY       VARCHAR2
    )

IS
    l_mol_rec   CSP_ORDERLINES_PVT.MOL_Rec_Type;
    l_return_line_id NUMBER;
    l_api_version_number        CONSTANT NUMBER  := 1.0;
    l_api_name                  CONSTANT VARCHAR2(50) := 'Validate_And_Write';
    l_pkg_api_name              CONSTANT VARCHAR2(80) := G_PKG_NAME ||'.'||l_api_name;
    l_msg_data                  VARCHAR2(300);
    l_check_existence           NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER  := 0;
    l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    l_task_id                   NUMBER := p_task_id;
    l_task_assignment_id        NUMBER := p_task_assignment_id;
    EXCP_USER_DEFINED EXCEPTION;

    l_creation_date             DATE := p_creation_date;
    l_last_update_date          DATE := p_last_update_date;
    l_created_by                NUMBER := p_created_by;
    l_last_update_login         NUMBER := p_last_updated_login;
    l_last_updated_by           NUMBER := p_last_updated_by;
    Cursor l_Get_Creation_Date_Csr Is
      Select creation_date
      From csp_moveorder_lines
      Where line_id = p_LINE_ID;
    Cursor l_Get_Line_ID_Csr Is
      Select line_id
      From csp_moveorder_lines
      Where line_id = p_LINE_ID;

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

    --validating p_action_code
     IF nvl(p_action_code, fnd_api.g_miss_num) NOT IN (0, 1, 2) THEN
            fnd_message.set_name ('INV', 'INV-INVALID ACTION');
            fnd_message.set_token ('ROUTINE', l_pkg_api_name, FALSE);
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
     END IF;

     IF p_action_code = 0 THEN
            -- check p_header_id and p_line_id. if null return an error.
            IF nvl(p_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_header_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
            ELSE
               -- validate where the header_id already exists.
                BEGIN
                    SELECT header_id INTO l_check_existence
                    FROM mtl_txn_request_headers --csp_moveorder_headers
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

            END IF;

            IF nvl(p_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_line_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
            ELSE
                -- First check whether the line id already exists.
                OPEN l_Get_Line_ID_Csr;
                FETCH l_Get_Line_ID_Csr INTO l_check_existence;
                IF l_Get_Line_ID_Csr%NOTFOUND THEN
                      BEGIN
                          SELECT line_id INTO l_check_existence
                          FROM mtl_txn_request_lines
                          WHERE line_id = p_line_id
                          AND header_id = p_header_id;
                      EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              FND_MESSAGE.SET_NAME('CSP', 'CSP_MOLINE_NO_EXIST');
                              FND_MESSAGE.SET_TOKEN('LINE_ID', to_char(p_line_id), FALSE);
                              FND_MSG_PUB.ADD;
                              RAISE EXCP_USER_DEFINED;
                          WHEN OTHERS THEN
                              fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                              fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                              fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                              fnd_message.set_token('TABLE', 'MTL_TXN_REQUEST_LINES', FALSE);
                              FND_MSG_PUB.ADD;
                              RAISE EXCP_USER_DEFINED;
                      END;
                 ELSE
                    fnd_message.set_name ('CSP', 'CSP_DUPLICATE_RECORD');
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                 END IF;
                 CLOSE l_Get_Line_ID_Csr;
             END IF;

            IF nvl(p_task_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                -- Validate the task id
                BEGIN
                    SELECT task_id INTO l_check_existence
                    FROM jtf_tasks_vl
                    WHERE task_id = p_task_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('JTF', 'JTF_TASK_INVALID_TASK_ID');
                        FND_MESSAGE.SET_TOKEN('P_TASK_ID', to_char(p_task_id), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_task_id', FALSE);
                        fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'JTF_TASKS_TL', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                 END;
            END IF;

            IF nvl(p_task_assignment_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                IF nvl(p_task_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                    -- validate the task_assignment_id against the task_id.
                    BEGIN
                        SELECT task_assignment_id INTO l_check_existence
                        FROM jtf_task_assignments
                        WHERE task_assignment_id = p_task_assignment_id
                        AND task_id = p_task_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_TASK_ASSIGNMENT');
                            FND_MESSAGE.SET_TOKEN('ASSIGNMENT_ID', to_char(p_task_assignment_id), FALSE);
                            FND_MESSAGE.SET_TOKEN('TASK_ID', to_char(p_task_id), FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_task_assignment_id', FALSE);
                            fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                            fnd_message.set_token('TABLE', 'JTF_TASK_ASSIGNMENTS', FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                    END;
                ELSE
                    BEGIN
                        SELECT task_assignment_id INTO l_check_existence
                        FROM jtf_task_assignments
                        WHERE task_assignment_id = p_task_assignment_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('JTF', 'JTF_TASK_INV_TK_ASS');
                            FND_MESSAGE.SET_TOKEN('P_TASK_ASSIGNMENT_ID', to_char(p_task_assignment_id), FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_task_assignment_id', FALSE);
                            fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                            fnd_message.set_token('TABLE', 'JTF_TASK_ASSIGNMENTS', FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                    END;
                END IF;
            END IF;

            IF nvl(p_incident_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                 -- validate the incident id
                 BEGIN
                    SELECT incident_id INTO l_check_existence
                    FROM cs_incidents_all
                    WHERE incident_id = p_incident_id;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_INCIDENT_ID');
                        FND_MESSAGE.SET_TOKEN('INCIDENT_ID', to_char(p_incident_id), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_incident_id', FALSE);
                        fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'CS_INCIDENTS_ALL', FALSE);
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
          IF nvl(p_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_line_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
          ELSE
                BEGIN
                    SELECT line_id INTO l_check_existence
                    FROM csp_moveorder_lines
                    WHERE line_id = p_line_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_MOLINE_NO_EXIST');
                        FND_MESSAGE.SET_TOKEN('LINE_ID', to_char(p_line_id), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                        fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'CSP_MOVERDER_LINES', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
           END IF;

          -- check p_header_id and p_line_id. if null return an error.
          IF nvl(p_header_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              -- validate where the header_id already exists.
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
                      fnd_message.set_token('TABLE', 'CSP_MOVEORDER_LINES', FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
             END;
          END IF;

         IF nvl(l_task_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                -- Validate the task id
                BEGIN
                    SELECT task_id INTO l_check_existence
                    FROM jtf_tasks_vl
                    WHERE task_id = l_task_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('JTF', 'JTF_TASK_INVALID_TASK_ID');
                        FND_MESSAGE.SET_TOKEN('P_TASK_ID', to_char(p_task_id), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_task_id', FALSE);
                        fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'JTF_TASKS_TL', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;

                IF nvl(p_task_assignment_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                    SELECT nvl(task_assignment_id, fnd_api.g_miss_num) INTO l_task_assignment_id
                    FROM csp_moveorder_lines
                    WHERE line_id = p_line_id;

                    IF nvl(l_task_assignment_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                        BEGIN
                          SELECT task_assignment_id INTO l_check_existence
                          FROM jtf_task_assignments
                          WHERE task_assignment_id = l_task_assignment_id
                          AND task_id = l_task_id;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_TASK_ASSIGNMENT');
                              FND_MESSAGE.SET_TOKEN('ASSIGNMENT_ID', to_char(l_task_assignment_id), FALSE);
                              FND_MESSAGE.SET_TOKEN('TASK_ID', to_char(l_task_id), FALSE);
                              FND_MSG_PUB.ADD;
                              RAISE EXCP_USER_DEFINED;
                          WHEN OTHERS THEN
                              fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                              fnd_message.set_token('ERR_FIELD', 'p_task_assignment_id', FALSE);
                              fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                              fnd_message.set_token('TABLE', 'JTF_TASK_ASSIGNMENTS', FALSE);
                              FND_MSG_PUB.ADD;
                              RAISE EXCP_USER_DEFINED;
                        END;
                     END IF;
                  END IF;
            END IF;

         IF nvl(p_task_assignment_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                IF nvl(p_task_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                 -- find out the task_id in the existing moveorder_line record.
                    SELECT nvl(task_id, fnd_api.g_miss_num) INTO l_task_id
                    FROM csp_moveorder_lines
                   WHERE line_id = p_line_id;
                END IF;

                IF nvl(l_task_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                    -- validate the task_assignment_id against the task_id.
                    BEGIN
                        SELECT task_assignment_id INTO l_check_existence
                        FROM jtf_task_assignments
                        WHERE task_assignment_id = p_task_assignment_id
                        AND task_id = l_task_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_TASK_ASSIGNMENT');
                            FND_MESSAGE.SET_TOKEN('ASSIGNMENT_ID', to_char(p_task_assignment_id), FALSE);
                            FND_MESSAGE.SET_TOKEN('TASK_ID', to_char(l_task_id), FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_task_assignment_id', FALSE);
                            fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                            fnd_message.set_token('TABLE', 'JTF_TASK_ASSIGNMENTS', FALSE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                    END;
                ELSE
                        BEGIN
                            SELECT task_assignment_id INTO l_check_existence
                            FROM jtf_task_assignments
                            WHERE task_assignment_id = p_task_assignment_id;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.SET_NAME('JTF', 'JTF_TASK_INV_TK_ASS');
                                FND_MESSAGE.SET_TOKEN('P_TASK_ASSIGNMENT_ID', to_char(p_task_assignment_id), FALSE);
                                FND_MSG_PUB.ADD;
                                RAISE EXCP_USER_DEFINED;
                            WHEN OTHERS THEN
                                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                                fnd_message.set_token('ERR_FIELD', 'p_task_assignment_id', FALSE);
                                fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                                fnd_message.set_token('TABLE', 'JTF_TASK_ASSIGNMENTS', FALSE);
                                FND_MSG_PUB.ADD;
                                RAISE EXCP_USER_DEFINED;
                        END;
                END IF;
        END IF;

        IF nvl(p_incident_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
             -- validate the incident id
             BEGIN
                SELECT incident_id INTO l_check_existence
                FROM cs_incidents_all
                WHERE incident_id = p_incident_id;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_INVALID_INCIDENT_ID');
                    FND_MESSAGE.SET_TOKEN('INCIDENT_ID', to_char(p_incident_id), FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_incident_id', FALSE);
                    fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CS_INCIDENTS_ALL', FALSE);
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
                    fnd_message.set_token('TABLE', 'CSP_MOVEORDER_LINES', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
              End if;
              Close l_Get_Creation_Date_Csr;
           End if;

          IF nvl(l_last_update_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
              l_last_update_date := sysdate;
          END IF;
    ELSE -- p_action_code = 2
         IF nvl(p_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                    FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_line_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
          ELSE
                BEGIN
                    SELECT line_id INTO l_check_existence
                    FROM csp_moveorder_lines
                    WHERE line_id = p_line_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_MOLINE_NO_EXIST');
                        FND_MESSAGE.SET_TOKEN('LINE_ID', to_char(p_line_id), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_line_id', FALSE);
                        fnd_message.set_token('ROUTINE', l_pkg_api_name, FALSE);
                        fnd_message.set_token('TABLE', 'CSP_MOVERDER_LINES', FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
           END IF;
    END IF;

   -- construct the l_mol_rec for calling the CSP_ORDRELINES_PVT.Create_orderlines
          l_mol_rec.LINE_ID             := P_line_id;
          l_mol_rec.CREATED_BY          := nvl(l_CREATED_BY, fnd_api.g_miss_num);
          l_mol_rec.CREATION_DATE       := l_CREATION_DATE;
          l_mol_rec.LAST_UPDATED_BY     := nvl(l_LAST_UPDATED_BY, fnd_api.g_miss_num);
          l_mol_rec.LAST_UPDATE_DATE    := l_LAST_UPDATE_DATE;
          l_mol_rec.LAST_UPDATED_LOGIN  := l_LAST_UPDATE_LOGIN;
          l_mol_rec.HEADER_ID           := nvl(p_HEADER_ID, fnd_api.g_miss_num);
          l_mol_rec.CUSTOMER_PO         := p_CUSTOMER_PO;
          l_mol_rec.INCIDENT_ID         := p_INCIDENT_ID;
          l_mol_rec.TASK_ID             := p_TASK_ID;
          l_mol_rec.TASK_ASSIGNMENT_ID  := p_TASK_ASSIGNMENT_ID;
          l_mol_rec.COMMENTS            := p_COMMENTS;
          l_mol_rec.ATTRIBUTE_CATEGORY  := p_ATTRIBUTE_CATEGORY;
          l_mol_rec.ATTRIBUTE1          := p_ATTRIBUTE1;
          l_mol_rec.ATTRIBUTE2          := p_ATTRIBUTE2;
          l_mol_rec.ATTRIBUTE3          := p_ATTRIBUTE3;
          l_mol_rec.ATTRIBUTE4          := p_ATTRIBUTE4;
          l_mol_rec.ATTRIBUTE5          := p_ATTRIBUTE5;
          l_mol_rec.ATTRIBUTE6          := p_ATTRIBUTE6;
          l_mol_rec.ATTRIBUTE7          := p_ATTRIBUTE7;
          l_mol_rec.ATTRIBUTE8          := p_ATTRIBUTE8;
          l_mol_rec.ATTRIBUTE9          := p_ATTRIBUTE9;
          l_mol_rec.ATTRIBUTE10         := p_ATTRIBUTE10;
          l_mol_rec.ATTRIBUTE11         := p_ATTRIBUTE11;
          l_mol_rec.ATTRIBUTE12         := p_ATTRIBUTE12;
          l_mol_rec.ATTRIBUTE13         := p_ATTRIBUTE13;
          l_mol_rec.ATTRIBUTE14         := p_ATTRIBUTE14;
          l_mol_rec.ATTRIBUTE15         := p_ATTRIBUTE15;


         if p_action_code = 0  then   -- call the create_orderlines procedure
                CSP_ORDERLINES_PVT.Create_orderlines(
                P_Api_Version_Number => P_api_version_number,
                P_Init_Msg_List      => P_Init_Msg_List,
                P_Commit             => l_Commit,
                p_validation_level   => p_validation_level,
                P_MOL_Rec  => l_mol_rec,
                X_LINE_ID     => l_return_line_id,
                X_Return_Status => X_return_status,
                X_Msg_Count => X_Msg_Count,
                X_Msg_Data  => X_Msg_Data);

         elsif p_action_code = 1 then   -- call the update procedure

                 CSP_ORDERLINES_PVT.Update_orderlines(
                      P_Api_Version_Number => P_api_version_number,
                      P_Init_Msg_List     => P_Init_Msg_List,
                      P_Commit          => l_Commit,
                      p_validation_level   => p_validation_level,
                      P_Identity_Salesforce_Id   => NULL,
                      P_MOL_Rec      => l_mol_rec,
                      X_Return_Status => X_return_status,
                      X_Msg_Count => X_Msg_Count,
                      X_Msg_Data  => X_Msg_Data);

          else -- call the delete procedure
               CSP_ORDERLINES_PVT.Delete_orderlines(
                      P_Api_Version_Number => P_api_version_number,
                      P_Init_Msg_List     => P_Init_Msg_List,
                      P_Commit          => l_Commit,
                      p_validation_level   => p_validation_level,
                      P_Identity_Salesforce_Id   => NULL,
                      P_MOL_Rec      => l_mol_rec,
                      X_Return_Status => X_return_status,
                      X_Msg_Count => X_Msg_Count,
                      X_Msg_Data  => X_Msg_Data);
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
                fnd_message.set_token ('ROUTINE', l_pkg_api_name, FALSE);
                fnd_message.set_token ('SQLERRM', sqlerrm, FALSE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END Validate_and_Write;

END CSP_TO_FORM_MOLINES;

/
