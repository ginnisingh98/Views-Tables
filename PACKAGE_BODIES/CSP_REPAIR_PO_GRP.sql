--------------------------------------------------------
--  DDL for Package Body CSP_REPAIR_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REPAIR_PO_GRP" AS
/* $Header: cspgrpob.pls 120.19.12010000.6 2011/09/19 23:33:42 ajosephg ship $ */
-- Purpose: To create Repair execution
-- Start of Comments
-- Package name     : CSP_REPAIR_PO_GRP
-- Purpose          : This package creates Repair Purchase Order Requisition and Reservation of defective parts.
-- History          : 09-June-2005, Arul Joseph.
-- NOTE             :
-- End of Comments

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'CSP_REPAIR_PO_GRP';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvprqb.pls';

  PROCEDURE CREATE_REPAIR_PO
         (p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2  DEFAULT FND_API.G_FALSE
         ,p_commit                  IN VARCHAR2  DEFAULT FND_API.G_FALSE
         ,P_repair_supplier_id		IN NUMBER
         ,P_repair_supplier_org_id	IN NUMBER
         ,P_repair_program			IN VARCHAR2
         ,P_dest_organization_id	IN NUMBER
         ,P_source_organization_id	IN NUMBER
         ,P_repair_to_item_id		IN NUMBER
         ,P_quantity				IN NUMBER
         ,P_need_by_date            IN DATE
         ,P_defective_parts_tbl	    IN CSP_REPAIR_PO_GRP.defective_parts_tbl_Type
         ,x_requisition_header_id   OUT NOCOPY NUMBER
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
         )
  IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_REPAIR_PO';
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;
  EXCP_USER_DEFINED        EXCEPTION;
  l_check_existence        NUMBER;

  l_defective_parts_rec   CSP_REPAIR_PO_GRP.defective_parts_rec_type;
  l_defective_parts_tbl   CSP_REPAIR_PO_GRP.defective_parts_tbl_Type;

  l_reservation_rec       CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
  l_out_reservation_rec   CSP_REPAIR_PO_GRP.out_reserve_rec_type;
  l_out_reservation_tbl   CSP_REPAIR_PO_GRP.out_reserve_tbl_type;
  x_reservation_id        NUMBER;

  l_header_rec             CSP_PARTS_REQUIREMENT.header_rec_type;
  l_line_rec               CSP_PARTS_REQUIREMENT.Line_rec_type;
  l_lines_tbl              CSP_PARTS_REQUIREMENT.Line_Tbl_type;
  l_repair_po_header_id    NUMBER ;

  L_repair_supplier_org_id	NUMBER;
  L_VENDOR_NAME Varchar2(240);
  L_SOURCE_ORGANIZATION_NAME Varchar2(240);
  L_REPAIR_ORGANIZATION_NAME Varchar2(240);
  L_DEST_ORGANIZATION_NAME Varchar2(240);
  ln_count NUMBER;
  X_item_number VARCHAR2(40);

  X_PRIMARY_UOM_CODE          VARCHAR2(3);
  l_REVISION_QTY_CONTROL_CODE NUMBER;
  l_REVISION                  VARCHAR2(3);
  X_ITEM_DESCRIPTION          VARCHAR2(240);
  l_ship_to_location_id       NUMBER;
  l_shipping_method_code      VARCHAR2(30);
  l_supplier_org_location_id  NUMBER;

  l_MEANING     VARCHAR2(80);
  l_LOOKUP_CODE NUMBER;
  P_NOTE_ID     NUMBER;
  P_NOTE        LONG;
  X_Rowid VARCHAR2(2000);
  X_document_id NUMBER;
  X_media_id NUMBER;

  x_repair_po_header_id NUMBER;
  x_order_header_id     NUMBER;
  x_requisition_number  VARCHAR2(20);

  x_requisition_line_id NUMBER;
  x_order_line_id       NUMBER;
  x_line_num            NUMBER;
  x_poreq_line_reservation_id NUMBER;
  x_repair_po_line_id NUMBER;
  l_repair_po_line_id NUMBER;
  L_DEMAND_SOURCE_LINE_ID NUMBER;
 BEGIN

    SAVEPOINT CREATE_REPAIR_PO_PUB;

