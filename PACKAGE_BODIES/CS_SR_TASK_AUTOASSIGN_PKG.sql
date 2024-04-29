--------------------------------------------------------
--  DDL for Package Body CS_SR_TASK_AUTOASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_TASK_AUTOASSIGN_PKG" as
/* $Header: csxasrtb.pls 120.9.12010000.4 2009/09/01 07:03:56 gasankar ship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_SR_TASK_AUTOASSIGN_PKG';

/***********************
Define Local Procedures
***********************/
PROCEDURE Assign_Group
  (p_init_msg_list        IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit               IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_incident_id          IN   NUMBER,
   p_total_emp            IN   NUMBER   DEFAULT NULL,
   p_party_name           IN   VARCHAR2 DEFAULT NULL,
   p_service_request_rec  IN   CS_ServiceRequest_PUB.service_request_rec_type,
   p_task_attribute_rec   IN   SR_Task_rec_type,
   x_return_status        OUT  NOCOPY   VARCHAR2,
   x_group_id             OUT  NOCOPY   NUMBER,
   x_group_type           OUT  NOCOPY   VARCHAR2,
   x_territory_id         OUT   NOCOPY   NUMBER,
   x_msg_count            OUT  NOCOPY   NUMBER,
   x_msg_data             OUT  NOCOPY   VARCHAR2
  );

PROCEDURE Assign_Owner
  (p_init_msg_list        IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit               IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_incident_id          IN   NUMBER,
   p_total_emp            IN   NUMBER   DEFAULT NULL,
   p_party_name           IN   VARCHAR2 DEFAULT NULL,
   p_param_resource_type  IN   VARCHAR2,
   p_service_request_rec  IN   CS_ServiceRequest_PUB.service_request_rec_type,
   p_task_attribute_rec   IN   SR_Task_rec_type,
   x_return_status        OUT  NOCOPY   VARCHAR2,
   x_resource_id          OUT  NOCOPY   NUMBER,
   x_resource_type        OUT  NOCOPY   VARCHAR2,
   x_territory_id         OUT   NOCOPY   NUMBER,
   x_msg_count            OUT  NOCOPY   NUMBER,
   x_msg_data             OUT  NOCOPY   VARCHAR2
  );

/*************************************************
-- This is the Main Procedure which gets the Group
-- and Resources back to the calling Program.
**************************************************/
PROCEDURE Assign_Task_Resource
   (p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2,
    p_commit                 IN    VARCHAR2,
    p_incident_id            IN    NUMBER,
    p_service_request_rec    IN    CS_ServiceRequest_PUB.service_request_rec_type,
    p_task_attribute_rec     IN    SR_Task_rec_type,
    x_owner_group_id         OUT   NOCOPY   NUMBER,
    x_group_type             OUT   NOCOPY   VARCHAR2,
    x_owner_type	     OUT   NOCOPY   VARCHAR2,
    x_owner_id               OUT   NOCOPY   NUMBER,
    x_territory_id           OUT   NOCOPY   NUMBER,
    x_return_status          OUT   NOCOPY   VARCHAR2,
    x_msg_count              OUT   NOCOPY   NUMBER,
    x_msg_data               OUT   NOCOPY   VARCHAR2
  ) IS

-- Define Local Variables
l_api_name            CONSTANT VARCHAR2(30)    := 'Assign_Task_Resource';
l_api_version         CONSTANT NUMBER          := 1.0;
l_api_name_full       CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
l_location_id             NUMBER := p_service_request_rec.incident_location_id;
l_ib_inv_comp_id          NUMBER;
l_ib_inv_subcomp_id       NUMBER;
l_no_of_employees         NUMBER        := NULL;
l_country                 VARCHAR2(60)  := NULL;
l_province                VARCHAR2(60)  := NULL;
l_postal_code             VARCHAR2(60)  := NULL;
l_city                    VARCHAR2(60)  := NULL;
l_state                   VARCHAR2(60)  := NULL;
l_county                  VARCHAR2(60)  := NULL;
l_party_name              VARCHAR2(360) := NULL;
-- Return Status from Group, Owner and Resources Proc
l_grp_return_status       VARCHAR2(1)  := NULL;
l_own_return_status	  VARCHAR2(1)  := NULL;
l_main_return_status	  VARCHAR2(1) ;
l_return_status		  VARCHAR2(1);
l_default_group_type	  VARCHAR2(30);
l_group_type              VARCHAR2(30);
l_group_id		  NUMBER;
l_owner_id                NUMBER;
l_resource_type           VARCHAR2(30);
l_param_resource_type     VARCHAR2(30);
l_owner                   VARCHAR2(360);
l_group_owner             VARCHAR2(60);
l_update_own_flag         VARCHAR2(1)  := 'N';
l_update_grp_flag         VARCHAR2(1)  := 'N';
l_territory_id               NUMBER;
-- For Messages
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);

