--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_REPAIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_REPAIR" AS
/* $Header: cspvprpb.pls 120.1 2006/04/24 15:49:44 phegde noship $ */
--
--
-- Purpose: This package will contain procedures for creating internal orders
--          and repair order for repair notifications

-- MODIFICATION HISTORY
-- Person      Date      Comments
-- phegde      05/02/03  Created package

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csp_parts_repair';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvprpb.pls';


   PROCEDURE create_orders
    (  p_api_version             IN NUMBER
      ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
      ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
      ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
      ,p_Repair_supplier_id      IN NUMBER
      ,x_return_status           OUT NOCOPY VARCHAR2
      ,x_msg_count               OUT NOCOPY NUMBER
      ,x_msg_data                OUT NOCOPY VARCHAR2)
    IS
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'create_orders';
    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_line_Rec                  csp_parts_Requirement.line_rec_type;
    l_order_hdr_rec             csp_parts_requirement.header_rec_type;
    l_order_line_tbl            csp_parts_requirement.line_tbl_type;
    l_IO1_header_id             NUMBER;
    l_IR1_requisition_id        NUMBER;
    l_IO2_header_id             NUMBER;
    l_IR2_requisition_id        NUMBER;
/*    l_Repair_order_Rec        csd_repairs_pub.repln_rec_Type;
    l_repair_line_id            NUMBER; */
    l_service_request_number       VARCHAR2(30);

    -- Get unique requisition_header_id
    CURSOR req_header_id_cur IS
      SELECT po_requisition_headers_s.nextval
      FROM sys.dual;

    CURSOR supercess_items_cur(p_item_id NUMBER) IS
      SELECT related_item_id
      FROM mtl_related_items_view
      WHERE relationship_type_id = 18
      AND inventory_item_id = p_item_id;

    l_Repair_to_item_id         NUMBER;

  BEGIN
       SAVEPOINT Create_Orders_PUB;
       -- initialize return status
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_line_Rec := px_line_Table(1);

       IF p_repair_supplier_id IS NOT NULL THEN
         -- create internal order 1 with repair supplier found above as destination

         -- create header record for creating IO1
         FND_PROFILE.GET('CSP_ORDER_TYPE', l_order_hdr_rec.order_type_id);

         -- get ship to of repair organization
         begin
           select location_id
           into l_order_hdr_Rec.ship_to_location_id
           from hr_organization_units
           where organization_id = p_repair_supplier_id;
         exception
           when no_data_found then
             null;
         end;
         l_order_hdr_Rec.dest_organization_id := p_repair_supplier_id;
         l_order_hdr_rec.operation := csp_parts_requirement.G_OPR_CREATE;

         -- FIND NEED_BY_DATE

         -- create line record for creating IO1
         l_line_Rec.line_num := 1;
         l_order_line_tbl(1) := l_line_Rec;

         -- call process order
         csp_parts_order.process_order(
             p_api_version             => l_api_Version_number
            ,p_Init_Msg_List           => FND_API.G_TRUE
            ,p_commit                  => FND_API.G_FALSE
            ,px_header_rec             => l_order_hdr_Rec
            ,px_line_table             => l_order_Line_Tbl
            ,p_process_type            => 'BOTH'
            ,x_return_status           => l_return_status
            ,x_msg_count               => l_msg_count
            ,x_msg_data                => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_IO1_header_id := l_order_hdr_Rec.order_header_id;
            l_IR1_requisition_id := l_order_hdr_rec.requisition_header_id;
        END IF;

       -- create IO2 with with p_header_REc.dest_organization_id as destination
       -- and repair supplier found above as source

         l_line_Rec := px_line_Table(1);

       -- get ship to of FS organization
         begin
           select location_id
           into l_order_hdr_Rec.ship_to_location_id
           from hr_organization_units
           where organization_id = px_header_rec.dest_organization_id;
         exception
           when no_data_found then
             null;
         end;
         l_order_hdr_Rec.dest_organization_id := px_header_rec.dest_organization_id;
         l_order_hdr_rec.operation := csp_parts_requirement.G_OPR_CREATE;
         l_order_hdr_rec.requisition_number := NULL;
         l_order_hdr_rec.order_header_id := NULL;
         l_order_hdr_rec.requisition_header_id := NULL;

         -- create line record for creating IO2
         OPEN supercess_items_cur(px_line_table(1).inventory_item_id);
         FETCH supercess_items_cur INTO l_repair_to_item_id;
         CLOSE supercess_items_cur;
         l_line_rec.inventory_item_id := nvl(l_repair_to_item_id, px_line_table(1).inventory_item_id);

         l_line_rec.source_organization_id := p_repair_supplier_id;
         l_line_rec.requisition_line_id := NULL;
         l_line_rec.line_num := 1;
         l_line_rec.order_line_id := NULL;
         l_line_rec.source_subinventory := NULL;
         l_order_line_tbl(1) := l_line_Rec;

         -- call process order
         csp_parts_order.process_order(
             p_api_version             => l_api_Version_number
            ,p_Init_Msg_List           => FND_API.G_TRUE
            ,p_commit                  => FND_API.G_FALSE
            ,px_header_rec             => l_order_hdr_Rec
            ,px_line_table             => l_order_Line_Tbl
            ,p_process_type            => 'BOTH'
            ,x_return_status           => l_return_status
            ,x_msg_count               => l_msg_count
            ,x_msg_data                => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_IO2_header_id := l_order_hdr_Rec.order_header_id;
            l_IR2_requisition_id := l_order_hdr_rec.requisition_header_id;
        END IF;

       -- create repair order
       CSD_Refurbish_IRO_GRP.Create_InternalRO(
            P_api_version                => l_api_Version_number,
            P_init_msg_list              => FND_API.G_FALSE,
            P_commit                     => FND_API.G_TRUE,
            P_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                 => l_msg_data,
            P_req_header_id_in           => l_IR1_requisition_id,
            P_ISO_header_id_in           => l_IO1_header_id,
            P_req_header_id_out     => l_IR2_requisition_id,
            P_ISO_header_id_out          => l_IO2_header_id,
            x_service_request_number     => l_service_Request_number);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;
       px_header_rec.order_header_id := l_IO2_header_id;
       x_Return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

  EXCEPTION
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
      Rollback to create_orders_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;
END;

/
