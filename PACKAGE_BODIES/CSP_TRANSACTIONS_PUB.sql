--------------------------------------------------------
--  DDL for Package Body CSP_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TRANSACTIONS_PUB" AS
/*$Header: csppttnb.pls 120.6.12010000.44 2014/04/03 09:27:33 htank ship $*/


G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'CSP_TRANSACTIONS_PUB';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'csppttnb.pls';

-- Start of comments
--
-- Procedure Name   : create_move_order_header
-- Description      : Creates a move order header
-- Business Rules   :
-- Parameters       :
-- Version          : 1.0
-- End of comments

procedure cancel_move_order_header(
  p_header_id         in  number,
  x_return_status   OUT NOCOPY varchar2,
  x_msg_count       OUT NOCOPY number,
  x_msg_data        OUT NOCOPY varchar2) is

begin
    inv_mo_admin_pub.Close_Order(
			p_api_version  	   => 1.0,
			p_init_msg_list	   => fnd_api.g_false,
			p_commit           => fnd_api.g_false,
            p_validation_level => fnd_api.g_valid_level_full,
			p_header_Id	       => p_header_id,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            x_return_status       => x_return_status);
end cancel_move_order_header;

procedure cancel_move_order_line(
  p_line_id         in  number,
  x_return_status   OUT NOCOPY varchar2,
  x_msg_count       OUT NOCOPY number,
  x_msg_data        OUT NOCOPY varchar2) is

  l_quantity_delivered  number;
  l_mo_header_id number;
  l_other_line_id number;

  cursor c_quantity_delivered is
  select quantity_delivered
  from   mtl_txn_request_lines
  where  line_id = p_line_id;

begin

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.cancel_move_order_line',
					  'Begin');
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.cancel_move_order_line',
					  'p_line_id = ' || p_line_id);
	end if;

  open  c_quantity_delivered;
  fetch c_quantity_delivered into l_quantity_delivered;
  close c_quantity_delivered;

  l_quantity_delivered := nvl(l_quantity_delivered,0);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.cancel_move_order_line',
					  'l_quantity_delivered = ' || l_quantity_delivered);
	end if;

  if l_quantity_delivered = 0 then
    inv_mo_admin_pub.cancel_line(
      p_api_version         => 1.0,
      p_init_msg_list	    => fnd_api.g_false,
      p_commit              => fnd_api.g_true,
      p_validation_level    => fnd_api.g_valid_level_full,
      p_line_id             => p_line_id,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_return_status       => x_return_status);
  else
    inv_mo_admin_pub.close_line(
      p_api_version         => 1.0,
      p_init_msg_list	    => fnd_api.g_false,
      p_commit              => fnd_api.g_false,
      p_validation_level    => fnd_api.g_valid_level_full,
      p_line_id             => p_line_id,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_return_status       => x_return_status);
  end if;

  if x_return_status = 'S' then
    l_other_line_id := 0;

    select header_id
    into l_mo_header_id
    from MTL_TXN_REQUEST_lines
    where line_id = p_line_id;

    select count(line_id )
    into l_other_line_id
    from MTL_TXN_REQUEST_lines
    where header_id = l_mo_header_id
    and line_id <> p_line_id;

    if l_other_line_id = 0 then
      cancel_move_order_header(
          p_header_id => l_mo_header_id,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_return_status       => x_return_status);

      if x_return_status = 'S' then
        commit;
      end if;
    end if;
  end if;

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
            'csp.plsql.CSP_TRANSACTIONS_PUB.cancel_move_order_line',
            'x_return_status = ' || x_return_status
            || ', x_msg_count = ' || x_msg_count
            || ', x_msg_data = ' || x_msg_data);
  end if;

end cancel_move_order_line;

procedure reject_move_order_line(
  p_line_id         in  number,
  x_return_status   OUT NOCOPY varchar2,
  x_msg_count       OUT NOCOPY number,
  x_msg_data        OUT NOCOPY varchar2) is

  l_header_id       number;
  l_trolin_tbl      inv_move_order_pub.Trolin_Tbl_Type;
  l_trolin_old_tbl  inv_move_order_pub.trolin_tbl_type;
  x_trolin_tbl      inv_move_order_pub.trolin_tbl_type;

  cursor c_header_id is
  select header_id
  from   mtl_txn_request_lines
  where  line_id = p_line_id;

begin
  open  c_header_id;
  fetch c_header_id into l_header_id;
  close c_header_id;

  l_trolin_tbl(1).line_status := 9;
  l_trolin_tbl(1).header_id  := l_header_id;
  l_trolin_tbl(1).line_id  := p_line_id;
  l_trolin_tbl(1).operation  := inv_globals.g_opr_update;

  inv_move_order_pub.process_move_order_line(
        p_api_version_number => 1.0
    ,   x_return_status      => x_return_status
    ,   x_msg_count          => x_msg_count
    ,   x_msg_data           => x_msg_data
    ,   p_trolin_tbl         => l_trolin_tbl
    ,   p_trolin_old_tbl     => l_trolin_old_tbl
    ,   x_trolin_tbl         => x_trolin_tbl);