CURSOR c_inc_rec IS
SELECT incident_id,
       incident_number,
       incident_status_id,
       incident_type_id,
       incident_urgency_id,
       incident_severity_id,
       incident_owner_id,
       resource_type,
       inventory_item_id,
       customer_id,
       account_id,
       bill_to_site_use_id,
       purchase_order_num,
       ship_to_site_use_id,
       problem_code,
       expected_resolution_date,
       actual_resolution_date,
       customer_product_id,
       install_site_use_id,
       bill_to_contact_id,
       ship_to_contact_id,
       current_serial_number,
       product_revision,
       component_version,
       subcomponent_version,
       resolution_code,
       org_id,
       original_order_number,
       workflow_process_id,
       close_date,
       contract_service_id,
       contract_id,
       contract_number,
       project_number,
       owner_group_id,
       obligation_date,
       caller_type,
       platform_id,
       platform_version,
       db_version,
       cp_revision_id,
       inv_component_version,
       language_id,
       territory_id,
       inv_organization_id,
       cust_pref_lang_code,
       comm_pref_code,
       incident_address,
       incident_city,
       incident_state,
       incident_country,
       incident_province,
       incident_postal_code,
       incident_county,
       sr_creation_channel,
       coverage_type,
       customer_site_id,
       site_id,
       incident_date,
       category_id,
       inv_platform_org_id,
       incident_location_id,
       incident_location_type,
       -- Added for 11.5.10+
       cp_component_id,
       cp_subcomponent_id,
       inv_component_id,
       inv_subcomponent_id
FROM   cs_incidents_all_b
WHERE  incident_id = p_incident_id;

-- For 11.5.10+ Need to get the location_id from party sites
-- for location_type, HZ_PARTY_SITES
CURSOR c_inc_address(p_incident_location_id NUMBER) IS
SELECT country,province,state,city,postal_code,county
FROM   hz_locations
WHERE  location_id = p_incident_location_id;

CURSOR c_inc_party_site_address(p_party_site_id NUMBER) IS
SELECT location_id FROM hz_party_sites
WHERE  party_site_id = p_party_site_id;

-- Added the following cursors for ER# 3811871.
CURSOR c_inv_comp_id(p_component_id NUMBER) IS
SELECT inventory_item_id
FROM   csi_item_instances
WHERE  instance_id = p_component_id;

CURSOR c_inv_subcomp_id(p_subcomponent_id NUMBER) IS
SELECT inventory_item_id
FROM   csi_item_instances
WHERE  instance_id = p_subcomponent_id;

-- Added cursor to fetch the number of Employees for a
-- customer, for ER# 4107660.
CURSOR c_cust_det(p_customer_id NUMBER) IS
SELECT employees_total, party_name
FROM   hz_parties
WHERE  party_id = p_customer_id;

