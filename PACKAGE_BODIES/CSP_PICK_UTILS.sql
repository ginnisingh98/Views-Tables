--------------------------------------------------------
--  DDL for Package Body CSP_PICK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PICK_UTILS" AS
/*$Header: cspgtpub.pls 120.7.12010000.19 2013/01/22 10:37:35 rrajain ship $*/
--
--

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PICK_UTILS';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtpub.pls';
  G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;
  G_MIN_QUANTITY NUMBER := 0;
  G_MAX_QUANTITY NUMBER := 0;
  G_SAFETY_FACTOR NUMBER := 0;
  G_SAFETY_STOCK  NUMBER := 0;
  G_SERVICE_LEVEL NUMBER := 0;
  G_EDQ_FACTOR NUMBER := 0;
  G_ASL_FLAG Varchar2(1);
  G_SAFETY_STOCK_FLAG Varchar2(1);

   -- Start of comments
   --
   -- Procedure : create_pick
   -- Purpose   : Creates picklist headers and details for spares
   --             It calls the Auto_Detail API of Oracle Inventory
   --             which creates records in mtl_material_transactions_temp
   --             and the lot and serial temp tables
   --
   -- MODIFICATION HISTORY
   -- Person        Date     Comments
   -- ---------     ------   ------------------------------------------
   -- Pushpa Hegde  12/27/99 Created
   --
   -- End of comments


   PROCEDURE CSP_ASSIGN_GLOBAL_ORG_ID (P_ORG_ID NUMBER) is
   begin
     CSP_PICK_UTILS.GL_ORG_ID  := P_ORG_ID;
   End CSP_ASSIGN_GLOBAL_ORG_ID;

   function CSP_GLOBAL_ORG_ID return number is
   begin
      return(GL_ORG_ID);
   end CSP_GLOBAL_ORG_ID;
   function CSP_PRODUCT_ORGANIZATION return number is
   begin
      return(G_PRODUCT_ORGANIZATION);
   end CSP_PRODUCT_ORGANIZATION;

   PROCEDURE create_pick(  p_api_version_number     IN  NUMBER
                          ,x_return_status          OUT NOCOPY VARCHAR2
                          ,x_msg_count              OUT NOCOPY NUMBER
                          ,x_msg_data               OUT NOCOPY VARCHAR2
                          ,p_order_by               IN  NUMBER
                          ,p_org_id                 IN  NUMBER
                          ,p_move_order_header_id   IN  NUMBER
                          ,p_from_subinventory      IN  VARCHAR2
                          ,p_to_subinventory        IN  VARCHAR2
                          ,p_date_required          IN  DATE
                          ,p_created_by             IN  NUMBER
                          ,p_move_order_type        IN  NUMBER
                        ) IS

   l_order_by           VARCHAR2(30);
   l_line_number        NUMBER := 0;
   l_txn_header_id      NUMBER;
   l_picklist_header_id NUMBER;
   l_picklist_line_id   NUMBER;
   l_old_header_id      NUMBER          := null;
   l_from_sub           VARCHAR2(30)    := null;
   l_old_from_sub       VARCHAR2(30)    := null;
   l_to_sub             VARCHAR2(30)    := null;
   l_old_to_sub         VARCHAR2(30)    := null;
   l_date_required      DATE            := null;
   l_old_date_required  DATE            := null;
   l_created_by         NUMBER          := null;
   l_old_created_by     NUMBER          := null;
   l_line_id            NUMBER          := null;
   l_today              DATE;
   l_user_id            NUMBER;
   l_login_id           NUMBER;
   l_serial_control     NUMBER;
   l_serial_flag        VARCHAR2(1);
   l_num_of_rows        NUMBER;
   l_detailed_qty       NUMBER;
   l_transaction_temp_id NUMBER;
   l_rev                VARCHAR2(3);
   l_from_loc_id        NUMBER;
   l_to_loc_id          NUMBER;
   l_lot_number         VARCHAR2(80);
   l_expiration_date    DATE;
   l_action_code        NUMBER := 0; -- for insert
   l_cpll_rows          NUMBER;
   l_api_version_number        CONSTANT NUMBER  := 1.0;
   l_api_name                  CONSTANT VARCHAR2(20) := 'Create_Pick';
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(240);
   l_trolin_rec         INV_Move_Order_PUB.Trolin_Rec_Type;
   l_error_true         BOOLEAN := FALSE;
   l_prev_header_id     NUMBER := null;
   l_replen_line_id     NUMBER := null;
   l_replen_header_id   NUMBER := null;
   EXCP_USER_DEFINED    EXCEPTION;

   CURSOR mo_line_cur_header IS
     SELECT  mtrl.header_id
            ,mtrl.line_id
            ,mtrl.inventory_item_id
            ,mtrl.from_subinventory_code
            ,mtrl.to_subinventory_code
            ,mtrl.date_required
            ,mtrl.created_by
            ,mtrh.move_order_type
            ,mtrl.quantity_detailed
            ,mtrl.quantity
     FROM   mtl_item_locations_kfv  milk,
            mtl_system_items_b_kfv  msibk,
            csp_moveorder_lines     cmol,
            mtl_txn_request_lines   mtrl,
            mtl_txn_request_headers mtrh
     WHERE  mtrl.line_status in (3,7)
     AND    mtrl.transaction_type_id = 64 -- Subinventory Transfer = 64, Account Transfer = 63
     AND    (  (p_move_order_type = 1 and mtrh.move_order_type = 1)  -- Move Order Requistion
            OR (p_move_order_type = 2 and mtrh.move_order_type = 2)  -- Replenishment Move Orders
            OR (p_move_order_type = 3 and mtrh.move_order_type in (1,2)) -- Replenishment and Requisition move orders
            )
     AND    mtrl.organization_id = p_org_id
     and    mtrh.header_id       = mtrl.header_id
     --AND    nvl(quantity_detailed, 0) < quantity
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    milk.inventory_location_id(+) = mtrl.from_locator_id
     AND    milk.organization_id(+) = mtrl.organization_id
     AND    msibk.inventory_item_id(+) = mtrl.inventory_item_id
     AND    msibk.organization_id(+) = mtrl.organization_id
     AND    cmol.line_id = mtrl.line_id
     ORDER BY mtrl.header_id, mtrl.from_subinventory_code, milk.concatenated_segments, msibk.concatenated_segments;

     CURSOR mo_line_cur_from_sub IS
     SELECT  mtrl.header_id
            ,mtrl.line_id
            ,mtrl.inventory_item_id
            ,mtrl.from_subinventory_code
            ,mtrl.to_subinventory_code
            ,mtrl.date_required
            ,mtrl.created_by
            ,mtrh.move_order_type
            ,mtrl.quantity_detailed
            ,mtrl.quantity
     FROM   mtl_item_locations_kfv  milk,
            mtl_system_items_b_kfv  msibk,
            csp_moveorder_lines     cmol,
            mtl_txn_request_lines   mtrl,
            mtl_txn_request_headers mtrh
     WHERE  mtrl.line_status in (3,7)
     AND    mtrl.transaction_type_id = 64 -- Subinventory Transfer = 64, Account Transfer = 63
     AND    (  (p_move_order_type = 1 and mtrh.move_order_type = 1)  -- Move Order Requistion
            OR (p_move_order_type = 2 and mtrh.move_order_type = 2)  -- Replenishment Move Orders
            OR (p_move_order_type = 3 and mtrh.move_order_type in (1,2)) -- Replenishment and Requisition move orders
            )
     AND    mtrl.organization_id = p_org_id
     and    mtrh.header_id       = mtrl.header_id
     --AND    nvl(quantity_detailed, 0) < quantity
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    milk.inventory_location_id(+) = mtrl.from_locator_id
     AND    milk.organization_id(+) = mtrl.organization_id
     AND    msibk.inventory_item_id(+) = mtrl.inventory_item_id
     AND    msibk.organization_id(+) = mtrl.organization_id
     AND    cmol.line_id = mtrl.line_id
     ORDER BY mtrl.from_subinventory_code, milk.concatenated_segments, msibk.concatenated_segments;

     CURSOR mo_line_cur_to_sub IS
     SELECT  mtrl.header_id
            ,mtrl.line_id
            ,mtrl.inventory_item_id
            ,mtrl.from_subinventory_code
            ,mtrl.to_subinventory_code
            ,mtrl.date_required
            ,mtrl.created_by
            ,mtrh.move_order_type
            ,mtrl.quantity_detailed
            ,mtrl.quantity
     FROM   mtl_item_locations_kfv  milk,
            mtl_system_items_b_kfv  msibk,
            csp_moveorder_lines     cmol,
            mtl_txn_request_lines   mtrl,
            mtl_txn_request_headers mtrh
     WHERE  mtrl.line_status in (3,7)
     AND    mtrl.transaction_type_id = 64 -- Subinventory Transfer = 64, Account Transfer = 63
     AND    (  (p_move_order_type = 1 and mtrh.move_order_type = 1)  -- Move Order Requistion
            OR (p_move_order_type = 2 and mtrh.move_order_type = 2)  -- Replenishment Move Orders
            OR (p_move_order_type = 3 and mtrh.move_order_type in (1,2)) -- Replenishment and Requisition move orders
            )
     AND    mtrl.organization_id = p_org_id
     and    mtrh.header_id       = mtrl.header_id
     --AND    nvl(quantity_detailed, 0) < quantity
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    milk.inventory_location_id(+) = mtrl.from_locator_id
     AND    milk.organization_id(+) = mtrl.organization_id
     AND    msibk.inventory_item_id(+) = mtrl.inventory_item_id
     AND    msibk.organization_id(+) = mtrl.organization_id
     AND    cmol.line_id = mtrl.line_id
     ORDER BY mtrl.to_subinventory_code, mtrl.from_subinventory_code, milk.concatenated_segments, msibk.concatenated_segments;

     CURSOR mo_line_cur_date_reqd IS
     SELECT  mtrl.header_id
            ,mtrl.line_id
            ,mtrl.inventory_item_id
            ,mtrl.from_subinventory_code
            ,mtrl.to_subinventory_code
            ,mtrl.date_required
            ,mtrl.created_by
            ,mtrh.move_order_type
            ,mtrl.quantity_detailed
            ,mtrl.quantity
     FROM   mtl_item_locations_kfv  milk,
            mtl_system_items_b_kfv  msibk,
            csp_moveorder_lines     cmol,
            mtl_txn_request_lines   mtrl,
            mtl_txn_request_headers mtrh
     WHERE  mtrl.line_status in (3,7)
     AND    mtrl.transaction_type_id = 64 -- Subinventory Transfer = 64, Account Transfer = 63
     AND    (  (p_move_order_type = 1 and mtrh.move_order_type = 1)  -- Move Order Requistion
            OR (p_move_order_type = 2 and mtrh.move_order_type = 2)  -- Replenishment Move Orders
            OR (p_move_order_type = 3 and mtrh.move_order_type in (1,2)) -- Replenishment and Requisition move orders
            )
     AND    mtrl.organization_id = p_org_id
     and    mtrh.header_id       = mtrl.header_id
     --AND    nvl(quantity_detailed, 0) < quantity
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    milk.inventory_location_id(+) = mtrl.from_locator_id
     AND    milk.organization_id(+) = mtrl.organization_id
     AND    msibk.inventory_item_id(+) = mtrl.inventory_item_id
     AND    msibk.organization_id(+) = mtrl.organization_id
     AND    cmol.line_id = mtrl.line_id
     ORDER BY mtrl.date_Required, mtrl.from_subinventory_code, milk.concatenated_segments, msibk.concatenated_segments;

     CURSOR mo_line_cur_created_by IS
     SELECT  mtrl.header_id
            ,mtrl.line_id
            ,mtrl.inventory_item_id
            ,mtrl.from_subinventory_code
            ,mtrl.to_subinventory_code
            ,mtrl.date_required
            ,mtrl.created_by
            ,mtrh.move_order_type
            ,mtrl.quantity_detailed
            ,mtrl.quantity
     FROM   mtl_item_locations_kfv  milk,
            mtl_system_items_b_kfv  msibk,
            csp_moveorder_lines     cmol,
            mtl_txn_request_lines   mtrl,
            mtl_txn_request_headers mtrh
     WHERE  mtrl.line_status in (3,7)
     AND    mtrl.transaction_type_id = 64 -- Subinventory Transfer = 64, Account Transfer = 63
     AND    (  (p_move_order_type = 1 and mtrh.move_order_type = 1)  -- Move Order Requistion
            OR (p_move_order_type = 2 and mtrh.move_order_type = 2)  -- Replenishment Move Orders
            OR (p_move_order_type = 3 and mtrh.move_order_type in (1,2)) -- Replenishment and Requisition move orders
            )
     AND    mtrl.organization_id = p_org_id
     and    mtrh.header_id       = mtrl.header_id
     --AND    nvl(quantity_detailed, 0) < quantity
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    milk.inventory_location_id(+) = mtrl.from_locator_id
     AND    milk.organization_id(+) = mtrl.organization_id
     AND    msibk.inventory_item_id(+) = mtrl.inventory_item_id
     AND    msibk.organization_id(+) = mtrl.organization_id
     AND    cmol.line_id = mtrl.line_id
     ORDER BY mtrl.created_by, mtrl.from_subinventory_code, milk.concatenated_segments, msibk.concatenated_segments;

   CURSOR txn_temp_cur IS
     SELECT  transaction_temp_id
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,move_order_line_id
            ,inventory_item_id
            ,revision
            ,transaction_quantity
            ,transaction_uom
     FROM   mtl_material_transactions_temp
     WHERE  move_order_line_id = l_line_id
     --AND    transfer_subinventory = decode(l_to_sub, null, transfer_subinventory, l_to_sub)
     --AND    subinventory_code = decode(l_from_sub, null, subinventory_code, l_from_sub)
     AND    transaction_type_id = 64
     AND    organization_id = p_org_id;

   CURSOR mo_replen_cur IS
     SELECT mtrl.header_id
            ,mtrl.line_id
     FROM   mtl_txn_request_headers mtrh
            ,mtl_txn_request_lines mtrl
     WHERE  mtrl.header_id = mtrh.header_id
     AND    mtrl.line_status = 7
     AND    mtrh.move_order_type = 2
     AND    mtrl.from_subinventory_code = nvl(p_from_subinventory, mtrl.from_subinventory_code)
     AND    mtrl.to_subinventory_code = nvl(p_to_subinventory, mtrl.to_subinventory_code)
     AND    mtrl.date_required = nvl(p_date_required, mtrl.date_required)
     AND    mtrl.created_by = nvl(p_created_by, mtrl.created_by)
     AND    mtrl.header_id = nvl(p_move_order_header_id, mtrl.header_id)
     AND    mtrl.organization_id = mtrh.organization_id
     AND    mtrh.organization_id = p_org_id
     ORDER BY mtrl.header_id, mtrl.line_id;

   mo_replen_rec mo_replen_cur%ROWTYPE;
   mo_line_rec mo_line_cur_header%ROWTYPE;
   txn_temp_rec txn_temp_cur%ROWTYPE;

   l_return_count NUMBER := 1;
   t_msg_data  varchar2(2000);
   t_msg_dummy number;
   BEGIN

      -- Start of API savepoint
      SAVEPOINT Create_Pick_PUB;

      -- initialize message list
         FND_MSG_PUB.initialize;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      SELECT Sysdate INTO l_today FROM dual;
      l_user_id := fnd_global.user_id;
      l_login_id := fnd_global.login_id;

      -- If p_move_order_type = 2 or 3 (include replenishment move orders) then
      -- create records in spares move order tables
      IF (p_move_order_type = 2 OR p_move_order_type = 3) THEN
         OPEN mo_replen_cur;

         LOOP
           FETCH mo_replen_cur INTO mo_replen_rec;
           EXIT WHEN mo_replen_cur%NOTFOUND;

           BEGIN
             SELECT line_id
             INTO l_replen_line_id
             FROM CSP_MOVEORDER_LINES
             WHERE line_id = mo_replen_rec.line_id;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               IF (nvl(l_prev_header_id, 0) <> mo_replen_rec.header_id) THEN
                 BEGIN
                   SELECT header_id
                   INTO l_replen_header_id
                   FROM CSP_MOVEORDER_HEADERS
                   WHERE HEADER_ID = mo_replen_rec.header_id;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      CSP_TO_FORM_MOHEADERS.Validate_And_Write(
                          P_Api_Version_Number    => 1.0,
                          P_Init_Msg_List         => FND_API.G_FALSE,
                          P_Commit                => FND_API.G_FALSE,
                          p_validation_level      => null,
                          p_action_code           => l_action_code,/* 0 = insert, 1 = update, 2 = delete */
                          p_header_id             => mo_replen_rec.header_id,
                          p_created_by            => l_user_id,
                          p_CREATION_DATE         => l_today,
                          p_LAST_UPDATED_BY       => l_user_id,
                          p_LAST_UPDATE_DATE      => l_today,
                          p_LAST_UPDATE_LOGIN     => l_login_id,
                          p_carrier               => null,
                          p_shipment_method       => null,
                          p_autoreceipt_flag      => 'Y',
                          p_attribute_category    => null,
                          p_attribute1            => null,
                          p_attribute2            => null,
                          p_attribute3            => null,
                          p_attribute4            => null,
                          p_attribute5            => null,
                          p_attribute6            => null,
                          p_attribute7            => null,
                          p_attribute8            => null,
                          p_attribute9            => null,
                          p_attribute10           => null,
                          p_attribute11           => null,
                          p_attribute12           => null,
                          p_attribute13           => null,
                          p_attribute14           => null,
                          p_attribute15           => null,
                          p_location_id           => null,
                          p_party_site_id         => null,
                          X_Return_Status         => l_return_status,
                          X_Msg_Count             => l_msg_count,
                          X_Msg_Data              => l_msg_data
                          );

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            CLOSE mo_replen_cur;
                            RAISE FND_API.G_EXC_ERROR;
                          END IF;

                          l_prev_header_id := mo_replen_rec.header_id;

                   WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                      fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                      fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                      fnd_msg_pub.add;
                      RAISE EXCP_USER_DEFINED;
                 END;
               END IF;

             -- insert into csp_move_order_line
             CSP_TO_FORM_MOLINES.Validate_And_write(
                P_Api_Version_Number      => 1.0,
                P_Init_Msg_List           => FND_API.G_FALSE,
                P_Commit                  => FND_API.G_FALSE,
                p_validation_level        => null,
                p_action_code             => l_action_code,
                P_line_id                 => mo_replen_rec.line_id,
                p_CREATED_BY              => l_user_id,
                p_CREATION_DATE           => l_today,
                p_LAST_UPDATED_BY         => l_user_id,
                p_LAST_UPDATE_DATE        => l_today,
                p_LAST_UPDATED_LOGIN      => l_login_id,
                p_HEADER_ID               => mo_replen_rec.header_id,
                p_CUSTOMER_PO             => null,
                p_INCIDENT_ID             => null,
                p_TASK_ID                 => null,
                p_TASK_ASSIGNMENT_ID      => null,
                p_COMMENTS                => null,
                p_ATTRIBUTE_CATEGORY      => null,
                p_ATTRIBUTE1              => null,
                p_ATTRIBUTE2              => null,
                p_ATTRIBUTE3              => null,
                p_ATTRIBUTE4              => null,
                p_ATTRIBUTE5              => null,
                p_ATTRIBUTE6              => null,
                p_ATTRIBUTE7              => null,
                p_ATTRIBUTE8              => null,
                p_ATTRIBUTE9              => null,
                p_ATTRIBUTE10             => null,
                p_ATTRIBUTE11             => null,
                p_ATTRIBUTE12             => null,
                p_ATTRIBUTE13             => null,
                p_ATTRIBUTE14             => null,
                p_ATTRIBUTE15             => null,
                X_Return_Status           => l_return_status,
                X_Msg_Count               => l_msg_count,
                X_Msg_Data                => l_msg_data
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  CLOSE mo_replen_cur;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

             WHEN OTHERS THEN
               fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
               fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
               fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
               fnd_msg_pub.add;
               RAISE EXCP_USER_DEFINED;
           END;
         END LOOP;

         CLOSE mo_replen_cur;
      END IF;

      IF (p_order_by = 1) THEN
        OPEN mo_line_cur_header;
      ELSIF (p_order_by = 2) THEN
        OPEN mo_line_cur_from_sub;
      ELSIF (p_order_by = 3) THEN
        OPEN mo_line_cur_to_sub;
      ELSIF  (p_order_by = 4) THEN
        OPEN mo_line_cur_date_Reqd;
      ELSIF (p_order_by = 5) THEN
        OPEN mo_line_cur_created_by;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      LOOP
        IF (p_order_by = 1) THEN
          FETCH mo_line_cur_header INTO mo_line_rec;
        ELSIF (p_order_by = 2) THEN
          FETCH mo_line_cur_from_sub INTO mo_line_rec;
        ELSIF (p_order_by = 3) THEN
          FETCH mo_line_cur_to_sub INTO mo_line_rec;
        ELSIF  (p_order_by = 4) THEN
          FETCH mo_line_cur_date_reqd INTO mo_line_rec;
        ELSIF (p_order_by = 5) THEN
          FETCH mo_line_cur_created_by INTO mo_line_rec;
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        EXIT WHEN ((p_order_by = 1 and mo_line_cur_header%NOTFOUND) OR
                   (p_order_by = 2 and mo_line_cur_from_sub%NOTFOUND) OR
                   (p_order_by = 3 and mo_line_cur_to_sub%NOTFOUND) OR
                   (p_order_by =4 and mo_line_cur_date_reqd%NOTFOUND) OR
                   (p_order_by = 5 and mo_line_cur_created_by%NOTFOUND));

        l_line_id := mo_line_rec.line_id;

        SELECT mtl_material_transactions_s.nextval
        INTO   l_txn_header_id
        FROM   dual;

        -- This code is used for auto detailing serial numbers

        SELECT serial_number_control_code into l_serial_control
        FROM mtl_system_items
        WHERE inventory_item_id = mo_line_rec.inventory_item_id
        AND   organization_id = p_org_id;

        IF l_serial_control = 1 THEN
           l_serial_flag := fnd_api.g_false;
        ELSE
          l_serial_flag := fnd_api.g_true;
        END IF;


        INV_Replenish_Detail_PUB.Line_Details_PUB(
            p_line_id                   => mo_line_rec.line_id,
            x_number_of_rows            => l_num_of_rows,
            x_detailed_qty              => l_detailed_qty,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            x_revision                  => l_rev,
            x_locator_id                => l_from_loc_id,
            x_transfer_to_location      => l_to_loc_id,
            x_lot_number                => l_lot_number,
            x_expiration_date           => l_expiration_date,
            x_transaction_temp_id       => l_transaction_temp_id,
            p_transaction_header_id     => l_txn_header_id,
            p_transaction_mode          => null,
            p_move_order_type           => mo_line_rec.move_order_type,
            p_serial_flag               => l_serial_flag
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              fnd_message.set_name ('CSP', 'CSP_MO_DETAILING_ERROR');
              fnd_message.set_token ('MOVE_ORDER_LINE_ID', to_char(mo_line_rec.line_id), FALSE);
              fnd_msg_pub.add;

              for j in reverse 1..fnd_msg_pub.count_msg loop
                  fnd_msg_pub.get
                  ( j
                  , FND_API.G_FALSE
                  , t_msg_data
                  , t_msg_dummy
                  );

                  x_msg_data := x_msg_data || t_msg_data;

                  IF mod(l_return_count, 2) = 0 THEN
                     x_msg_data := x_msg_data || fnd_global.local_chr(10);
                  END IF;
                  l_return_count := l_return_count + 1;
              end loop;
              l_return_status := fnd_api.g_ret_sts_success;
              x_msg_count := -1 ;
        END IF;

        IF (l_num_of_rows >= 1) THEN

          -- update mtl_txn_request_lines with the detailed quantity
          l_trolin_rec := INV_Trolin_util.Query_Row( mo_line_rec.line_id );
          l_trolin_rec.quantity_detailed := l_detailed_qty;
          l_trolin_rec.last_update_date := SYSDATE;
          l_trolin_rec.last_updated_by := FND_GLOBAL.USER_ID;
          l_trolin_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

          INV_Trolin_Util.Update_Row(l_trolin_rec);

        /*  update mtl_txn_request_lines
          set quantity_detailed = l_detailed_qty
          where line_id = mo_line_rec.line_id; */


          OPEN txn_temp_cur;

          LOOP
            FETCH txn_temp_cur INTO txn_temp_rec;
            EXIT WHEN txn_temp_cur%NOTFOUND;

            SELECT count(1)
            INTO   l_cpll_rows
            FROM   csp_picklist_lines
            WHERE  transaction_temp_id = txn_temp_rec.transaction_temp_id;

            IF (nvl(l_cpll_rows, 0) =  0) THEN

               IF (((p_order_by = 1) AND (l_old_header_id is NULL OR l_old_header_id <> mo_line_rec.header_id))
                  OR ((p_order_by = 2) AND (l_old_from_sub is NULL OR l_old_from_sub <> mo_line_rec.from_subinventory_code))
                  OR ((p_order_by = 3) AND (l_old_to_sub is NULL OR l_old_to_sub <> mo_line_rec.to_subinventory_code))
                  OR ((p_order_by = 4) AND (l_old_date_required is NULL OR l_old_date_required <> mo_line_rec.date_required))
                  OR ((p_order_by = 5) AND (l_old_created_by is NULL OR l_old_created_by <> mo_line_rec.created_by))
                  ) THEN

                    l_old_header_id := mo_line_rec.header_id;
                    l_old_from_sub  := mo_line_rec.from_subinventory_code;
                    l_old_to_sub    := mo_line_rec.to_subinventory_code;
                    l_old_date_required := mo_line_rec.date_required;
                    l_old_created_by := mo_line_rec.created_by;

                    l_line_number   := 0;  -- Initialize the line number

                    SELECT csp_picklist_headers_s1.nextval
                    INTO   l_picklist_header_id
                    FROM   dual;

                    CSP_PC_FORM_PICKHEADERS.Validate_And_Write (
                        P_Api_Version_Number        => 1.0,
                        P_Init_Msg_List             => FND_API.G_FALSE,
                        P_Commit                    => FND_API.G_FALSE,
                        p_validation_level          => null,
                        p_action_code               => l_action_code,
                        px_PICKLIST_HEADER_ID       => l_picklist_header_id,
                        p_CREATED_BY                => l_user_id,
                        p_CREATION_DATE             => l_today,
                        p_LAST_UPDATED_BY           => l_user_id,
                        p_LAST_UPDATE_DATE          => l_today,
                        p_LAST_UPDATE_LOGIN         => l_login_id,
                        p_ORGANIZATION_ID           => p_org_id,
                        p_PICKLIST_NUMBER           => l_picklist_header_id,
                        p_PICKLIST_STATUS           => 1,           -- open
                        p_DATE_CREATED              => l_today,
                        p_DATE_CONFIRMED            => null,
                        p_ATTRIBUTE_CATEGORY        => null,
                        p_ATTRIBUTE1                => null,
                        p_ATTRIBUTE2                => null,
                        p_ATTRIBUTE3                => null,
                        p_ATTRIBUTE4                => null,
                        p_ATTRIBUTE5                => null,
                        p_ATTRIBUTE6                => null,
                        p_ATTRIBUTE7                => null,
                        p_ATTRIBUTE8                => null,
                        p_ATTRIBUTE9                => null,
                        p_ATTRIBUTE10               => null,
                        p_ATTRIBUTE11               => null,
                        p_ATTRIBUTE12               => null,
                        p_ATTRIBUTE13               => null,
                        p_ATTRIBUTE14               => null,
                        p_ATTRIBUTE15               => null,
                        X_Return_Status             => l_return_status,
                        X_Msg_Count                 => l_msg_count,
                        X_Msg_Data                  => l_msg_data
                    );
               END IF;

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               l_line_number := (l_line_number + 1);

               SELECT csp_picklist_lines_s1.nextval
               INTO   l_picklist_line_id
               FROM   dual;

               CSP_PC_FORM_PICKLINES.Validate_And_Write (
                 P_Api_Version_Number           => 1.0
                ,P_Init_Msg_List                => FND_API.G_FALSE
                ,P_Commit                       => FND_API.G_FALSE
                ,p_validation_level             => null
                ,p_action_code                  => l_action_code      /* 0 = insert, 1 = update, 2 = delete */
                ,px_PICKLIST_LINE_ID            => l_picklist_line_id
                ,p_CREATED_BY                   => txn_temp_rec.created_by
                ,p_CREATION_DATE                => txn_temp_rec.creation_date
                ,p_LAST_UPDATED_BY              => txn_temp_rec.last_updated_by
                ,p_LAST_UPDATE_DATE             => txn_temp_rec.last_update_date
                ,p_LAST_UPDATE_LOGIN            => txn_temp_rec.last_update_login
                ,p_PICKLIST_LINE_NUMBER         => l_line_number
                ,p_PICKLIST_HEADER_ID           => l_picklist_header_id
                ,p_LINE_ID                      => mo_line_rec.line_id
                ,p_INVENTORY_ITEM_ID            => txn_temp_rec.inventory_item_id
                ,p_UOM_CODE                     => txn_temp_rec.transaction_uom
                ,p_REVISION                     => txn_temp_rec.revision
                ,p_QUANTITY_PICKED              => txn_temp_rec.transaction_quantity
                ,p_TRANSACTION_TEMP_ID          => txn_temp_rec.transaction_temp_id
                ,p_ATTRIBUTE_CATEGORY           => null
                ,p_ATTRIBUTE1                   => null
                ,p_ATTRIBUTE2                   => null
                ,p_ATTRIBUTE3                   => null
                ,p_ATTRIBUTE4                   => null
                ,p_ATTRIBUTE5                   => null
                ,p_ATTRIBUTE6                   => null
                ,p_ATTRIBUTE7                   => null
                ,p_ATTRIBUTE8                   => null
                ,p_ATTRIBUTE9                   => null
                ,p_ATTRIBUTE10                  => null
                ,p_ATTRIBUTE11                  => null
                ,p_ATTRIBUTE12                  => null
                ,p_ATTRIBUTE13                  => null
                ,p_ATTRIBUTE14                  => null
                ,p_ATTRIBUTE15                  => null
                ,x_return_status                => l_return_status
                ,x_msg_count                    => l_msg_count
                ,x_msg_data                     => l_msg_data
                );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
             END IF;
          END LOOP;
          CLOSE txn_temp_cur;

        END IF;
      END LOOP;

      IF (p_order_by = 1) THEN
        CLOSE mo_line_cur_header;
      ELSIF (p_order_by = 2) THEN
        CLOSE mo_line_cur_from_sub;
      ELSIF (p_order_by = 3) THEN
        CLOSE mo_line_cur_to_sub;
      ELSIF  (p_order_by = 4) THEN
        CLOSE mo_line_cur_date_Reqd;
      ELSIF (p_order_by = 5) THEN
        CLOSE mo_line_cur_created_by;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      x_return_status := l_return_status;

      EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
             Rollback to Create_Pick_PUB;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;

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
                Rollback to Create_Pick_PUB;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;
   END create_pick;


Procedure Confirm_Pick (
-- Start of Comments
-- Procedure    : Confirm_Pick
-- Purpose      : This procedure inserts the record into the csp_picklist_serial_lots tables based on the
--                msnt or the mtlt record associated with the picklist.
--
-- History      :
--  UserID       Date          Comments
--  -----------  --------      --------------------------
--   klou       02/01/2000      Created.
--
-- NOTES:
--
--End of Comments
     P_Api_Version_Number           IN   NUMBER
    ,P_Init_Msg_List                IN   VARCHAR2
    ,P_Commit                       IN   VARCHAR2
    ,p_validation_level             IN   NUMBER
    ,p_picklist_header_id           IN   NUMBER
    ,p_organization_id              IN   NUMBER
    ,x_return_status                OUT NOCOPY  VARCHAR2
    ,x_msg_count                    OUT NOCOPY  NUMBER
    ,x_msg_data                     OUT NOCOPY  VARCHAR2
)

IS
    l_api_version_number   CONSTANT NUMBER  := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'Confirm_Pick';
    l_return_status     VARCHAR2(1);
    l_msg_count NUMBER := 0;
    l_msg_data  VARCHAR2(500);
    l_commit           VARCHAR2(1) := fnd_api.g_false;
    l_check_existence   NUMBER := 0;
    EXCP_USER_DEFINED EXCEPTION;
    l_picklist_serial_lot_id   NUMBER;

    TYPE picklist_line_Rec_Type IS RECORD
    (
       picklist_line_id                NUMBER := NULL,
       picklist_header_id              NUMBER := NULL,
       LINE_ID                         NUMBER := NULL,
       INVENTORY_ITEM_ID               NUMBER := NULL,
       QUANTITY_PICKED                 NUMBER := NULL,
       TRANSACTION_TEMP_ID             NUMBER := NULL );

    TYPE mtl_txn_serial_lot_Rec_Type IS RECORD
    (
       item_serial_control_code         NUMBER := NULL,
       item_lot_control_code            NUMBER := NULL );

    TYPE mtl_txn_lot_numbers_Rec_Type IS RECORD
    (
        transaction_temp_id           NUMBER := NULL,
        serial_transaction_temp_id    NUMBER := NULL,
        lot_number                    VARCHAR2(80) := NULL,
        transaction_quantity          NUMBER := NULL,
        primary_quantity              NUMBER := NULL );

    l_picklist_line_rec   picklist_line_Rec_Type;
    l_mmtt_rec            mtl_txn_serial_lot_Rec_Type;
    l_lot_number_rec      mtl_txn_lot_numbers_Rec_Type;

    CURSOR l_Get_Picklist_Lines_Csr IS
        SELECT picklist_line_id, picklist_header_id, line_id, inventory_item_id,
               quantity_picked, transaction_temp_id
        FROM csp_picklist_lines
        WHERE picklist_header_id = p_picklist_header_id;

    CURSOR l_Get_Mmtt_Csr (l_transaction_temp_id NUMBER) IS
        SELECT item_serial_control_code, item_lot_control_code
        FROM mtl_material_transactions_temp
        WHERE organization_id = p_organization_id
        AND transaction_temp_id = l_transaction_temp_id;

    CURSOR l_Get_Mtlt_Csr (l_transaction_temp_id NUMBER) IS
       SELECT transaction_temp_id, serial_transaction_temp_id, lot_number,
              transaction_quantity, primary_quantity
       FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = l_transaction_temp_id;

    -- define a subfunction to transact any serial record
    Function transact_serial (
          l_temp_id_ref IN NUMBER) RETURN BOOLEAN
    is
        /*
         TYPE mtl_serial_numbers_Rec_Type IS RECORD(
              transaction_temp_id           NUMBER := NULL,
              fm_serial_number              VARCHAR2(30) := NULL,
              to_serial_number              VARCHAR2(30) := NULL );

         l_serial_number_rec   mtl_serial_numbers_Rec_Type;
         CURSOR l_Get_Serial_Numbers_Csr IS
                SELECT transaction_temp_id, fm_serial_number, to_serial_number
                FROM mtl_serial_numbers_temp
                WHERE transaction_temp_id = l_temp_id_ref;
          */
          l_msnt_tbl                 csp_pp_util.g_msnt_tbl_type;
          l_tbl_index                NUMBER  := 1;
          l_fm_prefix                VARCHAR2(30);
          l_to_prefix                VARCHAR2(30);
          l_fm_number                VARCHAR2(30);
          l_to_number                VARCHAR2(30);
          l_fm_serial_to_del         VARCHAR2(30);
          l_to_serial_to_del         VARCHAR2(30);
          l_temp_id_to_del           NUMBER;
          l_number_length            NUMBER  := 0;
          l_total_serial_numbers     NUMBER  := 0;
          l_index                    NUMBER  := 0;

          CURSOR l_Get_Serial_Numbers_Csr IS
            SELECT * FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id = l_temp_id_ref;
     BEGIN
          OPEN l_Get_Serial_Numbers_Csr;
          LOOP <<process_serial_records>>
          -- FETCH l_Get_Serial_Numbers_Csr INTO l_serial_number_rec;
          FETCH l_Get_Serial_Numbers_Csr Into l_msnt_tbl(l_tbl_index);
          EXIT WHEN l_Get_Serial_Numbers_Csr%NOTFOUND;

         -- Analyze the serial number range
            csp_pp_util.split_prefix_num (
                   p_serial_number        => l_msnt_tbl(l_tbl_index).fm_serial_number
                  ,p_prefix               => l_fm_prefix
                  ,x_num                  => l_fm_number
                 );

            csp_pp_util.split_prefix_num (
                   p_serial_number        => l_msnt_tbl(l_tbl_index).to_serial_number
                  ,p_prefix               => l_to_prefix
                  ,x_num                  => l_to_number
                 );

            IF (l_fm_number IS NULL AND l_to_number IS NOT NULL)
                 -- OR (l_fm_number IS NOT NULL AND l_to_number IS NULL)
                  OR (nvl(to_number(l_to_number), l_fm_number) < to_number(l_fm_number)) THEN
                  fnd_message.set_name ('CSP', 'CSP_INVALID_SERIAL_RANGE');
                  fnd_msg_pub.add;
                  CLOSE l_Get_Mmtt_Csr;
                  CLOSE l_Get_Serial_Numbers_Csr;
                  CLOSE l_Get_Picklist_Lines_Csr;
                  RAISE EXCP_USER_DEFINED;
            END IF;

            l_fm_serial_to_del     := l_msnt_tbl(l_tbl_index).fm_serial_number;
            l_to_serial_to_del     := l_msnt_tbl(l_tbl_index).to_serial_number;
            l_temp_id_to_del       := l_msnt_tbl(l_tbl_index).transaction_temp_id;
            l_total_serial_numbers := to_number(l_to_number);

            IF nvl(l_to_number, l_fm_number) = l_fm_number OR (l_to_number IS NULL AND l_fm_number IS NULL) THEN
                l_total_serial_numbers := 1;
            END IF;

           IF l_total_serial_numbers = 1 THEN
              CSP_Pick_SL_Util.Validate_And_Write (
                     P_Api_Version_Number      => l_api_version_number,
                     P_Init_Msg_List           => FND_API.G_TRUE,
                     P_Commit                  => l_commit,
                     p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                     p_action_code             => 0,
                     px_PICKLIST_SERIAL_LOT_ID => l_picklist_serial_lot_id,
                     p_CREATED_BY              => G_USER_ID,
                     p_CREATION_DATE           => sysdate,
                     p_LAST_UPDATED_BY         => G_USER_ID,
                     p_LAST_UPDATE_DATE        => sysdate,
                     p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
                     p_PICKLIST_LINE_ID        => l_picklist_line_rec.picklist_line_id,
                     p_ORGANIZATION_ID         => p_organization_id,
                     p_INVENTORY_ITEM_ID       => l_picklist_line_rec.inventory_item_id,
                     p_QUANTITY                => 1,
                     p_LOT_NUMBER              => l_lot_number_rec.lot_number,
                     p_SERIAL_NUMBER           => l_msnt_tbl(l_tbl_index).fm_serial_number,
                     X_Return_Status           => l_return_status,
                     X_Msg_Count               => l_msg_count,
                     X_Msg_Data                => l_msg_data
                     );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     CLOSE l_Get_Serial_Numbers_Csr;
                     RETURN FALSE;
                  END IF;
            ELSE
               l_index         := to_number(l_fm_number);
               l_number_length := length(l_fm_number);

              WHILE l_index <= l_total_serial_numbers LOOP
                  CSP_Pick_SL_Util.Validate_And_Write (
                               P_Api_Version_Number      => l_api_version_number,
                               P_Init_Msg_List           => FND_API.G_TRUE,
                               P_Commit                  => l_commit,
                               p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                               p_action_code             => 0,
                               px_PICKLIST_SERIAL_LOT_ID => l_picklist_serial_lot_id,
                               p_CREATED_BY              => G_USER_ID,
                               p_CREATION_DATE           => sysdate,
                               p_LAST_UPDATED_BY         => G_USER_ID,
                               p_LAST_UPDATE_DATE        => sysdate,
                               p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
                               p_PICKLIST_LINE_ID        => l_picklist_line_rec.picklist_line_id,
                               p_ORGANIZATION_ID         => p_organization_id,
                               p_INVENTORY_ITEM_ID       => l_picklist_line_rec.inventory_item_id,
                               p_QUANTITY                => 1,
                               p_LOT_NUMBER              => l_lot_number_rec.lot_number,
                               p_SERIAL_NUMBER           => l_fm_prefix||lpad(to_char(l_index),l_number_length, '0'),
                               X_Return_Status           => l_return_status,
                               X_Msg_Count               => l_msg_count,
                               X_Msg_Data                => l_msg_data );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       CLOSE l_Get_Serial_Numbers_Csr;
                       RETURN FALSE;
                  END IF;

                  l_msnt_tbl(l_tbl_index).fm_serial_number    := l_fm_prefix||lpad(to_char(l_index),l_number_length, '0');
                  l_msnt_tbl(l_tbl_index).to_serial_number    := l_fm_prefix||lpad(to_char(l_index),l_number_length, '0');
                  l_msnt_tbl(l_tbl_index).serial_prefix       := 1;
                  l_msnt_tbl(l_tbl_index).creation_date       := sysdate;
                  l_msnt_tbl(l_tbl_index).last_update_date    := sysdate;

                  csp_pp_util.insert_msnt(
                    x_return_status  => l_return_status
                   ,p_msnt_tbl       => l_msnt_tbl
                   ,p_msnt_tbl_size  => 1
                   );

                  l_index := l_index + 1;
              END LOOP; -- end the while loop
               --Delete the existing serial temp records
                 delete from mtl_serial_numbers_temp
                 where  transaction_temp_id = l_temp_id_to_del
                 and    fm_serial_number    = l_fm_serial_to_del
                 and    to_serial_number    = nvl(l_to_serial_to_del, to_serial_number);

                 If sql%notfound Then
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                      fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                      fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                      fnd_msg_pub.add;
                      CLOSE l_Get_Serial_Numbers_Csr;
                      RETURN FALSE;
                 End If;
            End If;
         END LOOP process_serial_records;

         If l_Get_Serial_Numbers_Csr%ROWCOUNT = 0 THEN
            fnd_message.set_name ('CSP', 'CSP_PICK_SERIAL_LOT_FAILURE');
            fnd_message.set_token('PICKLIST_HEADER_ID', to_char(p_picklist_header_id), FALSE);
            fnd_msg_pub.add;
            CLOSE l_Get_Serial_Numbers_Csr;
            Return False;
         End If;

         IF l_Get_Serial_Numbers_Csr%ISOPEN THEN
            CLOSE l_Get_Serial_Numbers_Csr;
         END IF;

         RETURN TRUE;

      End transact_serial;

BEGIN
  -- Start of API savepoint
     SAVEPOINT Confirm_Pick_PUB;
     x_return_status := fnd_api.g_ret_sts_success;

  -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
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

     IF p_organization_id IS NULL THEN
         fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
         fnd_message.set_token ('PARAMETER', 'p_organization_id', TRUE);
         fnd_msg_pub.add;
         RAISE EXCP_USER_DEFINED;
     ELSE
        -- Check whether the organizaton exists.
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
                fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
        END;
     END IF;

     IF p_picklist_header_id IS NULL THEN
         fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
         fnd_message.set_token ('PARAMETER', 'p_picklist_header_id', TRUE);
         fnd_msg_pub.add;
         RAISE EXCP_USER_DEFINED;
     ELSE
        -- check whether the organizaton exists.
        BEGIN
            SELECT picklist_header_id INTO l_check_existence
            FROM csp_picklist_headers
            WHERE organization_id = p_organization_id
            AND picklist_header_id = p_picklist_header_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 fnd_message.set_name ('CSP', 'CSP_INVALID_PICKLIST_HEADER');
                 fnd_message.set_token ('HEADER_ID', to_char(p_picklist_header_id), TRUE);
                 fnd_msg_pub.add;
                 RAISE EXCP_USER_DEFINED;
            WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'p_picklist_header_id', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'csp_picklist_headers', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
        END;
     END IF;
    -- get all picklist lines
    OPEN l_Get_Picklist_Lines_Csr;
    LOOP <<process_mmtt_records>>
        FETCH l_Get_Picklist_Lines_Csr INTO l_picklist_line_rec;
        EXIT WHEN l_Get_Picklist_Lines_Csr%NOTFOUND;

           Update_Misc_MMTT (
               P_Api_Version_Number         => p_api_version_number,
               P_Init_Msg_List              => p_init_msg_list,
               P_Commit                     => fnd_api.g_false,
               p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
               p_transaction_temp_id        => l_picklist_line_rec.transaction_temp_id,
               p_organization_id            => p_organization_id,
               X_Return_Status              => l_return_status,
               X_Msg_Count                  => l_msg_count,
               X_Msg_Data                   => l_msg_data );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  CLOSE l_Get_Mmtt_Csr;
                  CLOSE l_Get_Picklist_Lines_Csr;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;

        -- Find the serial_control_code and the lot_control_code of the record in the mmtt table.
           OPEN l_Get_Mmtt_Csr(l_picklist_line_rec.transaction_temp_id);
           FETCH l_Get_Mmtt_Csr INTO l_mmtt_rec;

           IF l_Get_Mmtt_Csr%NOTFOUND THEN
              fnd_message.set_name ('CSP', 'CSP_NO_TXN_RECORD');
              fnd_message.set_token ('PICKLIST_ID', to_char(l_picklist_line_rec.picklist_line_id), TRUE);
              fnd_msg_pub.add;
              CLOSE l_Get_Mmtt_Csr;
              CLOSE l_Get_Picklist_Lines_Csr;
              RAISE EXCP_USER_DEFINED;
           END IF;

           --Let's handle the lot control case first.
           IF nvl(l_mmtt_rec.item_lot_control_code, 1) <> 1 THEN

             OPEN l_Get_Mtlt_Csr(l_picklist_line_rec.transaction_temp_id);
             Loop <<process_lot_rec>>
                FETCH l_Get_Mtlt_Csr INTO l_lot_number_rec;
                Exit When l_Get_Mtlt_Csr%NOTFOUND;

                If nvl(l_mmtt_rec.item_serial_control_code, 1) in (2, 5) Then

                    -- the item is also under serial control, find out the serial number in the mtl_serial_numbers_temp
                    -- and insert it into the csp_picklist_serial_lots along with the lot number.
                    IF not (transact_serial(l_lot_number_rec.serial_transaction_temp_id)) THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                        fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                        fnd_msg_pub.add;
                        CLOSE l_Get_Mmtt_Csr;
                        CLOSE l_Get_Picklist_Lines_Csr;
                        RAISE EXCP_USER_DEFINED;
                   END IF;

              Else
                   -- the item is only under lot control, insert the lot number into the csp_picklist_serial_lots
                     CSP_Pick_SL_Util.Validate_And_Write (
                                 P_Api_Version_Number      => l_api_version_number,
                                 P_Init_Msg_List           => FND_API.G_TRUE,
                                 P_Commit                  => l_commit,
                                 p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                 p_action_code             => 0,
                                 px_PICKLIST_SERIAL_LOT_ID => l_picklist_serial_lot_id,
                                 p_CREATED_BY              => G_USER_ID,
                                 p_CREATION_DATE           => sysdate,
                                 p_LAST_UPDATED_BY         => G_USER_ID,
                                 p_LAST_UPDATE_DATE        => sysdate,
                                 p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
                                 p_PICKLIST_LINE_ID        => l_picklist_line_rec.picklist_line_id,
                                 p_ORGANIZATION_ID         => p_organization_id,
                                 p_INVENTORY_ITEM_ID       => l_picklist_line_rec.inventory_item_id,
                                 p_QUANTITY                => l_lot_number_rec.transaction_quantity,
                                 p_LOT_NUMBER              => l_lot_number_rec.lot_number,
                                 p_SERIAL_NUMBER           => null,
                                 X_Return_Status           => l_return_status,
                                 X_Msg_Count               => l_msg_count,
                                 X_Msg_Data                => l_msg_data
                              );
                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                             CLOSE l_Get_Mmtt_Csr;
                             CLOSE l_Get_Picklist_Lines_Csr;
                             RAISE FND_API.G_EXC_ERROR;
                      END IF;
              End If;
            End loop process_lot_rec;

              IF l_Get_Mtlt_Csr%ROWCOUNT = 0 THEN
                   fnd_message.set_name ('CSP', 'CSP_PICK_SERIAL_LOT_FAILURE');
                   fnd_message.set_token('PICKLIST_HEADER_ID', to_char(p_picklist_header_id), FALSE);
                   fnd_msg_pub.ADD;
                    CLOSE l_Get_Mmtt_Csr;
                    CLOSE l_Get_Picklist_Lines_Csr;
                    RAISE EXCP_USER_DEFINED;
              ELSE
                    CLOSE l_Get_Mtlt_Csr;
              END IF;
             ELSE
               l_lot_number_rec.transaction_quantity := null;
               l_lot_number_rec.lot_number           := null;

               -- the item is not under lot control. It can either be under serial control or no control at all.
               If nvl(l_mmtt_rec.item_serial_control_code, 1) in (2, 5) Then
                    -- the item is under serial control, find out the serial number in the mtl_serial_numbers_temp
                    -- and insert it into the csp_picklist_serial_lots.
                    IF not (transact_serial(l_picklist_line_rec.transaction_temp_id)) THEN
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                        fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                        fnd_msg_pub.add;
                        CLOSE l_Get_Mmtt_Csr;
                        CLOSE l_Get_Picklist_Lines_Csr;
                        RAISE EXCP_USER_DEFINED;
                    END IF;
               Else -- the item is neither under serial control nor lot control. do nothing.
                    NULL;
               End if;
             End If;

           IF l_Get_Mmtt_Csr%ISOPEN THEN
             CLOSE l_Get_Mmtt_Csr;
           END IF;
    END LOOP process_mmtt_records;

    IF l_Get_Picklist_Lines_Csr%ISOPEN THEN
        CLOSE l_Get_Picklist_Lines_Csr;
    END IF;

  -- update the quantity_detailed in the mtl_txn_request_lines
    /*  Save_Pick (
                   P_Api_Version_Number          => l_api_version_number
                  ,P_Init_Msg_List               => FND_API.G_TRUE
                  ,P_Commit                      => FND_API.G_FALSE
                  ,p_validation_level            => FND_API.G_VALID_LEVEL_FULL
                  ,p_picklist_header_id          => p_picklist_header_id
                  ,p_organization_id             => p_organization_id
                  ,x_return_status               => l_return_status
                  ,x_msg_count                   => l_msg_count
                  ,x_msg_data                    => l_msg_data
                 );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE FND_API.G_EXC_ERROR;
       END IF;
*/
       IF fnd_api.to_boolean(p_commit) THEN
            commit work;
       END IF;

EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
             Rollback to Confirm_Pick_PUB;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;

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
                Rollback to Confirm_Pick_PUB;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
                ( p_count => x_msg_count
                , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END Confirm_Pick;

Procedure Update_Misc_MMTT (
 -- Start of Comments
  -- Procedure    : Update_Misc_MMTT
  -- Purpose      : This procedure updates the transaction source type, transaction type, and transaction action of the
  --                a mmtt temp table to 13 (Inventory), 2 (Inventory sub transfer) and 2 (Subinventory transfer), respectively.
  --                This procedure also updates the item_lot_control_code and the item_serial_control_code to that in the
  --                mtl_system_items table.
  --
  --  History      :
  --  UserID       Date          Comments
  --  -----------  --------      --------------------------
  --   klou       04/25/00      Created.
  --
  --  NOTES:
  --
  --End of Comments
          P_Api_Version_Number            IN   NUMBER
          ,P_Init_Msg_List                IN   VARCHAR2
          ,P_Commit                       IN   VARCHAR2
          ,p_validation_level             IN   NUMBER
          ,p_transaction_temp_id          IN   NUMBER
          ,p_organization_id              IN   NUMBER
          ,x_return_status                OUT NOCOPY  VARCHAR2
          ,x_msg_count                    OUT NOCOPY  NUMBER
          ,x_msg_data                     OUT NOCOPY  VARCHAR2
          )

IS

    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_api_name              CONSTANT VARCHAR2(50) := 'Update_Misc_MMTT';
    l_msg_data                       VARCHAR2(300);
    l_validation_level               NUMBER       := FND_API.G_VALID_LEVEL_NONE;
    l_check_existence                NUMBER       := 0;
    l_return_status                  VARCHAR2(1);
    l_msg_count                      NUMBER      := 0;
    l_commit                         VARCHAR2(1) := FND_API.G_FALSE;
    l_item_serial_control_code       NUMBER;
    l_item_lot_control_code          NUMBER;
    EXCP_USER_DEFINED                EXCEPTION;

    l_csp_mtltxn_rec  CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;

    CURSOR l_ml_records IS
        SELECT TRANSACTION_HEADER_ID            ,
       TRANSACTION_TEMP_ID              ,
       SOURCE_CODE                      ,
       SOURCE_LINE_ID                   ,
       TRANSACTION_MODE                 ,
       LOCK_FLAG                        ,
       LAST_UPDATE_DATE                 ,
       LAST_UPDATED_BY                  ,
       CREATION_DATE                    ,
       CREATED_BY                       ,
       LAST_UPDATE_LOGIN                ,
       REQUEST_ID                       ,
       PROGRAM_APPLICATION_ID           ,
       PROGRAM_ID                       ,
       PROGRAM_UPDATE_DATE              ,
       INVENTORY_ITEM_ID                ,
       REVISION                         ,
       ORGANIZATION_ID                  ,
       SUBINVENTORY_CODE                ,
       LOCATOR_ID                       ,
       TRANSACTION_QUANTITY             ,
       PRIMARY_QUANTITY                 ,
       TRANSACTION_UOM                  ,
       TRANSACTION_COST                 ,
       TRANSACTION_TYPE_ID              ,
       TRANSACTION_ACTION_ID            ,
       TRANSACTION_SOURCE_TYPE_ID       ,
       TRANSACTION_SOURCE_ID            ,
       TRANSACTION_SOURCE_NAME          ,
       TRANSACTION_DATE                 ,
       ACCT_PERIOD_ID                   ,
       DISTRIBUTION_ACCOUNT_ID          ,
       TRANSACTION_REFERENCE            ,
       REQUISITION_LINE_ID              ,
       REQUISITION_DISTRIBUTION_ID      ,
       REASON_ID                        ,
       LOT_NUMBER                       ,
       LOT_EXPIRATION_DATE              ,
       SERIAL_NUMBER                    ,
       RECEIVING_DOCUMENT               ,
       DEMAND_ID                        ,
       RCV_TRANSACTION_ID               ,
       MOVE_TRANSACTION_ID              ,
       COMPLETION_TRANSACTION_ID        ,
       WIP_ENTITY_TYPE                  ,
       SCHEDULE_ID                      ,
       REPETITIVE_LINE_ID               ,
       EMPLOYEE_CODE                    ,
       PRIMARY_SWITCH                   ,
       SCHEDULE_UPDATE_CODE             ,
       SETUP_TEARDOWN_CODE              ,
       ITEM_ORDERING                    ,
       NEGATIVE_REQ_FLAG                ,
       OPERATION_SEQ_NUM                ,
       PICKING_LINE_ID                  ,
       TRX_SOURCE_LINE_ID               ,
       TRX_SOURCE_DELIVERY_ID           ,
       PHYSICAL_ADJUSTMENT_ID           ,
       CYCLE_COUNT_ID                   ,
       RMA_LINE_ID                      ,
       CUSTOMER_SHIP_ID                 ,
       CURRENCY_CODE                    ,
       CURRENCY_CONVERSION_RATE         ,
       CURRENCY_CONVERSION_TYPE         ,
       CURRENCY_CONVERSION_DATE         ,
       USSGL_TRANSACTION_CODE           ,
       VENDOR_LOT_NUMBER                ,
       ENCUMBRANCE_ACCOUNT              ,
       ENCUMBRANCE_AMOUNT               ,
       SHIP_TO_LOCATION                 ,
       SHIPMENT_NUMBER                  ,
       TRANSFER_COST                    ,
       TRANSPORTATION_COST              ,
       TRANSPORTATION_ACCOUNT           ,
       FREIGHT_CODE                    ,
       CONTAINERS                       ,
       WAYBILL_AIRBILL                 ,
       EXPECTED_ARRIVAL_DATE            ,
       TRANSFER_SUBINVENTORY            ,
       TRANSFER_ORGANIZATION            ,
       TRANSFER_TO_LOCATION             ,
       NEW_AVERAGE_COST                 ,
       VALUE_CHANGE                     ,
       PERCENTAGE_CHANGE                ,
       MATERIAL_ALLOCATION_TEMP_ID      ,
       DEMAND_SOURCE_HEADER_ID          ,
       DEMAND_SOURCE_LINE               ,
       DEMAND_SOURCE_DELIVERY           ,
       ITEM_SEGMENTS                   ,
       ITEM_DESCRIPTION                ,
       ITEM_TRX_ENABLED_FLAG            ,
       ITEM_LOCATION_CONTROL_CODE       ,
       ITEM_RESTRICT_SUBINV_CODE        ,
       ITEM_RESTRICT_LOCATORS_CODE      ,
       ITEM_REVISION_QTY_CONTROL_CODE   ,
       ITEM_PRIMARY_UOM_CODE            ,
       ITEM_UOM_CLASS                   ,
       ITEM_SHELF_LIFE_CODE             ,
       ITEM_SHELF_LIFE_DAYS             ,
       ITEM_LOT_CONTROL_CODE            ,
       ITEM_SERIAL_CONTROL_CODE         ,
       ITEM_INVENTORY_ASSET_FLAG        ,
       ALLOWED_UNITS_LOOKUP_CODE        ,
       DEPARTMENT_ID                    ,
       DEPARTMENT_CODE                  ,
       WIP_SUPPLY_TYPE                  ,
       SUPPLY_SUBINVENTORY              ,
       SUPPLY_LOCATOR_ID                ,
       VALID_SUBINVENTORY_FLAG          ,
       VALID_LOCATOR_FLAG               ,
       LOCATOR_SEGMENTS                 ,
       CURRENT_LOCATOR_CONTROL_CODE     ,
       NUMBER_OF_LOTS_ENTERED           ,
       WIP_COMMIT_FLAG                  ,
       NEXT_LOT_NUMBER                  ,
       LOT_ALPHA_PREFIX                 ,
       NEXT_SERIAL_NUMBER               ,
       SERIAL_ALPHA_PREFIX              ,
       SHIPPABLE_FLAG                   ,
       POSTING_FLAG                     ,
       REQUIRED_FLAG                    ,
       PROCESS_FLAG                     ,
       ERROR_CODE                       ,
       ERROR_EXPLANATION                ,
       ATTRIBUTE_CATEGORY               ,
       ATTRIBUTE1                       ,
       ATTRIBUTE2                       ,
       ATTRIBUTE3                       ,
       ATTRIBUTE4                       ,
       ATTRIBUTE5                       ,
       ATTRIBUTE6                       ,
       ATTRIBUTE7                       ,
       ATTRIBUTE8                       ,
       ATTRIBUTE9                       ,
       ATTRIBUTE10                      ,
       ATTRIBUTE11                      ,
       ATTRIBUTE12                      ,
       ATTRIBUTE13                      ,
       ATTRIBUTE14                      ,
       ATTRIBUTE15                      ,
       MOVEMENT_ID                      ,
       RESERVATION_QUANTITY             ,
       SHIPPED_QUANTITY                 ,
       TRANSACTION_LINE_NUMBER          ,
       TASK_ID                          ,
       TO_TASK_ID                       ,
       SOURCE_TASK_ID                   ,
       PROJECT_ID                       ,
       SOURCE_PROJECT_ID                ,
       PA_EXPENDITURE_ORG_ID            ,
       TO_PROJECT_ID                    ,
       EXPENDITURE_TYPE                 ,
       FINAL_COMPLETION_FLAG            ,
       TRANSFER_PERCENTAGE              ,
       TRANSACTION_SEQUENCE_ID          ,
       MATERIAL_ACCOUNT                 ,
       MATERIAL_OVERHEAD_ACCOUNT        ,
       RESOURCE_ACCOUNT                 ,
       OUTSIDE_PROCESSING_ACCOUNT       ,
       OVERHEAD_ACCOUNT                 ,
       FLOW_SCHEDULE                    ,
       COST_GROUP_ID                    ,
       DEMAND_CLASS                     ,
       QA_COLLECTION_ID                 ,
       KANBAN_CARD_ID                   ,
       OVERCOMPLETION_TRANSACTION_ID    ,
       OVERCOMPLETION_PRIMARY_QTY       ,
       OVERCOMPLETION_TRANSACTION_QTY   ,
       --PROCESS_TYPE                     ,  --removed 01/13/00. process_type does not exist in the mmtt table.
       END_ITEM_UNIT_NUMBER             ,
       SCHEDULED_PAYBACK_DATE           ,
       LINE_TYPE_CODE                   ,
       PARENT_TRANSACTION_TEMP_ID       ,
       PUT_AWAY_STRATEGY_ID             ,
       PUT_AWAY_RULE_ID                 ,
       PICK_STRATEGY_ID                 ,
       PICK_RULE_ID                     ,
       COMMON_BOM_SEQ_ID                ,
       COMMON_ROUTING_SEQ_ID            ,
       COST_TYPE_ID                     ,
       ORG_COST_GROUP_ID                ,
       MOVE_ORDER_LINE_ID               ,
       TASK_GROUP_ID                    ,
       PICK_SLIP_NUMBER                 ,
       RESERVATION_ID                   ,
       TRANSACTION_STATUS               ,
       STANDARD_OPERATION_ID            ,
       TASK_PRIORITY                    ,
       -- ADDED by phegde 02/23
       WMS_TASK_TYPE                    ,
       PARENT_LINE_ID
       --SOURCE_LOT_NUMBER
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id  = p_transaction_temp_id
       AND   organization_id = p_organization_id;
BEGIN
    SAVEPOINT Update_Misc_MMTT_PUB;
    x_return_status := fnd_api.g_ret_sts_success;

  -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
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
            IF p_organization_id IS NULL THEN
                 fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
                 fnd_message.set_token ('PARAMETER', 'p_organization_id', TRUE);
                 fnd_msg_pub.add;
                 RAISE EXCP_USER_DEFINED;
             ELSE
                -- check whether the organizaton exists.
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
                        fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                        FND_MSG_PUB.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;
             END IF;
     END IF;

     OPEN l_ml_records;
     FETCH l_ml_records INTO l_csp_mtltxn_rec;

     IF l_ml_records%NOTFOUND THEN
        fnd_message.set_name ('CSP', 'CSP_NO_MO_TXN_RECORD');
        fnd_msg_pub.add;
        CLOSE l_ml_records;
        RAISE EXCP_USER_DEFINED;
     END IF;

     CLOSE l_ml_records;

     l_csp_mtltxn_rec.transaction_source_type_id := 13;   -- Inventory
     l_csp_mtltxn_rec.transaction_type_id        := 2;    -- subinventory transfer type
     l_csp_mtltxn_rec.transaction_action_id      := 2;    -- subinventory tranfer

  -- Check whether the item is under serial control and / or lot control.
     BEGIN
          SELECT nvl(lot_control_code, 1), nvl(serial_number_control_code,1)
          INTO l_item_lot_control_code, l_item_serial_control_code
          FROM MTL_SYSTEM_ITEMS_KFV
          WHERE inventory_item_id = l_csp_mtltxn_rec.inventory_item_id
          AND organization_id = l_csp_mtltxn_rec.organization_id;

          IF nvl(l_csp_mtltxn_rec.item_lot_control_code, 1) <> l_item_lot_control_code
              OR nvl(l_csp_mtltxn_rec.item_serial_control_code, 1) <> l_item_serial_control_code THEN
                l_csp_mtltxn_rec.item_lot_control_code := l_item_lot_control_code;
                l_csp_mtltxn_rec.item_serial_control_code := l_item_serial_control_code;

          END IF;
      END;

     CSP_Material_Transactions_PVT.Update_material_transactions(
              P_Api_Version_Number         => p_api_version_number,
              P_Init_Msg_List              => p_init_msg_list,
              P_Commit                     => fnd_api.g_false,
              p_validation_level           => l_validation_level,
              P_CSP_Rec                    => l_csp_mtltxn_rec,
              X_Return_Status              => l_return_status,
              X_Msg_Count                  => l_msg_count,
              X_Msg_Data                   => l_msg_data);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
     END IF;

    x_return_status := l_return_status;

    IF fnd_api.to_boolean(P_Commit) THEN
        commit work;
    END IF;

EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
             Rollback to Update_Misc_MMTT_PUB;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;
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
                Rollback to Update_Misc_MMTT_PUB;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END Update_Misc_MMTT;


------------------------
  -- Start of Comments
  -- Procedure    : Save_Pick
  -- Purpose      : This procedure saves the headers and lines for the specified
  --                picklist and updates the quantity detailed in mtl_txn_request_lines
  --
  --  History      :
  --  UserID       Date          Comments
  --  -----------  --------      --------------------------
  --   phegde      02/01/2000      Created.
  --
  --  NOTES:
  --
  --End of Comments

  Procedure Save_Pick (
     P_Api_Version_Number           IN   NUMBER
    ,P_Init_Msg_List                IN   VARCHAR2
    ,P_Commit                       IN   VARCHAR2
    ,p_validation_level             IN   NUMBER
    ,p_picklist_header_id           IN   NUMBER
    ,p_organization_id              IN   NUMBER
    ,x_return_status                OUT NOCOPY  VARCHAR2
    ,x_msg_count                    OUT NOCOPY  NUMBER
    ,x_msg_data                     OUT NOCOPY  VARCHAR2
   )

  IS
    l_api_version_number    CONSTANT NUMBER  := 1.0;
    l_api_name              CONSTANT VARCHAR2(30) := 'Save_Pick';
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(500);
    l_commit                VARCHAR2(1) := fnd_api.g_false;
    l_check_existence       NUMBER := 0;
    EXCP_USER_DEFINED       EXCEPTION;

    CURSOR pickline_cur IS
      SELECT sum(quantity_picked) qty_det,
             line_id
      FROM   csp_picklist_lines
      WHERE  picklist_header_id = p_picklist_header_id
      GROUP BY line_id;

    pickline_rec    pickline_cur%ROWTYPE;
    l_trolin_rec    INV_Move_Order_PUB.Trolin_Rec_Type;
  BEGIN
     -- Start of API savepoint
     SAVEPOINT Save_Pick_PUB;
     x_return_status := fnd_api.g_ret_sts_success;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
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

     IF p_organization_id IS NULL THEN
         fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
         fnd_message.set_token ('PARAMETER', 'p_organization_id', TRUE);
         fnd_msg_pub.add;
         RAISE EXCP_USER_DEFINED;
     ELSE
        -- check whether the organizaton exists.
        BEGIN
            SELECT organization_id into l_check_existence
            FROM   mtl_parameters
            WHERE  organization_id = p_organization_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                 FND_MSG_PUB.ADD;
                 RAISE EXCP_USER_DEFINED;
            WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
        END;
     END IF;

     -- get all lines for this picklist_header
     OPEN pickline_cur;

     LOOP
        FETCH pickline_cur INTO pickline_rec;
        EXIT WHEN pickline_cur%NOTFOUND;

        l_trolin_rec := INV_Trolin_util.Query_Row( pickline_rec.line_id );
        l_trolin_rec.quantity_detailed := pickline_rec.qty_det;
        l_trolin_rec.last_update_date := SYSDATE;
        l_trolin_rec.last_updated_by := FND_GLOBAL.USER_ID;
        l_trolin_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

        INV_Trolin_Util.Update_Row(l_trolin_rec);
        commit;

     END LOOP;

     CLOSE pickline_cur;
    x_return_status := fnd_api.G_ret_sts_success;

  EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
             Rollback to Save_Pick_PUB;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;

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
            Rollback to Save_Pick_PUB;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

  END Save_Pick;
  Procedure Issue_Savepoint(p_Savepoint Varchar2) Is
  Begin
	SAVEPOINT p_Savepoint;
  End;
  Procedure Issue_Rollback(p_Savepoint Varchar2) Is
  Begin
	ROLLBACK TO p_Savepoint;
  End;
  Procedure Issue_Commit Is
  Begin
	COMMIT;
  End;
  Function Calculate_Min_Max(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER Is
  Cursor c_Safety_Factor(p_SL Number,p_Exp Number) Is
	  Select SAFETY_FACTOR
	  From   CSP_SAFETY_FACTORS
	  Where  EXPOSURES = p_Exp
	  And    SERVICE_LEVEL = p_SL;

  Cursor c_factor_Minmax Is
	Select MIN(Exposures) , MAX(Exposures)
	From   CSP_SAFETY_FACTORS;

  l_min Number;
  l_max Number;
  l_Safety_factor Number;
  l_Exposures Number := 0;
  l_Safety_Stock Number := 0;
  l_Edq		 Number := 0;
  l_Reorder_Point Number := 0;
  l_Service_Level Number;
  l_Edq_Factor    Number;
  l_Asl_Flag	   Varchar2(1);
  l_Safety_Stock_Flag Varchar2(1);
  Begin
    l_Service_Level := p_Service_Level;
    l_Edq_factor := p_Edq_Factor;
    l_Safety_Stock_Flag := p_Safety_Stock_Flag;
    l_Asl_Flag := p_Asl_Flag;

    G_SERVICE_LEVEL := l_Service_Level;
    G_EDQ_FACTOR    := l_Edq_Factor;
    G_ASL_FLAG := l_Asl_Flag;
    G_SAFETY_STOCK_FLAG := l_Safety_Stock_Flag;
    -- Calculate Edq
	If nvl(p_Item_Cost,0) > 0 Then
	   l_Edq := ROUND(l_Edq_Factor * (SQRT(52 * p_Awu * p_Item_Cost)/p_Item_Cost),4);
	   Else l_Edq := 0;
	End If;
	-- Calculate Exposures
	If nvl(l_Edq,0) > 0 Then
   		l_Exposures := ROUND(p_Awu * 52/l_Edq);
 	  Else l_Exposures := 0;
	End If;
	--- Get Safety Factor
	Open c_Factor_minmax;
	Fetch c_Factor_minmax INTO l_Min,l_max;
	Close c_Factor_minmax;
	If l_Exposures < l_min Then
   		l_Exposures := l_min;
  	 Elsif l_Exposures > l_Max Then
		l_Exposures := l_Max;
	End If;
	Open c_Safety_Factor(l_Service_Level,l_Exposures);
	Fetch c_Safety_Factor INTO l_Safety_Factor;
	Close c_Safety_Factor;
	G_Safety_Factor := l_Safety_factor;
	-- Calculate Safety Stock
	If nvl(l_Safety_Stock_flag,'N') = 'N' Then
	   l_Safety_Stock := 0;
	   Else l_safety_Stock := ROUND(nvl(l_Safety_Factor,0) * nvl(p_Standard_Deviation,0),4);
	End If;
	-- Calculate Reorder Point
	l_Reorder_Point := nvl(p_Awu/7 * p_Lead_Time,0) + nvl(l_Safety_Stock,0);
	-- Calculate Minimum and Maximum Quantities
     G_min_Quantity := ROUND(nvl(l_Reorder_Point,0));
	G_Max_Quantity := ROUND(nvl(l_Reorder_Point,0) + nvl(l_Edq,0));
     G_safety_Stock := l_safety_stock;

-- If max is 0, min must be 0
-- If max > 0, min must be > 0
     if nvl(g_max_quantity,0) = 0 then
       g_min_quantity := 0;
	else
	  g_min_quantity := greatest(g_min_quantity,1);
	end if;

	return 0;
	Exception
	  When OTHERS Then
		  return 1;
  End;

  Function get_min_quantity(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER Is

  Cursor c_Safety_Factor(p_SL Number,p_Exp Number) Is
	  Select SAFETY_FACTOR
	  From   CSP_SAFETY_FACTORS
	  Where  EXPOSURES = p_Exp
	  And    SERVICE_LEVEL = p_SL;

  Cursor c_factor_Minmax Is
	Select MIN(Exposures) , MAX(Exposures)
	From   CSP_SAFETY_FACTORS;

  l_min Number;
  l_max Number;
  l_Safety_factor Number;
  l_Exposures Number := 0;
  l_Safety_Stock Number := 0;
  l_Edq		 Number := 0;
  l_Reorder_Point Number := 0;
  l_Service_Level Number;
  l_Edq_Factor    Number;
  l_Asl_Flag	   Varchar2(1);
  l_Safety_Stock_Flag Varchar2(1);
  Begin
    l_Service_Level := p_Service_Level;
    l_Edq_factor := p_Edq_Factor;
    l_Safety_Stock_Flag := p_Safety_Stock_Flag;
    l_Asl_Flag := p_Asl_Flag;

    -- Calculate Edq
	If nvl(p_Item_Cost,0) > 0 Then
	   l_Edq := ROUND(l_Edq_Factor * (SQRT(52 * p_Awu * p_Item_Cost)/p_Item_Cost),4);
	   Else l_Edq := 0;
	End If;
	-- Calculate Exposures
	If nvl(l_Edq,0) > 0 Then
   		l_Exposures := ROUND(p_Awu * 52/l_Edq);
 	  Else l_Exposures := 0;
	End If;
	--- Get Safety Factor
	Open c_Factor_minmax;
	Fetch c_Factor_minmax INTO l_Min,l_max;
	Close c_Factor_minmax;
	If l_Exposures < l_min Then
   		l_Exposures := l_min;
  	 Elsif l_Exposures > l_Max Then
		l_Exposures := l_Max;
	End If;
	Open c_Safety_Factor(l_Service_Level,l_Exposures);
	Fetch c_Safety_Factor INTO l_Safety_Factor;
	Close c_Safety_Factor;
	G_Safety_Factor := l_Safety_factor;
	-- Calculate Safety Stock
	If nvl(l_Safety_Stock_flag,'N') = 'N' Then
	   l_Safety_Stock := 0;
	   Else l_safety_Stock := ROUND(nvl(l_Safety_Factor,0) * nvl(p_Standard_Deviation,0),4);
	End If;
	-- Calculate Reorder Point
	l_Reorder_Point := nvl(p_Awu/7 * p_Lead_Time,0) + nvl(l_Safety_Stock,0);
	-- Calculate Minimum and Maximum Quantities
     G_min_Quantity := ROUND(nvl(l_Reorder_Point,0));
     G_Max_Quantity := ROUND(nvl(l_Reorder_Point,0) + nvl(l_Edq,0));
     G_safety_Stock := l_safety_stock;

-- If max is 0, min must be 0
-- If max > 0, min must be > 0
     if nvl(g_max_quantity,0) = 0 then
       g_min_quantity := 0;
	else
	  g_min_quantity := greatest(g_min_quantity,1);
	end if;

	return g_min_quantity;
	Exception
	  When OTHERS Then
		  return g_min_quantity;
end;

  Function get_max_quantity(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER Is

  Cursor c_Safety_Factor(p_SL Number,p_Exp Number) Is
	  Select SAFETY_FACTOR
	  From   CSP_SAFETY_FACTORS
	  Where  EXPOSURES = p_Exp
	  And    SERVICE_LEVEL = p_SL;

  Cursor c_factor_Minmax Is
	Select MIN(Exposures) , MAX(Exposures)
	From   CSP_SAFETY_FACTORS;

  l_min Number;
  l_max Number;
  l_Safety_factor Number;
  l_Exposures Number := 0;
  l_Safety_Stock Number := 0;
  l_Edq		 Number := 0;
  l_Reorder_Point Number := 0;
  l_Service_Level Number;
  l_Edq_Factor    Number;
  l_Asl_Flag	   Varchar2(1);
  l_Safety_Stock_Flag Varchar2(1);
  Begin
    l_Service_Level := p_Service_Level;
    l_Edq_factor := p_Edq_Factor;
    l_Safety_Stock_Flag := p_Safety_Stock_Flag;
    l_Asl_Flag := p_Asl_Flag;

    -- Calculate Edq
	If nvl(p_Item_Cost,0) > 0 Then
	   l_Edq := ROUND(l_Edq_Factor * (SQRT(52 * p_Awu * p_Item_Cost)/p_Item_Cost),4);
	   Else l_Edq := 0;
	End If;
	-- Calculate Exposures
	If nvl(l_Edq,0) > 0 Then
   		l_Exposures := ROUND(p_Awu * 52/l_Edq);
 	  Else l_Exposures := 0;
	End If;
	--- Get Safety Factor
	Open c_Factor_minmax;
	Fetch c_Factor_minmax INTO l_Min,l_max;
	Close c_Factor_minmax;
	If l_Exposures < l_min Then
   		l_Exposures := l_min;
  	 Elsif l_Exposures > l_Max Then
		l_Exposures := l_Max;
	End If;
	Open c_Safety_Factor(l_Service_Level,l_Exposures);
	Fetch c_Safety_Factor INTO l_Safety_Factor;
	Close c_Safety_Factor;
	G_Safety_Factor := l_Safety_factor;
	-- Calculate Safety Stock
	If nvl(l_Safety_Stock_flag,'N') = 'N' Then
	   l_Safety_Stock := 0;
	   Else l_safety_Stock := ROUND(nvl(l_Safety_Factor,0) * nvl(p_Standard_Deviation,0),4);
	End If;
	-- Calculate Reorder Point
	l_Reorder_Point := nvl(p_Awu/7 * p_Lead_Time,0) + nvl(l_Safety_Stock,0);
	-- Calculate Minimum and Maximum Quantities
     G_min_Quantity := ROUND(nvl(l_Reorder_Point,0));
     G_Max_Quantity := ROUND(nvl(l_Reorder_Point,0) + nvl(l_Edq,0));
     G_safety_Stock := l_safety_stock;

-- If max is 0, min must be 0
-- If max > 0, min must be > 0
     if nvl(g_max_quantity,0) = 0 then
       g_min_quantity := 0;
	else
	  g_min_quantity := greatest(g_min_quantity,1);
	end if;

	return g_max_quantity;
	Exception
	  When OTHERS Then
		  return g_max_quantity;
end;

  Function Get_SAFETY_FACTOR(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER Is

  Cursor c_Safety_Factor(p_SL Number,p_Exp Number) Is
	  Select SAFETY_FACTOR
	  From   CSP_SAFETY_FACTORS
	  Where  EXPOSURES = p_Exp
	  And    SERVICE_LEVEL = p_SL;

  Cursor c_factor_Minmax Is
	Select MIN(Exposures) , MAX(Exposures)
	From   CSP_SAFETY_FACTORS;

  l_min Number;
  l_max Number;
  l_Safety_factor Number;
  l_Exposures Number := 0;
  l_Safety_Stock Number := 0;
  l_Edq		 Number := 0;
  l_Reorder_Point Number := 0;
  l_Service_Level Number;
  l_Edq_Factor    Number;
  l_Asl_Flag	   Varchar2(1);
  l_Safety_Stock_Flag Varchar2(1);
  Begin
    l_Service_Level := p_Service_Level;
    l_Edq_factor := p_Edq_Factor;
    l_Safety_Stock_Flag := p_Safety_Stock_Flag;
    l_Asl_Flag := p_Asl_Flag;

    -- Calculate Edq
	If nvl(p_Item_Cost,0) > 0 Then
	   l_Edq := ROUND(l_Edq_Factor * (SQRT(52 * p_Awu * p_Item_Cost)/p_Item_Cost),4);
	   Else l_Edq := 0;
	End If;
	-- Calculate Exposures
	If nvl(l_Edq,0) > 0 Then
   		l_Exposures := ROUND(p_Awu * 52/l_Edq);
 	  Else l_Exposures := 0;
	End If;
	--- Get Safety Factor
	Open c_Factor_minmax;
	Fetch c_Factor_minmax INTO l_Min,l_max;
	Close c_Factor_minmax;
	If l_Exposures < l_min Then
   		l_Exposures := l_min;
  	 Elsif l_Exposures > l_Max Then
		l_Exposures := l_Max;
	End If;
	Open c_Safety_Factor(l_Service_Level,l_Exposures);
	Fetch c_Safety_Factor INTO l_Safety_Factor;
	Close c_Safety_Factor;
	G_Safety_Factor := l_Safety_factor;

	return G_SAFETY_FACTOR;
	Exception
	  When OTHERS Then
		  return G_SAFETY_FACTOR;
  End;

  Function Get_SAFETY_STOCK(p_Subinventory Varchar2,
					    p_Organization_Id Number,
					    p_Edq_factor Number,
					    p_Service_Level Number,
					    p_Item_Cost Number,
					    p_Awu Number,
					    p_Lead_time Number,
					    p_Standard_Deviation Number,
					    p_Safety_Stock_Flag Varchar2,
					    p_Asl_Flag Varchar2) RETURN NUMBER Is
  Cursor c_Safety_Factor(p_SL Number,p_Exp Number) Is
	  Select SAFETY_FACTOR
	  From   CSP_SAFETY_FACTORS
	  Where  EXPOSURES = p_Exp
	  And    SERVICE_LEVEL = p_SL;

  Cursor c_factor_Minmax Is
	Select MIN(Exposures) , MAX(Exposures)
	From   CSP_SAFETY_FACTORS;

  l_min Number;
  l_max Number;
  l_Safety_factor Number;
  l_Exposures Number := 0;
  l_Safety_Stock Number := 0;
  l_Edq		 Number := 0;
  l_Reorder_Point Number := 0;
  l_Service_Level Number;
  l_Edq_Factor    Number;
  l_Asl_Flag	   Varchar2(1);
  l_Safety_Stock_Flag Varchar2(1);
  Begin
    l_Service_Level := p_Service_Level;
    l_Edq_factor := p_Edq_Factor;
    l_Safety_Stock_Flag := p_Safety_Stock_Flag;
    l_Asl_Flag := p_Asl_Flag;

    G_SERVICE_LEVEL := l_Service_Level;
    G_EDQ_FACTOR    := l_Edq_Factor;
    G_ASL_FLAG := l_Asl_Flag;
    G_SAFETY_STOCK_FLAG := l_Safety_Stock_Flag;
    -- Calculate Edq
	If nvl(p_Item_Cost,0) > 0 Then
	   l_Edq := ROUND(l_Edq_Factor * (SQRT(52 * p_Awu * p_Item_Cost)/p_Item_Cost),4);
	   Else l_Edq := 0;
	End If;
	-- Calculate Exposures
	If nvl(l_Edq,0) > 0 Then
   		l_Exposures := ROUND(p_Awu * 52/l_Edq);
 	  Else l_Exposures := 0;
	End If;
	--- Get Safety Factor
	Open c_Factor_minmax;
	Fetch c_Factor_minmax INTO l_Min,l_max;
	Close c_Factor_minmax;
	If l_Exposures < l_min Then
   		l_Exposures := l_min;
  	 Elsif l_Exposures > l_Max Then
		l_Exposures := l_Max;
	End If;
	Open c_Safety_Factor(l_Service_Level,l_Exposures);
	Fetch c_Safety_Factor INTO l_Safety_Factor;
	Close c_Safety_Factor;
	G_Safety_Factor := l_Safety_factor;
	-- Calculate Safety Stock
	If nvl(l_Safety_Stock_flag,'N') = 'N' Then
	   l_Safety_Stock := 0;
	   Else l_safety_Stock := ROUND(nvl(l_Safety_Factor,0) * nvl(p_Standard_Deviation,0),4);
	End If;

    G_safety_Stock := l_safety_stock;

	return G_SAFETY_STOCK;
	Exception
	  When OTHERS Then
		  return G_SAFETY_STOCK;
  End;

FUNCTION Get_Service_Level RETURN NUMBER Is
Begin
  return (G_SERVICE_LEVEL);
End;

FUNCTION Get_EDQ_FACTOR RETURN NUMBER Is
Begin
  Return(G_EDQ_FACTOR);
End;
FUNCTION Get_SAFETY_STOCK_FLAG RETURN Varchar2 Is
Begin
  Return(G_SAFETY_STOCK_FLAG);
End;
FUNCTION Get_ASL_FLAG RETURN Varchar2 Is
Begin
  Return(G_ASL_FLAG);
End;

-- get the name of an object using its definition in JTF_OBJETCS
FUNCTION get_object_name
( p_object_type_code in varchar2
, p_object_id        in number
) return varchar2
IS
  cursor c_ref is
    select   select_id
    ,        select_name
    ,        from_table
    ,        where_clause
    from     jtf_objects_vl
    where    object_code = p_object_type_code;
  l_rec  c_ref%rowtype;
  -- max data from jtf_objects_vl can be about 2600
  l_stmt varchar2(3000);
  -- highest max col length found in dom1151 = 421
  l_name varchar2(500) := null;
BEGIN
  open c_ref;
  fetch c_ref into l_rec;
  if c_ref%notfound then
    close c_ref;
    return null;
  end if;
  close c_ref;
  l_stmt :=
    'SELECT '||l_rec.select_name||' FROM '||l_rec.from_table||' WHERE ';
  if l_rec.where_clause is not null then
    l_stmt := l_stmt||l_rec.where_clause||' AND ';
  end if;
  l_stmt := l_stmt||l_rec.select_id||' = :object_id';
  execute immediate l_stmt into l_name using p_object_id;
  return l_name;
EXCEPTION
  when others then
    return null;
END get_object_name;
FUNCTION get_object_Type_meaning(p_object_type_code varchar2) return varchar2
IS
    CURSOR csp_object_type is
     select Name
     from JTF_OBJECTS_VL
     where OBJECT_CODE =p_object_type_code;

     l_object_type_name varchar2(200);

BEGIN
    l_object_type_name := null;
    open csp_object_type;
    FETCH csp_object_type INTO l_object_type_name;
    CLOSE csp_object_type;
    return l_object_type_name;

END get_object_Type_meaning;
FUNCTION get_ret_sts_success return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_success;
END get_ret_sts_success;

FUNCTION get_ret_sts_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_error;
END get_ret_sts_error;

FUNCTION get_ret_sts_unexp_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_unexp_error;
END get_ret_sts_unexp_error;

FUNCTION get_true return varchar2
IS
BEGIN
  return fnd_api.g_true;
END get_true;

FUNCTION get_false return varchar2
IS
BEGIN
  return fnd_api.g_false;
END get_false;

Function get_rs_cust_sequence return number
IS
l_sequence_number NUMBER;
BEGIN
    SELECT CSP_RS_CUST_RELATIONS_s1.nextval into l_sequence_number from dual;
    return l_sequence_number;
END get_rs_cust_sequence;

FUNCTION get_assignment(p_task_id number)
         return date IS
  cursor c_minutes is
  SELECT fnd_profile.value('CSF_UOM_MINUTES') minutes
  FROM   dual;

  cursor c_task_assignment is
  select jta.last_update_date,
         jta.task_assignment_id,
         jta.resource_id,
         jta.resource_type_code,
         nvl(jta.sched_travel_distance,0) sched_travel_distance,
         nvl(jta.sched_travel_duration,0) sched_travel_duration,
         jta.sched_travel_duration_uom,
         nvl(jta.actual_travel_distance,0) actual_travel_distance,
         nvl(jta.actual_travel_duration,0) actual_travel_duration,
         jta.actual_travel_duration_uom
  from   jtf_task_assignments jta
  where  jta.task_id = p_task_id
  order by jta.task_assignment_id desc,
           jta.resource_type_code,
           jta.resource_id;

  l_sched_travel_duration  number;
  l_actual_travel_duration number;

BEGIN
  G_LAST_UPDATE_DATE       := null;
  G_TASK_ASSIGNMENT_ID     := null;
  G_RESOURCE_NAME          := null;
  G_SCHED_TRAVEL_DISTANCE  := null;
  G_SCHED_TRAVEL_DURATION  := null;
  G_ACTUAL_TRAVEL_DISTANCE := null;
  G_ACTUAL_TRAVEL_DURATION := null;

  if G_MINUTES is null then
    open  c_minutes;
    fetch c_minutes into G_MINUTES;
    close c_minutes;
  end if;

  for cr in c_task_assignment loop
    G_LAST_UPDATE_DATE := greatest(G_LAST_UPDATE_DATE,cr.last_update_date);
    if G_TASK_ASSIGNMENT_ID is null then
      G_TASK_ASSIGNMENT_ID := cr.task_assignment_id;
    end if;
    if G_RESOURCE_NAME is not null then
      G_RESOURCE_CODE := G_RESOURCE_CODE||fnd_global.local_chr(127)||
        cr.resource_type_code||cr.resource_id;
      G_RESOURCE_NAME :=
        G_RESOURCE_NAME||fnd_global.local_chr(127)||
        csp_pick_utils.get_object_name(cr.resource_type_code,cr.resource_id);
    else
      G_RESOURCE_CODE := cr.resource_type_code||cr.resource_id;
      G_RESOURCE_NAME :=
        csp_pick_utils.get_object_name(cr.resource_type_code,cr.resource_id);
    end if;
    G_SCHED_TRAVEL_DISTANCE := nvl(G_SCHED_TRAVEL_DISTANCE,0) +
                               cr.sched_travel_distance;
    G_ACTUAL_TRAVEL_DISTANCE := nvl(G_ACTUAL_TRAVEL_DISTANCE,0) +
                               cr.actual_travel_distance;

    l_sched_travel_duration := null;
    if cr.sched_travel_duration is not null then
      l_sched_travel_duration :=
        inv_convert.inv_um_convert(NULL,0,cr.sched_travel_duration,
                                   cr.sched_travel_duration_uom,
                                   G_MINUTES,NULL,NULL);
      if l_sched_travel_duration = -99999 then
        l_sched_travel_duration := null;
      end if;
    end if;
    if l_sched_travel_duration is not null then
      G_SCHED_TRAVEL_DURATION := nvl(G_SCHED_TRAVEL_DURATION,0) +
                                 l_sched_travel_duration;
    end if;

    l_actual_travel_duration := null;
    if cr.actual_travel_duration is not null then
      l_actual_travel_duration :=
        inv_convert.inv_um_convert(NULL,0,cr.actual_travel_duration,
                                   cr.actual_travel_duration_uom,
                                   G_MINUTES,NULL,NULL);
      if l_actual_travel_duration = -99999 then
        l_actual_travel_duration := null;
      end if;
    end if;
    if l_actual_travel_duration is not null then
      G_ACTUAL_TRAVEL_DURATION := nvl(G_ACTUAL_TRAVEL_DURATION,0) +
                                 l_actual_travel_duration;
    end if;

  end loop;
  return G_LAST_UPDATE_DATE;
END;

FUNCTION get_order_status(p_order_line_id     NUMBER,
                          p_flow_status_code  VARCHAR2)
         return varchar2 IS
  l_status              VARCHAR2(240) := NULL;
  l_released_count      NUMBER;
  l_total_count         NUMBER;
  l_backorder_flag      VARCHAR2(100);
  l_backorder_meaning   VARCHAR2(240);

  CURSOR backorder IS
    SELECT pick_status,pick_meaning
    FROM   wsh_delivery_line_status_v
    WHERE  source_line_id = p_order_line_id;

  CURSOR waybill_cur IS
    SELECT distinct waybill,
               name
    FROM wsh_new_deliveries wnd,
         wsh_delivery_Assignments wda,
         wsh_delivery_details wdd
    WHERE wnd.delivery_id = wda.delivery_id
    AND   wdd.delivery_detail_id = wda.delivery_Detail_id
    AND   wdd.source_line_id = p_order_line_id
    AND wdd.source_code = 'OE';

  CURSOR qty_received_cur IS
    SELECT rsl.shipment_line_status_code,
        SUM(rsl.quantity_received),
        rsl.unit_of_measure,
        MAX(mmt.transaction_date) received_date
      FROM po_Requisition_lines_all prl,
        oe_order_lines_all oola,
        rcv_shipment_lines rsl,
        (SELECT transaction_date,
          transaction_source_id
        FROM mtl_material_transactions
        WHERE transaction_source_type_id IN (3, 7)
        AND transaction_action_id         = 12
        ) mmt
      WHERE prl.requisition_line_id     = rsl.requisition_line_id
      AND oola.source_document_line_id  = prl.requisition_line_id
      AND oola.source_document_type_id  = 10
      AND oola.line_id                  = p_order_line_id
      AND mmt.transaction_source_id (+) = oola.source_document_id
      GROUP BY oola.line_id,rsl.shipment_line_status_code,rsl.unit_of_measure;

BEGIN
    l_status := p_flow_status_code;
    G_DELIVERY_NUMBER     := NULL;
    G_WAYBILL             := NULL ;
    G_RECEIVED_QTY        := NULL ;
    G_RECEIVED_QTY_UOM    := NULL ;
    G_RECEIVED_DATE       := NULL ;
    G_STATUS_MEANING      := NULL;

    OPEN waybill_cur;
    FETCH waybill_cur INTO G_WAYBILL, G_DELIVERY_NUMBER;
    IF waybill_cur%NOTFOUND THEN
      null;
    END IF;
    CLOSE waybill_cur;
	--	begin

    OPEN qty_received_cur;
    FETCH qty_received_cur
    INTO l_status, G_RECEIVED_QTY, G_RECEIVED_QTY_UOM,G_RECEIVED_DATE;
    IF qty_received_cur%NOTFOUND THEN
      null;
    END IF;
    CLOSE qty_received_cur;

    IF l_status <> 'FULLY RECEIVED' THEN
      G_RECEIVED_DATE := null;
    END IF;

    OPEN  backorder;
    FETCH backorder into l_backorder_flag,l_backorder_meaning;
    CLOSE backorder;

    IF l_backorder_flag = 'B' THEN
      G_STATUS_MEANING := l_backorder_meaning;
      l_status := l_backorder_flag;
    ELSIF (p_flow_status_code IN ('SHIPPED', 'CLOSED')) THEN
      BEGIN

        SELECT meaning
        INTO G_STATUS_MEANING
        FROM FND_LOOKUP_VALUES LV
        WHERE lookup_type = 'SHIPMENT LINE STATUS'
        AND lookup_code = l_status
        AND LANGUAGE = USERENV('LANG')
        AND VIEW_APPLICATION_ID = 201
        AND SECURITY_GROUP_ID = fnd_global.lookup_security_group(LV.LOOKUP_TYPE,
                                    LV.VIEW_APPLICATION_ID);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_status := p_flow_status_code;
          SELECT meaning
          INTO G_STATUS_MEANING
          FROM fnd_lookup_values lv
          WHERE lookup_type = 'LINE_FLOW_STATUS'
          AND lookup_code = p_flow_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660
          AND SECURITY_GROUP_ID = fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                                 lv.view_application_id);
        WHEN OTHERS THEN
          null;
      END;

    ELSIF (p_flow_status_code <> 'AWAITING_SHIPPING' AND
	    p_flow_status_code <> 'PRODUCTION_COMPLETE') THEN

          l_status := p_flow_status_code;

          SELECT meaning
          INTO G_STATUS_MEANING
          FROM fnd_lookup_values lv
          WHERE lookup_type = 'LINE_FLOW_STATUS'
          AND lookup_code = p_flow_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660
          AND SECURITY_GROUP_ID = fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                                   lv.view_application_id);
       /* status is AWAITING_SHIPPING or PRODUCTION_COMPLETE, get value from
 * shipping table */
    ELSE
		l_status := p_flow_status_code;

          SELECT sum(decode(released_status, 'Y', 1, 0)), sum(1)
          INTO l_released_count, l_total_count
          FROM wsh_delivery_details
          WHERE source_line_id = p_order_line_id
          AND source_code = 'OE';

          IF l_released_count = l_total_count THEN
           l_status := 'PICKED';
           SELECT meaning
           INTO G_STATUS_MEANING
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID = fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                                    lv.view_application_id);
          ELSIF l_released_count < l_total_count and l_released_count <> 0 THEN
           l_status := 'PICKED_PARTIAL';
           SELECT meaning
           INTO G_STATUS_MEANING
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED_PARTIAL'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID = fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                                    lv.view_application_id);
          ELSE
           SELECT meaning
           INTO G_STATUS_MEANING
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = l_status
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID = fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                                    lv.view_application_id);
          END IF;
    END IF;
    RETURN(l_status);
END;

FUNCTION get_attribute_value(p_attribute_name VARCHAR2) return VARCHAR2 IS
BEGIN
  IF p_attribute_name = 'DELIVERY_NUMBER' THEN
    RETURN(G_DELIVERY_NUMBER);
  ELSIF p_attribute_name = 'WAYBILL' THEN
    RETURN (G_WAYBILL);
  ELSIF p_Attribute_name = 'RECEIVED_QTY_UOM' THEN
    RETURN (G_RECEIVED_QTY_UOM);
  ELSIF p_attribute_name = 'STATUS_MEANING' THEN
    RETURN (G_STATUS_MEANING);
  ELSIF p_Attribute_name = 'RECEIVED_DATE' THEN
    RETURN (TO_CHAR(G_RECEIVED_DATE,'DDMMRRRRHH24MISS'));
  ELSIF p_attribute_name = 'TASK_ASSIGNMENT_ID' THEN
    RETURN (G_TASK_ASSIGNMENT_ID);
  ELSIF p_attribute_name = 'RESOURCE_NAME' THEN
    RETURN (G_RESOURCE_NAME);
  ELSIF p_attribute_name = 'RESOURCE_CODE' THEN
    RETURN (G_RESOURCE_CODE);
  ELSIF p_attribute_name = 'SCHED_TRAVEL_DISTANCE' THEN
    RETURN (G_SCHED_TRAVEL_DISTANCE);
  ELSIF p_attribute_name = 'SCHED_TRAVEL_DURATION' THEN
    RETURN (G_SCHED_TRAVEL_DURATION);
  ELSIF p_attribute_name = 'ACTUAL_TRAVEL_DISTANCE' THEN
    RETURN (G_ACTUAL_TRAVEL_DISTANCE);
  ELSIF p_attribute_name = 'ACTUAL_TRAVEL_DURATION' THEN
    RETURN (G_ACTUAL_TRAVEL_DURATION);
  ELSIF p_attribute_name = 'MINUTES' THEN
    RETURN (G_MINUTES);
  ELSIF p_attribute_name = 'LAST_UPDATE_DATE' THEN
    RETURN (G_LAST_UPDATE_DATE);
  END IF;
END;

FUNCTION get_received_qty RETURN NUMBER IS
Begin
  Return(G_RECEIVED_QTY);
End;

FUNCTION get_adjusted_date(p_source_tz_id   NUMBER,
                           p_dest_tz_id     NUMBER,
                           p_source_day_time DATE) RETURN DATE IS
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(500);
l_dest_day_time         DATE;
BEGIN
  IF ((nvl(fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'), 'N') = 'Y') AND
       p_source_tz_id <> p_dest_tz_id) THEN
    HZ_TIMEZONE_PUB.Get_Time(p_api_version    => 1.0,
                           p_init_msg_list  => 'F',
                           p_source_tz_id   => p_source_tz_id,
                           p_dest_tz_id     => p_dest_tz_id,
                           p_source_day_time=> p_source_day_time,
                           x_dest_day_time  => l_dest_day_time,
                           x_return_status  => l_return_status ,
                           x_msg_count      => l_msg_count ,
                           x_msg_data       => l_msg_data);
  ELSE
    l_dest_day_time := p_source_day_time;
  END IF;

  return(l_dest_day_time);
END;
Function get_contact_info(p_incident_id NUMBER) return varchar2 IS
    l_contact varchar2(2000);
    cursor get_contact is
    select CONTACT_COMM_PREF,CONTACT_NAME
    from csf_po_contact_points_v
    where INCIDENT_ID = p_incident_id;
begin
  g_contact_name := NULL;

  OPEN get_contact;
  FETCH get_contact INTO l_contact,g_contact_name;
  CLOSE get_contact;
  return l_contact;
END;

FUNCTION get_contact_name RETURN varchar2 IS
Begin
  Return(G_contact_name);
End;

FUNCTION get_line_status_meaning(
      p_line_id     NUMBER,
      p_booked_flag VARCHAR2,
      p_flow_status_code VARCHAR2,
      p_lookup_type VARCHAR2 DEFAULT 'LINE_FLOW_STATUS'
    )
    RETURN VARCHAR2
  IS
    x_status VARCHAR2(4000);
CURSOR c_default_status(v_lookup_type varchar2,v_lookup_code varchar2) is
     SELECT meaning
      FROM fnd_lookup_values lv
      WHERE lookup_type       = v_lookup_type
      AND lookup_code         = v_lookup_code
      And Language            = 'US'
      And View_Application_Id = 660;

    CURSOR c_status_meaning(v_line_id NUMBER)
    IS
      SELECT pick_meaning
      FROM WSH_DELIVERY_LINE_STATUS_V
      WHERE source_line_id = v_line_id;

    CURSOR ship_code_cur(v_line_id NUMBER) IS
     SELECT fl.meaning
     FROM po_Requisition_lines_all prl,
          oe_order_lines_all oola,
          rcv_shipment_lines rsl,
	  FND_LOOKUP_VALUES fl
     WHERE prl.requisition_line_id = rsl.requisition_line_id
     AND oola.source_document_line_id = prl.requisition_line_id
     AND oola.source_document_type_id = 10
     AND oola.line_id = v_line_id
     AND fl.lookup_type = 'SHIPMENT LINE STATUS'
     AND fl.lookup_code = rsl.shipment_line_status_code
     AND fl.LANGUAGE = USERENV('LANG')
     AND fl.VIEW_APPLICATION_ID = 201;

  TYPE c_status_meaning_type IS  TABLE OF c_status_meaning%ROWTYPE;
  rec_status c_status_meaning_type;

  TYPE ship_code_cur_type IS  TABLE OF ship_code_cur%ROWTYPE;
  ship_status ship_code_cur_type;
  v_counter NUMBER :=0;
BEGIN
  IF p_booked_flag = 'Y' THEN
    IF (p_flow_status_code IN ('SHIPPED', 'CLOSED')) THEN
      OPEN ship_code_cur(p_line_id);
      FETCH ship_code_cur BULK COLLECT INTO ship_status;
      CLOSE ship_code_cur;
      IF ship_status.COUNT > 0 THEN
           FOR i IN 1..ship_status.COUNT
          LOOP
            x_status     := x_status || ship_status(i).meaning;
            v_counter    := v_counter + 1;
            IF v_counter <> ship_status.COUNT THEN
              x_status   := x_status || ',';
            END IF;
            END LOOP;
      ELSE
      SELECT meaning
          INTO x_status
          FROM fnd_lookup_values lv
          WHERE lookup_type = p_lookup_type
          AND lookup_code = p_flow_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660;
      END IF;
    ELSE
      OPEN c_status_meaning(p_line_id);
      FETCH c_status_meaning BULK COLLECT INTO rec_status;
      CLOSE c_status_meaning;
      IF (rec_status.COUNT > 0) THEN
      FOR i IN 1..rec_status.COUNT
      LOOP
          x_status     := x_status || rec_status(i).pick_meaning;
          v_counter    := v_counter + 1;
          IF v_counter <> rec_status.COUNT THEN
            x_status   := x_status || ',';
          END IF;
        END LOOP;
      ELSE
          Open c_default_status(P_Lookup_Type,P_Flow_Status_Code);
          Fetch c_default_status Into X_Status;
          close c_default_status;
      END IF;
    END IF;
  ELSE
          Open c_default_status(P_Lookup_Type,P_Flow_Status_Code);
          Fetch c_default_status Into X_Status;
          close c_default_status;
  END IF;
  RETURN x_status;
END get_line_status_meaning;

END;  -- End of Package

/