end reject_move_order_line;
PROCEDURE CREATE_MOVE_ORDER_HEADER
  (px_header_id             IN OUT NOCOPY NUMBER
  ,p_request_number         IN VARCHAR2
  ,p_api_version            IN NUMBER
  ,p_Init_Msg_List          IN VARCHAR2
  ,p_commit                 IN VARCHAR2
  ,p_date_required          IN DATE
  ,p_organization_id        IN NUMBER
  ,p_from_subinventory_code IN VARCHAR2
  ,p_to_subinventory_code   IN VARCHAR2
  ,p_address1               IN VARCHAR2
  ,p_address2               IN VARCHAR2
  ,p_address3               IN VARCHAR2
  ,p_address4               IN VARCHAR2
  ,p_city                   IN VARCHAR2
  ,p_postal_code            IN VARCHAR2
  ,p_state                  IN VARCHAR2
  ,p_province               IN VARCHAR2
  ,p_country                IN VARCHAR2
  ,p_freight_carrier        IN VARCHAR2
  ,p_shipment_method        IN VARCHAR2
  ,p_autoreceipt_flag       IN VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

l_mohdr_rec             INV_Move_Order_PUB.Trohdr_Rec_Type;
l_mohdr_val_rec         INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
l_header_id             number;

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Move_Order_Header';
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_commit                VARCHAR2(1) := FND_API.G_FALSE;
EXCP_USER_DEFINED      EXCEPTION;

BEGIN
  SAVEPOINT Create_Move_Order_Header_PUB;

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    -- initialize message list
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check organization
  IF p_organization_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
  END IF;

  IF (px_header_id IS NOT NULL) THEN
    BEGIN
      SELECT header_id
      INTO l_header_id
      FROM mtl_txn_request_headers
      WHERE header_id = px_header_id
      AND   organization_id = p_organization_id;

      FND_MESSAGE.SET_NAME('CSP', 'CSP_PARAMETER_EXISTS');
      FND_MESSAGE.SET_TOKEN('PARAMETER', 'px_header_id' , TRUE);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;

    EXCEPTION
      WHEN no_data_found THEN
        -- valid id
        NULL;
    END;
  END IF;

  -- initialize move order header record type
  l_mohdr_rec.header_id             := nvl(px_header_id, FND_API.G_MISS_NUM);
  l_mohdr_rec.request_number        := nvl(p_request_number, FND_API.G_MISS_CHAR);
  l_mohdr_rec.created_by            := nvl(fnd_global.user_id,1);
  l_mohdr_rec.creation_date         := sysdate;
  l_mohdr_rec.date_required         := p_date_required;
  l_mohdr_rec.from_subinventory_code:= p_from_subinventory_code;
  l_mohdr_rec.header_status         := INV_Globals.G_TO_STATUS_PREAPPROVED;
  l_mohdr_rec.last_updated_by       := nvl(fnd_global.user_id,1);
  l_mohdr_rec.last_update_date      := sysdate;
  l_mohdr_rec.last_update_login     := nvl(fnd_global.login_id,-1);
  l_mohdr_rec.organization_id       := p_organization_id;
  l_mohdr_rec.status_date           := sysdate;
  l_mohdr_rec.to_subinventory_code  := p_to_subinventory_code;
  l_mohdr_rec.transaction_type_id   := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
  l_mohdr_rec.move_order_type       := INV_GLOBALS.G_MOVE_ORDER_REQUISITION;
  l_mohdr_rec.db_flag               := FND_API.G_TRUE;
  l_mohdr_rec.operation             := INV_GLOBALS.G_OPR_CREATE;

  -- call public api to create a record for move order header in Oracle Inventory
  INV_Move_Order_PUB.Create_Move_order_Header(
    p_api_version_number => 1,
    p_init_msg_list      => p_init_msg_list,
    p_return_values      => FND_API.G_TRUE,
    p_commit             => l_commit,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data,
    p_trohdr_rec         => l_mohdr_rec,
    p_trohdr_val_rec     => l_mohdr_val_rec,
    x_trohdr_rec         => l_mohdr_rec,
    x_trohdr_val_rec     => l_mohdr_val_rec
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    /* call table handlers for inserting into csp_move_order_header table*/
    csp_to_form_moheaders.Validate_and_Write(
       P_Api_Version_Number           => 1.0
      ,P_Init_Msg_List               => p_init_msg_list
      ,P_Commit                      => l_commit
      ,p_validation_level            => null
      ,p_action_code                 => 0    -- 0 = insert, 1 = update, 2 = delete
      ,p_header_id                   => l_mohdr_rec.header_id
      ,p_created_by                  => nvl(fnd_global.user_id,1)
      ,p_creation_date               => sysdate
      ,p_last_updated_by             => nvl(fnd_global.user_id,1)
      ,p_last_update_date            => sysdate
      ,p_last_update_login           => nvl(fnd_global.login_id,-1)
      ,p_carrier                     => p_freight_carrier
      ,p_shipment_method              => p_shipment_method
      ,p_autoreceipt_flag             => p_autoreceipt_flag
      ,p_attribute_category           => null
      ,p_attribute1                   => null
      ,p_attribute2                   => null
      ,p_attribute3                   => null
      ,p_attribute4                   => null
      ,p_attribute5                   => null
      ,p_attribute6                   => null
      ,p_attribute7                   => null
      ,p_attribute8                   => null
      ,p_attribute9                   => null
      ,p_attribute10                  => null
      ,p_attribute11                  => null
      ,p_attribute12                  => null
      ,p_attribute13                  => null
      ,p_attribute14                  => null
      ,p_attribute15                  => null
      ,p_location_id                  => null
      /*,p_address1                     => p_address1
      ,p_address2                     => p_address2
      ,p_address3                     => p_address3
      ,p_address4                     => p_address4
      ,p_city                         => p_city
      ,p_postal_code                  => p_postal_code
      ,p_state                        => p_state
      ,p_province                     => p_province
      ,p_country                      => p_country */
      ,X_Return_Status                => l_return_status
      ,X_Msg_Count                    => l_msg_count
      ,X_Msg_Data                     => l_msg_data
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     px_header_id := l_mohdr_rec.header_id;
   END IF;

   IF fnd_api.to_boolean(p_commit) THEN
        commit work;
   END IF;

    fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
 /* Exception Block */
 EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to Create_Move_Order_Header_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get
        ( p_count   => x_msg_count
        , p_data    => x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      Rollback to Create_Move_Order_Header_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

END CREATE_MOVE_ORDER_HEADER;


-- Start of comments
--
-- Procedure Name   : create_move_order_lines
-- Descritpion      : Creates move order lines
-- Business Rules   :
-- Parameters       :
-- Version          : 1.0
-- End of comments

PROCEDURE CREATE_MOVE_ORDER_LINE
  (p_api_version            IN NUMBER
  ,p_Init_Msg_List          IN VARCHAR2     := FND_API.G_FALSE
  ,p_commit                 IN VARCHAR2     := FND_API.G_FALSE
  ,px_line_id               IN OUT NOCOPY NUMBER
  ,p_header_id              IN NUMBER
  ,p_organization_id        IN NUMBER
  ,p_from_subinventory_code IN VARCHAR2
  ,p_from_locator_id        IN NUMBER
  ,p_inventory_item_id      IN NUMBER
  ,p_revision               IN VARCHAR2
  ,p_lot_number             IN VARCHAR2
  ,p_serial_number_start    IN VARCHAR2
  ,p_serial_number_end      IN VARCHAR2
  ,p_quantity               IN NUMBER
  ,p_uom_code               IN VARCHAR2
  ,p_quantity_delivered     IN NUMBER
  ,p_to_subinventory_code   IN VARCHAR2
  ,p_to_locator_id          IN VARCHAR2
  ,p_to_organization_id     IN NUMBER
  ,p_service_request        IN VARCHAR2
  ,p_task_id                IN NUMBER
  ,p_task_assignment_id     IN NUMBER
  ,p_customer_po            IN VARCHAR2
  ,p_date_required          IN DATE
  ,p_comments               IN VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

l_trolin_tbl            INV_Move_Order_PUB.Trolin_Tbl_Type;
l_trolin_val_tbl        INV_Move_Order_PUB.Trolin_Val_Tbl_Type;

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Move_Order_Line';
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_commit                VARCHAR2(1) := FND_API.G_FALSE;
EXCP_USER_DEFINED      EXCEPTION;

l_line_num              NUMBER := 0;
l_line_id               NUMBER;
l_order_count           NUMBER := 1; /* total number of lines */

BEGIN
  SAVEPOINT Create_Move_Order_Line_PUB;

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    -- initialize message list
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check organization
  IF p_organization_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
  END IF;

  IF p_header_id IS NULL THEN
    FND_MESSAGE.SET_NAME('CSP', 'CSP_MISSING_PARAMETERS');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'p_header_id', TRUE);
    FND_MSG_PUB.ADD;
    RAISE EXCP_USER_DEFINED;
  END IF;

  IF (px_line_id IS NOT NULL) THEN
    BEGIN
      SELECT line_id
      INTO l_line_id
      FROM mtl_txn_request_lines
      WHERE line_id = px_line_id
      AND   organization_id = p_organization_id;

      FND_MESSAGE.SET_NAME('CSP', 'CSP_PARAMETER_EXISTS');
      FND_MESSAGE.SET_TOKEN('PARAMETER', 'px_line_id' , TRUE);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;

    EXCEPTION
      WHEN no_data_found THEN
        -- valid id
        NULL;
    END;
  END IF;

  select nvl(max(line_number), 0)
  into l_line_num
  from mtl_txn_request_lines
  where header_id = p_header_id;

  l_line_num := l_line_num + 1;
  l_trolin_tbl(l_order_count).header_id             := p_header_id;
  l_trolin_tbl(l_order_count).created_by            := nvl(FND_GLOBAL.USER_ID,1);
  l_trolin_tbl(l_order_count).creation_date         := sysdate;
  l_trolin_tbl(l_order_count).date_required         := p_date_required;
  l_trolin_tbl(l_order_count).from_subinventory_code:= p_from_subinventory_code;
  l_trolin_tbl(l_order_count).from_locator_id       := p_from_locator_id;
  l_trolin_tbl(l_order_count).inventory_item_id     := p_inventory_item_id;
  l_trolin_tbl(l_order_count).revision              := p_revision;
  l_trolin_tbl(l_order_count).lot_number            := p_lot_number;
  l_trolin_tbl(l_order_count).serial_number_start   := p_serial_number_start;
  l_trolin_tbl(l_order_count).serial_number_end     := p_serial_number_end;
  l_trolin_tbl(l_order_count).last_updated_by       := nvl(FND_GLOBAL.USER_ID,1);
  l_trolin_tbl(l_order_count).last_update_date      := sysdate;
  l_trolin_tbl(l_order_count).last_update_login     := nvl(FND_GLOBAL.LOGIN_ID, -1);
  l_trolin_tbl(l_order_count).line_id               := nvl(px_line_id,FND_API.G_MISS_NUM);
  l_trolin_tbl(l_order_count).line_number           := l_line_num;
  l_trolin_tbl(l_order_count).line_status           := INV_Globals.G_TO_STATUS_PREAPPROVED;
  l_trolin_tbl(l_order_count).transaction_type_id   := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
  l_trolin_tbl(l_order_count).organization_id       := p_organization_id;
  l_trolin_tbl(l_order_count).to_organization_id    := p_to_organization_id;
  l_trolin_tbl(l_order_count).quantity              := p_quantity;
  l_trolin_tbl(l_order_count).quantity_delivered    := p_quantity_delivered;
  l_trolin_tbl(l_order_count).status_date           := sysdate;
  l_trolin_tbl(l_order_count).to_subinventory_code  := p_to_subinventory_code;
  l_trolin_tbl(l_order_count).to_locator_id         := p_to_locator_id;
  l_trolin_tbl(l_order_count).uom_code              := p_uom_code;
  l_trolin_tbl(l_order_count).db_flag               := FND_API.G_TRUE;
  l_trolin_tbl(l_order_count).operation             := INV_GLOBALS.G_OPR_CREATE;

  INV_Move_Order_Pub.Create_Move_Order_Lines
       (  p_api_version_number       => 1.0 ,
          p_init_msg_list            => p_init_msg_list,
          p_commit                   => l_commit,
          p_return_values            => FND_API.G_TRUE,
          x_return_status            => l_return_status,
          x_msg_count                => l_msg_count,
          x_msg_data                 => l_msg_data,
          p_trolin_tbl               => l_trolin_tbl,
          p_trolin_val_tbl           => l_trolin_val_tbl,
          x_trolin_tbl               => l_trolin_tbl,
          x_trolin_val_tbl           => l_trolin_val_tbl
       );

   px_line_id := l_trolin_tbl(l_order_count).line_id;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSE
     /* call table handlers for inserting into csp_move_order_lines table*/
     csp_to_form_molines.Validate_and_Write(
           P_Api_Version_Number      => 1.0
          ,P_Init_Msg_List           => p_init_msg_list
          ,P_Commit                  => l_commit
          ,p_validation_level        => null
          ,p_action_code             => 0
          ,P_line_id                 => l_trolin_tbl(l_order_count).line_id
          ,p_CREATED_BY              => nvl(fnd_global.user_id,1)
          ,p_CREATION_DATE           => sysdate
          ,p_LAST_UPDATED_BY         => nvl(fnd_global.user_id,1)
          ,p_LAST_UPDATE_DATE        => sysdate
          ,p_LAST_UPDATED_LOGIN      => nvl(fnd_global.login_id,-1)
          ,p_HEADER_ID               => p_header_id
          ,p_CUSTOMER_PO             => p_customer_po
          ,p_INCIDENT_ID             => p_service_request
          ,p_TASK_ID                 => p_task_id
          ,p_TASK_ASSIGNMENT_ID      => p_task_assignment_id
          ,p_COMMENTS                => p_comments
          ,p_attribute_category     => null
          ,p_attribute1             => null
          ,p_attribute2             => null
          ,p_attribute3             => null
          ,p_attribute4             => null
          ,p_attribute5             => null
          ,p_attribute6             => null
          ,p_attribute7             => null
          ,p_attribute8             => null
          ,p_attribute9             => null
          ,p_attribute10            => null
          ,p_attribute11            => null
          ,p_attribute12            => null
          ,p_attribute13            => null
          ,p_attribute14            => null
          ,p_attribute15            => null
          ,X_Return_Status          => l_return_status
          ,X_Msg_Count              => l_msg_count
          ,X_Msg_Data               => l_msg_data
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     px_line_id := l_trolin_tbl(l_order_count).line_id;
   END IF;

   IF fnd_api.to_boolean(p_commit) THEN
        commit work;
   END IF;
  fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
 /* Exception Block */
 EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to Create_Move_Order_Line_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get
        ( p_count   => x_msg_count
        , p_data    => x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      Rollback to Create_Move_Order_Line_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;


END CREATE_MOVE_ORDER_LINE;


-- Start of comments
--
-- Procedure Name   : transact_material
-- Descritpion      : Creates a material transaction in Inventory
-- Business Rules   :
-- Parameters       :
-- Version          : 1.0
-- Change History	: H Haugerud 	Added support for Intransit and Direct trans
-- End of comments

PROCEDURE TRANSACT_MATERIAL
  (p_api_version                IN NUMBER
  ,p_Init_Msg_List              IN VARCHAR2     := FND_API.G_FALSE
  ,p_commit                     IN VARCHAR2     := FND_API.G_FALSE
  ,px_transaction_id            IN OUT NOCOPY NUMBER
  ,px_transaction_header_id     IN OUT NOCOPY NUMBER
  ,p_inventory_item_id          IN NUMBER
  ,p_organization_id            IN NUMBER
  ,p_subinventory_code          IN VARCHAR2
  ,p_locator_id                 IN NUMBER
  ,p_lot_number                 IN VARCHAR2
  ,p_lot_expiration_date        IN DATE
  ,p_revision                   IN VARCHAR2
  ,p_serial_number              IN VARCHAR2  -- from serial number
  ,p_to_serial_number           IN VARCHAR2 := NULL
  ,p_quantity                   IN NUMBER
  ,p_uom                        IN VARCHAR2
  ,p_source_id                  IN VARCHAR2
  ,p_source_line_id             IN NUMBER
  ,p_transaction_type_id        IN NUMBER
  ,p_account_id                 IN NUMBER
  ,p_transfer_to_subinventory   IN VARCHAR2
  ,p_transfer_to_locator        IN NUMBER
  ,p_transfer_to_organization   IN NUMBER
  ,p_online_process_flag        IN BOOLEAN := TRUE
  ,p_transaction_source_id      IN NUMBER             -- added by klou 03/30/20000
  ,p_trx_source_line_id         IN NUMBER             -- added by klou 03/30/20000
  ,p_transaction_source_name	IN VARCHAR2
  ,p_waybill_airbill		IN VARCHAR2
  ,p_shipment_number    	IN VARCHAR2
  ,p_freight_code		IN VARCHAR2
  ,p_reason_id			IN NUMBER
  ,p_transaction_reference      IN VARCHAR2
  ,p_transaction_date           IN DATE
  ,p_expected_delivery_date     IN DATE DEFAULT NULL
  ,p_FINAL_COMPLETION_FLAG  	  IN VARCHAR2 DEFAULT NULL
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2 ) IS

  l_transaction_action_id       mtl_transaction_types.transaction_action_id%TYPE;
  l_transaction_source_type_id  mtl_transaction_types.transaction_source_type_id%TYPE;
  l_transaction_header_id       mtl_transactions_interface.transaction_header_id%TYPE;
  l_transaction_interface_id    mtl_transactions_interface.transaction_interface_id%TYPE;
  l_acct_period_id              org_acct_periods.acct_period_id%TYPE;
  l_transaction_date            date;
  l_quantity                    NUMBER;
  l_account_id                  NUMBER;
  l_code_comb_id                NUMBER;
  l_subinv_type  			  NUMBER;
  l_inv_asset_flag              VARCHAR2(1);

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(240);
  l_return_status               VARCHAR2(1);

  l_timeout                     NUMBER;
  l_outcome                     BOOLEAN := TRUE;
  l_error_code                  VARCHAR2(200);
  l_error_explanation           VARCHAR2(240);

  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(20) := 'Transact_Material';
  l_check_existence             NUMBER  := 0;
  l_organization_id             NUMBER;

  l_prev_resp_id                NUMBER;
  l_prev_resp_appl_id           NUMBER;
  l_prev_user_id                NUMBER;
  l_resp_id                     NUMBER;
  l_resp_appl_id                NUMBER;
  l_resp_set_flag               BOOLEAN := FALSE;

  p_org_id                      NUMBER;

  EXCP_USER_DEFINED             EXCEPTION;

  l_lot_number_val              VARCHAR2(80);
  ln_count                      NUMBER;
  p_lot_number_temp             VARCHAR2(80);
  --l_ship_number                 Varchar2(30);

  l_process_flag                number;
  l_transaction_source_id       number;
  l_wip_entity_type             number;
  l_FINAL_COMPLETION_FLAG       Varchar2(5);


  l_src_rsc_type                   csp_sec_inventories.owner_resource_type%TYPE;
  l_src_rsc_type_converted         csp_sec_inventories.owner_resource_type%TYPE;
  l_src_rsc_id                     csp_sec_inventories.owner_resource_id%TYPE;
  l_src_username                   jtf_rs_resource_extns.user_name%TYPE;
  l_dest_rsc_type                  csp_sec_inventories.owner_resource_type%TYPE;
  l_dest_rsc_type_converted        csp_sec_inventories.owner_resource_type%TYPE;
  l_dest_rsc_id                    csp_sec_inventories.owner_resource_id%TYPE;
  l_dest_username                  jtf_rs_resource_extns.user_name%TYPE;
  l_item_code                      MTL_SYSTEM_ITEMS_B_KFV.concatenated_segments%TYPE;
  l_source_org_code                mtl_organizations.organization_code%TYPE;
  l_dest_org_code                  mtl_organizations.organization_code%TYPE;
  l_dest_source_name               jtf_rs_resource_extns.source_name%TYPE;
  l_src_source_name                jtf_rs_resource_extns.source_name%TYPE;
  l_uom_desc                       mtl_item_uoms_view.description%TYPE;
  itemtype                         varchar2(20);


   CURSOR c_source_owner_dtls IS
    SELECT owner_resource_type, owner_resource_id
    FROM csp_sec_inventories WHERE
     organization_id = p_organization_id
       AND secondary_inventory_name = p_subinventory_code;


   CURSOR c_dest_owner_dtls IS
	  SELECT owner_resource_type, owner_resource_id
	 FROM csp_sec_inventories
	 WHERE organization_id = p_transfer_to_organization
	 AND secondary_inventory_name = p_transfer_to_subinventory;

   CURSOR c_source_user_name IS
       SELECT user_name, source_name FROM jtf_rs_resource_extns
       WHERE resource_id = l_src_rsc_id and category = l_src_rsc_type_converted;

   CURSOR c_dest_user_name IS
         SELECT user_name, source_name FROM jtf_rs_resource_extns
         WHERE resource_id = l_dest_rsc_id and category = l_dest_rsc_type_converted;

  CURSOR c_item_code IS
      SELECT concatenated_segments  FROM MTL_SYSTEM_ITEMS_B_KFV
      WHERE inventory_item_id=p_inventory_item_id and organization_id=p_organization_id;

  CURSOR c_source_org_code IS
      SELECT organization_code FROM mtl_organizations
      WHERE Organization_id = p_organization_id;

  CURSOR c_dest_org_code IS
      SELECT organization_code FROM mtl_organizations
      WHERE Organization_id = p_transfer_to_organization;

  CURSOR c_uom_desc IS
      SELECT description FROM mtl_item_uoms_view
      WHERE Organization_id = p_organization_id
      AND Inventory_item_id = p_inventory_item_id AND uom_code = p_uom;

  CURSOR l_transaction_header_id_csr IS
    SELECT mtl_material_transactions_s.nextval
    FROM   dual;


  CURSOR l_acct_period_csr is
    SELECT acct_period_id,
           least(sysdate,
                 decode(sign(trunc(period_start_date)-(trunc(p_transaction_date))),
                  1,sysdate,p_transaction_date)) transaction_date
    FROM   org_acct_periods
    WHERE  (trunc(p_transaction_date)
           between trunc(period_start_date)
           and     trunc(schedule_close_date)
    OR     trunc(sysdate)
           between trunc(period_start_date)
           and     trunc(schedule_close_date))
    AND    organization_id = p_organization_id
    AND    period_close_date is null
    AND    nvl(open_flag,'Y') = 'Y'
    ORDER BY period_start_date asc;

  CURSOR l_resp_csr IS
    SELECT application_id,
           responsibility_id
    FROM   fnd_responsibility
    WHERE  responsibility_key = 'SPARES_MANAGEMENT';

    CURSOR l_cost_of_acct(p_org_id Number,p_item_id Number) IS
    SELECT cost_of_sales_account,inventory_asset_flag
    FROM   mtl_system_items_b
    WHERE  organization_id = p_org_id
    AND    inventory_item_id = p_item_id;

    CURSOR l_subinv(p_org_id NUMBER,p_subinv VARCHAR2) IS
    SELECT asset_inventory
    FROM   mtl_secondary_inventories
    WHERE  organization_id = p_org_id
    AND    secondary_inventory_name = p_subinv;

    CURSOR transaction_id_cur IS
    select transaction_id
    from mtl_material_transactions
    where transaction_set_id = l_transaction_header_id;

--- added the following local varibales for bug 3608969
    l_retval 		number;
    l_msg_cnt 		number;
    l_trans_count 	number;
--------------------------------------------------------

BEGIN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'Begin');
	end if;

    Savepoint Transact_Material_PUB;

    IF fnd_api.to_boolean(P_Init_Msg_List) THEN
          -- initialize message list
            FND_MSG_PUB.initialize;
    END IF;

   -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  -- validating transaction_type_id
     IF p_transaction_type_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_transaction_type_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
     END IF;

  -- validating organization
     IF p_organization_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
     END IF;

  -- Check that item is an inventory_item, stockable, transactable and reservable
  --
    IF p_inventory_item_id IS NULL THEN
           FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_inventory_item_id ', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
     ELSE
        BEGIN
        -- validate whether the inventory_item_id exists in the given oranization_id
             select inventory_item_id into l_check_existence
             from mtl_system_items_kfv
             where inventory_item_id = p_inventory_item_id
             and organization_id = p_organization_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('INV', 'INV-NO ITEM RECROD');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
           WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'p_inventory_item_id', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'mtl_system_items', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
        END;
      END IF;

    --validating transaction_quantity
    IF p_quantity IS NULL OR p_quantity < 0 THEN
           fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN('PARAMETER', 'p_quantity', TRUE);
           fnd_msg_pub.add;
           RAISE EXCP_USER_DEFINED;
    END IF;

  --validating transaction_uom
    IF p_uom IS NULL THEN
           fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN('PARAMETER', 'p_uom', TRUE);
           fnd_msg_pub.add;
           RAISE EXCP_USER_DEFINED;
    END IF;

   -- Validating Account ID
   IF p_account_id is not NULL THEN
   BEGIN

       SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
       INTO   p_org_id
       from dual;

		SElECT gcc.code_combination_id
		INTO   l_code_comb_id
		FROM   hr_operating_units hou,gl_sets_of_books gsob,
			   gl_code_combinations gcc
    	--	WHERE hou.organization_id = p_organization_id
                WHERE hou.organization_id = p_org_id
		AND   hou.set_of_books_id = gsob.set_of_books_id
		AND   gsob.chart_of_accounts_id = gcc.chart_of_accounts_id
		AND   gcc.code_combination_id = p_account_id;

	     EXCEPTION
           WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSP', 'CSP_INVALID_ACCOUNT');
                fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
           WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'p_account_id', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'GL_code_combinations', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
        END;
   END IF;


    /* Removed the vaalidation of subinventory code by klou.
       Subinvnetory code is a NULL column in the interface table.
    --validating subinventory_code
    IF p_subinventory_code IS NULL THEN
           fnd_message.set_name ('CSP', 'CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN('PARAMETER', 'p_subinventory_code', TRUE);
           fnd_msg_pub.add;
           RAISE EXCP_USER_DEFINED;
    END IF;
   */

  IF (px_transaction_header_id IS NULL) THEN
    OPEN  l_transaction_header_id_csr;
      FETCH l_transaction_header_id_csr into l_transaction_header_id;
    CLOSE l_transaction_header_id_csr;
    px_transaction_header_id := l_transaction_header_id;
  ELSE
    l_transaction_header_id := px_transaction_header_id;
  END IF;

  OPEN  l_transaction_header_id_csr;
    FETCH l_transaction_header_id_csr into l_transaction_interface_id;
  CLOSE l_transaction_header_id_csr;

  OPEN l_acct_period_csr;
    FETCH l_acct_period_csr into l_acct_period_id, l_transaction_date;
  CLOSE l_acct_period_csr;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'l_acct_period_id=' || l_acct_period_id);
	end if;

  IF l_acct_period_id is null THEN
    x_msg_data := 'Cannot find open accounting period';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_transaction_type_id in (21,32,02,01,93,35) THEN
     l_quantity := p_quantity * (-1);
  ELSE
     l_quantity := p_quantity;
  END IF;
  l_account_id := p_account_id;
  IF p_account_id is NULL THEN
	  IF p_transaction_type_id in(32,93) THEN -- Issuing transaction
		OPEN l_cost_of_acct(p_organization_id,p_inventory_item_id);
		FETCH l_cost_of_acct INTO l_account_id,l_inv_asset_flag;
		CLOSE l_cost_of_acct;
		ELSIF p_transaction_type_id in (42,94) THEN --- Receiving Transaction
		  OPEN l_subinv(p_organization_id,p_subinventory_code);
		  FETCH l_subinv INTO l_subinv_type;
		  CLOSE l_subinv;
		  IF l_subinv_type = 1 THEN --- Asset Subinventory
			OPEN l_cost_of_acct(p_organization_id,p_inventory_item_id);
			FETCH l_cost_of_acct INTO l_account_id,l_inv_asset_flag;
			CLOSE l_cost_of_acct;
			ELSIF l_subinv_type = 2 THEN -- Expense Subinventory
                    		l_account_id := NULL;
             END IF; -- End if for subinv type
         END IF; -- End if for transaction type
  END IF; -- End if for account id is NULL

   -- bug # 6472464
   -- removed validation of duplicate shipment number
   -- this will be checked in wireless code
   /*
  If p_shipment_number is not null then
    Begin
      SELECT SHIPMENT_NUMBER INTO l_ship_number
      FROM MTL_MATERIAL_TRANSACTIONS_TEMP M
      WHERE M.SHIPMENT_NUMBER = p_shipment_number AND ROWNUM = 1;
    Exception
        When no_data_found then
        l_ship_number := Null;
    End;

    If l_ship_number is Not Null then
      fnd_message.set_name('INV','INV_SHIP_USED');
      fnd_msg_pub.add;
      RAISE EXCP_USER_DEFINED;
    End if;

    Begin
      SELECT SHIPMENT_NUM INTO l_ship_number
      FROM RCV_SHIPMENT_HEADERS M
      WHERE M.SHIPMENT_NUM = p_shipment_number AND ROWNUM = 1;
    Exception
      When no_data_found then
      l_ship_number := Null;
    End;

    If l_ship_number is Not Null then
       fnd_message.set_name('INV','INV_SHIP_USED');
       fnd_msg_pub.add;
       RAISE EXCP_USER_DEFINED;
    End if;

    Begin
      SELECT SHIPMENT_NUMBER INTO l_ship_number
      FROM MTL_TRANSACTIONS_INTERFACE M
      WHERE M.SHIPMENT_NUMBER = p_shipment_number AND ROWNUM = 1;
    Exception
      When no_data_found then
      l_ship_number := Null;
    End;

    If l_ship_number is Not Null then
      fnd_message.set_name('INV','INV_SHIP_USED');
      fnd_msg_pub.add;
      RAISE EXCP_USER_DEFINED;
    End if;


  End if;
   */

    If INSTR(p_transaction_source_name,'REPAIR_PO_WIP') > 0 then
        l_WIP_ENTITY_TYPE := 1;
        If p_transaction_type_id = 43 or p_transaction_type_id = 44 then
            l_FINAL_COMPLETION_FLAG := p_FINAL_COMPLETION_FLAG;
        Else
            l_FINAL_COMPLETION_FLAG := NULL;
        End if;
    Else
       l_WIP_ENTITY_TYPE := NULL;
       l_FINAL_COMPLETION_FLAG := NULL;
    End if;

  INSERT INTO mtl_transactions_interface
    ( source_code
    , source_header_id
    , source_line_id
    , process_flag
    , transaction_mode
    , transaction_header_id
    , transaction_interface_id
    , inventory_item_id
    , revision
    , organization_id
    , subinventory_code
    , locator_id
    , transaction_quantity
    , transaction_uom
    , transaction_date
    , acct_period_id
    , distribution_account_id
    , transaction_source_name
    , transaction_type_id
    , transfer_subinventory
    , transfer_locator
    , transfer_organization
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    , lock_flag    --always set to 2 so that the transaction_manager will pick the record and assign it to the transaction_worker.
    , transaction_source_id
    , trx_source_line_id
    , waybill_airbill
    , shipment_number
    , freight_code
    , reason_id
    , transaction_reference
    , expected_arrival_date
    , WIP_ENTITY_TYPE
    , FINAL_COMPLETION_FLAG
    )
  VALUES
    ( nvl(p_source_id,'CSP')
    , 100                               -- source header id
    , nvl(p_source_line_id,1)
    , 1                                 --process_flag yes
    , 2                                 --transaction_mode online
    , l_transaction_header_id
    , l_transaction_interface_id
    , p_inventory_item_id
    , p_revision
    , p_organization_id
    , p_subinventory_code
    , p_locator_id
    , l_quantity
    , p_uom
    , l_transaction_date                           --transaction_date
    , l_acct_period_id
    , l_account_id
    , p_transaction_source_name
    , p_transaction_type_id
    , p_transfer_to_subinventory
    , p_transfer_to_locator
    , p_transfer_to_organization
    , sysdate                           --last_update_date
    , nvl(fnd_global.user_id,1)         --last_updated_by
    , sysdate                           --creation_date
    , nvl(fnd_global.user_id,1)         --created_by
    , nvl(fnd_global.login_id,-1)
    , 2
    , decode(sign(p_transaction_source_id-1000000000000),-1,
                  p_transaction_source_id,null)
    , decode(sign(greatest(p_transaction_source_id,p_trx_source_line_id)
                  -1000000000000),-1,p_trx_source_line_id,null)
    , p_waybill_airbill
    , p_shipment_number
    , p_freight_code
    , p_reason_id
    , p_transaction_reference
    , p_expected_delivery_date
    , l_WIP_ENTITY_TYPE
    , l_FINAL_COMPLETION_FLAG
  );

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'after inserting into mtl_transactions_interface...');
	end if;

/*
	COMMIT;
      select process_flag,transaction_source_id,wip_entity_type
        into l_process_flag,l_transaction_source_id,l_wip_entity_type
        from mtl_transactions_interface
       where transaction_header_id = l_transaction_header_id
         and transaction_interface_id = l_transaction_interface_id;

      dbms_output.put_line('wip_entity_type '||l_wip_entity_type||' Process_flag '||l_process_flag||'  transaction_source_id ' || l_transaction_source_id);
*/

    p_lot_number_temp := p_lot_number;

/*
    select count(*)
      into ln_count
      from mtl_system_items
     where inventory_item_id = p_inventory_item_id
       and serial_number_control_code <> 1
       and lot_control_code = 2
       and organization_id = p_organization_id;

   If ln_count > 0 and p_lot_number is null then
*/

    If p_serial_number is not null and p_lot_number is null then
       Begin
        Select lot_number
          into l_lot_number_val
          From MTL_SERIAL_NUMBERS_VAL_V
         Where current_organization_id = p_organization_id
           and current_subinventory_code = p_subinventory_code
           and inventory_item_id = p_inventory_item_id
           and serial_number = p_serial_number
           and lot_number is not null;
       Exception
         When no_data_found then
         l_lot_number_val := null;
       End;

       If l_lot_number_val is not null then
          p_lot_number_temp := l_lot_number_val;
       end if;
     End if;

-- End if;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'before inserting into mtl_transaction_lots_interface...');
	end if;

  IF p_lot_number_temp IS NOT NULL THEN
    INSERT INTO mtl_transaction_lots_interface
    ( transaction_interface_id
    , lot_number
    , lot_expiration_date
    , transaction_quantity
    , serial_transaction_temp_id
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    )
    VALUES
    ( l_transaction_interface_id
    , p_lot_number_temp
    , p_lot_expiration_date
    , p_quantity
    , l_transaction_interface_id  -- We will only have 1 serial number at a time
    , sysdate
    , nvl(fnd_global.user_id,-1)
    , sysdate
    , nvl(fnd_global.user_id,-1)
    , nvl(fnd_global.login_id,-1)
    );
  END IF;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'before inserting into mtl_serial_numbers_interface...');
	end if;

  IF p_serial_number IS NOT NULL THEN
    INSERT INTO mtl_serial_numbers_interface
    ( transaction_interface_id
    , fm_serial_number
    , to_serial_number
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login)
    VALUES
    ( l_transaction_interface_id
    , p_serial_number
    , nvl(p_to_serial_number, p_serial_number)
    , sysdate           --last_update_date
    , nvl(fnd_global.user_id,1) --last_updated_by
    , sysdate           --creation_date
    , nvl(fnd_global.user_id,1) --created_by
    , nvl(fnd_global.login_id,-1)   --last_update_login
    );
  END IF;

  /*l_transaction_header_id := 2034265;*/
--dbms_output.put_line('transaction_header_id ' || l_transaction_header_id);

  -- If online_prcoess_flag is true then
  -- Call Inventory API for processing transactions in mtl_transactions_interface table
--dbms_output.put_line('transact_material: after calling the apps_initialized');


  IF (p_online_process_flag) THEN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'p_online_process_flag is TRUE...');
	end if;

     --check to see if we need to do intiialization of responsibility
     l_prev_resp_id := fnd_global.resp_id;

     IF (l_prev_resp_id IS NULL OR l_prev_resp_id = -1) THEN
        l_prev_resp_appl_id := fnd_global.resp_appl_id;
        l_prev_user_id := fnd_global.user_id;
        l_resp_set_flag := TRUE;

        OPEN  l_resp_csr;
        FETCH l_resp_csr into l_resp_appl_id, l_resp_id;
        CLOSE l_resp_csr;

        fnd_global.apps_initialize(user_id => nvl(fnd_global.user_id, -1),
                             resp_id => l_resp_id,
                             resp_appl_id => l_resp_appl_id
                             );
     END IF;