/*----------- Initialize Message List ------------ */
    IF fnd_api.to_boolean(P_Init_Msg_List) THEN
       FND_MSG_PUB.initialize;
    END IF;

/*----------- Standard call to check for call compatibility --------- */
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

/* ------- Initialize Return Status --------- */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_defective_parts_tbl := p_defective_parts_tbl;

/* -------- User and Login Information -------- */
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

/* --------- Start Create Reservations for Defective Parts passed ----------- */
    FOR I IN 1..l_defective_parts_tbl.COUNT
    LOOP
        l_defective_parts_rec := l_defective_parts_tbl(I);

        l_reservation_rec.need_by_date := P_need_by_date;
        l_reservation_rec.organization_id := P_source_organization_id; -- Defective Warehouse
        l_reservation_rec.item_id := l_defective_parts_rec.defective_item_id;
        l_reservation_rec.quantity_needed := l_defective_parts_rec.defective_quantity;
        l_reservation_rec.sub_inventory_code := Null;

       -- SELECT nvl(MAX(RESERVATION_ID),0) + 1 into l_demand_source_line_id FROM MTL_RESERVATIONS;
        Select MTL_DEMAND_S.NEXTVAL INTO l_demand_source_line_id FROM DUAL;
        l_reservation_rec.line_id := l_demand_source_line_id;

        If l_defective_parts_rec.defective_quantity <= 0 then
           FND_MESSAGE.SET_NAME ('CSP','CSP_INVALID_DEFECTIVE_QUANTITY');
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        End if;

        CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
           (P_source_organization_id
           ,l_defective_parts_rec.defective_item_id
           ,x_item_number
           ,x_item_description
           ,x_primary_uom_code
           ,x_return_status
           ,x_msg_data
           ,x_msg_count
           );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           L_SOURCE_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_source_organization_id);
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFECTITEM_AT_DEFECTORG');
           FND_MESSAGE.SET_TOKEN ('DEFECTIVE_ORG_NAME', L_SOURCE_ORGANIZATION_NAME,TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        END IF;

        CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
           (P_repair_supplier_org_id
           ,l_defective_parts_rec.defective_item_id
           ,x_item_number
           ,x_item_description
           ,x_primary_uom_code
           ,x_return_status
           ,x_msg_data
           ,x_msg_count
           );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           L_REPAIR_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_repair_supplier_org_id);
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFECTITEM_AT_REPAIRORG');
           FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG_NAME', L_REPAIR_ORGANIZATION_NAME,TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        END IF;

        l_reservation_rec.item_uom_code := X_PRIMARY_UOM_CODE;

        x_reservation_id := csp_sch_int_pvt.create_reservation(
                                                p_reservation_parts => l_reservation_rec,
                                                x_return_status     => l_return_status,
                                                x_msg_data          => l_msg_data
                                                );

        IF x_reservation_id = 0 OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE EXCP_USER_DEFINED;
        Elsif l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            /* This is for Insert the Reservation_id into CSP_REPAIR_PO_LINES table
               all the reservation made for defective parts
            */

            l_out_reservation_rec.need_by_date := l_reservation_rec.need_by_date;
            l_out_reservation_rec.organization_id := l_reservation_rec.organization_id; ---- Defective Warehouse
            l_out_reservation_rec.item_id := l_reservation_rec.item_id; ---- Defective Item
            l_out_reservation_rec.quantity_needed := l_reservation_rec.quantity_needed;
            l_out_reservation_rec.sub_inventory_code := Null;
            l_out_reservation_rec.line_id := Null;
            l_out_reservation_rec.item_uom_code := l_reservation_rec.item_uom_code;

            l_out_reservation_rec.reservation_id := x_reservation_id;

            l_out_reservation_tbl(I) := l_out_reservation_rec;

            If L_SOURCE_ORGANIZATION_NAME is null then
               L_SOURCE_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_source_organization_id);
	    End if;

            If p_note_id is null then
               P_NOTE:= 'ITEM                '||
                        'DESCRIPTION                                  '||
                        'QUANTITY      '||
                        'ORGANIZATION '||
                        fnd_global.newline||
                        x_item_number||'             '||
                        x_item_description||'                    '||
                        l_reservation_rec.quantity_needed||'           '||
                        L_SOURCE_ORGANIZATION_NAME;
            Else
               P_NOTE:= P_NOTE||
                        fnd_global.newline||
                        x_item_number||'             '||
                        x_item_description||'                    '||
                        l_reservation_rec.quantity_needed||'           '||
                        L_SOURCE_ORGANIZATION_NAME;
            End if;

        End if;
    END LOOP;