l_inc_rec        c_inc_rec%ROWTYPE;
l_service_request_rec    CS_ServiceRequest_PUB.service_request_rec_type ;
l_service_req_rec    CS_ServiceRequest_PUB.service_request_rec_type default p_service_request_rec;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status      := FND_API.G_RET_STS_SUCCESS;
  l_grp_return_status  := FND_API.G_RET_STS_SUCCESS;
  l_main_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Raise Error when both incident_id and the service request record is not
  -- passed. The service request record is checked for null based on the
  -- incident_type_id. If only incident_id is passed then fetch all the
  -- territory attributes from cs_incidents_all_b
  IF (p_incident_id IS NULL  and p_service_request_rec.type_id IS NULL) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF (p_service_request_rec.type_id IS NULL) THEN
      OPEN c_inc_rec;
      FETCH c_inc_rec INTO l_inc_rec;
      l_service_request_rec.customer_id            := l_inc_rec.customer_id;
      l_service_request_rec.type_id                := l_inc_rec.incident_type_id;
      l_service_request_rec.severity_id            := l_inc_rec.incident_severity_id;
      l_service_request_rec.urgency_id             := l_inc_rec.incident_urgency_id;
      l_service_request_rec.status_id              := l_inc_rec.incident_status_id;
      l_service_request_rec.problem_code           := l_inc_rec.problem_code;
      l_service_request_rec.sr_creation_channel    := l_inc_rec.sr_creation_channel;
      l_service_request_rec.inventory_item_id      := l_inc_rec.inventory_item_id;
      l_service_request_rec.inventory_org_id       := l_inc_rec.inv_organization_id;
      l_service_request_rec.comm_pref_code         := l_inc_rec.comm_pref_code;
      l_service_request_rec.platform_id            := l_inc_rec.platform_id;
      l_service_request_rec.inv_platform_org_id    := l_inc_rec.inv_platform_org_id;
      l_service_request_rec.category_id            := l_inc_rec.category_id;
      l_service_request_rec.cust_pref_lang_code    := l_inc_rec.cust_pref_lang_code;
      l_service_request_rec.coverage_type          := l_inc_rec.coverage_type;
      l_service_request_rec.customer_site_id       := l_inc_rec.customer_site_id;
      l_service_request_rec.site_id                := l_inc_rec.site_id;
      l_service_request_rec.request_date           := l_inc_rec.incident_date;
      l_service_request_rec.incident_country       := l_inc_rec.incident_country;
      l_service_request_rec.incident_city          := l_inc_rec.incident_city;
      l_service_request_rec.incident_state         := l_inc_rec.incident_state;
      l_service_request_rec.incident_province      := l_inc_rec.incident_province;
      l_service_request_rec.incident_postal_code   := l_inc_rec.incident_postal_code;
      l_service_request_rec.incident_county        := l_inc_rec.incident_county;
      l_service_request_rec.cp_component_id        := l_inc_rec.cp_component_id;
      l_service_request_rec.cp_subcomponent_id     := l_inc_rec.cp_subcomponent_id;
      l_service_request_rec.inv_component_id       := l_inc_rec.inv_component_id;
      l_service_request_rec.inv_subcomponent_id    := l_inc_rec.inv_subcomponent_id;
      l_service_request_rec.incident_location_id   := l_inc_rec.incident_location_id;
      l_service_request_rec.incident_location_type := l_inc_rec.incident_location_type;
      l_service_request_rec.owner_group_id         := l_inc_rec.owner_group_id;
      l_service_request_rec.customer_product_id    := l_inc_rec.customer_product_id;
      l_service_request_rec.contract_service_id    := l_inc_rec.contract_service_id;
      l_service_request_rec.language_id            := l_inc_rec.language_id;
      CLOSE c_inc_rec;
      l_service_req_rec := l_service_request_rec;
    END IF;

    -- Added the following for 11.5.10+
    IF (l_service_req_rec.incident_location_id is not null) THEN
      IF (l_service_req_rec.incident_location_type = 'HZ_PARTY_SITE') THEN
        OPEN  c_inc_party_site_address(l_service_req_rec.incident_location_id);
        FETCH c_inc_party_site_address INTO l_location_id;
        IF (c_inc_party_site_address%NOTFOUND) THEN
          l_location_id := NULL;
        END IF;
        CLOSE c_inc_party_site_address;
      -- Added for bug 5228561
      ELSE
        IF (l_service_req_rec.incident_location_type = 'HZ_LOCATION') THEN
           l_location_id := l_service_req_rec.incident_location_id;
	END IF;
      END IF;
      OPEN  c_inc_address(l_location_id);
      FETCH c_inc_address INTO l_country,l_province,l_state,l_city,l_postal_code,
            l_county;
      IF (c_inc_address%NOTFOUND) THEN
        NULL;
      END IF;
      CLOSE c_inc_address;
      l_service_req_rec.incident_country     := l_country;
      l_service_req_rec.incident_city        := l_city;
      l_service_req_rec.incident_postal_code := l_postal_code;
      l_service_req_rec.incident_state       := l_state;
      l_service_req_rec.incident_province    := l_province;
      l_service_req_rec.incident_county      := l_county;
    END IF;

    -- Added for 11.5.10+ ER# 3811871
    IF (l_service_req_rec.customer_product_id IS NOT NULL) THEN
      OPEN  c_inv_comp_id(l_service_req_rec.cp_component_id);
      FETCH c_inv_comp_id INTO l_ib_inv_comp_id;
      CLOSE c_inv_comp_id;

      OPEN  c_inv_subcomp_id(l_service_req_rec.cp_subcomponent_id);
      FETCH c_inv_subcomp_id INTO l_ib_inv_subcomp_id;
      CLOSE c_inv_subcomp_id;

      l_service_req_rec.cp_component_id    := l_ib_inv_comp_id;
      l_service_req_rec.cp_subcomponent_id := l_ib_inv_subcomp_id;
    END IF;

    OPEN  c_cust_det(l_service_req_rec.customer_id);
    FETCH c_cust_det INTO l_no_of_employees, l_party_name;
    IF (c_cust_det%NOTFOUND) THEN
      l_no_of_employees := NULL;
      l_party_name      := NULL;
    END IF;
    CLOSE c_cust_det;

    IF (NVL(FND_PROFILE.VALUE('CS_SR_TASK_OWNER_AUTO_ASSIGN_LEVEL'),'INDIVIDUAL') = 'INDIVIDUAL') THEN
      Assign_Owner
          ( p_init_msg_list        => p_init_msg_list,
            p_commit               => p_commit,
            p_incident_id          => p_incident_id,
            p_total_emp            => l_no_of_employees,
            p_party_name           => l_party_name,
            p_param_resource_type  => 'RS_INDIVIDUAL',
            p_service_request_rec  => l_service_req_rec,
            p_task_attribute_rec   => p_task_attribute_rec,
            x_return_status        => x_return_status,
            x_resource_id          => l_owner_id,
            x_resource_type        => l_resource_type,
            x_territory_id         => l_territory_id,
	    x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data
          );
    END IF; -- Profile value is INDIVIDUAL
      IF (l_owner_id IS NULL OR
          FND_PROFILE.VALUE('CS_SR_TASK_OWNER_AUTO_ASSIGN_LEVEL') = 'GROUP') THEN
        -- Call the Assign Group Procedure to return the Group and Group Type
        Assign_Group
          ( p_init_msg_list        => p_init_msg_list,
            p_commit               => p_commit,
            p_incident_id          => p_incident_id,
            p_total_emp            => l_no_of_employees,
            p_party_name           => l_party_name,
            p_service_request_rec  => l_service_req_rec,
            p_task_attribute_rec   => p_task_attribute_rec,
            x_return_status        => x_return_status,
            x_group_id             => l_group_id,
            x_group_type           => l_group_type,
            x_territory_id         => l_territory_id,
            x_msg_count            => x_msg_count,
            x_msg_data	           => x_msg_data
          );
      END IF; -- l_owner_id IS NULL
  END IF; -- p_incident_id IS NULL

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    x_owner_id       := NULL;
    x_owner_type     := NULL;
    x_owner_group_id := NULL;
    x_group_type     := NULL;
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_TASK_NO_OWNER');
    FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF (l_owner_id IS NULL AND l_group_id IS NULL) THEN
     -- FND_MSG_PUB.Initialize;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_TASK_NO_OWNER');
      FND_MESSAGE.Set_Token('API_NAME',l_api_name_full||l_service_req_rec.platform_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      x_owner_id       := l_owner_id;
      x_owner_type     := l_resource_type;
      x_owner_group_id := l_group_id;
      x_group_type     := l_group_type;
      x_territory_id   := l_territory_id;
      x_return_status  := x_return_status;
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Assign_Task_Resource;

/***************************************************
-- This Procedure returns the Group if not passed.
***************************************************/
PROCEDURE Assign_Group
  ( p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
    p_incident_id         IN   NUMBER,
    p_total_emp           IN   NUMBER,
    p_party_name          IN   VARCHAR2,
    p_service_request_rec IN   CS_Servicerequest_PUB.service_request_rec_type,
    p_task_attribute_rec  IN   SR_Task_rec_type,
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_group_id            OUT  NOCOPY   NUMBER,
    x_group_type          OUT  NOCOPY   VARCHAR2,
    x_territory_id        OUT  NOCOPY   NUMBER,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2
  ) IS

-- Define Local Variables
n                         NUMBER;
-- Input and output data structures
l_Assign_Groups_tbl       JTF_ASSIGN_PUB.AssignResources_tbl_type;
l_task_am_rec             JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type ;
-- Qualifier values
l_incident_id            NUMBER := p_incident_id;
l_inv_item_id            NUMBER := NULL;
l_inv_org_id             NUMBER := NULL;
l_party_id           	 NUMBER := p_service_request_rec.customer_id;
l_cust_category          VARCHAR2(30) := NULL;
l_area_code              VARCHAR2(60) := NULL;
l_contract_service_id    NUMBER := p_service_request_rec.contract_service_id;
l_cust_prod_id           NUMBER := p_service_request_rec.customer_product_id;
l_contract_res_flag      VARCHAR2(3);
l_ib_res_flag            VARCHAR2(3);
--parameters
l_no_of_resources       NUMBER :=  1;
l_business_process_id   NUMBER;
l_day_week		     VARCHAR2(10) ;
l_time_day		     VARCHAR2(10) ;

l_cs_sr_tsk_chk_res_cal_avl  VARCHAR2(1) ; --gasankar Calendar check feature added
l_start_date  Date  ;
l_end_date    Date ;

c_customer_phone_id NUMBER := p_service_request_rec.customer_phone_id;

-- List of Cursors used
CURSOR C_CONTRACT(l_contract_service_id number) IS
SELECT to_number(object1_id1), to_number(object1_id2)
FROM   okc_k_items
WHERE  cle_id = l_contract_service_id;

--Bug 5255184 Modified the c_area_code query
CURSOR c_area_code IS
SELECT hzp.phone_area_code
FROM   hz_contact_points hzp
WHERE  hzp.contact_point_id = c_customer_phone_id;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Proceed even if the group_type is null
  l_incident_id := p_incident_id;

  IF (FND_PROFILE.VALUE('CS_SR_USE_BUS_PROC_TASK_AUTO_ASSIGN') = 'YES') THEN
    SELECT business_process_id INTO l_business_process_id
    FROM   cs_incident_types
    WHERE  incident_type_id = p_service_request_rec.type_id;
  END IF;

--  4365612 Removed the profile check "Service : Use Component Subcomponent in Assignment (Reserved)"
--  Assigning component and subcomponent id directly to the am rec

   IF (l_cust_prod_id IS NOT NULL) THEN
      l_task_am_rec.item_component := p_service_request_rec.cp_component_id ;
      l_task_am_rec.item_subcomponent := p_service_request_rec.cp_subcomponent_id ;
   ELSE
      l_task_am_rec.item_component := p_service_request_rec.inv_component_id ;
      l_task_am_rec.item_subcomponent := p_service_request_rec.inv_subcomponent_id ;
   END IF;

  --Bug 5255184 Modified the c_area_code
  OPEN c_area_code;
  FETCH c_area_code INTO l_area_code;
  IF (c_area_code%NOTFOUND) THEN
    l_area_code := NULL;
  END IF;
  CLOSE c_area_code;
  -- Assign the values to the AM Record Type
  -- Assign the Task Related Information
  l_task_am_rec.task_type_id     := p_task_attribute_rec.task_type_id;
  l_task_am_rec.task_status_id   := p_task_attribute_rec.task_status_id;
  l_task_am_rec.task_priority_id := p_task_attribute_rec.task_priority_id;
  l_task_am_rec.num_of_employees := p_total_emp;
  -- Assign the Service Request Related Information
  l_task_am_rec.service_request_id   := p_incident_id;
  l_task_am_rec.party_id             := p_service_request_rec.customer_id;
  l_task_am_rec.incident_type_id     := p_service_request_rec.type_id;
  l_task_am_rec.incident_severity_id := p_service_request_rec.severity_id;
  l_task_am_rec.incident_urgency_id  := p_service_request_rec.urgency_id;
  l_task_am_rec.incident_status_id   := p_service_request_rec.status_id;
  l_task_am_rec.problem_code         := p_service_request_rec.problem_code;
  l_task_am_rec.platform_id          := p_service_request_rec.platform_id;
  l_task_am_rec.sr_creation_channel  := p_service_request_rec.sr_creation_channel;
  l_task_am_rec.inventory_item_id    := p_service_request_rec.inventory_item_id;
  l_task_am_rec.squal_char12         := p_service_request_rec.problem_code;
  l_task_am_rec.squal_char13         := p_service_request_rec.comm_pref_code;
  l_task_am_rec.squal_num12          := p_service_request_rec.platform_id;
  l_task_am_rec.squal_num13          := p_service_request_rec.inv_platform_org_id;
  l_task_am_rec.squal_num14          := p_service_request_rec.category_id;
  l_task_am_rec.squal_num15          := p_service_request_rec.inventory_item_id;
  l_task_am_rec.squal_num16          := p_service_request_rec.inventory_org_id;
  -- Passing SR Group Owner for Bug# 3564691
  l_task_am_rec.squal_num17          := p_service_request_rec.owner_group_id;
  l_task_am_rec.squal_num30          := p_service_request_rec.language_id;
  l_task_am_rec.squal_char20         := p_service_request_rec.cust_pref_lang_code;
  l_task_am_rec.squal_char21         := p_service_request_rec.coverage_type;
  l_task_am_rec.area_code            := l_area_code;
  l_task_am_rec.party_site_id        := p_service_request_rec.customer_site_id;
  l_task_am_rec.customer_site_id     := p_service_request_rec.customer_site_id;
  l_task_am_rec.support_site_id      := p_service_request_rec.site_id;
  l_task_am_rec.country              := p_service_request_rec.incident_country;
  l_task_am_rec.city                 := p_service_request_rec.incident_city;
  l_task_am_rec.postal_code          := p_service_request_rec.incident_postal_code;
  l_task_am_rec.state                := p_service_request_rec.incident_state;
  l_task_am_rec.province             := p_service_request_rec.incident_province;
  l_task_am_rec.county               := p_service_request_rec.incident_county;
  l_task_am_rec.comp_name_range      := p_party_name;

    -- 12.1.2 Enhancement
    Begin
       SELECT to_char(sysdate, 'd'), to_char(sysdate, 'hh24:mi')
          INTO l_day_week, l_time_day
	  FROM cs_incidents_all_b
	  WHERE incident_id = l_incident_id ;
     Exception
	When Others then
		l_time_day := null ;
		l_day_week := null ;
     End ;

     l_task_am_rec.DAY_OF_WEEK := l_day_week ;
     l_task_am_rec.TIME_OF_DAY := l_time_day ;

  -- Contract Item and Org dtls
  IF (l_contract_service_id IS NOT NULL) THEN
    OPEN  c_contract(l_contract_service_id);
    FETCH c_contract INTO l_inv_item_id,l_inv_org_id;
    IF (c_contract%NOTFOUND) THEN
      NULL;
    END IF;
    CLOSE c_contract;
  END IF;
  -- Assign the values to the qualifiers
  l_task_am_rec.squal_num18 := l_inv_item_id;
  l_task_am_rec.squal_num19 := l_inv_org_id;

    -- If customer product id is not null, then set ib_preferred_resource_flag
    -- to 'Y'.If contract line id is not null, then set
    -- contract_preferred_resource flag to 'Y'.
    IF (l_contract_service_id IS NOT NULL) THEN
      l_contract_res_flag := 'Y';
    ELSE
      l_contract_res_flag := 'N';
    END IF;
    IF (l_cust_prod_id IS NOT NULL) THEN
      l_ib_res_flag := 'Y';
    ELSE
      l_ib_res_flag := 'N';
    END IF;

    FND_PROFILE.Get('CS_SR_TSK_CHK_RES_CAL_AVL', l_cs_sr_tsk_chk_res_cal_avl); --gasankar Calendar check feature added

    If nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') <> 'N' Then
	l_start_date := sysdate ;
	l_end_date   := sysdate  ;
    End If ;

  JTF_ASSIGN_PUB.GET_Assign_Resources
    ( p_api_version                  => 1.0,
      p_init_msg_list                => 'T',
      p_commit                       => 'F',
      p_resource_id                  => NULL,
      p_resource_type                => 'RS_GROUP',
      p_role                         => NULL,
      p_no_of_resources              => l_no_of_resources,
      p_auto_select_flag             => 'N',
      p_contracts_preferred_engineer => l_contract_res_flag,
      p_ib_preferred_engineer        => l_ib_res_flag,
      p_contract_id                  => l_contract_service_id,
      p_customer_product_id          => l_cust_prod_id,
      p_effort_duration              => NULL,
      p_effort_uom                   => NULL,
      p_start_date                    => l_start_date,
      p_end_date                      => l_end_date,
      p_territory_flag               => 'Y',
      p_calendar_flag                =>  nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') ,
      p_calendar_check	             =>  nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') ,
      p_web_availability_flag        => 'Y',
      p_filter_excluded_resource      => 'Y',
      p_category_id                  => NULL,
      p_inventory_item_id            => NULL,
      p_inventory_org_id             => NULL,
      p_column_list                  => NULL,
      p_calling_doc_id               => NULL,
      p_calling_doc_type             => 'SR',
      p_sr_rec                       => NULL,
      p_sr_task_rec                  => l_task_am_rec,
      p_defect_rec                   => NULL,
      p_business_process_id          => l_business_process_id,
      p_business_process_date        => p_service_request_rec.request_date,
      x_Assign_Resources_tbl         => l_Assign_Groups_tbl,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
    );

  n := l_Assign_Groups_tbl.FIRST;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    IF (l_Assign_Groups_tbl.exists(n)) THEN
      x_group_id      := l_Assign_Groups_tbl(n).resource_id;
      x_group_type    := l_Assign_Groups_tbl(n).resource_type;
      x_territory_id  := l_Assign_Groups_tbl(n).terr_id ;
    ELSE
      x_group_id   := NULL;
      x_group_type := NULL;
    END IF;
  END IF;

END Assign_Group;

/**************************************************************
-- This Procedure returns the individual Owner from the Group
-- returned by the Assign_Group Procedure.
**************************************************************/
PROCEDURE Assign_Owner
  ( p_init_msg_list        IN    VARCHAR2  := FND_API.G_FALSE,
    p_commit               IN    VARCHAR2  := FND_API.G_FALSE,
    p_incident_id          IN    NUMBER,
    p_total_emp            IN    NUMBER,
    p_party_name           IN    VARCHAR2,
    p_param_resource_type  IN    VARCHAR2,
    p_service_request_rec  IN    CS_ServiceRequest_PUB.service_request_rec_type,
    p_task_attribute_rec   IN    SR_Task_rec_type,
    x_return_status        OUT   NOCOPY   VARCHAR2,
    x_resource_id          OUT   NOCOPY   NUMBER,
    x_resource_type        OUT   NOCOPY   VARCHAR2,
    x_territory_id         OUT   NOCOPY   NUMBER,
    x_msg_count            OUT   NOCOPY   NUMBER,
    x_msg_data	           OUT   NOCOPY   VARCHAR2
  ) IS

-- Input and output data structures
l_Assign_Owner_tbl       JTF_ASSIGN_PUB.AssignResources_tbl_type ;
l_task_am_rec            JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type ;
-- Message Variables
l_index	                 BINARY_INTEGER;
l_count		         NUMBER;
l_counter                NUMBER;
p			 NUMBER;
-- Qualifier values
l_incident_id            NUMBER       := p_incident_id;
l_contract_service_id    NUMBER       := p_service_request_rec.contract_service_id;
l_cust_prod_id           NUMBER       := p_service_request_rec.customer_product_id;
l_contract_res_flag      VARCHAR2(3);
l_ib_res_flag            VARCHAR2(3);
l_inv_item_id            NUMBER       := NULL;
l_inv_org_id             NUMBER       := NULL;
l_inv_category_id        NUMBER       := NULL ;
l_party_id        	 NUMBER       := p_service_request_rec.customer_id;
l_class_code             VARCHAR2(30) := NULL;
-- Passing parameters
l_no_of_resources        NUMBER       := NULL;
l_area_code 	         VARCHAR2(50) ;
l_business_process_id    NUMBER;
l_day_week		     VARCHAR2(10) ;
l_time_day		     VARCHAR2(10) ;

l_cs_sr_tsk_chk_res_cal_avl  VARCHAR2(1) ; --gasankar Calendar check feature added
l_start_date  Date  ;
l_end_date    Date ;


-- List of Cursors
CURSOR c_contract(l_contract_service_id NUMBER)IS
SELECT TO_NUMBER(object1_id1), TO_NUMBER(object1_id2)
FROM   okc_k_items
WHERE  cle_id = l_contract_service_id;

CURSOR c_area_code(c_incident_id NUMBER) IS
SELECT hzp.phone_area_code
FROM   hz_contact_points hzp,
       cs_incidents_all_b csi
WHERE  csi.incident_id       = c_incident_id
AND    csi.customer_phone_id = hzp.contact_point_id
AND    csi.customer_phone_id IS NOT NULL;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Proceed even if the group_id is null
 -- l_group_id := p_group_id ;

  --
  IF (FND_PROFILE.VALUE('CS_SR_USE_BUS_PROC_TASK_AUTO_ASSIGN') = 'YES') THEN
    SELECT business_process_id INTO l_business_process_id
    FROM   cs_incident_types
    WHERE  incident_type_id = p_service_request_rec.type_id;
  END IF;

--  4365612 Removed the profile check "Service : Use Component Subcomponent in Assignment (Reserved)"
--  Assigning component and subcomponent id directly to the am rec

IF (l_cust_prod_id IS NOT NULL) THEN
      l_task_am_rec.item_component := p_service_request_rec.cp_component_id ;
      l_task_am_rec.item_subcomponent := p_service_request_rec.cp_subcomponent_id ;
ELSE
      l_task_am_rec.item_component := p_service_request_rec.inv_component_id ;
      l_task_am_rec.item_subcomponent := p_service_request_rec.inv_subcomponent_id ;
END IF;

  OPEN c_area_code(l_incident_id);
  FETCH c_area_code INTO l_area_code;
  IF (c_area_code%NOTFOUND) THEN
    l_area_code := NULL;
  END IF;
  CLOSE c_area_code;

  -- Set the Task Related Information
  l_task_am_rec.task_type_id     := p_task_attribute_rec.task_type_id;
  l_task_am_rec.task_status_id   := p_task_attribute_rec.task_status_id;
  l_task_am_rec.task_priority_id := p_task_attribute_rec.task_priority_id;
  l_task_am_rec.num_of_employees := p_total_emp;
  -- Set the Service Request Related Information
  l_task_am_rec.service_request_id   := p_incident_id;
  l_task_am_rec.party_id             := p_service_request_rec.customer_id;
  l_task_am_rec.incident_type_id     := p_service_request_rec.type_id;
  l_task_am_rec.incident_severity_id := p_service_request_rec.severity_id;
  l_task_am_rec.incident_urgency_id  := p_service_request_rec.urgency_id;
  l_task_am_rec.incident_status_id   := p_service_request_rec.status_id;
  l_task_am_rec.problem_code         := p_service_request_rec.problem_code;
  l_task_am_rec.platform_id          := p_service_request_rec.platform_id;
  l_task_am_rec.sr_creation_channel  := p_service_request_rec.sr_creation_channel;
  l_task_am_rec.inventory_item_id    := p_service_request_rec.inventory_item_id;
  l_task_am_rec.squal_char12         := p_service_request_rec.problem_code;
  l_task_am_rec.squal_char13         := p_service_request_rec.comm_pref_code;
  l_task_am_rec.squal_char20         := p_service_request_rec.cust_pref_lang_code ;
  l_task_am_rec.squal_char21         := p_service_request_rec.coverage_type;
  l_task_am_rec.squal_num12          := p_service_request_rec.platform_id;
  l_task_am_rec.squal_num13          := p_service_request_rec.inv_platform_org_id;
  l_task_am_rec.squal_num14          := p_service_request_rec.category_id;
  l_task_am_rec.squal_num15          := p_service_request_rec.inventory_item_id;
  l_task_am_rec.squal_num16          := p_service_request_rec.inventory_org_id;
  -- Passing SR Group Owner for Bug# 3564691
  l_task_am_rec.squal_num17          := p_service_request_rec.owner_group_id;
  l_task_am_rec.squal_num30          := p_service_request_rec.language_id;
  l_task_am_rec.area_code            := l_area_code;
  l_task_am_rec.party_site_id        := p_service_request_rec.customer_site_id;
  l_task_am_rec.customer_site_id     := p_service_request_rec.customer_site_id;
  l_task_am_rec.support_site_id      := p_service_request_rec.site_id;
  l_task_am_rec.country              := p_service_request_rec.incident_country;
  l_task_am_rec.city                 := p_service_request_rec.incident_city;
  l_task_am_rec.postal_code          := p_service_request_rec.incident_postal_code;
  l_task_am_rec.state                := p_service_request_rec.incident_state;
  l_task_am_rec.province             := p_service_request_rec.incident_province;
  l_task_am_rec.county               := p_service_request_rec.incident_county;
  l_task_am_rec.comp_name_range      := p_party_name;

    -- 12.1.2 Enhancement
    Begin
       SELECT to_char(sysdate, 'd'), to_char(sysdate, 'hh24:mi')
          INTO l_day_week, l_time_day
	  FROM cs_incidents_all_b
	  WHERE incident_id = l_incident_id ;
     Exception
	When Others then
		l_time_day := null ;
		l_day_week := null ;
     End ;

     l_task_am_rec.DAY_OF_WEEK := l_day_week ;
     l_task_am_rec.TIME_OF_DAY := l_time_day ;

  --Contract Item and Org dtls
  IF (l_contract_service_id IS NOT NULL) THEN
    OPEN c_contract(l_contract_service_id);
    FETCH c_contract INTO l_inv_item_id,l_inv_org_id;
    IF c_contract%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE c_contract;
  END IF;
  -- Assign it to the AM record type For contracts
  l_task_am_rec.squal_num18 := l_inv_item_id;
  l_task_am_rec.squal_num19 := l_inv_org_id;
  l_task_am_rec.squal_char11 := null;

  -- If customer product id is not null, then set ib_preferred_resource_flag
  -- to 'Y'.If contract line id is not null, then set
  -- contract_preferred_resource flag to 'Y'.
  IF (l_contract_service_id IS NOT NULL) THEN
    l_contract_res_flag := 'Y';
  ELSE
    l_contract_res_flag := 'N';
  END IF;
  IF (l_cust_prod_id IS NOT NULL) THEN
    l_ib_res_flag := 'Y';
  ELSE
    l_ib_res_flag := 'N';
  END IF;

  FND_PROFILE.Get('CS_SR_TSK_CHK_RES_CAL_AVL', l_cs_sr_tsk_chk_res_cal_avl); --gasankar Calendar check feature added

    If nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') <> 'N' Then
	l_start_date := sysdate ;
	l_end_date   := sysdate ;
    End If ;

  JTF_ASSIGN_PUB.GET_Assign_Resources
    ( p_api_version                   => 1.0,
      p_init_msg_list                 => null,
      p_commit                        => 'F',
      --p_resource_id                 => l_group_id,
      p_resource_type                 => 'RS_INDIVIDUAL',
      p_role                          => NULL,
      p_no_of_resources               => l_no_of_resources,
      p_auto_select_flag              => 'N',
      p_ib_preferred_engineer         => l_ib_res_flag,
      p_contracts_preferred_engineer  => l_contract_res_flag,
      p_contract_id                   => l_contract_service_id,
      p_customer_product_id           => l_cust_prod_id,
      p_effort_duration               => NULL,
      p_effort_uom                    => NULL,
      p_start_date                    => l_start_date,
      p_end_date                      => l_end_date,
      p_territory_flag                => 'Y',
      p_calendar_flag                 => nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') ,
      p_calendar_check	              =>  nvl(l_cs_sr_tsk_chk_res_cal_avl, 'N') ,
      --p_web_availability_flag       => 'Y',
      p_filter_excluded_resource      => 'Y',
      p_category_id                   => NULL,
      p_inventory_item_id             => NULL,
      p_inventory_org_id              => NULL,
      p_column_list                   => NULL,
      p_calling_doc_id                => NULL,
      p_calling_doc_type              => 'SR',
      p_sr_rec                        => NULL,
      p_sr_task_rec                   => l_task_am_rec,
      p_defect_rec                    => NULL,
      p_business_process_id           => l_business_process_id,
      p_business_process_date         => p_service_request_rec.request_date,
      x_Assign_Resources_tbl          => l_Assign_Owner_tbl,
      x_return_status                 => x_return_status,
      x_msg_count                     => x_msg_count,
      x_msg_data                      => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    p := l_Assign_Owner_tbl.FIRST ;
    IF (l_Assign_Owner_tbl.COUNT >= 1) THEN
      x_resource_id   := l_Assign_Owner_tbl(p).resource_id ;
      x_resource_type := l_Assign_Owner_tbl(p).resource_type ;
      x_territory_id  := l_Assign_Owner_tbl(p).terr_id ;
    END IF;
  END IF ; -- Return status S
END Assign_Owner;

END CS_SR_TASK_AUTOASSIGN_PKG;

/