---------------------------------------------------
--- Added for bug 3608969
    Begin

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'before process_Transactions...');
	end if;

     l_retval := INV_TXN_MANAGER_PUB.process_Transactions(p_api_version => 1,
          p_init_msg_list    => fnd_api.g_false     ,
          p_commit           => fnd_api.g_false     ,
          p_validation_level => fnd_api.g_valid_level_full  ,
          x_return_status => l_return_status,
          x_msg_count  => l_msg_cnt,
          x_msg_data   => l_msg_data,
          x_trans_count   => l_trans_count,
          p_table	   => 1,
          p_header_id => l_transaction_header_id);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'after process_Transactions l_retval=' || l_retval);
	end if;

     if(l_retval <> 0) THEN
        l_outcome := false;
        select error_code, error_explanation
          into l_error_code, l_error_explanation
        from mtl_transactions_interface
        where transaction_header_id = l_transaction_header_id
          and rownum = 1;
     else
        l_outcome := true;
     end if;

	if(l_outcome) then
		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
							  'l_outcome=true');
		end if;
	end if;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_error_code := ' ';
        l_error_explanation := 'No Errors';
        l_outcome := true;
     WHEN TOO_MANY_ROWS THEN
        l_error_explanation:=  fnd_message.get;
        l_outcome := false;
     WHEN OTHERS THEN
        l_outcome := false;
   END;
----------------------------------------------------


