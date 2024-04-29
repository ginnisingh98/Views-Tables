--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_ORDER" AS
/* $Header: cspvpodb.pls 120.17.12010000.84 2014/01/28 07:02:40 htank ship $ */

--
-- Purpose: Create/Update/Cancel Internal Parts Order for Spares
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- phegde      05/01/01 Created new package body

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csp_parts_order';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvpodb.pls';

  -- This procedure is to get the Unit Price for Internal Requisition
  -- If the Currency Code is same for both Source and Destination Organization
  -- get the Unit Cost for the Source Organization, otherwise
  -- derive Unit Price based on the List Price and Conversion Rate
  -- This procedure will have 2 OUT parameters viz. Currency Code and Unit Price
  PROCEDURE get_unit_price_prc (p_item_id                     IN NUMBER,
                    p_source_organization_id      IN NUMBER,
                    p_destination_organization_id IN NUMBER,
                    p_set_of_books_id             IN NUMBER,
                    x_chart_of_account_id         IN OUT NOCOPY NUMBER,
                  x_currency_code               IN OUT NOCOPY VARCHAR2,
                  x_unit_price                  IN OUT NOCOPY NUMBER,
                  x_item_cost                   OUT NOCOPY NUMBER) IS

     -- Get Functional Currency and Chart of Accounts ID of the SOB for Internal Requsitions

     CURSOR currency_code_cur (p_organization_id NUMBER) IS
       SELECT glsob.currency_code
             ,glsob.chart_of_accounts_id
       FROM   gl_sets_of_books glsob,
              hr_organization_information hoi
       WHERE  glsob.set_of_books_id = hoi.org_information1
       AND    hoi.org_information_context ||'' = 'Accounting Information'
       AND    hoi.organization_id = p_organization_id;

     -- Get Unit Price for Internal Requsitions
     CURSOR unit_price_cur (p_item_id NUMBER, p_source_organization_id NUMBER) IS

       SELECT cic.item_cost
       FROM cst_item_costs_for_gl_view cic,
            mtl_parameters mp
       WHERE cic.inventory_item_id = p_item_id
       AND cic.organization_id = mp.cost_organization_id
       AND cic.inventory_asset_flag = 1
       AND mp.organization_id= p_source_organization_id;

     CURSOR converted_unit_price_cur (p_item_id NUMBER, p_source_organization_id NUMBER,
                                      p_set_of_books_id NUMBER) IS
       SELECT msi.list_price_per_unit  *
              round(gl_currency_api.get_closest_rate_sql
                      (p_set_of_books_id,
                       glsob.currency_code,
                       trunc(sysdate),
                       psp.DEFAULT_RATE_TYPE,
                       30),10)
       FROM   mtl_system_items msi,
              gl_sets_of_books glsob,
              hr_organization_information hoi,
              po_system_parameters psp
       WHERE  msi.inventory_item_id = p_item_id
       AND    hoi.organization_id = p_source_organization_id
       AND    hoi.org_information_context = 'Accounting Information'
       AND    msi.organization_id = hoi.organization_id
       AND    glsob.set_of_books_id = hoi.org_information1;

     CURSOR conversion_rate_cur IS
       SELECT round(gl_currency_api.get_closest_rate_sql
                      (p_set_of_books_id,
                       glsob.currency_code,
                       trunc(sysdate),
                       psp.DEFAULT_RATE_TYPE,
                       30),10)
       FROM   gl_sets_of_books glsob,
              hr_organization_information hoi,
              po_system_parameters psp
       WHERE  hoi.organization_id = p_source_organization_id
       AND    HOI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
       AND    glsob.set_of_books_id = hoi.org_information1;

     s_currency_code          VARCHAR2(15);
     d_currency_code          VARCHAR2(15);
     d_chart_of_accounts_id   NUMBER;
     s_chart_of_accounts_id   NUMBER;
     l_unit_price             NUMBER;
     UNIT_PRICE_LT_0          EXCEPTION;
     INVALID_UNIT_PRICE       EXCEPTION;
     l_conversion_rate        NUMBER;
  BEGIN

       -- Get the SOB Currency Code of the Source Organization ID
       OPEN currency_code_cur(p_source_organization_id);
       FETCH currency_code_cur INTO s_currency_code, s_chart_of_accounts_id;
       CLOSE currency_code_cur;

       -- Get SOB Currency Code of the Destination (Inventory)  Organization
       OPEN currency_code_cur(p_destination_organization_id);
       FETCH currency_code_cur INTO d_currency_code, d_chart_of_accounts_id;
       CLOSE currency_code_cur;

       -- If Currency Code is same for both Destination and Source Organization
       -- Get Item Cost of the Source Organization ID from  cst_item_costs__for_gl_view
       -- Get Unit Cost
       OPEN unit_price_cur (p_item_id, p_source_organization_id);
       FETCH unit_price_cur INTO l_unit_price;
       x_item_cost := l_unit_price;
       IF unit_price_cur%NOTFOUND THEN
          CLOSE unit_price_cur;
          Raise INVALID_UNIT_PRICE;
       END IF;
       CLOSE unit_price_cur;
       IF l_unit_price < 0 THEN
          Raise UNIT_PRICE_LT_0;
       END IF;

       IF NVL(s_currency_code,'X') <> NVL(d_currency_code,'X') THEN
       /* Currency Code is different for Source and Destination Organization */

         OPEN conversion_rate_cur;
         FETCH conversion_rate_cur INTO l_conversion_Rate;
         CLOSE conversion_Rate_cur;

         IF (l_conversion_rate = -1 OR l_conversion_rate = -2) THEN
           l_conversion_Rate := 1;
         END IF;
         l_unit_price := l_unit_price * l_conversion_rate;

         IF l_unit_price < 0 THEN
            Raise UNIT_PRICE_LT_0;
         END IF;
       END IF; /* Currency Check */

       x_currency_code         := d_currency_code;
       x_unit_price            := l_unit_price;
       x_chart_of_account_id        := d_chart_of_accounts_id;

  EXCEPTION

     WHEN UNIT_PRICE_LT_0 THEN
          po_message_s.app_error('PO_RI_UNIT_PRICE_LT_0');
          raise;

     WHEN INVALID_UNIT_PRICE THEN
          x_unit_price := 0;
          x_currency_code         := d_currency_code;
          x_chart_of_account_id        := d_chart_of_accounts_id;
  END get_unit_price_prc;


  -- This function is to check the subinventory type to derive
  -- Code Combinatin ID.  Function Returns Sub Inventory Type
  -- 'ASSET' or 'EXPENSE'.  If EXCEPTION, Returns 'X'

  FUNCTION check_sub_inv_type_fun (p_destination_subinventory     IN VARCHAR2,
                       p_destination_organization_id IN NUMBER )
  RETURN VARCHAR2 IS

  CURSOR asset_inventory_cur IS
      SELECT    asset_inventory
      FROM     mtl_secondary_inventories
      WHERE     secondary_inventory_name = NVL(p_destination_subinventory,'X')
      AND       organization_id             = p_destination_organization_id;

  l_asset_inventory NUMBER;
  l_subinventory_type VARCHAR2(10) := 'X';

  BEGIN
    OPEN asset_inventory_cur;
      FETCH asset_inventory_cur INTO l_asset_inventory;
      CLOSE asset_inventory_cur;

      IF    (l_asset_inventory = 1) THEN
             l_subinventory_type :=  'ASSET';
      ELSIF (l_asset_inventory = 2) then
             l_subinventory_type :=  'EXPENSE';
      END IF;

          RETURN l_subinventory_type;

  EXCEPTION

    WHEN OTHERS THEN
         RETURN 'X';

  END check_sub_inv_type_fun ;

  -- This function is to check the item  type to derive
  -- Code Combinatin ID.  Function Returns Item Type
  -- 'ASSET' or 'EXPENSE'.  If EXCEPTION, Returns 'X'

  FUNCTION check_inv_item_type_fun ( p_destination_organization_id  IN NUMBER,
                         p_item_id                       IN NUMBER)
  RETURN VARCHAR2 IS

  CURSOR item_type_cur IS
      SELECT    inventory_asset_flag
      FROM    mtl_system_items
      WHERE    organization_id   = p_destination_organization_id
      AND     inventory_item_id = p_item_id;

  l_item_type         VARCHAR2(10) := 'X';
  l_asset_flag        VARCHAR2(1);

  BEGIN

     OPEN item_type_cur;
     FETCH item_type_cur INTO l_asset_flag;
     CLOSE item_type_cur;

     IF l_asset_flag = 'Y' then
        l_item_type := 'ASSET';
     ELSE
        l_item_type :=  'EXPENSE';
     END IF;

     RETURN l_item_type;

  EXCEPTION

    WHEN OTHERS THEN
        RETURN 'X';

  END check_inv_item_type_fun;

  -- This function is to default Code Combination ID for
  -- Destination Type Code INVENTORY
  -- Called in Process_Requisition

  FUNCTION get_charge_account_fun (p_destination_organization_id IN NUMBER,
                                   p_item_id IN NUMBER,
                                   p_destination_subinventory  IN VARCHAR)

  RETURN NUMBER IS

  l_charge_account    NUMBER;
  l_item_type         VARCHAR2(10);
  l_subinventory_type VARCHAR2(10) := 'X';

  BEGIN

    l_item_type := check_inv_item_type_fun (p_destination_organization_id, p_item_id);


    IF l_item_type = 'EXPENSE' then

        -- Subinventory is provided
        IF (p_destination_subinventory IS NOT NULL) THEN
            BEGIN
               SELECT expense_account
             INTO   l_charge_account
               FROM   mtl_secondary_inventories
               WHERE  secondary_inventory_name = p_destination_subinventory
               AND    organization_id = p_destination_organization_id;
            EXCEPTION
            WHEN OTHERS THEN
              l_charge_account := 0;
            END;
        END IF;

      -- If Expense Account not available for the Subinventory and Org,
      -- get expense account from Item Master for the Item and the Org
      IF (l_charge_account IS NULL) THEN
          BEGIN
              SELECT expense_account
            INTO   l_charge_account
           FROM   mtl_system_items
           WHERE  organization_id = p_destination_organization_id
           and inventory_item_id = p_item_id;
          EXCEPTION
          WHEN OTHERS THEN
              l_charge_account := 0;
          END;
      END IF;

        -- If Expense Account not available in Item Master,  get account
        -- from MTL_PARAMETERS for the Destination Organization
        IF (l_charge_account IS NULL) THEN
            BEGIN
              SELECT    expense_account
              INTO     l_charge_account
              FROM    mtl_parameters
              WHERE     organization_id = p_destination_organization_id;

            EXCEPTION
            WHEN OTHERS THEN
              l_charge_account  := 0;
            END;
        END IF;

    ELSE -- item type is ASSET

          --Check subinventory for Asset or Expense tracking.
        IF (p_destination_subinventory IS NOT NULL) THEN

            l_subinventory_type := check_sub_inv_type_fun(p_destination_subinventory,
                                p_destination_organization_id);
        END IF;

       -- Get the default account from the Organization if Subinventory Type is NOT

       -- EXPENSE or ASSET
         IF l_subinventory_type = 'X' then
           BEGIN
             SELECT material_account
             INTO   l_charge_account
                 FROM   mtl_parameters
             WHERE  organization_id = p_destination_organization_id;
           EXCEPTION
         WHEN OTHERS THEN
                 l_charge_account := 1111;
         END;
       ELSIF l_subinventory_type = 'EXPENSE' THEN
             -- Get Expense Account for the Subinventory
         BEGIN
             SELECT expense_account
             INTO   l_charge_account
             FROM   mtl_secondary_inventories
             WHERE  secondary_inventory_name = p_destination_subinventory
             AND    organization_id           = p_destination_organization_id;
         EXCEPTION
                WHEN OTHERS THEN
                 l_charge_account := 1112;
       END;
         -- If charge account is NULL for the Subinventory, get the default account


       -- for the Organization from MTL_PARAMETERS
       IF (l_charge_account is NULL) THEN
           BEGIN
             SELECT expense_account
           INTO   l_charge_account
             FROM   mtl_parameters
             WHERE  organization_id = p_destination_organization_id;
           EXCEPTION
         WHEN OTHERS THEN
             l_charge_account := 1113;
         END;
       END IF;
      ELSE  -- destination sub inventory type is ASSET
                -- Get the Charge_Account for the Subinventory
            BEGIN
            SELECT material_account
             INTO     l_charge_account
            FROM  mtl_secondary_inventories
            WHERE secondary_inventory_name = p_destination_subinventory
            AND   organization_id             = p_destination_organization_id;
            EXCEPTION
                   WHEN OTHERS THEN
                 l_charge_account := 1114;
                END;

                -- If Charge_account is not availabe for the Subinventory,
                -- get it for the Destination Organization from MTL_PARAMETERS
            IF (l_charge_account IS NULL) THEN
              BEGIN
                 SELECT material_account
                  INTO   l_charge_account
                 FROM   mtl_parameters
                 WHERE  organization_id = p_destination_organization_id;
              EXCEPTION
            WHEN OTHERS THEN
                   l_charge_account := 1115;
            END;
            END IF;
         END IF; /* Sub Inventory Type */
     END IF; /* Item Type Check */

     RETURN (l_charge_account);

  EXCEPTION
    WHEN OTHERS THEN
         RETURN (1115);
  END get_charge_account_fun;


  /*
    Function to validate Code Combination IDs.
    If INVALID function will return FALSE
  */

  FUNCTION valid_account_id_fun (p_ccid IN NUMBER,
                                 p_gl_date IN DATE,
                                 p_chart_of_accounts_id IN NUMBER)
    RETURN BOOLEAN IS

  CURSOR validate_ccid_cur IS
    SELECT  'X'
    FROM    gl_code_combinations gcc
    WHERE   gcc.code_combination_id = p_ccid
    AND     gcc.enabled_flag = 'Y'
    AND     trunc(nvl(p_gl_date,SYSDATE))
               BETWEEN trunc(nvl(start_date_active, nvl(p_gl_date,SYSDATE) ))
               AND     trunc(nvl (end_date_active, SYSDATE+1))
    AND gcc.detail_posting_allowed_flag = 'Y'
    AND gcc.chart_of_accounts_id= p_chart_of_accounts_id
    AND gcc.summary_flag = 'N';

    l_dummy   VARCHAR2(1);

  BEGIN

     OPEN validate_ccid_cur;
     FETCH validate_ccid_cur INTO l_dummy;
     IF validate_ccid_cur%FOUND THEN
          CLOSE validate_ccid_cur;
            return TRUE;
     ELSE
          CLOSE validate_ccid_cur;
          return FALSE;
     END IF;

  EXCEPTION

    WHEN OTHERS THEN
       return (FALSE);

  END valid_account_id_fun;

  PROCEDURE Cancel_Order(
        /*  p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE */
          p_header_rec             IN csp_parts_requirement.header_rec_type
         ,p_line_table             IN csp_parts_requirement.Line_Tbl_type
         ,p_process_Type           IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
         ) IS
   l_api_version_number         CONSTANT NUMBER := 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) := 'cancel_order';
   l_line_tbl                   CSP_PARTS_REQUIREMENT.Line_tbl_type;
   l_line_rec                   CSP_PARTS_REQUIREMENT.Line_rec_type;
   l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

   -- Record and table types for oe process_order
   l_oe_line_tbl                OE_Order_PUB.line_tbl_type;
   lx_oe_line_tbl                OE_Order_PUB.line_tbl_type;
   l_oe_line_old_tbl            OE_Order_PUB.line_tbl_type;
   l_oe_header_rec              oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
   lx_oe_header_rec              oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
   l_oe_Header_Val_rec          oe_order_pub.header_val_rec_type;
   l_oe_header_adj_tbl          oe_order_pub.header_adj_tbl_type;
   l_oe_header_adj_val_tbl      oe_order_pub.header_adj_val_tbl_type;
   l_oe_header_price_att_tbl    oe_order_pub.header_price_att_tbl_type;
   l_oe_Header_Adj_Att_Tbl      oe_order_pub.header_adj_att_tbl_type;
   l_oe_Header_Adj_Assoc_Tbl    oe_order_pub.header_adj_assoc_tbl_type;
   l_oe_header_scr_tbl          OE_ORDER_PUB.header_scredit_tbl_type;
   l_oe_Header_Scredit_Val_Tbl  OE_ORDER_PUB.header_scredit_Val_tbl_type;
   l_oe_line_rec                oe_order_pub.line_rec_type;
   l_oe_Line_Val_Tbl            oe_order_pub.line_Val_tbl_type;
   l_oe_line_adj_tbl            oe_order_pub.line_adj_tbl_type;
   l_oe_Line_Adj_Val_Tbl        oe_order_pub.line_adj_val_tbl_type;
   l_oe_Line_Price_Att_Tbl      oe_order_pub.line_price_att_tbl_type;
   l_oe_Line_Adj_Att_Tbl        oe_order_pub.line_adj_att_tbl_type;
   l_oe_Line_Adj_Assoc_tbl      oe_order_pub.Line_Adj_Assoc_Tbl_Type;
   l_oe_line_scr_tbl            oe_order_pub.line_scredit_tbl_type;
   l_oe_Line_Scredit_Val_Tbl    oe_order_pub.line_scredit_val_tbl_type;
   l_oe_Lot_Serial_Tbl          oe_order_pub.lot_serial_tbl_type;
   l_oe_Lot_Serial_Val_Tbl      oe_order_pub.lot_serial_val_tbl_type;
   l_oe_Request_Tbl_Type        oe_order_pub.Request_tbl_type;
   l_oe_control_rec             OE_GLOBALS.Control_Rec_Type;

   l_oe_header_id              NUMBER;
   j                           number := 0;
   l_msg                       VARCHAR2(2000);

   /*
   CURSOR get_new_context(p_new_org_id number) IS
     SELECT      org_information2 ,
                 org_information3 ,
                 org_information4
     FROM        hr_organization_information hou
     WHERE       hou.organization_id = p_new_org_id
     AND         hou.org_information1 = 'FIELD_SERVICE'
     AND         hou.org_information_context =  'CS_USER_CONTEXT';
     */

   orig_org_id             number;
   orig_user_id            number;
   orig_resp_id            number;
   orig_resp_appl_id       number;
   new_org_id              number;
   new_user_id             number;
   new_resp_id             number;
   new_resp_appl_id        number;
   l_source_operating_unit number;
   l_org_id                number;
   l_user_id               number;
   new_user                varchar2(240);
   l_module_name varchar2(100) := 'csp.plsql.csp_parts_order.Cancel_Order';
   l_header_status varchar2(100);

  BEGIN

        SAVEPOINT Cancel_Order_PUB;

        -- initialize return status
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_user_id := nvl(fnd_global.user_id, 0) ;
        fnd_profile.get('RESP_ID',orig_resp_id);
        fnd_profile.get('RESP_APPL_ID',orig_resp_appl_id);

        BEGIN
            l_org_id := mo_global.get_current_org_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_org_id = ' || l_org_id);
            end if;

            if l_org_id is null then
                po_moac_utils_pvt.INITIALIZE;
                l_org_id := mo_global.get_current_org_id;
            end if;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_org_id = ' || l_org_id);
            end if;

            po_moac_utils_pvt.set_org_context(l_org_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE NO_DATA_FOUND;
        END;

        l_oe_header_id := p_header_rec.order_header_id;
        l_line_tbl := p_line_table;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'l_oe_header_id = ' || l_oe_header_id);
        end if;

        IF (p_process_type = 'REQUISITION') THEN
          FOR I in 1..l_line_tbl.count LOOP
            update po_requisition_lines
            set quantity_cancelled = l_line_Tbl(I).quantity,
               cancel_flag = 'Y',
               cancel_reason = l_line_tbl(I).change_reason,
               cancel_date = sysdate
            where requisition_line_id = l_line_tbl(I).requisition_line_id;

            -- update mtl_supply data for the requisition
            IF NOT po_supply.po_req_supply(
                         p_docid         => null,
                         p_lineid        => l_line_Tbl(I).requisition_line_id,
                         p_shipid        => null,
                         p_action        => 'Remove_Req_Line_Supply',
                         p_recreate_flag => NULL,
                         p_qty           => NULL,
                         p_receipt_date  => NULL) THEN

                   PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '035',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
        ELSE
          IF(l_oe_header_id IS NOT NULL) THEN

             -- source operating unit
             BEGIN
               SELECT org_id
               INTO l_source_operating_unit
               FROM OE_ORDER_HEADERS_ALL
               WHERE header_id = l_oe_header_id;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 RAISE NO_DATA_FOUND;
             END;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'l_source_operating_unit = ' || l_source_operating_unit);
        end if;

             IF (l_source_operating_unit <> l_org_id) THEN
               /*
               OPEN  get_new_context(l_source_operating_unit);
               FETCH get_new_context
                 INTO  new_user_id,new_resp_id,new_resp_appl_id;
               CLOSE get_new_context;
               */

              fnd_profile.get('CSP_USER_TEST', new_user);
              new_user_id := substr(new_user, 1, instr(new_user, '~') - 1);
              new_user := substr(ltrim(new_user, new_user_id), 3);
              new_resp_id := substr(new_user, 1, instr(new_user, '~') - 1);
              new_resp_appl_id := substr(ltrim(new_user, new_resp_id), 3);


               IF new_resp_id is not null and
                  new_user_id is not null and
                  new_resp_appl_id is not null THEN
                   fnd_global.apps_initialize(new_user_id,new_resp_id,new_resp_appl_id);
                   mo_global.set_policy_context('S',l_source_operating_unit);
               ELSE
                 --dbms_application_info.set_client_info(l_source_operating_unit);
                 mo_global.set_policy_context('S',l_source_operating_unit);
               END IF;
             END If;

             oe_header_util.Query_Row(
                 p_header_id => l_oe_header_id,
                 x_header_rec => l_oe_header_rec);

     /*        l_oe_header_rec.cancelled_flag := 'Y';
               l_oe_header_rec.flow_status_code := 'CANCELLED';
             l_oe_header_rec.open_flag := 'N';
             l_oe_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
             l_oe_header_rec.change_reason := p_header_rec.change_reason;
             l_oe_header_rec.change_comments := p_header_rec.change_comments;
     */
             oe_line_util.Query_Rows
              (p_header_id                 => l_oe_header_id,
               x_line_tbl                  => l_oe_line_old_tbl
               );

             For I in 1 .. l_oe_line_old_tbl.count LOOP
               IF  nvl(l_oe_line_old_tbl(i).shipped_quantity,0) = 0  AND
                    Nvl(l_oe_line_old_tbl(i).cancelled_flag,'N') <> 'Y' AND
                    Nvl(l_oe_line_old_tbl(i).ordered_quantity,0) <> 0 THEN
                      J := J + 1;
                       l_oe_line_tbl(J) := l_oe_line_old_tbl(I);
                        l_oe_line_tbl(J).db_flag := FND_API.G_TRUE;
                      l_oe_line_tbl(J).cancelled_quantity := l_oe_line_old_tbl(J).ordered_quantity;

                     l_oe_line_tbl(j).ordered_quantity :=0;
                      l_oe_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
                      l_oe_line_tbl(j).change_reason := p_header_rec.change_reason;


                       l_oe_line_tbl(j).change_comments := p_header_Rec.change_comments;

                      l_oe_line_tbl(j).cancelled_flag := 'Y';
                      l_oe_line_tbl(j).flow_status_code := 'CANCELLED';
                      l_oe_line_tbl(j).source_document_line_id := l_oe_line_old_tbl(J).source_document_line_id;


                    l_oe_line_tbl(j).open_flag := 'N';
               End If;
             end loop;

          ELSE -- IF (l_oe_header_id IS NULL) THEN

            FOR I in 1..l_line_tbl.count LOOP
                BEGIN
                  SELECT org_id
                  INTO l_source_operating_unit
                  FROM oe_order_lines_all
                  WHERE line_id = l_line_tbl(i).order_line_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RAISE NO_DATA_FOUND;
                END;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'l_source_operating_unit = ' || l_source_operating_unit);
        end if;

                IF (l_source_operating_unit <> l_org_id) THEN
                  /*
                  OPEN  get_new_context(l_source_operating_unit);
                  FETCH get_new_context
                    INTO  new_user_id,new_resp_id,new_resp_appl_id;
                  CLOSE get_new_context;
                  */

                  fnd_profile.get('CSP_USER_TEST', new_user);
                  new_user_id := substr(new_user, 1, instr(new_user, '~') - 1);
                  new_user := substr(ltrim(new_user, new_user_id), 3);
                  new_resp_id := substr(new_user, 1, instr(new_user, '~') - 1);
                  new_resp_appl_id := substr(ltrim(new_user, new_resp_id), 3);

                  IF new_resp_id is not null and
                     new_user_id is not null and
                     new_resp_appl_id is not null THEN
                      fnd_global.apps_initialize(new_user_id,new_resp_id,new_resp_appl_id);
                      mo_global.set_policy_context('S',l_source_operating_unit);
                  ELSE
                    --dbms_application_info.set_client_info(l_source_operating_unit);
                    mo_global.set_policy_context('S',l_source_operating_unit);
                  END IF;
                END If;

                l_oe_line_old_tbl(i) := oe_line_util.Query_Row(l_line_tbl(i).order_line_id);


                IF  nvl(l_oe_line_old_tbl(i).shipped_quantity,0) = 0  AND
                  Nvl(l_oe_line_old_tbl(i).cancelled_flag,'N') <> 'Y' AND
                  Nvl(l_oe_line_old_tbl(i).ordered_quantity,0) <> 0 THEN
                    J := J + 1;
                     l_oe_line_tbl(J) := l_oe_line_old_tbl(I);
                      l_oe_line_tbl(J).db_flag := FND_API.G_TRUE;
                    l_oe_line_tbl(J).cancelled_quantity := l_oe_line_tbl(J).ordered_quantity;

                    l_oe_line_tbl(j).ordered_quantity :=0;
                    l_oe_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
                    l_oe_line_tbl(j).change_reason := p_line_table(i).change_reason;

                     l_oe_line_tbl(j).change_comments := p_line_table(i).change_comments;

                    l_oe_line_tbl(j).cancelled_flag := 'Y';
                    l_oe_line_tbl(j).flow_status_code := 'CANCELLED';
                    l_oe_line_tbl(j).source_document_line_id := l_oe_line_old_tbl(J).source_document_line_id;


                    l_oe_line_tbl(j).open_flag := 'N';
               End If;
            END LOOP;

            oe_header_util.Query_Row(
                   p_header_id => l_oe_line_old_tbl(1).header_id,
                   x_header_rec => l_oe_header_rec);

          END If;

          IF l_oe_line_tbl.count = 0 THEN
            FND_MESSAGE.SET_NAME('ONT','OE_NO_ELIGIBLE_LINES');
            FND_MESSAGE.SET_TOKEN('ORDER',
                    l_oe_header_rec.Order_Number, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
                ( p_count => x_msg_count
                , p_data  => x_msg_data);

            x_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
          END IF;

      l_oe_control_rec.controlled_operation := TRUE;
          l_oe_control_rec.change_attributes    := TRUE;
          l_oe_control_rec.validate_entity      := TRUE;
          l_oe_control_rec.write_to_DB          := TRUE;
          l_oe_control_rec.default_attributes   := FALSE;
          l_oe_control_rec.process              := FALSE;

          --  Instruct API to retain its caches
          l_oe_control_rec.clear_api_cache      := FALSE;
          l_oe_control_rec.clear_api_requests   := FALSE;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Starting OW Debug...');

                oe_debug_pub.G_FILE := NULL;
                oe_debug_pub.debug_on;
                oe_debug_pub.initialize;
                oe_debug_pub.setdebuglevel(5);

                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'OE Debug File : '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
            end if;

          -- Call to Process Order
           OE_Order_PUB.Process_Order(
            p_org_id             => l_source_operating_unit
           , p_api_version_number => l_api_version_number
           ,p_init_msg_list      => FND_API.G_TRUE
           ,p_return_values      => FND_API.G_FALSE
           ,p_action_commit      => FND_API.G_FALSE
           -- Passing just the entity records that are a part of this order
           ,p_header_rec         => l_oe_header_rec
           ,p_line_tbl            => l_oe_line_tbl
           ,p_old_line_tbl        => l_oe_line_old_tbl
           -- OUT variables
           ,x_header_rec            => lx_oe_header_rec
           ,x_header_val_rec      => l_oe_Header_Val_rec
           ,x_header_adj_tbl        => l_oe_header_adj_tbl
           ,x_Header_Adj_val_tbl   => l_oe_header_adj_val_tbl
           ,x_Header_price_Att_tbl => l_oe_header_price_att_tbl
           ,x_Header_Adj_Att_tbl   => l_oe_Header_Adj_Att_Tbl
           ,x_Header_Adj_Assoc_tbl => l_oe_Header_Adj_Assoc_Tbl
           ,x_header_scredit_tbl   => l_oe_header_scr_tbl
           ,x_Header_Scredit_val_tbl => l_oe_Header_Scredit_Val_Tbl
           ,x_line_tbl             => lx_oe_line_tbl
           ,x_line_val_tbl         => l_oe_Line_Val_Tbl
           ,x_line_adj_tbl         => l_oe_line_adj_tbl
           ,x_Line_Adj_val_tbl     => l_oe_Line_Adj_Val_Tbl
           ,x_Line_price_Att_tbl   => l_oe_Line_Price_Att_Tbl
           ,x_Line_Adj_Att_tbl     => l_oe_Line_Adj_Att_Tbl
           ,x_Line_Adj_Assoc_tbl   => l_oe_Line_Adj_Assoc_Tbl
           ,x_Line_Scredit_tbl     => l_oe_line_scr_tbl
           ,x_Line_Scredit_val_tbl => l_oe_Line_Scredit_Val_Tbl
           ,x_Lot_Serial_tbl       => l_oe_Lot_Serial_Tbl
           ,x_Lot_Serial_val_tbl   => l_oe_Lot_Serial_Val_Tbl
           ,x_action_request_tbl     => l_oe_Request_Tbl_Type
           ,x_return_status         => l_return_status
           ,x_msg_count             => l_msg_count
           ,x_msg_data             => l_msg_data
          );

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'done ... with l_return_status = ' || l_return_status);
            -- Stopping OE Debug...
            oe_debug_pub.debug_off;
        end if;

          IF (l_source_operating_unit <> l_org_id) THEN
              fnd_global.apps_initialize(l_user_id,orig_resp_id,orig_resp_appl_id);
               mo_global.set_policy_context('S',l_org_id);
          END If;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            for counter in REVERSE 1..l_msg_count Loop
              l_msg := OE_MSG_PUB.Get(counter,FND_API.G_FALSE) ;
              FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
              FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
              FND_MSG_PUB.ADD;
              fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
            End loop;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
             -- cancel the internal requisitions lines and header for the above order lines and header

             FOR I in 1..lx_oe_line_tbl.count LOOP
               update po_requisition_lines_all
               set quantity_cancelled = lx_oe_line_Tbl(I).cancelled_quantity,
                   cancel_flag = 'Y',
                   cancel_reason = lx_oe_line_tbl(I).change_reason,
                   cancel_date = sysdate
               where requisition_line_id = lx_oe_line_tbl(I).source_document_line_id;


               -- update mtl_supply data for the requisition
             /*  IF NOT po_supply.po_req_supply(
                         p_docid         => null,
                         p_lineid        => lx_oe_line_Tbl(I).source_document_line_id,
                         p_shipid        => null,
                         p_action        => 'Remove_Req_Line_Supply',
                         p_recreate_flag => NULL,
                         p_qty           => NULL,
                         p_receipt_date  => NULL) THEN
              */

                 BEGIN
                   UPDATE mtl_supply
                   SET quantity = 0
                   , change_flag = 'Y'
                   WHERE supply_type_code = 'REQ'
                   AND req_line_id = lx_oe_line_Tbl(I).source_document_line_id;
                 EXCEPTION
                   when no_data_found THEN

                     PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '035',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
                     RAISE FND_API.G_EXC_ERROR;
                 END;
             --  END IF;
             END LOOP;

         -- cancel header separately
          IF (p_header_rec.order_header_id IS NOT NULL) THEN
            -- bug 17165253
            -- check if the order header is already CLOSED
            -- do not try to cancel the header if it is already CLOSED
            select flow_status_code into l_header_status
            from oe_order_headers_all
            where header_id = p_header_rec.order_header_id;

            if l_header_status <> 'CLOSED' then

               IF (l_source_operating_unit <> l_org_id) THEN
                  IF new_resp_id is not null and
                     new_resp_appl_id is not null THEN
                      fnd_global.apps_initialize(new_user_id,new_resp_id,new_resp_appl_id);
                  ELSE
                    --dbms_application_info.set_client_info(l_source_operating_unit);
                    mo_global.set_policy_context('S',l_source_operating_unit);
                  END IF;
                END If;

               oe_header_util.Query_Row(
                    p_header_id => l_oe_header_id,
                    x_header_rec => l_oe_header_rec);

                  l_oe_header_rec.cancelled_flag := 'Y';
                    l_oe_header_rec.flow_status_code := 'CANCELLED';
                  l_oe_header_rec.open_flag := 'N';
                  l_oe_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
                  l_oe_header_rec.change_reason := p_header_rec.change_reason;
                  l_oe_header_rec.change_comments := p_header_rec.change_comments;

                  l_oe_control_rec.controlled_operation := TRUE;
                  l_oe_control_rec.change_attributes    := TRUE;
                  l_oe_control_rec.validate_entity      := TRUE;
                  l_oe_control_rec.write_to_DB          := TRUE;
                  l_oe_control_rec.default_attributes   := FALSE;
                  l_oe_control_rec.process              := FALSE;

                  --  Instruct API to retain its caches
                  l_oe_control_rec.clear_api_cache      := FALSE;
                  l_oe_control_rec.clear_api_requests   := FALSE;


                  For I in 1 .. l_oe_line_old_tbl.count LOOP
                    l_oe_line_old_tbl(I).operation := null;
                    l_oe_line_Tbl(i).operation := null;
                  END LOOP;

               if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Starting OW Debug...');

                   oe_debug_pub.G_FILE := NULL;
                   oe_debug_pub.debug_on;
                   oe_debug_pub.initialize;
                   oe_debug_pub.setdebuglevel(5);

                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'OE Debug File : '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
               end if;

              -- call to Process Order
                  OE_Order_PUB.Process_Order(
                   p_org_id             => l_source_operating_unit
                   ,p_api_version_number => l_api_version_number
                   ,p_init_msg_list      => FND_API.G_TRUE
                   ,p_return_values      => FND_API.G_FALSE
                   ,p_action_commit      => FND_API.G_FALSE
                   -- Passing just the entity records that are a part of this order
                   ,p_header_rec         => l_oe_header_rec
                   ,p_line_tbl            => l_oe_line_tbl
                   ,p_old_line_tbl        => l_oe_line_old_tbl
                   -- OUT variables
                   ,x_header_rec            => lx_oe_header_rec
                   ,x_header_val_rec      => l_oe_Header_Val_rec
                   ,x_header_adj_tbl        => l_oe_header_adj_tbl
                   ,x_Header_Adj_val_tbl   => l_oe_header_adj_val_tbl
                   ,x_Header_price_Att_tbl => l_oe_header_price_att_tbl
                   ,x_Header_Adj_Att_tbl   => l_oe_Header_Adj_Att_Tbl
                   ,x_Header_Adj_Assoc_tbl => l_oe_Header_Adj_Assoc_Tbl
                   ,x_header_scredit_tbl   => l_oe_header_scr_tbl
                   ,x_Header_Scredit_val_tbl => l_oe_Header_Scredit_Val_Tbl
                   ,x_line_tbl             => lx_oe_line_tbl
                   ,x_line_val_tbl         => l_oe_Line_Val_Tbl
                   ,x_line_adj_tbl         => l_oe_line_adj_tbl
                   ,x_Line_Adj_val_tbl     => l_oe_Line_Adj_Val_Tbl
                   ,x_Line_price_Att_tbl   => l_oe_Line_Price_Att_Tbl
                   ,x_Line_Adj_Att_tbl     => l_oe_Line_Adj_Att_Tbl
                   ,x_Line_Adj_Assoc_tbl   => l_oe_Line_Adj_Assoc_Tbl
                   ,x_Line_Scredit_tbl     => l_oe_line_scr_tbl
                   ,x_Line_Scredit_val_tbl => l_oe_Line_Scredit_Val_Tbl
                   ,x_Lot_Serial_tbl       => l_oe_Lot_Serial_Tbl
                   ,x_Lot_Serial_val_tbl   => l_oe_Lot_Serial_Val_Tbl
                   ,x_action_request_tbl     => l_oe_Request_Tbl_Type
                   ,x_return_status         => l_return_status
                   ,x_msg_count             => l_msg_count
                   ,x_msg_data             => l_msg_data
                );

               if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'done ... with l_return_status = ' || l_return_status);
                   -- Stopping OE Debug...
                   oe_debug_pub.debug_off;
               end if;

                IF (l_source_operating_unit <> l_org_id) THEN
                  fnd_global.apps_initialize(l_user_id,orig_resp_id,orig_resp_appl_id);
                  mo_global.set_policy_context('S',l_org_id);
                END If;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   x_return_status := l_return_status;
                  for counter in REVERSE 1..l_msg_count Loop
                    l_msg := OE_MSG_PUB.Get(counter,FND_API.G_FALSE) ;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                    FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                       ( p_count => x_msg_count
                       , p_data  => x_msg_data);
                  End loop;
                  RAISE FND_API.G_EXC_ERROR;
                END If;
             end if;
            END IF;
          END IF;
        END If;

    -- Bug 13417397. Setting the change_flag back to NULL
    FOR I in 1..lx_oe_line_tbl.count LOOP
      BEGIN
        update mtl_supply
        set change_flag = NULL
        where supply_type_code = 'REQ'
        and req_line_id = lx_oe_line_Tbl(I).source_document_line_id;
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;
    END LOOP;

    fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'exiting with x_return_status = ' || x_return_status);
    end if;

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
      Rollback to Cancel_order_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

  END;


  PROCEDURE cancel_order_line(
              p_order_line_id IN NUMBER,
              p_cancel_reason IN Varchar2,
              x_return_status OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_msg_data      OUT NOCOPY VARCHAR2) IS
      l_header_rec      csp_parts_requirement.header_rec_type;
      l_line_table      csp_parts_requirement.line_tbl_type;
  begin
      l_line_table(1).order_line_id := p_order_line_id;
      l_line_table(1).change_reason := p_cancel_reason;
      Cancel_Order(
        p_header_rec               => l_header_rec,
        p_line_table               => l_line_table,
        p_process_Type             => 'ORDER',
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data);
  end;

