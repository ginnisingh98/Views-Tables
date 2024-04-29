--------------------------------------------------------
--  DDL for Package Body CS_SR_WF_DUP_CHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_WF_DUP_CHK_PVT" AS
/* $Header: cswfdpcb.pls 120.1.12010000.2 2009/12/23 10:50:30 vpremach ship $ */

    PROCEDURE Check_SR_Channel
    (
        itemtype    VARCHAR2,
        itemkey	    VARCHAR2,
        actid	    NUMBER,
        funmode	    VARCHAR2,
        result	    OUT NOCOPY VARCHAR2
    )
    IS

        l_incident_id	NUMBER;

        CURSOR l_ServiceRequest_csr IS
          SELECT  sr_creation_channel
            FROM  cs_incidents_all_b
            WHERE incident_id = l_incident_id;

	    l_ServiceRequest_rec    l_ServiceRequest_csr%ROWTYPE;

    BEGIN

       IF (funmode = 'RUN') THEN

       -- Get the service request ID
          l_incident_id := WF_ENGINE.GetItemAttrNumber(
                           itemtype    => itemtype,
       		               itemkey     => itemkey,
                           aname       => 'REQUEST_ID' );

       -- Extract the service request record
          OPEN l_ServiceRequest_csr;
          FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

          IF l_ServiceRequest_rec.sr_creation_channel = 'WEB' or l_ServiceRequest_rec.sr_creation_channel = 'EMAIL' THEN
             result := 'Y';
          ELSE
             result := 'N';
          END IF;
          CLOSE l_ServiceRequest_csr;
       END IF;

    EXCEPTION
    WHEN OTHERS THEN
       WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Check_SR_Channel', itemtype, itemkey, actid, funmode);
       RAISE;

    END Check_SR_Channel;


    PROCEDURE Check_SR_Updated
    (
        itemtype    VARCHAR2,
        itemkey     VARCHAR2,
        actid       NUMBER,
        funmode     VARCHAR2,
        result      OUT NOCOPY VARCHAR2
    )
    IS
       l_incident_id             number;
       l_duplicate_check_profile varchar2(80);
       l_duplicate_criteria      varchar2(80);
       l_auto_task_profile       varchar2(80);
       l_task_error_note         varchar2(80);

       CURSOR l_ServiceRequest_csr IS
       SELECT  creation_date, last_update_date, object_version_number
         FROM  cs_incidents_all_b
        WHERE incident_id = l_incident_id;

       l_ServiceRequest_rec    l_ServiceRequest_csr%ROWTYPE;

   BEGIN
      IF (funmode = 'RUN') THEN

      -- Get the service request ID
         l_incident_id := WF_ENGINE.GetItemAttrNumber(
                          itemtype    => itemtype,
                          itemkey     => itemkey,
                          aname       => 'REQUEST_ID' );

      -- Extract the service request record
         OPEN l_ServiceRequest_csr;
         FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

         IF l_ServiceRequest_rec.object_version_number = 1 THEN
            result := 'N';

            l_duplicate_check_profile := FND_PROFILE.Value('CS_SR_DUP_CHK_SR');
            l_duplicate_criteria      := FND_PROFILE.Value('CS_SR_DUP_CHK_CRITERIA');
            l_auto_task_profile       := FND_PROFILE.value('CS_SR_AUTO_TASK_CREATE');
            l_task_error_note         := FND_PROFILE.value('CS_SR_TASK_ERROR_NOTE_TYPE');

            WF_ENGINE.SetItemAttrText(
                itemtype   => 'SERVEREQ',
                itemkey	   => itemkey,
                aname      => 'CS_DUPLICATE_CHECK_PROFILE',
                avalue     => l_duplicate_check_profile );

            WF_ENGINE.SetItemAttrText(
                itemtype   => 'SERVEREQ',
                itemkey	   => itemkey,
                aname      => 'CS_DUPLICATE_CRITERIA',
                avalue     => l_duplicate_criteria);

            WF_ENGINE.SetItemAttrText(
                itemtype   => 'SERVEREQ',
                itemkey	   => itemkey,
                aname      => 'CS_AUTO_TASK_PROFILE',
                avalue     => l_auto_task_profile );

            WF_ENGINE.SetItemAttrText(
                itemtype   => 'SERVEREQ',
                itemkey	   => itemkey,
                aname      => 'CS_TASK_FAILURE_NOTE_PROFILE',
                avalue     => l_task_error_note );

         ELSE
            result := 'Y';
         END IF;

      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Check_last_updated', itemtype, itemkey, actid, funmode);
      RAISE;

   END Check_SR_Updated;


    PROCEDURE Check_Duplicate_Profile
    (
        itemtype    VARCHAR2,
        itemkey	    VARCHAR2,
        actid       NUMBER,
        funmode	    VARCHAR2,
        result      OUT NOCOPY VARCHAR2
    )

    IS
       l_incident_id     NUMBER;
       l_duplicate_check_profile varchar2(80);

       CURSOR l_ServiceRequest_csr IS
       SELECT  creation_date, last_update_date
         FROM  cs_incidents_all_b
        WHERE incident_id = l_incident_id;

       l_ServiceRequest_rec    l_ServiceRequest_csr%ROWTYPE;

   BEGIN
      IF (funmode = 'RUN') THEN

         l_duplicate_check_profile := WF_ENGINE.GetItemAttrText(
                          itemtype    => itemtype,
                          itemkey     => itemkey,
                          aname       => 'CS_DUPLICATE_CHECK_PROFILE' );

         IF l_duplicate_check_profile = 'Y' THEN
            result := 'Y';
         ELSE
            result := 'N';
         END IF;

      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Check_last_updated', itemtype, itemkey, actid, funmode);
      RAISE;

   END Check_Duplicate_Profile;


    PROCEDURE Check_And_Perf_Dup_Check
    (
        itemtype    VARCHAR2,
        itemkey	    VARCHAR2,
        actid       NUMBER,
        funmode     VARCHAR2,
        result      OUT NOCOPY VARCHAR2
    )
   IS

        l_incident_id               NUMBER;
        l_ea_dup_chk                VARCHAR2(1);
        l_api_version               NUMBER := 1.0;
        l_init_msg_list	            VARCHAR2(1) ;
        l_commit                    VARCHAR2(1)	;
        l_validation_level          NUMBER;
        l_incident_type_id          NUMBER;
        l_customer_product_id       NUMBER;
        l_current_serial_number	    varchar2(30);
        l_inv_item_serial_number    varchar2(30);
        l_instance_serial_number    varchar2(30);
        l_customer_id               NUMBER;
        l_inventory_item_id	        NUMBER;
        l_cs_extended_attr          CS_SR_DUP_CHK_PVT.cs_extended_attr_tbl;
        l_incident_address          CS_SR_DUP_CHK_PVT.cs_incident_address_rec;
        l_duplicate_flag            VARCHAR2(1);
        l_sr_dupl_rec               CS_SR_DUP_CHK_PVT.Sr_Dupl_Tbl;
        l_return_status	            VARCHAR2(1);
        l_msg_count	                NUMBER;
        l_msg_data	                VARCHAR2(2000);
        l_dup_found_at              VARCHAR2(10);
	    l_counter                   NUMBER;
	    l_dup_criteria_profile	    VARCHAR2(30);


        CURSOR l_ServiceRequest_csr IS
        SELECT incident_id, incident_number, customer_id, inventory_item_id, customer_product_id,
               current_serial_number, item_serial_number,
               incident_type_id, incident_location_id,
               incident_Address, incident_city, incident_state, incident_country, incident_postal_code
          FROM cs_incidents_all_b
         WHERE incident_id = l_incident_id;

        l_ServiceRequest_rec   l_ServiceRequest_csr%ROWTYPE;

        CURSOR l_EA_Dup_Chk_csr IS
        SELECT conf.sr_dup_check_flag
          FROM cug_sr_type_dup_chk_info conf, cs_incidents_all_b inc
         WHERE conf.incident_type_id = inc.incident_type_id
           AND inc.incident_id = l_incident_id;

        CURSOR l_EA_Attr_csr IS
        SELECT incident_id, sr_attribute_code, sr_attribute_value
          FROM cug_incidnt_attr_vals_vl
         WHERE incident_id = l_incident_id;

        l_EA_Attr_rec          l_EA_Attr_csr%ROWTYPE;

   BEGIN
      IF (funmode = 'RUN') THEN

        l_duplicate_flag := 'N' ;

      -- Get the service request ID
         l_incident_id := WF_ENGINE.GetItemAttrNumber(
                          itemtype   => itemtype,
                          itemkey    => itemkey,
                          aname      => 'REQUEST_ID' );

      -- Extract the service request record
         OPEN l_ServiceRequest_csr;
         FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;
         l_incident_type_id := l_ServiceRequest_rec.incident_type_id;

