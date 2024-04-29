--------------------------------------------------------
--  DDL for Package Body CSP_PL_SHIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PL_SHIP_UTIL" AS
/* $Header: cspgtpsb.pls 120.0 2005/05/25 11:27:47 appldev noship $ */
-- Start of comments
--
-- API name : CSP_PL_SHIP_UTIL
-- Type     : PUBLIC
-- Purpose  : CSP Utility programs to handle confirm_ship, update packlist line status and header status.
--
-- Modification History
-- Userid      Date        Comments
-- ---------   ------     ------------------------------------------
--  klou       01/12/99    replace as_utility calls with jtf_plsql_api.
--  klou       01/04/99    created
--
-- Note :
-- End of comments

-- ****/////////////////////////////////////////////////////////////////////////////**** --

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PL_SHIP_UTIL';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtpsb.pls';

PROCEDURE Confirm_Ship(
  /* $Header: cspgtpsb.pls 120.0 2005/05/25 11:27:47 appldev noship $ */
  -- Start of Comments
  -- Procedure name   : Confirm_Ship
  -- Purpose          : This procedure updates the packlist_line_status and the quantity_shipped in the csp_packlist_lines table.
  --                    It requires the packlist_header_id and the quantity_shipped.
  -- History          :
  -- Userid      Date        Comments
  -- ---------   ------     ------------------------------------------
  --  klou       01/26/00   Add standard exception messages.
  --  klou       01/12/00   Replace AS_UTLIITY calls with JTF
  --  klou       01/04/99   created.
  --
  --  NOTES: If validations have been done in the precedent procedure from which this one is being called,
  --  doing a full validation in this procedure is unnecessary. To avoid repeating the same validations,
  --  you can set the p_validation_level to fnd_api.g_valid_level_none. However, it is your responsibility
  --  to make sure all proper validations have been done if you decided not to use the validations in this
  --  procedure. You are recommended to let this procedure handle the validations if you are in doubt.
  --
  --  CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to
  --  FND_API.G_VALID_LEVEL_NONE. If you do not do your own validations before calling this procedure,
  --  you should set the p_validation_level to FND_API.G_VALID_LEVEL_FULL when calling this procedure.
  -- End of Comments

          P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_packlist_header_id           IN   NUMBER,
          p_organization_id              IN   NUMBER,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2)

  IS

      l_api_version_number        CONSTANT NUMBER  := 1.0;
      l_api_name                  CONSTANT VARCHAR2(20) := 'Confirm_Ship';
      l_msg_data                  VARCHAR2(300);
      l_check_existence           NUMBER := 0;
      l_return_status             VARCHAR2(1);
      l_msg_count                 NUMBER  := 0;
      l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
      l_organization_id           NUMBER;
      l_picklist_line_id          NUMBER := 0;
      l_transaction_quantity      NUMBER := 0;
      l_transaction_temp_id       NUMBER := 0;
      l_packlist_header_id        NUMBER;
      --l_counter                   NUMBER := 0;  -- used to test the loop. can be removed after debug.

     -- for inserting data, the validation_level should be none
     -- because we do not want to call the core apps standard validations.
      l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
      l_autoreceipt_flag          csp_moveorder_headers.autoreceipt_flag%type;

      l_outcome                     BOOLEAN := TRUE;
      l_error_code                  VARCHAR2(200);
      l_error_explanation           VARCHAR2(240);

      EXCP_USER_DEFINED           EXCEPTION;

      -- Define excp_nosavepoint exception to trap oracle's No Savepoint exception.
      EXCP_NOSAVEPOINT            EXCEPTION;
      PRAGMA EXCEPTION_INIT(EXCP_NOSAVEPOINT, -1086);

    Cursor C_Get_packlist_lines IS
    Select PACKLIST_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_LINE_NUMBER,
           PACKLIST_HEADER_ID,
           BOX_ID,
           PICKLIST_LINE_ID,
           PACKLIST_LINE_STATUS,
           INVENTORY_ITEM_ID,
           QUANTITY_PACKED,
           QUANTITY_SHIPPED,
           QUANTITY_RECEIVED,
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
           UOM_CODE,
           LINE_ID
    From  CSP_PACKLIST_LINES
    WHERE organization_id = p_organization_id
    AND   packlist_header_id = p_packlist_header_id;

   Cursor C_Get_Packlist_Headers IS
        SELECT
          PACKLIST_HEADER_ID ,
          CREATED_BY ,
          CREATION_DATE ,
          LAST_UPDATED_BY ,
          LAST_UPDATE_DATE ,
          LAST_UPDATE_LOGIN ,
          ORGANIZATION_ID ,
          PACKLIST_NUMBER ,
          SUBINVENTORY_CODE ,
          PACKLIST_STATUS ,
          DATE_CREATED ,
          DATE_PACKED ,
          DATE_SHIPPED ,
          DATE_RECEIVED ,
          CARRIER ,
          SHIPMENT_METHOD ,
          WAYBILL ,
          COMMENTS ,
          LOCATION_ID,
          PARTY_SITE_ID,
          ATTRIBUTE_CATEGORY ,
          ATTRIBUTE1 ,
          ATTRIBUTE2 ,
          ATTRIBUTE3 ,
          ATTRIBUTE4 ,
          ATTRIBUTE5 ,
          ATTRIBUTE6 ,
          ATTRIBUTE7 ,
          ATTRIBUTE8 ,
          ATTRIBUTE9 ,
          ATTRIBUTE10 ,
          ATTRIBUTE11 ,
          ATTRIBUTE12 ,
          ATTRIBUTE13 ,
          ATTRIBUTE14 ,
          ATTRIBUTE15
    From  CSP_PACKLIST_HEADERS
    WHERE organization_id = p_organization_id
    AND   packlist_header_id = p_packlist_header_id;

    l_packlist_headers_rec     CSP_packlist_headers_PVT.PLH_Rec_Type;
    l_packlist_line_rec        CSP_packlist_lines_PVT.PLL_Rec_Type;
    l_transaction_header_id    NUMBER := null;
    l_temp_id                  NUMBER;
    l_move_order_line_id       NUMBER;
    l_header_id                NUMBER;
    l_trolin_rec               INV_Move_Order_PUB.Trolin_Rec_Type;

    CURSOR C_Get_Temp_ID IS
      SELECT transaction_temp_id
      FROM CSP_Picklist_Lines
      WHERE picklist_line_id = l_packlist_line_rec.picklist_line_id;

    CURSOR C_Get_Move_Order_Line_ID(p_temp_id NUMBER) IS
      SELECT move_order_line_id
      FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = p_temp_id
      AND organization_id = p_organization_id;



   BEGIN
    SAVEPOINT Confirm_Ship_PUB;
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


   IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN
       -- validate p_organization_id
        IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            IF p_validation_level = fnd_api.g_valid_level_full THEN
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
                          fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'mtl_parameters', TRUE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                  END;
             END IF;
             NULL;
        END IF;

      -- validate packlist_header_id
      IF p_packlist_header_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_header_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
      ELSE
          IF p_validation_level = fnd_api.g_valid_level_full THEN
                BEGIN
                    select packlist_header_id into l_check_existence
                    from csp_packlist_headers
                    where organization_id = p_organization_id
                    and packlist_header_id = p_packlist_header_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_PACKLIST_HEADER');
                       FND_MESSAGE.SET_TOKEN('HEADER_ID', to_char(p_packlist_header_id), TRUE);
                       FND_MSG_PUB.ADD;
                       RAISE EXCP_USER_DEFINED;
                     WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_packlist_header_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'csp_packlist_headers', TRUE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                END;
           END IF;
           NULL;
      END IF;
    END IF;  -- end full validations

  -- Update the packlist header status to shipped and date_shipped to sysdate
        Open C_Get_Packlist_Headers;
        Fetch C_Get_Packlist_Headers Into l_packlist_headers_rec;

        IF C_Get_Packlist_Headers%NOTFOUND THEN
            CLOSE C_Get_Packlist_Headers;
            fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_HEADER');
            fnd_message.set_token ('HEADER_ID', to_char(p_packlist_header_id), TRUE);
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE C_Get_Packlist_Headers;
        l_packlist_headers_rec.date_shipped      := sysdate;
        l_packlist_headers_rec.packlist_status   := '2';
        l_packlist_headers_rec.last_update_date  := sysdate;
          /*update_packlist_header_sts (
          P_Api_Version_Number          => l_api_version_number,
          P_Init_Msg_List               => FND_API.G_true,
          P_Commit                      => l_commit,
          p_validation_level            => l_validation_level,
          p_packlist_header_id          => p_packlist_header_id,
          p_organization_id             => p_organization_id,
          p_packlist_status             => '2',
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data );*/

        -- call the CSP_Packlist_Headers_PVT.Update_packlist_headers to updat the packlist_status.
        CSP_Packlist_Headers_PVT.Update_packlist_headers(
            P_Api_Version_Number         => l_api_version_number,
            P_Init_Msg_List              => p_init_msg_list,
            P_Commit                     => FND_API.G_FALSE,
            p_validation_level           => l_validation_level,
            P_Identity_Salesforce_Id     => NULL,
            P_PLH_Rec                    => l_packlist_headers_rec,
            X_Return_Status              => l_return_status,
            X_Msg_Count                  => l_msg_count,
            X_Msg_Data                   => l_msg_data
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
       --dbms_output.put_line('Failed in 1 ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

   -- First we need to determine whether the move order associated with this packlist is an autoreceipt or
   -- a manual receipt. If it is an autoreceipt, we need to initiate the material transactions. Else,
   -- we need to split the material transactions into two stages.
   -- Steps
   -- 1. get the picklist_line_id from the packlist_lines cursor.
   -- 2. get the trasaction_temp_id from the picklist_line_id.
   -- 3. get the move_order_line_id from the transaction_temp_id.
    OPEN C_Get_packlist_lines;

    LOOP
        FETCH C_Get_packlist_lines INTO l_packlist_line_rec;
        EXIT WHEN C_Get_packlist_lines%NOTFOUND;

      -- Update the packlist status to 'shipped' and the quantity_shipped to p_quantity_shipped.
          Update_Packlist_Sts_Qty (
                P_Api_Version_Number => l_api_version_number,
                P_Init_Msg_List      => FND_API.G_true,
                P_Commit            => l_commit,
                p_validation_level  => l_validation_level,
                p_organization_id   => p_organization_id,
                p_packlist_line_id  => l_packlist_line_rec.packlist_line_id,
                p_line_status       => '2',
                p_quantity_packed   => NULL,
                p_quantity_shipped  => l_packlist_line_rec.quantity_packed,
                p_quantity_received => NULL,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data
          );

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            --    dbms_output.put_line('Failed in 2 ');

                RAISE FND_API.G_EXC_ERROR;
          END IF;

    -- Update the quantity_shipped of the l_packlist_line_rec to quantity_packed.
        l_packlist_line_rec.quantity_shipped := l_packlist_line_rec.quantity_packed;
        BEGIN
            OPEN C_Get_Temp_ID;
            FETCH C_Get_Temp_ID INTO l_temp_id;
            IF C_Get_Temp_ID%NOTFOUND THEN
                CLOSE C_Get_Temp_ID;
                fnd_message.set_name ('CSP', 'CSP_NO_TXN_RECORD');
                fnd_message.set_token ('PICKLIST_ID', to_char(l_packlist_line_rec.picklist_line_id), TRUE);
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
            END IF;

           CLOSE C_Get_Temp_ID;
                -- get the move_order_line based on the l_temp_id
                   BEGIN
                        OPEN C_Get_Move_Order_Line_ID(l_temp_id);
                        FETCH C_Get_Move_Order_Line_ID INTO l_move_order_line_id;
                        IF C_Get_Move_Order_Line_ID%NOTFOUND THEN
                            CLOSE C_Get_Move_Order_Line_ID;
                            fnd_message.set_name ('CSP', 'CSP_PACKLIST_MOVEORDER_ERRORS');
                            fnd_message.set_token ('HEADER_ID', to_char(p_packlist_header_id), TRUE);
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;
                        END IF;

                       CLOSE C_Get_Move_Order_Line_ID;
                        select header_id into l_header_id
                        from csp_moveorder_lines
                        where line_id = l_move_order_line_id;

                        select autoreceipt_flag into l_autoreceipt_flag
                        from csp_moveorder_headers
                        where header_id = l_header_id;

                        -- Update the quantity_delivered of the move order line.
                         l_trolin_rec := INV_Trolin_util.Query_Row(l_move_order_line_id);
                         l_trolin_rec.quantity_delivered := nvl(l_trolin_rec.quantity_delivered,0) + l_packlist_line_rec.quantity_shipped;
                         l_trolin_rec.last_update_date := SYSDATE;
                         l_trolin_rec.last_updated_by := FND_GLOBAL.USER_ID;
                         l_trolin_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
                         INV_Trolin_Util.Update_Row(l_trolin_rec);

                        IF l_autoreceipt_flag = 'Y' THEN
                          -- call the ccsp_mo_mtltxns_util.confirm_receipt with l_validation_level = none
                          csp_mo_mtltxns_util.confirm_receipt (
                                 P_Api_Version_Number      => l_api_version_number,
                                 P_Init_Msg_List           => FND_API.G_True,
                                 P_Commit                  => l_commit,
                                 p_validation_level        => l_validation_level,
                                 p_packlist_line_id        => l_packlist_line_rec.packlist_line_id,
                                 p_organization_id         => p_organization_id,
                                 p_transaction_temp_id     => l_temp_id,
                                 p_quantity_received       => l_packlist_line_rec.quantity_shipped,
                                 px_transaction_header_id  => l_transaction_header_id,
                                 p_process_flag            => FND_API.G_FALSE,
                                 X_Return_Status           => l_return_status,
                                 X_Msg_Count               => l_msg_count,
                                 X_Msg_Data                => l_msg_data
                           );


                              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                             --     dbms_output.put_line('Failed in 3');

                                 Rollback to Confirm_Ship_PUB;
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;

                         ELSIF l_autoreceipt_flag = 'N' THEN

                            CSP_PC_FORM_MTLTXNS.CSP_MO_LINES_MANUAL_RECEIPT (
                               P_Api_Version_Number      => l_api_version_number,
                               P_Init_Msg_List           => FND_API.G_True,
                               P_Commit                  => l_commit,
                               p_validation_level        => l_validation_level,
                               p_organization_id         => p_organization_id,
                               p_transaction_temp_id     => l_temp_id,
                               px_transaction_header_id  => l_transaction_header_id,
                               p_process_flag            => FND_API.G_FALSE,
                               X_Return_Status           => l_return_status,
                               X_Msg_Count               => l_msg_count,
                               X_Msg_Data                => l_msg_data
                           );

                              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                  --   dbms_output.put_line('Failed in 4 ');

                                 Rollback to Confirm_Ship_PUB;
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                         ELSE
                             fnd_message.set_name ('CSP', 'CSP_INVALID_MO_RECEIPT_TYPE');
                             fnd_message.set_token ('HEADER_ID', to_char(l_header_id), TRUE);
                             fnd_msg_pub.add;
                                    IF C_Get_packlist_lines%ISOPEN THEN
                                        CLOSE C_Get_packlist_lines;
                                    END IF;
                            RAISE EXCP_USER_DEFINED;

                         END IF;

                   EXCEPTION
                        WHEN EXCP_NOSAVEPOINT THEN
                            RAISE EXCP_NOSAVEPOINT;
                        WHEN NO_DATA_FOUND THEN
                            fnd_message.set_name ('CSP', 'CSP_INVALID_MOVEORDER');
                            fnd_message.set_token ('HEADER_ID', to_char(l_header_id), TRUE);
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;
                        WHEN EXCP_USER_DEFINED THEN
                            RAISE EXCP_USER_DEFINED;
                        WHEN OTHERS THEN
                            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                            fnd_message.set_token('SQLEERM', sqlerrm, TRUE);
                            fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                            fnd_msg_pub.add;
                            RAISE EXCP_USER_DEFINED;

                   END;
        END;
     --l_counter := l_counter+1;

     END LOOP;
     IF C_Get_packlist_lines%rowcount = 0 THEN
        CLOSE C_Get_packlist_lines;
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_PACKLIST_HEADER');
        FND_MESSAGE.SET_TOKEN('HEADER_ID', to_char(p_packlist_header_id), TRUE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
     END IF;

     IF C_Get_packlist_lines%ISOPEN THEN
        CLOSE C_Get_packlist_lines;
     END IF;

     IF l_transaction_header_id IS NOT NULL THEN
            IF NOT CSP_Mo_Mtltxns_Util.Call_Online (p_transaction_header_id   => l_transaction_header_id) THEN
                     l_outcome := FALSE;
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                     Return;
            END IF;
     END IF;

    IF fnd_api.to_boolean(p_commit) THEN
        commit work;
    END IF;

     fnd_msg_pub.count_and_get
     ( p_count => x_msg_count
     , p_data  => x_msg_data);
    x_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
        WHEN EXCP_NOSAVEPOINT THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);
        WHEN EXCP_USER_DEFINED THEN
            Rollback to Confirm_Ship_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);
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
               Rollback to Confirm_Ship_PUB;
               fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
               fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
               fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
               fnd_msg_pub.add;
               fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
               x_return_status := fnd_api.g_ret_sts_error;
END Confirm_Ship;


Procedure Update_Packlist_Sts_Qty(
    P_Api_Version_Number IN   NUMBER,
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level   IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_organization_id    IN   NUMBER,
    p_packlist_line_id   IN   NUMBER,
    p_line_status        IN   VARCHAR2,
    p_quantity_packed    IN   NUMBER,
    p_quantity_shipped   IN   NUMBER,
    p_quantity_received  IN   NUMBER,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2)
IS
    l_packlist_line_rec  CSP_packlist_lines_PVT.PLL_Rec_Type;

    Cursor C_Get_packlist_lines IS
    Select PACKLIST_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_LINE_NUMBER,
           PACKLIST_HEADER_ID,
           BOX_ID,
           PICKLIST_LINE_ID,
           PACKLIST_LINE_STATUS,
           INVENTORY_ITEM_ID,
           QUANTITY_PACKED,
           QUANTITY_SHIPPED,
           QUANTITY_RECEIVED,
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
           UOM_CODE,
           LINE_ID
    From  CSP_PACKLIST_LINES
    WHERE organization_id = p_organization_id
    AND   packlist_line_id = p_packlist_line_id;
-- For Update NOWAIT;

    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(50) := 'Update_Packlist_Sts_Qty';
    l_msg_count NUMBER;
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    l_msg_data  VARCHAR2(300);
    l_check_existence NUMBER;
    l_packlist_header_id NUMBER;
    EXCP_USER_DEFINED           EXCEPTION;
BEGIN

    SAVEPOINT Update_Packlist_Sts_Qty_PUB;
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

       -- validate p_organization_id
        IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            IF p_validation_level = fnd_api.g_valid_level_full THEN
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
                          fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'mtl_parameters', TRUE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                  END;
             END IF;
             NULL;
        END IF;

       -- validate the p_packlist_line_id
        IF p_packlist_line_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_line_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            IF p_validation_level = fnd_api.g_valid_level_full THEN
                  BEGIN
                      select packlist_line_id into l_check_existence
                      from csp_packlist_lines
                      where organization_id = p_organization_id
                      and packlist_line_id = p_packlist_line_id;
                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_PACKLIST_LINE');
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                      WHEN OTHERS THEN
                          fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                          fnd_message.set_token('ERR_FIELD', 'p_packlist_line_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'csp_packlist_lines', TRUE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;

                  END;
             END IF;
             NULL;
         END IF;


    -- now it's ready to perform the update
     OPEN C_Get_packlist_lines;
     FETCH C_Get_packlist_lines INTO l_packlist_line_rec;
     IF C_Get_packlist_lines%NOTFOUND THEN
        CLOSE C_Get_packlist_lines;
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_PACKLIST_LINE');
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
     ELSE

        IF p_line_status IS NOT NULL THEN
            l_packlist_line_rec.packlist_line_status := p_line_status;
        END IF;
        IF p_quantity_packed IS NOT NULL THEN
            l_packlist_line_rec.quantity_packed := p_quantity_packed;
        END IF;
        IF p_quantity_shipped IS NOT NULL THEN
            l_packlist_line_rec.quantity_shipped:= p_quantity_shipped;
        END IF;
        IF p_quantity_received IS NOT NULL THEN
            l_packlist_line_rec.quantity_received:= p_quantity_received;
        END IF;

        l_packlist_line_rec.last_update_date := sysdate;
        CSP_packlist_lines_PVT.Update_packlist_lines(
              P_Api_Version_Number         => l_api_version_number,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
              P_Identity_Salesforce_Id     => NULL,
              P_PLL_Rec                    => l_packlist_line_rec,
              X_Return_Status              => l_return_status,
              X_Msg_Count                  => l_msg_count,
              X_Msg_Data                   => l_msg_data
        );
     END IF;
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_return_status := l_return_status;

EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
            Rollback to Update_Packlist_Sts_Qty_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);
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
                Rollback to Update_Packlist_Sts_Qty_PUB;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END Update_Packlist_Sts_Qty;


FUNCTION validate_pl_line_status (
-- Start of Comments
-- Function name   : validate_pl_line_status
-- Purpose         : This function checks whether the statuses of all packlist lines of a packlist header have been closed.
--                   It returns fnd_api.g_true if the statuses of all lines has been set to shipped.
--                   Otherwise, it returns fnd_api.g_false.
-- History          :
--  Person       Date               Descriptions
--  ------       --------           -----------------
--  klou         12-Apr-2000         Add p_check_receipt_short. If true, check also whether the status is '4' when it is not
--                                   the p_status_to_be_validated.
--  klou         06-Feb-2000         Added standard messages.
--  klou         04-Jan-2000         Created.
--
--  NOTES:
-- End of Comments
        p_packlist_header_id     IN  NUMBER,
        p_status_to_be_validated IN VARCHAR2,
        p_check_receipt_short    BOOLEAN := FALSE)
        RETURN VARCHAR2
IS
    l_line_id NUMBER;
    l_line_status VARCHAR2(30) := '-1';
    CURSOR C_Get_Packlist_Lines IS
        SELECT packlist_line_id
        FROM CSP_Packlist_LINES
        WHERE packlist_header_id = p_packlist_header_id;

BEGIN
        OPEN C_Get_Packlist_Lines;
            LOOP
                FETCH C_Get_Packlist_Lines INTO l_line_id;
                EXIT WHEN C_Get_Packlist_Lines%NOTFOUND;

                BEGIN
                    SELECT packlist_line_status INTO l_line_status
                    FROM CSP_Packlist_Lines
                    WHERE packlist_line_id = l_line_id;

                     IF l_line_status <> p_status_to_be_validated THEN
                        IF p_check_receipt_short THEN
                            IF l_line_status <> '4' THEN
                                CLOSE  C_Get_Packlist_Lines;
                                RETURN fnd_api.g_false;
                            END IF;
                        ELSE
                           RETURN fnd_api.g_false;
                        END IF;
                     END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        CLOSE  C_Get_Packlist_Lines;
                        RETURN fnd_api.g_false;
                END;

            END LOOP;

         IF  C_Get_Packlist_Lines%rowcount = 0 THEN
                IF  C_Get_Packlist_Lines%ISOPEN THEN
                     CLOSE  C_Get_Packlist_Lines;
                END IF;
                RETURN fnd_api.g_false;
         END IF;

         IF  C_Get_Packlist_Lines%ISOPEN THEN
            CLOSE  C_Get_Packlist_Lines;
         END IF;

        RETURN fnd_api.g_true;

END validate_pl_line_status;


Procedure update_packlist_header_sts (
          P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_packlist_header_id           IN   NUMBER,
          p_organization_id              IN   NUMBER,
          p_packlist_status              IN   VARCHAR2     := FND_API.G_MISS_CHAR,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2

    )
IS
    Cursor C_Get_Packlist_Headers IS
        SELECT
          PACKLIST_HEADER_ID ,
          CREATED_BY ,
          CREATION_DATE ,
          LAST_UPDATED_BY ,
          LAST_UPDATE_DATE ,
          LAST_UPDATE_LOGIN ,
          ORGANIZATION_ID ,
          PACKLIST_NUMBER ,
          SUBINVENTORY_CODE ,
          PACKLIST_STATUS ,
          DATE_CREATED ,
          DATE_PACKED ,
          DATE_SHIPPED ,
          DATE_RECEIVED ,
          CARRIER ,
          SHIPMENT_METHOD ,
          WAYBILL ,
          COMMENTS ,
          LOCATION_ID,
          PARTY_SITE_ID,
          ATTRIBUTE_CATEGORY ,
          ATTRIBUTE1 ,
          ATTRIBUTE2 ,
          ATTRIBUTE3 ,
          ATTRIBUTE4 ,
          ATTRIBUTE5 ,
          ATTRIBUTE6 ,
          ATTRIBUTE7 ,
          ATTRIBUTE8 ,
          ATTRIBUTE9 ,
          ATTRIBUTE10 ,
          ATTRIBUTE11 ,
          ATTRIBUTE12 ,
          ATTRIBUTE13 ,
          ATTRIBUTE14 ,
          ATTRIBUTE15
    From  CSP_PACKLIST_HEADERS
    WHERE organization_id = p_organization_id
    AND   packlist_header_id = p_packlist_header_id;

    l_packlist_headers_rec    CSP_packlist_headers_PVT.PLH_Rec_Type;
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(50) := 'Update_Packlist_Sts_Qty';
    l_msg_count NUMBER;
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    l_msg_data  VARCHAR2(300);
    l_check_existence NUMBER;
    l_packlist_header_id NUMBER;
    l_validation_level          NUMBER  := FND_API.G_VALID_LEVEL_NONE;
    EXCP_USER_DEFINED           EXCEPTION;

BEGIN
     SAVEPOINT Update_Packlist_Sts_Qty_PUB;

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

  IF p_validation_level = fnd_api.g_valid_level_full THEN
     -- validate the p_organization_id
      IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            IF p_validation_level = fnd_api.g_valid_level_full THEN
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
                          fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                          fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                          fnd_message.set_token('TABLE', 'mtl_parameters', TRUE);
                          FND_MSG_PUB.ADD;
                          RAISE EXCP_USER_DEFINED;
                  END;
             END IF;
             NULL;
        END IF;

      IF p_packlist_header_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_packlist_header_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
      ELSE
         -- IF p_validation_level = fnd_api.g_valid_level_full THEN
                BEGIN
                    select packlist_header_id into l_check_existence
                    from csp_packlist_headers
                    where organization_id = p_organization_id
                    and packlist_header_id = p_packlist_header_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_HEADER');
                        fnd_message.set_token ('HEADER_ID', to_char(p_packlist_header_id), TRUE);
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'p_packlist_header_id', TRUE);
                        fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token('TABLE', 'csp_packlist_headers', TRUE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
           --END IF;
      END IF;
    END IF;
      -- Now it's ready to do the update
      OPEN C_Get_Packlist_Headers;
      FETCH C_Get_Packlist_Headers INTO l_packlist_headers_rec;

      IF C_Get_Packlist_Headers%NOTFOUND THEN
            CLOSE C_Get_Packlist_Headers;
            fnd_message.set_name ('CSP', 'CSP_INVALID_PACKLIST_HEADER');
            fnd_message.set_token ('HEADER_ID', to_char(p_packlist_header_id), TRUE);
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
        CLOSE C_Get_Packlist_Headers;

        IF nvl(p_packlist_status, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
            l_packlist_headers_rec.packlist_status := p_packlist_status;
        ELSE
            l_packlist_headers_rec.packlist_status := '2';
        END IF;

        l_packlist_headers_rec.last_update_date := sysdate;

        -- call the CSP_Packlist_Headers_PVT.Update_packlist_headers to updat the packlist_status.
        CSP_Packlist_Headers_PVT.Update_packlist_headers(
            P_Api_Version_Number         => l_api_version_number,
            P_Init_Msg_List              => p_init_msg_list,
            P_Commit                     => FND_API.G_FALSE,
            p_validation_level           => l_validation_level,
            P_Identity_Salesforce_Id     => NULL,
            P_PLH_Rec                    => l_packlist_headers_rec,
            X_Return_Status              => l_return_status,
            X_Msg_Count                  => l_msg_count,
            X_Msg_Data                   => l_msg_data
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF fnd_api.to_boolean(p_commit) THEN
            commit WORK;
        END IF;

        x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
            Rollback to Update_Packlist_Sts_Qty_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);

            --for debugging purpose
           -- x_msg_data := l_msg_data;

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
               Rollback to Update_Packlist_Sts_Qty_PUB;
               fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
               fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
               fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
               fnd_msg_pub.add;
               fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
               x_return_status := fnd_api.g_ret_sts_error;

END update_packlist_header_sts;

END CSP_PL_SHIP_UTIL;

/
