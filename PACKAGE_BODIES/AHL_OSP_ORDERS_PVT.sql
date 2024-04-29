--------------------------------------------------------
--  DDL for Package Body AHL_OSP_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_ORDERS_PVT" AS
/* $Header: AHLVOSPB.pls 120.24 2008/03/14 14:41:52 mpothuku ship $ */

  --G_DEBUG varchar2(1) := FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG       VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'AHL_OSP_ORDERS_PVT';
  G_APP_NAME    CONSTANT VARCHAR2(3) := 'AHL';
  G_LOG_PREFIX  CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME||'.';
  G_OAF_MODULE  CONSTANT VARCHAR2(3) := 'OAF';

  g_module_type VARCHAR2(30)  := NULL;
  --Mainly used for whether to default unchanged attributes.For OAF, we don't.
  g_old_status_code VARCHAR2(30) := NULL;
  /*
  -- Commented out by jaramana on January 7, 2008 for the Requisition ER 6034236
  g_order_status_for_update VARCHAR2(30) := NULL;
  --For OSP status change
  g_order_conversion_flag VARCHAR2(1) := 'N';
  -- jaramana End
  */

  --Indicates whether update order involves converting between 'SERVICE' and 'EXCHANGE'
  g_old_type_code VARCHAR2(30) := NULL;
  g_new_type_code VARCHAR2(30) := NULL;
  --For OSP order type conversion

--***** The following lines were added by Jerry for Inventory Service Orders *****--
  g_dummy_char VARCHAR2(1);
  g_dummy_num  NUMBER;

  TYPE item_service_rel_rec_type IS RECORD (
    inv_org_id  NUMBER,
    inv_item_id NUMBER,
    service_item_id NUMBER);
  TYPE item_service_rels_tbl_type IS TABLE OF item_service_rel_rec_type INDEX BY BINARY_INTEGER;

  TYPE Vendor_Id_Rec_Type IS RECORD (
    vendor_id      NUMBER,
    vendor_site_id NUMBER
  );
  TYPE Vendor_id_tbl_type IS TABLE OF Vendor_Id_Rec_Type INDEX BY BINARY_INTEGER;

--Given a series of physical item, service item combinations to get the common
--vendor attributes.
PROCEDURE derive_default_vendor(
  p_item_service_rels_tbl IN item_service_rels_tbl_type,
  x_vendor_id             OUT NOCOPY NUMBER,
  x_vendor_site_id        OUT NOCOPY NUMBER,
  x_vendor_contact_id     OUT NOCOPY NUMBER,
  x_valid_vendors_tbl     OUT NOCOPY vendor_id_tbl_type);

--This procedure tries to derive the common vendors for an OSP Order based on its Lines.
--If the x_any_vendor_flag is 'Y', it means that any vendor can be used for this Order.
--Else, only the vendors whose ids are returned in the table x_valid_vendors_tbl
--are valid. It uses the derive_default_vendor method.
PROCEDURE Derive_Common_Vendors(p_osp_order_id      IN  NUMBER,
                                x_valid_vendors_tbl OUT NOCOPY Vendor_id_tbl_type,
                                x_any_vendor_flag   OUT NOCOPY VARCHAR2);

--Newly created for validating vendor_id, vendor_site_id and
--vendor_contact_id together
PROCEDURE validate_vendor_site_contact(p_vendor_id IN NUMBER,
                                       p_vendor_site_id IN NUMBER,
                                       p_vendor_contact_id IN NUMBER);

--yazhou 07-Aug-2006 starts
-- bug fix#5448191

--Create shipment header/lines for osp line
PROCEDURE create_shipment(
  p_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type);

--yazhou 07-Aug-2006 ends

--Contains OSP order header record default, validation and creation
PROCEDURE create_osp_order_header(
  p_x_osp_order_rec       IN OUT NOCOPY osp_order_rec_type,
  p_x_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type);

--Contains OSP order header record default, validation and update, including
--Status change and type conversion
PROCEDURE update_osp_order_header(
  p_x_osp_order_rec IN OUT NOCOPY osp_order_rec_type);

--Contains OSP order line record default and creation
PROCEDURE create_osp_order_line(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--validate osp line for creation
PROCEDURE validate_order_line_creation(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--update osp order line record
PROCEDURE update_osp_order_line(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--validate osp line for update
PROCEDURE validate_order_line_update(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--do the G_MISS to NULL and NULL to old value conversion for order
--line record
PROCEDURE default_unchanged_order_line(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--Convert values to Ids for OSP order line record
PROCEDURE convert_order_line_val_to_id(
  p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type);

--Validate the physical/service item combination with the vendor
PROCEDURE validate_vendor_service_item(
  p_osp_order_line_rec IN osp_order_line_rec_type);

--Validate service_item_id (simplified the original one)
PROCEDURE validate_service_item_id(
  p_service_item_id IN NUMBER,
  p_organization_id IN NUMBER);

--Handle the order type change (new procedure but copied the old logic)
PROCEDURE process_order_type_change(
  p_osp_order_rec IN osp_order_rec_type);

-----------------------------------------------
-- Declare Local TYPE, FUNCTION and PROCEDURE--
-----------------------------------------------
TYPE del_cancel_so_line_rec IS RECORD(
   osp_order_id NUMBER,
   oe_ship_line_id NUMBER,
   oe_return_line_id NUMBER
   );
TYPE del_cancel_so_lines_tbl_type IS TABLE OF del_cancel_so_line_rec INDEX BY BINARY_INTEGER;
PROCEDURE delete_cancel_so(
   p_oe_header_id             IN        NUMBER,
   p_del_cancel_so_lines_tbl  IN        del_cancel_so_lines_tbl_type,
   p_cancel_flag              IN        VARCHAR2  := FND_API.G_FALSE
   );
PROCEDURE process_order_status_change(
   p_x_osp_order_rec IN OUT NOCOPY   osp_order_rec_type
   );
FUNCTION can_convert_order(
    p_osp_order_id  IN  NUMBER,
    p_old_type_code IN  VARCHAR2,
    p_new_type_code IN  VARCHAR2
    --p_new_order_rec  IN AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    --p_old_order_rec  IN AHL_OSP_ORDERS_PVT.osp_order_rec_type
  ) RETURN BOOLEAN;
FUNCTION vendor_id_exist_in_PO(
     p_po_header_id   IN NUMBER,
     p_vendor_id      IN NUMBER
  ) RETURN BOOLEAN;
FUNCTION vendor_site_id_exist_in_PO(
    p_po_header_id      IN NUMBER,
    p_vendor_site_id    IN NUMBER
 ) RETURN BOOLEAN;

PROCEDURE validate_order_header(
    p_x_osp_order_rec  IN OUT NOCOPY   osp_order_rec_type
    );
PROCEDURE validate_vendor(
    p_vendor_id  IN NUMBER
    );
PROCEDURE validate_vendor_site(
    p_vendor_id  IN NUMBER,
    p_vendor_site_id  IN NUMBER
    );
PROCEDURE validate_customer(
    p_customer_id IN NUMBER
    );
PROCEDURE validate_buyer(
    p_po_agent_id IN NUMBER
    );
PROCEDURE validate_contract(
    p_order_type_code IN VARCHAR2,
    p_contract_id IN VARCHAR2,
    p_party_vendor_id IN VARCHAR2,
    p_authoring_org_id IN VARCHAR2
    );
PROCEDURE validate_po_header(
    p_osp_order_id IN NUMBER,
    p_po_header_id IN NUMBER
    );
PROCEDURE default_unchanged_order_header(
	p_x_osp_order_rec  IN OUT NOCOPY osp_order_rec_type
    );
PROCEDURE validate_workorder(
    p_workorder_id IN NUMBER
    );

--Commented by mpothuku on 27-Feb-06 as the following procs. are not being used anymore and the Perf Bug #4919164 --has been logged for some of the cursors in the procedures below
/*
PROCEDURE validate_service_item(
    p_workorder_id IN NUMBER,
    p_service_item_id IN NUMBER,
    p_order_type_code IN VARCHAR2
    );
PROCEDURE validate_service_item_desc(
    p_service_item_id IN NUMBER,
    p_service_item_description IN VARCHAR2
    );
*/

-- Added by jaramana on January 7, 2008 for the Requisition ER 6034236
PROCEDURE val_svc_item_vs_wo_svc_item(
    p_workorder_id IN NUMBER,
    p_service_item_id IN NUMBER
    );
-- jaramana End

--p_org_id added by mpothuku to fix the Perf Bug #4919164
PROCEDURE validate_service_item_uom(
   p_service_item_id IN NUMBER,
   p_service_item_uom_code IN VARCHAR2,
   p_org_id IN NUMBER
   );
PROCEDURE validate_po_line_type(
   p_po_line_type_id IN NUMBER
   );
PROCEDURE validate_po_line(
   p_po_line_id IN NUMBER,
   p_osp_order_id IN NUMBER
   );
PROCEDURE validate_exchange_instance_id(
   p_exchange_instance_id IN NUMBER
   );
-- Commented out by jaramana on January 7, 2008 for the Requisition ER 6034236 (We are not using this procedure anymore)
/*
PROCEDURE nullify_exchange_instance(
  p_osp_order_id          IN NUMBER,
  p_x_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type
);
*/
-- jaramana End

------------------------------
-- Declare Local Procedures --
------------------------------
/*
PROCEDURE process_order_header(
    p_validation_level IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_osp_order_rec  IN OUT NOCOPY  osp_order_rec_type
    );
PROCEDURE process_order_lines(
    p_validation_level      IN       NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_osp_order_rec         IN       osp_order_rec_type,
    p_x_osp_order_lines_tbl IN OUT NOCOPY  osp_order_lines_tbl_type
    );
PROCEDURE convert_order_lines_val_to_id(
    p_x_osp_order_lines_tbl IN OUT NOCOPY  osp_order_lines_tbl_type
    );
PROCEDURE convert_order_header_val_to_id(
    p_x_osp_order_rec  IN OUT NOCOPY  osp_order_rec_type
    );
PROCEDURE validate_order_lines(
    p_osp_order_rec         IN       osp_order_rec_type,
    p_x_osp_order_lines_tbl IN OUT NOCOPY    osp_order_lines_tbl_type,
    x_del_cancel_so_lines_tbl OUT NOCOPY del_cancel_so_lines_tbl_type
    );
PROCEDURE default_unchanged_order_lines(
	p_x_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type
    );
PROCEDURE validate_osp_updates(
   p_osp_order_rec         IN       osp_order_rec_type
   );
*/

-- *****Procedure definitions start here *****--
-- When DML operation is not INSERT and osp_order_id is not available, populates osp_order_id from othe unique keys.
-- other unique keys are -- osp_order_number, po_header_id, oe_header_id
--------------------------------------------------------------------------------------------------------------
--(?)Jerry on 04/17/2005, may need to add vendor_contact value to id conversion in this procedure
PROCEDURE convert_order_header_val_to_id(
    p_x_osp_order_rec  IN OUT NOCOPY  osp_order_rec_type
    ) IS
    CURSOR vendor_id_csr(p_vendor_name IN VARCHAR2) IS
    SELECT vendor_id FROM po_vendors_view
    WHERE vendor_name = p_vendor_name
      AND enabled_flag = G_YES_FLAG
      AND NVL(vendor_start_date_active, SYSDATE - 1) <= SYSDATE
      AND NVL(vendor_end_date_active, SYSDATE + 1) > SYSDATE;
    l_vendor_id NUMBER;
    CURSOR vendor_site_id_csr(p_vendor_site_code IN VARCHAR2) IS
    SELECT vendor_site_id FROM po_vendor_sites
    WHERE vendor_site_code = p_vendor_site_code
      AND   NVL(inactive_date, SYSDATE + 1) > SYSDATE
      AND   purchasing_site_flag = G_YES_FLAG;
    l_vendor_site_id NUMBER;

    CURSOR po_agent_id_csr(p_buyer_name IN VARCHAR2) IS
    SELECT buyer_id FROM po_agents_name_v
    WHERE full_name = p_buyer_name;
    l_po_agent_id NUMBER;
    CURSOR customer_id_csr(p_customer_name IN VARCHAR2) IS
    SELECT party_id from hz_parties
    where party_name = p_customer_name and party_type = 'ORGANIZATION';
    l_customer_id NUMBER;
    CURSOR contract_id_csr(p_contract_number IN VARCHAR2) IS
    SELECT chr.id  FROM okc_k_headers_b chr, okc_statuses_b sts
    WHERE chr.contract_number = p_contract_number
    AND chr.sts_code = sts.code AND sts.ste_code in ('ACTIVE', 'SIGNED');
    l_contract_id NUMBER;
    CURSOR osp_order_on_csr(p_osp_order_number IN NUMBER) IS
    SELECT osp_order_id, object_version_number from ahl_osp_orders_b
    WHERE osp_order_number = p_osp_order_number;
    -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
    /*
    CURSOR osp_order_po_csr(p_po_header_id IN NUMBER) IS
    SELECT osp_order_id, object_version_number from ahl_osp_orders_b
    WHERE po_header_id = p_po_header_id;
    CURSOR osp_order_oe_csr(p_oe_header_id IN NUMBER) IS
    SELECT osp_order_id, object_version_number from ahl_osp_orders_b
    WHERE oe_header_id = p_oe_header_id;
    */
    -- jaramana End
    l_osp_order_id NUMBER;
    l_object_version_number NUMBER;
    l_count NUMBER;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.convert_order_header_val_to_id';
BEGIN
    --dbms_output.put_line('Entering : convert_order_header_val_to_id');
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF (p_x_osp_order_rec.operation_flag IS NOT NULL AND p_x_osp_order_rec.operation_flag NOT IN(G_OP_CREATE, G_OP_UPDATE, G_OP_DELETE)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVOP');
        FND_MSG_PUB.ADD;
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF(g_module_type = 'JSP')THEN
        -- conversion of value to id for Vendor name
        IF(p_x_osp_order_rec.vendor_name IS NULL) THEN
           p_x_osp_order_rec.vendor_id := NULL;
        ELSIF (p_x_osp_order_rec.vendor_name = FND_API.G_MISS_CHAR) THEN
           IF(p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
              p_x_osp_order_rec.vendor_id := FND_API.G_MISS_NUM;
           ELSE
              p_x_osp_order_rec.vendor_id := NULL;
           END IF;
        END IF;
        IF(p_x_osp_order_rec.vendor_site_code IS NULL) THEN
           p_x_osp_order_rec.vendor_site_id := NULL;
        ELSIF (p_x_osp_order_rec.vendor_site_code = FND_API.G_MISS_CHAR) THEN
           IF(p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
              p_x_osp_order_rec.vendor_site_id := FND_API.G_MISS_NUM;
           ELSE
              p_x_osp_order_rec.vendor_site_id := NULL;
           END IF;
        END IF;
        IF(p_x_osp_order_rec.buyer_name IS NULL) THEN
           p_x_osp_order_rec.po_agent_id := NULL;
        ELSIF (p_x_osp_order_rec.buyer_name = FND_API.G_MISS_CHAR) THEN
           IF(p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
              p_x_osp_order_rec.po_agent_id := FND_API.G_MISS_NUM;
           ELSE
              p_x_osp_order_rec.po_agent_id := NULL;
           END IF;
        END IF;
        IF(p_x_osp_order_rec.customer_name IS NULL) THEN
           p_x_osp_order_rec.customer_id := NULL;
        ELSIF (p_x_osp_order_rec.customer_name = FND_API.G_MISS_CHAR) THEN
           IF(p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
              p_x_osp_order_rec.customer_id := FND_API.G_MISS_NUM;
           ELSE
              p_x_osp_order_rec.customer_id := NULL;
           END IF;
        END IF;
        IF(p_x_osp_order_rec.contract_number IS NULL) THEN
           p_x_osp_order_rec.contract_id := NULL;
        ELSIF (p_x_osp_order_rec.contract_number = FND_API.G_MISS_CHAR) THEN
           IF(p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
              p_x_osp_order_rec.contract_id := FND_API.G_MISS_NUM;
           ELSE
              p_x_osp_order_rec.contract_id := NULL;
           END IF;
        END IF;
        --dbms_output.put_line('Done nulling out order header ids');
    END IF;
   -- conversion of value to id for Vendor name
   IF (p_x_osp_order_rec.vendor_name IS NOT NULL AND  p_x_osp_order_rec.vendor_name <> FND_API.G_MISS_CHAR) THEN
        l_count := 0;
        --dbms_output.put_line('converting vendor_name to id');
        OPEN vendor_id_csr(p_x_osp_order_rec.vendor_name);
        LOOP
           FETCH vendor_id_csr INTO l_vendor_id;
           IF(vendor_id_csr%NOTFOUND) THEN
             EXIT;
           ELSIF (p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id = l_vendor_id) THEN
             l_count := 1;
             EXIT;
           ELSE
             l_count := l_count + 1;
           END IF;
        END LOOP;
        CLOSE vendor_id_csr;
        IF(l_count = 0 ) THEN
           --dbms_output.put_line('checkpoint 1');
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_NAME_INV');
           FND_MESSAGE.Set_Token('VENDOR_NAME', p_x_osp_order_rec.vendor_name);
           FND_MSG_PUB.ADD;
        ELSIF (l_count > 1) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_INV_NON_UNQ');
           FND_MESSAGE.Set_Token('VENDOR_NAME', p_x_osp_order_rec.vendor_name);
           FND_MSG_PUB.ADD;
        ELSE
           p_x_osp_order_rec.vendor_id := l_vendor_id;
        END IF;
        --dbms_output.put_line('done converting vendor_name to id');
    END IF;
    -- conversion of value to id for vendor site code
    IF (p_x_osp_order_rec.vendor_site_code IS NOT NULL AND  p_x_osp_order_rec.vendor_site_code <> FND_API.G_MISS_CHAR) THEN
        l_count := 0;
        OPEN vendor_site_id_csr(p_x_osp_order_rec.vendor_site_code);
        LOOP
           FETCH vendor_site_id_csr INTO l_vendor_site_id;
           IF(vendor_site_id_csr%NOTFOUND) THEN
             EXIT;
           ELSIF (p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id = l_vendor_site_id) THEN
             l_count := 1;
             EXIT;
           ELSE
             l_count := l_count + 1;
           END IF;
        END LOOP;
        CLOSE vendor_site_id_csr;
        IF(l_count = 0 ) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_INV');
           FND_MESSAGE.Set_Token('VENDOR_SITE', p_x_osp_order_rec.vendor_site_code);
           FND_MSG_PUB.ADD;
        ELSIF (l_count > 1) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_INV_NON_UNQ');
           FND_MESSAGE.Set_Token('VENDOR_SITE', p_x_osp_order_rec.vendor_site_code);
           FND_MSG_PUB.ADD;
        ELSE
           p_x_osp_order_rec.vendor_site_id := l_vendor_site_id;
        END IF;
     END IF;
     -- conversion of value to id for buyer name
     IF (p_x_osp_order_rec.buyer_name IS NOT NULL AND  p_x_osp_order_rec.buyer_name <> FND_API.G_MISS_CHAR) THEN
        l_count := 0;
        OPEN po_agent_id_csr(p_x_osp_order_rec.buyer_name);
        LOOP
           FETCH po_agent_id_csr INTO l_po_agent_id;
           IF(po_agent_id_csr%NOTFOUND) THEN
             EXIT;
           ELSIF (p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id = l_po_agent_id) THEN
             l_count := 1;
             EXIT;
           ELSE
             l_count := l_count + 1;
           END IF;
        END LOOP;
        CLOSE po_agent_id_csr;
        IF(l_count = 0 ) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_INV');
           FND_MESSAGE.Set_Token('BUYER_NAME', p_x_osp_order_rec.buyer_name);
           FND_MSG_PUB.ADD;
        ELSIF (l_count > 1) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_INV_NON_UNQ');
           FND_MESSAGE.Set_Token('BUYER_NAME', p_x_osp_order_rec.buyer_name);
           FND_MSG_PUB.ADD;
        ELSE
           p_x_osp_order_rec.po_agent_id := l_po_agent_id;
        END IF;
     END IF;
     -- conversion of value to id for customer name
     IF (p_x_osp_order_rec.customer_name IS NOT NULL AND  p_x_osp_order_rec.customer_name <> FND_API.G_MISS_CHAR) THEN
        --dbms_output.put_line('converting customer_name to id');
        l_count := 0;
        OPEN customer_id_csr(p_x_osp_order_rec.customer_name);
        LOOP
           FETCH customer_id_csr INTO l_customer_id;
           IF(customer_id_csr%NOTFOUND) THEN
             EXIT;
           ELSIF (p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id = l_customer_id) THEN
             l_count := 1;
             EXIT;
           ELSE
             l_count := l_count + 1;
           END IF;
        END LOOP;
        CLOSE customer_id_csr;
        IF(l_count = 0 ) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUST_INV');
           FND_MESSAGE.Set_Token('CUST_NAME', p_x_osp_order_rec.customer_name);
           FND_MSG_PUB.ADD;
        ELSIF (l_count > 1) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUST_INV_NON_UNQ');
           FND_MESSAGE.Set_Token('CUST_NAME', p_x_osp_order_rec.customer_name);
           FND_MSG_PUB.ADD;
        ELSE
           p_x_osp_order_rec.customer_id := l_customer_id;
        END IF;
     END IF;
     -- conversion of value to id for contract number
     IF (p_x_osp_order_rec.contract_number IS NOT NULL AND  p_x_osp_order_rec.contract_number <> FND_API.G_MISS_CHAR) THEN
         --dbms_output.put_line('converting contract_number to id');
         OPEN contract_id_csr(p_x_osp_order_rec.contract_number);
         FETCH contract_id_csr INTO l_contract_id;
         IF(contract_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CONTRACT_INV');
            FND_MESSAGE.Set_Token('CONTRACT_NUM', p_x_osp_order_rec.contract_number);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_rec.contract_id := l_contract_id;
         END IF;
         CLOSE contract_id_csr;
     END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- finding unique key osp_order_id when operation flag is not 'C'
    IF (p_x_osp_order_rec.osp_order_id IS NULL) THEN
        --dbms_output.put_line('finding osp_order_id');
        IF p_x_osp_order_rec.operation_flag <> G_OP_CREATE THEN
            IF (p_x_osp_order_rec.osp_order_number IS NOT NULL) THEN
                OPEN osp_order_on_csr(p_x_osp_order_rec.osp_order_number);
                FETCH osp_order_on_csr INTO l_osp_order_id,l_object_version_number;
                IF(osp_order_on_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_NUM_INV');
                    FND_MESSAGE.Set_Token('ORDER_NUMBER', p_x_osp_order_rec.osp_order_number);
                    FND_MSG_PUB.ADD;
                ELSE
                    p_x_osp_order_rec.osp_order_id := l_osp_order_id;
                    p_x_osp_order_rec.object_version_number := l_object_version_number;
                END IF;
                CLOSE osp_order_on_csr;
            -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
            /*
            ELSIF (p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                OPEN osp_order_po_csr(p_x_osp_order_rec.po_header_id);
                FETCH osp_order_po_csr INTO l_osp_order_id,l_object_version_number;
                IF(osp_order_po_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PO_HEADER_INV');
                    FND_MESSAGE.Set_Token('PO_HEADER_ID', p_x_osp_order_rec.po_header_id);
                    FND_MSG_PUB.ADD;
                ELSE
                    p_x_osp_order_rec.osp_order_id := l_osp_order_id;
                    p_x_osp_order_rec.object_version_number := l_object_version_number;
                END IF;
                CLOSE osp_order_po_csr;
            ELSIF (p_x_osp_order_rec.oe_header_id IS NOT NULL AND p_x_osp_order_rec.oe_header_id <> FND_API.G_MISS_NUM) THEN
                OPEN osp_order_oe_csr(p_x_osp_order_rec.oe_header_id);
                FETCH osp_order_oe_csr INTO l_osp_order_id,l_object_version_number;
                IF(osp_order_oe_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_OE_HEADER_INV');
                    FND_MESSAGE.Set_Token('OE_HEADER_ID', p_x_osp_order_rec.oe_header_id);
                    FND_MSG_PUB.ADD;
                ELSE
                    p_x_osp_order_rec.osp_order_id := l_osp_order_id;
                    p_x_osp_order_rec.object_version_number := l_object_version_number;
                END IF;
                CLOSE osp_order_oe_csr;
            */
            -- jaramana End
            ELSE
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_HEADER_INV');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
    --dbms_output.put_line('Exiting : convert_order_header_val_to_id');
END convert_order_header_val_to_id;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_vendor(p_vendor_id  IN NUMBER) IS
  CURSOR val_vendor_id_csr(p_vendor_id IN NUMBER) IS
    SELECT 'X'
      FROM po_vendors_view
     WHERE vendor_id = p_vendor_id
       AND enabled_flag = G_YES_FLAG
       AND NVL(vendor_start_date_active, SYSDATE - 1) <= SYSDATE
       AND NVL(vendor_end_date_active, SYSDATE + 1) > SYSDATE;
  CURSOR get_vendor_cert IS
    SELECT 'X'
      FROM ahl_vendor_certifications_v
     WHERE vendor_id = p_vendor_id
       AND TRUNC(active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(nvl(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_vendor';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_vendor_id IS NOT NULL AND p_vendor_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_vendor_id_csr(p_vendor_id);
       FETCH val_vendor_id_csr INTO l_exist;
       IF(val_vendor_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
          FND_MESSAGE.Set_Token('VENDOR_ID', p_vendor_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_vendor_id_csr;
       OPEN get_vendor_cert;
       FETCH get_vendor_cert INTO l_exist;
       IF(get_vendor_cert%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
          FND_MESSAGE.Set_Token('VENDOR_ID', p_vendor_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE get_vendor_cert;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_vendor;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_vendor_site(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
  CURSOR val_vendor_site_id_csr(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
    SELECT 'x' FROM po_vendor_sites
     WHERE vendor_site_id = p_vendor_site_id
       AND vendor_id = p_vendor_id
       AND NVL(inactive_date, SYSDATE + 1) > SYSDATE
       AND purchasing_site_flag = G_YES_FLAG
       AND NVL(RFQ_ONLY_SITE_FLAG, G_NO_FLAG) = G_NO_FLAG;
  CURSOR get_vendor_cert IS
    SELECT 'X'
      FROM ahl_vendor_certifications_v
     WHERE vendor_id = p_vendor_id
       AND vendor_site_id = p_vendor_site_id
       AND TRUNC(active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(nvl(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);
  l_exist VARCHAR2(1);
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_vendor_site';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF (p_vendor_id IS NULL OR p_vendor_id = FND_API.G_MISS_NUM) THEN
        IF(p_vendor_site_id IS NOT NULL AND p_vendor_site_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VEND_ID_NLL');
           FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
           FND_MSG_PUB.ADD;
        END IF;
    ELSE
        IF(p_vendor_site_id IS NOT NULL AND p_vendor_site_id <> FND_API.G_MISS_NUM)THEN
           OPEN val_vendor_site_id_csr(p_vendor_id, p_vendor_site_id);
           FETCH val_vendor_site_id_csr INTO l_exist;
           IF(val_vendor_site_id_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
              FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
              FND_MSG_PUB.ADD;
           END IF;
           CLOSE val_vendor_site_id_csr;
           OPEN get_vendor_cert;
           FETCH get_vendor_cert INTO l_exist;
           IF(get_vendor_cert%NOTFOUND) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
              FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
              FND_MSG_PUB.ADD;
           END IF;
           CLOSE get_vendor_cert;
       END IF;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_vendor_site;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_customer(
    p_customer_id IN NUMBER
    )IS
    CURSOR val_customer_id_csr(p_customer_id IN NUMBER) IS
    SELECT 'x' from hz_parties
    where party_id = p_customer_id and party_type = 'ORGANIZATION';
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_customer';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_customer_id IS NOT NULL AND p_customer_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_customer_id_csr(p_customer_id);
       FETCH val_customer_id_csr INTO l_exist;
       IF(val_customer_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUST_ID_INV');
          FND_MESSAGE.Set_Token('CUSTOMER_ID', p_customer_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_customer_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_customer;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_buyer(
    p_po_agent_id IN NUMBER
    )IS
    CURSOR val_po_agent_id_csr(p_po_agent_id IN NUMBER) IS
    SELECT 'x' FROM po_agents_name_v
    WHERE buyer_id = p_po_agent_id;
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_buyer';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_po_agent_id IS NOT NULL AND p_po_agent_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_po_agent_id_csr(p_po_agent_id);
       FETCH val_po_agent_id_csr INTO l_exist;
       IF(val_po_agent_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_ID_INV');
          FND_MESSAGE.Set_Token('BUYER_ID', p_po_agent_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_po_agent_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_buyer;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_contract(
    p_order_type_code IN VARCHAR2,
    p_contract_id IN VARCHAR2,
    p_party_vendor_id IN VARCHAR2,
    p_authoring_org_id IN VARCHAR2
    )IS
    CURSOR val_contract_id_csr(p_contract_id IN NUMBER,p_party_vendor_id in NUMBER,
                           p_buy_or_sell IN VARCHAR2, p_authoring_org_id IN NUMBER, p_object_code IN VARCHAR2) IS
    SELECT 'x'  FROM okc_k_headers_b chr, okc_k_party_roles_b cpl, okc_statuses_b sts
    WHERE chr.id = p_contract_id
      AND cpl.object1_id1 = p_party_vendor_id
      AND chr.authoring_org_id = p_authoring_org_id
      AND chr.id = cpl.chr_id AND chr.buy_or_sell = p_buy_or_sell AND chr.sts_code = sts.code AND sts.ste_code in ('ACTIVE', 'SIGNED')
      AND cpl.jtot_object1_code = p_object_code;
    l_exist VARCHAR2(1);
    l_buy_or_sell VARCHAR2(1);
    l_object_code VARCHAR2(30);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_contract';
BEGIN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
     IF(p_order_type_code = G_OSP_ORDER_TYPE_BORROW) THEN
        l_buy_or_sell := 'B';
        l_object_code := 'OKX_VENDOR';
     ELSIF (p_order_type_code = G_OSP_ORDER_TYPE_LOAN) THEN
        l_buy_or_sell := 'S';
        l_object_code := 'OKX_PARTY';
     ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_CTRCT');
        FND_MSG_PUB.ADD;
        RETURN;
     END IF;
     IF(p_party_vendor_id IS NULL OR p_party_vendor_id = FND_API.G_MISS_NUM) THEN
        IF(p_contract_id IS NOT NULL AND p_contract_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VEND_PTY_ID_NLL');
           FND_MESSAGE.Set_Token('CONTRACT_ID', p_contract_id);
           FND_MSG_PUB.ADD;
        END IF;
     ELSE
        IF(p_contract_id IS NOT NULL AND p_contract_id <> FND_API.G_MISS_NUM) THEN
           OPEN val_contract_id_csr(p_contract_id, p_party_vendor_id, l_buy_or_sell, p_authoring_org_id, l_object_code);
           FETCH val_contract_id_csr INTO l_exist;
           IF(val_contract_id_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CTRCT');
              FND_MESSAGE.Set_Token('CONTRACT_ID', p_contract_id);
              FND_MSG_PUB.ADD;
           END IF;
           CLOSE val_contract_id_csr;
        END IF;
     END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_contract;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_po_header(
    p_osp_order_id IN NUMBER,
    p_po_header_id IN NUMBER
    )IS
    CURSOR val_po_header_id_csr(p_po_header_id IN NUMBER,p_osp_order_id IN NUMBER) IS
    SELECT 'x' FROM po_headers_all
    WHERE po_header_id = p_po_header_id
     AND reference_num = p_osp_order_id
     AND interface_source_code = G_APP_NAME;
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_po_header';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_osp_order_id IS NULL OR p_osp_order_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_HEADER_INV');
       FND_MSG_PUB.ADD;
       RETURN;
    END IF;
    IF(p_po_header_id IS NOT NULL AND p_po_header_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_po_header_id_csr(p_po_header_id, p_osp_order_id);
       FETCH val_po_header_id_csr INTO l_exist;
       IF(val_po_header_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PO_HEADER_INV');
          FND_MESSAGE.Set_Token('PO_HEADER_ID', p_po_header_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_po_header_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_po_header;

--------------------------------------------------------------------------------------------------------------
-- validates osp header information for different order types and DML operations.
-- Steps :
-- Order Type Code can be Service, Loan , Borrow
-- Opreation Flag can be 'C', 'U', 'D' or null
-- IF not 'C', record should exist and osp_order_id and object version number should match in AHL_OSP_ORDERS_B table.
-- IF 'C', osp_order_id and object version number should be null.
-- IMPORTANT NOTE: This procedure is NOT being called for Order Header Creation any more.
-- Added by jaramana on January 8, 2008 for the Requisition ER 6034236
-- Also Note that operation_flag will never be NULL in the call to this API, as if it is null, then there is no updation
-- that needs to be performed on the Order Header, hence no validation is necessary.
--------------------------------------------------------------------------------------------------------------
PROCEDURE validate_order_header(
    p_x_osp_order_rec  IN OUT NOCOPY    osp_order_rec_type)
IS
    CURSOR osp_order_csr(p_osp_order_id IN NUMBER, p_object_version_number IN NUMBER) IS
    -- po_req_header_id added by jaramana on January 8, 2008 for the Requisition ER 6034236
    SELECT  osp_order_number, order_type_code, single_instance_flag, po_header_id, oe_header_id,vendor_id, vendor_site_id,
        customer_id,order_date,contract_id,contract_terms,operating_unit_id, po_synch_flag, status_code,
        po_batch_id, po_request_id,po_agent_id, po_interface_header_id, po_req_header_id , description, vendor_contact_id
    -- jaramana End
    FROM ahl_osp_orders_vl
    WHERE osp_order_id = p_osp_order_id
    AND object_version_number = p_object_version_number;

    -- Added by jaramana on January 8, 2008 for the Requisition ER 6034236
    CURSOR chk_requisition_exists_csr(c_osp_order_id IN NUMBER) IS
      SELECT POREQ.SEGMENT1
        FROM PO_REQUISITION_HEADERS_ALL POREQ, AHL_OSP_ORDERS_B OSP
        WHERE POREQ.INTERFACE_SOURCE_LINE_ID = c_osp_order_id
          AND OSP.OSP_ORDER_ID = c_osp_order_id
          AND OSP.OPERATING_UNIT_ID = POREQ.ORG_ID
          AND POREQ.INTERFACE_SOURCE_CODE = AHL_GLOBAL.AHL_APP_SHORT_NAME
	  AND NVL(POREQ.CLOSED_CODE, 'X') NOT IN ('CANCELLED', 'CLOSED', 'CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING',
             'FINALLY CLOSED', 'REJECTED', 'RETURNED');

    l_req_num VARCHAR2(20);

    l_osp_order_rec osp_order_rec_type;
    l_operating_unit_id NUMBER;
    l_new_order_number NUMBER;
    l_del_cancel_so_lines_tbl del_cancel_so_lines_tbl_type;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_order_header';
BEGIN
    --dbms_output.put_line('Entering : validate_order_header');
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    l_operating_unit_id := mo_global.get_current_org_id();
    IF (l_operating_unit_id IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_ORG_NOT_SET');
        FND_MSG_PUB.ADD;
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Note added by jaramana on January 8, 2008 for the Requisition ER 6034236
    -- Note that p_x_osp_order_rec.operation_flag will never be NULL in the call to this API. As an operation_flag of NULL
    -- means, there need to be no change in the osp_order_header, hence no validation is necessary.
    IF(p_x_osp_order_rec.operation_flag IS NULL OR p_x_osp_order_rec.operation_flag <> G_OP_CREATE) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.notCreate', 'operation is not create, it is:'||p_x_osp_order_rec.operation_flag);
        END IF;
        IF(p_x_osp_order_rec.osp_order_id IS NULL OR p_x_osp_order_rec.object_version_number IS NULL) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_OBJ_MISS');
           FND_MSG_PUB.ADD;
        ELSE
            -- fetch record and verify the latest record is being dealt with.
            OPEN osp_order_csr(p_x_osp_order_rec.osp_order_id, p_x_osp_order_rec.object_version_number);
            -- jaramana modified on January 8, 2008 for the Requisition ER 6034236 (Added po_req_header_id)
            FETCH osp_order_csr INTO l_osp_order_rec.osp_order_number, l_osp_order_rec.order_type_code,l_osp_order_rec.single_instance_flag,
                  l_osp_order_rec.po_header_id, l_osp_order_rec.oe_header_id,l_osp_order_rec.vendor_id,
                  l_osp_order_rec.vendor_site_id, l_osp_order_rec.customer_id, l_osp_order_rec.order_date,
                  l_osp_order_rec.contract_id, l_osp_order_rec.contract_terms, l_osp_order_rec.operating_unit_id,
                  l_osp_order_rec.po_synch_flag, l_osp_order_rec.status_code, l_osp_order_rec.po_batch_id, l_osp_order_rec.po_request_id,
                  l_osp_order_rec.po_agent_id, l_osp_order_rec.po_interface_header_id, l_osp_order_rec.po_req_header_id, l_osp_order_rec.description, l_osp_order_rec.vendor_contact_id;
            -- jaramana End
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'osp_order_id='||p_x_osp_order_rec.osp_order_id|| 'ovn='||p_x_osp_order_rec.object_version_number);
            END IF;
            -- if record not found, raise error and declare that record has been modified.
            IF (osp_order_csr%NOTFOUND) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INVOP_OSP_NFOUND');
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE osp_order_csr;
            -- check existing status. If closed, raise error.
            IF(l_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
               FND_MSG_PUB.ADD;
            ELSE
                g_old_status_code := l_osp_order_rec.status_code;
	                --g_order_status_for_update := l_osp_order_rec.status_code;
                g_old_type_code := l_osp_order_rec.order_type_code;
            END IF;

            -- Added by jaramana on January 8, 2008 for the Requisition ER 6034236
            -- User should not pass G_OSP_REQ_SUBMITTED_STATUS directly. User need to pass G_OSP_SUBMITTED_STATUS and
            -- depening on the 'Initialize Purchase Requisition' profile we deduce whether Requisition needs to be created
            IF(p_x_osp_order_rec.status_code is not null AND l_osp_order_rec.status_code <> G_OSP_REQ_SUBMITTED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_REQ_SUBMITTED_STATUS) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
               FND_MSG_PUB.ADD;
            END IF;

            --If the Profile 'Initialize Purchase Requisition' is set, then set the status to G_OSP_REQ_SUBMITTED_STATUS
            --if the passed status is G_OSP_SUBMITTED_STATUS and the old status is not G_OSP_SUBMITTED_STATUS
            IF (NVL(FND_PROFILE.VALUE('AHL_OSP_INIT_PO_REQ'), 'N') = 'Y') THEN
              IF(p_x_osp_order_rec.order_type_code IN (G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE) AND
                            (p_x_osp_order_rec.status_code is not null and p_x_osp_order_rec.status_code = G_OSP_SUBMITTED_STATUS and
                             l_osp_order_rec.status_code <> G_OSP_SUBMITTED_STATUS)) THEN
                p_x_osp_order_rec.status_code := G_OSP_REQ_SUBMITTED_STATUS;
              END IF;
            END IF;
            -- jaramana End

            -- check whether order_type_code is same -- . IF null, default it.
            IF(p_x_osp_order_rec.order_type_code IS NOT NULL AND p_x_osp_order_rec.order_type_code <> l_osp_order_rec.order_type_code) THEN
               --item exchange enhancement
               --only service/exchange ordertype conversion are allowed
               IF(p_x_osp_order_rec.order_type_code IN ( G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)
                  AND l_osp_order_rec.order_type_code IN ( G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)) THEN
                     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.notCreate', 'Set conversion Flag to Yes');
                     END IF;
                     -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
                     -- g_order_conversion_flag := G_YES_FLAG;
                     -- jaramana End
                     g_old_type_code := l_osp_order_rec.order_type_code;
                     g_new_type_code := p_x_osp_order_rec.order_type_code;
               ELSE
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_TYPE');
                  FND_MSG_PUB.ADD;
               END IF;
            ELSE
                p_x_osp_order_rec.order_type_code := l_osp_order_rec.order_type_code;
            END IF;
            -- osp order number can not be changed.
            IF(p_x_osp_order_rec.osp_order_number IS NOT NULL AND p_x_osp_order_rec.osp_order_number <> l_osp_order_rec.osp_order_number) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_NUM_INV');
               FND_MESSAGE.Set_Token('ORDER_NUMBER', p_x_osp_order_rec.osp_order_number);
               FND_MSG_PUB.ADD;
            END IF;
            -- order date can not be changed.
            IF(p_x_osp_order_rec.order_date IS NOT NULL AND TRUNC(p_x_osp_order_rec.order_date) <> TRUNC(l_osp_order_rec.order_date)) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_ORD_DT');
               FND_MSG_PUB.ADD;
            END IF;
            -- operating_unit_id can not change
            IF(p_x_osp_order_rec.operating_unit_id IS NOT NULL AND p_x_osp_order_rec.operating_unit_id <> l_osp_order_rec.operating_unit_id) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_OPUNIT');
               FND_MSG_PUB.ADD;
            END IF;


            -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
            /*
            Note that p_x_osp_order_rec.operation_flag will never be NULL in the call to this API. As an operation_flag of NULL
            means, there need to be no change in the osp_order_header, hence no validation is necessary.
            Hence commenting out the following code
            */
            -- if operation_flag is NULL , default po_header_id, oe_header_id (needed  for lines)
            /*
            IF(p_x_osp_order_rec.operation_flag IS NULL) THEN
               p_x_osp_order_rec.po_header_id := l_osp_order_rec.po_header_id;
               p_x_osp_order_rec.oe_header_id := l_osp_order_rec.oe_header_id;
               p_x_osp_order_rec.operating_unit_id := l_osp_order_rec.operating_unit_id;
               p_x_osp_order_rec.single_instance_flag := l_osp_order_rec.single_instance_flag;
            END IF;
            */
            -- contract terms should be null.
            IF(p_x_osp_order_rec.contract_terms IS NOT NULL AND p_x_osp_order_rec.contract_terms <> FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_CO');
               FND_MSG_PUB.ADD;
           END IF;
           -- shipping info is not allowed to update in this API
           IF(p_x_osp_order_rec.oe_header_id IS NOT NULL ) THEN
               IF(l_osp_order_rec.oe_header_id IS NULL AND p_x_osp_order_rec.oe_header_id <> FND_API.G_MISS_NUM) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_OE');                   FND_MSG_PUB.ADD;
               ELSIF(p_x_osp_order_rec.oe_header_id <> l_osp_order_rec.oe_header_id) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_OE');
                  FND_MSG_PUB.ADD;
               END IF;
            END IF;
        END IF;
    -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
    --This API is not being called during the create mode any more. Hence commenting out the following
    --validations. Some of the fields like PO related fields are defaulted to Null ignoring the user passed inputs
    --and the rest of them are being validated in the create_osp_order_header API
    /*
    ELSE -- mode is create and following processing is same for all type of orders

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.create', 'operation is create');
         END IF;
        IF(p_x_osp_order_rec.osp_order_id IS NOT NULL AND p_x_osp_order_rec.osp_order_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.object_version_number IS NOT NULL AND p_x_osp_order_rec.object_version_number <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_OBJV_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        -- populate order number
        IF(p_x_osp_order_rec.osp_order_number IS NOT NULL AND p_x_osp_order_rec.osp_order_number <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_NUM_INV');
           FND_MESSAGE.Set_Token('ORDER_NUMBER', p_x_osp_order_rec.osp_order_number);
           FND_MSG_PUB.ADD;
        END IF;
        -- populate order_date
        IF(p_x_osp_order_rec.order_date IS NOT NULL AND p_x_osp_order_rec.order_date <> FND_API.G_MISS_DATE) THEN
           IF(TRUNC(p_x_osp_order_rec.order_date) <> TRUNC(SYSDATE)) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_ORD_DAT');
              FND_MESSAGE.Set_Token('ORDER_DATE', p_x_osp_order_rec.order_date);
              FND_MSG_PUB.ADD;
           END IF;
        ELSE
           p_x_osp_order_rec.order_date := TRUNC(SYSDATE);
        END IF;
        -- populate operating_unit_id
        IF(p_x_osp_order_rec.operating_unit_id IS NOT NULL AND p_x_osp_order_rec.operating_unit_id <> FND_API.G_MISS_NUM) THEN
           IF(p_x_osp_order_rec.operating_unit_id <> l_operating_unit_id) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_OP_UNIT');
              FND_MSG_PUB.ADD;
           END IF;
        ELSE
              p_x_osp_order_rec.operating_unit_id := l_operating_unit_id;
        END IF;
        -- po_header_id, oe_header_id, po_batch_id, po_request_id, po_interface_header_id, contract_terms should be null for CREATE.
        IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.oe_header_id IS NOT NULL AND p_x_osp_order_rec.oe_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_OE_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_batch_id IS NOT NULL AND p_x_osp_order_rec.po_batch_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_request_id IS NOT NULL AND p_x_osp_order_rec.po_request_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_interface_header_id IS NOT NULL AND p_x_osp_order_rec.po_interface_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        -- status_code should be null or 'ENTERED'. IF null, default to 'ENTERED'
        IF(p_x_osp_order_rec.status_code IS NOT NULL AND p_x_osp_order_rec.status_code <> FND_API.G_MISS_CHAR
           AND p_x_osp_order_rec.status_code <> G_OSP_ENTERED_STATUS) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
           FND_MSG_PUB.ADD;
        ELSE
           p_x_osp_order_rec.status_code := G_OSP_ENTERED_STATUS;
           g_old_status_code := G_OSP_ENTERED_STATUS;
           --g_order_status_for_update := G_OSP_ENTERED_STATUS;
        END IF;
        --dbms_output.put_line('Create mode defaulting done');
    */
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    ----------------------------
    -- forcing null column rules
    ----------------------------
    -- add item exchange enhancement to if condition
    IF (p_x_osp_order_rec.order_type_code IN ( G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE))THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.type', 'Update Order type is Service or Exchange');
         END IF;
        -- contract_id and customer_id must be null for SERVICE or EXCHANGE
        IF(p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_CTRCT');
           FND_MESSAGE.Set_Token('CONTRACT_ID', p_x_osp_order_rec.contract_id);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUST_ID_INV');
           FND_MESSAGE.Set_Token('CUSTOMER_ID', p_x_osp_order_rec.customer_id);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.contract_terms IS NOT NULL AND p_x_osp_order_rec.contract_terms <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_CO');
           FND_MSG_PUB.ADD;
        END IF;
    ELSIF (p_x_osp_order_rec.order_type_code IN( G_OSP_ORDER_TYPE_LOAN,G_OSP_ORDER_TYPE_BORROW) ) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.type', 'Update Order type is Loan or Borrow');
         END IF;
        -- po_agent_id,vendor_id(FOR LOAN only) and vendor_site_id must be null.
        IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_ID_INV');
           FND_MESSAGE.Set_Token('BUYER_ID', p_x_osp_order_rec.po_agent_id);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
           FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_x_osp_order_rec.vendor_site_id);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.order_type_code = G_OSP_ORDER_TYPE_LOAN) THEN
           IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
              FND_MESSAGE.Set_Token('VENDOR_ID', p_x_osp_order_rec.vendor_id);
              FND_MSG_PUB.ADD;
           END IF;
        END IF;
        -- po_header_id, po_batch_id, po_request_id, po_interface_header_id, contract_terms should be null
        IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_batch_id IS NOT NULL AND p_x_osp_order_rec.po_batch_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_request_id IS NOT NULL AND p_x_osp_order_rec.po_request_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.po_interface_header_id IS NOT NULL AND p_x_osp_order_rec.po_interface_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
           FND_MSG_PUB.ADD;
        END IF;

        -- Added by jaramana on January 8, 2008 for the Requisition ER 6034236
        IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_REQ_NNLL');
           FND_MSG_PUB.ADD;
        END IF;
        -- jaramana End

        IF(p_x_osp_order_rec.contract_terms IS NOT NULL AND p_x_osp_order_rec.contract_terms <> FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_CO');
           FND_MSG_PUB.ADD;
        END IF;

    END IF;
    --dbms_output.put_line('ensured null columns');
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_x_osp_order_rec.order_type_code IN ( G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)) THEN  --item exchange enhancement add G_OSP_ORDER_TYPE_EXCHANGE condition
        -- Commented out by jaramana on January 8, 2008 for the Requisition ER 6034236
        -- This API is not being called during the create mode any more.
        -- Hence commenting out the following validations.

        /*
        IF(p_x_osp_order_rec.operation_flag = G_OP_CREATE) THEN
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.type.oper', 'Update Order type is Service or Exchange Operation is Create');
           END IF;
           --dbms_output.put_line('validate single_instance_flag');
           --set single_instance_flag
           IF(p_x_osp_order_rec.single_instance_flag IS NULL OR p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR)THEN
              p_x_osp_order_rec.single_instance_flag := G_NO_FLAG;
           ELSIF (p_x_osp_order_rec.single_instance_flag NOT IN(G_NO_FLAG,G_YES_FLAG))THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_INST_FLG');
              FND_MESSAGE.Set_Token('INST_FLG', p_x_osp_order_rec.single_instance_flag);
              FND_MSG_PUB.ADD;
           END IF;
           --dbms_output.put_line('validate vendor');

           -- validate vendor_id.
           IF(p_x_osp_order_rec.vendor_id IS NULL OR p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_vendor(p_x_osp_order_rec.vendor_id);
           END IF;
           --dbms_output.put_line('validate vendor site');
           -- validate vendor_site_id.
           IF(p_x_osp_order_rec.vendor_site_id IS NULL OR p_x_osp_order_rec.vendor_site_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_vendor_site(p_x_osp_order_rec.vendor_id, p_x_osp_order_rec.vendor_site_id);
           END IF;

           validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                        p_x_osp_order_rec.vendor_site_id,
                                        p_x_osp_order_rec.vendor_contact_id);
           -- validate po_agent_id.
           --dbms_output.put_line('validate buyer');
           IF(p_x_osp_order_rec.po_agent_id IS NULL OR p_x_osp_order_rec.po_agent_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_buyer(p_x_osp_order_rec.po_agent_id);
           END IF;
        */
        -- jaramana End
        IF(p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update', 'Update Order type is Service or Exchange Operation is Update ');
           END IF;
           -- Modified by jaramana on January 9, 2008 for the Requisition ER 6034236 (Added G_OSP_REQ_SUB_FAILED_STATUS)
           IF(g_old_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS)) THEN
           -- jaramana End
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'
                              || 'g_old_status_code' || g_old_status_code);
              END IF;
              -- po_header_id should be null.
              IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
                FND_MSG_PUB.ADD;
              END IF;
              -- Modified by jaramana on January 9, 2008 for the Requisition ER 6034236
              -- req_header_id should be null.
              IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_ORD_REQ_NNLL');
                FND_MSG_PUB.ADD;
              END IF;
              -- jaramana End

              -- Modified by jaramana on January 9, 2008 for the Requisition ER 6034236
              -- status_code should be null,'ENTERED', 'SUBMISSION_FAILED' or 'SUBMITTED'
              /*
              IF(p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code NOT IN(G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_SUBMITTED_STATUS)) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              ELSIF (g_old_status_code  = G_OSP_ENTERED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_SUB_FAILED_STATUS) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              ELSIF (g_old_status_code  = G_OSP_SUB_FAILED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_ENTERED_STATUS) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              */
              /*
              1. If the current status is G_OSP_ENTERED_STATUS, the status cannot be changed to G_OSP_SUB_FAILED_STATUS or
              G_OSP_REQ_SUB_FAILED_STATUS. It can only be changed to G_OSP_SUBMITTED_STATUS or G_OSP_REQ_SUBMITTED_STATUS or
              it can be changed to G_OSP_ENTERED_STATUS (No update)

              2. If the current status is G_OSP_SUB_FAILED_STATUS, the status cannot be changed to G_OSP_ENTERED_STATUS or
              G_OSP_REQ_SUB_FAILED_STATUS. It can only be changed to G_OSP_SUBMITTED_STATUS or G_OSP_REQ_SUBMITTED_STATUS or
              it can be changed to G_OSP_SUB_FAILED_STATUS (No update)

              3. If the current status is G_OSP_REQ_SUB_FAILED_STATUS, the status cannot be changed to G_OSP_ENTERED_STATUS or
              G_OSP_SUB_FAILED_STATUS. It can only be changed to G_OSP_SUBMITTED_STATUS or G_OSP_REQ_SUBMITTED_STATUS or
              it can be changed to G_OSP_REQ_SUB_FAILED_STATUS (No update)

              In all the above the changes status is either itself or G_OSP_SUBMITTED_STATUS or G_OSP_REQ_SUBMITTED_STATUS
              */

              IF(p_x_osp_order_rec.status_code IS NOT NULL AND p_x_osp_order_rec.status_code <> g_old_status_code AND p_x_osp_order_rec.status_code NOT IN (G_OSP_SUBMITTED_STATUS,G_OSP_REQ_SUBMITTED_STATUS )) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;

              --
              --set single_instance_flag
              IF(p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR)THEN
                 p_x_osp_order_rec.single_instance_flag := G_NO_FLAG;
              ELSIF (p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag NOT IN(G_NO_FLAG,G_YES_FLAG))THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_INST_FLG');
                 FND_MESSAGE.Set_Token('INST_FLG', p_x_osp_order_rec.single_instance_flag);
                 FND_MSG_PUB.ADD;
              END IF;
              /*
              -- validate vendor_id
              IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
                 FND_MSG_PUB.ADD;
              ELSIF (p_x_osp_order_rec.vendor_id IS NOT NULL) THEN
                 validate_vendor(p_x_osp_order_rec.vendor_id);
              END IF;
              -- validate vendor_site_id.
              IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id = FND_API.G_MISS_NUM) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_NLL');
                 FND_MSG_PUB.ADD;
              ELSE
                 p_x_osp_order_rec.vendor_site_id := NVL(p_x_osp_order_rec.vendor_site_id,l_osp_order_rec.vendor_site_id);
                 p_x_osp_order_rec.vendor_id := NVL(p_x_osp_order_rec.vendor_id, l_osp_order_rec.vendor_id);
                 validate_vendor_site(p_x_osp_order_rec.vendor_id, p_x_osp_order_rec.vendor_site_id);
              END IF;
              */
              --When updating OSP order header, vendor_id is required
              --G_MISS/Null conversion has already been made in default_unchanged_order_header
              IF(p_x_osp_order_rec.vendor_id IS NULL) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_NLL');
                FND_MSG_PUB.ADD;
              END IF;

              --When updating OSP order header, vendor_site_id is required
              --G_MISS/Null conversion has already been made in default_unchanged_order_header
              IF(p_x_osp_order_rec.vendor_site_id IS NULL) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
                FND_MSG_PUB.ADD;
              END IF;

              validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                           p_x_osp_order_rec.vendor_site_id,
                                           p_x_osp_order_rec.vendor_contact_id);
              -- validate po_agent_id.
              --dbms_output.put_line('validate buyer in update');
              --IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id = FND_API.G_MISS_NUM) THEN
              --G_MISS/Null conversion has already been made in default_unchanged_order_header
              IF(p_x_osp_order_rec.po_agent_id IS NULL) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_ID_NLL');
                 FND_MSG_PUB.ADD;
              ELSIF (p_x_osp_order_rec.po_agent_id IS NOT NULL) THEN
                 validate_buyer(p_x_osp_order_rec.po_agent_id);
              END IF;
              -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
              -- Prevent Resubmission if the old status is G_OSP_REQ_SUB_FAILED_STATUS
              -- and new status is (G_OSP_SUBMITTED_STATUS or G_OSP_REQ_SUBMITTED_STATUS)
              -- and if the requisition header is not yet deleted by the user.
              -- This is the case where the Requisition was created only for some OSP lines
              -- and failed for the remaining - user has to manually delete the Requisition before resubmitting.
              IF(g_old_status_code = G_OSP_REQ_SUB_FAILED_STATUS AND
                 p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code IN (G_OSP_SUBMITTED_STATUS,G_OSP_REQ_SUBMITTED_STATUS)) THEN
                 OPEN chk_requisition_exists_csr(p_x_osp_order_rec.osp_order_id);
                 FETCH chk_requisition_exists_csr INTO l_req_num;
                 IF (chk_requisition_exists_csr%FOUND) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_REQ_NOT_DELETED');
                   FND_MESSAGE.Set_Token('REQ_NUM', l_req_num);
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE chk_requisition_exists_csr;
              END IF;
              -- End addition by jaramana on January 9, 2008
           ELSIF (g_old_status_code = G_OSP_SUBMITTED_STATUS) THEN
              -- status_code should be null,'SUBMITTED', 'SUBMISSION_FAILED' or 'PO_CREATED'
              IF(p_x_osp_order_rec.status_code IS NULL OR p_x_osp_order_rec.status_code = G_OSP_SUBMITTED_STATUS) THEN
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'
                              || 'g_old_status_code: ' || g_old_status_code || 'new status: ' || p_x_osp_order_rec.status_code );
                  END IF;
                 -- po_header_id should be null.
                 IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
                    FND_MSG_PUB.ADD;
                 END IF;

                -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
                -- req_header_id should be null.
                IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> FND_API.G_MISS_NUM) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_ORD_REQ_NNLL');
                  FND_MSG_PUB.ADD;
                END IF;
                -- jaramana End

                 -- single_instance_flag cant change
                 IF(p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag <> l_osp_order_rec.single_instance_flag) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_INST_FLG_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_id cant change
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_site_id cant change
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;

                 -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
                 -- This should have been present with ISO changes. Adding now.
                 -- vendor_contact_id cant change
                 IF(p_x_osp_order_rec.vendor_contact_id IS NOT NULL AND p_x_osp_order_rec.vendor_contact_id <> l_osp_order_rec.vendor_contact_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CTCT_CHG ');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- jaramana End

                 -- Buyer cant change
                 IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> l_osp_order_rec.po_agent_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_BUYER_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
              -- jaramana modified on January 9, 2008 for the Requisition ER 6034236
              --The transitions from G_OSP_SUBMITTED_STATUS -> G_OSP_SUB_FAILED_STATUS and
              --G_OSP_SUBMITTED_STATUS -> G_OSP_PO_CREATED_STATUS are not done from this API and are handled by the PO Synch
              --API. Hence removing these tranisitions from here. If at all these transitions take place, we are throwing a
              --validation error.
              /*
              ELSIF (p_x_osp_order_rec.status_code = G_OSP_SUB_FAILED_STATUS) THEN
                 -- po_header_id should be null.
                 IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
                    FND_MSG_PUB.ADD;
                 END IF;
                 --set single_instance_flag
                 IF(p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR)THEN
                    p_x_osp_order_rec.single_instance_flag := G_NO_FLAG;
                 ELSIF (p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag NOT IN(G_NO_FLAG,G_YES_FLAG))THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_INST_FLG');
                    FND_MESSAGE.Set_Token('INST_FLG', p_x_osp_order_rec.single_instance_flag);
                    FND_MSG_PUB.ADD;
                 END IF;
                */
                /*
                 -- validate vendor_id.
                IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
                   FND_MSG_PUB.ADD;
                ELSIF (p_x_osp_order_rec.vendor_id IS NOT NULL) THEN
                   validate_vendor(p_x_osp_order_rec.vendor_id);
                END IF;
                -- validate vendor_site_id.
                IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id = FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_NLL');
                   FND_MSG_PUB.ADD;
                ELSE
                   p_x_osp_order_rec.vendor_site_id := NVL(p_x_osp_order_rec.vendor_site_id,l_osp_order_rec.vendor_site_id);
                   p_x_osp_order_rec.vendor_id := NVL(p_x_osp_order_rec.vendor_id, l_osp_order_rec.vendor_id);
                   validate_vendor_site(p_x_osp_order_rec.vendor_id, p_x_osp_order_rec.vendor_site_id);
                END IF;
                */
                /*
                validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                             p_x_osp_order_rec.vendor_site_id,
                                             p_x_osp_order_rec.vendor_contact_id);
                -- validate po_agent_id.
                --dbms_output.put_line('validate buyer in update');
                IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id = FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_BUYER_ID_NLL');
                   FND_MSG_PUB.ADD;
                ELSIF (p_x_osp_order_rec.po_agent_id IS NOT NULL) THEN
                   validate_buyer(p_x_osp_order_rec.po_agent_id);
                END IF;
                 -- set status_code for lines
                 g_order_status_for_update := G_OSP_SUB_FAILED_STATUS;
              ELSIF (p_x_osp_order_rec.status_code = G_OSP_PO_CREATED_STATUS) THEN
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'
                              || 'g_old_status_code: ' || g_old_status_code || 'new status: ' || p_x_osp_order_rec.status_code );
                  END IF;
                 -- po_header_id should be not be null.
                 IF(p_x_osp_order_rec.po_header_id IS NULL OR p_x_osp_order_rec.po_header_id = FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_PO_NLL');
                    FND_MSG_PUB.ADD;
                 ELSE
                    validate_po_header(p_x_osp_order_rec.osp_order_id,p_x_osp_order_rec.po_header_id);
                 END IF;
                 -- single_instance_flag cant change
                 IF(p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag <> l_osp_order_rec.single_instance_flag) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_INST_FLG_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 --PO Synch enhancement  vendor id and vendor sitecode can change if the change come from PO
                 -- vendor_id cannot change unless it was change in PO
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    IF( vendor_id_exist_in_PO(l_osp_order_rec.po_header_id, p_x_osp_order_rec.vendor_id) = false) THEN
                         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                         FND_MSG_PUB.ADD;
                     END IF;
                 END IF;
                 -- vendor_site_id cannot change unless it was changed in PO
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                    IF( vendor_site_id_exist_in_PO(l_osp_order_rec.po_header_id, p_x_osp_order_rec.vendor_site_id) = false) THEN
                       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                       FND_MSG_PUB.ADD;
                     END IF;
                 END IF;
                 -- Buyer cant change
                 IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> l_osp_order_rec.po_agent_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_BUYER_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- set status_code for lines
                 g_order_status_for_update := G_OSP_PO_CREATED_STATUS;
              */
              -- jaramana End
              ELSE
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;

           ELSIF (g_old_status_code = G_OSP_PO_CREATED_STATUS) THEN
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'
                              || 'g_old_status_code: ' || g_old_status_code);
              END IF;
              -- status_code should be null, 'PO_CREATED' or 'CLOSED'
              IF(p_x_osp_order_rec.status_code IS NULL OR p_x_osp_order_rec.status_code IN( G_OSP_PO_CREATED_STATUS,G_OSP_CLOSED_STATUS)) THEN
                 -- po_header_id cant change
                 IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> l_osp_order_rec.po_header_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_PO_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;

                 -- jaramana modified on January 9, 2008 for the Requisition ER 6034236
                 -- req_header_id should be null.
                 IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_REQ_NNLL');
                   FND_MSG_PUB.ADD;
                 END IF;
                 -- jaramana End

                 -- single_instance_flag cant change
                 IF(p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag <> l_osp_order_rec.single_instance_flag) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_INST_FLG_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 /*
                 --PO Synch enhancement  vendor id and vendor sitecode can change if the change come from PO
                 -- vendor_id cant change
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    IF( vendor_id_exist_in_PO(l_osp_order_rec.po_header_id, p_x_osp_order_rec.vendor_id) = false) THEN
                      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                      FND_MSG_PUB.ADD;
                    END IF;
                 END IF;
                 -- vendor_site_id cant change
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                   IF( vendor_site_id_exist_in_PO(l_osp_order_rec.po_header_id, p_x_osp_order_rec.vendor_site_id) = false) THEN
                      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                      FND_MSG_PUB.ADD;
                   END IF;
                 END IF;
                 */
                 -- Changes by jaramana on January 9, 2008 for the Requisition ER 6034236
                 -- We are not planning to support this PO attribute continuous synch anymore.

                 -- vendor_id cant change
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_site_id cant change
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_contact_id cant change
                 IF(p_x_osp_order_rec.vendor_contact_id IS NOT NULL AND p_x_osp_order_rec.vendor_contact_id <> l_osp_order_rec.vendor_contact_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CTCT_CHG ');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- jaramana End

                 -- Buyer cant change
                 IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> l_osp_order_rec.po_agent_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_BUYER_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- set status_code for lines
                 --g_order_status_for_update := G_OSP_PO_CREATED_STATUS;
              ELSE
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
           ELSIF (g_old_status_code = G_OSP_REQ_SUBMITTED_STATUS) THEN
              IF(p_x_osp_order_rec.status_code IS NULL OR p_x_osp_order_rec.status_code = G_OSP_REQ_SUBMITTED_STATUS) THEN
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'||
                                        'g_old_status_code: ' || g_old_status_code || 'new status: ' || p_x_osp_order_rec.status_code );
                  END IF;
                 -- po_header_id should be null.
                 IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
                    FND_MSG_PUB.ADD;
                 END IF;

                -- req_header_id should be null.
                IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> FND_API.G_MISS_NUM) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_REQ_NNLL');
                  FND_MSG_PUB.ADD;
                END IF;

                 -- single_instance_flag cant change
                 IF(p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag <> l_osp_order_rec.single_instance_flag) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_INST_FLG_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_id cant change
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_site_id cant change
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_contact_id cant change
                 IF(p_x_osp_order_rec.vendor_contact_id IS NOT NULL AND p_x_osp_order_rec.vendor_contact_id <> l_osp_order_rec.vendor_contact_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CTCT_CHG ');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- Buyer cant change
                 IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> l_osp_order_rec.po_agent_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_BUYER_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
              ELSE
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;

           ELSIF (g_old_status_code = G_OSP_REQ_CREATED_STATUS) THEN
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.srvExch.update.', 'Update Order type is Service or Exchange Operation is Update'
                              || 'g_old_status_code: ' || g_old_status_code);
              END IF;
              -- status_code should be null, 'REQ_CREATED' or 'CLOSED'
              IF(p_x_osp_order_rec.status_code IS NULL OR p_x_osp_order_rec.status_code IN( G_OSP_REQ_CREATED_STATUS,G_OSP_CLOSED_STATUS)) THEN
                 -- req_header_id cant change
                 IF(p_x_osp_order_rec.po_req_header_id IS NOT NULL AND p_x_osp_order_rec.po_req_header_id <> l_osp_order_rec.po_req_header_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_REQ_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;

                 --po_header_id should be null
                 IF(p_x_osp_order_rec.po_header_id IS NOT NULL AND p_x_osp_order_rec.po_header_id <> FND_API.G_MISS_NUM) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_PO_NNLL');
                   FND_MSG_PUB.ADD;
                 END IF;

                 -- single_instance_flag cant change
                 IF(p_x_osp_order_rec.single_instance_flag IS NOT NULL AND p_x_osp_order_rec.single_instance_flag <> l_osp_order_rec.single_instance_flag) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_INST_FLG_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;

                 -- vendor_id cant change
                 IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- vendor_site_id cant change
                 IF(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND p_x_osp_order_rec.vendor_site_id <> l_osp_order_rec.vendor_site_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_STE_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;

                 -- vendor_contact_id cant change
                 IF(p_x_osp_order_rec.vendor_contact_id IS NOT NULL AND p_x_osp_order_rec.vendor_contact_id <> l_osp_order_rec.vendor_contact_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEN_CTCT_CHG ');
                    FND_MSG_PUB.ADD;
                 END IF;

                 -- Buyer cant change
                 IF(p_x_osp_order_rec.po_agent_id IS NOT NULL AND p_x_osp_order_rec.po_agent_id <> l_osp_order_rec.po_agent_id) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_BUYER_CHG');
                    FND_MSG_PUB.ADD;
                 END IF;
                 -- set status_code for lines
                 --g_order_status_for_update := G_OSP_PO_CREATED_STATUS;
              ELSE
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              --mpothuku End
           END IF; --IF(p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
        END IF; --IF (p_x_osp_order_rec.order_type_code IN ( G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)) THEN
    -- validate Loan order header
    ELSIF (p_x_osp_order_rec.order_type_code = G_OSP_ORDER_TYPE_LOAN) THEN
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '.loan', 'Update order type is Loan');
       END IF;
        -- single_instance_flag can not be other than null, GMISS or G_NO_FLAG.
        IF(p_x_osp_order_rec.single_instance_flag IS NULL OR p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR
           OR p_x_osp_order_rec.single_instance_flag = G_NO_FLAG )THEN
           p_x_osp_order_rec.single_instance_flag := G_NO_FLAG;
        ELSE
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_INST_FLG');
           FND_MESSAGE.Set_Token('INST_FLG', p_x_osp_order_rec.single_instance_flag);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.operation_flag = G_OP_CREATE) THEN
           -- validate customer_id.
           IF(p_x_osp_order_rec.customer_id IS NULL OR p_x_osp_order_rec.customer_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUSTOMER_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_customer(p_x_osp_order_rec.customer_id);
           END IF;
           -- validate contract_id
          /* Change made by mpothuku to make the contract_id optional on 12/16/04
	     This is a work around and has to be revoked after PM comes up with the Service Contract Integration
	  */
	  -- Changes begin
	 /*
           IF (p_x_osp_order_rec.contract_id IS NULL OR p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CONTRACT_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
           validate_contract(G_OSP_ORDER_TYPE_LOAN, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.customer_id , l_operating_unit_id);
	 */
	   IF (p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> FND_API.G_MISS_NUM) THEN
	    validate_contract(G_OSP_ORDER_TYPE_LOAN, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.customer_id , l_operating_unit_id);
           END IF;
	  --Changes by mpothuku End
        ELSIF(p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
           IF(g_old_status_code  = G_OSP_ENTERED_STATUS) THEN
              -- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236
              -- status_code should be null,'ENTERED', or 'SUBMITTED' or 'REQ_SUBMITTED'
              IF(p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code NOT IN(G_OSP_ENTERED_STATUS, G_OSP_SUBMITTED_STATUS, G_OSP_REQ_SUBMITTED_STATUS)) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              -- jaramana End
              -- validate customer_id.
              IF(p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id = FND_API.G_MISS_NUM) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CUSTOMER_ID_NLL');
                 FND_MSG_PUB.ADD;
              ELSIF(p_x_osp_order_rec.customer_id IS NOT NULL) THEN
                 validate_customer(p_x_osp_order_rec.customer_id);
              END IF;
              -- validate contract_id
              /* Change made by mpothuku to make the contract_id optional on 12/16/04
		This is a work around and has to be revoked after PM comes up with the Service Contract Integration
	      */
	      -- Changes begin
	      /*
              IF(p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CONTRACT_ID_NLL');
                 FND_MSG_PUB.ADD;
              ELSIF ( p_x_osp_order_rec.contract_id IS NOT NULL) THEN
                 validate_contract(G_OSP_ORDER_TYPE_LOAN, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.customer_id , l_operating_unit_id);
	      */
              IF ( p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> FND_API.G_MISS_NUM) THEN
                 validate_contract(G_OSP_ORDER_TYPE_LOAN, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.customer_id , l_operating_unit_id);
              END IF;
	     --Changes by mpothuku End
              -- set status
              --g_order_status_for_update := G_OSP_ENTERED_STATUS;
           ELSIF(g_old_status_code  = G_OSP_SUBMITTED_STATUS) THEN
               -- status_code should be null,'ENTERED', or 'SUBMITTED'
              IF(p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code NOT IN(G_OSP_SUBMITTED_STATUS, G_OSP_CLOSED_STATUS)) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              -- CUSTOMER_ID cant change
              IF(p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id <> l_osp_order_rec.customer_id) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CUST_CHG');
                 FND_MSG_PUB.ADD;
              END IF;
              -- contract_id cant change
              IF(p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> l_osp_order_rec.contract_id) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CTRCT_CHG');
                 FND_MSG_PUB.ADD;
              END IF;
              --g_order_status_for_update := G_OSP_SUBMITTED_STATUS;
           ELSE
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
              FND_MSG_PUB.ADD;
           END IF;
        END IF;
    -- validate BORROW order header
    ELSIF (p_x_osp_order_rec.order_type_code = G_OSP_ORDER_TYPE_BORROW) THEN
        -- single_instance_flag can not be other than null, GMISS or G_NO_FLAG.
        IF(p_x_osp_order_rec.single_instance_flag IS NULL OR p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR
           OR p_x_osp_order_rec.single_instance_flag = G_NO_FLAG )THEN
           p_x_osp_order_rec.single_instance_flag := G_NO_FLAG;
        ELSE
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_INST_FLG');
           FND_MESSAGE.Set_Token('INST_FLG', p_x_osp_order_rec.single_instance_flag);
           FND_MSG_PUB.ADD;
        END IF;
        IF(p_x_osp_order_rec.operation_flag = G_OP_CREATE) THEN
           -- validate customer_id.
           IF(p_x_osp_order_rec.customer_id IS NOT NULL) THEN
              validate_customer(p_x_osp_order_rec.customer_id);
           END IF;
           /*
           -- validate vendor_id.
           IF(p_x_osp_order_rec.vendor_id IS NULL OR p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_vendor(p_x_osp_order_rec.vendor_id);
           END IF;
           */
           validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                        p_x_osp_order_rec.vendor_site_id,
                                        p_x_osp_order_rec.vendor_contact_id);
           -- validate contract_id
	   /* Change made by mpothuku to make the contract_id optional on 12/16/04
	      This is a work around and has to be revoked after PM comes up with the Service Contract Integration
	   */
	   -- Changes begin
	   /*
            IF (p_x_osp_order_rec.contract_id IS NULL OR p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CONTRACT_ID_NLL');
              FND_MSG_PUB.ADD;
           ELSE
              validate_contract(G_OSP_ORDER_TYPE_BORROW, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.vendor_id , l_operating_unit_id);
           END IF;
	   */
	   IF (p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> FND_API.G_MISS_NUM) THEN
		validate_contract(G_OSP_ORDER_TYPE_BORROW, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.vendor_id , l_operating_unit_id);
           END IF;
	   --Changes by mpothuku End
        ELSIF(p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
           IF(g_old_status_code  = G_OSP_ENTERED_STATUS) THEN
              -- status_code should be null,'ENTERED', or 'SUBMITTED'
              IF(p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code NOT IN(G_OSP_ENTERED_STATUS, G_OSP_SUBMITTED_STATUS)) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              -- validate customer_id.
              IF(p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id <> FND_API.G_MISS_NUM) THEN
                 validate_customer(p_x_osp_order_rec.customer_id);
              END IF;
	      /* Change made by mpothuku to make the contract_id optional on 12/16/04
	         This is a work around and has to be revoked after PM comes up with the Service Contract Integration
	      */
	      -- Changes begin
	      /*
              IF (p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CONTRACT_ID_NLL');
                  FND_MSG_PUB.ADD;
              ELSIF(p_x_osp_order_rec.contract_id IS NOT NULL AND (p_x_osp_order_rec.vendor_id IS NULL OR p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM)) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
                  FND_MSG_PUB.ADD;
              ELSIF(p_x_osp_order_rec.vendor_id IS NOT NULL OR p_x_osp_order_rec.contract_id IS NOT NULL) THEN
                  -- validate vendor_id.
                   validate_vendor(p_x_osp_order_rec.vendor_id);
                   p_x_osp_order_rec.contract_id := NVL(p_x_osp_order_rec.contract_id, l_osp_order_rec.contract_id);
                  -- validate contract_id
                  validate_contract(G_OSP_ORDER_TYPE_BORROW, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.vendor_id , l_operating_unit_id);
              END IF;
	     */
             /*
	     -- validate vendor_id.
             IF(p_x_osp_order_rec.vendor_id IS NULL OR p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
		 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_NLL');
		  FND_MSG_PUB.ADD;
	      ELSE
		validate_vendor(p_x_osp_order_rec.vendor_id);
	     END IF;
             */
             validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                          p_x_osp_order_rec.vendor_site_id,
                                          p_x_osp_order_rec.vendor_contact_id);

             p_x_osp_order_rec.contract_id := NVL(p_x_osp_order_rec.contract_id, l_osp_order_rec.contract_id);
	     --validate contract_id only if it is not null.
	     IF (p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> FND_API.G_MISS_NUM) THEN
		validate_contract(G_OSP_ORDER_TYPE_BORROW, p_x_osp_order_rec.contract_id , p_x_osp_order_rec.vendor_id , l_operating_unit_id);
	     END IF;
	  --Changes by mpothuku End
	     -- set status
              --g_order_status_for_update := G_OSP_ENTERED_STATUS;
           ELSIF(g_old_status_code  = G_OSP_SUBMITTED_STATUS) THEN
               -- status_code should be null,'ENTERED', or 'SUBMITTED'
              IF(p_x_osp_order_rec.status_code IS NOT NULL AND
                 p_x_osp_order_rec.status_code NOT IN(G_OSP_SUBMITTED_STATUS, G_OSP_CLOSED_STATUS)) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
                 FND_MSG_PUB.ADD;
              END IF;
              -- CUSTOMER_ID cant change
              IF(p_x_osp_order_rec.customer_id IS NOT NULL AND p_x_osp_order_rec.customer_id <> l_osp_order_rec.customer_id) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CUST_CHG');
                 FND_MSG_PUB.ADD;
              END IF;
              -- vendor_id cant change
              IF(p_x_osp_order_rec.vendor_id IS NOT NULL AND p_x_osp_order_rec.vendor_id <> l_osp_order_rec.vendor_id) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_VEND_CHG');
                 FND_MSG_PUB.ADD;
              END IF;
              -- contract_id cant change
              IF(p_x_osp_order_rec.contract_id IS NOT NULL AND p_x_osp_order_rec.contract_id <> l_osp_order_rec.contract_id) THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CTRCT_CHG');
                 FND_MSG_PUB.ADD;
              END IF;
              -- set status
              --g_order_status_for_update := G_OSP_SUBMITTED_STATUS;
           ELSE
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_STATUS');
              FND_MSG_PUB.ADD;
           END IF;
        END IF;
    ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INV_TYPE');
        FND_MSG_PUB.ADD;
    END IF;
    -- delete header
    IF(p_x_osp_order_rec.operation_flag = G_OP_DELETE) THEN
        -- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236 (Added G_OSP_REQ_SUB_FAILED_STATUS)
        IF(g_old_status_code NOT IN( G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS ))THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVOP');
            FND_MSG_PUB.ADD;
        ELSE
            --g_order_status_for_update := G_OSP_DELETED_STATUS;
            IF(l_osp_order_rec.oe_header_id IS NOT NULL) THEN
              -- calling to delete SO HEADER
              delete_cancel_so(
                 p_oe_header_id             => l_osp_order_rec.oe_header_id,
                 p_del_cancel_so_lines_tbl  =>l_del_cancel_so_lines_tbl
              );
            END IF;
        END IF;
        -- jaramana End
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
    --dbms_output.put_line('Exiting : validate_order_header');
END validate_order_header;

--------------------------------------------------------------------------------------------------------------
-- defaults values and populates unchanged fields in header record.
--------------------------------------------------------------------------------------------------------------
--Added the handling for vendor_contact_id, (?)Jerry 04/17/2005
--This procedure should be called after value to id conversion
PROCEDURE default_unchanged_order_header(
	p_x_osp_order_rec  IN OUT NOCOPY osp_order_rec_type
    ) IS

    -- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236 (Added the PO_REQ_HEADER_ID in the cursor below)
    CURSOR osp_order_csr(p_osp_order_id IN NUMBER, p_object_version_number IN NUMBER) IS
    SELECT  osp_order_number, order_type_code, single_instance_flag, po_header_id, oe_header_id,vendor_id, vendor_site_id,
        customer_id,order_date,contract_id,contract_terms,operating_unit_id, po_synch_flag, status_code,
        po_batch_id, po_request_id,po_agent_id, po_interface_header_id, po_req_header_id, description,attribute_category,
        attribute1,attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
        attribute10, attribute11, attribute12, attribute13, attribute14, attribute15, vendor_contact_id
    -- jaramana End
    FROM ahl_osp_orders_vl
    WHERE osp_order_id = p_osp_order_id
    AND object_version_number= p_object_version_number;
    l_osp_order_rec osp_order_rec_type;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.default_unchanged_order_header';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
        OPEN osp_order_csr(p_x_osp_order_rec.osp_order_id, p_x_osp_order_rec.object_version_number);
        -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236 (Added the PO_REQ_HEADER_ID in the rec below)
        FETCH osp_order_csr INTO l_osp_order_rec.osp_order_number, l_osp_order_rec.order_type_code,l_osp_order_rec.single_instance_flag,
         l_osp_order_rec.po_header_id, l_osp_order_rec.oe_header_id,l_osp_order_rec.vendor_id,
         l_osp_order_rec.vendor_site_id, l_osp_order_rec.customer_id, l_osp_order_rec.order_date,
         l_osp_order_rec.contract_id, l_osp_order_rec.contract_terms, l_osp_order_rec.operating_unit_id,
         l_osp_order_rec.po_synch_flag, l_osp_order_rec.status_code, l_osp_order_rec.po_batch_id, l_osp_order_rec.po_request_id,
         l_osp_order_rec.po_agent_id, l_osp_order_rec.po_interface_header_id, l_osp_order_rec.po_req_header_id, l_osp_order_rec.description,
         l_osp_order_rec.attribute_category,l_osp_order_rec.attribute1,l_osp_order_rec.attribute2,
         l_osp_order_rec.attribute3, l_osp_order_rec.attribute4, l_osp_order_rec.attribute5,
         l_osp_order_rec.attribute6, l_osp_order_rec.attribute7, l_osp_order_rec.attribute8,
         l_osp_order_rec.attribute9, l_osp_order_rec.attribute10, l_osp_order_rec.attribute11,
         l_osp_order_rec.attribute12, l_osp_order_rec.attribute13, l_osp_order_rec.attribute14,
         l_osp_order_rec.attribute15, l_osp_order_rec.vendor_contact_id;
         -- jaramana End
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'osp_order_id='||p_x_osp_order_rec.osp_order_id|| 'ovn='||p_x_osp_order_rec.object_version_number);
        END IF;
        IF (osp_order_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INVOP_OSP_NFOUND');
            FND_MSG_PUB.ADD;
        ELSE
            --dbms_output.put_line('l_osp_order_rec.osp_order_number ' || l_osp_order_rec.osp_order_number);
            IF (p_x_osp_order_rec.osp_order_number IS NULL) THEN
                p_x_osp_order_rec.osp_order_number := l_osp_order_rec.osp_order_number;
            ELSIF(p_x_osp_order_rec.osp_order_number = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.osp_order_number := null;
            END IF;
             IF (p_x_osp_order_rec.order_type_code IS NULL) THEN
                p_x_osp_order_rec.order_type_code := l_osp_order_rec.order_type_code;
            ELSIF(p_x_osp_order_rec.order_type_code = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.order_type_code := null;
            END IF;
             IF (p_x_osp_order_rec.single_instance_flag IS NULL) THEN
                p_x_osp_order_rec.single_instance_flag := l_osp_order_rec.single_instance_flag;
            ELSIF(p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.single_instance_flag := null;
            END IF;
            IF (p_x_osp_order_rec.po_header_id IS NULL) THEN
                p_x_osp_order_rec.po_header_id := l_osp_order_rec.po_header_id;
            ELSIF(p_x_osp_order_rec.po_header_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_header_id := null;
            END IF;
            IF (p_x_osp_order_rec.oe_header_id IS NULL) THEN
                p_x_osp_order_rec.oe_header_id := l_osp_order_rec.oe_header_id;
            ELSIF(p_x_osp_order_rec.oe_header_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.oe_header_id := null;
            END IF;
            IF (p_x_osp_order_rec.vendor_id IS NULL) THEN
                p_x_osp_order_rec.vendor_id := l_osp_order_rec.vendor_id;
            ELSIF(p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.vendor_id := null;
            END IF;
            IF (p_x_osp_order_rec.vendor_site_id IS NULL) THEN
                p_x_osp_order_rec.vendor_site_id := l_osp_order_rec.vendor_site_id;
            ELSIF(p_x_osp_order_rec.vendor_site_id = FND_API.G_MISS_NUM) THEN
              p_x_osp_order_rec.vendor_site_id := null;
            END IF;
            IF (p_x_osp_order_rec.customer_id IS NULL) THEN
                p_x_osp_order_rec.customer_id := l_osp_order_rec.customer_id;
            ELSIF(p_x_osp_order_rec.customer_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.customer_id := null;
            END IF;
            IF (p_x_osp_order_rec.order_date IS NULL) THEN
                p_x_osp_order_rec.order_date := l_osp_order_rec.order_date;
            ELSIF(p_x_osp_order_rec.order_date = FND_API.G_MISS_DATE) THEN
                p_x_osp_order_rec.order_date := null;
            END IF;
            IF (p_x_osp_order_rec.contract_id IS NULL) THEN
                p_x_osp_order_rec.contract_id := l_osp_order_rec.contract_id;
            ELSIF(p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.contract_id := null;
            END IF;
            IF (p_x_osp_order_rec.contract_terms IS NULL) THEN
                p_x_osp_order_rec.contract_terms := l_osp_order_rec.contract_terms;
            ELSIF(p_x_osp_order_rec.contract_terms = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.contract_terms := null;
            END IF;
            IF (p_x_osp_order_rec.operating_unit_id IS NULL) THEN
                p_x_osp_order_rec.operating_unit_id := l_osp_order_rec.operating_unit_id;
            ELSIF(p_x_osp_order_rec.operating_unit_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.operating_unit_id := null;
            END IF;
            IF (p_x_osp_order_rec.po_synch_flag IS NULL) THEN
                p_x_osp_order_rec.po_synch_flag := l_osp_order_rec.po_synch_flag;
            ELSIF(p_x_osp_order_rec.po_synch_flag = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.po_synch_flag := null;
            END IF;
            IF (p_x_osp_order_rec.status_code IS NULL) THEN
                p_x_osp_order_rec.status_code := l_osp_order_rec.status_code;
            ELSIF(p_x_osp_order_rec.status_code = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.status_code := null;
            END IF;
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                    'batch_id='||p_x_osp_order_rec.po_batch_id||
                    'request_id='||p_x_osp_order_rec.po_request_id||
                    'interface_id='||p_x_osp_order_rec.po_interface_header_id);
              END IF;
            IF (p_x_osp_order_rec.po_batch_id IS NULL) THEN
                p_x_osp_order_rec.po_batch_id := l_osp_order_rec.po_batch_id;
            ELSIF(p_x_osp_order_rec.po_batch_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_batch_id := null;
            END IF;
            IF (p_x_osp_order_rec.po_request_id IS NULL) THEN
                p_x_osp_order_rec.po_request_id := l_osp_order_rec.po_request_id;
            ELSIF(p_x_osp_order_rec.po_request_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_request_id := null;
            END IF;
            IF (p_x_osp_order_rec.po_agent_id IS NULL) THEN
                p_x_osp_order_rec.po_agent_id := l_osp_order_rec.po_agent_id;
            ELSIF(p_x_osp_order_rec.po_agent_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_agent_id := null;
            END IF;
            IF (p_x_osp_order_rec.po_interface_header_id IS NULL) THEN
                p_x_osp_order_rec.po_interface_header_id := l_osp_order_rec.po_interface_header_id;
            ELSIF(p_x_osp_order_rec.po_interface_header_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_interface_header_id := null;
            END IF;
            -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
            IF (p_x_osp_order_rec.po_req_header_id IS NULL) THEN
                p_x_osp_order_rec.po_req_header_id := l_osp_order_rec.po_req_header_id;
            ELSIF(p_x_osp_order_rec.po_req_header_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.po_req_header_id := null;
            END IF;
            -- jaramana End
            IF (p_x_osp_order_rec.description IS NULL) THEN
                p_x_osp_order_rec.description := l_osp_order_rec.description;
            ELSIF(p_x_osp_order_rec.description = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.description := null;
            END IF;
            IF (p_x_osp_order_rec.attribute_category IS NULL) THEN
                p_x_osp_order_rec.attribute_category := l_osp_order_rec.attribute_category;
            ELSIF(p_x_osp_order_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute_category := null;
            END IF;
            IF (p_x_osp_order_rec.attribute1 IS NULL) THEN
                p_x_osp_order_rec.attribute1 := l_osp_order_rec.attribute1;
            ELSIF(p_x_osp_order_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute1 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute2 IS NULL) THEN
                p_x_osp_order_rec.attribute2 := l_osp_order_rec.attribute2;
            ELSIF(p_x_osp_order_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute2 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute3 IS NULL) THEN
                p_x_osp_order_rec.attribute3 := l_osp_order_rec.attribute3;
            ELSIF(p_x_osp_order_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute3 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute4 IS NULL) THEN
                p_x_osp_order_rec.attribute4 := l_osp_order_rec.attribute4;
            ELSIF(p_x_osp_order_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute4 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute5 IS NULL) THEN
                p_x_osp_order_rec.attribute5 := l_osp_order_rec.attribute5;
            ELSIF(p_x_osp_order_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute5 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute6 IS NULL) THEN
                p_x_osp_order_rec.attribute6 := l_osp_order_rec.attribute6;
            ELSIF(p_x_osp_order_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute6 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute7 IS NULL) THEN
                p_x_osp_order_rec.attribute7 := l_osp_order_rec.attribute7;
            ELSIF(p_x_osp_order_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute7 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute8 IS NULL) THEN
                p_x_osp_order_rec.attribute8 := l_osp_order_rec.attribute8;
            ELSIF(p_x_osp_order_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute8 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute9 IS NULL) THEN
                p_x_osp_order_rec.attribute9 := l_osp_order_rec.attribute9;
            ELSIF(p_x_osp_order_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute9 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute10 IS NULL) THEN
                p_x_osp_order_rec.attribute10 := l_osp_order_rec.attribute10;
            ELSIF(p_x_osp_order_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute10 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute11 IS NULL) THEN
                p_x_osp_order_rec.attribute11 := l_osp_order_rec.attribute11;
            ELSIF(p_x_osp_order_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute11 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute12 IS NULL) THEN
                p_x_osp_order_rec.attribute12 := l_osp_order_rec.attribute12;
            ELSIF(p_x_osp_order_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute12 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute13 IS NULL) THEN
                p_x_osp_order_rec.attribute13 := l_osp_order_rec.attribute13;
            ELSIF(p_x_osp_order_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute13 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute14 IS NULL) THEN
                p_x_osp_order_rec.attribute14 := l_osp_order_rec.attribute14;
            ELSIF(p_x_osp_order_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute14 := null;
            END IF;
            IF (p_x_osp_order_rec.attribute15 IS NULL) THEN
                p_x_osp_order_rec.attribute15 := l_osp_order_rec.attribute15;
            ELSIF(p_x_osp_order_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                p_x_osp_order_rec.attribute15 := null;
            END IF;
            IF (p_x_osp_order_rec.vendor_contact_id IS NULL) THEN
                p_x_osp_order_rec.vendor_contact_id := l_osp_order_rec.vendor_contact_id;
            ELSIF(p_x_osp_order_rec.vendor_contact_id = FND_API.G_MISS_NUM) THEN
                p_x_osp_order_rec.vendor_contact_id := null;
            END IF;
        END IF;
        CLOSE osp_order_csr;
    ELSIF (p_x_osp_order_rec.operation_flag = G_OP_CREATE) THEN
         IF(p_x_osp_order_rec.osp_order_number = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.osp_order_number := null;
         END IF;
         IF(p_x_osp_order_rec.order_type_code = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.order_type_code := null;
         END IF;
         IF(p_x_osp_order_rec.single_instance_flag = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.single_instance_flag := null;
         END IF;
         IF(p_x_osp_order_rec.po_header_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_header_id := null;
         END IF;
         IF(p_x_osp_order_rec.oe_header_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.oe_header_id := null;
         END IF;
         IF(p_x_osp_order_rec.vendor_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.vendor_id := null;
         END IF;
         IF(p_x_osp_order_rec.vendor_site_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.vendor_site_id := null;
         END IF;
         IF(p_x_osp_order_rec.customer_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.customer_id := null;
         END IF;
         IF(p_x_osp_order_rec.order_date = FND_API.G_MISS_DATE) THEN
            p_x_osp_order_rec.order_date := null;
         END IF;
         IF(p_x_osp_order_rec.contract_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.contract_id := null;
         END IF;
         IF(p_x_osp_order_rec.contract_terms = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.contract_terms := null;
         END IF;
         IF(p_x_osp_order_rec.operating_unit_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.operating_unit_id := null;
         END IF;
         IF(p_x_osp_order_rec.po_synch_flag = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.po_synch_flag := null;
         END IF;
         IF(p_x_osp_order_rec.status_code = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.status_code := null;
         END IF;
         IF(p_x_osp_order_rec.po_batch_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_batch_id := null;
         END IF;
         IF(p_x_osp_order_rec.po_request_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_request_id := null;
         END IF;
         IF(p_x_osp_order_rec.po_agent_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_agent_id := null;
         END IF;
         IF(p_x_osp_order_rec.po_interface_header_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_interface_header_id := null;
         END IF;
         -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
         IF(p_x_osp_order_rec.po_req_header_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.po_req_header_id := null;
         END IF;
         -- jaramana End
         IF(p_x_osp_order_rec.description = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.description := null;
         END IF;
         IF(p_x_osp_order_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute_category := null;
         END IF;
         IF(p_x_osp_order_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute1 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute2 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute3 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute4 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute5 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute6 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute7 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute8 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute9 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute10 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute11 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute12 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute13 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute14 := null;
         END IF;
         IF(p_x_osp_order_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
            p_x_osp_order_rec.attribute15 := null;
         END IF;
         IF(p_x_osp_order_rec.vendor_contact_id = FND_API.G_MISS_NUM) THEN
            p_x_osp_order_rec.vendor_contact_id := null;
         END IF;
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
    --dbms_output.put_line('Exiting : default_unchanged_order_header');
END default_unchanged_order_header;

-------------------------------------------------------------------------
PROCEDURE validate_workorder(
    p_workorder_id IN NUMBER
    )IS
    CURSOR val_workorder_id_csr(p_workorder_id IN NUMBER) IS
    --Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
    /*
    SELECT 'x' FROM ahl_workorders_osp_v
    WHERE workorder_id = p_workorder_id
    AND upper(department_class_code) = 'VENDOR'
    AND job_status_code = G_OSP_WO_RELEASED;
    */
    SELECT 'x'
    FROM ahl_workorders wo,
         wip_discrete_jobs wdj,
         bom_departments bmd,
         ahl_visits_b vst,
         ahl_visit_tasks_b vts,
         inv_organization_info_v org
   WHERE wo.workorder_id = p_workorder_id
     AND wo.master_workorder_flag = 'N'
     AND wo.visit_task_id = vts.visit_task_id
     AND vst.visit_id = vts.visit_id
     AND wdj.organization_id = vst.organization_id
     AND wdj.wip_entity_id = wo.wip_entity_id
     AND wdj.owning_department = bmd.department_id
     AND upper(bmd.department_class_code) = 'VENDOR'
     AND org.organization_id = vst.organization_id
     AND NVL (org.operating_unit, mo_global.get_current_org_id ()) = mo_global.get_current_org_id()
     AND wo.status_code = G_OSP_WO_RELEASED;

    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_workorder';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_workorder_id IS NOT NULL) THEN
       OPEN val_workorder_id_csr(p_workorder_id);
       FETCH val_workorder_id_csr INTO l_exist;
       IF(val_workorder_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_WO');
          FND_MESSAGE.Set_Token('WORKORDER_ID', p_workorder_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_workorder_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_workorder;

/*
--Commented by mpothuku on 27-Feb-06 as the following procs. are not being used anymore and the Perf Bug #4919164 --has been logged for some of the cursors in the procedures below

--------------------------------------------------------------------------------------------------------------
PROCEDURE validate_service_item(
    p_workorder_id IN NUMBER,
    p_service_item_id IN NUMBER,
    p_order_type_code IN VARCHAR2
    )IS
    CURSOR val_service_item_id_inv_csr(p_service_item_id IN VARCHAR2, p_workorder_id IN NUMBER) IS
    SELECT 'x' FROM mtl_system_items_kfv MTL, ahl_workorders_osp_v WO
    WHERE MTL.inventory_item_id = p_service_item_id
     AND MTL.enabled_flag = G_YES_FLAG
     AND MTL.inventory_item_flag = G_NO_FLAG
     AND MTL.stock_enabled_flag = G_NO_FLAG
     AND NVL(MTL.start_date_active, SYSDATE - 1) <= SYSDATE
     AND NVL(MTL.end_date_active, SYSDATE + 1) > SYSDATE
     AND MTL.purchasing_enabled_flag = G_YES_FLAG
     AND NVL(outside_operation_flag, G_NO_FLAG) = G_NO_FLAG
     AND MTL.organization_id = WO.organization_id
     AND WO.workorder_id = p_workorder_id;
    CURSOR val_service_item_id_wo_csr(p_workorder_id IN NUMBER, p_service_item_id IN NUMBER) IS
    SELECT 'x' from ahl_workorders_osp_v
    WHERE workorder_id = p_workorder_id
     AND NVL(service_item_id,p_service_item_id) = p_service_item_id;
     CURSOR val_service_item_id_nll_csr(p_workorder_id IN NUMBER) IS
     SELECT 'x' from ahl_workorders_osp_v
     WHERE workorder_id = p_workorder_id
     AND service_item_id IS NULL;

     CURSOR item_exists_in_wo_org_csr(p_workorder_id IN NUMBER) IS
     SELECT 'x'
     from ahl_workorders_osp_v wo, ahl_mtl_items_ou_v mtl
     where wo.workorder_id = p_workorder_id and
     wo.service_item_id = mtl.inventory_item_id and
     mtl.inventory_org_id = wo.organization_id;
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_service_item';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_service_item_id IS NOT NULL AND p_service_item_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_service_item_id_inv_csr(p_service_item_id, p_workorder_id);
       FETCH val_service_item_id_inv_csr INTO l_exist;
       IF(val_service_item_id_inv_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM');
          FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
          FND_MSG_PUB.ADD;
          --dbms_output.put_line('Invalid service item not in inventory');
       ELSE
          -- Valid service item, exists in WO Org
          IF ( p_order_type_code = G_OSP_ORDER_TYPE_SERVICE) THEN   -- item exchange enhancement
             OPEN val_service_item_id_wo_csr(p_workorder_id, p_service_item_id);
             FETCH val_service_item_id_wo_csr INTO l_exist;
             IF(val_service_item_id_wo_csr%NOTFOUND) THEN
                -- Service Item does not match that in WO
                OPEN item_exists_in_wo_org_csr(p_workorder_id);
                FETCH item_exists_in_wo_org_csr INTO l_exist;
                IF (item_exists_in_wo_org_csr%FOUND) THEN
                   -- WO Service Item does exist in WO Org. So, should have matched!
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM_MISWO');
                   FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
                   FND_MSG_PUB.ADD;
                   --dbms_output.put_line('Invalid service item , does not match in wo');
                ELSE
                   -- WO Service Item does not exist in WO Org.
                   -- So, a mismatch is OK
                   null;
                END IF;
                CLOSE item_exists_in_wo_org_csr;
              END IF;
             CLOSE val_service_item_id_wo_csr;
           END IF;
       END IF;
       CLOSE val_service_item_id_inv_csr;
    ELSE
       -- Service item is null
       IF ( p_order_type_code = G_OSP_ORDER_TYPE_SERVICE) THEN --item exchange enhancement
          OPEN val_service_item_id_nll_csr(p_workorder_id);
          FETCH val_service_item_id_nll_csr INTO l_exist;
          IF(val_service_item_id_nll_csr%NOTFOUND) THEN
             -- Work order has a not null service item
             OPEN item_exists_in_wo_org_csr(p_workorder_id);
             FETCH item_exists_in_wo_org_csr INTO l_exist;
             IF (item_exists_in_wo_org_csr%FOUND) THEN
                -- WO Service Item does exist in WO Org. So, should not have been null
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM_NLL');
                FND_MSG_PUB.ADD;
                --dbms_output.put_line('Passed service item is null, in wo its not null');
             ELSE
                -- WO Service Item does not exist in WO Org.
                -- So, user entered value can be null
                null;
             END IF;
             CLOSE item_exists_in_wo_org_csr;
          END IF;
          CLOSE val_service_item_id_nll_csr;
        END IF;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_service_item;

--------------------------------------------------------------------------------------------------------------
PROCEDURE validate_service_item_desc(
    p_service_item_id IN NUMBER,
    p_service_item_description IN VARCHAR2
    ) IS
    CURSOR val_service_item_desc_csr(p_service_item_id IN VARCHAR2, p_service_item_description IN VARCHAR2) IS
    SELECT 'x' FROM mtl_system_items_kfv MTL
    WHERE MTL.inventory_item_id = p_service_item_id
    AND MTL.DESCRIPTION = p_service_item_description;
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_service_item_desc';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_service_item_id IS NOT NULL AND p_service_item_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_service_item_desc_csr(p_service_item_id , p_service_item_description);
       FETCH val_service_item_desc_csr INTO l_exist;
       IF(val_service_item_desc_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM_DESC');
          FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
          FND_MESSAGE.Set_Token('SERVICE_ITEM_DESC', p_service_item_description);
          FND_MSG_PUB.ADD;
          --dbms_output.put_line('Invalid service item description');
       END IF;
       CLOSE val_service_item_desc_csr;
     END IF;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_service_item_desc;

--------------------------------------------------------------------------------------------------------------
*/
-- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
PROCEDURE val_svc_item_vs_wo_svc_item(
    p_workorder_id IN NUMBER,
    p_service_item_id IN NUMBER
    )IS
    CURSOR val_service_item_id_inv_csr(p_service_item_id IN VARCHAR2, p_workorder_id IN NUMBER) IS
    SELECT 'x' FROM mtl_system_items_kfv MTL, ahl_workorders WO, AHL_VISITS_B VST
    WHERE MTL.inventory_item_id = p_service_item_id
     AND MTL.enabled_flag = G_YES_FLAG
     AND MTL.inventory_item_flag = G_NO_FLAG
     AND MTL.stock_enabled_flag = G_NO_FLAG
     AND NVL(MTL.start_date_active, SYSDATE - 1) <= SYSDATE
     AND NVL(MTL.end_date_active, SYSDATE + 1) > SYSDATE
     AND MTL.purchasing_enabled_flag = G_YES_FLAG
     AND NVL(outside_operation_flag, G_NO_FLAG) = G_NO_FLAG
     AND MTL.organization_id = VST.organization_id
     AND VST.visit_id = WO.visit_id
     AND WO.workorder_id = p_workorder_id;

    CURSOR val_service_item_id_wo_csr(p_workorder_id IN NUMBER, p_service_item_id IN NUMBER) IS
    SELECT 'x' from ahl_workorders WO, AHL_ROUTES_B ARB
    WHERE WO.workorder_id = p_workorder_id
     AND WO.ROUTE_ID = ARB.ROUTE_ID (+)
     AND NVL(ARB.service_item_id, p_service_item_id) = p_service_item_id;

    CURSOR val_service_item_id_nll_csr(p_workorder_id IN NUMBER) IS
    SELECT 'x' from ahl_workorders WO, AHL_ROUTES_B ARB
    WHERE WO.workorder_id = p_workorder_id
     AND WO.ROUTE_ID = ARB.ROUTE_ID (+)
     AND ARB.service_item_id IS NULL;

    CURSOR item_exists_in_wo_org_csr(p_workorder_id IN NUMBER) IS
    SELECT 'x'
    from ahl_workorders WO, AHL_ROUTES_B ARB, AHL_VISITS_B VST, ahl_mtl_items_ou_v mtl
    where wo.workorder_id = p_workorder_id and
     WO.ROUTE_ID = ARB.ROUTE_ID (+) and
     ARB.service_item_id = mtl.inventory_item_id and
     VST.visit_id = WO.visit_id and
     mtl.inventory_org_id = VST.organization_id;

    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.val_svc_item_vs_wo_svc_item';

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_service_item_id IS NOT NULL AND p_service_item_id <> FND_API.G_MISS_NUM) THEN

      OPEN val_service_item_id_inv_csr(p_service_item_id, p_workorder_id);
      FETCH val_service_item_id_inv_csr INTO l_exist;
      IF(val_service_item_id_inv_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_LN_INV_SVC_ITEM');
        FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Invalid service item not in inventory');
      ELSE
        -- Valid service item, exists in WO Org
         OPEN val_service_item_id_wo_csr(p_workorder_id, p_service_item_id);
         FETCH val_service_item_id_wo_csr INTO l_exist;
         IF(val_service_item_id_wo_csr%NOTFOUND) THEN
            -- Service Item does not match that in WO
            OPEN item_exists_in_wo_org_csr(p_workorder_id);
            FETCH item_exists_in_wo_org_csr INTO l_exist;
            IF (item_exists_in_wo_org_csr%FOUND) THEN
               -- WO Service Item does exist in WO Org. So, should have matched!
               FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_LN_INV_SVC_ITEM_MISWO');
               FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
               FND_MSG_PUB.ADD;
               --dbms_output.put_line('Invalid service item , does not match in wo');
            ELSE
               -- WO Service Item does not exist in WO Org.
               -- So, a mismatch is OK
               null;
            END IF;
            CLOSE item_exists_in_wo_org_csr;
          END IF;
         CLOSE val_service_item_id_wo_csr;
       END IF;
      CLOSE val_service_item_id_inv_csr;

    ELSE
      -- Service item is null
      OPEN val_service_item_id_nll_csr(p_workorder_id);
      FETCH val_service_item_id_nll_csr INTO l_exist;
      IF(val_service_item_id_nll_csr%NOTFOUND) THEN
         -- Work order has a not null service item
         OPEN item_exists_in_wo_org_csr(p_workorder_id);
         FETCH item_exists_in_wo_org_csr INTO l_exist;
         IF (item_exists_in_wo_org_csr%FOUND) THEN
            -- WO Service Item does exist in WO Org. So, should not have been null
            FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_LN_INV_SVC_ITEM_NLL');
            FND_MSG_PUB.ADD;
            --dbms_output.put_line('Passed service item is null, in wo its not null');
         ELSE
            -- WO Service Item does not exist in WO Org.
            -- So, user entered value can be null
            null;
         END IF;
         CLOSE item_exists_in_wo_org_csr;
      END IF;
      CLOSE val_service_item_id_nll_csr;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END val_svc_item_vs_wo_svc_item;

--------------------------------------------------------------------------------------------------------------

--p_org_id added by mpothuku to fix the Perf Bug #4919164
PROCEDURE validate_service_item_uom(
   p_service_item_id IN NUMBER,
   p_service_item_uom_code IN VARCHAR2,
   p_org_id IN NUMBER
   )IS
   CURSOR val_service_item_uom_csr(p_service_item_id IN NUMBER,p_service_item_uom_code IN VARCHAR2, p_org_id IN NUMBER ) IS
   SELECT 'x' FROM ahl_item_class_uom_v
   WHERE inventory_item_id = p_service_item_id
   AND uom_code = p_service_item_uom_code
   AND inventory_org_id = p_org_id;
   CURSOR val_uom_code_csr(p_service_item_uom_code IN VARCHAR2) IS
   SELECT 'x' from mtl_units_of_measure_vl
   WHERE uom_code = p_service_item_uom_code;
   l_exist VARCHAR2(1);
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_service_item_uom';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure'
                      || '- Service Item Id: ' || p_service_item_id || 'uom_code' || p_service_item_uom_code );
    END IF;
    IF(p_service_item_id IS NOT NULL AND p_service_item_id <> FND_API.G_MISS_NUM) THEN
       IF(p_service_item_uom_code IS NOT NULL AND p_service_item_uom_code <> FND_API.G_MISS_CHAR) THEN
          OPEN val_service_item_uom_csr(p_service_item_id,p_service_item_uom_code,p_org_id);
          FETCH val_service_item_uom_csr INTO l_exist;
          IF(val_service_item_uom_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_UOM');
            FND_MESSAGE.Set_Token('UOM_CODE', p_service_item_uom_code);
           -- FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
            FND_MSG_PUB.ADD;
          END IF;
          CLOSE val_service_item_uom_csr;
        END IF;
    ELSE
        IF(p_service_item_uom_code IS NOT NULL AND p_service_item_uom_code <> FND_API.G_MISS_CHAR) THEN
           OPEN val_uom_code_csr(p_service_item_uom_code);
           FETCH val_uom_code_csr INTO l_exist;
           IF(val_uom_code_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_UOM');
             FND_MESSAGE.Set_Token('UOM_CODE', p_service_item_uom_code);
           --  FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
             FND_MSG_PUB.ADD;
           END IF;
           CLOSE val_uom_code_csr;
        END IF;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_service_item_uom;

--------------------------------------------------------------------------------------------------------------
PROCEDURE validate_po_line_type(
   p_po_line_type_id IN NUMBER
   )IS
   CURSOR val_po_line_type_id_csr(p_po_line_type_id IN NUMBER) IS
   SELECT 'x' FROM po_line_types
   WHERE line_type_id = p_po_line_type_id and
   ORDER_TYPE_LOOKUP_CODE = 'QUANTITY' and
   NVL(OUTSIDE_OPERATION_FLAG, G_NO_FLAG) = G_NO_FLAG;
   l_exist VARCHAR2(1);
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_po_line_type';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_po_line_type_id IS NOT NULL AND p_po_line_type_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_po_line_type_id_csr(p_po_line_type_id);
       FETCH val_po_line_type_id_csr INTO l_exist;
       IF(val_po_line_type_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_LNTYP_ID');
          FND_MESSAGE.Set_Token('LINE_TYPE_ID', p_po_line_type_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_po_line_type_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_po_line_type;

--------------------------------------------------------------------------------------------------------------
PROCEDURE validate_po_line(
   p_po_line_id IN NUMBER,
   p_osp_order_id IN NUMBER
   )IS
   CURSOR val_po_line_id_csr(p_po_line_id IN NUMBER, p_osp_order_id IN NUMBER) IS
   SELECT 'x' FROM po_lines_all POL, ahl_osp_orders_b OO
    WHERE POL.po_line_id = p_po_line_id
    AND OO.osp_order_id = p_osp_order_id
    AND POL.PO_HEADER_ID = OO.po_header_id
    -- Added by jaramana on January 9, 2008 to fix the Bug 5358438/5967633
    AND NVL(POL.CANCEL_FLAG, 'N') <> 'Y'
    --the line_id should not have already been associated to the same osp order
    AND NOT EXISTS (select 1 from ahl_osp_order_lines
                     where osp_order_id = p_osp_order_id
                       and po_line_id = p_po_line_id );
    -- jaramana End
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_po_line';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_po_line_id IS NOT NULL AND p_po_line_id <> FND_API.G_MISS_NUM) THEN
       OPEN val_po_line_id_csr(p_po_line_id, p_osp_order_id);
       FETCH val_po_line_id_csr INTO l_exist;
       IF(val_po_line_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PO_LINE_INV');
          FND_MESSAGE.Set_Token('PO_LINE_ID', p_po_line_id);
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE val_po_line_id_csr;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END validate_po_line;

-------------------------------------------------------------------------------------------------------------
PROCEDURE validate_exchange_instance_id(p_exchange_instance_id IN NUMBER) IS
    CURSOR val_instance_id_csr(p_instance_id IN NUMBER) IS
      SELECT 'x' FROM csi_item_instances csi
        WHERE instance_id = p_instance_id
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
          AND NOT EXISTS (select subject_id from csi_ii_relationships where
                           subject_id = p_instance_id and
                           relationship_type_code = 'COMPONENT-OF' and
                           trunc(sysdate) >= trunc(nvl(active_start_date,sysdate)) and
                           trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                          ) ;
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_exchange_instance_id';
BEGIN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
     END IF;
     IF(p_exchange_instance_id IS NOT NULL AND p_exchange_instance_id <> FND_API.G_MISS_NUM) THEN
        OPEN val_instance_id_csr(p_exchange_instance_id);
        FETCH val_instance_id_csr INTO l_exist;
        IF (val_instance_id_csr %NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INSTANCE_ID_INV');
          FND_MESSAGE.Set_Token('EXCHANGE_INSTANCE_ID', p_exchange_instance_id);
          FND_MSG_PUB.ADD;
        END IF;
      END IF;
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
      END IF;
END validate_exchange_instance_id;


/*
- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236 (We are not using this procedure anymore):
Commented the nullify_exchange_instance procedure and placed it at the end of package. Please note that instead of using this
heavy weight procedure we are directly updating the AHL_OSP_ORDER_LINES table
*/

--------------------------------------------------------------------------------------------------------------
-- Jerry made minor changes to this procedure for ISO in May 27, 2005
-- Basically, just replace g_old_status_code with l_old_status_code which
-- is queried on the fly
--------------------------------------------------------------------------------------------------------------
PROCEDURE process_order_status_change(
   p_x_osp_order_rec IN OUT NOCOPY osp_order_rec_type)
IS
   CURSOR val_order_has_lines(p_osp_order_id IN NUMBER)IS
   SELECT 'x' FROM ahl_osp_order_lines
   WHERE osp_order_id = p_osp_order_id;
   l_exist VARCHAR2(1);
   CURSOR val_order_has_ship_lines(p_osp_order_id IN NUMBER)IS
   SELECT oe_ship_line_id, oe_return_line_id, osp_line_number FROM ahl_osp_order_lines
   WHERE osp_order_id = p_osp_order_id;
   l_oe_ship_line_id NUMBER;
   l_oe_return_line_id NUMBER;
   l_line_number NUMBER;
   l_count NUMBER;
   l_batch_id NUMBER;
   l_request_id NUMBER;
   l_interface_header_id NUMBER;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(1000);
   l_shipment_IDs_Tbl       AHL_OSP_SHIPMENT_PUB.Ship_ID_Tbl_Type;
   CURSOR val_all_wo_closed(p_osp_order_id IN NUMBER) IS
   --Modified by mpothuku on 27-Feb-06 to use ahl_workorders instead of ahl_workorders_osp_v
   --to fix the Perf Bug #4919164
   SELECT 'x' from ahl_osp_order_lines OL, ahl_workorders WO
   WHERE OL.osp_order_id = p_osp_order_id
   AND OL.workorder_id = WO.workorder_id
   AND OL.status_code IS NULL
   AND WO.status_code NOT IN(G_OSP_WO_CANCELLED,G_OSP_WO_CLOSED);
   CURSOR val_order_lines_csr(p_osp_order_id IN NUMBER) IS
   SELECT osp_line_number, service_item_id, service_item_description, service_item_uom_code, quantity, need_by_date, po_line_type_id
   FROM AHL_OSP_ORDER_LINES
   WHERE osp_order_id = p_osp_order_id
   ORDER BY osp_line_number;
   CURSOR get_old_status IS
     SELECT status_code, object_version_number
       FROM ahl_osp_orders_b
      WHERE osp_order_id = p_x_osp_order_rec.osp_order_id;

   l_osp_line_number  NUMBER;
   l_service_item_id  NUMBER;
   l_service_item_description VARCHAR(2000);
   l_service_item_uom_code VARCHAR(30);
   l_quantity   NUMBER;
   l_need_by_date DATE;
   l_po_line_type_id NUMBER;
   l_old_status_code VARCHAR2(30);
   l_temp_status_code VARCHAR2(30);
   l_new_ovn NUMBER;
   l_old_ovn NUMBER;
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'process_order_status_change';
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                    'osp_order_id='||p_x_osp_order_rec.osp_order_id||
                    'status='||p_x_osp_order_rec.status_code||
                    'ovn='||p_x_osp_order_rec.object_version_number);
   END IF;
   OPEN get_old_status;
   FETCH get_old_status INTO l_old_status_code, l_old_ovn;
   CLOSE get_old_status;
   IF(p_x_osp_order_rec.order_type_code IN (G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE) AND p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
      --IF(g_old_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS) AND
      -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
      IF(l_old_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS) AND
         p_x_osp_order_rec.status_code IN (G_OSP_SUBMITTED_STATUS, G_OSP_REQ_SUBMITTED_STATUS)) THEN
      -- jaramana End
         -- validate fields and submit for PO creation
         IF(p_x_osp_order_rec.vendor_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_VEN_NLL');
            FND_MSG_PUB.ADD;
         END IF;
         IF (p_x_osp_order_rec.vendor_site_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_VENST_NLL');
            FND_MSG_PUB.ADD;
         END IF;
         IF (p_x_osp_order_rec.po_agent_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_BUYER_NLL');
            FND_MSG_PUB.ADD;
         END IF;
         IF (p_x_osp_order_rec.po_header_id IS NOT NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_PO_NNLL');
            FND_MSG_PUB.ADD;
         END IF;

         -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
         IF (p_x_osp_order_rec.po_req_header_id IS NOT NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_REQ_NNLL');
            FND_MSG_PUB.ADD;
         END IF;
         -- jaramana End

         -- check whether order has lines
         OPEN val_order_has_lines(p_x_osp_order_rec.osp_order_id);
         FETCH val_order_has_lines INTO l_exist;
         IF(val_order_has_lines%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_NO_LNS');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE val_order_has_lines;
          -- check null values in order lines
          OPEN val_order_lines_csr(p_x_osp_order_rec.osp_order_id);
          LOOP
            FETCH val_order_lines_csr INTO l_osp_line_number, l_service_item_id, l_service_item_description,
                                           l_service_item_uom_code, l_quantity, l_need_by_date, l_po_line_type_id;
             EXIT WHEN  val_order_lines_csr%NOTFOUND;
              --service item id and service item description cannot be both null
             IF(l_service_item_description IS NULL  AND l_service_item_id IS NULL) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_ITMID_NL');
               FND_MESSAGE.Set_Token('LINE_NUM', l_osp_line_number);
               FND_MSG_PUB.ADD;
             END IF;
             --l_service_item_uom_code cannot be null
             IF(l_service_item_uom_code IS NULL) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_UOM_NL');
               FND_MESSAGE.Set_Token('LINE_NUM', l_osp_line_number);
               FND_MSG_PUB.ADD;
             END IF;
             --quantity cannot be null
             IF(l_quantity IS NULL) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_QTY_NL');
               FND_MESSAGE.Set_Token('LINE_NUM', l_osp_line_number);
               FND_MSG_PUB.ADD;
             END IF;
             --need_by_date cannot be null
             IF(l_need_by_date IS NULL) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_NBD_NL');
               FND_MESSAGE.Set_Token('LINE_NUM', l_osp_line_number);
               FND_MSG_PUB.ADD;
             END IF;
             --po_line_type_id cannot be null
             IF(l_po_line_type_id IS NULL) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_PO_LNTYP_NL');
               FND_MESSAGE.Set_Token('LINE_NUM', l_osp_line_number);
               FND_MSG_PUB.ADD;
             END IF;
         END LOOP;
         CLOSE val_order_lines_csr;
         IF FND_MSG_PUB.count_msg > 0 THEN
            RAISE  FND_API.G_EXC_ERROR;
         -- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236
         ELSIF(p_x_osp_order_rec.status_code =  G_OSP_SUBMITTED_STATUS) THEN
         -- jaramana End
            -- submit for PO creation
            AHL_OSP_PO_PVT.Create_Purchase_Order
            (
             p_api_version   => 1.0 ,
             p_osp_order_id  => p_x_osp_order_rec.osp_order_id,
             x_batch_id      => l_batch_id,
             x_request_id    => l_request_id,
             x_interface_header_id  =>l_interface_header_id,
             x_return_status => l_return_status,
             x_msg_count  => l_msg_count,
             x_msg_data  => l_msg_data
            );
            OPEN get_old_status;
            FETCH get_old_status INTO l_temp_status_code, l_new_ovn;
            CLOSE get_old_status;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS OR
                l_new_ovn <> l_old_ovn+1) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_PO_FLD');
              FND_MSG_PUB.ADD;
            ELSE
              p_x_osp_order_rec.object_version_number := l_new_ovn;
              p_x_osp_order_rec.po_request_id := l_request_id;
              p_x_osp_order_rec.po_interface_header_id := l_interface_header_id;
              p_x_osp_order_rec.po_batch_id := l_batch_id;
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                    'batch_id='||p_x_osp_order_rec.po_batch_id||
                    'request_id='||p_x_osp_order_rec.po_request_id||
                    'interface_id='||p_x_osp_order_rec.po_interface_header_id);
              END IF;
            END IF;
          -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
          ELSIF(p_x_osp_order_rec.status_code = G_OSP_REQ_SUBMITTED_STATUS) THEN
            -- submit for PO creation
            AHL_OSP_PO_REQ_PVT.Create_PO_Requisition
            (
             p_api_version   => 1.0 ,
             p_osp_order_id  => p_x_osp_order_rec.osp_order_id,
             x_batch_id      => l_batch_id,
             x_request_id    => l_request_id,
             x_return_status => l_return_status,
             x_msg_count  => l_msg_count,
             x_msg_data  => l_msg_data
            );
            OPEN get_old_status;
            FETCH get_old_status INTO l_temp_status_code, l_new_ovn;
            CLOSE get_old_status;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS OR
                l_new_ovn <> l_old_ovn+1) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_REQ_FLD');
              FND_MSG_PUB.ADD;
            ELSE
              p_x_osp_order_rec.object_version_number := l_new_ovn;
              p_x_osp_order_rec.po_request_id := l_request_id;
              p_x_osp_order_rec.po_batch_id := l_batch_id;
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                    'batch_id='||p_x_osp_order_rec.po_batch_id||
                    'request_id='||p_x_osp_order_rec.po_request_id);
              END IF;
            END IF;
          -- jaramana End

         END IF;
      --ELSIF(g_old_status_code = G_OSP_PO_CREATED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN
      -- Changed by jaramana on January 9, 2008 for the Requisition ER 6034236
      --ELSIF(l_old_status_code = G_OSP_PO_CREATED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN
      ELSIF(l_old_status_code IN (G_OSP_PO_CREATED_STATUS,G_OSP_REQ_CREATED_STATUS) AND p_x_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN

         -- validate fields and ask whether PO and SO is closed.
         IF(l_old_status_code = G_OSP_PO_CREATED_STATUS AND p_x_osp_order_rec.po_header_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_PO_NLL');
            FND_MSG_PUB.ADD;
         ELSIF(l_old_status_code = G_OSP_REQ_CREATED_STATUS AND p_x_osp_order_rec.po_req_header_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_REQ_NLL');
            FND_MSG_PUB.ADD;
         ELSE --This would mean either po_header_id is not null OR po_req_header_id is not NULL
            -- If the status is PO_CREATED, ask PO whether it is closed/cancelled.
            IF (l_old_status_code = G_OSP_PO_CREATED_STATUS AND
            AHL_OSP_PO_PVT.Is_PO_Closed(p_x_osp_order_rec.po_header_id) = G_NO_FLAG ) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_PO_OPEN');
              FND_MSG_PUB.ADD;
            END IF;
            -- If the status is REQ_CREATED, ask Requisition whether the order can be closed.
            IF(l_old_status_code = G_OSP_REQ_CREATED_STATUS AND
            AHL_OSP_PO_REQ_PVT.Is_PO_Req_Closed(p_x_osp_order_rec.po_req_header_id) = G_NO_FLAG ) THEN
              FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_INV_CL_REQ_OPEN');
              FND_MSG_PUB.ADD;
            END IF;

            -- ask SO whether can close
            IF(p_x_osp_order_rec.oe_header_id IS NOT NULL) THEN
              IF NOT(FND_API.TO_BOOLEAN(AHL_OSP_SHIPMENT_PUB.Is_Order_Header_Closed( p_x_osp_order_rec.oe_header_id))) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_SO_OPEN');
                FND_MSG_PUB.ADD;
              END IF;
            END IF;
            -- check whether all the workorders are closed.
            OPEN val_all_wo_closed(p_x_osp_order_rec.osp_order_id);
            FETCH val_all_wo_closed INTO l_exist;
            IF(val_all_wo_closed%FOUND) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_WO_OPEN');
               FND_MSG_PUB.ADD;
            END IF;
            CLOSE val_all_wo_closed;
         END IF;
      END IF;
    ELSIF(p_x_osp_order_rec.order_type_code IN(G_OSP_ORDER_TYPE_LOAN, G_OSP_ORDER_TYPE_BORROW) AND p_x_osp_order_rec.operation_flag = G_OP_UPDATE)THEN
      --IF(g_old_status_code = G_OSP_ENTERED_STATUS  AND
      IF(l_old_status_code = G_OSP_ENTERED_STATUS  AND
         p_x_osp_order_rec.status_code = G_OSP_SUBMITTED_STATUS) THEN
         IF(p_x_osp_order_rec.customer_id IS NULL AND p_x_osp_order_rec.order_type_code = G_OSP_ORDER_TYPE_LOAN) THEN
			--only loan type requires customer id for borrow it's optional (bug fix).
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_CUST_NLL');
            FND_MSG_PUB.ADD;
         END IF;
	/* Change made by mpothuku to make the contract_id optional on 12/16/04
	   This is a work around and has to be revoked after PM comes up with the Service Contract Integration
	*/
	-- Changes start
	/*
         IF(p_x_osp_order_rec.contract_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_CTRCT_NLL');
            FND_MSG_PUB.ADD;
         END IF;
	*/
	-- Changes by mpothuku End
         IF(p_x_osp_order_rec.oe_header_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_OE_NLL');
            FND_MSG_PUB.ADD;
         END IF;
         -- check whether order has lines and all lines have shipping information
         OPEN val_order_has_ship_lines(p_x_osp_order_rec.osp_order_id);
         l_count := 0;
         LOOP
           FETCH val_order_has_ship_lines INTO l_oe_ship_line_id, l_oe_return_line_id, l_line_number;
           IF(val_order_has_ship_lines%NOTFOUND) THEN
             EXIT;
           ELSIF (l_oe_ship_line_id IS NULL AND  l_oe_return_line_id IS NULL) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_NO_SHIP_LN');
              FND_MESSAGE.Set_Token('LINE_NUMBER', l_line_number);
              FND_MSG_PUB.ADD;
              l_count := l_count + 1;
           ELSE
              l_count := l_count + 1;
           END IF;
         END LOOP;
         IF(l_count < 1) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_NO_LNS');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE val_order_has_ship_lines;
         IF FND_MSG_PUB.count_msg > 0 THEN
            RAISE  FND_API.G_EXC_ERROR;
         ELSE
            l_shipment_IDs_Tbl(1) := p_x_osp_order_rec.oe_header_id;
            AHL_OSP_SHIPMENT_PUB.Book_Order(
                       p_api_version      => 1.0,
                       p_init_msg_list    => FND_API.G_FALSE,
                       p_commit           => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                       p_oe_header_tbl    => l_shipment_IDs_Tbl,
                       x_return_status    => l_return_status,
                       x_msg_count        => l_msg_count,
                       x_msg_data         => l_msg_data
            );
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SUB_SO_FLD');
               FND_MSG_PUB.ADD;
            END IF;
         END IF;
      --ELSIF(g_old_status_code = G_OSP_SUBMITTED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN
      ELSIF(l_old_status_code = G_OSP_SUBMITTED_STATUS AND p_x_osp_order_rec.status_code = G_OSP_CLOSED_STATUS) THEN
         -- validate fields and ask SO whether order can be closed.
         --dbms_output.put_line('Sales order closed ');
         IF(p_x_osp_order_rec.oe_header_id IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_OE_NLL');
            FND_MSG_PUB.ADD;
         ELSE
            --dbms_output.put_line('Sales order closed ' || AHL_OSP_SHIPMENT_PUB.Is_Order_Header_Closed( p_x_osp_order_rec.oe_header_id));
            IF NOT(FND_API.TO_BOOLEAN(AHL_OSP_SHIPMENT_PUB.Is_Order_Header_Closed( p_x_osp_order_rec.oe_header_id))) THEN
              --dbms_output.put_line('Sales order is not closed');
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_SO_OPEN');
              FND_MSG_PUB.ADD;
            END IF;
            -- check whether all the workorders are closed.
            OPEN val_all_wo_closed(p_x_osp_order_rec.osp_order_id);
            FETCH val_all_wo_closed INTO l_exist;
            IF(val_all_wo_closed%FOUND) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CL_WO_OPEN');
               FND_MSG_PUB.ADD;
            END IF;
            CLOSE val_all_wo_closed;
         END IF;
      END IF;
    END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END process_order_status_change;

--------------------------------------------------------------------------------------------------------------
PROCEDURE delete_cancel_so(
   p_oe_header_id             IN        NUMBER,
   p_del_cancel_so_lines_tbl  IN        del_cancel_so_lines_tbl_type,
   p_cancel_flag              IN        VARCHAR2  := FND_API.G_FALSE
) IS
  l_Ship_ID_Tbl AHL_OSP_SHIPMENT_PUB.Ship_ID_Tbl_Type;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(1000);
  CURSOR can_del_ship_line_csr(p_osp_order_id IN NUMBER, p_oe_ship_line_id IN NUMBER) IS
  SELECT 'x' FROM ahl_osp_order_lines
  WHERE osp_order_id = p_osp_order_id
  AND oe_ship_line_id = p_oe_ship_line_id
  AND status_code IS NULL;
  CURSOR can_del_return_line_csr(p_osp_order_id IN NUMBER, p_oe_return_line_id IN NUMBER) IS
  SELECT 'x' FROM ahl_osp_order_lines
  WHERE osp_order_id = p_osp_order_id
  AND oe_return_line_id = p_oe_return_line_id
  AND status_code IS NULL;
  CURSOR line_already_shipped_csr(p_oe_line_id IN NUMBER) IS
    SELECT 'x' from oe_order_lines_all
      where line_id = p_oe_line_id AND
            shipped_quantity > 0;
  l_exist VARCHAR2(1);
  l_index NUMBER := 1;
  l_unique_flag BOOLEAN := TRUE;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.delete_cancel_so';
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
   IF(p_oe_header_id IS NOT NULL) THEN
      -- CALL SO to delete/cancel SO
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling AHL_OSP_SHIPMENT_PUB.Delete_Cancel_Order with p_oe_header_id = ' || p_oe_header_id);
      END IF;
      AHL_OSP_SHIPMENT_PUB.Delete_Cancel_Order (
          p_api_version              => 1.0,
          p_oe_header_id             => p_oe_header_id,
          p_oe_lines_tbl             => l_Ship_ID_Tbl,
          p_cancel_flag              => p_cancel_flag,
          x_return_status            => l_return_status ,
          x_msg_count                => l_msg_count ,
          x_msg_data                 => l_msg_data
      );
      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SO_CAN_FLD');
         FND_MSG_PUB.ADD;
      END IF;
   ELSIF ( p_del_cancel_so_lines_tbl IS NOT NULL) THEN
      IF NOT(p_del_cancel_so_lines_tbl.COUNT > 0) THEN
       RETURN;
      END IF;
      FOR i IN p_del_cancel_so_lines_tbl.FIRST..p_del_cancel_so_lines_tbl.LAST  LOOP
          IF(p_del_cancel_so_lines_tbl(i).oe_ship_line_id IS NOT NULL) THEN
             IF(l_Ship_ID_Tbl.COUNT > 0) THEN
               l_unique_flag := TRUE;
               -- Check if this shipment line has already been included for deletion
               -- If so, set the l_unique_flag to false to prevent duplicates
               FOR j IN l_Ship_ID_Tbl.FIRST..l_Ship_ID_Tbl.LAST  LOOP
                 IF(l_Ship_ID_Tbl(j) = p_del_cancel_so_lines_tbl(i).oe_ship_line_id) THEN
                   l_unique_flag := FALSE;
                   EXIT;
                 END IF;
               END LOOP;
             END IF;
             IF(l_unique_flag) THEN
                -- Not a duplicate
                -- Check if there are any active OSP Lines for this Shipment
                OPEN can_del_ship_line_csr(p_del_cancel_so_lines_tbl(i).osp_order_id, p_del_cancel_so_lines_tbl(i).oe_ship_line_id);
                FETCH can_del_ship_line_csr INTO l_exist;
                IF(can_del_ship_line_csr%NOTFOUND) THEN
                   -- No other active OSP Line for this shipment
                   -- Check if the shipment has already occured
                   OPEN line_already_shipped_csr(p_del_cancel_so_lines_tbl(i).oe_ship_line_id);
                   FETCH line_already_shipped_csr INTO l_exist;
                   IF (line_already_shipped_csr%NOTFOUND) THEN
                     -- Line not yet shipped: Include for deletion
                     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Shipment line with id ' || p_del_cancel_so_lines_tbl(i).oe_ship_line_id || ' included for deletion/cancellation.');
                     END IF;
                     l_Ship_ID_Tbl(l_index) := p_del_cancel_so_lines_tbl(i).oe_ship_line_id;
                     l_index := l_index + 1;
                   END IF;
                   CLOSE line_already_shipped_csr;
                END IF;
                CLOSE can_del_ship_line_csr;
             END IF;
          END IF;
          IF(p_del_cancel_so_lines_tbl(i).oe_return_line_id IS NOT NULL) THEN
             IF(l_Ship_ID_Tbl.COUNT > 0) THEN
               l_unique_flag := TRUE;
               -- Check if this shipment line has already been included for deletion
               -- If so, set the l_unique_flag to false to prevent duplicates
               FOR j IN l_Ship_ID_Tbl.FIRST..l_Ship_ID_Tbl.LAST  LOOP
                 IF(l_Ship_ID_Tbl(j) = p_del_cancel_so_lines_tbl(i).oe_return_line_id) THEN
                   l_unique_flag := FALSE;
                   EXIT;
                 END IF;
               END LOOP;
             END IF;
             IF(l_unique_flag) THEN
                -- Not a duplicate
                -- Check if there are any active OSP Lines for this Return Shipment
                OPEN can_del_return_line_csr(p_del_cancel_so_lines_tbl(i).osp_order_id,p_del_cancel_so_lines_tbl(i).oe_return_line_id);
                FETCH can_del_return_line_csr INTO l_exist;
                IF(can_del_return_line_csr%NOTFOUND) THEN
                   -- No other active OSP Line for this Return shipment
                   -- Check if the shipment has already occured
                   OPEN line_already_shipped_csr(p_del_cancel_so_lines_tbl(i).oe_return_line_id);
                   FETCH line_already_shipped_csr INTO l_exist;
                   IF (line_already_shipped_csr%NOTFOUND) THEN
                     -- Line not yet shipped: Include for deletion
                     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return Shipment line with id ' || p_del_cancel_so_lines_tbl(i).oe_return_line_id || ' included for deletion/cancellation.');
                     END IF;
                     l_Ship_ID_Tbl(l_index) := p_del_cancel_so_lines_tbl(i).oe_return_line_id;
                     l_index := l_index + 1;
                   END IF;
                   CLOSE line_already_shipped_csr;
                END IF;
                CLOSE can_del_return_line_csr;
             END IF;
          END IF;
      END LOOP;
      -- CALL SO API with consolidated list of line IDs
      IF(l_Ship_ID_Tbl.COUNT > 0) THEN
         -- CALL SO to delete/cancel SO
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling AHL_OSP_SHIPMENT_PUB.Delete_Cancel_Order with l_Ship_ID_Tbl.COUNT = ' || l_Ship_ID_Tbl.COUNT);
         END IF;
         AHL_OSP_SHIPMENT_PUB.Delete_Cancel_Order (
          p_api_version              => 1.0,
          p_oe_header_id             => NULL,
          p_oe_lines_tbl             => l_Ship_ID_Tbl,
          p_cancel_flag              => p_cancel_flag,
          x_return_status            => l_return_status ,
          x_msg_count                => l_msg_count ,
          x_msg_data                 => l_msg_data
         );
       IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_SO_LN_CAN_FLD');
          FND_MSG_PUB.ADD;
       END IF;
      END IF;
   END IF;
   IF FND_MSG_PUB.count_msg > 0 THEN
      RAISE  FND_API.G_EXC_ERROR;
      --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END delete_cancel_so;

-----------------------------------------------------------------------------------------------------
FUNCTION can_convert_order(p_osp_order_id IN NUMBER,
                           p_old_type_code IN VARCHAR2,
                           p_new_type_code IN VARCHAR2
                            --p_new_order_rec  IN AHL_OSP_ORDERS_PVT.osp_order_rec_type,
                           --p_old_order_rec  IN AHL_OSP_ORDERS_PVT.osp_order_rec_type
                          ) RETURN BOOLEAN  IS
  CURSOR order_has_ship_return_csr(p_osp_order_id IN NUMBER) IS
      SELECT 'x' FROM ahl_osp_order_lines ol       --, oe_order_lines_all oel
          WHERE ol.osp_order_id = p_osp_order_id
           AND ol.oe_return_line_id IS NOT NULL;   --= oel.line_id;
  CURSOR order_header_status_csr(p_osp_order_id IN NUMBER) IS
     SELECT status_code FROM ahl_osp_orders_b
        WHERE osp_order_id = p_osp_order_id;
  l_exist VARCHAR(1);
  l_status_code VARCHAR(30);
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.CAN_CONVERT_ORDER';
BEGIN
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Function');
END IF;
IF(p_old_type_code  NOT IN (G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)) THEN
   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CONV_FR_TYPE');
     FND_MSG_PUB.ADD;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY ||'.error',  'Cannot Convert from Order Type is not Service or Exchange');
   END IF;
    return false;
END IF;
IF(p_new_type_code NOT IN (G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)) THEN
   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CONV_TO_TYPE');
     FND_MSG_PUB.ADD;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY ||'.error', 'Cannot Convert to an order that is not of  type Service or Exchange');
   END IF;
    return false;
END IF;
-- check if the order is closed
OPEN order_header_status_csr(p_osp_order_id);
FETCH order_header_status_csr INTO l_status_code;
IF(l_status_code = G_OSP_CLOSED_STATUS) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CONV_CLOSED');
    FND_MSG_PUB.ADD;
    CLOSE order_header_status_csr;
    return false;
END IF;
CLOSE order_header_status_csr;
--mpothuku commented on 10-Feb-2007 to implment the Osp Receiving ER. Conversion is enhanced to cancel the return lines in the back ground.
--We do not need this check any more.
/*
OPEN order_has_ship_return_csr(p_osp_order_id);
FETCH  order_has_ship_return_csr INTO l_exist;
IF( order_has_ship_return_csr %FOUND) THEN
  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INV_CONV_HAS_RET_LINE');
    FND_MSG_PUB.ADD;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY ||'.error', 'can_convert:  Cannot Convert. Order has shipment return line');
  END IF;
  CLOSE order_has_ship_return_csr;
   return false;
END IF;
CLOSE order_has_ship_return_csr;
*/
--mpothuku End
  RETURN true;
END can_convert_order;

------------------------------------------------------------------------------------------------------
FUNCTION vendor_id_exist_in_PO( p_po_header_id   IN NUMBER,
                                p_vendor_id      IN NUMBER
 ) RETURN BOOLEAN IS
 CURSOR vendor_id_csr(p_po_header_id IN NUMBER, p_vendor_id IN NUMBER) IS
    SELECT 'x' FROM po_headers_all
      WHERE po_header_id = p_po_header_id
        AND vendor_id = p_vendor_id;
 l_exist VARCHAR(1);
 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.vendor_id_exist_in_PO';
BEGIN
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Function - '
                     || 'p_po_header_id: ' || p_po_header_id || '  p_vendor_id: ' || p_vendor_id);
END IF;
IF(p_po_header_id IS NOT NULL AND p_po_header_id <> FND_API.G_MISS_NUM
   AND p_vendor_id IS NOT NULL AND p_vendor_id <> FND_API.G_MISS_NUM) THEN
   OPEN vendor_id_csr(p_po_header_id, p_vendor_id);
   FETCH vendor_id_csr INTO l_exist;
   IF(vendor_id_csr %FOUND) THEN
      CLOSE vendor_id_csr;
      RETURN true;
   END IF;
   CLOSE vendor_id_csr;
END IF;
RETURN false;
END vendor_id_exist_in_PO;

--------------------------------------------------------------------------------------------------------------
FUNCTION vendor_site_id_exist_in_PO( p_po_header_id   IN NUMBER,
                                p_vendor_site_id      IN NUMBER
 ) RETURN BOOLEAN IS
 CURSOR vendor_site_id_csr(p_po_header_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
    SELECT 'x' FROM po_headers_all
      WHERE po_header_id = p_po_header_id
        AND vendor_site_id = p_vendor_site_id;
 l_exist VARCHAR(1);
 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.vendor_site_id_exist_in_PO';
BEGIN
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Function - '
                   || 'p_po_header_id: ' || p_po_header_id || '  p_vendor_site_id: ' || p_vendor_site_id);
END IF;
IF(p_po_header_id IS NOT NULL AND p_po_header_id <> FND_API.G_MISS_NUM
   AND p_vendor_site_id IS NOT NULL AND p_vendor_site_id <> FND_API.G_MISS_NUM) THEN
   OPEN vendor_site_id_csr(p_po_header_id, p_vendor_site_id);
   FETCH vendor_site_id_csr INTO l_exist;
   IF(vendor_site_id_csr %FOUND) THEN
      CLOSE vendor_site_id_csr;
      RETURN true;
   END IF;
   CLOSE vendor_site_id_csr;
END IF;
RETURN false;
END vendor_site_id_exist_in_PO;

---------------------------------------------------------------------------
--This is the main API for processing Inventory Service Orders including work order based.
--It handles OSP order header Creation, Update, and Deletion, order lines Creation, Update
--and Deletion.
PROCEDURE process_osp_order(
  p_api_version           IN              NUMBER    := 1.0,
  p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
  p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_module_type           IN              VARCHAR2  := NULL,
  p_x_osp_order_rec       IN OUT NOCOPY   osp_order_rec_type,
  p_x_osp_order_lines_tbl IN OUT NOCOPY   osp_order_lines_tbl_type,
  x_return_status         OUT NOCOPY      VARCHAR2,
  x_msg_count             OUT NOCOPY      NUMBER,
  x_msg_data              OUT NOCOPY      VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'process_osp_order';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_del_cancel_so_lines_tbl   del_cancel_so_lines_tbl_type;
  l_dummy_dc_so_lines_tbl     del_cancel_so_lines_tbl_type;
  l_osp_order_id              NUMBER;
  l_oe_ship_line_id           NUMBER;
  l_oe_return_line_id         NUMBER;
  l_oe_header_id              NUMBER;
  l_status_code               VARCHAR2(30);
  l_vendor_validate_flag      BOOLEAN := FALSE;
  l_validate_pass_flag        BOOLEAN := FALSE;
  l_first_index               NUMBER;
  l_valid_vendors_tbl         vendor_id_tbl_type;
  l_any_vendor_flag           VARCHAR2(1);
  l_header_vendor_id          NUMBER;
  l_header_site_id            NUMBER;
  i                           NUMBER;
  CURSOR get_order_lines(c_osp_order_id NUMBER) IS
    SELECT osp_order_line_id
      FROM ahl_osp_order_lines
     WHERE osp_order_id = c_osp_order_id;
BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT process_osp_order;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      G_LOG_PREFIX||l_api_name, --module
      'The main API Begin: and header operation_flag='||p_x_osp_order_rec.operation_flag); --message_text
  END IF;

  --Validate the operation_flag of the header record, and it could be NULL which
  --means no change to the header record
  IF (p_x_osp_order_rec.operation_flag IS NOT NULL AND
      p_x_osp_order_rec.operation_flag NOT IN (G_OP_CREATE, G_OP_UPDATE, G_OP_DELETE)) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVOP');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --Validate the operation_flag of the line records and it couldn't be NULL
  --In case only header record is to be processed, then NULL is supposed to be passed
  --to the lines table
  IF (p_x_osp_order_lines_tbl.COUNT > 0) THEN
    FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
      IF (p_x_osp_order_lines_tbl(i).operation_flag NOT IN (G_OP_CREATE, G_OP_UPDATE, G_OP_DELETE)) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVOP');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;

  --Set the global variable g_module_type
  g_module_type := p_module_type;

  /* Customer pre-processing section, Mandatory */

  IF (JTF_USR_HKS.Ok_to_execute('AHL_OSP_ORDERS_PVT', 'PROCESS_OSP_ORDER', 'B', 'C' )) then
    ahl_osp_orders_CUHK.process_osp_order_pre(
      p_osp_order_rec => p_x_osp_order_rec,
      p_osp_order_lines_tbl => p_x_osp_order_lines_tbl,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      x_return_status => l_return_status);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (p_x_osp_order_rec.operation_flag IS NULL) THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
        G_LOG_PREFIX||l_api_name, --module
        'Within API: No change to OSP header, just for lines');
    END IF;
    --No change to the header record and only to the line records
    IF (p_x_osp_order_lines_tbl.COUNT > 0) THEN
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        IF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_DELETE) THEN
        --Front end just passes osp_order_line_id and operation_flag
          BEGIN
            SELECT osp_order_id, oe_ship_line_id, oe_return_line_id
              INTO l_osp_order_id, l_oe_ship_line_id, l_oe_return_line_id
              FROM ahl_osp_order_lines
             WHERE osp_order_line_id = p_x_osp_order_lines_tbl(i).osp_order_line_id;

             SELECT status_code, oe_header_id INTO l_status_code, l_oe_header_id
              FROM ahl_osp_orders_b
             WHERE osp_order_id = l_osp_order_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_LN_INV');
              FND_MESSAGE.Set_Token('OSP_LINE_ID',p_x_osp_order_lines_tbl(i).osp_order_line_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END;
          -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
          IF (l_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS)) THEN
          -- jaramana End
            IF (l_oe_ship_line_id IS NOT NULL OR l_oe_return_line_id IS NOT NULL) THEN
              l_del_cancel_so_lines_tbl(1).osp_order_id := l_osp_order_id;
              l_del_cancel_so_lines_tbl(1).oe_ship_line_id := l_oe_ship_line_id;
              l_del_cancel_so_lines_tbl(1).oe_return_line_id := l_oe_return_line_id;
            END IF;

            --Delete OSP line record first (it makes more sense to delete shipment lines first, but
            --here just keep it the same as the old logic).
            AHL_OSP_ORDER_LINES_PKG.delete_row(p_x_osp_order_lines_tbl(i).osp_order_line_id);

            --Delete or cancel shipment lines
            delete_cancel_so(
                p_oe_header_id            => NULL,
                p_del_cancel_so_lines_tbl => l_del_cancel_so_lines_tbl);
          ELSE
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVOP');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_CREATE) THEN
          --Create(Add) new line record
          create_osp_order_line(p_x_osp_order_lines_tbl(i));
          --Create shipment at the same time if the flag is checked
          --Removed to the out loop for performance gain
          --IF (p_x_osp_order_lines_tbl(i).shipment_creation_flag = 'Y') THEN
            --create_shipment(p_x_osp_order_lines_tbl(i));
          --END IF;
        ELSIF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_UPDATE) THEN
          --Update line record
          update_osp_order_line(p_x_osp_order_lines_tbl(i));
        END IF;
      END LOOP;

      --To check whether it is necessary to do a post vendor/items combination validation
      --after the records were inserted into or updated from the database
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        -- Modified by jaramana on January 9, 2008 to not do this Vendor check if the line is PO Cancelled or PO Deleted
        IF p_x_osp_order_lines_tbl(i).operation_flag <> G_OP_DELETE AND
           (NVL(p_x_osp_order_lines_tbl(i).status_code, 'ENTERED') NOT IN (G_OL_PO_CANCELLED_STATUS, G_OL_PO_DELETED_STATUS)) THEN
          l_vendor_validate_flag := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF l_vendor_validate_flag THEN
      --Needs to do the post vendor/items combination validation
        l_first_index := p_x_osp_order_lines_tbl.FIRST;
        derive_common_vendors(p_x_osp_order_lines_tbl(l_first_index).osp_order_id,
                               l_valid_vendors_tbl,
                               l_any_vendor_flag);
        IF l_any_vendor_flag <> 'Y' THEN
          BEGIN
            SELECT vendor_id, vendor_site_id INTO l_header_vendor_id, l_header_site_id
              FROM ahl_osp_orders_b
             WHERE osp_order_id = p_x_osp_order_lines_tbl(l_first_index).osp_order_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVALID');
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
          END;

          IF l_valid_vendors_tbl.count > 0 THEN
            IF (l_header_vendor_id IS NULL OR l_header_site_id IS NULL) THEN
              l_validate_pass_flag := TRUE;
            ELSE
              FOR i IN l_valid_vendors_tbl.FIRST..l_valid_vendors_tbl.LAST LOOP
                IF (l_header_vendor_id = l_valid_vendors_tbl(i).vendor_id AND
                    l_header_site_id = l_valid_vendors_tbl(i).vendor_site_id) THEN
                  l_validate_pass_flag := TRUE;
                  EXIT;
                END IF;
              END LOOP;
            END IF;
            IF NOT l_validate_pass_flag THEN
              FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_VENDOR_MISMATCH');
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          ELSE
            FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_VENDOR_MISMATCH');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;
      --Call create_shipment. Create_shipment will check whether it will create
      --shipment or not(if the operation is not Create and no shipment_creation_flag
      --is checked, it will do nothing)
      create_shipment(p_x_osp_order_lines_tbl);
    END IF;
  ELSIF (p_x_osp_order_rec.operation_flag = G_OP_DELETE) THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
        G_LOG_PREFIX||l_api_name, --module
        'Within API: Delete OSP Header/Lines');
    END IF;
    --Front end just passes the osp_order_id
    BEGIN
      SELECT status_code, oe_header_id INTO l_status_code, l_oe_header_id
        FROM ahl_osp_orders_b
       WHERE osp_order_id = p_x_osp_order_rec.osp_order_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVALID');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
    --check the osp order could be deleted, if Yes then
    --Delete OSP order Header/Line records
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        G_LOG_PREFIX||l_api_name,
        'Before deletion and status='||l_status_code||' oe_header='||l_oe_header_id);
    END IF;
    -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
    IF(l_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS)) THEN
    -- jaramana End
      IF (l_oe_header_id IS NOT NULL) THEN
        -- calling to delete SO HEADER
        -- Here needs to populate the l_del_cancel_so_lines_tbl
        i := 1;
        FOR l_get_order_lines IN get_order_lines(p_x_osp_order_rec.osp_order_id) LOOP
          BEGIN
          SELECT oe_ship_line_id, oe_return_line_id
            INTO l_oe_ship_line_id, l_oe_return_line_id
            FROM ahl_osp_order_lines
           WHERE osp_order_line_id = l_get_order_lines.osp_order_line_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_LN_INV');
              FND_MESSAGE.Set_Token('OSP_LINE_ID',l_get_order_lines.osp_order_line_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END;
          IF (l_oe_ship_line_id IS NOT NULL OR l_oe_return_line_id IS NOT NULL) THEN
            l_del_cancel_so_lines_tbl(i).osp_order_id := p_x_osp_order_rec.osp_order_id;
            l_del_cancel_so_lines_tbl(i).oe_ship_line_id := l_oe_ship_line_id;
            l_del_cancel_so_lines_tbl(i).oe_return_line_id := l_oe_return_line_id;
            i := i+1;
          END IF;
        END LOOP;
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
            G_LOG_PREFIX||l_api_name,
            'Before calling: delete_cancel_so and table_count='||to_char(i-1));
        END IF;
        --Delete Shipment header/lines
        delete_cancel_so(
          p_oe_header_id            => l_oe_header_id,
          p_del_cancel_so_lines_tbl => l_dummy_dc_so_lines_tbl);
      END IF;

      --Delete OSP order lines
      FOR l_get_order_lines IN get_order_lines(p_x_osp_order_rec.osp_order_id) LOOP
        AHL_OSP_ORDER_LINES_PKG.delete_row(l_get_order_lines.osp_order_line_id);
      END LOOP;

      --Delete OSP order header record
      AHL_OSP_ORDERS_PKG.delete_row(x_osp_order_id => p_x_osp_order_rec.osp_order_id);
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
          G_LOG_PREFIX||l_api_name,
          'After deleting header.');
      END IF;
    ELSE
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVOP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (p_x_osp_order_rec.operation_flag = G_OP_UPDATE) THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
        G_LOG_PREFIX||l_api_name, --module
        'Within API: Update OSP Header/Lines');
    END IF;
    -- Validate and update header record
    -- Handling if order status is to be changed
    --process_order_status_change(p_x_osp_order_rec);
    -- Handling if order type is to be changed
    --process_order_type_change(p_x_osp_order_rec);
    --Just update the Header record first
    update_osp_order_header(p_x_osp_order_rec);
    IF (p_x_osp_order_lines_tbl IS NOT NULL AND p_x_osp_order_lines_tbl.COUNT > 0) THEN
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        IF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_DELETE) THEN
        --Front end just passes osp_order_line_id and operation_flag
          BEGIN
            SELECT osp_order_id, oe_ship_line_id, oe_return_line_id
              INTO l_osp_order_id, l_oe_ship_line_id, l_oe_return_line_id
              FROM ahl_osp_order_lines
             WHERE osp_order_line_id = p_x_osp_order_lines_tbl(i).osp_order_line_id;

             SELECT status_code, oe_header_id INTO l_status_code, l_oe_header_id
              FROM ahl_osp_orders_b
             WHERE osp_order_id = l_osp_order_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_LN_INV');
              FND_MESSAGE.Set_Token('OSP_LINE_ID',p_x_osp_order_lines_tbl(i).osp_order_line_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END;
          -- Added by jaramana on January 9, 2008 for the Requisition ER 6034236
          IF (l_status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS)) THEN
          -- jaramana End
            IF (p_x_osp_order_lines_tbl(i).oe_ship_line_id IS NOT NULL OR
                p_x_osp_order_lines_tbl(i).oe_return_line_id IS NOT NULL) THEN
              l_del_cancel_so_lines_tbl(1).osp_order_id := l_osp_order_id;
              l_del_cancel_so_lines_tbl(1).oe_ship_line_id := l_oe_ship_line_id;
              l_del_cancel_so_lines_tbl(1).oe_return_line_id := l_oe_return_line_id;
            END IF;

            --Delete line record first (it makes more sense to delete shipment lines first, but
            --here just keep it the same as the old logic.
            AHL_OSP_ORDER_LINES_PKG.delete_row(p_x_osp_order_lines_tbl(i).osp_order_line_id);
            --Delete or cancel Shipment lines
            delete_cancel_so(
                p_oe_header_id            => NULL,
                p_del_cancel_so_lines_tbl => l_del_cancel_so_lines_tbl);
          ELSE
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVOP');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          --AHL_OSP_ORDER_LINES_PKG.delete_row(p_x_osp_order_lines_tbl(i).osp_order_line_id);
        ELSIF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_UPDATE) THEN
          --update osp order line
          update_osp_order_line(p_x_osp_order_lines_tbl(i));
        ELSIF (p_x_osp_order_lines_tbl(i).operation_flag = G_OP_CREATE) THEN
          --Add new osp order line
          create_osp_order_line(p_x_osp_order_lines_tbl(i));
          -- Moved out of the loop for performance gain
          --IF (p_x_osp_order_lines_tbl(i).shipment_creation_flag = 'Y') THEN
            --create_shipment(p_x_osp_order_lines_tbl(i));
          --END IF;
        END IF;
      END LOOP;

      --Call create_shipment. Create_shipment will check whether it will create
      --shipment or not(if the operation is not Create and no shipment_creation_flag
      --is checked, it will do nothing)
      create_shipment(p_x_osp_order_lines_tbl);
    END IF;

    --To check whether it is necessary to do a post vendor/items combination validation
    --after the records were inserted into or updated from the database
    derive_common_vendors(p_x_osp_order_rec.osp_order_id,
                          l_valid_vendors_tbl,
                          l_any_vendor_flag);
    BEGIN
      SELECT vendor_id, vendor_site_id INTO l_header_vendor_id, l_header_site_id
        FROM ahl_osp_orders_b
       WHERE osp_order_id = p_x_osp_order_rec.osp_order_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVALID');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
    IF l_any_vendor_flag <> 'Y' THEN
      IF l_valid_vendors_tbl.count > 0 THEN
        IF (l_header_vendor_id IS NULL OR l_header_site_id IS NULL) THEN
          l_validate_pass_flag := TRUE;
        ELSE
          FOR i IN l_valid_vendors_tbl.FIRST..l_valid_vendors_tbl.LAST LOOP
            IF (l_header_vendor_id = l_valid_vendors_tbl(i).vendor_id AND
                l_header_site_id = l_valid_vendors_tbl(i).vendor_site_id) THEN
              l_validate_pass_flag := TRUE;
              EXIT;
            END IF;
          END LOOP;
        END IF;
        IF NOT l_validate_pass_flag THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_VENDOR_MISMATCH');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_VENDOR_MISMATCH');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  ELSIF (p_x_osp_order_rec.operation_flag = G_OP_CREATE) THEN
    --Validate new line records first because in header record only one attribute needs validation
    --but it needs line records to derive vendor attributes.
    --
    --Default the attributes of header record and create OSP order header record
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
        G_LOG_PREFIX||l_api_name,
        'OSP order header/Lines creation and lines count='||p_x_osp_order_lines_tbl.Count||
        'osp_order_id='||p_x_osp_order_rec.osp_order_id);
    END IF;
    create_osp_order_header(p_x_osp_order_rec, p_x_osp_order_lines_tbl);
    IF (p_x_osp_order_lines_tbl IS NOT NULL AND p_x_osp_order_lines_tbl.COUNT > 0) THEN
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        --Create OSP order line records
        --p_x_osp_order_lines_tbl(i).osp_order_id := p_x_osp_order_rec.osp_order_id;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
            G_LOG_PREFIX||l_api_name,
            'Within the API and i='||i||'workorder_id='||p_x_osp_order_lines_tbl(i).workorder_id||
            'First='||p_x_osp_order_lines_tbl.FIRST||'Last='||p_x_osp_order_lines_tbl.LAST||
            'Count='||p_x_osp_order_lines_tbl.Count);
        END IF;
        p_x_osp_order_lines_tbl(i).osp_order_id := p_x_osp_order_rec.osp_order_id;
        create_osp_order_line(p_x_osp_order_lines_tbl(i));
        -- Moved out of the loop for performance gain
        --IF (p_x_osp_order_lines_tbl(i).shipment_creation_flag = 'Y') THEN
          --create_shipment(p_x_osp_order_lines_tbl(i));
        --END IF;
      END LOOP;
      --Call create_shipment. Create_shipment will check whether it will create
      --shipment or not(if the operation is not Create and no shipment_creation_flag
      --is checked, it will do nothing)
      create_shipment(p_x_osp_order_lines_tbl);
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      G_LOG_PREFIX||l_api_name,
      'API End: at the end of the procedure');
  END IF;

/* Customer Post Processing section - mandatory */
  IF (JTF_USR_HKS.Ok_to_execute('AHL_OSP_ORDERS_PVT', 'PROCESS_OSP_ORDER', 'A', 'C' )) then
    ahl_osp_orders_CUHK. process_osp_order_Post(
      p_osp_order_rec => p_x_osp_order_rec,
      p_osp_order_lines_tbl => p_x_osp_order_lines_tbl,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      x_return_status => l_return_status);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_osp_order;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_osp_order;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO process_osp_order;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END process_osp_order;

-- create_osp_order_header Procedure revamped by jaramana on May 9, 2006 for Bug 5215894
-- to make the process_osp_order API conform to Oracle Apps Public API Standards
-- in the create mode also.
-- 1. Perform Value to Id conversions
-- 2. Honor the input values/Ids passed
-- 3. Validate the Ids passed or derived
PROCEDURE create_osp_order_header(p_x_osp_order_rec IN OUT NOCOPY osp_order_rec_type,
                                  p_x_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type)
IS
  l_operating_unit_id        NUMBER;
  l_osp_order_id             NUMBER;
  l_osp_order_number         NUMBER;
  l_item_service_rels_tbl    item_service_rels_tbl_type;
  l_vendor_id                NUMBER;
  l_vendor_site_id           NUMBER;
  l_vendor_contact_id        NUMBER;
  l_return_status            VARCHAR2(1);
  l_organization_id          NUMBER;
  l_inventory_item_id        NUMBER;
  l_service_item_id          NUMBER;
  l_rowid_dummy              VARCHAR2(100);
  l_buyer_id                 NUMBER;
  l_valid_vendors_tbl        vendor_id_tbl_type;
  l_temp_num                 NUMBER;
  l_vendor_valid_flag        BOOLEAN := FALSE;

  CURSOR get_buyer_id IS
    SELECT PA.buyer_id
      FROM po_agents_name_v PA,
           fnd_user FU
     WHERE FU.user_id = fnd_global.user_id
       AND PA.buyer_id = FU.employee_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || 'create_osp_order_header',
                   'Procedure begins...');
  END IF;

  --Generate the primary key
  SELECT ahl_osp_orders_b_s.NEXTVAL
    INTO l_osp_order_id
    FROM sys.dual;
  --If there is no records in the table, then max(osp_order_number) IS null
  --SELECT NVL(MAX(osp_order_number), l_osp_order_id-1)+1
  --  INTO l_osp_order_number
  --  FROM ahl_osp_orders_b;
  --Finally decided to change back because the above logic will probably violate the unique
  --index defined on osp_order_number if two concurrent users submit the OSP Order creation at
  --the same time
  l_osp_order_number := l_osp_order_id;
  --Derive operating_unit_id
  l_operating_unit_id :=mo_global.get_current_org_id();
  IF (l_operating_unit_id IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_ORG_NOT_SET');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --Validate the only user passed parameter order_type_code
  IF (p_x_osp_order_rec.order_type_code IS NULL OR
      p_x_osp_order_rec.order_type_code NOT IN (G_OSP_ORDER_TYPE_SERVICE,
                                                G_OSP_ORDER_TYPE_EXCHANGE,
                                                G_OSP_ORDER_TYPE_BORROW)) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORDER_TYPE_INVALID');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
  --This API nulls out the G_MISS info, if passed by the user in the create mode.
  IF nvl(g_module_type, 'NULL') <> G_OAF_MODULE THEN
    default_unchanged_order_header(p_x_osp_order_rec);
  END IF;
  -- jaramana End

  -- Added by jaramana on May 9, 2006 for Bug 5215894
  convert_order_header_val_to_id(p_x_osp_order_rec);

  --Derive vendor related attributes
  IF (p_x_osp_order_lines_tbl IS NULL OR p_x_osp_order_lines_tbl.COUNT = 0) THEN
    l_vendor_id := NULL;
    l_vendor_site_id := NULL;
    l_vendor_contact_id := NULL;
    /** Added by jaramana on May 9, 2006 for Bug 5215894 **/
    IF (p_x_osp_order_rec.vendor_id IS NOT NULL) THEN
      IF (p_x_osp_order_rec.vendor_site_id IS NOT NULL) THEN
        IF (p_x_osp_order_rec.vendor_contact_id IS NOT NULL) THEN
          -- Validate the combination of vendor/site/contact
          validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                       p_x_osp_order_rec.vendor_site_id,
                                       p_x_osp_order_rec.vendor_contact_id);
          IF FND_MSG_PUB.count_msg > 0 THEN
            -- Vendor/Vendor Site/Vendor Contact is Invalid
            RAISE  FND_API.G_EXC_ERROR;
          END IF;
          -- If valid, use the input values
          l_vendor_id := p_x_osp_order_rec.vendor_id;
          l_vendor_site_id := p_x_osp_order_rec.vendor_site_id;
          l_vendor_contact_id := p_x_osp_order_rec.vendor_contact_id;
        ELSE
          -- Validate the vendor and vendor site
          validate_vendor_site(p_x_osp_order_rec.vendor_id,
                               p_x_osp_order_rec.vendor_site_id);
          IF FND_MSG_PUB.count_msg > 0 THEN
            -- Vendor/Vendor Site/Vendor Contact is Invalid
            RAISE  FND_API.G_EXC_ERROR;
          END IF;
          -- If valid, use the input values
          l_vendor_id := p_x_osp_order_rec.vendor_id;
          l_vendor_site_id := p_x_osp_order_rec.vendor_site_id;
        END IF;
      ELSE
        -- Validate the Vendor
        validate_vendor(p_x_osp_order_rec.vendor_id);
        IF FND_MSG_PUB.count_msg > 0 THEN
          -- Vendor/Vendor Site/Vendor Contact is Invalid
          RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- If valid, use the input values
        l_vendor_id := p_x_osp_order_rec.vendor_id;
      END IF;
    END IF;
    /** End addition by jaramana on May 9, 2006 for Bug 5215894 **/
  ELSIF (p_x_osp_order_lines_tbl.COUNT > 0) THEN
    IF (p_x_osp_order_lines_tbl(p_x_osp_order_lines_tbl.FIRST).workorder_id IS NULL) THEN
    --Only need to check the the first record, either all work order lines or inventory
    --service order lines. All service order lines
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        l_item_service_rels_tbl(i).inv_org_id := p_x_osp_order_lines_tbl(i).inventory_org_id;
        l_item_service_rels_tbl(i).inv_item_id := p_x_osp_order_lines_tbl(i).inventory_item_id;
        l_item_service_rels_tbl(i).service_item_id := p_x_osp_order_lines_tbl(i).service_item_id;
      END LOOP;
    ELSE
      --All work order lines
      FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
        BEGIN
        --Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
         /*
          SELECT organization_id, inventory_item_id, service_item_id
            INTO l_organization_id, l_inventory_item_id, l_service_item_id
            FROM ahl_workorders_osp_v
           WHERE workorder_id = p_x_osp_order_lines_tbl(i).workorder_id;
         */
        SELECT vst.organization_id, vts.inventory_item_id, arb.service_item_id
          INTO l_organization_id, l_inventory_item_id, l_service_item_id
          FROM ahl_workorders wo,
               ahl_visits_b vst,
               ahl_visit_tasks_b vts,
               ahl_routes_b arb,
               inv_organization_info_v org
         WHERE wo.workorder_id = p_x_osp_order_lines_tbl (i).workorder_id
           AND wo.route_id = arb.route_id(+)
           AND wo.master_workorder_flag = 'N'
           AND wo.visit_id = vst.visit_id
           AND wo.visit_task_id = vts.visit_task_id
           AND vst.visit_id = vts.visit_id
           AND vst.organization_id = org.organization_id
           AND NVL (org.operating_unit, mo_global.get_current_org_id ())= mo_global.get_current_org_id();

          l_item_service_rels_tbl(i).inv_org_id := l_organization_id;
          l_item_service_rels_tbl(i).inv_item_id := l_inventory_item_id;
          l_item_service_rels_tbl(i).service_item_id := l_service_item_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_WO');
            FND_MESSAGE.Set_Token('WORKORDER_ID', p_x_osp_order_lines_tbl(i).workorder_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END;
      END LOOP;
    END IF;
    derive_default_vendor(l_item_service_rels_tbl,
                          l_vendor_id,
                          l_vendor_site_id,
                          l_vendor_contact_id,
                          l_valid_vendors_tbl);
    /** Added by jaramana on May 9, 2006 for Bug 5215894 **/
    -- If the user has passed a Vendor or Vendor + Vendor Site, validate and use these instead of the default
    -- If only Vendor Site is passed (without the Vendor), ignore and use default
    IF (p_x_osp_order_rec.vendor_id IS NOT NULL) THEN
      IF (l_valid_vendors_tbl.count > 0) THEN
        FOR l_temp_num in l_valid_vendors_tbl.FIRST..l_valid_vendors_tbl.LAST LOOP
          IF (l_valid_vendors_tbl(l_temp_num).vendor_id = p_x_osp_order_rec.vendor_id AND
              l_valid_vendors_tbl(l_temp_num).vendor_site_id = NVL(p_x_osp_order_rec.vendor_site_id, l_valid_vendors_tbl(l_temp_num).vendor_site_id)) THEN
            l_vendor_id := p_x_osp_order_rec.vendor_id;
            l_vendor_site_id := NVL(p_x_osp_order_rec.vendor_site_id, l_valid_vendors_tbl(l_temp_num).vendor_site_id);
            l_vendor_valid_flag := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;
      IF (l_vendor_valid_flag = FALSE) THEN
        -- The vendor or vendor + vendor site passed in is not a valid: Throw Error
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
        FND_MESSAGE.Set_Token('VENDOR_ID', p_x_osp_order_rec.vendor_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_x_osp_order_rec.vendor_site_id IS NOT NULL) THEN
        IF (p_x_osp_order_rec.vendor_contact_id IS NOT NULL) THEN
          -- Check if p_x_osp_order_rec.vendor_contact_id is valid
          validate_vendor_site_contact(p_x_osp_order_rec.vendor_id,
                                       p_x_osp_order_rec.vendor_site_id,
                                       p_x_osp_order_rec.vendor_contact_id);
          IF FND_MSG_PUB.count_msg > 0 THEN
            -- Vendor/Vendor Site/Vendor Contact is Invalid
            RAISE  FND_API.G_EXC_ERROR;
          END IF;
          -- Vendor Contact is valid: Use it
          l_vendor_contact_id := p_x_osp_order_rec.vendor_contact_id;
        ELSE
          -- User has passed Vendor and Vendor Site, but not Vendor Contact: Leave Contact as null
          l_vendor_contact_id := null;
        END IF;
      ELSE
        -- User has passed Vendor, but not Vendor Site: Set Contact as null even if passed
        l_vendor_contact_id := null;
      END IF;
    END IF;
  END IF;

  IF (p_x_osp_order_rec.po_agent_id IS NOT NULL) THEN
    -- Validate the buyer
    validate_buyer(p_x_osp_order_rec.po_agent_id);
    IF FND_MSG_PUB.count_msg > 0 THEN
      -- Buyer is Invalid
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Buyer is valid: Use it
    l_buyer_id := p_x_osp_order_rec.po_agent_id;
  ELSE
    --Derive the default po_agent_id
    l_buyer_id := fnd_global.user_id;
    OPEN get_buyer_id;
    FETCH get_buyer_id INTO l_buyer_id;
    CLOSE get_buyer_id;
  END IF;
  /** End addition by jaramana on May 9, 2006 for Bug 5215894 **/

  --In Create mode, assume that UI will never pass G_MISS value(if it is null in UI, then just pass
  --Null to the API). Thus in this Create procedure, there are only three attributes probably need
  --validation: customer_id, contract_id and contract_terms
  AHL_OSP_ORDERS_PKG.insert_row(
    x_rowid => l_rowid_dummy,
    x_osp_order_id => l_osp_order_id,
    x_object_version_number => 1,
    x_created_by => FND_GLOBAL.user_id,
    x_creation_date => SYSDATE,
    x_last_updated_by => FND_GLOBAL.user_id,
    x_last_update_date => SYSDATE,
    x_last_update_login => FND_GLOBAL.login_id,
    x_osp_order_number => l_osp_order_number,
    x_order_type_code => p_x_osp_order_rec.order_type_code, --User entered
    x_single_instance_flag => G_NO_FLAG,
    x_po_header_id => NULL, --p_x_osp_order_rec.po_header_id,
    x_oe_header_id => NULL, --p_x_osp_order_rec.oe_header_id,
    x_vendor_id => l_vendor_id,
    x_vendor_site_id => l_vendor_site_id,
    x_vendor_contact_id => l_vendor_contact_id,
    x_customer_id => p_x_osp_order_rec.customer_id,
    x_order_date => TRUNC(SYSDATE),
    x_contract_id => p_x_osp_order_rec.contract_id,
    x_contract_terms => p_x_osp_order_rec.contract_terms,
    x_operating_unit_id => l_operating_unit_id,
    x_po_synch_flag => NULL, --p_x_osp_order_rec.po_synch_flag,
    x_status_code => G_OSP_ENTERED_STATUS,
    x_po_batch_id => NULL, --p_x_osp_order_rec.po_batch_id,
    x_po_request_id => NULL, --p_x_osp_order_rec.po_request_id,
    x_po_agent_id => l_buyer_id,
    x_po_interface_header_id => NULL, --p_x_osp_order_rec.po_interface_header_id,
    -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
    x_po_req_header_id => NULL,
    -- jaramana End
    x_description => p_x_osp_order_rec.description,
    x_attribute_category => p_x_osp_order_rec.attribute_category,
    x_attribute1 => p_x_osp_order_rec.attribute1,
    x_attribute2 => p_x_osp_order_rec.attribute2,
    x_attribute3 => p_x_osp_order_rec.attribute3,
    x_attribute4 => p_x_osp_order_rec.attribute4,
    x_attribute5 => p_x_osp_order_rec.attribute5,
    x_attribute6 => p_x_osp_order_rec.attribute6,
    x_attribute7 => p_x_osp_order_rec.attribute7,
    x_attribute8 => p_x_osp_order_rec.attribute8,
    x_attribute9 => p_x_osp_order_rec.attribute9,
    x_attribute10 => p_x_osp_order_rec.attribute10,
    x_attribute11 => p_x_osp_order_rec.attribute11,
    x_attribute12 => p_x_osp_order_rec.attribute12,
    x_attribute13 => p_x_osp_order_rec.attribute13,
    x_attribute14 => p_x_osp_order_rec.attribute14,
    x_attribute15 => p_x_osp_order_rec.attribute15);
  --Return the generated order header id to the output record structure
  p_x_osp_order_rec.osp_order_id := l_osp_order_id;
  IF (p_x_osp_order_lines_tbl IS NOT NULL AND p_x_osp_order_lines_tbl.COUNT > 0) THEN
    FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST LOOP
      p_x_osp_order_lines_tbl(i).osp_order_id := l_osp_order_id;
    END LOOP;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || '.create_osp_order_header',
                   'Procedure exits normally');
  END IF;
END create_osp_order_header;

PROCEDURE update_osp_order_header(p_x_osp_order_rec IN OUT NOCOPY osp_order_rec_type)
IS
  l_operating_unit_id        NUMBER;
  l_osp_order_id             NUMBER;
  l_osp_order_number         NUMBER;
  l_item_service_rels_tbl    item_service_rels_tbl_type;
  l_vendor_id                NUMBER;
  l_vendor_site_id           NUMBER;
  l_vendor_contact_id        NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_organization_id          NUMBER;
  l_inventory_item_id        NUMBER;
  l_service_item_id          NUMBER;
  l_dummy_num                NUMBER;
  l_osp_order_line_rec       osp_order_line_rec_type;
  l_oe_header_id             NUMBER;
  CURSOR get_all_lines(c_osp_order_id NUMBER) IS
    SELECT osp_order_line_id, inventory_item_id,
           inventory_org_id, service_item_id, workorder_id
      FROM ahl_osp_order_lines
     WHERE osp_order_id = c_osp_order_id;
  CURSOR get_old_vendor_attrs(c_osp_order_id NUMBER) IS
    SELECT vendor_id, vendor_site_id, oe_header_id
      FROM ahl_osp_orders_b
     WHERE osp_order_id = c_osp_order_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || '.update_osp_order_header',
                   'Procedure begins and osp_order_id='||p_x_osp_order_rec.osp_order_id);
  END IF;
  --This three procedures are borrowed from the original ones
  --For OAF, the default procedure may not be necessary.
  --we decided to pass null when you want to change it to null, the old value if there is no change.
  IF nvl(g_module_type, 'NULL') <> G_OAF_MODULE THEN
    default_unchanged_order_header(p_x_osp_order_rec);
  END IF;
  convert_order_header_val_to_id(p_x_osp_order_rec);
  validate_order_header(p_x_osp_order_rec);

  --Handling if order status is to be changed
  process_order_status_change(p_x_osp_order_rec);
  --Handling if order type is to be changed
  process_order_type_change(p_x_osp_order_rec);

  OPEN get_old_vendor_attrs(p_x_osp_order_rec.osp_order_id);
  FETCH get_old_vendor_attrs INTO l_vendor_id, l_vendor_site_id, l_oe_header_id;
  CLOSE get_old_vendor_attrs;

  --Call table handler to update
  AHL_OSP_ORDERS_PKG.update_row(
        x_osp_order_id => p_x_osp_order_rec.osp_order_id,
        x_object_version_number => p_x_osp_order_rec.object_version_number + 1,
        x_osp_order_number => p_x_osp_order_rec.osp_order_number,
        x_order_type_code => p_x_osp_order_rec.order_type_code,
        x_single_instance_flag => p_x_osp_order_rec.single_instance_flag,
        x_po_header_id => p_x_osp_order_rec.po_header_id,
        x_oe_header_id => p_x_osp_order_rec.oe_header_id,
        x_vendor_id => p_x_osp_order_rec.vendor_id,
        x_vendor_site_id => p_x_osp_order_rec.vendor_site_id,
        x_vendor_contact_id => p_x_osp_order_rec.vendor_contact_id,
        x_customer_id => p_x_osp_order_rec.customer_id,
        x_order_date => TRUNC(p_x_osp_order_rec.order_date),
        x_contract_id => p_x_osp_order_rec.contract_id,
        x_contract_terms => p_x_osp_order_rec.contract_terms,
        x_operating_unit_id => p_x_osp_order_rec.operating_unit_id,
        x_po_synch_flag => p_x_osp_order_rec.po_synch_flag,
        x_status_code => p_x_osp_order_rec.status_code,
        x_po_batch_id => p_x_osp_order_rec.po_batch_id,
        x_po_request_id => p_x_osp_order_rec.po_request_id,
        x_po_agent_id => p_x_osp_order_rec.po_agent_id,
        x_po_interface_header_id => p_x_osp_order_rec.po_interface_header_id,
-- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
        x_po_req_header_id => p_x_osp_order_rec.po_req_header_id,
-- jaramana End
        x_description => p_x_osp_order_rec.description,
        x_attribute_category => p_x_osp_order_rec.attribute_category,
        x_attribute1 => p_x_osp_order_rec.attribute1,
        x_attribute2 => p_x_osp_order_rec.attribute2,
        x_attribute3 => p_x_osp_order_rec.attribute3,
        x_attribute4 => p_x_osp_order_rec.attribute4,
        x_attribute5 => p_x_osp_order_rec.attribute5,
        x_attribute6 => p_x_osp_order_rec.attribute6,
        x_attribute7 => p_x_osp_order_rec.attribute7,
        x_attribute8 => p_x_osp_order_rec.attribute8,
        x_attribute9 => p_x_osp_order_rec.attribute9,
        x_attribute10 => p_x_osp_order_rec.attribute10,
        x_attribute11 => p_x_osp_order_rec.attribute11,
        x_attribute12 => p_x_osp_order_rec.attribute12,
        x_attribute13 => p_x_osp_order_rec.attribute13,
        x_attribute14 => p_x_osp_order_rec.attribute14,
        x_attribute15 => p_x_osp_order_rec.attribute15,
        x_last_updated_by => fnd_global.user_id,
        x_last_update_date => SYSDATE,
        x_last_update_login => fnd_global.login_id
      );
  --After the header vendor gets changed then calling validate_vendor_service_item.
  --If it is not for calling validate_vendor_service_item, then it is better to put
  --this validation ahead of table_handler calling
  --Validate the header vendor with physical/Service item combinations in lines
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX || '.update_osp_order_header',
                   'new_vendor='||p_x_osp_order_rec.vendor_id||
                   'old_vendor='||l_vendor_id);
  END IF;
  --The following validation was moved to process_osp_order and acting like
  --a post database operation validation (Jerry) 06/15/2005
  --IF ((p_x_osp_order_rec.vendor_id <> l_vendor_id) OR
      --(p_x_osp_order_rec.vendor_id IS NOT NULL AND l_vendor_id IS NULL) OR
      --(p_x_osp_order_rec.vendor_site_id <> l_vendor_site_id) OR
      --(p_x_osp_order_rec.vendor_site_id IS NOT NULL AND l_vendor_site_id IS NULL)) THEN
    -- Both new vendor_id and vendor_site_id can't be null. Already validated in
    -- validate_order_header
    --FOR l_get_all_lines IN get_all_lines(p_x_osp_order_rec.osp_order_id) LOOP
      --l_osp_order_line_rec.osp_order_id := p_x_osp_order_rec.osp_order_id;
      --l_osp_order_line_rec.osp_order_line_id := l_get_all_lines.osp_order_line_id;
      --l_osp_order_line_rec.inventory_item_id := l_get_all_lines.inventory_item_id;
      --l_osp_order_line_rec.inventory_org_id := l_get_all_lines.inventory_org_id;
      --l_osp_order_line_rec.service_item_id := l_get_all_lines.service_item_id;
      --IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        --FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   --G_LOG_PREFIX || '.update_osp_order_header',
                   --'before calling validate_vendor_service_item'||
                   --'line_id='||l_get_all_lines.osp_order_line_id||
                   --'inventory_item_id ='||l_osp_order_line_rec.inventory_item_id||
                   --'org_id = '||l_osp_order_line_rec.inventory_org_id||
                   --'service_id = '||l_osp_order_line_rec.service_item_id);
      --END IF;
      -- validate_vendor_service_item(l_osp_order_line_rec);
    --END LOOP;
  --END IF;
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                   G_LOG_PREFIX || '.update_osp_order_header',
                   'Before calling AHL_OSP_SHIPMENT_PUB.handle_vendor_change');
  END IF;
  IF ((l_oe_header_id IS NOT NULL) AND
      ((p_x_osp_order_rec.vendor_id IS NOT NULL AND l_vendor_id IS NULL) OR
       (p_x_osp_order_rec.vendor_id <> l_vendor_id) OR
       -- Added by jaramana on January 10, 2008 to fix the issue with the SO Customer change if the Vendor Site is Changed, Bug 6521712.
       (p_x_osp_order_rec.vendor_site_id IS NOT NULL AND l_vendor_site_id IS NULL) OR
       (p_x_osp_order_rec.vendor_site_id <> l_vendor_site_id ))) THEN
  --Only if vendor gets changed, then call the shipment API to handle the change
    AHL_OSP_SHIPMENT_PUB.handle_vendor_change(
      p_osp_order_id  => p_x_osp_order_rec.osp_order_id,
      p_vendor_id     => p_x_osp_order_rec.vendor_id,
      p_vendor_loc_id => p_x_osp_order_rec.vendor_site_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     G_LOG_PREFIX || '.update_osp_order_header',
                     'Normally exit after calling AHL_OSP_SHIPMENT_PUB.handle_vendor_change'||
                     'x_return_status='||l_return_status);
    END IF;
  END IF;
END update_osp_order_header;

PROCEDURE create_osp_order_line(p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type)
IS
  l_osp_line_id              NUMBER;
  l_osp_line_number          NUMBER;
  l_return_status            VARCHAR2(1);
  l_organization_id          NUMBER;
  l_inventory_item_id        NUMBER;
  l_service_item_id          NUMBER;
  l_service_duration         NUMBER;
  l_quantity                 NUMBER;
  l_service_item_uom_code    VARCHAR2(3);
  l_temp_uom_code            VARCHAR2(3);
  l_item_description         VARCHAR2(240);
  l_vendor_id                NUMBER;
  l_vendor_site_id           NUMBER;
  --Added by mpothuku on 24-Mar-06 for ER: 4544654
  l_owrite_svc_desc_prf VARCHAR2(1);
  l_item_prefix         VARCHAR2(240);
  l_serial_prefix       VARCHAR2(240);
  l_inv_item_number     VARCHAR2(40);
  l_svc_item_number     VARCHAR2(40);
  l_desc_update_flag    VARCHAR2(1);
  --mpothuku end
  CURSOR get_wo_item_attrs(c_workorder_id NUMBER) IS
  --Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
  /*
    SELECT inventory_item_id,
           organization_id,
           lot_number,
           serial_number,
           quantity, --This quantity is from csi, so it means instance quantity
           item_instance_uom,
           service_item_id,
           service_item_description,
           service_item_uom
      FROM ahl_workorders_osp_v
     WHERE workorder_id = c_workorder_id;
 */
     SELECT vts.inventory_item_id,
           vst.organization_id,
           csii.lot_number,
           csii.serial_number,
           csii.quantity, --This quantity is from csi, so it means instance quantity
           csii.unit_of_measure item_instance_uom,
           arb.service_item_id,
           mtls.description service_item_description,
           mtls.primary_uom_code service_item_uom
      FROM ahl_workorders wo,
           ahl_visits_b vst,
           ahl_visit_tasks_b vts,
           csi_item_instances csii,
           mtl_system_items_kfv mtls,
           ahl_routes_b arb
     WHERE wo.workorder_id = c_workorder_id
       AND wo.visit_task_id = vts.visit_task_id
       AND vst.visit_id = vts.visit_id
       AND wo.route_id = arb.route_id(+)
       AND arb.service_item_org_id = mtls.organization_id(+)
       AND arb.service_item_id = mtls.inventory_item_id(+)
       AND vts.instance_id = csii.instance_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX || '.create_osp_order_line',
                   'Before line validation:'||
                   'osp_order_id='||p_x_osp_order_line_rec.osp_order_id);
  END IF;
  --Validate the order line
  validate_order_line_creation(p_x_osp_order_line_rec);

--yazhou 22-Aug-2006 starts
-- Bug fix#5479266

  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--yazhou 22-Aug-2006 ends

  --Generate the primary key
  SELECT ahl_osp_order_lines_s.NEXTVAL
    INTO l_osp_line_id
    FROM sys.dual;

  --Generate the line number
  --NOTE: This logic to generate osp_line number will probably violate the unique
  --index defined on osp_line_number if two concurrent users try to add osp order line
  --to the same OSP Order headet at the same time.
  SELECT NVL(MAX(osp_line_number), 0)+1
    INTO l_osp_line_number
    FROM ahl_osp_order_lines
   WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id;

  /*
    Changed by jaramana on January 10, 2008
    Fix for the Bug 5358438/5967633/5417460
    Its better not to change the existing flow if the po_line_id is passed. The attribute defaulting as well as validation
    happens in the validate_order_creation, we only need to call the insert_row method here.
  */
  IF(p_x_osp_order_line_rec.po_line_id is null) THEN

  --For work order based lines, it is better to populate the physical item/service item related attributes
  --And these attributes don't have to be validated.
  IF (p_x_osp_order_line_rec.workorder_id IS NOT NULL) THEN
    OPEN get_wo_item_attrs(p_x_osp_order_line_rec.workorder_id);
    FETCH get_wo_item_attrs INTO p_x_osp_order_line_rec.inventory_item_id,
                                 p_x_osp_order_line_rec.inventory_org_id,
                                 p_x_osp_order_line_rec.lot_number,
                                 p_x_osp_order_line_rec.serial_number,
                                 p_x_osp_order_line_rec.inventory_item_quantity,
                                 p_x_osp_order_line_rec.inventory_item_uom,
                                 p_x_osp_order_line_rec.service_item_id,
                                 p_x_osp_order_line_rec.service_item_description,
                                 p_x_osp_order_line_rec.service_item_uom_code;
                                 --leave p_x_osp_order_line_rec.sub_inventory blank
    CLOSE get_wo_item_attrs;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || 'create_osp_order_line',
                   'After line validation and before insert operation:'||
                   'inv_item_id='||p_x_osp_order_line_rec.inventory_item_id||' service_item_id='||p_x_osp_order_line_rec.service_item_id);
  END IF;

  --Default service item quantity and uom if there are null and service item not null, derive
  --service item description always as long as service_item_id is not null regardless what being passed (means
  --it could be overwrite if a non null value passed to service_item_description if service_item_id is not null)

-- yazhou 06-Jul-2006 starts
-- bug fix#5376907
--  l_quantity := p_x_osp_order_line_rec.quantity; --here it means service_item quantity
-- yazhou 06-Jul-2006 ends

  l_service_item_uom_code := p_x_osp_order_line_rec.service_item_uom_code;
  l_item_description := p_x_osp_order_line_rec.service_item_description;
  IF (p_x_osp_order_line_rec.service_item_id IS NOT NULL) THEN
    BEGIN
      --Assuming the org of service_item_id is the same as that of physical item
      --Alwasy set service_item_description to be derived from service_item_id if service_item_id is not null
      SELECT primary_uom_code, description,concatenated_segments, allow_item_desc_update_flag INTO
			l_temp_uom_code, l_item_description, l_svc_item_number, l_desc_update_flag
        FROM mtl_system_items_kfv
       WHERE inventory_item_id = p_x_osp_order_line_rec.service_item_id
         AND organization_id = p_x_osp_order_line_rec.inventory_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM');
        FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_x_osp_order_line_rec.service_item_id);
        FND_MSG_PUB.ADD;
    END;

-- yazhou 06-Jul-2006 starts
-- bug fix#5376907

--    IF (p_x_osp_order_line_rec.quantity IS NULL) THEN
--      l_quantity := 1;
--    END IF;
-- yazhou 06-Jul-2006 ends

    IF (p_x_osp_order_line_rec.service_item_uom_code IS NULL) THEN
      l_service_item_uom_code := l_temp_uom_code;
    END IF;
    --Added by mpothuku on 24-Mar-06 for ER: 4544654
    /*IF Overwrite Svc Description profile set to No l_item_description would have been
      defaulted as the service item desc from inventory above, if the profile is Yes, we proceed below
      to override the value set from the inventory */

    l_owrite_svc_desc_prf := NVL(FND_PROFILE.VALUE('AHL_OSP_OWRITE_SVC_DESC'), 'N');
    l_item_prefix := FND_PROFILE.VALUE('AHL_OSP_POL_ITEM_PREFIX');
    l_serial_prefix := FND_PROFILE.VALUE('AHL_OSP_POL_SER_PREFIX');

    IF(l_owrite_svc_desc_prf = 'Y') THEN --Overwrite Svc Description profile set to Yes
      IF(NVL(l_desc_update_flag, 'N') = 'N') THEN --Allow Description update set to No
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_SVC_DESC_NOCHNG');
        FND_MESSAGE.Set_Token('SERVICE_ITEM_NUMBER', l_svc_item_number);
        FND_MSG_PUB.ADD;
      ELSE
        BEGIN
          SELECT concatenated_segments INTO l_inv_item_number
            FROM mtl_system_items_kfv
           WHERE inventory_item_id = p_x_osp_order_line_rec.inventory_item_id
             AND organization_id = p_x_osp_order_line_rec.inventory_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PHY_ITEM_INVALID');
            FND_MSG_PUB.ADD;
        END;
        l_item_description :=
        SUBSTR(l_item_prefix||l_inv_item_number||' '||l_serial_prefix||p_x_osp_order_line_rec.serial_number,1,240);
      END IF;
    END IF;
      --mpothuku End
  END IF;

  --This is for deriving need_by_date from the profile option value and service_duration defined
  --at association between vendor and items combination
  BEGIN
    SELECT vendor_id, vendor_site_id
      INTO l_vendor_id, l_vendor_site_id
      FROM ahl_osp_orders_b
     WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id;
    IF (l_vendor_id IS NOT NULL AND l_vendor_site_id IS NOT NULL) THEN
      SELECT IV.service_duration INTO l_service_duration
        FROM ahl_inv_service_item_rels SI,
             ahl_item_vendor_rels IV,
             ahl_vendor_certifications_v VC
       WHERE SI.inv_item_id = p_x_osp_order_line_rec.inventory_item_id
         AND SI.inv_org_id = p_x_osp_order_line_rec.inventory_org_id
         AND SI.service_item_id = p_x_osp_order_line_rec.service_item_id
         AND VC.vendor_id = l_vendor_id
         AND VC.vendor_site_id = l_vendor_site_id
         AND SI.inv_service_item_rel_id = IV.inv_service_item_rel_id
         AND IV.vendor_certification_id = VC.vendor_certification_id
         AND trunc(SI.active_start_date) <= trunc(SYSDATE)
         AND trunc(nvl(SI.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
         AND trunc(IV.active_start_date) <= trunc(SYSDATE)
         AND trunc(nvl(IV.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
         AND trunc(VC.active_start_date) <= trunc(SYSDATE)
         AND trunc(nvl(VC.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
     ELSE
       l_service_duration := FND_PROFILE.value('AHL_VENDOR_SERVICE_DURATION');
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_service_duration := FND_PROFILE.value('AHL_VENDOR_SERVICE_DURATION');
  END;
  --In case service_duration returned from the above query is null
  IF l_service_duration IS NULL THEN
    l_service_duration := FND_PROFILE.value('AHL_VENDOR_SERVICE_DURATION');
  END IF;

-- yazhou 06-Jul-2006 starts
-- bug fix#5376907
-- Service item qty should be the same as physical item qty at the time of creation

  --Call table handler to insert the line
  AHL_OSP_ORDER_LINES_PKG.insert_row(
               p_x_osp_order_line_id => l_osp_line_id,
               p_object_version_number => 1,
               p_created_by => fnd_global.user_id,
               p_creation_date => SYSDATE,
               p_last_updated_by => fnd_global.user_id,
               p_last_update_date => SYSDATE,
               p_last_update_login => fnd_global.login_id,
               p_osp_order_id => p_x_osp_order_line_rec.osp_order_id,
               p_osp_line_number => l_osp_line_number,
               p_status_code => NULL, --Derived from header status when displaying
               p_po_line_type_id => to_number(FND_PROFILE.VALUE('AHL_OSP_PO_LINE_TYPE_ID')),
               p_service_item_id => p_x_osp_order_line_rec.service_item_id,
               p_service_item_description => l_item_description,
               p_service_item_uom_code => l_service_item_uom_code,
               p_need_by_date => TRUNC(SYSDATE+l_service_duration),
               p_ship_by_date => TRUNC(nvl(p_x_osp_order_line_rec.ship_by_date, SYSDATE)),
               p_po_line_id => NULL,
               -- by jaramana on January 10, 2008 to fix the Bug 5358438/5967633/5417460
               --p_po_line_id => p_x_osp_order_line_rec.po_line_id, --yazhou 28-jul-2006 bug#5417460
               p_oe_ship_line_id => NULL,
               p_oe_return_line_id => NULL,
               p_workorder_id => p_x_osp_order_line_rec.workorder_id,
               p_operation_id => NULL,
--               p_quantity => l_quantity,
               p_quantity => p_x_osp_order_line_rec.inventory_item_quantity,
               p_exchange_instance_id => NULL,
               p_inventory_item_id => p_x_osp_order_line_rec.inventory_item_id,
               p_inventory_org_id => p_x_osp_order_line_rec.inventory_org_id,
               p_sub_inventory => p_x_osp_order_line_rec.sub_inventory,
               p_lot_number => p_x_osp_order_line_rec.lot_number,
               p_serial_number => p_x_osp_order_line_rec.serial_number,
               p_inventory_item_uom => p_x_osp_order_line_rec.inventory_item_uom,
               p_inventory_item_quantity => p_x_osp_order_line_rec.inventory_item_quantity,
               -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
               p_po_req_line_id => NULL,
               -- jaramana End
               p_attribute_category => p_x_osp_order_line_rec.attribute_category,
               p_attribute1 => p_x_osp_order_line_rec.attribute1,
               p_attribute2 => p_x_osp_order_line_rec.attribute2,
               p_attribute3 => p_x_osp_order_line_rec.attribute3,
               p_attribute4 => p_x_osp_order_line_rec.attribute4,
               p_attribute5 => p_x_osp_order_line_rec.attribute5,
               p_attribute6 => p_x_osp_order_line_rec.attribute6,
               p_attribute7 => p_x_osp_order_line_rec.attribute7,
               p_attribute8 => p_x_osp_order_line_rec.attribute8,
               p_attribute9 => p_x_osp_order_line_rec.attribute9,
               p_attribute10 => p_x_osp_order_line_rec.attribute10,
               p_attribute11 => p_x_osp_order_line_rec.attribute11,
               p_attribute12 => p_x_osp_order_line_rec.attribute12,
               p_attribute13 => p_x_osp_order_line_rec.attribute13,
               p_attribute14 => p_x_osp_order_line_rec.attribute14,
               p_attribute15 => p_x_osp_order_line_rec.attribute15
             );
-- yazhou 06-Jul-2006 ends
  ELSE --IF(p_x_osp_order_line_rec.po_line_id is null) THEN,  which would mean po_line_id is passed

    --Purchasing allows past need_by_date as well, if so defaulting ship_by_date to the need_by_date
    --else initializing it to the sysdate
    --this field does not have much significance
    IF(trunc(p_x_osp_order_line_rec.need_by_date) <= trunc(sysdate)) THEN
      p_x_osp_order_line_rec.ship_by_date := p_x_osp_order_line_rec.need_by_date;
    ELSE
      p_x_osp_order_line_rec.ship_by_date := SYSDATE;
    END IF;

    --Call table handler to insert the line
    AHL_OSP_ORDER_LINES_PKG.insert_row(
                 p_x_osp_order_line_id => l_osp_line_id,
                 p_object_version_number => 1,
                 p_created_by => fnd_global.user_id,
                 p_creation_date => SYSDATE,
                 p_last_updated_by => fnd_global.user_id,
                 p_last_update_date => SYSDATE,
                 p_last_update_login => fnd_global.login_id,
                 p_osp_order_id => p_x_osp_order_line_rec.osp_order_id,
                 p_osp_line_number => l_osp_line_number,
                 p_status_code => NULL, --Derived from header status when displaying
                 p_po_line_type_id => p_x_osp_order_line_rec.po_line_type_id, --derived from PO Line
                 p_service_item_id => p_x_osp_order_line_rec.service_item_id, --derived from PO Line
                 p_service_item_description => p_x_osp_order_line_rec.service_item_description, --derived from PO Line
                 p_service_item_uom_code => p_x_osp_order_line_rec.service_item_uom_code, --derived from PO Line
                 p_need_by_date => p_x_osp_order_line_rec.need_by_date, --derived from PO Line
                 p_ship_by_date => p_x_osp_order_line_rec.ship_by_date,
                 p_po_line_id => p_x_osp_order_line_rec.po_line_id,
                 p_oe_ship_line_id => NULL,
                 p_oe_return_line_id => NULL,
                 p_workorder_id => p_x_osp_order_line_rec.workorder_id,
                 p_operation_id => NULL,
                 p_quantity => p_x_osp_order_line_rec.quantity, --derived from PO Line
                 p_exchange_instance_id => NULL,
                 p_inventory_item_id => p_x_osp_order_line_rec.inventory_item_id,
                 p_inventory_org_id => p_x_osp_order_line_rec.inventory_org_id,
                 p_sub_inventory => p_x_osp_order_line_rec.sub_inventory,
                 p_lot_number => p_x_osp_order_line_rec.lot_number,
                 p_serial_number => p_x_osp_order_line_rec.serial_number,
                 p_inventory_item_uom => p_x_osp_order_line_rec.inventory_item_uom,
                 p_inventory_item_quantity => p_x_osp_order_line_rec.inventory_item_quantity,
                 p_po_req_line_id => NULL,
                 p_attribute_category => p_x_osp_order_line_rec.attribute_category,
                 p_attribute1 => p_x_osp_order_line_rec.attribute1,
                 p_attribute2 => p_x_osp_order_line_rec.attribute2,
                 p_attribute3 => p_x_osp_order_line_rec.attribute3,
                 p_attribute4 => p_x_osp_order_line_rec.attribute4,
                 p_attribute5 => p_x_osp_order_line_rec.attribute5,
                 p_attribute6 => p_x_osp_order_line_rec.attribute6,
                 p_attribute7 => p_x_osp_order_line_rec.attribute7,
                 p_attribute8 => p_x_osp_order_line_rec.attribute8,
                 p_attribute9 => p_x_osp_order_line_rec.attribute9,
                 p_attribute10 => p_x_osp_order_line_rec.attribute10,
                 p_attribute11 => p_x_osp_order_line_rec.attribute11,
                 p_attribute12 => p_x_osp_order_line_rec.attribute12,
                 p_attribute13 => p_x_osp_order_line_rec.attribute13,
                 p_attribute14 => p_x_osp_order_line_rec.attribute14,
                 p_attribute15 => p_x_osp_order_line_rec.attribute15
               );

  END IF; --IF(p_x_osp_order_line_rec.po_line_id is null) THEN
  -- jaramana January 10, 2008 Bug 5358438/5967633/5417460 ends

  --Remember to return the line id created
  p_x_osp_order_line_rec.osp_order_line_id := l_osp_line_id;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX || '.create_osp_order_line', 'After insert operation:');
  END IF;

END create_osp_order_line;

--yazhou 07-Aug-2006 starts
-- bug fix#5448191

PROCEDURE create_shipment(p_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type)
--yazhou 07-Aug-2006 ends

IS
  l_oe_header_id       NUMBER;
  l_oe_header_rec      AHL_OSP_SHIPMENT_PUB.ship_header_rec_type;
  l_oe_lines_tbl       AHL_OSP_SHIPMENT_PUB.ship_line_tbl_type;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_create_shipment    BOOLEAN;
  l_osp_order_id       NUMBER;
  i                    NUMBER;
  j                    NUMBER;
  k                    NUMBER;
  l_create_ship_line   BOOLEAN;
  CURSOR check_ship_line_exists(c_inventory_item_id NUMBER,
                                c_inventory_org_id NUMBER,
                                c_serial_number VARCHAR2,
                                c_osp_order_id NUMBER) IS
    SELECT 'X'
      FROM ahl_osp_order_lines
     WHERE inventory_item_id = c_inventory_item_id
       AND inventory_org_id = c_inventory_org_id
       AND serial_number = c_serial_number
       AND osp_order_id = c_osp_order_id
       AND (oe_ship_line_id IS NOT NULL OR oe_return_line_id IS NOT NULL);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||'create_shipment','Begin');
  END IF;
  l_create_shipment := FALSE;
  IF p_osp_order_lines_tbl.count > 0 THEN
    FOR i IN p_osp_order_lines_tbl.FIRST..p_osp_order_lines_tbl.LAST LOOP

-- yazhou 07-Aug-2006 starts
-- bug fix#5448191
      IF p_osp_order_lines_tbl(i).operation_flag = G_OP_CREATE THEN

        IF p_osp_order_lines_tbl(i).shipment_creation_flag = G_YES_FLAG THEN
           IF NOT l_create_shipment THEN
             l_create_shipment := TRUE;
             l_osp_order_id := p_osp_order_lines_tbl(i).osp_order_id;
           END IF;
        ELSE
           -- turn on create shipment flag if shipments for the same physical item
           -- already exist, so that shipment can be associated to new OSP order line
           -- in AHL_OSP_SHIPMENT_PUB.process_order
           OPEN check_ship_line_exists(p_osp_order_lines_tbl(i).inventory_item_id,
                                        p_osp_order_lines_tbl(i).inventory_org_id,
                                        p_osp_order_lines_tbl(i).serial_number,
                                        p_osp_order_lines_tbl(i).osp_order_id);
            FETCH check_ship_line_exists INTO g_dummy_char;
            IF check_ship_line_exists%FOUND THEN
              p_osp_order_lines_tbl(i).shipment_creation_flag := G_YES_FLAG;
              IF NOT l_create_shipment THEN
                 l_create_shipment := TRUE;
                 l_osp_order_id := p_osp_order_lines_tbl(i).osp_order_id;
              END IF;
            END IF;

            CLOSE check_ship_line_exists;

        END IF;

        --EXIT;
      END IF;

-- yazhou 07-Aug-2006 ends

    END LOOP;
    --For safety purpose, just check whether shipment header already exists
    --This is probably not necessary
    IF l_create_shipment THEN
      BEGIN
        SELECT oe_header_id INTO l_oe_header_id
          FROM ahl_osp_orders_b
         WHERE osp_order_id = l_osp_order_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_INVALID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
      l_oe_header_rec.header_id := l_oe_header_id;
      l_oe_header_rec.osp_order_id := l_osp_order_id;
      IF l_oe_header_id IS NULL THEN
      --No shipment header/lines exist yet
        l_oe_header_rec.operation := G_OP_CREATE;
      ELSE
      --Already has shipment header, but no change to shipment header itself and
      --just adding new shipment lines to the existing shipment header
      --And try to make it the same as front end calling Shipment API for which
      --Shipment header as a whole is passed as null
        l_oe_header_rec.operation := NULL;
        l_oe_header_rec.header_id := NULL;

--yazhou 03-Aug-2006 starts
-- bug fix#5442904
-- osp_order_id is used in AHL_OSP_SHIPMENT_PUB.Process_Line_Tbl to fetch vendor info

--        l_oe_header_rec.osp_order_id := NULL;

--yazhou 03-Aug-2006 ends

      END IF;
      k := 1;
      FOR i IN p_osp_order_lines_tbl.FIRST..p_osp_order_lines_tbl.LAST LOOP
        IF (p_osp_order_lines_tbl(i).operation_flag = G_OP_CREATE AND
            p_osp_order_lines_tbl(i).shipment_creation_flag = G_YES_FLAG) THEN
          --Jerry added on 10/19/2005
          --Adding the following logic to check whether really needs to create shipment
          --line because for the same tracked item instance with different service time
          --combination, we still need to create one set of shipment lines. This is
          --feature is added for fixing bug 4571305

          l_create_ship_line := TRUE;
          IF l_oe_header_id IS NOT NULL THEN
            OPEN check_ship_line_exists(p_osp_order_lines_tbl(i).inventory_item_id,
                                        p_osp_order_lines_tbl(i).inventory_org_id,
                                        p_osp_order_lines_tbl(i).serial_number,
                                        p_osp_order_lines_tbl(i).osp_order_id);
            FETCH check_ship_line_exists INTO g_dummy_char;
            IF check_ship_line_exists%FOUND THEN
              l_create_ship_line := FALSE;
            ELSIF i > p_osp_order_lines_tbl.FIRST THEN
              FOR j IN p_osp_order_lines_tbl.FIRST .. i-1 LOOP
                IF (p_osp_order_lines_tbl(i).inventory_item_id = p_osp_order_lines_tbl(j).inventory_item_id AND
                    p_osp_order_lines_tbl(i).inventory_org_id = p_osp_order_lines_tbl(j).inventory_org_id AND
                    p_osp_order_lines_tbl(i).serial_number = p_osp_order_lines_tbl(j).serial_number AND
                    p_osp_order_lines_tbl(i).osp_order_id = p_osp_order_lines_tbl(j).osp_order_id) THEN
                  l_create_ship_line := FALSE;
                  EXIT;
                END IF;
              END LOOP;
            END IF;
            CLOSE check_ship_line_exists;
          ELSIF (l_oe_header_id IS NULL AND i > p_osp_order_lines_tbl.FIRST) THEN
            FOR j IN p_osp_order_lines_tbl.FIRST .. i-1 LOOP
              IF (p_osp_order_lines_tbl(i).inventory_item_id = p_osp_order_lines_tbl(j).inventory_item_id AND
                  p_osp_order_lines_tbl(i).inventory_org_id = p_osp_order_lines_tbl(j).inventory_org_id AND
                  p_osp_order_lines_tbl(i).serial_number = p_osp_order_lines_tbl(j).serial_number AND
                  p_osp_order_lines_tbl(i).osp_order_id = p_osp_order_lines_tbl(j).osp_order_id) THEN
                  l_create_ship_line := FALSE;
                EXIT;
              END IF;
            END LOOP;
          END IF;

          IF l_create_ship_line THEN
            l_oe_lines_tbl(k).header_id := l_oe_header_id;
            l_oe_lines_tbl(k).line_type_id := FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID');
            l_oe_lines_tbl(k).osp_order_id := p_osp_order_lines_tbl(i).osp_order_id;
            l_oe_lines_tbl(k).osp_line_id := p_osp_order_lines_tbl(i).osp_order_line_id;
            l_oe_lines_tbl(k).ship_from_org_id := p_osp_order_lines_tbl(i).inventory_org_id;
            /* The following will be derived from Shipment API
            l_oe_lines_tbl(k).inventory_item_id := p_osp_order_lines_tbl(i).inventory_item_id;
            l_oe_lines_tbl(k).inventory_org_id := p_osp_order_lines_tbl(i).inventory_org_id;
            l_oe_lines_tbl(k).subinventory := p_osp_order_lines_tbl(i).sub_inventory;
            l_oe_lines_tbl(k).serial_number := p_osp_order_lines_tbl(i).serial_number;
            l_oe_lines_tbl(k).lot_number := p_osp_order_lines_tbl(i).lot_number;
            */
            l_oe_lines_tbl(k).osp_line_flag := G_YES_FLAG;
            l_oe_lines_tbl(k).operation := G_OP_CREATE;

            l_oe_lines_tbl(k+1).header_id := l_oe_header_id;
            l_oe_lines_tbl(k+1).line_type_id := FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID');
            l_oe_lines_tbl(k+1).osp_order_id := p_osp_order_lines_tbl(i).osp_order_id;
            l_oe_lines_tbl(k+1).osp_line_id := p_osp_order_lines_tbl(i).osp_order_line_id;
            l_oe_lines_tbl(k+1).ship_from_org_id := p_osp_order_lines_tbl(i).inventory_org_id;
            /* The following will be derived from Shipment API
            l_oe_lines_tbl(k+1).inventory_item_id := p_osp_order_lines_tbl(i).inventory_item_id;
            l_oe_lines_tbl(k+1).inventory_org_id := p_osp_order_lines_tbl(i).inventory_org_id;
            l_oe_lines_tbl(k+1).subinventory := p_osp_order_lines_tbl(i).sub_inventory;
            l_oe_lines_tbl(k+1).serial_number := p_osp_order_lines_tbl(i).serial_number;
            l_oe_lines_tbl(k+1).lot_number := p_osp_order_lines_tbl(i).lot_number;
            */
            l_oe_lines_tbl(k+1).osp_line_flag := G_YES_FLAG;
            l_oe_lines_tbl(k+1).operation := G_OP_CREATE;
            --other attributes to populate
            k := k+2;
          END IF;
        END IF;
      END LOOP;
      IF (l_oe_lines_tbl.COUNT > 0 AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||'create_shipment','Before calling Shipment API: process_order and the parameters are'||
                   'oe_header='||l_oe_header_rec.header_id||' header_oper_flag='||l_oe_header_rec.operation||
                   'oe_line1_osp_order_id='||l_oe_lines_tbl(1).osp_order_id||'oe_line2_osp_line_id='||l_oe_lines_tbl(1).osp_line_id||
                   'oe_line_operation='||l_oe_lines_tbl(1).operation);
      END IF;
      AHL_OSP_SHIPMENT_PUB.process_order(
              p_api_version      => 1.0,
              p_init_msg_list    => FND_API.G_FALSE,
              p_commit           => FND_API.G_FALSE,
              p_validation_level => FND_API.G_VALID_LEVEL_FULL,
              --Changed by mpothuku on 14-Dec-05 to differentiate the call from here and from
              --Shipment Line Details UI. Note that Shipment Line Details will be using OAF as the p_module_type
              p_module_type      => NULL,--G_OAF_MODULE,
              p_x_header_rec     => l_oe_header_rec,
              p_x_lines_tbl 	 => l_oe_lines_tbl,
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data);
    END IF;
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||'create_shipment',
                   'End: after calling shipment creation API and x_return_status='||l_return_status);
  END IF;
END create_shipment;

PROCEDURE validate_order_line_creation(p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type)
IS
  CURSOR check_physical_item(c_inventory_item_id NUMBER, c_inventory_org_id NUMBER) IS
    SELECT organization_id,
           inventory_item_id,
           concatenated_segments,
           primary_uom_code,
           serial_number_control_code,
           lot_control_code,
           comms_nl_trackable_flag
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = c_inventory_item_id
       AND organization_id = c_inventory_org_id;
  l_check_physical_item check_physical_item%ROWTYPE;
  CURSOR check_sub_inventory(c_organization_id NUMBER, c_sub_inventory VARCHAR2) IS
    SELECT 'X'
      FROM mtl_secondary_inventories
     WHERE organization_id = c_organization_id
       AND secondary_inventory_name = c_sub_inventory;
  CURSOR check_serial_number (c_inv_item_id NUMBER, c_serial_number VARCHAR2) IS
    SELECT 'X'
      FROM mtl_serial_numbers
     WHERE inventory_item_id = c_inv_item_id
       AND serial_number = c_serial_number;
  CURSOR check_lot_number (c_inv_item_id NUMBER, c_org_id NUMBER, c_lot_number VARCHAR2) IS
    SELECT 'X'
      FROM mtl_lot_numbers
     WHERE inventory_item_id = c_inv_item_id
       AND organization_id = c_org_id
       AND lot_number = c_lot_number;

  -- Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164 and also added subinventory to
  --calculate the onhand quantity correctly.
  CURSOR get_onhand_quantity(c_inv_item_id NUMBER, c_inv_org_id NUMBER, c_subinv VARCHAR2, c_lot_number VARCHAR2) IS
	--Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
    SELECT ahl_osp_queries_pvt.get_onhand_quantity(c_inv_org_id, c_subinv, c_inv_item_id, c_lot_number)  onhand_quantity,        primary_uom_code uom_code
      FROM mtl_system_items_b
     WHERE inventory_item_id = c_inv_item_id
       AND organization_id = c_inv_org_id;
  CURSOR check_phy_ser_item_unique(c_osp_order_id NUMBER,
                                   c_service_item_id NUMBER,
                                   c_inv_item_id NUMBER,
                                   c_inv_org_id NUMBER,
                                   c_lot_number VARCHAR2,
                                   c_serial_number VARCHAR2) IS
    SELECT 'X'
      FROM ahl_osp_order_lines
     WHERE osp_order_id = c_osp_order_id
       AND ((service_item_id = c_service_item_id) OR
            (service_item_id IS NULL AND c_service_item_id IS NULL))
       AND inventory_item_id = c_inv_item_id
       AND inventory_org_id = c_inv_org_id
       AND ((lot_number IS NULL AND c_lot_number IS NULL) OR (lot_number = c_lot_number))
       AND ((serial_number IS NULL AND c_serial_number IS NULL) OR (serial_number = c_serial_number));
  CURSOR check_phy_item_unique(c_osp_order_id NUMBER, c_inv_item_id NUMBER) IS
    SELECT 'X'
      FROM ahl_osp_order_lines
     WHERE inventory_item_id = c_inv_item_id
       AND osp_order_id = c_osp_order_id;

--yazhou 22-Aug-2006 starts
-- Bug fix#5479266

/*
  CURSOR check_osp_order_unique(c_osp_order_id NUMBER, c_inventory_item_id NUMBER,
                                c_inventory_org_id NUMBER, c_serial_number VARCHAR2) IS
   SELECT 'X'
     FROM ahl_osp_order_lines ospl, ahl_osp_orders_b osp
    WHERE ospl.osp_order_id = osp.osp_order_id
      AND osp.status_code <> 'CLOSED'
      AND ospl.status_code is null
      AND ospl.inventory_item_id = c_inventory_item_id
      AND ospl.inventory_org_id = c_inventory_org_id
      AND NVL (ospl.serial_number, 'XXX') = NVL (c_serial_number, 'XXX')
      AND osp.osp_order_id <> c_osp_order_id;
*/
-- Added by jaramana on January 10, 2008 for the Bug 5547870/5673279
  CURSOR check_osp_order_unique(c_osp_order_id NUMBER, c_inventory_item_id NUMBER,
                                c_inventory_org_id NUMBER, c_serial_number VARCHAR2) IS
   SELECT 'X'
     FROM ahl_osp_order_lines ospl, ahl_osp_orders_b osp, oe_order_lines_all oelship
    WHERE ospl.osp_order_id = osp.osp_order_id
      AND osp.status_code <> 'CLOSED'
      AND oelship.LINE_ID = ospl.OE_SHIP_LINE_ID
      --The order line should not be closed and should not be cancelled to be considered in the uniqueness check
      AND (nvl(oelship.cancelled_flag, 'N') <> 'Y' OR nvl(oelship.flow_status_code, 'XXX') <> 'CANCELLED')
      AND (oelship.open_flag <> 'N' OR nvl(oelship.flow_status_code, 'XXX') <> 'CLOSED')
      AND ospl.inventory_item_id = c_inventory_item_id
      AND ospl.inventory_org_id = c_inventory_org_id
      AND NVL (ospl.serial_number, 'XXX') = NVL (c_serial_number, 'XXX')
      AND osp.osp_order_id <> c_osp_order_id;

  -- Added by jaramana on January 10, 2008 for the Bug 5358438/5967633/5417460
  CURSOR get_wo_item_attrs(c_workorder_id NUMBER) IS
    SELECT vts.inventory_item_id,
           vst.organization_id,
           csii.lot_number,
           csii.serial_number,
           csii.quantity,
           csii.unit_of_measure item_instance_uom,
           arb.service_item_id,
           mtls.description service_item_description,
           mtls.primary_uom_code service_item_uom
      FROM ahl_workorders wo,
           ahl_visits_b vst,
           ahl_visit_tasks_b vts,
           csi_item_instances csii,
           mtl_system_items_kfv mtls,
           ahl_routes_b arb
     WHERE workorder_id = c_workorder_id
       AND wo.visit_task_id = vts.visit_task_id
       AND vst.visit_id = vts.visit_id
       AND wo.route_id = arb.route_id(+)
       AND arb.service_item_org_id = mtls.organization_id(+)
       AND arb.service_item_id = mtls.inventory_item_id(+)
       AND vts.instance_id = csii.instance_id;

  -- Added by jaramana on January 10, 2008 for the Bug 5358438/5967633/5417460
  --Get the PO Line attributes and the need_by_date from the first record of po_line_locations_all
  CURSOR get_po_line_attrs(c_po_line_id NUMBER) IS
    SELECT pol.line_num,
           pol.item_id,
           pol.item_description,
           pol.line_type_id,
           uom.uom_code,
           pol.quantity,
           (select min(need_by_date)
              from po_line_locations_all
             where po_line_id = pol.po_line_id
               and po_header_id = pol.po_header_id) need_by_date
      FROM po_lines_all pol,
           mtl_units_of_measure_vl uom
     WHERE pol.po_line_id = c_po_line_id
       AND uom.unit_of_measure = pol.unit_meas_lookup_code;
  -- jaramana January 10, 2008 Ends
--yazhou 22-Aug-2006 ends

  l_vendor_id         NUMBER;
  l_vendor_site_id    NUMBER;
  l_vendor_contact_id NUMBER;
  l_quantity          NUMBER;
  l_onhand_quantity   NUMBER;
  l_uom_code          VARCHAR2(3);
  l_po_line_attrs     get_po_line_attrs%ROWTYPE;
  L_DEBUG_KEY         CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_order_line_creation';

BEGIN
  --Suppose all value id conversion has been done.
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX || '.validate_order_line_creation', 'Begin:');
  END IF;
  --For OAF, we decided to pass null when you want to change it to null, the old value if there is no
  --change.
  IF nvl(g_module_type, 'NULL') <> G_OAF_MODULE THEN
    default_unchanged_order_line(p_x_osp_order_line_rec);
  END IF;

  --And need to adde value to id conversion here
  convert_order_line_val_to_id(p_x_osp_order_line_rec);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || 'create_osp_order_line',
    'osp_order_id='||p_x_osp_order_line_rec.osp_order_id);
  END IF;
  --Validate osp_order_id
  BEGIN

-- yazhou 28-jul-2006 starts
-- bug#5417460
   IF p_x_osp_order_line_rec.po_line_id is not null and p_x_osp_order_line_rec.workorder_id is not null then
    SELECT osp_order_id INTO g_dummy_num
      FROM ahl_osp_orders_b
     WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id
       AND status_code = G_OSP_PO_CREATED_STATUS
       -- Added by jaramana on January 10, 2008 for the Bug 5358438/5967633/5417460
       --Pos are not applying to the other order types.
       AND order_type_code IN (G_OSP_ORDER_TYPE_SERVICE, G_OSP_ORDER_TYPE_EXCHANGE)
       -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
       --If we are creating an osp order line based on PO line that is created from the Purchasing forms, then
       --the work order selected for the order Line, should not be associated with any open order lines
       --Note that instead of status_code not in, we could have use status_code is null as well.
       AND not exists (select 1
                         from ahl_osp_order_lines
                         where workorder_id =p_x_osp_order_line_rec.workorder_id
                           and nvl(status_code, 'X') not in (G_OL_PO_CANCELLED_STATUS, G_OL_PO_DELETED_STATUS, G_OL_REQ_CANCELLED_STATUS, G_OL_REQ_DELETED_STATUS));
       -- jaramana End
   ELSE
    SELECT osp_order_id INTO g_dummy_num
      FROM ahl_osp_orders_b
     WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id
       -- jaramana modified on January 10, 2008 for the Requisition ER 6034236 (Added G_OSP_REQ_SUB_FAILED_STATUS)
       AND status_code IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS);
       -- jaramana End
   END IF;
-- yazhou 28-jul-2006 ends

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORD_INVALID');
      FND_MSG_PUB.add;
  END;

  -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236 (partial fix for the Bug 5358438/5967633/5417460)
  --po_line_id should be passed only along with the work_order_id
  --value to id conversion should already have taken place, so even if the user passes job_number,
  --we would have derived the workorder_id
  IF p_x_osp_order_line_rec.po_line_id is not null and p_x_osp_order_line_rec.workorder_id is not null THEN
    validate_po_line(p_x_osp_order_line_rec.po_line_id, p_x_osp_order_line_rec.osp_order_id);
  ELSIF (p_x_osp_order_line_rec.po_line_id is not null and p_x_osp_order_line_rec.workorder_id is null) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_WO_NLL_CR_POL');
    FND_MSG_PUB.add;
  END IF;
  -- jaramna End

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || '.validate_order_line_creation', 'item='||p_x_osp_order_line_rec.inventory_item_id||'org='||p_x_osp_order_line_rec.inventory_org_id);
  END IF;
  IF (p_x_osp_order_line_rec.workorder_id IS NULL AND p_x_osp_order_line_rec.inventory_item_id IS NULL) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_WO_ITEM_ALL_NULL');
    FND_MSG_PUB.add;
  --Validate workorder_id (borrow the old code)
  ELSIF(p_x_osp_order_line_rec.workorder_id IS NOT NULL) THEN
    validate_workorder(p_x_osp_order_line_rec.workorder_id);
  --Validate physical item
  ELSIF (p_x_osp_order_line_rec.inventory_item_id IS NOT NULL) THEN
    IF (p_x_osp_order_line_rec.inventory_org_id IS NULL) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_ORG_NULL');
      FND_MSG_PUB.add;
    END IF;
    OPEN check_physical_item(p_x_osp_order_line_rec.inventory_item_id,
                             p_x_osp_order_line_rec.inventory_org_id);
    FETCH check_physical_item INTO l_check_physical_item;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || '.validate_order_line_creation', 'track_flag='||l_check_physical_item.comms_nl_trackable_flag);
    END IF;
    IF check_physical_item%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_INVALID');
      FND_MSG_PUB.add;
    ELSE
      IF (p_x_osp_order_line_rec.sub_inventory IS NOT NULL) THEN
        OPEN check_sub_inventory(p_x_osp_order_line_rec.inventory_org_id,
                                 p_x_osp_order_line_rec.sub_inventory);
        FETCH check_sub_inventory INTO g_dummy_char;
        IF check_sub_inventory%NOTFOUND THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_SUB_INV_INVALID');
          FND_MSG_PUB.add;
        END IF;
        CLOSE check_sub_inventory;
      END IF;

      --Non tracked physical item's quantity (to be serviced) is manadatory
      IF (nvl(l_check_physical_item.comms_nl_trackable_flag, 'N')='N' AND
          (p_x_osp_order_line_rec.inventory_item_quantity IS NULL)) THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_QTY_REQUIRED');
        FND_MSG_PUB.add;
      END IF;

	  /*
	  Comment Added by mpothuku on 27-Feb-06: May need to revise this logic
	  as the checks below will not cater to serial and lot controlled items
	  */
      IF l_check_physical_item.serial_number_control_code IN (2, 5, 6) THEN
        OPEN check_serial_number(p_x_osp_order_line_rec.inventory_item_id,
                                 p_x_osp_order_line_rec.serial_number);
        FETCH check_serial_number INTO g_dummy_char;
        IF check_serial_number%NOTFOUND THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_SN_INVALID');
          FND_MSG_PUB.add;
        ELSIF p_x_osp_order_line_rec.inventory_item_quantity <> 1 THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_QT_INVALID');
          FND_MSG_PUB.add;
        END IF;
        CLOSE check_serial_number;
      ELSIF l_check_physical_item.lot_control_code = 2 THEN
        OPEN check_lot_number(p_x_osp_order_line_rec.inventory_item_id,
                              p_x_osp_order_line_rec.inventory_org_id,
                              p_x_osp_order_line_rec.lot_number);
        FETCH check_lot_number INTO g_dummy_char;
        IF check_lot_number%NOTFOUND THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_LOT_INVALID');
          FND_MSG_PUB.add;
        END IF;
        CLOSE check_lot_number;
      --Validate the onhand quantity with the quantity to be serviced
      --Subinventory_code added by mpothuku on 27-Feb-06 to fix the Perf bug #4919164
      ELSIF nvl(l_check_physical_item.comms_nl_trackable_flag, 'N')='N' THEN
        OPEN get_onhand_quantity(p_x_osp_order_line_rec.inventory_item_id,
                                 p_x_osp_order_line_rec.inventory_org_id,
                                 p_x_osp_order_line_rec.sub_inventory,
                                 --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
                                 p_x_osp_order_line_rec.lot_number);
        FETCH get_onhand_quantity INTO l_onhand_quantity, l_uom_code;
        IF get_onhand_quantity%NOTFOUND THEN
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PHY_ITEM_INVALID');
          FND_MSG_PUB.add;
        END IF;
        CLOSE get_onhand_quantity;
        IF (l_onhand_quantity IS NOT NULL AND l_uom_code IS NOT NULL) THEN
          --l_uom_code is primary_uom_code
          --convert the inventory_item_uom to l_uom_code
          IF (p_x_osp_order_line_rec.inventory_item_quantity IS NOT NULL AND
              p_x_osp_order_line_rec.inventory_item_uom IS NOT NULL) THEN
            l_quantity := inv_convert.inv_um_convert(
                               item_id        => p_x_osp_order_line_rec.inventory_item_id,
                               precision      => 6,
                               from_quantity  => p_x_osp_order_line_rec.inventory_item_quantity,
                               from_unit      => p_x_osp_order_line_rec.inventory_item_uom,
                               to_unit        => l_uom_code,
                               from_name      => NULL,
                               to_name        => NULL);
            IF (l_quantity > l_onhand_quantity) THEN
              FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_ONHAND_LESS_SERV');
              FND_MSG_PUB.add;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    CLOSE check_physical_item;
  END IF;

  -- Added by jaramana on January 10, 2008 for the Bug 5358438/5967633/5417460
  /*
  1. Retrieve the ITEM_ID, ITEM_DESCRIPTION, UNIT_MEAS_LOOKUP_CODE, QUANTITY, LINE_TYPE_ID
     from PO_LINES_All corresponding to the PO_LINE_ID passed
  2. ITEM_ID and ITEM_DESCRIPTION cannot both be null
  3. If ITEM_ID is not null, validate it agains the work order's service_item_id
  6. UNIT_MEAS_LOOKUP_CODE, QUANTITY, LINE_TYPE_ID, NEED_BY_DATE are mandatory
  */

  --We already added the check that if the po_line_id is not null, the workorder_id also should not be null
  IF(p_x_osp_order_line_rec.po_line_id is NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.po_line_id='||p_x_osp_order_line_rec.po_line_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.workorder_id='||p_x_osp_order_line_rec.workorder_id);
    END IF;

    OPEN get_wo_item_attrs(p_x_osp_order_line_rec.workorder_id);
    FETCH get_wo_item_attrs INTO p_x_osp_order_line_rec.inventory_item_id,
                                 p_x_osp_order_line_rec.inventory_org_id,
                                 p_x_osp_order_line_rec.lot_number,
                                 p_x_osp_order_line_rec.serial_number,
                                 p_x_osp_order_line_rec.inventory_item_quantity,
                                 p_x_osp_order_line_rec.inventory_item_uom,
                                 p_x_osp_order_line_rec.service_item_id,
                                 p_x_osp_order_line_rec.service_item_description,
                                 p_x_osp_order_line_rec.service_item_uom_code;

    CLOSE get_wo_item_attrs;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.service_item_id ='||p_x_osp_order_line_rec.service_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.service_item_description ='||p_x_osp_order_line_rec.service_item_description);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.service_item_uom_code ='||p_x_osp_order_line_rec.service_item_uom_code);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_osp_order_line_rec.po_line_id='||p_x_osp_order_line_rec.po_line_id);
    END IF;

    OPEN get_po_line_attrs(p_x_osp_order_line_rec.po_line_id);
    FETCH get_po_line_attrs INTO l_po_line_attrs.line_num,
                                 l_po_line_attrs.item_id,
                                 l_po_line_attrs.item_description,
                                 l_po_line_attrs.line_type_id,
                                 l_po_line_attrs.uom_code,
                                 l_po_line_attrs.quantity,
                                 l_po_line_attrs.need_by_date;
    CLOSE get_po_line_attrs;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.line_num ='||l_po_line_attrs.line_num);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.item_id ='||l_po_line_attrs.item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.item_description ='||l_po_line_attrs.item_description);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.line_type_id ='||l_po_line_attrs.line_type_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.uom_code ='||l_po_line_attrs.uom_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.quantity ='||l_po_line_attrs.quantity);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_po_line_attrs.need_by_date ='||l_po_line_attrs.need_by_date);
    END IF;


    IF (l_po_line_attrs.item_id is null and l_po_line_attrs.item_description is null) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_POL_ITEM_ID_DESC_NLL');
      FND_MESSAGE.Set_Token('LINE_NUM', l_po_line_attrs.line_num);
      FND_MSG_PUB.ADD;
    END IF;

    IF (l_po_line_attrs.line_type_id is null) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_POL_TYPE_NLL');
      FND_MESSAGE.Set_Token('LINE_NUM', l_po_line_attrs.line_num);
      FND_MSG_PUB.ADD;
    END IF;

    IF (l_po_line_attrs.uom_code is null) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_POL_UOM_NLL');
      FND_MESSAGE.Set_Token('LINE_NUM', l_po_line_attrs.line_num);
      FND_MSG_PUB.ADD;
    END IF;

    IF (l_po_line_attrs.quantity is null) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_POL_QUANT_NLL');
      FND_MESSAGE.Set_Token('LINE_NUM', l_po_line_attrs.line_num);
      FND_MSG_PUB.ADD;
    END IF;

    IF (l_po_line_attrs.need_by_date is null) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_POL_NBDATE_NLL');
      FND_MESSAGE.Set_Token('LINE_NUM', l_po_line_attrs.line_num);
      FND_MSG_PUB.ADD;
    END IF;

  END IF;

  --If the po_line_id is passed validate the attributes got from the PO Line
  IF(p_x_osp_order_line_rec.po_line_id is NOT NULL) THEN
    /*
    Note that the messages below will not have PO line numbers associated. They will not ideally occur from
    front end as the front LOV already will filter records according to the conditions below
    and moreover the data from po_lines_all should not have the below errors unless manually changed in the tables
    */
    val_svc_item_vs_wo_svc_item (p_x_osp_order_line_rec.workorder_id, l_po_line_attrs.item_id);
    validate_service_item_uom(l_po_line_attrs.item_id, p_x_osp_order_line_rec.service_item_uom_code, p_x_osp_order_line_rec.inventory_org_id);
    IF(l_po_line_attrs.quantity <=0)  THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_VAL');
      FND_MESSAGE.Set_Token('QUANTITY', p_x_osp_order_line_rec.quantity);
      FND_MSG_PUB.ADD;
    END IF;
    validate_po_line_type(l_po_line_attrs.line_type_id);
    --Assign the attributes from the po line to the osp line
    --over-write the ones defined at the workorder route level
    p_x_osp_order_line_rec.service_item_id := l_po_line_attrs.item_id;
    p_x_osp_order_line_rec.service_item_description := l_po_line_attrs.item_description;
    p_x_osp_order_line_rec.service_item_uom_code := l_po_line_attrs.uom_code;

    p_x_osp_order_line_rec.po_line_type_id := l_po_line_attrs.line_type_id;
    p_x_osp_order_line_rec.quantity := l_po_line_attrs.quantity;
    p_x_osp_order_line_rec.need_by_date := l_po_line_attrs.need_by_date;

  ELSE --retain the existing logic

  --validate service_item_id (simplfied the original one)
  --All the service item related attributes validations are applicable only
  --when the service item is provided
  /* Comment Added by mpothuku on 28-Feb-06: Note that for workorder based lines, the service item defined
     at the route level is not yet defaulted, so for such lines both the service_item_id and service_item_uom are null and also there is no need to validate these for the workorder based lines */
  IF (p_x_osp_order_line_rec.service_item_id IS NOT NULL) THEN
    validate_service_item_id(p_x_osp_order_line_rec.service_item_id, p_x_osp_order_line_rec.inventory_org_id);
    --validate service_item_description
    --it is not necessary to add the original one here.
    --validate sercice_item_uom (just borrowed the old one)
    validate_service_item_uom(p_x_osp_order_line_rec.service_item_id, p_x_osp_order_line_rec.service_item_uom_code, p_x_osp_order_line_rec.inventory_org_id);
    --validate sercice_item_quantity(quantity)
    IF (p_x_osp_order_line_rec.quantity IS NOT NULL AND p_x_osp_order_line_rec.quantity <> FND_API.G_MISS_NUM) THEN
      IF(p_x_osp_order_line_rec.quantity <=0)  THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_VAL');
        FND_MESSAGE.Set_Token('QUANTITY', p_x_osp_order_line_rec.quantity);
        FND_MSG_PUB.ADD;
      END IF;
    --quantity cannot be null when UOM is not null
    ELSIF (p_x_osp_order_line_rec.service_item_uom_code IS NOT NULL AND p_x_osp_order_line_rec.service_item_uom_code <> FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_NLL');
      FND_MSG_PUB.ADD;
    END IF;

    --Validate header vendor with physical, service item combination in line
    --validate_vendor_service_item(p_x_osp_order_line_rec);
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX || '.validate_order_line_creation', 'Normal End.');
    END IF;
  END IF;

  --yazhou 22-Aug-2006 starts
  -- Bug fix#5479266
  -- For serial controlled items, check whether another OSP order
  -- has already been created for the same item.

   IF l_check_physical_item.serial_number_control_code IN (2, 5, 6) THEN

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || '.validate_order_line_creation', 'osp_order_id='||p_x_osp_order_line_rec.osp_order_id||'lot_number='||p_x_osp_order_line_rec.lot_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_LOG_PREFIX || '.validate_order_line_creation', 'serial_number='||p_x_osp_order_line_rec.serial_number);
    END IF;

     OPEN check_osp_order_unique(p_x_osp_order_line_rec.osp_order_id,
                                 p_x_osp_order_line_rec.inventory_item_id,
                                 p_x_osp_order_line_rec.inventory_org_id,
                                 p_x_osp_order_line_rec.serial_number);

      FETCH check_osp_order_unique INTO g_dummy_char;

      IF check_osp_order_unique%FOUND THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PHY_ITEM_UNIUE');
         FND_MSG_PUB.ADD;
      END IF;
      CLOSE check_osp_order_unique;
   END IF;
  --yazhou 22-Aug-2006 ends

  --For tracked item, same physical item and service item combination can only appear once in a given OSP order header
  --While for non tracked item, same physical item can only appear once in a given OSP order header
  IF (p_x_osp_order_line_rec.workorder_id IS NULL) THEN
    IF (nvl(l_check_physical_item.comms_nl_trackable_flag, 'N')='N') THEN
      OPEN check_phy_item_unique(p_x_osp_order_line_rec.osp_order_id,
                                 p_x_osp_order_line_rec.inventory_item_id);
      FETCH check_phy_item_unique INTO g_dummy_char;
      IF check_phy_item_unique%FOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PHY_ITEM_UNIUE');
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE check_phy_item_unique;
    --ELSIF (p_x_osp_order_line_rec.service_item_id IS NOT NULL) THEN
    --The cursor query contains the case which service_item_id is null
    ELSE
      OPEN check_phy_ser_item_unique(p_x_osp_order_line_rec.osp_order_id,
                                     p_x_osp_order_line_rec.service_item_id,
                                     p_x_osp_order_line_rec.inventory_item_id,
                                     p_x_osp_order_line_rec.inventory_org_id,
                                     p_x_osp_order_line_rec.lot_number,
                                     p_x_osp_order_line_rec.serial_number);
      FETCH check_phy_ser_item_unique INTO g_dummy_char;
      IF check_phy_ser_item_unique%FOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PHY_SER_ITEM_UNIUE');
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE check_phy_ser_item_unique;
    END IF;
  END IF;

  END IF;--IF(p_x_osp_order_line_rec.po_line_id is NOT NULL)
  -- jaramana January 10, 2008 Bug 5358438/5967633/5417460 Ends

END validate_order_line_creation;

PROCEDURE update_osp_order_line(p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type)
IS
  l_osp_line_id              NUMBER;
  l_osp_line_number          NUMBER;
  l_return_status            VARCHAR2(1);
  l_organization_id          NUMBER;
  l_inventory_item_id        NUMBER;
  l_service_item_id          NUMBER;
  l_service_duration         NUMBER;
BEGIN
  validate_order_line_update(p_x_osp_order_line_rec);
  --call table handler to update the record
  AHL_OSP_ORDER_LINES_PKG.update_row(
           p_osp_order_line_id => p_x_osp_order_line_rec.osp_order_line_id,
           p_object_version_number => p_x_osp_order_line_rec.object_version_number +1,
           p_osp_order_id => p_x_osp_order_line_rec.osp_order_id,
           p_osp_line_number => p_x_osp_order_line_rec.osp_line_number,
           p_status_code => p_x_osp_order_line_rec.status_code,
           p_po_line_type_id => p_x_osp_order_line_rec.po_line_type_id,
           p_service_item_id => p_x_osp_order_line_rec.service_item_id,
           p_service_item_description => p_x_osp_order_line_rec.service_item_description,
           p_service_item_uom_code => p_x_osp_order_line_rec.service_item_uom_code,
           p_need_by_date => TRUNC(p_x_osp_order_line_rec.need_by_date),
           p_ship_by_date => TRUNC(p_x_osp_order_line_rec.ship_by_date),
           p_po_line_id => p_x_osp_order_line_rec.po_line_id,
           p_oe_ship_line_id => p_x_osp_order_line_rec.oe_ship_line_id,
           p_oe_return_line_id => p_x_osp_order_line_rec.oe_return_line_id,
           p_workorder_id => p_x_osp_order_line_rec.workorder_id,
           p_operation_id => p_x_osp_order_line_rec.operation_id,
           p_quantity => p_x_osp_order_line_rec.quantity,
           p_exchange_instance_id    => p_x_osp_order_line_rec.exchange_instance_id,
           p_inventory_item_id       => p_x_osp_order_line_rec.inventory_item_id,
           p_inventory_org_id        => p_x_osp_order_line_rec.inventory_org_id,
           p_inventory_item_uom      => p_x_osp_order_line_rec.inventory_item_uom,
           p_inventory_item_quantity => p_x_osp_order_line_rec.inventory_item_quantity,
           p_sub_inventory           => p_x_osp_order_line_rec.sub_inventory,
           p_lot_number              => p_x_osp_order_line_rec.lot_number,
           p_serial_number           => p_x_osp_order_line_rec.serial_number,
-- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
           p_po_req_line_id          => p_x_osp_order_line_rec.po_req_line_id,
-- jaramana End
           p_attribute_category => p_x_osp_order_line_rec.attribute_category,
           p_attribute1 => p_x_osp_order_line_rec.attribute1,
           p_attribute2 => p_x_osp_order_line_rec.attribute2,
           p_attribute3 => p_x_osp_order_line_rec.attribute3,
           p_attribute4 => p_x_osp_order_line_rec.attribute4,
           p_attribute5 => p_x_osp_order_line_rec.attribute5,
           p_attribute6 => p_x_osp_order_line_rec.attribute6,
           p_attribute7 => p_x_osp_order_line_rec.attribute7,
           p_attribute8 => p_x_osp_order_line_rec.attribute8,
           p_attribute9 => p_x_osp_order_line_rec.attribute9,
           p_attribute10 => p_x_osp_order_line_rec.attribute10,
           p_attribute11 => p_x_osp_order_line_rec.attribute11,
           p_attribute12 => p_x_osp_order_line_rec.attribute12,
           p_attribute13 => p_x_osp_order_line_rec.attribute13,
           p_attribute14 => p_x_osp_order_line_rec.attribute14,
           p_attribute15 => p_x_osp_order_line_rec.attribute15,
           p_last_updated_by => FND_GLOBAL.user_id,
           p_last_update_date => SYSDATE,
           p_last_update_login => FND_GLOBAL.login_id
         );
END update_osp_order_line;

PROCEDURE validate_order_line_update(p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type)
IS
  l_osp_line_id              NUMBER;
  l_osp_line_number          NUMBER;
  l_return_status            VARCHAR2(1);
  l_organization_id          NUMBER;
  l_inventory_item_id        NUMBER;
  l_service_item_id          NUMBER;
  l_service_duration         NUMBER;
  l_trackable_flag           VARCHAR2(1);
  l_header_status_code       VARCHAR2(30);
  l_item_description         VARCHAR2(240);
  l_desc_update_flag         VARCHAR2(1);
  CURSOR osp_order_line_csr IS
    SELECT *
      FROM ahl_osp_order_lines
     WHERE osp_order_line_id = p_x_osp_order_line_rec.osp_order_line_id
       AND object_version_number= p_x_osp_order_line_rec.object_version_number;
  l_osp_order_line_rec osp_order_line_csr%ROWTYPE;
  CURSOR check_phy_ser_item_unique(c_osp_order_id NUMBER,
                                   c_service_item_id NUMBER,
                                   c_inv_item_id NUMBER,
                                   c_inv_org_id NUMBER,
                                   c_lot_number VARCHAR2,
                                   c_serial_number VARCHAR2) IS
    SELECT 'X'
      FROM ahl_osp_order_lines
     WHERE osp_order_id = c_osp_order_id
       AND ((service_item_id = c_service_item_id) OR
            (service_item_id IS NULL AND c_service_item_id IS NULL))
       AND inventory_item_id = c_inv_item_id
       AND inventory_org_id = c_inv_org_id
       AND ((lot_number IS NULL AND c_lot_number IS NULL) OR (lot_number = c_lot_number))
       AND ((serial_number IS NULL AND c_serial_number IS NULL) OR (serial_number = c_serial_number));
  CURSOR check_phy_item_unique(c_osp_order_id NUMBER, c_inv_item_id NUMBER) IS
    SELECT 'X'
      FROM ahl_osp_order_lines
     WHERE inventory_item_id = c_inv_item_id
       AND osp_order_id = c_osp_order_id;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_order_line_update';
  --Added by mpothuku on 24-Mar-06 for ER: 4544654
  l_owrite_svc_desc_prf VARCHAR2(1);
  l_item_prefix         VARCHAR2(240);
  l_serial_prefix       VARCHAR2(240);
  l_inv_item_number     VARCHAR2(40);
  l_svc_item_number     VARCHAR2(40);
  --mpothuku end
BEGIN
  --For OAF, the default logic may not be necessary
  --we decided to pass null when you want to change it to null, the old value if there is no change.
  IF nvl(g_module_type, 'NULL') <> G_OAF_MODULE THEN
    default_unchanged_order_line(p_x_osp_order_line_rec);
  END IF;
  convert_order_line_val_to_id(p_x_osp_order_line_rec);
  --Add the other validations here
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
  END IF;
  IF(p_x_osp_order_line_rec.osp_order_line_id IS NULL OR p_x_osp_order_line_rec.object_version_number IS NULL) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_ID_OBJ_MISS');
    FND_MSG_PUB.ADD;
  ELSE
    OPEN osp_order_line_csr;
    FETCH osp_order_line_csr INTO l_osp_order_line_rec;
    IF (osp_order_line_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INVOP_OSP_LN_NFOUND');
      FND_MSG_PUB.ADD;
    ELSE
      --The following attributes can't be changed once created
      --osp_order_id can't be changed, and osp_order_id is required
      IF(p_x_osp_order_line_rec.osp_order_id IS NULL OR
         p_x_osp_order_line_rec.osp_order_id <> l_osp_order_line_rec.osp_order_id) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_ORD_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --osp_order_number can't be changed and osp_order_number is required
      IF(p_x_osp_order_line_rec.osp_line_number IS NULL OR
         p_x_osp_order_line_rec.osp_line_number <> l_osp_order_line_rec.osp_line_number) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_LN_NUM_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --workorder_id can't be changed but workorder can be null
      IF((p_x_osp_order_line_rec.workorder_id <> l_osp_order_line_rec.workorder_id) OR
         (p_x_osp_order_line_rec.workorder_id IS NOT NULL AND l_osp_order_line_rec.workorder_id IS NULL) OR
         (p_x_osp_order_line_rec.workorder_id IS NULL AND l_osp_order_line_rec.workorder_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_WO_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --inventory_item_id can't be changed and inventory_item_id is always populated
      IF(p_x_osp_order_line_rec.inventory_item_id IS NULL OR
         p_x_osp_order_line_rec.inventory_item_id <> l_osp_order_line_rec.inventory_item_id) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_ITEM_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --inventory_org_id can't be changed and inventory_org_id is always popluated
      IF(p_x_osp_order_line_rec.inventory_org_id IS NULL OR
         p_x_osp_order_line_rec.inventory_org_id <> l_osp_order_line_rec.inventory_org_id) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_ORG_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --inventory_item_uom can't be changed and inventory_item_uom is always populated
      IF(p_x_osp_order_line_rec.inventory_item_uom IS NULL OR
         p_x_osp_order_line_rec.inventory_item_uom <> l_osp_order_line_rec.inventory_item_uom) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_UOM_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --inventory_item_quantity can't be changed and inventory_item_quantity is always populated
      IF(p_x_osp_order_line_rec.inventory_item_quantity IS NULL OR
         p_x_osp_order_line_rec.inventory_item_quantity <> l_osp_order_line_rec.inventory_item_quantity) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QTY_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --sub_inventory can't be changed but sub_inventory can be null
      IF((p_x_osp_order_line_rec.sub_inventory <> l_osp_order_line_rec.sub_inventory) OR
         (p_x_osp_order_line_rec.sub_inventory IS NOT NULL AND l_osp_order_line_rec.sub_inventory IS NULL) OR
         (p_x_osp_order_line_rec.sub_inventory IS NULL AND l_osp_order_line_rec.sub_inventory IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SUB_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --lot_number can't be changed but lot_number can be null
      IF((p_x_osp_order_line_rec.lot_number <> l_osp_order_line_rec.lot_number) OR
         (p_x_osp_order_line_rec.lot_number IS NOT NULL AND l_osp_order_line_rec.lot_number IS NULL) OR
         (p_x_osp_order_line_rec.lot_number IS NULL AND l_osp_order_line_rec.lot_number IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_LOT_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --serial_number can't be changed but serial_number can be null
      IF((p_x_osp_order_line_rec.serial_number <> l_osp_order_line_rec.serial_number) OR
         (p_x_osp_order_line_rec.serial_number IS NOT NULL AND l_osp_order_line_rec.serial_number IS NULL) OR
         (p_x_osp_order_line_rec.serial_number IS NULL AND l_osp_order_line_rec.serial_number IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SERIAL_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      -- this API does not allow to update SO line information, Shipment API needs to update
      -- OSP tables directly (is this the best approach?)
      --oe_ship_line_id can't be changed from this API, and it could be null.
      IF((p_x_osp_order_line_rec.oe_ship_line_id <> l_osp_order_line_rec.oe_ship_line_id) OR
         (p_x_osp_order_line_rec.oe_ship_line_id IS NOT NULL AND l_osp_order_line_rec.oe_ship_line_id IS NULL) OR
         (p_x_osp_order_line_rec.oe_ship_line_id IS NULL AND l_osp_order_line_rec.oe_ship_line_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SHIP_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --oe_return_line_id can't be changed from this API, and it could be null.
      IF((p_x_osp_order_line_rec.oe_return_line_id <> l_osp_order_line_rec.oe_return_line_id) OR
         (p_x_osp_order_line_rec.oe_return_line_id IS NOT NULL AND l_osp_order_line_rec.oe_return_line_id IS NULL) OR
         (p_x_osp_order_line_rec.oe_return_line_id IS NULL AND l_osp_order_line_rec.oe_return_line_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_RET_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      -- this API does not allow to update PO line information, PO API needs to update
      -- OSP tables directly (is this the best approach?)
      --po_line_id can't be changed from this API, and it could be null.
      IF((p_x_osp_order_line_rec.po_line_id <> l_osp_order_line_rec.po_line_id) OR
         (p_x_osp_order_line_rec.po_line_id IS NOT NULL AND l_osp_order_line_rec.po_line_id IS NULL) OR
         (p_x_osp_order_line_rec.po_line_id IS NULL AND l_osp_order_line_rec.po_line_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_POLINE_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;

      -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
      -- this API does not allow to update PO line information, PO API needs to update OSP tables directly
      --po_req_line_id can't be changed from this API, and it could be null.
      IF((p_x_osp_order_line_rec.po_req_line_id <> l_osp_order_line_rec.po_req_line_id) OR
         (p_x_osp_order_line_rec.po_req_line_id IS NOT NULL AND l_osp_order_line_rec.po_req_line_id IS NULL) OR
         (p_x_osp_order_line_rec.po_req_line_id IS NULL AND l_osp_order_line_rec.po_req_line_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_REQLINE_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;

      --po_line_type_id can't be changed from this API, and it could be null.
      IF((p_x_osp_order_line_rec.po_line_type_id <> l_osp_order_line_rec.po_line_type_id) OR
         (p_x_osp_order_line_rec.po_line_type_id IS NOT NULL AND l_osp_order_line_rec.po_line_type_id IS NULL) OR
         (p_x_osp_order_line_rec.po_line_type_id IS NULL AND l_osp_order_line_rec.po_line_type_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_POTYPE_ID_CHG');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;

      -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
      --If the status is other than 'ENTERED', 'SUBMISSION_FAILED', 'REQ_SUBMISSION_FAILED' we should not allow updates of
      --service_item_id, service_item_uom_code, quantity and need_by_date
      SELECT status_code INTO l_header_status_code
        FROM ahl_osp_orders_b
       WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id;

       IF(l_header_status_code NOT IN (G_OSP_ENTERED_STATUS, G_OSP_SUB_FAILED_STATUS, G_OSP_REQ_SUB_FAILED_STATUS)) THEN
          --service_item_id can't be changed from this API, and it could be null.
          IF((p_x_osp_order_line_rec.service_item_id <> l_osp_order_line_rec.service_item_id) OR
             (p_x_osp_order_line_rec.service_item_id IS NOT NULL AND l_osp_order_line_rec.service_item_id IS NULL) OR
             (p_x_osp_order_line_rec.service_item_id IS NULL AND l_osp_order_line_rec.service_item_id IS NOT NULL)) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SER_ID_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;

          --service_item_description can't be changed from this API, and it could be null.
          IF((p_x_osp_order_line_rec.service_item_description <> l_osp_order_line_rec.service_item_description) OR
             (p_x_osp_order_line_rec.service_item_description IS NOT NULL AND l_osp_order_line_rec.service_item_description IS NULL) OR
             (p_x_osp_order_line_rec.service_item_description IS NULL AND l_osp_order_line_rec.service_item_description IS NOT NULL)) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SER_DESC_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;

	 /*
          --exchange_instance_id can't be changed from this API, and it could be null.
          IF((p_x_osp_order_line_rec.exchange_instance_id <> l_osp_order_line_rec.exchange_instance_id) OR
             (p_x_osp_order_line_rec.exchange_instance_id IS NOT NULL AND l_osp_order_line_rec.exchange_instance_id IS NULL) OR
             (p_x_osp_order_line_rec.exchange_instance_id IS NULL AND l_osp_order_line_rec.exchange_instance_id IS NOT NULL)) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_EXCH_ID_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;
	 */

          --service_item_uom cannot change and cannot be null
          IF(p_x_osp_order_line_rec.service_item_uom_code IS NULL OR
             (p_x_osp_order_line_rec.service_item_uom_code <> l_osp_order_line_rec.service_item_uom_code) ) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SER_UOM_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;

          --service_item_quantity cannot change and cannot be null
          IF(p_x_osp_order_line_rec.quantity IS NULL OR
             (p_x_osp_order_line_rec.quantity <> l_osp_order_line_rec.quantity) ) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SER_QTY_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;

          --Neeed By Date cannot change and cannot be null
          IF(p_x_osp_order_line_rec.need_by_date IS NULL OR
             (trunc(p_x_osp_order_line_rec.need_by_date) <> trunc(l_osp_order_line_rec.need_by_date) )) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_NBD_CHG');
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          END IF;
      END IF;
      -- jaramana End

      --Service_item_description is updatable only if service_item_id is NULL, and serive_item_description can be null
      --Here we use the item description derived from service_item_id instead of l_service_item_description which is from
      --database table and could be derived from service_item_id and could be just
      --the identifier of one-time service item

      --Jerry changed on 10/04/05 for AE enhancement 4544654 to allow the service item description to be changed in AHL
      --side.

      IF (p_x_osp_order_line_rec.service_item_id IS NOT NULL) THEN
        BEGIN
          --Assuming service_item_id is always in mtl_system_items_kfv and its organization equals that of physical item
          --Alwasy set service_item_description to be derived from service_item_id if service_item_id is not null
          --Changes made by mpothuku on 27-Mar-06 to fix the ER 4544654 and Bug 5013047
          SELECT description, allow_item_desc_update_flag, concatenated_segments INTO l_item_description, l_desc_update_flag, l_svc_item_number
            FROM mtl_system_items_kfv
           WHERE inventory_item_id = p_x_osp_order_line_rec.service_item_id
             AND organization_id = p_x_osp_order_line_rec.inventory_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM');
            FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_x_osp_order_line_rec.service_item_id);
            FND_MSG_PUB.ADD;
        END;
        l_owrite_svc_desc_prf := NVL(FND_PROFILE.VALUE('AHL_OSP_OWRITE_SVC_DESC'), 'N');
        l_item_prefix := FND_PROFILE.VALUE('AHL_OSP_POL_ITEM_PREFIX');
        l_serial_prefix := FND_PROFILE.VALUE('AHL_OSP_POL_SER_PREFIX');

        --Fix for the bug 5013047
        /*
        IF(l_desc_update_flag <> 'Y' AND
           ((p_x_osp_order_line_rec.service_item_description <> l_item_description) OR
            (p_x_osp_order_line_rec.service_item_description IS NOT NULL AND l_item_description IS NULL) OR
            (p_x_osp_order_line_rec.service_item_description IS NULL AND l_item_description IS NOT NULL))) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVCITMDSC_CHG');
          FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
          FND_MSG_PUB.ADD;
        END IF;
        */
        /*
        IF Overwrite Svc Description profile set to No l_item_description would have been
          defaulted as the service item desc from inventory above, if the profile is Yes, we proceed below
          to override the value set from the inventory
        */

        IF(l_owrite_svc_desc_prf = 'Y') THEN --Overwrite Svc Description profile set to Yes
          IF(NVL(l_desc_update_flag, 'N') = 'N') THEN --Allow Description update set to No
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVCITMDSC_CHG');
            FND_MESSAGE.Set_Token('SERVICE_ITEM_NUMBER', l_svc_item_number);
            FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
            FND_MSG_PUB.ADD;
          ELSE
            BEGIN
              SELECT concatenated_segments INTO l_inv_item_number
                FROM mtl_system_items_kfv
               WHERE inventory_item_id = p_x_osp_order_line_rec.inventory_item_id
                 AND organization_id = p_x_osp_order_line_rec.inventory_org_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PHY_ITEM_INVALID');
                FND_MSG_PUB.ADD;
            END;
            l_item_description :=
            SUBSTR(l_item_prefix||l_inv_item_number||' '||l_serial_prefix||p_x_osp_order_line_rec.serial_number,1,240);
          END IF;
        END IF;
        p_x_osp_order_line_rec.service_item_description := l_item_description;
      END IF;
      --mpothuku End

      --Enforcing that either service_item_id and description should be not null
      --This is only enforced during update. Maybe it is better if delaying this validation
      --until submitting the OSP order?
      IF (p_x_osp_order_line_rec.service_item_id IS NULL AND p_x_osp_order_line_rec.service_item_description IS NULL) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_SVCITMDSC_BOTH_NLL');
        FND_MESSAGE.Set_Token('LINE_NUMBER', l_osp_order_line_rec.osp_line_number);
        FND_MSG_PUB.ADD;
      END IF;
      --validate status_code change
      --it looks like only changing to 'CLOSED' occurs in this API, other statuses will be
      --changed in PO API?
      --NULL;
      --validate need_by_date
      -- Modified by jaramana on August 11, 2006 to not do this Date check if the line is PO Cancelled or PO Deleted (Bug 5478764)
      -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236 (Added the Requisition related statuses)
      IF(TRUNC(p_x_osp_order_line_rec.need_by_date) < TRUNC(SYSDATE) AND
         (NVL(p_x_osp_order_line_rec.status_code, 'ENTERED') NOT IN (G_OL_PO_CANCELLED_STATUS, G_OL_PO_DELETED_STATUS,G_OL_REQ_CANCELLED_STATUS, G_OL_REQ_DELETED_STATUS))) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_NEED_DT');
        FND_MESSAGE.Set_Token('NEED_BY_DATE', p_x_osp_order_line_rec.need_by_date);
        FND_MSG_PUB.ADD;
      END IF;
      -- jaramana End
      --validate ship_by_date (is this necessary?)
      /* Commented out on 05/31/2005 by Jerry
      IF(TRUNC(p_x_osp_order_line_rec.ship_by_date) < TRUNC(SYSDATE))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SHIP_DT');
        FND_MESSAGE.Set_Token('SHIP_BY_DATE', p_x_osp_order_line_rec.ship_by_date);
        FND_MSG_PUB.ADD;
      END IF;
      */
      --validate service_item_id (simplfied the original one)

      /* p_org_id added to validate_service_item_uom to fix the Perf Bug #4919164 by mpothuku on 28-Feb-06
      default_unchanged_order_line would have defaulted the inventory_org_id by now, hence even for workorder based lines inventory_org_id will be populated with the visit's org */

      validate_service_item_id(p_x_osp_order_line_rec.service_item_id, p_x_osp_order_line_rec.inventory_org_id);
      --validate service_item_description
      --it is not necessary to add the original one here.
      --validate sercice_item_uom (just borrowed the old one)
      validate_service_item_uom(p_x_osp_order_line_rec.service_item_id, p_x_osp_order_line_rec.service_item_uom_code, p_x_osp_order_line_rec.inventory_org_id);
      --validate sercice_item_quantity(quantity)
      --Service item quantity could be from the quantity of PO lines and not necessary to be the same as
      --as the value in ahl_osp_order_lines when PO has ever been created
      --created
      -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
      --Moved the logic below, to above
      /*
      SELECT status_code INTO l_header_status_code
        FROM ahl_osp_orders_b
       WHERE osp_order_id = p_x_osp_order_line_rec.osp_order_id;
      */
      -- jaramana End
      IF (p_x_osp_order_line_rec.quantity IS NOT NULL AND p_x_osp_order_line_rec.quantity <> FND_API.G_MISS_NUM) THEN
        IF(p_x_osp_order_line_rec.quantity <= 0)  THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_VAL');
          FND_MESSAGE.Set_Token('QUANTITY', p_x_osp_order_line_rec.quantity);
          FND_MSG_PUB.ADD;
        END IF;
        -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
        --Included the equal to zero clause above. Since we are modifying the OSP Line Views and are refraining from
        --synching up the quantity from PO Lines, the equal to clause can be imposed on all the OSP line statuses
        /*
        IF (p_x_osp_order_line_rec.quantity = 0 AND
            l_header_status_code NOT IN (G_OSP_PO_CREATED_STATUS, G_OSP_CLOSED_STATUS)) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_VAL');
          FND_MESSAGE.Set_Token('QUANTITY', p_x_osp_order_line_rec.quantity);
          FND_MSG_PUB.ADD;
        END IF;
        */
        -- jaramana End
      --quantity cannot be null when UOM is not null
      ELSIF (p_x_osp_order_line_rec.service_item_uom_code IS NOT NULL AND p_x_osp_order_line_rec.service_item_uom_code <> FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_QUANT_NLL');
        FND_MSG_PUB.ADD;
      END IF;

      -- validate service/physical item combination with vendor
      --validate_vendor_service_item(p_x_osp_order_line_rec);
      -- validate physical/service item combination unique for a given OSP order
      -- For tracked item, same physical item and service item combination can only appear once in a given OSP order header
      -- While for non tracked item, same physical item can only appear once in a given OSP order header
      IF (p_x_osp_order_line_rec.workorder_id IS NULL AND
          p_x_osp_order_line_rec.service_item_id <> l_osp_order_line_rec.service_item_id) THEN
        SELECT comms_nl_trackable_flag INTO l_trackable_flag
          FROM mtl_system_items_kfv
         WHERE inventory_item_id = p_x_osp_order_line_rec.inventory_item_id
           AND organization_id = p_x_osp_order_line_rec.inventory_org_id;
        /* Commented out by Jerry on 10/11/05 due to an issue found by Pavan
        IF (nvl(l_trackable_flag, 'N')='N') THEN
          OPEN check_phy_item_unique(p_x_osp_order_line_rec.osp_order_id,
                                     p_x_osp_order_line_rec.inventory_item_id);
          FETCH check_phy_item_unique INTO g_dummy_char;
          IF check_phy_item_unique%FOUND THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PHY_ITEM_UNIUE');
            FND_MSG_PUB.ADD;
          END IF;
          CLOSE check_phy_item_unique;
        ELSE
        */
        IF (nvl(l_trackable_flag, 'N')='Y') THEN
          OPEN check_phy_ser_item_unique(p_x_osp_order_line_rec.osp_order_id,
                                         p_x_osp_order_line_rec.service_item_id,
                                         p_x_osp_order_line_rec.inventory_item_id,
                                         p_x_osp_order_line_rec.inventory_org_id,
                                         p_x_osp_order_line_rec.lot_number,
                                         p_x_osp_order_line_rec.serial_number);
          FETCH check_phy_ser_item_unique INTO g_dummy_char;
          IF check_phy_ser_item_unique%FOUND THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PHY_SER_ITEM_UNIUE');
            FND_MSG_PUB.ADD;
          END IF;
          CLOSE check_phy_ser_item_unique;
        END IF;
      END IF;
    END IF;
    CLOSE osp_order_line_csr;
  END IF;
END validate_order_line_update;

PROCEDURE derive_default_vendor(
  p_item_service_rels_tbl IN item_service_rels_tbl_type,
  x_vendor_id             OUT NOCOPY NUMBER,
  x_vendor_site_id        OUT NOCOPY NUMBER,
  x_vendor_contact_id     OUT NOCOPY NUMBER,
  x_valid_vendors_tbl     OUT NOCOPY Vendor_id_tbl_type)
IS
  CURSOR get_vendor_cert(c_inv_item_id NUMBER,
                         c_inv_org_id NUMBER,
                         c_service_item_id NUMBER) IS

    /* mpothuku modified ahl_vendor_certifications to _v to fix the OU related Bug 5350882 on 21-Jul-06
       Also added the inv_org_id related OU filter */

    SELECT IV.vendor_certification_id,
           IV.rank
      FROM ahl_inv_service_item_rels SI,
           ahl_item_vendor_rels IV,
           ahl_vendor_certifications_v VC
     WHERE SI.inv_service_item_rel_id = IV.inv_service_item_rel_id
       AND IV.vendor_certification_id = VC.vendor_certification_id
       AND SI.inv_item_id = c_inv_item_id
       AND SI.inv_org_id = c_inv_org_id
       AND SI.service_item_id = c_service_item_id
       AND trunc(SI.active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(SI.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND trunc(IV.active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(IV.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND trunc(VC.active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(VC.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_vendor_ids(c_vendor_cert_id NUMBER) IS
    SELECT vendor_id,
           vendor_site_id,
           vendor_contact_id
      FROM ahl_vendor_certifications_v
     WHERE vendor_certification_id = c_vendor_cert_id
       AND trunc(active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  TYPE vendor_rank_count_rec_type IS RECORD (
    rank_sum        NUMBER, --the summary of ranks for all the vendor_certification_ids
    count_num       NUMBER);--if count_num = p_item_service_rels_tbl.count then the vendor_cert_id is common
  --The index of the record type is vendor_certification_id
  TYPE vendor_rank_count_tbl_type IS TABLE OF vendor_rank_count_rec_type INDEX BY BINARY_INTEGER;
  l_vendor_rank_count_tbl vendor_rank_count_tbl_type;
  i                     NUMBER;
  l_first_index         NUMBER;
  l_tbl_index           NUMBER;
  l_vendor_index        NUMBER;
  l_temp_index          NUMBER;
  l_temp_vendor_cert_id NUMBER;
  l_temp_rank           NUMBER;
  l_temp_rank_sum       NUMBER;
  l_vendor_cert_id      NUMBER;
  l_common_exists_flag  BOOLEAN;

  l_temp_vendor_index   NUMBER := 0;
  l_dummy_contact_id    NUMBER;
BEGIN
  --This whole logic depends on the assumption that rank is mandatory in table
  --ahl_item_vendor_rels
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || 'derive_default_vendor',
                   'Procedure begins and count='||p_item_service_rels_tbl.count);
  END IF;
  x_vendor_id := NULL;
  x_vendor_site_id := NULL;
  x_vendor_contact_id := NULL;
  IF (p_item_service_rels_tbl.count > 0) THEN
    --get the vendor_cert_id set for the first physical/service item combination record
    --and take it as the base for comparing with other sets to seek the common vendor_cert_id
    l_tbl_index := p_item_service_rels_tbl.FIRST;
    FOR l_get_vendor_cert IN get_vendor_cert(p_item_service_rels_tbl(l_tbl_index).inv_item_id,
                                             p_item_service_rels_tbl(l_tbl_index).inv_org_id,
                                             p_item_service_rels_tbl(l_tbl_index).service_item_id) LOOP
      l_first_index := l_get_vendor_cert.vendor_certification_id;
      l_vendor_rank_count_tbl(l_first_index).rank_sum := l_get_vendor_cert.rank;
      l_vendor_rank_count_tbl(l_first_index).count_num := 1;
    END LOOP;
    --Loop through other vendor_cert_id sets of all the other physical/service item combination records
    --Counting the appearing times and suming their ranks in all the vendor_cert_id sets of each
    --vendor_cert_id in the base set. By this rule we could find the common vendor_cert_id
    --with the highest rank.
    IF (l_vendor_rank_count_tbl.count > 0) THEN
      FOR i IN (l_tbl_index+1)..p_item_service_rels_tbl.LAST LOOP
        l_common_exists_flag := FALSE;
        FOR l_get_vendor_cert IN get_vendor_cert(p_item_service_rels_tbl(i).inv_item_id,
                                                 p_item_service_rels_tbl(i).inv_org_id,
                                                 p_item_service_rels_tbl(i).service_item_id) LOOP
          l_temp_index := l_get_vendor_cert.vendor_certification_id;
          l_temp_rank := l_get_vendor_cert.rank;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX || 'derive_default_vendor',
                   'l_temp_index='||l_temp_index||
                   'l_temp_rank='||l_temp_rank);
          END IF;
          IF l_vendor_rank_count_tbl.EXISTS(l_temp_index) THEN
            l_common_exists_flag := TRUE;
            l_vendor_rank_count_tbl(l_temp_index).rank_sum := l_vendor_rank_count_tbl(l_temp_index).rank_sum + l_temp_rank;
            l_vendor_rank_count_tbl(l_temp_index).count_num := l_vendor_rank_count_tbl(l_temp_index).count_num + 1;
          END IF;
        END LOOP;
        IF NOT l_common_exists_flag THEN
          RETURN;
        END IF;
      END LOOP;
      --Pick up the common vendor_cert_id (exists in all the sets) with
      --the highest(least) summary rank
      l_vendor_cert_id := NULL;
      l_temp_rank_sum := FND_API.G_MISS_NUM; --Just want to use a big positive number
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX || 'derive_default_vendor',
                   'Procedure begins and count2='||l_vendor_rank_count_tbl.count||
                   'first='||l_vendor_rank_count_tbl.first||'last='||l_vendor_rank_count_tbl.last);
      END IF;
      l_vendor_index := l_vendor_rank_count_tbl.FIRST;  -- get subscript of first element
      --You can't use FOR l_vendor_index IN l_vendor_rank_count_tbl.FIRST..l_vendor_rank_count_tbl.LAST here
      WHILE l_vendor_index IS NOT NULL LOOP
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX || 'derive_default_vendor',
                   'l_vendor_index='||l_vendor_index);
        END IF;
        IF (l_vendor_rank_count_tbl(l_vendor_index).count_num = p_item_service_rels_tbl.count) THEN
          -- Make a note of this common vendor
          l_temp_vendor_index := l_temp_vendor_index + 1;
          x_valid_vendors_tbl(l_temp_vendor_index).vendor_id := l_vendor_index;
          IF (l_vendor_rank_count_tbl(l_vendor_index).rank_sum < l_temp_rank_sum) THEN
            -- Current Best Rank
            l_vendor_cert_id := l_vendor_index;
            l_temp_rank_sum := l_vendor_rank_count_tbl(l_vendor_index).rank_sum;
          END IF;
        END IF;
        l_vendor_index := l_vendor_rank_count_tbl.NEXT(l_vendor_index);  -- get subscript of next element
      END LOOP;

      OPEN get_vendor_ids(l_vendor_cert_id);
      FETCH get_vendor_ids INTO x_vendor_id, x_vendor_site_id, x_vendor_contact_id;
      CLOSE get_vendor_ids;

      -- Convert All Certification Ids to Vendor/Vendor Location Ids
      IF x_valid_vendors_tbl.count > 0 THEN
        FOR i IN x_valid_vendors_tbl.FIRST..x_valid_vendors_tbl.LAST LOOP
          OPEN get_vendor_ids(x_valid_vendors_tbl(i).vendor_id);
          FETCH get_vendor_ids INTO x_valid_vendors_tbl(i).vendor_id, x_valid_vendors_tbl(i).vendor_site_id, l_dummy_contact_id;
          CLOSE get_vendor_ids;
        END LOOP;
      END IF;
    END IF;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || 'derive_default_vendor',
                   'Procedure exits normallly');
  END IF;
END derive_default_vendor;

--This procedure tries to derive the common vendors for an OSP Order based on its Lines.
--If the x_any_vendor_flag is 'Y', it means that any vendor can be used for this Order.
--Else, only the vendors whose ids are returned in the table x_valid_vendors_tbl
--are valid. It uses the derive_default_vendor method.
PROCEDURE derive_common_vendors(p_osp_order_id      IN  NUMBER,
                                x_valid_vendors_tbl OUT NOCOPY Vendor_id_tbl_type,
                                x_any_vendor_flag   OUT NOCOPY VARCHAR2) IS

  CURSOR item_service_dtls_csr IS
    SELECT INVENTORY_ORG_ID, INVENTORY_ITEM_ID, SERVICE_ITEM_ID FROM ahl_osp_order_lines
    WHERE osp_order_id = p_osp_order_id AND
          service_item_id IS NOT NULL;

  CURSOR is_vendor_defined_csr (c_inventory_item_id IN NUMBER,
                                c_service_item_id   IN NUMBER) IS
    SELECT 1
	FROM ahl_inv_service_item_rels isr,
	     ahl_item_vendor_rels ivr
    WHERE isr.inv_item_id = c_inventory_item_id AND
          isr.service_item_id = c_service_item_id AND
          isr.inv_service_item_rel_id = ivr.inv_service_item_rel_id;

   L_DEBUG_KEY   CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Derive_Common_Vendors';
   l_temp_number NUMBER;
   l_item_dtls_tbl item_service_rels_tbl_type;
   l_item_dtls_rec item_service_rel_rec_type;
   l_temp_index NUMBER := 0;
   l_dummy_vendor_id     NUMBER;
   l_dummy_site_id       NUMBER;
   l_dummy_contact_id    NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure. p_osp_order_id = ' || p_osp_order_id);
  END IF;

  x_any_vendor_flag := 'N';

  OPEN item_service_dtls_csr;
  LOOP
    FETCH item_service_dtls_csr INTO l_item_dtls_rec;
    EXIT WHEN item_service_dtls_csr%NOTFOUND;
    -- Check if a Vendor exists for this item/service
    OPEN is_vendor_defined_csr(l_item_dtls_rec.inv_item_id, l_item_dtls_rec.service_item_id);
    FETCH is_vendor_defined_csr INTO l_temp_number;
    IF (is_vendor_defined_csr%FOUND) THEN
      -- There is a vendor defined for this item/svc association
      l_temp_index := l_temp_index + 1;  -- One based index
      -- Populate the table with this Item Association Details
      l_item_dtls_tbl(l_temp_index) := l_item_dtls_rec;
    END IF;
    CLOSE is_vendor_defined_csr;
  END LOOP;
  CLOSE item_service_dtls_csr;

  IF (l_temp_index = 0) THEN
    -- All OSP lines have only one-time items or no vendor is defined for any item/svc combination
	-- In such a case, Can use any Vendor
    x_any_vendor_flag := 'Y';
    RETURN;
  END IF;

  -- Now try to get the common Vendor(s) for the associations in l_item_dtls_tbl

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Trying to get the common vendors for ' || l_item_dtls_tbl.COUNT || ' associations.');
  END IF;

  derive_default_vendor(p_item_service_rels_tbl => l_item_dtls_tbl,
                        x_vendor_id             => l_dummy_vendor_id,
                        x_vendor_site_id        => l_dummy_site_id,
                        x_vendor_contact_id     => l_dummy_contact_id,
                        x_valid_vendors_tbl     => x_valid_vendors_tbl);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Total number of common vendors: ' || x_valid_vendors_tbl.COUNT);
  END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END derive_common_vendors;

--Newly created to validate vendor_id, vendor_site_id and
--vendor_contact_id together(crosss attribute validation)
PROCEDURE validate_vendor_site_contact(p_vendor_id IN NUMBER,
                                       p_vendor_site_id IN NUMBER,
                                       p_vendor_contact_id IN NUMBER)
IS
  CURSOR val_vendor_id_csr IS
    SELECT 'X'
     FROM po_vendors_view
    WHERE vendor_id = p_vendor_id
      AND enabled_flag = G_YES_FLAG
      AND TRUNC(NVL(vendor_start_date_active, SYSDATE - 1)) <= TRUNC(SYSDATE)
      AND TRUNC(NVL(vendor_end_date_active, SYSDATE + 1)) > TRUNC(SYSDATE);
  CURSOR get_vendor_cert IS
    SELECT 'X'
      FROM ahl_vendor_certifications_v
     WHERE vendor_id = p_vendor_id
       AND TRUNC(active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(nvl(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);
  CURSOR val_vendor_site_id_csr IS
    SELECT 'X'
     FROM po_vendor_sites
    WHERE vendor_site_id = p_vendor_site_id
      AND vendor_id = p_vendor_id
      AND TRUNC(NVL(inactive_date, SYSDATE + 1)) > TRUNC(SYSDATE)
      AND purchasing_site_flag = G_YES_FLAG
      AND NVL(RFQ_ONLY_SITE_FLAG, G_NO_FLAG) =G_NO_FLAG ;
  CURSOR get_site_cert IS
    SELECT 'X'
      FROM ahl_vendor_certifications_v
     WHERE vendor_id = p_vendor_id
       AND vendor_site_id = p_vendor_site_id
       AND TRUNC(active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(nvl(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);
  CURSOR val_vendor_contact_id_csr IS
    SELECT 'X'
     FROM po_vendor_contacts
    WHERE vendor_site_id = p_vendor_site_id
      AND vendor_contact_id = p_vendor_contact_id
      AND TRUNC(NVL(inactive_date, SYSDATE+1)) > TRUNC(SYSDATE);
  CURSOR get_contact_cert IS
    SELECT 'X'
     FROM ahl_vendor_certifications
    WHERE vendor_contact_id = p_vendor_contact_id
      AND TRUNC(active_start_date) <= TRUNC(SYSDATE)
      AND TRUNC(NVL(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);
    l_exist VARCHAR2(1);
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_vendor_site_contact';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
  END IF;
  IF (p_vendor_id IS NULL) THEN
    IF (p_vendor_site_id IS NOT NULL OR p_vendor_contact_id IS NOT NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
      FND_MESSAGE.Set_Token('VENDOR_ID', p_vendor_id);
      FND_MSG_PUB.ADD;
    END IF;
  ELSE
    OPEN val_vendor_id_csr;
    FETCH val_vendor_id_csr INTO l_exist;
    IF(val_vendor_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
      FND_MESSAGE.Set_Token('VENDOR_ID', p_vendor_id);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE val_vendor_id_csr;
    OPEN get_vendor_cert;
    FETCH get_vendor_cert INTO l_exist;
    IF(get_vendor_cert%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
      FND_MESSAGE.Set_Token('VENDOR_ID', p_vendor_id);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE get_vendor_cert;
    IF (p_vendor_site_id IS NULL AND p_vendor_contact_id IS NOT NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
      FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
      FND_MSG_PUB.ADD;
    ELSIF (p_vendor_site_id IS NOT NULL) THEN
      OPEN val_vendor_site_id_csr;
      FETCH val_vendor_site_id_csr INTO l_exist;
      IF(val_vendor_site_id_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
        FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE val_vendor_site_id_csr;
      OPEN get_site_cert;
      FETCH get_site_cert INTO l_exist;
      IF(get_site_cert%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENSITE_ID_INV');
        FND_MESSAGE.Set_Token('VENDOR_SITE_ID', p_vendor_site_id);
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE get_site_cert;
      IF (p_vendor_contact_id IS NOT NULL) THEN
        OPEN val_vendor_contact_id_csr;
        FETCH val_vendor_contact_id_csr INTO l_exist;
        IF(val_vendor_contact_id_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VEN_CONTACT_ID_INV');
          FND_MESSAGE.Set_Token('VENDOR_CONTACT_ID', p_vendor_contact_id);
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE val_vendor_contact_id_csr;
        OPEN get_contact_cert;
        FETCH get_contact_cert INTO l_exist;
        IF(get_contact_cert%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VEN_CONTACT_ID_INV');
          FND_MESSAGE.Set_Token('VENDOR_CONTACT_ID', p_vendor_contact_id);
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_contact_cert;
      END IF;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
END validate_vendor_site_contact;

--Copied from original default_unchanged_order_lines, so some inherited logic
--may not be necessary. It is applicable to both Update and Create
PROCEDURE default_unchanged_order_line(p_x_osp_order_line_rec IN OUT NOCOPY osp_order_line_rec_type)
IS
  CURSOR osp_order_lines_csr IS
  --Updated by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
  /*
    SELECT osp_order_id,
           osp_line_number,
           status_code, --status is not defined in the record because user can't directly change the status
           po_line_type_id, --no po_line_type here because it is not changeable once it is created(from a profile option)
           service_item_id,
           service_item_number,
           service_item_description,
           service_item_uom_code,
           quantity,
           need_by_date,
           ship_by_date,
           po_line_id,
           oe_ship_line_id,
           oe_return_line_id,
           workorder_id,
           job_number,
           operation_id, --this attribute should be deleted from the table, so ignore it
           exchange_instance_id,
           exchange_instance_number,
           inventory_item_id,
           inventory_org_id,
           item_number,
           inventory_item_uom,
           inventory_item_quantity,
           sub_inventory,
           lot_number,
           serial_number,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM ahl_osp_order_lines_v
    WHERE osp_order_line_id = p_x_osp_order_line_rec.osp_order_line_id
    AND object_version_number= p_x_osp_order_line_rec.object_version_number;
 */
    SELECT ospl.osp_order_id,
            ospl.osp_line_number,
            ospl.status_code, --status is not defined in the record because user can't directly change the status
            ospl.po_line_type_id, --no po_line_type here because it is not changeable once it is created(from a profile option)
            ospl.service_item_id,
            (select mtlsvc.concatenated_segments
              from mtl_system_items_kfv mtlsvc
             where mtlsvc.inventory_item_id = ospl.service_item_id
               and mtlsvc.organization_id = decode(ospl.workorder_id, null, ospl.inventory_org_id, vst.organization_id)
            )service_item_number,
            ospl.service_item_description,
            --modified by mpothuku on 14-mar-2008 to fix the Bug 6885513
            /*
            decode(ospl.po_line_id, null, ospl.service_item_uom_code, mtluom.uom_code )service_item_uom_code,
            decode(ospl.po_line_id, null, ospl.quantity, pl.quantity )quantity,
            */
            ospl.service_item_uom_code,
            ospl.quantity,
            --mpothuku End
            ospl.need_by_date,
            ospl.ship_by_date,
            ospl.po_line_id,
            ospl.oe_ship_line_id,
            ospl.oe_return_line_id,
            ospl.workorder_id,
            wo.workorder_name job_number,
            ospl.operation_id, --this attribute should be deleted from the table, so ignore it
            ospl.exchange_instance_id,
            csiex.instance_number exchange_instance_number,
            decode(ospl.workorder_id, null, ospl.inventory_item_id, vts.inventory_item_id)inventory_item_id,
            --Fix for the regression issue by mpothuku on 28th August 2006, changed the item_id to org_id in decode below
            decode(ospl.workorder_id, null, ospl.inventory_org_id, vst.organization_id) inventory_org_id,
            (select mtli.concatenated_segments
              from mtl_system_items_kfv mtli
             where mtli.inventory_item_id = ospl.inventory_item_id
               and mtli.organization_id = decode(ospl.workorder_id, null, ospl.inventory_org_id, vst.organization_id)
            )item_number,
            decode(ospl.workorder_id, null, ospl.inventory_item_uom, csiwo.unit_of_measure)inventory_item_uom,
            decode(ospl.workorder_id, null, ospl.inventory_item_quantity, csiwo.quantity)inventory_item_quantity,
            decode(ospl.workorder_id, null, ospl.sub_inventory, null)sub_inventory,
            decode(ospl.workorder_id, null, ospl.lot_number, csiwo.lot_number)lot_number,
            decode(ospl.workorder_id, null, ospl.serial_number, csiwo.serial_number)serial_number,
            -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
            po_req_line_id,
            -- jaramana End
            ospl.attribute_category,
            ospl.attribute1,
            ospl.attribute2,
            ospl.attribute3,
            ospl.attribute4,
            ospl.attribute5,
            ospl.attribute6,
            ospl.attribute7,
            ospl.attribute8,
            ospl.attribute9,
            ospl.attribute10,
            ospl.attribute11,
            ospl.attribute12,
            ospl.attribute13,
            ospl.attribute14,
            ospl.attribute15
       FROM ahl_osp_order_lines ospl,
            ahl_workorders wo,
            ahl_visits_b vst,
            ahl_visit_tasks_b vts,
            csi_item_instances csiwo,
            csi_item_instances csiex,
            --po_lines_all pl,
            mtl_units_of_measure_tl mtluom
      WHERE ospl.osp_order_line_id = p_x_osp_order_line_rec.osp_order_line_id
        AND ospl.object_version_number= p_x_osp_order_line_rec.object_version_number
        AND ospl.workorder_id = wo.workorder_id(+)
        AND wo.visit_task_id = vts.visit_task_id(+)
        AND vts.visit_id = vst.visit_id(+)
        AND vts.instance_id = csiwo.instance_id(+)
        AND NVL (ospl.status_code, 'ENTERED') <> 'PO_DELETED'
        --modified by mpothuku on 14-mar-2008 to fix the Bug 6885513
        /*
        AND ospl.po_line_id = pl.po_line_id(+)
        AND pl.unit_meas_lookup_code = mtluom.unit_of_measure(+)
        AND mtluom.language(+) = USERENV('LANG')
        */
        --mpothuku End
        AND csiex.instance_id(+) = ospl.exchange_instance_id;

    l_osp_order_line_rec osp_order_lines_csr%ROWTYPE;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.default_unchanged_order_lines';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    IF(p_x_osp_order_line_rec.operation_flag = G_OP_UPDATE) THEN
      OPEN osp_order_lines_csr;
      FETCH osp_order_lines_csr INTO l_osp_order_line_rec;
      IF (osp_order_lines_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INVOP_OSP_LN_NFOUND');
        FND_MSG_PUB.ADD;
      ELSE
        IF (p_x_osp_order_line_rec.osp_order_id IS NULL) THEN
          p_x_osp_order_line_rec.osp_order_id := l_osp_order_line_rec.osp_order_id;
        ELSIF(p_x_osp_order_line_rec.osp_order_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.osp_order_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.osp_line_number IS NULL) THEN
          p_x_osp_order_line_rec.osp_line_number := l_osp_order_line_rec.osp_line_number;
        ELSIF(p_x_osp_order_line_rec.osp_line_number = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.osp_line_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.status_code IS NULL) THEN
          p_x_osp_order_line_rec.status_code := l_osp_order_line_rec.status_code;
        ELSIF(p_x_osp_order_line_rec.status_code = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.status_code := null;
        END IF;
        IF (p_x_osp_order_line_rec.need_by_date IS NULL) THEN
          p_x_osp_order_line_rec.need_by_date := l_osp_order_line_rec.need_by_date;
        ELSIF(p_x_osp_order_line_rec.need_by_date = FND_API.G_MISS_DATE) THEN
          p_x_osp_order_line_rec.need_by_date := null;
        END IF;
        IF (p_x_osp_order_line_rec.ship_by_date IS NULL) THEN
          p_x_osp_order_line_rec.ship_by_date := l_osp_order_line_rec.ship_by_date;
        ELSIF(p_x_osp_order_line_rec.ship_by_date = FND_API.G_MISS_DATE) THEN
          p_x_osp_order_line_rec.ship_by_date := null;
        END IF;
        IF (p_x_osp_order_line_rec.service_item_id IS NULL) THEN
          p_x_osp_order_line_rec.service_item_id := l_osp_order_line_rec.service_item_id;
        ELSIF(p_x_osp_order_line_rec.service_item_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.service_item_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.service_item_number IS NULL) THEN
          p_x_osp_order_line_rec.service_item_number := l_osp_order_line_rec.service_item_number;
        ELSIF(p_x_osp_order_line_rec.service_item_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.service_item_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.service_item_description IS NULL) THEN
          p_x_osp_order_line_rec.service_item_description := l_osp_order_line_rec.service_item_description;
        ELSIF(p_x_osp_order_line_rec.service_item_description = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.service_item_description := null;
        END IF;
        IF (p_x_osp_order_line_rec.service_item_uom_code IS NULL) THEN
          p_x_osp_order_line_rec.service_item_uom_code := l_osp_order_line_rec.service_item_uom_code;
        ELSIF(p_x_osp_order_line_rec.service_item_uom_code = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.service_item_uom_code := null;
        END IF;
        IF (p_x_osp_order_line_rec.quantity IS NULL) THEN
          p_x_osp_order_line_rec.quantity := l_osp_order_line_rec.quantity;
        ELSIF(p_x_osp_order_line_rec.quantity = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.quantity := null;
        END IF;
        IF (p_x_osp_order_line_rec.po_line_type_id IS NULL) THEN
          p_x_osp_order_line_rec.po_line_type_id := l_osp_order_line_rec.po_line_type_id;
        ELSIF(p_x_osp_order_line_rec.po_line_type_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.po_line_type_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.po_line_id IS NULL) THEN
          p_x_osp_order_line_rec.po_line_id := l_osp_order_line_rec.po_line_id;
        ELSIF(p_x_osp_order_line_rec.po_line_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.po_line_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.oe_ship_line_id IS NULL) THEN
          p_x_osp_order_line_rec.oe_ship_line_id := l_osp_order_line_rec.oe_ship_line_id;
        ELSIF(p_x_osp_order_line_rec.oe_ship_line_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.oe_ship_line_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.oe_return_line_id IS NULL) THEN
          p_x_osp_order_line_rec.oe_return_line_id := l_osp_order_line_rec.oe_return_line_id;
        ELSIF(p_x_osp_order_line_rec.oe_return_line_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.oe_return_line_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.workorder_id IS NULL) THEN
          p_x_osp_order_line_rec.workorder_id := l_osp_order_line_rec.workorder_id;
        ELSIF(p_x_osp_order_line_rec.workorder_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.workorder_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.job_number IS NULL) THEN
          p_x_osp_order_line_rec.job_number := l_osp_order_line_rec.job_number;
        ELSIF(p_x_osp_order_line_rec.job_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.job_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.exchange_instance_id IS NULL) THEN
          p_x_osp_order_line_rec.exchange_instance_id := l_osp_order_line_rec.exchange_instance_id;
        ELSIF(p_x_osp_order_line_rec.exchange_instance_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.exchange_instance_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.exchange_instance_number IS NULL) THEN
          p_x_osp_order_line_rec.exchange_instance_number := l_osp_order_line_rec.exchange_instance_number;
        ELSIF(p_x_osp_order_line_rec.exchange_instance_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.exchange_instance_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.inventory_item_id IS NULL) THEN
          p_x_osp_order_line_rec.inventory_item_id := l_osp_order_line_rec.inventory_item_id;
        ELSIF(p_x_osp_order_line_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.inventory_item_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.inventory_org_id IS NULL) THEN
          p_x_osp_order_line_rec.inventory_org_id := l_osp_order_line_rec.inventory_org_id;
        ELSIF(p_x_osp_order_line_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.inventory_org_id := null;
        END IF;
        IF (p_x_osp_order_line_rec.item_number IS NULL) THEN
          p_x_osp_order_line_rec.item_number := l_osp_order_line_rec.item_number;
        ELSIF(p_x_osp_order_line_rec.item_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.item_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.inventory_item_uom IS NULL) THEN
          p_x_osp_order_line_rec.inventory_item_uom := l_osp_order_line_rec.inventory_item_uom;
        ELSIF(p_x_osp_order_line_rec.inventory_item_uom = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.inventory_item_uom := null;
        END IF;
        IF (p_x_osp_order_line_rec.inventory_item_quantity IS NULL) THEN
          p_x_osp_order_line_rec.inventory_item_quantity := l_osp_order_line_rec.inventory_item_quantity;
        ELSIF(p_x_osp_order_line_rec.inventory_item_quantity = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.inventory_item_quantity := null;
        END IF;
        IF (p_x_osp_order_line_rec.sub_inventory IS NULL) THEN
          p_x_osp_order_line_rec.sub_inventory := l_osp_order_line_rec.sub_inventory;
        ELSIF(p_x_osp_order_line_rec.sub_inventory = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.sub_inventory := null;
        END IF;
        IF (p_x_osp_order_line_rec.lot_number IS NULL) THEN
          p_x_osp_order_line_rec.lot_number := l_osp_order_line_rec.lot_number;
        ELSIF(p_x_osp_order_line_rec.lot_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.lot_number := null;
        END IF;
        IF (p_x_osp_order_line_rec.serial_number IS NULL) THEN
          p_x_osp_order_line_rec.serial_number := l_osp_order_line_rec.serial_number;
        ELSIF(p_x_osp_order_line_rec.serial_number = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.serial_number := null;
        END IF;

        -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
        IF (p_x_osp_order_line_rec.po_req_line_id IS NULL) THEN
          p_x_osp_order_line_rec.po_req_line_id := l_osp_order_line_rec.po_req_line_id;
        ELSIF(p_x_osp_order_line_rec.po_req_line_id = FND_API.G_MISS_NUM) THEN
          p_x_osp_order_line_rec.po_req_line_id := null;
        END IF;
        -- jaramana End

        IF (p_x_osp_order_line_rec.attribute_category IS NULL) THEN
          p_x_osp_order_line_rec.attribute_category := l_osp_order_line_rec.attribute_category;
        ELSIF(p_x_osp_order_line_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute_category := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute1 IS NULL) THEN
          p_x_osp_order_line_rec.attribute1 := l_osp_order_line_rec.attribute1;
        ELSIF(p_x_osp_order_line_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute1 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute2 IS NULL) THEN
          p_x_osp_order_line_rec.attribute2 := l_osp_order_line_rec.attribute2;
        ELSIF(p_x_osp_order_line_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute2 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute3 IS NULL) THEN
          p_x_osp_order_line_rec.attribute3 := l_osp_order_line_rec.attribute3;
        ELSIF(p_x_osp_order_line_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute3 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute4 IS NULL) THEN
          p_x_osp_order_line_rec.attribute4 := l_osp_order_line_rec.attribute4;
        ELSIF(p_x_osp_order_line_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute4 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute5 IS NULL) THEN
          p_x_osp_order_line_rec.attribute5 := l_osp_order_line_rec.attribute5;
        ELSIF(p_x_osp_order_line_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute5 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute6 IS NULL) THEN
          p_x_osp_order_line_rec.attribute6 := l_osp_order_line_rec.attribute6;
        ELSIF(p_x_osp_order_line_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute6 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute7 IS NULL) THEN
          p_x_osp_order_line_rec.attribute7 := l_osp_order_line_rec.attribute7;
        ELSIF(p_x_osp_order_line_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute7 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute8 IS NULL) THEN
          p_x_osp_order_line_rec.attribute8 := l_osp_order_line_rec.attribute8;
        ELSIF(p_x_osp_order_line_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute8 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute9 IS NULL) THEN
          p_x_osp_order_line_rec.attribute9 := l_osp_order_line_rec.attribute9;
        ELSIF(p_x_osp_order_line_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute9 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute10 IS NULL) THEN
          p_x_osp_order_line_rec.attribute10 := l_osp_order_line_rec.attribute10;
        ELSIF(p_x_osp_order_line_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute10 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute11 IS NULL) THEN
          p_x_osp_order_line_rec.attribute11 := l_osp_order_line_rec.attribute11;
        ELSIF(p_x_osp_order_line_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute11 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute12 IS NULL) THEN
          p_x_osp_order_line_rec.attribute12 := l_osp_order_line_rec.attribute12;
        ELSIF(p_x_osp_order_line_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute12 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute13 IS NULL) THEN
          p_x_osp_order_line_rec.attribute13 := l_osp_order_line_rec.attribute13;
        ELSIF(p_x_osp_order_line_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute13 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute14 IS NULL) THEN
          p_x_osp_order_line_rec.attribute14 := l_osp_order_line_rec.attribute14;
        ELSIF(p_x_osp_order_line_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute14 := null;
        END IF;
        IF (p_x_osp_order_line_rec.attribute15 IS NULL) THEN
          p_x_osp_order_line_rec.attribute15 := l_osp_order_line_rec.attribute15;
        ELSIF(p_x_osp_order_line_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
          p_x_osp_order_line_rec.attribute15 := null;
        END IF;
      END IF;
      CLOSE osp_order_lines_csr;
    ELSIF (p_x_osp_order_line_rec.operation_flag = G_OP_CREATE) THEN
      IF(p_x_osp_order_line_rec.osp_order_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.osp_order_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.osp_line_number = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.osp_line_number := null;
      END IF;
      IF(p_x_osp_order_line_rec.status_code = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.status_code := null;
      END IF;
      IF(p_x_osp_order_line_rec.need_by_date = FND_API.G_MISS_DATE) THEN
        p_x_osp_order_line_rec.need_by_date := null;
      END IF;
      IF(p_x_osp_order_line_rec.ship_by_date = FND_API.G_MISS_DATE) THEN
        p_x_osp_order_line_rec.ship_by_date := null;
      END IF;
      IF(p_x_osp_order_line_rec.service_item_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.service_item_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.service_item_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.service_item_number := null;
      END IF;
      IF(p_x_osp_order_line_rec.service_item_description = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.service_item_description := null;
      END IF;
      IF(p_x_osp_order_line_rec.service_item_uom_code = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.service_item_uom_code := null;
      END IF;
      IF(p_x_osp_order_line_rec.quantity = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.quantity := null;
      END IF;
      IF(p_x_osp_order_line_rec.po_line_type_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.po_line_type_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.po_line_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.po_line_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.oe_ship_line_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.oe_ship_line_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.oe_return_line_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.oe_return_line_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.workorder_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.workorder_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.job_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.job_number := null;
      END IF;
      IF(p_x_osp_order_line_rec.exchange_instance_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.exchange_instance_id := null;
      END IF;
      IF(p_x_osp_order_line_rec.exchange_instance_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.exchange_instance_number := null;
      END IF;
      IF (p_x_osp_order_line_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.inventory_item_id := null;
      END IF;
      IF (p_x_osp_order_line_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.inventory_org_id := null;
      END IF;
      IF (p_x_osp_order_line_rec.item_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.item_number := null;
      END IF;
      IF (p_x_osp_order_line_rec.inventory_item_uom = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.inventory_item_uom := null;
      END IF;
      IF (p_x_osp_order_line_rec.inventory_item_quantity = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.inventory_item_quantity := null;
      END IF;
      IF (p_x_osp_order_line_rec.sub_inventory = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.sub_inventory := null;
      END IF;
      IF (p_x_osp_order_line_rec.lot_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.lot_number := null;
      END IF;
      IF (p_x_osp_order_line_rec.serial_number = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.serial_number := null;
      END IF;
      -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
      IF (p_x_osp_order_line_rec.po_req_line_id  = FND_API.G_MISS_NUM) THEN
        p_x_osp_order_line_rec.po_req_line_id := null;
      END IF;
      -- jaramana End
      IF (p_x_osp_order_line_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute_category := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute1 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute2 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute3 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute4 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute5 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute6 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute7 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute8 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute9 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute10 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute11 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute12 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute13 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute14 := null;
      END IF;
      IF (p_x_osp_order_line_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
        p_x_osp_order_line_rec.attribute15 := null;
      END IF;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END default_unchanged_order_line;

--Copied from original convert_order_lines_val_to_id, so some inherited logic
--may not be necessary
PROCEDURE convert_order_line_val_to_id(p_x_osp_order_line_rec IN OUT NOCOPY  osp_order_line_rec_type)
IS
    CURSOR workorder_id_csr(p_job_number IN VARCHAR2) IS
    --Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
    /*
    SELECT workorder_id
      FROM ahl_workorders_osp_v
     WHERE job_number = p_job_number;
    */
    SELECT workorder_id from ahl_workorders
     WHERE workorder_name = p_job_number;

    l_workorder_id NUMBER;
    CURSOR service_item_id_csr(p_service_item_number IN VARCHAR2, p_inventory_org_id NUMBER) IS
    SELECT MTL.inventory_item_id
      FROM mtl_system_items_kfv MTL
     WHERE MTL.concatenated_segments = p_service_item_number
       AND MTL.organization_id = p_inventory_org_id;
    l_service_item_id NUMBER;
    l_organization_id NUMBER;
    CURSOR po_line_type_id_csr(p_po_line_type IN VARCHAR2) IS
    SELECT line_type_id
      FROM po_line_types
     WHERE line_type = p_po_line_type
       AND order_type_lookup_code = 'QUANTITY'
       AND NVL(outside_operation_flag, G_NO_FLAG) = G_NO_FLAG;
    l_po_line_type_id NUMBER;
    CURSOR osp_order_line_on_csr(p_osp_order_id IN NUMBER, p_osp_line_number IN NUMBER) IS
    SELECT osp_order_line_id
      FROM ahl_osp_order_lines
     WHERE osp_order_id = p_osp_order_id
    and osp_line_number = p_osp_line_number;
    -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
    -- We are not planning to derive the OSP_ORDER_LINE_ID from PO_LINE_ID
    /*
    CURSOR osp_order_line_po_csr(p_po_line_id IN NUMBER) IS
    SELECT osp_order_line_id
      FROM ahl_osp_order_lines
     WHERE po_line_id = p_po_line_id;
    */
    -- jaramana End
    l_osp_order_line_id NUMBER;
    CURSOR exchange_instance_id_csr(p_exchange_instance_number IN VARCHAR2) IS
    SELECT instance_id
      FROM csi_item_instances
     WHERE instance_number = p_exchange_instance_number;
    l_exchange_instance_id NUMBER;
    CURSOR physical_item_id_csr(p_item_number IN VARCHAR2, p_inventory_org_id NUMBER) IS
    SELECT MTL.inventory_item_id
      FROM mtl_system_items_kfv MTL
     WHERE MTL.concatenated_segments = p_item_number
       AND MTL.organization_id = p_inventory_org_id;
    l_physical_item_id NUMBER;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.convert_order_lines_val_to_id';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
    -- nulling out ids if module type is JSP
    --Jerry 04/18/2005, this 'JSP' consideration may not be necessary for
    --newly added physical item, so it is not added here
        IF(g_module_type = 'JSP') THEN
            -- service item number
            IF(p_x_osp_order_line_rec.service_item_number IS NULL) THEN
                p_x_osp_order_line_rec.service_item_id := NULL;
            ELSIF (p_x_osp_order_line_rec.service_item_number = FND_API.G_MISS_CHAR) THEN
                IF(p_x_osp_order_line_rec.operation_flag <> G_OP_CREATE) THEN
                    p_x_osp_order_line_rec.service_item_id := FND_API.G_MISS_NUM;
                ELSE
                    p_x_osp_order_line_rec.service_item_id := NULL;
                END IF;
            END IF;
            -- job number and workorder_id
            IF(p_x_osp_order_line_rec.job_number IS NULL) THEN
                p_x_osp_order_line_rec.workorder_id := NULL;
            ELSIF (p_x_osp_order_line_rec.job_number = FND_API.G_MISS_CHAR) THEN
                IF(p_x_osp_order_line_rec.operation_flag <> G_OP_CREATE) THEN
                    p_x_osp_order_line_rec.workorder_id := FND_API.G_MISS_NUM;
                ELSE
                    p_x_osp_order_line_rec.workorder_id := NULL;
                END IF;
            END IF;
            -- po_line_type_id
            IF(p_x_osp_order_line_rec.po_line_type IS NULL) THEN
                p_x_osp_order_line_rec.po_line_type_id := NULL;
            ELSIF (p_x_osp_order_line_rec.po_line_type = FND_API.G_MISS_CHAR) THEN
                IF(p_x_osp_order_line_rec.operation_flag <> G_OP_CREATE) THEN
                    p_x_osp_order_line_rec.po_line_type_id := FND_API.G_MISS_NUM;
                ELSE
                    p_x_osp_order_line_rec.po_line_type_id := NULL;
                END IF;
            END IF;
        END IF;
       -- conversion of value to id for job number (to workorder_id)
       IF (p_x_osp_order_line_rec.job_number IS NOT NULL AND  p_x_osp_order_line_rec.job_number <> FND_API.G_MISS_CHAR) THEN
         OPEN workorder_id_csr(p_x_osp_order_line_rec.job_number);
         FETCH workorder_id_csr INTO l_workorder_id;
         IF(workorder_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_JOB_NUM_INV');
            FND_MESSAGE.Set_Token('JOB_NUMBER', p_x_osp_order_line_rec.job_number);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_line_rec.workorder_id := l_workorder_id;
         END IF;
         CLOSE workorder_id_csr;
       END IF;
       -- conversion of value to id for service item number
       IF (p_x_osp_order_line_rec.service_item_number IS NOT NULL AND  p_x_osp_order_line_rec.service_item_number <> FND_API.G_MISS_CHAR) THEN
         OPEN service_item_id_csr(p_x_osp_order_line_rec.service_item_number, p_x_osp_order_line_rec.inventory_org_id);
         FETCH service_item_id_csr INTO l_service_item_id;
         IF(service_item_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_SVC_ITEM_INV');
            FND_MESSAGE.Set_Token('SERVICE_ITEM', p_x_osp_order_line_rec.service_item_number);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_line_rec.service_item_id := l_service_item_id;
         END IF;
         CLOSE service_item_id_csr;
       END IF;
       -- conversion of value to id for po_line_type (to po_line_type_id)
       IF (p_x_osp_order_line_rec.po_line_type IS NOT NULL AND  p_x_osp_order_line_rec.po_line_type <> FND_API.G_MISS_CHAR) THEN
         OPEN po_line_type_id_csr(p_x_osp_order_line_rec.po_line_type);
         FETCH po_line_type_id_csr INTO l_po_line_type_id;
         IF(po_line_type_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PO_LN_TYPE_INV');
            FND_MESSAGE.Set_Token('PO_LINE_TYPE', p_x_osp_order_line_rec.po_line_type);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_line_rec.po_line_type_id := l_po_line_type_id;
         END IF;
         CLOSE po_line_type_id_csr;
       END IF;
       -- conversion of value to id for exchange_instance_number (to exchange_instance_id)
       IF (p_x_osp_order_line_rec.exchange_instance_number IS NOT NULL AND  p_x_osp_order_line_rec.exchange_instance_number <> FND_API.G_MISS_CHAR) THEN
         OPEN exchange_instance_id_csr(p_x_osp_order_line_rec.exchange_instance_number);
         FETCH exchange_instance_id_csr INTO l_exchange_instance_id;
         IF(exchange_instance_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_X_INST_NUM_INV');
            FND_MESSAGE.Set_Token('INTANCE_NUMBER', p_x_osp_order_line_rec.exchange_instance_number);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_line_rec.exchange_instance_id := l_exchange_instance_id;
         END IF;
         CLOSE exchange_instance_id_csr;
       END IF;
       -- conversion of value to id for physical item number
       IF (p_x_osp_order_line_rec.item_number IS NOT NULL AND  p_x_osp_order_line_rec.inventory_item_id IS NULL) THEN
         OPEN physical_item_id_csr(p_x_osp_order_line_rec.item_number, p_x_osp_order_line_rec.inventory_org_id);
         FETCH physical_item_id_csr INTO l_physical_item_id;
         IF(physical_item_id_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_PHY_ITEM_INV');
            FND_MESSAGE.Set_Token('PHSICAL_ITEM', p_x_osp_order_line_rec.item_number);
            FND_MSG_PUB.ADD;
         ELSE
            p_x_osp_order_line_rec.inventory_item_id := l_physical_item_id;
         END IF;
         CLOSE physical_item_id_csr;
       END IF;
       -- fetching the unique key osp_order_line_id based on other unique keys
       IF (p_x_osp_order_line_rec.osp_order_line_id IS NULL) THEN
            IF p_x_osp_order_line_rec.operation_flag <> G_OP_CREATE THEN
                IF (p_x_osp_order_line_rec.osp_order_id IS NOT NULL AND p_x_osp_order_line_rec.osp_line_number IS NOT NULL) THEN
                    OPEN osp_order_line_on_csr(p_x_osp_order_line_rec.osp_order_id , p_x_osp_order_line_rec.osp_line_number);
                    FETCH osp_order_line_on_csr INTO l_osp_order_line_id;
                    IF(osp_order_line_on_csr%NOTFOUND) THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ORD_ID_LN_INV');
                        FND_MESSAGE.Set_Token('OSP_LINE_NUMBER', p_x_osp_order_line_rec.osp_line_number);
                        FND_MSG_PUB.ADD;
                    ELSE
                        p_x_osp_order_line_rec.osp_order_line_id := l_osp_order_line_id;
                    END IF;
                    CLOSE osp_order_line_on_csr;
                -- Added by jaramana on January 10, 2008 for the Requisition ER 6034236
                -- We are not planning to derive the OSP_ORDER_LINE_ID from PO_LINE_ID
                /*
                ELSIF (p_x_osp_order_line_rec.po_line_id IS NOT NULL AND p_x_osp_order_line_rec.po_line_id <>  FND_API.G_MISS_NUM) THEN
                    OPEN osp_order_line_po_csr(p_x_osp_order_line_rec.po_line_id );
                    FETCH osp_order_line_po_csr INTO l_osp_order_line_id;
                    IF(osp_order_line_po_csr%NOTFOUND) THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_PO_LINE_INV');
                        FND_MESSAGE.Set_Token('PO_LINE_ID', p_x_osp_order_line_rec.po_line_id);
                        FND_MSG_PUB.ADD;
                    ELSE
                        p_x_osp_order_line_rec.osp_order_line_id := l_osp_order_line_id;
                    END IF;
                    CLOSE osp_order_line_po_csr;
                */
                -- jaramana End
                ELSE
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV');
                    FND_MESSAGE.Set_Token('OSP_LINE_NUMBER', p_x_osp_order_line_rec.osp_line_number);                     FND_MSG_PUB.ADD;
                END IF;
            END IF;
        END IF;
    IF FND_MSG_PUB.count_msg > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
     --dbms_output.put_line('Exiting : convert_order_lines_val_to_id');
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
    END IF;
END convert_order_line_val_to_id;

--validate service_item_id (simplified the original one)
PROCEDURE validate_service_item_id(
  p_service_item_id IN NUMBER,
  p_organization_id IN NUMBER)
IS
  CURSOR val_service_item_id_csr IS
    SELECT 'X'
      FROM mtl_system_items_kfv MTL
     WHERE MTL.inventory_item_id = p_service_item_id
       AND MTL.enabled_flag = G_YES_FLAG
       AND MTL.inventory_item_flag = G_NO_FLAG
       AND MTL.stock_enabled_flag = G_NO_FLAG
       AND NVL(MTL.start_date_active, SYSDATE - 1) <= SYSDATE
       AND NVL(MTL.end_date_active, SYSDATE + 1) > SYSDATE
       AND MTL.purchasing_enabled_flag = G_YES_FLAG
       AND NVL(MTL.outside_operation_flag, G_NO_FLAG) = G_NO_FLAG
       AND MTL.organization_id = p_organization_id;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_service_item_id';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
  END IF;

  IF(p_service_item_id IS NOT NULL AND p_service_item_id <> FND_API.G_MISS_NUM) THEN
    OPEN val_service_item_id_csr;
    FETCH val_service_item_id_csr INTO g_dummy_char;
    IF(val_service_item_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_LN_INV_SVC_ITEM');
      FND_MESSAGE.Set_Token('SERVICE_ITEM_ID', p_service_item_id);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE val_service_item_id_csr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
END validate_service_item_id;

--Validate header vendor with physical, service item combination in line
PROCEDURE validate_vendor_service_item(p_osp_order_line_rec IN osp_order_line_rec_type)
IS
  l_vendor_id         NUMBER;
  l_vendor_site_id    NUMBER;
  l_vendor_contact_id NUMBER;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  CURSOR verify_vendor(c_vendor_id NUMBER, c_vendor_site_id NUMBER) IS
    SELECT A.inv_service_item_rel_id
      FROM ahl_inv_service_item_rels A,
           ahl_item_vendor_rels_v B
     WHERE A.inv_service_item_rel_id = B.inv_service_item_rel_id
       AND A.inv_item_id = p_osp_order_line_rec.inventory_item_id
       AND A.inv_org_id = p_osp_order_line_rec.inventory_org_id
       AND A.service_item_id = p_osp_order_line_rec.service_item_id
       AND TRUNC(A.active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(NVL(A.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE)
       AND TRUNC(B.active_start_date) <= TRUNC(SYSDATE)
       AND TRUNC(NVL(B.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE)
       AND B.vendor_id = c_vendor_id
       AND B.vendor_site_id = c_vendor_site_id;
       --AND B.vendor_contact_id = l_vendor_contact_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     G_LOG_PREFIX || '.validate_vendor_service_item',
                     'osp_order_id='||p_osp_order_line_rec.osp_order_id );
  END IF;
  --IF (p_osp_order_line_rec.workorder_id IS NULL) THEN --commented out on 06/10/2006
    /*(From Jay said on 06/07/2005) service_item_id is not mandatory even for update
    IF p_osp_order_line_rec.service_item_id IS NULL THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_SERVICE_ITEM_NULL');
      FND_MSG_PUB.add;
    END IF;
    */
    --(Note: 05/31/2005 Jerry)It is not good to use ahl_osp_orders_v here but
    --there exists a special case where vendor_contact_id is null in
    --ahl_osp_orders_b but populated in ahl_osp_orders_v. After discussion with
    --Jay and found we have to use _v here because the vendor_id and vendor_site_id
    --could be changed from PO side
  BEGIN
    --Modified by mpothuku on 27-Feb-06 to fix the Perf Bug #4919164
    /*
    SELECT decode(osp.po_header_id, null, osp.vendor_id, po.vendor_id) vendor_id,
           decode(osp.po_header_id, null, osp.vendor_site_id, po.vendor_site_id) vendor_site_id --, vendor_contact_id
      INTO l_vendor_id, l_vendor_site_id --, l_vendor_contact_id
      FROM ahl_osp_orders_b osp,
           po_headers_all po
     WHERE osp.osp_order_id = p_osp_order_line_rec.osp_order_id
       AND osp.po_header_id = po.po_header_id(+);
    */
    --modified by mpothuku on 14-mar-2008 to fix the Bug 6885513
    SELECT vendor_id,
           vendor_site_id
      INTO l_vendor_id, l_vendor_site_id --, l_vendor_contact_id
      FROM ahl_osp_orders_b osp
     WHERE osp.osp_order_id = p_osp_order_line_rec.osp_order_id;
    --mpothuku End
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_ORDER_INVALID');
      FND_MSG_PUB.add;
  END;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX || '.validate_vendor_service_item',
                     'vendor_id='||l_vendor_id||
                     'item_id='||p_osp_order_line_rec.inventory_item_id||
                     'org_id='||p_osp_order_line_rec.inventory_org_id||
                     'service_id='||p_osp_order_line_rec.service_item_id);
  END IF;

  IF (l_vendor_id IS NOT NULL AND l_vendor_site_id IS NOT NULL AND
      p_osp_order_line_rec.service_item_id IS NOT NULL) THEN
    --If the service_item_id in OSP Order Line is null then we don't have to
    --validate it against OSP header vendor attributes
    --Check the vendor itself is valid
    BEGIN
      SELECT 'X' INTO g_dummy_char
        FROM ahl_vendor_certifications_v
       WHERE vendor_id = l_vendor_id
         AND vendor_site_id = l_vendor_site_id
         AND trunc(active_start_date) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_VENDOR_ID_INV');
        FND_MESSAGE.Set_Token('VENDOR_ID', l_vendor_id);
        FND_MSG_PUB.ADD;
    END;

    OPEN verify_vendor(l_vendor_id, l_vendor_site_id);
    FETCH verify_vendor INTO g_dummy_num;
    IF verify_vendor%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_OSP_ITEM_VENDOR_MISMATCH');
      FND_MESSAGE.set_token('ITEM_ID', p_osp_order_line_rec.inventory_item_id);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
      --FND_MSG_PUB.count_and_get(
        --p_encoded  => FND_API.G_FALSE,
        --p_count    => l_msg_count,
        --p_data     => l_msg_data);
    END IF;
    CLOSE verify_vendor;
  END IF;
  --END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX || '.validate_vendor_service_item',
                   'Normal end and msg_count='||l_msg_count||
                   'msg='||l_msg_data);
  END IF;
END validate_vendor_service_item;

PROCEDURE process_order_type_change(
  p_osp_order_rec IN osp_order_rec_type) IS
  l_old_type_code VARCHAR2(30);
  l_return_status VARCHAR2(30);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX||'process_order_type_change', 'Begin');
  END IF;
  SELECT order_type_code INTO l_old_type_code
    FROM ahl_osp_orders_b
   WHERE osp_order_id = p_osp_order_rec.osp_order_id;
  IF l_old_type_code <> p_osp_order_rec.order_type_code THEN
    IF(can_convert_order(p_osp_order_rec.osp_order_id, l_old_type_code, p_osp_order_rec.order_type_code)) THEN
      IF(p_osp_order_rec.order_type_code = G_OSP_ORDER_TYPE_SERVICE) THEN
        UPDATE ahl_osp_order_lines
           SET exchange_instance_id = NULL,
               last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id,
               object_version_number = object_version_number+1
        WHERE osp_order_id = p_osp_order_rec.osp_order_id;
        --set exchange instance id to null and update object_version_number in p_x_osp_order_lines_tbl
        --nullify_exchange_instance(p_osp_order_rec.osp_order_id, p_x_osp_order_lines_tbl);
      END IF;
      AHL_OSP_SHIPMENT_PUB.convert_subtxn_type(
          p_api_version          =>    1.0,
          p_init_msg_list        =>    FND_API.G_FALSE,
          p_commit               =>    FND_API.G_FALSE,
          p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL,
          p_default              =>    FND_API.G_TRUE,
          p_module_type          =>    NULL,
          p_osp_order_id         =>    p_osp_order_rec.osp_order_id ,
          p_old_order_type_code  =>    l_old_type_code,
          p_new_order_type_code  =>    p_osp_order_rec.order_type_code,
          x_return_status        =>    l_return_status,
          x_msg_count            =>    l_msg_count,
          x_msg_data             =>    l_msg_data);
    END IF;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_LOG_PREFIX||'process_order_type_change', 'End');
  END IF;
END process_order_type_change;

END ahl_osp_orders_pvt;

/*
PROCEDURE nullify_exchange_instance(
             p_osp_order_id IN NUMBER,
             p_x_osp_order_lines_tbl IN OUT NOCOPY osp_order_lines_tbl_type
           ) IS
CURSOR l_order_lines_csr(p_osp_order_id IN NUMBER) IS
    SELECT osp_order_line_id, object_version_number, last_update_date, last_updated_by , last_update_login,
           osp_order_id, osp_line_number, status_code , po_line_type_id, service_item_id, service_item_description , service_item_uom_code,
           need_by_date, ship_by_date, po_line_id, oe_ship_line_id , oe_return_line_id , workorder_id, operation_id,
           quantity, exchange_instance_id, attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6,
           attribute7, attribute8, attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
   FROM ahl_osp_order_lines
   WHERE osp_order_id = p_osp_order_id;
l_osp_order_lines_rec osp_order_line_rec_type;
CURSOR l_order_line_obj_ver_csr(p_osp_order_line_id IN NUMBER) IS
   SELECT object_version_number FROM ahl_osp_order_lines
   WHERE osp_order_line_id = p_osp_order_line_id;
i  NUMBER;   --index for looping
L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.nullify_exchange_instance';
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Begin Procedure');
    END IF;
  OPEN l_order_lines_csr(p_osp_order_id);
  LOOP
     FETCH l_order_lines_csr INTO l_osp_order_lines_rec.osp_order_line_id         ,
                               l_osp_order_lines_rec.object_version_number     ,
                               l_osp_order_lines_rec.last_update_date          ,
                               l_osp_order_lines_rec.last_updated_by           ,
                               l_osp_order_lines_rec.last_update_login         ,
                               l_osp_order_lines_rec.osp_order_id              ,
                               l_osp_order_lines_rec.osp_line_number           ,
                               l_osp_order_lines_rec.status_code               ,
                               l_osp_order_lines_rec.po_line_type_id           ,
                               l_osp_order_lines_rec.service_item_id           ,
                               l_osp_order_lines_rec.service_item_description  ,
                               l_osp_order_lines_rec.service_item_uom_code     ,
                               l_osp_order_lines_rec.need_by_date              ,
                               l_osp_order_lines_rec.ship_by_date              ,
                               l_osp_order_lines_rec.po_line_id                ,
                               l_osp_order_lines_rec.oe_ship_line_id           ,
                               l_osp_order_lines_rec.oe_return_line_id         ,
                               l_osp_order_lines_rec.workorder_id              ,
                               l_osp_order_lines_rec.operation_id              ,
                               l_osp_order_lines_rec.quantity                  ,
                               l_osp_order_lines_rec.exchange_instance_id      ,
                               l_osp_order_lines_rec.attribute_category        ,
                               l_osp_order_lines_rec.attribute1                ,
                               l_osp_order_lines_rec.attribute2                ,
                               l_osp_order_lines_rec.attribute3                ,
                               l_osp_order_lines_rec.attribute4                ,
                               l_osp_order_lines_rec.attribute5                ,
                               l_osp_order_lines_rec.attribute6                ,
                               l_osp_order_lines_rec.attribute7                ,
                               l_osp_order_lines_rec.attribute8                ,
                               l_osp_order_lines_rec.attribute9                ,
                               l_osp_order_lines_rec.attribute10               ,
                               l_osp_order_lines_rec.attribute11               ,
                               l_osp_order_lines_rec.attribute12               ,
                               l_osp_order_lines_rec.attribute13               ,
                               l_osp_order_lines_rec.attribute14               ,
                               l_osp_order_lines_rec.attribute15               ;
     IF(l_order_lines_csr %NOTFOUND) THEN
       EXIT;
     END IF;
     AHL_OSP_ORDER_LINES_PKG.update_row(
        p_osp_order_line_id        =>  l_osp_order_lines_rec.osp_order_line_id,
        p_object_version_number    =>  l_osp_order_lines_rec.object_version_number + 1,
        p_last_update_date         =>  l_osp_order_lines_rec.last_update_date,
        p_last_updated_by          =>  l_osp_order_lines_rec.last_updated_by,
        p_last_update_login        =>  l_osp_order_lines_rec.last_update_login,
        p_osp_order_id             =>  l_osp_order_lines_rec.osp_order_id,
        p_osp_line_number          =>  l_osp_order_lines_rec.osp_line_number,
        p_status_code              =>  l_osp_order_lines_rec.status_code,
        p_po_line_type_id          =>  l_osp_order_lines_rec.po_line_type_id,
        p_service_item_id          =>  l_osp_order_lines_rec.service_item_id,
        p_service_item_description =>  l_osp_order_lines_rec.service_item_description,
        p_service_item_uom_code    =>  l_osp_order_lines_rec.service_item_uom_code,
        p_need_by_date             =>  l_osp_order_lines_rec.need_by_date,
        p_ship_by_date             =>  l_osp_order_lines_rec.ship_by_date,
        p_po_line_id               =>  l_osp_order_lines_rec.po_line_id,
        p_oe_ship_line_id          =>  l_osp_order_lines_rec.oe_ship_line_id,
        p_oe_return_line_id        =>  l_osp_order_lines_rec.oe_return_line_id,
        p_workorder_id             =>  l_osp_order_lines_rec.workorder_id,
        p_operation_id             =>  l_osp_order_lines_rec.operation_id,
        p_quantity                 =>  l_osp_order_lines_rec.quantity,
        p_exchange_instance_id     =>  NULL,
        p_inventory_item_id       => l_osp_order_lines_rec.inventory_item_id,
        p_inventory_org_id        => l_osp_order_lines_rec.inventory_org_id,
        p_inventory_item_uom      => l_osp_order_lines_rec.inventory_item_uom,
        p_inventory_item_quantity => l_osp_order_lines_rec.inventory_item_quantity,
        p_sub_inventory           => l_osp_order_lines_rec.sub_inventory,
        p_lot_number              => l_osp_order_lines_rec.lot_number,
        p_serial_number           => l_osp_order_lines_rec.serial_number,

        p_attribute_category       =>  l_osp_order_lines_rec.attribute_category,
        p_attribute1               =>  l_osp_order_lines_rec.attribute1,
        p_attribute2               =>  l_osp_order_lines_rec.attribute2,
        p_attribute3               =>  l_osp_order_lines_rec.attribute3,
        p_attribute4               =>  l_osp_order_lines_rec.attribute4,
        p_attribute5               =>  l_osp_order_lines_rec.attribute5,
        p_attribute6               =>  l_osp_order_lines_rec.attribute6,
        p_attribute7               =>  l_osp_order_lines_rec.attribute7,
        p_attribute8               =>  l_osp_order_lines_rec.attribute8,
        p_attribute9               =>  l_osp_order_lines_rec.attribute9,
        p_attribute10              =>  l_osp_order_lines_rec.attribute10,
        p_attribute11              =>  l_osp_order_lines_rec.attribute11,
        p_attribute12              =>  l_osp_order_lines_rec.attribute12,
        p_attribute13              =>  l_osp_order_lines_rec.attribute13,
        p_attribute14              =>  l_osp_order_lines_rec.attribute14,
        p_attribute15              =>  l_osp_order_lines_rec.attribute15
     );
  END LOOP;
  --get the newest object_version_number for p_x_osp_order_lines_tbl
  IF(p_x_osp_order_lines_tbl IS NOT NULL AND p_x_osp_order_lines_tbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, ' p_x_osp_order_lines_tbl not null' ||
                              'p_x_osp_order_lines_tbl.FIRST: ' || p_x_osp_order_lines_tbl.FIRST ||
                              'p_x_osp_order_lines_tbl.LAST:  ' || p_x_osp_order_lines_tbl.LAST);
     END IF;
    FOR i IN p_x_osp_order_lines_tbl.FIRST..p_x_osp_order_lines_tbl.LAST  LOOP
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'loop inside table p_x_osp_order_lines_tbl');
        END IF;
        IF(p_x_osp_order_lines_tbl(i).osp_order_line_id IS NOT NULL) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'loop inside table p_x_osp_order_lines_tbl.osp_order_line_id');
          END IF;
           OPEN l_order_line_obj_ver_csr(p_x_osp_order_lines_tbl(i).osp_order_line_id);
           FETCH l_order_line_obj_ver_csr INTO p_x_osp_order_lines_tbl(i).object_version_number;
           CLOSE l_order_line_obj_ver_csr;
        END IF;
    END LOOP;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
END nullify_exchange_instance;
*/

/