--	     l_dup_criteria_profile := FND_PROFILE.Value('CS_SR_DUP_CHK_CRITERIA');
         l_dup_criteria_profile := WF_ENGINE.GetItemAttrText(
                          itemtype   => itemtype,
                          itemkey    => itemkey,
                          aname      => 'CS_DUPLICATE_CRITERIA' );


         IF ( l_dup_criteria_profile = 'CS_DUP_CRIT_EA_ADDR' OR
              l_dup_criteria_profile = 'CS_DUP_CRIT_WITHNO_SERIAL' OR
              l_dup_criteria_profile = 'CS_DUP_CRIT_WITH_SERIAL') THEN

            OPEN l_EA_Dup_Chk_csr;
            FETCH l_EA_Dup_Chk_csr INTO l_ea_dup_chk;

            IF l_EA_Dup_Chk_csr%FOUND and l_ea_dup_chk = 'Y' THEN

               l_counter := 0;
               FOR l_ea_attr_rec in l_ea_attr_csr LOOP
                  l_counter := l_counter + 1;
                  l_cs_extended_attr(l_counter).incident_type_id := l_ServiceRequest_rec.incident_type_id;
                  l_cs_extended_attr(l_counter).sr_attribute_code := l_EA_Attr_rec.sr_attribute_code;
                  l_cs_extended_attr(l_counter).sr_attribute_value := l_EA_Attr_rec.sr_attribute_value;
               END LOOP;

/*               OPEN l_EA_Attr_csr;
               LOOP
                  FETCH l_EA_Attr_csr INTO l_EA_Attr_rec;
                  EXIT WHEN l_EA_Attr_csr%NOTFOUND;

                  l_counter := l_counter + 1;
                  l_cs_extended_attr(l_counter).incident_type_id := l_ServiceRequest_rec.incident_type_id;
                  l_cs_extended_attr(l_counter).sr_attribute_code := l_EA_Attr_rec.sr_attribute_code;
                  l_cs_extended_attr(l_counter).sr_attribute_value := l_EA_Attr_rec.sr_attribute_value;
               END LOOP;
*/

               l_incident_address.Incident_address  := l_ServiceRequest_rec.Incident_address;
               l_incident_address.Incident_city	    := l_ServiceRequest_rec.Incident_city;
               l_incident_address.incident_state	:= l_ServiceRequest_rec.Incident_state;
               l_incident_address.incident_postal_code := l_ServiceRequest_rec.Incident_postal_code;
               l_incident_address.incident_country  := l_ServiceRequest_rec.Incident_country;
            END IF;
            CLOSE l_EA_Dup_Chk_Csr;

            IF l_dup_criteria_profile = 'CS_DUP_CRIT_WITH_SERIAL' THEN
               l_current_serial_number	  := l_ServiceRequest_rec.current_serial_number;
               l_inv_item_serial_number   := l_ServiceRequest_rec.item_serial_number;
            END IF;

            IF (l_dup_criteria_profile = 'CS_DUP_CRIT_WITHNO_SERIAL' OR
                l_dup_criteria_profile = 'CS_DUP_CRIT_WITH_SERIAL')  THEN
               IF l_ServiceRequest_rec.customer_product_id IS NOT NULL THEN
                  l_customer_product_id     := l_ServiceRequest_rec.customer_product_id;
                  l_current_serial_number   := NULL;
                  l_inv_item_serial_number  := NULL;
                  l_customer_id             := NULL;
                  l_inventory_item_id       := NULL;
               ELSE
                  l_customer_product_id     := NULL;
                  l_customer_id             := l_ServiceRequest_rec.customer_id;
                  l_inventory_item_id       := l_ServiceRequest_rec.inventory_item_id;
               END IF;
            END IF;

         ELSIF l_dup_criteria_profile = 'CS_DUP_CRIT_INST_CUST_PROD' THEN
            IF l_ServiceRequest_rec.customer_product_id IS NOT NULL THEN
               l_customer_product_id      := l_ServiceRequest_rec.customer_product_id;
               l_current_serial_number    := NULL;
               l_inv_item_serial_number   := NULL;
               l_customer_id              := NULL;
               l_inventory_item_id        := NULL;
            ELSE
               l_customer_product_id      := NULL;
               l_customer_id              := l_ServiceRequest_rec.customer_id;
               l_inventory_item_id        := l_ServiceRequest_rec.inventory_item_id;
               l_current_serial_number    := NULL;
               l_inv_item_serial_number   := NULL;
            END IF;

         ELSIF l_dup_criteria_profile = 'CS_DUP_CRIT_INST_CUST_PROD_SER' THEN
            IF l_ServiceRequest_rec.customer_product_id IS NOT NULL THEN
               l_customer_product_id       := l_ServiceRequest_rec.customer_product_id;
               l_current_serial_number     := NULL;
               l_inv_item_serial_number    := NULL;
               l_customer_id               := NULL;
               l_inventory_item_id         := NULL;
            ELSE
               l_customer_product_id       := NULL;
               l_customer_id               := l_ServiceRequest_rec.customer_id;
               l_inventory_item_id         := l_ServiceRequest_rec.inventory_item_id;
               l_current_serial_number     := l_ServiceRequest_rec.current_serial_number;
               l_inv_item_serial_number	   := l_ServiceRequest_rec.item_serial_number;
            END IF;
         END IF;

         cs_sr_dup_chk_pvt.duplicate_check
         (
          	p_api_version           => l_api_version,
            p_init_msg_list	        => l_init_msg_list,
            p_commit                => l_commit,
            p_validation_level      => l_validation_level,
            p_incident_id           => l_incident_id,
            p_incident_type_id      => l_incident_type_id,
            p_customer_product_id   => l_customer_product_id,
            p_current_serial_number => l_current_serial_number,
            p_instance_serial_number=> l_instance_serial_number,
            p_inv_item_serial_number=> l_inv_item_serial_number,
            p_customer_id           => l_customer_id,
            p_inventory_item_id	    => l_inventory_item_id,
            p_cs_extended_attr      => l_cs_extended_attr,
            p_incident_address      => l_incident_address,
            x_duplicate_flag        => l_duplicate_flag,
            x_sr_dupl_rec           => l_sr_dupl_rec,
            x_dup_found_at          => l_dup_found_at,
            x_return_status         => l_return_status,
            x_msg_count	            => l_msg_count,
            x_msg_data              => l_msg_data
         );

         IF l_duplicate_flag = 'T' THEN
            WF_ENGINE.SetItemAttrText(
                itemtype   => 'SERVEREQ',
                itemkey	   => itemkey,
                aname      => 'CS_DUPLICATE_FOUND_AT',
                avalue     => l_dup_found_at );
            result := 'Y';
         ELSE
            result := 'N';
         END IF;

      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Check_And_Perf_Dup_Check', itemtype, itemkey, actid, funmode);
      RAISE;

   END Check_And_Perf_Dup_Check;


   PROCEDURE Auto_Task_Create
    (
        itemtype    VARCHAR2,
        itemkey     VARCHAR2,
        actid       NUMBER,
        funmode     VARCHAR2,
        result      OUT NOCOPY VARCHAR2
    )
   IS
      l_incident_id           NUMBER;
      l_task_prof_value       VARCHAR2(30);
      l_api_version           NUMBER := 1.0;
      l_init_msg_list         VARCHAR2(1) ;
      l_commit                VARCHAR2(1)	;
      l_return_status         VARCHAR2(1);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(4000);
      l_msg_index_out         NUMBER;
      l_parent_noted_id       NUMBER;
      l_jtf_note_id           NUMBER;

      l_errmsg_name           VARCHAR2(2000);
      l_API_ERROR             EXCEPTION;

      l_sr_rec                CS_ServiceRequest_PVT.service_request_rec_type;
      l_sr_rec2               CS_ServiceRequest_PUB.service_request_rec_type;
      l_auto_Task_gen_rec     CS_AutoGen_Task_PVT.auto_task_gen_rec_type;
      l_ea_sr_attr_table_type CS_EA_AutoGen_Tasks_PVT.EA_SR_ATTR_TABLE_TYPE;

      l_counter                    NUMBER ;
      l_auto_task_gen_attemped     VARCHAR2(100);
      l_note_type                  VARCHAR2(80);
      l_field_service_task_created VARCHAR2(100);
      l_incident_number            CS_Incidents_All_B.incident_number%type;
      l_task_template_group_rec    JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info;
      l_task_template_table        JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl;

      l_err                     VARCHAR2(4000);
      l_login_id                jtf_notes_b.last_update_login%TYPE;
      l_user_id                 jtf_notes_b.last_updated_by%TYPE;
      l_note_id                 NUMBER;

      cursor l_incident_csr is
      select * from cs_incidents_all_b
       where incident_id = l_incident_id;
      l_incident_rec      l_incident_csr%ROWTYPE;

      CURSOR l_EA_Attr_csr IS
      SELECT sr_attribute_code, sr_attribute_value
        FROM cug_incidnt_attr_vals_vl
       WHERE incident_id = l_incident_id;
      l_EA_Attr_rec       l_EA_Attr_csr%ROWTYPE;

      --Added for bug 8849552
      CURSOR cur_tsk_obj_ver IS
      SELECT object_version_number
      FROM jtf_tasks_b
      WHERE source_object_id = l_incident_id
      and source_object_type_code = 'SR';
      l_tsk_obj_ver_number  NUMBER;

   BEGIN
      IF (funmode = 'RUN') THEN
         l_counter := 0;