----- End Create Reservations for Defective Parts passed -----------


----- Start Create PO_REQUISITION for the Repair to Item -----------
--------------------------------------------
    /*Validate the Repair supplier*/
--------------------------------------------
    Begin
        Select VENDOR_NAME
          into l_VENDOR_NAME
          from po_vendors
         where vendor_id = P_repair_supplier_id
       --and nvl(start_date_active,sysdate) <= nvl(end_date_active,sysdate);
         and NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
         and NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE;
    Exception
        When No_Data_Found then
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_VALID_REPAIR_SUPPLIER');
           FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ID',to_char(P_repair_supplier_id), TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
    End;

---------------------------------------------------------------
/* Get Repair supplier Organization Id based on Vendor Id */
---------------------------------------------------------------
If P_repair_supplier_org_id is null then
    Begin
        Select organization_id
          into L_repair_supplier_org_id ----> P_repair_supplier_org_id
          from hr_organization_information
         where ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
           and ORG_INFORMATION3 = P_repair_supplier_id; ---> 1159 (Vendor Id parameter)
    Exception
        When No_Data_Found then
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIR_SUPPLIER_ORG');
           FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_NAME', l_VENDOR_NAME, TRUE);
                                  --(OR) No organization is linked with the repair supplier Id.
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
    End;
End if;

/*
	Begin
		SELECT LOCATION_ID
		INTO l_supplier_org_location_id
		FROM HR_ORGANIZATION_UNITS
		WHERE ORGANIZATION_ID = L_repair_supplier_org_id;
	Exception
		When no_data_found then
		l_supplier_org_location_id := Null;
	End;
*/

/*
-------------------------------------------------------
Get Vendor Id based on Repair supplier Organization Id
-------------------------------------------------------
    Begin
        select a.vendor_id
         from po_vendors a, hr_organization_information b
        where b.organization_id = 3201 --> P_repair_supplier_org_id (Repair supplier Org Id parameter)
          and a.vendor_id = b.ORG_INFORMATION3
          and b.ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
          and NVL(a.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
          and NVL(a.END_DATE_ACTIVE,SYSDATE) >= SYSDATE;
    Exception
        When no_data_found then
           FND_MESSAGE.SET_NAME ('CSP','CSP_MISSING_PARAMETERS');
           FND_MESSAGE.SET_TOKEN ('PARAMETER', 'Repair Supplier ID cannot be null', TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
    End;
*/

--------------------------------------------------
  /* VALIDATION for P_repair_program parameter */
--------------------------------------------------

    Begin
    	Select MEANING, LOOKUP_CODE
    	  into l_MEANING, l_LOOKUP_CODE
    	from mfg_lookups
    	Where LOOKUP_TYPE = 'INV_REPAIR_PROGRAMS' --'MRP_REPAIR_PROGRAM_DEFINITIONS'
    	  and ENABLED_FLAG = 'Y'
      	  and NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
      	  and NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
          and lookup_code = p_repair_program;
    Exception
        When no_data_found then
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_VALID_REPAIR_PROGRAM');
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
    End;

        select csp_repair_po_headers_s1.nextval
          into l_repair_po_header_id
          from dual;