/**************************************************************************
***************************************************************************
***************************************************************************
                    PROCESS_ORDER
***************************************************************************
***************************************************************************
***************************************************************************/
  PROCEDURE process_order(
          p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2
         ,p_commit                  IN VARCHAR2
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,p_process_type            IN VARCHAR2
         ,p_book_order                IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        )
  IS
   l_action_request_tbl     oe_order_pub.request_tbl_type;
   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'process_order';
   l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_today                  DATE;

   EXCP_USER_DEFINED        EXCEPTION;
   INVALID_CHARGE_ACCOUNT   EXCEPTION;
   INVALID_ACCRUAL_ACCOUNT  EXCEPTION;
   INVALID_BUDGET_ACCOUNT   EXCEPTION;
   INVALID_VARIANCE_ACCOUNT EXCEPTION;

   l_org_id                 NUMBER;
   l_set_of_books_id        NUMBER;
   l_request_id             NUMBER;
   l_order_source_id        NUMBER := 10;
   l_orig_sys_document_ref  VARCHAR2(50);
   l_change_sequence        VARCHAR2(10);
   l_validate_only            VARCHAR2(1);
   l_init_msg_list            VARCHAR2(240);
   l_rowid                  NUMBER;
   l_dummy                  NUMBER;
   l_segment1               VARCHAR2(240);
   l_employee_id            NUMBER := -1;
   l_unit_meas_lookup_code  VARCHAR2(25);
   l_category_id            NUMBER;
   l_price_list_id          NUMBER;
   l_line_price_list_id     NUMBER;
   l_currency_code          VARCHAR2(3);
   l_unit_price             NUMBER;
   l_chart_of_Accounts_id   NUMBER;

   l_customer_id            NUMBER;
   l_cust_acct_id        NUMBER;
   l_site_use_id            NUMBER;
   l_line_type_id           NUMBER;
   l_order_line_type_id     NUMBER;
   l_order_line_category_code VARCHAR2(30);
   l_order_number           NUMBER;
   l_source_operating_unit  NUMBER;

   l_header_rec             csp_parts_requirement.header_rec_type;
   l_line_rec               csp_parts_requirement.line_rec_type;
   l_line_tbl               csp_parts_requirement.Line_tbl_type;
   l_dist_Rec               csp_parts_order.req_dist_rec_type;

   l_transferred_to_oe_flag VARCHAR2(1) := 'Y';
   l_msg varchar2(2000);
   -- Record and table types for oe process_order
   l_oe_header_rec              oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
   lx_oe_header_rec              oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
   l_oe_Header_Val_rec          oe_order_pub.header_val_rec_type := OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

   l_oe_header_adj_tbl          oe_order_pub.header_adj_tbl_type;
   l_oe_header_adj_val_tbl      oe_order_pub.header_adj_val_tbl_type;
   l_oe_header_price_att_tbl    oe_order_pub.header_price_att_tbl_type;
   l_oe_Header_Adj_Att_Tbl      oe_order_pub.header_adj_att_tbl_type;
   l_oe_Header_Adj_Assoc_Tbl    oe_order_pub.header_adj_assoc_tbl_type;
   l_oe_header_scr_tbl          OE_ORDER_PUB.header_scredit_tbl_type;
   l_oe_Header_Scredit_Val_Tbl  OE_ORDER_PUB.header_scredit_Val_tbl_type;
   l_oe_line_rec                oe_order_pub.line_rec_type := OE_ORDER_PUB.G_MISS_LINE_REC;
   l_oe_line_tbl                oe_order_pub.line_tbl_type := OE_ORDER_PUB.G_MISS_LINE_TBL;
   lx_oe_line_tbl                oe_order_pub.line_tbl_type := OE_ORDER_PUB.G_MISS_LINE_TBL;
   l_oe_Line_Val_Tbl            oe_order_pub.line_Val_tbl_type := OE_ORDER_PUB.G_MISS_LINE_VAL_TBL;
   l_oe_line_adj_tbl            oe_order_pub.line_adj_tbl_type := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL;
   l_oe_Line_Adj_Val_Tbl        oe_order_pub.line_adj_val_tbl_type := OE_ORDER_PUB.G_MISS_LINE_ADJ_VAL_TBL;
   l_oe_Line_Price_Att_Tbl      oe_order_pub.line_price_att_tbl_type := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL;
   l_oe_Line_Adj_Att_Tbl        oe_order_pub.line_adj_att_tbl_type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL;
   l_oe_Line_Adj_Assoc_tbl      oe_order_pub.Line_Adj_Assoc_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
   l_oe_line_scr_tbl            oe_order_pub.line_scredit_tbl_type := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL;
   l_oe_Line_Scredit_Val_Tbl    oe_order_pub.line_scredit_val_tbl_type;
   l_oe_Lot_Serial_Tbl          oe_order_pub.lot_serial_tbl_type;
   l_oe_Lot_Serial_Val_Tbl      oe_order_pub.lot_serial_val_tbl_type;
   l_oe_Request_Tbl_Type        oe_order_pub.Request_tbl_type := OE_ORDER_PUB.G_MISS_REQUEST_TBL;
   l_oe_control_rec             OE_GLOBALS.Control_Rec_Type;

   CURSOR rowid_cur IS
     SELECT rowid FROM PO_REQUISITION_HEADERS
     WHERE requisition_header_id = l_header_rec.requisition_header_id;

   -- Get requisition_number (PO_REQUSITION_HEADERS.segment1)
   CURSOR req_number_cur IS
     SELECT to_char(current_max_unique_identifier + 1)
     FROM   po_unique_identifier_control
     WHERE  table_name = 'PO_REQUISITION_HEADERS'
     FOR    UPDATE OF current_max_unique_identifier;

   -- Get unique requisition_header_id
   CURSOR req_header_id_cur IS
     SELECT po_requisition_headers_s.nextval
     FROM sys.dual;

   -- Get unique requisition_line_id
   CURSOR req_line_id_cur IS
     SELECT po_requisition_lines_s.nextval
     FROM sys.dual;

   -- Cursor to get unique Distribution_id
   CURSOR dist_line_id_cur IS
     SELECT po_req_distributions_s.nextval
     FROM sys.dual;

   -- Cursor to get Accrual Account ID and Variance Account ID
   -- For Destination Type Code INVENTORY get accrual account id
   -- from MTL_PARAMETERS
   -- Per Requisition Import program (pocis.opc).
   CURSOR accrual_account_id_cur (p_destination_organization_id NUMBER) IS
     SELECT mp.ap_accrual_account,
            mp.invoice_price_var_account
     FROM   mtl_parameters mp
     WHERE  mp.organization_id = p_destination_organization_id;

   -- Get Item Category ID
   -- As in Requisition Import
   CURSOR item_category_cur(p_item_id NUMBER, p_destination_org_id NUMBER) IS
     SELECT mic.category_id
     FROM   mtl_item_categories mic,
            mtl_default_sets_view mdsv
     WHERE  mic.inventory_item_id = p_item_id
     AND    mic.organization_id = p_destination_org_id
     AND    mic.category_set_id = mdsv.category_set_id
     AND    mdsv.functional_area_id = 2;

   -- Get Set of Books ID for a given Org_ID - Mandatory in PO_REQ_DISTRIBUTIONS

   CURSOR set_of_books_cur (p_organization_id NUMBER) IS
     SELECT set_of_books_id
     FROM   hr_operating_units
     WHERE  organization_id = p_organization_id;

   -- If encumbrance flag is 'Y' get the budget account
   -- For Internal Req, Destination Type Code will be INVENTORY
   -- Hence, it is assumed that the budget account will come
   -- from MTL_PARAMETERS for the Item and the Destination Organization
   CURSOR budget_account_cur (p_destination_organization_id NUMBER,
                              p_item_id NUMBER) IS
     SELECT nvl (msi.encumbrance_account,mp.encumbrance_account)
     FROM   mtl_system_items msi,
            mtl_parameters mp
     WHERE  msi.inventory_item_id = p_item_id
     AND    msi.organization_id = p_destination_organization_id
     AND    mp.organization_id = msi.organization_id;

   -- Get Requisition Encumbrance Flag for the Set of Books
   -- Based on this flag Budget Account will be populated
   -- in PO_REQ_DISTRIBUTIONS
   CURSOR req_encumbrance_cur (p_set_of_books_id NUMBER) IS
     SELECT nvl (fsp.req_encumbrance_flag,'N')
     FROM   financials_system_parameters fsp
     WHERE  fsp.set_of_books_id = p_set_of_books_id;

   -- Get Charge Account for the Item and Organization
   CURSOR charge_account_cur (p_destination_organization_id NUMBER,
                              p_item_id NUMBER) IS
      SELECT NVL(expense_account,-1)
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_destination_organization_id;

   -- Get Unit_of_Measure from MTL_UNIT_OF_MEASURES, since OM passes
   -- only UOM_CODE and PO requires UNIT_OF_MEASURE.  This is being done
   -- to fix the problem of line not showing up from POXRQVRQ form
   CURSOR unit_of_measure_cur (p_uom_code VARCHAR2) IS
     SELECT mum.unit_of_measure
     FROM   mtl_units_of_measure mum
     WHERE  mum.uom_code = p_uom_code;

   -- Get default line type
   CURSOR line_type_cur IS
     SELECT psp.line_type_id,
            plt.order_type_lookup_code,
            plt.purchase_basis,
            plt.matching_basis
     FROM PO_SYSTEM_PARAMETERS_ALL psp,
          PO_LINE_TYPES plt
     WHERE psp.org_id = l_org_id
     AND plt.line_type_id = psp.line_type_id;

   l_line_type_rec line_Type_cur%ROWTYPE;

   -- Get preparer_id
   CURSOR employee_id_cur IS
     SELECT employee_id
     FROM fnd_user
     WHERE user_id = l_user_id;

  -- Get site_use_id for the inventory location id
  CURSOR cust_site_cur IS
    SELECT pol.customer_id, pol.site_use_id, cust_acct.cust_account_id
    FROM PO_LOCATION_ASSOCIATIONS_ALL pol,
         HZ_CUST_ACCT_SITES_ALL cust_acct,
         HZ_CUST_SITE_USES_ALL site_use
    WHERE pol.location_id = l_header_rec.ship_to_location_id
    AND site_use.site_use_id = pol.site_use_id
    AND cust_acct.cust_acct_site_id = site_use.cust_acct_site_id
    AND pol.org_id = l_source_operating_unit;

        CURSOR get_cust_site_id IS
            SELECT cust_acct.cust_acct_site_id,
              pol.customer_id,
              (SELECT cust_acct2.party_site_id
              FROM HZ_CUST_ACCT_SITES_ALL cust_acct2,
                HZ_CUST_SITE_USES_ALL site_use2
              WHERE cust_acct2.party_site_id   = cust_acct.party_site_id
              AND cust_acct2.org_id            = l_source_operating_unit
              AND cust_acct2.cust_account_id   = cust_acct.cust_account_id
              AND cust_acct2.cust_acct_site_id = site_use2.cust_acct_site_id
              AND site_use2.site_use_code      = 'SHIP_TO'
              AND site_use2.status             = 'A'
              AND cust_acct2.status            = 'A'
              ),
              pol.org_id
            FROM PO_LOCATION_ASSOCIATIONS_ALL pol,
              HZ_CUST_SITE_USES_ALL site_use,
              HZ_CUST_ACCT_SITES_ALL cust_acct
            WHERE pol.location_id          = l_header_rec.ship_to_location_id
            AND pol.site_use_id            = site_use.site_use_id
            AND site_use.cust_acct_site_id = cust_acct.cust_acct_site_id;

        CURSOR get_cust_site_id2 IS
            SELECT cust_acct.cust_acct_site_id,
              pol.customer_id,
              (SELECT cust_acct2.party_site_id
              FROM HZ_CUST_ACCT_SITES_ALL cust_acct2
              WHERE cust_acct2.party_site_id   = cust_acct.party_site_id
              AND cust_acct2.org_id            = l_source_operating_unit
              AND cust_acct2.cust_account_id   = cust_acct.cust_account_id
              AND cust_acct2.status            = 'A'
              ),
              pol.org_id,
              (SELECT cust_acct2.cust_acct_site_id
              FROM HZ_CUST_ACCT_SITES_ALL cust_acct2
              WHERE cust_acct2.party_site_id   = cust_acct.party_site_id
              AND cust_acct2.org_id            = l_source_operating_unit
              AND cust_acct2.cust_account_id   = cust_acct.cust_account_id
              )
            FROM PO_LOCATION_ASSOCIATIONS_ALL pol,
              HZ_CUST_SITE_USES_ALL site_use,
              HZ_CUST_ACCT_SITES_ALL cust_acct
            WHERE pol.location_id          = l_header_rec.ship_to_location_id
            AND pol.site_use_id            = site_use.site_use_id
            AND site_use.cust_acct_site_id = cust_acct.cust_acct_site_id;

         l_tmp_org_id number;
         l_party_site_id number;
         l_cust_site_id number;
         l_cust_acct_site_use_id NUMBER;
         v_cust_acct_site_rec  hz_cust_account_site_v2pub.cust_acct_site_rec_type;
         v_cust_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
         v_customer_profile_rec  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
         x_cust_acct_site_id NUMBER;
         x_site_use_id NUMBER;
         temp_bill_to_site_id number;
         temp_ship_to_use_id number;

         CURSOR get_new_cust_ids IS
          select
            cust_acct.cust_acct_site_id,
            site_use.site_use_id
          from
            HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL cust_acct
          where
            cust_acct.party_site_id = l_party_site_id
            -- AND cust_acct.cust_account_id = l_customer_id     -- bug # 12545721
            AND cust_acct.org_id = l_source_operating_unit
            AND cust_acct.cust_acct_site_id = site_use.cust_acct_site_id
            AND site_use.site_use_code = 'SHIP_TO'
            AND site_use.status = 'A'
            AND rownum = 1;

    cursor get_primary_bill_to (p_operating_unit number) is
    select site_use_id, cust_acct_site_id from HZ_CUST_SITE_USES_ALL where cust_acct_site_id in
        (select hsa.cust_acct_site_id from HZ_CUST_ACCT_SITES_ALL hsa
            where hsa.cust_account_id = l_cust_acct_id
            and hsa.status = 'A'
            and hsa.org_id = p_operating_unit)
    and site_use_code = 'BILL_TO'
    and primary_flag = 'Y'
    and status = 'A';

    v_primary_bill_site_use_id number;
    v_primary_bill_site_id number;

         cursor get_cust_acct_site_uses is
        SELECT site_use_id
        FROM hz_cust_site_uses_all
        WHERE cust_acct_site_id = l_cust_site_id
        AND status              = 'A'
        AND site_use_code NOT  IN
          (SELECT site_use_code
          FROM hz_cust_site_uses_all
          WHERE cust_acct_site_id = x_cust_acct_site_id
          AND status              = 'A'
          );

   v_ship_bill_site  number;
   v_bill_site_id number;
   v_bill_acct_site_rec hz_cust_account_site_v2pub.cust_acct_site_rec_type;
   v_pri_bill_acct_site_rec hz_cust_account_site_v2pub.cust_acct_site_rec_type;
   x_bill_acct_site_id number;
   x_pri_bill_acct_site_id number;
   l_bill_acct_site_use_id number;
   v_bill_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
   v_pri_bill_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
   v_bill_cust_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
   v_pri_bill_cust_prf_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

   cursor get_bill_site_id is
     select cust_acct_site_id
     from HZ_CUST_SITE_USES_ALL
     where site_use_code = 'BILL_TO'
     and site_use_id = v_ship_bill_site;

   cursor check_bill_to_location is
      select newu.site_use_id
     from HZ_CUST_SITE_USES_ALL orgu,
     HZ_CUST_ACCT_SITES_ALL orgs,
     HZ_CUST_SITE_USES_ALL newu,
     HZ_CUST_ACCT_SITES_ALL news
     where orgu.site_use_code = 'BILL_TO'
     and orgu.site_use_id = v_ship_bill_site
     and orgu.cust_acct_site_id = orgs.cust_acct_site_id
     and news.party_site_id = orgs.party_site_id
     and news.cust_acct_site_id = newu.cust_acct_site_id
     and newu.site_use_code = 'BILL_TO'
     and newu.location = orgu.location
     and news.org_id = l_source_operating_unit;

   l_existing_bill_to number;

         /*
    cursor get_bill_acct_site_uses is
          select site_use_id
          from hz_cust_site_uses_all
          where cust_acct_site_id = v_bill_site_id
    and site_use_id = v_ship_bill_site;
    */

         -- end of bug # 7759059

  -- Get Item Description for a given Item ID
  -- For the purpose of creating Approved Internal Requisition
  -- it is assumed that the calling procedure will always pass the Item ID
  -- so that Item Description can be derived.
  CURSOR item_Desc_cur(p_item_id NUMBER, p_orgn_id NUMBER) IS
    SELECT description
    FROM mtl_system_items_b
    WHERE inventory_item_id = p_item_id
    AND organization_id = p_orgn_id;