--         l_task_prof_value := FND_PROFILE.value('CS_SR_AUTO_TASK_CREATE');
         l_task_prof_value := WF_ENGINE.GetItemAttrText(
                          itemtype  => itemtype,
                          itemkey   => itemkey,
                          aname     => 'CS_AUTO_TASK_PROFILE' );

         IF l_task_prof_value = 'NONE' THEN
            result := 'Y';
            return;
         END IF;

         l_incident_id := WF_ENGINE.GetItemAttrNumber(
                          itemtype  => itemtype,
                          itemkey   => itemkey,
                          aname     => 'REQUEST_ID' );

  --Added for bug 8849552
  /* Start*/
         OPEN cur_tsk_obj_ver;
         FETCH cur_tsk_obj_ver into l_tsk_obj_ver_number;
         IF (cur_tsk_obj_ver%NOTFOUND) THEN
             l_tsk_obj_ver_number := 0;
         END IF;
	 IF l_tsk_obj_ver_number <> 0 THEN
	    result := 'Y';
	    return;
	 END IF;
  /* End*/

         FOR l_rec IN l_incident_csr LOOP
            l_sr_rec.type_id                   := l_rec.incident_type_id;
            l_sr_rec.status_id                 := l_rec.incident_status_id;
            l_sr_rec.urgency_id                := l_rec.incident_urgency_id;
            l_sr_rec.severity_id               := l_rec.incident_severity_id;
            l_sr_rec.obligation_date           := l_rec.obligation_date;
            l_sr_rec.problem_code              := l_rec.problem_code;
            l_sr_rec.inventory_item_id         := l_rec.inventory_item_id;
            l_sr_rec.inventory_org_id          := l_rec.inv_organization_id;
            l_sr_rec.customer_id               := l_rec.customer_id;
            l_sr_rec.customer_number           := l_rec.customer_number;
            l_sr_rec.category_id               := l_rec.category_id;
            l_sr_rec.category_set_id           := l_rec.category_set_id;
            l_sr_rec.incident_location_id      := l_rec.incident_location_id;
            l_sr_rec.incident_location_type    := l_rec.incident_location_type;
            l_sr_rec.request_date              := l_rec.incident_date;
            l_sr_rec.type_id                   := l_rec.incident_type_id;
            l_sr_rec.status_id                 := l_rec.incident_status_id;
            l_sr_rec.severity_id               := l_rec.incident_severity_id;
            l_sr_rec.urgency_id                := l_rec.incident_urgency_id;
            l_sr_rec.closed_date               := l_rec.close_date;
            l_sr_rec.owner_id                  := l_rec.incident_owner_id;
            l_sr_rec.owner_group_id            := l_rec.owner_group_id;
            l_sr_rec.publish_flag              := l_rec.publish_flag;
            l_sr_rec.caller_type               := l_rec.caller_type;
            l_sr_rec.customer_id               := l_rec.customer_id;
            l_sr_rec.customer_number           := l_rec.customer_number;
            l_sr_rec.employee_id               := l_rec.employee_id;
            l_sr_rec.customer_product_id       := l_rec.customer_product_id;
            l_sr_rec.platform_id               := l_rec.platform_id;
            l_sr_rec.platform_version          := l_rec.platform_version;
            l_sr_rec.db_version                := l_rec.db_version;
            l_sr_rec.platform_version_id       := l_rec.platform_version_id;
            l_sr_rec.cp_component_id           := l_rec.cp_component_id;
            l_sr_rec.cp_component_version_id     := l_rec.cp_component_version_id;
            l_sr_rec.cp_subcomponent_id          := l_rec.cp_subcomponent_id;
            l_sr_rec.cp_subcomponent_version_id  := l_rec.cp_subcomponent_version_id;
            l_sr_rec.language_id                 := l_rec.language_id;
            l_sr_rec.inventory_item_id           := l_rec.inventory_item_id;
            l_sr_rec.inventory_org_id            := l_rec.inv_organization_id;
            l_sr_rec.current_serial_number       := l_rec.current_serial_number;
            l_sr_rec.original_order_number       := l_rec.original_order_number;
            l_sr_rec.problem_code                := l_rec.problem_code;
            l_sr_rec.exp_resolution_date         := l_rec.expected_resolution_date;
            l_sr_rec.install_site_use_id         := l_rec.install_site_use_id;
            l_sr_rec.request_attribute_1         := l_rec.incident_attribute_1;
            l_sr_rec.request_attribute_2         := l_rec.incident_attribute_2;
            l_sr_rec.request_attribute_3         := l_rec.incident_attribute_3;
            l_sr_rec.request_attribute_4         := l_rec.incident_attribute_4;
            l_sr_rec.request_attribute_5         := l_rec.incident_attribute_5;
            l_sr_rec.request_attribute_6         := l_rec.incident_attribute_6;
            l_sr_rec.request_attribute_7         := l_rec.incident_attribute_7;
            l_sr_rec.request_attribute_8         := l_rec.incident_attribute_8;
            l_sr_rec.request_attribute_9         := l_rec.incident_attribute_9;
            l_sr_rec.request_attribute_10        := l_rec.incident_attribute_10;
            l_sr_rec.request_attribute_11        := l_rec.incident_attribute_11;
            l_sr_rec.request_attribute_12        := l_rec.incident_attribute_12;
            l_sr_rec.request_attribute_13        := l_rec.incident_attribute_13;
            l_sr_rec.request_attribute_14        := l_rec.incident_attribute_14;
            l_sr_rec.request_attribute_15        := l_rec.incident_attribute_15;
            l_sr_rec.external_attribute_1        := l_rec.external_attribute_1;
            l_sr_rec.external_attribute_2        := l_rec.external_attribute_2;
            l_sr_rec.external_attribute_3        := l_rec.external_attribute_3;
            l_sr_rec.external_attribute_4        := l_rec.external_attribute_4;
            l_sr_rec.external_attribute_5        := l_rec.external_attribute_5;
            l_sr_rec.external_attribute_6        := l_rec.external_attribute_6;
            l_sr_rec.external_attribute_7        := l_rec.external_attribute_7;
            l_sr_rec.external_attribute_8        := l_rec.external_attribute_8;
            l_sr_rec.external_attribute_9        := l_rec.external_attribute_9;
            l_sr_rec.external_attribute_10       := l_rec.external_attribute_10;
            l_sr_rec.external_attribute_11       := l_rec.external_attribute_11;
            l_sr_rec.external_attribute_12       := l_rec.external_attribute_12;
            l_sr_rec.external_attribute_13       := l_rec.external_attribute_13;
            l_sr_rec.external_attribute_14       := l_rec.external_attribute_14;
            l_sr_rec.external_attribute_15       := l_rec.external_attribute_15;
            l_sr_rec.external_context            := l_rec.external_context;
            l_sr_rec.bill_to_site_use_id         := l_rec.bill_to_site_use_id;
            l_sr_rec.bill_to_contact_id          := l_rec.bill_to_contact_id;
            l_sr_rec.ship_to_site_use_id         := l_rec.ship_to_site_use_id;
            l_sr_rec.ship_to_contact_id          := l_rec.ship_to_contact_id;
            l_sr_rec.resolution_code             := l_rec.resolution_code;
            l_sr_rec.act_resolution_date         := l_rec.actual_resolution_date;
            l_sr_rec.contract_service_id         := l_rec.contract_service_id;
            l_sr_rec.contract_id                 := l_rec.contract_id;
            l_sr_rec.project_number              := l_rec.project_number;
            l_sr_rec.qa_collection_plan_id       := l_rec.qa_collection_id;
            l_sr_rec.account_id                  := l_rec.account_id;
            l_sr_rec.resource_type               := l_rec.resource_type;
            l_sr_rec.resource_subtype_id         := l_rec.resource_subtype_id;
            l_sr_rec.sr_creation_channel         := l_rec.sr_creation_channel;
            l_sr_rec.obligation_date             := l_rec.obligation_date;
            l_sr_rec.time_zone_id                := l_rec.time_zone_id;
            l_sr_rec.time_difference             := l_rec.time_difference;
            l_sr_rec.site_id                     := l_rec.site_id;
            l_sr_rec.customer_site_id            := l_rec.customer_site_id;
            l_sr_rec.territory_id                := l_rec.territory_id;
            l_sr_rec.cp_revision_id              := l_rec.cp_revision_id;
            l_sr_rec.inv_item_revision           := l_rec.inv_item_revision;
            l_sr_rec.inv_component_id            := l_rec.inv_component_id;
            l_sr_rec.inv_component_version       := l_rec.inv_component_version;
            l_sr_rec.inv_subcomponent_id         := l_rec.inv_subcomponent_id;
            l_sr_rec.inv_subcomponent_version    := l_rec.inv_subcomponent_version;
            l_sr_rec.tier                        := l_rec.tier;
            l_sr_rec.tier_version                := l_rec.tier_version;
            l_sr_rec.operating_system            := l_rec.operating_system;
            l_sr_rec.operating_system_version    := l_rec.operating_system_version;
            l_sr_rec.database                    := l_rec.database;
            l_sr_rec.cust_pref_lang_id           := l_rec.cust_pref_lang_id;
            l_sr_rec.category_id                 := l_rec.category_id;
            l_sr_rec.group_type                  := l_rec.group_type;
            l_sr_rec.group_territory_id          := l_rec.group_territory_id;
            l_sr_rec.inv_platform_org_id         := l_rec.inv_platform_org_id;
            l_sr_rec.component_version           := l_rec.component_version;
            l_sr_rec.subcomponent_version        := l_rec.subcomponent_version;
            l_sr_rec.comm_pref_code              := l_rec.comm_pref_code;
            l_sr_rec.cust_pref_lang_code         := l_rec.cust_pref_lang_code;
            l_sr_rec.last_update_channel         := l_rec.last_update_channel;
            l_sr_rec.category_set_id             := l_rec.category_set_id;
            l_sr_rec.external_reference          := l_rec.external_reference;
            l_sr_rec.system_id                   := l_rec.system_id;
            l_sr_rec.error_code                  := l_rec.error_code;
            l_sr_rec.incident_occurred_date      := l_rec.incident_occurred_date;
            l_sr_rec.incident_resolved_date      := l_rec.incident_resolved_date;
            l_sr_rec.inc_responded_by_date       := l_rec.inc_responded_by_date;
            l_sr_rec.incident_location_id        := l_rec.incident_location_id;
            l_sr_rec.incident_address            := l_rec.incident_address;
            l_sr_rec.incident_city               := l_rec.incident_city;
            l_sr_rec.incident_state              := l_rec.incident_state;
            l_sr_rec.incident_country            := l_rec.incident_country;
            l_sr_rec.incident_province           := l_rec.incident_province;
            l_sr_rec.incident_postal_code        := l_rec.incident_postal_code;
            l_sr_rec.incident_county             := l_rec.incident_country;
            l_sr_rec.cc_number                   := l_rec.credit_card_number;
            l_sr_rec.cc_expiration_date          := l_rec.credit_card_expiration_date;
            l_sr_rec.cc_type_code                := l_rec.credit_card_type_code;
            l_sr_rec.cc_first_name               := l_rec.credit_card_holder_fname;
            l_sr_rec.cc_last_name                := l_rec.credit_card_holder_lname;
            l_sr_rec.cc_middle_name              := l_rec.credit_card_holder_mname;
            l_sr_rec.cc_id                       := l_rec.credit_card_id;
            l_sr_rec.bill_to_account_id          := l_rec.bill_to_account_id;
            l_sr_rec.ship_to_account_id          := l_rec.ship_to_account_id;
            l_sr_rec.customer_phone_id   	     := l_rec.customer_phone_id;
            l_sr_rec.customer_email_id   	     := l_rec.customer_email_id;
            l_sr_rec.creation_program_code       := l_rec.creation_program_code;
            l_sr_rec.last_update_program_code    := l_rec.last_update_program_code;
            l_sr_rec.bill_to_party_id            := l_rec.bill_to_party_id;
            l_sr_rec.ship_to_party_id            := l_rec.ship_to_party_id;
            l_sr_rec.program_id                  := l_rec.program_id;
            l_sr_rec.program_application_id      := l_rec.program_application_id;
            l_sr_rec.program_login_id            := l_rec.program_login_id;
            l_sr_rec.bill_to_site_id             := l_rec.bill_to_site_id;
            l_sr_rec.ship_to_site_id             := l_rec.ship_to_site_id;
            l_sr_rec.incident_point_of_interest  := l_rec.incident_point_of_interest;
            l_sr_rec.incident_cross_street       := l_rec.incident_cross_street;
            l_sr_rec.incident_direction_qualifier:= l_rec.incident_direction_qualifier;
            l_sr_rec.incident_distance_qualifier := l_rec.incident_distance_qualifier;
            l_sr_rec.incident_distance_qual_uom  := l_rec.incident_distance_qual_uom;
            l_sr_rec.incident_address2           := l_rec.incident_address2;
            l_sr_rec.incident_address3           := l_rec.incident_address3;
            l_sr_rec.incident_address4           := l_rec.incident_address4;
            l_sr_rec.incident_address_style      := l_rec.incident_address_style;
            l_sr_rec.incident_addr_lines_phonetic:= l_rec.incident_addr_lines_phonetic;
            l_sr_rec.incident_po_box_number      := l_rec.incident_po_box_number;
            l_sr_rec.incident_house_number       := l_rec.incident_house_number;
            l_sr_rec.incident_street_suffix      := l_rec.incident_street_suffix;
            l_sr_rec.incident_street             := l_rec.incident_street;
            l_sr_rec.incident_street_number      := l_rec.incident_street_number;
            l_sr_rec.incident_floor              := l_rec.incident_floor;
            l_sr_rec.incident_suite              := l_rec.incident_suite;
            l_sr_rec.incident_postal_plus4_code  := l_rec.incident_postal_plus4_code;
            l_sr_rec.incident_position           := l_rec.incident_position;
            l_sr_rec.incident_location_directions:= l_rec.incident_location_directions;
            l_sr_rec.incident_location_description := l_rec.incident_location_description;
            l_sr_rec.install_site_id             := l_rec.install_site_id;

            l_sr_rec2.type_id                    := l_rec.incident_type_id;
            l_sr_rec2.status_id                  := l_rec.incident_status_id;
            l_sr_rec2.urgency_id                 := l_rec.incident_urgency_id;
            l_sr_rec2.severity_id                := l_rec.incident_severity_id;
            l_sr_rec2.obligation_date            := l_rec.obligation_date;
            l_sr_rec2.problem_code               := l_rec.problem_code;
            l_sr_rec2.inventory_item_id          := l_rec.inventory_item_id;
            l_sr_rec2.inventory_org_id           := l_rec.inv_organization_id;
            l_sr_rec2.customer_id                := l_rec.customer_id;
            l_sr_rec2.customer_number            := l_rec.customer_number;
            l_sr_rec2.category_id                := l_rec.category_id;
            l_sr_rec2.category_set_id            := l_rec.category_set_id;
            l_sr_rec2.incident_location_id       := l_rec.incident_location_id;
            l_sr_rec2.incident_location_type     := l_rec.incident_location_type;
            l_sr_rec2.request_date               := l_rec.incident_date;
            l_sr_rec2.type_id                    := l_rec.incident_type_id;
            l_sr_rec2.status_id                  := l_rec.incident_status_id;
            l_sr_rec2.severity_id                := l_rec.incident_severity_id;
            l_sr_rec2.urgency_id                 := l_rec.incident_urgency_id;
            l_sr_rec2.closed_date                := l_rec.close_date;
            l_sr_rec2.owner_id                   := l_rec.incident_owner_id;
            l_sr_rec2.owner_group_id             := l_rec.owner_group_id;
            l_sr_rec2.publish_flag               := l_rec.publish_flag;
            l_sr_rec2.caller_type                := l_rec.caller_type;
            l_sr_rec2.customer_id                := l_rec.customer_id;
            l_sr_rec2.customer_number            := l_rec.customer_number;
            l_sr_rec2.employee_id                := l_rec.employee_id;
            l_sr_rec2.customer_product_id 		 := l_rec.customer_product_id;
            l_sr_rec2.platform_id         		 := l_rec.platform_id;
            l_sr_rec2.platform_version	  		 := l_rec.platform_version;
            l_sr_rec2.db_version		         := l_rec.db_version;
            l_sr_rec2.platform_version_id 		 := l_rec.platform_version_id;
            l_sr_rec2.cp_component_id            := l_rec.cp_component_id;
            l_sr_rec2.cp_component_version_id     := l_rec.cp_component_version_id;
            l_sr_rec2.cp_subcomponent_id          := l_rec.cp_subcomponent_id;
            l_sr_rec2.cp_subcomponent_version_id  := l_rec.cp_subcomponent_version_id;
            l_sr_rec2.language_id                 := l_rec.language_id;
            l_sr_rec2.inventory_item_id           := l_rec.inventory_item_id;
            l_sr_rec2.inventory_org_id            := l_rec.inv_organization_id;
            l_sr_rec2.current_serial_number       := l_rec.current_serial_number;
            l_sr_rec2.original_order_number       := l_rec.original_order_number;
            l_sr_rec2.problem_code                := l_rec.problem_code;
            l_sr_rec2.exp_resolution_date         := l_rec.expected_resolution_date;
            l_sr_rec2.install_site_use_id         := l_rec.install_site_use_id;
            l_sr_rec2.request_attribute_1         := l_rec.incident_attribute_1;
            l_sr_rec2.request_attribute_2         := l_rec.incident_attribute_2;
            l_sr_rec2.request_attribute_3         := l_rec.incident_attribute_3;
            l_sr_rec2.request_attribute_4         := l_rec.incident_attribute_4;
            l_sr_rec2.request_attribute_5         := l_rec.incident_attribute_5;
            l_sr_rec2.request_attribute_6         := l_rec.incident_attribute_6;
            l_sr_rec2.request_attribute_7         := l_rec.incident_attribute_7;
            l_sr_rec2.request_attribute_8         := l_rec.incident_attribute_8;
            l_sr_rec2.request_attribute_9         := l_rec.incident_attribute_9;
            l_sr_rec2.request_attribute_10        := l_rec.incident_attribute_10;
            l_sr_rec2.request_attribute_11        := l_rec.incident_attribute_11;
            l_sr_rec2.request_attribute_12        := l_rec.incident_attribute_12;
            l_sr_rec2.request_attribute_13        := l_rec.incident_attribute_13;
            l_sr_rec2.request_attribute_14        := l_rec.incident_attribute_14;
            l_sr_rec2.request_attribute_15        := l_rec.incident_attribute_15;
            l_sr_rec2.external_attribute_1        := l_rec.external_attribute_1;
            l_sr_rec2.external_attribute_2        := l_rec.external_attribute_2;
            l_sr_rec2.external_attribute_3        := l_rec.external_attribute_3;
            l_sr_rec2.external_attribute_4        := l_rec.external_attribute_4;
            l_sr_rec2.external_attribute_5        := l_rec.external_attribute_5;
            l_sr_rec2.external_attribute_6        := l_rec.external_attribute_6;
            l_sr_rec2.external_attribute_7        := l_rec.external_attribute_7;
            l_sr_rec2.external_attribute_8        := l_rec.external_attribute_8;
            l_sr_rec2.external_attribute_9        := l_rec.external_attribute_9;
            l_sr_rec2.external_attribute_10       := l_rec.external_attribute_10;
            l_sr_rec2.external_attribute_11       := l_rec.external_attribute_11;
            l_sr_rec2.external_attribute_12       := l_rec.external_attribute_12;
            l_sr_rec2.external_attribute_13       := l_rec.external_attribute_13;
            l_sr_rec2.external_attribute_14       := l_rec.external_attribute_14;
            l_sr_rec2.external_attribute_15       := l_rec.external_attribute_15;
            l_sr_rec2.external_context            := l_rec.external_context;
            l_sr_rec2.bill_to_site_use_id         := l_rec.bill_to_site_use_id;
            l_sr_rec2.bill_to_contact_id          := l_rec.bill_to_contact_id;
            l_sr_rec2.ship_to_site_use_id         := l_rec.ship_to_site_use_id;
            l_sr_rec2.ship_to_contact_id          := l_rec.ship_to_contact_id;
            l_sr_rec2.resolution_code             := l_rec.resolution_code;
            l_sr_rec2.act_resolution_date         := l_rec.actual_resolution_date;
            l_sr_rec2.contract_service_id         := l_rec.contract_service_id;
            l_sr_rec2.contract_id                 := l_rec.contract_id;
            l_sr_rec2.project_number              := l_rec.project_number;
            l_sr_rec2.qa_collection_plan_id       := l_rec.qa_collection_id;
            l_sr_rec2.account_id                  := l_rec.account_id;
            l_sr_rec2.resource_type               := l_rec.resource_type;
            l_sr_rec2.resource_subtype_id         := l_rec.resource_subtype_id;
            l_sr_rec2.sr_creation_channel         := l_rec.sr_creation_channel;
            l_sr_rec2.obligation_date             := l_rec.obligation_date;
            l_sr_rec2.time_zone_id                := l_rec.time_zone_id;
            l_sr_rec2.time_difference             := l_rec.time_difference;
            l_sr_rec2.site_id                     := l_rec.site_id;
            l_sr_rec2.customer_site_id            := l_rec.customer_site_id;
            l_sr_rec2.territory_id                := l_rec.territory_id;
            l_sr_rec2.cp_revision_id              := l_rec.cp_revision_id;
            l_sr_rec2.inv_item_revision           := l_rec.inv_item_revision;
            l_sr_rec2.inv_component_id            := l_rec.inv_component_id;
            l_sr_rec2.inv_component_version       := l_rec.inv_component_version;
            l_sr_rec2.inv_subcomponent_id         := l_rec.inv_subcomponent_id;
            l_sr_rec2.inv_subcomponent_version    := l_rec.inv_subcomponent_version;
            l_sr_rec2.tier                        := l_rec.tier;
            l_sr_rec2.tier_version                := l_rec.tier_version;
            l_sr_rec2.operating_system            := l_rec.operating_system;
            l_sr_rec2.operating_system_version    := l_rec.operating_system_version;
            l_sr_rec2.database                    := l_rec.database;
            l_sr_rec2.cust_pref_lang_id           := l_rec.cust_pref_lang_id;
            l_sr_rec2.category_id                 := l_rec.category_id;
            l_sr_rec2.group_type                  := l_rec.group_type;
            l_sr_rec2.group_territory_id          := l_rec.group_territory_id;
            l_sr_rec2.inv_platform_org_id         := l_rec.inv_platform_org_id;
            l_sr_rec2.component_version           := l_rec.component_version;
            l_sr_rec2.subcomponent_version        := l_rec.subcomponent_version;
            l_sr_rec2.comm_pref_code              := l_rec.comm_pref_code;
            l_sr_rec2.cust_pref_lang_code         := l_rec.cust_pref_lang_code;
            l_sr_rec2.last_update_channel         := l_rec.last_update_channel;
            l_sr_rec2.category_set_id             := l_rec.category_set_id;
            l_sr_rec2.external_reference          := l_rec.external_reference;
            l_sr_rec2.system_id                   := l_rec.system_id;
            l_sr_rec2.error_code                  := l_rec.error_code;
            l_sr_rec2.incident_occurred_date      := l_rec.incident_occurred_date;
            l_sr_rec2.incident_resolved_date      := l_rec.incident_resolved_date;
            l_sr_rec2.inc_responded_by_date       := l_rec.inc_responded_by_date;
            l_sr_rec2.incident_location_id        := l_rec.incident_location_id;
            l_sr_rec2.incident_address            := l_rec.incident_address;
            l_sr_rec2.incident_city               := l_rec.incident_city;
            l_sr_rec2.incident_state              := l_rec.incident_state;
            l_sr_rec2.incident_country            := l_rec.incident_country;
            l_sr_rec2.incident_province           := l_rec.incident_province;
            l_sr_rec2.incident_postal_code        := l_rec.incident_postal_code;
            l_sr_rec2.incident_county             := l_rec.incident_country;
            l_sr_rec2.cc_number                   := l_rec.credit_card_number;
            l_sr_rec2.cc_expiration_date          := l_rec.credit_card_expiration_date;
            l_sr_rec2.cc_type_code                := l_rec.credit_card_type_code;
            l_sr_rec2.cc_first_name               := l_rec.credit_card_holder_fname;
            l_sr_rec2.cc_last_name                := l_rec.credit_card_holder_lname;
            l_sr_rec2.cc_middle_name              := l_rec.credit_card_holder_mname;
            l_sr_rec2.cc_id                       := l_rec.credit_card_id;
            l_sr_rec2.bill_to_account_id          := l_rec.bill_to_account_id;
            l_sr_rec2.ship_to_account_id          := l_rec.ship_to_account_id;
            l_sr_rec2.customer_phone_id   	     := l_rec.customer_phone_id;
            l_sr_rec2.customer_email_id   	     := l_rec.customer_email_id;
            l_sr_rec2.creation_program_code       := l_rec.creation_program_code;
            l_sr_rec2.last_update_program_code    := l_rec.last_update_program_code;
            l_sr_rec2.bill_to_party_id            := l_rec.bill_to_party_id;
            l_sr_rec2.ship_to_party_id            := l_rec.ship_to_party_id;
            l_sr_rec2.program_id                  := l_rec.program_id;
            l_sr_rec2.program_application_id      := l_rec.program_application_id;
            l_sr_rec2.program_login_id            := l_rec.program_login_id;
            l_sr_rec2.bill_to_site_id             := l_rec.bill_to_site_id;
            l_sr_rec2.ship_to_site_id             := l_rec.ship_to_site_id;
            l_sr_rec2.incident_point_of_interest  := l_rec.incident_point_of_interest;
            l_sr_rec2.incident_cross_street       := l_rec.incident_cross_street;
            l_sr_rec2.incident_direction_qualifier:= l_rec.incident_direction_qualifier;
            l_sr_rec2.incident_distance_qualifier := l_rec.incident_distance_qualifier;
            l_sr_rec2.incident_distance_qual_uom  := l_rec.incident_distance_qual_uom;
            l_sr_rec2.incident_address2           := l_rec.incident_address2;
            l_sr_rec2.incident_address3           := l_rec.incident_address3;
            l_sr_rec2.incident_address4           := l_rec.incident_address4;
            l_sr_rec2.incident_address_style      := l_rec.incident_address_style;
            l_sr_rec2.incident_addr_lines_phonetic:= l_rec.incident_addr_lines_phonetic;
            l_sr_rec2.incident_po_box_number      := l_rec.incident_po_box_number;
            l_sr_rec2.incident_house_number       := l_rec.incident_house_number;
            l_sr_rec2.incident_street_suffix      := l_rec.incident_street_suffix;
            l_sr_rec2.incident_street             := l_rec.incident_street;
            l_sr_rec2.incident_street_number      := l_rec.incident_street_number;
            l_sr_rec2.incident_floor              := l_rec.incident_floor;
            l_sr_rec2.incident_suite              := l_rec.incident_suite;
            l_sr_rec2.incident_postal_plus4_code  := l_rec.incident_postal_plus4_code;
            l_sr_rec2.incident_position           := l_rec.incident_position;
            l_sr_rec2.incident_location_directions:= l_rec.incident_location_directions;
            l_sr_rec2.incident_location_description := l_rec.incident_location_description;
            l_sr_rec2.install_site_id             := l_rec.install_site_id;

            l_incident_number                     := l_rec.incident_number;

         END LOOP;