/* In "CSP_PARTS_ORDER.PROCESS_PURCHASE_REQ" API inserting into
   "PO_REQUISITIONS_INTERFACE_ALL" table SOURCE_TYPE_CODE as "VENDOR".
   So this item must be Purchasing_enabled in both Repair supplier org and destination org. */

        L_REPAIR_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_repair_supplier_org_id);

        If L_REPAIR_ORGANIZATION_NAME is null then
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIR_SUPPLIER_ORG');
           FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_NAME', l_VENDOR_NAME, TRUE);
                                  --(OR) No organization is linked with the repair supplier Id.
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;

        Elsif L_REPAIR_ORGANIZATION_NAME is not null then
           CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
               (P_repair_supplier_org_id
               ,P_repair_to_item_id
               ,x_item_number
               ,x_item_description
               ,x_primary_uom_code
               ,x_return_status
               ,x_msg_data
               ,x_msg_count
               );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIRITEM_AT_REPAIRORG');
               FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG_NAME', L_REPAIR_ORGANIZATION_NAME,TRUE);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
           END IF;

    	Begin
    		SELECT LOCATION_ID
    		INTO l_supplier_org_location_id
    		FROM HR_ORGANIZATION_UNITS
    		WHERE ORGANIZATION_ID = nvl(P_repair_supplier_org_id,L_repair_supplier_org_id);
    	Exception
    		When no_data_found then
     	   --l_supplier_org_location_id := Null;
             FND_MESSAGE.SET_NAME ('CSP','CSP_NO_SHIPFROM_LOCATION_ID');
             FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG', L_REPAIR_ORGANIZATION_NAME, TRUE);
             FND_MSG_PUB.ADD;
             RAISE EXCP_USER_DEFINED;
        End;

        End if;

/* Find the Ship to Location for the Destination Warehouse and
   a customer must be associated with this location in Purchasing*/

        L_DEST_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_dest_organization_id);
        If L_DEST_ORGANIZATION_NAME is null then
           FND_MESSAGE.SET_NAME ('CSP','CSP_NO_VALID_DEST_ORG');
           FND_MESSAGE.SET_TOKEN ('DEST_ORG_ID', to_char(P_dest_organization_id), TRUE);
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        Elsif L_DEST_ORGANIZATION_NAME is not null then

           CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
               (P_dest_organization_id
               ,P_repair_to_item_id
               ,x_item_number
               ,x_item_description
               ,x_primary_uom_code
               ,x_return_status
               ,x_msg_data
               ,x_msg_count
               );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIRITEM_AT_DESTORG');
               FND_MESSAGE.SET_TOKEN ('DEST_ORG_NAME', L_DEST_ORGANIZATION_NAME,TRUE);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
           END IF;

            Begin
                SELECT LOCATION_ID
                INTO l_ship_to_location_id
                FROM HR_ORGANIZATION_UNITS
                WHERE ORGANIZATION_ID = P_dest_organization_id;
            Exception
                When no_data_found then
               --l_ship_to_location_id := Null;
                FND_MESSAGE.SET_NAME ('CSP','CSP_NO_SHIPTO_LOCATION_ID');
                FND_MESSAGE.SET_TOKEN ('DESTINATION_ORG', L_DEST_ORGANIZATION_NAME, TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
            End;
        End if;
-------- No shipping network between Org's with Default shipping method assigned ---------

        Begin
            SELECT SHIP_METHOD
              INTO l_shipping_method_code
              FROM MTL_INTERORG_SHIP_METHODS
             WHERE FROM_ORGANIZATION_ID = P_repair_supplier_org_id
               AND TO_ORGANIZATION_ID = P_dest_organization_id
               AND FROM_LOCATION_ID = l_supplier_org_location_id
               AND TO_LOCATION_ID = l_ship_to_location_id
               AND DEFAULT_FLAG = 1;
        Exception
            When no_data_found then
               L_REPAIR_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_repair_supplier_org_id);
               L_DEST_ORGANIZATION_NAME := GET_ORGANIZATION_NAME(P_dest_organization_id);
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFAULT_SHIPPING_METHOD');
               FND_MESSAGE.SET_TOKEN ('FROM_ORG', L_REPAIR_ORGANIZATION_NAME, TRUE);
               FND_MESSAGE.SET_TOKEN ('TO_ORG', L_DEST_ORGANIZATION_NAME, TRUE);
               FND_MSG_PUB.ADD;
               RAISE EXCP_USER_DEFINED;
        End;

        If nvl(P_quantity,0) <= 0 then
           FND_MESSAGE.SET_NAME ('CSP','CSP_INVALID_REPAIRPO_NEED_QTY');
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        End if;

        If trunc(nvl(P_need_by_date,sysdate)) < trunc(sysdate) then
           FND_MESSAGE.SET_NAME ('CSP','CSP_INVALID_REPAIRPO_NEED_DATE');
           FND_MSG_PUB.ADD;
           RAISE EXCP_USER_DEFINED;
        End if;

    l_header_rec.ship_to_location_id := l_ship_to_location_id;
    l_header_rec.need_by_date := P_need_by_date;
    l_header_rec.dest_organization_id := P_dest_organization_id;
    l_header_Rec.requirement_header_id := l_repair_po_header_id;
    l_header_rec.operation := csp_parts_order.G_OPR_CREATE; -- 'CREATE';

    l_line_rec.inventory_item_id := P_repair_to_item_id;
    l_line_rec.item_description  := X_ITEM_DESCRIPTION;
    l_line_rec.unit_of_measure   := X_PRIMARY_UOM_CODE;

    l_line_rec.shipping_method_code := l_shipping_method_code;
    l_line_rec.ordered_quantity := P_quantity;

    --l_line_rec.dest_subinventory := Null;

    /* This value is needed for Iternal requisition only */

    l_line_rec.source_organization_id := nvl(P_repair_supplier_org_id,L_repair_supplier_org_id);
  --l_line_rec.source_location_id := l_supplier_org_location_id;

    /*Add these parameters in the CSP_PARTS_REQUIREMENT.Header_Rec_Type and pass the repair_supplier_id to this parameter */

    l_header_rec.suggested_vendor_id := P_repair_supplier_id;
    l_header_rec.SUGGESTED_VENDOR_NAME := l_VENDOR_NAME;

    l_lines_tbl(1) := l_line_rec;