/* commented for bug 3608969
     l_outcome := mtl_online_transaction_pub.process_online
                 ( p_transaction_header_id  => l_transaction_header_id
                 , p_timeout                => l_timeout
                 , p_error_code             => l_error_code
                 , p_error_explanation      => l_error_explanation
                 );
*/

    IF (l_resp_set_flag) THEN
      fnd_global.apps_initialize(user_id => l_prev_user_id,
                                resp_id  => l_prev_resp_id,
                                resp_appl_id => l_prev_resp_appl_id);
    END IF;

    IF (l_outcome = FALSE) THEN
      delete from mtl_transactions_interface where transaction_header_id = l_transaction_header_id;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_TRANSACT_ERRORS');
      FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code, TRUE);
      FND_MESSAGE.SET_TOKEN('ERROR_EXPLANATION', l_error_explanation, FALSE);
      FND_MSG_PUB.ADD;
      RAISE EXCP_USER_DEFINED;
    else
        OPEN transaction_id_cur;
        FETCH transaction_id_cur INTO px_transaction_id;
        CLOSE transaction_id_cur;


	 if(p_transaction_type_id = 2 or p_transaction_type_id = 3) then

		OPEN c_source_owner_dtls;
         FETCH c_source_owner_dtls INTO l_src_rsc_type,l_src_rsc_id;
         CLOSE c_source_owner_dtls;
		l_src_rsc_type_converted := csf_alerts_pub.category_type(l_src_rsc_type);

         OPEN c_source_user_name;
         FETCH c_source_user_name into l_src_username,l_src_source_name;
         CLOSE c_source_user_name;

         OPEN c_dest_owner_dtls;
         FETCH c_dest_owner_dtls INTO l_dest_rsc_type,l_dest_rsc_id;
         CLOSE c_dest_owner_dtls;
		l_dest_rsc_type_converted := csf_alerts_pub.category_type(l_dest_rsc_type);

         OPEN c_dest_user_name;
         FETCH c_dest_user_name INTO l_dest_username,l_dest_source_name;
         CLOSE c_dest_user_name;

         OPEN c_source_org_code;
         FETCH c_source_org_code INTO l_source_org_code;
         CLOSE c_source_org_code;

         OPEN c_dest_org_code;
         FETCH c_dest_org_code INTO l_dest_org_code;
         CLOSE c_dest_org_code;

		OPEN c_item_code;
         FETCH c_item_code INTO l_item_code;
         CLOSE c_item_code;

		OPEN c_uom_desc;
         FETCH c_uom_desc INTO l_uom_desc;
         CLOSE c_uom_desc;


          itemtype := 'CSPSITXN';

   	wf_engine.createprocess(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              process => 'CSPSITXN_PROCESS');
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'ITEMNAME',
                              avalue => l_item_code);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'MTLQUANTITY',
                              avalue => p_quantity);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'UOM',
                              avalue => l_uom_desc);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'TO_ORG_CODE',
                              avalue => l_dest_org_code);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'FROM_ORG_CODE',
                              avalue => l_source_org_code);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'TO_SUBINV',
                              avalue => p_transfer_to_subinventory);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'FROM_SUBINV',
                              avalue => p_subinventory_code);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'SOURCEORGUSER',
                              avalue => l_src_username);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'DESTORGUSER',
                              avalue => l_dest_username);
 	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'DEST_USER_FULL_NAME',
                              avalue => l_dest_source_name);
  	wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'SRC_USER_FULL_NAME',
                              avalue => l_src_source_name);
	IF p_serial_number IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'SERIAL_NUMBER',
                              avalue => p_serial_number);
    ELSE
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'SERIAL_NUMBER',
                              avalue => '-');
    END IF;
    IF p_to_serial_number IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'TO_SERIAL_NUMBER',
                              avalue => p_to_serial_number);
	ELSIF p_serial_number IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'TO_SERIAL_NUMBER',
                              avalue => p_serial_number);
    ELSE
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'TO_SERIAL_NUMBER',
                              avalue => '-');
    END IF;
        IF p_revision IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'REVISION',
                              avalue => p_revision);
        ELSE
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'REVISION',
                              avalue => '-');
        END IF;
        IF p_lot_number IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'LOT_NUMBER',
                              avalue => p_lot_number);
        ELSE
        wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => px_transaction_id,
                              aname => 'LOT_NUMBER',
                              avalue => '-');
        END IF;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'before launching the workflow...');
	end if;

   	wf_engine.startprocess(itemtype => itemtype,
                              itemkey => px_transaction_id);
         END IF;



    END IF;
  END IF;

  IF fnd_api.to_boolean(p_commit) THEN
        commit work;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := l_msg_data;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
						  'x_msg_data=' || x_msg_data);
	end if;
  -- dbms_output.put_line('TRANSACT_MATERIAL: returning successfully');
 /*
 fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data); */
  EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
              If l_outcome = true then  -- i.e. process_online has not been called.
                  Rollback to Transact_Material_Pub;
              end if;
              x_return_status := FND_API.G_RET_STS_ERROR;
				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
									  'csp.plsql.CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL',
									  'in EXCP_USER_DEFINED block x_msg_data=' || x_msg_data);
				end if;
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
                If l_outcome = true then
                  Rollback to Transact_Material_Pub;
                end if;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;

END TRANSACT_MATERIAL;


PROCEDURE transact_temp_record(
/*$Header: csppttnb.pls 120.6.12010000.44 2014/04/03 09:27:33 htank ship $*/
-- Start of Comments
-- Procedure name   : transact_temp_record
-- Purpose          : This procedure copies the data from the given mtl_material_transactions_temp record to the
--                    mtl_transactions_temp_interface table. It will also analyzed whether the item associated with the
--                    the given temp id is under serial or lot control. If the item is under under lot or serial control, this
--                    procedure inserts the necessary data into the mtl_lot_transactions_interface table or the
--                    mtl_serial_numbers_interface table. After the insertion completes, it deletes the existing record from
--                    the mtl_material_transactions_temp, mtl_transaction_lots_temp or the mtl_serial_numbers_temp tables.
--
-- History          :
--  Person       Date               Descriptions
--  ------       ----              --------------
--  klou         27-Mar-2000         created.
--
--  NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
--
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
-- End of Comments

       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_transaction_temp_id     IN      NUMBER,
       px_transaction_header_id  IN OUT NOCOPY  NUMBER,
       p_online_process_flag     IN      BOOLEAN      := FALSE,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
 )
IS
    Cursor l_Get_Temp_Csr IS
       select
        transaction_temp_id      ,
        transaction_source_id    ,
        lot_number               ,
        lot_expiration_date      ,
        transaction_quantity     ,
        move_order_line_id       ,
        item_lot_control_code    ,
        item_serial_control_code ,
        inventory_item_id        ,
        organization_id          ,
        subinventory_code        ,
        locator_id               ,
        revision                 ,
        TRANSACTION_UOM          ,
        SOURCE_CODE              ,
        source_line_id           ,
        TRANSACTION_TYPE_ID      ,
        distribution_account_id  ,
        transfer_subinventory    ,
        transfer_to_location     ,
        transfer_organization    ,
        trx_source_line_id       ,
        expected_arrival_date
      from mtl_material_transactions_temp
      where transaction_temp_id = p_transaction_temp_id;

    Cursor l_Get_Lot_Temp_Csr IS
        select transaction_temp_id, serial_transaction_temp_id,
               lot_number, lot_expiration_date, transaction_quantity
        from mtl_transaction_lots_temp
        where transaction_temp_id = p_transaction_temp_id;

    Cursor l_Get_Serial_Temp_Csr(l_transaction_temp_id NUMBER) IS
        select transaction_temp_id, fm_serial_number, to_serial_number, serial_prefix from mtl_serial_numbers_temp
        where transaction_temp_id = l_transaction_temp_id;

    Cursor l_Get_txn_header_id_csr IS
        SELECT mtl_material_transactions_s.nextval
        FROM   dual;

    Cursor l_Get_Mo_Header_id_csr(l_line_id NUMBER) IS
        select distinct header_id from csp_moveorder_lines
        where line_id = l_line_id;

    Type l_lot_temp_type IS Record (
        transaction_temp_id NUMBER,
        serial_transaction_temp_id NUMBER,
        lot_number      VARCHAR2(80),
        lot_expiration_date DATE,
        transaction_quantity NUMBER);

    Type l_serial_temp_type IS Record (
        transaction_temp_id NUMBER,
        fm_serial_number    VARCHAR2(30),
        to_serial_number    VARCHAR2(30),
        serial_prefix       NUMBER );

    Type l_mtl_temp_type IS Record (
        transaction_temp_id      NUMBER,
        transaction_source_id    NUMBER,
        lot_number               VARCHAR2(80),
        lot_expiration_date      DATE,
        transaction_quantity     NUMBER,
        move_order_line_id       NUMBER,
        item_lot_control_code    NUMBER,
        item_serial_control_code NUMBER,
        inventory_item_id        NUMBER,
        organization_id          NUMBER,
        subinventory_code        VARCHAR2(10),
        locator_id               NUMBER,
        revision                 VARCHAR2(3),
        TRANSACTION_UOM          VARCHAR2(3),
        SOURCE_CODE              VARCHAR2(30),
        source_line_id           NUMBER,
        TRANSACTION_TYPE_ID      NUMBER,
        distribution_account_id  NUMBER,
        transfer_subinventory    VARCHAR2(10),
        transfer_to_location     NUMBER,
        transfer_organization    NUMBER,
        trx_source_line_id       NUMBER,
        expected_arrival_date DATE);

    l_transaction_id   NUMBER;
    l_Mo_header_id NUMBER;
    l_lot_temp_rec  l_lot_temp_type;
    l_serial_temp_rec l_serial_temp_type;
    l_mtl_txn_temp_rec  l_mtl_temp_type; --CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type;
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name      CONSTANT VARCHAR2(50) := 'transact_temp_record';
    l_msg_data  VARCHAR2(300);
    l_check_existence   NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER  := 0;
    l_commit    VARCHAR2(1) := FND_API.G_FALSE;
    l_transaction_header_id number := px_transaction_header_id;
    l_lot_number      VARCHAR2(80);
    l_lot_expiration_date DATE;
    l_fm_serial_number    VARCHAR2(30);
    l_to_serial_number    VARCHAR2(30);
    l_qty_processed NUMBER := 0;
    l_moheader_id NUMBER;
    EXCP_USER_DEFINED   EXCEPTION;