--         l_sr_rec2 := l_sr_rec;

         IF l_task_prof_value = 'TASK_TMPL' THEN

            CS_AutoGen_Task_PVT.Auto_Generate_Tasks
            (
              p_api_version               => l_api_version,
              p_init_msg_list             => l_init_msg_list,
              p_commit                    => l_commit,
              p_validation_level          => fnd_api.g_valid_level_full,
              p_incident_id				 => l_incident_id,
              p_service_request_rec       => l_sr_rec,
              p_task_template_group_owner => NULL,
              p_task_tmpl_group_owner_type=> NULL,
              p_task_template_group_rec   => l_task_template_group_rec,
              p_task_template_table       => l_task_template_table,
              x_auto_task_gen_rec         => l_auto_Task_gen_rec,
              x_return_status             => l_return_status,
              x_msg_count                 => l_msg_count,
              x_msg_data                  => l_msg_data );

         ELSIF l_task_prof_value = 'TASK_CONF' THEN
            l_counter := 0;
            FOR l_ea_attr_rec in l_ea_attr_csr LOOP
               l_counter := l_counter + 1;
               l_ea_sr_attr_table_type(l_counter).sr_attribute_code := l_ea_attr_rec.sr_attribute_code;
               l_ea_sr_attr_table_type(l_counter).sr_attribute_value := l_ea_attr_rec.sr_attribute_value;
            END LOOP;