---------------------------------------------------------------------
/*
   Call to Create PO Requisition.
   This API Inserts record into PO_REQUISITIONS_INTERFACE_ALL table
*/
---------------------------------------------------------------------

/* REQUISITION_TYPE is passed as "PURCHASE" in the follwoing API.
   but this is not in valid values such as  BLANKET,PLANNED,SCHEDULED and STANDARD
*/

--dbms_output.put_line('First l_header_rec.requisition_header_id '||l_header_rec.requisition_header_id);

    l_header_rec.called_from := 'REPAIR_EXECUTION';
    l_header_rec.justification := l_LOOKUP_CODE ||' - '||l_MEANING;
    l_header_rec.note_to_buyer := l_LOOKUP_CODE ||' - '||l_MEANING;

/*
    select po_notes_s.nextval
      into p_note_id
      from dual;

    Insert into PO_NOTES
    (
    PO_NOTE_ID
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,CREATION_DATE
    ,CREATED_BY
    ,TITLE
    ,USAGE_ID
    ,NOTE_TYPE
    ,START_DATE_ACTIVE
    ,END_DATE_ACTIVE
    ,REQUEST_ID
    ,PROGRAM_APPLICATION_ID
    ,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,DOCUMENT_ID
    ,APP_SOURCE_VERSION
    ,NOTE
    )
    VALUES
    (
    p_note_id
    ,SYSDATE
    ,l_user_id
    ,l_login_id
    ,SYSDATE
    ,l_user_id
    ,'REPAIR AND RETURN: DEFECTIVE PARTS DETAILS'
    ,3 -- 'Note to Buyer'
    ,'S'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL --p_document_id
    ,'1.0'
    ,p_note
    );
*/
    fnd_documents_pkg.Insert_Row
                    (X_Rowid               => X_Rowid,
                     X_document_id         => X_document_id,
                     X_creation_date       => SYSDATE,
                     X_created_by          => l_user_id,
                     X_last_update_date    => SYSDATE,
                     X_last_updated_by     => l_user_id,
                     X_last_update_login   => l_login_id,
                     X_datatype_id         => 2,  -- Longtext
                     X_category_id         => 34, -- To Buyer
                     X_security_type       => 4,  -- None
                     X_security_id         => NULL,
                     X_publish_flag        => 'Y',
                     X_image_type          => NULL,
                     X_storage_type        => NULL, -- 1
                     X_usage_type          => 'O',  -- 'S'(Standard)
                     X_start_date_active   => SYSDATE,
                     X_end_date_active     => NULL,
                     X_request_id          => NULL,
                     X_program_application_id  => NULL,
                     X_program_id          => NULL,
                     X_program_update_date => NULL,
                     X_language            => USERENV('LANG'),
                     X_description         => 'Repair Purchase Order Defective Parts Details: '||L_REPAIR_PO_HEADER_ID,
                     X_file_name           => NULL,
                     X_media_id            => X_media_id,
                     X_Attribute_Category  => NULL,
                     X_Attribute1          => NULL,
                     X_Attribute2          => NULL,
                     X_Attribute3          => NULL,
                     X_Attribute4          => NULL,
                     X_Attribute5          => NULL,
                     X_Attribute6          => NULL,
                     X_Attribute7          => NULL,
                     X_Attribute8          => NULL,
                     X_Attribute9          => NULL,
                     X_Attribute10         => NULL,
                     X_Attribute11         => NULL,
                     X_Attribute12         => NULL,
                     X_Attribute13         => NULL,
                     X_Attribute14         => NULL,
                     X_Attribute15         => NULL,
 	               X_create_doc          => 'N');

            INSERT INTO	fnd_documents_long_text
            (MEDIA_ID, LONG_TEXT)
            VALUES(X_media_id, p_note);

    l_header_rec.NOTE1_ID := Null; --p_note_id;
    l_header_rec.NOTE1_TITLE := 'Repair Purchase Order Defective Parts Details: '||L_REPAIR_PO_HEADER_ID;

    CSP_PARTS_ORDER.process_purchase_req
    (P_API_VERSION     	=> 1.0
 	,P_INIT_MSG_LIST    => 'F'
	,P_COMMIT           => 'F'
 	,px_header_rec		=> l_header_rec
	,px_line_table		=> l_lines_tbl
	,x_return_status	=> l_return_status
	,x_msg_count		=> l_msg_count
   	,x_msg_data		    => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    End if;

/* Out values from the header record (l_header_rec) of PO Requisition Call */

    x_repair_po_header_id       := l_header_Rec.requirement_header_id;
    x_requisition_header_id     := l_header_rec.requisition_header_id;
    x_order_header_id           := l_header_rec.order_header_id;
    x_requisition_number        := l_header_rec.requisition_number;

--dbms_output.put_line('second l_header_rec.requisition_header_id '||l_header_rec.requisition_header_id);

/* Out values from the lines table (l_lines_tbl) of PO Requisition Call */

    -- This Loop may not be necessary because there is always a single requisition line
    FOR I IN 1..l_lines_tbl.COUNT
    LOOP
       l_line_rec := l_lines_tbl(I);
       --l_line_rec := l_lines_tbl(1);

       x_requisition_line_id            := l_line_rec.requisition_line_id;
       x_order_line_id                  := l_line_rec.order_line_id;
       x_line_num                       := l_line_rec.line_num;
       x_poreq_line_reservation_id      := l_line_rec.reservation_id;
       x_repair_po_line_id              := l_line_rec.requirement_line_id;

/* Insert into CSP_REPAIR_PO_HEADERS table the Requisition Header Id with the Item details */

        INSERT INTO CSP_REPAIR_PO_HEADERS
        (REPAIR_PO_HEADER_ID
        ,REQUISITION_HEADER_ID
        ,PURCHASE_ORDER_HEADER_ID
        ,INTERNAL_ORDER_HEADER_ID
        ,WIP_ID
        ,STATUS
        ,INVENTORY_ITEM_ID
        ,QUANTITY
        ,DEST_ORGANIZATION_ID
        ,NEED_BY_DATE
        ,REQUISITION_NUMBER
        ,REQUISITION_LINE_ID
        ,ORDER_LINE_ID
        ,LINE_NUM
        ,POREQ_LINE_RESERVATION_ID
        ,POREQ_LINE_ID
        ,ERROR_MESSAGE
        ,REPAIR_PROGRAM
        ,PO_NUMBER
        ,REPAIR_SUPPLIER_ID
        ,REPAIR_SUPPLIER_ORG_ID
        ,RECEIVED_QTY
        --,SCRAP_QTY
        --,ADJUSTED_QTY
        )
        VALUES
        (
	x_repair_po_header_id,
     	x_requisition_header_id , -- (+ 1 is stored in PO_REQUISITIONS_INTERFACE_ALL)
      NULL,
    	NULL,
    	NULL,
    	'1',
    	l_line_rec.inventory_item_id,
    	l_line_rec.ordered_quantity,
    	l_header_rec.dest_organization_id,
      l_header_rec.need_by_date,
      x_requisition_number,     	--( REQ_NUMBER_SEGMENT1 from PO_REQUISITIONS_INTERFACE_ALL)
      x_requisition_line_id,
      x_order_line_id,            ---- NULL
      x_line_num,                 ---- NULL
      x_poreq_line_reservation_id,---- NULL
      x_repair_po_line_id,        ---- NULL
      NULL,
      P_repair_program,
    	NULL,--PO_NUMBER
    	P_repair_supplier_id, --repair_supplier_id
    	P_repair_supplier_org_id, --Use "L_repair_supplier_org_id" if only P_repair_supplier_id is passed
    	NULL--received_qty
    --NULL,--scrap_qty
    --NULL--adjusted_qty
        );
    END LOOP;

    --COMMIT;

/* Insert into CSP_REPAIR_PO_LINES table all the reservation made for defective parts */

    FOR I IN 1..l_out_reservation_tbl.COUNT
    LOOP
        l_out_reservation_rec := l_out_reservation_tbl(I);

        select csp_repair_po_lines_s1.nextval
          into l_repair_po_line_id
          from dual;

        INSERT INTO CSP_REPAIR_PO_LINES
        (
        REPAIR_PO_LINE_ID
        ,REPAIR_PO_HEADER_ID
        ,DEFECTIVE_ORGANIZATION_ID
        ,INVENTORY_ITEM_ID
        ,QUANTITY
        ,RESERVATION_ID
        )
        VALUES
        (
        l_repair_po_line_id,
        x_repair_po_header_id,
        l_out_reservation_rec.organization_id,  ------- Defective Warehouse
        l_out_reservation_rec.item_id,          -------- Defective Item
        l_out_reservation_rec.quantity_needed,  -------- Defective Item Qty
        l_out_reservation_rec.reservation_id    -------- Reservation Id for the Defective Item
        --P_need_by_date                        -------- Same as the need by date of Repair to item
        );
    END LOOP;
    /*
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    */

    IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;


    EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
            Rollback to CREATE_REPAIR_PO_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get
            (p_count => x_msg_count
             ,p_data  => x_msg_data);
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
          Rollback to CREATE_REPAIR_PO_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              (p_count => x_msg_count
               ,p_data => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  FUNCTION GET_ORGANIZATION_NAME
          (P_dest_organization_id NUMBER
          ) return VARCHAR2 IS
    L_DEST_ORGANIZATION_NAME VARCHAR2(240);

    Cursor org_cur(P_dest_organization_id Number) is
    Select haou.name
      from hr_all_organization_units haou
     where haou.organization_id = p_dest_organization_id;
  BEGIN

    OPEN org_cur(P_dest_organization_id);
    LOOP
     FETCH org_cur INTO L_DEST_ORGANIZATION_NAME;
     EXIT WHEN org_cur%NOTFOUND;
    END LOOP;
    CLOSE org_cur;

    return L_DEST_ORGANIZATION_NAME;
  EXCEPTION
    WHEN OTHERS THEN
    L_DEST_ORGANIZATION_NAME := NULL;
    return L_DEST_ORGANIZATION_NAME;
  END;

  PROCEDURE GET_ITEM_DETAILS
           (P_organization_id       IN NUMBER
            ,P_inventory_item_id    IN NUMBER
            ,x_item_number          OUT NOCOPY VARCHAR2
            ,x_item_description     OUT NOCOPY VARCHAR2
            ,x_primary_uom_code     OUT NOCOPY VARCHAR2
            ,x_return_status        OUT NOCOPY VARCHAR2
            ,x_msg_data             OUT NOCOPY VARCHAR2
            ,x_msg_count            OUT NOCOPY NUMBER) IS

    Cursor item_cur (P_organization_id Number,P_inventory_item_id Number) is
    Select MSIK.concatenated_segments item_number,
           MSIK.description item_description,
           MSIK.primary_uom_code
      From mtl_system_items_kfv MSIK
     Where MSIK.organization_id = P_organization_id
       and MSIK.inventory_item_id = P_inventory_item_id
       and sysdate between nvl(MSIK.start_date_active,sysdate)
       and nvl(MSIK.end_date_active,sysdate);

    l_api_name VARCHAR2(60) := 'CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS';

  BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN item_cur(P_organization_id,P_inventory_item_id);
      LOOP
        FETCH item_cur INTO x_item_number,x_item_description,x_primary_uom_code;
        EXIT WHEN item_cur%NOTFOUND;
      END LOOP;
      CLOSE item_cur;

  EXCEPTION
      WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
             (p_count => x_msg_count
             ,p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END;


Procedure  CREATE_CSP_SNAP_LOG IS

	lv_dummy1            VARCHAR2(2000);
	lv_dummy2            VARCHAR2(2000);
	lv_inv_schema        VARCHAR2(32);
	lv_retval            BOOLEAN;
	v_applsys_schema     VARCHAR2(200);

	FUNCTION  GET_SCHEMA_NAME( p_apps_id IN  NUMBER)
	RETURN VARCHAR2 IS
	 lv_schema            VARCHAR2(30);
	 lv_prod_short_name   VARCHAR2(30);
	 lv_retval            boolean;
	 lv_dummy1            varchar2(32);
	 lv_dummy2            varchar2(32);
	  lv_is_new_ts_mode VARCHAR2(10);
	BEGIN

	   ad_tspace_util.is_new_ts_mode(lv_is_new_ts_mode);
	   IF(upper(lv_is_new_ts_mode) = 'N') THEN
        	SELECT  a.oracle_username
	        INTO  lv_schema
        	FROM  FND_ORACLE_USERID a,
              	FND_PRODUCT_INSTALLATIONS b
	         WHERE  a.oracle_id = b.oracle_id
        	 AND  b.application_id = p_apps_id;

	   ELSE
        	lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(p_apps_id);
	        lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);
	  END IF;

	 RETURN  lv_schema;

	EXCEPTION
	    WHEN OTHERS THEN
        	raise_application_error(-20001, 'Error getting the Schema : ' || sqlerrm);
	END GET_SCHEMA_NAME;

	PROCEDURE CREATE_SNAP_LOG( p_schema         in VARCHAR2,
                           p_table          in VARCHAR2,
                           p_applsys_schema IN VARCHAR2)
	IS
	   v_sql_stmt        VARCHAR2(6000);
	BEGIN

	v_sql_stmt:=
	' CREATE SNAPSHOT LOG ON '||p_schema ||'.'||p_table||'  WITH ROWID ' ;

	  ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => p_schema,
                 statement_type => AD_DDL.CREATE_TABLE,
                 statement => v_sql_stmt,
                 object_name => p_table);

	EXCEPTION
	     WHEN OTHERS THEN

	        IF SQLCODE IN (-12000) THEN
                            /*Snapshot Log already EXISTS*/
        	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Snapshot Log on  ' ||p_table||' already exists...');

        	ELSIF SQLCODE IN (-00942) THEN
                            /*Base Table does not exist*/
            	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Table '||p_table||' does not exist...');
	        ELSE
        	  FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
	         END IF;
	END CREATE_SNAP_LOG; --create_snap Log


  begin
    lv_retval := FND_INSTALLATION.GET_APP_INFO(
                    'FND', lv_dummy1,lv_dummy2, v_applsys_schema);
    lv_inv_schema := GET_SCHEMA_NAME(523);
    CREATE_SNAP_LOG (lv_inv_schema,'CSP_REPAIR_PO_HEADERS',v_applsys_schema);
  end CREATE_CSP_SNAP_LOG ;


Procedure create_csp_index (p_sql_stmt IN varchar2,p_object IN varchar2) is
lv_dummy1            VARCHAR2(2000);
lv_dummy2            VARCHAR2(2000);
lv_retval            BOOLEAN;
v_applsys_schema     VARCHAR2(200);
lv_prod_short_name   VARCHAR2(30);

begin
  lv_retval := FND_INSTALLATION.GET_APP_INFO(
                    'FND', lv_dummy1,lv_dummy2, v_applsys_schema);

       lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(523);
        ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                 application_short_name => lv_prod_short_name,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => p_sql_stmt,
                 object_name => p_object);


EXCEPTION
     WHEN OTHERS THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
	RAISE;
end  create_csp_index;




END CSP_REPAIR_PO_GRP;

/
