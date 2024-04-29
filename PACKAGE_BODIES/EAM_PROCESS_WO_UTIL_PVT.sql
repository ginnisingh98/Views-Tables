--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_WO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_WO_UTIL_PVT" AS
/* $Header: EAMVPWUB.pls 120.16.12010000.9 2012/02/22 09:35:36 vchidura ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVPWUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_PROCESS_WO_UTIL_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-OCT-2003    Basanth Roy     Initial Creation
--  15-Jul-05      Anju Gupta      Changes for MOAC
***************************************************************************/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_PROCESS_WO_UTIL_PVT';




procedure create_requisition
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_operation_seq_num           IN    NUMBER
    ,p_organization_id             IN    NUMBER
    ,p_user_id                     IN    NUMBER
    ,p_responsibility_id           IN    NUMBER
    ,p_quantity                    IN    NUMBER
    ,p_unit_price                  IN    NUMBER
    ,p_category_id                 IN    NUMBER
    ,p_item_description            IN    VARCHAR2
    ,p_uom_code                    IN    VARCHAR2
    ,p_need_by_date                IN    DATE
    ,p_inventory_item_id           IN    NUMBER
    ,p_direct_item_id              IN    NUMBER
    ,p_suggested_vendor_id         IN    NUMBER
    ,p_suggested_vendor_name       IN    VARCHAR2
    ,p_suggested_vendor_site       IN    VARCHAR2
    ,p_suggested_vendor_phone      IN    VARCHAR2
    ,p_suggested_vendor_item_num   IN    VARCHAR2
) IS

       l_api_name       CONSTANT VARCHAR2(30) := 'create_requisition';
       l_api_version    CONSTANT NUMBER       := 1.0;
       l_request_id              NUMBER;
       l_person_id               NUMBER;
       l_material_account        NUMBER;
       l_material_variance_account    NUMBER;
       l_currency       VARCHAR2(30);
       l_project_id     NUMBER;
       l_task_id        NUMBER;
       l_location_id    NUMBER;
       l_stmt_num       NUMBER;
       l_str_application_id VARCHAR2(30);
       l_project_acc_context VARCHAR2(1);
       l_ou_id number;
       l_wip_entity_name VARCHAR2(240);
       l_req_import VARCHAR2(50);
       l_available NUMBER;
 -- Added for NF2008 - Copy Asset Number to Notes to Approver on Purchase Requisitions
        l_asset_number		VARCHAR2(30);
        l_priority	NUMBER;
	l_priority_meaning	VARCHAR2(80) := '';
        l_asset_criticality VARCHAR2(240);
        l_descriptive_text  VARCHAR2(240);
	l_serial_number VARCHAR2(30);

	l_asset_group_id NUMBER; --Added for the bug 6928769 and 7037630
	l_organization_id NUMBER;--Added for the bug 6928769 and 7037630
	l_maintenance_object_id NUMBER; -- Added for the bug 8363544, the fix of the previous bug fixing
	l_maintenance_object_type NUMBER; -- Added for the bug 8363544, the fix of the previous bug fixing
	l_user_id NUMBER; --Added for bug 13638082
        l_status_options BOOLEAN ;    --Added for bug 13638082
 BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Start===============================================================');
	END IF;

    -- Standard Start of API savepoint
         l_stmt_num    := 10;
         SAVEPOINT create_requisition_pvt;

         l_stmt_num    := 20;
         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_stmt_num    := 30;
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;

         l_stmt_num    := 40;
         --  Initialize API return status to success
         x_return_status := fnd_api.g_ret_sts_success;

         l_stmt_num    := 50;

         -- API body

     -- If PO_DIRECT_DELIVERY_TO_SHOPFLOOR profile option is not set then return immediately with out error status
    IF ( NVL(fnd_profile.value('PO_DIRECT_DELIVERY_TO_SHOPFLOOR'), 'N') = 'N' ) THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : PO_DIRECT_DELIVERY_TO_SHOPFLOOR profile option is not set. So not creating requisitions.');
        END IF;
        return;
    END IF;

    --bug# 3691325 If requested quantity is less than or equal to zero then return immediately with out error status
    IF ( NVL(p_quantity,0) <= 0) then
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Requested Quantity is less than or equal to zero. So not creating requisitions.');
	END IF;
        return;
    END IF;


         --Added for the bug 13638082..This will select the User who has created the workorder
	 --and will be further used to create the requisition on the creator's name
	 --Else approver becomes the creator for the Requisition.
         SELECT CREATED_BY INTO l_user_id
         FROM wip_entities
         WHERE wip_entity_id  =  p_wip_entity_id;


         if ( Nvl(l_user_id, p_user_id) is not null) then

         select employee_id
         into l_person_id
         from fnd_user
         where user_id = Nvl(l_user_id, p_user_id) ;

         end if;

         if((p_wip_entity_id is not null) and (p_organization_id is not null)) then

      --bug# 8363544, using wip_discrete_jobs.maintenance_object_id instead of wip_discrete_jobs.asset_number which is no more used after R12
	  -- then find serial number, inventory_item_id in csi_item_instances table with wip_discrete_jobs.maintenance_object_id for serialized item
	  -- there is no asset number for non-serialized item
	  -- Use wdj.rebuild_item_id as group id for non-serialized items; otherwise, find group id in table "csi_item_instances" as well.
                SELECT wdj.project_id, wdj.task_id, we.wip_entity_name, wdj.maintenance_object_id,
                       wdj.maintenance_object_type, wdj.organization_id, wdj.priority
                  INTO l_project_id,l_task_id, l_wip_entity_name, l_maintenance_object_id,
				       l_maintenance_object_type,  l_organization_id, l_priority
                  FROM wip_discrete_jobs wdj, wip_entities we
                 WHERE wdj.wip_entity_id = p_wip_entity_id
                   AND wdj.organization_id = p_organization_id
                   AND wdj.wip_entity_id = we.wip_entity_id;

				    /* Added for bug 9216810 */
	 select count(category_id) into l_available from cst_cat_ele_exp_assocs_v cceav
                      where category_id = p_category_id;

        if l_available > 0 then
		select 	decode(cceav.mfg_cost_element_id,
					1,wac.material_account,
					2,wac.material_overhead_account,
					3,wac.resource_account,
					4,wac.outside_processing_account,
					5,wac.overhead_account,wac.material_account) account_id,

				decode(cceav.mfg_cost_element_id,
					1,wac.material_variance_account,
					2,wac.material_overhead_account,
					3,wac.resource_variance_account,
					4,wac.outside_proc_variance_account,
					5,wac.overhead_variance_account,wac.material_variance_account) variance_account_id

				into l_material_account,l_material_variance_account
		from  cst_cat_ele_exp_assocs_v cceav, wip_accounting_classes wac,wip_discrete_jobs wdj
		where  wdj.organization_id = p_organization_id  and
			wdj.wip_entity_id = p_wip_entity_id and
			wac.class_code = wdj.class_code and
			wac.organization_id= wdj.organization_id and
			cceav.category_id =p_category_id and
			nvl(cceav.start_date,sysdate-1) <= sysdate and
			nvl(cceav.end_date,sysdate+1) >= sysdate;
	else
		select wdj.material_account, wdj.material_variance_account
			into l_material_account,l_material_variance_account
		from wip_discrete_jobs wdj
		where wdj.wip_entity_id = p_wip_entity_id and
			wdj.organization_id = p_organization_id;
	end if;

		   if l_priority is not null then
			select meaning into l_priority_meaning from mfg_lookups where
			lookup_code=l_priority
			AND lookup_type='WIP_EAM_ACTIVITY_PRIORITY';
		   end if;

		-- Added for the bug 8363544, the fix of the previous bug fixing
		-- To get the correct asset number from csi_item_instances for serialized items
		IF l_maintenance_object_type = 3 THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Serialized Asset Retrieving info from csi_item_instances');
			END IF;

			SELECT serial_number, inventory_item_id
			INTO l_serial_number, l_asset_group_id
			FROM csi_item_instances
			WHERE instance_id =l_maintenance_object_id;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Checking query variables are null or not : Serial Number:'|| l_serial_number);
				EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Asset Group Id :' || l_asset_group_id ||' , Organization Id:' || l_organization_id);
			END IF;

              -- Added for NF2008 - Copy Asset Number to Notes to Approver on Purchase Requisitions
			SELECT meanv.descriptive_text, meanv.asset_criticality,instance_number
            INTO l_descriptive_text, l_asset_criticality,l_asset_number
            FROM mtl_eam_asset_numbers_v meanv
            WHERE meanv.serial_number = l_serial_number
			AND meanv.inventory_item_id = l_asset_group_id
		    AND meanv.CURRENT_ORGANIZATION_ID = l_organization_id;
		--for non serialized items
		ELSIF l_maintenance_object_type = 2 THEN
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Non-serialized Asset-Retrieving info from mtl_system_items_b: l_serial_number:'||l_serial_number);
				EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Asset Group Id:' || l_asset_group_id ||' , Organization Id:' || l_organization_id);
			END IF;

			SELECT msib.description
			INTO l_descriptive_text
			FROM mtl_system_items_b msib
			WHERE msib.inventory_item_id= l_maintenance_object_id
			AND msib.organization_id = l_organization_id;
		END IF;

     if l_project_id is not null then
        l_project_acc_context := 'Y';
     end if;




         select gb.currency_code, to_number(ho.ORG_INFORMATION3)
         into l_currency, l_ou_id
         from hr_organization_information ho, gl_sets_of_books  gb
         where gb.set_of_books_id = ho.ORG_INFORMATION1
         and ho.organization_id = p_organization_id
         and ho.ORG_INFORMATION_CONTEXT = 'Accounting Information';

         end if;

         if((p_wip_entity_id is not null) and (p_organization_id is not null) and (p_operation_seq_num is not null)) then

         begin
         select bd.location_id
         into l_location_id
     from bom_departments bd, wip_operations wo
     where bd.department_id = wo.department_id
     and bd.organization_id = wo.organization_id
     and wo.wip_entity_id = p_wip_entity_id
     and wo.operation_seq_num = p_operation_seq_num
         and wo.organization_id = p_organization_id;
         exception
         when no_data_found then
           l_location_id := 0;
         end;

         end if;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : inserting into po_requisitions_interface_all ..'); END IF;