BEGIN
    Savepoint transact_temp_record_pub;

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
          IF p_transaction_temp_id IS NULL THEN
                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_transaction_temp_id', FALSE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
          ELSE
                BEGIN
                    select transaction_temp_id into l_check_existence
                    from mtl_material_transactions_temp
                    where transaction_temp_id = p_transaction_temp_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name ('CSP', 'CSP_INVALID_TXN_TEMP_ID');
                          fnd_message.set_token('ID', to_char(p_transaction_temp_id), FALSE);
                          fnd_msg_pub.add;
                          RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                          RAISE TOO_MANY_ROWS;  -- this will really go to OTHERS exception.
                END;
        END IF;
    End If;

    IF px_transaction_header_id IS NULL THEN
           Open l_Get_Txn_Header_id_csr;
           Fetch l_Get_Txn_Header_id_csr into l_transaction_header_id;
           Close l_Get_Txn_Header_id_csr;
    ELSE
           l_transaction_header_id := px_transaction_header_id;
    END IF;

    -- begin to transact the transaction record
    -- Fetch the temp record into l_mtl_txn_temp_rec;
    Open l_Get_Temp_Csr;
    Fetch l_Get_Temp_Csr Into l_mtl_txn_temp_rec;
    If l_Get_Temp_Csr%NOTFOUND Then
        Close l_Get_Temp_Csr;
        fnd_message.set_name ('CSP', 'CSP_INVALID_TXN_TEMP_ID');
        fnd_message.set_token('ID', to_char(p_transaction_temp_id), FALSE);
        fnd_msg_pub.add;
        RAISE EXCP_USER_DEFINED;
    Else
        Close l_Get_Temp_Csr;
    End If;

    -- find the move order header id for keeping track on the record in the mtl_material_transactions table.
    If l_mtl_txn_temp_rec.transaction_source_id is null then
        Open l_Get_Mo_Header_id_csr(l_mtl_txn_temp_rec.move_order_line_id);
        Fetch l_Get_Mo_Header_id_csr Into l_Mo_header_id;
        If l_Get_Mo_header_id_csr%NOTFOUND THEN
            Close l_Get_Mo_header_id_csr;
            fnd_message.set_name ('CSP', 'CSP_MOVEORDER_LINE_NO_PARENT');
            fnd_message.set_token ('LINE_ID', to_char(l_mtl_txn_temp_rec.move_order_line_id), FALSE);
            fnd_msg_pub.add;
        End If;

        Close l_Get_Mo_header_id_csr;
    Else
        l_mo_header_id := l_mtl_txn_temp_rec.transaction_source_id;
    End If;

    -- Analyze whether the item being transacted is under serial or lot control.
    -- case 1: only lot control
        If nvl(l_mtl_txn_temp_rec.item_lot_control_code, 1) <> 1 And
            nvl(l_mtl_txn_temp_rec.item_serial_control_code, 1) in (1, 6) Then

                l_qty_processed := 0;

                -- open the l_Get_Lot_Temp_Csr to find out the lot number and expiration date
                   Open l_Get_Lot_Temp_Csr;
                   Loop <<process_lot_loop_1>>  -- there may be more than one lot record
                        Fetch l_Get_Lot_Temp_Csr Into l_lot_temp_rec;
                        Exit When l_Get_Lot_Temp_Csr%NOTFOUND;

                        IF l_qty_processed <= l_mtl_txn_temp_rec.transaction_quantity Then
                              TRANSACT_MATERIAL
                                (p_api_version            => l_api_version_number
                                ,p_Init_Msg_List          => P_Init_Msg_List
                                ,p_commit                 => l_commit
                                ,px_transaction_id        => l_transaction_id
                                ,px_transaction_header_id => l_transaction_header_id
                                ,p_inventory_item_id      => l_mtl_txn_temp_rec.inventory_item_id
                                ,p_organization_id        => l_mtl_txn_temp_rec.organization_id
                                ,p_subinventory_code      => l_mtl_txn_temp_rec.subinventory_code
                                ,p_locator_id             => l_mtl_txn_temp_rec.locator_id
                                ,p_lot_number             => l_lot_temp_rec.lot_number
                                ,p_lot_expiration_date    => l_lot_temp_rec.lot_expiration_date
                                ,p_revision               => l_mtl_txn_temp_rec.revision
                                ,p_serial_number          => null
                                ,p_to_serial_number       => NULL
                                ,p_quantity               => l_lot_temp_rec.transaction_quantity
                                ,p_uom                    => l_mtl_txn_temp_rec.TRANSACTION_UOM
                                ,p_source_id              => l_mtl_txn_temp_rec.SOURCE_CODE --TRANSACTION_SOURCE_ID
                                ,p_source_line_id         => l_mtl_txn_temp_rec.source_line_id
                                ,p_transaction_type_id    => l_mtl_txn_temp_rec.TRANSACTION_TYPE_ID
                                ,p_account_id             => l_mtl_txn_temp_rec.distribution_account_id
                                ,p_transfer_to_subinventory => l_mtl_txn_temp_rec.transfer_subinventory
                                ,p_transfer_to_locator    => l_mtl_txn_temp_rec.transfer_to_location
                                ,p_transfer_to_organization => l_mtl_txn_temp_rec.transfer_organization
                                ,p_online_process_flag    => p_online_process_flag
                                ,p_transaction_source_id    => l_mo_header_id
                                ,p_trx_source_line_id       =>  nvl(l_mtl_txn_temp_rec.trx_source_line_id, l_mtl_txn_temp_rec.move_order_line_id)
                                ,p_expected_delivery_date   => l_mtl_txn_temp_rec.expected_arrival_date
                                ,x_return_status          => l_return_status
                                ,x_msg_count              => l_msg_count
                                ,x_msg_data               => l_msg_data
                               );

                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  Close l_Get_Lot_Temp_Csr;
                                  RAISE FND_API.G_EXC_ERROR;
                               END IF;
                               l_qty_processed := l_qty_processed + l_lot_temp_rec.transaction_quantity;
                         End If;
                     End Loop; -- <<process_lot_loop_1>>

                     If l_Get_Lot_Temp_Csr%rowcount = 0 Then
                        Close l_Get_Lot_Temp_Csr;
                        fnd_message.set_name('CSP', 'CSP_NO_LOT_TXN_RECORD');
                        fnd_msg_pub.add;
                        RAISE EXCP_USER_DEFINED;
                     End if;

                     If l_Get_Lot_Temp_Csr%ISOPEN Then
                        Close l_Get_Lot_Temp_Csr;
                     End if;

         -- case 2: under both lot control and serial control
          Elsif nvl(l_mtl_txn_temp_rec.item_lot_control_code, 1) <> 1 And
                nvl(l_mtl_txn_temp_rec.item_serial_control_code, 1) in (2, 5) Then
                   l_qty_processed := 0;

                   -- open the l_Get_Lot_Temp_Csr to find out the lot number and expiration date
                   Open l_Get_Lot_Temp_Csr;
                   Loop <<process_lot_loop_2>>  -- there may be more than one lot record
                        Fetch l_Get_Lot_Temp_Csr Into l_lot_temp_rec;
                        Exit When l_Get_Lot_Temp_Csr%NOTFOUND;

                            -- for each lot record, it may have more than one serial record
                            -- open the l_Get_Serial_Temp_Csr(l_transaction_temp_id NUMBER)
                            Open l_Get_Serial_Temp_Csr(l_lot_temp_rec.serial_transaction_temp_id);
                            Loop <<process_serial_loop_2>>
                            Fetch l_Get_Serial_Temp_Csr Into l_serial_temp_rec;
                            Exit when l_Get_Serial_Temp_Csr%NOTFOUND;

                               IF l_qty_processed <= l_mtl_txn_temp_rec.transaction_quantity Then
                                  TRANSACT_MATERIAL
                                    (p_api_version            => l_api_version_number
                                    ,p_Init_Msg_List          => P_Init_Msg_List
                                    ,p_commit                 => l_commit
                                    ,px_transaction_id        => l_transaction_id
                                    ,px_transaction_header_id => l_transaction_header_id
                                    ,p_inventory_item_id      => l_mtl_txn_temp_rec.inventory_item_id
                                    ,p_organization_id        => l_mtl_txn_temp_rec.organization_id
                                    ,p_subinventory_code      => l_mtl_txn_temp_rec.subinventory_code
                                    ,p_locator_id             => l_mtl_txn_temp_rec.locator_id
                                    ,p_lot_number             => l_lot_temp_rec.lot_number
                                    ,p_lot_expiration_date    => l_lot_temp_rec.lot_expiration_date
                                    ,p_revision               => l_mtl_txn_temp_rec.revision
                                    ,p_serial_number          => l_serial_temp_rec.fm_serial_number
                                    ,p_to_serial_number       => l_serial_temp_rec.to_serial_number
                                    ,p_quantity               => nvl(l_serial_temp_rec.serial_prefix, 1)
                                    ,p_uom                    => l_mtl_txn_temp_rec.TRANSACTION_UOM
                                    ,p_source_id              => l_mtl_txn_temp_rec.SOURCE_CODE --TRANSACTION_SOURCE_ID
                                    ,p_source_line_id         => l_mtl_txn_temp_rec.source_line_id
                                    ,p_transaction_type_id    => l_mtl_txn_temp_rec.TRANSACTION_TYPE_ID
                                    ,p_account_id             => l_mtl_txn_temp_rec.distribution_account_id
                                    ,p_transfer_to_subinventory => l_mtl_txn_temp_rec.transfer_subinventory
                                    ,p_transfer_to_locator    => l_mtl_txn_temp_rec.transfer_to_location
                                    ,p_transfer_to_organization => l_mtl_txn_temp_rec.transfer_organization
                                    ,p_online_process_flag    => p_online_process_flag
                                    ,p_transaction_source_id    => l_mo_header_id
                                    ,p_trx_source_line_id       =>  nvl(l_mtl_txn_temp_rec.trx_source_line_id, l_mtl_txn_temp_rec.move_order_line_id)
                                    ,p_expected_delivery_date   => l_mtl_txn_temp_rec.expected_arrival_date
                                    ,x_return_status          => l_return_status
                                    ,x_msg_count              => l_msg_count
                                    ,x_msg_data               => l_msg_data
                                   );

                                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                      Close l_Get_Lot_Temp_Csr;
                                      Close l_Get_Serial_Temp_Csr;
                                      RAISE FND_API.G_EXC_ERROR;
                                   END IF;
                                   l_qty_processed := l_qty_processed + nvl(l_serial_temp_rec.serial_prefix, 1);
                                End If;
                             End Loop; -- <<process_serial_loop_2>>

                             If l_Get_Serial_Temp_Csr%rowcount = 0 Then
                                Close l_Get_Lot_Temp_Csr;
                                Close l_Get_Serial_Temp_Csr;
                                fnd_message.set_name('CSP', 'CSP_NO_SERIAL_TXN_RECORD');
                                fnd_msg_pub.add;
                                RAISE EXCP_USER_DEFINED;
                             End If;

                             If l_Get_Serial_Temp_Csr%ISOPEN Then
                                  Close l_Get_Serial_Temp_Csr;
                             End if;
                   End Loop; --<<process_lot_loop_2>>

              If l_Get_Lot_Temp_Csr%ISOPEN Then
                       Close l_Get_Lot_Temp_Csr;
              End if;

     -- case 3: only under serial control
          Elsif nvl(l_mtl_txn_temp_rec.item_lot_control_code, 1) = 1 And
                nvl(l_mtl_txn_temp_rec.item_serial_control_code, 1) in (2, 5) Then
              l_qty_processed := 0;

                 -- open the l_Get_Serial_Temp_Csr(l_transaction_temp_id NUMBER)
                    Open l_Get_Serial_Temp_Csr(l_mtl_txn_temp_rec.transaction_temp_id);
                    Loop <<process_serial_loop_3>>
                    Fetch l_Get_Serial_Temp_Csr Into l_serial_temp_rec;
                    Exit when l_Get_Serial_Temp_Csr%NOTFOUND;

                       IF l_qty_processed <= l_mtl_txn_temp_rec.transaction_quantity Then
                          TRANSACT_MATERIAL
                            (p_api_version            => l_api_version_number
                            ,p_Init_Msg_List          => P_Init_Msg_List
                            ,p_commit                 => l_commit
                            ,px_transaction_id        => l_transaction_id
                            ,px_transaction_header_id => l_transaction_header_id
                            ,p_inventory_item_id      => l_mtl_txn_temp_rec.inventory_item_id
                            ,p_organization_id        => l_mtl_txn_temp_rec.organization_id
                            ,p_subinventory_code      => l_mtl_txn_temp_rec.subinventory_code
                            ,p_locator_id             => l_mtl_txn_temp_rec.locator_id
                            ,p_lot_number             => null
                            ,p_lot_expiration_date    => null
                            ,p_revision               => l_mtl_txn_temp_rec.revision
                            ,p_serial_number          => l_serial_temp_rec.fm_serial_number
                            ,p_to_serial_number       => l_serial_temp_rec.to_serial_number
                            ,p_quantity               => nvl(l_serial_temp_rec.serial_prefix, 1)
                            ,p_uom                    => l_mtl_txn_temp_rec.TRANSACTION_UOM
                            ,p_source_id              => l_mtl_txn_temp_rec.SOURCE_CODE --TRANSACTION_SOURCE_ID
                            ,p_source_line_id         => l_mtl_txn_temp_rec.source_line_id
                            ,p_transaction_type_id    => l_mtl_txn_temp_rec.TRANSACTION_TYPE_ID
                            ,p_account_id             => l_mtl_txn_temp_rec.distribution_account_id
                            ,p_transfer_to_subinventory => l_mtl_txn_temp_rec.transfer_subinventory
                            ,p_transfer_to_locator    => l_mtl_txn_temp_rec.transfer_to_location
                            ,p_transfer_to_organization => l_mtl_txn_temp_rec.transfer_organization
                            ,p_online_process_flag    => p_online_process_flag
                            ,p_transaction_source_id    => l_mo_header_id
                            ,p_trx_source_line_id       =>  nvl(l_mtl_txn_temp_rec.trx_source_line_id, l_mtl_txn_temp_rec.move_order_line_id)
                            ,p_expected_delivery_date   => l_mtl_txn_temp_rec.expected_arrival_date
                            ,x_return_status          => l_return_status
                            ,x_msg_count              => l_msg_count
                            ,x_msg_data               => l_msg_data
                           );

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              Close l_Get_Serial_Temp_Csr;
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;
                           l_qty_processed := l_qty_processed + l_serial_temp_rec.serial_prefix;
                        End If;
                    End Loop; --<<process_serial_loop_3>>
                 If l_Get_Serial_Temp_Csr%ISOPEN Then
                       Close l_Get_Serial_Temp_Csr;
                 End if;

          -- case 4: neither serial control nor lot control
          Else
            TRANSACT_MATERIAL
            (p_api_version              => l_api_version_number
            ,p_Init_Msg_List            => P_Init_Msg_List
            ,p_commit                   => l_commit
            ,px_transaction_id          => l_transaction_id
            ,px_transaction_header_id   => l_transaction_header_id
            ,p_inventory_item_id        => l_mtl_txn_temp_rec.inventory_item_id
            ,p_organization_id          => l_mtl_txn_temp_rec.organization_id
            ,p_subinventory_code        => l_mtl_txn_temp_rec.subinventory_code
            ,p_locator_id               => l_mtl_txn_temp_rec.locator_id
            ,p_lot_number               => null
            ,p_lot_expiration_date      => null
            ,p_revision                 => l_mtl_txn_temp_rec.revision
            ,p_serial_number            => null
            ,p_to_serial_number         => null
            ,p_quantity                 => l_mtl_txn_temp_rec.transaction_quantity
            ,p_uom                      => l_mtl_txn_temp_rec.TRANSACTION_UOM
            ,p_source_id                => l_mtl_txn_temp_rec.SOURCE_CODE--TRANSACTION_SOURCE_ID
            ,p_source_line_id           => l_mtl_txn_temp_rec.source_line_id
            ,p_transaction_type_id      => l_mtl_txn_temp_rec.TRANSACTION_TYPE_ID
            ,p_account_id               => l_mtl_txn_temp_rec.distribution_account_id
            ,p_transfer_to_subinventory => l_mtl_txn_temp_rec.transfer_subinventory
            ,p_transfer_to_locator      => l_mtl_txn_temp_rec.transfer_to_location
            ,p_transfer_to_organization => l_mtl_txn_temp_rec.transfer_organization
            ,p_online_process_flag      => p_online_process_flag
            ,p_transaction_source_id    => l_mo_header_id
            ,p_trx_source_line_id       => nvl(l_mtl_txn_temp_rec.trx_source_line_id, l_mtl_txn_temp_rec.move_order_line_id)
            ,p_expected_delivery_date   => l_mtl_txn_temp_rec.expected_arrival_date
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
           );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    Close l_Get_Serial_Temp_Csr;
                    RAISE FND_API.G_EXC_ERROR;
            END IF;
          End if;

           IF fnd_api.to_boolean(p_commit) THEN
                 commit work;
           END IF;
           x_return_status :=  l_return_status;
           fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
  EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
             Rollback to transact_temp_record_pub;
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
                Rollback to transact_temp_record_pub;
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token ('ROUTINE', l_api_name, FALSE);
                fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
                fnd_msg_pub.add;
                fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
                x_return_status := fnd_api.g_ret_sts_error;
  END transact_temp_record;


PROCEDURE transact_items_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY   Trans_Items_Tbl_Type,
    p_Trans_Type_id           IN      NUMBER,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  ) IS

  PX_TRANSACTION_ID NUMBER;
  PX_TRANSACTION_HEADER_ID NUMBER;
  inx1 PLS_INTEGER;
  v_temp_error_msg    varchar2(2000);