-- Bug 14494663 - Not required as in case of special ship address as we cannot create address
 /* CURSOR rs_loc_exists_cur(p_inv_loc_id NUMBER, p_resource_id NUMBER, p_resource_type VARCHAR2) IS

    SELECT ps.location_id site_loc_id
    from   csp_rs_cust_relations rcr,
           hz_cust_acct_sites cas,
           hz_cust_site_uses csu,
           po_location_associations pla,
           hz_party_sites ps
    where  rcr.customer_id = cas.cust_account_id
    and    cas.cust_acct_site_id = csu.cust_acct_site_id (+)
    and    csu.site_use_code = 'SHIP_TO'
    and    csu.site_use_id = pla.site_use_id
    and    cas.party_site_id = ps.party_site_id
    and    rcr.resource_type = p_resource_type
    and    rcr.resource_id = p_resource_id
    and    pla.location_id = p_inv_loc_id;*/

  CURSOR address_type_cur(p_rqmt_header_id NUMBER) IS
    SELECT crh.address_type,
           crh.ship_to_location_id,
           decode(crh.task_assignment_id,null,crh.resource_id,jta.resource_id),
           decode(crh.task_assignment_id,null,crh.resource_type,jta.resource_type_code)
    from   jtf_task_assignments jta,
           csp_requirement_headers crh
    where  jta.task_assignment_id(+) = crh.task_assignment_id
    and    crh.requirement_header_id = p_rqmt_header_id;

   /*  bug # 8474563
  CURSOR get_new_context(p_new_org_id number) IS
     SELECT      org_information2 ,
                 org_information3 ,
                 org_information4
     FROM        hr_organization_information hou
     WHERE       hou.organization_id = p_new_org_id
     AND         hou.org_information1 = 'FIELD_SERVICE'
     AND         hou.org_information_context =  'CS_USER_CONTEXT';
     */

  -- bug # 6471559
  cursor get_bill_to_for_sr (p_rqmt_header_id NUMBER) IS
     SELECT site_use.site_use_id, cia.ship_to_contact_id, cia.bill_to_contact_id
     FROM HZ_CUST_ACCT_SITES_ALL cust_acct,
        HZ_CUST_SITE_USES_ALL site_use,
        hz_party_site_uses hpsu,
        cs_incidents_all cia,
        csp_requirement_headers_v req
     WHERE req.requirement_header_id = p_rqmt_header_id
        and cia.incident_id = req.incident_id
        and cust_acct.cust_account_id = cia.bill_to_account_id
        and hpsu.party_site_use_id = cia.bill_to_site_use_id
        and cust_acct.party_site_id = hpsu.party_site_id
        and cust_acct.cust_acct_site_id = site_use.cust_acct_site_id
        and site_use.site_use_code = 'BILL_TO'
        and site_use.org_id = cia.org_id
        and site_use.status = 'A';

  l_bill_to_site_use_id number := null;

    cursor get_res_primary_bill_to(p_resource_id NUMBER, p_resource_type VARCHAR2) IS
    select csu.site_use_id
    from
        csp_rs_cust_relations cr,
        hz_cust_acct_sites cas,
        hz_cust_site_uses csu
    where
        cr.resource_type = p_resource_type
        and cr.resource_id = p_resource_id
        and cr.customer_id     = cas.cust_account_id
        and cas.bill_to_flag = 'P'
        and cas.cust_acct_site_id = csu.cust_acct_site_id
        and csu.site_use_code     = 'BILL_TO';

  l_sr_org_id number;
    new_user    VARCHAR2(240);

    cursor c_sr_src_bill_to (v_rqmt_header_id NUMBER, v_src_org_id number) is
	SELECT site_use.site_use_id
	FROM HZ_CUST_ACCT_SITES_ALL cust_acct,
	  HZ_CUST_SITE_USES_ALL site_use,
	  hz_party_site_uses hpsu,
	  cs_incidents_all cia,
	  csp_requirement_headers_v req,
	  po_location_associations_all pla,
	  HZ_CUST_ACCT_SITES_ALL cust_acct1,
	  HZ_CUST_SITE_USES_ALL site_use1
	WHERE req.requirement_header_id = v_rqmt_header_id
	AND req.address_type           IN ('C', 'T') -- bug # 14743823
	AND req.ship_to_location_id     = pla.location_id
	AND pla.site_use_id             = site_use1.site_use_id
	AND site_use1.cust_acct_site_id = cust_acct1.cust_acct_site_id
	AND cust_acct1.cust_account_id  = cust_acct.cust_account_id
	AND cia.incident_id             = req.incident_id
	AND cust_acct.cust_account_id   = cia.bill_to_account_id
	AND hpsu.party_site_use_id      = cia.bill_to_site_use_id
	AND cust_acct.party_site_id     = hpsu.party_site_id
	AND cust_acct.cust_acct_site_id = site_use.cust_acct_site_id
	AND site_use.site_use_code      = 'BILL_TO'
	AND site_use.org_id             = v_src_org_id
	AND site_use.status             = 'A';

  -- bug # 9320107
  l_ship_to_contact_id number;
  l_invoice_to_contact_id number;
  l_pr_ship_to_contact_id number;

  l_ship_to_contact_id_final number;
  l_invoice_to_contact_id_final number;

  cursor get_valid_contact_id (v_party_id number, v_org_id number) is
  SELECT  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID
  FROM
    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
    HZ_CUST_SITE_USES_ALL   SITE_USE,
    HZ_CUST_ACCT_SITES_all  ADDR
  WHERE
    ACCT_ROLE.party_id = v_party_id
    AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
    AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
    AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
    AND  SITE_USE.SITE_USE_ID = v_org_id
    AND  SITE_USE.STATUS = 'A'
    AND  ADDR.STATUS ='A'
    AND  ACCT_ROLE.STATUS = 'A'
    AND  ROWNUM = 1;

    CURSOR validate_order_type (v_org_id number, v_order_type_id number) IS
    SELECT 1
    FROM oe_transaction_types_all ot
    WHERE ot.org_id            = v_org_id
    AND ot.transaction_type_id = v_order_type_id
    AND sysdate BETWEEN NVL(ot.start_date_active, sysdate-1)
    AND NVL(ot.end_date_active, sysdate+1);

	cursor is_price_list_valid(v_price_list_id number, v_org_id number) is
	SELECT count(1)
	FROM QP_LIST_HEADERS_B
	WHERE list_header_id = v_price_list_id
	AND active_flag      = 'Y'
	AND (global_flag     = 'Y'
	OR orig_org_id       = v_org_id);

   cursor c_sr_account_id(v_req_header_id number) is
   SELECT cia.account_id
   FROM cs_incidents_all cia,
   csp_requirement_headers_v rh
   WHERE cia.incident_id        = rh.incident_id
   AND rh.requirement_header_id = v_req_header_id