/* Changed for MOAC: Insert org_id as well */
insert into po_requisitions_interface_all (
             interface_source_code,
             destination_type_code,
             authorization_status,
             preparer_id,  -- person id of the user name
             quantity,
             destination_organization_id,
             deliver_to_location_id,
             deliver_to_requestor_id,
             source_type_code,
             category_id,
             item_description,
             uom_code,
             unit_price,
             need_by_date,
             wip_entity_id,
             wip_operation_seq_num,
             charge_account_id,
             variance_account_id,
             item_id,
             wip_resource_seq_num,
             suggested_vendor_id,
             suggested_vendor_name,
             suggested_vendor_site,
             suggested_vendor_phone,
             suggested_vendor_item_num,
             currency_code,
             project_id,
             task_id,
         project_accounting_context,
             last_updated_by,
             last_update_date,
             created_by,
             creation_date,
             org_id,
         reference_num,
         NOTE_TO_APPROVER )
   values (
             'EAM',
             'SHOP FLOOR',
             'INCOMPLETE',
             l_person_id,
             p_quantity,
             p_organization_id,
             l_location_id,
             l_person_id,
             'VENDOR',
             p_category_id,
             p_item_description,
             p_uom_code,
             nvl(p_unit_price,0),
             p_need_by_date,
             p_wip_entity_id,
             p_operation_seq_num,
             l_material_account,
             l_material_variance_account,
             p_inventory_item_id,
             p_direct_item_id,
             p_suggested_vendor_id,
             p_suggested_vendor_name,
             p_suggested_vendor_site,
             p_suggested_vendor_phone,
             p_suggested_vendor_item_num,
             l_currency,
             l_project_id,
             l_task_id,
         l_project_acc_context,
             Nvl(l_user_id, p_user_id),
             sysdate,
             Nvl(l_user_id, p_user_id),
             sysdate,
             l_ou_id,
         substrb(l_wip_entity_name, 1, 25) ,
         l_asset_number||':'||l_DESCRIPTIVE_TEXT||':'||l_ASSET_CRITICALITY||':'||l_priority_meaning
             );
	 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Asset Number Debug: Asset Number: '||l_asset_number||' , Description:'||l_DESCRIPTIVE_TEXT);
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Criticality:'||l_ASSET_CRITICALITY||' , Priority:'||l_priority);
	END IF;

          l_str_application_id := fnd_profile.value('RESP_APPL_ID');

      -- This call to fnd_global.apps_initialize is needed because this is
      -- part of the WO API which can also be used as a standalone API
      -- and there needs to be a call to APPS_INITIALIZE before
      -- concurrent programs are called

      if ( Nvl(l_user_id, p_user_id) is not null and p_responsibility_id is not null and l_str_application_id is not null) then
                FND_GLOBAL.APPS_INITIALIZE( Nvl(l_user_id, p_user_id), p_responsibility_id, to_number(l_str_application_id),0);
      end if;

      /* Changes for MOAC */
      fnd_request.set_org_id (l_ou_id);
      l_status_options := fnd_request.set_options(datagroup => 'Standard');

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Calling the concurrent program ...'); END IF;
     SELECT REQIMPORT_GROUP_BY_CODE into l_req_import
     FROM PO_SYSTEM_PARAMETERS_ALL where ORG_ID=l_ou_id;  -- Changed for bug 6837105
     l_request_id := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'EAM', NULL, l_req_import,
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;



       -- End of API body.
           -- Standard check of p_commit.
           IF fnd_api.to_boolean(p_commit) THEN
              COMMIT WORK;
           END IF;

           l_stmt_num    := 999;
           -- Standard call to get message count and if count is 1, get message info.
           fnd_msg_pub.count_and_get(
              p_encoded => fnd_api.g_false
             ,p_count => x_msg_count
             ,p_data => x_msg_data);

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_requisition : Concurrent program finished Status : '||x_return_status||' End =========================');
	END IF;