BEGIN

  PX_TRANSACTION_ID := NULL;
  PX_TRANSACTION_HEADER_ID := NULL;

  FOR inx1 IN 1..p_Trans_Items.COUNT LOOP
	  PX_TRANSACTION_ID := NULL;
	  PX_TRANSACTION_HEADER_ID := NULL;
    CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL(
        P_API_VERSION => P_Api_Version_Number,
        P_INIT_MSG_LIST => FND_API.G_TRUE,
        P_COMMIT => FND_API.G_TRUE,
        PX_TRANSACTION_ID => PX_TRANSACTION_ID,
        PX_TRANSACTION_HEADER_ID => PX_TRANSACTION_HEADER_ID,
        P_INVENTORY_ITEM_ID => p_Trans_Items(inx1).INVENTORY_ITEM_ID,
        P_ORGANIZATION_ID => p_Trans_Items(inx1).FRM_ORGANIZATION_ID,
        P_SUBINVENTORY_CODE => p_Trans_Items(inx1).FRM_SUBINVENTORY_CODE,
        P_LOCATOR_ID => p_Trans_Items(inx1).FRM_LOCATOR_ID,
        P_LOT_NUMBER => p_Trans_Items(inx1).LOT_NUMBER,
        P_LOT_EXPIRATION_DATE => NULL,
        P_REVISION => p_Trans_Items(inx1).REVISION,
        P_SERIAL_NUMBER => p_Trans_Items(inx1).SERIAL_NUMBER,
        P_TO_SERIAL_NUMBER => p_Trans_Items(inx1).TO_SERIAL_NUMBER,
        P_QUANTITY => p_Trans_Items(inx1).QUANTITY,
        P_UOM => p_Trans_Items(inx1).UOM_CODE,
        P_SOURCE_ID => NULL,
        P_SOURCE_LINE_ID => NULL,
        P_TRANSACTION_TYPE_ID => p_Trans_Type_id,
        P_ACCOUNT_ID => NULL,
        P_TRANSFER_TO_SUBINVENTORY => p_Trans_Items(inx1).TO_SUBINVENTORY_CODE,
        P_TRANSFER_TO_LOCATOR => p_Trans_Items(inx1).TO_LOCATOR_ID,
        P_TRANSFER_TO_ORGANIZATION => p_Trans_Items(inx1).TO_ORGANIZATION_ID,
        P_ONLINE_PROCESS_FLAG => TRUE,
        P_TRANSACTION_SOURCE_ID => NULL,
        P_TRX_SOURCE_LINE_ID => NULL,
        P_TRANSACTION_SOURCE_NAME => NULL,
        P_WAYBILL_AIRBILL => p_Trans_Items(inx1).WAYBILL_AIRBILL,
        P_SHIPMENT_NUMBER => p_Trans_Items(inx1).SHIPMENT_NUMBER,
        P_FREIGHT_CODE => p_Trans_Items(inx1).FREIGHT_CODE,
        P_REASON_ID => p_Trans_Items(inx1).REASON_ID,
        P_TRANSACTION_REFERENCE => NULL,
        P_TRANSACTION_DATE => sysdate,
        P_EXPECTED_DELIVERY_DATE => NULL,
        P_FINAL_COMPLETION_FLAG => NULL,
        X_RETURN_STATUS => X_Return_Status,
        X_MSG_COUNT => X_Msg_Count,
        X_MSG_DATA => X_Msg_Data
    );

    IF X_Return_Status <> 'S' THEN
      v_temp_error_msg := X_Msg_Data;
      p_Trans_Items(inx1).ERROR_MSG := v_temp_error_msg;
		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.transact_items_transfer',
							  'p_Trans_Items(inx1).ERROR_MSG=' || p_Trans_Items(inx1).ERROR_MSG);
		end if;
    END IF;
  END LOOP;

  X_Return_Status := 'S';

END transact_items_transfer;

PROCEDURE transact_subinv_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY   Trans_Items_Tbl_Type,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  ) IS
BEGIN
  transact_items_transfer(
    P_Api_Version_Number  => P_Api_Version_Number,
    P_Init_Msg_List       => P_Init_Msg_List,
    P_Commit              => P_Commit,
    p_Trans_Items         => p_Trans_Items,
    p_Trans_Type_id       => 2,   -- Subinventory Transfer
    X_Return_Status       => X_Return_Status,
    X_Msg_Count           => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data
  );
END transact_subinv_transfer;


PROCEDURE transact_intorg_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY   Trans_Items_Tbl_Type,
    p_if_intransit            IN      BOOLEAN,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  ) IS

  v_Trans_Type_id number;
BEGIN

  v_Trans_Type_id := 3;   -- Direct Org Transfer
  IF p_if_intransit THEN
    v_Trans_Type_id := 21;  --  Intransit Shipment
  END IF;

  transact_items_transfer(
    P_Api_Version_Number  => P_Api_Version_Number,
    P_Init_Msg_List       => P_Init_Msg_List,
    P_Commit              => P_Commit,
    p_Trans_Items         => p_Trans_Items,
    p_Trans_Type_id       => v_Trans_Type_id,
    X_Return_Status       => X_Return_Status,
    X_Msg_Count           => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data
  );
END transact_intorg_transfer;