and rh.address_type in ('C', 'T');

	l_price_list_valid number;

   orig_org_id             number;
   orig_user_id            number;
   orig_resp_id            number;
   orig_resp_appl_id       number;
   new_org_id              number;
   new_user_id             number;
   new_resp_id             number;
   new_resp_appl_id        number;

  l_address_type        VARCHAR2(30);
  l_ship_to_location_id NUMBER;
  l_site_loc_id         NUMBER;
  l_resource_id         NUMBER;
  l_resource_type       VARCHAR2(240);
  l_object_version_number   NUMBER;
  l_item_cost              NUMBER;
  l_scheduling_code     VARCHAR2(30);
  l_dest_operating_unit number;
  l_first_org_id  number;
  l_is_valid_order_type number;

  BEGIN

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.csp_parts_order.process_order',
                    'Begin');
  end if;

    SAVEPOINT Process_Order_PUB;

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

    l_user_id := nvl(fnd_global.user_id, 0) ;
    fnd_profile.get('RESP_ID',orig_resp_id);
    fnd_profile.get('RESP_APPL_ID',orig_resp_appl_id);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_parts_order.process_order',
                      'l_user_id = ' || l_user_id
                      || ', orig_resp_id = ' || orig_resp_id
                      || ', orig_resp_appl_id = ' || orig_resp_appl_id);
    end if;

    l_header_rec := px_header_rec;
    l_line_tbl := px_line_table;

    IF (l_line_Tbl.count <= 0 AND l_header_rec.operation <> CSP_PARTS_ORDER.G_OPR_CANCEL) THEN
      return;
    END IF;

    if l_header_rec.ship_to_location_id is null then
      select
        nvl(sub.location_id, org.location_id)
      into l_header_rec.ship_to_location_id
      from
        MTL_SECONDARY_INVENTORIES sub,
        hr_all_organization_units org
      where org.organization_id = l_header_rec.dest_organization_id
        and org.organization_id = sub.organization_id(+)
        and sub.secondary_inventory_name(+) = l_header_rec.dest_subinventory;
    end if;

    -- get all the values required to insert into po_requisition_header table
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id := nvl(fnd_global.user_id, 0) ;
    l_login_id := nvl(fnd_global.login_id, -1);

    -- operating unit
    BEGIN
      /*SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
      INTO   l_org_id
      FROM   dual;*/

      l_org_id := mo_global.get_current_org_id;
      l_first_org_id := l_org_id;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.csp_parts_order.process_order',
                        'Original l_org_id from context = ' || l_org_id);
      end if;

      BEGIN
        SELECT operating_unit
        INTO l_dest_operating_unit
        FROM org_organization_Definitions
        WHERE organization_id = l_header_rec.dest_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_dest_operating_unit', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
      END;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.csp_parts_order.process_order',
                        'l_dest_operating_unit = ' || l_dest_operating_unit);
      end if;

      if l_dest_operating_unit is not null
        and l_dest_operating_unit <> nvl(l_org_id, -999) then

          l_org_id := l_dest_operating_unit;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_org_id changed to = ' || l_org_id);
            end if;

      end if;

      po_moac_utils_pvt.set_org_context(l_org_id);
      l_sr_org_id := l_org_id;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.csp_parts_order.process_order',
                        'Setting org context for l_org_id = ' || l_org_id);
      end if;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          null;
    END;

    -- Get Set of Books Id.
    -- this is a required field for po_Req_distributions
    OPEN set_of_books_cur (l_org_id);
    FETCH set_of_books_cur INTO l_set_of_books_id;
    CLOSE set_of_books_cur;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_parts_order.process_order',
                      'l_header_rec.operation = ' || l_header_rec.operation);
    end if;

    IF (l_header_rec.operation = CSP_PARTS_ORDER.G_OPR_CANCEL) THEN
        Cancel_Order( p_header_rec  => l_header_rec,
                      p_line_table  => l_line_tbl,
                      p_process_type => p_process_type,
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data
                    );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.csp_parts_order.process_order',
                          'p_process_Type = ' || p_process_Type);
        end if;

        IF (p_process_Type = 'BOTH' or p_process_type = 'ORDER') THEN
          -- if address type is special check to see if the location exists in the engineers list
          -- if it does not exist, add it to the list
          IF (l_header_rec.requirement_header_id IS NOT NULL) THEN
            OPEN address_type_cur(l_header_rec.requirement_header_id);
            FETCH address_type_cur INTO l_address_type, l_ship_to_location_id, l_resource_id, l_resource_type;
            CLOSE address_type_cur;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_address_type = ' || l_address_type
                              || ', l_ship_to_location_id = ' || l_ship_to_location_id
                              || ', l_resource_id = ' || l_resource_id
                              || ', l_resource_type = ' || l_resource_type);
            end if;

            -- bug 12401673
            -- as we change ship to address, we should not use DB data
            -- we should get preference to whatever data passed to this API

            l_address_type := nvl(l_header_rec.address_type, l_address_type);
            l_ship_to_location_id := nvl(l_header_rec.ship_to_location_id, l_ship_to_location_id);

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_address_type = ' || l_address_type
                              || ', l_ship_to_location_id = ' || l_ship_to_location_id);
            end if;

            IF (l_address_type = 'S') THEN
             -- Bug 14494663 - Not required as in case of special ship address as we cannot create address
              /*OPEN rs_loc_exists_cur(l_ship_to_location_id, l_resource_id, l_resource_type);
              FETCH rs_loc_exists_cur INTO l_site_loc_id;
              IF (rs_loc_exists_cur%NOTFOUND) THEN
                -- call ship_to_address_handler for creating resource address
                csp_ship_to_address_pvt.ship_to_address_handler(
                        P_TASK_ASSIGNMENT_ID    => l_header_rec.task_assignment_id
                       ,P_RESOURCE_TYPE         => l_resource_type
                        ,P_RESOURCE_ID           => l_resource_id
                       ,P_CUSTOMER_ID           => l_customer_id
                        ,P_LOCATION_ID           => l_ship_to_location_id
                       ,P_STYLE                 => null
                       ,P_ADDRESS_LINE_1        => null
                        ,P_ADDRESS_LINE_2        => null
                        ,P_ADDRESS_LINE_3        => null
                        ,P_COUNTRY               => null
                        ,P_POSTAL_CODE           => null
                     ,P_REGION_1              => null
                     ,P_REGION_2              => null
                        ,P_REGION_3              => null
                        ,P_TOWN_OR_CITY          => null
                        ,P_TAX_NAME              => null
                        ,P_TELEPHONE_NUMBER_1    => null
                        ,P_TELEPHONE_NUMBER_2    => null
                        ,P_TELEPHONE_NUMBER_3    => null
                        ,P_LOC_INFORMATION13     => null
                        ,P_LOC_INFORMATION14     => null
                        ,P_LOC_INFORMATION15     => null
                        ,P_LOC_INFORMATION16     => null
                        ,P_LOC_INFORMATION17     => null
                        ,P_LOC_INFORMATION18     => null
                        ,P_LOC_INFORMATION19     => null
                       ,P_LOC_INFORMATION20     => null
                     ,P_TIMEZONE              => null
                      ,P_PRIMARY_FLAG          => null
                      ,P_STATUS                => null
                      ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                        ,p_API_VERSION_NUMBER    => l_api_version_number
                        ,P_INIT_MSG_LIST         => 'T'
                     ,P_COMMIT                => 'F'
                     ,P_ATTRIBUTE_CATEGORY    => NULL
                     ,P_ATTRIBUTE1            => NULL
                     ,P_ATTRIBUTE2            => NULL
                     ,P_ATTRIBUTE3            => NULL
                     ,P_ATTRIBUTE4            => NULL
                     ,P_ATTRIBUTE5            => NULL
                     ,P_ATTRIBUTE6            => NULL
                     ,P_ATTRIBUTE7            => NULL
                     ,P_ATTRIBUTE8            => NULL
                     ,P_ATTRIBUTE9            => NULL
                     ,P_ATTRIBUTE10           => NULL
                     ,P_ATTRIBUTE11           => NULL
                     ,P_ATTRIBUTE12           => NULL
                     ,P_ATTRIBUTE13           => NULL
                     ,P_ATTRIBUTE14           => NULL
                     ,P_ATTRIBUTE15           => NULL
                     ,P_ATTRIBUTE16           => NULL
                     ,P_ATTRIBUTE17           => NULL
                     ,P_ATTRIBUTE18           => NULL
                     ,P_ATTRIBUTE19           => NULL
                     ,P_ATTRIBUTE20           => NULL
                        ,X_RETURN_STATUS         => l_return_status
                        ,X_MSG_COUNT             => l_msg_count
                     ,X_MSG_DATA              => l_msg_data
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

              END If;
              CLOSE rs_loc_exists_cur;*/

              open get_res_primary_bill_to(l_resource_id, l_resource_type);
              fetch get_res_primary_bill_to into l_bill_to_site_use_id;
              close get_res_primary_bill_to;

            -- bug # 6471559
            ELSIF (l_address_type = 'C' or l_address_type = 'T') THEN
                open get_bill_to_for_sr(l_header_rec.requirement_header_id);
                fetch get_bill_to_for_sr into l_bill_to_site_use_id, l_ship_to_contact_id, l_invoice_to_contact_id;
                close get_bill_to_for_sr;

                l_sr_org_id := null;
                SELECT cia.org_id
                INTO l_sr_org_id
                FROM cs_incidents_all cia,
                  csp_requirement_headers_v req
                WHERE req.requirement_header_id = l_header_rec.requirement_header_id
                AND cia.incident_id             = req.incident_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_sr_org_id = ' || l_sr_org_id);
                end if;

            /*
            ELSIF (l_address_type = 'R') THEN
                open get_res_primary_bill_to(l_resource_id, l_resource_type);
                fetch get_res_primary_bill_to into l_bill_to_site_use_id;
                close get_res_primary_bill_to;
            */
            END If;

            -- bug # 13707506
            -- use ship to contact id while creating an internal order
            select nvl(ship_to_contact_id, -9999)
            into l_pr_ship_to_contact_id
            from csp_requirement_headers
            where requirement_header_id = l_header_rec.requirement_header_id;

            if l_pr_ship_to_contact_id <> -9999 then
                SELECT party_id
                into l_ship_to_contact_id
                FROM HZ_CUST_ACCOUNT_ROLES
                WHERE cust_account_role_id = l_pr_ship_to_contact_id;
            end if;
            -- end of bug # 13707506

          END IF;
        END If;



        IF (l_header_rec.operation = G_OPR_CREATE) THEN

          IF (p_process_Type IN ('REQUISITION', 'BOTH')) THEN

              -- requisition_header_id
              IF l_header_rec.requisition_header_id is null then
                OPEN req_header_id_cur;
                FETCH req_header_id_cur into l_header_rec.requisition_header_id;
                CLOSE req_header_id_cur;
              END IF;

              -- Requisition_number
              IF l_header_rec.requisition_number IS NULL THEN
                OPEN req_number_cur;
                FETCH req_number_cur INTO l_header_rec.requisition_number;
                UPDATE po_unique_identifier_control
                SET current_max_unique_identifier
                      = current_max_unique_identifier + 1
                WHERE  CURRENT of req_number_cur;
                CLOSE req_number_cur;
              END IF;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_header_rec.requisition_header_id = ' || l_header_rec.requisition_header_id
                                || ', l_header_rec.requisition_number = ' || l_header_rec.requisition_number);
              end if;

              -- preparer id
              IF l_user_id IS NOT NULL THEN
                OPEN employee_id_cur;
                FETCH employee_id_cur into l_employee_id;
                CLOSE employee_id_cur;

                  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_employee_id = ' || l_employee_id);
                    end if;

                     -- bug 12805692
                     -- if employee_id not found then use CSP_EMPLOYEE_ID profile value
                     IF l_employee_id is null then
                        FND_PROFILE.GET('CSP_EMPLOYEE_ID', l_employee_id);
                     end if;

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_employee_id = ' || l_employee_id);
                    end if;

              END IF;

              -- check for uniqueness of requisition_number
              BEGIN

                SELECT 1 INTO l_dummy
                FROM   DUAL
                WHERE NOT EXISTS
                  ( SELECT 1
                    FROM po_requisition_headers
                    WHERE Segment1 = l_header_rec.requisition_number)
                AND NOT EXISTS
                  ( SELECT 1
                    FROM   po_history_requisitions phr
                    WHERE  phr.segment1 = l_header_rec.requisition_number);

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  po_message_s.app_error('PO_ALL_ENTER_UNIQUE');
                  raise;
                WHEN OTHERS THEN
                  po_message_s.sql_error('check_unique','010',sqlcode);
                  raise;
              END;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'Inserting data into PO_REQUISITION_HEADERS');
              end if;
              -- create approved requisition headers
              -- insert into PO_REQUISITION_HEADERS
              INSERT INTO PO_REQUISITION_HEADERS(
                       org_id,
                       requisition_header_id,
                       preparer_id,
                       last_update_date,
                       last_updated_by,
                       segment1,
                       summary_flag,
                       enabled_flag,
                       segment2,
                       segment3,
                       segment4,
                       segment5,
                       start_date_active,
                       end_date_active,
                       last_update_login,
                       creation_date,
                       created_by,
                       description,
                       authorization_status,
                       note_to_authorizer,
                       type_lookup_code,
                       transferred_to_oe_flag,
                       attribute_category,
                       attribute1,
                       attribute2,
                       attribute3,
                       attribute4,
                       attribute5,
                       on_line_flag,
                       preliminary_research_flag,
                       research_complete_flag,
                       preparer_finished_flag,
                       preparer_finished_date,
                       agent_return_flag,
                       agent_return_note,
                       cancel_flag,
                       attribute6,
                       attribute7,
                       attribute8,
                       attribute9,
                       attribute10,
                       attribute11,
                       attribute12,
                       attribute13,
                       attribute14,
                       attribute15,
                       ussgl_transaction_code,
                       government_context,
                       interface_source_code,
                       interface_source_line_id,
                       closed_code
                     ) VALUES (
                       l_org_id,
                       l_header_rec.requisition_header_id,
                       l_employee_id,
                       l_today,
                       nvl(l_user_id, 1),
                       l_header_Rec.requisition_number,
                       'N',                    -- summary_flag
                       'Y',                    -- Enabled_Flag
                       null,
                       null,
                       null,
                       null,
                       null,                    -- Start_Date_Active
                       null,                    -- End_Date_Active
                       nvl(l_login_id, -1),     -- Last_Update_Login
                       l_today,                 -- Creation_Date
                       nvl(l_user_id, 1),             -- Created_By
                       l_header_rec.description, -- Description
                       'APPROVED',              -- Authorization_Status
                       null,                    -- note to Authorizor
                       'INTERNAL',              -- Type_Lookup_Code; need to confirm this. po_lookup_codes has different values for document_type

                       l_transferred_to_oe_flag,                     -- X_Transferred_To_Oe_Flag
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       'CSP',
                       null,
                       null
                     );

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'Inserting data into PO_ACTION_HISTORY');
              end if;
             -- insert 2 lines of history, one for SUBMIT and one for APPROVE
                     INSERT into PO_ACTION_HISTORY
                       (object_id,
                        object_type_code,
                        object_sub_type_code,
                        sequence_num,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        action_code,
                        action_date,
                        employee_id,
                        note,
                        object_revision_num,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        approval_path_id,
                        offline_code)
                    VALUES
                       (l_header_rec.requisition_header_id,
                        'REQUISITION',
                        'INTERNAL',
                        0,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        'SUBMIT',
                        sysdate,
                        l_employee_id,
                        null,
                        null,
                        fnd_global.login_id,
                        0,
                        0,
                        0,
                        '',
                        null,
                        '' );

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'Inserting data into PO_ACTION_HISTORY');
              end if;

                     INSERT into PO_ACTION_HISTORY
                       (object_id,
                        object_type_code,
                        object_sub_type_code,
                        sequence_num,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        action_code,
                        action_date,
                        employee_id,
                        note,
                        object_revision_num,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        approval_path_id,
                        offline_code)
                    VALUES
                       (l_header_rec.requisition_header_id,
                        'REQUISITION',
                        'INTERNAL',
                        1,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        'APPROVE',
                        sysdate,
                        l_employee_id,
                        null,
                        null,
                        fnd_global.login_id,
                        0,
                        0,
                        0,
                        '',
                        null,
                        '' );

          END IF;

          IF (p_process_Type IN ('ORDER', 'BOTH')) THEN

              BEGIN
                SELECT operating_unit
                INTO l_source_operating_unit
                FROM org_organization_Definitions
                WHERE organization_id = l_line_tbl(1).source_organization_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                  FND_MESSAGE.SET_TOKEN ('PARAMETER', 'source_org_operating_unit', FALSE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
              END;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_org_id = ' || l_org_id
                                || ', l_source_operating_unit = ' || l_source_operating_unit);
              end if;

              BEGIN
                IF (l_sr_org_id <> l_source_operating_unit) THEN
                  -- bug # 7644078
                  -- Here we are going to change the operating unit
                  -- so hlding old BILL TO from SR will not be a valid one
                  -- now, OM code will take proper BILL TO

                  -- bug # 12653874
                  -- try one more time, if we can get the bill to from SR
                  l_bill_to_site_use_id := null;
                  open c_sr_src_bill_to(l_header_rec.requirement_header_id, l_source_operating_unit);
                  fetch c_sr_src_bill_to into l_bill_to_site_use_id;
                  close c_sr_src_bill_to;

                  --l_ship_to_contact_id := null;
                  l_invoice_to_contact_id := null;
                END IF;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_bill_to_site_use_id = ' || l_bill_to_site_use_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_ship_to_contact_id = ' || l_ship_to_contact_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_invoice_to_contact_id = ' || l_invoice_to_contact_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'original l_header_rec.order_type_id = ' || l_header_rec.order_type_id);
              end if;

                l_is_valid_order_type := -999;
                open validate_order_type(l_source_operating_unit, l_header_rec.order_type_id);
                fetch validate_order_type into l_is_valid_order_type;
                close validate_order_type;

                if l_is_valid_order_type <> 1 then
                    SELECT ORDER_TYPE_ID
                    INTO l_header_rec.order_type_id
                    FROM  PO_SYSTEM_PARAMETERS_ALL
                    WHERE ORG_ID = l_source_operating_unit;
                end if;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'after validation l_header_rec.order_type_id = ' || l_header_rec.order_type_id);
              end if;

              -- get all required information for passing to process_orders
                SELECT hdr.price_list_id,
                         hdr.currency_code,
                         hdr.default_outbound_line_type_id,
                         line.price_list_id,
                         line.order_category_code,
                         nvl(line.scheduling_level_code, hdr.scheduling_level_code)
                    INTO l_price_list_id,
                         l_currency_code,
                         l_order_line_type_id,
                         l_line_price_list_id,
                         l_order_line_category_code,
                         l_scheduling_code
                    FROM   oe_transaction_types_all hdr,
                         oe_transaction_types_all line
                    WHERE  hdr.transaction_Type_id = l_header_rec.order_type_id
                    AND    line.transaction_type_id = hdr.default_outbound_line_type_id
                    AND    hdr.org_id = l_source_operating_unit
                    AND    line.org_id = l_source_operating_unit;
              EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      -- exception handler
                      null;
                    WHEN OTHERS THEN
                      -- exception handler
                      null;
              END;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_price_list_id = ' || l_price_list_id
                                || ', l_currency_code = ' || l_currency_code
                                || ', l_order_line_type_id = ' || l_order_line_type_id
                                || ', l_line_price_list_id = ' || l_line_price_list_id
                                || ', l_order_line_category_code = ' || l_order_line_category_code
                                || ', l_scheduling_code = ' || l_scheduling_code);
              end if;

              IF (l_currency_code IS NULL) THEN
                BEGIN
                  SELECT  glsob.CURRENCY_CODE
                  INTO    l_currency_code
                  FROM    GL_SETS_OF_BOOKS GLSOB,
                          FINANCIALS_SYSTEM_PARAMS_ALL FSP
                  WHERE   GLSOB.SET_OF_BOOKS_ID=FSP.SET_OF_BOOKS_ID
                  AND     nvl(FSP.org_id,-1) = l_source_operating_unit;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    null;
                  WHEN OTHERS THEN
                    null;

                END;
              END IF;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_currency_code = ' || l_currency_code);
              end if;

              -- get customer and ship to site
              OPEN cust_site_cur;
              FETCH cust_site_cur INTO l_customer_id, l_site_use_id, l_cust_acct_id;
              CLOSE cust_site_cur;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_customer_id = ' || l_customer_id
                                || ', l_site_use_id = ' || l_site_use_id
                                || ', l_cust_acct_id = ' || l_cust_acct_id);
              end if;

                      -- htank
                         -- bug #         7759059

                         IF l_customer_id IS NULL THEN
                         OPEN get_cust_site_id;
                         FETCH get_cust_site_id INTO l_cust_site_id, l_customer_id, l_party_site_id, l_tmp_org_id;
                         CLOSE get_cust_site_id;

                         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                            'csp.plsql.csp_parts_order.process_order',
                                                            'l_cust_site_id=' || l_cust_site_id
                                                            || ', l_customer_id=' || l_customer_id
                                                            || ', l_party_site_id=' || l_party_site_id
                                                            || ', l_tmp_org_id=' || l_tmp_org_id);
                         end if;

                         IF l_party_site_id IS NULL THEN

                            -- check if the site is already present
                            open get_cust_site_id2;
                            fetch get_cust_site_id2 into l_cust_site_id, l_customer_id, l_party_site_id, l_tmp_org_id, x_cust_acct_site_id;
                            close get_cust_site_id2;

                         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                            'csp.plsql.csp_parts_order.process_order',
                                                            'l_cust_site_id=' || l_cust_site_id
                                                            || ', l_customer_id=' || l_customer_id
                                                            || ', l_party_site_id=' || l_party_site_id
                                                            || ', l_tmp_org_id=' || l_tmp_org_id
                                                            || ', x_cust_acct_site_id = ' || x_cust_acct_site_id);
                         end if;

                         if l_party_site_id IS NULL THEN

                         -- get cust_site record in current ou
                         --dbms_application_info.set_client_info(l_tmp_org_id);
                         po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                         hz_cust_account_site_v2pub.get_cust_acct_site_rec (
                                                  p_init_msg_list => FND_API.G_TRUE,
                                                  p_cust_acct_site_id => l_cust_site_id,
                                                  x_cust_acct_site_rec => v_cust_acct_site_rec,
                                                  x_return_status => x_return_status,
                                                  x_msg_count => x_msg_count,
                                                  x_msg_data => x_msg_data);
                         --dbms_application_info.set_client_info(l_org_id);
                         po_moac_utils_pvt.set_org_context(l_tmp_org_id);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          l_msg := x_msg_data;
                          FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                          FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                          FND_MSG_PUB.ADD;
                          fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          --dbms_application_info.set_client_info(l_org_id);
                          RAISE FND_API.G_EXC_ERROR;
                         END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.csp_parts_order.process_order',
                                                          'populated v_cust_acct_site_rec');
                         end if;

                         v_cust_acct_site_rec.cust_acct_site_id := NULL;
          v_cust_acct_site_rec.tp_header_id := NULL;
          v_cust_acct_site_rec.language := NULL;
          v_cust_acct_site_rec.created_by_module := 'CSPSHIPAD';
                         v_cust_acct_site_rec.org_id := l_source_operating_unit;

                         -- now create same site in source ou
                         --dbms_application_info.set_client_info(l_source_operating_unit);
                         po_moac_utils_pvt.set_org_context(l_source_operating_unit);
                         hz_cust_account_site_v2pub.create_cust_acct_site (
                                                                            p_init_msg_list => FND_API.G_TRUE,
                                                                            p_cust_acct_site_rec => v_cust_acct_site_rec,
                                                                            x_cust_acct_site_id => x_cust_acct_site_id,
                                                                            x_return_status => x_return_status,
                                                                            x_msg_count => x_msg_count,
                                                                            x_msg_data => x_msg_data);
                         --dbms_application_info.set_client_info(l_org_id);
                         po_moac_utils_pvt.set_org_context(l_org_id);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          l_msg := x_msg_data;
                          FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                          FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                          FND_MSG_PUB.ADD;
                          fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          RAISE FND_API.G_EXC_ERROR;
                         END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.csp_parts_order.process_order',
                                                          'x_cust_acct_site_id=' || x_cust_acct_site_id);
                         end if;

                        end if; -- if l_party_site_id IS NULL THEN # 2

                         -- now fetch all site uses records and copy them to source ou
                         open get_cust_acct_site_uses;
                         LOOP
                          fetch get_cust_acct_site_uses into l_cust_acct_site_use_id;
                          EXIT WHEN get_cust_acct_site_uses%NOTFOUND;

                          --dbms_application_info.set_client_info(l_tmp_org_id);
                          po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                         hz_cust_account_site_v2pub.get_cust_site_use_rec (
                                            p_init_msg_list => FND_API.G_TRUE,
                                            p_site_use_id => l_cust_acct_site_use_id,
                                            x_cust_site_use_rec => v_cust_site_use_rec,
                                            x_customer_profile_rec => v_customer_profile_rec,
                                            x_return_status => x_return_status,
                                            x_msg_count => x_msg_count,
                                            x_msg_data => x_msg_data);
                         --dbms_application_info.set_client_info(l_org_id);
                         po_moac_utils_pvt.set_org_context(l_org_id);

                          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            l_msg := x_msg_data;
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                            FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                  ( p_count => x_msg_count
                                  , p_data  => x_msg_data);
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            --dbms_application_info.set_client_info(l_org_id);
                            RAISE FND_API.G_EXC_ERROR;
                          END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                            'csp.plsql.csp_parts_order.process_order',
                                                            'populated v_cust_site_use_rec');
                          end if;

                          v_cust_site_use_rec.site_use_id := NULL;
                          v_cust_site_use_rec.primary_flag := 'N';
                          v_cust_site_use_rec.created_by_module := 'CSPSHIPAD';
                          --v_cust_site_use_rec.location := 'CSP_LOCATION';
                          v_cust_site_use_rec.org_id := l_source_operating_unit;
                          v_cust_site_use_rec.cust_acct_site_id := x_cust_acct_site_id;
                          v_cust_site_use_rec.tax_code := NULL;

						l_price_list_valid := 0;
						if v_cust_site_use_rec.price_list_id is not null then
							open is_price_list_valid(v_cust_site_use_rec.price_list_id, l_source_operating_unit);
							fetch is_price_list_valid into l_price_list_valid;
							close is_price_list_valid;

							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
															'csp.plsql.csp_parts_order.process_order',
															'v_cust_site_use_rec.price_list_id=' || v_cust_site_use_rec.price_list_id
															|| ', l_price_list_valid=' || l_price_list_valid);
							end if;

							if l_price_list_valid = 0 then
							  v_cust_site_use_rec.price_list_id := null;
							end if;
						end if;

                          if v_cust_site_use_rec.site_use_code = 'SHIP_TO' then
              if v_cust_site_use_rec.bill_to_site_use_id is not null then
                v_ship_bill_site := v_cust_site_use_rec.bill_to_site_use_id;
                open get_bill_site_id;
                fetch get_bill_site_id into v_bill_site_id;
                close get_bill_site_id;

               if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'csp.plsql.csp_parts_order.process_order',
                       'v_bill_site_id = ' || v_bill_site_id);
               end if;

                if v_bill_site_id <> l_cust_site_id then

                   open check_bill_to_location;
                   fetch check_bill_to_location into l_existing_bill_to;
                   close check_bill_to_location;

                 if l_existing_bill_to is null then

                  -- do lots of stuff here
                  po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                  hz_cust_account_site_v2pub.get_cust_acct_site_rec (
                         p_init_msg_list => FND_API.G_TRUE,
                         p_cust_acct_site_id => v_bill_site_id,
                         x_cust_acct_site_rec => v_bill_acct_site_rec,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);
                  po_moac_utils_pvt.set_org_context(l_tmp_org_id);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   l_msg := x_msg_data;
                   FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                   FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                   FND_MSG_PUB.ADD;
                   fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                  END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           'csp.plsql.csp_parts_order.process_order',
                           'populated v_bill_acct_site_rec');
                  end if;

                  v_bill_acct_site_rec.cust_acct_site_id := NULL;
                  v_bill_acct_site_rec.tp_header_id := NULL;
                  v_bill_acct_site_rec.language := NULL;
                  v_bill_acct_site_rec.created_by_module := 'CSPSHIPAD';
                  v_bill_acct_site_rec.org_id := l_source_operating_unit;

                  -- now create same site in source ou
                  po_moac_utils_pvt.set_org_context(l_source_operating_unit);
                  hz_cust_account_site_v2pub.create_cust_acct_site (
                                 p_init_msg_list => FND_API.G_TRUE,
                                 p_cust_acct_site_rec => v_bill_acct_site_rec,
                                 x_cust_acct_site_id => x_bill_acct_site_id,
                                 x_return_status => x_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data);
                  po_moac_utils_pvt.set_org_context(l_org_id);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   l_msg := x_msg_data;
                   FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                   FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                   FND_MSG_PUB.ADD;
                   fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                  END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           'csp.plsql.csp_parts_order.process_order',
                           'x_bill_acct_site_id=' || x_bill_acct_site_id);
                  end if;

                  /*
                  open get_bill_acct_site_uses;
                  fetch get_bill_acct_site_uses into l_bill_acct_site_use_id;
                  close get_bill_acct_site_uses;
                  */
                  l_bill_acct_site_use_id := v_ship_bill_site;

                  po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                  hz_cust_account_site_v2pub.get_cust_site_use_rec (
                         p_init_msg_list => FND_API.G_TRUE,
                         p_site_use_id => l_bill_acct_site_use_id,
                         x_cust_site_use_rec => v_bill_site_use_rec,
                         x_customer_profile_rec => v_bill_cust_profile_rec,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);
                  po_moac_utils_pvt.set_org_context(l_org_id);

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     l_msg := x_msg_data;
                     FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                     FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                     FND_MSG_PUB.ADD;
                     fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     RAISE FND_API.G_EXC_ERROR;
                   END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                   if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'csp.plsql.csp_parts_order.process_order',
                             'populated v_bill_site_use_rec');
                   end if;

                   v_bill_site_use_rec.site_use_id := NULL;
                   v_bill_site_use_rec.primary_flag := 'N';
                   v_bill_site_use_rec.created_by_module := 'CSPSHIPAD';
                   v_bill_site_use_rec.org_id := l_source_operating_unit;
                   v_bill_site_use_rec.cust_acct_site_id := x_bill_acct_site_id;
                   v_bill_site_use_rec.tax_code := NULL;

						l_price_list_valid := 0;
						if v_bill_site_use_rec.price_list_id is not null then
							open is_price_list_valid(v_bill_site_use_rec.price_list_id, l_source_operating_unit);
							fetch is_price_list_valid into l_price_list_valid;
							close is_price_list_valid;

							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
															'csp.plsql.csp_parts_order.process_order',
															'v_bill_site_use_rec.price_list_id=' || v_bill_site_use_rec.price_list_id
															|| ', l_price_list_valid=' || l_price_list_valid);
							end if;

							if l_price_list_valid = 0 then
							  v_bill_site_use_rec.price_list_id := null;
							end if;
						end if;

                   po_moac_utils_pvt.set_org_context(l_source_operating_unit);
                   hz_cust_account_site_v2pub.create_cust_site_use (
                                 p_init_msg_list => FND_API.G_TRUE,
                                 p_cust_site_use_rec => v_bill_site_use_rec,
                                 p_customer_profile_rec => v_bill_cust_profile_rec,
                                 p_create_profile => FND_API.G_FALSE,
                                 p_create_profile_amt => FND_API.G_FALSE,
                                 x_site_use_id => x_site_use_id,
                                 x_return_status => x_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data);
                   po_moac_utils_pvt.set_org_context(l_org_id);

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     l_msg := x_msg_data;
                     FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                     FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                     FND_MSG_PUB.ADD;
                     fnd_msg_pub.count_and_get
                     ( p_count => x_msg_count
                     , p_data  => x_msg_data);
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     po_moac_utils_pvt.set_org_context(l_org_id);
                     RAISE FND_API.G_EXC_ERROR;
                   END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'x_site_use_id=' || x_site_use_id);
                  end if;

                  v_cust_site_use_rec.bill_to_site_use_id := x_site_use_id;

                 else
                   v_cust_site_use_rec.bill_to_site_use_id := l_existing_bill_to;
                 end if;

                else
                   v_cust_site_use_rec.bill_to_site_use_id := null;
                end if;
              end if;
              end if;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                'csp.plsql.csp_parts_order.process_order',
                                                'v_cust_site_use_rec.site_use_code=' || v_cust_site_use_rec.site_use_code
                                                || ', v_cust_site_use_rec.bill_to_site_use_id=' || v_cust_site_use_rec.bill_to_site_use_id);
              end if;

              --dbms_application_info.set_client_info(l_source_operating_unit);
              po_moac_utils_pvt.set_org_context(l_source_operating_unit);
              hz_cust_account_site_v2pub.create_cust_site_use (
                                                                      p_init_msg_list => FND_API.G_TRUE,
                                                                      p_cust_site_use_rec => v_cust_site_use_rec,
                                                                      p_customer_profile_rec => v_customer_profile_rec,
                                                                      p_create_profile => FND_API.G_FALSE,
                                                                      p_create_profile_amt => FND_API.G_FALSE,
                                                                      x_site_use_id => x_site_use_id,
                                                                      x_return_status => x_return_status,
                                                                      x_msg_count => x_msg_count,
                                                                      x_msg_data => x_msg_data);
              --dbms_application_info.set_client_info(l_org_id);
              po_moac_utils_pvt.set_org_context(l_org_id);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_msg := x_msg_data;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                      ( p_count => x_msg_count
                      , p_data  => x_msg_data);
                x_return_status := FND_API.G_RET_STS_ERROR;
                --dbms_application_info.set_client_info(l_org_id);
                po_moac_utils_pvt.set_org_context(l_org_id);
                RAISE FND_API.G_EXC_ERROR;
              END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              if v_cust_site_use_rec.site_use_code = 'BILL_TO' then
                temp_bill_to_site_id := x_site_use_id;
              end if;

              if v_cust_site_use_rec.site_use_code = 'SHIP_TO' then
                temp_ship_to_use_id := x_site_use_id;
              end if;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                'csp.plsql.csp_parts_order.process_order',
                                                'x_site_use_id=' || x_site_use_id);
              end if;

             END LOOP;
             close get_cust_acct_site_uses;

             l_party_site_id := v_cust_acct_site_rec.party_site_id;

             END IF; -- IF l_party_site_id IS NULL THEN

             --dbms_application_info.set_client_info(l_org_id);

             open get_new_cust_ids;
             fetch get_new_cust_ids into x_cust_acct_site_id, temp_ship_to_use_id;
             close get_new_cust_ids;

             if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                        'csp.plsql.csp_parts_order.process_order',
                                        'x_cust_acct_site_id=' || x_cust_acct_site_id
                                        || ', temp_ship_to_use_id=' || temp_ship_to_use_id);
             end if;

             -- update inventory_location link for this new site_use
             --dbms_application_info.set_client_info(l_source_operating_unit);
             po_moac_utils_pvt.set_org_context(l_source_operating_unit);
             arp_clas_pkg.insert_po_loc_associations(
                p_inventory_location_id       => l_header_rec.ship_to_location_id,
                p_inventory_organization_id   => l_source_operating_unit,
                p_customer_id                 => l_customer_id,
                p_address_id                  => x_cust_acct_site_id,
                p_site_use_id                 => temp_ship_to_use_id,
                      x_return_status               => x_return_status,
                      x_msg_count                   => x_msg_count,
                      x_msg_data                    => x_msg_data);
             --dbms_application_info.set_client_info(l_org_id);
             po_moac_utils_pvt.set_org_context(l_org_id);

             OPEN cust_site_cur;
             FETCH cust_site_cur INTO l_customer_id, l_site_use_id, l_cust_acct_id;
             CLOSE cust_site_cur;

             if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                        'csp.plsql.csp_parts_order.process_order',
                                        'l_customer_id=' || l_customer_id
                                        || ', l_site_use_id=' || l_site_use_id
                                        || ', l_cust_acct_id=' || l_cust_acct_id);
             end if;

             END IF; --IF l_customer_id IS NULL THEN
             -- end of bug # 7759059

            -- bug # 8850605
            -- check for primary bill to
            -- if not available, copy it from destination OU assuming there is
            -- one Primary Bill To available for the customer
            open get_primary_bill_to(l_source_operating_unit);
            fetch get_primary_bill_to into v_primary_bill_site_use_id, v_primary_bill_site_id;
            if get_primary_bill_to%notfound then
                close get_primary_bill_to;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.csp_parts_order.process_order',
                        'Primary Bill To is not available for source OU... Creating...');
                end if;

                if l_tmp_org_id is null then
                    l_tmp_org_id := l_org_id;
                end if;

                open get_primary_bill_to(l_tmp_org_id);
                fetch get_primary_bill_to into v_primary_bill_site_use_id, v_primary_bill_site_id;
                close get_primary_bill_to;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.csp_parts_order.process_order',
                        'v_primary_bill_site_use_id = ' || v_primary_bill_site_use_id
                        || ', v_primary_bill_site_id = ' || v_primary_bill_site_id);
                end if;