return;


 EXCEPTION


           WHEN fnd_api.g_exc_error THEN
              ROLLBACK TO create_requisition_pvt;
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              fnd_msg_pub.count_and_get(
                 p_encoded => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);
           WHEN fnd_api.g_exc_unexpected_error THEN
              ROLLBACK TO create_requisition_pvt;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              fnd_msg_pub.count_and_get(
                 p_encoded => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);
           WHEN OTHERS THEN
              ROLLBACK TO create_requisition_pvt;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
              IF fnd_msg_pub.check_msg_level(
                    fnd_msg_pub.g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
              END IF;

              fnd_msg_pub.count_and_get(
                 p_encoded   => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);



 END create_requisition;






     PROCEDURE create_reqs_at_wo_rel
        (  p_api_version                 IN    NUMBER        := 1.0
          ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
          ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
          ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
          ,x_return_status               OUT NOCOPY   VARCHAR2
          ,x_msg_count                   OUT NOCOPY   NUMBER
          ,x_msg_data                    OUT NOCOPY   VARCHAR2
          ,p_user_id                     IN    NUMBER
          ,p_responsibility_id           IN    NUMBER
          ,p_wip_entity_id               IN    NUMBER        -- data
          ,p_organization_id             IN    NUMBER)
     IS
       l_api_name       CONSTANT VARCHAR2(30) := 'create_reqs_at_wo_rel';
       l_api_version    CONSTANT NUMBER       := 1.0;
       l_request_id              NUMBER;
       l_person_id               NUMBER;
       l_material_account        NUMBER;
       l_material_variance_account    NUMBER;
       l_currency       VARCHAR2(30);
       l_project_id     NUMBER;
       l_task_id        NUMBER;
       l_location_id    NUMBER;
       l_description    VARCHAR2(240);
       l_stmt_num       NUMBER;
       l_api_return_status  VARCHAR2(1);
       l_api_msg_count      NUMBER;
       l_api_msg_data       VARCHAR2(2000);
       l_total_req_qty   NUMBER;
       l_req_for_cancel_qty_profile VARCHAR2(1);

       CURSOR l_di_recs IS
       (
        SELECT  wip_entity_id,
            organization_id,
            operation_seq_num as task_number,
            to_number(null) as inventory_item_id,
            direct_item_sequence_id,
            1 as direct_item_type_id,
            description,
            required_quantity,
            unit_price,
            uom as uom_code,
            purchasing_category_id,
            need_by_date as date_required,
            auto_request_material,
            suggested_vendor_id,
            suggested_vendor_name,
            suggested_vendor_site,
            suggested_vendor_phone,
            suggested_vendor_item_num
         FROM wip_eam_direct_items
             WHERE wip_entity_id = p_wip_entity_id
             AND organization_id = p_organization_id
         UNION ALL
         SELECT wro.wip_entity_id,
            wro.organization_id,
            wro.operation_seq_num as task_number,
            wro.inventory_item_id,
            to_number(null) as direct_item_sequence_id,
            2 as direct_item_type_id,
            msi.description,
            wro.required_quantity,
            wro.unit_price,
            msi.primary_uom_code as uom_code,
            mic.category_id as purchasing_category_id,
            wro.date_required,
            wro.auto_request_material,
            vendor_id,
            wro.suggested_vendor_name,
            to_char(null) as suggested_vendor_site,
            to_char(null) as suggested_vendor_phone,
            to_char(null) as suggested_vendor_item_num
          FROM wip_requirement_operations wro,
            mtl_system_items_kfv msi,
            mtl_item_categories mic ,
            mtl_default_category_sets mdcs
           WHERE msi.inventory_item_id = wro.inventory_item_id
            AND msi.organization_id = wro.organization_id
            AND nvl(msi.stock_enabled_flag, 'N') = 'N'
            AND wro.inventory_item_id = mic.inventory_item_id
            AND wro.organization_id = mic.organization_id
            AND mic.category_set_id = mdcs.category_set_id
            AND mdcs.functional_area_id = 2
        AND wro.wip_entity_id = p_wip_entity_id
            AND wro.organization_id =  p_organization_id
    );

 BEGIN

    -- Standard Start of API savepoint
         l_stmt_num    := 10;
         SAVEPOINT create_requisition_pvt;

         l_stmt_num    := 20;
         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_stmt_num    := 30;
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;

         l_stmt_num    := 40;
         --  Initialize API return status to success
         x_return_status := fnd_api.g_ret_sts_success;

         l_stmt_num    := 50;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Start ==========================================================='); END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel:PROFILE : EAM: Trigger requisition for cancelled quantity : '||FND_PROFILE.VALUE('EAM_TRIGGER_REQ_CANCEL_QTY')); END IF;

        l_req_for_cancel_qty_profile := NVL(FND_PROFILE.VALUE('EAM_TRIGGER_REQ_CANCEL_QTY'),'Y');  --bug 13102446

         FOR l_di_record in l_di_recs
         LOOP

           if l_di_record.wip_entity_id is not null
              and l_di_record.auto_request_material = 'Y' then


              IF l_di_record.direct_item_type_id = 1 THEN  -- description based direct item . fix for 3421830

                l_description := l_di_record.description;

                IF(l_req_for_cancel_qty_profile = 'Y') then
		--13102446 trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN
                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/
                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id =l_di_record.wip_entity_id
                        AND pria.destination_organization_id = l_di_record.organization_id
                        AND pria.wip_operation_seq_num = l_di_record.task_number
                        AND pria.item_id is null
                        AND pria.wip_resource_seq_num = l_di_record.direct_item_sequence_id
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                        AND prla.wip_entity_id =l_di_record.wip_entity_id
                        AND prla.destination_organization_id = l_di_record.organization_id
                        AND prla.wip_operation_seq_num = l_di_record.task_number
                        AND prla.item_id is null
                        AND prla.wip_resource_seq_num = l_di_record.direct_item_sequence_id

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND UPPER(NVL(pl.cancel_flag,'N')) <> 'Y'
                        AND pd.wip_entity_id = l_di_record.wip_entity_id
                        AND pd.destination_organization_id = l_di_record.organization_id
                        AND pd.wip_operation_seq_num = l_di_record.task_number
                        AND pl.item_id is null
                        AND pd.wip_resource_seq_num = l_di_record.direct_item_sequence_id
                        AND pd.line_location_id not in(
	                        SELECT nvl(prla.line_location_id,0)
	                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
	                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
	                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
	                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
	                        AND prla.wip_entity_id =l_di_record.wip_entity_id
	                        AND prla.destination_organization_id = l_di_record.organization_id
	                        AND prla.wip_operation_seq_num = l_di_record.task_number
	                        AND prla.item_id is null
	                        AND prla.wip_resource_seq_num = l_di_record.direct_item_sequence_id)
                        );
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0;
                        END;

                ELSE  -- Don't trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN
                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/
                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id =l_di_record.wip_entity_id
                        AND pria.destination_organization_id = l_di_record.organization_id
                        AND pria.wip_operation_seq_num = l_di_record.task_number
                        AND pria.item_id is null
                        AND pria.wip_resource_seq_num = l_di_record.direct_item_sequence_id
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND prla.wip_entity_id =l_di_record.wip_entity_id
                        AND prla.destination_organization_id = l_di_record.organization_id
                        AND prla.wip_operation_seq_num = l_di_record.task_number
                        AND prla.item_id is null
                        AND prla.wip_resource_seq_num = l_di_record.direct_item_sequence_id

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_di_record.wip_entity_id
                        AND pd.destination_organization_id = l_di_record.organization_id
                        AND pd.wip_operation_seq_num = l_di_record.task_number
                        AND pl.item_id is null
                        AND pd.wip_resource_seq_num = l_di_record.direct_item_sequence_id
                        AND pd.line_location_id not in(
                               SELECT nvl(prla.line_location_id,0)
                               FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                               WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                               AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                               AND prla.wip_entity_id =l_di_record.wip_entity_id
                               AND prla.destination_organization_id = l_di_record.organization_id
                               AND prla.wip_operation_seq_num = l_di_record.task_number
                               AND prla.item_id is null
                               AND prla.wip_resource_seq_num = l_di_record.direct_item_sequence_id)
                        );
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0;
                        END;

                END IF;  --IF(l_req_for_cancel_qty_profile = 'Y') then

             ELSE
                --Bug4188160:pass description of item instead of item name
                l_description := l_di_record.description;

                IF(l_req_for_cancel_qty_profile = 'Y') then
                -- trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN

                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/

                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id = l_di_record.wip_entity_id
                        AND pria.destination_organization_id = l_di_record.organization_id
                        AND pria.wip_operation_seq_num = l_di_record.task_number
                        AND pria.item_id = l_di_record.inventory_item_id
                        AND pria.wip_resource_seq_num is null
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                        AND prla.wip_entity_id = l_di_record.wip_entity_id
                        AND prla.destination_organization_id = l_di_record.organization_id
                        AND prla.wip_operation_seq_num = l_di_record.task_number
                        AND prla.item_id = l_di_record.inventory_item_id
                        AND prla.wip_resource_seq_num is null

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(pl.cancel_flag,'N')) <> 'Y'
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_di_record.wip_entity_id
                        AND pd.destination_organization_id = l_di_record.organization_id
                        AND pd.wip_operation_seq_num = l_di_record.task_number
                        AND pl.item_id = l_di_record.inventory_item_id
                        AND pd.wip_resource_seq_num is null
                        AND pd.line_location_id not in(
                               SELECT nvl(prla.line_location_id,0)
                               FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                               WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                               AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                               AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                               AND prla.wip_entity_id =l_di_record.wip_entity_id
                               AND prla.destination_organization_id = l_di_record.organization_id
                               AND prla.wip_operation_seq_num = l_di_record.task_number
                               AND pl.item_id = l_di_record.inventory_item_id
                               AND prla.wip_resource_seq_num is null)
                        );


                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0 ;
                        END;

                ELSE  -- Don't trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN
                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/

                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id = l_di_record.wip_entity_id
                        AND pria.destination_organization_id = l_di_record.organization_id
                        AND pria.wip_operation_seq_num = l_di_record.task_number
                        AND pria.item_id = l_di_record.inventory_item_id
                        AND pria.wip_resource_seq_num is null
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND prla.wip_entity_id = l_di_record.wip_entity_id
                        AND prla.destination_organization_id = l_di_record.organization_id
                        AND prla.wip_operation_seq_num = l_di_record.task_number
                        AND prla.item_id = l_di_record.inventory_item_id
                        AND prla.wip_resource_seq_num is null

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_di_record.wip_entity_id
                        AND pd.destination_organization_id = l_di_record.organization_id
                        AND pd.wip_operation_seq_num = l_di_record.task_number
                        AND pl.item_id = l_di_record.inventory_item_id
                        AND pd.wip_resource_seq_num is null
                        AND pd.line_location_id not in(
                        	SELECT nvl(prla.line_location_id,0)
                        	FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        	WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        	AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        	AND prla.wip_entity_id =l_di_record.wip_entity_id
                        	AND prla.destination_organization_id = l_di_record.organization_id
                        	AND prla.wip_operation_seq_num = l_di_record.task_number
                        	AND pl.item_id = l_di_record.inventory_item_id
                                AND prla.wip_resource_seq_num is null)
                        );


                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       l_total_req_qty := 0 ;
                       END;

                 END IF; --IF(l_req_for_cancel_qty_profile = 'Y') then

             END IF;  -- IF l_di_record.direct_item_type_id = 1

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : DirectItemType(1:Description/2:Non-Stock) : '||l_di_record.direct_item_type_id||', Description: '||l_description);
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : WipentityId : '||l_di_record.wip_entity_id||', Operation : '||l_di_record.task_number);
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Inv Item Id : '||l_di_record.inventory_item_id||', Direct Item Seq Id: '||l_di_record.direct_item_sequence_id);
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : UOM : '||l_di_record.uom_code||', Unit Price : '||l_di_record.unit_price);
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Required Quantity : '||l_di_record.required_quantity||', Available Quantity : '||nvl(l_total_req_qty,0));
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Creating requisition for quantity : '||(l_di_record.required_quantity-nvl(l_total_req_qty,0)));
	END IF;

             create_requisition
               (  p_api_version                 => 1.0
                 ,p_init_msg_list               => FND_API.G_FALSE
                 ,p_commit                      => FND_API.G_FALSE
                 ,p_validate_only               => FND_API.G_TRUE
                 ,x_return_status               => l_api_return_status
                 ,x_msg_count                   => l_api_msg_count
                 ,x_msg_data                    => l_api_msg_data
                 ,p_wip_entity_id               => l_di_record.wip_entity_id
                 ,p_operation_seq_num           => l_di_record.task_number
                 ,p_organization_id             => l_di_record.organization_id
                 ,p_user_id                     => p_user_id
                 ,p_responsibility_id           => p_responsibility_id
                 ,p_quantity                    => (l_di_record.required_quantity-nvl(l_total_req_qty,0))  -- fix for 3421830
                 ,p_unit_price                  => l_di_record.unit_price
                 ,p_category_id                 => l_di_record.purchasing_category_id
                 ,p_item_description            => l_description
                 ,p_uom_code                    => l_di_record.uom_code
                 ,p_need_by_date                => l_di_record.date_required
                 ,p_inventory_item_id           => l_di_record.inventory_item_id
                 ,p_direct_item_id              => l_di_record.direct_item_sequence_id
                 ,p_suggested_vendor_id         => l_di_record.suggested_vendor_id
                 ,p_suggested_vendor_name       => l_di_record.suggested_vendor_name
                 ,p_suggested_vendor_site       => l_di_record.suggested_vendor_site
                 ,p_suggested_vendor_phone      => l_di_record.suggested_vendor_phone
                 ,p_suggested_vendor_item_num   => l_di_record.suggested_vendor_item_num);



             if nvl(l_api_return_status,'Q') <> 'S' then
               x_return_status := fnd_api.g_ret_sts_error;
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Creating reqs for the above direct item finished with status '||l_api_return_status);
		END IF;

             end if;

           end if;

         END LOOP;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : End=============================================================='); END IF;


         EXCEPTION

           when others then

             x_return_status := fnd_api.g_ret_sts_error;

           declare
             l_text varchar2(1000);
           begin
             l_text := sqlerrm;
             IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel : Creating reqs for direct items Error: , sqlerrm='||substrb(l_text,1,200));
	     END IF;
           end;

     END create_reqs_at_wo_rel;



     PROCEDURE create_reqs_at_di_upd
        (  p_api_version                 IN    NUMBER        := 1.0
          ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
          ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
          ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
          ,x_return_status               OUT NOCOPY   VARCHAR2
          ,x_msg_count                   OUT NOCOPY   NUMBER
          ,x_msg_data                    OUT NOCOPY   VARCHAR2
          ,p_user_id                     IN  NUMBER
          ,p_responsibility_id           IN  NUMBER
          ,p_wip_entity_id               IN    NUMBER        -- data
          ,p_organization_id             IN    NUMBER
          ,p_direct_item_sequence_id     IN    NUMBER
          ,p_inventory_item_id           IN    NUMBER
          ,p_required_quantity           IN    NUMBER)
     IS
       l_api_name       CONSTANT VARCHAR2(30) := 'create_reqs_at_di_upd';
       l_api_version    CONSTANT NUMBER       := 1.0;
       l_request_id              NUMBER;
       l_person_id               NUMBER;
       l_material_account        NUMBER;
       l_material_variance_account    NUMBER;
       l_currency       VARCHAR2(30);
       l_project_id     NUMBER;
       l_task_id        NUMBER;
       l_location_id    NUMBER;
       l_stmt_num       NUMBER;
       l_api_return_status  NUMBER;
       l_api_msg_count      NUMBER;
       l_api_msg_data       VARCHAR2(2000);
       TYPE DirectItemRec IS RECORD (
        wip_entity_id                  eam_direct_item_recs_v.wip_entity_id%TYPE,
        organization_id                eam_direct_item_recs_v.organization_id%TYPE,
        task_number                    eam_direct_item_recs_v.task_number%TYPE,
        inventory_item_id              eam_direct_item_recs_v.inventory_item_id%TYPE,
        direct_item_sequence_id        eam_direct_item_recs_v.direct_item_sequence_id%TYPE,
        direct_item_type_id            eam_direct_item_recs_v.direct_item_type_id%TYPE,
        description                    eam_direct_item_recs_v.description%TYPE,
        required_quantity              eam_direct_item_recs_v.required_quantity%TYPE,
        unit_price                     eam_direct_item_recs_v.unit_price%TYPE,
        uom_code                       eam_direct_item_recs_v.uom_code%TYPE,
        purchasing_category_id         eam_direct_item_recs_v.purchasing_category_id%TYPE,
        date_required                  eam_direct_item_recs_v.date_required%TYPE,
        auto_request_material          eam_direct_item_recs_v.auto_request_material%TYPE,
        suggested_vendor_id            eam_direct_item_recs_v.suggested_vendor_id%TYPE,
        suggested_vendor_name          eam_direct_item_recs_v.suggested_vendor_name%TYPE,
        suggested_vendor_site          eam_direct_item_recs_v.suggested_vendor_site%TYPE,
        suggested_vendor_phone         eam_direct_item_recs_v.suggested_vendor_phone%TYPE,
        suggested_vendor_item_num      eam_direct_item_recs_v.suggested_vendor_item_num%TYPE );

       TYPE l_di_recs_type IS REF CURSOR RETURN DirectItemRec;
       l_di_recs l_di_recs_type;
       l_di_record l_di_recs%ROWTYPE;

 BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Start========================================'); END IF;
    -- Standard Start of API savepoint
         l_stmt_num    := 10;
         SAVEPOINT create_requisition_pvt;

         l_stmt_num    := 20;
         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_stmt_num    := 30;
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;

         l_stmt_num    := 40;
         --  Initialize API return status to success
         x_return_status := fnd_api.g_ret_sts_success;

         l_stmt_num    := 50;

         -- API body

         IF NOT l_di_recs%ISOPEN THEN

           IF p_direct_item_sequence_id is not null then

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Description Direct Item Update'); END IF;

             OPEN l_di_recs FOR
             SELECT  wip_entity_id,
            organization_id,
            operation_seq_num as task_number,
            to_number(null) as inventory_item_id,
            direct_item_sequence_id,
            1 as direct_item_type_id,
            description,
            required_quantity,
            unit_price,
            uom as uom_code,
            purchasing_category_id,
            need_by_date as date_required,
            auto_request_material,
            SUGGESTED_VENDOR_ID,
            suggested_vendor_name,
            suggested_vendor_site,
            suggested_vendor_phone,
            suggested_vendor_item_num
           FROM wip_eam_direct_items
             WHERE wip_entity_id = p_wip_entity_id
           AND organization_id = p_organization_id
           AND direct_item_sequence_id = p_direct_item_sequence_id;

         ELSIF p_inventory_item_id is not null then

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Non-Stock Direct Item Update'); END IF;

             OPEN l_di_recs FOR
             SELECT wro.wip_entity_id,
            wro.organization_id,
            wro.operation_seq_num as task_number,
            wro.inventory_item_id,
            to_number(null) as direct_item_sequence_id,
            2 as direct_item_type_id,
            msi.description,
            wro.required_quantity,
            wro.unit_price,
            msi.primary_uom_code as uom_code,
            mic.category_id as purchasing_category_id,
            wro.date_required,
            wro.auto_request_material,
            vendor_id,
            wro.suggested_vendor_name,
            to_char(null) as suggested_vendor_site,
            to_char(null) as suggested_vendor_phone,
            to_char(null) as suggested_vendor_item_num
          FROM wip_requirement_operations wro,
            mtl_system_items_kfv msi,
            mtl_item_categories mic ,
            mtl_default_category_sets mdcs
              WHERE msi.inventory_item_id = wro.inventory_item_id
            AND msi.organization_id = wro.organization_id
            AND nvl(msi.stock_enabled_flag, 'N') = 'N'
            AND wro.inventory_item_id = mic.inventory_item_id
            AND wro.organization_id = mic.organization_id
            AND mic.category_set_id = mdcs.category_set_id
            AND mdcs.functional_area_id = 2
            AND wro.wip_entity_id = p_wip_entity_id
            AND wro.organization_id =  p_organization_id
            and wro.inventory_item_id = p_inventory_item_id;
           end if;

         END IF;

         LOOP

         FETCH l_di_recs INTO l_di_record;
         EXIT WHEN l_di_recs%NOTFOUND;

           if l_di_record.wip_entity_id is not null
              and l_di_record.auto_request_material = 'Y' then

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Direct Item Type(1:Description Direct /2:Non-Stock Direct ) : '||l_di_record.direct_item_type_id);
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : WipentityId: '||l_di_record.wip_entity_id||' Operation : '||l_di_record.task_number);
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Inv Item Id: '||l_di_record.inventory_item_id||' Dir Item Seq id: '||l_di_record.direct_item_sequence_id);
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : UOM : '||l_di_record.uom_code||' Unit Price : '||l_di_record.unit_price);
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : To be Requested Quantity : '||p_required_quantity||' , Description : '||l_di_record.description);
		END IF;

             --Bug4188160:pass description of item instead of item name
             create_requisition
               (  p_api_version                 => 1.0
                 ,p_init_msg_list               => FND_API.G_FALSE
                 ,p_commit                      => FND_API.G_FALSE
                 ,p_validate_only               => FND_API.G_TRUE
                 ,x_return_status               => l_api_return_status
                 ,x_msg_count                   => l_api_msg_count
                 ,x_msg_data                    => l_api_msg_data
                 ,p_wip_entity_id               => l_di_record.wip_entity_id
                 ,p_operation_seq_num           => l_di_record.task_number
                 ,p_organization_id             => l_di_record.organization_id
                 ,p_user_id                     => p_user_id
                 ,p_responsibility_id           => p_responsibility_id
                 ,p_quantity                    => p_required_quantity
                 ,p_unit_price                  => l_di_record.unit_price
                 ,p_category_id                 => l_di_record.purchasing_category_id
                 ,p_item_description            => l_di_record.description
                 ,p_uom_code                    => l_di_record.uom_code
                 ,p_need_by_date                => l_di_record.date_required
                 ,p_inventory_item_id           => l_di_record.inventory_item_id
                 ,p_direct_item_id              => l_di_record.direct_item_sequence_id
                 ,p_suggested_vendor_id       => l_di_record.suggested_vendor_id
                 ,p_suggested_vendor_name       => l_di_record.suggested_vendor_name
                 ,p_suggested_vendor_site       => l_di_record.suggested_vendor_site
                 ,p_suggested_vendor_phone      => l_di_record.suggested_vendor_phone
                 ,p_suggested_vendor_item_num   => l_di_record.suggested_vendor_item_num);


             if nvl(l_api_return_status,'Q') <> 'S' then
               x_return_status := fnd_api.g_ret_sts_error;
	       IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : create_requisition return status : '||l_api_return_status); END IF;

             end if;

           end if;

         END LOOP;
     CLOSE l_di_recs;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : End================================================='); END IF;

         EXCEPTION

           when others then

             x_return_status := fnd_api.g_ret_sts_error;

	   declare
             l_text varchar2(1000);
           begin
             l_text := sqlerrm;
             IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_di_upd : Creating reqs for direct items Error: , sqlerrm='||substrb(l_text,1,200));
	     END IF;
           end;
  END create_reqs_at_di_upd;



END EAM_PROCESS_WO_UTIL_PVT;

/