PROCEDURE create_move_order (
    p_Trans_Items            IN OUT NOCOPY Trans_Items_Tbl_Type,
    p_date_required          IN DATE,
    p_comments               IN VARCHAR2,
    x_move_order_number      OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

  CURSOR c_REQUEST_NUMBER (v_move_order_id number )IS
    SELECT REQUEST_NUMBER
    FROM MTL_TXN_REQUEST_HEADERS
    WHERE HEADER_ID = v_move_order_id;

  l_move_order_id NUMBER;
  l_line_id       NUMBER;
  inx1 PLS_INTEGER;
  v_temp_error_msg    varchar2(2000);
BEGIN

  l_move_order_id := NULL;
  l_line_id := NULL;

    -- INSERT HEADER FIRST

    CSP_TRANSACTIONS_PUB.CREATE_MOVE_ORDER_HEADER(
      px_header_id             => l_move_order_id
      ,p_request_number         => null
      ,p_api_version            => 1.0
      ,p_Init_Msg_List          => FND_API.G_TRUE
      ,p_commit                 => FND_API.G_TRUE
      ,p_date_required          => NVL(p_date_required, sysdate)
      ,p_organization_id        => p_Trans_Items(1).FRM_ORGANIZATION_ID
      ,p_from_subinventory_code => p_Trans_Items(1).FRM_SUBINVENTORY_CODE
      ,p_to_subinventory_code   => p_Trans_Items(1).TO_SUBINVENTORY_CODE
      ,p_address1               => null
      ,p_address2               => null
      ,p_address3               => null
      ,p_address4               => null
      ,p_city                   => null
      ,p_postal_code            => null
      ,p_state                  => null
      ,p_province               => null
      ,p_country                => null
      ,p_freight_carrier        => null
      ,p_shipment_method        => null
      ,p_autoreceipt_flag       => null
      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data );


    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      fnd_msg_pub.get
          ( p_msg_index     => x_msg_count
          , p_encoded       => FND_API.G_FALSE
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_count
          );
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      FOR inx1 IN 1..p_Trans_Items.COUNT LOOP
        CSP_TRANSACTIONS_PUB.CREATE_MOVE_ORDER_LINE
          (p_api_version            => 1.0
          ,p_Init_Msg_List          => FND_API.G_TRUE
          ,p_commit                 => FND_API.G_TRUE
          ,px_line_id               => l_line_id
          ,p_header_id              => l_move_order_id
          ,p_organization_id        => p_Trans_Items(inx1).FRM_ORGANIZATION_ID
          ,p_from_subinventory_code => p_Trans_Items(inx1).FRM_SUBINVENTORY_CODE
          ,p_from_locator_id        => p_Trans_Items(inx1).FRM_LOCATOR_ID
          ,p_inventory_item_id      => p_Trans_Items(inx1).INVENTORY_ITEM_ID
          ,p_revision               => p_Trans_Items(inx1).REVISION
          ,p_lot_number             => p_Trans_Items(inx1).LOT_NUMBER
          ,p_serial_number_start    => p_Trans_Items(inx1).SERIAL_NUMBER
          ,p_serial_number_end      => p_Trans_Items(inx1).SERIAL_NUMBER
          ,p_quantity               => p_Trans_Items(inx1).QUANTITY
          ,p_uom_code               => p_Trans_Items(inx1).UOM_CODE
          ,p_quantity_delivered     => null
          ,p_to_subinventory_code   => p_Trans_Items(inx1).TO_SUBINVENTORY_CODE
          ,p_to_locator_id          => p_Trans_Items(inx1).TO_LOCATOR_ID
          ,p_to_organization_id     => p_Trans_Items(inx1).TO_ORGANIZATION_ID
          ,p_service_request        => null
          ,p_task_id                => null
          ,p_task_assignment_id     => null
          ,p_customer_po            => null
          ,p_date_required          => NVL(p_date_required, sysdate)
          ,p_comments               => p_comments
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            fnd_msg_pub.get
              ( p_msg_index     => x_msg_count
              , p_encoded       => FND_API.G_FALSE
              , p_data          => x_msg_data
              , p_msg_index_out => x_msg_count
              );
            p_Trans_Items(inx1).ERROR_MSG := x_msg_data;
          end if;

        END LOOP;

      x_return_status := FND_API.G_RET_STS_SUCCESS ;
      COMMIT WORK;
      /*
      open c_REQUEST_NUMBER(l_move_order_id);
      fetch c_REQUEST_NUMBER into x_move_order_number;
      close c_REQUEST_NUMBER;
      */
      x_move_order_number := to_char(l_line_id);

    END IF;

 EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END create_move_order;

PROCEDURE receive_requirement_trans (
    p_trans_header_id     IN NUMBER,
    p_trans_line_id       IN NUMBER,
    p_trans_record        IN Trans_Items_Rec_Type,
    p_trans_type          IN VARCHAR2,
    p_req_line_detail_id  IN NUMBER,
    p_close_short         IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

  l_actual_trans_type   varchar2(15);
  l_Trans_Items         Trans_Items_Tbl_Type;
  l_task_id   number;
  l_requirement_line_id number;
  l_new_reservation_id  number;
  l_req_line_detail_id  number;
  l_RESERVATION_REC   CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
  l_if_intransit boolean;

  l_inv_reservation_rec inv_reservation_global.mtl_reservation_rec_type;
  l_serial_number   inv_reservation_global.serial_number_tbl_type;
  l_relieved_quantity        NUMBER;
  l_relieved_quantity1        NUMBER;
  l_remaining_quantity       NUMBER;

  l_mo_transaction_header_id number;

  cursor check_task_req is
    select h.task_id, l.requirement_line_id
    from
      csp_requirement_headers h,
      csp_requirement_lines l,
      csp_req_line_details d
    where d.req_line_detail_id = p_req_line_detail_id
      and d.requirement_line_id = l.requirement_line_id
      and l.requirement_header_id = h.requirement_header_id
      and h.task_id is not null;

	-- bug # 9525245
	l_oe_header_id	number;
	l_oe_line_id number;
	l_rcv_ship_header_id	number;
	l_rcv_ship_line_id	number;
	l_receive_hdr_rec CSP_RECEIVE_PVT.rcv_hdr_rec_type;
	l_receive_rec_tbl	CSP_RECEIVE_PVT.rcv_rec_tbl_type;
	l_rcv_rec_type	CSP_RECEIVE_PVT.rcv_rec_type;

	cursor get_rcv_header_data is
	select
	  rsh.shipment_header_id,
	  rsl.shipment_line_id,
	  'INTERNAL' SOURCE_TYPE_CODE,
	  rsh.receipt_source_code,
	  rsh.shipment_num,
	  rsh.ship_to_org_id,
	  rsh.bill_of_lading,
	  rsh.packing_slip,
	  rsh.shipped_date,
	  rsh.freight_carrier_code,
	  rsh.expected_receipt_date,
	  rsh.waybill_airbill_num,
	  rsh.RECEIPT_NUM
	from
	  RCV_SHIPMENT_LINES rsl,
	  RCV_SHIPMENT_HEADERS rsh
	where
	  rsl.shipment_line_id = l_rcv_ship_line_id
	  and rsh.shipment_header_id = rsl.shipment_header_id
	  and rsh.receipt_source_code = 'INTERNAL ORDER';

	cursor get_rcv_line_data is
	select
	  'INTERNAL' SOURCE_TYPE_CODE,
	  order_type_code,
	  item_id,
	  item_revision,
	  item_category_id,
	  item_description,
	  from_organization_id,
	  ordered_qty,
	  ordered_uom,
	  decode(SERIAL_NUMBER_CONTROL_CODE, 1, TRANSACTION_QTY, 1),
	  REQ_LINE_ID,
	  receipt_source_code,
	  lot_num,
	  PRIMARY_UOM,
	  PRIMARY_UOM_CLASS,
	  SERIAL_NUM,
	  TO_ORGANIZATION_ID,
	  DESTINATION_SUBINVENTORY,
	  DESTINATION_TYPE_CODE,
	  ROUTING_ID,
	  SHIP_TO_LOCATION_ID,
	  ENFORCE_SHIP_TO_LOCATION_CODE,
	  SET_OF_BOOKS_ID_SOB,
	  CURRENCY_CODE_SOB,
	  SERIAL_NUMBER_CONTROL_CODE,
	  LOT_CONTROL_CODE,
      LOT_QUANTITY,
	  item_revision
	from
	  CSP_RECEIVE_lines_V
	where
	  rcv_shipment_header_id = l_rcv_ship_header_id
	  and rcv_shipment_line_id = l_rcv_ship_line_id
    and nvl(SERIAL_NUM, -999) = nvl(p_trans_record.SERIAL_NUMBER, -999);

    l_total_reserved_qty number;
    l_total_req_qty number;
    l_already_res_qty number;
    l_hdr_need_by   date;
    l_res_exists number;

	cursor c_dest_info is
	SELECT h.destination_organization_id,
		h.destination_subinventory
	FROM csp_requirement_headers h,
		csp_requirement_lines l,
		csp_req_line_details d
	WHERE d.req_line_detail_id  = p_req_line_detail_id
	AND d.requirement_line_id   = l.requirement_line_id
	AND l.requirement_header_id = h.requirement_header_id;

	l_req_dest_org_id number;
	l_req_dest_subinv varchar2(100);

BEGIN
  /*
    Logic in brief
    - if p_trans_type is 'RES' then actual transaction can be
      Subinventory Transfer, Inter-Org Transfer (Direct) or
      Inter-Org Transfer (Intransit)
    - if it is MO/IO/PO then will call another API
    - For 'RES'
      -> Get actual transaction based on Source and Destination
      -> Call API to complete the transaction
      -> Remove reservation from actual Source
      -> Create a new reservation on destination
        (Only if requirement is for a Task)
      -> Stamp this new reservation_id to requirement line detail record
  */

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'Begin');
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_type=' || p_trans_type);

	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_header_id=' || p_trans_header_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_line_id=' || p_trans_line_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_req_line_detail_id=' || p_req_line_detail_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_close_short=' || p_close_short);

	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.INVENTORY_ITEM_ID=' || p_trans_record.INVENTORY_ITEM_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.REVISION=' || p_trans_record.REVISION);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.QUANTITY=' || p_trans_record.QUANTITY);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.UOM_CODE=' || p_trans_record.UOM_CODE);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.LOT_NUMBER=' || p_trans_record.LOT_NUMBER);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.SERIAL_NUMBER=' || p_trans_record.SERIAL_NUMBER);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.FRM_ORGANIZATION_ID=' || p_trans_record.FRM_ORGANIZATION_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.FRM_SUBINVENTORY_CODE=' || p_trans_record.FRM_SUBINVENTORY_CODE);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.FRM_LOCATOR_ID=' || p_trans_record.FRM_LOCATOR_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.TO_ORGANIZATION_ID=' || p_trans_record.TO_ORGANIZATION_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.TO_SUBINVENTORY_CODE=' || p_trans_record.TO_SUBINVENTORY_CODE);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.TO_LOCATOR_ID=' || p_trans_record.TO_LOCATOR_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.TO_SERIAL_NUMBER=' || p_trans_record.TO_SERIAL_NUMBER);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.WAYBILL_AIRBILL=' || p_trans_record.WAYBILL_AIRBILL);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.FREIGHT_CODE=' || p_trans_record.FREIGHT_CODE);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.SHIPMENT_NUMBER=' || p_trans_record.SHIPMENT_NUMBER);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.PACKLIST_LINE_ID=' || p_trans_record.PACKLIST_LINE_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.TEMP_TRANSACTION_ID=' || p_trans_record.TEMP_TRANSACTION_ID);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.ERROR_MSG=' || p_trans_record.ERROR_MSG);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'p_trans_record.SHIPMENT_LINE_ID=' || p_trans_record.SHIPMENT_LINE_ID);

	end if;

  if p_trans_type = 'RES' then


        l_remaining_quantity := 0;

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'p_close_short=' || p_close_short);
		end if;

      if p_close_short = 'Y' then
         CSP_SCH_INT_PVT.CANCEL_RESERVATION(
            p_reserv_id => p_trans_header_id,
            x_return_status => x_return_status,
            x_msg_data => x_msg_count,
            x_msg_count => x_msg_data
            );

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'After calling CSP_SCH_INT_PVT.CANCEL_RESERVATION...');
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'x_return_status=' || x_return_status ||
							  ', x_msg_count=' || x_msg_count ||
							  ', x_msg_data=' || x_msg_data);
			end if;
      else
        l_inv_reservation_rec.reservation_id := p_trans_header_id;
        l_relieved_quantity := p_trans_record.QUANTITY;

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'Before calling inv_reservation_pub.relieve_reservation for reservation_id = '
						  || l_inv_reservation_rec.reservation_id || ' and qty = ' || l_relieved_quantity);
		end if;

		inv_reservation_pub.relieve_reservation(
              p_api_version_number    => 1.0
              ,p_init_msg_lst         => fnd_api.g_false
              ,x_return_status        => x_return_status
              ,x_msg_count            => x_msg_count
              ,x_msg_data             => x_msg_data
              ,p_rsv_rec              => l_inv_reservation_rec
              ,p_primary_relieved_quantity => l_relieved_quantity
              ,p_relieve_all          => fnd_api.g_false
              ,p_original_serial_number => l_serial_number
              ,p_validation_flag       => fnd_api.g_true
              ,x_primary_relieved_quantity  => l_relieved_quantity1
              ,x_primary_remain_quantity  => l_remaining_quantity
              );

		fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'After calling inv_reservation_pub.relieve_reservation...');
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'x_return_status=' || x_return_status ||
						  ', x_msg_count=' || x_msg_count ||
						  ', x_msg_data=' || x_msg_data ||
						  ', l_remaining_quantity=' || l_remaining_quantity);
		end if;

      end if;

      if x_return_status <> 'S' or x_msg_data is not NULL then
        return;
      end if;

  ------------
    l_actual_trans_type := getPartsReturnOrderType(p_trans_record.FRM_ORGANIZATION_ID,
                                        p_trans_record.FRM_SUBINVENTORY_CODE,
                                        p_trans_record.TO_ORGANIZATION_ID,
                                        p_trans_record.TO_SUBINVENTORY_CODE);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'l_actual_trans_type=' || l_actual_trans_type);
	end if;

    l_Trans_Items(1) := p_trans_record;

    if l_actual_trans_type = 'SUBINVTRANS' then

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'Before calling transact_subinv_transfer...');
		end if;

	  transact_subinv_transfer(
              P_Api_Version_Number => 1.0,
              P_Init_Msg_List => FND_API.G_TRUE,
              P_Commit => FND_API.G_TRUE,
              p_Trans_Items => l_Trans_Items,
              X_Return_Status => x_return_status,
              X_Msg_Count => x_msg_count,
              X_Msg_Data => x_msg_data
          );

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'After calling transact_subinv_transfer...');
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'x_return_status=' || x_return_status ||
						  ', x_msg_count=' || x_msg_count ||
						  ', x_msg_data=' || x_msg_data);
		end if;

    elsif l_actual_trans_type like 'INTORG%' then

      l_if_intransit := false;
      if l_actual_trans_type = 'INTORG_I' then
        l_if_intransit := true;
      end if;

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'Before calling transact_intorg_transfer...');
		end if;

	  transact_intorg_transfer(
              P_Api_Version_Number => 1.0,
              P_Init_Msg_List => FND_API.G_TRUE,
              P_Commit => FND_API.G_FALSE,
              p_Trans_Items => l_Trans_Items,
              p_if_intransit => l_if_intransit,
              X_Return_Status => x_return_status,
              X_Msg_Count => x_msg_count,
              X_Msg_Data => x_msg_data
          );

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'After calling transact_intorg_transfer...');
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
						  'x_return_status=' || x_return_status ||
						  ', x_msg_count=' || x_msg_count ||
						  ', x_msg_data=' || x_msg_data);
		end if;

    end if;


    if x_return_status = 'S'
        and x_msg_data is NULL
        and l_Trans_Items(1).ERROR_MSG is NULL then



      if x_return_status = 'S' then
        -- check this is for a task
        open check_task_req;
        fetch check_task_req into l_task_id, l_requirement_line_id;
        if check_task_req%notfound then
          --close check_task_req;

          -- remove this req_line_details link
          if l_remaining_quantity = 0 or p_close_short = 'Y' then
			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'Before calling csp_req_line_details_pkg.delete_row...');
			end if;
            csp_req_line_details_pkg.delete_row(p_req_line_detail_id);
			commit;
          end if;

        else
          -- create new reservation
          l_RESERVATION_REC.need_by_date := sysdate;
          l_RESERVATION_REC.organization_id := p_trans_record.TO_ORGANIZATION_ID;
          l_RESERVATION_REC.sub_inventory_code := p_trans_record.TO_SUBINVENTORY_CODE;
          l_RESERVATION_REC.item_id := p_trans_record.INVENTORY_ITEM_ID;
          l_RESERVATION_REC.item_uom_code := p_trans_record.UOM_CODE;
          l_RESERVATION_REC.quantity_needed := p_trans_record.QUANTITY;
          l_RESERVATION_REC.revision := p_trans_record.REVISION;
          l_RESERVATION_REC.line_id := l_requirement_line_id;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'Before calling CSP_SCH_INT_PVT.CREATE_RESERVATION...');
			end if;

		  l_new_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(
                      p_reservation_parts => l_RESERVATION_REC,
                      x_return_status => x_return_status,
                      x_msg_data => x_msg_data);

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'After calling CSP_SCH_INT_PVT.CREATE_RESERVATION...');
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
							  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
							  'x_return_status=' || x_return_status ||
							  ', x_msg_data=' || x_msg_data ||
							  ', l_new_reservation_id=' || l_new_reservation_id);
			end if;

          if ((x_return_status = 'S') and (l_new_reservation_id is not null)) then


            if l_remaining_quantity = 0 or p_close_short = 'Y' then

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
								  'Before calling csp_req_line_details_pkg.Update_Row...');
				end if;
               l_req_line_detail_id := p_req_line_detail_id;
               csp_req_line_details_pkg.Update_Row(px_REQ_LINE_DETAIL_ID => l_req_line_detail_id,
                  p_REQUIREMENT_LINE_ID => l_requirement_line_id,
                  p_CREATED_BY => FND_GLOBAL.user_id,
                  p_CREATION_DATE => sysdate,
                  p_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                  p_LAST_UPDATE_DATE => sysdate,
                  p_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id,
                  p_SOURCE_TYPE => 'RES',
                  p_SOURCE_ID => l_new_reservation_id);
            else

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
								  'Before calling csp_req_line_details_pkg.Insert_Row...');
				end if;
                  l_req_line_detail_id := FND_API.G_MISS_NUM;
                  csp_req_line_details_pkg.Insert_Row(px_REQ_LINE_DETAIL_ID => l_req_line_detail_id,
                  p_REQUIREMENT_LINE_ID => l_requirement_line_id,
                  p_CREATED_BY => FND_GLOBAL.user_id,
                  p_CREATION_DATE => sysdate,
                  p_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                  p_LAST_UPDATE_DATE => sysdate,
                  p_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id,
                  p_SOURCE_TYPE => 'RES',
                  p_SOURCE_ID => l_new_reservation_id);
            end if;
			commit;
          end if;

        end if;
        close check_task_req;

      end if;
    end if;
  elsif p_trans_type = 'MO' then
    -- call MO receiving API
    CSP_MO_MTLTXNS_UTIL.confirm_receipt(P_Api_Version_Number => 1.0,
       P_Init_Msg_List => FND_API.G_FALSE,
       P_Commit => FND_API.G_FALSE,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_packlist_line_id => p_trans_record.PACKLIST_LINE_ID,
       p_organization_id => p_trans_record.TO_ORGANIZATION_ID,
       p_transaction_temp_id => p_trans_record.TEMP_TRANSACTION_ID,
       p_quantity_received => p_trans_record.QUANTITY,
       p_to_subinventory_code => p_trans_record.TO_SUBINVENTORY_CODE,
       p_to_locator_id => p_trans_record.TO_LOCATOR_ID,
       p_serial_number => p_trans_record.SERIAL_NUMBER,
       p_lot_number => p_trans_record.LOT_NUMBER,
       p_revision => p_trans_record.REVISION,
       p_receiving_option => 0, --0 = receiving normal, 1 = receipt short, 2 = over receipt (but do not close the packlist and move order, 3 = over receipt (close everything)
       px_transaction_header_id => l_mo_transaction_header_id,
       p_process_flag => fnd_api.g_true,
       X_Return_Status => x_return_status,
       X_Msg_Count => x_msg_count,
       X_Msg_Data => x_msg_data);

  elsif p_trans_type = 'IO' then

	l_oe_header_id := p_trans_header_id;
	l_oe_line_id := p_trans_line_id;
    l_rcv_ship_line_id := p_trans_record.SHIPMENT_LINE_ID;

	open get_rcv_header_data;
	fetch get_rcv_header_data into
		l_rcv_ship_header_id,
		l_rcv_ship_line_id,
		l_receive_hdr_rec.source_type_code,
		l_receive_hdr_rec.receipt_source_code,
		l_receive_hdr_rec.rcv_shipment_num,
		l_receive_hdr_rec.ship_to_org_id,
		l_receive_hdr_rec.bill_of_lading,
		l_receive_hdr_rec.packing_slip,
		l_receive_hdr_rec.shipped_date,
		l_receive_hdr_rec.freight_carrier_code,
		l_receive_hdr_rec.expected_receipt_date,
		l_receive_hdr_rec.waybill_airbill_num,
		l_receive_hdr_rec.receipt_num;
	close get_rcv_header_data;

	l_receive_hdr_rec.receipt_header_id := l_rcv_ship_header_id;

	open get_rcv_line_data;
	fetch get_rcv_line_data into
		l_rcv_rec_type.source_type_code,
		l_rcv_rec_type.order_type_code,
		l_rcv_rec_type.item_id,
		l_rcv_rec_type.item_revision,
		l_rcv_rec_type.item_category_id,
		l_rcv_rec_type.item_description,
		l_rcv_rec_type.from_organization_id,
		l_rcv_rec_type.ordered_qty,
		l_rcv_rec_type.ordered_uom,
		l_rcv_rec_type.transaction_quantity,
		l_rcv_rec_type.req_line_id,
		l_rcv_rec_type.receipt_source_code,
		l_rcv_rec_type.lot_number,
		l_rcv_rec_type.primary_uom,
		l_rcv_rec_type.primary_uom_class,
		l_rcv_rec_type.fm_serial_number,
		l_rcv_rec_type.to_organization_id,
		l_rcv_rec_type.destination_subinventory,
		l_rcv_rec_type.destination_type_code,
		l_rcv_rec_type.routing_id,
		l_rcv_rec_type.ship_to_location_id,
		l_rcv_rec_type.enforce_ship_to_location_code,
		l_rcv_rec_type.set_of_books_id_sob,
		l_rcv_rec_type.currency_code_sob,
		l_rcv_rec_type.serial_number_control_code,
		l_rcv_rec_type.lot_control_code,
        l_rcv_rec_type.lot_quantity,
		l_rcv_rec_type.item_revision;
	close get_rcv_line_data;

	if l_rcv_rec_type.serial_number_control_code = 1 then
		l_rcv_rec_type.transaction_quantity := p_trans_record.QUANTITY;
	end if;

	-- we should change destination subinv from the part req's destination subinv
	-- this change is required to make sure other tech can receive a part
	-- which was processed and shipped for a different tech
	-- condition is old and new destination org is same and only subinv is different
	open c_dest_info;
	fetch c_dest_info into l_req_dest_org_id, l_req_dest_subinv;
	close c_dest_info;

	if l_req_dest_org_id = l_rcv_rec_type.to_organization_id
		and l_req_dest_subinv <> l_rcv_rec_type.destination_subinventory then
		l_rcv_rec_type.destination_subinventory := l_req_dest_subinv;
	end if;

	l_rcv_rec_type.transaction_uom := l_rcv_rec_type.ordered_uom;
	l_rcv_rec_type.rcv_shipment_header_id := l_rcv_ship_header_id;
	l_rcv_rec_type.rcv_shipment_line_id := l_rcv_ship_line_id;
	l_rcv_rec_type.oe_order_header_id := l_oe_header_id;
	l_rcv_rec_type.oe_order_line_id := l_oe_line_id;
	l_rcv_rec_type.to_serial_number := l_rcv_rec_type.fm_serial_number;
	l_rcv_rec_type.product_code := 'RCV';
        l_rcv_rec_type.locator_id := p_trans_record.TO_LOCATOR_ID;
	l_receive_rec_tbl(1) := l_rcv_rec_type;

	CSP_RECEIVE_PVT.receive_shipments(
					P_Api_Version_Number => 1.0,
					P_init_Msg_List => 'T',
					P_Commit => 'T',
					P_Validation_Level => 100,
					p_receive_hdr_rec => l_receive_hdr_rec,
					p_receive_rec_tbl => l_receive_rec_tbl,
					X_Return_Status => x_return_status,
					X_Msg_Count => x_msg_count,
					X_Msg_Data => x_msg_data
				);

	if x_return_status = 'S' then
        -- bug 12681895
        open check_task_req;
        fetch check_task_req into l_task_id, l_requirement_line_id;
        close check_task_req;

        if l_task_id is not null then

            SELECT NVL(h.need_by_date, sysdate)
            INTO l_hdr_need_by
            FROM csp_requirement_headers h,
              csp_requirement_lines l
            WHERE l.requirement_line_id = l_requirement_line_id
            AND l.requirement_header_id = h.requirement_header_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                              'l_hdr_need_by = ' || to_char(l_hdr_need_by, 'DD-MON-YYYY HH24:MI:SS'));
            end if;

            -- create new reservation
            l_RESERVATION_REC.need_by_date := l_hdr_need_by;
            l_RESERVATION_REC.organization_id := p_trans_record.TO_ORGANIZATION_ID;
            l_RESERVATION_REC.sub_inventory_code := p_trans_record.TO_SUBINVENTORY_CODE;
            l_RESERVATION_REC.item_id := p_trans_record.INVENTORY_ITEM_ID;
            l_RESERVATION_REC.item_uom_code := p_trans_record.UOM_CODE;
            l_RESERVATION_REC.quantity_needed := p_trans_record.QUANTITY;
            l_RESERVATION_REC.revision := l_rcv_rec_type.item_revision;
            l_RESERVATION_REC.line_id := l_requirement_line_id;
			l_RESERVATION_REC.serial_number := l_rcv_rec_type.to_serial_number;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                              'Before calling CSP_SCH_INT_PVT.CREATE_RESERVATION...');
            end if;

            l_new_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(
                      p_reservation_parts => l_RESERVATION_REC,
                      x_return_status => x_return_status,
                      x_msg_data => x_msg_data);

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                              'After calling CSP_SCH_INT_PVT.CREATE_RESERVATION...');
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                              'x_return_status=' || x_return_status ||
                              ', x_msg_data=' || x_msg_data ||
                              ', l_new_reservation_id=' || l_new_reservation_id);
            end if;

            if ((x_return_status = 'S') and (l_new_reservation_id is not null)) then
                l_req_line_detail_id := p_req_line_detail_id;

                -- check how much reserved
                select reservation_quantity into l_total_reserved_qty
                from mtl_reservations where reservation_id = l_new_reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                  'l_total_reserved_qty = ' || l_total_reserved_qty);
                end if;

                SELECT nvl(SUM(mr.reservation_quantity), 0)
                INTO l_already_res_qty
                FROM mtl_reservations mr,
                  csp_req_line_details cd
                WHERE mr.reservation_id    = cd.source_id
                AND cd.source_type         = 'RES'
                AND cd.requirement_line_id = l_requirement_line_id
                AND cd.source_id          <> l_new_reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                  'l_already_res_qty = ' || l_already_res_qty);
                end if;

                -- check how much required
                SELECT req.quantity
                INTO l_total_req_qty
                FROM po_requisition_lines_all req,
                  oe_order_lines_all ord,
                  csp_req_line_details csp
                WHERE req.requisition_line_id = ord.source_document_line_id
                AND ord.line_id               = csp.source_id
                AND csp.source_type           = 'IO'
                AND csp.req_line_detail_id    = l_req_line_detail_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                  'l_total_req_qty = ' || l_total_req_qty);
                end if;

                SELECT COUNT(*)
                INTO l_res_exists
                FROM csp_req_line_details
                WHERE requirement_line_id = l_requirement_line_id
                AND source_type           = 'RES'
                AND source_id             = l_new_reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                  'l_res_exists = ' || l_res_exists);
                end if;

                if (l_total_reserved_qty + l_already_res_qty) >= l_total_req_qty then

                    if l_res_exists = 0 then
                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                          'Before calling csp_req_line_details_pkg.Insert_Row...');
                        end if;

                       l_req_line_detail_id := null;
					   csp_req_line_details_pkg.Insert_Row(px_REQ_LINE_DETAIL_ID => l_req_line_detail_id,
                          p_REQUIREMENT_LINE_ID => l_requirement_line_id,
                          p_CREATED_BY => FND_GLOBAL.user_id,
                          p_CREATION_DATE => sysdate,
                          p_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                          p_LAST_UPDATE_DATE => sysdate,
                          p_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id,
                          p_SOURCE_TYPE => 'RES',
                          p_SOURCE_ID => l_new_reservation_id);
                    else
                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                          'deleting.... l_req_line_detail_id = ' || l_req_line_detail_id);
                        end if;
                        --csp_req_line_details_pkg.delete_row(l_req_line_detail_id);
                    end if;
                else

                    if l_res_exists = 0 then
                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
                                          'Before calling csp_req_line_details_pkg.Insert_Row...');
                        end if;

                        l_req_line_detail_id := null;
                        csp_req_line_details_pkg.Insert_Row(
                          px_REQ_LINE_DETAIL_ID => l_req_line_detail_id,
                          p_REQUIREMENT_LINE_ID => l_requirement_line_id,
                          p_CREATED_BY => FND_GLOBAL.user_id,
                          p_CREATION_DATE => sysdate,
                          p_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                          p_LAST_UPDATE_DATE => sysdate,
                          p_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id,
                          p_SOURCE_TYPE => 'RES',
                          p_SOURCE_ID => l_new_reservation_id);
                    end if;

                end if; -- if l_remaining_quantity = 0 then
            end if; -- if ((x_return_status = 'S') and
        end if; -- if l_task_id is not null then
        commit;
	end if; -- if x_return_status = 'S' then
  end if;   -- if IO

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'Leaving receive_requirement_trans...');
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.receive_requirement_trans',
					  'x_return_status=' || x_return_status ||
					  ', x_msg_count=' || x_msg_count ||
					  ', x_msg_data=' || x_msg_data);
	end if;