/*
            OPEN l_ea_attr_csr;
            FETCH l_ea_attr_csr BULK COLLECT INTO l_ea_sr_attr_table_type;
            CLOSE l_ea_attr_csr;
*/

            CS_EA_AutoGen_Tasks_PVT.Create_Extnd_Attr_Tasks
            (
               p_api_version                => l_api_version,
               p_init_msg_list              => l_init_msg_list,
               p_commit                     => l_commit,
               p_sr_rec                     => l_sr_rec2,
               p_sr_attributes_tbl          => l_ea_sr_attr_table_type,
               p_REQUEST_ID                 => l_incident_id,
               p_incident_number            => l_incident_number,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data,
               x_auto_task_gen_attempted    => l_auto_task_gen_attemped,
               x_field_service_Task_created => l_field_service_task_created
             );
         END IF;

         IF (l_return_status <> 'S') THEN
            for i in 1..l_msg_count loop
               FND_MSG_PUB.Get(p_msg_index=>i,
                               p_encoded=>'F',
                               p_data=>l_msg_data,
                               p_msg_index_out=>l_msg_index_out);
               l_err := l_err || l_msg_data ;
            end loop;

--            l_note_type := fnd_profile.value('CS_SR_TASK_ERROR_NOTE_TYPE');
            l_note_type := WF_ENGINE.GetItemAttrText(
                             itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'CS_TASK_FAILURE_NOTE_PROFILE' );

            IF (l_note_type is null) THEN
               fnd_msg_pub.initialize;
               fnd_message.set_name ('CS', 'CS_EA_NULL_NOTE_TYPE');
               fnd_msg_pub.add;

               raise l_api_error;
            END IF;

            l_return_status := NULL;
            l_login_id := fnd_global.login_id;
            l_user_id  := fnd_global.user_id ;

            jtf_notes_pub.create_note
            (
               p_parent_note_id     => l_parent_noted_id,
               p_jtf_note_id        => l_jtf_note_id,
               p_api_version        => 1,
               p_init_msg_list      => l_init_msg_list,
               p_commit             => l_commit,
               p_validation_level   => fnd_api.g_valid_level_full,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_entered_by         => l_user_id,
               p_entered_date       => sysdate,
               p_last_update_date   => sysdate,
               p_last_updated_by    => l_user_id,
               p_creation_date      => sysdate,
               p_created_by         => l_user_id,
               p_last_update_login  => l_login_id,
               p_source_object_id   => l_incident_id,
               p_source_object_code => 'SR',
               p_notes              => l_err,
               p_notes_detail       => l_err,
               p_note_type          => l_note_type,
               p_note_status        => 'P',
               x_jtf_note_id        => l_note_id
            );
         END IF;
      END IF;

   EXCEPTION
   WHEN l_API_ERROR THEN
       l_errmsg_name := NULL;
       for i in 1..l_msg_count loop
          FND_MSG_PUB.Get(p_msg_index=>i,
                          p_encoded=>'F',
                          p_data=>l_msg_data,
                          p_msg_index_out=>l_msg_index_out);
          l_errmsg_name := l_errmsg_name || l_msg_data ;
       end loop;
       WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Auto_Task_Create - '|| l_errmsg_name || ' ....(' || l_err || ')....',
                      itemtype, itemkey, actid, funmode);
       RAISE;

   WHEN OTHERS THEN
       WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Auto_Task_Create - ' || sqlerrm,
  		      itemtype, itemkey, actid, funmode);
       RAISE;

   END Auto_Task_Create;


   PROCEDURE Setup_Notify_Name
   (
      itemtype   VARCHAR2,
      itemkey    VARCHAR2,
      actid      NUMBER,
      funmode    VARCHAR2,
      result     OUT NOCOPY VARCHAR2
   )
   IS

      l_return_status     VARCHAR2(1);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);
      l_incident_id       NUMBER;
      l_dup_found_at      VARCHAR2(10);

      l_owner_role        VARCHAR2(100);
      l_owner_name        VARCHAR2(240);

      l_errmsg_name       VARCHAR2(30);
      l_API_ERROR         EXCEPTION;

      CURSOR l_ServiceRequest_csr IS
      SELECT emp.source_id incident_owner_id
        FROM cs_incidents_all_vl inc ,jtf_rs_resource_extns emp
       WHERE inc.INCIDENT_OWNER_ID = emp.resource_id AND
             incident_id = l_incident_id;

      l_ServiceRequest_rec    l_ServiceRequest_csr%ROWTYPE;

      CURSOR l_EA_Recipient_notify_csr IS
      SELECT  emp.source_id incident_owner_id
        FROM  cug_sr_type_dup_chk_info maps, cs_incidents_all_b sr, jtf_rs_resource_extns emp
       WHERE maps.incident_type_id = sr.incident_type_id
         AND maps.resource_id = emp.resource_id
         AND sr.incident_id = l_incident_id;

      l_EA_Recipient_Notify_rec	l_EA_Recipient_Notify_csr%ROWTYPE;

   BEGIN

      IF (funmode = 'RUN') THEN

         l_incident_id := WF_ENGINE.GetItemAttrNumber(
                          itemtype    => itemtype,
                          itemkey     => itemkey,
                          aname       => 'REQUEST_ID' );

         l_dup_found_at := WF_ENGINE.GetItemAttrText(
                           itemtype   => itemtype,
                           itemkey    => itemkey,
                           aname      => 'CS_DUPLICATE_FOUND_AT' );

         IF l_dup_found_at = 'BOTH' or l_dup_found_at = 'SR' THEN

            OPEN l_ServiceRequest_csr;
            FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

            IF (l_ServiceRequest_rec.incident_owner_id is not null) THEN
            -- Retrieve the role name for the request owner
               CS_WORKFLOW_PUB.Get_Employee_Role (
                  p_api_version	   =>  1.0,
                  p_return_status  =>  l_return_status,
                  p_msg_count      =>  l_msg_count,
                  p_msg_data       =>  l_msg_data,
                  p_employee_id    =>  l_ServiceRequest_rec.incident_owner_id,
                  p_role_name      =>  l_owner_role,
                  p_role_display_name =>  l_owner_name );

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_owner_role is NULL) THEN
                  wf_core.context(
                     pkg_name   => 'CS_WORKFLOW_PUB',
                     proc_name  => 'Get_Employee_Role',
                     arg1       => 'p_employee_id=>'||to_char(l_ServiceRequest_rec.incident_owner_id));
                  l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
                  raise l_API_ERROR;
               END IF;

               WF_ENGINE.SetItemAttrText(
                   itemtype   => 'SERVEREQ',
                   itemkey    => itemkey,
                   aname      => 'OWNER_NAME',
                   avalue     => l_owner_name );

               WF_ENGINE.SetItemAttrText(
                   itemtype   => 'SERVEREQ',
                   itemkey    => itemkey,
                   aname      => 'OWNER_ROLE',
                   avalue     => l_owner_role );
            END IF;
            CLOSE l_ServiceRequest_csr;
         END IF;

         IF l_dup_found_at = 'BOTH' or l_dup_found_at = 'EA' THEN
            OPEN l_EA_Recipient_Notify_csr;
            FETCH l_EA_Recipient_Notify_csr INTO l_EA_Recipient_Notify_rec;

            IF (l_EA_Recipient_Notify_rec.incident_owner_id is not null) THEN
             -- Retrieve the role name for the request owner
               CS_WORKFLOW_PUB.Get_Employee_Role (
                   p_api_version        =>  1.0,
                   p_return_status      =>  l_return_status,
                   p_msg_count          =>  l_msg_count,
                   p_msg_data           =>  l_msg_data,
                   p_employee_id        =>  l_EA_Recipient_Notify_rec.incident_owner_id,
                   p_role_name          =>  l_owner_role,
                   p_role_display_name	=>  l_owner_name );

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_owner_role is NULL) THEN
                  wf_core.context(
                      pkg_name   => 'CS_WORKFLOW_PUB',
                      proc_name  => 'Get_Employee_Role',
                      arg1       => 'p_employee_id=>'||to_char(l_EA_Recipient_Notify_rec.incident_owner_id));
                  l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
                  raise l_API_ERROR;
               END IF;

               WF_ENGINE.SetItemAttrText(
                  itemtype  => 'SERVEREQ',
                  itemkey   => itemkey,
                  aname     => 'CS_EA_SR_OWNER_NOTIFY',
                  avalue    => l_owner_role );