if v_primary_bill_site_id is not null and v_primary_bill_site_use_id is not null
then

                 -- do lots of stuff here
                 po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                 hz_cust_account_site_v2pub.get_cust_acct_site_rec (
                        p_init_msg_list => FND_API.G_TRUE,
                        p_cust_acct_site_id => v_primary_bill_site_id,
                        x_cust_acct_site_rec => v_pri_bill_acct_site_rec,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);
                 po_moac_utils_pvt.set_org_context(l_org_id);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_msg := x_msg_data;
                  FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                  FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                  FND_MSG_PUB.ADD;
                  fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
                 END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.csp_parts_order.process_order',
                          'populated v_pri_bill_acct_site_rec');
                 end if;

                 v_pri_bill_acct_site_rec.cust_acct_site_id := NULL;
                 v_pri_bill_acct_site_rec.tp_header_id := NULL;
                 v_pri_bill_acct_site_rec.language := NULL;
                 v_pri_bill_acct_site_rec.created_by_module := 'CSPSHIPAD';
                 v_pri_bill_acct_site_rec.org_id := l_source_operating_unit;

                 -- now create same site in source ou
                 po_moac_utils_pvt.set_org_context(l_source_operating_unit);
                 hz_cust_account_site_v2pub.create_cust_acct_site (
                                p_init_msg_list => FND_API.G_TRUE,
                                p_cust_acct_site_rec => v_pri_bill_acct_site_rec,
                                x_cust_acct_site_id => x_pri_bill_acct_site_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);
                 po_moac_utils_pvt.set_org_context(l_org_id);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_msg := x_msg_data;
                  FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                  FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                  FND_MSG_PUB.ADD;
                  fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
                 END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.csp_parts_order.process_order',
                          'x_bill_acct_site_id=' || x_pri_bill_acct_site_id);
                 end if;


                 po_moac_utils_pvt.set_org_context(l_tmp_org_id);
                 hz_cust_account_site_v2pub.get_cust_site_use_rec (
                        p_init_msg_list => FND_API.G_TRUE,
                        p_site_use_id => v_primary_bill_site_use_id,
                        x_cust_site_use_rec => v_pri_bill_site_use_rec,
                        x_customer_profile_rec => v_pri_bill_cust_prf_rec,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);
                 po_moac_utils_pvt.set_org_context(l_org_id);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_msg := x_msg_data;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                    FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.csp_parts_order.process_order',
                            'populated v_pri_bill_site_use_rec');
                  end if;

                  v_pri_bill_site_use_rec.site_use_id := NULL;
                  v_pri_bill_site_use_rec.primary_flag := 'N';
                  v_pri_bill_site_use_rec.created_by_module := 'CSPSHIPAD';
                  v_pri_bill_site_use_rec.org_id := l_source_operating_unit;
                  v_pri_bill_site_use_rec.cust_acct_site_id := x_pri_bill_acct_site_id;
                  v_pri_bill_site_use_rec.tax_code := NULL;

						l_price_list_valid := 0;
						if v_pri_bill_site_use_rec.price_list_id is not null then
							open is_price_list_valid(v_pri_bill_site_use_rec.price_list_id, l_source_operating_unit);
							fetch is_price_list_valid into l_price_list_valid;
							close is_price_list_valid;

							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
															'csp.plsql.csp_parts_order.process_order',
															'v_pri_bill_site_use_rec.price_list_id=' || v_pri_bill_site_use_rec.price_list_id
															|| ', l_price_list_valid=' || l_price_list_valid);
							end if;

							if l_price_list_valid = 0 then
							  v_pri_bill_site_use_rec.price_list_id := null;
							end if;
						end if;

                  po_moac_utils_pvt.set_org_context(l_source_operating_unit);
                  hz_cust_account_site_v2pub.create_cust_site_use (
                                p_init_msg_list => FND_API.G_TRUE,
                                p_cust_site_use_rec => v_pri_bill_site_use_rec,
                                p_customer_profile_rec => v_pri_bill_cust_prf_rec,
                                p_create_profile => FND_API.G_FALSE,
                                p_create_profile_amt => FND_API.G_FALSE,
                                x_site_use_id => x_site_use_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);
                  po_moac_utils_pvt.set_org_context(l_org_id);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_msg := x_msg_data;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                    FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    po_moac_utils_pvt.set_org_context(l_org_id);
                    RAISE FND_API.G_EXC_ERROR;
                  END IF; -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               'csp.plsql.csp_parts_order.process_order',
                               'x_site_use_id=' || x_site_use_id);
                 end if;
