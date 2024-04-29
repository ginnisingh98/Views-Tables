--------------------------------------------------------
--  DDL for Package Body CSP_PLANNED_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PLANNED_ORDERS" AS
/* $Header: cspvppob.pls 120.11 2008/03/26 17:11:46 hhaugeru ship $ */
--
-- Purpose: To create planned orders for a warehouse
--
-- MODIFICATION HISTORY
-- Person      Date      Comments
-- ---------   ------    ------------------------------------------
-- phegde      6/13/2005 Created package body

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csp_planned_orders';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvppob.pls';

   PROCEDURE create_orders
        ( p_api_version             IN NUMBER
        , p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        , p_organization_id         NUMBER
        , p_inventory_item_id       NUMBER
        , px_line_tbl               CSP_PLANNED_ORDERS.Line_Tbl_Type
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_msg_count               OUT NOCOPY NUMBER
        , x_msg_data                OUT NOCOPY VARCHAR2)
   IS
   l_api_version_number        CONSTANT NUMBER := 1.0;
   l_api_name                  CONSTANT VARCHAR2(30) := 'create_orders';
   l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);
   l_line_tbl                  csp_planned_orders.line_tbl_type;
   l_order_line_tbl            csp_parts_requirement.line_tbl_type;
   l_order_hdr_rec             csp_parts_requirement.header_rec_type;
   l_po_line_tbl               csp_parts_requirement.line_tbl_type;
   l_po_hdr_rec                csp_parts_requirement.header_rec_type;
   l_defective_parts_tbl       csp_repair_po_grp.defective_parts_tbl_Type;
   l_int_rpr_line_tbl          csp_parts_Requirement.line_Tbl_Type;
   l_int_rpr_header_rec        csp_parts_Requirement.header_rec_type;
   J                           NUMBER := 1;
   K                           NUMBER := 1;
   l_wip_id                    NUMBER;
   l_user_id                   NUMBER;
   l_location_id               NUMBER;
   l_repair_supplier_id        NUMBER;
   l_repair_supplier_org_id    NUMBER;
   l_repair_organization_id    NUMBER;
   l_requisition_header_id     NUMBER;
   l_source_type               NUMBER;
   l_repair_program            NUMBER;

   CURSOR item_attr_cur IS
     SELECT c.description                       item_Description,
           c.planning_make_buy_code             mbf,
           c.primary_uom_code                   uom,
           p.ap_accrual_account                 accru_Acct,
           p.invoice_price_var_account          ipv_acct,
           nvl(p.encumbrance_account,
               c.encumbrance_account)           budget_Acct,
           decode(c.inventory_asset_flag, 'Y', p.material_account,
                  NVL(c.expense_Account, p.expense_Account)) charge_Acct,
           NVL(c.source_type, p.source_type)    src_type,
           DECODE(c.source_type, NULL,
                  DECODE(p.source_type, NULL, NULL, p.source_organization_id),
                  c.source_organization_id)     src_org,
           DECODE(c.source_type, NULL,
                  DECODE(p.source_type, NULL, NULL, p.source_subinventory),
                  c.source_subinventory)        src_subinv,
           c.purchasing_enabled_flag            purch_flag,
           c.internal_order_enabled_flag        order_flag,
           c.mtl_transactions_enabled_flag      transact_flag,
           c.list_price_per_unit                unit_price,
           c.planner_code                       planner,
           build_in_wip_flag                    build_in_wip,
           pick_components_flag                 pick_components
    FROM mtl_system_items c,
         mtl_parameters p
    WHERE c.inventory_item_id = p_inventory_item_id
    AND   c.organization_id = p.organization_id
    AND   p.organization_id = p_organization_id;

    l_item_attr_rec item_attr_cur%ROWTYPE;
    EXCP_USER_DEFINED EXCEPTION;

    CURSOR uom_code_cur(t_organization_id NUMBER,
                        t_item_id NUMBER) IS
      SELECT primary_uom_code
      FROM mtl_system_items_b
      WHERE organization_id = t_organization_id
      AND inventory_item_id = t_item_id;

    CURSOR C_supplier (p_organization_id NUMBER,l_supplied_item_id NUMBER)
    is select misl.source_type, misl.source_organization_id, misl.vendor_id
          into l_source_type, l_repair_organization_id, l_repair_supplier_id
          from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
          where cpp.organization_id = p_organization_id
          and misl.organization_id = cpp.organization_id
          and misl.assignment_set_id =cpp.repair_assignment_set_id
          and inventory_item_id = l_supplied_item_id --l_line_tbl(I).supplied_item_id
          and SOURCE_TYPE in (1,3)
          and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                            where organization_id = p_organization_id
                            and assignment_set_id =  cpp.repair_assignment_set_id
                            and inventory_item_id = l_supplied_item_id --l_line_tbl(I).supplied_item_id
                            and sourcing_level not in (2,9))
          order by misl.rank,misl.source_type;

     l_supplier_count NUMBER;
     l_supplier_available NUMBER := 0;

   BEGIN
     SAVEPOINT Create_Orders_PUB;
       -- initialize return status
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     SELECT fnd_global.user_id INTO l_user_id from dual;

     l_line_tbl := px_line_tbl;
     -- get ship to of warehouse
     begin
       select location_id
       into l_location_id
       from hr_organization_units
       where organization_id = p_organization_id;
     exception
       when no_data_found then
         null;
     end;

     FOR I IN 1..l_line_tbl.COUNT LOOP
       IF (l_line_tbl(I).uom_code IS NULL) THEN
           OPEN uom_code_cur(l_line_tbl(I).source_organization_id,
                             l_line_tbl(I).supplied_item_id);
           FETCH uom_code_cur INTO l_line_tbl(I).uom_code;
           CLOSE uom_code_cur;
       END IF;

       IF l_line_Tbl(I).planned_order_type = 4110 THEN -- excess
         IF l_order_hdr_rec.dest_organization_id IS NULL THEN
           l_order_hdr_rec.dest_organization_id := p_organization_id;
           FND_PROFILE.GET('CSP_ORDER_TYPE', l_order_hdr_rec.order_type_id);
           l_order_hdr_Rec.ship_to_location_id := l_location_id;
         END IF;
         l_order_line_tbl(J).inventory_item_id := l_line_Tbl(I).supplied_item_id;
         l_order_line_tbl(J).quantity := l_line_Tbl(I).quantity;
         l_order_line_tbl(J).ordered_quantity := l_line_Tbl(I).quantity;
         l_order_line_tbl(J).unit_of_measure := l_line_Tbl(I).uom_code;
         l_order_line_tbl(J).source_organization_id := l_line_Tbl(I).source_organization_id;
         l_order_line_tbl(J).need_by_Date := l_line_tbl(I).plan_Date;
         l_order_line_tbl(J).line_num := J;
         J := J + 1;
       ELSIF l_line_tbl(I).planned_order_type = 4210 THEN -- repair
         -- check if this is an internal or external repair supplier

              Open c_supplier(p_organization_id,l_line_tbl(I).supplied_item_id);
              Loop
                 Fetch c_supplier into l_source_type, l_repair_organization_id, l_repair_supplier_id;
                 Exit when c_supplier%NotFound;
                 If (l_source_type = 3 and
                     l_repair_organization_id IS NOT NULL and
                     l_repair_supplier_id IS NOT NULL) Then

                   Select count(*)
                     into l_supplier_count
                     from hr_organization_information
                    where ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
                      and org_information3 = l_repair_supplier_id
                      and organization_id = l_repair_organization_id;

                    If l_supplier_count > 0 then
                       l_supplier_available := 1;
                       Exit;
                    End if;
                 Elsif (l_source_type = 1 and l_repair_organization_id IS NOT NULL) then
                    l_supplier_available := 1;
                    Exit;
                 End if;
              End loop;
              Close c_supplier;

              If l_supplier_available = 0 then
                 FND_MESSAGE.SET_NAME('CSP', 'CSP_REPAIR_ASSIGNMENT_NULL');
                 FND_MSG_PUB.ADD;
                 RAISE EXCP_USER_DEFINED;
              End if;

