--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_REQUIREMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_REQUIREMENT" AS
/* $Header: cspvprqb.pls 120.4.12010000.44 2013/08/22 10:58:23 rrajain ship $ */

-- Purpose: Create/Update/Cancel Internal Parts Requirements for Spares
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- phegde      05/17/01 Created new package body

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csp_parts_requirement';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspvprqb.pls';

  G_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
  g_old_tsk_asgn_sts_id number;

  PROCEDURE Get_source_organization (
    P_Inventory_Item_Id          IN   NUMBER,
    P_Organization_Id            IN   NUMBER,
    P_Secondary_Inventory        IN   VARCHAR2,
    x_source_org_id              OUT NOCOPY  NUMBER,
	x_source_subinv              OUT NOCOPY VARCHAR2
    )
  IS

  Cursor c_Get_Source_Org(p_org_id Number) Is
  Select SOURCE_TYPE,
  	  SOURCE_ORGANIZATION_ID,
  	  SOURCE_SUBINVENTORY
  From   MTL_PARAMETERS
  Where  ORGANIZATION_ID   = p_org_id;

  Cursor c_Get_Source_Subinv(p_org_id Number,p_subinv Varchar2) Is
  Select SOURCE_TYPE,
  	  SOURCE_ORGANIZATION_ID,
  	  SOURCE_SUBINVENTORY
  From   MTL_SECONDARY_INVENTORIES
  Where  ORGANIZATION_ID   = p_org_id
  And    SECONDARY_INVENTORY_NAME = p_subinv;

  Cursor c_Get_Source_Item(p_inventory_item_id Number,p_org_id Number) Is
  Select SOURCE_TYPE,
  	  SOURCE_ORGANIZATION_ID,
  	  SOURCE_SUBINVENTORY
  From   MTL_SYSTEM_ITEMS
  Where  INVENTORY_ITEM_ID = p_inventory_item_id
  And    ORGANIZATION_ID   = p_org_id;

  Cursor c_Get_Source_Item_Subinv(p_inventory_item_id Number,p_org_id Number,p_subinventory Varchar2) Is

  Select SOURCE_TYPE,
  	  SOURCE_ORGANIZATION_ID,
  	  SOURCE_SUBINVENTORY
  From   MTL_ITEM_SUB_INVENTORIES
  Where  INVENTORY_ITEM_ID = p_inventory_item_id
  And    ORGANIZATION_ID   = p_org_id
  And    SECONDARY_INVENTORY = p_subinventory;

  l_return_status_full      VARCHAR2(1);
  l_Sqlcode				 NUMBER;
  l_Sqlerrm				 Varchar2(2000);
  l_api_name               CONSTANT VARCHAR2(30) := 'get_source_organization';

  l_source_org_rec         c_Get_Source_Org%ROWTYPE;

  l_Inventory_Item_Id 		Number := 0;
  l_Organization_Id   		Number := 0;
  l_Secondary_Inventory 	Varchar2(10);

  BEGIN
    --
    -- API body
    --
    l_Inventory_Item_Id 		:= P_Inventory_Item_Id;
    l_Organization_Id  		    := P_Organization_Id;
    l_Secondary_Inventory 	    := P_Secondary_Inventory;

	l_source_org_rec       := NULL;

    --- Check to see the source for Item And Subinventory
    If (l_Secondary_Inventory is NOT NULL AND l_Organization_id is NOT NULL) Then

	    Open c_Get_Source_Item_Subinv(p_Inventory_Item_Id ,l_Organization_Id,l_Secondary_Inventory);
		Fetch c_Get_Source_Item_Subinv  Into l_Source_Org_Rec;
        Close c_Get_Source_Item_Subinv;
     END If;

     -- If source organization is null, Check to see the source in Item definition

     If (l_source_org_rec.source_organization_id IS NULL)  Then
		Open c_Get_Source_Item(p_Inventory_Item_Id,l_Organization_Id);
		Fetch c_Get_Source_Item  Into l_Source_Org_Rec;
		Close c_Get_Source_Item;
     END If;

     --- IF source_organiZation_id is still null, Check to see the source in Subinventory definition

	 IF (l_source_org_Rec.source_organization_id IS NULL and l_secondary_inventory IS NOT NULL) THEN

	     Open c_Get_Source_Subinv(l_Organization_Id,l_Secondary_Inventory);
		 Fetch c_Get_Source_Subinv  Into l_Source_Org_Rec;
         Close c_Get_Source_Subinv;
     END If;

     --- Check to see the source in Organization definition
     if (l_Source_org_Rec.source_organization_id IS NULL and l_organization_id IS NOT NULL) THEN

       Open c_Get_Source_Org(l_Organization_Id);
	   Fetch c_Get_Source_Org  INTO l_Source_Org_Rec;
	   Close c_Get_Source_Org;
     End If;

     -- Assign output variables
     x_source_org_id := l_source_org_Rec.source_organization_id;
	 x_source_subinv := l_source_org_rec.source_subinventory;

	 --
     -- End of API body
     --

  EXCEPTION
          WHEN OTHERS THEN
		    l_sqlcode := SQLCODE;
		    l_sqlerrm := SQLERRM;
            l_source_org_rec.source_organization_id := FND_API.G_MISS_NUM;

  End Get_source_organization;


  PROCEDURE process_requirement
     (    p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,p_create_order_flag       IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
      ) IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'process_requirement';
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_msg_dummy		   VARCHAR2(2000);
  l_order_msg		   VARCHAR2(8000);
  l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;
  EXCP_USER_DEFINED        EXCEPTION;
  l_check_existence        NUMBER;
  l_window                 BOOLEAN;

  l_requirement_header_id  NUMBER ;
  l_requirement_line_id    NUMBER;
  l_parts_defined          VARCHAR2(30);

  l_header_rec             Header_Rec_Type;
  l_line_rec               Line_rec_type;
  l_line_tbl               Line_Tbl_type;

  l_rqmt_header_Rec        csp_requirement_headers_pvt.requirement_header_rec_type;

  l_rqmt_line_Rec          csp_requirement_lines_pvt.requirement_line_rec_type;
  l_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;
  x_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;
  l_req_line_details_tbl   csp_parts_requirement.Line_detail_Tbl_Type;
  j                        NUMBER;

  --Record types and tbl types for finding availability of parts
  l_parts_list_rec	       csp_sch_int_pvt.csp_parts_rec_type;
  l_parts_list_tbl	       csp_sch_int_pvt.csp_parts_tbl_typ1;
  l_avail_list_tbl         csp_sch_int_pvt.available_parts_tbl_typ1;
  l_resource_rec	       csp_sch_int_pvt.csp_sch_resources_rec_typ;
  l_req_line_Dtl_id NUMBER;
  l_timezone_id     NUMBER;

  CURSOR rs_loc_cur(p_resource_type VARCHAR2, p_resource_id NUMBER) IS
  SELECT pla.location_id inv_loc_id,
         hzl.time_zone
  from csp_rs_cust_relations rcr,
       hz_cust_acct_sites cas,
       hz_cust_site_uses csu,
       po_location_associations pla,
       hz_party_sites ps,
       hz_locations hzl
  where rcr.customer_id = cas.cust_account_id
  and cas.cust_acct_site_id = csu.cust_acct_site_id (+)
  and csu.site_use_code = 'SHIP_TO'
  and csu.site_use_id = pla.site_use_id
  and cas.party_site_id = ps.party_site_id
  and ps.location_id = hzl.location_id
  and csu.primary_flag = 'Y'
  and rcr.resource_type = p_resource_type
  and rcr.resource_id = p_resource_id;

  CURSOR task_asgnmt_loc_cur(p_task_Assignment_id NUMBER) IS
  SELECT pla.location_id inv_loc_id,
         hzl.time_zone timezone_id
  from csp_rs_cust_relations rcr,
       hz_cust_acct_sites cas,
       hz_cust_site_uses csu,
       po_location_associations pla,
       hz_party_sites ps,
       hz_locations hzl,
       jtf_task_assignments jta
  where rcr.customer_id = cas.cust_account_id
  and cas.cust_acct_site_id = csu.cust_acct_site_id (+)
  and csu.site_use_code = 'SHIP_TO'
  and csu.site_use_id = pla.site_use_id
  and cas.party_site_id = ps.party_site_id
  and ps.location_id = hzl.location_id
  and csu.primary_flag = 'Y'
  and rcr.resource_type = jta.resource_type_code
  and rcr.resource_id = jta.resource_id
  and jta.task_assignment_id = p_task_assignment_id;

  BEGIN
    SAVEPOINT Process_Requirement_PUB;

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

    l_header_Rec := px_header_rec;
    l_line_tbl := px_line_table;

    -- user and login information
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    -- call availability API to get source organization
    l_resource_rec.resource_type := l_header_Rec.resource_type;
    l_resource_Rec.resource_id := l_header_Rec.resource_id;

    FOR I IN 1..l_line_tbl.COUNT LOOP
        IF l_line_tbl(I).source_organization_id IS   NULL THEN
            l_parts_list_rec.item_id := l_line_tbl(I).inventory_item_id;
            l_parts_list_rec.revision := l_line_Tbl(I).revision;
            l_parts_list_rec.item_uom := l_line_tbl(I).unit_of_measure;
            l_parts_list_rec.quantity := l_line_tbl(I).ordered_quantity;
            l_parts_list_rec.ship_set_name := l_line_tbl(I).ship_complete;
            l_parts_list_rec.line_id := l_line_tbl(I).line_num;
            l_parts_list_tbl(i) := l_parts_list_rec;
        END IF;
    END LOOP;
    IF l_parts_list_tbl.count > 0  THEN

    	IF sysdate < l_header_rec.need_by_date THEN
    -- call csp_sch_int_pvt.check_parts_availability()
        	csp_sch_int_pvt.check_parts_availability(
		    p_resource 		    => l_resource_rec,
		    p_organization_id 	=> l_header_rec.dest_organization_id,
            	    p_subinv_code       => null,
		    p_need_by_date 		=> l_header_rec.need_by_date,
		    p_parts_list 		=> l_parts_list_tbl,
		    p_timezone_id		=> null,
		    x_availability 		=> l_avail_list_tbl,
		    x_return_status 	=> l_return_status,
		    x_msg_data		    => l_msg_data,
		    x_msg_count		    => l_msg_count,
           	    p_called_from       => 'MOBILE'
            	   );
    	ELSE
          FND_MESSAGE.Set_Name('CSP', 'CSP_NEED_PASSED');
          l_order_msg := FND_MESSAGE.GET;
        END IF;
    END IF;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      null; --RAISE FND_API.G_EXC_ERROR;
    END IF;
    if l_msg_count > 0 THEN
     for j in 1..fnd_msg_pub.count_msg loop
          fnd_msg_pub.get(
          	j,
          	FND_API.G_FALSE,
          	l_msg_data,
          	l_msg_dummy);
          l_order_msg := l_order_msg || l_msg_data;
     end loop;
    END IF;
    J := 1;
    IF (l_Avail_list_tbl.COUNT > 0) THEN
      FOR I IN 1..l_line_tbl.COUNT LOOP
        IF (l_avail_list_tbl(J).item_id = l_line_tbl(I).inventory_item_id) THEN
          IF (l_line_tbl(I).source_organization_id IS NULL) THEN
            l_line_tbl(I).source_organization_id := l_avail_list_tbl(J).source_org_id;
            l_line_tbl(I).shipping_method_code := l_avail_list_tbl(J).shipping_methode;
            l_line_Tbl(I).order_by_date := l_Avail_list_tbl(J).order_by_date;
          END IF;
          J := J+1;
        END IF;
      END LOOP;
    END IF;

    -- check to see if any of the lines have null source org and if yes, get source organization defined
    -- for replenishment at item/subinventory/organization level
	-- not required since this will be part of the check_availability call
	/*
    FOR I IN 1..l_line_tbl.COUNT LOOP
      IF (l_line_Tbl(I).source_organization_id IS NULL) THEN
        Get_source_organization(P_Inventory_Item_Id => l_line_Tbl(I).inventory_item_id,
                                P_Organization_Id   => l_header_Rec.dest_organization_id,
                                P_Secondary_Inventory => l_header_rec.dest_subinventory,
                                x_source_org_id     => l_line_Tbl(I).source_organization_id);
        IF ((l_line_Tbl(I).source_organization_id IS NULL) OR
            (l_line_Tbl(I).source_organization_id = FND_API.G_MISS_NUM)) THEN
          -- no source organization defined, create requirement with error status
          l_rqmt_header_rec.open_requirement := 'E';
        END IF;
      END If;
    END LOOP;
	*/

    -- find default ship to of resource if ship_to_location_id is null
    IF (l_header_Rec.ship_to_location_id IS NULL) THEN
      -- check if task_assignment_id is passed
      IF ((l_header_Rec.task_assignment_id IS NOT NULL) AND
          (l_header_Rec.resource_type IS NULL OR l_header_rec.resource_id IS NULL)) THEN
        -- get resource and default addr of resource based on task assignment
        OPEN task_asgnmt_loc_cur(l_header_rec.task_assignment_id);
        FETCH task_asgnmt_loc_cur INTO l_header_rec.ship_to_location_id, l_timezone_id;
        CLOSE task_asgnmt_loc_cur;
      ELSIF (l_header_Rec.resource_type IS NOT NULL AND l_header_rec.resource_id IS NOT NULL) THEN
        -- get default ship-to location of resource
        OPEN rs_loc_cur(l_header_rec.resource_type, l_header_Rec.resource_id);
        FETCH rs_loc_cur into l_header_Rec.ship_to_location_id, l_timezone_id;
        CLOSE rs_loc_cur;
      ELSE
        -- raise error, either ship to location or resource must be specified
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
        FND_MESSAGE.SET_TOKEN ('PARAMETER', 'resource or task assignment or ship to location', FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      END If;
    ELSE
      BEGIN
        SELECT hzl.time_zone time_zone_id
        INTO l_timezone_id
        from hz_cust_acct_sites cas,
             hz_cust_site_uses csu,
             po_location_associations pla,
             hz_party_sites ps,
             hz_locations hzl
        where cas.cust_acct_site_id = csu.cust_acct_site_id (+)
        and csu.site_use_code = 'SHIP_TO'
        and csu.site_use_id = pla.site_use_id
        and pla.location_id = l_header_rec.ship_to_location_id
        and cas.party_site_id = ps.party_site_id
        and ps.location_id = hzl.location_id;
      EXCEPTION
        when no_data_found then
          null;
        when others then
          null;
      END;
    END IF;

    IF (p_create_order_flag = 'Y' AND l_rqmt_header_Rec.open_requirement <> 'E') THEN

      -- call csp_process_order API
      csp_parts_order.process_order(
          p_api_version             => l_api_version_number
         ,p_Init_Msg_List           => p_init_msg_list
         ,p_commit                  => FND_API.G_false
         ,px_header_rec             => l_header_rec
         ,px_line_table             => l_line_tbl
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data
        );

      -- set parts_defined to 'Y' if order has been created for this requirement
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        l_parts_defined := 'Y';
        l_rqmt_header_rec.open_requirement := 'Y';
        px_header_rec.order_header_id := l_header_Rec.order_header_id;
        l_order_msg := null;
      ELSE
        l_rqmt_header_rec.open_requirement := 'E';
        for j in 1..fnd_msg_pub.count_msg loop
          fnd_msg_pub.get(
          	j,
          	FND_API.G_FALSE,
          	l_msg_data,
          	l_msg_dummy);
          l_order_msg := l_order_msg || l_msg_data;
        end loop;
      END IF;
    END IF;

    -- SETTING UP THE PARTS REQUIREMENT HEADER RECORD
    IF (l_header_rec.operation = G_OPR_CREATE) THEN
      l_rqmt_header_Rec.created_by                 := nvl(l_user_id, -1);
      l_rqmt_header_Rec.creation_date              := l_today;
    ELSIF (l_header_rec.operation IN (G_OPR_UPDATE, G_OPR_DELETE)) THEN
      IF nvl(l_header_rec.requirement_header_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
        FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_header_rec.requirement_header_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
      ELSE
        BEGIN
          select requirement_header_id
          into l_check_existence
          from csp_requirement_headers
          where requirement_header_id = l_header_rec.requirement_header_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_HEADER');
            fnd_message.set_token('HEADER_ID', to_char(l_header_rec.requirement_header_id), FALSE);

            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
          WHEN OTHERS THEN
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
            fnd_message.set_token('ERR_FIELD', 'l_header_rec.requirement_header_id', FALSE);
            fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
            fnd_message.set_token('TABLE', 'CSP_REQUIREMENT_HEADERS', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;
      END IF;
    END IF;

    l_rqmt_header_Rec.requirement_header_id      := nvl(l_header_rec.requirement_header_id, FND_API.G_MISS_NUM); --l_requirement_header_id;
    l_rqmt_header_Rec.last_updated_by            := nvl(l_user_id, -1);
    l_rqmt_header_Rec.last_update_date           := l_today;
    l_rqmt_header_Rec.last_update_login          := nvl(l_login_id, -1);
    l_rqmt_header_Rec.ship_to_location_id        := nvl(l_header_rec.ship_to_location_id, FND_API.G_MISS_NUM);
    l_rqmt_header_Rec.timezone_id                := nvl(l_timezone_id, FND_API.G_MISS_NUM);
    l_rqmt_header_Rec.address_type               := l_header_rec.address_type;-- csp_parts_Requirement.G_ADDR_RESOURCE;
    l_rqmt_header_Rec.task_id                    := nvl(l_header_rec.task_id, FND_API.G_MISS_NUM);
    l_rqmt_header_Rec.task_assignment_id         := nvl(l_header_rec.task_assignment_id, FND_API.G_MISS_NUM);
    l_rqmt_header_Rec.shipping_method_code       := nvl(l_header_rec.shipping_method_code, FND_API.G_MISS_CHAR);
    l_rqmt_header_Rec.need_by_date               := nvl(l_header_rec.need_by_date, FND_API.G_MISS_DATE);
    l_rqmt_header_Rec.destination_organization_id := nvl(l_header_rec.dest_organization_id, FND_API.G_MISS_NUM);
    l_rqmt_header_Rec.destination_subinventory   := nvl(l_header_rec.dest_subinventory, FND_API.G_MISS_CHAR);
    l_rqmt_header_Rec.parts_defined              := nvl(l_parts_defined, FND_API.G_MISS_CHAR);
    -- l_rqmt_header_Rec.open_requirement           := 'Y';
    l_rqmt_header_rec.order_type_id              := nvl(l_header_rec.order_type_id, FND_API.G_MISS_NUM);
    l_rqmt_header_rec.attribute_Category         := nvl(l_header_rec.attribute_category, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute1                 := nvl(l_header_rec.attribute1, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute2                 := nvl(l_header_rec.attribute2, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute3                 := nvl(l_header_rec.attribute3, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute4                 := nvl(l_header_rec.attribute4, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute5                 := nvl(l_header_rec.attribute5, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute6                 := nvl(l_header_rec.attribute6, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute7                 := nvl(l_header_rec.attribute7, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute8                 := nvl(l_header_rec.attribute8, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute9                 := nvl(l_header_rec.attribute9, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute10                := nvl(l_header_rec.attribute10, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute11                := nvl(l_header_rec.attribute11, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute12                := nvl(l_header_rec.attribute12, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute13                := nvl(l_header_rec.attribute13, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute14                := nvl(l_header_rec.attribute14, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.attribute15                := nvl(l_header_rec.attribute15, FND_API.G_MISS_CHAR);
    l_rqmt_header_rec.ship_to_contact_id         := nvl(l_header_rec.ship_to_contact_id, FND_API.G_MISS_NUM);

	if (l_header_Rec.task_assignment_id IS NULL)
		and (l_header_Rec.resource_id is null
			or l_header_rec.resource_type is null) then
				FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
				FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_header_Rec.resource_id', FALSE);
				FND_MSG_PUB.ADD;
				RAISE EXCP_USER_DEFINED;
	end if;

    --IF (l_header_Rec.task_assignment_id IS NULL) THEN
      l_Rqmt_header_rec.resource_type    := l_header_rec.resource_type;
      l_Rqmt_header_rec.resource_id      := l_header_Rec.resource_id;
    --END IF;

    -- SETTING UP THE PARTS REQUIREMENT LINE RECORD
    FOR I IN 1..l_line_tbl.COUNT LOOP
      l_line_rec := l_line_tbl(I);

      IF (l_header_rec.operation = G_OPR_CREATE) THEN
        l_rqmt_line_Rec.created_by             := nvl(l_user_id, -1);
        l_rqmt_line_Rec.creation_date          := l_today;
      ELSIF (l_header_rec.operation IN (G_OPR_UPDATE, G_OPR_DELETE)) THEN
        IF nvl(l_line_rec.requirement_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

          FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_line_rec.requirement_line_id', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
          BEGIN
            select requirement_line_id
            into l_check_existence
            from csp_requirement_lines
            where requirement_line_id = l_line_rec.requirement_line_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_LINE');
              fnd_message.set_token ('LINE_ID', to_char(l_line_rec.requirement_line_id), FALSE);

              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
            WHEN OTHERS THEN
              fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
              fnd_message.set_token('ERR_FIELD', 'l_line_rec.requirement_line_id', FALSE);
              fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
              fnd_message.set_token('TABLE', 'CSP_REQUIREMENT_LINES', FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
          END;
        END IF;
      END IF;

      l_rqmt_line_Rec.requirement_line_id := l_line_rec.requirement_line_id;
      l_rqmt_line_rec.last_updated_by := nvl(l_user_id, 1);
      l_rqmt_line_rec.last_update_date := l_today;
      l_rqmt_line_rec.last_update_login := nvl(l_login_id, -1);
      --l_rqmt_line_rec.requirement_header_id := nvl(l_header_rec.requirement_header_id, FND_API.G_MISS_NUM);

      l_rqmt_line_rec.inventory_item_id := l_line_rec.inventory_item_id;
      l_rqmt_line_rec.uom_code := l_line_rec.unit_of_measure;
      l_rqmt_line_rec.required_quantity := l_line_rec.quantity;
      l_rqmt_line_rec.ship_complete_flag := l_line_rec.ship_complete;
      l_rqmt_line_rec.likelihood := l_line_rec.likelihood;
      l_rqmt_line_rec.revision := l_line_rec.revision;
      /*l_rqmt_line_rec.source_organization_id := l_line_rec.source_organization_id;

      l_rqmt_line_rec.source_subinventory := l_line_rec.source_subinventory;
      l_rqmt_line_rec.ordered_quantity := l_line_Rec.ordered_quantity;

      l_rqmt_line_rec.reservation_id := l_line_rec.reservation_id;
      l_rqmt_line_rec.order_by_date := l_line_rec.order_by_date;*/

      l_rqmt_line_rec.attribute_Category         := nvl(l_line_rec.attribute_category, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute1                 := nvl(l_line_rec.attribute1, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute2                 := nvl(l_line_rec.attribute2, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute3                 := nvl(l_line_rec.attribute3, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute4                 := nvl(l_line_rec.attribute4, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute5                 := nvl(l_line_rec.attribute5, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute6                 := nvl(l_line_rec.attribute6, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute7                 := nvl(l_line_rec.attribute7, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute8                 := nvl(l_line_rec.attribute8, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute9                 := nvl(l_line_rec.attribute9, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute10                := nvl(l_line_rec.attribute10, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute11                := nvl(l_line_rec.attribute11, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute12                := nvl(l_line_rec.attribute12, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute13                := nvl(l_line_rec.attribute13, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute14                := nvl(l_line_rec.attribute14, FND_API.G_MISS_CHAR);
      l_rqmt_line_rec.attribute15                := nvl(l_line_rec.attribute15, FND_API.G_MISS_CHAR);

      l_rqmt_line_rec.order_line_id := l_line_Rec.order_line_id;
      px_line_table(I).order_line_id := l_line_Rec.order_line_id;
      l_rqmt_line_Tbl(I) := l_rqmt_line_rec;

    END LOOP;

    IF ( l_header_rec.operation = 'CREATE') THEN

      -- check to see if requirements exist for a given task
      IF (l_header_rec.task_id IS NOT NULL AND
          l_header_rec.requirement_header_id IS NULL) THEN
        BEGIN
          SELECT requirement_header_id
          INTO l_requirement_header_id
          FROM csp_requirement_headers
          WHERE task_id = l_header_rec.task_id;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- call private api for inserting into csp_Requirement_headers
           CSP_REQUIREMENT_HEADERS_PVT.Create_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_REQUIREMENT_HEADER_ID      => l_requirement_header_id,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
            );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSE
                IF l_order_msg IS NOT null THEN
                    FND_MESSAGE.Set_Name('CSP', 'CSP_REQ_CREATED');
                    FND_MESSAGE.Set_Token('REQ_NUMBER',to_char(l_requirement_header_id));
                    x_msg_data := FND_MESSAGE.GET;
                END IF;
            END IF;
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF (l_header_rec.requirement_header_id IS NOT NULL) THEN
        BEGIN
          SELECT requirement_header_id
          INTO l_requirement_header_id
          FROM csp_requirement_headers
          WHERE requirement_header_id = l_header_rec.requirement_header_id;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- call private api for inserting into csp_Requirement_headers
           CSP_REQUIREMENT_HEADERS_PVT.Create_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_REQUIREMENT_HEADER_ID      => l_requirement_header_id,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            IF l_order_msg IS NOT null THEN
                FND_MESSAGE.Set_Name('CSP', 'CSP_REQ_CREATED');
                FND_MESSAGE.Set_Token('REQ_NUMBER',to_char(l_requirement_header_id));
                x_msg_data := FND_MESSAGE.GET;
            END IF;
          END IF;
        END;
      ELSE
        -- call private api for inserting into csp_Requirement_headers
        CSP_REQUIREMENT_HEADERS_PVT.Create_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_REQUIREMENT_HEADER_ID      => l_requirement_header_id,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF l_order_msg IS NOT null THEN
                FND_MESSAGE.Set_Name('CSP', 'CSP_REQ_CREATED');
                FND_MESSAGE.Set_Token('REQ_NUMBER',to_char(l_requirement_header_id));
                x_msg_data := FND_MESSAGE.GET;
            END IF;
        END IF;
      END IF;

      -- Update return header rec with requirement_header_id
      px_header_rec.requirement_header_id := l_requirement_header_id;

      -- Fill the requirement_header_id in the line record
      FOR I in 1..l_rqmt_line_Tbl.COUNT LOOP
        l_rqmt_line_Tbl(I).requirement_header_id := l_requirement_header_id;
      END LOOP;
        x_rqmt_line_tbl := l_rqmt_line_tbl;
      -- call private api for inserting into csp_requirement_lines
        CSP_Requirement_Lines_PVT.Create_requirement_lines(
                P_Api_Version_Number         => l_api_version_number,
                P_Init_Msg_List              => p_Init_Msg_List,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_Requirement_Line_Tbl       => l_rqmt_line_tbl,
                x_Requirement_Line_tbl       => x_rqmt_line_tbl,
                X_Return_Status              => l_return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF x_msg_data IS null  and l_order_msg is not null THEN
                FND_MESSAGE.Set_Name('CSP', 'CSP_REQ_UPDATED');
                FND_MESSAGE.Set_Token('REQ_NUMBER',to_char(l_requirement_header_id));
                x_msg_data := FND_MESSAGE.GET;
            END IF;
        END IF;
        FOR I IN 1..x_rqmt_line_tbl.count LOOP
          IF x_rqmt_line_tbl(I).order_line_id IS NOT NULL THEN
            SELECT csp_req_line_Details_s1.nextval
            INTO l_req_line_Dtl_id
            FROM dual;

          csp_req_line_Details_pkg.Insert_Row(
                px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                p_REQUIREMENT_LINE_ID   =>  x_rqmt_line_tbl(I).requirement_line_id,
                p_CREATED_BY            =>  nvl(l_user_id, 1),
                p_CREATION_DATE         =>  sysdate,
                p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                p_LAST_UPDATE_DATE      =>  sysdate,
                p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                p_SOURCE_TYPE           => 'IO',
                p_SOURCE_ID             => x_rqmt_line_tbl(I).order_line_id);
          END IF;
        END LOOP;

    ELSIF (l_header_rec.operation = 'UPDATE') THEN
      -- call private api for updating requirement headers
      CSP_REQUIREMENT_HEADERS_PVT.Update_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- call private api for updating requirement lines
      --FOR I in 1..l_rqmt_line_tbl.COUNT LOOP
        CSP_Requirement_Lines_PVT.Update_requirement_lines(
                P_Api_Version_Number         => l_api_version_number,
                P_Init_Msg_List              => p_Init_Msg_List,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_Requirement_Line_Tbl       => l_rqmt_line_tbl,
                X_Return_Status              => l_return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      --END LOOP;
        If p_commit = FND_API.G_TRUE then
            commit work;
        end if;
    END IF;
    	IF x_msg_data is not null or l_order_msg is not null THEN
    		x_msg_data := x_msg_data || '  ' || l_order_msg;
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
      Rollback to process_requirement_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

  END;



  PROCEDURE csptrreq_fm_order(
         p_api_version             IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'csptrreq_fm_order';
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;
  EXCP_USER_DEFINED        EXCEPTION;
  l_check_existence        NUMBER;

  l_requirement_header_id  NUMBER ;
  l_requirement_line_id    NUMBER;

  l_header_rec             Header_Rec_Type;
  l_line_rec               Line_rec_type;
  l_line_tbl               Line_Tbl_type;
  l_old_line_tbl           Line_Tbl_type;
  l_po_line_tbl            Line_Tbl_type;
  l_po_line_Rec            Line_Rec_Type;

  J                        NUMBER;
  K                        NUMBER;
  l_qty_to_reserve         NUMBER := 0;
  l_resource_att           NUMBER := 0;
  l_resource_onhand        NUMBER := 0;
  l_resource_org_id        NUMBER;
  l_resource_subinv        VARCHAR2(30);
  l_reservation_rec        CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
  l_local_reservation_id   NUMBER;

  l_rqmt_line_Rec          csp_requirement_lines_pvt.requirement_line_rec_type;
  l_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;

  CURSOR rs_info_cur(p_rqmt_header_id NUMBER) IS
  SELECT cla.organization_id,
         cla.subinventory_code
  FROM   csp_requirement_headers crh,
         jtf_task_assignments jta,
         csp_INV_LOC_ASSIGNMENTS cla
  WHERE  cla.default_code = 'IN'
  AND    cla.resource_type = decode(crh.task_assignment_id,null,crh.resource_type,jta.resource_type_code)
  AND    cla.resource_id = decode(crh.task_assignment_id,null,crh.resource_id,jta.resource_id)
  and    jta.task_assignment_id(+) = crh.task_assignment_id
  AND    crh.requirement_header_id = p_rqmt_header_id;

 BEGIN

    SAVEPOINT csptrreq_fm_order_PUB;

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

    l_header_Rec := px_header_rec;
    l_old_line_tbl := px_line_table;

    -- user and login information
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    -- create reservations and create line table which qualify for creating order

    OPEN rs_info_cur(l_header_rec.requirement_header_id);
    FETCH rs_info_cur INTO l_resource_org_id, l_resource_subinv;
    CLOSE rs_info_cur;

    J := 1;
    K := 1;
    FOR I IN 1..l_old_line_Tbl.COUNT LOOP
      l_line_rec := l_old_line_Tbl(I);

      l_qty_to_Reserve := l_line_Rec.quantity - l_line_rec.ordered_quantity;

      IF (l_resource_org_id IS NOT NULL AND l_resource_subinv IS NOT NULL) THEN
        csp_sch_int_pvt.check_local_inventory(p_org_id            => l_resource_org_id,
                                              p_subinv_code       => l_resource_subinv,
                                              p_item_id           => l_line_rec.inventory_item_id,
                                              p_revision          => l_line_Rec.revision,
                                              x_att               => l_resource_att,
                                              x_onhand            => l_resource_onhand,
                                              x_return_status     => l_return_status,
                                              x_msg_count         => l_msg_count,
                                              x_msg_Data          => l_msg_data
                                             );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END If;
      END IF;

      IF (l_qty_to_Reserve < l_resource_att and l_qty_to_reserve > 0)  THEN
        -- create reservations on qty_to_Reserve in engineers subinv
        l_reservation_rec.need_by_date := sysdate; --l_header_rec.need_by_date;
        l_reservation_rec.organization_id := l_resource_org_id;
        l_reservation_rec.item_id := l_line_Rec.inventory_item_id;
        l_Reservation_rec.revision := l_line_rec.revision;
        l_reservation_rec.item_uom_code := l_line_rec.unit_of_measure;
        l_reservation_rec.quantity_needed := l_qty_to_reserve;
        l_reservation_rec.sub_inventory_code := l_resource_subinv;

        l_local_reservation_id := csp_sch_int_pvt.create_reservation(
                                                p_reservation_parts => l_reservation_rec,
                                                x_return_status     => l_return_status,
                                                --x_msg_count         => l_msg_Count,
                                                x_msg_data          => l_msg_data

                                                );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END If;

        update csp_Requirement_lines
        set local_Reservation_id = l_local_Reservation_id
        where requirement_line_id = l_line_Rec.requirement_line_id;

      END IF;

      IF (l_line_rec.sourced_from = 'INVENTORY' AND (l_line_rec.ordered_quantity > 0)) THEN
        l_line_tbl(J) := l_line_rec;
        J := J + 1;
      ELSIF (l_line_rec.sourced_from = 'VENDOR' AND (l_line_rec.ordered_quantity > 0)) THEN
        l_po_line_tbl(K) := l_line_Rec;
        K := K+1;
      END IF;

    END LOOP;

    -- call csp_process_order API only if atleast one line qualifies for order to be created

    IF (l_line_tbl.count > 0) THEN
        csp_parts_order.process_order(
              p_api_version             => l_api_version_number
             ,p_Init_Msg_List           => p_init_msg_list
             ,p_commit                  => p_commit
             ,px_header_rec             => l_header_rec
             ,px_line_table             => l_line_tbl
             ,x_return_status           => l_return_status
             ,x_msg_count               => l_msg_count
             ,x_msg_data                => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- update csp_requirement_line table with order information
            FOR I IN 1..l_line_tbl.COUNT LOOP
              l_line_rec := l_line_tbl(I);

              IF nvl(l_line_rec.requirement_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_line_rec.requirement_line_id', FALSE);

                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
              ELSE
                BEGIN
                  select requirement_line_id
                  into l_check_existence
                  from csp_requirement_lines
                  where requirement_line_id = l_line_rec.requirement_line_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_LINE');
                    fnd_message.set_token ('LINE_ID', to_char(l_line_rec.requirement_line_id), FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'l_line_rec.requirement_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_REQUIREMENT_LINES', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                END;
            END IF;

            l_rqmt_line_Rec.requirement_line_id := l_line_rec.requirement_line_id;
            l_rqmt_line_rec.last_updated_by := nvl(l_user_id, 1);
            l_rqmt_line_rec.last_update_date := l_today;
            l_rqmt_line_rec.last_update_login := nvl(l_login_id, -1);
            l_rqmt_line_rec.ordered_quantity := l_line_Rec.ordered_quantity;
            l_rqmt_line_rec.order_line_id := l_line_Rec.order_line_id;
            l_rqmt_line_rec.sourced_from  := 'INVENTORY';
            --l_rqmt_line_rec.reservation_id := l_line_rec.reservation_id;
            --l_rqmt_line_rec.order_by_date := l_line_rec.order_by_date;

            l_rqmt_line_Tbl(I) := l_rqmt_line_rec;

          END LOOP;
        END IF;
    END IF;

    -- create purchase requisitions if po_line_tbl has atleast one record
    IF (l_po_line_tbl.count > 0) THEN
        csp_parts_order.process_purchase_req(
             p_api_version      => l_api_version_number
            ,p_init_msg_list    => p_init_msg_list
            ,p_commit           => p_commit
            ,px_header_rec      => l_header_Rec
            ,px_line_Table      => l_po_line_tbl
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- now update csp_requirement_line table with purchase req information
            J := l_line_tbl.count + 1;
            FOR I IN 1..l_po_line_tbl.COUNT LOOP
              l_line_rec := l_po_line_tbl(I);

              IF nvl(l_line_rec.requirement_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                FND_MESSAGE.SET_TOKEN ('PARAMETER', 'l_line_rec.requirement_line_id', FALSE);

                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
              ELSE
                BEGIN
                  select requirement_line_id
                  into l_check_existence
                  from csp_requirement_lines
                  where requirement_line_id = l_line_rec.requirement_line_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_LINE');
                    fnd_message.set_token ('LINE_ID', to_char(l_line_rec.requirement_line_id), FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'l_line_rec.requirement_line_id', FALSE);
                    fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
                    fnd_message.set_token('TABLE', 'CSP_REQUIREMENT_LINES', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
                  END;
              END IF;

            l_rqmt_line_Rec.requirement_line_id := l_line_rec.requirement_line_id;
            l_rqmt_line_rec.last_updated_by := nvl(l_user_id, 1);
            l_rqmt_line_rec.last_update_date := l_today;
            l_rqmt_line_rec.last_update_login := nvl(l_login_id, -1);
            l_rqmt_line_rec.ordered_quantity := l_line_Rec.ordered_quantity;
            l_rqmt_line_rec.order_line_id := l_line_Rec.requisition_line_id;
            l_rqmt_line_Rec.sourced_from := 'VENDOR';
            --l_rqmt_line_rec.reservation_id := l_line_rec.reservation_id;
            --l_rqmt_line_rec.order_by_date := l_line_rec.order_by_date;

            l_rqmt_line_Tbl(J) := l_rqmt_line_rec;

          END LOOP;
        END IF;
    END IF;

    IF (l_rqmt_line_Tbl.count > 0) THEN

      CSP_Requirement_Lines_PVT.Update_requirement_lines(
              P_Api_Version_Number         => l_api_version_number,
              P_Init_Msg_List              => p_Init_Msg_List,
              P_Commit                     => p_commit,
              p_validation_level           => null,
              P_Requirement_Line_Tbl       => l_rqmt_line_tbl,
              X_Return_Status              => l_return_status,
              X_Msg_Count                  => l_msg_count,
              X_Msg_Data                   => l_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign output variables
      px_header_rec := l_header_rec;
      px_line_table := l_line_tbl;

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
      Rollback to csptrreq_fm_order_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

  END csptrreq_fm_order;

       PROCEDURE csptrreq_order_res(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'csptrreq_fm_order';
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;
  EXCP_USER_DEFINED        EXCEPTION;
  l_check_existence        NUMBER;
  J                        NUMBER;
  K                        NUMBER;

  l_requirement_header_id  NUMBER ;
  l_requirement_line_id    NUMBER;

  l_header_rec             Header_Rec_Type;
  l_line_rec               Line_rec_type;
  l_line_tbl               Line_Tbl_type;
  l_oe_line_tbl            Line_Tbl_type;
  l_oe_line_rec            Line_rec_type;
  l_po_line_tbl            Line_Tbl_type;
  l_po_line_Rec            Line_Rec_Type;

  l_reservation_rec        CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
  l_reservation_id         NUMBER;

  l_req_line_dtl_id        NUMBER;

    l_party_site_id          NUMBER;
  l_customer_id             NUMBER;
  l_cust_account_id         NUMBER;
  l_org_id number;
  l_internal_order_status  VARCHAR2(5);
  l_order_status           VARCHAR2(5);


    cursor get_party_details( c_incident_id number,c_location_id number) is
    select  jpl.party_site_id, cia.customer_id, cia.account_id, cia.org_id
    from    jtf_party_locations_v jpl, cs_incidents_all_b cia
    where   jpl.party_id = cia.customer_id
    and     cia.incident_id = c_incident_id
    and     jpl.location_id = c_location_id;

 BEGIN

    SAVEPOINT csptrreq_fm_order_PUB;

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

    l_header_Rec := px_header_rec;
    l_line_tbl := px_line_table;

    -- user and login information
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_parts_requirement.csptrreq_order_res',
                      'l_header_rec.address_type = ' || l_header_rec.address_type
                      || ', l_header_rec.incident_id = ' || l_header_rec.incident_id
                      || ', l_header_rec.task_id = ' || l_header_rec.task_id
                      || ', l_header_Rec.ship_to_location_id = ' || l_header_Rec.ship_to_location_id);
    end if;

    IF (l_header_rec.address_type = 'C') THEN
      IF (l_header_rec.incident_id IS NULL AND l_header_rec.task_id IS NOT NULL) THEN
        BEGIN
          SELECT source_object_id
          INTO l_header_rec.incident_id
          FROM jtf_Tasks_b
          where task_id = l_header_rec.task_id;
        EXCEPTION
          when no_data_found then
            null;
        END;
      END IF;

      open get_party_details(l_header_Rec.incident_id,l_header_Rec.ship_to_location_id) ;
      FETCH get_party_details INTO l_party_site_id,l_customer_id,l_cust_account_id, l_org_id;
      CLOSE get_party_details;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_parts_requirement.csptrreq_order_res',
                      'l_party_site_id = ' || l_party_site_id
                      || ', l_customer_id = ' || l_customer_id
                      || ', l_cust_account_id = ' || l_cust_account_id
					  || ', l_org_id = ' || l_org_id);
    end if;

      csp_ship_to_address_pvt.cust_inv_loc_link
      (          p_api_version              => 1.0
            ,p_Init_Msg_List            => FND_API.G_FALSE
                ,p_commit                   => FND_API.G_FALSE
                        ,px_location_id             => l_header_Rec.ship_to_location_id
                ,p_party_site_id            => l_party_site_id
                ,p_cust_account_id          => l_cust_account_id
                ,p_customer_id              => l_customer_id
				,p_org_id					=> l_org_id
                ,p_attribute_category       => null
                ,p_attribute1                => null
                ,p_attribute2                => null
                ,p_attribute3                => null
                ,p_attribute4                => null
                ,p_attribute5                => null
                ,p_attribute6                => null
                ,p_attribute7                => null
                ,p_attribute8                => null
                ,p_attribute9                => null
                ,p_attribute10               => null
                ,p_attribute11               => null
                ,p_attribute12               => null
                ,p_attribute13               => null
                ,p_attribute14               => null
                ,p_attribute15               => null
                ,p_attribute16               => null
                ,p_attribute17               => null
                ,p_attribute18               => null
                ,p_attribute19               => null
                ,p_attribute20               => null
                ,x_return_status             => l_return_status
                        ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_parts_requirement.csptrreq_order_res',
                      'l_return_status = ' || l_return_status);
    end if;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

    -- create reservations and create line table which qualify for creating order
    K := 1;
    J := 1;
    FOR I IN 1..l_line_Tbl.COUNT LOOP
      l_line_rec := l_line_tbl(I);
      IF (l_line_rec.sourced_From = 'RES') THEN
        l_reservation_rec.need_by_date := sysdate; --l_header_rec.need_by_date;
        l_reservation_rec.organization_id := l_line_rec.source_organization_id;
        l_reservation_rec.item_id := l_line_Rec.inventory_item_id;
        l_Reservation_rec.revision := l_line_rec.revision;
        l_reservation_rec.item_uom_code := l_line_rec.unit_of_measure;
        l_reservation_rec.quantity_needed := l_line_rec.ordered_quantity;
        l_reservation_rec.sub_inventory_code := l_line_rec.source_subinventory;

        l_reservation_id := csp_sch_int_pvt.create_reservation(
                                                p_reservation_parts => l_reservation_rec,
                                                x_return_status     => l_return_status,
                                                x_msg_data          => l_msg_data
                                                );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
          -- code for inserting into req line dtls
          SELECT csp_req_line_Details_s1.nextval
          INTO l_req_line_Dtl_id
          FROM dual;

          csp_req_line_Details_pkg.Insert_Row(
                px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                p_REQUIREMENT_LINE_ID   =>  l_line_rec.requirement_line_id,
                p_CREATED_BY            =>  nvl(l_user_id, 1),
                p_CREATION_DATE         =>  sysdate,
                p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                p_LAST_UPDATE_DATE      =>  sysdate,
                p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                p_SOURCE_TYPE           => 'RES',
                p_SOURCE_ID             => l_Reservation_id
                );
        END If;
      ELSIF (l_line_rec.sourced_from = 'IO') THEN
        l_oe_line_tbl(J) := l_line_rec;
        J := J + 1;
      ELSIF (l_line_rec.sourced_from = 'POREQ') THEN
        l_po_line_tbl(K) := l_line_Rec;
        K := K+1;
      END IF;
    END LOOP;

    l_internal_order_status := fnd_profile.value('CSP_INIT_IO_STATUS_PARTREQ');

    IF (l_line_rec.sourced_from = 'IO')
    THEN
      IF( l_internal_order_status = 'B') OR (l_internal_order_status = null)
      THEN
      l_order_status := 'Y';
      ELSIF( l_internal_order_status = 'E')
      THEN
      l_order_status := 'N';
      END IF;
    ELSE
      l_order_status := 'Y';
    END IF;
    -- call csp_process_order API only if atleast one line qualifies for order to be created

    IF (l_oe_line_tbl.count > 0) THEN
        csp_parts_order.process_order(
              p_api_version             => l_api_version_number
             ,p_Init_Msg_List           => p_init_msg_list
             ,p_commit                  => p_commit
             ,px_header_rec             => l_header_rec
             ,px_line_table             => l_oe_line_tbl
             ,x_return_status           => l_return_status
             ,x_msg_count               => l_msg_count
             ,x_msg_data                => l_msg_data
             ,p_book_order              => l_order_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- insert record in csp_req_line_details table with order information
            FOR I IN 1..l_oe_line_tbl.COUNT LOOP
              l_line_rec := l_oe_line_tbl(I);

              SELECT csp_req_line_Details_s1.nextval
              INTO l_req_line_Dtl_id
              FROM dual;

              csp_req_line_Details_pkg.Insert_Row(
                px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                p_REQUIREMENT_LINE_ID   =>  l_line_rec.requirement_line_id,
                p_CREATED_BY            =>  nvl(l_user_id, 1),
                p_CREATION_DATE         =>  sysdate,
                p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                p_LAST_UPDATE_DATE      =>  sysdate,
                p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                p_SOURCE_TYPE           =>  'IO',
                p_SOURCE_ID             =>  l_line_rec.order_line_id);
            END LOOP;
        END IF;
    END IF;

    -- create purchase requisitions if po_line_tbl has atleast one record
    IF (l_po_line_tbl.count > 0) THEN
        csp_parts_order.process_purchase_req(
             p_api_version      => l_api_version_number
            ,p_init_msg_list    => p_init_msg_list
            ,p_commit           => p_commit
            ,px_header_rec      => l_header_Rec
            ,px_line_Table      => l_po_line_tbl
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
          -- insert into csp_req_line_Details table with purchase req information
           FOR I IN 1..l_po_line_tbl.COUNT LOOP
            l_line_rec := l_po_line_tbl(I);

            SELECT csp_req_line_Details_s1.nextval
              INTO l_req_line_Dtl_id
              FROM dual;

              csp_req_line_Details_pkg.Insert_Row(
                px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                p_REQUIREMENT_LINE_ID   =>  l_line_rec.requirement_line_id,
                p_CREATED_BY            =>  nvl(l_user_id, 1),
                p_CREATION_DATE         =>  sysdate,
                p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                p_LAST_UPDATE_DATE      =>  sysdate,
                p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                p_SOURCE_TYPE           =>  'POREQ',
                p_SOURCE_ID             =>  l_line_rec.requisition_line_id);
          END LOOP;
        END IF;
    END IF;

    px_header_rec := l_header_rec;
    px_line_table := l_line_tbl;

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
      Rollback to csptrreq_fm_order_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE delete_rqmt_header(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  )IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'delete_rqmt_header';
  EXCP_USER_DEFINED        EXCEPTION;
  l_count                  NUMBER;
  BEGIN
    SAVEPOINT delete_rqmt_header_PUB;

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

    IF (p_header_id IS NOT NULL) THEN
        SELECT count(*)
        INTO l_count
        FROM csp_requirement_lines crl, csp_req_line_Details crld
        WHERE crl.requirement_header_id = p_header_id
        AND crl.requirement_line_id = crld.requirement_line_id;

       IF l_count > 0 THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_RQMT_LINE_DELETE_ERROR');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_header_id', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        ELSE
          DELETE FROM csp_requirement_lines
          WHERE requirement_header_id = p_header_id;

          DELETE FROM csp_requirement_headers
          WHERE requirement_header_id = p_header_id;
        END IF;

        IF fnd_api.to_boolean(p_commit) THEN
           commit work;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
  EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to delete_rqmt_header_PUB;
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
      Rollback to delete_rqmt_header_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE save_rqmt_line(
        p_api_version              IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_tbl               IN OUT NOCOPY csp_parts_requirement.Line_tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  )IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'save_rqmt_line';
  l_header_rec             csp_parts_requirement.Header_rec_type;
  l_line_tbl               csp_parts_requirement.Line_Tbl_type;
  l_line_rec               Line_rec_type;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;
  l_parts_defined          VARCHAR2(30);
  l_rqmt_header_Rec        csp_requirement_headers_pvt.requirement_header_rec_type;
  l_rqmt_line_Rec          csp_requirement_lines_pvt.requirement_line_rec_type;
  l_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;
  l_rqmt_line_Tbl_out      csp_requirement_lines_pvt.requirement_line_tbl_type;
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_requirement_header_id  NUMBER;
  l_resource_name          VARCHAR2(240);

  EXCP_USER_DEFINED        EXCEPTION;

  l_party_site_id          NUMBER;
  l_customer_id             NUMBER;
  l_cust_account_id         NUMBER;
  I                         NUMBER;
  l_check_existence         NUMBER;
  l_count                   NUMBER;
  l_org_id number;

  cursor get_party_details( c_incident_id number,c_location_id number) is
    select  jpl.party_site_id, cia.customer_id, cia.account_id, cia.org_id
    from    jtf_party_locations_v jpl, cs_incidents_all_b cia
    where   jpl.party_id = cia.customer_id
    and     cia.incident_id = c_incident_id
    and     jpl.location_id = c_location_id;

  cursor rqmt_lines_cur(p_rqmt_header_id NUMBER) IS
  select crl.requirement_line_id,
         crl.inventory_item_id ,
         crl.revision,
         crl.required_quantity,
         crl.uom_code
  from   csp_requirement_lines crl,
         csp_req_line_details crld
  where  crld.requirement_line_id(+) = crl.requirement_line_id
  and    crl.requirement_header_id = p_rqmt_header_id
  and    crld.source_id is null;

  rqmt_line  rqmt_lines_cur%ROWTYPE;

  -- File Handling
  /*  debug_handler utl_file.file_type;
    debug_handler1 utl_file.file_type;
    l_utl_dir varchar2(1000) := '/appslog/srv_top/utl/srvmntr8/out';
  */
  BEGIN
    SAVEPOINT save_rqmt_line_PUB;

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
    l_header_Rec := px_header_rec;
    l_line_tbl   := px_line_tbl;

    -- user and login information
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;

    l_login_id := fnd_global.login_id;

    IF (l_header_rec.requirement_header_id IS NULL) THEN
      -- create header
      --get resource information
        BEGIN
          SELECT resource_id
          INTO l_header_rec.resource_id
          FROM jtf_rs_resource_extns
          WHERE user_id = l_user_id;
        EXCEPTION
          WHEN no_Data_found THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_RS_USER_NOT_DEFINED');
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;

     /* BEGIN
          SELECT resource_type, resource_name
          INTO l_header_Rec.resource_type, l_resource_name
          FROM jtf_rs_all_resources_vl
          WHERE resource_id = l_header_rec.resource_id;
        EXCEPTION
          WHEN no_Data_found THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_INVALID_RES_ID_TYPE');
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;
      */
        -- Since wireless deals with employee type resources only, hardcode resource type
        l_header_rec.resource_type := 'RS_EMPLOYEE';

        BEGIN
          SELECT organization_id, subinventory_code
          INTO l_header_rec.dest_organization_id, l_header_rec.dest_subinventory
          FROM CSP_INV_LOC_ASSIGNMENTS
          WHERE resource_id = l_header_rec.resource_id
          AND resource_type = l_header_rec.resource_type
          AND default_code = 'IN';
        EXCEPTION
          WHEN no_Data_found THEN

            FND_MESSAGE.SET_NAME ('CSP', 'CSP_SCH_DEFAULT_SUBINV');
            FND_MESSAGE.SET_TOKEN('RESOURCE_TYPE', l_header_rec.resource_type);
            FND_MESSAGE.SET_TOKEN('RESOURCE_NAME', l_resource_name);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
          WHEN TOO_MANY_ROWS THEN

            FND_MESSAGE.SET_NAME ('CSP', 'CSP_ONE_DEFAULT_IN_ALLOWED');
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;

        IF (l_header_rec.task_id IS NOT NULL) THEN
            BEGIN
              SELECT source_object_id
              INTO l_header_rec.incident_id
              FROM jtf_tasks_b
              WHERE task_id = l_header_rec.task_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETER');
                FND_MESSAGE.SET_TOKEN('PARAMETER', 'Service Request');
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
            END;
          END IF;

          IF (l_header_rec.address_type = 'C') THEN
            open get_party_details(l_header_Rec.incident_id,l_header_Rec.ship_to_location_id) ;
    	    FETCH get_party_details INTO  l_party_site_id,l_customer_id,l_cust_account_id, l_org_id;
    	    CLOSE get_party_details;

            csp_ship_to_address_pvt.cust_inv_loc_link
    	    (  	 p_api_version              => 1.0
        	    ,p_Init_Msg_List            => FND_API.G_FALSE
        		,p_commit                   => FND_API.G_FALSE
       			,px_location_id             => l_header_Rec.ship_to_location_id
        		,p_party_site_id            => l_party_site_id
        		,p_cust_account_id          => l_cust_account_id
        		,p_customer_id              => l_customer_id
				,p_org_id					=> l_org_id
        		,p_attribute_category       => null
        		,p_attribute1                => null
        		,p_attribute2                => null
        		,p_attribute3                => null
        		,p_attribute4                => null
        		,p_attribute5                => null
        		,p_attribute6                => null
        		,p_attribute7                => null
        		,p_attribute8                => null
        		,p_attribute9                => null
        		,p_attribute10               => null
        		,p_attribute11               => null
        		,p_attribute12               => null
        		,p_attribute13               => null
        		,p_attribute14               => null
        		,p_attribute15               => null
        		,p_attribute16               => null
        		,p_attribute17               => null
        		,p_attribute18               => null
        		,p_attribute19               => null
        		,p_attribute20               => null
        		,x_return_status             => l_return_status
       			,x_msg_count                 => l_msg_count
        		,x_msg_data                  => l_msg_data);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

      l_rqmt_header_Rec.requirement_header_id      := nvl(l_header_rec.requirement_header_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.created_by                 := nvl(l_user_id, -1);
      l_rqmt_header_Rec.creation_date              := l_today;
      l_rqmt_header_Rec.last_updated_by            := nvl(l_user_id, -1);
      l_rqmt_header_Rec.last_update_date           := l_today;
      l_rqmt_header_Rec.last_update_login          := nvl(l_login_id, -1);
      l_rqmt_header_Rec.ship_to_location_id        := nvl(l_header_rec.ship_to_location_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.address_type               := l_header_Rec.address_type;
      l_rqmt_header_Rec.task_id                    := nvl(l_header_rec.task_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.task_assignment_id         := nvl(l_header_rec.task_assignment_id, FND_API.G_MISS_NUM);
      IF(l_header_rec.task_id IS NULL) THEN
        l_rqmt_header_Rec.resource_id              := nvl(l_header_rec.resource_id, FND_API.G_MISS_NUM);
        l_rqmt_header_Rec.resource_type            := nvl(l_header_rec.resource_type, FND_API.G_MISS_CHAR);
      END IF;
      l_rqmt_header_Rec.need_by_date               := nvl(l_header_rec.need_by_date, FND_API.G_MISS_DATE);
      l_rqmt_header_Rec.destination_organization_id := nvl(l_header_rec.dest_organization_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.destination_subinventory   := nvl(l_header_rec.dest_subinventory, FND_API.G_MISS_CHAR);
      l_rqmt_header_Rec.shipping_method_code       := FND_API.G_MISS_CHAR;
      l_rqmt_header_Rec.parts_defined              := nvl(l_parts_defined, FND_API.G_MISS_CHAR);
      l_rqmt_header_Rec.open_requirement           := 'W';
      l_rqmt_header_rec.order_type_id              := nvl(l_header_rec.order_type_id, FND_PROFILE.value('CSP_ORDER_TYPE'));
      l_rqmt_header_rec.attribute_Category         := nvl(l_header_rec.attribute_category, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute1                 := nvl(l_header_rec.attribute1, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute2                 := nvl(l_header_rec.attribute2, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute3                 := nvl(l_header_rec.attribute3, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute4                 := nvl(l_header_rec.attribute4, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute5                 := nvl(l_header_rec.attribute5, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute6                 := nvl(l_header_rec.attribute6, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute7                 := nvl(l_header_rec.attribute7, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute8                 := nvl(l_header_rec.attribute8, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute9                 := nvl(l_header_rec.attribute9, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute10                := nvl(l_header_rec.attribute10, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute11                := nvl(l_header_rec.attribute11, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute12                := nvl(l_header_rec.attribute12, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute13                := nvl(l_header_rec.attribute13, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute14                := nvl(l_header_rec.attribute14, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.attribute15                := nvl(l_header_rec.attribute15, FND_API.G_MISS_CHAR);
      l_rqmt_header_rec.ship_to_contact_id         := nvl(l_header_rec.ship_to_contact_id, FND_API.G_MISS_NUM);

      -- check to see if requirements exist for a given task
     /*commenting for 11.5.10 since multiple rqmt headers can exist for a task
       IF (l_header_rec.task_id IS NOT NULL) THEN
        BEGIN
          SELECT requirement_header_id
          INTO l_requirement_header_id
          FROM csp_requirement_headers
          WHERE task_id = l_header_rec.task_id;

          IF (l_requirement_header_id IS NOT NULL) THEN
            Rollback to save_rqmt_line_PUB;
            --FND_MESSAGE.SET_NAME('CSP', 'CSP_TASK_RQMT_EXISTS');
            --FND_MSG_PUB.ADD;
            --fnd_msg_pub.count_and_get
            --  ( p_count => x_msg_count
            --  , p_data  => x_msg_data);
		  x_msg_data := fnd_message.get_string('CSP', 'CSP_TASK_RQMT_EXISTS');
            x_return_status := 'E';
            return;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           -- call private api for inserting into csp_Requirement_headers
           CSP_REQUIREMENT_HEADERS_PVT.Create_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_REQUIREMENT_HEADER_ID      => l_requirement_header_id,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               fnd_msg_pub.count_and_get
                 ( p_count => x_msg_count
                 , p_data  => x_msg_data);
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
               --RAISE FND_API.G_EXC_ERROR;
            END IF;
            l_header_rec.requirement_header_id := l_requirement_header_id;
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE */
        -- call private api for inserting into csp_Requirement_headers
        CSP_REQUIREMENT_HEADERS_PVT.Create_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_REQUIREMENT_HEADER_ID      => l_requirement_header_id,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_header_rec.requirement_header_id := l_requirement_header_id;
   --   END IF;

    ELSE
      -- update header
      -- check to see if requirement_header_id is valid
       BEGIN
          select requirement_header_id
          into l_check_existence
          from csp_requirement_headers
          where requirement_header_id = l_header_rec.requirement_header_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_HEADER');
            fnd_message.set_token('HEADER_ID', to_char(l_header_rec.requirement_header_id), FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
          WHEN OTHERS THEN
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
            fnd_message.set_token('ERR_FIELD', 'l_header_rec.requirement_header_id', FALSE);
            fnd_message.set_token('ROUTINE', G_PKG_NAME||'.'||l_api_name, FALSE);
            fnd_message.set_token('TABLE', 'CSP_REQUIREMENT_HEADERS', FALSE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END;

      l_rqmt_header_Rec.requirement_header_id      := l_header_rec.requirement_header_id;
      l_rqmt_header_Rec.last_updated_by            := nvl(l_user_id, -1);
      l_rqmt_header_Rec.last_update_date           := l_today;
      l_rqmt_header_Rec.last_update_login          := nvl(l_login_id, -1);
      l_rqmt_header_Rec.ship_to_location_id        := nvl(l_header_rec.ship_to_location_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.task_id                    := nvl(l_header_rec.task_id, FND_API.G_MISS_NUM);
      l_rqmt_header_Rec.need_by_date               := nvl(l_header_rec.need_by_date, FND_API.G_MISS_DATE);

      CSP_REQUIREMENT_HEADERS_PVT.Update_requirement_headers(
                P_Api_Version_Number         => l_api_Version_number,
                P_Init_Msg_List              => p_init_msg_list,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_REQUIREMENT_HEADER_Rec     => l_rqmt_header_rec,
                X_Return_Status              => l_Return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

      -- create rqmt line
      FOR I IN 1..l_line_tbl.COUNT LOOP
          l_line_rec := l_line_tbl(I);
          IF (l_line_rec.unit_of_measure IS NULL) THEN
            SELECT primary_uom_code
            INTO l_line_rec.unit_of_measure
            FROM mtl_system_items
            WHERE inventory_item_id = l_line_Rec.inventory_item_id
            AND  organization_id = cs_Std.get_item_valdn_orgzn_id;
          END IF;
          l_rqmt_line_Rec.requirement_line_id := l_line_rec.requirement_line_id;

          BEGIN
            select count(*)
            into l_count
            from csp_requirement_lines
            where requirement_line_id = l_rqmt_line_rec.requirement_line_id;
            IF l_count > 0 THEN
              fnd_message.set_name('CSP', 'CSP_DUPLICATE_RQMT_LINE');
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              null;
          END;
          l_rqmt_line_Rec.created_by             := nvl(l_user_id, -1);
          l_rqmt_line_Rec.creation_date          := l_today;
          l_rqmt_line_rec.last_updated_by := nvl(l_user_id, 1);
          l_rqmt_line_rec.last_update_date := l_today;
          l_rqmt_line_rec.last_update_login := nvl(l_login_id, -1);
          l_rqmt_line_rec.requirement_header_id := l_header_rec.requirement_header_id;
          l_rqmt_line_rec.inventory_item_id := l_line_rec.inventory_item_id;
          l_rqmt_line_rec.uom_code := l_line_rec.unit_of_measure;
          l_rqmt_line_rec.required_quantity := l_line_rec.quantity;
          l_rqmt_line_rec.ship_complete_flag := l_line_rec.ship_complete;
          l_rqmt_line_rec.likelihood := l_line_rec.likelihood;
          l_rqmt_line_rec.revision := l_line_rec.revision;
    	  l_rqmt_line_rec.ordered_quantity := l_line_Rec.quantity;
          l_rqmt_line_rec.attribute_Category         := nvl(l_line_rec.attribute_category, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute1                 := nvl(l_line_rec.attribute1, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute2                 := nvl(l_line_rec.attribute2, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute3                 := nvl(l_line_rec.attribute3, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute4                 := nvl(l_line_rec.attribute4, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute5                 := nvl(l_line_rec.attribute5, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute6                 := nvl(l_line_rec.attribute6, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute7                 := nvl(l_line_rec.attribute7, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute8                 := nvl(l_line_rec.attribute8, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute9                 := nvl(l_line_rec.attribute9, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute10                := nvl(l_line_rec.attribute10, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute11                := nvl(l_line_rec.attribute11, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute12                := nvl(l_line_rec.attribute12, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute13                := nvl(l_line_rec.attribute13, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute14                := nvl(l_line_rec.attribute14, FND_API.G_MISS_CHAR);
          l_rqmt_line_rec.attribute15                := nvl(l_line_rec.attribute15, FND_API.G_MISS_CHAR);

          l_rqmt_line_tbl(I) := l_rqmt_line_rec;
      END LOOP;

      CSP_Requirement_Lines_PVT.Create_requirement_lines(
                P_Api_Version_Number         => l_api_version_number,
                P_Init_Msg_List              => p_Init_Msg_List,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_Requirement_Line_Tbl       => l_rqmt_line_tbl,
                x_Requirement_Line_tbl       => l_rqmt_line_tbl_out,
                X_Return_Status              => l_return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Return header rec and line table.
	  px_header_rec := l_header_rec;
      OPEN rqmt_lines_cur(l_header_rec.requirement_header_id);
      I := 1;
      LOOP
        FETCH rqmt_lines_cur INTO rqmt_line;
        EXIT WHEN rqmt_lines_cur%NOTFOUND;
        px_line_tbl(I).requirement_line_id := rqmt_line.requirement_line_id;
        px_line_tbl(I).inventory_item_id :=  rqmt_line.inventory_item_id;
        px_line_tbl(I).revision := rqmt_line.revision;
        px_line_tbl(I).quantity := rqmt_line.required_quantity;
        px_line_tbl(I).unit_of_measure := rqmt_line.uom_code;
        I := I + 1;
      END LOOP;

      IF fnd_api.to_boolean(p_commit) THEN
           commit work;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to save_rqmt_line_PUB;
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
      Rollback to save_rqmt_line_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;


  PROCEDURE delete_rqmt_line(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_line_tbl                IN OUT NOCOPY csp_parts_requirement.Rqmt_Line_tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'delete_rqmt_line';
  BEGIN
    SAVEPOINT delete_rqmt_line_PUB;

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

    IF (p_line_tbl.count > 0) THEN
      FOR I IN 1..p_line_Tbl.count LOOP
        DELETE FROM csp_Requirement_lines
        WHERE requirement_line_id = p_line_tbl(I).requirement_line_id;
      END LOOP;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
           commit work;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

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
      Rollback to delete_rqmt_line_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE check_Availability(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_line_Tbl                OUT NOCOPY csp_parts_requirement.Line_tbl_type
        ,x_avail_flag              OUT NOCOPY VARCHAR2
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  )IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'check_availability';
  l_count                  NUMBER;
  l_header_rec             csp_parts_requirement.Header_rec_type;
  l_line_rec               csp_parts_requirement.line_rec_type;
  l_line_tbl               csp_parts_Requirement.line_Tbl_type;
  l_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;
  EXCP_USER_DEFINED        EXCEPTION;
  l_parts_list_rec	       csp_sch_int_pvt.csp_parts_rec_type;
  l_parts_list_tbl	       csp_sch_int_pvt.csp_parts_tbl_typ1;
  l_avail_list_tbl         csp_sch_int_pvt.available_parts_tbl_typ1;
  I                        NUMBER;
  J                        NUMBER;
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);

  CURSOR rqmt_line_cur IS
  select crl.requirement_line_id,
         crl.inventory_item_id,
         crl.uom_code,
         crl.required_quantity
  from   csp_requirement_lines crl,
         csp_req_line_details crld
  where  crld.requirement_line_id(+) = crl.requirement_line_id
  and    crl.requirement_header_id = p_header_id
  and    crld.source_id is null;

  BEGIN
    SAVEPOINT check_Availability_PUB;

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

    IF (p_header_id IS NOT NULL) THEN
      select count(*)
      into   l_count
      from   csp_requirement_lines crl,
             csp_req_line_details crld
      where  crld.requirement_line_id(+) = crl.requirement_line_id
      and    crl.requirement_header_id = p_header_id
      and    crld.source_id is null;

      IF (l_count > 0) THEN
        BEGIN
          SELECT
            requirement_header_id,
            need_by_date,
            destination_organization_id,
            destination_subinventory
          INTO
            l_header_rec.requirement_header_id,
            l_header_rec.need_by_Date,
            l_header_rec.dest_organization_id,
            l_header_rec.dest_subinventory
          FROM csp_Requirement_headers
          WHERE requirement_header_id = p_header_id;

        EXCEPTION
          WHEN no_data_found THEN
              fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_HEADER');
              fnd_message.set_token('HEADER_ID', to_char(p_header_id), FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
        END;

        OPEN rqmt_line_cur;
        I := 1;
        LOOP
          FETCH rqmt_line_cur
          INTO l_line_rec.requirement_line_id,
          l_line_rec.inventory_item_id,
          l_line_rec.unit_of_measure,
          l_line_rec.quantity;
          EXIT WHEN rqmt_line_cur%NOTFOUND;
          l_line_tbl(I) := l_line_rec;
          l_parts_list_tbl(I).item_id := l_line_rec.inventory_item_id;
          l_parts_list_tbl(I).item_uom := l_line_rec.unit_of_measure;
          l_parts_list_tbl(I).quantity := l_line_rec.quantity;
          l_parts_list_tbl(I).line_id := l_line_rec.requirement_line_id;
          I := I + 1;
        END LOOP;

        IF (l_parts_list_Tbl.count > 0) THEN
          FND_MSG_PUB.initialize;
          -- call csp_sch_int_pvt.check_parts_availability()
          csp_sch_int_pvt.check_parts_availability(
		    p_resource 		    => null,
		    p_organization_id 	=> l_header_rec.dest_organization_id,
            p_subinv_code       => l_header_rec.dest_subinventory,
		    p_need_by_date 		=> l_header_rec.need_by_date,
		    p_parts_list 		=> l_parts_list_tbl,
  		    p_timezone_id		=> null,
		    x_availability 		=> l_avail_list_tbl,
		    x_return_status 	=> l_return_status,
		    x_msg_data		    => l_msg_data,
		    x_msg_count		    => l_msg_count,
            p_Called_From       => 'MOBILE',
            p_location_id      => l_header_rec.ship_to_location_id
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            null;
            --RAISE FND_API.G_EXC_ERROR;
          END IF;

          J := 1;
          I := 1;
          IF (l_Avail_list_tbl.COUNT > 0) THEN
            WHILE (I <= l_line_tbl.COUNT AND J <= l_Avail_list_Tbl.COUNT) LOOP
              IF (l_line_tbl(I).requirement_line_id = l_avail_list_Tbl(J).line_id) THEN
                IF (nvl(l_Avail_list_tbl(J).recommended_option, 'N') = 'Y') THEN
                   -- IF (l_avail_list_tbl(J).source_type = 'INVENTORY') THEN
                    IF (l_line_Tbl(I).inventory_item_id <> l_avail_list_tbl(I).item_id) THEN
                      l_line_tbl(I).inventory_item_id := l_Avail_list_tbl(I).item_id;
                    END IF;
                    IF (l_line_Tbl(I).arrival_date > l_header_rec.need_by_date) THEN
                      l_line_tbl(I).available_by_need_date := 'N';
                    ELSE
                      l_line_tbl(I).available_by_need_date := 'Y';
                    END IF;
                    l_line_tbl(I).sourced_from := l_Avail_list_tbl(J).source_type;
                    l_line_tbl(I).source_organization_id := l_avail_list_tbl(J).source_org_id;
                    l_line_tbl(I).arrival_Date := l_Avail_list_tbl(J).arraival_date;
                    l_line_Tbl(I).shipping_method_code := l_Avail_list_tbl(J).shipping_methode;
                    l_line_tbl(I).order_by_date := l_Avail_list_Tbl(J).order_by_Date;
                    l_line_Tbl(I).ordered_quantity := l_Avail_list_Tbl(J).ordered_quantity;
                    J := J + 1;
                    I := I + 1;
                    --END IF;
                ELSE
                  J := J+1;
                END IF;
              ELSE
                J := J + 1;
              END IF;
            END LOOP;
          END IF;
          FOR I IN 1..l_line_tbl.COUNT LOOP
            IF (nvl(l_line_tbl(I).sourced_from, 'IO') = 'IO') THEN
			-- not required since this will be part of the call to check_Avail
			/*
			and l_line_Tbl(I).source_organization_id IS NULL) THEN
              Get_source_organization(P_Inventory_Item_Id => l_line_Tbl(I).inventory_item_id,
                                P_Organization_Id   => l_header_Rec.dest_organization_id,
                                P_Secondary_Inventory => l_header_rec.dest_subinventory,
                                x_source_org_id     => l_line_Tbl(I).source_organization_id);
			*/
              IF ((l_line_Tbl(I).source_organization_id IS NULL) OR
                  (l_line_Tbl(I).source_organization_id = FND_API.G_MISS_NUM)) THEN
                 -- no source organization defined, create requirement with error status
                 x_avail_flag := 'N';
              END IF;
            END If;
            -- insert into l_rqmt_line_rec for updation.
            l_rqmt_line_tbl(I).requirement_line_id := l_line_tbl(I).requirement_line_id;
            l_rqmt_line_tbl(I).last_updated_by := nvl(FND_GLOBAL.user_id, 1);
            l_rqmt_line_tbl(I).last_update_date := sysdate;
            l_rqmt_line_tbl(I).last_update_login := nvl(FND_GLOBAL.login_id , -1);
            l_rqmt_line_tbl(I).inventory_item_id := l_line_tbl(I).inventory_item_id;
            l_rqmt_line_tbl(I).sourced_From := l_line_tbl(I).sourced_From;
            l_rqmt_line_tbl(I).source_organization_id := nvl(l_line_tbl(I).source_organization_id, FND_API.G_MISS_NUM);
            l_rqmt_line_tbl(I).arrival_Date := nvl(l_line_tbl(I).arrival_Date, FND_API.G_MISS_DATE);
            l_rqmt_line_tbl(I).shipping_method_code :=  nvl(l_line_Tbl(I).shipping_method_code, FND_API.G_MISS_CHAR);
            l_rqmt_line_tbl(I).order_by_date := nvl(l_line_tbl(I).order_by_date, FND_API.G_MISS_DATE);
            l_rqmt_line_tbl(I).ordered_quantity := nvl(l_line_Tbl(I).ordered_quantity, 0);
          END LOOP;

          IF l_rqmt_line_tbl.COUNT > 0 THEN
            CSP_Requirement_Lines_PVT.Update_requirement_lines(
                P_Api_Version_Number         => l_api_version_number,
                P_Init_Msg_List              => p_Init_Msg_List,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => null,
                P_Requirement_Line_Tbl       => l_rqmt_line_tbl,
                X_Return_Status              => l_return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END If;
        x_line_tbl := l_line_tbl;
        x_avail_flag := nvl(x_avail_flag, 'Y');
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
           commit work;
      END IF;
    END IF;
  EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to check_Availability_PUB;
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
      Rollback to check_Availability_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE create_order(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_order_tbl               OUT NOCOPY Order_Tbl_Type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  )IS
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'create_order';
  l_count                  NUMBER;
  l_header_rec             csp_parts_requirement.Header_rec_type;
  l_line_rec               csp_parts_requirement.line_rec_type;
  l_line_tbl               csp_parts_Requirement.line_Tbl_type;
  l_oe_line_tbl            csp_parts_requirement.line_Tbl_Type;
  l_po_line_Tbl            csp_parts_requirement.line_tbl_type;
  l_rqmt_line_Tbl          csp_requirement_lines_pvt.requirement_line_tbl_type;
  EXCP_USER_DEFINED        EXCEPTION;
  I                        NUMBER;
  J                        NUMBER;
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_order_number           NUMBER;
  l_open_requirement       VARCHAr2(30);
  l_req_line_dtl_id        NUMBER;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
  l_today                  DATE;

  CURSOR rqmt_line_cur IS
    SELECT c.requirement_line_id,
           c.inventory_item_id,
           c.revision,
           c.uom_code,
           c.required_quantity,
           c.sourced_from,
           c.source_organization_id,
           c.source_subinventory,
           c.shipping_method_code,
           c.arrival_date
    FROM csp_requirement_lines c
    WHERE c.requirement_header_id = p_header_id
    AND not exists (select 1 from csp_req_line_Details d where d.requirement_line_id = c.requirement_line_id)
    FOR UPDATE of c.order_line_id NOWAIT;

 BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                      'Begin');
    end if;

    SAVEPOINT create_order_PUB;

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

    -- user and login information
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                      'l_user_id = ' || l_user_id
                      || ', l_login_id = ' || l_login_id);
    end if;

    IF (p_header_id IS NOT NULL) THEN
      select count(*)
      into   l_count
      from   csp_requirement_lines crl,
             csp_req_line_details crld
      where  crld.requirement_line_id(+) = crl.requirement_line_id
      and    crl.requirement_header_id = p_header_id
      and    crld.source_id is null;

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                        'p_header_id is NOT NULL and number of lines for this requirement is = ' || l_count);
      end if;

      IF (l_count > 0) THEN
        BEGIN
          SELECT
            requirement_header_id,
            nvl(order_type_id, FND_PROFILE.value('CSP_ORDER_TYPE')),
            ship_to_location_id,
            need_by_date,
            destination_organization_id,
            destination_subinventory
          INTO
            l_header_rec.requirement_header_id,
            l_header_rec.order_type_id,
            l_header_Rec.ship_to_location_id,
            l_header_rec.need_by_Date,
            l_header_rec.dest_organization_id,
            l_header_rec.dest_subinventory
          FROM csp_Requirement_headers
          WHERE requirement_header_id = p_header_id;

          l_header_Rec.operation := G_OPR_CREATE;

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                            'Part Req Header Data... '
                            || 'l_header_rec.requirement_header_id = ' || l_header_rec.requirement_header_id
                            || ', l_header_rec.order_type_id = ' || l_header_rec.order_type_id
                            || ', l_header_Rec.ship_to_location_id = ' || l_header_Rec.ship_to_location_id
                            || ', l_header_rec.need_by_Date = ' || l_header_rec.need_by_Date
                            || ', l_header_rec.dest_organization_id = ' || l_header_rec.dest_organization_id
                            || ', l_header_rec.dest_subinventory = ' || l_header_rec.dest_subinventory
                            || ', l_header_Rec.operation = ' || l_header_Rec.operation);
          end if;

        EXCEPTION
          WHEN no_data_found THEN
              fnd_message.set_name('CSP', 'CSP_INVALID_REQUIREMENT_HEADER');
              fnd_message.set_token('HEADER_ID', to_char(p_header_id), FALSE);
              FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
        END;

        OPEN rqmt_line_cur;
        I := 1;
        J := 1;
        LOOP
          FETCH rqmt_line_cur
            INTO l_line_rec.requirement_line_id,
                 l_line_rec.inventory_item_id,
                 l_line_Rec.revision,
                 l_line_rec.unit_of_measure,
                 l_line_rec.quantity,
                 l_line_rec.sourced_from,
                 l_line_rec.source_organization_id,
                 l_line_rec.source_subinventory,
                 l_line_rec.shipping_method_code,
                 l_line_rec.arrival_Date ;

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                            'Part Req Line Data... '
                            || 'l_line_rec.requirement_line_id = ' || l_line_rec.requirement_line_id
                            || ', l_line_rec.inventory_item_id = ' || l_line_rec.inventory_item_id
                            || ', l_line_Rec.revision = ' || l_line_Rec.revision
                            || ', l_line_rec.unit_of_measure = ' || l_line_rec.unit_of_measure
                            || ', l_line_rec.quantity = ' || l_line_rec.quantity
                            || ', l_line_rec.sourced_from = ' || l_line_rec.sourced_from
                            || ', l_line_rec.source_organization_id = ' || l_line_rec.source_organization_id
                            || ', l_line_rec.source_subinventory = ' || l_line_rec.source_subinventory
                            || ', l_line_rec.shipping_method_code = ' || l_line_rec.shipping_method_code
                            || ', l_line_rec.arrival_Date = ' || l_line_rec.arrival_Date);
          end if;

          EXIT WHEN rqmt_line_cur%NOTFOUND;
          IF (l_line_rec.sourced_From = 'IO' and l_line_rec.source_organization_id IS NULL) THEN
            fnd_message.set_name('CSP', 'CSP_NULL_SRC_ORGN');
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
          END If;
          l_line_rec.ordered_quantity := l_line_Rec.quantity;
          IF (l_line_rec.sourced_from = 'IO') THEN
            l_line_rec.line_num := I;
            l_oe_line_tbl(I) := l_line_rec;
            I := I + 1;
          ELSIF (l_line_Rec.sourced_From = 'POREQ') THEN
            l_line_Rec.line_num := J;
            l_po_line_Tbl(J) := l_line_rec;
            J := J + 1;
          END IF;
        END LOOP;

        IF (l_oe_line_tbl.COUNT > 0) THEN
          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                            'Calling csp_parts_order.process_order...');
          end if;
          csp_parts_order.process_order(
              p_api_version             => l_api_version_number
             ,p_Init_Msg_List           => p_init_msg_list
             ,p_commit                  => FND_API.G_FALSE
             ,px_header_rec             => l_header_rec
             ,px_line_table             => l_oe_line_tbl
             ,x_return_status           => l_return_status
             ,x_msg_count               => l_msg_count
             ,x_msg_data                => l_msg_data
          );
          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                            'csp_parts_order.process_order return status = ' || l_return_status);
          end if;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            -- update open_requirement_flag on requirement header
            BEGIN
              l_open_requirement := 'S';
              update csp_requirement_headers
              set open_requirement = 'S'
              where requirement_header_id = p_header_id;
            EXCEPTION
              when others then
                null;
            END;
            IF (l_header_rec.order_header_id IS NOT NULL) THEN
            BEGIN
              SELECT order_number
              INTO l_order_number
              FROM OE_ORDER_HEADERS_ALL
              WHERE header_id = l_header_Rec.order_header_id;

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                                'l_order_number = ' || l_order_number);
              end if;
            EXCEPTION
              when no_data_found then
                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                                  'No Data Found for l_header_rec.order_header_id = '
                                  || l_header_rec.order_header_id || ' in OE_ORDER_HEADERS_ALL');
                end if;
                null;
            END;
            END IF;

            x_order_tbl(1).source_type := 'IO';
            x_order_tbl(1).order_number := l_order_number;
            -- x_order_tbl(1).line_tbl := l_oe_line_tbl;

            -- update csp_requirement_line table with order information
            FOR I IN 1..l_oe_line_tbl.COUNT LOOP
              l_line_rec := l_oe_line_tbl(I);

              SELECT csp_req_line_Details_s1.nextval
              INTO l_req_line_Dtl_id
              FROM dual;

              csp_req_line_Details_pkg.Insert_Row(
                px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                p_REQUIREMENT_LINE_ID   =>  l_line_rec.requirement_line_id,
                p_CREATED_BY            =>  nvl(l_user_id, 1),
                p_CREATION_DATE         =>  sysdate,
                p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                p_LAST_UPDATE_DATE      =>  sysdate,
                p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                p_SOURCE_TYPE           =>  'IO',
                p_SOURCE_ID             =>  l_line_rec.order_line_id);
            END LOOP;
           END IF;
         END IF;

        -- create purchase requisitions if po_line_tbl has atleast one record
         IF (l_po_line_tbl.count > 0) THEN

          l_header_rec.requisition_header_id := null;
          l_header_rec.requisition_number := null;

          csp_parts_order.process_purchase_req(
             p_api_version      => l_api_version_number
            ,p_init_msg_list    => p_init_msg_list
            ,p_commit           => p_commit
            ,px_header_rec      => l_header_Rec
            ,px_line_Table      => l_po_line_tbl
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            IF (nvl(l_open_requirement, 'W') <> 'S') THEN
              update csp_requirement_headers
              set open_requirement = 'S'
              where requirement_header_id = p_header_id;
            END IF;

            x_order_tbl(2).source_type := 'POREQ';
            x_order_tbl(2).order_number := l_header_rec.requisition_number;
            -- x_order_tbl(2).line_tbl := l_po_line_tbl;

            -- insert into csp_req_line_Details table with purchase req information
             FOR I IN 1..l_po_line_tbl.COUNT LOOP
               l_line_rec := l_po_line_tbl(I);

               SELECT csp_req_line_Details_s1.nextval
               INTO l_req_line_Dtl_id
               FROM dual;

               csp_req_line_Details_pkg.Insert_Row(
                 px_REQ_LINE_DETAIL_ID   =>  l_Req_line_Dtl_id,
                 p_REQUIREMENT_LINE_ID   =>  l_line_rec.requirement_line_id,
                 p_CREATED_BY            =>  nvl(l_user_id, 1),
                 p_CREATION_DATE         =>  sysdate,
                 p_LAST_UPDATED_BY       =>  nvl(l_user_id, 1),
                 p_LAST_UPDATE_DATE      =>  sysdate,
                 p_LAST_UPDATE_LOGIN     =>  nvl(l_login_id, -1),
                 p_SOURCE_TYPE           =>  'POREQ',
                 p_SOURCE_ID             =>  l_line_rec.requisition_line_id);
            END LOOP;
          END IF;
        END IF;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF fnd_api.to_boolean(p_commit) THEN
           commit work;
      END IF;
    END If;
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_PARTS_REQUIREMENT.create_order',
                      'Returning from csp.plsql.CSP_PARTS_REQUIREMENT.create_order with return status = '
                      || x_return_status);
    end if;
  EXCEPTION
    WHEN EXCP_USER_DEFINED THEN
        Rollback to create_order_PUB;
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
      Rollback to create_order_PUB;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE TASK_ASSIGNMENT_POST_UPDATE(x_return_status out nocopy varchar2)IS
  l_task_assignment_id  NUMBER;
  l_resource_id         NUMBER;
  l_resource_type_code  VARCHAR2(30);
  l_rqmt_header_id      NUMBER;
  l_ship_to_location_id NUMBER;
  l_organization_id     NUMBER;
  l_subinventory_code   VARCHAR2(30);

  CURSOR get_rqmt_Header IS
    SELECT requirement_header_id, address_type, destination_organization_id, destination_subinventory
    FROM csp_requirement_headers
    WHERE task_assignment_id = l_Task_Assignment_id;

  CURSOR get_resource_location IS
    SELECT csp.ship_to_location_id
    FROM csp_rs_ship_to_addresses_all_v csp,
      hz_cust_acct_sites_All hz,
      cs_incidents_all_b cs,
      jtf_tasks_b jtb,
      jtf_task_assignments jta
    WHERE csp.cust_acct_site_id     = hz.cust_acct_site_id
    AND csp.resource_id             = jta.resource_id
    AND csp.resource_type           = jta.resource_type_code
    AND primary_flag                = 'Y'
    AND hz.org_id                   = cs.org_id
    AND jta.task_assignment_id      = l_Task_Assignment_id
    AND jta.task_id                 = jtb.task_id
    AND jtb.source_object_type_code = 'SR'
    AND jtb.source_object_id        = cs.incident_id
    AND csp.resource_id             = l_resource_id
    AND csp.resource_type           = l_resource_type_code;

  CURSOR get_Resource_org_sub IS
    SELECT organization_id, subinventory_code
    FROM csp_inv_loc_assignments
    WHERE resource_id = l_resource_id
    AND resource_type = l_resource_type_code
    AND default_code = 'IN';

  l_ship_to_type  varchar2(1);
  l_dummy number;
  EXCP_USER_DEFINED        EXCEPTION;
  l_source_type   varchar2(10);
  l_source_id number;
  l_req_line_dtl_id number;
  x_msg_data varchar2(4000);
  x_msg_count number;
  l_assignment_status_id number := -999;
  l_assg_sts_flag varchar2(1);
  l_o_assg_sts_flag varchar2(1);
  l_oe_header_id number := -999;
  l_oe_order_num varchar2(100) := NULL;
  l_assignee_role VARCHAR2(10);
  l_is_cancelled varchar2(1);
  l_old_dest_OU number;
  l_new_dest_OU number;
  l_dest_org_id number;
  l_dest_subinv varchar2(30);
  l_res_same_org number;
  l_resource_name varchar2(1000);
  l_resource_type_name varchar2(1000);
  l_task_id number;


  CURSOR check_IO_booked IS
    select head.requirement_header_id, count(dtl.source_type)
    from
      csp_requirement_headers head,
      csp_requirement_lines line,
      csp_req_line_details dtl,
      oe_order_lines_all oel
    where
      head.task_assignment_id = l_Task_Assignment_id
      and head.requirement_header_id = line.requirement_header_id
      and line.requirement_line_id = dtl.requirement_line_id
      and dtl.source_type = 'IO'
      and dtl.source_id = oel.line_id
      and oel.booked_flag = 'Y'
    group by head.requirement_header_id;

  CURSOR get_req_line_dtl(v_req_header_id number) is
    select dtl.req_line_detail_id, dtl.source_id, dtl.source_type
    from
      csp_requirement_headers head,
      csp_requirement_lines line,
      csp_req_line_details dtl
    where
      head.requirement_header_id = v_req_header_id
      and head.requirement_header_id = line.requirement_header_id
      and line.requirement_line_id = dtl.requirement_line_id;

    cursor get_task_asg_sts_id is
    select assignment_status_id
    from jtf_task_assignments
    where task_assignment_id = l_task_assignment_id;

    cursor get_order_header_id is
    SELECT oel.header_id
    FROM jtf_task_assignments jta,
      csp_requirement_headers ch,
      csp_requirement_lines cl,
      csp_req_line_details cld,
      oe_order_lines_all oel
    WHERE jta.task_assignment_id = l_task_assignment_id
    AND ch.task_assignment_id  = jta.task_assignment_id
    AND ch.task_id               = jta.task_id
    AND ch.requirement_header_id = cl.requirement_header_id
    AND cl.requirement_line_id   = cld.requirement_line_id
    AND cld.source_type          = 'IO'
    AND cld.source_id            = oel.line_id
    AND oel.booked_flag          = 'N'
    AND oel.cancelled_flag       = 'N'
    AND oel.open_flag            = 'Y';

	l_sch_option CSP_SCH_INT_PVT.csp_sch_options_rec_typ;
	l_booking_start_date date;
	l_partial_line number;
	l_fl_rcvd_lines number;
	l_fl_rcvd_multi_source number;
	l_oth_req_line number;
	l_non_src_line number;
	l_shpd_lines number;
	l_tech_spec_pr number;
	l_ship_multi_src number;
	l_dest_ou number;
	l_rs_ou number;
	l_module varchar2(100) := 'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE';
	l_requirement_header      CSP_Requirement_Headers_PVT.REQUIREMENT_HEADER_Rec_Type;
	l_order_number varchar2(100);
	l_dest_org_name varchar2(240);

	cursor c_parts_req (v_task_id number, v_task_assignment_id number) is
	select requirement_header_id
	from csp_requirement_headers
	where task_id = v_task_id
	and task_assignment_id = v_task_assignment_id;

	cursor get_rs_ou(v_rs_type varchar2, v_rs_id number) is
	SELECT csp.organization_id
	FROM CSP_RS_SUBINVENTORIES_V csp
	WHERE csp.resource_type = v_rs_type
	AND csp.resource_id     = v_rs_id
	AND csp.condition_type  = 'G'
	AND csp.default_flag    = 'Y';

	cursor get_non_src_req is
	SELECT h.requirement_header_id,
	  h.address_type
	FROM csp_requirement_headers h,
	  csp_requirement_lines l
	WHERE h.task_id             = l_task_id
	AND h.task_assignment_id    = l_task_assignment_id
	AND l.requirement_header_id = h.requirement_header_id
	AND (SELECT COUNT(d.source_id)
	  FROM csp_req_line_details d
	  WHERE d.requirement_line_id = l.requirement_line_id) = 0;

  BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'Begin');
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                      'l_task_assignment_id = ' || l_task_assignment_id
                      || ', l_resource_id = ' || l_resource_id
                      || ', l_resource_type_code = ' || l_resource_type_code
                      || ', l_rqmt_header_id = ' || l_rqmt_header_id
                      || ', l_ship_to_location_id = ' || l_ship_to_location_id
                      || ', l_organization_id = ' || l_organization_id
                      || ', l_subinventory_code = ' || l_subinventory_code);
    end if;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
    l_resource_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_id;
    l_resource_type_code := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_type_code;
    l_assignee_role := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.assignee_role;
	l_task_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_id;
	l_booking_start_date := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.booking_start_date;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                      'l_task_assignment_id = ' || l_task_assignment_id
					  || ', l_task_id =' || l_task_id
                      || ', l_resource_id = ' || l_resource_id
                      || ', l_resource_type_code = ' || l_resource_type_code
					  || ', l_booking_start_date = ' || to_char(l_booking_start_date, 'dd-mon-yyyy hh24:mi:ss')
                      || ', l_assignee_role = ' || l_assignee_role
                      || ', G_old_resource_id = ' || G_old_resource_id);
    end if;

	l_oth_req_line := 0;
	SELECT COUNT(l.requirement_line_id)
	INTO l_oth_req_line
	FROM csp_requirement_headers h,
	  csp_requirement_lines l
	WHERE h.task_id             = l_task_id
	AND h.task_assignment_id    = l_task_assignment_id
	AND h.requirement_header_id = l.requirement_header_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                      'l_oth_req_line = ' || l_oth_req_line);
    end if;

	if l_oth_req_line = 0 then
		return;
	end if;

    if l_assignee_role = 'ASSIGNEE' then
        IF (l_Resource_id is not null and G_old_resource_id is not null and
            l_Resource_id <> G_old_resource_id)THEN

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                              'checking for re-assignment case...');
            end if;

          OPEN get_Resource_org_sub;
          FETCH get_resource_org_sub INTO l_organization_id, l_subinventory_code;
          CLOSE get_resource_org_sub;

          OPEN get_resource_location;
          FETCH get_resource_location INTO l_ship_to_location_id;
          CLOSE get_resource_location;

          /*
		  open check_IO_booked;
          loop
            fetch check_IO_booked into l_rqmt_header_id, l_dummy;
            exit when check_IO_booked%NOTFOUND;

            if l_dummy > 0 then
              FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASGN_ORDER_MSG');
              FND_MESSAGE.SET_TOKEN('REQ_NUM', l_rqmt_header_id, TRUE);
              FND_MSG_PUB.ADD;
              raise EXCP_USER_DEFINED;
            end if;
          end loop;
          close check_IO_booked;

          savepoint csp_correct_req_record;
          OPEN get_rqmt_header;
          LOOP
            FETCH get_rqmt_Header INTO l_rqmt_header_id, l_ship_to_type, l_dest_org_id, l_dest_subinv;
            EXIT WHEN get_rqmt_Header%NOTFOUND;

            IF l_rqmt_header_id IS NOT NULL THEN

              -- clean reservations and remove cancelled IO links
              open get_req_line_dtl(l_rqmt_header_id);
              loop
                fetch get_req_line_dtl into l_req_line_dtl_id, l_source_id, l_source_type;
                exit when get_req_line_dtl%NOTFOUND;

                if l_source_type = 'IO' then


				  select nvl(cancelled_flag, 'N')
                  into l_is_cancelled
                  from oe_order_lines_all
                  where line_id = l_source_id;

                  if l_is_cancelled = 'N' then  -- entered status
                    -- check ship to type
                    if l_ship_to_type = 'R' or l_ship_to_type = 'S' then
                        -- raise an error message
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASGN_SHIP_MSG');
                        FND_MESSAGE.SET_TOKEN('REQ_NUM', l_rqmt_header_id, TRUE);
                        FND_MSG_PUB.ADD;
                        raise EXCP_USER_DEFINED;
                    end if;

                    -- check new and old INV org in same OU
                    SELECT operating_unit
                    INTO l_old_dest_OU
                    FROM org_organization_Definitions
                    WHERE organization_id = l_dest_org_id;

                    if l_organization_id is null or l_subinventory_code is null then
                        SELECT NAME
                        INTO l_resource_type_name
                        FROM JTF_OBJECTS_VL
                        WHERE OBJECT_CODE = l_resource_type_code;

                        l_resource_name := csp_pick_utils.get_object_name(l_resource_type_code, l_resource_id);

                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DEFAULT_SUBINV');
                        FND_MESSAGE.SET_TOKEN('RESOURCE_TYPE', l_resource_type_name, TRUE);
                        FND_MESSAGE.SET_TOKEN('RESOURCE_NAME', l_resource_name, TRUE);
                        FND_MSG_PUB.ADD;
                        raise EXCP_USER_DEFINED;
                    end if;

                    SELECT operating_unit
                    INTO l_new_dest_OU
                    FROM org_organization_Definitions
                    WHERE organization_id = l_organization_id;

                    if l_old_dest_OU <> l_new_dest_OU then
                        -- raise an error message
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASGN_OU_MSG');
                        FND_MESSAGE.SET_TOKEN('REQ_NUM', l_rqmt_header_id, TRUE);
                        FND_MSG_PUB.ADD;
                        raise EXCP_USER_DEFINED;
                    end if;

                    UPDATE po_requisition_lines_all
                    SET destination_subinventory  = l_subinventory_code,
                      destination_organization_id = l_organization_id
                    WHERE requisition_line_id     =
                      (SELECT source_document_line_id
                      FROM oe_order_lines_all
                      WHERE line_id = l_source_id);

                  else
                    CSP_REQ_LINE_DETAILS_PKG.Delete_Row(l_req_line_dtl_id);
                  end if;   -- if l_is_cancelled = 'N' then  -- entered status


                elsif l_source_type = 'RES' then

                    -- check if the reservation is under same dest org then remove it
                    -- otherwise leave it

                    SELECT count(*)
                    into l_res_same_org
                    FROM mtl_reservations
                    WHERE reservation_id  = l_source_id
                    AND organization_id   = l_dest_org_id
                    AND subinventory_code = l_dest_subinv;

                    if l_res_same_org > 0 then
                        CSP_SCH_INT_PVT.CANCEL_RESERVATION(l_source_id, x_return_status, x_msg_data, x_msg_count);
                        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                            rollback to csp_correct_req_record;
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_MAN_NOT_CANCEL_RESERV');
                            FND_MESSAGE.SET_TOKEN('REQ_NUM', l_rqmt_header_id, TRUE);
                            FND_MSG_PUB.ADD;
                            raise EXCP_USER_DEFINED;
                        else
                            CSP_REQ_LINE_DETAILS_PKG.Delete_Row(l_req_line_dtl_id);
                        end if;

						-- we need to source the part for the new tech
						l_sch_option.resource_id := l_resource_id;
						l_sch_option.resource_type := l_resource_type_code;
						l_sch_option.start_time := l_booking_start_date;
						l_sch_option.transfer_cost := 9999999; --- this should be a high number to avoid cost check in choose option

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
						  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
										  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
										  'before calling CSP_SCH_INT_PVT.CHOOSE_OPTION...');
						end if;
						CSP_SCH_INT_PVT.CHOOSE_OPTION(
							p_api_version_number => 1.0,
							p_task_id => l_task_id,
							p_task_assignment_id => l_task_assignment_id,
							p_likelihood => 0,
							p_mandatory => true,
							p_trunk => true,
							p_warehouse => false,
							p_options => l_sch_option,
							x_return_status => x_return_status,
							x_msg_data => x_msg_data,
							x_msg_count => x_msg_count
						);
						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
						  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
										  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
										  'after calling CSP_SCH_INT_PVT.CHOOSE_OPTION...x_return_status=' || x_return_status);
						end if;

						if x_return_status <> FND_API.G_RET_STS_SUCCESS then
							-- now try to find the part in warehouse
							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
											  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
											  'before calling CSP_SCH_INT_PVT.CHOOSE_OPTION...');
							end if;
							CSP_SCH_INT_PVT.CHOOSE_OPTION(
								p_api_version_number => 1.0,
								p_task_id => l_task_id,
								p_task_assignment_id => l_task_assignment_id,
								p_likelihood => 0,
								p_mandatory => true,
								p_trunk => false,
								p_warehouse => true,
								p_options => l_sch_option,
								x_return_status => x_return_status,
								x_msg_data => x_msg_data,
								x_msg_count => x_msg_count
							);
							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
											  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
											  'after calling CSP_SCH_INT_PVT.CHOOSE_OPTION...x_return_status=' || x_return_status);
							end if;
							if x_return_status <> FND_API.G_RET_STS_SUCCESS then
								rollback to csp_correct_req_record;
								raise EXCP_USER_DEFINED;
							else
								return;		-- early exit
							end if;
						else
							return;			-- early exit
						end if;
                    end if;

                end if; -- if l_source_type = 'IO' then

              end loop;
              close get_req_line_dtl;

              UPDATE csp_requirement_headers
              SET task_assignment_id = l_task_assignment_id,
                  ship_to_location_id = decode(l_ship_to_type, 'C', ship_to_location_id, 'T', ship_to_location_id, l_ship_to_location_id),
                  destination_organization_id = l_organization_id,
                  destination_subinventory = l_subinventory_code,
                  resource_type = l_resource_type_code,
                  resource_id = l_resource_id,
                  address_type = decode(l_ship_to_type, 'S', 'R', l_ship_to_type)
              WHERE requirement_header_id = l_rqmt_header_id;
            END IF;
          END LOOP;
          CLOSE get_rqmt_header;
		  */

			-- check if the requirement is without any details
			l_rqmt_header_id := 0;
			open get_non_src_req;
			fetch get_non_src_req into l_rqmt_header_id, l_ship_to_type;
			close get_non_src_req;

			if l_rqmt_header_id <> 0 then
				UPDATE csp_requirement_headers
				SET task_assignment_id = l_task_assignment_id,
				  ship_to_location_id = decode(l_ship_to_type, 'C', ship_to_location_id, 'T', ship_to_location_id, l_ship_to_location_id),
				  destination_organization_id = l_organization_id,
				  destination_subinventory = l_subinventory_code,
				  resource_type = l_resource_type_code,
				  resource_id = l_resource_id,
				  address_type = decode(l_ship_to_type, 'S', 'R', l_ship_to_type),
				  ship_to_contact_id = decode(l_ship_to_type, 'C', ship_to_contact_id, 'T', ship_to_contact_id, null)
				WHERE requirement_header_id = l_rqmt_header_id;
				return;
			end if;

			-- check if we need to source the item and schedule dates are already in past
			-- then stop reassignment
			if l_booking_start_date is null or l_booking_start_date <= sysdate then
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DATE_PST_ASSGN');
				FND_MSG_PUB.ADD;
				fnd_msg_pub.count_and_get
						( p_count => x_msg_count
						, p_data  => x_msg_data);
				return;
			end if;


			-- first check for the partial received order line status
			l_partial_line := 0;
			SELECT count(l.requirement_line_id)
			into l_partial_line
			FROM csp_requirement_headers h,
			  csp_requirement_lines l,
			  csp_req_line_details d,
			  oe_order_lines_all oola
			WHERE h.task_id             = l_task_id
			AND h.task_assignment_id    = l_Task_Assignment_id
			AND h.requirement_header_id = l.requirement_header_id
			AND l.requirement_line_id   = d.requirement_line_id
			and d.source_type          = 'IO'
			AND d.source_id = oola.line_id
			AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code) = 'PARTIALLY RECEIVED';

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'l_partial_line = ' || l_partial_line);
			end if;

			if l_partial_line > 0 then
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
				FND_MSG_PUB.ADD;
				fnd_msg_pub.count_and_get
						( p_count => x_msg_count
						, p_data  => x_msg_data);
				return;
			end if;

			-- bug # 14182971
			-- block rescheduling if part is already received for Tech or Special
			-- ship to address type
			l_fl_rcvd_lines := 0;
			SELECT COUNT(l.requirement_line_id)
			into l_fl_rcvd_lines
			FROM csp_requirement_headers h,
			  csp_requirement_lines l,
			  csp_req_line_details dio,
			  csp_req_line_details dres,
			  oe_order_lines_all oola,
			  mtl_reservations mr
			WHERE h.task_id             = l_task_id
			AND h.task_assignment_id    = l_Task_Assignment_id
			AND h.address_type         IN ('R', 'S')
			AND h.requirement_header_id = l.requirement_header_id
			AND l.requirement_line_id   = dio.requirement_line_id
			AND dio.source_type        = 'IO'
			and dio.source_id = oola.line_id
			AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        = 'FULLY RECEIVED'
			AND dio.requirement_line_id = dres.requirement_line_id
			AND oola.inventory_item_id    = mr.inventory_item_id
			AND oola.ordered_quantity   = mr.reservation_quantity
			AND dres.source_type       = 'RES'
			AND dres.source_id = mr.reservation_id;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'l_fl_rcvd_lines (R or S) = ' || l_fl_rcvd_lines);
			end if;

			if l_fl_rcvd_lines > 0 then
				SELECT ooha.order_number
				into l_order_number
				FROM csp_requirement_headers h,
				  csp_requirement_lines l,
				  csp_req_line_details dio,
				  oe_order_lines_all oola,
				  oe_order_headers_all ooha
				WHERE h.task_id             = l_task_id
				AND h.task_assignment_id    = l_Task_Assignment_id
				AND h.address_type         IN ('R', 'S')
				AND h.requirement_header_id = l.requirement_header_id
				AND l.requirement_line_id   = dio.requirement_line_id
				AND dio.source_type        = 'IO'
				and dio.source_id = oola.line_id
				and oola.header_id = ooha.header_id
				AND rownum                  = 1;

				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASSGN_NO_IO_CAN');
				FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_order_number, FALSE);
				FND_MSG_PUB.ADD;
				fnd_msg_pub.count_and_get
						( p_count => x_msg_count
						, p_data  => x_msg_data);
				return;
			end if;

			-- for fully rcvd case
			l_fl_rcvd_lines := 0;
			SELECT COUNT(l.requirement_line_id)
			into l_fl_rcvd_lines
			FROM csp_requirement_headers h,
			  csp_requirement_lines l,
			  csp_req_line_details dio,
			  csp_req_line_details dres,
			  oe_order_lines_all oola,
			  mtl_reservations mr
			WHERE h.task_id             = l_task_id
			AND h.task_assignment_id    = l_Task_Assignment_id
			AND h.address_type         IN ('T', 'C', 'P')
			AND h.requirement_header_id = l.requirement_header_id
			AND l.requirement_line_id   = dio.requirement_line_id
			AND dio.source_type        = 'IO'
			AND dio.source_id = oola.line_id
			AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
			AND dio.requirement_line_id = dres.requirement_line_id
			AND oola.inventory_item_id    = mr.inventory_item_id
			AND oola.ordered_quantity   = mr.reservation_quantity
			AND dres.source_type       = 'RES'
			AND dres.source_id = mr.reservation_id;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'l_fl_rcvd_lines = ' || l_fl_rcvd_lines);
			end if;

			if l_fl_rcvd_lines > 0 then

				-- get fully received lines for task and customer ship to case
				l_fl_rcvd_multi_source := 0;
				SELECT COUNT(l.requirement_line_id)
				into l_fl_rcvd_multi_source
				FROM csp_requirement_headers h,
				  csp_requirement_lines l,
				  csp_req_line_details dio,
				  csp_req_line_details dres,
				  csp_req_line_details dother,
				  oe_order_lines_all oola,
				  mtl_reservations mr
				WHERE h.task_id             = l_task_id
				AND h.task_assignment_id    = l_Task_Assignment_id
				AND h.address_type         IN ('T', 'C', 'P')
				AND h.requirement_header_id = l.requirement_header_id
				AND l.requirement_line_id   = dio.requirement_line_id
				AND dio.source_type        = 'IO'
				AND dio.source_id = oola.line_id
				AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
				AND dio.requirement_line_id = dres.requirement_line_id
				AND oola.inventory_item_id    = mr.inventory_item_id
				AND oola.ordered_quantity   = mr.reservation_quantity
				AND dres.source_type       = 'RES'
				AND dres.source_id = mr.reservation_id
				AND l.requirement_line_id   = dother.requirement_line_id
				AND dother.source_id       <> dio.source_id
				AND dother.source_id       <> dres.source_id;

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'l_fl_rcvd_multi_source = ' || l_fl_rcvd_multi_source);
				end if;

				if l_fl_rcvd_multi_source > 0 then
					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
					FND_MSG_PUB.ADD;
					fnd_msg_pub.count_and_get
							( p_count => x_msg_count
							, p_data  => x_msg_data);
					return;
				end if;

				-- check if any other req line sourced
				l_oth_req_line := 0;
				SELECT COUNT(requirement_line_id)
				into l_oth_req_line
				FROM
				  (SELECT l.requirement_line_id
				  FROM csp_requirement_headers h,
					csp_requirement_lines l,
					csp_req_line_details d
				  WHERE h.task_id             = l_task_id
				  AND h.task_assignment_id    = l_Task_Assignment_id
				  AND h.requirement_header_id = l.requirement_header_id
				  AND h.address_type         IN ('T', 'C', 'P')
				  AND l.requirement_line_id   = d.requirement_line_id
				  MINUS
				  SELECT l.requirement_line_id
				  FROM csp_requirement_headers h,
					csp_requirement_lines l,
					csp_req_line_details dio,
					csp_req_line_details dres,
					oe_order_lines_all oola,
					mtl_reservations mr
				  WHERE h.task_id             = l_task_id
				  AND h.task_assignment_id    = l_Task_Assignment_id
				  AND h.address_type         IN ('T', 'C', 'P')
				  AND h.requirement_header_id = l.requirement_header_id
				  AND l.requirement_line_id   = dio.requirement_line_id
				  AND dio.source_type        = 'IO'
				  AND dio.source_id = oola.line_id
				  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
				  AND dio.requirement_line_id = dres.requirement_line_id
				  AND oola.inventory_item_id    = mr.inventory_item_id
				  AND oola.ordered_quantity   = mr.reservation_quantity
				  AND dres.source_type       = 'RES'
				  AND dres.source_id = mr.reservation_id
				  );

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'l_oth_req_line = ' || l_oth_req_line);
				end if;

				if l_oth_req_line > 0 then
					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
					FND_MSG_PUB.ADD;
					fnd_msg_pub.count_and_get
							( p_count => x_msg_count
							, p_data  => x_msg_data);
					return;
				end if;

				--check if there is any not sourced line
				l_non_src_line := 0;
				SELECT COUNT(requirement_line_id)
				into l_non_src_line
				FROM
				  (SELECT l.requirement_line_id
				  FROM csp_requirement_headers h,
					csp_requirement_lines l
				  WHERE h.task_id             = l_task_id
				  AND h.task_assignment_id    = l_Task_Assignment_id
				  AND h.requirement_header_id = l.requirement_header_id
				  AND h.address_type         IN ('T', 'C', 'P')
				  AND (SELECT COUNT (d.requirement_line_id)
					FROM csp_req_line_details d
					WHERE d.requirement_line_id = l.requirement_line_id) = 0
				  MINUS
				  SELECT l.requirement_line_id
				  FROM csp_requirement_headers h,
					csp_requirement_lines l,
					csp_req_line_details dio,
					csp_req_line_details dres,
					oe_order_lines_all oola,
					mtl_reservations mr
				  WHERE h.task_id             = l_task_id
				  AND h.task_assignment_id    = l_Task_Assignment_id
				  AND h.address_type         IN ('T', 'C', 'P')
				  AND h.requirement_header_id = l.requirement_header_id
				  AND l.requirement_line_id   = dio.requirement_line_id
				  AND dio.source_type        = 'IO'
				  AND dio.source_id = oola.line_id
				  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
				  AND dio.requirement_line_id = dres.requirement_line_id
				  AND oola.inventory_item_id    = mr.inventory_item_id
				  AND oola.ordered_quantity   = mr.reservation_quantity
				  AND dres.source_type       = 'RES'
				  AND dres.source_id = mr.reservation_id
				  );

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'l_non_src_line = ' || l_non_src_line);
				end if;

				if l_non_src_line = 0 then
					-- if we are here that means all the lines source have been
					-- already recived
					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'before calling move_parts_on_reassign...');
					end if;
					CSP_SCH_INT_PVT.move_parts_on_reassign(
						p_task_id => l_task_id,
						p_task_asgn_id => l_Task_Assignment_id,
						p_new_task_asgn_id => l_Task_Assignment_id,
						p_new_need_by_date => l_booking_start_date,
						p_new_resource_id => l_resource_id,
						p_new_resource_type => l_resource_type_code,
						x_return_status => x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data
					);
					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'after calling move_parts_on_reassign...x_return_status=' || x_return_status);
					end if;
					if x_return_status <> FND_API.G_RET_STS_SUCCESS then
						x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
						FND_MSG_PUB.ADD;
						fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
					end if;
					return;
				end if;
			end if;

			-- now check for shipped lines
			l_shpd_lines := 0;
			SELECT COUNT(l.requirement_line_id)
			into l_shpd_lines
			FROM csp_requirement_headers h,
			  csp_requirement_lines l,
			  csp_req_line_details d,
			  oe_order_lines_all oola
			WHERE h.task_id             = l_task_id
			AND h.task_assignment_id    = l_Task_Assignment_id
			AND h.requirement_header_id = l.requirement_header_id
			AND l.requirement_line_id   = d.requirement_line_id
			AND d.source_type          = 'IO'
			AND d.source_id = oola.line_id
			AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)           in ('SHIPPED', 'EXPECTED');

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'l_shpd_lines = ' || l_shpd_lines);
			end if;

			if l_shpd_lines > 0 then
				l_tech_spec_pr := 0;
				SELECT count(h.address_type)
				into l_tech_spec_pr
				FROM csp_requirement_headers h
				WHERE h.task_id          = l_task_id
				AND h.task_assignment_id = l_Task_Assignment_id
				AND h.address_type      IN ('R', 'S');

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'l_tech_spec_pr = ' || l_tech_spec_pr);
				end if;

				if l_tech_spec_pr > 0 then
					SELECT ooha.order_number
					INTO l_order_number
					FROM csp_requirement_headers h,
					  csp_requirement_lines l,
					  csp_req_line_details d,
					  oe_order_lines_all oola,
					  oe_order_headers_all ooha
					WHERE h.task_assignment_id  = l_Task_Assignment_id
					AND h.task_id               = l_task_id
					AND h.requirement_header_id = l.requirement_header_id
					AND l.requirement_line_id   = d.requirement_line_id
					AND d.source_type          = 'IO'
					AND d.source_id = oola.line_id
					AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         IN ('SHIPPED', 'EXPECTED')
					AND oola.header_id = ooha.header_id
					AND rownum                  = 1;

					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASSGN_NO_IO_CAN');
					FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_order_number, FALSE);
					FND_MSG_PUB.ADD;
					fnd_msg_pub.count_and_get
							( p_count => x_msg_count
							, p_data  => x_msg_data);
					return;
				else
					-- now check for same line multiple IO case
					l_ship_multi_src := 0;
					SELECT COUNT(l.requirement_line_id)
					into l_ship_multi_src
					FROM csp_requirement_headers h,
					  csp_requirement_lines l,
					  csp_req_line_details d,
					  csp_req_line_details dother,
					  oe_order_lines_all oola
					WHERE h.task_id                = l_task_id
					AND h.task_assignment_id       = l_Task_Assignment_id
					AND h.requirement_header_id    = l.requirement_header_id
					AND l.requirement_line_id      = d.requirement_line_id
					AND h.address_type         IN ('T', 'C', 'P')
					AND d.source_type             = 'IO'
					AND d.source_id = oola.line_id
					AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)             in ('SHIPPED', 'EXPECTED')
					AND dother.requirement_line_id = l.requirement_line_id
					AND dother.source_id          <> d.source_id;

					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'l_ship_multi_src = ' || l_ship_multi_src);
					end if;

					if l_ship_multi_src > 0 then
						x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
						FND_MSG_PUB.ADD;
						fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
						return;
					end if;

					-- check of other source line
					l_oth_req_line := 0;
					SELECT COUNT(requirement_line_id)
					into l_oth_req_line
					FROM
					  (SELECT l.requirement_line_id
					  FROM csp_requirement_headers h,
						csp_requirement_lines l,
						csp_req_line_details d
					  WHERE h.task_id             = l_task_id
					  AND h.task_assignment_id    = l_Task_Assignment_id
					  AND h.requirement_header_id = l.requirement_header_id
					  AND l.requirement_line_id   = d.requirement_line_id
					  MINUS
					  SELECT l.requirement_line_id
					  FROM csp_requirement_headers h,
						csp_requirement_lines l,
						csp_req_line_details d,
						oe_order_lines_all oola
					  WHERE h.task_id             = l_task_id
					  AND h.task_assignment_id    = l_Task_Assignment_id
					  AND h.requirement_header_id = l.requirement_header_id
					  AND l.requirement_line_id   = d.requirement_line_id
					  AND d.source_type          = 'IO'
					  AND d.source_id = oola.line_id
					  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        in ('SHIPPED', 'EXPECTED')
					  );

					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'l_oth_req_line = ' || l_oth_req_line);
					end if;

					if l_oth_req_line > 0 then
						x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
						FND_MSG_PUB.ADD;
						fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
						return;
					end if;

					-- now check for non sourced lines
					l_non_src_line := 0;
					SELECT COUNT(requirement_line_id)
					into l_non_src_line
					FROM
					  (SELECT l.requirement_line_id
					  FROM csp_requirement_headers h,
						csp_requirement_lines l
					  WHERE h.task_id             = l_task_id
					  AND h.task_assignment_id    = l_Task_Assignment_id
					  AND h.requirement_header_id = l.requirement_header_id
					  AND (SELECT COUNT (d.requirement_line_id)
									FROM csp_req_line_details d
									WHERE d.requirement_line_id = l.requirement_line_id) = 0
					  MINUS
					  SELECT l.requirement_line_id
					  FROM csp_requirement_headers h,
						csp_requirement_lines l,
						csp_req_line_details d,
						oe_order_lines_all oola
					  WHERE h.task_id             = l_task_id
					  AND h.task_assignment_id    = l_Task_Assignment_id
					  AND h.requirement_header_id = l.requirement_header_id
					  AND l.requirement_line_id   = d.requirement_line_id
					  AND d.source_type          = 'IO'
					  AND d.source_id = oola.line_id
					  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         in ('SHIPPED', 'EXPECTED')
					  );

					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'l_non_src_line = ' || l_non_src_line);
					end if;

					if l_non_src_line = 0 then
						l_dest_ou := -999;
						SELECT ch.destination_organization_id, h.name
						into l_dest_ou, l_dest_org_name
						FROM csp_requirement_headers ch, HR_ALL_ORGANIZATION_UNITS h
						WHERE ch.task_id                     = l_task_id
						AND ch.task_assignment_id          = l_Task_Assignment_id
						AND ch.destination_organization_id = h.organization_id
						AND rownum                         = 1;

						l_rs_ou := -999;
						open get_rs_ou(l_resource_type_code, l_resource_id);
						fetch get_rs_ou into l_rs_ou;
						close get_rs_ou;
						if(l_rs_ou <> -999 and l_rs_ou = l_dest_ou) then
							for cr in c_parts_req(l_task_id, l_Task_Assignment_id)
							loop
								l_requirement_header := CSP_Requirement_headers_PVT.G_MISS_REQUIREMENT_HEADER_REC;
								l_requirement_header.requirement_header_id := cr.requirement_header_id;
								l_requirement_header.last_update_date := sysdate;
								l_requirement_header.destination_organization_id := l_organization_id;
								l_requirement_header.destination_subinventory := l_subinventory_code;
								l_requirement_header.resource_type := l_resource_type_code;
								l_requirement_header.resource_id := l_resource_id;

								if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
												  'before calling Update_requirement_headers...');
								end if;
								CSP_Requirement_Headers_PVT.Update_requirement_headers(
												P_Api_Version_Number         => 1.0,
												P_Init_Msg_List              => FND_API.G_FALSE,
												P_Commit                     => FND_API.G_FALSE,
												p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
												P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
												X_Return_Status              => x_return_status,
												X_Msg_Count                  => x_msg_count,
												x_msg_data                   => x_msg_data
												);
								if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
												  'after calling Update_requirement_headers...x_return_status=' || x_return_status);
								end if;

								if x_return_status <> FND_API.G_RET_STS_SUCCESS then
									x_return_status := FND_API.G_RET_STS_ERROR;
									FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
									FND_MSG_PUB.ADD;
									fnd_msg_pub.count_and_get
											( p_count => x_msg_count
											, p_data  => x_msg_data);
									return;
								end if;
							end loop;
						else
							x_return_status := FND_API.G_RET_STS_ERROR;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_RASG_IO_UPD_OU_ERR');
							FND_MESSAGE.SET_TOKEN('ORG_NAME', l_dest_org_name, TRUE);
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
									( p_count => x_msg_count
									, p_data  => x_msg_data);
							return;
						end if;
						return;
					end if;
				end if;
			end if;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'before making call to CLEAN_REQUIREMENT...');
			end if;

			CSP_SCH_INT_PVT.CLEAN_REQUIREMENT(
				p_api_version_number    => 1.0,
				p_task_assignment_id    => l_Task_Assignment_id,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data
				);

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
							  'after making call to CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);
			end if;

			IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
				-- we need to source the part for the new tech
				l_sch_option.resource_id := l_resource_id;
				l_sch_option.resource_type := l_resource_type_code;
				l_sch_option.start_time := l_booking_start_date;
				l_sch_option.transfer_cost := 9999999; --- this should be a high number to avoid cost check in choose option

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'before calling CSP_SCH_INT_PVT.CHOOSE_OPTION...');
				end if;
				CSP_SCH_INT_PVT.CHOOSE_OPTION(
					p_api_version_number => 1.0,
					p_task_id => l_task_id,
					p_task_assignment_id => l_task_assignment_id,
					p_likelihood => 0,
					p_mandatory => true,
					p_trunk => true,
					p_warehouse => false,
					p_options => l_sch_option,
					x_return_status => x_return_status,
					x_msg_data => x_msg_data,
					x_msg_count => x_msg_count
				);
				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
								  'after calling CSP_SCH_INT_PVT.CHOOSE_OPTION...x_return_status=' || x_return_status);
				end if;

				if x_return_status <> FND_API.G_RET_STS_SUCCESS then
					-- now try to find the part in warehouse
					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'before calling CSP_SCH_INT_PVT.CHOOSE_OPTION...');
					end if;
					CSP_SCH_INT_PVT.CHOOSE_OPTION(
						p_api_version_number => 1.0,
						p_task_id => l_task_id,
						p_task_assignment_id => l_task_assignment_id,
						p_likelihood => 0,
						p_mandatory => true,
						p_trunk => false,
						p_warehouse => true,
						p_options => l_sch_option,
						x_return_status => x_return_status,
						x_msg_data => x_msg_data,
						x_msg_count => x_msg_count
					);
					if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
									  'after calling CSP_SCH_INT_PVT.CHOOSE_OPTION...x_return_status=' || x_return_status);
					end if;
					if x_return_status <> FND_API.G_RET_STS_SUCCESS then
						FND_MSG_PUB.initialize;
						l_resource_name := csp_pick_utils.get_object_name(l_resource_type_code, l_resource_id);
						FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASSGN_NO_SRC');
						FND_MESSAGE.SET_TOKEN('RESOURCE_NAME',l_resource_name, FALSE);
						FND_MSG_PUB.ADD;
						fnd_msg_pub.count_and_get
								( p_count => x_msg_count
								, p_data  => x_msg_data);
					end if;
				end if;
			elsif x_return_status = 'C' then
				l_dest_ou := -999;
				SELECT ch.destination_organization_id, h.name
				into l_dest_ou, l_dest_org_name
				FROM csp_requirement_headers ch, HR_ALL_ORGANIZATION_UNITS h
				WHERE ch.task_id                     = l_task_id
				AND ch.task_assignment_id          = l_Task_Assignment_id
				AND ch.destination_organization_id = h.organization_id
				AND rownum                         = 1;

				l_rs_ou := -999;
				open get_rs_ou(l_resource_type_code, l_resource_id);
				fetch get_rs_ou into l_rs_ou;
				close get_rs_ou;
				if(l_rs_ou <> -999 and l_rs_ou = l_dest_ou) then
					for cr in c_parts_req(l_task_id, l_Task_Assignment_id)
					loop
						l_requirement_header := CSP_Requirement_headers_PVT.G_MISS_REQUIREMENT_HEADER_REC;
						l_requirement_header.requirement_header_id := cr.requirement_header_id;
						l_requirement_header.last_update_date := sysdate;
						l_requirement_header.destination_organization_id := l_organization_id;
						l_requirement_header.destination_subinventory := l_subinventory_code;
						l_requirement_header.resource_type := l_resource_type_code;
						l_requirement_header.resource_id := l_resource_id;

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
						  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
										  'before calling Update_requirement_headers...');
						end if;
						CSP_Requirement_Headers_PVT.Update_requirement_headers(
										P_Api_Version_Number         => 1.0,
										P_Init_Msg_List              => FND_API.G_FALSE,
										P_Commit                     => FND_API.G_FALSE,
										p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
										P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
										X_Return_Status              => x_return_status,
										X_Msg_Count                  => x_msg_count,
										x_msg_data                   => x_msg_data
										);
						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
						  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
										  'after calling Update_requirement_headers...x_return_status=' || x_return_status);
						end if;

						if x_return_status <> FND_API.G_RET_STS_SUCCESS then
							x_return_status := FND_API.G_RET_STS_ERROR;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
									( p_count => x_msg_count
									, p_data  => x_msg_data);
							return;
						end if;
					end loop;
				else
					x_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CSP', 'CSP_RASG_IO_UPD_OU_ERR');
					FND_MESSAGE.SET_TOKEN('ORG_NAME', l_dest_org_name, TRUE);
					FND_MSG_PUB.ADD;
					fnd_msg_pub.count_and_get
							( p_count => x_msg_count
							, p_data  => x_msg_data);
					return;
				end if;
				return;
			else
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
				FND_MSG_PUB.ADD;
				fnd_msg_pub.count_and_get
						( p_count => x_msg_count
						, p_data  => x_msg_data);
			END IF;
			return;
        -- this else part is to book the order
        else

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'checking for task assignment status change...');
            end if;

            open get_task_asg_sts_id;
            fetch get_task_asg_sts_id into l_assignment_status_id;
            close get_task_asg_sts_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'l_assignment_status_id = ' || l_assignment_status_id);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'g_old_tsk_asgn_sts_id = ' || g_old_tsk_asgn_sts_id);
            end if;

            SELECT nvl(cancelled_flag, 'N')
            INTO l_o_assg_sts_flag
            FROM JTF_TASK_STATUSES_B
            WHERE task_status_id = g_old_tsk_asgn_sts_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'l_o_assg_sts_flag = ' || l_o_assg_sts_flag);
            end if;

            if l_o_assg_sts_flag = 'Y' then

                SELECT decode(count(*), 1, 'Y', 'N')
                INTO l_assg_sts_flag
                FROM JTF_TASK_STATUSES_B
                WHERE task_status_id = l_assignment_status_id
                and (nvl(assigned_flag, 'N') = 'Y'
                    or nvl(accepted_flag, 'N') = 'Y' or nvl(planned_flag, 'N') = 'Y');

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'l_assg_sts_flag = ' || l_assg_sts_flag);
                end if;

                if l_assg_sts_flag = 'Y' then
                    TASK_ASSIGNMENT_POST_INSERT(x_return_status => x_return_status);

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                      'after calling TASK_ASSIGNMENT_POST_INSERT.... x_return_status = ' || x_return_status);
                    end if;

                    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                        return;
                    end if;

                end if;

            end if;


            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'checking for accepted status change');
            end if;

            SELECT nvl(accepted_flag, 'N')
            INTO l_assg_sts_flag
            FROM JTF_TASK_STATUSES_B
            WHERE task_status_id = l_assignment_status_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'l_assg_sts_flag = ' || l_assg_sts_flag);
            end if;

            if l_assg_sts_flag = 'Y' then

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'fetching entered status order header_id...');
                end if;

                savepoint csp_book_order;
                for cr in get_order_header_id loop

                    l_oe_header_id := cr.header_id;

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                      'l_oe_header_id = ' || l_oe_header_id);
                    end if;

                    if l_oe_header_id is not null then

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                          'before calling CSP_PARTS_ORDER.book_order ...');
                        end if;

                        CSP_PARTS_ORDER.book_order(
                            p_oe_header_id => l_oe_header_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data
                        );

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                          'after calling CSP_PARTS_ORDER.book_order ...');
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                          'x_return_status = ' || x_return_status);
                        end if;

                        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                            rollback to csp_book_order;

                            select order_number into l_oe_order_num
                                from oe_order_headers_all where header_id = l_oe_header_id;

                            FND_MESSAGE.SET_NAME('CSP', 'CSP_IO_BOOK_ERROR');
                            FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_oe_order_num, TRUE);
                            FND_MSG_PUB.ADD;
                            raise EXCP_USER_DEFINED;
                        end if;

                    end if;
                end loop;
            end if;	-- if l_assg_sts_flag = 'Y' then -- accepted

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'checking for cancelled status change');
            end if;

            SELECT nvl(cancelled_flag, 'N')
            INTO l_assg_sts_flag
            FROM JTF_TASK_STATUSES_B
            WHERE task_status_id = l_assignment_status_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'l_assg_sts_flag = ' || l_assg_sts_flag);
            end if;

            if l_assg_sts_flag = 'Y' then

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'before calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT...');
                end if;

                CSP_SCH_INT_PVT.CLEAN_REQUIREMENT(
                            p_api_version_number    => 1.0,
                            p_task_assignment_id    => l_task_assignment_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data
                        );

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'after calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);
                end if;

				if x_return_status = 'C' then
					-- bug # 16028705
					if(nvl(CSF_TASKS_PUB.g_reschedule, 'N') = 'Y') then
						-- ignore it
						x_return_status := FND_API.G_RET_STS_SUCCESS;
					else
						x_return_status := 'E';
					end if;
				end if;

            end if; -- if l_assg_sts_flag = 'Y' then -- cancelled

	    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'checking for closed status change');
            end if;

	     SELECT nvl(closed_flag, 'N')
            INTO l_assg_sts_flag
            FROM JTF_TASK_STATUSES_B
            WHERE task_status_id = l_assignment_status_id;

	    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                              'l_assg_sts_flag = ' || l_assg_sts_flag);
            end if;

	    if l_assg_sts_flag = 'Y' then

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'before calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT...');
                end if;

                CSP_SCH_INT_PVT.CLEAN_REQUIREMENT(
                            p_api_version_number    => 1.0,
                            p_task_assignment_id    => l_task_assignment_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data
                        );

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                                  'after calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);
                end if;

				if x_return_status = 'C' then
					-- bug # 16028705
					if(nvl(CSF_TASKS_PUB.g_reschedule, 'N') = 'Y') then
						-- ignore it
						x_return_status := FND_API.G_RET_STS_SUCCESS;
					else
						x_return_status := 'E';
					end if;
				end if;

				--17080626
                     if (nvl(CSF_TASKS_PUB.g_reschedule, 'N') <> 'Y') then
			  for cr in c_parts_req(l_task_id, l_Task_Assignment_id)
			  loop
                          l_requirement_header := CSP_Requirement_headers_PVT.G_MISS_REQUIREMENT_HEADER_REC;
                          l_requirement_header.requirement_header_id := cr.requirement_header_id;
                          l_requirement_header.last_update_date := sysdate;
                          l_requirement_header.open_requirement := 'N';

                          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                                    'before calling Update_requirement_headers...');
                          end if;
                          CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                  P_Api_Version_Number         => 1.0,
                                  P_Init_Msg_List              => FND_API.G_FALSE,
                                  P_Commit                     => FND_API.G_FALSE,
                                  p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                  P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                  X_Return_Status              => x_return_status,
                                  X_Msg_Count                  => x_msg_count,
                                  x_msg_data                   => x_msg_data
                                  );
                          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                                    'after calling Update_requirement_headers...x_return_status=' || x_return_status);
                          end if;

                          if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                            return;
                          end if;
                end loop;
          end if;

            end if; -- if l_assg_sts_flag = 'Y' then -- closed

        END IF;
    END IF;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_UPDATE',
                      'done ...');
    end if;
  END;

  PROCEDURE TASK_ASSIGNMENT_PRE_UPDATE
    ( x_return_status OUT NOCOPY varchar2) IS

  CURSOR c_task_assignment( b_task_assignment_id NUMBER ) IS
    SELECT resource_id, assignment_status_id
    FROM   jtf_task_assignments -- don't use synonym as that one filters on OWNER records
    WHERE  task_assignment_id = b_task_assignment_id;

  l_task_assignment_id NUMBER;
  l_assignee_role VARCHAR2(10);

  BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
    l_assignee_role := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.assignee_role;

    if l_assignee_role = 'ASSIGNEE' then
        OPEN c_task_assignment(l_task_assignment_id);
        FETCH c_task_assignment INTO G_old_resource_id, g_old_tsk_asgn_sts_id;
    end if;

  END;

PROCEDURE TASK_ASSIGNMENT_POST_INSERT(
                        x_return_status out nocopy varchar2)
    IS

    l_task_assignment_id NUMBER;
    l_assignee_role VARCHAR2(10);
    l_rqmt_header_id number;
    l_organization_id number;
    l_subinventory_code   VARCHAR2(30);
    l_dflt_ship_add_prf varchar2(10);
    l_ship_to_type varchar2(1);
    l_ship_to_location_id number;
    l_ship_hz_loc_id number := -999;
    l_party_site_id number;
    l_cust_act_id  number;
    l_cust_id number;
    l_org_id number;
    x_msg_data varchar2(4000);
    x_msg_count number;
    l_resource_id         NUMBER;
    l_resource_type_code  VARCHAR2(30);

    cursor get_current_ship_to (v_req_header_id number) is
    SELECT rh.ship_to_location_id, rh.ADDRESS_TYPE
    FROM csp_requirement_headers rh
    WHERE rh.requirement_header_id = v_req_header_id;

    cursor get_blank_req_header is
    SELECT rh.requirement_header_id
    FROM csp_requirement_headers rh,
      jtf_task_assignments jta
    WHERE jta.task_assignment_id = l_task_assignment_id
    AND rh.task_id               = jta.task_id
    AND rh.task_assignment_id   IS NULL
    AND NOT EXISTS
      (SELECT 1
      FROM csp_req_line_details rld,
        csp_requirement_lines rl
      WHERE rl.requirement_line_id = rld.requirement_line_id
      AND rl.requirement_header_id = rh.requirement_header_id);

    CURSOR get_Resource_org_sub IS
    SELECT organization_id, subinventory_code
    FROM csp_inv_loc_assignments
    WHERE resource_id = l_resource_id
        AND resource_type = l_resource_type_code
        AND default_code = 'IN';

    CURSOR get_task_ship_add_loc IS
    SELECT
      pa.location_id as hrLocationId,
      jpl.location_id as hzLocationId,
      jpl.party_site_id as partySiteId,
      hcas.cust_account_id as custAccountId,
      jpl.party_id as customerId,
      cia.org_id
    FROM jtf_party_locations_v jpl,
      cs_incidents_all_b cia,
      jtf_tasks_b jtb,
      hz_cust_site_uses_all hcsu,
      hz_cust_acct_sites_all hcas,
      po_location_associations_all pa,
      jtf_task_assignments jta
    WHERE jta.task_assignment_id      = l_Task_Assignment_id
      AND jtb.task_id = jta.task_id
      AND jtb.source_object_type_code = 'SR'
      and jtb.source_object_id = cia.incident_id
      AND jpl.party_id           = cia.customer_id
      AND jpl.type               = 'SHIP_TO'
      AND jpl.type = hcsu.site_use_code
      AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
      AND hcas.party_site_id     = jpl.party_site_id
      AND hcas.cust_account_id = cia.account_id
      AND hcsu.site_use_id = pa.site_use_id(+)
      AND pa.address_id(+) = hcsu.cust_acct_site_id
      AND hcas.org_id = cia.org_id
      AND jpl.party_site_id = jtb.address_id;

    CURSOR get_cust_add_location IS
    SELECT
      pa.location_id as hrLocationId,
      jpl.location_id as hzLocationId,
      jpl.party_site_id as partySiteId,
      hcas.cust_account_id as custAccountId,
      jpl.party_id as customerId,
      cia.org_id
    FROM jtf_party_locations_v jpl,
      cs_incidents_all_b cia,
      jtf_tasks_b jtb,
      hz_cust_site_uses_all hcsu,
      hz_cust_acct_sites_all hcas,
      po_location_associations_all pa,
      jtf_task_assignments jta
    WHERE jta.task_assignment_id      = l_Task_Assignment_id
      AND jtb.task_id = jta.task_id
      AND jtb.source_object_type_code = 'SR'
      and jtb.source_object_id = cia.incident_id
      AND jpl.party_id           = cia.customer_id
      AND jpl.type               = 'SHIP_TO'
      AND jpl.type = hcsu.site_use_code
      AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
      AND hcas.party_site_id     = jpl.party_site_id
      AND hcas.cust_account_id = cia.account_id
      AND hcsu.site_use_id = pa.site_use_id(+)
      AND pa.address_id(+) = hcsu.cust_acct_site_id
      AND hcas.org_id = cia.org_id
      AND jpl.primary_flag = 'Y';

  CURSOR get_resource_location IS
    SELECT csp.ship_to_location_id
    FROM csp_rs_ship_to_addresses_all_v csp,
      hz_cust_acct_sites_All hz,
      cs_incidents_all_b cs,
      jtf_tasks_b jtb,
      jtf_task_assignments jta
    WHERE csp.cust_acct_site_id     = hz.cust_acct_site_id
    AND csp.resource_id             = jta.resource_id
    AND csp.resource_type           = jta.resource_type_code
    AND primary_flag                = 'Y'
    AND hz.org_id                   = cs.org_id
    AND jta.task_assignment_id      = l_Task_Assignment_id
    AND jta.task_id                 = jtb.task_id
    AND jtb.source_object_type_code = 'SR'
    AND jtb.source_object_id        = cs.incident_id
    AND csp.resource_id             = l_resource_id
    AND csp.resource_type           = l_resource_type_code;

BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
              'Begin');
    end if;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
    l_assignee_role := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.assignee_role;
    l_resource_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_id;
    l_resource_type_code := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_type_code;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
              'l_task_assignment_id = ' || l_task_assignment_id
              || ', l_assignee_role = ' || l_assignee_role
              || ', l_resource_id = ' || l_resource_id
              || ', l_resource_type_code = ' || l_resource_type_code);
    end if;

    if l_assignee_role = 'ASSIGNEE' then

        -- check any requirement without task_assignment_id, if yes popuplate assignment details...

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                          'checking if there is no task assignment posted on the part req...');
        end if;

        for cr in get_blank_req_header loop
            l_rqmt_header_id := cr.requirement_header_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'found one l_rqmt_header_id = ' || l_rqmt_header_id);
            end if;

            -- we need to default following things
            -- 1. task_assignment_id
            -- 2. resource_type and resource_id
            -- 3. destination_org and subinv
            -- 4. Ship To address Type
            -- 5. Ship To address
            --
            -- we can default 1 to 3 items easily
            -- for item 4, we need to read profile value  CSP_PART_REQ_DEF_SHIP_TO
            -- for item 5, we need to get the address and generate HR_LOCATION_ID if not already available

            -- we already have information for item 1 and 2

            -- this is to get item 3
            OPEN get_Resource_org_sub;
            FETCH get_resource_org_sub INTO l_organization_id, l_subinventory_code;
            CLOSE get_resource_org_sub;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'l_organization_id = ' || l_organization_id
                              || ', l_subinventory_code = ' || l_subinventory_code);
            end if;

            open get_current_ship_to(l_rqmt_header_id);
            fetch get_current_ship_to into l_ship_to_location_id, l_ship_to_type;
            close get_current_ship_to;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'l_ship_to_location_id = ' || l_ship_to_location_id);
            end if;

            if l_ship_to_location_id is null then
                -- this is to get item 4 and 5

                /*
                There is a bug in scheduler code. It creates task assignment first and
                then checks for Spares availability! So, if this code updates a part req
                then spares-scheduler integration code will break. So, removing this code to
                default ship to address based on profile and always default technician
                primary ship to address as there is a similar logic in spares-scheduler
                integration code as well.
                */


                --l_dflt_ship_add_prf := FND_PROFILE.value('CSP_PART_REQ_DEF_SHIP_TO');

                if l_dflt_ship_add_prf is null then
                    l_dflt_ship_add_prf := 'NONE';
                end if;


                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                  'profile CSP_PART_REQ_DEF_SHIP_TO is l_dflt_ship_add_prf = ' || l_dflt_ship_add_prf);
                end if;

                if l_dflt_ship_add_prf = 'TASK' then

                    l_ship_to_type := 'T';

                    open get_task_ship_add_loc;
                    fetch get_task_ship_add_loc into l_ship_to_location_id,
                                                    l_ship_hz_loc_id,
                                                    l_party_site_id,
                                                    l_cust_act_id,
                                                    l_cust_id,
                                                    l_org_id;
                    close get_task_ship_add_loc;

                elsif l_dflt_ship_add_prf = 'CUSTOMER' then

                    l_ship_to_type := 'C';

                    open get_cust_add_location;
                    fetch get_cust_add_location into l_ship_to_location_id,
                                                    l_ship_hz_loc_id,
                                                    l_party_site_id,
                                                    l_cust_act_id,
                                                    l_cust_id,
                                                    l_org_id;
                    close get_cust_add_location;

                else
                    l_ship_to_type := 'R';

                    OPEN get_resource_location;
                    FETCH get_resource_location INTO l_ship_to_location_id;
                    CLOSE get_resource_location;

                end if;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                  'l_ship_to_type = ' || l_ship_to_type
                                  || ', l_ship_to_location_id = ' || l_ship_to_location_id
                                  || ', l_ship_hz_loc_id = ' || l_ship_hz_loc_id);
                end if;

                -- assuming technician ship to address will have proper hr_location_id
                /*
                if l_ship_to_location_id is null and nvl(l_ship_hz_loc_id, -999) <> -999 then
                    -- need to generate HR_LOCATION_ID

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                      'Before calling csp_ship_to_address_pvt.cust_inv_loc_link...');
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                      'l_party_site_id = ' || l_party_site_id
                                      || ', l_cust_act_id = ' || l_cust_act_id
                                      || ', l_cust_id = ' || l_cust_id
                                      || ', l_org_id = ' || l_org_id);
                    end if;

                    csp_ship_to_address_pvt.cust_inv_loc_link
                        (p_api_version              => 1.0
                        ,p_Init_Msg_List            => FND_API.G_FALSE
                        ,p_commit                   => FND_API.G_FALSE
                        ,px_location_id             => l_ship_hz_loc_id
                        ,p_party_site_id            => l_party_site_id
                        ,p_cust_account_id          => l_cust_act_id
                        ,p_customer_id              => l_cust_id
                        ,p_org_id		             => l_org_id
                        ,p_attribute_category       => null
                        ,p_attribute1               => null
                        ,p_attribute2               => null
                        ,p_attribute3               => null
                        ,p_attribute4               => null
                        ,p_attribute5               => null
                        ,p_attribute6               => null
                        ,p_attribute7               => null
                        ,p_attribute8               => null
                        ,p_attribute9               => null
                        ,p_attribute10              => null
                        ,p_attribute11              => null
                        ,p_attribute12              => null
                        ,p_attribute13              => null
                        ,p_attribute14              => null
                        ,p_attribute15              => null
                        ,p_attribute16              => null
                        ,p_attribute17              => null
                        ,p_attribute18              => null
                        ,p_attribute19              => null
                        ,p_attribute20              => null
                        ,x_return_status            => x_return_status
                        ,x_msg_count                => x_msg_count
                        ,x_msg_data                 => x_msg_data
                        );

                    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                      'After calling csp_ship_to_address_pvt.cust_inv_loc_link...');
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                                      'x_return_status = ' || x_return_status
                                      || ', x_msg_count = ' || x_msg_count
                                      || ', x_msg_data = ' || x_msg_data
                                      || ', l_ship_hz_loc_id = ' || l_ship_hz_loc_id);
                    end if;

                    if nvl(x_return_status, 'S') = FND_API.G_RET_STS_SUCCESS then
                        l_ship_to_location_id := l_ship_hz_loc_id;
                        x_return_status := 'S';
                    end if;

                end if;
                */
            end if;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'before calling CSP_REQUIREMENT_HEADERS_PKG.Update_Row...');
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'l_ship_to_location_id = ' || l_ship_to_location_id);
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'l_ship_to_type = ' || l_ship_to_type);
            end if;

            CSP_REQUIREMENT_HEADERS_PKG.Update_Row(
                p_REQUIREMENT_HEADER_ID => l_rqmt_header_id,
                p_TASK_ASSIGNMENT_ID => l_task_assignment_id,
                p_resource_id => l_resource_id,
                p_resource_type => l_resource_type_code,
                p_DESTINATION_ORGANIZATION_ID => l_organization_id,
                P_DESTINATION_SUBINVENTORY => l_subinventory_code,
                p_ADDRESS_TYPE => l_ship_to_type,
                p_SHIP_TO_LOCATION_ID => l_ship_to_location_id,
                p_ship_to_contact_id => null
            );

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                              'after calling CSP_REQUIREMENT_HEADERS_PKG.Update_Row...');
            end if;

        end loop;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_PARTS_REQUIREMENT.TASK_ASSIGNMENT_POST_INSERT',
                      'done ...');
    end if;
END;

PROCEDURE TASK_ASSIGNMENT_PRE_DELETE(x_return_status out nocopy varchar2)
    IS
    l_log_module varchar2(100) := 'csp.plsql.csp_parts_requirement.task_assignment_pre_delete';
    l_task_assignment_id NUMBER;
    x_msg_data varchar2(4000);
    x_msg_count number;
	l_task_id number;
	l_dtl_count number;
	EXCP_USER_DEFINED        EXCEPTION;
BEGIN
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'begin ...');
    end if;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
	l_task_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'before calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT...');
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'l_task_assignment_id=' || l_task_assignment_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'l_task_id=' || l_task_id);
    end if;

    CSP_SCH_INT_PVT.CLEAN_REQUIREMENT(
                p_api_version_number    => 1.0,
                p_task_assignment_id    => l_task_assignment_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
            );

	-- check if we still has any req line details
	l_dtl_count := 0;
	SELECT COUNT(*)
	INTO l_dtl_count
	FROM csp_requirement_headers h,
	  csp_requirement_lines l,
	  csp_req_line_details d
	WHERE h.task_assignment_id  = l_task_assignment_id
	AND h.task_id               = l_task_id
	AND h.requirement_header_id = l.requirement_header_id
	AND l.requirement_line_id   = d.requirement_line_id;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'l_dtl_count=' || l_dtl_count);
    end if;

	if l_dtl_count > 0 then
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
		FND_MSG_PUB.ADD;
		fnd_msg_pub.count_and_get
				( p_count => x_msg_count
				, p_data  => x_msg_data);
		raise EXCP_USER_DEFINED;
	end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'after calling CSP_SCH_INT_PVT.CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_log_module,
                      'done ...');
    end if;
END;

procedure log(p_procedure in varchar2,p_message in varchar2) as
begin
    --dbms_output.put_line(p_procedure||' - '||p_message);
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'csp.plsql.csp_parts_requirement.'||p_procedure,
                   p_message);
    end if;
end;

procedure get_resource_shift_end(
         p_resource_id             in number
        ,p_resource_type           in varchar2
        ,x_shift_end_datetime      out nocopy date
        ,x_return_status           out nocopy varchar2
        ,x_msg_count               out nocopy number
        ,x_msg_data                out nocopy varchar2
  )
is
  l_start_date date;
  l_end_date date;
  l_shifts apps.csf_resource_pub.shift_tbl_type;
  l_lead_time_days number;
  l_shift_date_start date;
  l_shift_date_start_local date;
  l_shift_datetime_end date;
  l_shift_datetime_end_local date;
begin
  l_lead_time_days := fnd_profile.value('CSP_PR_NEED_BY_LEAD_TIME');
  log('get_resource_shift_end', 'CSP_PR_NEED_BY_LEAD_TIME = ' || l_lead_time_days);
  if(l_lead_time_days is null) then
     x_return_status :='S';
  else
    l_start_date := sysdate+l_lead_time_days;
    l_end_date := sysdate+l_lead_time_days+30;

    csf_resource_pub.get_resource_shifts(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_false,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_resource_id => p_resource_id,
      p_resource_type => p_resource_type,
      p_start_date => l_start_date,
      p_end_date => l_end_date,
      p_shift_type => null,
      x_shifts => l_shifts
    );
    log('get_resource_shift_end', 'x_return_status = ' || x_return_status);
    log('get_resource_shift_end', 'x_msg_count = ' || x_msg_count);
    log('get_resource_shift_end', 'x_msg_data = ' || x_msg_data);

    if (x_return_status = 'S') and (l_shifts is not null) and (l_shifts.count > 0) then
      for i in 1..l_shifts.count loop
        log('get_resource_shift_end', i||' ====================================================== '||i);
        log('get_resource_shift_end', 'shift_construct_id: '||l_shifts(i).shift_construct_id);
        log('get_resource_shift_end', 'start_datetime: '||to_char(l_shifts(i).start_datetime, 'DD-MM-YYYY HH24:MI'));
        log('get_resource_shift_end', 'end_datetime: '||to_char(l_shifts(i).end_datetime, 'DD-MM-YYYY HH24:MI'));
        log('get_resource_shift_end', 'availability_type: '||l_shifts(i).availability_type);
        log('get_resource_shift_end', i||' ====================================================== '||i);

        l_shift_date_start_local := to_date(to_char(l_shifts(i).start_datetime, 'DD-MM-YYYY'), 'DD-MM-YYYY');
        l_shift_datetime_end_local := l_shifts(i).end_datetime;

        if l_shift_date_start is null then
          l_shift_date_start := l_shift_date_start_local;
          l_shift_datetime_end := l_shift_datetime_end_local;
        elsif l_shift_date_start = l_shift_date_start_local then
          l_shift_datetime_end := l_shift_datetime_end_local;
        else
          exit;
        end if;
      end loop;

      log('get_resource_shift_end', 'Next Available Shift End Datetime: '||to_char(l_shift_datetime_end, 'DD-MM-YYYY HH24:MI'));
      x_shift_end_datetime := l_shift_datetime_end;
    end if;
      if x_shift_end_datetime is null then
         x_shift_end_datetime := to_date(to_char(l_start_date, 'DD/MM/YYYY') || ' 23:59:00', 'DD/MM/YYYY HH24:MI:SS');
      end if;
      log('get_resource_shift_end', 'Final Next Available Shift End Datetime: '||to_char(x_shift_end_datetime, 'DD-MM-YYYY HH24:MI'));
  end if;
end;

END;

/