end if;
            else
                close get_primary_bill_to;
            end if;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.csp_parts_order.process_order',
                            'l_cust_acct_id=' || l_cust_acct_id);
            end if;

            open c_sr_account_id(l_header_rec.requirement_header_id);
            fetch c_sr_account_id into l_cust_acct_id;
            close c_sr_account_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.csp_parts_order.process_order',
                            'l_cust_acct_id=' || l_cust_acct_id);
            end if;


              -- SETTING UP THE ORDER PROCESS HEADER RECORD
              -- order_header_id
              IF l_header_rec.order_header_id IS NULL THEN
                 select oe_order_headers_s.nextval
                 into l_header_rec.order_header_id
                 from dual;
              END IF;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_header_rec.order_header_id = ' || l_header_rec.order_header_id);
              end if;

              -- Required attributes (e.g. Order Type and Customer)
              l_oe_header_rec.header_id := l_header_rec.order_header_id;
              --l_order_number := OE_Default_header.Get_Order_Number;
              l_oe_header_rec.order_number := null; --l_header_rec.order_header_id;
              l_oe_header_rec.version_number := 1;
              l_oe_header_rec.order_type_id := l_header_rec.order_type_id;
              l_oe_header_rec.org_id := l_source_operating_unit;
              l_oe_header_rec.sold_to_org_id := l_cust_acct_id;
              l_oe_header_rec.ship_to_org_id := l_site_use_id;

              -- bug # 6471559
             if l_bill_to_site_use_id is not NULL then
              l_oe_header_rec.invoice_to_org_id := l_bill_to_site_use_id;
             end if;


             if l_ship_to_contact_id is not null then

                open get_valid_contact_id(l_ship_to_contact_id, l_oe_header_rec.ship_to_org_id);
                fetch get_valid_contact_id into l_ship_to_contact_id_final;
                close get_valid_contact_id;

               if l_ship_to_contact_id_final is not null then
                l_oe_header_rec.ship_to_contact_id := l_ship_to_contact_id_final;
               end if;
             end if;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_oe_header_rec.ship_to_contact_id = ' || l_oe_header_rec.ship_to_contact_id);
              end if;

             if l_invoice_to_contact_id is not null and l_oe_header_rec.invoice_to_org_id is not null then

                open get_valid_contact_id(l_invoice_to_contact_id, l_oe_header_rec.invoice_to_org_id);
                fetch get_valid_contact_id into l_invoice_to_contact_id_final;
                close get_valid_contact_id;

               if l_invoice_to_contact_id_final is not null then
                l_oe_header_rec.INVOICE_TO_CONTACT_ID := l_invoice_to_contact_id_final;
               end if;
             end if;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_oe_header_rec.INVOICE_TO_CONTACT_ID = ' || l_oe_header_rec.INVOICE_TO_CONTACT_ID);
              end if;


             l_oe_header_rec.ORIG_SYS_DOCUMENT_REF := l_header_rec.requisition_number;
              l_oe_header_rec.SOURCE_DOCUMENT_ID := l_header_rec.requisition_header_id;
              l_oe_header_rec.transactional_curr_code := l_currency_code;
              l_oe_header_rec.open_flag := 'Y';

              /*
			  if nvl(p_book_order, 'Y') = 'Y' then
                l_oe_header_rec.booked_flag := l_line_tbl(1).booked_flag; --N;
              else
                l_oe_header_rec.booked_flag := 'N';
              end if;
			  */

              l_oe_header_rec.order_source_id := l_order_source_id;
              l_oe_header_rec.source_document_type_id := l_order_source_id;

              -- bug 8220079
              l_oe_header_rec.shipping_method_code := nvl(l_header_rec.shipping_method_code, FND_API.G_MISS_CHAR);


              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_oe_header_rec.shipping_method_code = ' || l_oe_header_rec.shipping_method_code);
              end if;

              -- Other attributes
              l_oe_header_rec.price_list_id := l_price_list_id;
          END IF;

          -- Indicates to process order that a new header is being created
          l_oe_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

        ELSIF (l_header_rec.operation = G_OPR_UPDATE) THEN
          IF (l_header_rec.order_header_id is null) THEN
             FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
             FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_header_rec.order_header_id', FALSE);

             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
          END IF;

          oe_header_util.Query_Row(
               p_header_id => l_header_rec.order_header_id,
               x_header_rec => l_oe_header_rec);

          -- Indicates to process order that header is to be updated
          l_oe_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
          l_oe_header_rec.booked_flag := l_line_tbl(1).booked_flag;

        END IF;

        /*IF (p_process_type in ('ORDER', 'BOTH')) THEN
            -- Required attributes (e.g. Order Type and Customer)
            l_oe_header_rec.header_id := l_header_rec.order_header_id;
            --l_order_number := OE_Default_header.Get_Order_Number;
            l_oe_header_rec.order_number := l_header_rec.order_header_id;
            l_oe_header_rec.version_number := 1;
            l_oe_header_rec.order_type_id := l_header_rec.order_type_id;
            l_oe_header_rec.org_id := l_org_id;
            l_oe_header_rec.sold_to_org_id := l_cust_acct_id;
            l_oe_header_rec.ship_to_org_id := l_site_use_id;
            l_oe_header_rec.ORIG_SYS_DOCUMENT_REF := l_header_rec.requisition_number;
            l_oe_header_rec.SOURCE_DOCUMENT_ID := l_header_rec.requisition_header_id;
            l_oe_header_rec.transactional_curr_code := l_currency_code;
            l_oe_header_rec.open_flag := 'Y';
            l_oe_header_rec.booked_flag := l_line_tbl(1).booked_flag; --N;
            l_oe_header_rec.order_source_id := l_order_source_id;
            l_oe_header_rec.source_document_type_id := l_order_source_id;

            -- Other attributes
            l_oe_header_rec.price_list_id := l_price_list_id;
        END IF;
        */

        -- get all the values required to insert into po_requisition_lines table

        -- line_type_id for Requisition
        OPEN line_type_cur;
        FETCH line_type_cur INTO l_line_type_rec;
        CLOSE line_type_cur;

        FOR I IN 1..l_line_tbl.COUNT LOOP

          IF (l_header_rec.operation = G_OPR_CREATE) THEN

            IF (p_process_type in ('REQUISITION', 'BOTH')) THEN
                 -- get requisition_line_id
                IF (l_line_tbl(i).Requisition_Line_Id is NULL) THEN
                  OPEN req_line_id_cur;
                  FETCH req_line_id_cur INTO l_line_tbl(i).requisition_line_id;
                  CLOSE req_line_id_cur;
                END IF;

                OPEN item_desc_cur(l_line_tbl(i).inventory_item_id, l_header_rec.dest_organization_id);
                FETCH item_desc_cur INTO l_line_tbl(i).item_description;
                IF item_Desc_cur%NOTFOUND THEN
                    CLOSE item_desc_cur;
                    FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_ITEM_ORGN');
                    FND_PROFILE.GET('CS_INV_VALIDATION_ORG', l_line_tbl(i).source_organization_id); -- taking dummy variable as we are going to throw an error only

                    if l_line_tbl(i).source_organization_id is not null then
                        SELECT concatenated_segments
                        INTO l_line_tbl(i).item_description     -- taking dummy variable as we are going to throw an error only
                        FROM   mtl_system_items_kfv
                        WHERE  organization_id = l_line_tbl(i).source_organization_id
                        and inventory_item_id = l_line_tbl(i).inventory_item_id;

                        select organization_code
                        into l_line_tbl(i).ATTRIBUTE1   -- taking dummy variable as we are going to throw an error only
                        from mtl_parameters
                        where organization_id = l_header_rec.dest_organization_id;

                        FND_MESSAGE.SET_TOKEN ('ITM', l_line_tbl(i).item_description, FALSE);
                        FND_MESSAGE.SET_TOKEN ('ORG', l_line_tbl(i).ATTRIBUTE1, FALSE);
                    end if;

                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE item_desc_cur;


                --IF (l_line_tbl(i).item_description IS NULL) THEN
                  OPEN item_desc_cur(l_line_tbl(i).inventory_item_id, l_line_tbl(i).source_organization_id);
                  FETCH item_desc_cur INTO l_line_tbl(i).item_description;
                  IF item_Desc_cur%NOTFOUND THEN
                    CLOSE item_desc_cur;
                    FND_MESSAGE.SET_NAME ('ONT', 'OE_INVALID_ITEM_WHSE');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
                  CLOSE item_desc_cur;
                --END IF;

                -- Get Category ID of the Item
                OPEN item_category_cur (l_line_tbl(i).inventory_item_id, l_header_rec.dest_organization_id);
                FETCH item_category_cur INTO l_category_id;
                CLOSE item_category_cur;

                -- Derive Unit_of_Measure from Uom_Code
                OPEN unit_of_measure_cur(l_line_tbl(i).unit_of_measure);
                FETCH unit_of_measure_cur INTO l_unit_meas_lookup_code;
                CLOSE unit_of_measure_cur;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'Getting Unit Price...');
              end if;

                /* Get Unit Price and Currency Code*/
                get_unit_price_prc (l_line_tbl(i).inventory_item_id
                   ,l_line_tbl(i).source_organization_id
                   ,l_header_rec.dest_organization_id
                   ,l_set_of_books_id
                   ,l_chart_of_accounts_id
                   ,l_currency_code
                   ,l_unit_price
                   ,l_item_cost );

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'Inserting data into PO_REQUISITION_LINES...');
                end if;

                -- insert into po_requisition_lines table
                INSERT INTO PO_REQUISITION_LINES(
                       org_id,
                       requisition_line_id,
                       requisition_header_id,
                       line_num,
                       line_type_id,
                       category_id,
                       item_description,
                       unit_meas_lookup_code,
                       unit_price,
                       quantity,
                       deliver_to_location_id,
                       to_person_id,
                       last_update_date,
                       last_updated_by,
                       source_type_code,
                       last_update_login,
                       creation_date,
                       created_by,
                       item_id,
                       item_revision,
                       encumbered_flag,
                       rfq_required_flag,
                       need_by_date,
                       source_organization_id,
                       source_subinventory,
                       destination_type_code,
                       destination_organization_id,
                       destination_subinventory,
                       cancel_flag,
               order_type_lookup_code,
                       purchase_basis,
                       matching_basis,
                       transferred_to_oe_flag
                      ) VALUES (
                       l_org_id,
                       l_line_tbl(i).requisition_line_id,
                       l_header_rec.requisition_header_id,
                       l_line_tbl(i).line_num,
                       l_line_type_rec.line_type_id,                 -- Line_Type_Id
                       nvl(l_Category_id, 1),          -- Category_id
                       l_line_tbl(i).item_description, -- Item_Description
                       nvl(l_unit_meas_lookup_code, l_line_tbl(i).unit_of_measure),  -- Unit_Meas_Lookup_Code
                       l_unit_price,
                       l_line_tbl(i).ordered_quantity,
                       l_header_rec.ship_to_location_id,       -- Deliver_To_Location_Id
                       l_employee_id,                  -- To_Person_Id
                       l_today,                        -- Last_Update_Date
                       nvl(l_user_id, -1),             -- Last_Updated_By
                       'INVENTORY',                    -- Source_Type_Code
                       nvl(l_login_id, -1),
                       l_today,                        -- Creation_Date
                       nvl(l_user_id, -1),
                       l_line_tbl(i).inventory_item_id,
                       l_line_tbl(i).revision,
                       'N',                             -- Encumbered_flag
                       'N',                             -- X_Rfq_Required_Flag
                       l_header_rec.need_by_date,
                       l_line_tbl(i).source_organization_id,
                       l_line_tbl(i).source_subinventory,
                       'INVENTORY',                         -- Destination_Type_Code
                       l_header_rec.dest_organization_id,
                       nvl(l_line_tbl(i).dest_subinventory, l_header_rec.dest_subinventory), /* Bug  7242187*/
                       'N',
               l_line_type_rec.order_type_lookup_code,
                       l_line_type_rec.purchase_basis,
                       l_line_Type_rec.matching_basis,                                  --Cancel_Flag
                       l_transferred_to_oe_flag
                );

                -- create req distributions
                -- It is assumed that only 1 dIstribution line will be there for each
                   -- INTERNAL Requisition.  If Multiple Distributions Lines are to created
                   -- this procedure should be modified

                  -- Get Distribution ID from the Distribution Sequence
                OPEN dist_line_id_cur;
                FETCH dist_line_id_cur INTO l_dist_rec.distribution_id;
                CLOSE dist_line_id_cur;

                -- Assign Requisition Line ID if NULL
                l_dist_rec.requisition_line_id := l_line_tbl(i).requisition_line_id;
                l_dist_rec.org_id := l_org_id;

                -- Assign Requisition Quantity if NULL
                l_dist_rec.req_line_quantity := l_line_tbl(i).ordered_quantity;

                -- Assign Requisition Line Number as Distribution Number
                l_dist_rec.distribution_num := l_line_tbl(i).line_num;

                -- Assign SYSDATE to gl_encumbered_date
                l_dist_rec.gl_encumbered_date := l_today;
                l_dist_rec.prevent_encumbrance_flag := 'N';
                --s_chart_of_accounts_id := 101;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_header_rec.dest_organization_id = ' || l_header_rec.dest_organization_id);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_line_tbl(i).inventory_item_id = ' || l_line_tbl(i).inventory_item_id);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_line_Tbl(i).dest_subinventory = ' || l_line_Tbl(i).dest_subinventory);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_header_rec.dest_subinventory = ' || l_header_rec.dest_subinventory);
            end if;

                -- Get Charge Account ID
                l_dist_rec.code_combination_id := get_charge_account_fun
                                                 (l_header_rec.dest_organization_id,
                                                  l_line_tbl(i).inventory_item_id,
                                                  nvl(l_line_Tbl(i).dest_subinventory, l_header_rec.dest_subinventory));     -- bug # 12433536 scheduler does not pass l_line_Tbl(i).dest_subinventory


            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'Checking Valid Account Id...');
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_dist_rec.code_combination_id = '
                              || l_dist_rec.code_combination_id);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_dist_rec.gl_encumbered_date = '
                              || to_char(l_dist_rec.gl_encumbered_date, 'DD-MON-YYYY HH24:MI:SS'));
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'l_chart_of_accounts_id = '
                              || l_chart_of_accounts_id);
            end if;

                -- Check for valid charge account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.code_combination_id,
                                             l_dist_rec.gl_encumbered_date,
                                             l_chart_of_accounts_id) THEN
                  Raise INVALID_CHARGE_ACCOUNT;
            END IF;

                -- Get Accrual Account ID and Variance Account ID for the
                --Destination Organization from MTL_PARAMETERS

                OPEN accrual_account_id_cur (l_header_Rec.dest_organization_id);
                FETCH accrual_account_id_cur
                INTO l_dist_rec.accrual_account_id,
                     l_dist_rec.variance_account_id;
                CLOSE accrual_account_id_cur;

                -- Check for valid accrual account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.accrual_account_id,
                                             l_dist_rec.gl_encumbered_date,
                                             l_chart_of_accounts_id) THEN
                  Raise INVALID_ACCRUAL_ACCOUNT;
                END IF;

                -- Check for valid variance account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.variance_account_id,
                                             l_dist_rec.gl_encumbered_date,
                                             l_chart_of_accounts_id) THEN
                  Raise INVALID_VARIANCE_ACCOUNT;
                END IF;

                -- Assign Set of Books ID
                l_dist_rec.set_of_books_id := l_set_of_books_id;

                -- Get Requisition Encumbrance Flag for Financial System Parameters

                -- If Req_Encumbrance_flag = 'Y' populate Budget Account ID for
                -- Req Distribution
                -- If gl_encumbered_flag = 'N' then don't populate gl_encumbered_date

                OPEN req_encumbrance_cur (l_dist_rec.set_of_books_id);
                FETCH req_encumbrance_cur INTO l_dist_rec.encumbered_flag;
                CLOSE req_encumbrance_cur;

                -- bug # 12359711
                l_dist_rec.prevent_encumbrance_flag := l_dist_rec.encumbered_flag;
                --l_dist_rec.encumbered_flag := 'N';

                IF l_dist_rec.encumbered_flag = 'Y' THEN
                    OPEN budget_account_cur (l_header_rec.dest_organization_id,
                                            l_line_tbl(i).inventory_item_id);
                    FETCH budget_account_cur INTO l_dist_rec.budget_account_id;
                    CLOSE budget_account_cur;

                    -- Check for valid budget account.  If Invalid Raise ERROR
                    IF NOT valid_account_id_fun (l_dist_rec.budget_account_id,
                                                l_dist_rec.gl_encumbered_date,
                                                l_chart_of_accounts_id) THEN
                      Raise INVALID_BUDGET_ACCOUNT;
                    END IF;
                ELSE
                   l_dist_rec.gl_encumbered_date := '';
                END IF;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'prevent_encumbrance_flag = ' || l_dist_rec.prevent_encumbrance_flag
                                  || ', encumbered_flag = ' || l_dist_rec.encumbered_flag);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'Inserting data into po_req_distributions ...');
                end if;

                -- create po_req_distributions
                INSERT INTO po_req_distributions(
                      distribution_id
                    ,last_update_date
                    ,last_updated_by
                    ,requisition_line_id
                    ,set_of_books_id
                    ,code_combination_id
                    ,req_line_quantity
                    ,last_update_login
                    ,creation_date
                    ,created_by
                    ,encumbered_flag
                    ,gl_encumbered_date
                    ,gl_encumbered_period_name
                    ,gl_cancelled_date
                    ,failed_funds_lookup_code
                    ,encumbered_amount
                    ,budget_account_id
                    ,accrual_account_id
                    ,variance_account_id
                    ,prevent_encumbrance_flag
                    ,attribute_category
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,ussgl_transaction_code
                    ,government_context
                    ,project_id
                    ,task_id
                    ,expenditure_type
                    ,project_accounting_context
                    ,expenditure_organization_id
                    ,gl_closed_date
                    ,source_req_distribution_id
                    ,distribution_num
                    ,project_related_flag
                    ,expenditure_item_date
                    ,org_id
                    ,allocation_type
                    ,allocation_value
                    ,award_id
                    ,end_item_unit_number
                    ,recoverable_tax
                    ,nonrecoverable_tax
                    ,recovery_rate
                    ,tax_recovery_override_flag
                    ,oke_contract_line_id
                    ,oke_contract_deliverable_id
                    )
                VALUES
                    (
                     l_dist_rec.distribution_id
                    ,l_today     --last_update_date
                    ,l_user_id      --last_updated_by
                    ,l_dist_rec.requisition_line_id
                    ,l_dist_rec.set_of_books_id
                    ,l_dist_rec.code_combination_id
                    ,l_dist_rec.req_line_quantity
                    ,l_login_id  --last_update_login
                    ,l_today     --creation_date
                    ,l_user_id   --created_by
                    ,l_dist_rec.encumbered_flag
                    ,l_dist_rec.gl_encumbered_date
                    ,l_dist_rec.gl_encumbered_period_name
                    ,l_dist_rec.gl_cancelled_date
                    ,l_dist_rec.failed_funds_lookup_code
                    ,l_dist_rec.encumbered_amount
                    ,l_dist_rec.budget_account_id
                    ,l_dist_rec.accrual_account_id
                    ,l_dist_rec.variance_account_id
                    ,l_dist_rec.prevent_encumbrance_flag
                    ,l_dist_rec.attribute_category
                    ,l_dist_rec.attribute1
                    ,l_dist_rec.attribute2
                    ,l_dist_rec.attribute3
                    ,l_dist_rec.attribute4
                    ,l_dist_rec.attribute5
                    ,l_dist_rec.attribute6
                    ,l_dist_rec.attribute7
                    ,l_dist_rec.attribute8
                    ,l_dist_rec.attribute9
                    ,l_dist_rec.attribute10
                    ,l_dist_rec.attribute11
                    ,l_dist_rec.attribute12
                    ,l_dist_rec.attribute13
                    ,l_dist_rec.attribute14
                    ,l_dist_rec.attribute15
                    ,l_dist_rec.ussgl_transaction_code
                    ,l_dist_rec.government_context
                    ,l_dist_rec.project_id
                    ,l_dist_rec.task_id
                    ,l_dist_rec.expenditure_type
                    ,l_dist_rec.project_accounting_context
                    ,l_dist_rec.expenditure_organization_id
                    ,l_dist_rec.gl_closed_date
                    ,l_dist_rec.source_req_distribution_id
                    ,l_dist_rec.distribution_num
                    ,l_dist_rec.project_related_flag
                    ,l_dist_rec.expenditure_item_date
                    ,l_dist_rec.org_id
                    ,l_dist_rec.allocation_type
                    ,l_dist_rec.allocation_value
                    ,l_dist_rec.award_id
                    ,l_dist_rec.end_item_unit_number
                    ,l_dist_rec.recoverable_tax
                    ,l_dist_rec.nonrecoverable_tax
                    ,l_dist_rec.recovery_rate
                    ,l_dist_rec.tax_recovery_override_flag
                      ,l_dist_rec.oke_contract_line_id
                      ,l_dist_rec.oke_contract_deliverable_id
                );


            END IF;

            IF (p_process_type in ('ORDER', 'BOTH')) THEN
                -- SETTING UP THE ORDER PROCESS LINE RECORD

                /* Same as 115.10 bug 5362711 but for R12 */
                /* Get Unit Price and Currency Code*/
                get_unit_price_prc (l_line_tbl(i).inventory_item_id
                   ,l_line_tbl(i).source_organization_id
                   ,l_header_rec.dest_organization_id
                   ,l_set_of_books_id
                   ,l_chart_of_accounts_id
                   ,l_currency_code
                   ,l_unit_price
                   ,l_item_cost );

                IF l_line_tbl(i).order_line_id IS NULL THEN
                   select oe_order_lines_s.nextval
                   into l_line_tbl(i).order_line_id
                   from dual;
                END IF;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'l_line_tbl(i).order_line_id ('
                                  || to_char(i) || ') = ' || l_line_tbl(i).order_line_id);
                end if;

                l_oe_line_rec.org_id := l_source_operating_unit;
                l_oe_line_rec.header_id := l_oe_header_rec.header_id;
                l_oe_line_rec.line_id := l_line_tbl(i).order_line_id;
                l_oe_line_rec.line_number := l_line_tbl(i).line_num;
                /*
                IF (nvl(l_scheduling_code, 'THREE') = 'THREE' OR
                    nvl(l_scheduling_code, 'THREE') = 'FOUR') THEN
                  l_oe_line_rec.reserved_quantity := l_line_tbl(i).ordered_quantity;
                END IF;
                */
                l_oe_line_rec.line_type_id := l_order_line_type_id;
                l_oe_line_rec.inventory_item_id := l_line_tbl(i).inventory_item_id;
                l_oe_line_rec.item_revision := l_line_tbl(i).revision;
                l_oe_line_rec.order_quantity_uom := l_line_tbl(i).unit_of_measure;
        IF (l_line_price_list_id IS NOT NULL) THEN
                 l_oe_line_rec.price_list_id := l_line_price_list_id;
        END IF;
                l_oe_line_rec.ORIG_SYS_DOCUMENT_REF := l_header_rec.requisition_number;
                l_oe_line_rec.ORIG_SYS_LINE_REF := l_line_tbl(i).line_num;
                l_oe_line_rec.ship_from_org_id := l_line_tbl(i).source_organization_id;
                IF (l_oe_line_rec.subinventory IS NOT NULL) THEN
                  l_oe_line_rec.subinventory := l_line_tbl(i).source_subinventory;
                END IF;
                l_oe_line_rec.request_date := nvl(l_header_rec.need_by_date,sysdate);


                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'l_line_tbl(i).arrival_date = ' || l_line_tbl(i).arrival_date);
                end if;

                if l_line_tbl(i).arrival_date is not null then
					l_oe_line_rec.promise_date := l_line_tbl(i).arrival_date;
					l_oe_line_rec.actual_arrival_date := l_line_tbl(i).arrival_date;
					--l_oe_line_rec.request_date := l_line_tbl(i).arrival_date;
                end if;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'l_oe_line_rec.promise_date = ' || l_oe_line_rec.promise_date);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.csp_parts_order.process_order',
                                  'l_oe_line_rec.request_date = ' || l_oe_line_rec.request_date);
                end if;

                l_oe_line_rec.sold_to_org_id := l_cust_acct_id;
                l_oe_line_rec.ship_to_org_id := l_site_use_id;

                -- bug # 6471559
                if l_bill_to_site_use_id is not NULL then
                 l_oe_line_rec.invoice_to_org_id := l_bill_to_site_use_id;
                end if;

                if l_oe_header_rec.ship_to_contact_id is not null then
                  l_oe_line_rec.ship_to_contact_id := l_oe_header_rec.ship_to_contact_id;
                end if;

                if l_oe_header_rec.INVOICE_TO_CONTACT_ID is not null then
                  l_oe_line_rec.INVOICE_TO_CONTACT_ID := l_oe_header_rec.INVOICE_TO_CONTACT_ID;
                end if;

                l_oe_line_rec.line_category_code := l_order_line_category_code;
                l_oe_line_rec.order_source_id := l_order_source_id;
                l_oe_line_rec.source_document_type_id := l_order_source_id;
                l_oe_line_rec.source_document_id := l_header_rec.requisition_header_id;
                l_oe_line_rec.source_document_line_id := l_line_tbl(i).requisition_line_id;
                l_oe_line_rec.ship_set := l_line_tbl(i).ship_complete;
                l_oe_line_Rec.shipping_method_code := nvl(l_line_tbl(i).shipping_method_code, FND_API.G_MISS_CHAR);

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'l_oe_line_Rec.shipping_method_code = ' || l_oe_line_Rec.shipping_method_code);
              end if;

                l_oe_line_Rec.calculate_price_flag := 'N';
                l_oe_line_Rec.unit_list_price := l_unit_price;
                l_oe_line_Rec.unit_Selling_price := l_unit_price;
                l_oe_line_Rec.open_flag := 'Y';
                l_oe_line_rec.ordered_quantity := l_line_tbl(i).ordered_quantity;

                /*
				if nvl(p_book_order, 'Y') = 'Y' then
                    l_oe_line_rec.booked_flag := l_line_tbl(i).booked_Flag; --N;
                else
                    l_oe_line_rec.booked_flag := 'N';
                end if;
				*/

                l_oe_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
            END IF;

          ELSIF (l_header_rec.operation = CSP_PARTS_ORDER.G_OPR_UPDATE) THEN
            IF (p_process_Type = 'REQUISITION') THEN
              IF (l_line_Tbl(I).requisition_line_id IS NULL) THEN
                 FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_line_rec.requisition_line_id', FALSE);
                 FND_MSG_PUB.ADD;
                 RAISE EXCP_USER_DEFINED;
              END IF;

              -- update requisition line table with new quantity
              -- quantity is the only change allowed
              update po_requisition_lines
              set quantity = l_line_tbl(I).ordered_quantity
              where requisition_line_id = l_line_Tbl(I).requisition_line_id;

              -- update req distributions with new quantity
              update po_req_distributions
              set req_line_quantity = l_line_tbl(i).ordered_quantity
              where requisition_line_id = l_line_tbl(i).requisition_line_id;

              -- update mtl_supply data for the requisition
              IF NOT po_supply.po_req_supply(
                         p_docid         => null,
                         p_lineid        => l_line_Tbl(I).requisition_line_id,
                         p_shipid        => null,
                         p_action        => 'Update_Req_Line_Qty',
                         p_recreate_flag => NULL,
                         p_qty           => l_line_tbl(i).ordered_quantity,
                         p_receipt_date  => NULL) THEN

                   PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '035',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

            ELSIF (p_process_type in ('ORDER', 'BOTH')) THEN
              IF (l_line_tbl(i).order_line_id IS NULL) THEN
                 FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_line_rec.order_line_id', FALSE);

                 FND_MSG_PUB.ADD;
                 RAISE EXCP_USER_DEFINED;
              END IF;

              -- l_oe_line_Rec := oe_line_util.Query_Row(l_line_tbl(i).order_line_id);

              l_oe_line_rec.line_id := l_line_tbl(i).order_line_id;
              l_oe_line_rec.booked_flag := l_line_tbl(i).booked_Flag;
              l_oe_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
            END If;

          END IF;

          --l_oe_line_rec.ordered_quantity := l_line_tbl(i).ordered_quantity;
          --l_oe_line_rec.booked_flag := l_line_tbl(i).booked_Flag; --N;

          -- Adding this record to the line table to be passed to process order
          l_oe_line_tbl(i) := l_oe_line_rec;

        END LOOP;

        -- create supply information for requisitions created
        IF (p_process_type in ('REQUISITION', 'BOTH') AND l_header_Rec.operation = G_OPR_CREATE) THEN

          /*IF NOT po_supply.po_req_supply(
                         p_docid         => l_header_rec.requisition_header_id,
                         p_lineid        => null,
                         p_shipid        => null,
                         p_action        => 'Approve_Req_Supply',
                         p_recreate_flag => NULL,
                         p_qty           => NULL,
                         p_receipt_date  => NULL) THEN


                   PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '005',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
          END IF;
          */
          BEGIN

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'Deleting record from mtl_supply...');
            end if;

             DELETE FROM mtl_supply ms1
             WHERE ms1.supply_source_id IN
             (
               SELECT pl.requisition_line_id
               FROM po_requisition_lines pl
               WHERE pl.requisition_header_id = l_header_rec.requisition_header_id
               AND NVL(pl.modified_by_agent_flag, 'N') <> 'Y'
               AND NVL(pl.closed_code, 'OPEN') = 'OPEN'
               AND NVL(pl.cancel_flag, 'N') = 'N'
               AND pl.line_location_id IS NULL
             )
             AND ms1.supply_type_code = 'REQ';

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'Inserting data into mtl_supply...');
            end if;

             INSERT INTO mtl_supply
               (supply_type_code,
                supply_source_id,
                last_updated_by,
                last_update_date,
                last_update_login,
                created_by,
                creation_date,
                req_header_id,
                req_line_id,
                item_id,
                item_revision,
                quantity,
                unit_of_measure,
                receipt_date,
                need_by_date,
                destination_type_code,
                location_id,
                from_organization_id,
                from_subinventory,
                to_organization_id,
                to_subinventory,
                change_flag)
               SELECT 'REQ',
                       prl.requisition_line_id,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       created_by,
                       creation_date,
                       prl.requisition_header_id,
                       prl.requisition_line_id,
                       prl.item_id,
                       decode(prl.source_type_code,'INVENTORY', null,
                              prl.item_revision),
                       prl.quantity - ( nvl(prl.QUANTITY_CANCELLED, 0) +
                                        nvl(prl.QUANTITY_DELIVERED, 0) ),
                       prl.unit_meas_lookup_code,
                       prl.need_by_date,
                       prl.need_by_date,
                       prl.destination_type_code,
                       prl.deliver_to_location_id,
                       prl.source_organization_id,
                       prl.source_subinventory,
                       prl.destination_organization_id,
                       prl.destination_subinventory,
                       'Y'
                FROM   po_requisition_lines prl
                WHERE  prl.requisition_header_id = l_header_rec.requisition_header_id
                AND    nvl(prl.modified_by_agent_flag,'N') <> 'Y'
                AND    nvl(prl.CLOSED_CODE,'OPEN') = 'OPEN'
                AND    nvl(prl.CANCEL_FLAG, 'N') = 'N'
                -- <Doc Manager Rewrite R12>: Filter out amount basis
                AND    prl.matching_basis <> 'AMOUNT'
                AND    prl.line_location_id is null
                AND    not exists
                       (SELECT 'supply exists'
                        FROM   mtl_supply ms
                        WHERE  ms.supply_type_code = 'REQ'
                        AND ms.supply_source_id = prl.requisition_line_id);
           EXCEPTION
             when no_data_found THEN

                  PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '005',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
                  RAISE FND_API.G_EXC_ERROR;
           END;


        END IF;
        BEGIN
          update mtl_supply
          set expected_delivery_date = nvl(l_header_rec.need_by_date, sysdate),
              need_by_date = nvl(l_header_rec.need_by_date, sysdate)
          where req_header_id = l_header_rec.requisition_header_id;
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;

        IF (p_process_type in ('ORDER', 'BOTH')) THEN
        -- cross operating unit order
            IF (l_source_operating_unit <> l_org_id) THEN
              /*
              OPEN  get_new_context(l_source_operating_unit);
              FETCH get_new_context
                INTO  new_user_id,new_resp_id,new_resp_appl_id;
              CLOSE get_new_context;
              */
            fnd_profile.get('CSP_IO_USER', new_user);
            new_user_id := substr(new_user, 1, instr(new_user, '~') - 1);
            new_user := substr(ltrim(new_user, new_user_id), 3);
            new_resp_id := substr(new_user, 1, instr(new_user, '~') - 1);
            new_resp_appl_id := substr(ltrim(new_user, new_resp_id), 3);

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'new_user = ' || new_user
                              || ', new_user_id = ' || new_user_id
                              || ', new_resp_id = ' || new_resp_id
                              || ', new_resp_appl_id = ' || new_resp_appl_id);
            end if;

              IF   new_resp_id is not null and
                   new_user_id is not null and
                   new_resp_appl_id is not null THEN
                   fnd_global.apps_initialize(new_user_id,new_resp_id,new_resp_appl_id);
                   mo_global.set_policy_context('S', l_source_operating_unit);
                 /*  fnd_profile.get('ORG_ID',new_org_id); --Operating Unit for the new context.
                   IF l_source_operating_unit <> new_org_id THEN
                       FND_MESSAGE.Set_Name('CS','CS_CHG_NEW_CONTEXT_OU_NOT_MATCH'); --to be seeded.
                       FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
                       FND_MSG_PUB.Add;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  */
             ELSE
                --dbms_application_info.set_client_info(l_source_operating_unit);
                mo_global.set_policy_context('S', l_source_operating_unit);
            END IF;
            END If;

            -- CONTROL RECORD
            -- Use the default settings
            l_oe_control_rec.controlled_operation := FALSE;
            l_oe_control_rec.default_Attributes := TRUE;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.csp_parts_order.process_order',
                              'Now finally calling OE_Order_PUB.Process_Order for operation = '
                              || l_oe_header_rec.operation);
            end if;

            -- CALL TO PROCESS ORDER
            IF  (l_oe_header_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN

            -- CALL TO PROCESS ORDER
                l_action_request_tbl(1).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;

                if nvl(p_book_order, 'Y') = 'Y' then
                    l_action_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;
                end if;
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'start calling requirement order dff hook...');
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of before calling the hook api PR Header : Attribute 1 :  ' || px_header_rec.ATTRIBUTE1 || ' , ' ||
                      'Attribute 2 : ' || px_header_rec.ATTRIBUTE2 || ' , ' ||
                      'Attribute 3 : ' || px_header_rec.ATTRIBUTE3 || ' , ' ||
                      'Attribute 4 :' || px_header_rec.ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || px_header_rec.ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || px_header_rec.ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || px_header_rec.ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || px_header_rec.ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || px_header_rec.ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || px_header_rec.ATTRIBUTE10 || ' , ' ||
                      'Attribute 11:' || px_header_rec.ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || px_header_rec.ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || px_header_rec.ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || px_header_rec.ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || px_header_rec.ATTRIBUTE15);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of before  calling the hook api OE Header : Attribute 1: ' || l_oe_header_rec.ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || l_oe_header_rec.ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || l_oe_header_rec.ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || l_oe_header_rec.ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || l_oe_header_rec.ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || l_oe_header_rec.ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || l_oe_header_rec.ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || l_oe_header_rec.ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || l_oe_header_rec.ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || l_oe_header_rec.ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || l_oe_header_rec.ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || l_oe_header_rec.ATTRIBUTE12 || ' , ' ||
                      'Attribute 13:' || l_oe_header_rec.ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || l_oe_header_rec.ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || l_oe_header_rec.ATTRIBUTE15);
          for k in 1..px_line_table.count loop
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of before  calling the hook api PR Line'  || k || ': Attribute 1: ' || px_line_table(k).ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || px_line_table(k).ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || px_line_table(k).ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || px_line_table(k).ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || px_line_table(k).ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || px_line_table(k).ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || px_line_table(k).ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || px_line_table(k).ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || px_line_table(k).ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || px_line_table(k).ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || px_line_table(k).ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || px_line_table(k).ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || px_line_table(k).ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || px_line_table(k).ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || px_line_table(k).ATTRIBUTE15);
            end loop;
            for k in 1..l_oe_line_tbl.count loop
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of before  calling the hook api OE Line'  || k || ': Attribute 1: ' || l_oe_line_tbl(k).ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || l_oe_line_tbl(k).ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || l_oe_line_tbl(k).ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || l_oe_line_tbl(k).ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || l_oe_line_tbl(k).ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || l_oe_line_tbl(k).ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || l_oe_line_tbl(k).ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || l_oe_line_tbl(k).ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || l_oe_line_tbl(k).ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || l_oe_line_tbl(k).ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || l_oe_line_tbl(k).ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || l_oe_line_tbl(k).ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || l_oe_line_tbl(k).ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || l_oe_line_tbl(k).ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || l_oe_line_tbl(k).ATTRIBUTE15);
            end loop;

            end if;
        csp_process_order_hook.update_oe_dff_info(
             px_req_header_rec => px_header_rec
            ,px_req_line_table => px_line_table
            ,px_oe_header_rec  => l_oe_header_rec
            ,px_oe_line_table  => l_oe_line_tbl);
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of after calling the hook api PR Header : Attribute 1 :  ' || px_header_rec.ATTRIBUTE1 || ' , ' ||
                      'Attribute 2 : ' || px_header_rec.ATTRIBUTE2 || ' , ' ||
                      'Attribute 3 : ' || px_header_rec.ATTRIBUTE3 || ' , ' ||
                      'Attribute 4 :' || px_header_rec.ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || px_header_rec.ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || px_header_rec.ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || px_header_rec.ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || px_header_rec.ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || px_header_rec.ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || px_header_rec.ATTRIBUTE10 || ' , ' ||
                      'Attribute 11:' || px_header_rec.ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || px_header_rec.ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || px_header_rec.ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || px_header_rec.ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || px_header_rec.ATTRIBUTE15);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of after  calling the hook api OE Header : Attribute 1: ' || l_oe_header_rec.ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || l_oe_header_rec.ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || l_oe_header_rec.ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || l_oe_header_rec.ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || l_oe_header_rec.ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || l_oe_header_rec.ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || l_oe_header_rec.ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || l_oe_header_rec.ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || l_oe_header_rec.ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || l_oe_header_rec.ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || l_oe_header_rec.ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || l_oe_header_rec.ATTRIBUTE12 || ' , ' ||
                      'Attribute 13:' || l_oe_header_rec.ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || l_oe_header_rec.ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || l_oe_header_rec.ATTRIBUTE15);
          for k in 1..px_line_table.count loop
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of after  calling the hook api PR Line'  || k || ': Attribute 1: ' || px_line_table(k).ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || px_line_table(k).ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || px_line_table(k).ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || px_line_table(k).ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || px_line_table(k).ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || px_line_table(k).ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || px_line_table(k).ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || px_line_table(k).ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || px_line_table(k).ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || px_line_table(k).ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || px_line_table(k).ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || px_line_table(k).ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || px_line_table(k).ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || px_line_table(k).ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || px_line_table(k).ATTRIBUTE15);
            end loop;
            for k in 1..l_oe_line_tbl.count loop
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp.plsql.csp_parts_order.process_order',
                      'Values of after  calling the hook api OE Line'  || k || ': Attribute 1: ' || l_oe_line_tbl(k).ATTRIBUTE1 || ' , ' ||
                      'Attribute 2: ' || l_oe_line_tbl(k).ATTRIBUTE2 || ' , ' ||
                      'Attribute 3: ' || l_oe_line_tbl(k).ATTRIBUTE3 || ' , ' ||
                      'Attribute 4: ' || l_oe_line_tbl(k).ATTRIBUTE4 || ' , ' ||
                      'Attribute 5: ' || l_oe_line_tbl(k).ATTRIBUTE5 || ' , ' ||
                      'Attribute 6: ' || l_oe_line_tbl(k).ATTRIBUTE6 || ' , ' ||
                      'Attribute 7: ' || l_oe_line_tbl(k).ATTRIBUTE7 || ' , ' ||
                      'Attribute 8: ' || l_oe_line_tbl(k).ATTRIBUTE8 || ' , ' ||
                      'Attribute 9: ' || l_oe_line_tbl(k).ATTRIBUTE9 || ' , ' ||
                      'Attribute 10: ' || l_oe_line_tbl(k).ATTRIBUTE10 || ' , ' ||
                      'Attribute 11: ' || l_oe_line_tbl(k).ATTRIBUTE11 || ' , ' ||
                      'Attribute 12: ' || l_oe_line_tbl(k).ATTRIBUTE12 || ' , ' ||
                      'Attribute 13: ' || l_oe_line_tbl(k).ATTRIBUTE13 || ' , ' ||
                      'Attribute 14: ' || l_oe_line_tbl(k).ATTRIBUTE14 || ' , ' ||
                      'Attribute 15: ' || l_oe_line_tbl(k).ATTRIBUTE15);
            end loop;
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'end of calling requirement order dff hook...');
            end if;
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'Starting OW Debug...');

                oe_debug_pub.G_FILE := NULL;
                oe_debug_pub.debug_on;
                oe_debug_pub.initialize;
                oe_debug_pub.setdebuglevel(5);

                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'OE Debug File : '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE'));

                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'l_line_tbl.count = '|| l_line_tbl.count);
            end if;

            OE_Order_PUB.Process_Order(
                  p_org_id             => l_source_operating_unit
                 ,p_api_version_number => l_api_version_number
                 ,p_init_msg_list      => FND_API.G_TRUE
                 ,p_return_values      => FND_API.G_FALSE
                 ,p_action_commit      => FND_API.G_FALSE
                 -- Passing just the entity records that are a part of this order

                 ,p_header_rec             => l_oe_header_rec
                 ,p_line_tbl            => l_oe_line_tbl
                 ,p_action_request_tbl  => l_action_request_tbl
                 -- OUT variables
                 ,x_header_rec            => lx_oe_header_rec
                 ,x_header_val_rec      => l_oe_Header_Val_rec
                 ,x_header_adj_tbl        => l_oe_header_adj_tbl
                 ,x_Header_Adj_val_tbl   => l_oe_header_adj_val_tbl
                 ,x_Header_price_Att_tbl => l_oe_header_price_att_tbl
                 ,x_Header_Adj_Att_tbl   => l_oe_Header_Adj_Att_Tbl
                 ,x_Header_Adj_Assoc_tbl => l_oe_Header_Adj_Assoc_Tbl
                 ,x_header_scredit_tbl   => l_oe_header_scr_tbl
                 ,x_Header_Scredit_val_tbl => l_oe_Header_Scredit_Val_Tbl
                 ,x_line_tbl             => lx_oe_line_tbl
                 ,x_line_val_tbl         => l_oe_Line_Val_Tbl
                 ,x_line_adj_tbl         => l_oe_line_adj_tbl
                 ,x_Line_Adj_val_tbl     => l_oe_Line_Adj_Val_Tbl
                 ,x_Line_price_Att_tbl   => l_oe_Line_Price_Att_Tbl
                 ,x_Line_Adj_Att_tbl     => l_oe_Line_Adj_Att_Tbl
                 ,x_Line_Adj_Assoc_tbl   => l_oe_Line_Adj_Assoc_Tbl
                 ,x_Line_Scredit_tbl     => l_oe_line_scr_tbl
                 ,x_Line_Scredit_val_tbl => l_oe_Line_Scredit_Val_Tbl
                 ,x_Lot_Serial_tbl       => l_oe_Lot_Serial_Tbl
                 ,x_Lot_Serial_val_tbl   => l_oe_Lot_Serial_Val_Tbl
                 ,x_action_request_tbl     => l_oe_Request_Tbl_Type
                 ,x_return_status         => l_return_status
                 ,x_msg_count             => l_msg_count
                 ,x_msg_data             => l_msg_data
                );
            ELSE
                 --p_action_request_tbl => l_action_request_tbl
                 OE_Order_PUB.Process_Order(
                  p_org_id             => l_source_operating_unit
                 ,p_api_version_number => l_api_version_number
                 ,p_init_msg_list      => FND_API.G_TRUE
                 ,p_return_values      => FND_API.G_FALSE
                 ,p_action_commit      => FND_API.G_FALSE
                 -- Passing just the entity records that are a part of this order
                 -- OUT variables
                 ,x_header_rec            => lx_oe_header_rec
                 ,x_header_val_rec      => l_oe_Header_Val_rec
                 ,x_header_adj_tbl        => l_oe_header_adj_tbl
                 ,x_Header_Adj_val_tbl   => l_oe_header_adj_val_tbl
                 ,x_Header_price_Att_tbl => l_oe_header_price_att_tbl
                 ,x_Header_Adj_Att_tbl   => l_oe_Header_Adj_Att_Tbl
                 ,x_Header_Adj_Assoc_tbl => l_oe_Header_Adj_Assoc_Tbl
                 ,x_header_scredit_tbl   => l_oe_header_scr_tbl
                 ,x_Header_Scredit_val_tbl => l_oe_Header_Scredit_Val_Tbl
                 ,x_line_tbl             => lx_oe_line_tbl
                 ,x_line_val_tbl         => l_oe_Line_Val_Tbl
                 ,x_line_adj_tbl         => l_oe_line_adj_tbl
                 ,x_Line_Adj_val_tbl     => l_oe_Line_Adj_Val_Tbl
                 ,x_Line_price_Att_tbl   => l_oe_Line_Price_Att_Tbl
                 ,x_Line_Adj_Att_tbl     => l_oe_Line_Adj_Att_Tbl
                 ,x_Line_Adj_Assoc_tbl   => l_oe_Line_Adj_Assoc_Tbl
                 ,x_Line_Scredit_tbl     => l_oe_line_scr_tbl
                 ,x_Line_Scredit_val_tbl => l_oe_Line_Scredit_Val_Tbl
                 ,x_Lot_Serial_tbl       => l_oe_Lot_Serial_Tbl
                 ,x_Lot_Serial_val_tbl   => l_oe_Lot_Serial_Val_Tbl
                 ,x_action_request_tbl     => l_oe_Request_Tbl_Type
                 ,x_return_status         => l_return_status
                 ,x_msg_count             => l_msg_count
                 ,x_msg_data             => l_msg_data
                );
             END IF;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'Stopping OE debug ...');
                oe_debug_pub.debug_off;
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csp.plsql.csp_parts_order.process_order',
                    'l_return_status = ' || l_return_status);
            end if;

            -- dbms_application_info.set_client_info(l_org_id);
            --IF (l_source_operating_unit <> l_org_id) THEN
              fnd_global.apps_initialize(l_user_id,orig_resp_id,orig_resp_appl_id);

              if l_first_org_id is not null then
                mo_global.set_org_context(l_first_org_id,null,'CSF');
              end if;
            --END If;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              for counter in REVERSE 1..l_msg_count Loop
                l_msg := OE_MSG_PUB.Get(counter,FND_API.G_FALSE) ;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_PROCESS_ORDER_ERRORS');
                FND_MESSAGE.SET_TOKEN('OM_MSG', l_msg, FALSE);
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                  , p_data  => x_msg_data);
              End loop;
              x_return_status := FND_API.G_RET_STS_ERROR;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.csp_parts_order.process_order',
                                'Error in OE_Order_PUB.Process_Order API... Message = '
                                || l_msg);
              end if;

              RAISE FND_API.G_EXC_ERROR;
            ELSE
              -- assign output variables with respected values if operation is CREATE

              IF (l_header_Rec.operation = G_OPR_CREATE) THEN
                l_header_rec.order_header_id := lx_oe_header_rec.header_id;

                FOR i in 1..lx_oe_line_tbl.count LOOP
                  l_line_tbl(i).order_line_id := lx_oe_line_tbl(i).line_id;
                END LOOP;
                px_header_rec := l_header_rec;
                px_line_table := l_line_tbl;
              ELSIF (l_header_rec.operation = G_OPR_UPDATE) THEN
                -- update requisition line table with new quantity
                -- quantity is the only change allowed
                FOR i in 1..lx_oe_line_tbl.count LOOP
                  IF (lx_oe_line_tbl(I).ordered_quantity IS NOT NULL OR
                      lx_oe_line_tbl(I).ordered_quantity <> FND_API.G_MISS_NUM) THEN
                    update po_requisition_lines
                    set quantity = lx_oe_line_tbl(I).ordered_quantity
                    where requisition_line_id = lx_oe_line_Tbl(I).source_document_line_id;


                    -- update req distributions
                    update po_req_distributions
                    set req_line_quantity = lx_oe_line_tbl(I).ordered_quantity
                    where requisition_line_id = lx_oe_line_Tbl(I).source_document_line_id;


                    -- update mtl_supply data for the requisition
                    IF NOT po_supply.po_req_supply(
                         p_docid         => null,
                         p_lineid        => lx_oe_line_Tbl(I).source_document_line_id,
                         p_shipid        => null,
                         p_action        => 'Update_Req_Line_Qty',
                         p_recreate_flag => NULL,
                         p_qty           => lx_oe_line_tbl(I).ordered_quantity,
                         p_receipt_date  => NULL) THEN

                       PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_SUPPLY',
                               token2 => 'ERR_NUMBER',
                               value2 => '035',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_REQ_SUPPLY()');
                       RAISE FND_API.G_EXC_ERROR;
               END IF;
                  END IF;
                END LOOP;
              END If;
            END IF;
        END IF;

        px_header_rec := l_header_rec;
        px_line_table := l_line_tbl;

        fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                  , p_data  => x_msg_data);

    END If;

    -- Bug 13417397. Setting the change_flag back to NULL
    BEGIN
      update mtl_supply
      set change_flag = NULL
      where req_header_id = l_header_rec.requisition_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    -- bug # 12568146
    if x_return_status is null then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.csp_parts_order.process_order',
                    'process_order API returning with x_return_status = ' || x_return_status);
    end if;

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

    WHEN INVALID_CHARGE_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_CHARGE_ACC_ID');
        raise;

    WHEN INVALID_ACCRUAL_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_ACCRUAL_ACC_ID');
        raise;

    WHEN INVALID_BUDGET_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_BUDGET_ACC_ID');
        raise;

    WHEN INVALID_VARIANCE_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_VARIANCE_ACC_ID');
        raise;

    WHEN OTHERS THEN
      Rollback to process_order_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;




  /**************************************************************************
  ***************************************************************************
  ***************************************************************************
                    PROCESS_PURCHASE_REQUSITION
  ***************************************************************************
  ***************************************************************************
  ***************************************************************************/


  PROCEDURE process_purchase_req(
          p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2
         ,p_commit                  IN VARCHAR2
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        )
  IS

   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'process_purchase_req';
   l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_today                  DATE;
   l_employee_id            NUMBER;
   l_org_id                 NUMBER;
   l_line_type_id           NUMBER;
   l_dummy                  NUMBER;

   l_header_rec             csp_parts_requirement.header_rec_type;
   l_line_rec               csp_parts_requirement.line_rec_type;
   l_line_tbl               csp_parts_requirement.Line_tbl_type;

   l_gl_encumbered_date     DATE;
   l_prevent_encumbrance_flag VARCHAR2(1);
   l_chart_of_accounts_id   NUMBER;
   l_charge_account_id      NUMBER;
   l_unit_of_measure        VARCHAR2(30);
   l_justification          VARCHAR2(480);
   l_note_to_buyer          VARCHAR2(480);
   l_note1_id               NUMBER;
   l_note1_title            VARCHAR2(80);
   l_SUGGESTED_VENDOR_ID    NUMBER;
   l_SUGGESTED_VENDOR_NAME  VARCHAR2(240);
   l_source_organization_id NUMBER;
   l_autosource_flag VARCHAR2(10);
   l_dest_operating_unit number;

   l_planner_employee_id  NUMBER;

   l_VENDOR_ID NUMBER;
   l_VENDOR_SITE_ID NUMBER;

   EXCP_USER_DEFINED        EXCEPTION;
   INVALID_CHARGE_ACCOUNT   EXCEPTION;

   -- Get requisition_number (PO_REQUSITION_HEADERS.segment1)
   CURSOR req_number_cur IS
     SELECT to_char(current_max_unique_identifier + 1)
     FROM   po_unique_identifier_control
     WHERE  table_name = 'PO_REQUISITION_HEADERS'
     FOR    UPDATE OF current_max_unique_identifier;

   -- Get unique requisition_header_id
   CURSOR req_header_id_cur IS
     SELECT po_requisition_headers_s.nextval
     FROM sys.dual;

   -- Get unique requisition_line_id
   CURSOR req_line_id_cur IS
     SELECT po_requisition_lines_s.nextval
     FROM sys.dual;

   -- Get preparer_id
   CURSOR employee_id_cur IS
     SELECT employee_id
     FROM fnd_user
     WHERE user_id = l_user_id;

  BEGIN

    SAVEPOINT Process_Order_PUB;

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

    l_header_rec := px_header_rec;
    l_line_tbl := px_line_table;

    -- Get data for populating who columns
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id := nvl(fnd_global.user_id, 0) ;
    l_login_id := nvl(fnd_global.login_id, -1);

    -- operating unit
    -- changed for bug 11847583
    BEGIN
        l_org_id := mo_global.get_current_org_id;

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  'csp.plsql.csp_parts_order.process_purchase_req',
                    'Original l_org_id from context = ' || l_org_id);
        end if;

        BEGIN
            SELECT operating_unit
            INTO l_dest_operating_unit
            FROM org_organization_Definitions
            WHERE organization_id = l_header_rec.dest_organization_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_dest_operating_unit', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,    'csp.plsql.csp_parts_order.process_purchase_req',
                    'l_dest_operating_unit = ' || l_dest_operating_unit);
        end if;

        if l_dest_operating_unit is not null  and l_dest_operating_unit <> nvl(l_org_id, -999) then
            l_org_id := l_dest_operating_unit;

            if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,  'csp.plsql.csp_parts_order.process_purchase_req',
                        'l_org_id changed to = ' || l_org_id);
            end if;
        end if;
        po_moac_utils_pvt.set_org_context(l_org_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          null;
    END;

    -- requisition_header_id
    IF l_header_rec.requisition_header_id is null then
      OPEN req_header_id_cur;
      FETCH req_header_id_cur into l_header_rec.requisition_header_id;
      CLOSE req_header_id_cur;
    END IF;

    -- Requisition_number
    -- IF l_header_rec.requisition_number IS NULL THEN
      OPEN req_number_cur;
      FETCH req_number_cur INTO l_header_rec.requisition_number;
      UPDATE po_unique_identifier_control
        SET current_max_unique_identifier
              = current_max_unique_identifier + 1
        WHERE  CURRENT of req_number_cur;
      CLOSE req_number_cur;
    --END IF;

    -- preparer id
    IF l_user_id IS NOT NULL THEN
      OPEN employee_id_cur;
      FETCH employee_id_cur into l_employee_id;
      CLOSE employee_id_cur;
    END IF;

    -- check for uniqueness of requisition_number
    BEGIN

      SELECT 1 INTO l_dummy
      FROM   DUAL
      WHERE NOT EXISTS
        ( SELECT 1
          FROM po_requisition_headers
          WHERE Segment1 = l_header_rec.requisition_number)
      AND NOT EXISTS
        ( SELECT 1
          FROM   po_history_requisitions phr
          WHERE  phr.segment1 = l_header_rec.requisition_number);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        po_message_s.app_error('PO_ALL_ENTER_UNIQUE');
        raise;
      WHEN OTHERS THEN
        po_message_s.sql_error('check_unique','010',sqlcode);
        raise;
    END;

    FND_PROFILE.GET('CSP_PO_LINE_TYPE', l_line_Type_id);

    FOR I IN 1..l_line_tbl.COUNT LOOP

      -- get requisition_line_id
      IF (l_line_tbl(i).Requisition_Line_Id is NULL) THEN
        OPEN req_line_id_cur;
        FETCH req_line_id_cur INTO l_line_tbl(i).requisition_line_id;
        CLOSE req_line_id_cur;
      END IF;

      -- Assign SYSDATE to gl_encumbered_date
      l_gl_encumbered_date := l_today;
      l_prevent_encumbrance_flag := 'N';

      -- Get Charge Account ID
      l_charge_account_id := get_charge_account_fun(l_header_rec.dest_organization_id,
                                                    l_line_tbl(i).inventory_item_id,
                                                    l_line_tbl(i).dest_subinventory);

      BEGIN
        SELECT unit_of_measure
    INTO l_unit_of_measure
    FROM mtl_item_uoms_view
    WHERE organization_id = l_header_rec.dest_organization_id
    AND inventory_item_id = l_line_Tbl(i).inventory_item_id
    AND uom_code = l_line_Tbl(i).unit_of_measure;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
      l_unit_of_measure := l_line_tbl(i).unit_of_measure;
      END;

     /*
      -- Check for valid charge account.  If Invalid Raise ERROR
      IF NOT valid_account_id_fun(l_charge_account_id,
                                  l_gl_encumbered_date,
                                  l_chart_of_accounts_id) THEN
          Raise INVALID_CHARGE_ACCOUNT;
      END IF;
    */


      If l_header_rec.CALLED_FROM = 'REPAIR_EXECUTION' then
         l_justification := l_header_rec.JUSTIFICATION;
         l_note_to_buyer := l_header_rec.NOTE_TO_BUYER;
         l_note1_id      := l_header_rec.note1_id;
         l_note1_title   := l_header_rec.note1_title;
         l_SUGGESTED_VENDOR_ID := l_header_rec.SUGGESTED_VENDOR_ID;
         l_SUGGESTED_VENDOR_NAME := l_header_rec.SUGGESTED_VENDOR_NAME;
       l_source_organization_id := l_line_tbl(i).source_organization_id;
         l_autosource_flag := 'N';
Begin
        Select employee_id into l_planner_employee_id From MTL_PLANNERS
          Where Organization_id = l_header_rec.dest_organization_id
            and Planner_code = ( Select Planner_code from mtl_system_items_b
where inventory_item_id = l_line_tbl(i).inventory_item_id and organization_id =
l_header_rec.dest_organization_id )
            and nvl(DISABLE_DATE,SYSDATE+1) > SYSDATE;
Exception
             When no_data_found then
             l_planner_employee_id := Null;
  When others then
  l_planner_employee_id := Null;
End;
        If l_planner_employee_id is not null then
           l_employee_id := l_planner_employee_id;
        End if;

      Begin
          SELECT ORG_INFORMATION3, ORG_INFORMATION4
            INTO l_VENDOR_ID, l_VENDOR_SITE_ID
            FROM HR_ORGANIZATION_INFORMATION
            WHERE ORGANIZATION_ID = l_source_organization_id
              and org_information_context = 'Customer/Supplier Association';
        Exception
          When no_data_found then
          l_VENDOR_SITE_ID := Null;
          When others then
          l_VENDOR_SITE_ID := Null;
        End;

      Else
         l_justification := to_char(l_header_rec.need_by_date, 'DD-MON-RRRR HH:MI:SS');
         l_note_to_buyer := l_line_tbl(i).shipping_method_code;
         l_note1_id      := null;
         l_note1_title   := null;
         l_SUGGESTED_VENDOR_ID := null;
         l_SUGGESTED_VENDOR_NAME := null;
         l_VENDOR_SITE_ID := null;
       l_source_organization_id := null;
        l_autosource_flag := null;
      End if;


      -- Insert into ReqImport Interface tables
      INSERT INTO PO_REQUISITIONS_INTERFACE_ALL
         (CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          INTERFACE_SOURCE_CODE,
          --INTERFACE_SOURCE_LINE_ID,
          SOURCE_TYPE_CODE,
          REQUISITION_TYPE,
          DESTINATION_TYPE_CODE,
          QUANTITY,
          UOM_CODE,
      UNIT_OF_MEASURE,
          --UNIT_PRICE,
          AUTHORIZATION_STATUS,
          PREPARER_ID,
          ITEM_ID,
          CHARGE_ACCOUNT_ID,
          DESTINATION_ORGANIZATION_ID,
          DESTINATION_SUBINVENTORY,
          DELIVER_TO_LOCATION_ID,
          DELIVER_TO_REQUESTOR_ID,
          NEED_BY_DATE,
          ORG_ID,
          LINE_TYPE_ID,
          REQ_NUMBER_SEGMENT1,
          REQUISITION_HEADER_ID,
          REQUISITION_LINE_ID,
          REFERENCE_NUM,
          JUSTIFICATION,
          NOTE_TO_BUYER,
          --TRANSACTION_REASON_CODE
          NOTE1_ID,
          NOTE1_TITLE,
          SUGGESTED_VENDOR_ID,
          SUGGESTED_VENDOR_NAME,
          SUGGESTED_VENDOR_SITE_ID,
          source_organization_id,
          AUTOSOURCE_FLAG
         )
      VALUES
         (l_today,     --creation_date
          l_user_id,   --created_by
          l_today,     -- last_update_date
          l_user_id,   -- last_update_login
          l_login_id,  --last_update_login
          'CSP',    -- interface_source_code
          'VENDOR',
          'PURCHASE',
          'INVENTORY',
          l_line_tbl(i).ordered_quantity,
          l_line_tbl(i).unit_of_measure,
      l_unit_of_measure,
          'APPROVED',
          l_employee_id,
          l_line_tbl(i).inventory_item_id,
          l_charge_Account_id,
          l_header_Rec.dest_organization_id,
          l_line_tbl(i).dest_subinventory,
          l_header_rec.ship_to_location_id,
          l_employee_id,
          nvl(l_line_tbl(i).need_by_date, l_header_rec.need_by_date),
          l_org_id,
          l_line_Type_id,
          l_header_rec.requisition_number,
          l_header_rec.requisition_header_id,
          l_line_tbl(i).requisition_line_id,
          l_header_rec.requirement_header_id,
          l_justification,
          l_note_to_buyer,
          --'Spares Parts Order'
          l_note1_id,
          l_note1_title,
          l_SUGGESTED_VENDOR_ID,
          l_SUGGESTED_VENDOR_NAME,
          l_VENDOR_SITE_ID,
          l_source_organization_id,
          l_autosource_flag
          );
      END LOOP;

      px_header_rec := l_header_rec;
      px_line_Table := l_line_Tbl;

      IF (p_commit = FND_API.G_TRUE) THEN
        commit;
      END IF;

      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data);

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

    WHEN INVALID_CHARGE_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_CHARGE_ACC_ID');
        raise;

    WHEN OTHERS THEN
      Rollback to process_order_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