END receive_requirement_trans;

FUNCTION getPartsReturnOrderType (
      p_source_org_id      IN NUMBER,
      p_source_subinv      IN VARCHAR2,
      p_dest_org_id        IN NUMBER,
      p_dest_subinv        IN VARCHAR2
   ) RETURN VARCHAR2 IS

    v_ret_order_type varchar2(15);
    v_auto_receipt_flag varchar2(1);
    v_stocking_site_type varchar2(30);
    v_intransit_flag number;
    v_internal_order_req_flag number;

    CURSOR get_auto_receipt_flag(cp_org_id number, cp_subinv varchar2) IS
      select autoreceipt_flag
      from csp_sec_inventories
      where organization_id = cp_org_id
      and secondary_inventory_name = cp_subinv;

    CURSOR getStockingSiteType(cp_org_id number, cp_subinv varchar2) IS
      select nvl(stocking_site_type, 'TECHNICIAN')
      from csp_stocking_site_details_v
      where organization_id = cp_org_id
      and nvl(subinventory_code, 'NULL') = nvl(cp_subinv, 'NULL');

    CURSOR getIntransitDetail(cp_s_org_id number, cp_d_org_id number) IS
      select internal_order_required_flag,
        INTRANSIT_TYPE
      from MTL_SHIPPING_NETWORK_VIEW
      where from_organization_id = cp_s_org_id
      and to_organization_id = cp_d_org_id;
BEGIN
    v_ret_order_type := null;
    v_stocking_site_type := 'TECHNICIAN';    -- default assum 'TECHNICIAN'

    IF p_source_org_id = p_dest_org_id THEN
      if nvl(p_source_subinv, 'NULL') = nvl(p_dest_subinv, 'NULL') then
         v_ret_order_type := 'RES';
      else
         -- bug # 13345661
         -- even if same organization, if the source is Manned Warehouse,
         -- we should create Internal Order
         open getStockingSiteType(p_source_org_id, p_source_subinv);
         fetch getStockingSiteType into v_stocking_site_type;
         close getStockingSiteType;

         if v_stocking_site_type = 'MANNED' then
            v_ret_order_type := 'IO';
         else
            open get_auto_receipt_flag(p_dest_org_id, p_dest_subinv);
            fetch get_auto_receipt_flag into v_auto_receipt_flag;
            close get_auto_receipt_flag;

            if v_auto_receipt_flag = 'Y' then
                v_ret_order_type := 'SUBINVTRANS';
            else
                v_ret_order_type := 'MO';
            end if;
         end if;
      end if;
    ELSE
      open getStockingSiteType(p_source_org_id, p_source_subinv);
      fetch getStockingSiteType into v_stocking_site_type;
      close getStockingSiteType;

      if v_stocking_site_type = 'TECHNICIAN' then
        open getIntransitDetail(p_source_org_id, p_dest_org_id);
        fetch getIntransitDetail into v_internal_order_req_flag, v_intransit_flag;
        close getIntransitDetail;

        if v_internal_order_req_flag = 2 then   -- IO not required
          if v_intransit_flag = 1 then    -- Direct
            v_ret_order_type := 'INTORG_D';
          else
            v_ret_order_type := 'INTORG_I';
          end if;
        else
          v_ret_order_type := 'IO';   -- I'm not sure if it is correct
        end if;
      else  -- source is warehouse
        if v_stocking_site_type = 'MANNED' then
          v_ret_order_type := 'IO';
        else
          v_ret_order_type := 'INTORG_D';
        end if;
      end if;
    END IF;

    return (v_ret_order_type);
END getPartsReturnOrderType;

function res_for_rcv_trans(p_subscription_guid IN RAW,
                    p_event IN OUT NOCOPY wf_event_t) return varchar2 is

    l_shipment_header_id    number;
    l_reservation_parts CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
    l_reservation_id NUMBER;
    l_req_line_detali_id NUMBER;
    x_return_Status varchar2(1);
    x_msg_data varchar2(4000);

    cursor c_ship_detail is
    SELECT rsl.to_organization_id AS organization_id,
      rsl.to_subinventory         AS subinv_code,
      rsl.item_id,
      rsl.item_revision     AS revision,
      rsl.quantity_received AS rcv_qty,
      (SELECT quantity
      FROM po_requisition_lines_all
      WHERE requisition_line_id = oola.source_document_line_id
      )                              AS ord_qty,
      mmt.transaction_uom            AS uom,
      NVL(crh.need_by_date, sysdate) AS need_by_date,
      crld.req_line_detail_id,
      crl.requirement_line_id
    FROM csp_requirement_headers crh,
      csp_requirement_lines crl,
      csp_req_line_details crld,
      rcv_shipment_lines rsl,
      oe_order_lines_all oola,
      mtl_material_transactions mmt
    WHERE rsl.SHIPMENT_HEADER_ID  = l_shipment_header_id
    AND rsl.mmt_transaction_id    = mmt.transaction_id
    AND rsl.requisition_line_id   = oola.source_document_line_id
    AND oola.line_id              = crld.source_id
    AND crld.source_type          = 'IO'
    AND crld.requirement_line_id  = crl.requirement_line_id
    AND crl.requirement_header_id = crh.requirement_header_id
    AND crh.task_id              IS NOT NULL
    AND mmt.transaction_action_id in (2, 3)
    AND not exists (select 1 from csp_req_line_details crld2
                      where crld2.requirement_line_id = crld.requirement_line_id
                      and crld2.source_type = 'RES');

    l_res_exists number;
    l_already_res_qty number;
    l_total_reserved_qty number;

begin

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
					  'begin...');
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
					  'event name = ' || p_event.geteventname());
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
					  'event key = ' || p_event.geteventkey());
    end if;

    l_shipment_header_id := p_event.GetValueForParameter('SHIPMENT_HEADER_ID');

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
					  'l_shipment_header_id = ' || l_shipment_header_id);
    end if;

    for grd in c_ship_detail loop

        l_reservation_id := NULL;
        l_reservation_parts.need_by_date       := grd.need_by_date;
        l_reservation_parts.organization_id    := grd.organization_id ;
        l_reservation_parts.item_id            := grd.item_id;
        l_reservation_parts.item_uom_code      := grd.uom;
        l_reservation_parts.quantity_needed    := grd.rcv_qty ;
        l_reservation_parts.sub_inventory_code := grd.subinv_code ;
        l_reservation_parts.revision           := grd.revision;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.need_by_date = '
                          || to_char(l_reservation_parts.need_by_date, 'DD-MON-YYYY HH24:MI:SS'));
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.organization_id = ' || l_reservation_parts.organization_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.item_id = ' || l_reservation_parts.item_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.item_uom_code = ' || l_reservation_parts.item_uom_code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.quantity_needed = ' || l_reservation_parts.quantity_needed);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.sub_inventory_code = ' || l_reservation_parts.sub_inventory_code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_parts.revision = ' || l_reservation_parts.revision);
        end if;

        l_reservation_id := csp_sch_int_pvt.CREATE_RESERVATION(l_reservation_parts
                                                            ,x_return_status
                                                            ,x_msg_data );

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_reservation_id = ' || l_reservation_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'x_return_status = ' || x_return_status);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'x_msg_data = ' || x_msg_data);
        end if;


        SELECT COUNT(*)
        INTO l_res_exists
        FROM csp_req_line_details
        WHERE requirement_line_id = grd.requirement_line_id
        AND source_type           = 'RES'
        AND source_id             = l_reservation_id;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                          'l_res_exists = ' || l_res_exists);
        end if;

        l_req_line_detali_id := NULL;

        IF l_reservation_id IS NOT NULL AND l_reservation_id > 0 THEN

            if l_res_exists = 0 then
                csp_req_line_details_pkg.insert_row(px_req_line_detail_id => l_req_line_detali_id
                                  ,p_requirement_line_id => grd.requirement_line_id
                                  ,p_created_by => FND_GLOBAL.user_id
                                  ,p_creation_date => sysdate
                                  ,p_last_updated_by =>  FND_GLOBAL.user_id
                                  ,p_last_update_date => sysdate
                                  ,p_last_update_login => FND_GLOBAL.login_id
                                  ,p_source_type => 'RES'
                                  ,p_source_id => l_reservation_id );
            end if;

            /*
			select reservation_quantity into l_total_reserved_qty
            from mtl_reservations where reservation_id = l_reservation_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                              'l_total_reserved_qty = ' || l_total_reserved_qty);
            end if;

            SELECT nvl(SUM(mr.reservation_quantity), 0)
            INTO l_already_res_qty
            FROM mtl_reservations mr,
              csp_requirement_lines cl,
              csp_req_line_details cd
            WHERE mr.reservation_id    = cd.source_id
            AND cd.source_type         = 'RES'
            AND cl.requirement_line_id = grd.requirement_line_id
            AND cd.requirement_line_id = cl.requirement_line_id
            AND cd.source_id          <> l_reservation_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                              'l_already_res_qty = ' || l_already_res_qty);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
                              'grd.ord_qty = ' || grd.ord_qty);
            end if;

            IF (l_total_reserved_qty + l_already_res_qty) >= grd.ord_qty THEN
                csp_req_line_details_pkg.delete_row(grd.req_line_detail_id);
            END IF;
			*/

        END IF;

    end loop;   -- for grd in c_ship_detail loop

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_TRANSACTIONS_PUB.res_for_rcv_trans',
					  'done...');
    end if;

    return 'SUCCESS';
end res_for_rcv_trans;

function gen_numbers(n in number default null)
    return csparray PIPELINED
is
begin
 for i in 1 .. nvl(n,999999999)
 loop
     pipe row(i);
 end loop;
 return;
end gen_numbers;

END csp_transactions_pub;

/
