--------------------------------------------------------
--  DDL for Package Body CS_ASSIGN_RESOURCE_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_ASSIGN_RESOURCE_CON_PKG" as
/* $Header: csvconab.pls 120.8.12010000.4 2009/09/01 07:03:19 gasankar ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_ASSIGN_RESOURCE_CON_PKG';

PROCEDURE MAIN_PROCEDURE
  (x_errbuf                OUT  NOCOPY VARCHAR2,
   X_retcode               OUT  NOCOPY NUMBER,
   p_group1_id             IN   NUMBER,
   p_group2_id             IN   NUMBER,
   p_group3_id             IN   NUMBER,
   p_group4_id             IN   NUMBER,
   p_group5_id             IN   NUMBER,
   p_incident_type1_id     IN   NUMBER,
   p_incident_type2_id     IN   NUMBER,
   p_incident_type3_id     IN   NUMBER,
   p_incident_type4_id     IN   NUMBER,
   p_incident_type5_id     IN   NUMBER,
   p_incident_severity1_id IN   NUMBER,
   p_incident_severity2_id IN   NUMBER,
   p_incident_severity3_id IN   NUMBER,
   p_incident_severity4_id IN   NUMBER,
   p_incident_severity5_id IN   NUMBER
  ) IS

-- Define Local Variables
l_sr_rec                CS_ServiceRequest_PVT.service_request_rec_type ;
l_temp_owner_group_id   NUMBER ;
l_temp_owner_id         NUMBER ;
l_temp_owner_type       VARCHAR2(30);
l_return_status         VARCHAR2(1) := NULL ;
l_msg_count             NUMBER ;
l_msg_data              VARCHAR2(2000);
l_incident_id           NUMBER ;
l_object_version_number NUMBER ;
l_type_id               NUMBER ;
l_severity_id           NUMBER ;
l_inv_item_id           NUMBER ;
l_inv_org_id            NUMBER ;
l_category_id           NUMBER ;
l_platform_id           NUMBER ;
l_inv_plat_org_id       NUMBER ;
l_problem_code          VARCHAR2(50) ;
l_cust_pref_lang_code   VARCHAR2(4);
l_category_set_id       NUMBER ;
l_comm_pref_code        VARCHAR2(30);
l_account_id            NUMBER ;
l_urgency_id            NUMBER ;
l_status_id             NUMBER ;
l_customer_id           NUMBER ;
l_customer_product_id   NUMBER ;
l_cp_comp_id            NUMBER;
l_cp_subcomp_id         NUMBER;
l_inv_comp_id           NUMBER;
l_inv_subcomp_id        NUMBER;
l_inc_country           VARCHAR2(60);
l_inc_city              VARCHAR2(60);
l_inc_postal_code       VARCHAR2(60);
l_inc_state             VARCHAR2(60);
l_inc_province          VARCHAR2(60);
l_inc_county            VARCHAR2(255);
l_inc_location_type     VARCHAR2(30);
-- Changed the type from NUMBER to VARCHAR2 for Bug# 3262309
l_sr_number             VARCHAR2(64) ;
-- Status should be "OPEN"
l_status                NUMBER := 1 ; -- 121;
x_incident_id           NUMBER ;
l_count                 NUMBER := 0;
l_sr_count		NUMBER := 0;
--l_summary               VARCHAR2(80);
l_group_id              NUMBER;
l_contract_service_id   NUMBER;
l_incident_location_id  NUMBER;
l_site_id               NUMBER;
l_load_balance_forms    VARCHAR2(10);
l_load_balance_html     VARCHAR2(10);
l_msg                   VARCHAR2(2000);
l_coverage_type         VARCHAR2(90);
l_creation_channel      VARCHAR2(90);
-- Commented for Bug# 2889279
-- l_coverage_type_rec OKS_Entitlements_Pub.CovType_Rec_Type;

--List of Cursors
-- Made the owner_group_id to be from one of the groups and selected
-- owner_group_id for ER# 2439984.
CURSOR cs_incident_id_csr IS
SELECT incident_number,incident_id,object_version_number,incident_type_id,
       incident_severity_id,inventory_item_id, inv_organization_id,
       category_id,platform_id,inv_platform_org_id,problem_code,
       cust_pref_lang_code,comm_pref_code,account_id,incident_status_id,
       incident_urgency_id, customer_id,customer_product_id,
       owner_group_id,contract_service_id,incident_location_id,site_id,
       coverage_type,sr_creation_channel,cp_component_id, cp_subcomponent_id,
       inv_component_id, inv_subcomponent_id, incident_country, incident_city,
       incident_postal_code, incident_state, incident_province, incident_county,
       incident_location_type
FROM   cs_incidents_all_b
WHERE  incident_status_id IN (SELECT incident_status_id
       FROM  cs_incident_statuses
       WHERE NVL(close_flag,'N') <> 'Y' AND incident_subtype = 'INC')
       AND   NVL(owner_assigned_flag,'N') <> 'Y'
             AND (((p_group1_id IS NOT NULL
                    OR p_group2_id IS NOT NULL
                    OR p_group3_id IS NOT NULL
                    OR p_group4_id IS NOT NULL
                    OR p_group5_id IS NOT NULL)
               AND  owner_group_id IN (p_group1_id,
                                       p_group2_id,
                                       p_group3_id,
                                       p_group4_id,
                                       p_group5_id))
               OR  (p_group1_id IS NULL
                    AND p_group2_id IS NULL
                    AND p_group3_id IS NULL
                    AND p_group4_id IS NULL
                    AND p_group5_id IS NULL))
             AND (((p_incident_type1_id IS NOT NULL
                    or p_incident_type2_id IS NOT NULL
                    or p_incident_type3_id IS NOT NULL
                    or p_incident_type4_id IS NOT NULL
                    or p_incident_type5_id IS NOT NULL)
               AND incident_type_id IN (p_incident_type1_id,
                                        p_incident_type2_id,
                                        p_incident_type3_id,
                                        p_incident_type4_id,
                                        p_incident_type5_id))
               OR (p_incident_type1_id IS NULL
                     AND p_incident_type2_id IS NULL
                     AND p_incident_type3_id IS NULL
                     AND p_incident_type4_id IS NULL
                     AND p_incident_type5_id IS NULL))
             AND (((p_incident_severity1_id IS NOT NULL
                    or p_incident_severity2_id IS NOT NULL
                    or p_incident_severity3_id IS NOT NULL
                    or p_incident_severity4_id IS NOT NULL
                    or p_incident_severity5_id IS NOT NULL)
                AND incident_severity_id IN (p_incident_severity1_id,
                                         p_incident_severity2_id,
                                         p_incident_severity3_id,
                                         p_incident_severity4_id,
                                         p_incident_severity5_id))
                 OR (p_incident_severity1_id IS NULL
                     and p_incident_severity2_id IS NULL
                     and p_incident_severity3_id IS NULL
                     and p_incident_severity4_id IS NULL
                     and p_incident_severity5_id IS NULL));


BEGIN
  -- l_load_balance_forms := fnd_profile.value('CS_LOAD_BALANCING_REQD_FORMS');
  -- l_load_balance_html  := fnd_profile.value('CS_LOAD_BALANCING_REQD_HTML');
  OPEN cs_incident_id_csr ;
    LOOP
      FETCH cs_incident_id_csr INTO l_sr_number,l_incident_id,
            l_object_version_number,l_type_id,l_severity_id,l_inv_item_id,
            l_inv_org_id,l_category_id,l_platform_id,l_inv_plat_org_id,
            l_problem_code,l_cust_pref_lang_code, l_comm_pref_code,
            l_account_id,l_status_id,l_urgency_id,l_customer_id,
            l_customer_product_id,l_group_id,
            l_contract_service_id,l_incident_location_id,l_site_id,
            l_coverage_type,l_creation_channel, l_cp_comp_id, l_cp_subcomp_id,
            l_inv_comp_id, l_inv_subcomp_id, l_inc_country, l_inc_city,
            l_inc_postal_code, l_inc_state, l_inc_province, l_inc_county,
            l_inc_location_type ;
      IF(cs_incident_id_csr%NOTFOUND) THEN
        EXIT ;
      END IF;

      l_sr_rec.type_id                := l_type_id;
      l_sr_rec.severity_id            := l_severity_id ;
      l_sr_rec.inventory_item_id      := l_inv_item_id ;
      l_sr_rec.inventory_org_id       := l_inv_org_id ;
      l_sr_rec.category_id            := l_category_id ;
      l_sr_rec.platform_id            := l_platform_id;
      l_sr_rec.inv_platform_org_id    := l_inv_plat_org_id ;
      l_sr_rec.problem_code           := l_problem_code ;
      l_sr_rec.cust_pref_lang_code    := l_cust_pref_lang_code ;
      l_sr_rec.category_set_id        := l_category_set_id ;
      l_sr_rec.comm_pref_code         := l_comm_pref_code ;
      l_sr_rec.account_id             := l_account_id ;
      l_sr_rec.status_id              := l_status_id ;
      l_sr_rec.urgency_id             := l_urgency_id ;
      l_sr_rec.customer_id            := l_customer_id;
      l_sr_rec.customer_product_id    := l_customer_product_id ;
      l_sr_rec.owner_group_id         := l_group_id;
      l_sr_rec.contract_service_id    := l_contract_service_id;
      l_sr_rec.incident_location_id   := l_incident_location_id;
      l_sr_rec.site_id                := l_site_id;
      l_sr_rec.coverage_type          := l_coverage_type;
      l_sr_rec.sr_creation_channel    := l_creation_channel;
      l_sr_rec.incident_location_type := l_inc_location_type;
      l_sr_rec.incident_country       := l_inc_country;
      l_sr_rec.incident_city          := l_inc_city;
      l_sr_rec.incident_postal_code   := l_inc_postal_code;
      l_sr_rec.incident_state         := l_inc_state;
      l_sr_rec.incident_province      := l_inc_province;
      l_sr_rec.incident_county        := l_inc_county;
      l_sr_rec.cp_component_id        := l_cp_comp_id;
      l_sr_rec.cp_subcomponent_id     := l_cp_subcomp_id;
      l_sr_rec.inv_component_id       := l_inv_comp_id;
      l_sr_rec.inv_subcomponent_id    := l_inv_subcomp_id;

      -- From 11.5.9 load balancing is enabled for auto-assignment.
      l_sr_rec.load_balance         := 'Y' ;

      fnd_file.put_line(fnd_file.log,'Service Request no :  ' || l_sr_number);

      CS_Assign_Resource_CON_PKG.Assign_ServiceRequest_Main
        ( p_api_name              => 'Assign_ServiceRequest_Main',
          p_api_version           => 1.0 ,
          p_init_msg_list         => fnd_api.g_false,
          p_commit                => fnd_api.g_false,
          p_incident_id           => l_incident_id,
          p_object_version_number => l_object_version_number,
          p_last_updated_by       => FND_GLOBAL.USER_ID,
          p_service_request_rec   => l_sr_rec,
          x_owner_group_id        => l_temp_owner_group_id,
          x_owner_id              => l_temp_owner_id,
          x_owner_type            => l_temp_owner_type,
          x_return_status         => l_return_status ,
          x_msg_count             => l_msg_count ,
          x_msg_data              => l_msg_data
         );
      l_sr_count := l_sr_count + 1;
    END LOOP ;
  CLOSE cs_incident_id_csr ;
  fnd_file.put_line(fnd_file.log,'+-------------------------------------------+' );
  fnd_file.put_line(fnd_file.log,' No. of Service Requests Processed :  ' || l_sr_count);
  fnd_file.put_line(fnd_file.log,'+-------------------------------------------+' );

END MAIN_PROCEDURE;

PROCEDURE Assign_ServiceRequest_Main
  (p_api_name               IN    VARCHAR2,
   p_api_version            IN    NUMBER,
   p_init_msg_list          IN    VARCHAR2,
   p_commit                 IN    VARCHAR2,
   p_incident_id            IN    NUMBER,
   p_object_version_number  IN    NUMBER,
   p_last_updated_by        IN    VARCHAR2,
   p_service_request_rec    IN    CS_ServiceRequest_pvt.service_request_rec_type,
   x_owner_group_id         OUT   NOCOPY   NUMBER,
   x_owner_id               OUT   NOCOPY   NUMBER,
   x_owner_type  	    OUT   NOCOPY   VARCHAR2,
   x_return_status          OUT   NOCOPY   VARCHAR2,
   x_msg_count              OUT   NOCOPY   NUMBER,
   x_msg_data               OUT   NOCOPY   VARCHAR2
  ) IS

--Define Local Variables
l_api_name            CONSTANT VARCHAR2(30)    := 'Assign_ServiceRequest_Main';
l_api_version         CONSTANT NUMBER          := 1.0;
l_api_name_full       CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
l_return_status		       VARCHAR2(1)     := null;

l_sr_rec   CS_ServiceRequest_PVT.service_request_rec_type DEFAULT p_service_request_rec;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (p_incident_id IS NOT NULL) THEN
    CS_ASSIGN_RESOURCE_CON_PKG.Assign_Resources
      ( p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_incident_id           => p_incident_id,
        p_object_version_number => p_object_version_number,
        p_last_updated_by       => p_last_updated_by,
        p_service_request_rec   => l_sr_rec,
        x_owner_group_id        => x_owner_group_id,
        x_owner_type	        => x_owner_type,
        x_owner_id              => x_owner_id,
        x_return_status         => l_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data		=> x_msg_data
      );
  END IF;
  x_return_status := l_return_status;

END Assign_ServiceRequest_Main;

PROCEDURE Assign_Resources
  ( p_init_msg_list          IN    VARCHAR2,
    p_commit                 IN    VARCHAR2,
    p_incident_id            IN    NUMBER,
    p_object_version_number  IN    NUMBER,
    p_last_updated_by        IN    VARCHAR2,
    p_service_request_rec    IN    CS_ServiceRequest_pvt.service_request_rec_type,
    x_owner_group_id         OUT   NOCOPY   NUMBER,
    x_owner_type	     OUT   NOCOPY   VARCHAR2,
    x_owner_id               OUT   NOCOPY   NUMBER,
    x_return_status          OUT   NOCOPY   VARCHAR2,
    x_msg_count              OUT   NOCOPY   NUMBER,
    x_msg_data               OUT   NOCOPY   VARCHAR2
  ) IS

-- Define Local Variables
l_api_name       CONSTANT VARCHAR2(30)    := 'Assign_ServiceRequest_Main';
l_api_version    CONSTANT NUMBER          := 1.0;
l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
l_HTML_profile            VARCHAR2(1);
l_FORMS_profile           VARCHAR2(1);
l_grp_return_status	  VARCHAR2(1) := NULL;
l_own_return_status	  VARCHAR2(1) := NULL;
l_main_return_status	  VARCHAR2(1) ;
l_return_status		  VARCHAR2(1);
l_default_group_type	  VARCHAR2(30);
l_ib_inv_comp_id          NUMBER      := NULL;
l_ib_inv_subcomp_id       NUMBER      := NULL;
l_group_id		  NUMBER;
l_owner_id                NUMBER;
l_territory_id            NUMBER;
l_resource_type           VARCHAR2(30);
l_param_resource_type     VARCHAR2(30);
l_owner                   VARCHAR2(360);
l_group_owner             VARCHAR2(60);
l_msg_count     	  NUMBER;
l_msg_data      	  VARCHAR2(2000);
l_msg                     VARCHAR2(2000);
--for Updating SR
l_update_grp_flag         VARCHAR2(1) := 'N';
l_update_own_flag         VARCHAR2(1) := 'N';
l_interaction_id          NUMBER;
l_workflow_process_id     NUMBER;

l_sr_rec   CS_ServiceRequest_pvt.service_request_rec_type DEFAULT p_service_request_rec;
l_service_request_rec     CS_ServiceRequest_pvt.service_request_rec_type;
l_notes_table             CS_ServiceRequest_pvt.notes_table;
l_contacts_table          CS_ServiceRequest_pvt.contacts_table;
l_sr_update_out_rec       CS_ServiceRequest_pvt.sr_update_out_rec_type;
l_object_version_number   NUMBER   := p_object_version_number;

-- List of Cursors used
CURSOR c_inv_comp_id(p_component_id NUMBER) IS
SELECT inventory_item_id
FROM   csi_item_instances
WHERE  instance_id = p_component_id;

CURSOR c_inv_subcomp_id(p_subcomponent_id NUMBER) IS
SELECT inventory_item_id
FROM   csi_item_instances
WHERE  instance_id = p_subcomponent_id;

BEGIN
  --  Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_grp_return_status := FND_API.G_RET_STS_SUCCESS;
  l_main_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if default_group_type profile is null, set default to RS_GROUP for API always
  IF (l_sr_rec.group_type IS NULL) THEN
    FND_PROFILE.Get('CS_SR_DEFAULT_GROUP_TYPE', l_default_group_type);
    IF (l_default_group_type IS NULL) THEN
         l_default_group_type := 'RS_GROUP';
    END IF;
  ELSE
    l_default_group_type := l_sr_rec.group_type;
  END IF;

  IF (l_sr_rec.customer_product_id IS NOT NULL) THEN
    OPEN  c_inv_comp_id(l_sr_rec.cp_component_id);
    FETCH c_inv_comp_id INTO l_ib_inv_comp_id;
    CLOSE c_inv_comp_id;

    OPEN  c_inv_subcomp_id(l_sr_rec.cp_subcomponent_id);
    FETCH c_inv_subcomp_id INTO l_ib_inv_subcomp_id;
    CLOSE c_inv_subcomp_id;

    l_sr_rec.cp_component_id    := l_ib_inv_comp_id;
    l_sr_rec.cp_subcomponent_id := l_ib_inv_subcomp_id;
  END IF;

  IF (l_sr_rec.owner_group_id IS NULL) THEN
    l_group_id        := NULL;
    l_update_grp_flag := 'N';

    CS_ASSIGN_RESOURCE_CON_PKG.Assign_Group
      (p_init_msg_list       => p_init_msg_list,
       p_commit              => p_commit,
       p_incident_id         => p_incident_id,
       p_group_type          => l_default_group_type,
       p_service_request_rec => l_sr_rec,
       x_return_status       => l_grp_return_status,
       x_resource_id         => l_group_id,
       x_territory_id        => l_territory_id,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data
      );
    IF (l_grp_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_PROFILE.VALUE('CS_SR_OWNER_AUTO_ASSIGN_LEVEL') = 'GROUP') THEN
        x_owner_group_id := l_group_id;
        IF (l_group_id IS NOT NULL) THEN
          l_update_grp_flag := 'Y';
        END IF;
        --RETURN;
      ELSE
        -- for GIT, no owner is reqd
        --  l_owner_id := null;
        IF (l_group_id IS NOT NULL ) THEN
          l_update_grp_flag := 'Y';
          IF (l_default_group_type <> 'RS_TEAM') THEN
            l_param_resource_type := 'RS_INDIVIDUAL';
            l_update_own_flag := 'N';
            -- Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_own_return_status := FND_API.G_RET_STS_SUCCESS;

	    CS_ASSIGN_RESOURCE_CON_PKG.Assign_Owner
              (p_init_msg_list       => p_init_msg_list,
               p_commit               => p_commit,
               p_incident_id          => p_incident_id,
               p_param_resource_type  => l_param_resource_type,
               p_group_id             => l_group_id,
               p_service_request_rec  => l_sr_rec,
               x_return_status        => l_own_return_status,
               x_resource_id          => l_owner_id,
               x_resource_type        => l_resource_type,
               x_territory_id         => l_territory_id,
               x_msg_count            => x_msg_count,
               x_msg_data	      => x_msg_data
              );
            x_return_status := l_own_return_status ;
            IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
              IF (l_owner_id IS NULL) THEN
                FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
                FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
                l_msg := fnd_message.get ;
                fnd_file.put_line(fnd_file.log,'     ' || l_msg);
                l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ELSE
                l_update_own_flag := 'Y';
              END IF;
            ELSE
              -- Check for Expected and Unexpected Error
              -- For Expected Error the message stack is initialized.
              -- For Unexpected Error only all the messages are shown
              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                FND_MSG_PUB.Initialize;
                FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
                FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
                l_msg := fnd_message.get ;
                fnd_file.put_line(fnd_file.log,'     ' || l_msg);
                l_main_return_status := FND_API.G_RET_STS_ERROR;
              ELSE
                FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
                FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
                l_msg := fnd_message.get ;
                fnd_file.put_line(fnd_file.log,'     ' || l_msg);
                l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              END IF;
            END IF;
          END IF; /* group_type <> RS_TEAM */
        ELSE  /* l_group_id is not null */
             -- Print all the error messages
          FND_MESSAGE.Set_Name('CS', 'CS_API_NO_GROUP');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          fnd_file.put_line(fnd_file.log,'     ' || l_msg);
          l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        END IF; /* CS_SR_OWNER_AUTO_ASSIGN_LEVEL */
       ELSE /* l_grp_return_status is not success */
         -- Check for Expected and Unexpected Error
         -- For Expected Error the message stack is initialized.
         -- For Unexpected Error only all the messages are shown
         IF (l_grp_return_status = FND_API.G_RET_STS_ERROR) THEN
           FND_MSG_PUB.Initialize;
           FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
           FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
           l_msg := fnd_message.get ;
           fnd_file.put_line(fnd_file.log,'     ' || l_msg);
           l_main_return_status := FND_API.G_RET_STS_ERROR;
         ELSE
           FND_MESSAGE.Set_Name('CS', 'CS_API_NO_GROUP');
           FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
           l_msg := fnd_message.get ;
           fnd_file.put_line(fnd_file.log,'     ' || l_msg);
           l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         END IF;
       END IF; /* l_grp_return_status is not success  */

  ELSE /* owner_group_id is not null, group has been assigned */
    IF (l_default_group_type <> 'RS_TEAM') THEN
      l_param_resource_type := 'RS_INDIVIDUAL';
      l_update_own_flag := 'N';
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_own_return_status := FND_API.G_RET_STS_SUCCESS;
      l_group_id := p_service_request_rec.owner_group_id ;

      IF (FND_PROFILE.VALUE('CS_SR_OWNER_AUTO_ASSIGN_LEVEL') = 'GROUP') THEN
        x_owner_group_id := l_group_id;
        RETURN;
      ELSE
        CS_ASSIGN_RESOURCE_CON_PKG.Assign_Owner
          (p_init_msg_list        => p_init_msg_list,
           p_commit               => p_commit,
           p_incident_id          => p_incident_id,
           p_param_resource_type  => l_param_resource_type,
           p_group_id             => l_group_id,
           p_service_request_rec  => l_sr_rec,
           x_return_status        => l_own_return_status,
           x_resource_id          => l_owner_id,
           x_resource_type        => l_resource_type,
           x_territory_id         => l_territory_id,
           x_msg_count            => x_msg_count,
           x_msg_data		=> x_msg_data
          );
        x_return_status := l_own_return_status ;
        IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_owner_id IS NULL) THEN
            FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
            FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
            l_msg := fnd_message.get ;
            fnd_file.put_line(fnd_file.log,'     ' || l_msg);
            l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          ELSE
            l_update_own_flag := 'Y';
          END IF;
        ELSE
          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            FND_MSG_PUB.Initialize;
            FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
            FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
            l_msg := fnd_message.get ;
            fnd_file.put_line(fnd_file.log,'     ' || l_msg);
            l_main_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
            FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
            FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
            l_msg := fnd_message.get ;
            fnd_file.put_line(fnd_file.log,'     ' || l_msg);
            l_main_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          END IF;
        END IF;
      END IF; /* CS_SR_OWNER_AUTO_ASSIGN_LEVEL */
    END IF; /* group_type <> RS_TEAM */
  END IF; /* owner_group_id is not null, group has been assigned */

  IF ((l_update_grp_flag = 'Y') OR ( l_update_own_flag = 'Y')) THEN
    BEGIN
      --Call Update Service Request for Updating owner_group_id,owner_id
      -- and resource_type. If a group_id is not returned by AM API then
      -- do not do any updates
      -- initialise

      CS_ServiceRequest_pvt.initialize_rec(l_service_request_rec);

      l_service_request_rec.group_type       := l_default_group_type;
      IF (l_sr_rec.owner_group_id IS NULL) THEN
        l_service_request_rec.owner_group_id := l_group_id;
      END IF;

      IF l_update_own_flag = 'Y' THEN
        IF l_sr_rec.owner_id IS NULL THEN
          l_service_request_rec.owner_id      := l_owner_id;
          l_service_request_rec.resource_type := l_resource_type;
        END IF;
      END IF;

      --From 11.5.9 source program code is mandatory for update.
      --SRAMCONC is the lookup code for auto-assignment conc. pgm.
      l_service_request_rec.last_update_program_code := 'SRAMCONC';
      l_service_request_rec.territory_id             := l_territory_id;

      CS_ServiceRequest_pvt.Update_ServiceRequest(
                 p_api_version           => 4.0,
                 p_init_msg_list         => 'T',
                 p_commit                => 'T',
                 p_validation_level      => fnd_api.g_valid_level_none,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data,
                 p_request_id            => p_incident_id,
                 p_object_version_number => l_object_version_number,
                 p_resp_appl_id          => NULL,
                 p_resp_id               => NULL,
                 p_last_updated_by       => p_last_updated_by,
                 p_last_update_login     => NULL,
                 p_last_update_date      => sysdate,
                 p_service_request_rec   => l_service_request_rec,
                 p_update_desc_flex      => 'F',
                 p_notes                 => l_notes_table,
                 p_contacts              => l_contacts_table,
                 p_audit_comments        => NULL,
                 p_called_by_workflow    => 'F',
                 p_workflow_process_id   => NULL,
                 x_sr_update_out_rec     => l_sr_update_out_rec
      );

    END;
  END IF;
  IF (l_main_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_owner_id       := NULL;
    x_owner_type     := NULL;
    x_owner_group_id := l_group_id;
    x_return_status  := l_main_return_status;
  ELSE
    x_owner_id       := l_owner_id;
    x_owner_type     := l_resource_type;
    x_owner_group_id := l_group_id;
    x_return_status  := l_main_return_status;
  END IF;
  fnd_file.put_line(fnd_file.log,'Group : ' || l_group_id || '  Owner : ' || l_owner_id);
  fnd_file.put_line(fnd_file.log,'+---------------------------------------------+');

END Assign_Resources;

PROCEDURE Assign_Group
  (p_init_msg_list  	  IN   VARCHAR2  := fnd_api.g_false,
   p_commit         	  IN   VARCHAR2  := fnd_api.g_false,
   p_incident_id    	  IN   NUMBER,
   p_group_type           IN   VARCHAR2,
   p_service_request_rec  IN   CS_ServiceRequest_pvt.service_request_rec_type,
   x_return_status        OUT  NOCOPY   VARCHAR2,
   x_resource_id          OUT  NOCOPY   NUMBER,
   x_territory_id         OUT  NOCOPY   NUMBER,
   x_msg_count            OUT  NOCOPY   NUMBER,
   x_msg_data	          OUT  NOCOPY   VARCHAR2
  ) IS

--profiles variables
l_web_availability_check  VARCHAR2(1);
l_category_set_id         NUMBER;
l_platform_catg_set_id    NUMBER;
n                         NUMBER;

-- input and output data structures
l_Assign_Groups_tbl       JTF_ASSIGN_PUB.AssignResources_tbl_type;
l_sr_am_rec               JTF_ASSIGN_PUB.JTF_Serv_req_rec_type := NULL;
l_sr_rec   CS_ServiceRequest_pvt.service_request_rec_type DEFAULT p_service_request_rec;

--qualifier values
l_business_process_id    NUMBER;
l_incident_id            NUMBER := p_incident_id;
l_contract_service_id    NUMBER := p_service_request_rec.contract_service_id;
l_inv_item_id            NUMBER := NULL;
l_inv_org_id             NUMBER := NULL;
l_inv_category_id        NUMBER := NULL;
l_no_of_employees        NUMBER := NULL;
l_am_calling_doc_id      NUMBER := NULL;
l_no_of_resources        NUMBER := NULL;
l_party_id           	 NUMBER := p_service_request_rec.customer_id;
l_location_id            NUMBER := p_service_request_rec.incident_location_id;
l_cust_prod_id           NUMBER := p_service_request_rec.customer_product_id;
l_class_code             VARCHAR2(30)  := NULL;
l_cust_category          VARCHAR2(30)  := NULL;
l_country		 VARCHAR2(60)  := NULL;
l_province               VARCHAR2(60)  := NULL;
l_postal_code            VARCHAR2(60)  := NULL;
l_city                   VARCHAR2(60)  := NULL;
l_state                  VARCHAR2(60)  := NULL;
l_county                 VARCHAR2(60)  := NULL;
l_area_code              VARCHAR2(60)  := NULL;
l_party_name             VARCHAR2(360) := NULL;
l_web_availability_flag  VARCHAR2(1)   := NULL;
l_am_calling_doc_type    VARCHAR2(2)   := 'SR';
l_resource_type 	 VARCHAR2(30)  := p_group_type;
l_contract_res_flag      VARCHAR2(3);
l_ib_resource_flag       VARCHAR2(3);
c_customer_phone_id NUMBER := p_service_request_rec.customer_phone_id;

l_cs_sr_chk_res_cal_avl VARCHAR2(1) ; --gasankar Calendar check feature added

l_start_date  Date  ;
l_end_date    Date ;


l_day_week		     VARCHAR2(10) ;
l_time_day		     VARCHAR2(10) ;

-- List of Cursors
CURSOR c_inc_address(p_incident_location_id NUMBER) is
SELECT country,province,state,city,postal_code,county
FROM   hz_locations
WHERE  location_id = p_incident_location_id;

-- Added for 11.5.10 Incident Location Type ER
CURSOR c_inc_party_site_address(p_party_site_id NUMBER) IS
SELECT location_id FROM hz_party_sites
WHERE  party_site_id = p_party_site_id;

CURSOR C_CONTRACT(l_contract_service_id NUMBER)is
SELECT TO_NUMBER(object1_id1), TO_NUMBER(object1_id2)
FROM   okc_k_items
WHERE  cle_id = l_contract_service_id;

CURSOR C_CLASS_CODE(l_party_id NUMBER,l_cust_category VARCHAR2) IS
SELECT class_code
FROM   hz_code_assignments
WHERE  owner_table_name = 'HZ_PARTIES'
AND    owner_table_id   = l_party_id
AND    class_category   = l_cust_category;

--Bug 5255184 Modified the c_area_code query
CURSOR c_area_code IS
SELECT hzp.phone_area_code
FROM   hz_contact_points hzp
WHERE  hzp.contact_point_id = c_customer_phone_id;

CURSOR c_cust_det(p_customer_id NUMBER) IS
SELECT employees_total, party_name
FROM   hz_parties
WHERE  party_id = p_customer_id;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_incident_id := p_incident_id;
  l_cust_prod_id     := l_sr_rec.customer_product_id;

  -- if incident_id is not null proceed, else exit API
  -- group type must have a value - default is RS_GROUP, passed by caller
  IF (l_incident_id IS NOT NULL) AND (p_group_type IS NOT NULL) THEN
    l_resource_type := p_group_type;

    IF (FND_PROFILE.VALUE('CS_SR_USE_BUS_PROC_AUTO_ASSIGN') = 'YES') THEN
      SELECT business_process_id INTO l_business_process_id
      FROM   cs_incident_types
      WHERE  incident_type_id = l_sr_rec.type_id;
    END IF;

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

     l_sr_am_rec.DAY_OF_WEEK := l_day_week ;
     l_sr_am_rec.TIME_OF_DAY := l_time_day ;
--  4365612 Removed the profile check "Service : Use Component Subcomponent in Assignment (Reserved)"
--  Assigning component and subcomponent id directly to the am rec

 IF (l_cust_prod_id IS NOT NULL) THEN
    l_sr_am_rec.item_component := l_sr_rec.cp_component_id;
    l_sr_am_rec.item_subcomponent := l_sr_rec.cp_subcomponent_id;
 ELSE
    l_sr_am_rec.item_component := l_sr_rec.inv_component_id;
    l_sr_am_rec.item_subcomponent :=  l_sr_rec.inv_subcomponent_id;
 END IF;


    IF (p_service_request_rec.incident_location_id IS NOT NULL) THEN
    -- Added in 11.5.9 ER# 2527850
      IF (p_service_request_rec.incident_location_type = 'HZ_PARTY_SITE') THEN
        OPEN  c_inc_party_site_address(p_service_request_rec.incident_location_id);
        FETCH c_inc_party_site_address INTO l_location_id;
        IF (c_inc_party_site_address%NOTFOUND) THEN
          l_location_id := NULL;
        END IF;
        CLOSE c_inc_party_site_address;
      END IF;
      OPEN  c_inc_address(l_location_id);
      FETCH c_inc_address INTO l_country,l_province,l_state,l_city,
            l_postal_code, l_county;
      IF (c_inc_address%NOTFOUND) THEN
        NULL;
      END IF;
      l_sr_am_rec.country     := l_country;
      l_sr_am_rec.city        := l_city;
      l_sr_am_rec.postal_code := l_postal_code;
      l_sr_am_rec.state       := l_state;
      l_sr_am_rec.province    := l_province;
      l_sr_am_rec.county      := l_county;
      CLOSE c_inc_address;
    ELSE
      l_sr_am_rec.country     := p_service_request_rec.incident_country;
      l_sr_am_rec.city        := p_service_request_rec.incident_city;
      l_sr_am_rec.postal_code := p_service_request_rec.incident_postal_code;
      l_sr_am_rec.state       := p_service_request_rec.incident_state;
      l_sr_am_rec.province    := p_service_request_rec.incident_province;
      l_sr_am_rec.county      := p_service_request_rec.incident_county;
    END IF;

    --Bug 5255184 Modified the c_area_code
    OPEN c_area_code;
    FETCH c_area_code INTO l_area_code;
    IF (c_area_code%NOTFOUND) THEN
      l_area_code := NULL;
    END IF;
    CLOSE c_area_code;

    OPEN  c_cust_det(l_sr_rec.customer_id);
    FETCH c_cust_det INTO l_no_of_employees, l_party_name;
    IF (c_cust_det%NOTFOUND) THEN
      l_no_of_employees := NULL;
    END IF;
    CLOSE c_cust_det;

    l_sr_am_rec.service_request_id   := l_incident_id;
    l_sr_am_rec.party_id             := l_sr_rec.customer_id;
    l_sr_am_rec.incident_type_id     := l_sr_rec.type_id;
    l_sr_am_rec.incident_severity_id := l_sr_rec.severity_id;
    l_sr_am_rec.incident_urgency_id  := l_sr_rec.urgency_id;
    l_sr_am_rec.problem_code         := l_sr_rec.problem_code;
    l_sr_am_rec.incident_status_id   := l_sr_rec.status_id;
    l_sr_am_rec.platform_id          := l_sr_rec.platform_id;
    l_sr_am_rec.inventory_item_id    := l_sr_rec.inventory_item_id;
    l_sr_am_rec.sr_creation_channel  := l_sr_rec.sr_creation_channel;
    l_sr_am_rec.area_code            := l_area_code;
    --l_sr_am_rec.customer_site_id   := l_sr_rec.customer_site_id;
    --l_sr_am_rec.support_site_id    := l_sr_rec.site_id;
    l_sr_am_rec.squal_char12         := l_sr_rec.problem_code;
    l_sr_am_rec.squal_char13         := l_sr_rec.comm_pref_code;
    l_sr_am_rec.squal_char20         := l_sr_rec.cust_pref_lang_code;
    l_sr_am_rec.squal_num12          := l_sr_rec.platform_id;
    l_sr_am_rec.squal_num13          := l_sr_rec.inv_platform_org_id;
    l_sr_am_rec.squal_num14          := l_sr_rec.category_id;
    l_sr_am_rec.squal_num15          := l_sr_rec.inventory_item_id;
    l_sr_am_rec.squal_num16          := l_sr_rec.inventory_org_id;
    l_sr_am_rec.squal_num17          := NULL;
    l_sr_am_rec.squal_num30          := l_sr_rec.language_id;
    l_sr_am_rec.squal_char21         := l_sr_rec.coverage_type;
    l_sr_am_rec.num_of_employees     := l_no_of_employees;
    l_sr_am_rec.comp_name_range      := l_party_name;

    --Contract Item and Org dtls
    IF (l_contract_service_id is not null) then
      OPEN C_CONTRACT(l_contract_service_id);
      FETCH C_CONTRACT INTO l_inv_item_id,l_inv_org_id;
      IF (C_CONTRACT%NOTFOUND) THEN
        NULL;
      END IF;
      CLOSE C_CONTRACT;
    END IF;
    l_sr_am_rec.squal_num18 := l_inv_item_id;
    l_sr_am_rec.squal_num19 := l_inv_org_id;

    /* Waiting for JTA patch for their sql change so comment out for now
    --VIP Customer Code
    IF (l_party_id IS NOT NULL) THEN
      OPEN C_CLASS_CODE(l_party_id,l_cust_category);
      FETCH C_CLASS_CODE INTO l_class_code;
      IF (C_CLASS_CODE%NOTFOUND) THEN
        NULL;
      END IF;
      CLOSE C_CLASS_CODE;
    END IF;
    l_sr_am_rec.squal_char11 := l_class_code;
    */
    l_class_code := null;

    -- populate the form parameters
    l_am_calling_doc_id := l_incident_id;

    -- Passing the auto_select_flag as 'N' bcoz if it is null the JTF API
    -- assigns it as 'Y' and always returns the first record. No Load Balancing
    -- is done.
    -- If customer product id is not null, then set ib_preferred_resource_flag
    -- to 'Y'.If contract line id is not null, then set
    -- contract_preferred_resource flag to 'Y'.
    IF (l_contract_service_id IS NOT NULL) THEN
      l_contract_res_flag := 'Y';
    ELSE
      l_contract_res_flag := 'N';
    END IF;
    IF (l_cust_prod_id IS NOT NULL) THEN
      l_ib_resource_flag := 'Y';
    ELSE
      l_ib_resource_flag := 'N';
    END IF;

    FND_PROFILE.Get('CS_SR_CHK_RES_CAL_AVL', l_cs_sr_chk_res_cal_avl); --gasankar Calendar check feature added
    If nvl(l_cs_sr_chk_res_cal_avl, 'N') <> 'N' Then
	l_start_date := sysdate ;
 	l_end_date   := sysdate ;
    End If ;

    JTF_ASSIGN_PUB.GET_Assign_Resources
      ( p_api_version                  => 1.0,
	p_init_msg_list                => 'T',
	p_commit                       => 'F',
	p_resource_id                  => NULL,
	p_resource_type                => l_resource_type,
	p_role                         => NULL,
	p_no_of_resources              => l_no_of_resources,
	p_auto_select_flag             => NULL,
	p_contracts_preferred_engineer => l_contract_res_flag,
	p_ib_preferred_engineer        => l_ib_resource_flag,
	p_effort_duration              => NULL,
	p_effort_uom                   => NULL,
	p_start_date                    => l_start_date,
	p_end_date                      => l_end_date,
	p_territory_flag               => 'Y',
        p_calendar_flag                =>  nvl(l_cs_sr_chk_res_cal_avl, 'N') ,
	p_calendar_check	       =>  nvl(l_cs_sr_chk_res_cal_avl, 'N') ,
       	p_web_availability_flag        => 'Y',
        p_filter_excluded_resource     => 'Y',
       	p_category_id                  => NULL,
       	p_inventory_item_id            => NULL,
       	p_inventory_org_id             => NULL,
    	p_column_list                  => NULL,
       	p_calling_doc_id               => NULL,
	p_calling_doc_type             => 'SR',
	p_sr_rec                       => l_sr_am_rec,
	p_sr_task_rec                  => NULL,
	p_defect_rec                   => NULL,
        p_business_process_id          => l_business_process_id,
        p_business_process_date        => l_sr_rec.request_date,
	x_Assign_Resources_tbl         => l_Assign_Groups_tbl,
	x_return_status                => x_return_status,
	x_msg_count                    => x_msg_count,
	x_msg_data                     => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_Assign_Groups_tbl.COUNT > 0) THEN
      CS_ASSIGN_RESOURCE_PKG.Get_Sup_Usage_Group(
               l_Assign_Groups_tbl, x_resource_id, x_territory_id);
      END IF;
    END IF;

  END IF; /* l_incident_id is not null */
END Assign_Group;
/*==========================================================================================+
  ==
  ==  Procedure name      : Assign_Owner
  ==  Parameters          :
  ==  IN                  : event VARCHAR2
  ==  OUT                 : none.
  ==
  ==  Description         : This Procedure returns the individual Owner from the Group
  ==			    returned by the Assign_Group Procedure.
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  == ----------  ---------  ---------------------------------------------
  == 08/02/2007  GASANKAR   Bug 6241796 Fixed
  ==                        Initializing p_res_load_table(l_tbl_index).resource_type ,
  ==                        resource_id if the resource is not belonging to a group.
  == 07/09/2007  GASANKAR   Bug 6391261 Fixed
  ==			    First record of the p_res_load_table is not been left blank, so
  ==			    that contract preferred resource will work properly.
  ===========================================================================================*/
PROCEDURE Assign_Owner
  (p_init_msg_list  	  IN   VARCHAR2  := fnd_api.g_false,
   p_commit         	  IN   VARCHAR2  := fnd_api.g_false,
   p_incident_id    	  IN   NUMBER,
   p_param_resource_type  IN   VARCHAR2,
   p_group_id       	  IN   NUMBER,
   p_service_request_rec  IN   CS_ServiceRequest_pvt.service_request_rec_type,
   x_return_status  	  OUT  NOCOPY   VARCHAR2,
   x_resource_id    	  OUT  NOCOPY   NUMBER,
   x_resource_type  	  OUT  NOCOPY   VARCHAR2,
   x_territory_id         OUT  NOCOPY   NUMBER,
   x_msg_count      	  OUT  NOCOPY   NUMBER,
   x_msg_data	      	  OUT  NOCOPY   VARCHAR2
  ) IS

--profiles variables
l_web_availability_check  VARCHAR2(1);
l_category_set_id         NUMBER;
l_platform_catg_set_id    NUMBER;
l_api_name                CONSTANT VARCHAR2(30) := 'Assign_ServiceRequest_Main';
l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
l_msg                     VARCHAR2(2000) ;
-- input and output data structures
l_Assign_Owner_tbl       JTF_ASSIGN_PUB.AssignResources_tbl_type ;
l_sr_am_rec              JTF_ASSIGN_PUB.JTF_Serv_req_rec_type;
l_resource_load_tbl      CS_ASSIGN_RESOURCE_CON_PKG.LoadBalance_tbl_type;
l_index			 BINARY_INTEGER;
l_count			 NUMBER;
p			 NUMBER;
l                        NUMBER;
l_cal_load_return_sts    VARCHAR2(1) := null;
l_sr_rec                 CS_ServiceRequest_pvt.service_request_rec_type DEFAULT p_service_request_rec;
--qualifier values
l_incident_id            NUMBER := p_incident_id;
l_contract_service_id    NUMBER := p_service_request_rec.contract_service_id;
l_inv_item_id            NUMBER := NULL;
l_inv_org_id             NUMBER := NULL;
l_inv_category_id        NUMBER := NULL ;
l_party_id           	 NUMBER := p_service_request_rec.customer_id;
l_group_id               NUMBER := p_group_id;
l_cust_prod_id           NUMBER := p_service_request_rec.customer_product_id;
l_location_id            NUMBER := p_service_request_rec.incident_location_id;
l_class_code             VARCHAR2(30)  := NULL;
l_cust_category          VARCHAR2(30)  := NULL;
l_country		 VARCHAR2(60)  := NULL;
l_province               VARCHAR2(60)  := NULL;
l_postal_code            VARCHAR2(60)  := NULL;
l_city                   VARCHAR2(60)  := NULL;
l_state                  VARCHAR2(60)  := NULL;
l_county                 VARCHAR2(60)  := NULL;
l_party_name             VARCHAR2(360) := NULL;
l_web_availability_flag  VARCHAR2(1)   := NULL;
l_am_calling_doc_type    VARCHAR2(2)   := 'SR';
l_ismember               VARCHAR2(1)   := 'N';
l_param_resource_type    VARCHAR2(30)  := p_param_resource_type;
l_am_calling_doc_id      NUMBER        := NULL;
l_no_of_resources        NUMBER        := NULL;
l_no_of_employees        NUMBER        := NULL;
l_product_skill_level    NUMBER;
l_counter	         NUMBER;
l_cat_wt                 NUMBER;
l_prod_wt                NUMBER;
l_prob_wt                NUMBER;
l_business_process_id    NUMBER;
l_area_code              VARCHAR2(60);
l_contract_res_flag      VARCHAR2(3);
l_ib_resource_flag       VARCHAR2(3);
l_prod_skill_check       VARCHAR2(3);

l_day_week		     VARCHAR2(10) ;
l_time_day		     VARCHAR2(10) ;

l_cs_sr_chk_res_cal_avl VARCHAR2(1) ; --gasankar Calendar check feature added

l_start_date  Date  ;
l_end_date    Date ;

c_customer_phone_id NUMBER := p_service_request_rec.customer_phone_id;
-- List of Cursors
CURSOR c_inc_address(p_incident_location_id NUMBER) IS
SELECT country,province,state,city,postal_code,county
FROM   hz_locations
WHERE  location_id = p_incident_location_id;

-- Added for 11.5.10 Incident Location Type ER
CURSOR c_inc_party_site_address(p_party_site_id NUMBER) IS
SELECT location_id FROM hz_party_sites
WHERE  party_site_id = p_party_site_id;

CURSOR c_contract(l_contract_service_id NUMBER) IS
SELECT TO_NUMBER(object1_id1), TO_NUMBER(object1_id2)
FROM   okc_k_items
WHERE  cle_id = l_contract_service_id;

CURSOR c_class_code(l_party_id NUMBER,l_cust_category VARCHAR2) is
SELECT class_code
FROM   hz_code_assignments
WHERE  owner_table_name = 'HZ_PARTIES'
AND    owner_table_id   = l_party_id
AND    class_category   = l_cust_category;

--Added in 11.5.9
CURSOR c_load_wt(l_incident_type_id NUMBER,l_incident_severity_id NUMBER) IS
       select product_skill_wt,prob_code_skill_wt, category_skill_wt
         from cs_sr_load_balance_wt
         where incident_type_id = l_incident_type_id
         and incident_severity_id = l_incident_severity_id;

-- Added in 11.5.9. Fetch phone area code for the customer.
--Bug 5255184 Modified the c_area_code query
CURSOR c_area_code IS
SELECT hzp.phone_area_code
FROM   hz_contact_points hzp
WHERE  hzp.contact_point_id = c_customer_phone_id;

-- Added for member filtering for IB/Contracts Preferred Resources
-- From 11.5.10 onwards
CURSOR c_check_grp_res(p_group_id NUMBER, p_resource_id NUMBER) IS
SELECT 'Y'
FROM   jtf_rs_group_members
WHERE  group_id = p_group_id
AND    resource_id = p_resource_id
AND    NVL(delete_flag, 'N') <> 'Y';

CURSOR c_cust_det(p_customer_id NUMBER) IS
SELECT employees_total, party_name
FROM   hz_parties
WHERE  party_id = p_customer_id;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_incident_id := p_incident_id;
  l_cust_prod_id     := l_sr_rec.customer_product_id;
  -- if incident_id is not null proceed, otherwise exit API
  IF ((l_incident_id IS NOT NULL) AND (p_group_id IS NOT NULL )) THEN
    l_group_id := p_group_id ;

    IF (FND_PROFILE.VALUE('CS_SR_USE_BUS_PROC_AUTO_ASSIGN') = 'YES') THEN
      SELECT business_process_id INTO l_business_process_id
      FROM   cs_incident_types
      WHERE  incident_type_id = l_sr_rec.type_id;
    END IF;

--  4365612 Removed the profile check "Service : Use Component Subcomponent in Assignment (Reserved)"
--  Assigning component and subcomponent id directly to the am rec

 IF (l_cust_prod_id IS NOT NULL) THEN
    l_sr_am_rec.item_component := l_sr_rec.cp_component_id;
    l_sr_am_rec.item_subcomponent := l_sr_rec.cp_subcomponent_id;
 ELSE
    l_sr_am_rec.item_component := l_sr_rec.inv_component_id;
    l_sr_am_rec.item_subcomponent :=  l_sr_rec.inv_subcomponent_id;
 END IF;

    IF (p_service_request_rec.incident_location_id IS NOT NULL) THEN
      -- Added  for 11.5.9 ER# 2527850
      IF (p_service_request_rec.incident_location_type = 'HZ_PARTY_SITE') THEN
        OPEN  c_inc_party_site_address(p_service_request_rec.incident_location_id);
        FETCH c_inc_party_site_address INTO l_location_id;
        IF (c_inc_party_site_address%NOTFOUND) THEN
          l_location_id := NULL;
        END IF;
        CLOSE c_inc_party_site_address;
      END IF;
      OPEN  c_inc_address(l_location_id);
      FETCH c_inc_address INTO l_country,l_province,l_state,l_city,
            l_postal_code, l_county;
      IF (c_inc_address%NOTFOUND) THEN
        NULL;
      END IF;
      l_sr_am_rec.country     := l_country;
      l_sr_am_rec.city        := l_city;
      l_sr_am_rec.postal_code := l_postal_code;
      l_sr_am_rec.state       := l_state;
      l_sr_am_rec.province    := l_province;
      l_sr_am_rec.county      := l_county;
      CLOSE c_inc_address;
    ELSE
      l_sr_am_rec.country     := p_service_request_rec.incident_country;
      l_sr_am_rec.city        := p_service_request_rec.incident_city;
      l_sr_am_rec.postal_code := p_service_request_rec.incident_postal_code;
      l_sr_am_rec.state       := p_service_request_rec.incident_state;
      l_sr_am_rec.province    := p_service_request_rec.incident_province;
      l_sr_am_rec.county      := p_service_request_rec.incident_county;
    END IF;

    OPEN  c_area_code;
    FETCH c_area_code INTO l_area_code;
    IF (c_area_code%NOTFOUND) THEN
      l_area_code := NULL;
    END IF;
    CLOSE c_area_code;

    OPEN  c_cust_det(l_sr_rec.customer_id);
    FETCH c_cust_det INTO l_no_of_employees, l_party_name;
    IF (c_cust_det%NOTFOUND) THEN
      l_no_of_employees := NULL;
      l_party_name      := NULL;
    END IF;
    CLOSE c_cust_det;
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

     l_sr_am_rec.DAY_OF_WEEK := l_day_week ;
     l_sr_am_rec.TIME_OF_DAY := l_time_day ;
    l_sr_am_rec.service_request_id   := l_incident_id;
    l_sr_am_rec.party_id             := l_sr_rec.customer_id;
    l_sr_am_rec.party_id             := l_sr_rec.customer_id;
    l_sr_am_rec.incident_type_id     := l_sr_rec.type_id;
    l_sr_am_rec.incident_severity_id := l_sr_rec.severity_id;
    l_sr_am_rec.incident_urgency_id  := l_sr_rec.urgency_id;
    l_sr_am_rec.problem_code         := l_sr_rec.problem_code;
    l_sr_am_rec.incident_status_id   := l_sr_rec.status_id;
    l_sr_am_rec.platform_id          := l_sr_rec.platform_id;
    l_sr_am_rec.inventory_item_id    := l_sr_rec.inventory_item_id;
    l_sr_am_rec.sr_creation_channel  := l_sr_rec.sr_creation_channel;
    l_sr_am_rec.area_code            := l_area_code;
    --l_sr_am_rec.customer_site_id   := l_sr_rec.customer_site_id;
    --l_sr_am_rec.support_site_id    := l_sr_rec.site_id;
    l_sr_am_rec.squal_char12         := l_sr_rec.problem_code;
    l_sr_am_rec.squal_char13         := l_sr_rec.comm_pref_code;
    l_sr_am_rec.squal_char20         := l_sr_rec.cust_pref_lang_code ;
    l_sr_am_rec.squal_char21         := l_sr_rec.coverage_type;
    l_sr_am_rec.squal_num12          := l_sr_rec.platform_id;
    l_sr_am_rec.squal_num13          := l_sr_rec.inv_platform_org_id;
    l_sr_am_rec.squal_num14          := l_sr_rec.category_id;
    l_sr_am_rec.squal_num15          := l_sr_rec.inventory_item_id;
    l_sr_am_rec.squal_num16          := l_sr_rec.inventory_org_id;
    l_sr_am_rec.squal_num17          := l_group_id;
    l_sr_am_rec.squal_num30          := l_sr_rec.language_id;
    l_sr_am_rec.num_of_employees     := l_no_of_employees;
    l_sr_am_rec.comp_name_range      := l_party_name;

    --Contract Item and Org dtls
    IF (l_contract_service_id IS NOT NULL) THEN
      OPEN c_contract(l_contract_service_id);
      FETCH c_contract INTO l_inv_item_id,l_inv_org_id;
      IF c_contract%NOTFOUND THEN
        NULL;
      END IF;
      CLOSE c_contract;
    END IF;
    -- For contracts
    l_sr_am_rec.squal_num18  := l_inv_item_id;
    l_sr_am_rec.squal_num19  := l_inv_org_id;
    l_sr_am_rec.squal_char11 := NULL;

    -- populate the  AM parameters
    l_am_calling_doc_id   := l_incident_id;
    l_param_resource_type := p_param_resource_type;

    -- If customer product id is not null, then set ib_preferred_resource_flag
    -- to 'Y'.If contract line id is not null, then set
    -- contract_preferred_resource flag to 'Y'.
    IF (l_contract_service_id IS NOT NULL) THEN
      l_contract_res_flag := 'Y';
    ELSE
      l_contract_res_flag := 'N';
    END IF;
    IF (l_cust_prod_id IS NOT NULL) THEN
      l_ib_resource_flag      := 'Y';
    ELSE
      l_ib_resource_flag := 'N';
    END IF;

   FND_PROFILE.Get('CS_SR_CHK_RES_CAL_AVL', l_cs_sr_chk_res_cal_avl); --gasankar Calendar check feature added

    If nvl(l_cs_sr_chk_res_cal_avl, 'N') <> 'N' Then
	l_start_date := sysdate ;
	l_end_date   := sysdate ;
    End If ;

    l_param_resource_type := 'RS_INDIVIDUAL';

    -- Passing the auto_select_flag as 'N' bcoz if it is null the JTF API
    -- assigns it as 'Y' and always returns the first record. No Load Balancing
    -- is done. Made contracts_preferred_engineer as 'Y' for 11.5.9 according
    -- to whether contract_service_id is not null.
    -- From 11.5.9+, the contract_id, inventory_item_id and inventory_org_id
    -- are always passed as Null and the Load Balancing will be done for all
    -- the resources with or without skills.
    JTF_ASSIGN_PUB.GET_Assign_Resources
      ( p_api_version                   => 1.0,
        p_init_msg_list                 => 'T',
        p_commit                        => 'F',
        p_resource_id                   => l_group_id,
        p_resource_type                 => l_param_resource_type,
        p_role                          => null,
        p_no_of_resources               => l_no_of_resources,
        p_auto_select_flag              => 'N',
        p_ib_preferred_engineer         => l_ib_resource_flag,
        p_contracts_preferred_engineer  => l_contract_res_flag,
        p_contract_id                   => l_contract_service_id,
        p_customer_product_id           => l_cust_prod_id,
        p_effort_duration               => null,
        p_effort_uom                    => null,
	p_start_date                    => l_start_date,
	p_end_date                      => l_end_date,
        p_territory_flag                => 'Y',
        p_calendar_flag                =>  nvl(l_cs_sr_chk_res_cal_avl, 'N') ,
	p_calendar_check	       =>  nvl(l_cs_sr_chk_res_cal_avl, 'N') ,
        p_web_availability_flag         => 'Y',
        p_filter_excluded_resource      => 'Y',
        p_category_id                   => NULL,
        p_inventory_item_id             => NULL,
        p_inventory_org_id              => NULL,
        p_column_list                   => null,
        p_calling_doc_id                => l_am_calling_doc_id,
        p_calling_doc_type              => l_am_calling_doc_type,
        p_sr_rec                        => l_sr_am_rec,
        p_sr_task_rec                   => null,
        p_defect_rec                    => null,
        p_business_process_id           => l_business_process_id,
        p_business_process_date         => l_sr_rec.request_date,
        x_Assign_Resources_tbl          => l_Assign_Owner_tbl,
        x_return_status                 => x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      p := l_Assign_Owner_tbl.FIRST ;
      if (l_Assign_Owner_tbl.count = 1  AND
        l_Assign_Owner_tbl(p).web_availability_flag = 'Y') then
        OPEN  c_check_grp_res(l_group_id, l_Assign_Owner_tbl(p).resource_id);
        FETCH c_check_grp_res INTO l_ismember;
        CLOSE c_check_grp_res;
        IF (NVL(l_ismember, 'N') = 'Y') THEN
          x_resource_id   := l_Assign_Owner_tbl(p).resource_id ;
          x_resource_type := l_Assign_Owner_tbl(p).resource_type ;
          x_territory_id  := l_Assign_Owner_tbl(p).terr_id;
        END IF;
      END IF;

      IF (l_Assign_Owner_tbl.COUNT > 1) THEN
        l_count   := l_Assign_Owner_tbl.COUNT;
        l_index   := l_Assign_Owner_tbl.FIRST;
        l_counter := l_Assign_Owner_tbl.FIRST ;
        WHILE l_index <= l_count
        LOOP
          l_ismember := 'N';
          IF (l_Assign_Owner_tbl(l_index).web_availability_flag = 'Y') THEN
              OPEN  c_check_grp_res(l_group_id, l_Assign_Owner_tbl(l_index).resource_id);
              FETCH c_check_grp_res INTO l_ismember;
              CLOSE c_check_grp_res;
              IF (NVL(l_ismember, 'N') = 'Y') THEN
                l_resource_load_tbl(l_counter).resource_id :=
                           l_Assign_Owner_tbl(l_index).resource_id;
                l_resource_load_tbl(l_counter).resource_type :=
                           l_Assign_Owner_tbl(l_index).resource_type;
                l_resource_load_tbl(l_counter).support_site_id :=
                           l_Assign_Owner_tbl(l_index).support_site_id;
	        l_resource_load_tbl(l_counter).territory_id :=
                           l_Assign_Owner_tbl(l_index).terr_id;
              ELSE
	      /* Start Bug : 6241796 */
		l_resource_load_tbl(l_counter).resource_id :=
                            Null;
		l_resource_load_tbl(l_counter).resource_type :=
                            Null ;
		l_resource_load_tbl(l_counter).support_site_id :=
                            Null ;
		l_resource_load_tbl(l_counter).territory_id :=
                            Null ; /* End Bug : 6241796 */
	      END IF;

            /* Start Bug : 6391261 */
              IF ( l_Counter = l_Assign_Owner_tbl.FIRST AND nvl(l_ismember, 'N') = 'N' ) Then
                null ;
              ELSE
		l_counter := l_counter + 1;
	      END IF ;
	     /* End Bug : 6391261 */
          END IF;
          l_index := l_index + 1;
        END LOOP;

        IF (l_resource_load_tbl.COUNT > 1) THEN
          CS_ASSIGN_RESOURCE_CON_PKG.Calculate_Load
            ( p_init_msg_list => p_init_msg_list,
              p_incident_id => p_incident_id,
              p_incident_type_id => p_service_request_rec.type_id,
              p_incident_severity_id => p_service_request_rec.severity_id,
              p_inv_item_id => p_service_request_rec.inventory_item_id,
              p_inv_org_id  => p_service_request_rec.inventory_org_id,
              p_platform_org_id => p_service_request_rec.inv_platform_org_id,
              p_inv_cat_id => p_service_request_rec.category_id,
              p_platform_id  => p_service_request_rec.platform_id,
              p_problem_code => p_service_request_rec.problem_code,
              p_contact_timezone_id => p_service_request_rec.time_zone_id,
              p_res_load_table => l_resource_load_tbl,
              x_return_status  => l_cal_load_return_sts,
              x_resource_id    => x_resource_id,
              x_resource_type  => x_resource_type,
              x_msg_count      => x_msg_count,
              x_msg_data           => x_msg_data,
              x_territory_id         => x_territory_id
            );

          IF (l_cal_load_return_sts <>  FND_API.G_RET_STS_SUCCESS) THEN
          /* due to TZ API error, but continue if resource is returned */
            IF (x_resource_id IS NOT NULL) THEN
              x_return_status       := FND_API.G_RET_STS_SUCCESS;
              l_cal_load_return_sts := FND_API.G_RET_STS_SUCCESS;
            END IF;
          END IF;

          IF (l_cal_load_return_sts <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.Set_Name('CS', 'CS_API_NO_OWNER');
            FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
            l_msg := fnd_message.get ;
            fnd_file.put_line(fnd_file.log,'     ' || l_msg);
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
        ELSE
          IF (l_resource_load_tbl.COUNT = 1) THEN
            l := l_resource_load_tbl.FIRST;
            x_resource_id := l_resource_load_tbl(l).resource_id;
            x_resource_type := l_resource_load_tbl(l).resource_type;
	    x_territory_id := l_resource_load_tbl(l).territory_id;
          END IF;
        END IF; -- l_resource_load_tbl.Count >1
      --  x_territory_id := l_Assign_Owner_tbl(l).terr_id;
      END IF; -- l_Assign_Owner_tbl.Count > 1
    END IF ; --Return status S
  END IF; -- l_incident_id is not null
END Assign_Owner;

-- Added parameter p_inv_cat_id by pnkalari on 06/11/2002.
PROCEDURE Calculate_Load
  (p_init_msg_list  	  IN      VARCHAR2  := fnd_api.g_false,
   p_incident_id    	  IN      NUMBER,
   p_incident_type_id 	  IN      NUMBER,
   p_incident_severity_id IN      NUMBER,
   p_inv_item_id    	  IN      NUMBER,
   p_inv_org_id     	  IN      NUMBER,
   p_inv_cat_id           IN      NUMBER,
   p_platform_org_id 	  IN      NUMBER,
   p_platform_id     	  IN      NUMBER,
   p_problem_code    	  IN      VARCHAR2,
   p_contact_timezone_id  IN      NUMBER,
   p_res_load_table  	  IN OUT  NOCOPY   CS_ASSIGN_RESOURCE_CON_PKG.LoadBalance_tbl_type,
   x_return_status  	  OUT     NOCOPY   VARCHAR2,
   x_resource_id    	  OUT     NOCOPY   NUMBER,
   x_resource_type  	  OUT     NOCOPY   VARCHAR2,
   x_msg_count      	  OUT     NOCOPY   NUMBER,
   x_msg_data	          OUT     NOCOPY   VARCHAR2,
   x_territory_id         OUT  NOCOPY   NUMBER
  ) IS

-- Define Local Variables
l_api_name             CONSTANT VARCHAR2(30) := 'Assign_ServiceRequest_Main';
l_api_name_full        CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
l_msg                  VARCHAR2(2000) ;
l_resource_id          NUMBER;
l_resource_type        VARCHAR2(30);
l_support_site_id      NUMBER;
l_return_status        VARCHAR2(1);
l_incident_type_id     NUMBER;
l_incident_severity_id NUMBER;
l_wt_prd_skill         NUMBER;
l_wt_plt_skill         NUMBER;
l_wt_pbm_skill         NUMBER;
l_wt_cat_skill         NUMBER;
l_wt_time_last_login   NUMBER;
l_wt_backlog_sev1      NUMBER;
l_wt_backlog_sev2      NUMBER;
l_wt_backlog_sev3      NUMBER;
l_wt_backlog_sev4      NUMBER;
l_wt_time_zone_lag     NUMBER;
l_res_load             NUMBER;
l_max_total_load       NUMBER;
l_tbl_index            BINARY_INTEGER;
i                      BINARY_INTEGER;
l_count                NUMBER;
l_max_record_index     BINARY_INTEGER;
l_supp_timezone_id     NUMBER;
l_contact_timezone_id  NUMBER       := p_contact_timezone_id;
l_time_lag             NUMBER;
l_time_lag_score       NUMBER       := 0;
l_problem_code         VARCHAR2(50) := p_problem_code;
l_prod_skill           NUMBER       := NULL;
l_plat_skill           NUMBER       := NULL;
l_prob_skill           NUMBER       := NULL;
l_cat_skill            NUMBER       := NULL;
l_time_last_login      NUMBER       := NULL;
l_backlog_sev1         NUMBER       := NULL;
l_backlog_sev2         NUMBER       := NULL;
l_backlog_sev3         NUMBER       := NULL;
l_backlog_sev4         NUMBER       := NULL;
l_imp_level            NUMBER       := NULL;
-- List of Cursors
CURSOR c_load_wt(l_incident_type_id NUMBER,l_incident_severity_id NUMBER) IS
SELECT product_skill_wt,platform_skill_wt,prob_code_skill_wt, category_skill_wt,
       last_login_time_wt,severity1_count_wt,severity2_count_wt,
       severity3_count_wt,severity4_count_wt,time_zone_diff_wt
FROM   cs_sr_load_balance_wt
WHERE  incident_type_id     = l_incident_type_id
AND    incident_severity_id = l_incident_severity_id;

CURSOR C_PROD_SKILL(l_prod_id NUMBER,l_prod_org_id NUMBER,l_resource_id NUMBER) IS
SELECT s.skill_level
FROM   jtf_rs_skill_levels_vl s,
       jtf_rs_resource_skills rs
WHERE  rs.resource_id    = l_resource_id
AND    rs.product_id     = l_prod_id
AND    rs.product_org_id = l_prod_org_id
AND    rs.skill_level_id = s.skill_level_id;
-- and nvl(rs.category_id,0) = nvl(l_cat_id,0)

CURSOR C_PLAT_SKILL(l_platform_id NUMBER,l_platform_org_id NUMBER,l_resource_id NUMBER) IS
SELECT s.skill_level
FROM   jtf_rs_skill_levels_vl s,
       jtf_rs_resource_skills rs
WHERE rs.resource_id   = l_resource_id
AND rs.platform_id     = l_platform_id
AND rs.platform_org_id = l_platform_org_id
AND rs.skill_level_id  = s.skill_level_id;

CURSOR C_PROB_SKILL(l_problem_code VARCHAR2,l_resource_id NUMBER) IS
SELECT s.skill_level
FROM   jtf_rs_skill_levels_vl s,
       jtf_rs_resource_skills rs
WHERE  rs.resource_id    = l_resource_id
AND    rs.problem_code   = l_problem_code
AND    rs.skill_level_id = s.skill_level_id;

-- Added cursor to fetch the Category Skill for ER# 2527963.
CURSOR c_cat_skill(l_category_id NUMBER, l_resource_id NUMBER) IS
SELECT s.skill_level
FROM   jtf_rs_skill_levels_vl s,
       jtf_rs_resource_skills rs
WHERE  rs.resource_id    = l_resource_id
AND    rs.category_id    = l_category_id
AND    rs.skill_level_id = s.skill_level_id;

CURSOR c_time_last_login(l_resource_id NUMBER) IS
SELECT ROUND(((SYSDATE - nvl( max(owner_assigned_time),to_date('1990-01-01','yyyy-mm-dd'))) *24 * 60),2)
FROM   cs_incidents_all_b
WHERE  incident_owner_id = l_resource_id;

-- Commented above and added for Bug# 3562642
CURSOR c_imp_level(p_inc_severity_id NUMBER) IS
SELECT importance_level
FROM   cs_incident_severities_vl
WHERE  incident_subtype = 'INC'
AND    incident_severity_id = p_inc_severity_id;

CURSOR c_sev1_cnt(l_sev1_id NUMBER,l_resource_id NUMBER) IS
SELECT COUNT(*)
FROM   cs_incidents_all_b
WHERE  incident_severity_id = l_sev1_id
AND    incident_owner_id    = l_resource_id
AND    incident_status_id NOT IN (
       SELECT incident_status_id
       FROM cs_incident_statuses_vl
       WHERE incident_subtype = 'INC'
       AND   close_flag       = 'Y');

CURSOR c_sev2_cnt(l_sev2_id NUMBER ,l_resource_id NUMBER) IS
SELECT COUNT(*)
FROM   cs_incidents_all_b
WHERE  incident_severity_id = l_sev2_id
AND    incident_owner_id    = l_resource_id
AND    incident_status_id NOT IN (
       SELECT incident_status_id
       FROM   cs_incident_statuses_vl
       WHERE  incident_subtype = 'INC'
       AND    close_flag       = 'Y');

CURSOR c_sev3_cnt(l_sev3_id NUMBER,l_resource_id NUMBER) IS
SELECT COUNT(*)
FROM   cs_incidents_all_b
WHERE  incident_severity_id = l_sev3_id
AND    incident_owner_id = l_resource_id
AND    incident_status_id NOT IN (
       SELECT incident_status_id
       FROM   cs_incident_statuses_vl
       WHERE  incident_subtype = 'INC'
       AND    close_flag       = 'Y');

CURSOR c_sev4_cnt(l_sev4_id NUMBER,l_resource_id NUMBER) IS
SELECT COUNT(*)
FROM   cs_incidents_all_b
WHERE  incident_severity_id = l_sev4_id
AND    incident_owner_id    = l_resource_id
AND    incident_status_id NOT IN (
       SELECT incident_status_id
       FROM   cs_incident_statuses_vl
       WHERE  incident_subtype = 'INC'
       AND    close_flag       = 'Y');

CURSOR c_res_time_zone(p_resource_id NUMBER) IS
SELECT time_zone
FROM   jtf_rs_resource_extns
WHERE  resource_id = p_resource_id;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_incident_type_id := p_incident_type_id;
  l_incident_severity_id := p_incident_severity_id;

  OPEN c_load_wt(l_incident_type_id,l_incident_severity_id);
  FETCH c_load_wt INTO
        l_wt_prd_skill, l_wt_plt_skill, l_wt_pbm_skill, l_wt_cat_skill,
        l_wt_time_last_login, l_wt_backlog_sev1, l_wt_backlog_sev2 ,
        l_wt_backlog_sev3, l_wt_backlog_sev4, l_wt_time_zone_lag;
  IF (c_load_wt%NOTFOUND) THEN
       l_wt_prd_skill        := 0;
       l_wt_plt_skill        := 0;
       l_wt_pbm_skill        := 0;
       l_wt_cat_skill        := 0;
       l_wt_time_last_login  := 0;
       l_wt_backlog_sev1     := 0;
       l_wt_backlog_sev2     := 0;
       l_wt_backlog_sev3     := 0;
       l_wt_backlog_sev4     := 0;
       l_wt_time_zone_lag    := 0;
  END IF;
  CLOSE c_load_wt;

   l_tbl_index := p_res_load_table.FIRST;
   l_count := p_res_load_table.COUNT;
   WHILE l_tbl_index <= l_count
   LOOP
     l_resource_id := p_res_load_table(l_tbl_index).resource_id;
     l_resource_type := p_res_load_table(l_tbl_index).resource_type;
     l_support_site_id := p_res_load_table(l_tbl_index).support_site_id;
     l_supp_timezone_id := NULL;
     l_time_lag         := NULL;
     l_time_lag_score   := NULL;
     l_res_load         := NULL;

     IF (p_inv_item_id IS NOT NULL AND
         p_inv_org_id IS NOT NULL AND
         l_resource_id IS NOT NULL AND NVL(l_wt_prd_skill,0) >0) THEN
       OPEN  c_prod_skill(p_inv_item_id,p_inv_org_id,l_resource_id);
       FETCH c_prod_skill INTO l_prod_skill;
       IF (c_prod_skill%NOTFOUND) THEN
         l_prod_skill := NULL;
       END IF;
       CLOSE c_prod_skill;
     END IF;

     IF (p_platform_id IS NOT NULL AND
         p_platform_org_id IS NOT NULL AND
         l_resource_id IS NOT NULL AND NVL(l_wt_plt_skill,0)>0) THEN
       OPEN  c_plat_skill(p_platform_id,p_platform_org_id,l_resource_id);
       FETCH c_plat_skill INTO l_plat_skill;
       IF (c_plat_skill%NOTFOUND) THEN
         l_plat_skill := NULL;
       END IF;
       CLOSE c_plat_skill;
     END IF;

     IF (l_problem_code IS NOT NULL AND
         l_resource_id IS NOT NULL AND NVL(l_wt_pbm_skill,0)>0) THEN
       OPEN  c_prob_skill(l_problem_code,l_resource_id);
       FETCH c_prob_skill INTO l_prob_skill;
       IF (c_prob_skill%NOTFOUND) THEN
         l_prob_skill := NULL;
       END IF;
       CLOSE c_prob_skill;
     END IF;

     IF (p_inv_cat_id IS NOT NULL AND
       l_resource_id IS NOT NULL AND NVL(l_wt_cat_skill,0) >0) THEN
       OPEN c_cat_skill(p_inv_cat_id, l_resource_id);
       FETCH c_cat_skill INTO l_cat_skill;
       IF (c_cat_skill%NOTFOUND) THEN
         l_cat_skill := NULL;
       END IF;
       CLOSE c_cat_skill;
     END IF;

     -- Changed the if condition to calculate the count of SRs if
     -- l_resource_id is not null 11.5.9
     IF (l_resource_id IS NOT NULL) THEN
       IF (NVL(l_wt_time_last_login,0)<>0) THEN
         --For every resource get the backlog of severity 1,2 3, 4 SR's
         OPEN  c_time_last_login(l_resource_id);
         FETCH c_time_last_login INTO l_time_last_login;
         IF (c_time_last_login%NOTFOUND) THEN
           l_time_last_login := NULL;
         END IF;
         CLOSE c_time_last_login;
       END IF;

        OPEN c_imp_level(l_incident_severity_id);
        FETCH c_imp_level INTO l_imp_level;
        IF (c_imp_level%NOTFOUND) THEN
          l_imp_level := 0;
        END IF;
        CLOSE c_imp_level;

        IF (l_imp_level = 1 AND NVL(l_wt_backlog_sev1,0) <> 0) THEN
          OPEN  c_sev1_cnt(l_incident_severity_id,l_resource_id);
          FETCH c_sev1_cnt INTO l_backlog_sev1;
          IF (c_sev1_cnt%NOTFOUND) THEN
            l_backlog_sev1 := NULL;
          END IF;
          CLOSE c_sev1_cnt;
        ELSIF (l_imp_level = 2 AND NVL(l_wt_backlog_sev2,0) <> 0) THEN
          OPEN  c_sev2_cnt(l_incident_severity_id,l_resource_id);
          FETCH c_sev2_cnt INTO l_backlog_sev2;
          IF (c_sev2_cnt%NOTFOUND) THEN
            l_backlog_sev2 := NULL;
          END IF;
          CLOSE c_sev2_cnt;
        ELSIF (l_imp_level = 3 AND NVL(l_wt_backlog_sev3,0) <> 0) THEN
          OPEN  c_sev3_cnt(l_incident_severity_id,l_resource_id);
          FETCH c_sev3_cnt INTO l_backlog_sev3;
          IF (c_sev3_cnt%NOTFOUND) THEn
            l_backlog_sev3 := NULL;
          END IF;
          CLOSE c_sev3_cnt;
        ELSIF (l_imp_level = 4 AND NVL(l_wt_backlog_sev4,0) <> 0) THEN
          OPEN  c_sev4_cnt(l_incident_severity_id,l_resource_id);
          FETCH c_sev4_cnt INTO l_backlog_sev4;
          IF (c_sev4_cnt%NOTFOUND) THEN
            l_backlog_sev4 := NULL;
          END IF;
          CLOSE c_sev4_cnt;
        ELSE
          l_backlog_sev1 := NULL;
          l_backlog_sev2 := NULL;
          l_backlog_sev3 := NULL;
          l_backlog_sev4 := NULL;
        END IF;

     END IF; -- l_resource_id is not null

     IF (l_support_site_id IS NOT NULL  AND NVL(l_wt_time_zone_lag,0)<>0) THEN
        OPEN  c_res_time_zone(l_resource_id);
        FETCH c_res_time_zone INTO l_supp_timezone_id;
        IF (c_res_time_zone%NOTFOUND) THEN
          l_supp_timezone_id := NULL;
        END IF;
        CLOSE c_res_time_zone;
     END IF;

     IF (l_contact_timezone_id IS NOT NULL AND
         l_supp_timezone_id IS  NOT NULL) THEN
       IF (l_contact_timezone_id <> l_supp_timezone_id) THEN
         CS_TZ_GET_DETAILS_PVT.GET_LEADTIME
           (1.0,
            'T',
            l_supp_timezone_id,
            l_contact_timezone_id,
            l_time_lag,
            x_return_status,
            x_msg_count,
            x_msg_data
           );
       ELSE
         l_time_lag := 0;
       END IF;

       IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
         FND_MESSAGE.Set_Name('CS', 'CS_TZ_API_ERR');
         FND_MESSAGE.Set_Token('API_NAME',l_api_name_full);
         l_msg := fnd_message.get ;
         fnd_file.put_line(fnd_file.log,'     ' || l_msg);
         EXIT ;
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_time_lag  := abs(l_time_lag);
       ELSE
          l_time_lag := 0;
       END IF;
     ELSE  /* l_contact_timezone_id or l_supp_timezone_id is not null*/
       l_time_lag := 0;
     END IF;  /* l_contact_timezone_id or l_supp_timezone_id is missing */

     -- New formula for time lag for OSS ,as  given in enhancement 2093850
      -- Added weight multiplication and support timezone id check for Bug# 3526252
      IF (l_supp_timezone_id IS NULL) THEN
        l_time_lag_score := 0;
      ELSE
        l_time_lag_score := ROUND(2.77 - (l_time_lag/4)) * NVL(l_wt_time_zone_lag,0);
      END IF;

     -- calculate total load for each
     -- Added nvl for all the weights 11.5.9
     l_res_load :=
       ((NVL(l_prod_skill,0)     * NVL(l_wt_prd_skill,0))       +
       (NVL(l_plat_skill,0)      * NVL(l_wt_plt_skill,0))       +
       (NVL(l_prob_skill,0)      * NVL(l_wt_pbm_skill,0))       +
       (NVL(l_cat_skill,0)       * NVL(l_wt_cat_skill,0))       +
       (NVL(l_time_last_login,0) * NVL(l_wt_time_last_login,0)) +
       (NVL(l_backlog_sev1,0)    * NVL(l_wt_backlog_sev1,0))    +
       (NVL(l_backlog_sev2,0)    * NVL(l_wt_backlog_sev2,0))    +
       (NVL(l_backlog_sev3,0)    * NVL(l_wt_backlog_sev3,0))    +
       (NVL(l_backlog_sev4,0)    * NVL(l_wt_backlog_sev4,0))    +
       (NVL(l_time_lag_score,0)  * NVL(l_wt_time_zone_lag,0)));

     -- copy values into table
     p_res_load_table(l_tbl_index).product_skill_level   := l_prod_skill;
     p_res_load_table(l_tbl_index).platform_skill_level  := l_plat_skill;
     p_res_load_table(l_tbl_index).pbm_code_skill_level  := l_prob_skill;
     p_res_load_table(l_tbl_index).category_skill_level  := l_cat_skill;
     p_res_load_table(l_tbl_index).time_since_last_login := l_time_last_login;
     p_res_load_table(l_tbl_index).backlog_sev1          := l_backlog_sev1;
     p_res_load_table(l_tbl_index).backlog_sev2          := l_backlog_sev2;
     p_res_load_table(l_tbl_index).backlog_sev3          := l_backlog_sev3;
     p_res_load_table(l_tbl_index).backlog_sev4          := l_backlog_sev4;
     p_res_load_table(l_tbl_index).time_zone_lag         := l_time_lag;
     p_res_load_table(l_tbl_index).total_load            := l_res_load;

     l_tbl_index := l_tbl_index + 1;
   END LOOP;
   -- After the load for all resources are calculated find the
   -- resource with the max load.This is the winning resource to
   -- be returned
   -- If timezone API does not give error then proceed

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     --i := 0;
     -- Added this because if all the resource loads are 0,
     -- l_max_record_index is always the first resource.
     l_max_record_index := p_res_load_table.FIRST;

    -- Bug 4907196 . The value of l_max_total_load is changed to -9999999 from 0.
    -- Total load can have negative values hence the initial value shouldn't be 0
    l_max_total_load   := -999999999;

     /* Commented out for Bug# 4017138
     FOR i IN 1..p_res_load_table.COUNT LOOP
       IF (i = 1 ) THEN
         l_max_total_load   := p_res_load_table(i).total_load ;
         l_max_record_index := i ;
       ELSE
         IF (p_res_load_table(i).total_load > l_max_total_load) THEN
	   l_max_total_load := p_res_load_table(i).total_load;
           l_max_record_index := i;
         END IF;
       END IF;
     END LOOP ;
     */
     IF (p_res_load_table.COUNT > 0) THEN
       FOR i IN p_res_load_table.FIRST..p_res_load_table.LAST LOOP
         IF ( p_res_load_table.COUNT = 1 ) THEN
           l_max_total_load   := p_res_load_table(i).total_load ;
           l_max_record_index := i ;
         ELSE
           IF (p_res_load_table(i).total_load > l_max_total_load) THEN
             l_max_total_load   := p_res_load_table(i).total_load;
             l_max_record_index := i;
           END IF;
         END IF;
       END LOOP ;
     END IF;
     x_resource_id   := p_res_load_table(l_max_record_index).resource_id;
     x_resource_type := p_res_load_table(l_max_record_index).resource_type;
     x_territory_id  :=  p_res_load_table(l_max_record_index).territory_id;
     IF (x_resource_id IS NOT NULL) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS ;
     ELSIF(x_resource_id IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE -- x_return_status is success loop
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   END IF;

END Calculate_Load;

END CS_ASSIGN_RESOURCE_CON_PKG;

/