PROCEDURE book_order (
    p_oe_header_id        IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data            OUT NOCOPY VARCHAR2
) IS
    l_module_name varchar2(100) := 'csp.plsql.csp_parts_order.book_order';
    l_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;
    l_org_id number;
    l_org_org_id number;

    l_header_rec OE_ORDER_PUB.Header_Rec_Type;
    l_header_val_rec OE_ORDER_PUB.Header_Val_Rec_Type;
    l_Header_Adj_tbl OE_ORDER_PUB.Header_Adj_Tbl_Type;
    l_Header_Adj_val_tbl OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
    l_Header_price_Att_tbl OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl OE_ORDER_PUB.Header_Scredit_Tbl_Type;
    l_Header_Scredit_val_tbl OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
    l_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
    l_line_val_tbl OE_ORDER_PUB.Line_Val_Tbl_Type;
    l_Line_Adj_tbl OE_ORDER_PUB.Line_Adj_Tbl_Type;
    l_Line_Adj_val_tbl OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
    l_Line_price_Att_tbl OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl OE_ORDER_PUB.Line_Scredit_Tbl_Type;
    l_Line_Scredit_val_tbl OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
    l_Lot_Serial_tbl OE_ORDER_PUB.Lot_Serial_Tbl_Type;
    l_Lot_Serial_val_tbl OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
    lx_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;