/*
               WF_ENGINE.SetItemAttrText(
                  itemtype  => 'SERVEREQ',
                  itemkey   => itemkey,
                  aname     => 'CS_EA_SR_OWNER_NOTIFY',
                  avalue    => l_owner_name );
*/
            END IF;
            CLOSE l_EA_Recipient_Notify_csr;
         END IF;

         IF l_dup_found_at = 'BOTH' THEN
            result := 'CS_BOTH';
         ELSIF l_dup_found_at = 'SR' THEN
            result := 'CS_SR';
         ELSIF l_dup_found_at = 'EA' THEN
            result := 'CS_EA';
         END IF;

      END IF;

   EXCEPTION
   WHEN l_API_ERROR THEN
        WF_CORE.Raise(l_errmsg_name);

   WHEN OTHERS THEN
        WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Setup_Notify_Name',
               itemtype, itemkey, actid, funmode);
        RAISE;

   END Setup_Notify_Name;


   PROCEDURE Check_SR_Owner_To_Notify
   (
      itemtype   VARCHAR2,
      itemkey    VARCHAR2,
      actid      NUMBER,
      funmode    VARCHAR2,
      result     OUT NOCOPY VARCHAR2
   )
   IS
      l_incident_id	   NUMBER;

      CURSOR l_ServiceRequest_csr IS
      SELECT  incident_owner_id
        FROM  cs_incidents_all_b inc
       WHERE incident_id = l_incident_id;

      l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;

   BEGIN

      IF (funmode = 'RUN') THEN

         l_incident_id := WF_ENGINE.GetItemAttrNumber(
            itemtype   => itemtype,
            itemkey	   => itemkey,
            aname      => 'REQUEST_ID' );

         OPEN l_ServiceRequest_csr;
         FETCH l_ServiceRequest_csr into l_ServiceRequest_rec;

         IF l_ServiceRequest_rec.incident_owner_id IS NULL THEN
            result := 'N';
         ELSE
            result := 'Y';
         END IF;
         CLOSE l_ServiceRequest_csr;
      END IF;
   EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.Context('CS_SR_WF_DUP_CHK_PVT', 'Setup_Notify_Name',
            itemtype, itemkey, actid, funmode);
      RAISE;

   END Check_SR_Owner_To_Notify;

END CS_SR_WF_DUP_CHK_PVT;

/