/*
         begin
           select misl.source_type, misl.source_organization_id, misl.vendor_id
           into l_source_type, l_repair_organization_id, l_repair_supplier_id
           from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
           where cpp.organization_id = p_organization_id
           and misl.organization_id = cpp.organization_id
           and misl.assignment_set_id =cpp.repair_assignment_set_id
           and inventory_item_id = l_line_tbl(I).supplied_item_id
           and SOURCE_TYPE       in (1,3)
           and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                             where organization_id = p_organization_id
                             and assignment_set_id =  cpp.repair_assignment_set_id
                             and inventory_item_id = l_line_tbl(I).supplied_item_id
                             and sourcing_level not in (2,9))
           order by misl.rank;
*/
           IF (l_source_type = 3 and l_repair_supplier_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('CSP', 'CSP_REPAIR_SUPPLIER_NULL');
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
           END IF;
/*
         exception
           WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME('CSP', 'CSP_REPAIR_ASSIGNMENT_NULL');
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
         end;
*/
         IF (l_source_type = 1) THEN
           l_int_rpr_header_rec.dest_organization_id := p_organization_id;
           l_int_rpr_header_rec.need_by_date := l_line_Tbl(I).plan_date;
           l_int_rpr_line_tbl(1).inventory_item_id := l_line_Tbl(I).supplied_item_id;
           l_int_rpr_line_tbl(1).quantity := l_line_Tbl(I).quantity;
           l_int_rpr_line_tbl(1).ordered_quantity := l_line_Tbl(I).quantity;
           l_int_rpr_line_tbl(1).unit_of_measure := l_line_Tbl(I).uom_code;
           l_int_rpr_line_tbl(1).source_organization_id := l_line_Tbl(I).source_organization_id;

           csp_parts_repair.create_orders(
                p_api_Version   => 1.0,
                p_init_msg_list => null,
                p_commit        => null,
                px_header_rec   => l_int_rpr_header_rec,
                px_line_table   => l_int_rpr_line_tbl,
                p_repair_supplier_id => l_repair_organization_id,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data
                );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
           END If;
         ELSE
           begin
             Select organization_id
             into l_repair_supplier_org_id
             from hr_organization_information
             where ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
             and org_information3 = l_repair_supplier_id;

             Begin
              SELECT repair_program
              INTO l_repair_program
              FROM mtl_system_items_b
              WHERE organization_id = l_repair_supplier_org_id
              AND inventory_item_id = p_inventory_item_id;
             Exception
              When no_data_found then
              l_repair_program := 3; --Repair Return
             End;

             IF l_Repair_Supplier_id IS NOT NULL THEN

               l_Defective_parts_tbl(1).defective_item_id := l_line_tbl(I).supplied_item_id;
               l_Defective_parts_tbl(1).defective_quantity := l_line_tbl(I).quantity;
               CSP_REPAIR_PO_GRP.CREATE_REPAIR_PO
                    (p_api_version             => 1.0
                    ,p_Init_Msg_List           => null
                    ,p_commit                  => FND_API.G_FALSE
                    ,P_repair_supplier_id	   => l_repair_supplier_id
                    ,P_repair_supplier_org_id  => l_repair_supplier_org_id
                    ,P_repair_program		   => l_repair_program
                    ,P_dest_organization_id	   => p_organization_id
                    ,P_source_organization_id  => l_line_Tbl(I).source_organization_id
                    ,P_repair_to_item_id	   => p_inventory_item_id
                    ,P_quantity				   => l_line_Tbl(I).quantity
                    ,P_need_by_date            => l_line_Tbl(I).plan_date
                    ,P_defective_parts_tbl	   => l_defective_parts_tbl
                    ,x_requisition_header_id   => l_requisition_header_id
                    ,x_return_status           => l_Return_status
                    ,x_msg_count               => l_msg_count
                    ,x_msg_data                => l_msg_data
                    );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
               END If;
             ELSE
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIR_SUPPLIER_ORG');
               FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_NAME', to_char(null), TRUE);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
             END IF;
           exception
             when no_data_found then
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIR_SUPPLIER_ORG');
               FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_NAME', to_char(null), TRUE);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
           end;
         END IF;
       ELSIF l_line_tbl(I).planned_order_type = 4310 THEN
         -- check item make buy code
         IF (l_item_attr_rec.uom IS NULL) THEN
           OPEN item_Attr_cur;
           FETCH item_attr_cur INTO l_item_attr_rec;
           CLOSE item_attr_cur;
         END IF;

       /*  IF (l_item_attr_rec.mbf = 1) THEN
           SELECT WIP_JOB_SCHEDULE_INTERFACE_S.nextval
           INTO l_wip_id
           FROM dual;

           IF (l_item_attr_rec.build_in_wip <> 'Y' OR
               l_item_attr_rec.pick_components <> 'N') THEN
             FND_MESSAGE.SET_NAME('CSP', 'CSP_WIP_ORDER_ERROR');
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
           END IF;

           INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                LAST_UNIT_COMPLETION_DATE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,STATUS_TYPE)
           VALUES(
               sysdate,
               l_user_id,
               sysdate,
               nvl(fnd_global.login_id, 0),
               l_wip_id,
               2,
               1,
               p_organization_id,
               1,
               l_line_tbl(I).plan_date,
               l_line_tbl(I).supplied_item_id,
               l_line_tbl(I).quantity,
               3);
         ELSE
         */
           IF ((l_item_attr_Rec.src_type IS NULL) OR
             (l_item_Attr_Rec.src_type = 1 AND l_item_attr_rec.order_flag <> 'Y') OR
             (l_item_attr_rec.src_type = 2 AND l_item_attr_rec.purch_flag <> 'Y')) THEN
             FND_MESSAGE.SET_NAME('CSP', 'CSP_CREATE_REQ_ERROR');
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
           END IF;

           IF (l_item_attr_rec.src_type = 2) THEN
             IF (l_po_hdr_rec.dest_organization_id IS NULL) THEN
               l_po_hdr_rec.dest_organization_id := p_organization_id;
               l_po_hdr_rec.ship_To_location_id := l_location_id;
             END IF;
             l_po_line_tbl(K).inventory_item_id := l_line_Tbl(I).supplied_item_id;
             l_po_line_tbl(K).quantity := l_line_tbl(I).quantity;
             l_po_line_tbl(K).ordered_quantity := l_line_Tbl(I).quantity;
             l_po_line_tbl(K).unit_of_measure := l_line_Tbl(I).uom_code;
             l_po_line_tbl(K).line_num := K;
             l_po_line_tbl(K).need_by_date := l_line_Tbl(I).plan_date;
             K := K + 1;
           ELSIF (l_item_attr_rec.src_type = 1) THEN
             IF l_order_hdr_rec.dest_organization_id IS NULL THEN
               l_order_hdr_rec.dest_organization_id := p_organization_id;
               FND_PROFILE.GET('CSP_ORDER_TYPE', l_order_hdr_rec.order_type_id);
               l_order_hdr_Rec.ship_to_location_id := l_location_id;
             END IF;
             l_order_line_tbl(J).inventory_item_id := l_line_Tbl(I).supplied_item_id;
             l_order_line_tbl(J).quantity := l_line_Tbl(I).quantity;
             l_order_line_tbl(J).ordered_quantity := l_line_Tbl(I).quantity;
             l_order_line_tbl(J).unit_of_measure := l_line_Tbl(I).uom_code;
             l_order_line_tbl(J).source_organization_id := l_item_attr_rec.src_org; --l_line_Tbl(I).source_organization_id;
             l_order_line_tbl(J).need_by_Date := l_line_tbl(I).plan_Date;
             l_order_line_tbl(J).line_num := J;
             J := J + 1;
           END If;
         --END IF;
       END IF;
     END LOOP;

     IF (l_order_line_tbl.COUNT > 0) THEN
       l_order_hdr_rec.operation := 'CREATE';
       l_order_hdr_rec.need_by_date :=
nvl(l_order_hdr_rec.need_by_date,l_order_line_tbl(1).need_by_date);
       csp_parts_order.process_order(
              p_api_version             => l_api_version_number
             ,p_Init_Msg_List           => p_init_msg_list
             ,p_commit                  => p_commit
             ,px_header_rec             => l_order_hdr_rec
             ,px_line_table             => l_order_line_tbl
             ,x_return_status           => l_return_status
             ,x_msg_count               => l_msg_count
             ,x_msg_data                => l_msg_data
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     IF (l_po_line_tbl.COUNT > 0) THEN
       csp_parts_order.process_purchase_req(
             p_api_version      => l_api_version_number
            ,p_init_msg_list    => p_init_msg_list
            ,p_commit           => p_commit
            ,px_header_rec      => l_po_hdr_Rec
            ,px_line_Table      => l_po_line_tbl
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     COMMIT;
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