begin

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Begin...');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_oe_header_id = ' || p_oe_header_id);
    end if;

    select org_id into l_org_id from oe_order_headers_all where header_id = p_oe_header_id;
    l_org_org_id := mo_global.get_current_org_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_id = ' || l_org_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_org_id = ' || l_org_org_id);
    end if;

    if l_org_org_id is null then
        po_moac_utils_pvt.INITIALIZE;
        l_org_org_id := mo_global.get_current_org_id;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_id = ' || l_org_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_org_id = ' || l_org_org_id);
    end if;

    if l_org_id <> nvl(l_org_org_id, -999) and l_org_id is not null then
        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'changing context to l_org_id = ' || l_org_id);
        end if;
        po_moac_utils_pvt.set_org_context(l_org_id);
    end if;

    l_action_request_tbl := OE_ORDER_PUB.G_MISS_REQUEST_TBL;
    l_action_request_tbl(1).request_type := oe_globals.g_book_order;
    l_action_request_tbl(1).entity_code := oe_globals.g_entity_header;
    l_action_request_tbl(1).entity_id := p_oe_header_id;

    OE_ORDER_PUB.process_order(
        p_api_version_number    => 1.0,
        p_org_id                => l_org_id,
        p_init_msg_list          => FND_API.G_TRUE,
        p_return_values          => FND_API.G_FALSE,
        p_action_commit          => FND_API.G_FALSE,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                => x_msg_data,
        p_action_request_tbl    => l_action_request_tbl,
        -- OUT parameters
        x_header_rec            => l_header_rec,
        x_header_val_rec        => l_header_val_rec,
        x_Header_Adj_tbl        => l_Header_Adj_tbl,
        x_Header_Adj_val_tbl    => l_Header_Adj_val_tbl,
        x_Header_price_Att_tbl    => l_Header_price_Att_tbl,
        x_Header_Adj_Att_tbl    => l_Header_Adj_Att_tbl,
        x_Header_Adj_Assoc_tbl    => l_Header_Adj_Assoc_tbl,
        x_Header_Scredit_tbl    => l_Header_Scredit_tbl,
        x_Header_Scredit_val_tbl => l_Header_Scredit_val_tbl,
        x_line_tbl                => l_line_tbl,
        x_line_val_tbl            => l_line_val_tbl,
        x_Line_Adj_tbl            => l_Line_Adj_tbl,
        x_Line_Adj_val_tbl        => l_Line_Adj_val_tbl,
        x_Line_price_Att_tbl    => l_Line_price_Att_tbl,
        x_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl,
        x_Line_Adj_Assoc_tbl    => l_Line_Adj_Assoc_tbl,
        x_Line_Scredit_tbl        => l_Line_Scredit_tbl,
        x_Line_Scredit_val_tbl    => l_Line_Scredit_val_tbl,
        x_Lot_Serial_tbl        => l_Lot_Serial_tbl,
        x_Lot_Serial_val_tbl    => l_Lot_Serial_val_tbl,
        x_action_request_tbl    => lx_action_request_tbl
    );

    if l_org_id <> l_org_org_id then
        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'changing context to l_org_org_id = ' || l_org_org_id);
        end if;
        po_moac_utils_pvt.set_org_context(l_org_org_id);
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'After calling OE_ORDER_PUB.process_order ...');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_return_status = ' || x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_msg_count = ' || x_msg_count);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_msg_data = ' || x_msg_data);
    end if;

    if x_return_status = FND_API.G_RET_STS_SUCCESS then
        commit;
    end if;

end;

PROCEDURE upd_oe_line_ship_method (
    p_oe_line_id        IN NUMBER
        ,p_ship_method      IN  VARCHAR2
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data            OUT NOCOPY VARCHAR2
) IS
    l_module_name varchar2(100) := 'csp.plsql.csp_parts_order.upd_oe_line_ship_method';
    l_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;
    l_org_id number;
    l_org_org_id number;
    l_ship_from_org_id number;
    l_arrival_date date;
	l_to_location_id number;

    l_header_rec OE_ORDER_PUB.Header_Rec_Type;
    l_header_val_rec OE_ORDER_PUB.Header_Val_Rec_Type;
    l_Header_Adj_tbl OE_ORDER_PUB.Header_Adj_Tbl_Type;
    l_Header_Adj_val_tbl OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
    l_Header_price_Att_tbl OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl OE_ORDER_PUB.Header_Scredit_Tbl_Type;
    l_Header_Scredit_val_tbl OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
    l_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
    l_line_val_tbl OE_ORDER_PUB.Line_Val_Tbl_Type;
    l_Line_Adj_tbl OE_ORDER_PUB.Line_Adj_Tbl_Type;
    l_Line_Adj_val_tbl OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
    l_Line_price_Att_tbl OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl OE_ORDER_PUB.Line_Scredit_Tbl_Type;
    l_Line_Scredit_val_tbl OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
    l_Lot_Serial_tbl OE_ORDER_PUB.Lot_Serial_Tbl_Type;
    l_Lot_Serial_val_tbl OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
    lx_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;

    l_line_tbl1 OE_ORDER_PUB.Line_Tbl_Type;

    -- To fix 17153689
   cursor c_get_to_location_id is
    SELECT ch.ship_to_location_id
    FROM csp_requirement_headers ch,
      csp_requirement_lines cl,
      csp_req_line_details cld
    WHERE cld.source_id            = p_oe_line_id
    AND cld.requirement_line_id  = cl.requirement_line_id
    AND cld.source_type = 'IO'
    AND cl.requirement_header_id = ch.requirement_header_id;

    cursor c_get_arrival_date is
    SELECT csp.arrival_date
    FROM CSP_SHIPPING_DETAILS_V csp
    WHERE csp.organization_id    = l_ship_from_org_id
    AND csp.shipping_method      = p_ship_method
    AND CSP.TO_LOCATION_ID = l_to_location_id
    AND csp.location_source      = 'HR';
-- TO fix 17153689

BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Begin...');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_oe_line_id = ' || p_oe_line_id
            || ', p_ship_method = ' || p_ship_method);
    end if;

    select org_id into l_org_id from oe_order_lines_all where line_id = p_oe_line_id;
    l_org_org_id := mo_global.get_current_org_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_id = ' || l_org_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_org_id = ' || l_org_org_id);
    end if;

    if l_org_org_id is null then
        po_moac_utils_pvt.INITIALIZE;
        l_org_org_id := mo_global.get_current_org_id;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_id = ' || l_org_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_org_org_id = ' || l_org_org_id);
    end if;

    if l_org_id <> nvl(l_org_org_id, -999) and l_org_id is not null then
        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'changing context to l_org_id = ' || l_org_id);
        end if;
        po_moac_utils_pvt.set_org_context(l_org_id);
    end if;

    l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_line_tbl(1).line_id := p_oe_line_id;
    l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    l_line_tbl(1).shipping_method_code := p_ship_method;

    -- bug # 12664116
    select ship_from_org_id into l_ship_from_org_id from oe_order_lines_all where line_id = p_oe_line_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_ship_from_org_id = ' || l_ship_from_org_id);
    end if;

	-- TO fix 17153689
    open c_get_to_location_id;
    fetch c_get_to_location_id into l_to_location_id;
    close c_get_to_location_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_to_location_id = ' || l_to_location_id);
    end if;
   -- TO fix 17153689

    open c_get_arrival_date;
    fetch c_get_arrival_date into l_arrival_date;
    close c_get_arrival_date;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_arrival_date = ' || to_char(nvl(l_arrival_date, sysdate), 'DD-MON-YYYY HH24:MI:SS'));
    end if;

    if l_arrival_date is not null then
      l_line_tbl(1).actual_arrival_date := l_arrival_date;
      l_line_tbl(1).promise_date := l_arrival_date;
      --l_line_tbl(1).request_date := l_arrival_date;
    end if;


    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Starting OW Debug...');

        oe_debug_pub.G_FILE := NULL;
        oe_debug_pub.debug_on;
        oe_debug_pub.initialize;
        oe_debug_pub.setdebuglevel(5);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'OE Debug File : '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE'));

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_line_tbl.count = '|| l_line_tbl.count);
    end if;

    OE_ORDER_PUB.process_order(
        p_api_version_number    => 1.0,
        p_org_id                => l_org_id,
        p_init_msg_list          => FND_API.G_TRUE,
        p_return_values          => FND_API.G_FALSE,
        p_action_commit          => FND_API.G_FALSE,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                => x_msg_data,
        p_action_request_tbl    => l_action_request_tbl,
        p_line_tbl              => l_line_tbl,
        p_header_rec            => l_header_rec,
        -- OUT parameters
        x_header_rec            => l_header_rec,
        x_header_val_rec        => l_header_val_rec,
        x_Header_Adj_tbl        => l_Header_Adj_tbl,
        x_Header_Adj_val_tbl    => l_Header_Adj_val_tbl,
        x_Header_price_Att_tbl    => l_Header_price_Att_tbl,
        x_Header_Adj_Att_tbl    => l_Header_Adj_Att_tbl,
        x_Header_Adj_Assoc_tbl    => l_Header_Adj_Assoc_tbl,
        x_Header_Scredit_tbl    => l_Header_Scredit_tbl,
        x_Header_Scredit_val_tbl => l_Header_Scredit_val_tbl,
        x_line_tbl                => l_line_tbl1,
        x_line_val_tbl            => l_line_val_tbl,
        x_Line_Adj_tbl            => l_Line_Adj_tbl,
        x_Line_Adj_val_tbl        => l_Line_Adj_val_tbl,
        x_Line_price_Att_tbl    => l_Line_price_Att_tbl,
        x_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl,
        x_Line_Adj_Assoc_tbl    => l_Line_Adj_Assoc_tbl,
        x_Line_Scredit_tbl        => l_Line_Scredit_tbl,
        x_Line_Scredit_val_tbl    => l_Line_Scredit_val_tbl,
        x_Lot_Serial_tbl        => l_Lot_Serial_tbl,
        x_Lot_Serial_val_tbl    => l_Lot_Serial_val_tbl,
        x_action_request_tbl    => lx_action_request_tbl
    );

    if l_org_id <> l_org_org_id then
        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'changing context to l_org_org_id = ' || l_org_org_id);
        end if;
        po_moac_utils_pvt.set_org_context(l_org_org_id);
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'After calling OE_ORDER_PUB.process_order ...');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_return_status = ' || x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_msg_count = ' || x_msg_count);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'x_msg_data = ' || x_msg_data);

        -- Stopping OE Debug...
        oe_debug_pub.debug_off;
    end if;

    if x_return_status = FND_API.G_RET_STS_SUCCESS then
        commit;
    end if;

END;

PROCEDURE upd_oe_ship_to_add (
    p_req_header_id        IN NUMBER
    ,p_new_hr_loc_id    IN  NUMBER
    ,p_new_add_type     IN  VARCHAR2
    ,p_update_req_header IN VARCHAR2
    ,p_commit           IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data            OUT NOCOPY VARCHAR2
) IS
    l_module_name varchar2(100) := 'csp.plsql.csp_parts_order.upd_oe_ship_to_add';
    l_org_id number;
    l_org_org_id number;
    l_booked_orders number;
    l_header_rec    csp_parts_requirement.header_rec_type;
    l_header_can_rec    csp_parts_requirement.header_rec_type;
    l_lines_tbl     csp_parts_requirement.Line_Tbl_type;
    l_oe_header_rec oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_oe_line_tbl   OE_Order_PUB.line_tbl_type;
    l_dest_org_id number;
    l_dest_subinv varchar2(40);
    l_need_by_date date;
    l_req_line_id number;
    l_req_line_dtl_rec  CSP_REQ_LINE_DETAILS_PVT.Req_Line_Details_Tbl_Type;
    l_req_line_dtl_id number;
    l_req_hdr_pvt_rec CSP_Requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type;
    l_cancel_reason varchar2(200);

    cursor check_io_status is
    SELECT count(1)
    FROM csp_requirement_lines cl,
      csp_req_line_details cld,
      oe_order_lines_all oel
    WHERE cl.requirement_header_id = p_req_header_id
    AND cl.requirement_line_id     = cld.requirement_line_id
    AND cld.source_type            = 'IO'
    AND cld.source_id              = oel.line_id
    AND oel.booked_flag            = 'Y';

    cursor get_booked_order_num is
    SELECT oeh.order_number
    FROM csp_requirement_lines cl,
      csp_req_line_details cld,
      oe_order_lines_all oel,
      oe_order_headers_all oeh
    WHERE cl.requirement_header_id = p_req_header_id
    AND cl.requirement_line_id     = cld.requirement_line_id
    AND cld.source_type            = 'IO'
    AND cld.source_id              = oel.line_id
    AND oel.booked_flag            = 'Y'
    AND oel.header_id              = oeh.header_id
    AND rownum                     = 1;

    cursor get_order_header_ids is
    SELECT distinct oel.header_id
    FROM csp_requirement_lines cl,
      csp_req_line_details cld,
      oe_order_lines_all oel
    WHERE cl.requirement_header_id = p_req_header_id
    AND cl.requirement_line_id     = cld.requirement_line_id
    AND cld.source_type            = 'IO'
    AND cld.source_id              = oel.line_id
    AND oel.booked_flag            = 'N'
    AND oel.cancelled_flag         = 'N'
    AND oel.open_flag              = 'Y';

    cursor get_req_header_data is
    SELECT destination_organization_id,
      destination_subinventory,
      need_by_date
    FROM csp_requirement_headers
    WHERE requirement_header_id = p_req_header_id;

    cursor get_req_line_id (v_oe_line_id number) is
    SELECT requirement_line_id,
      req_line_detail_id
    FROM csp_req_line_details
    WHERE source_type= 'IO'
    AND source_id    = v_oe_line_id;

BEGIN
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Begin...');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_req_header_id = ' || p_req_header_id
            || ', p_new_hr_loc_id = ' || p_new_hr_loc_id
            || ', p_update_req_header = ' || p_update_req_header
            || ', p_new_add_type = ' || p_new_add_type);
    end if;

    l_booked_orders := 0;
    open check_io_status;
    fetch check_io_status into l_booked_orders;
    close check_io_status;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_booked_orders = ' || l_booked_orders);
    end if;

    if l_booked_orders > 0 then
        open get_booked_order_num;
        fetch get_booked_order_num into l_booked_orders;
        close get_booked_order_num;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Raising error as l_booked_orders > 0 ');
        end if;

        FND_MESSAGE.SET_NAME('CSP', 'CSP_NO-SHIP_CNG_BOOK_IO');
        FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_booked_orders, FALSE);
        FND_MSG_PUB.ADD;
        fnd_msg_pub.count_and_get
            ( p_count => x_msg_count
            , p_data  => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;

    else    -- we will do stuff here

        -- logic in brief
        -- first cancel all the orders
        -- create orders again with new ship_to_address
        -- while creating orders make sure you create order per operating unit

        savepoint csp_upd_oe_ship_to_add;

        open get_req_header_data;
        fetch get_req_header_data into l_dest_org_id, l_dest_subinv, l_need_by_date;
        close get_req_header_data;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Fetched data from req header... ');
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'l_dest_org_id = ' || l_dest_org_id
                || ', l_dest_subinv = ' || l_dest_subinv
                || ', l_need_by_date = ' || l_need_by_date);
        end if;

        -- lets get orders which we need to cancel

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'fetching orders to be cancelled...');
        end if;

        for cr in get_order_header_ids loop
            l_header_can_rec.order_header_id := cr.header_id;

            -- bug # 12559884
            -- put Cancel reason code for cancelling a line
            -- value will be picked from the profile CSP_CANCEL_REASON
            fnd_profile.get('CSP_CANCEL_REASON', l_cancel_reason);
            l_header_can_rec.change_reason := l_cancel_reason;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'processing l_header_can_rec.order_header_id = ' || l_header_can_rec.order_header_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'l_header_can_rec.change_reason = ' || l_header_can_rec.change_reason);
            end if;

            oe_header_util.Query_Row(
                p_header_id     => cr.header_id,
                x_header_rec    => l_oe_header_rec);

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'fetched l_oe_header_rec...');
            end if;

            l_header_rec.dest_organization_id := l_dest_org_id;
            l_header_rec.dest_subinventory := l_dest_subinv;
            l_header_rec.need_by_date := l_need_by_date;
            l_header_rec.ship_to_location_id := p_new_hr_loc_id; -- important
            l_header_rec.address_type := p_new_add_type; -- important
            l_header_rec.requirement_header_id := p_req_header_id;
            l_header_rec.operation := 'CREATE';
            l_header_rec.shipping_method_code := l_oe_header_rec.shipping_method_code;
            l_header_rec.order_type_id := l_oe_header_rec.order_type_id;

            oe_line_util.Query_Rows(
                p_header_id     => cr.header_id,
                x_line_tbl      => l_oe_line_tbl);

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'fetched l_oe_line_tbl...');
            end if;

            l_req_line_dtl_rec := CSP_REQ_LINE_DETAILS_PVT.G_MISS_Req_Line_Details_TBL;
            for i in 1..l_oe_line_tbl.count loop

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'processing line # ' || i
                        || ' for item_id = ' || l_oe_line_tbl(i).inventory_item_id);
                end if;

                l_lines_tbl(i).booked_flag := 'Y';
                l_lines_tbl(i).dest_subinventory := l_dest_subinv;
                l_lines_tbl(i).inventory_item_id := l_oe_line_tbl(i).inventory_item_id;
                l_lines_tbl(i).need_by_date := l_need_by_date;
                l_lines_tbl(i).ordered_quantity := l_oe_line_tbl(i).ordered_quantity;
                l_lines_tbl(i).revision := l_oe_line_tbl(i).item_revision;
                l_lines_tbl(i).shipping_method_code := l_oe_line_tbl(i).shipping_method_code;
                l_lines_tbl(i).source_organization_id := l_oe_line_tbl(i).ship_from_org_id;
                l_lines_tbl(i).source_subinventory := l_oe_line_tbl(i).subinventory;
                l_lines_tbl(i).unit_of_measure := l_oe_line_tbl(i).order_quantity_uom;
                --l_lines_tbl(i).arrival_date := l_oe_line_tbl(i).request_date;
                l_lines_tbl(i).line_num := i;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'l_oe_line_tbl(i).line_id = ' || l_oe_line_tbl(i).line_id);
                end if;

                open get_req_line_id(l_oe_line_tbl(i).line_id);
                fetch get_req_line_id into l_req_line_id, l_req_line_dtl_id;
                close get_req_line_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'l_req_line_id = ' || l_req_line_id);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'l_req_line_dtl_id = ' || l_req_line_dtl_id);
                end if;

                l_lines_tbl(i).requirement_line_id := l_req_line_id;

                l_req_line_dtl_rec(i).REQ_LINE_DETAIL_ID := l_req_line_dtl_id;
                l_req_line_dtl_rec(i).REQUIREMENT_LINE_ID := l_req_line_id;
                l_req_line_dtl_rec(i).SOURCE_TYPE := 'IO';
            end loop;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Before trying to cancel the order...');
            end if;

            Cancel_Order(
                p_header_rec    => l_header_can_rec,
                p_line_table    => l_lines_tbl,
                p_process_Type  => 'ORDER',
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data
                );

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'after cancel the order... x_return_status = ' || x_return_status);
            end if;

            if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                rollback to csp_upd_oe_ship_to_add;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'x_return_status = ' || x_return_status);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'x_msg_count = ' || x_msg_count);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'x_msg_data = ' || x_msg_data);
                end if;

            else
                -- try to create the order :)
                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'before calling process_order...');
                end if;

                process_order(
                    p_api_version       => 1.0
                    ,p_Init_Msg_List    => FND_API.G_TRUE
                    ,p_commit           => FND_API.G_FALSE
                    ,px_header_rec      => l_header_rec
                    ,px_line_table      => l_lines_tbl
                    ,p_process_type     => 'BOTH'
                    ,p_book_order       => 'N'
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
                    );

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'after calling process_order... x_return_status = ' || x_return_status);
                end if;

                if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                    rollback to csp_upd_oe_ship_to_add;

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_return_status = ' || x_return_status);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_msg_count = ' || x_msg_count);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_msg_data = ' || x_msg_data);
                    end if;

                else
                    -- update the csp_req_line_details
                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'populating l_req_line_dtl_rec...');
                    end if;

                    for i in 1..l_lines_tbl.count loop
                        for j in 1..l_req_line_dtl_rec.count loop
                            if l_req_line_dtl_rec(j).REQUIREMENT_LINE_ID = l_lines_tbl(i).requirement_line_id then
                                l_req_line_dtl_rec(j).SOURCE_ID := l_lines_tbl(i).order_line_id;

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                        'new SOURCE_ID for REQUIREMENT_LINE_ID is = '
                                        || l_req_line_dtl_rec(j).REQUIREMENT_LINE_ID
                                        || ' -> ' || l_req_line_dtl_rec(j).SOURCE_ID);
                                end if;

                            end if;
                        end loop;
                    end loop;

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'before calling update req line details...');
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'l_req_line_dtl_rec.count = ' || l_req_line_dtl_rec.count);
                    end if;

                    CSP_REQ_LINE_DETAILS_PVT.Update_req_line_details(
                        P_Api_Version_Number        => 1.0,
                        P_Req_Line_Details_Tbl      => l_req_line_dtl_rec,
                        X_Return_Status             => x_return_status,
                        X_Msg_Count                 => x_msg_count,
                        X_Msg_Data                  => x_msg_data
                    );

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'after CSP_REQ_LINE_DETAILS_PVT.Update_req_line_details... x_return_status = ' || x_return_status);
                    end if;

                    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                        rollback to csp_upd_oe_ship_to_add;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'x_return_status = ' || x_return_status);
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'x_msg_count = ' || x_msg_count);
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'x_msg_data = ' || x_msg_data);
                        end if;
                    end if;

                end if;
            end if;

        end loop;

        if x_return_status = FND_API.G_RET_STS_SUCCESS then

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'p_update_req_header = ' || p_update_req_header);
            end if;

            if nvl(p_update_req_header, 'N') = 'Y' then
                -- update req header with new ship_to_location_id
                l_req_hdr_pvt_rec.REQUIREMENT_HEADER_ID := p_req_header_id;
                l_req_hdr_pvt_rec.SHIP_TO_LOCATION_ID := p_new_hr_loc_id;
                l_req_hdr_pvt_rec.ADDRESS_TYPE := p_new_add_type;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'before calling CSP_Requirement_headers_PVT.Update_requirement_headers...');
                end if;

                CSP_Requirement_headers_PVT.Update_requirement_headers(
                    P_Api_Version_Number        => 1.0,
                    P_REQUIREMENT_HEADER_Rec    => l_req_hdr_pvt_rec,
                    X_Return_Status             => x_return_status,
                    X_Msg_Count                 => x_msg_count,
                    X_Msg_Data                  => x_msg_data
                );

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'after calling CSP_Requirement_headers_PVT.Update_requirement_headers... x_return_status = ' || x_return_status);
                end if;

                if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                    rollback to csp_upd_oe_ship_to_add;

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_return_status = ' || x_return_status);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_msg_count = ' || x_msg_count);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'x_msg_data = ' || x_msg_data);
                    end if;
                else
                    if p_commit = FND_API.G_TRUE then
                        commit;
                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'transaction commited...');
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'returning...');
    end if;
END;

END;

/
